*&---------------------------------------------------------------------*
*& Include          ZVSS_ORDER_DETAIL_EVT_NEW
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  DATA: lv_stime       TYPE sy-uzeit,
        lv_etime       TYPE sy-uzeit,
        lv_werks       TYPE werks,
        lobj_reg_root  TYPE REF TO lcl_registry_entry,
        lobj_reg_entry TYPE REF TO lcl_registry_entry,

        lv_flags.

  CLEAR: lv_stime,  lv_etime,lv_flags.
  " Get time range

  SELECT SINGLE * FROM tvarvc CLIENT SPECIFIED
     INTO @DATA(ls_tvarvc)
     WHERE mandt = '000'
       AND name = 'ZPOTR_RPT_OFF_TIME'.
  IF sy-subrc = 0.
    IF ls_tvarvc-low IS NOT INITIAL.
      lv_stime = ls_tvarvc-low.
    ENDIF.
    IF ls_tvarvc-high IS NOT INITIAL.
      lv_etime = ls_tvarvc-high.
    ENDIF.
  ENDIF.

  IF p_rd1 = 'X' AND p_rd2 IS INITIAL.  "DBE order selected
    CLEAR:   p_po-low,p_pr-low , p_pdat-low ,p_pdat-high.
*    IF p_ordr-low IS INITIAL AND p_ddat-low IS INITIAL AND p_ddat-high IS INITIAL.
*      MESSAGE 'Please enter DBE order or DBE doucment date ' TYPE 'I'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.

    CLEAR: lv_days.
    IF p_ddat-high IS NOT INITIAL AND p_ddat-low IS NOT INITIAL.
      CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
        EXPORTING
          date1                       = p_ddat-high
          date2                       = p_ddat-low
          output_format               = '03'
        IMPORTING
*         YEARS                       =
*         MONTHS                      =
          days                        = lv_days
        EXCEPTIONS
          overflow_long_years_between = 1
          invalid_dates_specified     = 2
          OTHERS                      = 3.

      IF sy-batch IS INITIAL AND lv_days GT 180 .
        IF p_email IS INITIAL.                                                         " shahid added following lines till end.8100004362.
          MESSAGE 'DBE document date range should not be more than 180 days' TYPE 'I'.
          LEAVE LIST-PROCESSING.
        ENDIF.
      ELSEIF sy-batch IS NOT INITIAL AND  lv_days GT 180 .
        IF sy-uzeit GT lv_stime AND  sy-uzeit LT lv_etime.
          MESSAGE 'The background JOb execustion cancelled due to exceeded number of Date Range(> 60 days) in the wroking hours . ' TYPE 'E'.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

  ELSEIF p_rd2 IS NOT INITIAL AND p_rd1 IS INITIAL.

    CLEAR: p_ordr-low , p_ddat-low , p_ddat-high.
    IF p_po-low IS INITIAL AND p_pr-low IS INITIAL AND p_pdat-low IS INITIAL AND p_pdat-high IS INITIAL.
      MESSAGE 'Please enter Purchase Order or Purchase Order date or Purchase Requisition' TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.

    CLEAR: lv_days.
    IF p_pdat-high IS NOT INITIAL AND p_pdat-low IS NOT INITIAL.
      CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
        EXPORTING
          date1                       = p_pdat-high
          date2                       = p_pdat-low
          output_format               = '03'
        IMPORTING
*         YEARS                       =
*         MONTHS                      =
          days                        = lv_days
        EXCEPTIONS
          overflow_long_years_between = 1
          invalid_dates_specified     = 2
          OTHERS                      = 3.

      IF sy-batch IS INITIAL AND lv_days GT 180 .
        MESSAGE 'PO date range should not be more than 180 days' TYPE 'I'.
        LEAVE LIST-PROCESSING.

      ELSEIF sy-batch IS NOT INITIAL AND lv_days GT 180.

        IF sy-uzeit GT lv_stime AND  sy-uzeit LT lv_stime.
          MESSAGE 'You can not run this report background at this time. ' TYPE 'E'.
          RETURN.
        ENDIF.

      ENDIF.
    ENDIF.

  ENDIF.

  IF  p_plant-low IS INITIAL AND  ( p_pr-low IS INITIAL AND  p_ordr-low IS INITIAL ).
    MESSAGE 'Please enter Plant ' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ELSE.
    IF p_plant-low IS NOT INITIAL.
      SELECT SINGLE * FROM t001w INTO @DATA(wa) WHERE werks = @p_plant-low.
      IF sy-subrc NE 0.
        MESSAGE 'Please enter correct Plant ' TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
  ENDIF.


*get Standard order details
  IF p_rd1 IS NOT INITIAL .   "DBE order selctionn
    PERFORM f_get_order_details.
  ELSE.    "puchase order selection
    PERFORM f_get_po_details.
  ENDIF.

  PERFORM f_fill_data.

** Display result in ALV
  IF sy-batch IS INITIAL.
    IF p_email IS INITIAL.      " shahid added following lines till end.8100004362.
      PERFORM f_display_alv.
    ENDIF.
  ELSE.
    PERFORM f_email.  "send email with attachement
  ENDIF.

* shahid added following lines till end.8100004362.

  CHECK p_email = 'X'.

  LOOP AT it_order INTO ts_order.  "WHERE po_status = 'GR Completed'.
    ts_pono-vbeln = ts_order-vbeln.
    ts_pono-jobs = ts_order-jobs.
    APPEND ts_pono TO lt_pono.
  ENDLOOP.

  SORT lt_pono BY vbeln jobs.
  DELETE ADJACENT DUPLICATES FROM lt_pono COMPARING vbeln jobs.

  LOOP AT lt_pono INTO ts_pono.
    CLEAR lv_flag.
    LOOP AT it_order INTO ts_order WHERE vbeln = ts_pono-vbeln AND jobs = ts_pono-jobs.
      IF ts_order-po_status = 'GR Completed'.
        CONTINUE.
      ELSE.
        lv_flag = 1.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_flag = 0.
      "here all items of po is having po status as 'GR Completed' for same job#
      APPEND ts_pono TO lt_pono2.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_pono2 INTO ts_pono.
    CLEAR lv_flag.
    LOOP AT it_order INTO ts_order WHERE vbeln = ts_pono-vbeln AND jobs = ts_pono-jobs.
      IF ts_order-del_stat IS INITIAL.
        lv_flag = 1.
        EXIT.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDLOOP.
    IF lv_flag = 1.
      "here all items of po is having po status as 'GR Completed' for same job#
      APPEND ts_pono TO lt_pono3.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_pono3 INTO ts_pono.
    LOOP AT it_order INTO ts_order WHERE vbeln = ts_pono-vbeln.
      ts_email-werks = ts_order-werks.
      ts_email-pernr = ts_order-pernr.
      APPEND ts_email TO lt_email.
    ENDLOOP.
  ENDLOOP.

  CHECK lt_email IS NOT INITIAL.

  lt_email2[] = lt_email[].
  SORT lt_email  BY pernr.
  DELETE ADJACENT DUPLICATES FROM lt_email COMPARING pernr.

  LOOP AT lt_email INTO ts_email.
    lv_sv_adv_rm = 'SA'.  "service advisor
    PERFORM f_email.
  ENDLOOP.

  SORT lt_email2 BY werks.

  TRY .
      CLEAR: fs_extra_data.
      lobj_reg_root = lcl_registry_entry=>get_root( ).
      IF lobj_reg_root IS BOUND.
        lobj_reg_entry = lobj_reg_root->get_subentry( 'MM' )->get_subentry( 'Enhancement' )->get_subentry( 'YPOTR_Email_Notification' ).
        IF lobj_reg_entry IS NOT INITIAL.
          lint_extra_data = lobj_reg_entry->get_values( ).
        ENDIF.
      ENDIF.
    CATCH cx_root.

  ENDTRY.
  IF lint_extra_data IS NOT INITIAL.
    LOOP AT lt_email2 INTO ts_email.
      lv_werks = ts_email-werks.
      READ TABLE lint_extra_data INTO fs_extra_data WITH KEY key = lv_werks.
      IF sy-subrc = 0.
        ts_email-email_dl = fs_extra_data-value.
        MODIFY lt_email2 FROM ts_email.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT lt_email2 BY email_dl.
  DELETE ADJACENT DUPLICATES FROM lt_email2 COMPARING email_dl.
  CLEAR lv_flag.
  LOOP AT lt_email2 INTO ts_email.
       IF ts_email-email_dl IS INITIAL.
          lv_flag = 1.
          exit.
       ENDIF.
  ENDLOOP.

  IF lv_flag = 1.
     MESSAGE 'Please set up ZREG for email distribution list for regional managers. ' TYPE 'E'.
     RETURN.
  ENDIF.

  LOOP AT lt_email2 INTO ts_email.

    CALL FUNCTION 'SO_DLI_READ_API1'
      EXPORTING
        dli_name    = ts_email-email_dl
*       DLI_ID      = ' '
        shared_dli  = 'X'
*                    IMPORTING
*       DLI_DATA    =
      TABLES
        dli_entries = dli_entries
*   EXCEPTIONS
*       DLI_NOT_EXIST                    = 1
*       OPERATION_NO_AUTHORIZATION       = 2
*       PARAMETER_ERROR                  = 3
*       X_ERROR     = 4
*       OTHERS      = 5
      .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    LOOP AT dli_entries INTO dls_entries.
      MOVE-CORRESPONDING dls_entries TO dls_entries2.
      APPEND dls_entries2 TO dli_entries2.
    ENDLOOP.
  ENDLOOP.

  LOOP AT dli_entries2 INTO dls_entries.
    lv_sv_adv_rm = 'RM'.  "Regional Manager
    PERFORM f_email.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& Include          ZIINVENTORY_UPLOAD_FORM
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  F_FILE_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_file_value .

  DATA: l_rc         TYPE i,                                                      "RC Value
        l_select     TYPE string,                                                 "Select File
        lt_file_name TYPE STANDARD TABLE OF file_table.
  l_select = TEXT-002.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog                         "Selection screen file value help
    EXPORTING
      window_title            = l_select
*     default_filename        = ca_txt
      multiselection          = abap_true
    CHANGING
      file_table              = lt_file_name
      rc                      = l_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> ca_check.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  IF lt_file_name IS NOT INITIAL.
*Assign file names to selection screen field
    LOOP AT lt_file_name INTO wa_file_name.
      p_fname = wa_file_name-filename.
      CLEAR wa_file_name.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_AT_SEL_SCR_ON_VAL_REQ_PI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FNAME  text
*----------------------------------------------------------------------*
FORM f_at_sel_scr_on_val_req_pi  USING p_fname TYPE rlgrap-filename.

  DATA : l_fname TYPE localfile.

  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = l_fname
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  p_fname =  l_fname.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_loaddata.

  IF rb_pi IS INITIAL.
    PERFORM f_read_file.
  ELSE.
    PERFORM f_extract_data_pi.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_READ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_read_file .
  DATA: lv_extension TYPE char3.

  IF p_fname IS NOT INITIAL.
    CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
      EXPORTING
        filename  = p_fname
      IMPORTING
        extension = lv_extension.
    TRANSLATE lv_extension TO UPPER CASE.
    IF lv_extension <> lc_csv AND lv_extension <> lc_txt .
      MESSAGE e068(ymsg_jet_dbm). "File Extension of file is not supported.
    ELSE.
      IF lv_extension = lc_csv.
        lv_tab = lc_comma.
      ENDIF.
    ENDIF.
  ENDIF.

  DATA: l_filename TYPE string.                                               "File Name
  l_filename = p_fname.
  CONSTANTS: lc_err_msg TYPE c VALUE 'E'.

  CALL METHOD cl_gui_frontend_services=>gui_upload                            "Read file data into SAP.
    EXPORTING
      filename                = l_filename
      filetype                = ca_ftype
    CHANGING
      data_tab                = i_file_data
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc <> 0.
    CLEAR ls_log.
    ls_log-type = sy-msgty.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ls_log-message.
    APPEND ls_log TO lt_log.
  ENDIF.

  IF i_file_data IS INITIAL.
    MESSAGE TEXT-036 TYPE  lc_err_msg.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_EXTRACT_DATA_PI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_extract_data_pi .

  DATA : lw_row      TYPE string.
  DATA: lv_extension TYPE char3.
  DATA: lr_exref     TYPE REF TO cx_sy_conversion_codepage.
  DATA: lr_eref      TYPE REF TO cx_root.
  DATA: lv_count     TYPE i.
  DATA: lv_msg       TYPE string.

  IF p_fname IS NOT INITIAL.
    CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
      EXPORTING
        filename  = p_fname
      IMPORTING
        extension = lv_extension.
    TRANSLATE lv_extension TO UPPER CASE.
    IF lv_extension <> lc_csv AND lv_extension <> lc_txt .
      MESSAGE e068(ymsg_jet_dbm). "File Extension of file is not supported.
    ELSE.
      IF lv_extension = lc_csv.
        lv_tab = lc_comma.
      ENDIF.
    ENDIF.
  ENDIF.
  TRY.
      OPEN DATASET p_fname FOR INPUT IN TEXT MODE ENCODING UTF-8.
      IF sy-subrc IS INITIAL.
        DO.
          TRY.
              lv_count = lv_count + 1.
              READ DATASET p_fname INTO lw_row.
              IF sy-subrc NE 0.
                EXIT.
              ELSE.
                wa_file_data = lw_row.
                APPEND wa_file_data TO i_file_data.
                CLEAR wa_file_data.
              ENDIF.
            CATCH:cx_sy_conversion_codepage INTO lr_exref.
              CLEAR ls_log.
              ls_log-type = 'E'.
              lv_msg = lr_exref->if_message~get_longtext( ).
              MESSAGE e179(ymsg_jet_dbm) WITH lv_count INTO ls_log-message.
              CONCATENATE ls_log-message lv_msg INTO ls_log-message SEPARATED BY ','.
              APPEND ls_log TO lt_log.
            CATCH cx_root INTO lr_eref.
              CLEAR ls_log.
              ls_log-type = 'E'.
              lv_msg = lr_eref->if_message~get_longtext( ).
              MESSAGE e179(ymsg_jet_dbm) WITH lv_count INTO ls_log-message.
              CONCATENATE ls_log-message lv_msg INTO ls_log-message SEPARATED BY ','.
              APPEND ls_log TO lt_log.
          ENDTRY.
        ENDDO.
        CLOSE DATASET p_fname.
      ENDIF.
*    CATCH:cx_sy_conversion_codepage INTO lr_exref.
*      CLEAR ls_log.
*      lv_msg = lr_exref->if_message~get_longtext( ).
*      MESSAGE e179(ymsg_jet_dbm) WITH lv_count INTO ls_log-message.
*      CONCATENATE ls_log-message lv_msg INTO ls_log-message SEPARATED BY ','.
*      APPEND ls_log TO lt_log.
    CATCH cx_root INTO lr_eref.
      CLEAR ls_log.
      ls_log-type = 'E'.
      lv_msg = lr_eref->if_message~get_longtext( ).
      CONCATENATE ls_log-message lv_msg INTO ls_log-message.
      APPEND ls_log TO lt_log.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data.
  DATA : lt_events2 TYPE slis_t_event.
  DATA : ts_events2 TYPE slis_alv_event.
  DATA ts_log TYPE ty_log.
  DATA ls_gm_code TYPE bapi2017_gm_code.
  DATA lr_eref TYPE REF TO cx_root.
  DATA lv_count TYPE i.
  DATA lv_msg TYPE string.
  ls_gm_code-gm_code = '05'.

*  ts_log-matnr =  TEXT-l01.
*  ts_log-type  = TEXT-l02.
*  ts_log-mblnr =  TEXT-l03.
*  ts_log-message =  TEXT-l04.
*  APPEND ts_log TO lt_log.


  LOOP AT i_file_data INTO wa_file_data FROM 2.
    TRY.
*        lv_count = lv_count + 1.
        SPLIT wa_file_data  AT lv_tab INTO wa_file_value-bldat
                                           wa_file_value-budat
                                           wa_file_value-bktxt
                                           wa_file_value-bwart
                                           wa_file_value-werks
                                           wa_file_value-lgort
                                           wa_file_value-xnapr
                                           wa_file_value-wever
                                           wa_file_value-matnr
                                           lv_quantity "wa_file_value-menge
                                           wa_file_value-charg
                                           lv_split1 "wa_file_value-ext_cu
                                           wa_file_value-sgtxt
                                           wa_file_value-fmore
                                           wa_file_value-ref_doc_no
                                           wa_file_value-bill_of_lading.
*
        wa_file_value-menge = lv_quantity.
        wa_file_value-ext_cu = lv_split1.
        APPEND wa_file_value TO i_file_value .

        CLEAR: wa_file_data, lv_quantity,lv_split1.
      CATCH cx_root INTO lr_eref.
        CLEAR ls_log.
        ls_log-type = 'E'.
        lv_msg = lr_eref->if_message~get_longtext( ).
        MESSAGE e180(ymsg_jet_dbm) WITH wa_file_value-matnr INTO ls_log-message.
        CONCATENATE ls_log-message lv_msg INTO ls_log-message SEPARATED BY ','.
        APPEND ls_log TO lt_log.
    ENDTRY.
  ENDLOOP.

  LOOP  AT i_file_value INTO wa_file_value.
    TRY.
*        lv_count = 0.
*        lv_count = lv_count + 1.
        CONCATENATE wa_file_value-bldat+6(4) wa_file_value-bldat+3(2) wa_file_value-bldat+0(2) INTO date_f.
        ls_gv_header-pstng_date = date_f.
        CLEAR date_f.
        CONCATENATE wa_file_value-budat+6(4) wa_file_value-budat+3(2) wa_file_value-budat+0(2) INTO date_f.
        ls_gv_header-doc_date = date_f.
        ls_gv_header-header_txt = wa_file_value-bktxt.

        ls_gv_header-ver_gr_gi_slip = wa_file_value-wever.
        ls_gv_header-ver_gr_gi_slipx = abap_true.
        ls_gv_header-ref_doc_no = wa_file_value-ref_doc_no.
        ls_gv_header-bill_of_lading = wa_file_value-bill_of_lading.

        ls_log-matnr = wa_file_value-matnr.

        CALL FUNCTION 'CONVERSION_EXIT_MATN2_INPUT'
          EXPORTING
            input  = wa_file_value-matnr
          IMPORTING
            output = ls_gv_item-material.
        IF ls_gv_item-material  IS INITIAL.
          ls_gv_item-material = wa_file_value-matnr.
        ENDIF.

        " = wa_file_value-matnr.

        ls_gv_item-plant = wa_file_value-werks.
        ls_gv_item-stge_loc = wa_file_value-lgort.
        ls_gv_item-move_type = wa_file_value-bwart.
        ls_gv_item-entry_qnt = wa_file_value-menge.
        ls_gv_item-batch =  wa_file_value-charg.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_gv_item-batch
          IMPORTING
            output = ls_gv_item-batch.


        ls_gv_item-amount_lc = wa_file_value-ext_cu.
        ls_gv_item-item_text = wa_file_value-sgtxt.
        APPEND ls_gv_item TO lt_gv_item.
        CLEAR ls_gv_item.

        CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
          EXPORTING
            goodsmvt_header  = ls_gv_header
            goodsmvt_code    = ls_gm_code
          IMPORTING
            goodsmvt_headret = ls_dv_headret
            materialdocument = lv_mat_doc
            matdocumentyear  = lv_mat_doc_year
          TABLES
            goodsmvt_item    = lt_gv_item
            return           = i_return.

*    READ TABLE i_return INTO wa_return WITH KEY type = 'S'.
        CLEAR ls_log.
        ls_log-matnr = wa_file_value-matnr.
        IF i_return IS INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.

          ls_log-type = 'S'.
          ls_log-mblnr   =  lv_mat_doc.
          ls_log-message = TEXT-s04.

        ELSE.
          ls_log-type = 'E'.
          LOOP AT i_return INTO wa_return WHERE type EQ 'E'.
            CONCATENATE ls_log-message ' ' wa_return-message INTO ls_log-message." RESPECTING BLANKS.
          ENDLOOP.
        ENDIF.
        APPEND ls_log TO lt_log.
*      CLEAR :  lv_inc, wa_header, wa_headerx.
*      REFRESH : i_return, i_item, i_itemx, i_poshedule, i_poshedulex, i_poaccount, i_poaccountx.
*    ENDAT.
        CLEAR :wa_file_value,ls_gv_header,lt_gv_item.
      CATCH cx_root INTO lr_eref.
        CLEAR ls_log.
        ls_log-type = 'E'.
        lv_msg = lr_eref->if_message~get_longtext( ).
        MESSAGE e180(ymsg_jet_dbm) WITH wa_file_value-matnr INTO ls_log-message.
        CONCATENATE ls_log-message lv_msg INTO ls_log-message SEPARATED BY ','.
        APPEND ls_log TO lt_log.
    ENDTRY.
  ENDLOOP.
  lt_alv[] = lt_log[].  "alv for display and log for server log file
  DELETE lt_alv INDEX 1.
  IF lt_alv[] IS NOT INITIAL.
    PERFORM f_update_server.

    IF sy-batch IS INITIAL.
      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
        IMPORTING
          et_events = lt_events2.

      READ TABLE lt_events2 INTO ts_events2
         WITH KEY name = slis_ev_top_of_page .
      ts_events2-form = slis_ev_top_of_page .
      MODIFY lt_events2 FROM ts_events2 INDEX sy-tabix .

      PERFORM f_fill_field_catalog CHANGING it_fieldcat.

      wa_layout-zebra             = abap_true.
      wa_layout-colwidth_optimize = abap_true.



      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program     = sy-cprog
          i_callback_top_of_page = va_top
          i_grid_title           = TEXT-003
          is_layout              = wa_layout
          it_fieldcat            = it_fieldcat
          is_print               = ls_print
          it_events              = lt_events2
        TABLES
          t_outtab               = lt_alv
        EXCEPTIONS
          program_error          = 1
          OTHERS                 = 2.
      IF sy-subrc <> 0.
        CLEAR ls_log.
        ls_log-type = sy-msgty.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ls_log-message.
        APPEND ls_log TO lt_log.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       Fill field catalog for ALV
*----------------------------------------------------------------------*
*      <--P_IT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM f_fill_field_catalog  CHANGING ct_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: lw_fcat TYPE slis_fieldcat_alv.

  DEFINE m_cat ##NEEDED.
    lw_fcat-fieldname   = &1.
    lw_fcat-tabname     = &2.
    lw_fcat-seltext_l   = &3.
    lw_fcat-outputlen   = &4.
    APPEND lw_fcat TO ct_fieldcat.
  END-OF-DEFINITION.

  m_cat 'TYPE'           'LT_LOG' TEXT-004 TEXT-008.
  m_cat 'MATNR'         'LT_LOG' TEXT-005 TEXT-008.
  m_cat 'MBLNR'         'LT_LOG' TEXT-006 TEXT-008.
  m_cat 'MESSAGE'        'LT_LOG' TEXT-007 TEXT-009.

ENDFORM.
*&--------------------------------------------------------------------*
*&      Form  f_hide_field
*&--------------------------------------------------------------------*
* Hiding Fields
*---------------------------------------------------------------------*
*      -->i_va_group1  text
*---------------------------------------------------------------------*
FORM f_hide_field  USING iv_group1 ##PERF_NO_TYPE.
  LOOP AT SCREEN.
    IF screen-group1 = iv_group1.
      screen-input = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&--------------------------------------------------------------------*
*&      Form  f_unhide_field
*&--------------------------------------------------------------------*
* Unhiding Fields
*---------------------------------------------------------------------*
*      -->i_va_group1  text
*---------------------------------------------------------------------*
FORM f_unhide_field  USING iv_group1  ##PERF_NO_TYPE.
  LOOP AT SCREEN.
    IF screen-group1 = iv_group1.
      screen-input = 1.
      screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
******FORM f_update_server.
******  DATA : lw_data      TYPE  string,
******         l_path       TYPE  rcgfiletr-ftappl,
******         ts_log       TYPE  ty_log, " + Osman
******         lv_extension TYPE  char3,
******         ts_result    TYPE  match_result,
******         lv_offset    TYPE  i.
********* Success Log
*******  IF i_successful_records[] IS NOT INITIAL.
******  CLEAR: l_path, ts_result, lv_offset, lv_extension.
******
******
******  FIND FIRST OCCURRENCE OF lc_dot IN p_succ RESULTS ts_result.
******  IF sy-subrc = 0.
******    l_path = p_succ(ts_result-offset).
******    lv_offset = ts_result-offset + 1.
******    lv_extension = p_succ+lv_offset.
******  ENDIF.
******
******  CONCATENATE l_path TEXT-134
******              sy-datum sy-uzeit TEXT-132 lc_dot lv_extension INTO l_path.
******  OPEN DATASET l_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
******  IF sy-subrc IS INITIAL.
******    LOOP AT lt_log INTO ts_log WHERE type = 'S'  OR type = TEXT-l02.
******      lv_success = lv_success + 1.
******      lw_data = ts_log.
******      TRANSFER lw_data TO l_path.
******      IF sy-subrc IS NOT INITIAL.
******        EXIT.
******      ENDIF.
******    ENDLOOP.
******    lv_success = lv_success - 1.
******    CLOSE DATASET l_path.
******    IF sy-subrc = 0 ##NEEDED.
******    ENDIF.
******  ENDIF.
******  CLEAR lw_data.
*******  ENDIF.
********* Error Log
*******  IF it_failed_records[] IS NOT INITIAL.
******  CLEAR: l_path, ts_result, lv_offset, lv_extension.
******  FIND FIRST OCCURRENCE OF lc_dot IN p_error RESULTS ts_result.
******  IF sy-subrc = 0.
******    l_path = p_error(ts_result-offset).
******    lv_offset = ts_result-offset + 1.
******    lv_extension = p_error+lv_offset.
******  ENDIF.
******  CONCATENATE l_path TEXT-133
******              sy-datum sy-uzeit TEXT-132 lc_dot lv_extension INTO l_path.
******  OPEN DATASET l_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
******  IF sy-subrc IS INITIAL.
******    LOOP AT lt_log INTO ts_log WHERE type = 'E' OR type = TEXT-l02.
******      lv_error = lv_error + 1.
******      lw_data = ts_log.
******      TRANSFER lw_data TO l_path.
******      IF sy-subrc IS NOT INITIAL.
******        EXIT.
******      ENDIF.
******    ENDLOOP.
******    lv_error = lv_error - 1.
******    CLOSE DATASET l_path.
******    IF sy-subrc = 0 ##NEEDED.
******    ENDIF.
******  ENDIF.
******
*******  ENDIF.
******ENDFORM.


**********************************************************************
*Changed By : Clinton.                                               *
*User : TECH 5.                                                      *
*Date : 07/07/2017                                                   *
**********************************************************************
FORM f_update_server .
  CONSTANTS: lc_dot           TYPE char01 VALUE '.',
             lc_pattern       TYPE string VALUE '(.*)(\.{1}(?:csv|txt){1})$', " end with extension
             lc_path          TYPE string VALUE '(.*)(\.{1}(?:csv|txt){1})$', " end with extension
             lc_last_f_sls    TYPE string VALUE '.*/$', "end with /
             lc_not_full_path TYPE string VALUE '(\.\w+)?$'.
  DATA : lw_data                TYPE  string,
         l_path                 TYPE  string,
         lv_extension           TYPE  char5,
         ls_result              TYPE  match_result,
         lv_offset              TYPE  i,
         lv_off                 TYPE i,
         lv_len                 TYPE i,
         lt_result_tab          TYPE match_result_tab,
         ts_submatch_result_tab TYPE match_result,
         lv_sub_path_file       TYPE string,
         lv_sub_path_extension  TYPE string,
         lv_user_path           TYPE string,
         lv_ext_tmp             TYPE string,
         lv_file                TYPE string.
*** Success Log
*  IF i_successful_records[] IS NOT INITIAL.
  CLEAR: l_path, ls_result, lv_offset, lv_extension,lv_user_path.
  "copy path to local variable type string to omit succedding string space.
  lv_user_path = p_succ.


  CALL METHOD zcl_common_util=>get_path_params
    EXPORTING
      iv_path      = p_succ
    IMPORTING
      ev_directory = lv_sub_path_file
      ev_file_name = lv_file
      ev_extension = lv_sub_path_extension.

*  "fetch the file path and extension from the string using REGEX
*  FIND REGEX lc_pattern IN lv_user_path IGNORING CASE
*                   SUBMATCHES lv_sub_path_file lv_sub_path_extension .
*  IF sy-subrc = 0 AND lv_sub_path_extension IS NOT INITIAL . " found extension
*    lv_extension = lv_sub_path_extension.
*    l_path = lv_sub_path_file.
*  ELSE. " extension not found (.CSV or .TXT)
*    lv_extension = '.txt'.
*    "check its not full path
*    CLEAR lv_ext_tmp.
*    FIND REGEX lc_not_full_path IN lv_user_path IGNORING CASE RESULTS lt_result_tab  SUBMATCHES lv_ext_tmp  .
*
*    IF sy-subrc = 0 AND lv_ext_tmp IS INITIAL. " it is not an extension or wrong extension
*      READ TABLE lt_result_tab INTO ts_submatch_result_tab INDEX 1.
*      l_path = lv_user_path(ts_submatch_result_tab-offset).
*
*      "check if path has the last /
*      "if not it will be added here
*      FIND REGEX lc_last_f_sls IN l_path IGNORING CASE.
*      IF sy-subrc <> 0 . " there is no "/
*        "add /
*        CONCATENATE l_path '/' INTO l_path.
*      ENDIF.
*
*    ELSEIF lv_ext_tmp IS NOT INITIAL .
*      READ TABLE lt_result_tab INTO ts_submatch_result_tab INDEX 1.
*      l_path = lv_user_path(ts_submatch_result_tab-offset).
*    ENDIF.
*
*  ENDIF.

**********************************************************************

  CONCATENATE lv_sub_path_file lv_file TEXT-134
*  CONCATENATE l_path TEXT-134
*          TEXT-130 TEXT-145
              sy-datum sy-uzeit
*              TEXT-132
              lv_sub_path_extension INTO l_path.
*              lv_extension INTO l_path.
  OPEN DATASET l_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc IS INITIAL.
    lw_data = TEXT-e01.
    TRANSFER lw_data TO l_path.
    LOOP AT lt_log INTO ls_log WHERE type = 'S'.
*      MOVE-CORRESPONDING lw_successful_records TO lw_successful_records_1.
      lw_data = ls_log.
      TRANSFER lw_data TO l_path.
      IF sy-subrc IS NOT INITIAL.
        EXIT.
      ENDIF.
      lv_success = lv_success + 1.
    ENDLOOP.
    CLOSE DATASET l_path.
    IF sy-subrc = 0 ##NEEDED.
    ENDIF.
  ENDIF.
  CLEAR lw_data.

  CLEAR: l_path, ls_result, lv_offset, lv_extension,lv_extension,lv_user_path.
  "copy path to local variable type string to omit succedding string space.
  lv_user_path = p_error.

  CALL METHOD zcl_common_util=>get_path_params
    EXPORTING
      iv_path      = p_error
    IMPORTING
      ev_directory = lv_sub_path_file
      ev_file_name = lv_file
      ev_extension = lv_sub_path_extension.

*  "fetch the file path and extension from the string using REGEX
*  FIND REGEX lc_pattern IN lv_user_path IGNORING CASE
*                   SUBMATCHES lv_sub_path_file lv_sub_path_extension .
*  IF sy-subrc = 0 AND lv_sub_path_extension IS NOT INITIAL . " found extension
*    lv_extension = lv_sub_path_extension.
*    l_path = lv_sub_path_file.
*  ELSE. " extension not found (.CSV or .TXT)
*    lv_extension = '.txt'.
*    "check its not full path
*    CLEAR lv_ext_tmp.
*    FIND REGEX lc_not_full_path IN lv_user_path IGNORING CASE RESULTS lt_result_tab  SUBMATCHES lv_ext_tmp  .
*
*    IF sy-subrc = 0 AND lv_ext_tmp IS INITIAL. " it is not an extension or wrong extension
*      READ TABLE lt_result_tab INTO ts_submatch_result_tab INDEX 1.
*      l_path = lv_user_path(ts_submatch_result_tab-offset).
*
*      "check if path has the last /
*      "if not it will be added here
*      FIND REGEX lc_last_f_sls IN l_path IGNORING CASE.
*      IF sy-subrc <> 0 . " there is no "/
*        "add /
*        CONCATENATE l_path '/' INTO l_path.
*      ENDIF.
*
*    ELSEIF lv_ext_tmp IS NOT INITIAL .
*      READ TABLE lt_result_tab INTO ts_submatch_result_tab INDEX 1.
*      l_path = lv_user_path(ts_submatch_result_tab-offset).
*    ENDIF.
*  ENDIF.

  CONCATENATE lv_sub_path_file lv_file TEXT-135 sy-datum sy-uzeit lv_sub_path_extension INTO l_path.
*  CONCATENATE l_path TEXT-135 sy-datum sy-uzeit lv_extension INTO l_path.
  OPEN DATASET l_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc IS INITIAL.
    lw_data = TEXT-e01.
    TRANSFER lw_data TO l_path.
    LOOP AT lt_log INTO ls_log WHERE type = 'E'.
*      MOVE-CORRESPONDING lw_successful_records TO lw_successful_records_1.
      lw_data = ls_log.
      TRANSFER lw_data TO l_path.
      IF sy-subrc IS NOT INITIAL.
        EXIT.
      ENDIF.
      lv_error = lv_error + 1.
    ENDLOOP.
    CLOSE DATASET l_path.
    IF sy-subrc = 0 ##NEEDED.
    ENDIF.
  ENDIF.


ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM top_of_page .

  DATA: it_header TYPE slis_t_listheader,
        wa_header TYPE slis_listheader,
        lv_lines  TYPE n,
        lv_date   TYPE char15.

  DESCRIBE TABLE lt_alv LINES lv_lines.

  wa_header-typ = 'S'.
  wa_header-key = TEXT-s01.
  wa_header-info = lv_lines.
  APPEND wa_header TO it_header.
  CLEAR wa_header.

  wa_header-typ = 'S'.
  wa_header-key = TEXT-s02.
  wa_header-info = lv_success.
  APPEND wa_header TO it_header.
  CLEAR wa_header.

  wa_header-typ = 'S'.
  wa_header-key =  TEXT-s03.
  wa_header-info = lv_error.
  APPEND wa_header TO it_header.
  CLEAR wa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_header.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_PHYSICAL_FILE_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LOGICAL_PATH  text
*----------------------------------------------------------------------*
FORM get_physical_file_name  USING
       p_logical_path TYPE fileintern
      CHANGING cv_file TYPE localfile.

  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      logical_filename = p_logical_path
    IMPORTING
      file_name        = cv_file.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_LOG_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_log_path .
  DATA : lv_succ_directory  TYPE string,
         lv_error_directory TYPE string.

  IF p_slogic IS NOT INITIAL.
    PERFORM get_physical_file_name
                                      USING
                                         p_slogic
                                      CHANGING
                                         p_succ.
  ENDIF.
  IF p_elogic IS NOT INITIAL.
    PERFORM get_physical_file_name
                                  USING
                                     p_elogic
                                  CHANGING
                                     p_error.
  ENDIF.


  CALL METHOD zcl_common_util=>get_path_params
    EXPORTING
      iv_path      = p_succ
    IMPORTING
      ev_directory = lv_succ_directory.



  OPEN DATASET lv_succ_directory FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc  <> 0.
*    MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*            TYPE    'E'
*            NUMBER  027
*            WITH    TEXT-l10.
  ENDIF.
  CLOSE DATASET lv_succ_directory.

  CALL METHOD zcl_common_util=>get_path_params
    EXPORTING
      iv_path      = p_error
    IMPORTING
      ev_directory = lv_error_directory.

  OPEN DATASET lv_error_directory FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc  <> 0.
*    MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*            TYPE    'E'
*            NUMBER  027
*            WITH    TEXT-l11.
  ENDIF.
  CLOSE DATASET lv_error_directory.
ENDFORM.

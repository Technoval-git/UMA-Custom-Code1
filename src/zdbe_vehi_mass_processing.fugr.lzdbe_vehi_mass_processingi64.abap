*&---------------------------------------------------------------------*
*&      Module  M_GET_ACCTYP_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_get_acctyp_0800 INPUT.
  DATA:  lv_mandat             TYPE abap_bool.
  PERFORM get_acctyp_0800.

ENDMODULE.                    "m_get_acctyp_0800 INPUT
*&---------------------------------------------------------------------*
*&      Form  get_acctyp_0800
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_acctyp_0800.
  CONSTANTS:
     lc_acc_type_cost      TYPE  /DBE/work_type VALUE '1',
     lc_acc_type_costce    TYPE  /DBE/work_type VALUE '2',
     lc_acc_type_intord    TYPE  /DBE/work_type VALUE '3'.

  DATA :
    lt_company            TYPE STANDARD TABLE OF /DBE/c_company,
    ls_company            TYPE /DBE/c_company,
    ls_cskt               TYPE cskt,
    ls_costcenter         TYPE ty_acc_ccf4,
    lv_cc_count           TYPE i,
    lv_lines              TYPE i,
    ls_aac_data           TYPE /DBE/co_acc,
    ls_assigcat           TYPE /DBE/s_acas_typ,
    lt_vrm_kostl_values   TYPE STANDARD TABLE OF vrm_value,
    ls_vrm_kostl_values   TYPE vrm_value,
    lt_vrm_empge_values   TYPE STANDARD TABLE OF vrm_value,
    ls_vrm_empge_values   TYPE vrm_value,
    ls_aac_cc             TYPE ty_acc_ccf4,
    ls_incoming_action    TYPE vlcc_cvlc03_ps,
    ls_elementary_action  TYPE vlcc_cvlc03_ps,
    ls_vlcactdata_head_s  TYPE vlcactdata_head_s,
    ls_vlcactdata_item_s  TYPE vlcactdata_item_s,
    vlcactdata_cs         TYPE vlcactdata,
    lt_vlcstatus          TYPE TABLE OF vlcstatus ,
    ls_vlcstatus          TYPE vlcstatus,
    cvlc03_ls             LIKE cvlc03,
    ls_co_acc             TYPE /DBE/co_acc.

  CLEAR : ls_vlcstatus,lt_vlcstatus,
          gt_aac_costcenters,
          gv_kostl,
          lt_vrm_empge_values,
          ls_vrm_empge_values.

  "Get all
  CALL FUNCTION '/DBE/C_GET_COMPANY_DATA'
    EXPORTING
      i_check_access = 'X'
    TABLES
      e_company      = lt_company
    EXCEPTIONS
      no_data_found  = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ELSE.
    READ TABLE lt_company INTO ls_company  WITH KEY werks = /DBE/vbak_com-werks  vkorg = /DBE/vbak_com-vkorg.
    IF sy-subrc = 0.
      /DBE/vbak_com-bukrs_vf = ls_company-bukrs.
    ELSE.
      CLEAR :
        /DBE/vbak_com-ac_as_typ, /DBE/vbak_com-empge, /DBE/vbak_com-kstar, /DBE/vbak_com-werks.
      MESSAGE i154(/DBE/common) WITH /DBE/vbak_com-vkorg /DBE/vbak_com-werks DISPLAY LIKE 'E'.
    ENDIF.
    IF /DBE/vbak_com-bukrs_vf IS NOT INITIAL.
*   Get KOKRS from BUKRS
      CALL FUNCTION 'RK_KOKRS_FIND'
        EXPORTING
          bukrs                  = /DBE/vbak_com-bukrs_vf
        IMPORTING
          kokrs                  = /DBE/vbak_com-kokrs
        EXCEPTIONS
          assignment_not_allowed = 1
          insufficient_input     = 2
          no_kokrs_assigned      = 3
          no_kokrs_for_bukrs     = 4
          no_kokrs_for_bu_gb     = 5
          wrong_kokrs_for_bukrs  = 6
          wrong_kokrs_for_bu_gb  = 7
          OTHERS                 = 8.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
  " find AAC type/s when user selecte order type
  IF gv_ok_code EQ gc_order_type OR gv_ok_code EQ gc_enter_fcode.
    PERFORM f_check_aac_mandfields CHANGING lv_mandat.
    IF lv_mandat EQ abap_true.
      PERFORM f_get_acctype USING '/DBE/VBAK_COM-AC_AS_TYP'.
    ENDIF.
  ENDIF.

  " find receiver/s when user selecte receiver type
  IF gv_ok_code EQ gc_aac_type .  " ok_code changed

    "get assignment category
    CALL FUNCTION '/DBE/CO_ACAS_TYP_GET'
      EXPORTING
        iv_ac_as_typ = /DBE/vbak_com-ac_as_typ
      IMPORTING
        es_acas_typ  = ls_assigcat
      EXCEPTIONS
        not_found    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CLEAR lv_cc_count.
    LOOP AT gt_aac_data INTO ls_aac_data WHERE ac_as_typ = /DBE/vbak_com-ac_as_typ.
      lv_cc_count = lv_cc_count + 1.
    ENDLOOP.

    CLEAR /DBE/vbak_com-kstar.
    IF lv_cc_count EQ 1.
      CLEAR /DBE/vbak_com-empge.

*     Clear Receiver dropdown list
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id              = '/DBE/VBAK_COM-EMPGE'
          values          = lt_vrm_empge_values
        EXCEPTIONS
          id_illegal_name = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      READ TABLE gt_aac_data INTO ls_aac_data WITH KEY ac_as_typ = /DBE/vbak_com-ac_as_typ.
      IF sy-subrc <> 0.
      ELSE.
        IF NOT ls_aac_data-function IS INITIAL.
          "check if function exist
          CALL FUNCTION 'FUNCTION_EXISTS'
            EXPORTING
              funcname           = ls_aac_data-function
            EXCEPTIONS
              function_not_exist = 1
              OTHERS             = 2.
          IF sy-subrc <> 0.
            "function does not exist, go to the standard F4
          ELSE.
            /DBE/cl_api_pdi_order=>cv_aac_fm_name = ls_aac_data-function.
          ENDIF.

        ENDIF.

        CASE ls_assigcat-typ.
          WHEN lc_acc_type_cost.
            "Only cost centre as receiver
            /DBE/vbak_com-kostl = ls_aac_data-kostl.
            /DBE/vbak_com-empge = ls_aac_data-kostl.
            /DBE/vbak_com-kunre = ls_aac_data-kunre.
          WHEN lc_acc_type_costce.
            "Cost centre as receiver + Cost Element
            /DBE/vbak_com-kostl = ls_aac_data-kostl.
            /DBE/vbak_com-empge = ls_aac_data-kostl.
            /DBE/vbak_com-kstar = ls_aac_data-kstar.
            /DBE/vbak_com-kunre = ls_aac_data-kunre.
          WHEN lc_acc_type_intord.
            "Only internal order as receiver
            /DBE/vbak_com-empge = gc_int_ord.
            /DBE/vbak_com-kunre = ls_aac_data-kunre.
        ENDCASE.
      ENDIF.
    ELSE.
      CLEAR /DBE/vbak_com-empge.
      LOOP AT gt_aac_data INTO ls_aac_data WHERE ac_as_typ = /DBE/vbak_com-ac_as_typ.
        CLEAR ls_costcenter-kostl_text.
        ls_costcenter-kostl = ls_aac_data-kostl.
        ls_costcenter-kunre = ls_aac_data-kunre.
        "Get text
        CALL FUNCTION 'READ_COSTCENTER_TEXT'
          EXPORTING
            datum          = sy-datum
            kokrs          = /DBE/vbak_com-kokrs
            kostl          = ls_aac_data-kostl
            sprache        = sy-langu
          IMPORTING
            text_wa        = ls_cskt
          EXCEPTIONS
            text_not_found = 1
            OTHERS         = 2.
        IF sy-subrc = 0.
          ls_costcenter-kostl_text = ls_cskt-ktext.
        ENDIF.
        APPEND ls_costcenter TO gt_aac_costcenters.
      ENDLOOP.
      "fill the values-table for listbox
      LOOP AT gt_aac_costcenters INTO ls_aac_cc.
        CLEAR ls_vrm_empge_values.
        ls_vrm_empge_values-key  = ls_aac_cc-kostl.
        ls_vrm_empge_values-text = ls_aac_cc-kostl_text.
        APPEND ls_vrm_empge_values TO lt_vrm_empge_values.
      ENDLOOP.
      IF lt_vrm_empge_values IS INITIAL.
        CLEAR : /DBE/vbak_com-ac_as_typ.
        CLEAR : /DBE/vbak_com-empge,/DBE/vbak_com-kokrs.
        SET CURSOR FIELD '/DBE/VBAK_COM-AC-AS-TYP'.
        MESSAGE w055(/DBE/co).
      ENDIF.
      "fill receiver dropdown values
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id              = '/DBE/VBAK_COM-EMPGE'
          values          = lt_vrm_empge_values
        EXCEPTIONS
          id_illegal_name = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDIF.
  " find cost element when user selecte receiver
  IF gv_ok_code EQ gc_receiver.    " ok_code changed
    /DBE/vbak_com-kostl = /DBE/vbak_com-empge.
    READ TABLE gt_aac_data INTO ls_aac_data WITH KEY ac_as_typ = /DBE/vbak_com-ac_as_typ kostl = /DBE/vbak_com-empge.
    IF sy-subrc EQ 0.
      /DBE/vbak_com-kstar = ls_aac_data-kstar.
      SHIFT /DBE/vbak_com-kstar LEFT DELETING LEADING '0'.
    ENDIF.
  ENDIF.
ENDFORM.                    "get_acctyp_0800
*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI64 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0800 INPUT.
  DATA: lt_ok_vlcdiavehi        TYPE TABLE OF vlcdiavehi,
        lo_pdi_order            TYPE REF TO /DBE/cl_order,
        lt_valid_orgdata        TYPE STANDARD TABLE OF /DBE/c_ord_org,
        ls_params               TYPE bal_s_parm ,
        ls_context              TYPE bal_s_cont ,
        lv_valid1               TYPE c,
        ls_order_creation       TYPE /DBE/order_creation.

  PERFORM user_command_0800.


ENDMODULE.                 " USER_COMMAND_0800  INPUT

*&---------------------------------------------------------------------*
*&      Form  user_command_0800
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM user_command_0800.
  DATA :
          lv_success_count        TYPE i,
          lv_failed_count         TYPE i,
          lo_buf1                 TYPE REF TO /DBE/cl_veh_buf,
          ls_dialog_control       TYPE /DBE/oe_dialog_control,
          ls_pdi_job              TYPE ty_pdi_ord,
          context_ls              TYPE vlcmsgcontxt,
          ls_par                  TYPE bal_s_par,
          returncode(1)           TYPE c,
          lt_bob                  TYPE /DBE/t_veh_bob,                    "N:2304203
          ls_bob                  TYPE /DBE/s_veh_bob,
          lo_veh                  TYPE REF TO /DBE/cl_veh_dbmvehicle.

  FIELD-SYMBOLS  <fs_return>    TYPE bapiret2.

  IF gv_ok_code EQ gc_order_type OR gv_ok_code EQ gc_aac_type OR gv_ok_code EQ gc_receiver   "ok_code changed
    OR sy-ucomm EQ gc_enter_fcode .
    RETURN.
  ENDIF.
  "Get all changed data from ALV
  IF go_pdi_ordcrt IS BOUND.
    go_pdi_ordcrt->check_changed_data( IMPORTING e_valid = lv_valid1 ).
  ENDIF.
  IF lv_valid1 = abap_false.
    RETURN.
  ENDIF.

*  check if job or package is added to alv to create a PDI order
  IF gv_ok_code EQ gc_exec_fc.    " ok_code changed

*   check entry field                        N:2773495
    PERFORM check_fields_filled.

    IF /dbe/vbak_com-ac_as_typ IS INITIAL.  "N:2773495
      SET CURSOR FIELD gc_actype_fieldname.
      MESSAGE e055(/dbe/co).
    ENDIF.

    IF gt_pdi_ord IS INITIAL.
      MESSAGE i455(/DBE/vehicle_master).
      CLEAR gv_ok_code.
      RETURN.
    ELSE.

*      check if there is atleast one entry without job or pack desc
      LOOP AT gt_pdi_ord INTO ls_pdi_job WHERE job_descr = '' .
        READ TABLE gt_pdi_ord INTO ls_pdi_job  INDEX sy-tabix.
        IF sy-subrc EQ 0 AND ls_pdi_job-package_id = ''.
          MESSAGE i464(/DBE/vehicle_master).
          CLEAR gv_ok_code.
          RETURN.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDIF.

  "Fetch selected vehicles from vehicle buffer object
  lo_buf1 = /DBE/cl_veh_buf=>get_instance( ).

  IF lo_buf1 IS BOUND.
    CALL METHOD lo_buf1->get_all
      RECEIVING
        rt_bob = lt_bob.
  ENDIF.

  CREATE OBJECT go_pdi_order.
  go_pdi_order->cs_vbak_com = /DBE/vbak_com.
  go_pdi_order->mv_action   = gv_action.
  TRY.

      lv_success_count = lines( lt_bob ).
      LOOP AT lt_bob INTO ls_bob.
        IF go_pdi_order->mo_pdi_order IS BOUND.
          "Clear previous data
          go_pdi_order->clear( ).
        ENDIF.
        "Current vehicle
        lo_veh ?= ls_bob-bobref.
        go_pdi_order->mo_veh = lo_veh.
        "Set log context for current vehicel
        go_pdi_order->set_log_context( ).
        "Create PDI Order
        go_pdi_order->create_order( EXCEPTIONS OTHERS = 1 ).
        IF sy-subrc <> 0 OR go_pdi_order->mv_has_error EQ abap_true.
          CONTINUE.
        ENDIF.
        "Update PDI order by AAC data
        CALL METHOD go_pdi_order->change_order( EXCEPTIONS OTHERS = 1 ).
        IF sy-subrc <> 0 OR go_pdi_order->mv_has_error EQ abap_true.
          CONTINUE.
        ENDIF.
        "Add Jobs/Packages to PDI Order
        LOOP AT gt_pdi_ord INTO ls_pdi_job .
          IF ls_pdi_job-package_id IS INITIAL.
            "Create jobs without package items
            CALL METHOD go_pdi_order->add_job
              EXPORTING
                iv_job_descr            = ls_pdi_job-job_descr
                iv_job_price_limit      = ls_pdi_job-price_limit
                iv_job_price_limit_type = ls_pdi_job-price_limit_type
              EXCEPTIONS
                OTHERS                  = 4.
            IF sy-subrc <> 0 OR go_pdi_order->mv_has_error EQ abap_true.
              EXIT.
            ENDIF.
          ELSE.
            "Create jobs with package items
            go_pdi_order->add_package(
              EXPORTING
                iv_package_id           = ls_pdi_job-package_id
                iv_variant_id           = ls_pdi_job-variant_id
                iv_job_price_limit      = ls_pdi_job-price_limit      "N:3265700
                iv_job_price_limit_type = ls_pdi_job-price_limit_type "N:3265700
              EXCEPTIONS OTHERS = 1 ).
            IF sy-subrc <> 0 OR go_pdi_order->mv_has_error EQ abap_true.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF go_pdi_order->mv_has_error EQ abap_true.
          lv_failed_count = lv_failed_count + 1.
          lv_success_count = lv_success_count - 1.
          CONTINUE.
        ENDIF.
        "Save PDI Order and exit
        go_pdi_order->save_and_exit_order( EXCEPTIONS OTHERS = 1 ).
        IF sy-subrc <> 0 OR go_pdi_order->mv_has_error EQ abap_true.
          lv_failed_count = lv_failed_count + 1.
          lv_success_count = lv_success_count - 1.
        ENDIF.
      ENDLOOP.
    CATCH cx_root.
  ENDTRY.
  IF lv_failed_count IS INITIAL.
    MESSAGE s480(/DBE/vehicle_master) WITH gv_action_text.
  ELSEIF lv_success_count IS INITIAL.
    MESSAGE s479(/DBE/vehicle_master) WITH gv_action_text DISPLAY LIKE 'E'.
  ELSE.
    MESSAGE s478(/DBE/vehicle_master) WITH gv_action_text DISPLAY LIKE 'W'.
  ENDIF.

  IF gv_do_commit EQ abap_true.
    COMMIT WORK.
    CLEAR gv_do_commit.
  ENDIF.
ENDFORM.                    "user_command_0800
*----------------------------------------------------------------------*
*  MODULE validate_alv_data
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE validate_alv_data INPUT.
  "Get all changed data from ALV
  IF go_pdi_ordcrt IS BOUND.
    go_pdi_ordcrt->check_changed_data( IMPORTING e_valid = lv_valid1 ).
  ENDIF.
  IF lv_valid1 = abap_false.
    RETURN.
  ENDIF.
ENDMODULE.                    "validate_alv_data
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_JOBS_WITH_PACKAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LO_ORDER  text
*----------------------------------------------------------------------*
FORM f_create_jobs_with_package
                              USING
                                      ps_pdi_job LIKE LINE OF gt_pdi_ord   "TYPE /DBE/vmass_pdi
                                      pv_vhvin TYPE vlc_vhvin
                              CHANGING
                                po_order TYPE REF TO /DBE/cl_order.

  DATA : ls_item_detail     TYPE /DBE/s_pos,
         ls_vbak_com        TYPE /DBE/vbak_com,
         lo_bal             TYPE REF TO /DBE/cl_bal,                             "N:2304203
         lo_veh             TYPE REF TO /DBE/cl_veh_dbmvehicle.

  MOVE-CORRESPONDING po_order->ms_header_detail TO ls_item_detail.

  ls_item_detail-pstyv   =  gc_pack_pstyv.
  ls_item_detail-itcat   =  gc_pack_itcat.
  ls_item_detail-itobjid =  ps_pdi_job-package_id."'PK_WORKSCOPE1'.
  CLEAR po_order->mt_item_detail.
  APPEND ls_item_detail TO po_order->mt_item_detail.
  ls_vbak_com = po_order->ms_vbak_com.

  TRY.
      CALL FUNCTION '/DBE/ORD_UI_ORDER_DATA_SET'
        EXPORTING
          io_order = po_order.
    CATCH cx_root.
  ENDTRY.

  TRY.
      CALL FUNCTION '/DBE/ORD_UI_ITEM_DET_SEARCH'
        EXPORTING
          io_order       = po_order
        CHANGING
          cs_vbak_com    = ls_vbak_com
        EXCEPTIONS
          hotkey_error   = 1
          internal_error = 2.

      IF sy-subrc <> 0.
        po_order->bal_add_symessage( ).
      ENDIF.

      lo_bal = po_order->mo_bal.

      IF lo_bal->mv_error_raised EQ abap_false.
        po_order->ms_header_detail = ls_vbak_com.
      ELSE.
        CLEAR po_order->mt_item_detail.
        "Collect logs to global table
        PERFORM update_logs_to_globaltable USING po_order ls_order_creation-vhvin.
        "In case of error, delete all success message/s
        DELETE gt_bapireturn WHERE type NE gc_err_msgtype.
        "Update logs into the log tab
        lo_veh->add_bapiret2_bal( EXPORTING it_bapiret2 = gt_bapireturn
                                            is_context = ls_context
                                            is_params = ls_params  ).

        RETURN.
      ENDIF.

    CATCH cx_root.
  ENDTRY.

  TRY.

      CALL FUNCTION '/DBE/OE_MAIN_CONTROL'
        EXPORTING
          iv_event                     = /DBE/cl_order_engine=>c_ord_item_new
          io_order                     = po_order
*         IV_ALLOW_DIALOG_IN_RECURSION = ABAP_FALSE
        EXCEPTIONS
          internal_error               = 1
          nothing_selected             = 2
          action_error                 = 3
          user_abort                   = 4.

      IF sy-subrc NE 0.
        "Collect logs to global table
        PERFORM update_logs_to_globaltable USING po_order ls_order_creation-vhvin.
        "In case of error, delete all success message/s
        DELETE gt_bapireturn WHERE type NE gc_err_msgtype.
        "Update logs into the log tab
        lo_veh->add_bapiret2_bal( EXPORTING it_bapiret2 = gt_bapireturn
                                            is_context = ls_context
                                            is_params = ls_params  ).
        CLEAR: gt_bapireturn.
      ENDIF.
    CATCH cx_root.
  ENDTRY.
ENDFORM.                    "f_create_jobs_with_package
" F_CREATE_JOBS_WITH_PACKAGE

*&---------------------------------------------------------------------*
*&      Form  f_process_src_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_process_src_f4 .
  DATA :
        lt_ret          TYPE  TABLE OF ddshretval,
        ls_ret          TYPE ddshretval ,
        lt_dynp         TYPE STANDARD TABLE OF dselc.

  CLEAR : lt_ret, lt_dynp.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = '/DBE/VBAK_COM-EMPGE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = '/DBE/VBAK_COM-EMPGE'
      window_title    = 'Cost Center'(415)
      value_org       = gc_suc_msgtype
    TABLES
      value_tab       = gt_aac_costcenters
      return_tab      = lt_ret[]
      dynpfld_mapping = lt_dynp[]
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2.

  IF sy-subrc  =  0 AND lt_ret IS NOT INITIAL.
    "Get single selection on f4
    READ TABLE lt_ret INTO ls_ret INDEX 1.
    IF sy-subrc EQ 0.
*      lv_item_key = ls_ret-fieldval.
*      lv_item_posnr = ls_ret-fieldval.
*      perform f_read_src_item using lv_item_key lv_item_posnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_process_src_f4
*&---------------------------------------------------------------------*
*&      Module  M_GET_CCF4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_get_ccf4 INPUT.
  IF /DBE/vbak_com-ac_as_typ IS NOT INITIAL.
*    PERFORM f_process_src_f4.
  ENDIF.
ENDMODULE.                 " M_GET_CCF4  INPUT
*&---------------------------------------------------------------------*
*&      Module  M_GET_PKGF4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE m_get_pkgf4 INPUT.
*  PERFORM f_process_pkg_f4.
*ENDMODULE.                 " M_GET_PKGF4  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_PKG_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM f_process_pkg_f4 .
*
*  DATA :
*        lt_rettab          TYPE TABLE OF ddshretval,
*          ls_rettab          TYPE ddshretval.
*  REFRESH : lt_rettab .
*
*
*
*
** TODO <JAINEEL> ... fieldname is obligatory (checkman) ...
*  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'  "#EC FB_PAR_MIS
*    EXPORTING
*      tabname           = '/DBE/UPC_OPT'
**     fieldname         = lv_fieldname
*      searchhelp        = '/DBE/PACK_F4_8_2'
*      callback_program  = sy-repid
*      callback_form     = 'F4CALLBACK_PACK'
*    TABLES
*      return_tab        = lt_rettab
*    EXCEPTIONS
*      field_not_found   = 1
*      no_help_for_field = 2
*      inconsistent_help = 3
*      no_values_found   = 4
*      OTHERS            = 5.
*
*  IF lt_rettab IS NOT INITIAL.
*    READ TABLE lt_rettab INDEX 1 TRANSPORTING fieldval INTO ls_rettab.
*    IF sy-subrc EQ 0.
**            lv_item_key =  ls_rettab-fieldval.
*    ENDIF.
*  ENDIF.
*ENDFORM.                    " F_PROCESS_PKG_F4
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_AAC_MANDFIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_VALID  text
*----------------------------------------------------------------------*
FORM f_check_aac_mandfields  CHANGING pv_valid.

  IF /DBE/vbak_com-kokrs IS INITIAL
    OR /DBE/vbak_com-vkorg IS INITIAL
    OR /DBE/vbak_com-werks IS INITIAL
    OR /DBE/vbak_com-aufart IS INITIAL.

    pv_valid = abap_false.
  ELSE.
    pv_valid = abap_true.
  ENDIF.

ENDFORM.                    " F_CHECK_AAC_MANDFIELDS
*&---------------------------------------------------------------------*
*&      Module  M_CHECK_AND_UPDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_and_update INPUT.
  PERFORM f_check_aac_mandfields CHANGING lv_mandat.
  IF lv_mandat EQ abap_true.
    PERFORM f_get_acctype USING '/DBE/VBAK_COM-AC_AS_TYP' .
  ENDIF.
ENDMODULE.                 " M_CHECK_AND_UPDATE  INPUT
*&---------------------------------------------------------------------*
*&      Module  M_CHECK_FIELDS_FILLED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_fields_filled INPUT.
  PERFORM check_fields_filled.
ENDMODULE.                 " M_CHECK_FIELDS_FILLED  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_fields_filled
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_fields_filled.
  DATA: ls_knvv TYPE knvv,
        l_partner_exist TYPE abap_bool,
        ls_orgdata TYPE /DBE/c_ord_org.

  FIELD-SYMBOLS : <fs_pdi_ord> LIKE LINE OF gt_pdi_ord.

  IF  /DBE/vbak_com-vkorg IS NOT INITIAL AND /DBE/vbak_com-vtweg IS NOT INITIAL
    AND /DBE/vbak_com-werks IS NOT INITIAL AND /DBE/vbak_com-aufart IS NOT INITIAL
    AND ( sy-ucomm EQ gc_enter_fcode OR sy-ucomm EQ gc_exe_action_fcode OR sy-ucomm EQ gc_order_type ).
    SELECT * FROM /DBE/c_ord_org INTO TABLE lt_valid_orgdata
       WHERE vkorg  = /DBE/vbak_com-vkorg
       AND vtweg  = /DBE/vbak_com-vtweg
       AND aufart = /DBE/vbak_com-aufart.
    IF sy-subrc <> 0.
      CLEAR gv_ok_code. "
      MESSAGE e222(/DBE/order) WITH /DBE/vbak_com-aufart.
      RETURN.
    ELSE.
      READ TABLE lt_valid_orgdata INTO ls_orgdata INDEX 1.
      IF sy-subrc = 0.
        /DBE/vbak_com-spart = ls_orgdata-spart.
      ENDIF.
    ENDIF.
  ENDIF.
  IF /DBE/vbak_com-partner IS NOT INITIAL.
    CALL FUNCTION 'BKK_BUPA_PARTNER_CHECK'
      EXPORTING
        i_partner       = /DBE/vbak_com-partner
      IMPORTING
        e_partner_exist = l_partner_exist.
    IF l_partner_exist = abap_false.
      SET CURSOR FIELD '/DBE/VBAK_COM-PARTNER'.
      MESSAGE e457(/DBE/vehicle_master) .
    ENDIF.
  ENDIF.
  IF sy-ucomm EQ gc_enter_fcode OR sy-ucomm = gc_exe_action_fcode.
    IF /DBE/vbak_com-vkorg IS INITIAL.
      SET CURSOR FIELD '/DBE/VBAK_COM-VKORG'.
      CLEAR gv_ok_code.
      MESSAGE e452(/DBE/vehicle_master) .
    ELSEIF /DBE/vbak_com-vtweg IS INITIAL.
      SET CURSOR FIELD '/DBE/VBAK_COM-VTWEG'.
      CLEAR gv_ok_code.
      MESSAGE e451(/DBE/vehicle_master) .
    ELSEIF /DBE/vbak_com-werks IS INITIAL.
      SET CURSOR FIELD '/DBE/VBAK_COM-WERKS' .
      CLEAR gv_ok_code. "
      MESSAGE e404(/DBE/vehicle_master) .
    ELSEIF /DBE/vbak_com-partner IS INITIAL.
      SET CURSOR FIELD '/DBE/VBAK_COM-PARTNER'.
      CLEAR gv_ok_code.  "
      MESSAGE e450(/DBE/vehicle_master) .
    ELSEIF /DBE/vbak_com-aufart IS INITIAL.
      SET CURSOR FIELD '/DBE/VBAK_COM-AUFART'.
      CLEAR gv_ok_code.
      MESSAGE i453(/dbe/vehicle_master) DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    IF /DBE/vbak_com-partner IS NOT INITIAL AND /DBE/vbak_com-vkorg IS NOT INITIAL AND
      /DBE/vbak_com-vtweg IS NOT INITIAL AND /DBE/vbak_com-spart IS NOT INITIAL.
      CALL FUNCTION 'KNVV_SINGLE_READ'
        EXPORTING
          i_kunnr = /DBE/vbak_com-partner
          i_vkorg = /DBE/vbak_com-vkorg
          i_vtweg = /DBE/vbak_com-vtweg
          i_spart = /DBE/vbak_com-spart
        IMPORTING
          o_knvv  = ls_knvv
        EXCEPTIONS
          OTHERS  = 4.
      IF sy-subrc NE 0.
      ENDIF.
      IF ls_knvv-waers IS NOT INITIAL.
        LOOP AT gt_pdi_ord ASSIGNING <fs_pdi_ord>.
          <fs_pdi_ord>-price_limit_cuky = ls_knvv-waers.
        ENDLOOP.
      ENDIF.
    ENDIF.
    IF go_pdi_ordcrt IS BOUND.
      CALL METHOD go_pdi_ordcrt->refresh_table_display( ).
    ENDIF.
  ENDIF.
ENDFORM.                    "check_fields_filled
*&---------------------------------------------------------------------*
*&      Module  M_CHECK_ACC_AS_FILLED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_acc_as_filled INPUT.

  IF sy-ucomm EQ gc_exe_action_fcode.
    IF /DBE/vbak_com-ac_as_typ IS INITIAL.
      SET CURSOR FIELD gc_actype_fieldname.
      MESSAGE e055(/DBE/co).

    ENDIF.
  ENDIF.
ENDMODULE.                 " M_CHECK_ACC_AS_FILLED  INPUT
*&---------------------------------------------------------------------*
*&      Form  UPDATE_LOGS_TO_GLOBALTABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LO_PDI_ORDER  text
*      -->P_LS_ORDER_CREATION_VHVIN  text
*----------------------------------------------------------------------*
FORM update_logs_to_globaltable  USING    po_pdi_order TYPE REF TO /DBE/cl_order
                                          pv_vhvin TYPE vlc_vhvin.

  DATA            lt_return     TYPE bapiret2_t.
  FIELD-SYMBOLS  <fs_return>    TYPE bapiret2.

  "Collect logs into gt_bapireturn
  lt_return = po_pdi_order->bal_export( ).
  LOOP AT lt_return ASSIGNING <fs_return>." WHERE type EQ gc_err_msgtype.
    CONCATENATE  pv_vhvin <fs_return>-message INTO <fs_return>-message SEPARATED BY space.
  ENDLOOP.

  APPEND LINES OF lt_return TO gt_bapireturn.

ENDFORM.                    " UPDATE_LOGS_TO_GLOBALTABLE
*&---------------------------------------------------------------------*
*&      Form  F_EXIT_ORDER_WITHOUT_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LO_PDI_ORDER  text
*----------------------------------------------------------------------*
FORM f_exit_order_without_save  USING    po_pdi_order TYPE REF TO /DBE/cl_order.
  po_pdi_order->ms_dialog_control-oe_leave = abap_true.
  CALL FUNCTION '/DBE/OE_MAIN_CONTROL'
    EXPORTING
      iv_event         = /DBE/cl_order_engine=>c_ord_exit
      io_order         = po_pdi_order
    EXCEPTIONS
      internal_error   = 1
      nothing_selected = 2
      action_error     = 3
      OTHERS           = 4.
ENDFORM.                    " F_EXIT_ORDER_WITHOUT_SAVE

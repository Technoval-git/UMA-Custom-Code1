*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI63 .
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  M_GET_ORDTYP_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_get_ordtyp_0800 OUTPUT.
  PERFORM get_ordtyp_0800.
ENDMODULE.                 " M_GET_ORDTYP_0800  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  get_ordtyp_0800
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_ordtyp_0800.
  DATA:
    lt_aufart_bez        TYPE TABLE OF /dbe/c_values_aufart,
    lt_schema_data       TYPE STANDARD TABLE OF /dbe/s_ordtp_sch_data,
    ls_schema_com        TYPE /dbe/s_ordtp_sch_com,
    lt_ordertp           TYPE STANDARD TABLE OF /dbe/c_aufart_typ,
    ls_ordertp           TYPE /dbe/c_aufart_typ,
    lt_vrm_aufart_values TYPE STANDARD TABLE OF vrm_value,
    ls_vrm_aufart_values TYPE vrm_value,
    lt_values_aufart     TYPE STANDARD TABLE OF /dbe/c_values_aufart,
    ls_values_aufart     TYPE  /dbe/c_values_aufart,
    lt_vrm_values        TYPE STANDARD TABLE OF vrm_value.
  FIELD-SYMBOLS:
    <fs_aufart_bez>  TYPE /dbe/c_values_aufart,
    <fs_schema_data> TYPE /dbe/s_ordtp_sch_data.
  ok_code = sy-ucomm.
  IF ok_code EQ gc_order_type OR ok_code EQ gc_aac_type OR ok_code EQ gc_ente_fc OR ok_code EQ gc_receiver.
    RETURN.
  ENDIF.

  IF ok_code NE gc_exec_fc.
    CLEAR : /dbe/vbak_com, lt_vrm_values.
    "Clear Acc Assgnmnt Category  Dropdown list
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = '/DBE/VBAK_COM-AC_AS_TYP'
        values          = lt_vrm_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    "Clear Receiver  Dropdown list
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = '/DBE/VBAK_COM-EMPGE'
        values          = lt_vrm_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
  CLEAR :  gt_aac_data, gt_aac_costcenters,lt_ordertp.

*  "Find all the relevent order type- from Schema ID
  CLEAR: lt_schema_data, lt_vrm_aufart_values, lt_aufart_bez.
  ls_schema_com-schema_id = gc_pdi_schemaid.
  IF /dbe/cl_ordtp_schema=>check_schema_active( ls_schema_com-schema_id ) = abap_true.
    CALL METHOD /dbe/cl_lc_access=>read
      EXPORTING
        i_usage = '/DBE/ORD_TP_SCHM'
        i_com   = ls_schema_com
      IMPORTING
        et_data = lt_schema_data.
    "Get text for order type
    SELECT * FROM /dbe/c_ordertpt
    INTO CORRESPONDING FIELDS OF TABLE lt_aufart_bez
    FOR ALL ENTRIES IN lt_schema_data WHERE aufart = lt_schema_data-aufart AND spras  = sy-langu.

    LOOP AT lt_schema_data ASSIGNING <fs_schema_data> .
      CLEAR: ls_vrm_aufart_values.
      ls_vrm_aufart_values-key  = <fs_schema_data>-aufart.
      "Get order type text
      READ TABLE lt_aufart_bez ASSIGNING <fs_aufart_bez> WITH KEY aufart = <fs_schema_data>-aufart.
      IF sy-subrc EQ 0.
        ls_vrm_aufart_values-text = <fs_aufart_bez>-bezei.
      ENDIF.
      APPEND ls_vrm_aufart_values TO lt_vrm_aufart_values.
    ENDLOOP.
    IF lt_vrm_aufart_values IS INITIAL.
      MESSAGE i475(/dbe/vehicle_master) DISPLAY LIKE 'E'.
    ENDIF.
  ELSE.
    MESSAGE i476(/dbe/vehicle_master) WITH gc_pdi_schemaid DISPLAY LIKE 'E'.
  ENDIF.
*  "Find all the relevent order type
*  CALL FUNCTION '/DBE/CO_ORD_FILL_TAB_AUFART'
*    EXPORTING
*      i_split         = gc_xflag
*      i_aufart        = gc_pdi_ordertype
*      i_engine        = gc_pdi_controlcode
*      i_vbtyp         = gc_pdi_doccat
*    TABLES
*      t_aufart        = lt_ordertp
*      t_values_aufart = lt_values_aufart
*    EXCEPTIONS
*      not_found       = 1
*      OTHERS          = 2.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*  "Refresh data for order type dropdown
*  CLEAR : lt_vrm_aufart_values, ls_vrm_aufart_values.
*  LOOP AT lt_ordertp INTO  ls_ordertp WHERE doc_type = '02' OR doc_type EQ '05'.
*    ls_vrm_aufart_values-key  = ls_ordertp-aufart.
*    ls_vrm_aufart_values-text = ls_ordertp-bezei.
*    APPEND ls_vrm_aufart_values TO lt_vrm_aufart_values.
*  ENDLOOP.

  "Populate lt_ordertp into order type drop down list
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = '/DBE/VBAK_COM-AUFART'
      values          = lt_vrm_aufart_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    "get_ordtyp_0800
*&---------------------------------------------------------------------*
*&      Form  f_get_acctype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_FIELD1  text
*----------------------------------------------------------------------*
FORM f_get_acctype
       USING
       iv_field1   TYPE vrm_id.
  DATA :
    ls_vbak_com         TYPE /dbe/vbak_com,
    ls_acctype          TYPE /dbe/s_acas_typ,
    ls_acctypet         TYPE /dbe/s_acas_typt,
    lt_f4               TYPE t_t_acctype_f4,
    ls_f4               TYPE t_s_acctype_f4,
    ls_data             TYPE /dbe/co_acc,
    lt_data             TYPE /dbe/co_acc_tt,
    ls_aac              TYPE ty_aac_data,
    ls_vrm_values       TYPE  vrm_value,
    lt_vrm_empge_values TYPE STANDARD TABLE OF vrm_value,
    lt_vrm_values       TYPE STANDARD TABLE OF vrm_value,
    lt_acctypet         TYPE STANDARD TABLE OF /dbe/s_acas_typt,
    lt_acctype          TYPE STANDARD TABLE OF /dbe/s_acas_typ,
* VSS 5.0 {
    lt_spart            TYPE SORTED TABLE OF /dbe/vbak_com-spart WITH UNIQUE KEY table_line,
    lv_spart            LIKE LINE OF lt_spart[],
    lo_veh_buf          TYPE REF TO /dbe/cl_veh_buf,
    lt_veh_bob          TYPE /dbe/t_veh_bob,
    lo_vehicle          TYPE REF TO /dbe/cl_veh_dbmvehicle,
    lr_vlcactdata_head  TYPE REF TO vlcactdata_head_s.

  FIELD-SYMBOLS:
    <ls_veh_bob> LIKE LINE OF lt_veh_bob[].
* VSS 5.0 }

  CLEAR:              gt_aac_data, lt_vrm_values, ls_vrm_values.

* VSS 5.0 {
  "Determine the division from the selected vehicles
  TRY.
      lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
      lt_veh_bob[] = lo_veh_buf->get_all( ).
      LOOP AT lt_veh_bob[] ASSIGNING <ls_veh_bob>.
        lo_vehicle ?= <ls_veh_bob>-bobref.
        lr_vlcactdata_head ?= lo_vehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_head_s ).
        lv_spart = lr_vlcactdata_head->/dbe/spart.
        INSERT lv_spart INTO TABLE lt_spart[].
      ENDLOOP.
      UNASSIGN <ls_veh_bob>.

      IF lines( lt_spart[] ) = 1.
        "If the determination is unique, we pass it to the Lean Condition
        READ TABLE lt_spart[] INTO lv_spart INDEX 1.
        ASSERT sy-subrc = 0.
      ELSE.
        "In all other cases the division will be empty
        CLEAR lv_spart.
      ENDIF.
    CATCH /dbe/cx_veh_layer_not_found.
      "In case of exception the division is not determined
      CLEAR lv_spart.
  ENDTRY.
* VSS 5.0 }

  IF sy-ucomm EQ gc_order_type.
    CLEAR: /dbe/vbak_com-ac_as_typ,
           /dbe/vbak_com-empge,
           /dbe/vbak_com-kstar.
    "Clear Receiver Dropdown list
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

* get all accounting types
  CALL FUNCTION '/DBE/CO_ACAS_TYP_GET_ALL'
    TABLES
      et_acas_typ  = lt_acctype[]
      et_acas_typt = lt_acctypet[]
    EXCEPTIONS
      not_found    = 1
      OTHERS       = 2.

  IF sy-subrc = 0.

    LOOP AT lt_acctype INTO ls_acctype.
      CLEAR : lt_data, ls_vbak_com.
      MOVE-CORRESPONDING /dbe/vbak_com TO ls_vbak_com.
      ls_vbak_com-ac_as_typ = ls_acctype-ac_as_typ.
      ls_vbak_com-kokrs     = /dbe/vbak_com-kokrs.
      ls_vbak_com-vkorg     = /dbe/vbak_com-vkorg.
      ls_vbak_com-aufart    = /dbe/vbak_com-aufart.
* VSS 5.0 {
      ls_vbak_com-spart     = lv_spart.
* VSS 5.0 }

      MOVE-CORRESPONDING ls_acctype TO ls_vbak_com.
*     get customizing data
      CALL FUNCTION '/DBE/CO_INT_ACC_GET_TYPE'
        EXPORTING
          is_vbak = ls_vbak_com
        IMPORTING
          es_data = ls_data
          et_data = lt_data.

      IF NOT lt_data IS INITIAL.

        LOOP AT lt_data INTO ls_data.
          MOVE-CORRESPONDING ls_data TO ls_aac.
          ls_aac-ac_as_typ = ls_acctype-ac_as_typ.
          APPEND ls_aac TO gt_aac_data.
        ENDLOOP.
        CLEAR ls_f4.
        ls_f4-acctype = ls_acctype-ac_as_typ.
        "get text from internal table
        READ TABLE lt_acctypet INTO ls_acctypet
          WITH KEY ac_as_typ = ls_acctype-ac_as_typ.
        IF sy-subrc EQ 0.
          ls_f4-text = ls_acctypet-text.
        ENDIF.
        APPEND ls_f4 TO lt_f4.
      ENDIF.
    ENDLOOP.

*--> fill the values-table for listbox
    LOOP AT lt_f4 INTO ls_f4.
      CLEAR ls_vrm_values.
      ls_vrm_values-key  = ls_f4-acctype.
      ls_vrm_values-text = ls_f4-text.
      APPEND ls_vrm_values TO lt_vrm_values.
    ENDLOOP.


    IF sy-ucomm NE 'ACT_EXE' AND lt_vrm_values IS INITIAL .

      sy-ucomm = gc_aac_type.
    ENDIF.
*--> pass over the data to the listbox
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = '/DBE/VBAK_COM-AC_AS_TYP'
        values          = lt_vrm_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.
ENDFORM.                    " F_ACCTYPE_F4
*&---------------------------------------------------------------------*
*&      Module  M_INITIAL_VALUES_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_initial_values_0800 OUTPUT.
  PERFORM f_set_initial_values_800.
ENDMODULE.                 " M_INITIAL_VALUES_0800  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  f_set_initial_values_800
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_set_initial_values_800.
  IF sy-ucomm IS INITIAL AND gv_ok_code NE 'EXECUTE'.
    CLEAR gv_ok_code.
  ENDIF.
  IF gv_ok_code EQ gc_order_type.
    SET CURSOR FIELD '/DBE/VBAK_COM-AUFART'.
  ELSEIF gv_ok_code EQ gc_aac_type.
    SET CURSOR FIELD '/DBE/VBAK_COM-AC_AS_TYP'.
  ELSEIF gv_ok_code EQ gc_receiver..
    SET CURSOR FIELD '/DBE/VBAK_COM-EMPGE'.
  ENDIF.
  gv_visit_start_dat = sy-datum + 1 .
  gv_visit_end_dat   = sy-datum + 1.
ENDFORM.                    "f_set_initial_values_800
*&---------------------------------------------------------------------*
*&      Module  M_GET_USER_PARAM_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_get_user_param_0800 OUTPUT.
  PERFORM f_get_user_param.
  PERFORM f_get_text.
ENDMODULE.                 " M_GET_USER_PARAM_0800  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_GET_USER_PARAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_user_param .
  IF /dbe/vbak_com-vkorg IS INITIAL.
    GET PARAMETER ID 'VKO' FIELD /dbe/vbak_com-vkorg.
  ENDIF.

  IF /dbe/vbak_com-vtweg IS INITIAL.
    GET PARAMETER ID 'VTW' FIELD /dbe/vbak_com-vtweg.

  ENDIF.

  IF /dbe/vbak_com-werks IS  INITIAL.
    GET PARAMETER ID 'WRK' FIELD /dbe/vbak_com-werks.
  ENDIF.

ENDFORM.                    " F_GET_USER_PARAM

*&---------------------------------------------------------------------*
*&      Form  f_get_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_text .
  DATA: ls_errmsg       TYPE string,
        ls_error        TYPE bapiret2,
        lt_errors       TYPE bapiret2_t,
        lt_field_values TYPE TABLE OF dynpread,
        ls_field_value  TYPE          dynpread,
        lv_line         TYPE          sytabix.

  FIELD-SYMBOLS: <field_value> TYPE dynpread.

  CLEAR :tvkot,tvtwt,t001w, lt_errors.
  IF /dbe/vbak_com-vkorg IS NOT INITIAL.
    CALL FUNCTION 'TVKOT_SINGLE_READ'
      EXPORTING
        spras     = sy-langu
        vkorg     = /dbe/vbak_com-vkorg
      IMPORTING
        wtvkot    = tvkot
      EXCEPTIONS
        not_found = 01.
    IF sy-subrc <> 0.
      CLEAR ls_error.
      ls_error-id      = sy-msgid.
      ls_error-number  = sy-msgno.
      ls_error-type    = sy-msgty.
      ls_error-message_v1 = sy-msgv1.
      ls_error-message_v2 = sy-msgv2.
      ls_error-message_v3 = sy-msgv3.
      ls_error-message_v4 = sy-msgv4.
      APPEND ls_error TO lt_errors.
    ENDIF.
  ENDIF.

  IF /dbe/vbak_com-vtweg IS NOT INITIAL.
    CALL FUNCTION 'TVTWT_SINGLE_READ'
      EXPORTING
        spras     = sy-langu
        vtweg     = /dbe/vbak_com-vtweg
      IMPORTING
        wtvtwt    = tvtwt
      EXCEPTIONS
        not_found = 01.
    IF sy-subrc <> 0.
      CLEAR ls_error.
      ls_error-id      = sy-msgid.
      ls_error-number  = sy-msgno.
      ls_error-type    = sy-msgty.
      ls_error-message_v1 = sy-msgv1.
      ls_error-message_v2 = sy-msgv2.
      ls_error-message_v3 = sy-msgv3.
      ls_error-message_v4 = sy-msgv4.
      APPEND ls_error TO lt_errors.
    ENDIF.
  ENDIF.

  IF /dbe/vbak_com-werks IS NOT INITIAL.
    CALL FUNCTION 'T001W_SINGLE_READ'
      EXPORTING
        t001w_werks = /dbe/vbak_com-werks
      IMPORTING
        wt001w      = t001w
      EXCEPTIONS
        not_found   = 01.
    IF sy-subrc <> 0.
      CLEAR ls_error.
      ls_error-id      = sy-msgid.
      ls_error-number  = sy-msgno.
      ls_error-type    = sy-msgty.
      ls_error-message_v1 = sy-msgv1.
      ls_error-message_v2 = sy-msgv2.
      ls_error-message_v3 = sy-msgv3.
      ls_error-message_v4 = sy-msgv4.
      APPEND ls_error TO lt_errors.
    ENDIF.
  ENDIF.
  IF lt_errors IS NOT INITIAL.
    CALL FUNCTION '/DBE/CO_APLG_MSG_DISP_POPUP'
      EXPORTING
        it_error_tab2 = lt_errors.
  ENDIF.

* read BP/Customer description                  N:2773495
  IF /dbe/vbak_com-pernr IS NOT INITIAL.
    CALL METHOD /dbe/cl_tm_services=>get_ename
      EXPORTING
        im_pernr         = /dbe/vbak_com-pernr
      RECEIVING
        ex_ename         = /dbe/vbak_com-pname
      EXCEPTIONS
        no_person_record = 1.
    IF sy-subrc <> 0.
      CLEAR ls_error.
      ls_error-id      = sy-msgid.
      ls_error-number  = sy-msgno.
      ls_error-type    = sy-msgty.
      ls_error-message_v1 = sy-msgv1.
      ls_error-message_v2 = sy-msgv2.
      ls_error-message_v3 = sy-msgv3.
      ls_error-message_v4 = sy-msgv4.
      APPEND ls_error TO lt_errors.
    ENDIF.
  ELSE.
    CLEAR /dbe/vbak_com-pname.
  ENDIF.

  /dbe/vbak_com-bp_name = /dbe/cl_cu_business_partner=>get_singleton( )->get_bp_name( /dbe/vbak_com-partner ).

  IF lt_errors IS NOT INITIAL.
    CALL FUNCTION '/DBE/CO_APLG_MSG_DISP_POPUP'
      EXPORTING
        it_error_tab2 = lt_errors.
  ENDIF.
ENDFORM.                    " F_GET_USER_PARAM

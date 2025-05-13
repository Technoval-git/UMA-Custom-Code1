*&---------------------------------------------------------------------*
*& Include          ZIVSSLVM07CL2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class LCL_OPTIONALV_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_optionalv_event_receiver DEFINITION.

  PUBLIC SECTION.
    DATA: mo_alv_grid     TYPE REF TO cl_gui_alv_grid,
          mo_data_changed TYPE REF TO cl_alv_changed_data_protocol. "N:2338127

    METHODS handle_f4
                FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING e_fieldname
                e_fieldvalue
                es_row_no
                er_event_data
                et_bad_cells
                e_display.


    METHODS handle_data_changed
                FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed
                e_onf4
                e_onf4_before
                e_onf4_after
                e_ucomm.

    METHODS button_click FOR EVENT button_click
                OF cl_gui_alv_grid
      IMPORTING es_col_id
                es_row_no.

  PRIVATE SECTION.

    METHODS update_option_line
      IMPORTING e_opkey         TYPE /dbe/vd_opkey
                e_tabix         TYPE sy-tabix
                er_data_changed TYPE REF TO
                  cl_alv_changed_data_protocol OPTIONAL
      EXPORTING i_error         TYPE c.


ENDCLASS.               "LCL_OPTIONALV_EVENT_RECEIVER



*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_OPTIONALV_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_optionalv_event_receiver IMPLEMENTATION.

  METHOD handle_f4.

    DATA : ls_fields TYPE  dfies.
    DATA : lt_return TYPE STANDARD TABLE OF ddshretval.
    DATA : ls_return TYPE ddshretval.
    DATA : lv_value TYPE help_info-fldvalue.
    DATA : lv_opkey TYPE /dbe/vd_opkey.
    DATA : lv_optyp TYPE /dbe/vd_optyp.
    DATA : ls_optionalv TYPE /dbe/v_alvoptions.
    DATA : lv_rowno TYPE sy-tabix.
    DATA : ls_modi           TYPE lvc_s_modi.
    DATA : lv_modguid TYPE /dbe/model_guid.
    DATA : lo_badi_vehicle_ui TYPE REF TO /dbe/badi_vehicle_ui.
    DATA: ls_vm_options TYPE /dbe/vm_options.
    DATA: ls_vm_optionst TYPE /dbe/vm_optionst.
    DATA: lv_model TYPE /dbe/v_model.
    DATA: ls_shlp TYPE shlp_descr.
    DATA: lv_shlpname TYPE shlpname.
    DATA: lv_num(9) TYPE n.
    DATA: lv_char(12) TYPE c.

    FIELD-SYMBOLS <itab> TYPE lvc_t_modi.
    FIELD-SYMBOLS: <ls_interface> TYPE ddshiface.

    SET PARAMETER ID gc_opclass FIELD opclass.              "#EC EXISTS

*   Get the Badi instance
    CALL FUNCTION '/DBE/VM08_BADI_UI_INSTANCE_GET'          "N.1649844
      IMPORTING
        eo_instance = lo_badi_vehicle_ui.

*   Call the Badi method in order to change the F4 process
    IF lo_badi_vehicle_ui IS BOUND.
      CALL BADI lo_badi_vehicle_ui->iobj_multi_alv_on_f4
        EXPORTING
          iv_settype_name = '/DBE/V_IOPTION'
          iv_fieldname    = e_fieldname
          iv_fieldvalue   = e_fieldvalue
          is_row_no       = es_row_no
          ir_event_data   = er_event_data
          it_bad_cells    = et_bad_cells
          iv_display      = e_display
          ir_alv_grid     = mo_alv_grid
          it_outtab       = gt_optionalv.
    ENDIF.

    CHECK er_event_data->m_event_handled NE 'X'.

    IF e_fieldname EQ gc_opkey.

*      ls_fields-tabname = '/DBE/V_MOPTIONS'.
      ls_fields-tabname = '/DBE/V_ALVOPTIONS'.
      ls_fields-fieldname = 'OPKEY'.

* read corresponding optype
      lv_rowno = es_row_no-row_id.
*     check first modified cells for new value not updated yet in gt_optionalv N:2338127
      IF mo_data_changed IS BOUND.                          "N:2544519
        mo_data_changed->get_cell_value( EXPORTING i_row_id    = es_row_no-row_id
                                                   i_fieldname = 'OPTYP'
                                         IMPORTING e_value     = lv_optyp ).
      ENDIF.
      IF lv_optyp IS INITIAL.
        READ TABLE gt_optionalv INTO ls_optionalv INDEX lv_rowno.
        IF sy-subrc EQ 0.
          lv_optyp = ls_optionalv-optyp.
        ENDIF.
      ENDIF.

*Set parameters relevant for search help
      SET PARAMETER ID gc_model_guid                        "#EC EXISTS
            FIELD gs_iobj_single-/dbe/v_imodel-modguid.
      SET PARAMETER ID gc_opclass FIELD opclass.            "#EC EXISTS
      SET PARAMETER ID gc_optyp FIELD lv_optyp.             "#EC EXISTS

* START Call other search help (new) -----------------------------------------
      lv_shlpname = '/DBE/OPKEY_COL'.
      CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
        EXPORTING
          shlpname = lv_shlpname
        IMPORTING
          shlp     = ls_shlp.
      LOOP AT ls_shlp-interface ASSIGNING <ls_interface>.
        CASE <ls_interface>-shlpfield.
          WHEN 'MODEL_GUID'.
            <ls_interface>-value = /dbe/v_imodel-modguid.
          WHEN 'OPCLASS'.
            <ls_interface>-value = opclass.
          WHEN 'OPTYP'.
            <ls_interface>-value = lv_optyp.
            <ls_interface>-valtabname = '/DBE/V_ALVOPTIONS'.
            <ls_interface>-valfield = 'OPTYP'.
          WHEN 'OPKEY'.
            <ls_interface>-valtabname = '/DBE/V_ALVOPTIONS'.
            <ls_interface>-valfield = 'OPKEY'.
          WHEN 'MATNR'.
            <ls_interface>-valtabname = '/DBE/V_ALVOPTIONS'.
            <ls_interface>-valfield = 'MATNR'.
          WHEN 'PUPRC'.
            <ls_interface>-valtabname = '/DBE/V_ALVOPTIONS'.
            <ls_interface>-valfield = 'PUPRC'.
          WHEN 'PKONWA'.
            <ls_interface>-valtabname = '/DBE/V_ALVOPTIONS'.
            <ls_interface>-valfield = 'PKONWA'.
          WHEN 'SAPRC'.
            <ls_interface>-valtabname = '/DBE/V_ALVOPTIONS'.
            <ls_interface>-valfield = 'SAPRC'.
          WHEN 'SKONWA'.
            <ls_interface>-valtabname = '/DBE/V_ALVOPTIONS'.
            <ls_interface>-valfield = 'SKONWA'.
          WHEN 'OPTEXT1'.
            <ls_interface>-valtabname = '/DBE/V_ALVOPTIONS'.
            <ls_interface>-valfield = 'OPTEXT1'.
        ENDCASE.
      ENDLOOP.
* start SAPGui search help
      CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
        EXPORTING
          shlp          = ls_shlp
        TABLES
          return_values = lt_return.
      IF lt_return[] IS INITIAL.

      ELSE.
****        LOOP AT lt_result INTO ls_result.
****          CASE ls_result-fieldname.
****          ENDCASE.
****        ENDLOOP.
      ENDIF.


* END Call other search help (new) -----------------------------------------

* F4 retruns only opkey - read other model data
      READ TABLE lt_return INTO ls_return INDEX 1.
      IF sy-subrc EQ 0.
        e_fieldvalue = ls_return-fieldval.

* update grid field
        ASSIGN er_event_data->m_data->* TO <itab>.
        IF sy-subrc EQ 0.
          ls_modi-row_id = es_row_no-row_id.
          ls_modi-fieldname = e_fieldname.

          ls_modi-value = ls_return-fieldval.
          APPEND ls_modi TO <itab>.
*         Update Features Category key
          SELECT SINGLE * INTO lv_model FROM /dbe/v_model
                                        WHERE mcodesd = /dbe/v_imodel-mcodesd. "#EC *
          IF sy-subrc NE 0.
            CLEAR: lv_modguid.
          ELSE.
            lv_modguid = lv_model-model_guid.
          ENDIF.
          SELECT SINGLE optyp INTO lv_optyp FROM  /dbe/v_moptions
                                            WHERE model_guid = lv_modguid
                                            AND   opkey      = ls_modi-value. "#EC *
          IF sy-subrc = 0.
*           Put Features Category key to the ALV field
            ls_modi-row_id = es_row_no-row_id.
            ls_modi-fieldname = gc_optyp.
            ls_modi-value = lv_optyp.
            APPEND ls_modi TO <itab>.
          ELSE. "options master data table /DBE/vm_options
            SELECT SINGLE * INTO ls_vm_options FROM /dbe/vm_options WHERE mcatalog = lv_model-mcatalog
                                                                    AND    opclass = opclass
                                                                    AND      opkey = ls_modi-value.
            SELECT SINGLE * INTO ls_vm_optionst FROM /dbe/vm_optionst WHERE mcatalog  = lv_model-mcatalog AND
                                                                            opclass   = opclass AND
                                                                            opkey     = ls_modi-value AND
                                                                            spras     = sy-langu.
            IF sy-subrc = 0.
* Fill ALV fields
              ls_modi-row_id = es_row_no-row_id.
              ls_modi-fieldname = gc_optyp.
              ls_modi-value = ls_vm_options-optyp.
              APPEND ls_modi TO <itab>.
              ls_modi-fieldname = 'MATNR'.
              ls_modi-value = ls_vm_options-matnr.
              APPEND ls_modi TO <itab>.
              ls_modi-fieldname = 'PUPRC'.
              WRITE ls_vm_options-puprc TO lv_char.
              ls_modi-value = lv_char.
              APPEND ls_modi TO <itab>.
              ls_modi-fieldname = 'PKONWA'.
              ls_modi-value = ls_vm_options-pkonwa.
              APPEND ls_modi TO <itab>.
              ls_modi-fieldname = 'SAPRC'.
              WRITE ls_vm_options-saprc TO lv_char.
              ls_modi-value = lv_char.
              APPEND ls_modi TO <itab>.
              ls_modi-fieldname = 'SKONWA'.
              ls_modi-value = ls_vm_options-skonwa.
              APPEND ls_modi TO <itab>.
              ls_modi-fieldname = 'OPTEXT1'.
              ls_modi-value = ls_vm_optionst-optext1.
              APPEND ls_modi TO <itab>.
            ENDIF.
          ENDIF.
        ENDIF.

* take selected option and update the alv line
        lv_opkey = ls_return-fieldval.
*Update the line, if the option is defined in model master
        CALL METHOD update_option_line
          EXPORTING
            e_opkey = lv_opkey
            e_tabix = es_row_no-row_id.
      ENDIF.
*Set flag finished to avoid the standard search help
      er_event_data->m_event_handled = 'X'.
    ENDIF.
  ENDMETHOD.                                                "HANDLE_F4


  METHOD handle_data_changed.
    TYPES : t_v_alvoptions TYPE STANDARD TABLE OF /dbe/v_alvoptions.
    DATA: lv_prc_pai TYPE c VALUE space.

    DATA : ls_modcell TYPE lvc_s_modi.
    DATA : lv_key_changed(1).
    DATA : lv_opkey TYPE /dbe/vd_opkey.
    DATA : lv_tabix TYPE sy-tabix.
    DATA : lv_tdname TYPE tdobname.
    DATA : ls_inserted_row TYPE lvc_s_moce.
    DATA : ls_opti TYPE /dbe/v_alvoptions.
    DATA : ls_option TYPE /dbe/v_alvoptions.
    DATA : lv_domname TYPE ddobjname.
    DATA : ls_domdesc TYPE dd01v.
    DATA : lv_error TYPE c.
    DATA : lv_index TYPE sy-tabix.
    DATA : ls_bapireturn TYPE bapiret2.
    DATA : lt_bapireturn TYPE bapiret2_t.
    DATA : lt_optionalv TYPE STANDARD TABLE OF /dbe/v_alvoptions.
    DATA : lo_badi_vehicle_ui TYPE REF TO /dbe/badi_vehicle_ui.
    DATA:  mo_protocol TYPE REF TO cl_alv_changed_data_protocol.

    DATA : ls_fields TYPE  dfies.
    DATA : lt_return TYPE STANDARD TABLE OF ddshretval.
    DATA : ls_return TYPE ddshretval.
    DATA : lv_row_id TYPE int4.

    DATA : ls_ltext_opt LIKE LINE OF gs_iobj_multi-/dbe/v_ltext_opt.

*    DATA: lo_options TYPE REF TO /DBE/cl_veh_option_assistant,
*          lr_options TYPE REF TO data.

    FIELD-SYMBOLS: <f1>       TYPE         t_v_alvoptions.
    FIELD-SYMBOLS: <ls_ltext> LIKE LINE OF ls_ltext_opt-ltext.

*   In case of ALV data_changed event PBO is not executed so navigation
*   block flag is not cleared at the end of PBO in f_error_show->clear it here
    CALL FUNCTION '/DBE/VM08_ERROR_SET'
      EXPORTING
        iv_block_navigation = abap_false.

**Check if inserted row is not empty
    IF e_onf4 NE gc_xflag AND e_onf4 NE gc_aflag.
      lv_prc_pai = gc_xflag.
    ENDIF.

*   store modified data for usage in handle_f4 N:2338127
    IF e_onf4 = abap_true AND e_onf4_before = abap_true.
      mo_data_changed = er_data_changed.
    ELSE.
      CLEAR mo_data_changed.
    ENDIF.

*Get the domain description in order to check if lower case enable
*in opkey column
    lv_domname = '/DBE/OPKEY_UI'.

    CALL FUNCTION 'DDIF_DOMA_GET'
      EXPORTING
        name          = lv_domname
*       STATE         = 'A'
*       LANGU         = ' '
      IMPORTING
*       GOTSTATE      =
        dd01v_wa      = ls_domdesc
* TABLES
*       DD07V_TAB     =
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc NE 0.
      CLEAR ls_domdesc.
    ENDIF.

*Check if no errors in changed data
    LOOP AT er_data_changed->mt_mod_cells
      TRANSPORTING NO FIELDS WHERE error EQ 'X'.
      lv_error = 'X'.
    ENDLOOP.

    CHECK lv_error NE 'X'.

*   Get the valid option types for selected class
    SET PARAMETER ID gc_opclass FIELD opclass.              "#EC EXISTS

*   Get the Badi instance
    CALL FUNCTION '/DBE/VM08_BADI_UI_INSTANCE_GET'          "N.1649844
      IMPORTING
        eo_instance = lo_badi_vehicle_ui.

*   Call the Badi in order to change the standard on data changed process
    IF lo_badi_vehicle_ui IS BOUND.
      CALL BADI lo_badi_vehicle_ui->iobj_multi_alv_data_changed
        EXPORTING
          ir_data_changed = er_data_changed
          iv_onf4         = e_onf4
          iv_onf4_before  = e_onf4_before
          iv_onf4_after   = e_onf4_after
          iv_ucomm        = e_ucomm
          iv_settype_name = '/DBE/V_IOPTION'
          ir_alv_grid     = mo_alv_grid
          it_outtab       = gt_optionalv
        CHANGING
          ev_prc_pai      = lv_prc_pai.

*     Check if no errors in the alv grid
      mo_protocol = er_data_changed.
      READ TABLE er_data_changed->mt_protocol[]
      TRANSPORTING NO FIELDS WITH KEY msgty = 'E'.
      IF sy-subrc EQ 0.
        CLEAR lv_prc_pai.
      ENDIF.
    ENDIF.

*Set parameters relevant for search help                                          "N:2543315
    SET PARAMETER ID gc_model_guid FIELD gs_iobj_single-/dbe/v_imodel-modguid.
    SET PARAMETER ID gc_optyp      FIELD space.

*Call F4 for option key
    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
      EXPORTING
        tabname             = ls_fields-tabname
        fieldname           = ls_fields-fieldname
        searchhelp          = '/DBE/OPKEY_COL'
        suppress_recordlist = 'X'
      TABLES
        return_tab          = lt_return
      EXCEPTIONS
        field_not_found     = 1
        no_help_for_field   = 2
        inconsistent_help   = 3
        no_values_found     = 4
        OTHERS              = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*Check if option category belongs to the option class and
*update the inserted rows by option class
    ASSIGN er_data_changed->mp_mod_rows->* TO <f1>.
    LOOP AT <f1> INTO ls_opti.
      lv_index = sy-tabix.
*Get row id
      READ TABLE er_data_changed->mt_mod_cells INTO
        ls_modcell WITH KEY tabix = lv_index.
      IF sy-subrc EQ 0.
        lv_row_id = ls_modcell-row_id.
      ELSE.
        CLEAR lv_row_id.
      ENDIF.
      READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY
        fieldname = 'OPTYP' fieldval = ls_opti-optyp.
      IF sy-subrc NE 0.
        lv_error = 'X'.
*Error message
        MESSAGE ID '/DBE/VEHICLE_MASTER' TYPE 'E' NUMBER '034'
              WITH ls_opti-optyp opclass
              INTO ls_bapireturn-message.
*Show the error messages
        CALL METHOD er_data_changed->add_protocol_entry
          EXPORTING
            i_msgid     = sy-msgid
            i_msgty     = sy-msgty
            i_msgno     = sy-msgno
            i_msgv1     = sy-msgv1
            i_msgv2     = sy-msgv2
            i_fieldname = 'OPTYP'
            i_row_id    = lv_row_id
            i_tabix     = lv_index.
      ENDIF.
*check dublicate keys
      CLEAR ls_option.
      IF ls_opti-opkey IS INITIAL.
        lv_error = 'X'.
*Error message
        MESSAGE ID '/DBE/VEHICLE_MASTER' TYPE 'E' NUMBER '038'
        INTO ls_bapireturn-message.
*Show the error messages
        CALL METHOD er_data_changed->add_protocol_entry
          EXPORTING
            i_msgid     = sy-msgid
            i_msgty     = sy-msgty
            i_msgno     = sy-msgno
            i_msgv1     = sy-msgv1
            i_msgv2     = sy-msgv2
            i_fieldname = 'OPKEY'
            i_row_id    = lv_row_id
            i_tabix     = lv_index.
      ELSE.
        CLEAR lt_optionalv.
        lt_optionalv = gt_optionalv.
        DELETE lt_optionalv INDEX lv_row_id.
        READ TABLE lt_optionalv TRANSPORTING NO FIELDS WITH KEY
                                        opclass = ls_opti-opclass
                                        opkey   = ls_opti-opkey.
        IF sy-subrc = 0.
          lv_error = 'X'.
*Error message
          MESSAGE ID '/DBE/VEHICLE_MASTER' TYPE 'E' NUMBER '023'
          WITH ls_option-optyp opclass
          INTO ls_bapireturn-message.
*Show the error messages
          CALL METHOD er_data_changed->add_protocol_entry
            EXPORTING
              i_msgid     = sy-msgid
              i_msgty     = sy-msgty
              i_msgno     = sy-msgno
              i_msgv1     = sy-msgv1
              i_msgv2     = sy-msgv2
              i_fieldname = 'OPKEY'
              i_row_id    = lv_row_id
              i_tabix     = lv_index.
        ENDIF.        " IF sy-subrc = 0.
      ENDIF.      " IF NOT ls_option-opkey IS INITIAL.

*Check if longtext needs to be copyied
      IF lv_error NE 'X'.
        CLEAR ls_option.
        READ TABLE gt_optionalv INTO ls_option INDEX lv_row_id.
        CLEAR lv_tdname.
        CONCATENATE gs_vlcdiavehi-vguid
                    ls_option-opclass
                    ls_option-opkey
                    INTO lv_tdname.
*--> read the possibly existing concerned option longtext
        READ TABLE gs_iobj_multi-/dbe/v_ltext_opt INTO ls_ltext_opt
                   WITH KEY tdobject = /dbe/cl_ltext=>c_tdobject_vehi_o
                              tdname   = lv_tdname.
        IF sy-subrc = 0.
*--> copy longtext
          CLEAR lv_tdname.
          CONCATENATE gs_vlcdiavehi-vguid
                      ls_opti-opclass
                      ls_opti-opkey
                      INTO lv_tdname.
          ls_ltext_opt-tdname = lv_tdname.
          LOOP AT ls_ltext_opt-ltext ASSIGNING <ls_ltext>.
            <ls_ltext>-tdname = lv_tdname.
            <ls_ltext>-chngd  = /dbe/cl_ltext=>c_insert.
          ENDLOOP.
          APPEND ls_ltext_opt TO gs_iobj_multi-/dbe/v_ltext_opt.
        ENDIF.
      ENDIF.

*Update the class to the inserted rows
      READ TABLE er_data_changed->mt_inserted_rows TRANSPORTING NO
          FIELDS WITH KEY row_id = lv_row_id.
      IF sy-subrc EQ 0.
        ls_opti-opclass = opclass.
        MODIFY <f1> FROM ls_opti INDEX lv_index.
      ENDIF.
      CLEAR: ls_opti.
    ENDLOOP.

*Check if no errors
    CHECK lv_error NE 'X'.

*Get the changed data
    LOOP AT er_data_changed->mt_mod_cells INTO
      ls_modcell WHERE value IS NOT INITIAL.
      IF ls_modcell-fieldname EQ gc_opkey.
        lv_key_changed = gc_xflag.
        lv_opkey = ls_modcell-value.
        lv_tabix = ls_modcell-row_id.
*Check whether op_key should be converted to upper case
        IF ls_domdesc-lowercase NE 'X'.
          SET LOCALE LANGUAGE sy-langu.
          TRANSLATE lv_opkey TO UPPER CASE.
        ENDIF.
*Update option line if option is defined in model master
        CALL METHOD update_option_line
          EXPORTING
            e_opkey         = lv_opkey
            e_tabix         = lv_tabix
            er_data_changed = er_data_changed
          IMPORTING
            i_error         = lv_error.
        READ TABLE gt_optionalv INTO ls_opti INDEX lv_tabix.
        IF sy-subrc EQ 0.
          CLEAR ls_option.
          READ TABLE <f1> INTO ls_option
            WITH KEY opkey = lv_opkey.
*                     opclass = ls_opti-opclass.
          IF sy-subrc EQ 0.
            lv_index = sy-tabix.
*If option defined in the model master, then overwrite with master data
            IF lv_error NE 'X'.
              MODIFY <f1> FROM ls_opti INDEX lv_index.
*If option not from model master, then clear the guid
            ELSE.
              CLEAR: ls_option-option_guid, ls_opti-option_guid.
              MODIFY <f1> FROM ls_option INDEX lv_index.
              MODIFY gt_optionalv INDEX lv_tabix FROM ls_opti. "#EC CI_NOORDER
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*   Show the error messages
    CALL FUNCTION '/DBE/CO_APLG_MSG_DISP_POPUP'
      EXPORTING
        it_error_tab2 = lt_bapireturn.

    IF lt_bapireturn IS NOT INITIAL.
      CALL FUNCTION '/DBE/VM08_ERROR_SET'
        EXPORTING
          iv_block_navigation = abap_true.
    ENDIF.

    CLEAR: lt_bapireturn.

* call PAI processing
    IF lv_prc_pai EQ gc_xflag OR lv_key_changed NE space.
      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = gc_xxxx_fc.
    ENDIF.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED


  METHOD button_click.

    DATA: ls_optionalv       TYPE /dbe/v_alvoptions,
          ls_optionalv_check TYPE /dbe/v_alvoptions.

    DATA: ls_tdetproc_vhop_det_com  TYPE /dbe/v_tdetproc_vhop_det_com,
          ls_tdetproc_vhop_det_data TYPE /dbe/v_tdetproc_vhop_det_data.

    DATA: ls_ltext_opt LIKE LINE OF gs_iobj_multi-/dbe/v_ltext_opt.

    DATA: lv_actvt    TYPE activ_auth,
          lv_tdname   TYPE tdobname,
          lv_index    TYPE sy-tabix,
          lv_veh_mode TYPE c.

*--> determine the activity
    CALL FUNCTION '/DBE/VM08_VEHICLE_MODE_GET'
      IMPORTING
        ev_veh_mode = lv_veh_mode.

    IF lv_veh_mode EQ gc_0.
      lv_actvt = '03'.     " /DBE/cl_ltext_ui=>c_show_actvt.
    ELSE.
      lv_actvt = '02'.     " /DBE/cl_ltext_ui=>c_edit_actvt.
    ENDIF.

*--> read concerned alv line
    READ TABLE gt_optionalv INTO ls_optionalv INDEX es_row_no-row_id.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

*--> build text key
    CLEAR lv_tdname.
    CONCATENATE gs_vlcdiavehi-vguid
                ls_optionalv-opclass
                ls_optionalv-opkey
                INTO lv_tdname.

*--> read the possibly existing concerned option longtext
    READ TABLE gs_iobj_multi-/dbe/v_ltext_opt INTO ls_ltext_opt
                 WITH KEY tdobject = /dbe/cl_ltext=>c_tdobject_vehi_o
                           tdname   = lv_tdname.
    lv_index = sy-tabix.
    IF ls_ltext_opt-tdobject IS INITIAL.
*--> Build up the longtext key in case of a new one
      ls_ltext_opt-tdobject = /dbe/cl_ltext=>c_tdobject_vehi_o.
      ls_ltext_opt-tdname   = lv_tdname.
    ENDIF.

*--> determine the text determination procedure
    MOVE-CORRESPONDING gs_vlcdiavehi TO ls_tdetproc_vhop_det_com.
    MOVE-CORRESPONDING ls_optionalv  TO ls_tdetproc_vhop_det_com.
    ls_tdetproc_vhop_det_com-category_id = gv_iobj_catid.
    CALL METHOD /dbe/cl_lc_access=>read
      EXPORTING
        i_usage = /dbe/cl_ltext=>c_lc_usage_vehi_o
        i_com   = ls_tdetproc_vhop_det_com
      IMPORTING
        e_data  = ls_tdetproc_vhop_det_data.
    ls_ltext_opt-ltdetproc = ls_tdetproc_vhop_det_data-ltdetproc_vhop.

*--> Call the longtext popup
    CALL FUNCTION '/DBE/CO_LT_APPL_LTEXT_POPUP'
      EXPORTING
        iv_ltdetproc = ls_ltext_opt-ltdetproc
        is_ltext_com = ls_ltext_opt
        iv_actvt     = lv_actvt
      IMPORTING
        es_ltext_com = ls_ltext_opt
      EXCEPTIONS
        canceled     = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      IF lv_index IS INITIAL.
        APPEND ls_ltext_opt TO gs_iobj_multi-/dbe/v_ltext_opt.
      ELSE.
        MODIFY gs_iobj_multi-/dbe/v_ltext_opt
                             FROM ls_ltext_opt INDEX lv_index.
      ENDIF.
    ENDIF.

*--> Call pai when change mode
    IF lv_actvt = '02'.     " /DBE/cl_ltext_ui=>c_edit_actvt.
      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = gc_xxxx_fc.
    ENDIF.

  ENDMETHOD.                    "button_click

* update option line from model master in case of F4 help
*    or manual OPKEY
  METHOD update_option_line.
    TYPES : t_v_alvoptions TYPE STANDARD TABLE OF /dbe/v_alvoptions.
    DATA : ls_option TYPE /dbe/v_moptions.
    DATA : ls_option_mod TYPE /dbe/v_alvoptions.
    DATA : ls_optiont TYPE /dbe/v_moptionst.
    DATA : ls_alvoption TYPE /dbe/v_alvoptions.
    DATA : lv_index TYPE sy-tabix.

    FIELD-SYMBOLS <f1> TYPE t_v_alvoptions.

    IF er_data_changed IS BOUND.
      ASSIGN er_data_changed->mp_mod_rows->* TO <f1>.
    ENDIF.

*   take option data from model master
    SELECT * UP TO 1 ROWS
      FROM /dbe/v_moptions
      INTO ls_option
      WHERE model_guid = gs_iobj_single-/dbe/v_imodel-modguid
        AND opclass    = opclass
        AND opkey      = e_opkey.   "#EC CI_NOFIELD
    ENDSELECT.
    IF sy-subrc EQ 0.
*     Check the option type
      IF <f1> IS ASSIGNED.
        READ TABLE <f1> INTO ls_option_mod
              WITH KEY opkey = e_opkey.
        IF sy-subrc EQ 0.
          IF ( ls_option_mod-optyp NE ls_option-optyp ) AND
            ls_option_mod-optyp IS NOT INITIAL.
            i_error = 'X'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
*     Get the option text
      SELECT SINGLE * INTO ls_optiont
        FROM /dbe/v_moptionst
        WHERE option_guid = ls_option-option_guid
          AND spras       = sy-langu.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ls_optiont TO ls_alvoption.
      ENDIF.

      MOVE-CORRESPONDING ls_option TO ls_alvoption.
      MOVE e_tabix TO lv_index.
      MODIFY gt_optionalv INDEX lv_index FROM ls_alvoption. "#EC CI_NOORDER
      IF sy-subrc NE 0.
        APPEND ls_alvoption TO gt_optionalv.
      ENDIF.
    ELSE.
      i_error = 'X'.
    ENDIF.

  ENDMETHOD.                    "UPDATE_OPTION_LINE

ENDCLASS.               "LCL_OPTIONALV_EVENT_RECEIVER

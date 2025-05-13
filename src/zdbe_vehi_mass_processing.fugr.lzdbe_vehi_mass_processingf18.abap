*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF18 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZE_CREA_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialize_crea_screen .
* TO DO Modularise
  DATA  lt_roles            TYPE STANDARD TABLE OF cvlc19.
  DATA  lt_return           TYPE bapiret2_t.
  DATA  lv_dummy            TYPE c.
  DATA  lo_factory          TYPE REF TO /dbe/cl_veh_md_reader_factory.
  DATA  lo_reader           TYPE REF TO /dbe/if_veh_md_reader.
  DATA  lo_buskey           TYPE REF TO /dbe/cl_veh_md_key_bustype.
  DATA  lo_result           TYPE REF TO /dbe/if_veh_md_result.
  DATA  lo_division         TYPE REF TO /dbe/cl_veh_md_key_division.
  DATA  lo_usagetype        TYPE REF TO /dbe/cl_veh_md_key_usagetype.
  DATA  lo_salesorg         TYPE REF TO /dbe/cl_veh_md_key_salesorg.
  DATA  lo_category         TYPE REF TO /dbe/cl_veh_md_key_category.
  DATA  lo_plant            TYPE REF TO /dbe/cl_veh_md_key_plant.
  DATA  lo_distrch          TYPE REF TO /dbe/cl_veh_md_key_distrch.
  DATA  lo_bpkey            TYPE REF TO /dbe/cl_veh_md_key_bp.
  DATA  lv_model_sales_code TYPE REF TO /dbe/cl_veh_md_key_vmodel.
  DATA  lv_error_message    TYPE string.

  CONSTANTS: lc_catalog(25)     TYPE c VALUE '/DBE/V_MCATALOGT-MCATALOG',
             lc_catalog_txt(22) TYPE c VALUE '/DBE/V_MCATALOGT-DESCR'.

*Set catalog data invisible on the screen if catalog key is not determie
  IF gv_mcatalog IS INITIAL.
    LOOP AT SCREEN.
      IF screen-name EQ lc_catalog OR
        screen-name EQ lc_catalog_txt.              .
        screen-invisible = gc_1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
* Chech whether create is called via action - If called via action,disable the
* 'Create Vehicles button.
  IF gv_action_tobe_executed = abap_true.
    LOOP AT SCREEN.
      IF screen-name EQ 'EXEC'.                .
        screen-invisible = gc_1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  PERFORM f_check_bustype.

* check if the user is assigned to VMS-roles
  CALL FUNCTION 'VELO14_READ_CVLC25'
    EXPORTING
      username_iv       = sy-uname
    TABLES
      vmsroles_et       = lt_roles
    EXCEPTIONS
      no_roles_assigned = 1
      OTHERS            = 2.

  IF sy-subrc <> 0 OR lt_roles IS INITIAL.
    MESSAGE e166(velo) INTO lv_dummy.

    CALL FUNCTION '/DBE/CO_APLG_FILL_RETURN_TABLE'
      TABLES
        ct_return = lt_return.

    CALL FUNCTION '/DBE/CO_APLG_MSG_DISP_POPUP'
      EXPORTING
        it_error_tab2 = lt_return.
    LEAVE PROGRAM.
  ENDIF.

****In first screen interaction clear old buffer
*If new vehicle process, clear old structure
  CASE gv_ok_code.
    WHEN gc_new_fc.
      CLEAR: /dbe/v_imodel_old,gv_dbm_old_catalog.
    WHEN OTHERS.
  ENDCASE.

  DATA lr_exroot TYPE REF TO cx_root.
  TRY.
      lo_factory = /dbe/cl_veh_md_reader_factory=>get_instance( ).

*     reading the bustype
      TRY.
          lo_reader = lo_factory->create_reader( 'BUSTYPE' ).
          lo_buskey ?= lo_reader->createkey( ).
          lo_buskey->set_bustype( vlcactdata_head_s-/dbe/bustype ).
          lo_buskey->set_lang( sy-langu ).
          lo_result = lo_reader->read( lo_buskey ).
          /dbe/v_bustypet-descr = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          /dbe/v_bustypet-descr = ''.
      ENDTRY.

*     read the division
      TRY.
          lo_reader = lo_factory->create_reader( 'DIVISION' ).
          lo_division ?= lo_reader->createkey( ).
          lo_division->set_division( vlcactdata_item_s-/dbe/spart ).
          lo_result = lo_reader->read( lo_division ).
          tspat-vtext = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          tspat-vtext = ''.
      ENDTRY.

*     read usage type
      TRY.
          lo_reader = lo_factory->create_reader( 'USAGETYPE' ).
          lo_usagetype ?= lo_reader->createkey( ).
          lo_usagetype->set_usagetype( vlcdiavehi-vhusg ).
          lo_result = lo_reader->read( lo_usagetype ).
          cvlc13t-vhusgt = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          cvlc13t-vhusgt = ''.
      ENDTRY.

*     read plant
      TRY.
          lo_reader = lo_factory->create_reader( 'PLANT' ).
          lo_plant ?= lo_reader->createkey( ).
          lo_plant->set_plant( vlcactdata_head_s-werks ).
          lo_result = lo_reader->read( lo_plant ).
          t001w-name1 = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t001w-name1 = ''.
      ENDTRY.

*     read category
      TRY.
          lo_reader = lo_factory->create_reader( 'CATEGORY' ).
          lo_category ?= lo_reader->createkey( ).
          lo_category->set_category( /dbe/vm_fields_crea-category_id ).
          lo_result = lo_reader->read( lo_category ).
          comt_categoryt-category_text = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          comt_categoryt-category_text = ''.
      ENDTRY.

*     read sales organization
      TRY.
          lo_reader = lo_factory->create_reader( 'SALESORG' ).
          lo_salesorg ?= lo_reader->createkey( ).
          lo_salesorg->set_salesorg( vlcactdata_head_s-/dbe/vkorg ).
          lo_result = lo_reader->read( lo_salesorg ).
          tvkot-vtext = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          tvkot-vtext = ''.
      ENDTRY.

*     read distribution channel
      TRY.
          lo_reader = lo_factory->create_reader( 'DISTRCH' ).
          lo_distrch ?= lo_reader->createkey( ).
          lo_distrch->set_distrch( vlcactdata_head_s-/dbe/vtweg ).
          lo_result = lo_reader->read( lo_distrch ).
          tvtwt-vtext = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          tvtwt-vtext = ''.
      ENDTRY.

*     read business partner
      TRY.
          lo_reader = lo_factory->create_reader( 'BP' ).
          lo_bpkey ?= lo_reader->createkey( ).
          lo_bpkey->set_bpkey( /dbe/v_ipartner_dynp-partner ).
          lo_result = lo_reader->read( lo_bpkey ).
          /dbe/v_ipartner_dynp-partner_desc = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          /dbe/v_ipartner_dynp-partner_desc = ''.
      ENDTRY.

*     read vmodel text
      TRY.
          lo_reader = lo_factory->create_reader( 'VMODEL' ).
          lv_model_sales_code ?= lo_reader->createkey( ).
          lv_model_sales_code->set_model_guid( /dbe/v_imodel-modguid ).
          lo_result = lo_reader->read( lv_model_sales_code ).
          /dbe/v_modelt-motext1 = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          /dbe/v_modelt-motext1 = ''.
      ENDTRY.

    CATCH cx_root INTO lr_exroot .
      lv_error_message = lr_exroot->if_message~get_longtext( ).
*     if something went wrong during reading short text, the shost text will be empty and error silently
*     dropped becasue it not effecting.
  ENDTRY.
ENDFORM.                    " F_INITIALIZE_CREA_SCREEN

*&---------------------------------------------------------------------*
*&      Form  f_update_scrfield_visibility_initial
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_scrfield_visibility_initial .
  LOOP AT SCREEN.
    IF screen-group1 EQ 'EXP'.
      screen-invisible = 1.
    ELSEIF screen-group1 EQ 'COL'.
      screen-invisible = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    "f_update_scrfield_visibility_initial

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_VISIBILITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_scrfield_visibility .
*
*  DATA:
*   lv_group(3) TYPE c VALUE 'EXP'.

  gv_ok_code = sy-ucomm.
  "Change gv_ok_code temporary
  IF gv_expand_flag = abap_true.
    gv_ok_code     = gc_expand_fcode.
    gv_expand_flag = abap_false.
  ENDIF.
  CASE gv_ok_code.
    WHEN gc_collapse_fcode.

      CALL METHOD go_options_container->set_visible
        EXPORTING
          visible = cl_gui_control=>visible_false.

      LOOP AT SCREEN.
        IF screen-group1 EQ 'COL'.
          screen-invisible = 1.
        ELSEIF screen-group1 EQ 'EXP'.
          screen-invisible = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN gc_expand_fcode OR gc_load_okcode.
      CALL METHOD go_options_container->set_visible
        EXPORTING
          visible = cl_gui_control=>visible_true.

      LOOP AT SCREEN.
        IF screen-group1 EQ 'EXP'.
          screen-invisible = 1.
        ELSEIF screen-group1 EQ 'COL'.
          screen-invisible = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN OTHERS.
      "Change back gv_ok_code to sy-ucomm
      gv_ok_code = sy-ucomm.
      RETURN.
  ENDCASE.

  LOOP AT SCREEN.
    IF screen-name EQ 'EXEC' .
      IF gv_disable_button_qcre EQ abap_true. "and gv_ok_code EQ gc_opclass.
        screen-invisible = 1.
      ELSE.
        screen-invisible = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  "Change back gv_ok_code to sy-ucomm
  gv_ok_code = sy-ucomm.
ENDFORM.                    "f_update_scrfield_visibility

*&---------------------------------------------------------------------*
*&      Form  f_option_dropdown
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_option_dropdown.

  TYPE-POOLS vrm.

  DATA:
    ls_opclass_values TYPE vrm_value,
    lt_domvals        TYPE STANDARD TABLE OF dd07v,
    ls_domval         TYPE dd07v,
    lv_domain         TYPE ddobjname,
    lv_id             TYPE vrm_id.


  IF gv_opclass IS INITIAL.
    CLEAR :
      gt_opclass_values.

    CALL FUNCTION 'DDUT_DOMVALUES_GET'
      EXPORTING
        name          = '/DBE/VD_OPCLASS'
        langu         = sy-langu
      TABLES
        dd07v_tab     = lt_domvals
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    "add value for all options
    ls_opclass_values-text = TEXT-002.
    ls_opclass_values-key =  gc_option_allclasses_key.
    APPEND ls_opclass_values TO gt_opclass_values.

    LOOP AT lt_domvals INTO ls_domval.
      ls_opclass_values-text = ls_domval-ddtext.
      ls_opclass_values-key = ls_domval-domvalue_l.
      APPEND ls_opclass_values TO gt_opclass_values.
    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'GV_OPCLASS'
        values          = gt_opclass_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    gv_opclass =  gc_option_allclasses_key.

  ENDIF.

ENDFORM.                    "f_option_dropdown
*&---------------------------------------------------------------------*
*&      Module  M_CHANGE_VEHICLE_OPTION_101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_change_vehicle_option_101 INPUT.

  PERFORM  f_change_vehicle_option.

ENDMODULE.                 " M_CHANGE_VEHICLE_OPTION_101  INPUT

*----------------------------------------------------------------------*
*  MODULE set_cursor INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF15 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODEL_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_model_f4 .

* TO DO : Modularization required

  CONSTANTS: lc_spart  TYPE string VALUE 'VLCACTDATA_ITEM_S-/DBE/SPART',
              lc_werks    TYPE string VALUE 'VLCACTDATA_HEAD_S-WERKS',
              lc_mcodesd  TYPE string VALUE '/DBE/V_IMODEL-MCODESD',
              lc_mcatalog TYPE string VALUE '/DBE/V_MCATALOGT-MCATALOG',
              lc_mcatdesc TYPE string VALUE '/DBE/V_MCATALOGT-DESCR'.

  DATA: ls_errmsg TYPE string,
        ls_error  TYPE bapiret2,
        lt_errors TYPE bapiret2_t.

  DATA: ls_model     TYPE /DBE/v_model.
  DATA: lv_vk_code   TYPE /DBE/MODCODE_SALE.
  DATA: lv_land1     TYPE land1.                            "#EC NEEDED
  DATA: ls_dynpro    TYPE d020s.
  DATA: lt_dynpread  TYPE STANDARD TABLE OF dynpread.
  DATA: ls_dynpread  TYPE dynpread.
  DATA: ls_mcatalogt TYPE /DBE/v_mcatalogt.                 "#EC NEEDED
  DATA: lv_cat_chg   TYPE c.
  DATA: lv_nopopup   TYPE c.
  DATA: lt_roles        TYPE TABLE OF cvlc19,
        lt_materials    TYPE TABLE OF cvlc24.
  DATA: lv_matnr        TYPE matnr.

* Master data reader declarations
  DATA lo_factory        TYPE REF TO /DBE/cl_veh_md_reader_factory.
  DATA lo_reader         TYPE REF TO /DBE/if_veh_md_reader.
  DATA lo_vmodel_ext_key TYPE REF TO /DBE/cl_veh_md_key_vmodel_ext.
  DATA lo_result         TYPE REF TO /DBE/cl_veh_md_result_vmodel_e.
  DATA lr_exroot         TYPE REF TO cx_root.
  DATA ls_model_check    TYPE /DBE/v_model.
  CLEAR gv_block_navigation .

  lv_vk_code = /DBE/V_IMODEL-mcodesd.

*Check if spart and werks has been changed without procesing PAI
  ls_dynpro-prog = sy-repid.
  ls_dynpro-dnum = sy-dynnr.

  ls_dynpread-fieldname = lc_spart.
  APPEND ls_dynpread TO lt_dynpread.
  ls_dynpread-fieldname = lc_werks.
  APPEND ls_dynpread TO lt_dynpread.
  ls_dynpread-fieldname = lc_mcodesd.
  APPEND ls_dynpread TO lt_dynpread.

* take pre PAI values, in case no pai procesing was performed
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = ls_dynpro-prog
      dynumb               = ls_dynpro-dnum
    TABLES
      dynpfields           = lt_dynpread
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc <> 0.                                         "#EC NEEDED
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*get entered data on the screen
  READ TABLE lt_dynpread INTO ls_dynpread
    WITH KEY fieldname = lc_spart.
  IF sy-subrc EQ 0.
    IF vlcactdata_item_s-/DBE/spart NE ls_dynpread-fieldvalue. "#EC *
      vlcactdata_item_s-/DBE/spart = ls_dynpread-fieldvalue.
      lv_cat_chg = gc_xflag.
    ENDIF.
  ENDIF.
  READ TABLE lt_dynpread INTO ls_dynpread
    WITH KEY fieldname = lc_werks.
  IF sy-subrc EQ 0.
    IF vlcactdata_head_s-werks NE ls_dynpread-fieldvalue.   "#EC *
      vlcactdata_head_s-werks = ls_dynpread-fieldvalue.
      lv_cat_chg = gc_xflag.
    ENDIF.
  ENDIF.


  IF gv_dbm_old_catalog NE gv_mcatalog OR lv_cat_chg EQ gc_xflag.
    gv_dbm_old_catalog = gv_mcatalog.
    CLEAR: lv_vk_code, /DBE/V_IMODEL-mcodesd.
  ENDIF.

*If data have been changed - determine the new catalog
  PERFORM f_check_catalog.

  IF gv_mcatalog IS INITIAL.
    CLEAR lv_vk_code.
  ENDIF.

  IF ok_code NE gc_f4_fc.
    lv_nopopup = gc_xflag.
  ENDIF.
  CLEAR ok_code.

*get entered model sales code on the screen
  READ TABLE lt_dynpread INTO ls_dynpread
    WITH KEY fieldname = lc_mcodesd.
  IF sy-subrc EQ 0.
    IF lv_vk_code NE ls_dynpread-fieldvalue.                "#EC *
      lv_vk_code = ls_dynpread-fieldvalue.
    ENDIF.
  ENDIF.

*Check for model catalog authorization

  CALL FUNCTION '/DBE/CHECK_MODELCATALOG_AUTH'
    EXPORTING
      iv_model_cat = gv_mcatalog
    EXCEPTIONS
      no_authority = 1
      OTHERS       = 2.

  IF sy-subrc = 0.
*      Call F4 search function module
    CALL FUNCTION '/DBE/VM16_MODEL_SEARCH_HELP2'
      EXPORTING
        iv_vk_code  = lv_vk_code
        iv_mcatalog = gv_mcatalog
        iv_nopopup  = lv_nopopup
      IMPORTING
        es_model    = ls_model.
  ELSEIF sy-subrc = 1.
    CLEAR gv_mcatalog.
    CLEAR /DBE/V_IMODEL-mcodesd.
    CLEAR ls_model.
  ELSE.
    CLEAR ls_model.
  ENDIF.
*Check Model Sales Code related issues
  IF ls_model IS INITIAL.
    "Determine that why the entered model cannot be selected
    CALL FUNCTION 'VELO14_READ_CVLC25'
      EXPORTING
        username_iv       = sy-uname
      TABLES
        vmsroles_et       = lt_roles
      EXCEPTIONS
        no_roles_assigned = 1
        OTHERS            = 2.
    IF sy-subrc = 0 AND
       lt_roles[] IS NOT INITIAL AND
       lv_vk_code IS NOT INITIAL.

      "Get model data using the extended VModel master data reader
      TRY.
          lo_factory = /DBE/cl_veh_md_reader_factory=>get_instance( ).
          lo_reader = lo_factory->create_reader( 'VMODEL_EXT' ).
          lo_vmodel_ext_key ?= lo_reader->createkey( ).
          lo_vmodel_ext_key->set_mcodesd( lv_vk_code ).
          lo_result ?= lo_reader->read( lo_vmodel_ext_key ).
          ls_model_check = lo_result->vmodel_ext_record_get( ).
          lv_matnr = ls_model_check-matnr.
        CATCH cx_root INTO lr_exroot.
          CLEAR lv_matnr.
      ENDTRY.

      IF lv_matnr IS NOT INITIAL.
        "Check that the material is maintained in VELORM
        CALL FUNCTION 'VELO14_READ_CVLC24'                  "#EC *
          TABLES
            roles_it                    = lt_roles
            vlcrolemat_et               = lt_materials
          EXCEPTIONS
            no_role_material_assignment = 1
            OTHERS                      = 2.
        READ TABLE lt_materials WITH KEY material = lv_matnr
                                TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          "Material &1 is not assigned for role (transaction VELORM)
          MESSAGE e294(/DBE/vehicle_master) WITH lv_matnr lv_vk_code INTO ls_errmsg.
          ls_error-message = ls_errmsg.
          ls_error-type    = sy-msgty.
          ls_error-id      = sy-msgid.
          ls_error-number  = sy-msgno.
          ls_error-message_v1 = lv_vk_code.
          APPEND ls_error TO lt_errors.
        ENDIF.
      ELSE.
        "Model &1 does not exist (transaction /DBE/VMODEL)
        /DBE/V_IMODEL-mcodesd = ''.
        MESSAGE e290(/DBE/vehicle_master) WITH lv_vk_code INTO ls_errmsg.
        ls_error-message = ls_errmsg.
        ls_error-type    = sy-msgty.
        ls_error-id      = sy-msgid.
        ls_error-number  = sy-msgno.
        ls_error-message_v1 = lv_vk_code.
        APPEND ls_error TO lt_errors.

      ENDIF.
    ELSE.
      IF lv_vk_code IS NOT INITIAL.
        "Missing authorization (transaction VELORU)
        MESSAGE e293(/DBE/vehicle_master) INTO ls_errmsg.
        ls_error-message = ls_errmsg.
        ls_error-type    = sy-msgty.
        ls_error-id      = sy-msgid.
        ls_error-number  = sy-msgno.
        ls_error-message_v1 = lv_vk_code.
        APPEND ls_error TO lt_errors.

      ENDIF.
    ENDIF.

    IF ls_model-mcodesd = '' AND lv_nopopup EQ abap_true.
      MESSAGE e290(/DBE/vehicle_master) WITH lv_vk_code INTO ls_errmsg.
      ls_error-message = ls_errmsg.
      ls_error-type    = sy-msgty.
      ls_error-id      = sy-msgid.
      ls_error-number  = sy-msgno.
      ls_error-message_v1 = lv_vk_code.
      APPEND ls_error TO lt_errors.

    ENDIF.
  ENDIF.

*Get selected vk_code and model guid
  MOVE-CORRESPONDING ls_model TO /DBE/V_IMODEL  .
  MOVE-CORRESPONDING /DBE/V_IMODEL TO gs_iobj_single-/DBE/V_IMODEL.
  vlcactdata_head_s-matnr = ls_model-matnr.


  /DBE/V_IMODEL-mcodesd = ls_model-mcodesd.
  /DBE/V_IMODEL-modguid = ls_model-model_guid.
  IF /DBE/V_IMODEL-mcodesd NE /DBE/V_IMODEL_old-mcodesd.
    /DBE/V_IMODEL_old = /DBE/V_IMODEL.
    gv_expand_flag = abap_true.
  ENDIF.
*Update the fields on the screen
  IF lv_cat_chg EQ gc_xflag.
    CLEAR: lt_dynpread.
    ls_dynpread-fieldname = lc_mcatalog.
    ls_dynpread-fieldvalue = /DBE/v_mcatalogt-mcatalog.
    APPEND ls_dynpread TO lt_dynpread.
    ls_dynpread-fieldname = lc_mcatdesc.
    ls_dynpread-fieldvalue = /DBE/v_mcatalogt-descr.
    APPEND ls_dynpread TO lt_dynpread.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname               = ls_dynpro-prog
        dynumb               = ls_dynpro-dnum
      TABLES
        dynpfields           = lt_dynpread
      EXCEPTIONS
        invalid_abapworkarea = 1
        invalid_dynprofield  = 2
        invalid_dynproname   = 3
        invalid_dynpronummer = 4
        invalid_request      = 5
        no_fielddescription  = 6
        undefind_error       = 7
        OTHERS               = 8.
    IF sy-subrc <> 0.                                       "#EC NEEDED
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.


  IF lt_errors IS NOT INITIAL.
    "Delete same error message
    SORT lt_errors BY number.
    DELETE ADJACENT DUPLICATES FROM lt_errors COMPARING number.
    gv_cursor_on_field = '/DBE/V_IMODEL-MCODESD'.
    CALL FUNCTION '/DBE/CO_APLG_MSG_DISP_POPUP'
      EXPORTING
        it_error_tab2 = lt_errors.

    gv_ok_code = sy-ucomm.
  ENDIF.


ENDFORM.                    " F_MODEL_F4

*&---------------------------------------------------------------------*
*&      Form  f_prepare_optionalv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_prepare_optionalv.

  FIELD-SYMBOLS
        <fs_fieldcat> TYPE lvc_s_fcat.
  DATA:
        ls_fieldcat TYPE lvc_s_fcat.


  "Check and create container object for display options alv
  IF go_options_container IS INITIAL.
    CREATE OBJECT go_options_container
      EXPORTING
        container_name = gc_opt_container_name.
  ENDIF.
  "Check and create ALV object for options grid
  IF go_options_container IS BOUND AND go_alv_opt_grid IS INITIAL.
    CREATE OBJECT go_alv_opt_grid
      EXPORTING
        i_parent = go_options_container.
  ENDIF.

  "Option ALV event processing
  IF go_alv_opt_grid IS BOUND.
    "Register ALV event
    CALL METHOD go_alv_opt_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    "create the event handler for verifying the input data.
    CREATE OBJECT go_option_alv_handler.

    "Set ALV data changed event handler
    SET HANDLER go_option_alv_handler->handle_data_changed
           FOR go_alv_opt_grid.
    SET HANDLER go_option_alv_handler->handle_toolbar
           FOR go_alv_opt_grid.
    SET HANDLER go_option_alv_handler->handle_user_command          "N:2579712
           FOR go_alv_opt_grid.
  ENDIF.

  "create the field catalogue for option alv
  CLEAR gt_alv_opt_fieldcat.

  CALL FUNCTION 'VELO03_FIELDCATALOG_MERGE'
    EXPORTING
      structure_name_iv       = gc_opttabname
      client_never_display_iv = abap_true
    CHANGING
      fieldcat_ct             = gt_alv_opt_fieldcat
    EXCEPTIONS
      error_occured           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  "Change the layout properties for each column
  LOOP AT gt_alv_opt_fieldcat ASSIGNING <fs_fieldcat>.
    CASE <fs_fieldcat>-fieldname.
      WHEN  gc_option_guid   OR
            gc_model_guid    OR
            gc_opclass       OR
            gc_optext2       OR
            gc_optext3       OR
            gc_optext4       OR
            gc_optextnr      OR
            gc_active.
        <fs_fieldcat>-tech = abap_true.
      WHEN gc_copyrel.
        <fs_fieldcat>-checkbox = abap_true.
        <fs_fieldcat>-outputlen = 5.
      WHEN gc_optext1.
        <fs_fieldcat>-outputlen = 20.
      WHEN gc_puprc .
        <fs_fieldcat>-outputlen = 16.
        <fs_fieldcat>-coltext = 'Purchase Price'(020).
      WHEN gc_saprc.
        <fs_fieldcat>-outputlen = 16.
        <fs_fieldcat>-coltext = 'Sales Price'(021).
      WHEN gc_optyp.
        <fs_fieldcat>-outputlen = 8.
        <fs_fieldcat>-coltext = 'Category'(022).
*        <fs_fieldcat>-colddictxt = abap_true.
      WHEN gc_descr.
        <fs_fieldcat>-outputlen = 18.
      WHEN gc_pkonwa OR gc_skonwa.
        <fs_fieldcat>-coltext = text-124.
        <fs_fieldcat>-outputlen = 7.
      WHEN gc_matnr.
        <fs_fieldcat>-outputlen = 15.
      WHEN gc_mm_noord.
        <fs_fieldcat>-checkbox = abap_true.
        <fs_fieldcat>-outputlen = 7.
      WHEN gc_norordrel.
        <fs_fieldcat>-checkbox = abap_true.
        <fs_fieldcat>-outputlen = 7.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = gc_sel_option_field.
  ls_fieldcat-coltext   = 'Select'(008).
  ls_fieldcat-outputlen = 6.
  ls_fieldcat-col_pos   = 1.
  ls_fieldcat-checkbox = abap_true.
  ls_fieldcat-edit = abap_true.
  APPEND ls_fieldcat TO gt_alv_opt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = gc_copyrel.
  ls_fieldcat-coltext   = 'Default'(010).
  ls_fieldcat-outputlen = 6.
  ls_fieldcat-col_pos   = 2.
  ls_fieldcat-checkbox = abap_true.
  APPEND ls_fieldcat TO gt_alv_opt_fieldcat.



ENDFORM.                    "f_prepare_optionalv

*&---------------------------------------------------------------------*
*&      Form  f_display_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_display_optionalv.
  DATA: lt_toolbar_excluding        TYPE ui_functions,
        lo_badi_vehicle_ui          TYPE REF TO /DBE/badi_vehicle_ui,
        ls_variant                  TYPE disvariant,
        lv_save_variant             TYPE char1,
        lt_f4_fields                TYPE lvc_t_f4,
        ls_sort                     TYPE lvc_s_sort,
        lt_sort                     TYPE lvc_t_sort.
  FIELD-SYMBOLS:
        <fs_outtab>                 TYPE ANY TABLE.
  CONSTANTS:
         lc_tabname                 TYPE tabname VALUE '/DBE/V_IOPTION_DYNP_SV'.

  "Call the Badi in order to change the alv data
  CALL FUNCTION '/DBE/VM08_BADI_UI_INSTANCE_GET'
    IMPORTING
      eo_instance = lo_badi_vehicle_ui.


  ls_sort-fieldname = gc_sel_option_field.
  ls_sort-down = abap_true.
  ls_sort-level = 1.
  APPEND ls_sort TO lt_sort.

  ls_sort-fieldname = gc_optyp.
  ls_sort-down = abap_true.
  ls_sort-level = 2.
  APPEND ls_sort TO lt_sort.

  gs_layout_optalv-no_rowmark = abap_true.
  gs_layout_optalv-grid_title = text-005.

  gs_layout_optalv-smalltitle = abap_true.
  PERFORM exclude_tb_functions CHANGING lt_toolbar_excluding.

  CALL METHOD go_alv_opt_grid->set_table_for_first_display
    EXPORTING
      it_toolbar_excluding          = lt_toolbar_excluding
      is_layout                     = gs_layout_optalv
    CHANGING
      it_sort                       = lt_sort
      it_outtab                     = gt_optionalv
      it_fieldcatalog               = gt_alv_opt_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3.

  CALL METHOD go_alv_opt_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    "f_display_alv

*&---------------------------------------------------------------------*
*&      Form  f_populate_optionalv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_populate_optionalv.
  DATA:
      lt_vmod_opt   TYPE TABLE OF /DBE/v_moptions,
      ls_vmod_opt   TYPE /DBE/v_moptions,
      ls_optionalv  TYPE /DBE/v_options ,"ty_optionalv,
      lt_vmod_optt  TYPE TABLE OF /DBE/v_moptionst,
      ls_vmod_optt  TYPE /DBE/v_moptionst,
      ls_optypet    TYPE /DBE/v_optypet,
      lt_optypet    TYPE TABLE OF /DBE/v_optypet.
  FIELD-SYMBOLS:
        <fs_vmod_opt> TYPE /DBE/v_moptions.

  CLEAR: gt_optionalv, gt_optionalv_all.

  IF /DBE/V_IMODEL-modguid IS INITIAL.
    RETURN.
  ENDIF.

  CALL FUNCTION '/DBE/VM22_DB_OPTION_READ'
    EXPORTING
      iv_model_guid = /DBE/V_IMODEL-modguid
    TABLES
      et_vmod_opt   = lt_vmod_opt
    EXCEPTIONS
      not_found     = 1.

  IF sy-subrc = 0.
    "Fetch option text
    SELECT * FROM /DBE/v_moptionst
      INTO TABLE lt_vmod_optt
      FOR ALL ENTRIES IN lt_vmod_opt
      WHERE option_guid = lt_vmod_opt-option_guid AND spras = sy-langu.

    "Get Op-Type text
    SELECT * FROM /DBE/v_optypet
      INTO TABLE lt_optypet
      WHERE spras = sy-langu.


    LOOP AT lt_vmod_opt INTO ls_vmod_opt.
      "Get default options
      MOVE-CORRESPONDING ls_vmod_opt TO ls_optionalv.
      ls_optionalv-sel_option = ls_vmod_opt-copyrel.
      ls_optionalv-copy_rel = ls_vmod_opt-copyrel.

      "Get option text
      READ TABLE lt_vmod_optt
           WITH KEY option_guid = ls_vmod_opt-option_guid
           INTO ls_vmod_optt.
      ls_optionalv-optext1 = ls_vmod_optt-optext1.
      ls_optionalv-optext2 = ls_vmod_optt-optext2.
      ls_optionalv-optext3 = ls_vmod_optt-optext3.
      ls_optionalv-optext4 = ls_vmod_optt-optext4.
      ls_optionalv-optextnr = ls_vmod_optt-optextnr.

      "Get Op-Type Text
      READ TABLE lt_optypet INTO ls_optypet WITH KEY optyp = ls_vmod_opt-optyp TRANSPORTING descr.
      ls_optionalv-descr = ls_optypet-descr.

      APPEND ls_optionalv TO gt_optionalv.
    ENDLOOP.
    gt_optionalv_all = gt_optionalv.

    CASE gv_opclass.
      WHEN '*'.
        gt_optionalv = gt_optionalv_all.
      WHEN OTHERS.
        CLEAR gt_optionalv.
        LOOP AT gt_optionalv_all INTO ls_optionalv WHERE opclass EQ gv_opclass.
          APPEND ls_optionalv TO gt_optionalv.
        ENDLOOP.
    ENDCASE.
    CONCATENATE text-005 text-416 text-408 /DBE/V_IMODEL-mcodesd INTO gs_layout_optalv-grid_title SEPARATED BY ' '.
    CALL METHOD go_alv_opt_grid->refresh_table_display( ).
  ENDIF.

ENDFORM.                    "f_populate_optionalv
*&---------------------------------------------------------------------*
*&      Form  F_GET_MODTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_modtext .
* read vmodel text
  DATA:
        lo_factory TYPE REF TO /DBE/cl_veh_md_reader_factory,
        lo_reader1 TYPE REF TO /DBE/if_veh_md_reader,
        lo_result1 TYPE REF TO /DBE/if_veh_md_result,
        lv_model_sales_code TYPE REF TO /DBE/cl_veh_md_key_vmodel.

  TRY.
      lo_factory             = /DBE/cl_veh_md_reader_factory=>get_instance( ).
      lo_reader1             = lo_factory->create_reader( 'VMODEL' ).
      lv_model_sales_code   ?= lo_reader1->createkey( ).
      lv_model_sales_code->set_model_guid( /DBE/V_IMODEL-modguid ).
      lo_result1             = lo_reader1->read( lv_model_sales_code ).
      /DBE/v_modelt-motext1  = lo_result1->getstring( ).
    CATCH /DBE/cx_veh_md_datanotfound.
      /DBE/v_modelt-motext1  = ''.
  ENDTRY.

ENDFORM.                    " F_GET_MODTEXT

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF96 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BADI_ADC_INITIALIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM badi_adc_initialize .

  IF badi_dist_adc IS INITIAL.
    TRY.
        GET BADI badi_dist_adc.
      CATCH cx_root.
    ENDTRY.
  ENDIF.

ENDFORM.                    " BADI_ADC_INITIALIZE
*&---------------------------------------------------------------------*
*&      Form  SHOW_HIDE_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_hide_fields .
 CONSTANTS:  lv_gr1(3) VALUE 'GR1',
              lv_gr2(3) VALUE 'GR2',
              lv_gr3(3) VALUE 'GR3',
              lv_distribute_netamt(17)  VALUE 'DISTRIBUTE_NETAMT',
              lv_cost_all_button(15)    VALUE 'COST_ALL_BUTTON'.
  DATA:       lv_netamt TYPE boolean  .

  IF gv_action IS INITIAL. "we are not in /DBE/MASSACTION transaction   N:2066130
    DATA lv_action TYPE CVLC03.
    CALL FUNCTION '/DBE/VM08_SELECTED_ACTION_GET'
    IMPORTING
      es_sel_action        = lv_action.
    gv_action = lv_action-aktion.
  ENDIF.

  LOOP AT SCREEN.

    IF screen-name EQ 'VLCACTDATA_HEAD_S-/DBE/EXT_SRV_NETAMT' AND gv_netamt < '0'.
      CLEAR vlcactdata_head_s-/DBE/ext_srv_netamt.
      gv_netamt_neg = abap_true.
      MODIFY SCREEN.
      MESSAGE i449(/DBE/vehicle_master).
    ENDIF.

    CASE gv_action.
      WHEN /DBE/if_vms_constants=>c_qapo.
        IF screen-group1 NE lv_gr1 OR screen-name EQ lv_cost_all_button.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN /DBE/if_vms_constants=>c_qagr.
        IF screen-group2 NE lv_gr2.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN /DBE/if_vms_constants=>c_qain.
        IF screen-group3 NE lv_gr3.
          screen-active = 0.
          MODIFY SCREEN .
        ENDIF.

      WHEN /DBE/if_vms_constants=>c_qadc.
        IF screen-name EQ lv_distribute_netamt.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " SHOW_HIDE_FIELDS
*&---------------------------------------------------------------------*
*&      Form  PREPARE_DATA_0600
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_data_0600 .

  CONSTANTS:  lc_dd_all(6)  VALUE 'DD_ALL',
              lc_enter(5)   VALUE 'ENTER',
              lc_ente(4)   VALUE 'ENTE'.
  DATA:       lx_root TYPE REF TO cx_root,
              lo_buf  TYPE REF TO /DBE/cl_veh_buf,              "N:2304203
              lt_bob  TYPE /DBE/t_veh_bob,
              ls_bob  TYPE /DBE/s_veh_bob,
              lo_veh  TYPE REF TO /DBE/cl_veh_dbmvehicle,
              lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
              lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
              ls_guid TYPE vlcguid,
              lt_guids TYPE TABLE OF vlcguid.

*Dont execute when user press "Apply to All Button"
  IF gv_ok_code NE lc_dd_all AND gv_ok_code NE gc_ac_all AND gv_ok_code NE lc_enter AND gv_ok_code NE lc_ente.

* This indicates that actins are triggered by mass vehicle interface
    EXPORT cur_txn_name TO MEMORY ID 'TXN_NAME'.

* Default document date and posting date
*Document date while creating GR and invoice
    IF vlcactdata_head_s-bldat EQ 0 AND ( gv_action = /DBE/if_vms_constants=>c_qadc
                                          OR gv_action = /DBE/if_vms_constants=>c_qagr
                                          OR gv_action = /DBE/if_vms_constants=>c_qain ).
      vlcactdata_head_s-bldat = sy-datum.
    ENDIF.

* Posting date while GR create and cancle
    IF vlcactdata_head_s-budat EQ 0 AND ( gv_action = /DBE/if_vms_constants=>c_qadc
                                          OR gv_action = /DBE/if_vms_constants=>c_qagr
                                          OR gv_action = /DBE/if_vms_constants=>c_qain  ).
      vlcactdata_head_s-budat = sy-datum.
    ENDIF.

* get instance of the buffer...
    lo_buf = /DBE/cl_veh_buf=>get_instance( ).
* Read the buffer data
    CALL METHOD lo_buf->get_all
      RECEIVING
        rt_bob = lt_bob.

    LOOP AT lt_bob INTO ls_bob.                             "2066130
      IF sy-subrc = 0.
        lo_veh ?= ls_bob-bobref.
        TRY.
            CALL METHOD lo_veh->set_action
              EXPORTING
                iv_action     = gv_action
                iv_wo_prepare = abap_false.
          CATCH /DBE/cx_veh_action_not_defined INTO lx_root.
          CATCH /DBE/cx_veh_static_check INTO lx_root.
        ENDTRY.

        TRY.
            lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
            MOVE-CORRESPONDING lr_vlcactdata_head->* TO vlcactdata_head_s.
            IF sy-ucomm NE gc_error AND sy-ucomm NE gc_netamt AND sy-ucomm NE gc_calculate_tax_ac.
              CLEAR: vlcactdata_head_s-lifnr, vlcactdata_head_s-/DBE/srvc_vendor, lfa1-name1.
            ENDIF.
          CATCH /DBE/cx_veh_layer_not_found .
        ENDTRY.

        TRY.
            lr_vlcactdata_item ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
            MOVE-CORRESPONDING lr_vlcactdata_item->* TO vlcactdata_item_s.
*              CLEAR vlcactdata_head_s-lifnr.
          CATCH /DBE/cx_veh_layer_not_found .
        ENDTRY.
      ENDIF.
      ls_guid-vguid = ls_bob-guid.
      APPEND ls_guid TO lt_guids.
    ENDLOOP.

* Set data in Vehicle buffer
    TRY.
        CALL METHOD lo_buf->set_all.
      CATCH /DBE/cx_veh_error_occured INTO lx_root.
      CATCH cx_static_check INTO lx_root.
    ENDTRY.

    TRY.
      lo_buf->get_messages( EXPORTING io_cx_root    = lx_root
                                IMPORTING et_bapireturn = gt_bapireturn ).
    ENDTRY.

  ENDIF.
ENDFORM.                    " PREPARE_DATA_0600
*&---------------------------------------------------------------------*
*&      Form  PREPARE_ALV_GRID_0600
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_alv_grid_0600 .
*  DATA : go_custom_container        TYPE REF TO cl_gui_custom_container.

  CONSTANTS: lc_adc_alv_var_save TYPE c VALUE 'A'.
  CONSTANTS: lc_ac_alv_var_save  TYPE c VALUE 'A'.
  CONSTANTS: lc_alv_var_save     TYPE c VALUE 'A'.

  DATA:  ls_adc_variant      TYPE disvariant,
         ls_ac_variant       TYPE disvariant,
         lv_adc_save_variant TYPE char1,
         lv_ac_save_variant  TYPE char1,
         lt_excludes         TYPE ui_functions,
         ls_adc_layout       TYPE lvc_s_layo,
         lv_adc_container               TYPE scrfname,
         lv_container                   TYPE scrfname,
         lo_adc_grid                    TYPE REF TO cl_gui_alv_grid,
         lv_adc_width                   TYPE i,
         ls_adc_editcell                TYPE lvc_s_styl.
  TRY.
      ls_adc_variant-report  = sy-repid.
      lv_adc_save_variant    = lc_adc_alv_var_save.

      "this line is added to solve problem of vehicle list hide/dispaly issue.
      ok_code = gv_ok_code = gt_ok = sy-ucomm.

      IF ok_code EQ 'ORDTYP' OR ok_code EQ 'ACCTYP' OR ok_code EQ gc_enter_fcode OR ok_code EQ gc_receiver.
        RETURN.
      ENDIF.

      IF  sy-ucomm EQ 'ENTER' AND gv_netamt LT '0'. "sy-ucomm EQ 'AC_ALL' OR
        CLEAR gv_netamt.
        MESSAGE i449(/DBE/vehicle_master).
      ENDIF.

*  *Dont execute when user press "Distribute Button"
      IF sy-ucomm NE gc_ac_all AND gv_ok_code NE  gc_enter_fcode AND sy-ucomm NE gc_error.

        CLEAR: lv_container.

        IF gv_action = /DBE/if_vms_constants=>c_qapo OR gv_action = /DBE/if_vms_constants=>c_qagr
           OR gv_action = /DBE/if_vms_constants=>c_qain OR
           gv_action = /DBE/if_vms_constants=>c_qadc.
          CONCATENATE 'CONT_' /DBE/if_vms_constants=>c_qadc INTO lv_adc_container.
          CLEAR go_custom_container.
        ELSE.
          CONCATENATE 'CONT_' gv_action INTO lv_adc_container.
          CLEAR go_custom_container.
        ENDIF.

        IF go_custom_container IS NOT BOUND .
* Create custom container control for ALV Control
          CREATE OBJECT go_custom_container
            EXPORTING
              container_name              = lv_adc_container
            EXCEPTIONS
              cntl_error                  = 1
              cntl_system_error           = 2
              create_error                = 3
              lifetime_error              = 4
              lifetime_dynpro_dynpro_link = 5.
          IF sy-subrc NE 0.
          ENDIF.
        ENDIF.

        PERFORM build_fieldcatalog.
        PERFORM exclude_tb_functionss CHANGING lt_excludes.
        PERFORM prepare_alv_data.

        CASE gv_action.

          WHEN /DBE/if_vms_constants=>c_qadc OR /DBE/if_vms_constants=>c_qapo
             OR /DBE/if_vms_constants=>c_qagr OR /DBE/if_vms_constants=>c_qain.

            CLEAR gv_netamt.

            IF go_ac_create IS INITIAL.
* Create Instance of ALV control
              CREATE OBJECT go_ac_create
                EXPORTING
                  i_parent = go_custom_container.
            ENDIF.
            "Optionally register ENTER to raise event DATA_CHANGED.
            "(Per default the user may check data by using the check icon).
            CALL METHOD go_ac_create->register_edit_event
              EXPORTING
                i_event_id = cl_gui_alv_grid=>mc_evt_enter.

            CALL METHOD go_ac_create->register_edit_event
              EXPORTING
                i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*create the event handler for verifying the input data.

            IF g_alv_handler_ac IS NOT BOUND.
              CREATE OBJECT g_alv_handler_ac.
            ENDIF.

* register double click handler
            SET HANDLER g_alv_handler_ac->handle_data_changed
                   FOR go_ac_create.
            SET HANDLER g_alv_handler_ac->handle_data_changed_finished
                    FOR go_ac_create.

            ls_ac_variant-report = sy-repid.
            ls_ac_variant-handle = sy-dynnr.
            lv_ac_save_variant = lc_alv_var_save.

            IF go_ac_create IS BOUND.

              CALL METHOD go_ac_create->set_table_for_first_display
                EXPORTING
                  is_variant                    = ls_ac_variant  "use the local variables
                  i_save                        = lv_ac_save_variant
                  i_default                     = 'X'
                  is_layout                     = gs_layout
                  it_toolbar_excluding          = lt_excludes
                CHANGING
                  it_outtab                     = gt_ac_post
                  it_sort                       = gt_sort
                  it_fieldcatalog               = gt_fieldcatalog
*                 it_sort                       =
*                 it_filter                     =
                EXCEPTIONS
                  invalid_parameter_combination = 1
                  program_error                 = 2
                  too_many_lines                = 3
                  OTHERS                        = 4.
              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDIF.
    CATCH cx_root.
  ENDTRY.
ENDFORM.                    " PREPARE_ALV_GRID_0600

*&---------------------------------------------------------------------*
*&      Form  hide_fields_0600                                N:2711659
*&---------------------------------------------------------------------*
FORM hide_fields_0600.

  LOOP AT SCREEN.
    IF screen-name = 'VLCACTDATA_HEAD_S-EKORG'.
      IF gv_ekorg_0600_visible = abap_true.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF screen-name = 'VLCACTDATA_HEAD_S-EKGRP'.
      IF gv_ekgrp_0600_visible = abap_true.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF screen-name = 'T024E-EKOTX'.              "N:2773495
      IF gv_ekorg_0600_visible = abap_true.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF screen-name = 'T024-EKNAM'.               "N:2773495
      IF gv_ekorg_0600_visible = abap_true.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  initialize_screen_0600                                N:2773495
*&---------------------------------------------------------------------*
FORM f_initialize_screen_0600.

  DATA lo_factory TYPE REF TO /dbe/cl_veh_md_reader_factory.
  DATA lo_reader  TYPE REF TO /dbe/if_veh_md_reader.
  DATA lo_buskey TYPE REF TO /dbe/cl_veh_md_key_bustype.
  DATA lo_result TYPE REF TO /dbe/if_veh_md_result.
  DATA lo_doctype TYPE REF TO /dbe/cl_veh_md_key_doctype.
  DATA lo_purchorg TYPE REF TO /dbe/cl_veh_md_key_purchorg.
  DATA lo_purchgrp TYPE REF TO /dbe/cl_veh_md_key_purchgrp.
  DATA lo_vendor TYPE REF TO /dbe/cl_veh_md_key_vendor.
  DATA lo_plant TYPE REF TO /dbe/cl_veh_md_key_plant.
  DATA lv_error_message TYPE string.

* fill out the short texts
  DATA lr_exroot TYPE REF TO cx_root.


  IF vlcactdata_head_s-bsart IS INITIAL.
    GET PARAMETER ID 'BSA' FIELD vlcactdata_head_s-bsart.
  ENDIF.

  IF vlcactdata_head_s-ekorg IS INITIAL.
    GET PARAMETER ID 'EKO' FIELD vlcactdata_head_s-ekorg.
  ENDIF.

  IF vlcactdata_head_s-ekgrp IS INITIAL.
    GET PARAMETER ID 'EKG' FIELD vlcactdata_head_s-ekgrp.
  ENDIF.

  IF vlcactdata_head_s-/dbe/srvc_vendor IS INITIAL.
    GET PARAMETER ID 'LIF' FIELD vlcactdata_head_s-/dbe/srvc_vendor.
  ENDIF.

  TRY.
      lo_factory = /dbe/cl_veh_md_reader_factory=>get_instance( ).
      TRY.
* document type master data reader
          lo_reader = lo_factory->create_reader( 'DOCTYPE' ).
          lo_doctype ?= lo_reader->createkey( ).
          lo_doctype->set_doctype( vlcactdata_head_s-bsart ).
* we are looking for purchase document types only.
          lo_doctype->set_doccategory('F').
          lo_result = lo_reader->read( lo_doctype ).
          t161t-batxt = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t161t-batxt = ''.
      ENDTRY.
     TRY.
* read purchase organization
          lo_reader = lo_factory->create_reader( 'PURCHORG' ).
          lo_purchorg ?= lo_reader->createkey( ).
          lo_purchorg->set_purchorg( vlcactdata_head_s-ekorg ).
          lo_result = lo_reader->read( lo_purchorg ).
          t024e-ekotx = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t024e-ekotx = ''.
      ENDTRY.
      TRY.
* read purchase group
          lo_reader = lo_factory->create_reader( 'PURCHGRP' ).
          lo_purchgrp ?= lo_reader->createkey( ).
          lo_purchgrp->set_purchgrp( vlcactdata_head_s-ekgrp ).
          lo_result = lo_reader->read( lo_purchgrp ).
          t024-eknam = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t024-eknam = ''.
      ENDTRY.
      TRY.
* read vendor
          lo_reader = lo_factory->create_reader( 'VENDOR' ).
          lo_vendor ?= lo_reader->createkey( ).
          lo_vendor->set_vendorkey( vlcactdata_head_s-/dbe/srvc_vendor ).
          lo_result = lo_reader->read( lo_vendor ).
          lfa1-name1 = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          lfa1-name1 = ''.
      ENDTRY.
* read additional cost category
      DATA: lt_servtypetxt TYPE /dbe/servtype_tt,
            ls_servtypetxt TYPE /dbe/servtype_t.

*      Read Customizing Entries
      CALL FUNCTION '/DBE/VMASS_READ_SERVTYPE_TEXT'
        EXPORTING
          iv_langu       = sy-langu
        IMPORTING
          et_servtypetxt = lt_servtypetxt.

        READ TABLE lt_servtypetxt INTO ls_servtypetxt WITH KEY
                    service_type = vlcactdata_head_s-/dbe/ext_service_type.
        IF sy-subrc EQ 0.
          vlcactdata_item_s-/dbe/ext_service_type_txt = ls_servtypetxt-text.
        ELSE.
          CLEAR vlcactdata_item_s-/dbe/ext_service_type_txt.
        ENDIF.

   CATCH cx_root INTO lr_exroot .
      lv_error_message = lr_exroot->if_message~get_longtext( ).
*     if something went wrong during reading short text, the shost text will be empty and error silently
*     dropped becasue it not effecting.
  ENDTRY.

ENDFORM.

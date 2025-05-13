*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI57 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_TRANSFER_ADC_INFO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_transfer_adc_info INPUT.

  PERFORM transfer_adc_info.

ENDMODULE.                 " M_TRANSFER_ADC_INFO  INPUT
*&---------------------------------------------------------------------*
*&      Module  M_TRANSFER_CNL_ADC_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_transfer_cnl_adc_data INPUT.

* Only transfer the data in case of sy-ucomm is equal to the ACT_EXE
  IF gv_ok_code = gc_exec_fc OR gv_ok_code = gc_save_fc.
    PERFORM transfer_cnl_adc_data.
  ENDIF.

ENDMODULE.                 " M_TRANSFER_CNL_ADC_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Form  TRANSFER_CNL_ADC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM transfer_cnl_adc_data .

  DATA: ls_cnl_adc_info    TYPE ty_addcost_cancel,
        lv_clear_action    TYPE cvlc03-aktion VALUE abap_false,
        lt_veh_set_bob     TYPE /dbe/t_rfc_veh_vguid,
        lt_veh_reset_bob   TYPE /dbe/t_rfc_veh_vguid,
        ls_veh_set_bob     LIKE LINE OF  lt_veh_set_bob,
        ls_veh_reset_bob   LIKE LINE OF  lt_veh_reset_bob,
        lv_current_action  TYPE vlc_action,
        lv_valid           TYPE boole_d,
        lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
        lr_item_data       TYPE REF TO data,
        lr_data            TYPE REF TO data,
        lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
        lt_bob             TYPE /dbe/t_veh_bob,
        ls_bob             LIKE LINE OF lt_bob,
        lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
        lr_vlcactdata_item TYPE REF TO vlcactdata_item_s.

* check whether the data changed is valid
  IF go_ac_cancel IS BOUND.
    CALL METHOD go_ac_cancel->check_changed_data
      IMPORTING
        e_valid = lv_valid.
  ENDIF.

* Only if the data is valid then proceed
  CHECK lv_valid EQ abap_true.

* Get the vehicle instance
  CALL METHOD /dbe/cl_veh_buf=>get_instance
    RECEIVING
      ro_instance = lo_veh_buf.

* Get the vehicle instance
  CALL METHOD lo_veh_buf->get_all
    RECEIVING
      rt_bob = lt_bob.

  IF vlcactdata_head_s-budat IS INITIAL.
    MESSAGE e441(/dbe/vehicle_master).
  ENDIF.

  IF gv_action EQ /dbe/if_vms_constants=>c_qaic AND vlcactdata_head_s-budat < vlcactdata_item_s-budat.

    MESSAGE i430(/dbe/vehicle_master).
    CLEAR gv_ok_code.

  ENDIF.


* Collect all vehicles to be processed => selected / related whicever applicable
  LOOP AT gt_ac_cancel INTO ls_cnl_adc_info WHERE is_selected = abap_true.
    MOVE ls_cnl_adc_info-vguid TO ls_veh_set_bob-guid.
    APPEND ls_veh_set_bob TO lt_veh_set_bob.
    CLEAR ls_cnl_adc_info.
  ENDLOOP.

  CLEAR  lt_veh_reset_bob.
  LOOP AT gt_ac_cancel INTO ls_cnl_adc_info WHERE is_selected = abap_false.
    CLEAR ls_veh_reset_bob.
    READ TABLE lt_veh_set_bob INTO ls_veh_reset_bob WITH KEY guid = ls_cnl_adc_info-vguid.
    IF sy-subrc <> 0 .
      MOVE ls_cnl_adc_info-vguid TO ls_veh_reset_bob-guid.
      APPEND ls_veh_reset_bob TO lt_veh_reset_bob.
    ENDIF.
    CLEAR ls_cnl_adc_info.
  ENDLOOP.

  IF lt_bob IS NOT INITIAL.
    CLEAR ls_veh_reset_bob.
    LOOP AT lt_veh_reset_bob INTO ls_veh_reset_bob.
      CLEAR ls_bob.
      READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_veh_reset_bob-guid.
      IF sy-subrc EQ 0.
        lo_vehicle ?= ls_bob-bobref.

        CALL METHOD lo_vehicle->get_action
          IMPORTING
            ev_action = lv_current_action.

        IF lv_current_action = gv_action.
          TRY.
              CALL METHOD lo_vehicle->set_action
                EXPORTING
                  iv_action     = lv_clear_action
                  iv_wo_prepare = abap_true.

            CATCH /dbe/cx_veh_action_not_defined .
            CATCH /dbe/cx_veh_static_check .

          ENDTRY.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Collect all vehcicles to be removed from to be processed vehicle list

  IF lt_bob IS NOT INITIAL.

    LOOP AT lt_veh_set_bob INTO ls_veh_set_bob ."where is_selected = abap_true.

      READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_veh_set_bob-guid.

      IF sy-subrc EQ 0.

        lo_vehicle ?= ls_bob-bobref.

* In case if the PO is selected then set the action as gv_action
*        IF ls_cnl_adc_info-is_selected EQ abap_true.

        TRY.
            IF lo_vehicle IS BOUND.
              lr_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
            ENDIF.
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.

        IF lr_data IS BOUND.
          lr_vlcactdata_head ?= lr_data.
* Set buffer with posting date and reversal reason
          MOVE vlcactdata_head_s-budat TO lr_vlcactdata_head->*-budat.
          MOVE vlcactdata_head_s-revreason TO lr_vlcactdata_head->*-revreason.
          gs_vlcactdata_head = vlcactdata_head_s.

          TRY.
              lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.
          IF lr_item_data IS BOUND.
            lr_vlcactdata_item ?= lr_item_data.
          ENDIF.
        ENDIF.

*Update the budat at the item level
        IF gv_action EQ /dbe/if_vms_constants=>c_qaic OR gv_action EQ /dbe/if_vms_constants=>c_qagc
          OR gv_action EQ /dbe/if_vms_constants=>c_qacc.
          IF  lr_vlcactdata_item->*-vguid  = ls_bob-guid.
            lr_vlcactdata_item->*-budat = vlcactdata_head_s-budat.
          ENDIF.
        ENDIF.
        IF gv_action EQ /dbe/if_vms_constants=>c_qaic OR gv_action EQ /dbe/if_vms_constants=>c_qagc
          OR gv_action EQ /dbe/if_vms_constants=>c_qacc OR
          gv_action EQ /dbe/if_vms_constants=>c_qapc.
          CLEAR ls_cnl_adc_info.
          READ TABLE gt_ac_cancel INTO ls_cnl_adc_info WITH KEY is_selected = abap_true vguid = ls_veh_set_bob-guid .
          IF sy-subrc = 0 .
            IF lr_vlcactdata_item->*-vguid  = ls_bob-guid.

              lr_vlcactdata_item->*-po_number = ls_cnl_adc_info-po_number.
              lr_vlcactdata_item->*-po_item = ls_cnl_adc_info-po_item.

              lr_vlcactdata_item->*-/dbe/fi_belnr = ls_cnl_adc_info-inv_number.
              lr_vlcactdata_item->*-/dbe/fi_gjahr = ls_cnl_adc_info-inv_year.

              lr_vlcactdata_item->*-ref_doc = ls_cnl_adc_info-ref_doc.
              lr_vlcactdata_item->*-ref_doc_year = ls_cnl_adc_info-ref_doc_year.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDLOOP.
  ENDIF.

  TRY.
      CALL METHOD lo_veh_buf->set_all .
    CATCH /dbe/cx_veh_error_occured .
    CATCH cx_static_check .
  ENDTRY.


ENDFORM.                    " TRANSFER_CNL_ADC_DATA
*&---------------------------------------------------------------------*
*&      Module  M_PREPARE_DATA_601  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_prepare_data_601 OUTPUT.
*   Prepare the data.
  ok_code = gv_ok_code = gt_ok = sy-ucomm.
  PERFORM prepare_data_0601.
ENDMODULE.                 " M_PREPARE_DATA_601  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  PREPARE_DATA_0601
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_data_0601 .

* Constant for the current transaction name.
  CONSTANTS: lc_cur_txn_name(20)     TYPE c VALUE '/DBE/MASSACTIONS'.

* Data declaration
  DATA : lo_buf             TYPE REF TO /dbe/cl_veh_buf,
         lo_veh             TYPE REF TO /dbe/cl_veh_dbmvehicle,
         lt_bob             TYPE /dbe/t_veh_bob,
         ls_bob             TYPE /dbe/s_veh_bob,
         lr_iobj_single     TYPE REF TO /dbe/iobj_data_single_com_s,
         ls_iobj_single     TYPE  /dbe/iobj_data_single_com_s,
         lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
         lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
         lr_vlcdiavehi      TYPE REF TO vlcdiavehi,
         lt_guids           TYPE TABLE OF vlcguid,
         ls_guid            TYPE vlcguid,
         lv_document_type   TYPE int4.                      "N:2348422


  IF gv_action IS INITIAL. "we are not in /DBE/MASSACTION transaction   N:2066130
    DATA lv_action TYPE cvlc03.
    CALL FUNCTION '/DBE/VM08_SELECTED_ACTION_GET'
      IMPORTING
        es_sel_action = lv_action.
    gv_action = lv_action-aktion.
  ENDIF.

  IF gv_ok_code NE 'DD_ALL' AND gv_ok_code NE gc_ac_all AND gv_ok_code NE gc_enter_fcode.

* This indicates that actins are triggered by mass vehicle interface
    EXPORT lc_cur_txn_name TO MEMORY ID 'TXN_NAME'.

    CLEAR: lt_guids, ls_guid.

* Set the posting date equal to current date =>populate header from backend prepare
    IF vlcactdata_head_s-budat EQ 0 AND ( gv_action  = /dbe/if_vms_constants=>c_qacc OR
                                          gv_action  = /dbe/if_vms_constants=>c_qapc OR
                                          gv_action  = /dbe/if_vms_constants=>c_qaic OR
                                          gv_action = /dbe/if_vms_constants=>c_qagc ).
      vlcactdata_head_s-pstng_date = sy-datum.
    ENDIF.

  ENDIF.

* get instance of the buffer
  lo_buf = /dbe/cl_veh_buf=>get_instance( ).

* Read the buffer data
  CALL METHOD lo_buf->get_all
    RECEIVING
      rt_bob = lt_bob.

*  Loop at all the vehicles selected
  LOOP AT lt_bob INTO ls_bob.
    lo_veh ?= ls_bob-bobref.
    TRY.
*          Set the action to the vehicle
        CALL METHOD lo_veh->set_action
          EXPORTING
            iv_action     = gv_action
            iv_wo_prepare = abap_false.
      CATCH /dbe/cx_veh_action_not_defined .
      CATCH /dbe/cx_veh_static_check .
    ENDTRY.

    TRY.
        lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.

    TRY.
        lr_vlcactdata_item ?=  lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.

*      TRY.
*          lr_iobj_single ?=  lo_veh->get_data_com( lo_veh->gc_iobj_data_single_com_s ).
*        CATCH /DBE/cx_veh_layer_not_found .
*      ENDTRY.
*
*      IF lr_iobj_single IS BOUND.
*        MOVE-CORRESPONDING  lr_iobj_single->* TO ls_iobj_single.
*      ENDIF.

    IF lr_vlcactdata_head IS BOUND.
      IF gv_ok_code NE gc_enter_fcode.
        MOVE-CORRESPONDING lr_vlcactdata_head->* TO vlcactdata_head_s.
      ENDIF.
    ENDIF.

    ls_guid-vguid = ls_bob-guid.
    APPEND ls_guid TO lt_guids.
  ENDLOOP.

  IF gv_ok_code IS INITIAL.
    REFRESH gt_ac_cancel.
  ENDIF.

  IF gv_action EQ /dbe/if_vms_constants=>c_qacc.            "N:2348422
    lv_document_type = gc_spec_doc_type.
  ENDIF.
  IF gv_action EQ /dbe/if_vms_constants=>c_qapc.
    lv_document_type = gc_po_doc_type.
  ENDIF.
  IF gv_action EQ /dbe/if_vms_constants=>c_qaic.
    lv_document_type = gc_inv_doc_type.
  ENDIF.
  IF gv_action EQ /dbe/if_vms_constants=>c_qagc.
    lv_document_type = gc_gr_doc_type.
  ENDIF.

*  Call the form routine to get the related vehicles to the selected vehicle
*  due to the purchase order
  PERFORM get_related_vehicles TABLES lt_guids USING lv_document_type.

* Set data in Vehicle buffer
  TRY.
      CALL METHOD lo_buf->set_all.
    CATCH /dbe/cx_veh_error_occured .
    CATCH cx_static_check.
  ENDTRY.

ENDFORM.                    " PREPARE_DATA_0601
*&---------------------------------------------------------------------*
*&      Module  PREPARE_ALV_GRID_601  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE prepare_alv_grid_601 OUTPUT.
  PERFORM prepare_alv_grid_601.
ENDMODULE.                 " PREPARE_ALV_GRID_601  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  PREPARE_ALV_GRID_601
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_alv_grid_601 .

  CONSTANTS: lc_alv_var_save TYPE c VALUE 'A'.

* Data declaration
  DATA: ls_ac_variant      TYPE disvariant,
        lv_ac_save_variant TYPE char1,
        lv_container       TYPE scrfname,
        lv_width           TYPE i,
        ls_editcell        TYPE lvc_s_styl,
        lv_old_po_number   TYPE ebeln,
        lv_old_gr_number   TYPE mblnr,
        lv_old_gr_year     TYPE mjahr,
        lv_old_inv_number  TYPE re_belnr,
        lv_old_inv_year    TYPE gjahr,
        lt_excludes        TYPE ui_functions.

  FIELD-SYMBOLS
        <ls_ac_cancel> TYPE ty_addcost_cancel.

  " this line is added to solve problem of vehicle list hide/dispaly issue.
  ok_code = gv_ok_code = gt_ok = sy-ucomm.
  " screen numer uniquely identifies the variant
  ls_ac_variant-report = sy-repid.
  ls_ac_variant-handle = sy-dynnr.
  lv_ac_save_variant = lc_alv_var_save.

  IF ok_code EQ 'ORDTYP' OR ok_code EQ 'ACCTYP' OR ok_code EQ gc_enter_fcode OR ok_code EQ gc_receiver.
    RETURN.
  ENDIF.

*  *Dont execute when user press "Distribute Button"
  IF gv_ok_code NE gc_ac_all AND gv_ok_code NE  gc_enter_fcode AND gv_ok_code NE gc_error.

    CLEAR: lv_container.
    IF gv_action EQ /dbe/if_vms_constants=>c_qacc OR gv_action EQ /dbe/if_vms_constants=>c_qapc
      OR  gv_action EQ /dbe/if_vms_constants=>c_qaic OR  gv_action EQ  /dbe/if_vms_constants=>c_qagc.
      CONCATENATE 'CONT_' /dbe/if_vms_constants=>c_qacc INTO lv_container.
      CLEAR go_custom_container.
    ENDIF.

    IF go_custom_container IS NOT BOUND .
* Create custom container control for ALV Control
      CREATE OBJECT go_custom_container
        EXPORTING
          container_name              = lv_container
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
*    PERFORM prepare_alv_data.
    PERFORM prepare_alv_data_601.

    IF gv_action EQ /dbe/if_vms_constants=>c_qacc OR gv_action EQ /dbe/if_vms_constants=>c_qapc
       OR  gv_action EQ /dbe/if_vms_constants=>c_qaic OR  gv_action EQ  /dbe/if_vms_constants=>c_qagc.

      IF go_ac_cancel IS INITIAL.
* Create Instance of ALV control
        IF go_custom_container IS BOUND.
          CREATE OBJECT go_ac_cancel
            EXPORTING
              i_parent = go_custom_container.
        ENDIF.
      ENDIF.

      IF go_custom_container IS BOUND .

        lv_width = 940.
        CALL METHOD go_custom_container->set_width
          EXPORTING
            width      = lv_width
          EXCEPTIONS
            cntl_error = 1
            OTHERS     = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

*Optionally register ENTER to raise event DATA_CHANGED.

      CALL METHOD go_ac_cancel->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_enter.

      CALL METHOD go_ac_cancel->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*create the event handler for verifying the input data.
      IF g_alv_handler_ac IS NOT BOUND.
        CREATE OBJECT g_alv_handler_ac.
      ENDIF.

      IF g_alv_handler_ac IS BOUND.
* register handle data changed
        SET HANDLER g_alv_handler_ac->handle_data_changed FOR go_ac_cancel.
        SET HANDLER g_alv_handler_ac->handle_data_changed_finished FOR go_ac_cancel.
      ENDIF.

      SORT gt_ac_cancel BY po_number po_item.
      DELETE ADJACENT DUPLICATES FROM gt_ac_cancel.
      CLEAR : lv_old_po_number, lv_old_inv_number, lv_old_gr_number, lv_old_inv_year, lv_old_gr_year. "N:2348422

      CASE gv_action.
        WHEN /dbe/if_vms_constants=>c_qapc.                 "N:2348422
          LOOP AT gt_ac_cancel ASSIGNING <ls_ac_cancel>.
            IF lv_old_po_number NE <ls_ac_cancel>-po_number AND <ls_ac_cancel>-cannot_cancel IS INITIAL. "N:2348422
              ls_editcell-style = cl_gui_alv_grid=>mc_style_enabled.
            ELSE.
              ls_editcell-style = cl_gui_alv_grid=>mc_style_disabled.
            ENDIF.
            ls_editcell-fieldname = gc_is_selected.
            APPEND ls_editcell TO <ls_ac_cancel>-cellstyles.
            lv_old_po_number = <ls_ac_cancel>-po_number.
          ENDLOOP.
        WHEN /dbe/if_vms_constants=>c_qacc OR /dbe/if_vms_constants=>c_qaic. "N:2348422
          LOOP AT gt_ac_cancel ASSIGNING <ls_ac_cancel>.
            IF ( lv_old_inv_number NE <ls_ac_cancel>-inv_number OR lv_old_inv_year NE <ls_ac_cancel>-inv_year ) AND <ls_ac_cancel>-cannot_cancel IS INITIAL. "N:2348422
              ls_editcell-style = cl_gui_alv_grid=>mc_style_enabled.
            ELSE.
              ls_editcell-style = cl_gui_alv_grid=>mc_style_disabled.
            ENDIF.
            ls_editcell-fieldname = gc_is_selected.
            APPEND ls_editcell TO <ls_ac_cancel>-cellstyles.
            lv_old_inv_number = <ls_ac_cancel>-inv_number.
            lv_old_inv_year   = <ls_ac_cancel>-inv_year.
          ENDLOOP.
        WHEN /dbe/if_vms_constants=>c_qagc.
          LOOP AT gt_ac_cancel ASSIGNING <ls_ac_cancel>.
            IF ( lv_old_gr_number NE <ls_ac_cancel>-ref_doc OR lv_old_gr_year NE <ls_ac_cancel>-ref_doc_year ) AND <ls_ac_cancel>-cannot_cancel IS INITIAL. "N:2348422
              ls_editcell-style = cl_gui_alv_grid=>mc_style_enabled.
            ELSE.
              ls_editcell-style = cl_gui_alv_grid=>mc_style_disabled.
            ENDIF.
            ls_editcell-fieldname = gc_is_selected.
            APPEND ls_editcell TO <ls_ac_cancel>-cellstyles.
            lv_old_gr_number = <ls_ac_cancel>-ref_doc.
            lv_old_gr_year = <ls_ac_cancel>-ref_doc_year.
          ENDLOOP.
      ENDCASE.

      IF go_ac_cancel IS BOUND.
        gs_layout-stylefname = 'CELLSTYLES'.
        CALL METHOD go_ac_cancel->set_table_for_first_display
          EXPORTING
            is_variant                    = ls_ac_variant
            i_save                        = lv_ac_save_variant
            i_default                     = abap_true
            is_layout                     = gs_layout
            it_toolbar_excluding          = lt_excludes
          CHANGING
            it_outtab                     = gt_ac_cancel
            it_sort                       = gt_sort
            it_fieldcatalog               = gt_fieldcatalog
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
    ENDIF.

  ENDIF.
ENDFORM.                    " PREPARE_ALV_GRID_601

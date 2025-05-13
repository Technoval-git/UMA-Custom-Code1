*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGR01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_ACTION_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OK_CODE  text
*      -->P_GV_ACTION  text
*----------------------------------------------------------------------*
FORM f_prepare_action_data  USING    p_ok_code
                                     p_gv_action.

  DATA : lo_buf             TYPE REF TO /dbe/cl_veh_buf,
         lo_veh             TYPE REF TO /dbe/cl_veh_dbmvehicle,
         lt_bob             TYPE /dbe/t_veh_bob,
         ls_bob             TYPE /dbe/s_veh_bob,
         lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
         lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
         lt_guids           TYPE TABLE OF vlcguid,
         ls_guid            TYPE vlcguid,
         lv_wo_prepare      TYPE boole_d.

  CONSTANTS:  lc_dd_all(6)  VALUE 'DD_ALL'.

* redesign in Note 2784633, prepare functionality should be in actions prepare implementation

  "Don't execute when user press "Apply to All" Button
  IF gv_ok_code NE lc_dd_all.  "Note: 2093139

* get instance of the buffer...
    lo_buf = /dbe/cl_veh_buf=>get_instance( ).
* Read the buffer data
    TRY.
        CALL METHOD lo_buf->get_all
          RECEIVING
            rt_bob = lt_bob.
    ENDTRY.

    gv_action = 'ZSTB'.

    CASE gv_action.
      WHEN 'QIRB'.
        lv_wo_prepare  = abap_true.
      WHEN OTHERS.
        lv_wo_prepare = abap_false.
    ENDCASE.

    DATA : lt_veh TYPE STANDARD TABLE OF vlcvehicle,
           ls_veh TYPE vlcvehicle.

    SELECT * FROM vlcvehicle INTO TABLE lt_veh
        FOR ALL ENTRIES IN lt_bob WHERE vguid EQ lt_bob-guid.

    REFRESH gt_vsresult_selection.

    LOOP AT lt_veh INTO ls_veh.
      MOVE-CORRESPONDING ls_veh TO gs_selection.
      APPEND gs_selection TO gt_vsresult_selection.
      CLEAR gs_selection.
    ENDLOOP.

    LOOP AT gt_vsresult_selection INTO gs_selection.

      READ TABLE lt_bob INTO ls_bob WITH KEY guid = gs_selection-vguid.
      IF sy-subrc = 0.

        lo_veh ?= ls_bob-bobref.
        "Prepare is not called for cnacel incoming invoice as it raises error
        "if all the vehicles belonging to the invoice are passed for canclation
        " Disussion Required
        TRY.
            CALL METHOD lo_veh->set_action
              EXPORTING
                iv_action     = gv_action
                iv_wo_prepare = lv_wo_prepare.
          CATCH /dbe/cx_veh_action_not_defined .
          CATCH /dbe/cx_veh_static_check .
        ENDTRY.

        TRY.
            lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
            MOVE-CORRESPONDING lr_vlcactdata_head->* TO vlcactdata_head_s.
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.

        TRY.
            lr_vlcactdata_item ?=  lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
            MOVE-CORRESPONDING  lr_vlcactdata_item->* TO vlcactdata_item_s.
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.


      ENDIF.

      ls_guid-vguid = ls_bob-guid.
      APPEND ls_guid TO lt_guids.
    ENDLOOP.

    IF gv_action = /dbe/if_vms_constants=>c_qirb.
      PERFORM set_action_cancel_invoice TABLES lt_guids.

    ENDIF.

* Set data in Vehicle buffer
    IF lo_buf IS BOUND.
      TRY.
          CALL METHOD lo_buf->set_all.
        CATCH /dbe/cx_veh_error_occured .
        CATCH cx_static_check.
      ENDTRY.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PREPARE_ACTION_DATA

*&---------------------------------------------------------------------*
*&      Form  f_default_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_default_data.

  DATA  cur_txn_name(20)     TYPE c VALUE '/DBE/MASSACTIONS'.

  IF gv_ok_code NE 'DD_ALL' AND gv_ok_code NE 'AC_ALL' AND gv_ok_code NE gc_enter_fcode.

* This indicates that actins are triggered by mass vehicle interface
    EXPORT cur_txn_name TO MEMORY ID 'TXN_NAME'.
*    CLEAR: lt_guids, ls_guid." lr_vlcactdata_head,lr_vlcactdata_item,lr_iobj_single.
* Get Vehicles from database and fill the buffer
* If action is performed via the serach result , unless and until an action is
* executed, vehicle details will not be loaded to buffer.
* The below subroutine does the job of gettting vehicles to buffer

*------------------------Default sy-date------------------------
*Document date while creating GR and invoice
    IF vlcactdata_head_s-bldat EQ 0 AND ( gv_action EQ /dbe/if_vms_constants=>c_qgrb
       OR gv_action EQ /dbe/if_vms_constants=>c_qinb
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qadc
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qagr
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qain ).
      vlcactdata_head_s-bldat = sy-datum.
    ENDIF.

* Total net price should be empty
    IF gv_tax_calculated EQ abap_false AND gv_action EQ /dbe/if_vms_constants=>c_qinb.
      CLEAR vlcactdata_head_s-netpr.
    ENDIF.

    IF vlcactdata_head_s-/dbe/srvc_vendor IS NOT INITIAL AND ( gv_action EQ /dbe/if_vms_constants=>c_qadc
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qapo
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qagr
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qain ).
      CLEAR vlcactdata_head_s-/dbe/srvc_vendor. "vlcactdata_head_s-lifnr .
    ENDIF.

*posting date while GR create and cancle
    IF vlcactdata_head_s-budat EQ 0 AND ( gv_action EQ /dbe/if_vms_constants=>c_qgrb
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qgcb
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qadc
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qagr
                                          OR gv_action EQ /dbe/if_vms_constants=>c_qain ).
      vlcactdata_head_s-budat = sy-datum.

    ENDIF.

*Posting date while canceling inc invoice
    IF vlcactdata_head_s-pstng_date EQ 0 AND gv_action EQ /dbe/if_vms_constants=>c_qirb.
      vlcactdata_head_s-pstng_date = sy-datum.
    ENDIF.

*Delivery date while creating PO
    IF vlcactdata_head_s-eindt EQ 0 AND ( gv_action EQ /dbe/if_vms_constants=>c_qorb
       OR gv_action EQ /dbe/if_vms_constants=>c_qmob ) .
      vlcactdata_head_s-eindt = sy-datum.
    ENDIF.

  ENDIF.

*  DATA: lv_tab    TYPE ddobjname,
*        lv_field  TYPE fieldname,
*        lt_screen TYPE STANDARD TABLE OF dfies,
*        ls_screen TYPE dfies.
*  FIELD-SYMBOLS <input_field> TYPE any.
*  FIELD-SYMBOLS <date> TYPE any .
*
*  LOOP AT SCREEN.
*    ASSIGN (screen-name) TO <input_field>.
**       Check: Is entry field filled ?
*    IF <input_field> IS INITIAL.
*      SPLIT screen-name AT '-' INTO lv_tab lv_field.
*      CALL FUNCTION 'DDIF_FIELDINFO_GET'                    "N:1449767
*        EXPORTING
*          tabname        = lv_tab                           "N:1486828
*          all_types      = 'X'
*        TABLES
*          dfies_tab       = lt_screen
*        EXCEPTIONS
*          not_found      = 1
*          internal_error = 2
*          OTHERS         = 3.
*      IF sy-subrc <> 0 AND lt_screen IS INITIAL.
*        ls_screen-fieldtext = screen-name.
*      ELSE.
*        READ TABLE lt_screen WITH KEY fieldname = lv_field
*                                      langu     = sy-langu
*                                      INTO ls_screen.
*        IF ls_screen-datatype  =  'DATS'.
*          SET CURSOR FIELD screen-name.
**         Ensure that user is able to fill out the obligatory field
*          screen-input = 1.
*          ASSIGN  COMPONENT lv_field OF STRUCTURE lv_tab TO  <date>.
*          IF sy-subrc = 0 .
*             <date>  = sy-datum.
*          ENDIF.
*          MODIFY SCREEN.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      CONTINUE.
*    ENDIF.
*
*  ENDLOOP.

ENDFORM.                    "f_prepare_action_data
*&---------------------------------------------------------------------*
*&      Form  create_alv_grid_po
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_create_alv_grid_po.
  CONSTANTS: lc_alv_var_save_po TYPE c VALUE 'A'.

  DATA : lv_col_no          TYPE i,
         lv_cc_po_name      TYPE scrfname VALUE 'BCALVC_CREATE_PO_DIFF_DATE', "N:2784633
         lv_hide            TYPE abap_bool,
         ls_po_variant      TYPE disvariant,
         lv_po_save_variant TYPE char1,
         lt_exclude         TYPE ui_functions,
         lv_used_vehicle    TYPE abap_bool.                 "N:2784633

  FIELD-SYMBOLS <fieldcatalog> TYPE lvc_s_fcat.             "N:2784633

  lv_po_save_variant = lc_alv_var_save_po.
*Dont execute when user press "Apply to All Button"
  IF gv_ok_code NE 'DD_ALL'.


    CLEAR : gt_fieldcatalog , gs_fieldcat, gs_layout.

    IF go_cc_po_crt IS NOT BOUND.                           "N:2784633
*    IF has_diff_delv_date EQ abap_true OR gv_enable_alv EQ abap_true.
* CREATE A CUSTOM CONTAINER CONTROL FOR OUR ALV CONTROL
      CREATE OBJECT go_cc_po_crt                                               "N:2784633
        EXPORTING
          container_name              = lv_cc_po_name                          "N:2784633
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5.
      IF sy-subrc NE 0.
* ADD YOUR HANDLING, FOR EXAMPLE
        CALL FUNCTION 'POPUP_TO_INFORM'
          EXPORTING
            titel = sy-repid
            txt2  = sy-subrc
            txt1  = 'THE CONTROL COULD NOT BE CREATED'(510).
      ENDIF.
    ENDIF.
    IF go_po_items_alvgrid IS NOT BOUND.                    "N:2784633
* CREATE AN INSTANCE OF ALV CONTROL
      CREATE OBJECT go_po_items_alvgrid                                        "N:2784633
        EXPORTING
          i_parent = go_cc_po_crt.                                             "N:2784633
    ENDIF.
    CLEAR gt_fieldcatalog.

    lv_col_no = 1.
* SET A TITLEBAR FOR THE GRID CONTROL
    gs_layout-grid_title = TEXT-015.
    gs_layout-smalltitle = 'X'.
    gs_layout-cwidth_opt = 'X'.


    gs_fieldcat-fieldname   = 'VHCLE'.
    gs_fieldcat-coltext   = 'Int. Veh. No.'(127).
    gs_fieldcat-outputlen = 15.
    gs_fieldcat-col_pos     = lv_col_no.
    gs_fieldcat-datatype = 'CHAR' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.
    lv_col_no = lv_col_no + 1.

    gs_fieldcat-fieldname   = 'MCODESD'.
    gs_fieldcat-coltext   = 'Model Sales code'(122).
    gs_fieldcat-outputlen = 10.
    gs_fieldcat-col_pos     = lv_col_no + 1.
    gs_fieldcat-datatype = '/DBE/MODCODE_SALE' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.
    lv_col_no = lv_col_no + 1.

*Check: Estimated and Aimed purchase price will be visible only for used vehicel
    gs_fieldcat-fieldname = '/DBE/EST_PURCPRICE'.
    gs_fieldcat-cfieldname = 'CURRENCY'.                    "N:2304203
    gs_fieldcat-coltext   = 'Estimated Purch Price'(405).
    gs_fieldcat-tech = abap_true.                           "N:2784633
    gs_fieldcat-outputlen = 13.
    gs_fieldcat-col_pos   = lv_col_no + 1.
    gs_fieldcat-datatype  = 'CURR' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.
    lv_col_no = lv_col_no + 1.

    gs_fieldcat-fieldname = '/DBE/AIMED_PURCPRICE'.
    gs_fieldcat-cfieldname = 'CURRENCY'.                    "N:2304203
    gs_fieldcat-coltext   = 'Aimed Purch Price'(406).
    gs_fieldcat-tech = abap_true.                           "N:2784633
    gs_fieldcat-outputlen = 13.
    gs_fieldcat-col_pos   = lv_col_no + 1.
    gs_fieldcat-datatype  = 'CURR' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.
    lv_col_no = lv_col_no + 1.



    gs_fieldcat-fieldname   = 'NETPR'.
    gs_fieldcat-cfieldname = 'CURRENCY'.                    "N:2304203
    gs_fieldcat-coltext   = 'Net Price'(123).
    gs_fieldcat-outputlen = 11.
    gs_fieldcat-col_pos     = lv_col_no + 1.
    gs_fieldcat-datatype = 'CURR' .                         "N:2304203
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.
    lv_col_no = lv_col_no + 1.

    gs_fieldcat-fieldname  = 'OPTPR'.
    gs_fieldcat-cfieldname = 'CURRENCY'.
    gs_fieldcat-coltext    = 'Option Price'(126).
    gs_fieldcat-outputlen  = 11.
    gs_fieldcat-col_pos    = lv_col_no + 1.
    gs_fieldcat-datatype   = 'CURR' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.
    lv_col_no = lv_col_no + 1.

    gs_fieldcat-fieldname   = 'CURRENCY'.
    gs_fieldcat-coltext   = 'Currency'(124).
    gs_fieldcat-outputlen = 5.
    gs_fieldcat-col_pos     = lv_col_no + 1.
    gs_fieldcat-datatype = 'CUKY' .                         "N:2304203
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.
    lv_col_no = lv_col_no + 1.


    gs_fieldcat-fieldname   = 'EINDT'.
    gs_fieldcat-tabname   = 'gt_po_item_diff_delv'.
    gs_fieldcat-coltext   = 'Delivery Date'(125).
    gs_fieldcat-ref_table = 'VLCACTDATA_HEAD_S'.
    gs_fieldcat-ref_field = 'EINDT'.
    gs_fieldcat-outputlen = 10.
    gs_fieldcat-col_pos     = lv_col_no + 1.
    gs_fieldcat-datatype = 'DATS' .
    gs_fieldcat-f4availabl = 'X'.
    gs_fieldcat-edit = 'X'.
*      gs_fieldcat-auto_value = 'X'.
*      gs_fieldcat-tabname = 'D'.
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    PERFORM prepare_po_info.
*   check if used vehicle is selected                                                             >>>N:2784633
    PERFORM check_used_vehicle USING abap_false
                               CHANGING lv_used_vehicle.
    IF lv_used_vehicle = abap_true.
*     in case of used vehicle show as well Estimated Purchase Price and Aimed Purchase Price columns
      READ TABLE gt_fieldcatalog ASSIGNING <fieldcatalog> WITH KEY fieldname = '/DBE/EST_PURCPRICE'.
      IF sy-subrc = 0.
        <fieldcatalog>-tech = abap_false.
      ENDIF.

      READ TABLE gt_fieldcatalog ASSIGNING <fieldcatalog> WITH KEY fieldname = '/DBE/AIMED_PURCPRICE'.
      IF sy-subrc = 0.
        <fieldcatalog>-tech = abap_false.
      ENDIF.
    ENDIF.                                                                                         "<<<N:2784633

*Optionally register ENTER to raise event DATA_CHANGED.
* (Per default the user may check data by using the check icon).
    CALL METHOD go_po_items_alvgrid->register_edit_event                                           "N:2784633
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD go_po_items_alvgrid->register_edit_event                                           "N:2784633
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*create the event handler for verifying the input data.
    IF g_alv_handler_po IS INITIAL.                         "N:2784633
      CREATE OBJECT g_alv_handler_po.
    ENDIF.

* Register for data changed event handler
    SET HANDLER g_alv_handler_po->handle_data_changed
           FOR go_po_items_alvgrid.                         "N:2784633

    PERFORM exclude_action_tb_functions CHANGING lt_exclude.

    ls_po_variant-report = sy-repid.
    ls_po_variant-handle = '9001'.

    CALL METHOD go_po_items_alvgrid->set_table_for_first_display                                   "N:2784633
      EXPORTING
*       is_variant                    = ls_po_variant
*       i_save                        = lv_po_save_variant
        i_default                     = 'X'
        is_layout                     = gs_layout
        it_toolbar_excluding          = lt_exclude
      CHANGING
        it_outtab                     = gt_po_item_diff_delv
        it_fieldcatalog               = gt_fieldcatalog
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

ENDFORM.                    "create_alv_grid_po

*&---------------------------------------------------------------------*
*&      Form  determine_fields_by_bt_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_determine_fields_by_bt_type.
* redesign in note >>>N:2784633
  DATA :
    lt_bob_details     TYPE /dbe/t_veh_bob,
    ls_bob_details     TYPE /dbe/s_veh_bob,
    lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
    lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
    lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
    ls_vlcactdata_head TYPE  vlcactdata_head_s,
    ls_vlcactdata_item TYPE  vlcactdata_item_s,
    lv_pricingtype     TYPE /dbe/veh_pricingtype,
    lv_used_vehicle    TYPE abap_bool.

  lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).

  TRY.
      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob_details.
  ENDTRY.

  LOOP AT gt_vsresult_selection INTO gs_selection.
    READ TABLE lt_bob_details INTO ls_bob_details WITH KEY guid = gs_selection-vguid.
    IF sy-subrc = 0 .
      lo_vehicle ?= ls_bob_details-bobref.

      TRY.
          lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
        CATCH /dbe/cx_veh_layer_not_found .
      ENDTRY.
      ls_vlcactdata_head = lr_vlcactdata_head->*.

      TRY.
          lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
        CATCH /dbe/cx_veh_layer_not_found .
      ENDTRY.
      ls_vlcactdata_item = lr_vlcactdata_item->*.

      CALL FUNCTION '/DBE/VM08_FIND_PRICING_TYPE'
        EXPORTING
          is_vlcactdata_item   = ls_vlcactdata_item
          is_vlcactdata_head   = ls_vlcactdata_head
          iv_use_last_po_info  = abap_true
        IMPORTING
          ev_pricingtype       = lv_pricingtype
        EXCEPTIONS
          determination_failed = 0
          OTHERS               = 0.
      IF lv_pricingtype <> gc_vehipricing_new.
        lv_used_vehicle = abap_true.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_used_vehicle = abap_true.
    IF gv_action EQ /dbe/if_vms_constants=>c_qorb.
      LOOP AT SCREEN.
        IF screen-name EQ 'VLCACTDATA_HEAD_S-KOSTL'.
          screen-active = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    IF gv_action EQ /dbe/if_vms_constants=>c_qorb.
      LOOP AT SCREEN.
        IF screen-name EQ 'VLCACTDATA_HEAD_S-KOSTL'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
* redesign in note <<<N:2784633
ENDFORM.                    "determine_fields_by_bt_type
*&---------------------------------------------------------------------*
*&      Form  fill_common_del_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fill_common_del_date.
  DATA :
    wa_po_item_diff_delv TYPE ty_po_cre_diff_delvdate,
    wa_po_upd_info       TYPE  tty_po_info.

  IF sy-ucomm EQ 'DD_ALL'.
    IF vlcactdata_head_s-eindt IS INITIAL.
      MESSAGE e001(/dbe/vehicle_master) WITH 'Delivery Date'(404).
    ELSE.

      CASE gv_action.
        WHEN /dbe/if_vms_constants=>c_qorb.
          LOOP AT gt_po_item_diff_delv INTO wa_po_item_diff_delv.
            wa_po_item_diff_delv-eindt = vlcactdata_head_s-eindt.
            MODIFY gt_po_item_diff_delv INDEX sy-tabix FROM wa_po_item_diff_delv
            TRANSPORTING eindt.
          ENDLOOP.
          CALL METHOD go_po_items_alvgrid->refresh_table_display. "N:2784633

        WHEN /dbe/if_vms_constants=>c_qmob.
          LOOP AT gt_po_upd_info INTO wa_po_upd_info.
            wa_po_upd_info-eindt_changed = vlcactdata_head_s-eindt.
            MODIFY gt_po_upd_info INDEX sy-tabix FROM wa_po_upd_info
            TRANSPORTING eindt_changed.
          ENDLOOP.
          CALL METHOD go_po_upd_alvgrid->refresh_table_display. "N:2784633

      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    "fill_common_del_date
*&---------------------------------------------------------------------*
*&      Form  check_entry_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_check_entry_fields.

  DATA wa_po_item_diff_delv  LIKE LINE OF gt_po_item_diff_delv .
  DATA wa_po_upd_info        LIKE LINE OF gt_po_upd_info .

  IF gv_action EQ /dbe/if_vms_constants=>c_qorb.

    IF sy-ucomm EQ 'ACT_EXE' .
      PERFORM f_check_entry_fields_filled.
    ENDIF.

    IF sy-ucomm NE 'DD_ALL'.

      LOOP AT gt_po_item_diff_delv INTO wa_po_item_diff_delv.
        IF wa_po_item_diff_delv-eindt IS INITIAL.
          MESSAGE e001(/dbe/vehicle_master) WITH 'Delivery Date'(404).
        ENDIF.
      ENDLOOP.

    ENDIF.

  ELSEIF gv_action EQ /dbe/if_vms_constants=>c_qmob.

    IF sy-ucomm NE 'DD_ALL'.

      LOOP AT gt_po_upd_info INTO wa_po_upd_info.
        IF wa_po_upd_info-eindt_changed IS INITIAL.
          MESSAGE e001(/dbe/vehicle_master) WITH 'Delivery Date'(404).
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDIF.
ENDFORM.                    "check_entry_fields
*&---------------------------------------------------------------------*
*&      Form  transfer_po_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_transfer_po_data.
  DATA: ls_po_item_diff_delv  TYPE  ty_po_cre_diff_delvdate.
  DATA :lv_vendor_changed     TYPE boole_d.
  CLEAR lv_vendor_changed .
  DATA lr_vlcdiavehi         TYPE REF TO vlcdiavehi.
  DATA lv_valid TYPE char01.                                "N:2304203
  DATA lo_veh_buf TYPE REF TO /dbe/cl_veh_buf.
  DATA lt_bob     TYPE /dbe/t_veh_bob.
  DATA ls_bob     TYPE /dbe/s_veh_bob.
  DATA lo_vehicle TYPE REF TO /dbe/cl_veh_dbmvehicle.
  DATA lr_data    TYPE REF TO data.
  DATA lr_item_data TYPE REF TO data.
  DATA lr_vlcactdata_head TYPE REF TO vlcactdata_head_s.
  DATA lr_vlcactdata_item TYPE REF TO vlcactdata_item_s.

  IF gv_ok_code = gc_exec_fc OR gv_ok_code = 'ENTER'.       "N:2773495
    IF go_po_items_alvgrid IS BOUND.                        "N:2784633
      CALL METHOD go_po_items_alvgrid->check_changed_data  "N:2784633
        IMPORTING
          e_valid = lv_valid.
    ENDIF.

    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    TRY.
        CALL METHOD lo_veh_buf->get_all
          RECEIVING
            rt_bob = lt_bob.
    ENDTRY.

    LOOP AT gt_vsresult_selection INTO gs_selection.
      READ TABLE lt_bob INTO ls_bob WITH KEY guid = gs_selection-vguid.
      IF sy-subrc = 0.
        lo_vehicle ?= ls_bob-bobref.
        TRY.
            lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcdiavehi ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.
        IF lr_data IS BOUND.
          lr_vlcdiavehi ?= lr_data.
          IF vlcactdata_head_s-lifnr <> lr_vlcdiavehi->*-lifnr.
            MOVE vlcactdata_head_s-lifnr TO  lr_vlcdiavehi->*-lifnr.
            lv_vendor_changed = abap_true.
*            MESSAGE i445(/DBE/vehicle_master) WITH vlcactdata_head_s-lifnr.
          ENDIF.
        ENDIF.
        TRY.
            lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.
        IF lr_data IS BOUND.
          lr_vlcactdata_head ?= lr_data.

*          MOVE-CORRESPONDING vlcactdata_head_s TO  lr_vlcactdata_head->*.
          MOVE vlcactdata_head_s-bsart TO lr_vlcactdata_head->*-bsart.
          MOVE vlcactdata_head_s-ekorg TO lr_vlcactdata_head->*-ekorg.
          MOVE vlcactdata_head_s-ekgrp TO lr_vlcactdata_head->*-ekgrp.
          MOVE vlcactdata_head_s-lifnr TO lr_vlcactdata_head->*-lifnr.
          MOVE vlcactdata_head_s-/dbe/kostl TO lr_vlcactdata_head->*-/dbe/kostl.
          MOVE vlcactdata_head_s-werks TO  lr_vlcactdata_head->*-werks.
          MOVE vlcactdata_head_s-lgort TO lr_vlcactdata_head->*-lgort.
          MOVE vlcactdata_head_s-umwerks TO lr_vlcactdata_head->*-umwerks.
          MOVE vlcactdata_head_s-umlgo TO lr_vlcactdata_head->*-umlgo.
          MOVE vlcactdata_head_s-reworker TO lr_vlcactdata_head->*-reworker.
          MOVE vlcactdata_head_s-netpr TO lr_vlcactdata_head->*-netpr.
          MOVE vlcactdata_head_s-eindt TO lr_vlcactdata_head->*-eindt. "N:2773495
        ENDIF.
        TRY.
            lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.
        IF lr_item_data IS BOUND.
          lr_vlcactdata_item ?= lr_item_data.
        ENDIF.

*for PO of diff delivery date
        LOOP AT gt_po_item_diff_delv INTO ls_po_item_diff_delv.
          IF lr_vlcactdata_item->*-vguid  =  ls_po_item_diff_delv-vguid.
            IF lines( gt_po_item_diff_delv ) = 1. "In case of one vehicle, header and item both should have same date
              lr_vlcactdata_head->eindt = ls_po_item_diff_delv-eindt.
            ENDIF.
            lr_vlcactdata_item->*-eindt_changed = ls_po_item_diff_delv-eindt.
            lr_vlcactdata_item->*-netpr = ls_po_item_diff_delv-netpr.
            lr_vlcactdata_item->*-item_currency = ls_po_item_diff_delv-currency.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

* Set data in Vehicle buffer - moves data from COM to WRK layer
    TRY.
        CALL METHOD lo_veh_buf->set_all.
      CATCH /dbe/cx_veh_error_occured .
      CATCH cx_static_check.
    ENDTRY.
    IF lv_vendor_changed = abap_true.
      MESSAGE i445(/dbe/vehicle_master) WITH vlcactdata_head_s-lifnr.
      RETURN.
    ENDIF.

  ENDIF.
ENDFORM.                    "transfer_po_data
*&---------------------------------------------------------------------*
*&      Form  f_user_command_302
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_user_command_302.

  DATA : ls_bapireturn TYPE bapiret2,
         ls_vlcdiavehi TYPE vlcdiavehi,
         lx_root       TYPE REF TO cx_root,
         ls_vsresult   TYPE /dbe/vsresult,
         lo_veh_buf    TYPE REF TO /dbe/cl_veh_buf,         "N:2304203
         lt_bob        TYPE /dbe/t_veh_bob,
         ls_bob        TYPE /dbe/s_veh_bob,
         lo_vehicle    TYPE REF TO /dbe/cl_veh_dbmvehicle.

  CALL FUNCTION '/DBE/VMASS_GET_OK_CODE'
    IMPORTING
      ev_ok_code = gv_ok_code.


  CASE gv_ok_code .

    WHEN gc_exec_fc.
* get instance of the buffer...
      lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
* Trigger buffer save ,which in turn triggers action execution and mass save of vehicle class
      TRY.

          CALL METHOD lo_veh_buf->set_all.

          CALL METHOD lo_veh_buf->save( ).
          " If save doesnot throw any exceptions, go ahead with commit
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
* Get data from Work Layer to COM layer - after save , data like po number etc could be retrieved back to COM layer by this

          TRY.
              CALL METHOD lo_veh_buf->get_all
                RECEIVING
                  rt_bob = lt_bob.
          ENDTRY.
          LOOP AT lt_bob INTO ls_bob.
            lo_vehicle ?= ls_bob-bobref.
            TRY.
                CALL METHOD lo_vehicle->/dbe/if_veh_bob~fill_com.
              CATCH /dbe/cx_veh_static_check .
            ENDTRY.
          ENDLOOP.
          CLEAR : vlcactdata_head_s ,vlcactdata_item_s.

        CATCH /dbe/cx_veh_error_occured INTO lx_root.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          CLEAR : vlcactdata_head_s ,vlcactdata_item_s.
        CATCH  cx_static_check INTO lx_root.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          CLEAR : vlcactdata_head_s ,vlcactdata_item_s.
        CATCH cx_root.
          sy-subrc = 1.
      ENDTRY.


    WHEN OTHERS.
      " do nothing
  ENDCASE.


ENDFORM.                    "f_user_command_302
*&---------------------------------------------------------------------*
*&      Form  create_alv_grid_po_upd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_create_alv_grid_po_upd.
  DATA : lv_cc_po_upd_name TYPE scrfname VALUE 'CC_UPDATE_PO', "N:2784633
         ls_po_upd         TYPE tty_po_info,
         lv_used_vehicle   TYPE abap_bool.

  DATA: lt_excludes TYPE ui_functions.

  IF gv_ok_code NE 'DD_ALL'.
    IF go_cc_po_upd IS NOT BOUND .                          "N:2784633
* CREATE A CUSTOM CONTAINER CONTROL FOR OUR ALV CONTROL
      CREATE OBJECT go_cc_po_upd                                               "N:2784633
        EXPORTING
          container_name              = lv_cc_po_upd_name                      "N:2784633
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5.
      IF sy-subrc NE 0.
* ADD YOUR HANDLING, FOR EXAMPLE
        CALL FUNCTION 'POPUP_TO_INFORM'
          EXPORTING
            titel = sy-repid
            txt2  = sy-subrc
            txt1  = 'THE CONTROL COULD NOT BE CREATED'(510).
      ENDIF.

    ENDIF.
    IF go_po_upd_alvgrid IS NOT BOUND.                      "N:2784633
* CREATE AN INSTANCE OF ALV CONTROL
      CREATE OBJECT go_po_upd_alvgrid                                          "N:2784633
        EXPORTING
          i_parent = go_cc_po_upd.                                            "N:2784633
    ENDIF.
*
*    CALL METHOD po_upd_alvgrid->set_ready_for_input
*      EXPORTING
*        i_ready_for_input = 0.
    CLEAR gs_layout.
    CLEAR gs_fieldcat.
    CLEAR gt_fieldcatalog.
* SET A TITLEBAR FOR THE GRID CONTROL
    gs_layout-grid_title = TEXT-016.
    gs_layout-smalltitle = 'X'.
    gs_layout-cwidth_opt = 'X'.
*    gs_layout-edit = 'X'.

    gs_fieldcat-fieldname   = '/DBE/SELECTED'.
*    gs_fieldcat-coltext   = 'Int. Veh. No.'.
*    gs_fieldcat-outputlen = 35.
    gs_fieldcat-tech = 'X'.
    gs_fieldcat-col_pos     = 1.
    gs_fieldcat-datatype = 'CHAR' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-fieldname   = 'VHCLE'.
    gs_fieldcat-coltext   = 'Int. Veh. No.'(102).
    gs_fieldcat-outputlen = 15.
    gs_fieldcat-col_pos     = 2.
    gs_fieldcat-datatype = 'CHAR' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-fieldname   = 'MCODESD'.
    gs_fieldcat-coltext   = 'Model Sales code'(103).
    gs_fieldcat-outputlen = 10.
    gs_fieldcat-col_pos     = 3.
    gs_fieldcat-datatype = '/DBE/MODCODE_SALE' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-fieldname   = 'PO_NUMBER'.
    gs_fieldcat-coltext   = 'Purchase Order'(106).
    gs_fieldcat-outputlen = 13.
    gs_fieldcat-col_pos     = 4.
    gs_fieldcat-datatype = 'EBELN' .

    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.
    gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
    gs_fieldcat-fieldname   = 'PO_ITEM'.
    gs_fieldcat-coltext   = 'Item'(115).
    gs_fieldcat-outputlen = 13.
    gs_fieldcat-col_pos     = 5.
    gs_fieldcat-datatype = 'EBELP' .

    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
    gs_fieldcat-fieldname   = 'EKORG'.
    gs_fieldcat-coltext   = 'Purchasing Org'(107).
    gs_fieldcat-outputlen = 13.
    gs_fieldcat-col_pos     = 6.
    gs_fieldcat-datatype = 'CHAR' .

    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
    gs_fieldcat-fieldname   = 'EKGRP'.
    gs_fieldcat-coltext   = 'Purchasing Group'(108).
    gs_fieldcat-outputlen = 13.
    gs_fieldcat-col_pos     = 7.
    gs_fieldcat-datatype = 'CHAR' .

    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-fieldname   = 'NETPR'.
    gs_fieldcat-cfieldname = 'CURRENCY'.                    "N:2304203
    gs_fieldcat-coltext   = 'Net Price'(104).
    gs_fieldcat-outputlen = 11.
    gs_fieldcat-col_pos     = 8.
    gs_fieldcat-datatype = 'NETPR' .

    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-fieldname  = 'OPTPR'.
    gs_fieldcat-cfieldname = 'CURRENCY'.
    gs_fieldcat-coltext    = 'Option Price'(126).
    gs_fieldcat-outputlen  = 11.
    gs_fieldcat-col_pos    = 8.
    gs_fieldcat-datatype   = 'NETPR'.

    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.
*
    gs_fieldcat-fieldname   = 'CURRENCY'.
    gs_fieldcat-coltext   = 'Currency'(105).
    gs_fieldcat-outputlen = 11.
    gs_fieldcat-col_pos     = 9.
    gs_fieldcat-datatype = 'WAERS' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-fieldname   = 'EINDT_CHANGED'.
    gs_fieldcat-coltext   = 'Delivery Date'(109).
    gs_fieldcat-outputlen = 10.
    gs_fieldcat-col_pos     = 10.
    gs_fieldcat-datatype = 'DATS' .
    gs_fieldcat-ref_table = 'VLCACTDATA_HEAD_S'.
    gs_fieldcat-ref_field = 'EINDT'.
    gs_fieldcat-f4availabl = 'X'.
    gs_fieldcat-edit = 'X'.
    gs_fieldcat-auto_value = 'X'.
    gs_fieldcat-tabname = 'D'.
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.


*Optionally register ENTER to raise event DATA_CHANGED.
* (Per default the user may check data by using the check icon).
    CALL METHOD go_po_upd_alvgrid->register_edit_event         "N:2784633
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD go_po_upd_alvgrid->register_edit_event         "N:2784633
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*create the event handler for verifying the input data.
    IF g_alv_handler_po IS INITIAL.                         "N:2784633
      CREATE OBJECT g_alv_handler_po.
    ENDIF.

* register double click handler
    SET HANDLER g_alv_handler_po->handle_data_changed
           FOR go_po_upd_alvgrid.                           "N:2784633

    PERFORM prepare_po_info. " TABLES lt_ininvoice_info.

*    CALL METHOD po_upd_alvgrid->set_ready_for_input
*      EXPORTING
*        i_ready_for_input = 0.

    PERFORM exclude_tb_functionss CHANGING lt_excludes.
    CALL METHOD go_po_upd_alvgrid->set_table_for_first_display  "N:2784633
      EXPORTING
*       i_default                     = 'X'
        is_layout                     = gs_layout
        it_toolbar_excluding          = lt_excludes
      CHANGING
        it_outtab                     = gt_po_upd_info
        it_fieldcatalog               = gt_fieldcatalog
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    "create_alv_grid_po_upd
*&---------------------------------------------------------------------*
*&      Form  f_transfer_po_upd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_transfer_po_upd.

  DATA  : lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
          lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
          ls_po_info         LIKE LINE OF gt_po_upd_info,
          lr_item_data       TYPE REF TO data,
          lr_vlcactdata_head TYPE REF TO vlcactdata_head_s, "N:2304203
          lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
          lt_bob             TYPE /dbe/t_veh_bob,
          ls_bob             TYPE /dbe/s_veh_bob.

  DATA lv_valid TYPE c.

  IF gv_ok_code = 'ACT_EXE'.
    IF go_po_upd_alvgrid IS BOUND.                          "N:2784633
      CALL METHOD go_po_upd_alvgrid->check_changed_data      "N:2784633
        IMPORTING
          e_valid = lv_valid.
    ENDIF.

    CALL METHOD /dbe/cl_veh_buf=>get_instance
      RECEIVING
        ro_instance = lo_veh_buf.

    CALL METHOD lo_veh_buf->get_all
      RECEIVING
        rt_bob = lt_bob.

    IF lt_bob IS NOT INITIAL.
      LOOP AT gt_po_upd_info INTO ls_po_info.
        READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_po_info-vguid.
        lo_vehicle ?= ls_bob-bobref.
        TRY.
            lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.
        IF lr_item_data IS BOUND.
          lr_vlcactdata_item ?= lr_item_data.
        ENDIF.
* for PO of same delivery date
        IF  lr_vlcactdata_item->*-vguid  = ls_bob-guid.
          lr_vlcactdata_item->*-eindt_changed = ls_po_info-eindt_changed.
        ENDIF.
      ENDLOOP.
    ENDIF.

    TRY.
        CALL METHOD lo_veh_buf->set_all.
      CATCH /dbe/cx_veh_error_occured .
      CATCH cx_static_check .
    ENDTRY.
  ENDIF.
ENDFORM.                    "f_transfer_po_upd
*&---------------------------------------------------------------------*
*&      Form  f_create_alv_grid_po_del
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_create_alv_grid_po_del.
  DATA : lv_cc_po_del_name TYPE scrfname VALUE 'CC_DEL_PO', "N:2784633
         lt_exclude        TYPE ui_functions.

  CLEAR gs_layout.
  CLEAR gs_fieldcat.
  CLEAR gt_fieldcatalog.

  IF go_cc_po_del IS INITIAL .                              "N:2784633
* CREATE A CUSTOM CONTAINER CONTROL FOR OUR ALV CONTROL
    CREATE OBJECT go_cc_po_del                                                 "N:2784633
      EXPORTING
        container_name              = lv_cc_po_del_name                        "N:2784633
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc NE 0.
* ADD YOUR HANDLING, FOR EXAMPLE
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = sy-repid
          txt2  = sy-subrc
          txt1  = 'THE CONTROL COULD NOT BE CREATED'(510).
    ENDIF.

  ENDIF.                                                    "N:2784633

* CREATE AN INSTANCE OF ALV CONTROL
  IF go_po_del_alvgrid IS INITIAL.                          "N:2784633
    CREATE OBJECT go_po_del_alvgrid                                            "N:2784633
      EXPORTING
        i_parent = go_cc_po_del.                                               "N:2784633
  ENDIF.

  CLEAR gs_layout.

* SET A TITLEBAR FOR THE GRID CONTROL
  gs_layout-grid_title = TEXT-017.
  gs_layout-smalltitle ='X'.
  gs_layout-cwidth_opt = 'X'.

  gs_fieldcat-fieldname   = '/DBE/SELECTED'.
  gs_fieldcat-tech = 'X'.
  gs_fieldcat-col_pos     = 1.
  gs_fieldcat-datatype = 'CHAR' .
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.

  gs_fieldcat-fieldname   = 'VHCLE'.
  gs_fieldcat-coltext   = 'Int. Veh. No.'(111).
  gs_fieldcat-outputlen = 15.
  gs_fieldcat-col_pos     = 1.
  gs_fieldcat-datatype = 'CHAR' .
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.


  gs_fieldcat-fieldname   = 'MCODESD'.
  gs_fieldcat-coltext   = 'Model Sales code'(112).
  gs_fieldcat-outputlen = 10.
  gs_fieldcat-col_pos     = 2.
  gs_fieldcat-datatype = '/DBE/MODCODE_SALE' .
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.

  gs_fieldcat-fieldname   = 'PO_NUMBER'.
  gs_fieldcat-coltext   = 'Purchase Order'(113).
  gs_fieldcat-outputlen = 10.
  gs_fieldcat-col_pos     = 3.
  gs_fieldcat-datatype = 'EBELN' .

  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.

  gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
  gs_fieldcat-fieldname   = 'PO_ITEM'.
  gs_fieldcat-coltext   = 'Item'(115).
  gs_fieldcat-outputlen = 10.
  gs_fieldcat-col_pos     = 4.
  gs_fieldcat-datatype = 'EBELP' .

  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.

  gs_fieldcat-fieldname   = 'EKORG'.
  gs_fieldcat-coltext   = 'Purchasing Org'(114).
  gs_fieldcat-outputlen = 5.
  gs_fieldcat-col_pos     = 5.
  gs_fieldcat-datatype = 'EKORG' .

  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.

  gs_fieldcat-fieldname   = 'EKGRP'.
  gs_fieldcat-coltext   = 'Purchasing Group'(116).
  gs_fieldcat-outputlen = 5.
  gs_fieldcat-col_pos     = 6.
  gs_fieldcat-datatype = 'EKRP' .

  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.




  gs_fieldcat-fieldname   = 'NETPR'.
  gs_fieldcat-cfieldname = 'CURRENCY'.                      "N:2304203
  gs_fieldcat-coltext   = 'Net Price'(123).
  gs_fieldcat-outputlen = 25.
  gs_fieldcat-col_pos     = 7.
  gs_fieldcat-datatype = 'CURR'.                            "N:2304203
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.

  gs_fieldcat-fieldname  = 'OPTPR'.
  gs_fieldcat-cfieldname = 'CURRENCY'.
  gs_fieldcat-coltext    = 'Option Price'(126).
  gs_fieldcat-outputlen  = 25.
  gs_fieldcat-col_pos    = 7.
  gs_fieldcat-datatype   = 'CURR'.
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.

  gs_fieldcat-fieldname   = 'CURRENCY'.
  gs_fieldcat-coltext   = 'Currency'(124).
  gs_fieldcat-outputlen = 10.
  gs_fieldcat-col_pos     = 8.
  gs_fieldcat-datatype = 'CUKY'.                            "N:2304203
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.


  gs_fieldcat-fieldname   = 'EINDT_CHANGED'.
  gs_fieldcat-coltext   = 'Delivery Date'(109).
  gs_fieldcat-outputlen = 10.
  gs_fieldcat-col_pos     = 8.
  gs_fieldcat-datatype = 'DATS' .
  gs_fieldcat-ref_table = 'VLCACTDATA_HEAD_S'.
  gs_fieldcat-ref_field = 'EINDT'.
*    gs_fieldcat-f4availabl = 'X'.
*    gs_fieldcat-edit = 'X'.
  gs_fieldcat-auto_value = 'X'.
  gs_fieldcat-tabname = 'D'.

  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.

  PERFORM prepare_po_del_info.

  PERFORM exclude_tb_functionss CHANGING lt_exclude.
  CALL METHOD go_po_del_alvgrid->set_table_for_first_display  "N:2784633
    EXPORTING
      is_layout                     = gs_layout
      it_toolbar_excluding          = lt_exclude
    CHANGING
      it_outtab                     = gt_po_del_info
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
ENDFORM.                    "f_create_alv_grid_po_del
*&---------------------------------------------------------------------*
*&      Form  f_prepare_alv_grid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_prepare_alv_grid.
  CONSTANTS: lc_alv_var_save TYPE c VALUE 'A'.

  DATA: ls_ac_variant      TYPE disvariant,
        lv_ac_save_variant TYPE char1,
        ls_ac_layout       TYPE lvc_s_layo.

  DATA : lv_container     TYPE scrfname,
         lo_grid          TYPE REF TO cl_gui_alv_grid,
         ls_editcell      TYPE lvc_s_styl,
         lv_old_po_number TYPE ebeln,
         ls_pack_f4       TYPE lvc_s_f4,
         lt_pack_f4       TYPE lvc_t_f4.

  FIELD-SYMBOLS
        <ls_ac_cancel> TYPE ty_addcost_cancel.

* Update all ok code with current function code
  ok_code = gv_ok_code = gt_ok = sy-ucomm.

  ls_ac_variant-report = sy-repid.
  lv_ac_save_variant = lc_alv_var_save.

  IF ok_code EQ 'ORDTYP' OR ok_code EQ 'ACCTYP' OR ok_code EQ gc_enter_fcode OR ok_code EQ gc_receiver.
    RETURN.
  ENDIF.

*  *Dont execute when user press "Distribute Button"
  IF sy-ucomm NE gc_ac_all AND gv_ok_code NE  gc_enter_fcode AND sy-ucomm NE gc_error.

    CLEAR: lv_container.

    IF gv_action = /dbe/if_vms_constants=>c_qapo OR gv_action = /dbe/if_vms_constants=>c_qagr
      OR gv_action = /dbe/if_vms_constants=>c_qain OR
       gv_action = /dbe/if_vms_constants=>c_qadc.
      CONCATENATE 'CONT_' /dbe/if_vms_constants=>c_qadc INTO lv_container.
      CLEAR go_custom_container.
    ELSE.
      CONCATENATE 'CONT_' gv_action INTO lv_container.
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
    PERFORM prepare_alv_data.

    CASE gv_action.

      WHEN /dbe/if_vms_constants=>c_qgrb.
        IF go_gr_create IS NOT BOUND.

*        Create Instance of ALV control
          CREATE OBJECT go_gr_create
            EXPORTING
              i_parent = go_custom_container.
        ENDIF.


        IF go_gr_create IS BOUND.

          CALL METHOD go_gr_create->set_table_for_first_display
            EXPORTING
              is_layout                     = gs_layout
              it_toolbar_excluding          = lt_excludes
            CHANGING
              it_outtab                     = gt_gr_create
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

      WHEN /dbe/if_vms_constants=>c_qgcb.
        IF go_gr_cancel IS NOT BOUND.

*         Create Instance of ALV control
          CREATE OBJECT go_gr_cancel
            EXPORTING
              i_parent = go_custom_container.
        ENDIF.



        IF go_gr_cancel IS BOUND.
          CALL METHOD go_gr_cancel->set_table_for_first_display
            EXPORTING
              is_layout                     = gs_layout
              it_toolbar_excluding          = lt_excludes
            CHANGING
              it_outtab                     = gt_gr_cancel
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

      WHEN /dbe/if_vms_constants=>c_qirb.
        IF go_inv_cancel IS NOT BOUND.

*         Create Instance of ALV control
          CREATE OBJECT go_inv_cancel
            EXPORTING
              i_parent = go_custom_container.
        ENDIF.

        IF go_inv_cancel IS BOUND.
          CALL METHOD go_inv_cancel->set_table_for_first_display
            EXPORTING
              is_layout                     = gs_layout
              it_toolbar_excluding          = lt_excludes
            CHANGING
              it_outtab                     = gt_inv_cancel
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

      WHEN /dbe/if_vms_constants=>c_qpdi.

        IF  sy-ucomm IS INITIAL.
          gv_pdi_ord_cnt = 0.
          CLEAR gt_pdi_ord.
        ENDIF.

*      Local table for package f4 set to initial.
        REFRESH lt_pack_f4.

        IF go_pdi_ordcrt IS INITIAL.

*         Create Instance of ALV control
          CREATE OBJECT go_pdi_ordcrt
            EXPORTING
              i_parent = go_custom_container.
        ENDIF.

        IF go_pdi_ordcrt IS BOUND.
          CALL METHOD go_pdi_ordcrt->register_edit_event
            EXPORTING
              i_event_id = cl_gui_alv_grid=>mc_evt_enter.

          CALL METHOD go_pdi_ordcrt->register_edit_event
            EXPORTING
              i_event_id = cl_gui_alv_grid=>mc_evt_modified.
        ENDIF.

        IF g_alv_handler_pdiord IS NOT BOUND.
          CREATE OBJECT g_alv_handler_pdiord.
        ENDIF.

*      Register events
        IF g_alv_handler_pdiord IS BOUND.
          SET HANDLER g_alv_handler_pdiord->handle_data_changed_finished FOR go_pdi_ordcrt.
          SET HANDLER g_alv_handler_pdiord->handle_data_changed FOR go_pdi_ordcrt.
          SET HANDLER g_alv_handler_pdiord->handle_toolbar      FOR go_pdi_ordcrt.
          SET HANDLER g_alv_handler_pdiord->handle_menu_button  FOR go_pdi_ordcrt.
          SET HANDLER g_alv_handler_pdiord->handle_user_command FOR go_pdi_ordcrt.
          SET HANDLER g_alv_handler_pdiord->alv_handle_f4       FOR go_pdi_ordcrt.
        ENDIF.
        ls_pack_f4-fieldname  = 'PACKAGE_ID'.
        ls_pack_f4-register   = abap_true.

        APPEND ls_pack_f4 TO lt_pack_f4.

        CALL METHOD go_pdi_ordcrt->register_f4_for_fields
          EXPORTING
            it_f4 = lt_pack_f4.

        ls_ac_variant-report = sy-repid.
        ls_ac_variant-handle = '0800'.
        lv_ac_save_variant = lc_alv_var_save.

        IF go_pdi_ordcrt IS BOUND.
          gs_layout-stylefname = 'CELLSTYLES'.
          CALL METHOD go_pdi_ordcrt->set_table_for_first_display
            EXPORTING
              is_variant                    = ls_ac_variant
              i_save                        = lv_ac_save_variant
              is_layout                     = gs_layout
              it_toolbar_excluding          = lt_excludes
            CHANGING
              it_outtab                     = gt_pdi_ord
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

    ENDCASE.

  ENDIF.
ENDFORM.                    "f_prepare_alv_grid
*&---------------------------------------------------------------------*
*&      Form  f_fill_short_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fill_short_text.
  DATA lr_exroot TYPE REF TO cx_root.
  DATA lo_factory TYPE REF TO /dbe/cl_veh_md_reader_factory.
  DATA lo_reader TYPE REF TO /dbe/if_veh_md_reader.
  DATA lo_buskey TYPE REF TO /dbe/cl_veh_md_key_bustype.
  DATA lo_result TYPE REF TO /dbe/if_veh_md_result.
  DATA lo_txt TYPE string.
  DATA lo_plant TYPE REF TO /dbe/cl_veh_md_key_plant.
  DATA lo_storeloc TYPE REF TO /dbe/cl_veh_md_key_storeloc.
  DATA lv_error_message TYPE string.


  TRY.
      lo_factory = /dbe/cl_veh_md_reader_factory=>get_instance( ).
      TRY.
*read plant
          lo_reader = lo_factory->create_reader( 'PLANT' ).
          lo_plant ?= lo_reader->createkey( ).
          lo_plant->set_plant( vlcactdata_head_s-werks ).
          lo_result = lo_reader->read( lo_plant ).
          t001w-name1 = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t001w-name1 = ''.
      ENDTRY.
      TRY.
* read storage location
          lo_reader = lo_factory->create_reader( 'STORELOC' ).
          lo_storeloc ?= lo_reader->createkey( ).
          lo_storeloc->set_storeloc( vlcactdata_head_s-lgort ).
          lo_storeloc->set_plant( vlcactdata_head_s-werks ).
          lo_result = lo_reader->read( lo_storeloc ).
          t001l-lgobe = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t001l-lgobe = ''.
      ENDTRY.

    CATCH cx_root INTO lr_exroot .
      lv_error_message = lr_exroot->if_message~get_longtext( ).
*     if something went wrong during reading short text, the shost text will be empty and error silently
*     dropped becasue it not effecting.
  ENDTRY.
ENDFORM.                    "f_fill_short_text
*&---------------------------------------------------------------------*
*&      Form  f_transfer_gr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_transfer_gr.
  DATA: ls_gr_create       LIKE LINE OF gt_gr_create,
        lr_data            TYPE REF TO data,                "N:2304203
        lr_item_data       TYPE REF TO data,
        lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
        lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
        lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
        lt_bob             TYPE /dbe/t_veh_bob,
        ls_bob             TYPE /dbe/s_veh_bob,
        lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle.

*  IF sy-ucomm EQ 'ACT_EXE' .

  CALL METHOD /dbe/cl_veh_buf=>get_instance
    RECEIVING
      ro_instance = lo_veh_buf.

  TRY.
      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob.
  ENDTRY.

  LOOP AT gt_gr_create INTO ls_gr_create.

    READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_gr_create-vguid.
    lo_vehicle ?= ls_bob-bobref.

    TRY.
        lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_data IS BOUND.
      lr_vlcactdata_head ?= lr_data.
      " Dont do move correspopnding of head structure as it overwrite vguid and iobjectguid
      MOVE vlcactdata_head_s-bldat TO lr_vlcactdata_head->*-bldat.
      MOVE vlcactdata_head_s-budat TO lr_vlcactdata_head->*-budat.
      MOVE vlcactdata_head_s-werks TO lr_vlcactdata_head->*-werks.
*        MOVE ls_gr_create-lgort TO lr_vlcactdata_head->*-lgort.
      MOVE vlcactdata_head_s-lgort TO lr_vlcactdata_head->*-lgort.
      MOVE vlcactdata_head_s-lfsnr TO lr_vlcactdata_head->*-lfsnr.
      MOVE vlcactdata_head_s-frbnr TO lr_vlcactdata_head->*-frbnr.
      gs_vlcactdata_head = lr_vlcactdata_head->*.
    ENDIF.
    TRY.
        lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_item_data IS BOUND.
      lr_vlcactdata_item ?= lr_item_data.
      MOVE ls_gr_create-werks TO lr_vlcactdata_item->*-werks.
    ENDIF.

  ENDLOOP.

  TRY.
      CALL METHOD lo_veh_buf->set_all.
    CATCH /dbe/cx_veh_error_occured .
    CATCH cx_static_check .
  ENDTRY.

ENDFORM.                    "f_transfer_gr
*&---------------------------------------------------------------------*
*&      Form  f_create_alv_grid_inv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_create_alv_grid_inv.
  CONSTANTS: lc_alv_var_savein_in TYPE c VALUE 'A'.

  DATA : lt_f4              TYPE lvc_t_f4,
         ls_f4              TYPE lvc_s_f4,
         cc_create_inv      TYPE scrfname VALUE 'CC_INCOMING_INV',
         lt_ininvoice_info  TYPE TABLE OF tty_invoice_info,
         lt_exclude_inc     TYPE ui_functions,
         lv_col_no          TYPE i, " VALUE 1.
         ls_in_variant      TYPE disvariant,
         lv_in_save_variant TYPE char1,
         lv_used_vehicle    TYPE abap_bool.                 "N:2784633

  FIELD-SYMBOLS <fieldcatalog> TYPE lvc_s_fcat.             "N:2784633

*  Below CHECK is commented due to the note 2282056 corrections
*  CHECK incinvoice_alvgrid IS NOT BOUND.
  " this line is added to solve problem of vehicle list hide/dispaly issue.
  ok_code = gv_ok_code = gt_ok = sy-ucomm.


  CLEAR: gt_fieldcatalog , gs_fieldcat ,gs_layout, lv_col_no.
  lv_col_no = lv_col_no + 1.

  IF go_custom_container_inv IS INITIAL .
* CREATE A CUSTOM CONTAINER CONTROL FOR OUR ALV CONTROL
    CREATE OBJECT go_custom_container_inv
      EXPORTING
        container_name              = cc_create_inv
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc NE 0.
* ADD YOUR HANDLING, FOR EXAMPLE
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = sy-repid
          txt2  = sy-subrc
          txt1  = 'THE CONTROL COULD NOT BE CREATED'(510).
    ENDIF.

* CREATE AN INSTANCE OF ALV CONTROL
    CREATE OBJECT incinvoice_alvgrid
      EXPORTING
        i_parent = go_custom_container_inv.
  ENDIF.

  CLEAR: gs_layout, gt_fieldcatalog.

* SET A TITLEBAR FOR THE GRID CONTROL
  gs_layout-grid_title = TEXT-018.
  gs_layout-smalltitle = 'X'.

  gs_fieldcat-fieldname = '/DBE/SELECTED'.
  gs_fieldcat-tech     = 'X'.
  gs_fieldcat-col_pos  = lv_col_no.
  gs_fieldcat-datatype = 'CHAR' .
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.
  lv_col_no = lv_col_no + 1.

  gs_fieldcat-fieldname = 'VHCLE'.
  gs_fieldcat-coltext   = 'Int. Veh. No.'(090).
  gs_fieldcat-outputlen = 15.
  gs_fieldcat-col_pos   = lv_col_no + 1.
  gs_fieldcat-datatype  = 'CHAR' .
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.
  lv_col_no = lv_col_no + 1.

  gs_fieldcat-fieldname = '/DBE/AIMED_PURCPRICE'.
  gs_fieldcat-cfieldname = 'CURRENCY'.                      "N:2304203
  gs_fieldcat-coltext   = 'Aimed Purch Price'(406).
  gs_fieldcat-outputlen = 13.
  gs_fieldcat-col_pos   = lv_col_no + 1.
  gs_fieldcat-datatype  = 'CURR' .
  gs_fieldcat-tech      = abap_true.                        "N:2784633
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.
  lv_col_no = lv_col_no + 1.

  gs_fieldcat-fieldname = 'NETPR'.
  gs_fieldcat-cfieldname = 'CURRENCY'.                      "N:2304203
  gs_fieldcat-coltext   = 'Net Price'(091).
  gs_fieldcat-outputlen = 11.
  gs_fieldcat-edit      = 'X'.
  gs_fieldcat-col_pos   = lv_col_no + 1.
  gs_fieldcat-datatype  = 'CURR' .
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.
  lv_col_no = lv_col_no + 1.

  gs_fieldcat-fieldname = 'CURRENCY'.
  gs_fieldcat-coltext   = 'Currency'(092).
  gs_fieldcat-outputlen = 5.
*  gs_fieldcat-edit      = 'X'.
  gs_fieldcat-col_pos   = lv_col_no + 1.
  gs_fieldcat-datatype  = 'CUKY' .                          "N:2304203
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.
  lv_col_no = lv_col_no + 1.

  gs_fieldcat-fieldname = 'TAX_AMOUNT'.
  gs_fieldcat-cfieldname = 'CURRENCY'.                      "N:2304203
  gs_fieldcat-coltext   = 'Tax Amount'(094).
  gs_fieldcat-outputlen = 13.
  gs_fieldcat-col_pos   = lv_col_no + 1.
  gs_fieldcat-edit      = 'X'.
  gs_fieldcat-datatype  = 'CURR' .
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.
  lv_col_no = lv_col_no + 1.

  gs_fieldcat-fieldname = 'TAX_CODE'.
  gs_fieldcat-coltext   = 'Tax Code'(095).
*  gs_fieldcat-outputlen = 13.
  gs_fieldcat-col_pos   = lv_col_no + 1..
*  gs_fieldcat-edit      = 'X'.
*  gs_fieldcat-datatype  = 'CURR' .
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.
  lv_col_no = lv_col_no + 1.

  gs_fieldcat-fieldname = 'GROSS_AMOUNT'.
  gs_fieldcat-cfieldname = 'CURRENCY'.                      "N:2304203
  gs_fieldcat-coltext   = 'Gross Amount'(096).
  gs_fieldcat-outputlen = 13.
  gs_fieldcat-col_pos   = lv_col_no + 1.
  gs_fieldcat-edit      = 'X'.
  gs_fieldcat-datatype  = 'CURR' .
  APPEND gs_fieldcat TO gt_fieldcatalog.
  CLEAR  gs_fieldcat.
  lv_col_no = lv_col_no + 1.


*Optionally register ENTER to raise event DATA_CHANGED.
* (Per default the user may check data by using the check icon).
  CALL METHOD incinvoice_alvgrid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD incinvoice_alvgrid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*create the event handler for verifying the input data.

  IF g_alv_handler IS NOT BOUND.
    CREATE OBJECT g_alv_handler.
  ENDIF.
*
  PERFORM prepare_invoice_info. " TABLES lt_ininvoice_info.

* check if used vehicle is in selections                                                            >>>N:2784633
  PERFORM check_used_vehicle USING    abap_true "info from last PO
                             CHANGING lv_used_vehicle.
  IF lv_used_vehicle = abap_true.
*   in case of used vehicle show as well Aimed Purchase Price column
    READ TABLE gt_fieldcatalog ASSIGNING <fieldcatalog> WITH KEY fieldname = '/DBE/AIMED_PURCPRICE'.
    IF sy-subrc = 0.
      <fieldcatalog>-tech = abap_false.
    ENDIF.
  ENDIF.                                                                                           "<<<N:2784633

  PERFORM exclude_tb_functionss CHANGING lt_exclude_inc.

  ls_in_variant-report = sy-repid.
  ls_in_variant-handle = '0501'.


  CALL METHOD incinvoice_alvgrid->set_table_for_first_display
    EXPORTING
      is_variant                    = ls_in_variant
*     i_buffer_active               =
*     i_bypassing_buffer            =
*     i_consistency_check           =
*     i_structure_name              =
      i_default                     = 'X'
      is_layout                     = gs_layout
*     is_print                      =
*     it_special_groups             =
      it_toolbar_excluding          = lt_exclude_inc
*     it_hyperlink                  =
*     it_alv_graphics               =
*     it_except_qinfo               =
*     ir_salv_adapter               =
    CHANGING
      it_outtab                     = gt_ininvoice_info
      it_fieldcatalog               = gt_fieldcatalog
*     it_sort                       =
*     it_filter                     =
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* register double click handler
  SET HANDLER g_alv_handler->handle_data_changed
         FOR incinvoice_alvgrid.
  SET HANDLER g_alv_handler->handle_data_changed_finished
       FOR incinvoice_alvgrid.

  CALL METHOD incinvoice_alvgrid->refresh_table_display.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "f_create_alv_grid_inv
*&---------------------------------------------------------------------*
*&      Form  f_calculate_tax_for_inv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_calculate_tax_for_inv.
  DATA  : lv_gross_amount TYPE vlcactdata_head_s-gross_amount,
          lv_tax_amount   TYPE vlcactdata_head_s-tax_amount,
          lv_net_price    TYPE vlcactdata_head_s-netpr,
          lv_valid        TYPE boole_d.                     "N:2304203
  CLEAR : ls_invoice_info ,lv_tax_amount, lv_gross_amount ,lv_net_price.
* Calculate tax a gross amount based on inputs (tax_code /net price)
  PERFORM f_calculate_tax.

  IF incinvoice_alvgrid IS BOUND.
    CALL METHOD incinvoice_alvgrid->check_changed_data
      IMPORTING
        e_valid = lv_valid.
  ENDIF.
*  refresh the ALV table to show the updated values
  IF incinvoice_alvgrid IS BOUND.
    CALL METHOD incinvoice_alvgrid->refresh_table_display.
  ENDIF.
* Collect the prices and calculate thetax amount an dgross amount at header level.

  LOOP AT gt_ininvoice_info INTO ls_invoice_info.

    lv_net_price    = lv_net_price    + ls_invoice_info-netpr.
    lv_gross_amount = lv_gross_amount + ls_invoice_info-gross_amount.
    lv_tax_amount   = lv_tax_amount   + ls_invoice_info-tax_amount. "#EC CI_FLDEXT_OK[2610650]

  ENDLOOP.

  vlcactdata_head_s-netpr        = lv_net_price.
  vlcactdata_head_s-tax_amount   = lv_tax_amount.
  vlcactdata_head_s-gross_amount = lv_gross_amount.

  gv_tax_calculated = abap_true.
ENDFORM.                    "f_calculate_tax_for_inv
*&---------------------------------------------------------------------*
*&      Form  f_check_qinb_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_check_qinb_date.
* Return Parameters for DOCHEADER_PERIOD_FIND_CHECK
  DATA: l_gjahr TYPE         gjahr,
        l_xrueb TYPE         xrueb,
        l_currj TYPE         currj,
        l_monat TYPE         monat.
  DATA: ls_message TYPE bapiret2,
        lt_message TYPE bapiret2_t,
        ls_msgtext TYPE string.

* check of the dates
  CALL FUNCTION 'DOCHEADER_PERIOD_FIND_CHECK'               "1143365
    EXPORTING
      i_bukrs       = vlcactdata_head_s-comp_code
      i_bldat       = vlcactdata_head_s-doc_date
      i_budat       = vlcactdata_head_s-pstng_date
      i_softcheck   = ' '
*     I_KOART       = '+'
*     I_HKONT       = '+'
    IMPORTING
      e_gjahr       = l_gjahr
      e_xrueb       = l_xrueb
      e_currj       = l_currj
    CHANGING
      c_monat       = l_monat
    EXCEPTIONS
      error_message = 1.
  IF sy-subrc <> 0.
    IF sy-msgty IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                INTO ls_msgtext
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ls_message-message = ls_msgtext.
      ls_message-type = sy-msgty.
      ls_message-id = sy-msgid.
      ls_message-number = sy-msgno.
      ls_message-message_v1 = sy-msgv1.
      ls_message-message_v2 = sy-msgv2.
      ls_message-message_v3 = sy-msgv3.
      ls_message-message_v4 = sy-msgv4.
      APPEND ls_message TO gt_return.
    ENDIF.

  ENDIF.
ENDFORM.                    "f_check_qinb_date
*&---------------------------------------------------------------------*
*&      Form  f_create_options
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_create_options.
  DATA:
    ls_coll_id TYPE lvc_s_col,
    ls_row_no  TYPE lvc_s_roid.


*  gv_ok_code = sy-ucomm.

  IF gv_ok_code NE gc_opclass AND gv_ok_code NE gc_load_okcode
    AND gv_ok_code NE gc_collapse_fcode AND gv_ok_code NE gc_expand_fcode AND gv_ok_code NE space.

    "Prepare DBM model-option alv
    PERFORM f_prepare_optionalv.

    "Display DBM model option alv :- only empty alv, becoz no model selected
    PERFORM f_display_optionalv.

    IF /dbe/v_imodel-mcodesd IS INITIAL.
      CLEAR : gt_opclass_values,gv_opclass.
    ENDIF.
    "Set Option Class values in drop down
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

    RETURN.
  ENDIF.

  "set the cursor position to button only, when button is pressed
  IF gv_ok_code EQ gc_load_okcode AND /dbe/v_imodel-mcodesd IS NOT INITIAL.
    IF gt_optionalv IS INITIAL.
      gv_cursor_on_field = 'BUT_OPTION'.
    ELSE.

      "Get the focus
      CALL METHOD go_alv_opt_grid->get_current_cell
        IMPORTING
          es_col_id = ls_coll_id
          es_row_no = ls_row_no.

      "Refresh the table content
      CALL METHOD go_alv_opt_grid->refresh_table_display.

      "Set the focus on the proper position
      CALL METHOD go_alv_opt_grid->set_current_cell_via_id
        EXPORTING
          is_column_id = ls_coll_id
          is_row_no    = ls_row_no.

      CALL METHOD go_alv_opt_grid->set_focus
        EXPORTING
          control = go_alv_opt_grid.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_create_options
*&---------------------------------------------------------------------*
*&      Form  f_change_vehicle_option
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_change_vehicle_option.
  DATA ls_optionalv TYPE /dbe/v_options. "ty_optionalv.
  DATA lv_fieldname(20) TYPE c.
  DATA lv_value1(20) TYPE c.

  GET CURSOR FIELD lv_fieldname  VALUE lv_value1.
  IF lv_fieldname EQ '/DBE/V_IMODEL-MCODESD'
    AND lv_value1 NE /dbe/v_imodel-mcodesd
    AND gv_ok_code NE gc_exec_fc AND gv_ok_code NE gc_load_okcode.
    CLEAR :gt_optionalv, gt_optionalv_all.
    CALL METHOD go_alv_opt_grid->refresh_table_display( ).

  ENDIF.

  IF gv_ok_code EQ gc_opclass.
    CASE gv_opclass.
      WHEN '*'.
        gt_optionalv = gt_optionalv_all.
      WHEN OTHERS.
        CLEAR gt_optionalv.
        LOOP AT gt_optionalv_all INTO ls_optionalv WHERE opclass EQ gv_opclass.
          APPEND ls_optionalv TO gt_optionalv.
        ENDLOOP.
    ENDCASE.
    CALL METHOD go_alv_opt_grid->refresh_table_display( ).
    gv_cursor_on_field = 'GV_OPCLASS'.
  ENDIF.

ENDFORM.                    "f_change_vehicle_option
*&---------------------------------------------------------------------*
*&      Form  f_set_create_action
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_set_create_action.
  CONSTANTS: lc_object   TYPE /dbe/ctrl_object VALUE '/DBE/V_VEH_CREA_BULK'.
  DATA     : lv_value   TYPE /dbe/ctrl_value,
             ls_bapiret TYPE bapiret2.

  CHECK sy-ucomm NE gc_error.
  IF gv_action IS INITIAL .
    gv_create_action  = 'X' .
*Get vehicle creation action if not specified
    CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
      EXPORTING
        object               = lc_object
      IMPORTING
        value                = lv_value
      EXCEPTIONS
        object_not_defined   = 1
        value_not_maintained = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      "INTO gv_dummy_msg.
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = sy-msgty
          cl     = sy-msgid
          number = sy-msgno
          par1   = sy-msgv1
        IMPORTING
          return = ls_bapiret.

      APPEND ls_bapiret TO gt_return.
      CLEAR: ls_bapiret.
    ELSE.
      gv_action = lv_value.
    ENDIF.
  ELSE.
    gv_create_action = 'X'.
  ENDIF.
ENDFORM.                    "f_set_create_action
*&---------------------------------------------------------------------*
*&      Form  f_transfer_new_vehicles
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_transfer_new_vehicles.
  DATA:
    lt_bob_details          TYPE /dbe/t_veh_bob,
    lv_no_in_char           TYPE string,
    lv_dummy_guid           TYPE /dbe/veh_guid,
    lv_number               TYPE i,
    lo_vehicle_buf          TYPE REF TO /dbe/cl_veh_buf,
*            lt_bob_details              TYPE /DBE/t_veh_bob,
    ls_bob_details          TYPE /dbe/s_veh_bob,
    ls_req_data             TYPE /dbe/req_vehicle_data,
    lv_vehicles             TYPE i,
    lo_cx_root              TYPE REF TO cx_root,
    lo_vlcactdata_head      TYPE REF TO vlcactdata_head_s,
    lo_vlcactdata_item      TYPE REF TO vlcactdata_item_s,
    ls_new_vehicle          TYPE /dbe/s_veh_bobnew,
    lt_new_vehicles         TYPE /dbe/t_veh_bobnew,
    lt_vehicles             TYPE /dbe/t_veh_bob,
    ls_vehicles             TYPE /dbe/s_veh_bob,
    ls_vlcactdata_head      TYPE vlcactdata_head_s,
    lr_iobj_single_com      TYPE REF TO /dbe/iobj_data_single_com_s,
    lr_iobj_multi_com       TYPE REF TO /dbe/iobj_data_multi_com_s,
    lo_dbm_veh              TYPE REF TO /dbe/cl_veh_dbmvehicle,
    lo_iobject              TYPE REF TO /dbe/cl_veh_iobject_vehicle,
    lv_category_id          TYPE /dbe/exts_category_id,
    lv_id(20)               TYPE c,
    lv_model_guid           TYPE /dbe/model_guid,
    ls_category_id_det_com  TYPE /dbe/v_category_id_det_com, "N:2066912
    ls_category_id_det_data TYPE /dbe/v_category_id_det_data,
    ls_t001w                TYPE t001w,
    ls_model                TYPE /dbe/v_model,
    ls_material             TYPE /dbe/v_mara.

  IF gv_ok_code EQ gc_exec_fc..
* Create an instance of the buffer...
    lo_vehicle_buf = /dbe/cl_veh_buf=>get_instance( ).

    TRY.
        CALL METHOD lo_vehicle_buf->get_all
          RECEIVING
            rt_bob = lt_bob_details.

        CALL METHOD lo_vehicle_buf->rem_bob
          EXPORTING
            it_bob = lt_bob_details.

    ENDTRY.

    lv_vehicles = vlcactdata_head_s-numofvehi.
    lv_number = 0.
    CLEAR: lt_new_vehicles,lt_vehicles,gt_bapireturn.
* Prepare buffer entries according to the number of vehilce entered
    DO lv_vehicles TIMES.
      lv_number = lv_number + 1.
      lv_no_in_char = lv_number.
      CONCATENATE  'DUMMY' lv_no_in_char INTO lv_dummy_guid.
      ls_new_vehicle-guid    = lv_dummy_guid.
      ls_new_vehicle-bobtype  = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
      INSERT ls_new_vehicle INTO TABLE lt_new_vehicles.
    ENDDO.

    TRY.
        CALL METHOD lo_vehicle_buf->new_bob
          EXPORTING
            it_bobnew = lt_new_vehicles
          IMPORTING
            et_bob    = lt_vehicles.

      CATCH /dbe/cx_veh_error_occured INTO lo_cx_root.

        CALL METHOD lo_vehicle_buf->get_messages
          EXPORTING
            io_cx_root    = lo_cx_root
          IMPORTING
            et_bapireturn = gt_bapireturn.
        RETURN.
    ENDTRY.

*   Read the plant's data to determine the country
    CALL FUNCTION 'T001W_SINGLE_READ'                       "N:2066912
      EXPORTING
        t001w_werks = vlcactdata_head_s-werks
      IMPORTING
        wt001w      = ls_t001w
      EXCEPTIONS
        not_found   = 0
        OTHERS      = 0.

*   Read model master
    CALL FUNCTION '/DBE/VM16_MODEL_DETAILS_GET'
      EXPORTING
        iv_model_guid   = /dbe/v_imodel-modguid
        iv_mcodesd      = /dbe/v_imodel-mcodesd
      IMPORTING
        e_model         = ls_model
        es_material     = ls_material
      EXCEPTIONS
        model_not_found = 0
        OTHERS          = 0.

*   Determine Vehicle Category
    ls_category_id_det_com-/dbe/spart = vlcactdata_head_s-spart.
    ls_category_id_det_com-vclass     = ls_model-vclass.
    ls_category_id_det_com-country    = ls_t001w-land1.

    CALL METHOD /dbe/cl_lc_access=>read
      EXPORTING
        i_usage = '/DBE/VEH_CATID'
        i_com   = ls_category_id_det_com
      IMPORTING
        e_data  = ls_category_id_det_data.

    lv_category_id = ls_category_id_det_data-category_id.

    IF lv_category_id IS INITIAL.
*     iObject category determaination failed
      gv_block_navigation = abap_true.
      CLEAR: gt_ok, gv_ok_code.
      sy-ucomm = gc_error.
      MESSAGE e045(/dbe/vehicle_master).
    ENDIF.

    LOOP AT lt_vehicles INTO ls_vehicles.
      lo_dbm_veh ?= ls_vehicles-bobref.
* Indicate that the guid is a DUMMY guid yet.
      lo_dbm_veh->set_dummy_guid( ls_vehicles-guid ).
      lo_dbm_veh->clear_dialogue_allowed( ).

* Set action
      TRY.
          CALL METHOD lo_dbm_veh->set_action
            EXPORTING
              iv_action     = gv_action
              iv_wo_prepare = abap_false.

        CATCH /dbe/cx_veh_static_check INTO lo_cx_root.
          CALL METHOD lo_vehicle_buf->get_messages
            EXPORTING
              io_cx_root    = lo_cx_root
            IMPORTING
              et_bapireturn = gt_bapireturn.
          RETURN.
      ENDTRY.

      TRY.
          lr_iobj_single_com ?= lo_dbm_veh->get_data_com( lo_dbm_veh->gc_iobj_data_single_com_s ).
          MOVE-CORRESPONDING /dbe/v_imodel TO lr_iobj_single_com->*-/dbe/v_imodel   .

          lr_iobj_multi_com ?= lo_dbm_veh->get_data_com( lo_dbm_veh->gc_iobj_data_multi_com_s ).

          PERFORM f_transfer_option_iobject CHANGING lr_iobj_multi_com.
*       vlcactdata head structure
          lo_vlcactdata_head ?= lo_dbm_veh->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_head_s ).
          ls_vlcactdata_head  = vlcactdata_head_s.

* Clear the number of vehicles on tab switch
          CLEAR vlcactdata_head_s-numofvehi .
          CLEAR ls_vlcactdata_head-numofvehi .
          lo_vlcactdata_head->* =  ls_vlcactdata_head.
*       vlcactdata item structure
          lo_vlcactdata_item ?= lo_dbm_veh->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_item_s ).

        CATCH  /dbe/cx_veh_layer_not_found INTO lo_cx_root.
          CALL METHOD lo_vehicle_buf->get_messages
            EXPORTING
              io_cx_root    = lo_cx_root
            IMPORTING
              et_bapireturn = gt_bapireturn.
          RETURN.
      ENDTRY.

      vlcactdata_item_s-vguid = ls_vehicles-guid.
      MOVE ls_vehicles-guid TO  lo_vlcactdata_item->*-vguid.
      lo_vlcactdata_item->*  = vlcactdata_item_s.

*   Set Category id
      TRY.
          lo_iobject ?= lo_dbm_veh->iobject_get( ).
          IF lo_iobject IS BOUND.
            lo_iobject->set_category_data( lv_category_id ).
          ENDIF.

        CATCH  /dbe/cx_veh_iobj_cat_guid_get.
          RETURN.
        CATCH /dbe/cx_veh_iobj_meta_category.
          RETURN.
      ENDTRY.

      CONCATENATE sy-uname sy-datum INTO lv_id.
      CLEAR lv_model_guid.
      EXPORT model_guid FROM lv_model_guid TO MEMORY ID lv_id.
      "Set this memory ID, to avoid default options to be considered in FM /DBE/VM10_SET_MODEL_MASTER
      change_flag = abap_true.
      EXPORT change_flag FROM change_flag TO MEMORY ID 'VEH_OPTION_CHANGE'.

* Set data in buffer
      TRY.
          lo_dbm_veh->/dbe/if_veh_bob~set_bob( ).

        CATCH cx_static_check
              cx_root INTO lo_cx_root.

          CALL METHOD lo_vehicle_buf->get_messages
            EXPORTING
              io_cx_root    = lo_cx_root
            IMPORTING
              et_bapireturn = gt_bapireturn.
          RETURN.
      ENDTRY.
    ENDLOOP.

  ENDIF.

ENDFORM.                    "f_transfer_new_vehicles
*&---------------------------------------------------------------------*
*&      Form  f_user_command_901
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_user_command_901.

  DATA lx_root        TYPE REF TO cx_root.
  DATA ls_bapireturn  LIKE LINE OF gt_bapireturn.
  DATA ls_vlcdiavehi  TYPE vlcdiavehi.
  DATA ls_vsresult    LIKE LINE OF gt_vsresult.
  DATA lr_vlcdiavehi  TYPE REF TO vlcdiavehi.
  DATA lo_veh_buf TYPE REF TO /dbe/cl_veh_buf.              "N:2304203
  DATA lo_vehicle     TYPE REF TO /dbe/cl_veh_dbmvehicle.
  DATA lt_bob         TYPE /dbe/t_veh_bob.
  DATA ls_bob         TYPE /dbe/s_veh_bob.

  CASE gv_ok_code .

    WHEN gc_exec_fc.
* get instance of the buffer...
      lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
* Trigger buffer save ,which in turn triggers action execution and mass save of vehicle class
      TRY.
          CALL METHOD lo_veh_buf->save( ).
        CATCH /dbe/cx_veh_error_occured INTO lx_root.
      ENDTRY.

      TRY.
          lo_veh_buf->get_messages( EXPORTING io_cx_root    = lx_root
                                    IMPORTING et_bapireturn = gt_bapireturn ).
      ENDTRY.

      READ TABLE gt_return INTO ls_bapireturn WITH KEY type = 'E' .
      IF  sy-subrc <> 0.
        COMMIT WORK AND WAIT.
        TRY.
            CALL METHOD lo_veh_buf->get_all
              RECEIVING
                rt_bob = lt_bob.
        ENDTRY.
* Get data from Work Layer to COM layer
        LOOP AT lt_bob INTO ls_bob.
          lo_vehicle ?= ls_bob-bobref.
          TRY.
              CALL METHOD lo_vehicle->/dbe/if_veh_bob~fill_com.
              lr_vlcdiavehi ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcdiavehi ).
              ls_vlcdiavehi = lr_vlcdiavehi->*.

              LOOP AT gt_vsresult INTO ls_vsresult WHERE vguid = ls_vlcdiavehi-vguid.
                ls_vsresult-stock_date  = ls_vlcdiavehi-/dbe/stock_date.
                ls_vsresult-stock_age   = ls_vlcdiavehi-/dbe/stock_age.
                ls_vsresult-report_date = ls_vlcdiavehi-/dbe/report_date.
                MODIFY gt_vsresult FROM ls_vsresult.
              ENDLOOP.
            CATCH /dbe/cx_veh_static_check .
          ENDTRY.
        ENDLOOP.
      ENDIF.
  ENDCASE.

  PERFORM refresh_grid_control.
ENDFORM.                    "f_user_command_901
*&---------------------------------------------------------------------*
*&      Form  f_transfer_data_0901
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_transfer_data_0901.
  DATA: lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,     "N:2304203
        lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
        lt_bob             TYPE /dbe/t_veh_bob,
        ls_bob             TYPE /dbe/s_veh_bob,
        lr_data            TYPE REF TO data,
        lr_item_data       TYPE REF TO data,
        lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
        lr_vlcactdata_item TYPE REF TO vlcactdata_item_s.

* Header data
  MOVE-CORRESPONDING vlcactdata_head_s TO gs_vlcactdata_head.
* Item data
  MOVE-CORRESPONDING vlcactdata_item_s TO gs_vlcactdata_item.

* Move screen IObject single structures to the buffer
  PERFORM iobj_single_move USING gc_1.
* Get Buffer instance
  lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
  TRY.
      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob.
  ENDTRY.

  LOOP AT lt_bob INTO ls_bob .
    lo_vehicle ?= ls_bob-bobref.
    TRY.
        lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_data IS BOUND.
      lr_vlcactdata_head ?= lr_data.
      IF gv_action = /dbe/if_vms_constants=>c_qgcb OR gv_action = /dbe/if_vms_constants=>c_qirb.
        MOVE vlcactdata_head_s-pstng_date TO  lr_vlcactdata_head->*-pstng_date.
        MOVE vlcactdata_head_s-revreason TO  lr_vlcactdata_head->*-revreason.
      ELSE.
        MOVE-CORRESPONDING vlcactdata_head_s TO  lr_vlcactdata_head->*.
      ENDIF.
      IF gv_action NE /dbe/if_vms_constants=>c_qinb.
        "Netprice should be blank at header level while creating invoice
        MOVE vlcactdata_item_s-netpr TO lr_vlcactdata_head->*-netpr.
*      ELSE.
*        CLEAR  lr_vlcactdata_head->*-netpr.
      ENDIF.
    ENDIF.
    TRY.
        lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_item_data IS BOUND.
      lr_vlcactdata_item ?= lr_item_data.
*       MOVE-CORRESPONDING vlcactdata_item_s TO  lr_vlcactdata_head->*.
*        APPEND lr_vlcactdata_item->* TO gt_vlcactdata_item.
    ENDIF.
* for PO of same delivery date
    IF has_same_delv_date EQ abap_true ."AND lr_vlcactdata_item->*-vguid  = gs_vlcactdata_item-vguid.
*      lr_vlcactdata_item->*-eindt_changed = gs_vlcactdata_item-eindt_changed.
      lr_vlcactdata_item->*-eindt_changed = vlcactdata_head_s-eindt.
      lr_vlcactdata_item->*-netpr = vlcactdata_item_s-netpr.
    ENDIF.

  ENDLOOP.

* Set data in Vehicle buffer
  TRY.
      CALL METHOD lo_veh_buf->set_all.
    CATCH /dbe/cx_veh_error_occured .
    CATCH cx_static_check.
  ENDTRY.

ENDFORM.                    "f_transfer_data_0901

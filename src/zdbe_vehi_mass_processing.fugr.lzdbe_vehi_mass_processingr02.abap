*&---------------------------------------------------------------------*
*& Include          /DBE/LVEHI_MASS_PROCESSINGR02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_TEXT_EDITOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_display_text_editor USING iv_cont_name.

  IF gv_ok_code <> 'RE_ALL' AND gv_ok_code <> 'RN_ALL' AND gv_ok_code <> 'ENTER'.
    IF gv_action = 'QRSB'.
      IF go_text_editor IS BOUND.
        CALL METHOD go_text_editor->delete_text( ).
      ENDIF.
************************************************************************
* Create Custom Container
************************************************************************
      IF go_text_editor IS NOT BOUND.

        CREATE OBJECT go_editor_container
          EXPORTING
            container_name              = iv_cont_name
          EXCEPTIONS
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

************************************************************************
* Create Text Editor
************************************************************************
        CREATE OBJECT go_text_editor
          EXPORTING
            parent                     = go_editor_container
            wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder
            wordwrap_to_linebreak_mode = cl_gui_textedit=>true.

************************************************************************
* Hide Toolbars
************************************************************************
        CALL METHOD go_text_editor->set_statusbar_mode
          EXPORTING
            statusbar_mode = 0.

        CALL METHOD go_text_editor->set_toolbar_mode
          EXPORTING
            toolbar_mode = 0.

      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  create_alv_grid_reserv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_create_alv_grid_reserv.
  DATA:
    lt_exclude TYPE ui_functions.

  CONSTANTS:
    lc_cc_name TYPE scrfname VALUE 'RESERV_ALV'.

  FIELD-SYMBOLS:
    <ls_fieldcatalog> TYPE lvc_s_fcat.

************************************************************************
* Initialize
************************************************************************

  "Dont execute when user press "Apply to All Button"
  IF gv_ok_code <> 'RE_ALL' AND gv_ok_code <> 'RN_ALL' AND gv_ok_code <> 'ENTER'.

    CLEAR:
      gt_fieldcatalog,
      gs_fieldcat,
      gs_layout.

    IF go_cc_reserv_crt IS NOT BOUND.
      CREATE OBJECT go_cc_reserv_crt
        EXPORTING
          container_name              = lc_cc_name
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5.
    ENDIF.

    IF go_reserv_alvgrid IS NOT BOUND.
      CREATE OBJECT go_reserv_alvgrid
        EXPORTING
          i_parent = go_cc_reserv_crt.
    ENDIF.

************************************************************************
* Prepare Field Catalog (Initiate List 1)
************************************************************************
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'    "#EC CI_SUBRC
      EXPORTING
        i_structure_name       = '/DBE/V_STR_RESERVATION'
      CHANGING
        ct_fieldcat            = gt_fieldcatalog[]
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    ASSERT sy-subrc = 0.

    LOOP AT gt_fieldcatalog[] ASSIGNING <ls_fieldcatalog>.
      <ls_fieldcatalog>-edit = abap_false.
    ENDLOOP.
    UNASSIGN <ls_fieldcatalog>.

************************************************************************
* Alter Field Catalog: layout, toolbar
************************************************************************
    CASE gv_action.
      WHEN 'QRSB'.
        gs_layout-grid_title = 'Create Vehicle Reservation'.

        LOOP AT gt_fieldcatalog ASSIGNING <ls_fieldcatalog>.
          CASE <ls_fieldcatalog>-fieldname.
            WHEN 'ENDDATE'
            OR  'ENDTIME'
            OR  'CUSTOMER'
            OR  'CONTACTPERSON'
            OR  'SALESPERSON'
            OR  'VBELN'
            OR  'POSNR'
            OR  'RSV_NOTE'.
              <ls_fieldcatalog>-edit = abap_true.
            WHEN 'VGUID'.
              <ls_fieldcatalog>-tech = abap_true.

          ENDCASE.
        ENDLOOP.

      WHEN 'QDSB'.
        gs_layout-grid_title = 'Cancel Vehicle Reservation'.
    ENDCASE.
    UNASSIGN <ls_fieldcatalog>.

    gs_layout-smalltitle = abap_true.
    gs_layout-cwidth_opt = abap_true.
    gs_layout-no_rowmark = abap_true.

************************************************************************
* Set Handlers
************************************************************************
    CALL METHOD go_reserv_alvgrid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD go_reserv_alvgrid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    IF g_alv_handler_reserv IS INITIAL.
      CREATE OBJECT g_alv_handler_reserv.
    ENDIF.

    SET HANDLER g_alv_handler_reserv->handle_data_changed
           FOR go_reserv_alvgrid.

************************************************************************
* Get ALV Data
************************************************************************
    PERFORM prepare_reserv_alv_data.

************************************************************************
*  Set ALV Data
************************************************************************
    PERFORM exclude_tb_functionss CHANGING lt_exclude[].
    CALL METHOD go_reserv_alvgrid->set_table_for_first_display
      EXPORTING
        i_default                     = abap_true
        is_layout                     = gs_layout
        it_toolbar_excluding          = lt_exclude[]
      CHANGING
        it_outtab                     = gt_reserv_info[]
        it_fieldcatalog               = gt_fieldcatalog[]
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

ENDFORM.

*&---------------------------------------------------------------------*
*& Form prepare_alv_data_0311
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_reserv_alv_data.
  TYPES:
    ltyp_reserv_rng    TYPE RANGE OF /dbe/v_reserv-vguid.

  DATA:
    ls_reserv_info     LIKE LINE OF gt_reserv_info, "tty_reserv_info,
    ls_vlcactdata_head TYPE  vlcactdata_head_s,
    ls_vlcactdata_item TYPE  vlcactdata_item_s,

    lt_bob_details     TYPE /dbe/t_veh_bob,
    ls_bob_details     TYPE /dbe/s_veh_bob,
    lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
    lr_iobj_single     TYPE REF TO /dbe/iobj_data_single_com_s,
    ls_iobj_single     TYPE  /dbe/iobj_data_single_com_s,
    lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
    lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,

    lt_reserv_rng      TYPE ltyp_reserv_rng,
    ls_reserv_rng      LIKE LINE OF lt_reserv_rng[],
    lt_reserv_db       TYPE STANDARD TABLE OF /dbe/v_reserv.

  FIELD-SYMBOLS:
    <ls_reserv_db> LIKE LINE OF lt_reserv_db[].

************************************************************************
* Get Data for ALV
************************************************************************
  IF gv_ok_code <> 'RE_ALL' AND gv_ok_code <> 'RN_ALL'.
    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).

    TRY.
        CALL METHOD lo_veh_buf->get_all
          RECEIVING
            rt_bob = lt_bob_details.
    ENDTRY.

    CLEAR: gt_reserv_info.

    CASE gv_action.
      WHEN 'QRSB'.
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
                lr_iobj_single ?=  lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
              CATCH /dbe/cx_veh_layer_not_found .
            ENDTRY.

            IF lr_iobj_single IS BOUND.
              MOVE-CORRESPONDING lr_iobj_single->* TO ls_iobj_single.
            ENDIF.

            MOVE-CORRESPONDING ls_vlcactdata_head TO ls_reserv_info.

            TRY.
                lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
              CATCH /dbe/cx_veh_layer_not_found.
            ENDTRY.
            ls_vlcactdata_item = lr_vlcactdata_item->*.

            ls_reserv_info-vguid     = ls_vlcactdata_item-vguid.
            ls_reserv_info-vhcle     = ls_vlcactdata_item-vhcle.
            ls_reserv_info-startdate = vlcactdata_item_s-resdatfrom.
            ls_reserv_info-starttime = vlcactdata_item_s-restimefrom.
            APPEND ls_reserv_info TO gt_reserv_info[].

          ENDIF.
        ENDLOOP.

      WHEN 'QDSB'.
        LOOP AT gt_vsresult_selection INTO gs_selection.
          ls_reserv_rng-sign   = 'I'.
          ls_reserv_rng-option = 'EQ'.
          ls_reserv_rng-low = gs_selection-vguid.
          APPEND ls_reserv_rng TO lt_reserv_rng[].
        ENDLOOP.

        SELECT
            *
          FROM /dbe/v_reserv
          INTO CORRESPONDING FIELDS OF TABLE lt_reserv_db[]
          WHERE
            vguid IN lt_reserv_rng[] AND
            rsv_sts = 1.
        IF sy-subrc <> 0.

        ENDIF.

        LOOP AT lt_reserv_db[] ASSIGNING <ls_reserv_db>.
          READ TABLE lt_bob_details INTO ls_bob_details WITH KEY guid = <ls_reserv_db>-vguid.
          IF sy-subrc = 0 .
            lo_vehicle ?= ls_bob_details-bobref.

            TRY.
                lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
              CATCH /dbe/cx_veh_layer_not_found.
            ENDTRY.
            ls_vlcactdata_item = lr_vlcactdata_item->*.

            CALL FUNCTION 'VELO03_CONVERT_FROM_TIMESTAMP'
              EXPORTING
                timestamp_iv = <ls_reserv_db>-tstmp_from
                tzone_iv     = sy-zonlo
              IMPORTING
                datlo_ev     = ls_reserv_info-startdate
                timlo_ev     = ls_reserv_info-starttime.

            CALL FUNCTION 'VELO03_CONVERT_FROM_TIMESTAMP'
              EXPORTING
                timestamp_iv = <ls_reserv_db>-tstmp_to
                tzone_iv     = sy-zonlo
              IMPORTING
                datlo_ev     = ls_reserv_info-enddate
                timlo_ev     = ls_reserv_info-endtime.

            ls_reserv_info-vguid         = <ls_reserv_db>-vguid.
            ls_reserv_info-vhcle         = ls_vlcactdata_item-vhcle.
            ls_reserv_info-customer      = <ls_reserv_db>-customer.
            ls_reserv_info-contactperson = <ls_reserv_db>-contactperson.
            ls_reserv_info-salesperson   = <ls_reserv_db>-salesperson.
            ls_reserv_info-vbeln         = <ls_reserv_db>-vbeln.
            ls_reserv_info-posnr         = <ls_reserv_db>-posnr.
            ls_reserv_info-rsv_note      =  <ls_reserv_db>-note.
            APPEND ls_reserv_info TO gt_reserv_info[].
          ENDIF.

        ENDLOOP.
        UNASSIGN <ls_reserv_db>.

    ENDCASE.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_fill_reserv_enddate
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_fill_common_reserv.
  DATA:
    lv_rsv_note TYPE string.

  FIELD-SYMBOLS:
    <ls_reserv_info> LIKE LINE OF gt_reserv_info[].

  CASE gv_ok_code.
    WHEN 'RE_ALL'.
      LOOP AT gt_reserv_info[] ASSIGNING <ls_reserv_info>.
        <ls_reserv_info>-enddate       = vlcactdata_item_s-resdatto.
        <ls_reserv_info>-endtime       = vlcactdata_item_s-restimeto.
        <ls_reserv_info>-customer      = vlcactdata_item_s-endcu.
        <ls_reserv_info>-vbeln         = vlcactdata_item_s-vbeln.
        <ls_reserv_info>-posnr         = vlcactdata_item_s-posnr.
        <ls_reserv_info>-salesperson   = vlcactdata_item_s-salesperson.
        <ls_reserv_info>-contactperson = vlcactdata_item_s-contactperson.
      ENDLOOP.
      UNASSIGN <ls_reserv_info>.
      CALL METHOD go_reserv_alvgrid->refresh_table_display.

    WHEN 'RN_ALL'.
      IF go_text_editor IS BOUND.
        go_text_editor->get_textstream( IMPORTING text = lv_rsv_note ).
        cl_gui_cfw=>flush( ).
      ENDIF.

      LOOP AT gt_reserv_info[] ASSIGNING <ls_reserv_info>.
        <ls_reserv_info>-rsv_note = lv_rsv_note.
      ENDLOOP.
      UNASSIGN <ls_reserv_info>.
      CALL METHOD go_reserv_alvgrid->refresh_table_display.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_transfer_reserv_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_transfer_reserv_data.
  DATA:
    lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
    lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
    ls_reserv_info     LIKE LINE OF gt_reserv_info,
    lr_item_data       TYPE REF TO data,
    lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
    lt_bob             TYPE /dbe/t_veh_bob,
    ls_bob             TYPE /dbe/s_veh_bob,
    lv_valid           TYPE c,
    lv_rsv_note        TYPE string.

  IF gv_ok_code = gc_exec_fc. "OR gv_ok_code = 'ENTER'.

    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    TRY.
        CALL METHOD lo_veh_buf->get_all
          RECEIVING
            rt_bob = lt_bob.
    ENDTRY.

    IF lt_bob IS NOT INITIAL.
      LOOP AT gt_reserv_info[] INTO ls_reserv_info.
        READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_reserv_info-vguid.
        IF sy-subrc = 0.
          lo_vehicle ?= ls_bob-bobref.
          TRY.
              lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.
          IF lr_item_data IS BOUND.
            lr_vlcactdata_item ?= lr_item_data.
          ENDIF.

          IF lr_vlcactdata_item->*-vguid = ls_bob-guid.
            lr_vlcactdata_item->*-resdatfrom    = ls_reserv_info-startdate.
            lr_vlcactdata_item->*-restimefrom   = ls_reserv_info-starttime.
            lr_vlcactdata_item->*-resdatto      = ls_reserv_info-enddate.
            lr_vlcactdata_item->*-restimeto     = ls_reserv_info-endtime.
            lr_vlcactdata_item->*-endcu         = ls_reserv_info-customer.
            lr_vlcactdata_item->*-note          = ls_reserv_info-rsv_note.
            lr_vlcactdata_item->*-contactperson = ls_reserv_info-contactperson.
            lr_vlcactdata_item->*-salesperson   = ls_reserv_info-salesperson.
            lr_vlcactdata_item->*-vbeln         = ls_reserv_info-vbeln.
            lr_vlcactdata_item->*-posnr         = ls_reserv_info-posnr.
            lr_vlcactdata_item->*-rsv_type      = 'Sales'. "Hardcoded 'Sales'
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDIF.

    TRY.
        CALL METHOD lo_veh_buf->set_all.
      CATCH /dbe/cx_veh_error_occured.
      CATCH cx_static_check.
    ENDTRY.

    CLEAR gt_reserv_info[].

  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_prepare_reserv_action_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OK_CODE
*&      --> GV_ACTION
*&---------------------------------------------------------------------*
FORM f_prepare_reserv_action_data USING iv_ok_code
                                        iv_action.

  DATA:
    lo_buf             TYPE REF TO /dbe/cl_veh_buf,
    lo_veh             TYPE REF TO /dbe/cl_veh_dbmvehicle,
    lt_bob             TYPE /dbe/t_veh_bob,
    ls_bob             TYPE /dbe/s_veh_bob,
    lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
    lt_guids           TYPE TABLE OF vlcguid,
    ls_guid            TYPE vlcguid,
    lv_wo_prepare      TYPE boole_d.

  CONSTANTS:
    lc_re_all(6) VALUE 'RE_ALL',
    lc_rn_all(6) VALUE 'RN_ALL'.

  "Don't execute when user press "Apply to All" Button
  IF gv_ok_code <> lc_re_all AND gv_ok_code <> lc_rn_all AND gv_ok_code <> 'ENTER'.

* get instance of the buffer...
    lo_buf = /dbe/cl_veh_buf=>get_instance( ).
* Read the buffer data
    TRY.
        CALL METHOD lo_buf->get_all
          RECEIVING
            rt_bob = lt_bob.
    ENDTRY.

    lv_wo_prepare = abap_false.

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

* Set data in Vehicle buffer
    IF lo_buf IS BOUND.
      TRY.
          CALL METHOD lo_buf->set_all.
        CATCH /dbe/cx_veh_error_occured .
        CATCH cx_static_check.
      ENDTRY.
    ENDIF.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form f_validate_entries
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_validate_entries.
  DATA:
    lv_valid          TYPE c,
    lv_msgv1          TYPE string,
    lv_msgv2          TYPE string,
    lv_partner        TYPE but000-partner,

    lv_resdatto_str   TYPE string,
    lv_resdatfrom_str TYPE string,
    lv_new_tstmp_from TYPE vlc_ltstamp,
    lv_new_tstmp_to   TYPE vlc_ltstamp,
    lt_relationships  TYPE STANDARD TABLE OF bapibus1006_relations.

  FIELD-SYMBOLS:
    <ls_reserv_info> LIKE LINE OF gt_reserv_info[].

  IF gv_ok_code = 'ENTER' OR gv_ok_code = 'RE_ALL'.

    IF vlcactdata_item_s-endcu IS INITIAL.
      MESSAGE e305(velo).
    ENDIF.

************************************************************************
* Validate dates
************************************************************************
    IF vlcactdata_item_s-resdatto IS NOT INITIAL.

      CONVERT DATE vlcactdata_item_s-resdatfrom
              TIME vlcactdata_item_s-restimefrom
              INTO TIME STAMP lv_new_tstmp_from TIME ZONE sy-zonlo.

      CONVERT DATE vlcactdata_item_s-resdatto
              TIME vlcactdata_item_s-restimeto
              INTO TIME STAMP lv_new_tstmp_to TIME ZONE sy-zonlo.

      IF lv_new_tstmp_from >= lv_new_tstmp_to.
        CONCATENATE vlcactdata_item_s-resdatfrom vlcactdata_item_s-restimefrom INTO lv_resdatfrom_str SEPARATED BY space.
        CONCATENATE vlcactdata_item_s-resdatto vlcactdata_item_s-restimeto INTO lv_resdatto_str SEPARATED BY space.
        MESSAGE e208(va) WITH lv_resdatfrom_str lv_resdatto_str 'reservation'.
      ENDIF.
    ENDIF.

************************************************************************
* Validate if customer and contact person is related
************************************************************************
    IF vlcactdata_item_s-contactperson IS NOT INITIAL.

      CALL FUNCTION 'BAPI_BUPA_RELATIONSHIPS_GET'
        EXPORTING
          businesspartner = vlcactdata_item_s-endcu
        TABLES
          relationships   = lt_relationships[].

      READ TABLE lt_relationships[] TRANSPORTING NO FIELDS WITH KEY partner2 = vlcactdata_item_s-contactperson.
      IF sy-subrc <> 0.
        "There is no relationship between partner &1 and partner &2
        MESSAGE e102(bur) WITH vlcactdata_item_s-endcu vlcactdata_item_s-contactperson.
      ENDIF.

    ENDIF.
  ENDIF.

  IF gv_ok_code = 'ACT_EXE'.

    IF go_reserv_alvgrid IS BOUND.
      CALL METHOD go_reserv_alvgrid->check_changed_data.
    ENDIF.

    LOOP AT gt_reserv_info[] ASSIGNING <ls_reserv_info>.
      CLEAR lv_msgv1.
      IF <ls_reserv_info>-enddate IS INITIAL.
        lv_msgv1 = `End Date for Vehicle ` && <ls_reserv_info>-vhcle.
        MESSAGE e001(/dbe/vehicle_master) WITH lv_msgv1.
      ENDIF.
      IF <ls_reserv_info>-endtime IS INITIAL.
        lv_msgv1 = `End Time for Vehicle ` && <ls_reserv_info>-vhcle.
        MESSAGE e001(/dbe/vehicle_master) WITH lv_msgv1.
      ENDIF.
      IF <ls_reserv_info>-customer IS INITIAL.
        lv_msgv1 = `Customer for Vehicle ` && <ls_reserv_info>-vhcle.
        MESSAGE e001(/dbe/vehicle_master) WITH lv_msgv1.
      ENDIF.
    ENDLOOP.
    UNASSIGN <ls_reserv_info>.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_user_command_0311.
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_user_command_0311.

  DATA:
    ls_bapireturn TYPE bapiret2,
    ls_vlcdiavehi TYPE vlcdiavehi,
    lx_root       TYPE REF TO cx_root,
    ls_vsresult   TYPE /dbe/vsresult,
    lo_veh_buf    TYPE REF TO /dbe/cl_veh_buf,
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



ENDFORM.

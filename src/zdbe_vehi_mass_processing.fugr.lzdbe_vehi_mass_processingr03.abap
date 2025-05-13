*&---------------------------------------------------------------------*
*& Include          /DBE/LVEHI_MASS_PROCESSINGR03
*&---------------------------------------------------------------------*
FORM f_prepare_campaign_action_data USING iv_ok_code
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
    lc_re_all(6) VALUE 'RE_ALL'.

  "Don't execute when user press "Apply to All" Button
  IF gv_ok_code <> lc_re_all AND gv_ok_code <> 'ENTER'.

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
*&      Form  create_alv_grid_campaign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_create_alv_grid_campaign.
  DATA:
    lt_exclude TYPE ui_functions,
    lt_celltab TYPE lvc_t_styl,
    ls_celltab LIKE LINE OF lt_celltab[].

  CONSTANTS:
    lc_cc_name TYPE scrfname VALUE 'CAMPAIGN_ALV'.

  FIELD-SYMBOLS:
    <ls_fieldcatalog>  TYPE lvc_s_fcat,
    <ls_campaign_info> LIKE LINE OF gt_campaign_info[].

************************************************************************
* Initialize
************************************************************************
  "Don't execute when user press "Apply to All Button"
  IF gv_ok_code <> 'RE_ALL' AND gv_ok_code <> 'ENTER'.

    CLEAR:
      gt_fieldcatalog,
      gs_fieldcat,
      gs_layout.

    IF go_cc_campaign_crt IS NOT BOUND.
      CREATE OBJECT go_cc_campaign_crt
        EXPORTING
          container_name              = lc_cc_name
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5.
    ENDIF.

    IF go_campaign_alvgrid IS NOT BOUND.
      CREATE OBJECT go_campaign_alvgrid
        EXPORTING
          i_parent = go_cc_campaign_crt.
    ENDIF.

************************************************************************
* Prepare Field Catalog (Initiate List 1)
************************************************************************
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'    "#EC CI_SUBRC
      EXPORTING
        i_structure_name       = '/DBE/V_STR_CAMPAIGN'
      CHANGING
        ct_fieldcat            = gt_fieldcatalog[]
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    ASSERT sy-subrc = 0.

************************************************************************
* Set Handlers
************************************************************************
    CALL METHOD go_campaign_alvgrid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD go_campaign_alvgrid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    IF g_alv_handler_campaign IS INITIAL.
      CREATE OBJECT g_alv_handler_campaign.
    ENDIF.

    SET HANDLER g_alv_handler_campaign->handle_data_changed
           FOR go_campaign_alvgrid.

************************************************************************
* Get ALV Data
************************************************************************
    PERFORM prepare_campaign_alv_data.

************************************************************************
* Alter Field Catalog: layout, toolbar
************************************************************************
    CASE gv_action.
      WHEN 'QCMB'.
        gs_layout-grid_title = 'Assign Sales Campaign'.
        gs_layout-no_rowmark = abap_true.

        LOOP AT gt_fieldcatalog ASSIGNING <ls_fieldcatalog>.
          CASE <ls_fieldcatalog>-fieldname.
            WHEN '/DBE/CMPGN_ID1'
            OR   '/DBE/CMPGN_ID2'
            OR   '/DBE/CMPGN_ID3'.
              <ls_fieldcatalog>-edit = abap_true.
              <ls_fieldcatalog>-checktable = 'VLCSCAMPGN'.
*            WHEN 'VGUID'.
*              <ls_fieldcatalog>-tech = abap_true.
          ENDCASE.
        ENDLOOP.
        UNASSIGN <ls_fieldcatalog>.

      WHEN 'QDCB'.
        gs_layout-grid_title = 'Unassign Sales Campaign'.
        gs_layout-sel_mode   = 'A'.
    ENDCASE.
    UNASSIGN <ls_fieldcatalog>.

    READ TABLE gt_fieldcatalog[] ASSIGNING <ls_fieldcatalog> WITH KEY fieldname = 'VGUID'.
    <ls_fieldcatalog>-tech = abap_true.
    UNASSIGN <ls_fieldcatalog>.

    gs_layout-smalltitle = abap_true.
    gs_layout-cwidth_opt = abap_true.

************************************************************************
* Disable ALV cells if they are not initial in DB - if user wants
* to update values he shall first use Unassign function then Assign again
************************************************************************
    LOOP AT gt_campaign_info[] ASSIGNING <ls_campaign_info>.
      CLEAR: lt_celltab[], ls_celltab.

      IF <ls_campaign_info>-/dbe/cmpgn_id1 IS NOT INITIAL.
        ls_celltab-fieldname = '/DBE/CMPGN_ID1'.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        INSERT ls_celltab INTO TABLE lt_celltab[].
      ENDIF.
      IF <ls_campaign_info>-/dbe/cmpgn_id2 IS NOT INITIAL.
        ls_celltab-fieldname = '/DBE/CMPGN_ID2'.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        INSERT ls_celltab INTO TABLE lt_celltab[].
      ENDIF.
      IF <ls_campaign_info>-/dbe/cmpgn_id3 IS NOT INITIAL.
        ls_celltab-fieldname = '/DBE/CMPGN_ID3'.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        INSERT ls_celltab INTO TABLE lt_celltab[].
      ENDIF.

      <ls_campaign_info>-celltab = lt_celltab[].
    ENDLOOP.
    UNASSIGN <ls_campaign_info>.

    gt_origin_campaign_info = gt_campaign_info[].

    gs_layout-stylefname = 'CELLTAB'.

************************************************************************
*  Set ALV Data
************************************************************************
    PERFORM exclude_tb_functionss CHANGING lt_exclude[].
    CALL METHOD go_campaign_alvgrid->set_table_for_first_display
      EXPORTING
        i_default                     = abap_true
        is_layout                     = gs_layout
        it_toolbar_excluding          = lt_exclude[]
      CHANGING
        it_outtab                     = gt_campaign_info[]
        it_fieldcatalog               = gt_fieldcatalog[]
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

ENDFORM.

*&---------------------------------------------------------------------*
*& Form prepare_campaign_alv_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_campaign_alv_data.
  TYPES:
    ltyp_campaign_rng    TYPE RANGE OF /dbe/v_str_campaign-vguid.

  DATA:
    ls_campaign_info   LIKE LINE OF gt_campaign_info,
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

    lt_campaign_rng    TYPE ltyp_campaign_rng,
    ls_campaign_rng    LIKE LINE OF lt_campaign_rng[],
    lt_campaign_db     TYPE STANDARD TABLE OF /dbe/v_str_campaign.

  FIELD-SYMBOLS:
    <ls_campaign_db> LIKE LINE OF lt_campaign_db[].

************************************************************************
* Get Data for ALV
************************************************************************
  IF gv_ok_code <> 'RE_ALL' AND gv_ok_code <> 'ENTER'.
    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).

    TRY.
        CALL METHOD lo_veh_buf->get_all
          RECEIVING
            rt_bob = lt_bob_details.
    ENDTRY.

    CLEAR: gt_campaign_info, vlcactdata_item_s, gs_cpmg_selection.

    LOOP AT gt_vsresult_selection INTO gs_selection.
      READ TABLE lt_bob_details INTO ls_bob_details WITH KEY guid = gs_selection-vguid.
      IF sy-subrc = 0 .
        lo_vehicle ?= ls_bob_details-bobref.

        TRY.
            lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
          CATCH /dbe/cx_veh_layer_not_found.
        ENDTRY.
        ls_vlcactdata_item = lr_vlcactdata_item->*.

        ls_campaign_info-vguid = ls_vlcactdata_item-vguid.
        ls_campaign_info-vhcle = ls_vlcactdata_item-vhcle.
        ls_campaign_info-/dbe/cmpgn_id1 = ls_vlcactdata_item-/dbe/cmpgn_id1.
        ls_campaign_info-/dbe/cmpgn_id2 = ls_vlcactdata_item-/dbe/cmpgn_id2.
        ls_campaign_info-/dbe/cmpgn_id3 = ls_vlcactdata_item-/dbe/cmpgn_id3.
        APPEND ls_campaign_info TO gt_campaign_info[].

      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_validate_entries_campaign
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM f_validate_entries_campaign.
  DATA:
    lt_vlcscampgnt TYPE STANDARD TABLE OF vlcscampgnt.

  FIELD-SYMBOLS:
    <ls_campaign_info> LIKE LINE OF gt_campaign_info[].

  IF gv_ok_code = 'ENTER' OR gv_ok_code = 'RE_ALL'.

************************************************************************
* Validate if uses didn't provide same Sales Campaign
************************************************************************
    IF vlcactdata_item_s-/dbe/cmpgn_id1 IS NOT INITIAL AND
       ( vlcactdata_item_s-/dbe/cmpgn_id1 = vlcactdata_item_s-/dbe/cmpgn_id2 OR
       vlcactdata_item_s-/dbe/cmpgn_id1 = vlcactdata_item_s-/dbe/cmpgn_id3 ).
      MESSAGE e899(/dbe/vsales) WITH 'Sales Campaign' vlcactdata_item_s-/dbe/cmpgn_id1 'is repeated'.
    ENDIF.

    IF vlcactdata_item_s-/dbe/cmpgn_id2 IS NOT INITIAL AND
      ( vlcactdata_item_s-/dbe/cmpgn_id2 = vlcactdata_item_s-/dbe/cmpgn_id1 OR
      vlcactdata_item_s-/dbe/cmpgn_id2 = vlcactdata_item_s-/dbe/cmpgn_id3 ).
      MESSAGE e899(/dbe/vsales) WITH 'Sales Campaign' vlcactdata_item_s-/dbe/cmpgn_id2 'is repeated'.
    ENDIF.

    IF vlcactdata_item_s-/dbe/cmpgn_id3 IS NOT INITIAL AND
      ( vlcactdata_item_s-/dbe/cmpgn_id3 = vlcactdata_item_s-/dbe/cmpgn_id1 OR
      vlcactdata_item_s-/dbe/cmpgn_id3 = vlcactdata_item_s-/dbe/cmpgn_id2 ).
      MESSAGE e899(/dbe/vsales) WITH 'Sales Campaign' vlcactdata_item_s-/dbe/cmpgn_id3 'is repeated'.
    ENDIF.

************************************************************************
* Validate if Sales Campaign even exists
************************************************************************
    SELECT * FROM vlcscampgnt INTO TABLE lt_vlcscampgnt[].

    IF vlcactdata_item_s-/dbe/cmpgn_id1 IS NOT INITIAL.
      READ TABLE lt_vlcscampgnt[] TRANSPORTING NO FIELDS WITH KEY cmpgn = vlcactdata_item_s-/dbe/cmpgn_id1.
      IF sy-subrc <> 0.
        MESSAGE e899(/dbe/vsales) WITH 'Sales Campaign' vlcactdata_item_s-/dbe/cmpgn_id1 'does not exist'.
      ENDIF.
    ENDIF.

    IF vlcactdata_item_s-/dbe/cmpgn_id2 IS NOT INITIAL.
      READ TABLE lt_vlcscampgnt[] TRANSPORTING NO FIELDS WITH KEY cmpgn = vlcactdata_item_s-/dbe/cmpgn_id2.
      IF sy-subrc <> 0.
        MESSAGE e899(/dbe/vsales) WITH 'Sales Campaign' vlcactdata_item_s-/dbe/cmpgn_id2 'does not exist'.
      ENDIF.
    ENDIF.

    IF vlcactdata_item_s-/dbe/cmpgn_id3 IS NOT INITIAL.
      READ TABLE lt_vlcscampgnt[] TRANSPORTING NO FIELDS WITH KEY cmpgn = vlcactdata_item_s-/dbe/cmpgn_id3.
      IF sy-subrc <> 0.
        MESSAGE e899(/dbe/vsales) WITH 'Sales Campaign' vlcactdata_item_s-/dbe/cmpgn_id3 'does not exist'.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_fill_common_campaign
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM f_fill_common_campaign.
  DATA:
    lt_index_rows TYPE lvc_t_row,
    ls_index_rows LIKE LINE OF lt_index_rows[],
    lv_lines      TYPE i,
    lv_index      TYPE i VALUE 0.

  FIELD-SYMBOLS:
    <ls_campaign_info>        LIKE LINE OF gt_campaign_info[],
    <ls_origin_campaign_info> LIKE LINE OF gt_origin_campaign_info[].

  IF gv_ok_code = 'RE_ALL'.
    CASE gv_action.
      WHEN 'QCMB'.
************************************************************************
* Validate if there is at least one field value provided
************************************************************************
        IF vlcactdata_item_s-/dbe/cmpgn_id1 IS INITIAL AND
           vlcactdata_item_s-/dbe/cmpgn_id2 IS INITIAL AND
           vlcactdata_item_s-/dbe/cmpgn_id3 IS INITIAL.
          MESSAGE e899(/dbe/vsales) WITH 'Provide at least one Sales Campaign value'.
        ENDIF.

************************************************************************
* Apply values to all rows (if possible)
************************************************************************
        gt_campaign_info[] = gt_origin_campaign_info[].

        LOOP AT gt_campaign_info[] ASSIGNING <ls_campaign_info>.

          READ TABLE gt_origin_campaign_info[] ASSIGNING <ls_origin_campaign_info> WITH KEY vguid = <ls_campaign_info>-vguid.
          IF <ls_origin_campaign_info>-/dbe/cmpgn_id1 IS INITIAL.
            IF vlcactdata_item_s-/dbe/cmpgn_id1 <> <ls_campaign_info>-/dbe/cmpgn_id2 AND
               vlcactdata_item_s-/dbe/cmpgn_id1 <> <ls_campaign_info>-/dbe/cmpgn_id3.

              <ls_campaign_info>-/dbe/cmpgn_id1 = vlcactdata_item_s-/dbe/cmpgn_id1.
            ENDIF.
          ENDIF.
          UNASSIGN <ls_origin_campaign_info>.

          READ TABLE gt_origin_campaign_info[] ASSIGNING <ls_origin_campaign_info> WITH KEY vguid = <ls_campaign_info>-vguid.
          IF <ls_origin_campaign_info>-/dbe/cmpgn_id2 IS INITIAL.
            IF vlcactdata_item_s-/dbe/cmpgn_id2 <> <ls_campaign_info>-/dbe/cmpgn_id1 AND
               vlcactdata_item_s-/dbe/cmpgn_id2 <> <ls_campaign_info>-/dbe/cmpgn_id3.

              <ls_campaign_info>-/dbe/cmpgn_id2 = vlcactdata_item_s-/dbe/cmpgn_id2.
            ENDIF.
          ENDIF.
          UNASSIGN <ls_origin_campaign_info>.

          READ TABLE gt_origin_campaign_info[] ASSIGNING <ls_origin_campaign_info> WITH KEY vguid = <ls_campaign_info>-vguid.
          IF <ls_origin_campaign_info>-/dbe/cmpgn_id3 IS INITIAL.
            IF vlcactdata_item_s-/dbe/cmpgn_id3 <> <ls_campaign_info>-/dbe/cmpgn_id1 AND
               vlcactdata_item_s-/dbe/cmpgn_id3 <> <ls_campaign_info>-/dbe/cmpgn_id2.

              <ls_campaign_info>-/dbe/cmpgn_id3 = vlcactdata_item_s-/dbe/cmpgn_id3.
            ENDIF.
          ENDIF.
          UNASSIGN <ls_origin_campaign_info>.

        ENDLOOP.
        UNASSIGN <ls_campaign_info>.

        CALL METHOD go_campaign_alvgrid->refresh_table_display.

      WHEN 'QDCB'.
        IF gs_cpmg_selection-/dbe/cmpgn_id1 = abap_true OR
           gs_cpmg_selection-/dbe/cmpgn_id2 = abap_true OR
           gs_cpmg_selection-/dbe/cmpgn_id3 = abap_true.

************************************************************************
* Set all lines as selected
************************************************************************
          DESCRIBE TABLE gt_campaign_info[] LINES lv_lines.
          DO lv_lines TIMES.
            CLEAR ls_index_rows.
            ADD 1 TO lv_index.
            ls_index_rows-index = lv_index.
            INSERT ls_index_rows INTO TABLE lt_index_rows[].
          ENDDO.

          go_campaign_alvgrid->set_selected_rows(
           EXPORTING
              it_index_rows = lt_index_rows[] ).

        ELSE.
          MESSAGE e899(/dbe/vsales) WITH 'Check at least one Sales Campaign'.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form f_transfer_campaign_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_transfer_campaign_data.
  TYPES:
    BEGIN OF ltyp_selected_rows_key,
      vguid          TYPE vlcvehicle-vguid,
      vhcle          TYPE vlcvehicle-vhcle,
      /dbe/cmpgn_id1 TYPE vlcvehicle-/dbe/cmpgn_id1,
      /dbe/cmpgn_id2 TYPE vlcvehicle-/dbe/cmpgn_id2,
      /dbe/cmpgn_id3 TYPE vlcvehicle-/dbe/cmpgn_id3,
    END OF ltyp_selected_rows_key.

  DATA:
    lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
    lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
    ls_campaign_info   LIKE LINE OF gt_campaign_info,
    lr_vlcdiavehi      TYPE REF TO vlcdiavehi,
    lr_data            TYPE REF TO data,
    lr_item_data       TYPE REF TO data,
    lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
    lt_bob             TYPE /dbe/t_veh_bob,
    ls_bob             TYPE /dbe/s_veh_bob,
    ls_vlcactdata_head TYPE vlcactdata_head_s,

    lt_index_rows      TYPE lvc_t_row,
    lt_selected_rows   TYPE SORTED TABLE OF ltyp_selected_rows_key WITH UNIQUE KEY vguid.

  FIELD-SYMBOLS:
    <ls_index_rows>    LIKE LINE OF lt_index_rows,
    <ls_selected_rows> LIKE LINE OF lt_selected_rows,
    <ls_campaign_info> LIKE LINE OF gt_campaign_info.


  IF gv_ok_code = gc_exec_fc.

    IF go_campaign_alvgrid IS BOUND.
      CALL METHOD go_campaign_alvgrid->check_changed_data.
    ENDIF.

    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    TRY.
        CALL METHOD lo_veh_buf->get_all
          RECEIVING
            rt_bob = lt_bob.
    ENDTRY.

    CASE gv_action.
      WHEN 'QCMB'.
************************************************************************
* Process data
************************************************************************
        LOOP AT gt_campaign_info[] ASSIGNING <ls_campaign_info>.
          READ TABLE lt_bob INTO ls_bob WITH KEY guid = <ls_campaign_info>-vguid.
          IF sy-subrc = 0.
            lo_vehicle ?= ls_bob-bobref.

            TRY.
                lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcdiavehi ).
              CATCH /dbe/cx_veh_layer_not_found .
            ENDTRY.
            IF lr_data IS BOUND.
              lr_vlcdiavehi ?= lr_data.
            ENDIF.

            TRY.
                lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
              CATCH /dbe/cx_veh_layer_not_found .
            ENDTRY.
            IF lr_data IS BOUND.
              lr_vlcactdata_head ?= lr_data.
            ENDIF.

            TRY.
                lr_item_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
              CATCH /dbe/cx_veh_layer_not_found .
            ENDTRY.
            TRY.
                lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
              CATCH /dbe/cx_veh_layer_not_found .
            ENDTRY.
            IF lr_item_data IS BOUND.
              lr_vlcactdata_item ?= lr_item_data.
            ENDIF.

            IF lr_vlcactdata_item->*-vguid = ls_bob-guid.
              IF lr_vlcactdata_item->*-/dbe/cmpgn_id1 IS INITIAL AND
                 <ls_campaign_info>-/dbe/cmpgn_id1 IS NOT INITIAL.
                lr_vlcactdata_item->*-/dbe/cmpgn_id1 = <ls_campaign_info>-/dbe/cmpgn_id1.
              ENDIF.

              IF lr_vlcactdata_item->*-/dbe/cmpgn_id2 IS INITIAL AND
                 <ls_campaign_info>-/dbe/cmpgn_id2 IS NOT INITIAL.
                lr_vlcactdata_item->*-/dbe/cmpgn_id2 = <ls_campaign_info>-/dbe/cmpgn_id2.
              ENDIF.

              IF lr_vlcactdata_item->*-/dbe/cmpgn_id3 IS INITIAL AND
                 <ls_campaign_info>-/dbe/cmpgn_id3 IS NOT INITIAL.
                lr_vlcactdata_item->*-/dbe/cmpgn_id3 = <ls_campaign_info>-/dbe/cmpgn_id3.
              ENDIF.
            ENDIF.
          ENDIF.

        ENDLOOP.
        UNASSIGN <ls_campaign_info>.

      WHEN 'QDCB'.
************************************************************************
* Get selected rows and then unique keys
************************************************************************
        go_campaign_alvgrid->get_selected_rows(
         IMPORTING
            et_index_rows = lt_index_rows[] ).

        IF lt_index_rows[] IS INITIAL.
          MESSAGE e899(/dbe/vsales) WITH 'No rows selected'.
        ENDIF.

        LOOP AT lt_index_rows[] ASSIGNING <ls_index_rows>.
          READ TABLE gt_campaign_info[] ASSIGNING <ls_campaign_info> INDEX <ls_index_rows>-index.
          IF sy-subrc <> 0.
            "Should not happen
            CONTINUE.
          ENDIF.

          INSERT VALUE #(
            vguid = <ls_campaign_info>-vguid
            vhcle = <ls_campaign_info>-vhcle
            /dbe/cmpgn_id1 = <ls_campaign_info>-/dbe/cmpgn_id1
            /dbe/cmpgn_id2 = <ls_campaign_info>-/dbe/cmpgn_id2
            /dbe/cmpgn_id3 = <ls_campaign_info>-/dbe/cmpgn_id3 ) INTO TABLE lt_selected_rows[].
          ASSERT sy-subrc = 0.

        ENDLOOP.
        UNASSIGN <ls_index_rows>.

************************************************************************
* Process data
************************************************************************
        LOOP AT lt_selected_rows ASSIGNING <ls_selected_rows>.
          READ TABLE lt_bob INTO ls_bob WITH KEY guid = <ls_selected_rows>-vguid.
          IF sy-subrc = 0.
            lo_vehicle ?= ls_bob-bobref.

            TRY.
                lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcdiavehi ).
              CATCH /dbe/cx_veh_layer_not_found .
            ENDTRY.
            IF lr_data IS BOUND.
              lr_vlcdiavehi ?= lr_data.
            ENDIF.

            TRY.
                lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
              CATCH /dbe/cx_veh_layer_not_found .
            ENDTRY.
            IF lr_data IS BOUND.
              lr_vlcactdata_head ?= lr_data.
            ENDIF.

            TRY.
                lr_item_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
              CATCH /dbe/cx_veh_layer_not_found .
            ENDTRY.
            TRY.
                lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
              CATCH /dbe/cx_veh_layer_not_found .
            ENDTRY.
            IF lr_item_data IS BOUND.
              lr_vlcactdata_item ?= lr_item_data.
            ENDIF.

            IF lr_vlcactdata_item->*-vguid = ls_bob-guid.
              IF lr_vlcactdata_item->*-/dbe/cmpgn_id1 IS INITIAL AND
                 <ls_selected_rows>-/dbe/cmpgn_id1 IS NOT INITIAL.
                lr_vlcactdata_item->*-/dbe/cmpgn_id1 = <ls_selected_rows>-/dbe/cmpgn_id1.
              ENDIF.

              IF lr_vlcactdata_item->*-/dbe/cmpgn_id2 IS INITIAL AND
                 <ls_selected_rows>-/dbe/cmpgn_id2 IS NOT INITIAL.
                lr_vlcactdata_item->*-/dbe/cmpgn_id2 = <ls_selected_rows>-/dbe/cmpgn_id2.
              ENDIF.

              IF lr_vlcactdata_item->*-/dbe/cmpgn_id3 IS INITIAL AND
                 <ls_selected_rows>-/dbe/cmpgn_id3 IS NOT INITIAL.
                lr_vlcactdata_item->*-/dbe/cmpgn_id3 = <ls_selected_rows>-/dbe/cmpgn_id3.
              ENDIF.

              IF gs_cpmg_selection-/dbe/cmpgn_id1 = abap_true AND
                 lr_vlcactdata_item->*-/dbe/cmpgn_id1 IS NOT INITIAL.
                CLEAR lr_vlcactdata_item->*-/dbe/cmpgn_id1.
              ENDIF.
              IF gs_cpmg_selection-/dbe/cmpgn_id2 = abap_true AND
                 lr_vlcactdata_item->*-/dbe/cmpgn_id2 IS NOT INITIAL.
                CLEAR lr_vlcactdata_item->*-/dbe/cmpgn_id2.
              ENDIF.
              IF gs_cpmg_selection-/dbe/cmpgn_id3 = abap_true AND
                 lr_vlcactdata_item->*-/dbe/cmpgn_id3 IS NOT INITIAL.
                CLEAR lr_vlcactdata_item->*-/dbe/cmpgn_id3.
              ENDIF.

            ENDIF.
          ENDIF.

        ENDLOOP.
        UNASSIGN <ls_selected_rows>.

    ENDCASE.

* Set data in Vehicle buffer - moves data from COM to WRK layer
    TRY.
        CALL METHOD lo_veh_buf->set_all.
      CATCH /dbe/cx_veh_error_occured.
      CATCH cx_static_check.
    ENDTRY.

    CLEAR gt_campaign_info[].

  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_user_command_0321.
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_user_command_0321.

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

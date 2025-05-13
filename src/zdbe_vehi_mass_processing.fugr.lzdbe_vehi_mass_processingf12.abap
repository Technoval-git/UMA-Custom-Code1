*----------------------------------------------------------------------*
***INCLUDE /DBE/LVM06F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  create_grid_control
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_grid_control .

  DATA:  ls_variant      TYPE disvariant.
  DATA:  lv_save_variant TYPE char1.
  DATA:  ls_layout       TYPE lvc_s_layo.
  DATA:  lv_action_title_string LIKE ls_layout-grid_title.
  DATA:  lv_action_number(7) TYPE c.
  DATA:  ls_coll_id          TYPE lvc_s_col.
  DATA:  ls_row_no           TYPE lvc_s_roid.
*  DATA:  ls_exclude          TYPE ui_func.
  DATA:  lt_exclude          TYPE ui_functions.
*  DATA:  gs_layout           TYPE disvariant.

  FIELD-SYMBOLS: <fieldcatalog> TYPE lvc_s_fcat,
                 <fs_vsresult>  TYPE /DBE/vsresult.
  DATA lo_bcvp_mask        TYPE REF TO /DBE/cl_bcvp_block_and_mask.

* prepare title with nr of found vehicles
  DESCRIBE TABLE gt_vsresult LINES lv_action_number.
  CONDENSE lv_action_number.

* Mask blocked data
  lo_bcvp_mask = /DBE/cl_bcvp_block_and_mask=>get_instance( ).
  LOOP AT gt_vsresult ASSIGNING <fs_vsresult>.
    lo_bcvp_mask->mask_veh_search( CHANGING cs_vsresult = <fs_vsresult> ).
  ENDLOOP.

  IF gv_action_for_alv = /DBE/if_vms_constants=>c_qcrb.
    IF lv_action_number = '0'.
      MESSAGE i471(/DBE/vehicle_master) WITH text-610 INTO lv_action_title_string.
    ELSEIF lv_action_number = '1'.
      MESSAGE i471(/DBE/vehicle_master) WITH lv_action_number INTO lv_action_title_string.
    ELSE.
      MESSAGE i473(/DBE/vehicle_master) WITH lv_action_number INTO lv_action_title_string.
    ENDIF.
    CONDENSE lv_action_title_string.
    CLEAR gv_action_for_alv.
  ELSE.
    IF lv_action_number = '0'.
      MESSAGE i472(/DBE/vehicle_master) WITH text-610 INTO lv_action_title_string.
    ELSEIF lv_action_number = '1'.
      MESSAGE i472(/DBE/vehicle_master) WITH lv_action_number INTO lv_action_title_string.
    ELSE.
      MESSAGE i474(/DBE/vehicle_master) WITH lv_action_number INTO lv_action_title_string.
    ENDIF.
    CONDENSE lv_action_title_string.
    CLEAR gv_action_for_alv.
  ENDIF.
  CLEAR gv_action_for_alv.


  IF g_custom_container IS NOT BOUND.
* create container object
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = gc_container_name.
  ENDIF.

  IF g_alv_grid IS NOT BOUND AND  g_custom_container IS BOUND.
* create grid object
    CREATE OBJECT g_alv_grid
      EXPORTING
        i_parent      = g_custom_container
        i_appl_events = ' '.
  ENDIF.

  IF g_alv_grid IS BOUND.
*create the fieldcatalogue
    CALL FUNCTION 'VELO03_FIELDCATALOG_MERGE'
      EXPORTING
        structure_name_iv       = gv_tabname
        client_never_display_iv = 'X'
      CHANGING
        fieldcat_ct             = gt_alv_fieldcat
      EXCEPTIONS
        error_occured           = 1
        OTHERS                  = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


*--> modify the fieldcatalog -> the column-headings
    CALL FUNCTION 'VELO02_MODI_ALV_FIELDCAT_COLN'
      TABLES
        alvfieldcat_ct = gt_alv_fieldcat
      EXCEPTIONS
        error_occured  = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT gt_alv_fieldcat ASSIGNING <fieldcatalog>.
      IF <fieldcatalog>-fieldname = '/DBE/SELECTED'.
        <fieldcatalog>-tech = abap_true.
      ENDIF.
      IF <fieldcatalog>-fieldname = 'VHCLE'.
        <fieldcatalog>-outputlen = 50.
      ENDIF.
      IF <fieldcatalog>-fieldname = 'VHCEX'.
        <fieldcatalog>-outputlen = 40.
      ENDIF.
      IF <fieldcatalog>-fieldname = 'RCLSTAT_DESC'.
        <fieldcatalog>-coltext = text-717.
        <fieldcatalog>-outputlen = 20.
      ENDIF.
      IF <fieldcatalog>-fieldname = 'AUDAT_LS'.
        <fieldcatalog>-coltext = text-716.
      ENDIF.
    ENDLOOP.

    CALL METHOD g_alv_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
* prepare variant
    ls_variant-report = sy-repid.
    ls_variant-handle = gc_main_subscreen_dynpro.
* the user may save all types of variants
    lv_save_variant = gc_alv_var_save.

* sort vehicle list by vhcle
    SORT gt_vlcdisplalv BY vhcle.
    "set field name to store row selection
    ls_layout-zebra       = 'X'.
    ls_layout-cwidth_opt  = 'X'.
*   Setting selection mode to C is only necessary if we want to allow multiple selection
    ls_layout-sel_mode = 'A'.
*--> define the alv-layout and hand it over
    ls_layout-grid_title = lv_action_title_string.

* display the grid
    PERFORM exclude_tb_functions CHANGING lt_exclude.

    IF badi_result_alv IS BOUND.
      CALL BADI badi_result_alv->change_result_data
        CHANGING
          ct_vsresult = gt_vsresult
          ct_fieldcat = gt_alv_fieldcat.
    ENDIF.

    CALL METHOD g_alv_grid->set_table_for_first_display
      EXPORTING
        i_structure_name              = gv_tabname
        is_variant                    = ls_variant
        i_save                        = lv_save_variant
        i_default                     = 'X'
        is_layout                     = ls_layout
        it_toolbar_excluding          = lt_exclude
      CHANGING
        it_outtab                     = gt_vsresult
        it_fieldcatalog               = gt_alv_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3.

*create the event handler for verifying the input data.
    CREATE OBJECT g_alv_handler.

* register double click handler
    SET HANDLER g_alv_handler->double_click
                g_alv_handler->hotspot_click
                g_alv_handler->handle_toolbar
                g_alv_handler->handle_menu_button
                g_alv_handler->handle_before_user_command
                g_alv_handler->handle_user_command
                g_alv_handler->handle_data_changed
                  FOR g_alv_grid.
    CALL METHOD g_alv_grid->set_toolbar_interactive.
*Get the focus
    CALL METHOD g_alv_grid->get_current_cell
      IMPORTING
        es_col_id = ls_coll_id
        es_row_no = ls_row_no.
*Set the new title with vehicle count
    CALL METHOD g_alv_grid->set_gridtitle
      EXPORTING
        i_gridtitle = lv_action_title_string.
*Set the focus on the proper position
    CALL METHOD g_alv_grid->set_current_cell_via_id
      EXPORTING
        is_column_id = ls_coll_id
        is_row_no    = ls_row_no.
  ENDIF.

  CALL METHOD g_alv_grid->refresh_table_display
*    EXPORTING
*      IS_STABLE      =
*      I_SOFT_REFRESH =
*    EXCEPTIONS
*      FINISHED       = 1
*      others         = 2
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "create_grid_control1
*&---------------------------------------------------------------------*
*&      Form  exclude_tb_functions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_EXCLUDE text
*----------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.
* Only allow to change data not to create new entries (exclude
* generic functions).
  DATA ls_exclude TYPE ui_func.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_separator.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_mb_export.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_mb_sum.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_select_all.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_deselect_all.
  APPEND ls_exclude TO pt_exclude.
ENDFORM. " EXCLUDE_TB_FUNCTIONS.
" EXCLUDE_TB_FUNCTIONS.

" create_grid_control

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF42 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_STATUS_1210
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_status_1210 .

  TYPE-POOLS: icon.

  DATA: lt_exclude TYPE ui_functions,
        ls_exclude TYPE ui_func,
        ls_fcat    TYPE lvc_s_fcat,
        lt_fcat    TYPE lvc_t_fcat,
        lv_tabix   TYPE sy-tabix.

  DATA: ls_coll_id        TYPE lvc_s_col.
  DATA: ls_row_no         TYPE lvc_s_roid.

  SET PF-STATUS 'STATUS1210'.

  IF go_selvar_container IS INITIAL.
    CREATE OBJECT go_selvar_container
      EXPORTING
        container_name = g_container.
    CREATE OBJECT grid
      EXPORTING
        i_parent      = go_selvar_container
        i_appl_events = 'X'.
    ls_exclude = cl_gui_alv_grid=>mc_mb_sum.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_mb_export.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_mb_filter.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_mb_subtot.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_mb_variant.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_mb_view.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_mb_paste.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_print.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_info.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_find.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_find_more.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_check.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
    APPEND ls_exclude TO lt_exclude.

    CREATE OBJECT event_receiver.
    SET HANDLER event_receiver->handle_user_command FOR grid.
    SET HANDLER event_receiver->handle_toolbar FOR grid.
    SET HANDLER event_receiver->handle_hotspot_click FOR grid.
    SET HANDLER event_receiver->handle_data_changed FOR grid.


    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
*       I_BUFFER_ACTIVE        =
        i_structure_name       = '/DBE/ALV_VAR'
        i_client_never_display = 'X'
*       I_BYPASSING_BUFFER     =
*       I_INTERNAL_TABNAME     =
      CHANGING
        ct_fieldcat            = lt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_fcat INTO ls_fcat.
      IF ls_fcat-fieldname = 'DEF_FLAG'.
        ls_fcat-hotspot  = 'X'.
        ls_fcat-outputlen = 7.
        ls_fcat-just = 'C'.
      ELSEIF ls_fcat-fieldname = 'ORIG'.
        ls_fcat-tech = 'X'.
      ELSE.
        ls_fcat-edit = 'X'.
      ENDIF.
      MODIFY lt_fcat FROM ls_fcat.
    ENDLOOP.

    CALL METHOD grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

    CALL METHOD grid->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding = lt_exclude
      CHANGING
        it_fieldcatalog      = lt_fcat
        it_outtab            = gt_mass_alv_var.

  ELSE.
    CALL METHOD grid->refresh_table_display.
    READ TABLE gt_mass_alv_var WITH KEY orig = space TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      lv_tabix = sy-tabix.
      CALL METHOD grid->get_current_cell
        IMPORTING
          es_col_id = ls_coll_id
          es_row_no = ls_row_no.

      ls_row_no-row_id = lv_tabix.

      CALL METHOD grid->set_current_cell_via_id
        EXPORTING
          is_column_id = ls_coll_id
          is_row_no    = ls_row_no.

      CALL METHOD grid->set_focus
        EXPORTING
          control = grid.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_STATUS_1210

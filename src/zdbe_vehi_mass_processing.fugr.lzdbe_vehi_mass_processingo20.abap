*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO20 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      MODULE  GENERATE_ALV_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE generate_alv_grid INPUT.

*  DATA : cc_po_crt         TYPE REF TO cl_gui_custom_container,
*         cc_po             TYPE scrfname VALUE 'BCALVC_CREATE_PO_DIFF_DATE',
**        po_items_alvgrid  TYPE REF TO cl_gui_alv_grid.
*         lt_exclude TYPE ui_functions.
*  CLEAR : gt_fieldcatalog , gs_fieldcat, gs_layout.
*
*  IF cc_po_crt IS NOT BOUND.
**    IF has_diff_delv_date EQ abap_true OR gv_enable_alv EQ abap_true.
** CREATE A CUSTOM CONTAINER CONTROL FOR OUR ALV CONTROL
*    CREATE OBJECT cc_po_crt
*      EXPORTING
*        container_name              = cc_po
*      EXCEPTIONS
*        cntl_error                  = 1
*        cntl_system_error           = 2
*        create_error                = 3
*        lifetime_error              = 4
*        lifetime_dynpro_dynpro_link = 5.
*    IF sy-subrc NE 0.
** ADD YOUR HANDLING, FOR EXAMPLE
*      CALL FUNCTION 'POPUP_TO_INFORM'
*        EXPORTING
*          titel = sy-repid
*          txt2  = sy-subrc
*          txt1  = 'THE CONTROL COULD NOT BE CREATED'(510).
*    ENDIF.
*  ENDIF.
*  IF po_items_alvgrid IS NOT BOUND.
** CREATE AN INSTANCE OF ALV CONTROL
*    CREATE OBJECT po_items_alvgrid
*      EXPORTING
*        i_parent = cc_po_crt.
*  ENDIF.
*  CLEAR gt_fieldcatalog.
*
** SET A TITLEBAR FOR THE GRID CONTROL
*  gs_layout-grid_title = text-015.
*  gs_layout-smalltitle = 'X'.
*  gs_layout-cwidth_opt = 'X'.
*
*  gs_fieldcat-fieldname   = 'VHCLE'.
*  gs_fieldcat-coltext   = 'Int. Veh. No.'.
*  gs_fieldcat-outputlen = 10.
*  gs_fieldcat-col_pos     = 1.
*  gs_fieldcat-datatype = 'CHAR' .
*  APPEND gs_fieldcat TO gt_fieldcatalog.
*  CLEAR  gs_fieldcat.
*
*  gs_fieldcat-fieldname   = 'MCODESD'.
*  gs_fieldcat-coltext   = 'Model Sales code'.
*  gs_fieldcat-outputlen = 10.
*  gs_fieldcat-col_pos     = 2.
*  gs_fieldcat-datatype = '/DBE/MODCODE_SALE' .
*  APPEND gs_fieldcat TO gt_fieldcatalog.
*  CLEAR  gs_fieldcat.
*
*  gs_fieldcat-fieldname   = 'NETPR'.
*  gs_fieldcat-coltext   = 'Net Price'.
*  gs_fieldcat-outputlen = 35.
*  gs_fieldcat-col_pos     = 3.
*  gs_fieldcat-datatype = 'CHAR' .
*  APPEND gs_fieldcat TO gt_fieldcatalog.
*  CLEAR  gs_fieldcat.
*
*  gs_fieldcat-fieldname   = 'CURRENCY'.
*  gs_fieldcat-coltext   = 'Currency'.
*  gs_fieldcat-outputlen = 35.
*  gs_fieldcat-col_pos     = 4.
*  gs_fieldcat-datatype = 'CHAR' .
*  APPEND gs_fieldcat TO gt_fieldcatalog.
*  CLEAR  gs_fieldcat.
*
*  gs_fieldcat-fieldname   = 'EINDT'.
*  gs_fieldcat-tabname   = 'gt_po_item_diff_delv'.
*  gs_fieldcat-coltext   = 'Delivery Date'.
*  gs_fieldcat-ref_table = 'VLCACTDATA_HEAD_S'.
*  gs_fieldcat-ref_field = 'EINDT'.
*  gs_fieldcat-outputlen = 10.
*  gs_fieldcat-col_pos     = 5.
*  gs_fieldcat-datatype = 'DATS' .
*  gs_fieldcat-f4availabl = 'X'.
*  gs_fieldcat-edit = 'X'.
**      gs_fieldcat-auto_value = 'X'.
**      gs_fieldcat-tabname = 'D'.
*  APPEND gs_fieldcat TO gt_fieldcatalog.
*  CLEAR  gs_fieldcat.
*
*  PERFORM prepare_po_info.
*
**Optionally register ENTER to raise event DATA_CHANGED.
** (Per default the user may check data by using the check icon).
*  CALL METHOD po_items_alvgrid->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
*
*  CALL METHOD po_items_alvgrid->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*
**create the event handler for verifying the input data.
*  CREATE OBJECT g_alv_handler_po.
*
** Register for data changed event handler
*  SET HANDLER g_alv_handler_po->handle_data_changed
*         FOR po_items_alvgrid.
*
*  PERFORM exclude_tb_functionss CHANGING lt_exclude.
*  CALL METHOD po_items_alvgrid->set_table_for_first_display
*    EXPORTING
**     i_buffer_active               =
**     i_bypassing_buffer            =
**     i_consistency_check           =
**     i_structure_name              =
**     is_variant                    =
**     i_save                        =
**     i_default                     = 'X'
*      is_layout                     = gs_layout
**     is_print                      =
**     it_special_groups             =
*      it_toolbar_excluding          = lt_exclude
**     it_hyperlink                  =
**     it_alv_graphics               =
**     it_except_qinfo               =
**     ir_salv_adapter               =
*    CHANGING
*      it_outtab                     = gt_po_item_diff_delv
*      it_fieldcatalog               = gt_fieldcatalog
**     it_sort                       =
**     it_filter                     =
*    EXCEPTIONS
*      invalid_parameter_combination = 1
*      program_error                 = 2
*      too_many_lines                = 3
*      OTHERS                        = 4.
*  IF sy-subrc <> 0.
**       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*


*      SET HANDLER g_alv_handler_po->onf4 FOR po_items_alvgrid.
*Hide delivery date
*      LOOP AT SCREEN.
*        IF screen-name = 'VLCACTDATA_HEAD_S-EINDT'.
*          screen-invisible = abap_true.
*        ENDIF.
*        IF screen-name = 'VLCACTDATA_ITEM_S-NETPR'.
*          screen-invisible = abap_true.
*        ENDIF.
*        MODIFY SCREEN.
*      ENDLOOP.

*    ENDIF.
*  ELSE.
*    IF has_diff_delv_date EQ abap_true OR gv_enable_alv EQ abap_true.
*      cc_po_crt->set_visible( abap_true ).
*    ELSE.
*      cc_po_crt->set_visible( abap_false ).
*    ENDIF.

*  ENDIF.




ENDMODULE.                    "generate_alv_grid INPUT
*&---------------------------------------------------------------------*
*&      Form  exclude_tb_functionss
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_EXCLUDE text
*----------------------------------------------------------------------*
FORM exclude_tb_functionss CHANGING pt_exclude TYPE ui_functions.
* Only allow to change data not to create new entries (exclude
* generic functions).
  DATA ls_exclude TYPE ui_func.

  REFRESH pt_exclude.

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
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_mb_export.
  APPEND ls_exclude TO pt_exclude.
  IF ( gv_action NE /DBE/if_vms_constants=>c_qapc )
    AND ( gv_action NE /DBE/if_vms_constants=>c_qagc ) AND ( gv_action NE /DBE/if_vms_constants=>c_qaic )
      AND ( gv_action NE /DBE/if_vms_constants=>c_qapo ) AND ( gv_action NE /DBE/if_vms_constants=>c_qagr )
    AND ( gv_action NE /DBE/if_vms_constants=>c_qain )
      AND ( gv_action NE /DBE/if_vms_constants=>c_qadc ) AND ( gv_action NE /DBE/if_vms_constants=>c_qacc ) .
    ls_exclude = cl_gui_alv_grid=>mc_mb_filter.
    APPEND ls_exclude TO pt_exclude.
  ENDIF.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO pt_exclude.


  IF gv_action = /DBE/if_vms_constants=>c_qadc OR
     gv_action = /DBE/if_vms_constants=>c_qapo OR
     gv_action = /DBE/if_vms_constants=>c_qagr OR
     gv_action = /DBE/if_vms_constants=>c_qpdi OR
     gv_action = /DBE/if_vms_constants=>c_qain.
*    ls_exclude = cl_gui_alv_grid=>mc_fc_select_all  .
*    APPEND ls_exclude TO pt_exclude.

*    ls_exclude = cl_gui_alv_grid=>mc_fc_deselect_all.
*    APPEND ls_exclude TO pt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
    APPEND ls_exclude TO pt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_minimum.
    APPEND ls_exclude TO pt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_maximum.
    APPEND ls_exclude TO pt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_average.
    APPEND ls_exclude TO pt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
    APPEND ls_exclude TO pt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
    APPEND ls_exclude TO pt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
    APPEND ls_exclude TO pt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_print.
    APPEND ls_exclude TO pt_exclude.
  ENDIF.
ENDFORM. " EXCLUDE_TB_FUNCTIONS          " GENERATE_ALV_GRID  OUTPUT

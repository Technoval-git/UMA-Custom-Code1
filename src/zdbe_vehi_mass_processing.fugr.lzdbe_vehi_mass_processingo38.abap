*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO38 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GENERATE_ALV_GRID_CRT_PO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE generate_alv_grid_crt_po OUTPUT.

    PERFORM f_create_alv_grid_po .

ENDMODULE.                    "generate_alv_grid INPUT
*&---------------------------------------------------------------------*
*&      Form  exclude_tb_functionss
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_EXCLUDE text
*----------------------------------------------------------------------*
*FORM exclude_tb_functionss CHANGING pt_exclude TYPE ui_functions.
** Only allow to change data not to create new entries (exclude
** generic functions).
*  DATA ls_exclude TYPE ui_func.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_mb_export.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_mb_filter.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
*  APPEND ls_exclude TO pt_exclude.
*
*
*ENDFORM. " EXCLUDE_TB_FUNCTIONS          " GENERATE_ALV_GRID  OUTPUT
*endmodule.                 " GENERATE_ALV_GRID_CRT_PO  OUTPUT

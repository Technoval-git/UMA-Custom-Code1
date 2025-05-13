FUNCTION ZDBE_VEH_GET_GRID_DATA.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      TO_VLCDISPLALV STRUCTURE  VLCDISPLALV
*"--------------------------------------------------------------------

  DATA: lt_selected_rows TYPE lvc_t_roid,
        ls_selected_row  TYPE lvc_s_roid.

  FIELD-SYMBOLS: <vlcdisplalv> TYPE vlcdisplalv.

  to_vlcdisplalv[] = gt_vlcdisplalv[].
  IF g_alv_grid IS BOUND.
    g_alv_grid->get_selected_rows( IMPORTING et_row_no = lt_selected_rows ).
    LOOP AT lt_selected_rows INTO ls_selected_row.
      READ TABLE to_vlcdisplalv[] ASSIGNING <vlcdisplalv> INDEX ls_selected_row-row_id.
      IF sy-subrc = 0.
        <vlcdisplalv>-/DBE/selected = abap_true.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.

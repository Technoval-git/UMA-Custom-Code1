*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  FIND_ACTIVE_TAB_GET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE find_active_tab_get INPUT.

  IF gt_ok IS INITIAL.
    ok_code = sy-ucomm.
  ELSE.
    ok_code = gt_ok.
  ENDIF.

  CASE ok_code.
    WHEN gc_find-gc_tab1.
      g_find-pressed_tab = gc_find-gc_tab1.
    WHEN gc_find-gc_tab2.
      g_find-pressed_tab = gc_find-gc_tab2.
    WHEN gc_find-gc_tab3.
      g_find-pressed_tab = gc_find-gc_tab3.
    WHEN gc_find-gc_tab4.
      g_find-pressed_tab = gc_find-gc_tab4.

    WHEN OTHERS.

  ENDCASE.
* Switch to worklist view after search
  IF sy-ucomm EQ 'EXECUTE' and gt_vsresult is not INITIAL.
    g_find-pressed_tab = gc_find-gc_tab3.
  ENDIF.
  IF g_find-pressed_tab = 'MASS_FC2' AND ok_code = 'ACT_EXE'  AND gv_block_navigation EQ abap_false."AND gt_bapireturn IS INITIAL.
    g_find-pressed_tab = gc_find-gc_tab3.
  ENDIF.

ENDMODULE.                 " FIND_ACTIVE_TAB_GET  INPUT

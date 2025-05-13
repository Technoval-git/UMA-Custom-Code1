*&---------------------------------------------------------------------*
*& Include          ZIVSSLVM07F74
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV
*&---------------------------------------------------------------------*
FORM refresh_alv.
*-> local declaration
*-> structure to define the alv-layout
  DATA ls_layout TYPE lvc_s_layo.

*-> refresh modus
  DATA ls_stable TYPE lvc_s_stbl.

************************************************************************


*-> layout of the grid alv
  ls_layout-sel_mode = 'A'.

*-> set the layout
  CALL METHOD go_serv_hist_alv->set_frontend_layout
    EXPORTING
      is_layout = ls_layout.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

*-> refresh the recall-alv (soft-refresh)
  CALL METHOD go_serv_hist_alv->refresh_table_display
    EXPORTING
      is_stable = ls_stable.
ENDFORM.                    " REFRESH_ALV

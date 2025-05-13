*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI26 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_SELECTION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_selection INPUT.
  DATA: lt_invoice_info  LIKE gt_ininvoice_info.
  DATA: lt_index         TYPE lvc_t_row.
  DATA: lt_rowid         TYPE lvc_t_roid.
  DATA: ls_rowid         TYPE lvc_s_roid.

*Get index and row-id of selected vehicles from ALV Grid
  incinvoice_alvgrid->get_selected_rows( IMPORTING et_index_rows = lt_index et_row_no = lt_rowid ).


  lt_invoice_info =  gt_ininvoice_info.
  REFRESH gt_ininvoice_info.
  CLEAR ls_invoice_info.
*Get selected vehicles
  LOOP AT lt_rowid INTO ls_rowid.

    READ TABLE lt_invoice_info INTO ls_invoice_info INDEX ls_rowid-row_id.
    APPEND ls_invoice_info TO gt_ininvoice_info.

  ENDLOOP.

ENDMODULE.                 " GET_SELECTION  INPUT

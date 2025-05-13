

*&---------------------------------------------------------------------*
*&      Module  GET_SELECTED_VEHI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_selected_vehicle INPUT.

  DATA: ls_vehi  TYPE /DBE/vsresult.
*Get index and row-id of selected vehicles from ALV Grid
      g_alv_grid->get_selected_rows( IMPORTING  et_row_no = lt_rowid ).
        REFRESH gt_vsresult_selection.
*Get selected vehicles
      LOOP AT lt_rowid INTO ls_rowid.
        READ TABLE gt_vsresult INTO ls_vehi INDEX ls_rowid-row_id.
        APPEND ls_vehi TO gt_vsresult_selection.
      ENDLOOP.

ENDMODULE.

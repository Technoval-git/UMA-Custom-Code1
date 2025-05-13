*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO31 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  BADI_PUT_DATA_TO_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE badi_put_data_to_screen OUTPUT.

  IF badi_search_ui IS BOUND.

*    CALL BADI badi_search_ui->put_data_to_screen
*      EXPORTING
*        iv_searchstring = gv_searchstring
*        iv_searchmode   = gv_searchmode
*        it_vlcdiavehi   = gt_vlcdiavehi
*        iv_error_search = gv_error_search
*        it_search_crit  = gt_mass_search_crit
*        it_bapireturn   = gt_bapireturn
*        iv_ok_code      = ok_code.
  ENDIF.

ENDMODULE.                 " BADI_PUT_DATA_TO_SCREEN  OUTPUT

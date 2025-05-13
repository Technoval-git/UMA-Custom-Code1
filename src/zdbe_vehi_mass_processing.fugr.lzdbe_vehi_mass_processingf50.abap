*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF50 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BADI_GET_DATA_FROM_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM badi_get_data_from_screen .

  IF badi_search_ui IS BOUND.

*    CALL BADI badi_search_ui->get_data_from_screen
*      IMPORTING
*        ev_searchstring = gv_searchstring
*        ev_searchmode   = gv_searchmode
*        et_vlcdiavehi   = gt_vlcdiavehi
*        ev_error_search = gv_error_search
*        et_search_crit  = gt_mass_search_crit
*        ev_ok_code      = ok_code
*        et_bapireturn   = gt_bapireturn.

  ENDIF.

ENDFORM.                    " BADI_GET_DATA_FROM_SCREEN

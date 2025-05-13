*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF11 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_MODAL_DIALOG_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_MODAL_DIALOG_SCREEN ."#EC CALLED

  CALL SCREEN 3000 STARTING AT 20 20 ENDING AT 80 40.
  "gv_action_screen_program = gs_bulk_actions-prognam.
*    gv_action_screen_dynpro  = gs_bulk_actions-dynnr.
ENDFORM.                    " SET_MODAL_DIALOG_SCREEN
*&---------------------------------------------------------------------*
*&      Module  M_ERRORS_SHOW  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module M_ERRORS_SHOW input."#EC CALLED
PERFORM m_error_show.
endmodule.                 " M_ERRORS_SHOW  INPUT

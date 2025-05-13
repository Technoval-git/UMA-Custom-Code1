*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO26 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SET_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_subscreen OUTPUT.

  IF gv_action_screen_program IS INITIAL OR  gv_action_screen_dynpro  IS INITIAL.
    gv_action_screen_program = gc_default_action_program.
    gv_action_screen_dynpro  = gc_default_action_dynpro.
  ENDIF.
ENDMODULE.                 " SET_SUBSCREEN  OUTPUT

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO33 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SEARCH_CRITERIA_SUBSCREEN_SET  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE search_criteria_subscreen_set OUTPUT.

* If there is no BADI implementation we show the default screen.
  IF gv_badi_program      = gc_badi_program
     OR gv_badi_program   = gc_badi_program2 OR gv_badi_program IS INITIAL.
    gv_subscreen_program  = gc_mass_main_program.
    gv_subscreen_dynpro   = gc_mass_crit_subscreen_dynpro.
  ELSE.
    gv_subscreen_program  = gv_badi_program.
    gv_subscreen_dynpro   = gv_badi_dynpro.
  ENDIF.

ENDMODULE.                 " SEARCH_CRITERIA_SUBSCREEN_SET  OUTPUT

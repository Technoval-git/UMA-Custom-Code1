*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO34 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SEARCH_TAB_SET  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE search_tab_set OUTPUT.

  IF gv_subscreen_dynpro IS INITIAL.
    mass-activetab = gc_searchvm_fc.

* if the BADI suggests SAPLSEXM 0200 then there is no
* BADI implementation and we show the default screen.
    IF gv_badi_program = gc_badi_program
       OR gv_badi_program = gc_badi_program2 OR gv_badi_program IS INITIAL.
      gv_subscreen_program = gc_mass_main_program.
      gv_subscreen_dynpro =  gc_search_subscreen.
    ELSE.
      gv_subscreen_program = gv_badi_program.
      gv_subscreen_dynpro =  gv_badi_dynpro..
    ENDIF.
    gv_default_search_screen = gv_subscreen_dynpro.
  ENDIF.

ENDMODULE.                 " SEARCH_TAB_SET  OUTPUT

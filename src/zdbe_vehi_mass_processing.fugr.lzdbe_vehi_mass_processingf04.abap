*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  MAIN_SCREEN_DYNPRO_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM main_screen_dynpro_set .

* if the BADI suggests SAPLSEXM 0200 then there is no
* BADI implementation and we show the default screen.
  IF gv_badi_program = gc_badi_program
     OR gv_badi_program = gc_badi_program2 OR gv_badi_program IS INITIAL.
*    gv_main_subscreen_program = gc_mass_main_program.
*    gv_main_subscreen_dynpro = gc_mass_main_subscreen_dynpro.
    gv_tab_subscreen_program = gc_mass_main_program.
    gv_tab_subscreen_dynpro =  gc_tab_result_dynpro.
  ELSE.
    gv_tab_subscreen_program = gv_badi_program.
    gv_tab_subscreen_dynpro =  gv_badi_dynpro..
*    gv_main_subscreen_program = gv_badi_program.
*    gv_main_subscreen_dynpro = gv_badi_dynpro.
  ENDIF.

ENDFORM.                    " MAIN_SCREEN_DYNPRO_SET

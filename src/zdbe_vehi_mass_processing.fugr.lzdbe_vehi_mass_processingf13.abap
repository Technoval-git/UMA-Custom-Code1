*----------------------------------------------------------------------*
***INCLUDE /DBE/LVM06F05 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  result_screen_dynpro_set
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM result_screen_dynpro_set .

* if the BADI suggests SAPLSEXM 0200 then there is no
* BADI implementation and we show the default screen.
  IF gv_badi_program = gc_badi_program
  OR gv_badi_program = gc_badi_program2
  OR gv_badi_program IS INITIAL.
    gv_tab_subscreen_program  = gc_mass_main_program."gc_default_action_program .
    gv_tab_subscreen_dynpro   = gc_result_subscr_dynpro.
  ELSE.
    gv_tab_subscreen_program  = gv_badi_program.
    gv_tab_subscreen_dynpro   = gv_badi_dynpro.
  ENDIF.

ENDFORM.                    " result_screen_dynpro_set

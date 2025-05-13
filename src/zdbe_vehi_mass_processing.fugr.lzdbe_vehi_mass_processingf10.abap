*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF10 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OVERVIEW_SUBSCREEN_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM overview_subscreen_set .

  ok_code = gc_worklist_fc.

  mass-activetab        = gc_worklist_fc.
  gv_subscreen_dynpro   = gc_result_subscr_dynpro1.
  gv_subscreen_program  = gc_mass_main_program.

ENDFORM.                    " OVERVIEW_SUBSCREEN_SET

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF73 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_OBLIG_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_determine_oblig_fields .

*Set all obligatory fields as type '2' should be filled
  LOOP AT SCREEN.
    IF screen-group1 EQ gc_ftype_in1.
      screen-required = gc_2.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_DETERMINE_OBLIG_FIELDS

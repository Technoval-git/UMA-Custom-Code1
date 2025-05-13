**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGF71 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Form  F_DETERMINE_OBLIGATORY_FIELDS
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM f_determine_obligatory_fields .
*
**Set all obligatory fields as type '2' should be filled
*  LOOP AT SCREEN.
*    IF screen-group1 EQ gc_ftype_in1.
*      screen-required = gc_2.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.
*
*ENDFORM.                    " F_DETERMINE_OBLIGATORY_FIELDS

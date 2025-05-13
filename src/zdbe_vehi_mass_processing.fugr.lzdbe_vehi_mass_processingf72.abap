**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGF72 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Form  F_DETERMINE_OBLIGATORY_FIELDS
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*form F_DETERMINE_OBLIGATORY_FIELDS .
*
**Set all obligatory fields as type '2' should be filled
*  LOOP AT SCREEN.
*    IF screen-group1 EQ gc_ftype_in1.
*      screen-required = gc_2.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.
*
*endform.                    " F_DETERMINE_OBLIGATORY_FIELDS

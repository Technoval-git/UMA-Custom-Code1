*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF61 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RECORD_TAB   text
*      -->SHLP         text
*      -->CALLCONTROL  text
*----------------------------------------------------------------------*
*FORM f4callback TABLES record_tab STRUCTURE seahlpres
*                      CHANGING shlp TYPE shlp_descr
*                               callcontrol TYPE ddshf4ctrl.
*
*  DATA: aux_struc TYPE ddshselopt.
*
*  MOVE:
*  'SSH_T007A' TO aux_struc-shlpname,
*  'KALSM' TO aux_struc-shlpfield,
*  'I' TO aux_struc-sign,
*  'EQ' TO aux_struc-option,
*  'TAXD' TO aux_struc-low,
*  'TAXD' TO aux_struc-high.
*
*  APPEND aux_struc TO shlp-selopt.

*ENDFORM.                    " F4callback

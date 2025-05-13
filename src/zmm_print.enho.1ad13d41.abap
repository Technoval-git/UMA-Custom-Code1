"Name: \PR:SAPFM06P\FO:FILL_CONTROL_STRUCTURE\SE:END\EI
ENHANCEMENT 0 ZMM_PRINT.
*
  IF if_preview IS INITIAL.
    CLEAR: es_outparms-preview.
  ELSE.
    es_outparms-preview = 'X'.
    es_outparms-noprint = ' '.
  ENDIF.

ENDENHANCEMENT.

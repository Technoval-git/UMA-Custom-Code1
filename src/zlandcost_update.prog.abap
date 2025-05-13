REPORT zlandcost_update .
INCLUDE zlandcost_update_top.
INCLUDE zlandcost_update_sel.
INCLUDE zlandcost_update_cla.

AT SELECTION-SCREEN OUTPUT.
  PERFORM validation.

START-OF-SELECTION.
  PERFORM fetch_data USING  p_po CHANGING lt_final.
  lt_chfinal = lt_final.
  PERFORM field_catalog CHANGING it_fieldcat.
  IF lt_final IS NOT INITIAL.
    PERFORM display USING it_fieldcat lt_final.
  ELSE.
    MESSAGE 'No data found for given purchase order' TYPE 'I'.
  ENDIF.

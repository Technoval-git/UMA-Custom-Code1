FUNCTION ZDBE_CHECK_VMASS_BADI_IMP.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(EV_SEARCH_UI_BADI) TYPE  BOOLEAN
*"     REFERENCE(EV_RESULT_BADI) TYPE  BOOLEAN
*"--------------------------------------------------------------------

  PERFORM badi_search_initialize.
  IF  badi_search_ui IS BOUND.
    ev_search_ui_badi = abap_true.
  ELSE.
    CLEAR ev_search_ui_badi.
  ENDIF.

  PERFORM badi_result_initialize.

  IF badi_result_alv IS BOUND.
    ev_result_badi = abap_true.
  ELSE.
    CLEAR ev_result_badi.
  ENDIF.

ENDFUNCTION.

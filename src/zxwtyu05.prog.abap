*&---------------------------------------------------------------------*
*& Include          ZXWTYU05
*&---------------------------------------------------------------------*

CALL FUNCTION '/DBE/S_WTY_UE_WTY00002_005'
  EXPORTING
    is_pnwtyh = is_pnwtyh
    it_pwnytv = it_pwnytv
    it_pvwty  = it_pvwty
  IMPORTING
    ev_dynnr  = ev_dynnr.

IF sy-dynnr = '1502'.
  ev_dynnr = 1001.
ENDIF.

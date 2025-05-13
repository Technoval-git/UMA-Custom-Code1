*&---------------------------------------------------------------------*
*& Include          ZXWTYU03
*&---------------------------------------------------------------------*

CALL FUNCTION '/DBE/S_WTY_UE_WTY00002_003'
  EXPORTING
    iv_mode   = iv_mode
    is_pnwtyh = is_pnwtyh
    it_pnwtyv = it_pnwtyv
    it_pvwty  = it_pvwty
    is_pnwtyv = is_pnwtyv
    is_pvwty  = is_pvwty.

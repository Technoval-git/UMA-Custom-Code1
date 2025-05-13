*&---------------------------------------------------------------------*
*& Include          ZXWTYU02
*&---------------------------------------------------------------------*

CALL FUNCTION '/DBE/S_WTY_UE_WTY00001_002'
  IMPORTING
    es_pnwtyh_cust = es_pnwtyh_cust
    ev_activ       = ev_activ
    es_pnwtyh_dyn  = es_pnwtyh_dyn.

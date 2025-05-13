*&---------------------------------------------------------------------*
*& Include          ZMM_PPC_POOL_LIST_SSCR
*&---------------------------------------------------------------------*
SELECT-OPTIONS:
    s_banfn  FOR  eban-banfn MATCHCODE OBJECT mban,
    s_ekgrp  FOR  eban-ekgrp,
    s_matnr  FOR  eban-matnr MATCHCODE OBJECT mat1,
    s_matkl  FOR  eban-matkl,
    s_bednr  FOR  eban-bednr,
    s_werks  FOR eban-werks ,
    s_bsart  FOR eban-bsart,
    s_lfdat  FOR eban-lfdat,
    s_frgdt  FOR eban-frgdt,
    s_dispo  FOR eban-dispo,
    s_statu  FOR eban-statu,
    s_flief  FOR eban-flief MATCHCODE OBJECT kred,
    s_banpr  FOR eban-banpr,
    s_blckd  FOR eban-blckd,
    s_region FOR t001w-regio.
PARAMETERS:
  p_afnam  LIKE eban-afnam,
  p_txz01  LIKE eban-txz01,
  p_zugba  LIKE rm06a-p_zugeordn DEFAULT 'X',
  p_memory LIKE rm06a-p_memory DEFAULT 'X',
  p_erlba  LIKE rm06a-p_erledigt,
  p_bstba  LIKE rm06a-p_teilbest DEFAULT 'X',
  p_freig  LIKE rm06a-p_freigabe DEFAULT ' ',
  p_selgs  LIKE rm06a-p_selgs DEFAULT 'X',
  p_selpo  LIKE rm06a-p_selpo DEFAULT 'X'.

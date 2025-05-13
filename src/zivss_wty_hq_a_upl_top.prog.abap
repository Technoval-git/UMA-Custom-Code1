*&---------------------------------------------------------------------*
*& Include          ZIVSS_WTY_HQ_A_UPL_TOP
*&---------------------------------------------------------------------*

TABLES : pnwtyh.

CONSTANTS : gc_incoming TYPE wty_acode  VALUE 'ZVS1',
            gc_postclm  TYPE wty_acode  VALUE 'DBM2',
            gc_simultae TYPE wty_acode  VALUE 'ZVS2'.

DATA : lt_pnwtyh TYPE STANDARD TABLE OF pnwtyh,
       ls_pnwtyh TYPE pnwtyh.

DATA : lv_clm_not_exit  TYPE wty_flag,
       lv_clm_not_allow TYPE wty_flag.

DATA : it_return TYPE STANDARD TABLE OF bapiret2,
       it_smesg  TYPE  tsmesg.

DATA : t_bdcdata  LIKE TABLE OF bdcdata,
       fs_bdcdata LIKE LINE OF t_bdcdata.

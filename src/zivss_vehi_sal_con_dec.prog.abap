*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_SAL_CON_DEC
*&---------------------------------------------------------------------*

TABLES : vbrk, vlcvehicle.

DATA: ls_header   TYPE bapisdhd1,
      lv_order    TYPE bapivbeln-vbeln,
      ls_return   TYPE bapiret2,
      lt_return   TYPE TABLE OF bapiret2,
      ls_items    TYPE bapisditm,
      lt_items    TYPE TABLE OF bapisditm,
      ls_partners TYPE bapiparnr,
      lt_partners TYPE TABLE OF bapiparnr,
      ls_ctrdata  TYPE bapictr,
      lt_ctrdata  TYPE TABLE OF bapictr,
      lt_cond     TYPE TABLE OF bapicond,
      lt_condx    TYPE TABLE OF bapicondx,
      ls_cond     TYPE bapicond,
      ls_condx    TYPE bapicondx.

DATA : lt_extensionin TYPE TABLE OF bapiparex,
       ls_extensionin TYPE bapiparex.

DATA : lv_inc TYPE i.

DATA : lt_vehi_db  TYPE /dbe/t_cnt_vehi_db,
       ls_vehi_db TYPE /DBE/CNT_VEHI,
       lt_vehi_com TYPE /dbe/t_cnt_vehi_db,
       ls_vehi_com  TYPE /DBE/CNT_VEHI.

*&---------------------------------------------------------------------*
*& Include          ZLANDCOST_UPDATE_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_str,
         condition_no TYPE  knumv,
         itm_number   TYPE  kposn,
         cond_st_no   TYPE  stunr,
         curency      TYPE  waers,
         ebeln        TYPE ebeln,
         ebelp        TYPE ebelp,
         matnr        TYPE matnr,
         menge        TYPE bstmg,
         kmein        TYPE kmein,
         kpein        TYPE kpein,
         netpr        TYPE bprei,
         banfn        TYPE banfn,
         bnfpo        TYPE bnfpo,
         werks        TYPE werks,
         lgort        TYPE lgort_d,
         bednr        TYPE bednr,
         kschl        TYPE kschl,
         vtext        TYPE vtext,
         cur          TYPE waers,
         cur_te       TYPE val_text,
         kbetr        TYPE kbetr,
         new_KPEIN    TYPE string,
       END OF ty_str.
********      normal wway
DATA : it_fieldcat TYPE  slis_t_fieldcat_alv,
       wa_fieldcat TYPE slis_fieldcat_alv,
       new_k       TYPE p DECIMALS 3.




*PO CHANGE
DATA: wa_poheaderchdata TYPE bapimepoheader,

      it_pohederchange  TYPE TABLE OF bapimepocondheader,
      wa_poheaderch     TYPE  bapimepocondheader,
      wa_poiteamch      TYPE bapimepocond,

      it_poiteamchange  TYPE TABLE OF BAPIMEPOCOND,
      wa_pochcontyp     TYPE  BAPIMEPOCOND,
      it_pochaitcontypx TYPE TABLE OF BAPIMEPOCONDX,
      wa_poiteamchx     TYPE BAPIMEPOCONDX,

      wa_pochacontypx   TYPE  bapimepocondx,
      it_return         TYPE TABLE OF bapiret2,
      lt_pohederconx    TYPE TABLE OF bapimepocondheaderx,
      wa_pohederconx    TYPE  bapimepocondheaderx.
*
*getdata
DATA: wa_headerdata  TYPE bapimepoheader,
      lt_poheadercom TYPE TABLE OF bapimepocondheader,
*       wa_iteamdata  TYPE BAPIMEPOCOND,
      lt_poiteamcom  TYPE TABLE OF bapimepocond.



********
DATA: lt_final   TYPE TABLE OF ty_str,
      lt_chfinal TYPE TABLE OF ty_str,
      wa_final   TYPE ty_str,
      lt_desr    TYPE TABLE OF dd07v,
      ls_layout  TYPE slis_layout_alv.
DATA:
  lt_return    TYPE TABLE OF bapiret2,
  lt_pocondtio TYPE TABLE OF bapimepocond,
  go_functions TYPE REF TO cl_salv_functions,
  go_display   TYPE REF TO cl_salv_display_settings,
  lo_grid      TYPE REF TO cl_gui_alv_grid,
  lo_full_adap TYPE REF TO cl_salv_fullscreen_adapter.

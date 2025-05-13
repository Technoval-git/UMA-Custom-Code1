*&---------------------------------------------------------------------*
*& Include          ZIINVENTORY_UPLOAD_DEC
*&---------------------------------------------------------------------*
TYPE-POOLS: pic01.

TYPES: BEGIN OF ty_file_data,
         file_record(1000) TYPE c,
       END OF ty_file_data.

DATA : i_file_data  TYPE STANDARD TABLE OF  ty_file_data,
       wa_file_data TYPE ty_file_data.

DATA : wa_file_name  TYPE file_table.

DATA : lv_tab        TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
       lv_split1(40) TYPE c,
       lv_split2(40) TYPE c,
       lv_split3(40) TYPE c,
       lv_split4(40) TYPE c,
       lv_split5(40) TYPE c,
       lv_success    TYPE n VALUE 0,
       lv_error      TYPE n VALUE 0.

CONSTANTS : ca_check TYPE c       VALUE '0',
            ca_ftype TYPE char10  VALUE 'ASC'.
CONSTANTS: lc_log(3)   TYPE c VALUE 'LOG',
           lc_lgc(3)   TYPE c VALUE 'LGC',
           lc_fil(3)   TYPE c VALUE 'FIL',
           lc_csv(3)   TYPE c VALUE 'CSV',
           lc_txt(3)   TYPE c VALUE 'TXT',
           lc_comma(1) TYPE c VALUE ',',
           lc_dot(1)   TYPE c VALUE '.'.

TYPES : BEGIN OF ty_file_value,
*          po_no(10) TYPE c,
*          bldat  TYPE mkpf-bldat,
*          budat  TYPE mkpf-budat,
          bldat(10)      TYPE c,
          budat(10)      TYPE c,
          bktxt          TYPE mkpf-bktxt,
          bwart          TYPE mseg-bwart,
          werks          TYPE mseg-werks,
          lgort          TYPE mseg-lgort,
          xnapr          TYPE rm07m-xnapr,
          wever          TYPE rm07m-wever,
          matnr          TYPE matnr_ext,
          menge          TYPE mseg-erfmg,
          charg          TYPE mseg-charg,
          ext_cu         TYPE bapi_exbwr,
          sgtxt          TYPE sgtxt,
          fmore          TYPE dkacb-fmore,
          ref_doc_no     TYPE xblnr,
          bill_of_lading TYPE frbnr,

*          ekorg     TYPE ekko-ekorg,
*          ekgrp     TYPE ekko-ekgrp,
*          bukrs     TYPE ekko-bukrs,
*          ebelp     TYPE ekpo-ebelp,
*          knttp     TYPE ekpo-knttp,
*          pstyp     TYPE ekpo-pstyp,
*          matnr     TYPE ekpo-matnr,
*          menge     TYPE ekpo-menge,
*          meins     TYPE ekpo-meins,
*          eindt     TYPE eket-eindt,
*          netpr     TYPE ekpo-netpr,
*          matkl     TYPE ekpo-matkl,
*          werks     TYPE ekpo-werks,
*          bednr     TYPE ekpo-bednr,
*          afnam     TYPE ekpo-afnam,
*          lgort     TYPE ekpo-lgort,
*          kostl     TYPE ekkn-kostl,
*          sakto     TYPE ekkn-sakto,
*          wempf     TYPE ekkn-wempf,
*          mwskz     TYPE ekkn-mwskz,
*          prctr     TYPE ekkn-prctr,
        END OF ty_file_value.

DATA : i_file_value   TYPE STANDARD TABLE OF ty_file_value,
       wa_file_value  TYPE ty_file_value,
       wa_file_value1 TYPE ty_file_value.

DATA : lv_quantity(15) TYPE c,
       lv_netpr(15)    TYPE c.

DATA : ls_gv_header    TYPE bapi2017_gm_head_01,
       ls_dv_headret   TYPE bapi2017_gm_head_ret,
       lv_mat_doc      TYPE bapi2017_gm_head_ret-mat_doc,
       lv_mat_doc_year TYPE bapi2017_gm_head_ret-doc_year,
       i_return        TYPE STANDARD TABLE OF bapiret2,
       wa_return       TYPE bapiret2,
       lt_gv_item      TYPE STANDARD TABLE OF bapi2017_gm_item_create,
       ls_gv_item      TYPE bapi2017_gm_item_create.


*DATA :

DATA : lv_po_number TYPE ekko-ebeln,
       lv_inc       TYPE i.




TYPES: BEGIN OF ty_log,
         matnr   TYPE char40,
         type    TYPE char5,
         mblnr   TYPE char20,
         message TYPE char258,
       END OF ty_log.


DATA : lt_log TYPE STANDARD TABLE OF ty_log.
DATA : lt_alv TYPE STANDARD TABLE OF ty_log,
       ls_log TYPE ty_log.

DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
       wa_layout   TYPE slis_layout_alv,
       ls_print    TYPE slis_print_alv.

DATA va_top           TYPE slis_formname VALUE 'F_ALV_HEADER'.

DATA : date_c(10) TYPE c,
       date_f(8)  TYPE c.

ls_log-matnr =  TEXT-l01.
ls_log-type  = TEXT-l02.
ls_log-mblnr =  TEXT-l03.
ls_log-message =  TEXT-l04.
APPEND ls_log TO lt_log.

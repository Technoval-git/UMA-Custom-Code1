*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_PO_CREATE_TOP
*&---------------------------------------------------------------------*


TYPES:BEGIN OF ty_source_fields,
        bill_no   TYPE char20,
        odr_no    TYPE char10,
        veh_type  TYPE char20,
        vin       TYPE vlc_vhvin,
        engine_no TYPE char30,
        factory   TYPE char30,
        weight    TYPE char10,
        cbm       TYPE char10,
        cub_cap   TYPE char10,
        dest      TYPE char20,
        vessel    TYPE char10,
        ats       TYPE char10,
        eta       TYPE char10,
        mrn       TYPE char30,
      END OF ty_source_fields.
TYPES: BEGIN OF ty_veh,
         vguid        TYPE vlcvehicle-vguid,
         vhcle        TYPE vlc_vhcle,
         charg        TYPE charg_d,
         vhvin        TYPE vlc_vhvin,
         vhcex        TYPE vlc_vhcex,
         ebeln        TYPE ebeln,
         ebelp        TYPE ebelp,
         matnr        TYPE matnr,
         zvessel_name TYPE zvessel_name_de,
         zeta_date    TYPE zeta_date_de,
       END OF ty_veh.

TYPES: BEGIN OF ty_po,
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
       END OF ty_po.
*Log table
TYPES:BEGIN OF ty_log,
        message   TYPE char07,
        inbdel    TYPE vbeln_vl,
        long_text TYPE char100,
        verur     TYPE verur_la.
TYPES: END OF ty_log.
TYPES: tt_wueb TYPE TABLE OF wueb.
DATA:
  lv_extension     TYPE char03,
  it_source        TYPE TABLE OF ty_source_fields,
  it_lips_temp     TYPE TABLE OF lipsvb,
  it_log           TYPE TABLE OF ty_log,
  it_inb           TYPE TABLE OF bbp_inbd_d,
  it_inb_zbat      TYPE TABLE OF bbp_inbd_d,
  ts_inb           TYPE bbp_inbd_d,
  ts_inb_h         TYPE  bbp_inbd_l,
  va_total_records TYPE char7,
  va_succ_records  TYPE char7,
  va_fail_records  TYPE char7.

CONSTANTS: gc_log     TYPE char03 VALUE 'LOG',
           gc_lgc     TYPE char03 VALUE 'LGC',
           gc_fil     TYPE char03 VALUE 'FIL',
           gc_err     TYPE char01 VALUE 'E',
           gc_abort   TYPE char01 VALUE 'A',
           gc_succ    TYPE char01 VALUE 'S',
           gc_ext1    TYPE char03 VALUE 'CSV',
           gc_ext2    TYPE char03 VALUE 'TXT',
           gc_csv_sep TYPE char01 VALUE ',',
           gc_txt_sep TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
           gc_error   TYPE char07 VALUE 'Error',##NO_TEXT "Message Code TXT 1700
*           gc_warning TYPE char07 VALUE 'Warning',
           gc_success TYPE char07 VALUE 'Success',
           gc_warning TYPE char07 VALUE 'Warning'.
*Constants for field catalog

CONSTANTS:gc_message     TYPE char25 VALUE 'MESSAGE',
          gc_inbdel      TYPE char25 VALUE 'INBDEL',
          gc_long_text   TYPE char25 VALUE 'LONG_TEXT',
          gc_identifiers TYPE char25 VALUE 'IDENTIFIERS',
          gc_lifnr       TYPE char25 VALUE 'LIFNR',
          gc_verur       TYPE char25 VALUE 'VERUR',
          gc_ebeln       TYPE char25 VALUE 'EBELN',
          gc_ebelp       TYPE char25 VALUE 'EBELP',
          gc_lfdat_la    TYPE char25 VALUE 'LFDAT_LA',
          gc_lfimg       TYPE char25 VALUE 'LFIMG',
          gc_it_source   TYPE char10 VALUE 'IT_SOURCE'.

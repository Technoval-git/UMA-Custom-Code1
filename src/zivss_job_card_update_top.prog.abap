*&---------------------------------------------------------------------*
*& Include          ZIVSS_JOB_CARD_UPDATE_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_data,
*         mcatalog  TYPE  /dbe/mcatalog,
*         opclass   TYPE /dbe/vd_opclass,
*         opkey     TYPE /dbe/vd_opkey,
*         optyp     TYPE  /dbe/vd_optyp,
*         matnr     TYPE  /dbe/omatnr,
*         puprc(12) TYPE c, "/dbe/puprc,
*         pkonwa    TYPE  /dbe/puprc_c,
*         saprc(12) TYPE  c, "/dbe/vd_saprc,
*         skonwa    TYPE  /dbe/saprc_c,
*         spras     TYPE  spras,
*         optext1   TYPE  /dbe/vd_optext1,
*         optext2   TYPE  /dbe/vd_optext2,
*         optext3   TYPE  /dbe/vd_optext3,
*         optext4   TYPE /dbe/vd_optext4,
         ord_no     TYPE /dbe/vbeln_va,
         job_no     TYPE /dbe/jobnr,
         concern    TYPE string,
         cause      TYPE string,
         correction TYPE string,
         tech       TYPE persno,
         start_date TYPE string, "cats_ersda,
         start_time TYPE string, "catsbeguz,
         end_date   TYPE string, "cats_ersda,
         end_time   TYPE string, "catsbeguz,
       END OF ty_data.
DATA: gt_source TYPE STANDARD TABLE OF ty_data,
      gw_source TYPE ty_data.


CONSTANTS:gc_csv_sep TYPE char01 VALUE ','.

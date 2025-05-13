*&---------------------------------------------------------------------*
*& Include          ZVSS_MODEL_VEH_OPTIONS_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_data,
         mcatalog  TYPE  /dbe/mcatalog,
         opclass   TYPE /dbe/vd_opclass,
         opkey     TYPE /dbe/vd_opkey,
         optyp     TYPE  /dbe/vd_optyp,
         matnr     TYPE  /dbe/omatnr,
         puprc(12) TYPE c, "/dbe/puprc,
         pkonwa    TYPE  /dbe/puprc_c,
         saprc(12) TYPE  c, "/dbe/vd_saprc,
         skonwa    TYPE  /dbe/saprc_c,
         spras     TYPE  spras,
         optext1   TYPE  /dbe/vd_optext1,
         optext2   TYPE  /dbe/vd_optext2,
         optext3   TYPE  /dbe/vd_optext3,
         optext4   TYPE /dbe/vd_optext4,
       END OF ty_data.
DATA: gt_source TYPE STANDARD TABLE OF ty_data,
      gw_source TYPE ty_data.


CONSTANTS:gc_csv_sep TYPE char01 VALUE ','.

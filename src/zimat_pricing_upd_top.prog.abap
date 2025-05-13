*&---------------------------------------------------------------------*
*& Include          ZIMAT_PRICING_UPD_TOP
*&---------------------------------------------------------------------*

*Types Declaration
TYPES ty_knumhs TYPE STANDARD TABLE OF bapiknumhs.

TYPES:
* text type for coloumn heading
  BEGIN OF ty_colname,
*    table             TYPE char50,
    cond_type         TYPE char50,
    vendor            TYPE char50,
    pur_grp           TYPE char50,
    mat_grp4          TYPE char50,
    amount            TYPE char50,
    amount_unit       TYPE char50,
    cond_pr_unit      TYPE char50,
    cond_pr_unit_unit TYPE char50,
*    krech             TYPE char50,
    valid_from        TYPE char50,
    valid_to          TYPE char50,
  END OF ty_colname,

* text type for coloumn heading
  BEGIN OF ty_colname1,
*    table             TYPE char50,
    cond_type         TYPE char50,
    sales_org         TYPE char50,
    vtweg             TYPE vtweg,
    spart             TYPE spart,
    aufart            TYPE aufart,
    kdgrp             TYPE kdgrp,
    kunnr             TYPE kunnr,
    material          TYPE matnr,
    amount            TYPE char50,
    amount_unit       TYPE char50,
    cond_pr_unit      TYPE char50,
    cond_pr_unit_unit TYPE char50,
*    krech             TYPE char50,
    valid_from        TYPE char50,
    valid_to          TYPE char50,
  END OF ty_colname1,

*structure for FINAL TABLE
  BEGIN OF ty_final,
*    table             TYPE kotabnr,
    cond_type         TYPE kschl,
    vendor            TYPE elifn,
    pur_grp           TYPE ekorg,
    mat_grp4          TYPE mvgr4,
    amount            TYPE kbetr,
    amount_unit       TYPE konwa,
    cond_pr_unit      TYPE kpein,
    cond_pr_unit_unit TYPE kmein,
*    krech             TYPE char50,
    valid_from        TYPE char50,
    valid_to          TYPE char50,
  END OF ty_final,

  BEGIN OF ty_final1,
*    table             TYPE kotabnr,
    cond_type         TYPE kschl,
    sales_org         TYPE vkorg,
    vtweg             TYPE vtweg,
    spart             TYPE spart,
    aufart            TYPE aufart,
    kdgrp             TYPE kdgrp,
    kunnr             TYPE kunnr,
    material          TYPE matnr,
    amount            TYPE kbetr,
    amount_unit       TYPE konwa,
    cond_pr_unit      TYPE kpein,
    cond_pr_unit_unit TYPE kmein,
*    krech             TYPE char50,
    valid_from        TYPE char50,
    valid_to          TYPE char50,
  END OF ty_final1,

*structure for success log
  BEGIN OF ty_slog,
    row_no TYPE int4,
    knumhs TYPE char16,
    type   TYPE bapi_mtype,
    msg    TYPE bapiret2-message,
  END OF ty_slog,

*structure for error log
  BEGIN OF ty_elog,
    row_no TYPE int4,
    knumhs TYPE char16,
    type   TYPE bapi_mtype,
    msg    TYPE bapiret2-message,
  END OF ty_elog.



*Data declaration
DATA: ts_file_data  TYPE ty_final,
      ts_file_data1 TYPE ty_final1   ##NEEDED,                       "workarea for condition record file data
      it_file_data  TYPE STANDARD TABLE OF ty_final   ##NEEDED,     "internal table for  condition record file data
      it_file_data1 TYPE STANDARD TABLE OF ty_final1   ##NEEDED,     "internal table for  condition record file data
      ts_succ_log   TYPE ty_slog  ##NEEDED,                         "workarea for success log
      ts_err_log    TYPE ty_elog  ##NEEDED,                         "workarea for error log
      it_succ_log   TYPE STANDARD TABLE OF ty_slog ##NEEDED,        "internal table for success log
      it_err_log    TYPE STANDARD TABLE OF ty_elog ##NEEDED.       "internal table for success log

*Constants declaration
CONSTANTS: lc_e       TYPE c       VALUE 'E',
           lc_s       TYPE c       VALUE 'S',
           lc_w       TYPE c       VALUE 'W',
           lc_xls     TYPE char4   VALUE '.XLS',
           lc_non     TYPE bapitga-textformat VALUE 'NON',
           lc_lgc(3)  TYPE c VALUE 'LGC',
           lc_fil(3)  TYPE c VALUE 'FIL',
           lc_ext1(3) TYPE c VALUE 'CSV',
           lc_ext2(3) TYPE c VALUE 'TXT'.

*&---------------------------------------------------------------------*
*& Include          ZI_EWM_PARTNO_PRINT_TOP
*&---------------------------------------------------------------------*
REPORT zr_ewm_partno_print.

TABLES : mara.
DATA : gt_mara TYPE TABLE OF matnr.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  SELECT-OPTIONS : s_matnr FOR mara-matnr.
  SELECT-OPTIONS : s_mtart FOR mara-mtart.
  SELECT-OPTIONS : s_matkl FOR mara-matkl.
SELECTION-SCREEN END OF BLOCK b1.

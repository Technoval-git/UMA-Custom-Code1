*&---------------------------------------------------------------------*
*& Include          YSCC_SELC
*&---------------------------------------------------------------------*
TABLES: mara,marc.


SELECTION-SCREEN BEGIN OF BLOCK input WITH FRAME TITLE TEXT-001.
  PARAMETERS:
   rb_upl RADIOBUTTON GROUP rb1 USER-COMMAND rb1sel,
              rb_upd RADIOBUTTON GROUP rb1,
              rb_rep RADIOBUTTON GROUP rb1 DEFAULT 'X' .

SELECTION-SCREEN END OF BLOCK input.

SELECTION-SCREEN BEGIN OF BLOCK ReortIP WITH FRAME TITLE TEXT-002 .

  SELECT-OPTIONS: s_matnr FOR mara-matnr MODIF ID upr.
      PARAMETERS: s_matkl type matkl MODIF ID upr. "            s_matkl FOR mara-matkl MODIF ID upr,
     SELECT-OPTIONS:  s_werks for marc-werks MODIF ID upr. "s_werks FOR marc-werks MODIF ID upr.
     SELECT-OPTIONS: s_matkl1 for mara-matkl no-DISPLAY, "            s_matkl FOR mara-matkl MODIF ID upr,
                   s_maabc FOR marc-maabc MODIF ID upr,
                  s_werks1 for marc-werks no-DISPLAY. "s_werks FOR marc-werks MODIF ID upr.

    PARAMETERS :p_region TYPE zmm_region MODIF ID upr..
  SELECTION-SCREEN BEGIN OF BLOCK upd WITH FRAME TITLE TEXT-003 .

  PARAMETERS: cb_sim TYPE xfeld AS CHECKBOX DEFAULT 'X' MODIF ID upd.

 SELECTION-SCREEN COMMENT /1(70) comm1 MODIF ID upd.

  SELECTION-SCREEN END OF BLOCK upd .

SELECTION-SCREEN END OF BLOCK ReortIP.

SELECTION-SCREEN BEGIN OF BLOCK upload WITH FRAME TITLE TEXT-004.
  PARAMETERS: P_file  TYPE dynpread-fieldname MODIF ID upl.
SELECTION-SCREEN END OF BLOCK upload.

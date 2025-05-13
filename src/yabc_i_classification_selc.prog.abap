*&---------------------------------------------------------------------*
*& Include          YABC_I_CLASSIFICATION_SELC
*&---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK input WITH FRAME TITLE TEXT-001.
  PARAMETERS: rb_upl RADIOBUTTON GROUP rb1 USER-COMMAND rb1sel,
              rb_upd RADIOBUTTON GROUP rb1 DEFAULT 'X',
              rb_rep RADIOBUTTON GROUP rb1  .

SELECTION-SCREEN END OF BLOCK input.

SELECTION-SCREEN BEGIN OF BLOCK ReortIP WITH FRAME TITLE TEXT-002 .

  SELECT-OPTIONS: s_matnr FOR mara-matnr MODIF ID upr,
                  s_matkl FOR mara-matkl MODIF ID upr OBLIGATORY,
                  s_maabc FOR marc-maabc MODIF ID upr,
                  s_werks FOR marc-werks MODIF ID upr ."OBLIGATORY.
  PARAMETERS :p_region TYPE zmm_region.

  SELECTION-SCREEN BEGIN OF BLOCK upd WITH FRAME TITLE TEXT-003 .

    PARAMETERS: cb_sim TYPE xfeld AS CHECKBOX DEFAULT 'X' MODIF ID upd .

  SELECTION-SCREEN END OF BLOCK upd .

SELECTION-SCREEN END OF BLOCK ReortIP.

SELECTION-SCREEN BEGIN OF BLOCK upload WITH FRAME TITLE TEXT-004.
  PARAMETERS: P_file  TYPE char20 MODIF ID upl.
SELECTION-SCREEN END OF BLOCK upload.

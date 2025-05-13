*&---------------------------------------------------------------------*
*& Include          ZIMM_RIMS_PARTS_OUT_DEC
*&---------------------------------------------------------------------*

DATA:gv_matkl TYPE matkl,
     gv_mtart TYPE mtart,
     gv_matnr TYPE matnr,
     gv_werks TYPE werks_d,
     gv_vkorg TYPE vkorg,
     gv_spart TYPE spart,
     gv_dismm TYPE dismm,
     gv_date  TYPE fkdat,
     gv_bsart TYPE bsart,
     gv_fkart TYPE fkart.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS : s_matnr FOR gv_matnr,
                   s_mtart FOR gv_mtart OBLIGATORY,
                   s_matkl FOR gv_matkl OBLIGATORY,
                   s_werks FOR gv_werks,
                   s_dismm FOR gv_dismm,
                   s_bsart FOR gv_bsart OBLIGATORY,
                   s_date  FOR gv_date OBLIGATORY,
*                   s_fkart FOR gv_fkart OBLIGATORY,
                   s_vkorg FOR gv_vkorg OBLIGATORY,
                   s_spart FOR gv_spart OBLIGATORY.
  PARAMETERS : p_dcode(10) TYPE c.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_fname  TYPE rlgrap-filename.
*              p_ftpfnm TYPE rlgrap-filename.
  PARAMETERS: p_infile  LIKE rlgrap-filename." DEFAULT  '/usr/sap/temp/RIMOUT'.

SELECTION-SCREEN END OF BLOCK b2.

TYPES: BEGIN OF ty_tab,
         string TYPE string,
       END OF ty_tab.

DATA : lt_tab TYPE STANDARD TABLE OF ty_tab,
       ls_tab TYPE ty_tab.

TYPES : BEGIN OF ty_vbeln,
          vbeln TYPE /dbe/vbeln_va,
        END OF ty_vbeln.

DATA : lt_vbeln  TYPE STANDARD TABLE OF ty_vbeln,
       ls_vbeln  TYPE ty_vbeln,
       lt_vbeln1 TYPE STANDARD TABLE OF ty_vbeln.

TYPES: BEGIN OF ty_date,
         dates TYPE sy-datum,
       END OF ty_date.

DATA : lt_date TYPE STANDARD TABLE OF ty_date,
       ls_date TYPE ty_date.

TYPES : BEGIN OF ty_monyear,
          monyear(6) TYPE c,
        END OF ty_monyear.

DATA : lt_monyear TYPE STANDARD TABLE OF ty_monyear,
       ls_monyear TYPE ty_monyear.

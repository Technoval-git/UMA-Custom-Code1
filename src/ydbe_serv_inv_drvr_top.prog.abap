*&---------------------------------------------------------------------*
*& Include          YDBE_SERV_INV_DRVR_TOP
*&---------------------------------------------------------------------*
*   INCLUDE RLB_INVOICE_DATA_DECLARE                                   *
*----------------------------------------------------------------------*

INCLUDE rvadtabl.

DATA:   retcode   LIKE sy-subrc.         "Returncode
DATA:   xscreen(1) TYPE c.               "Output on printer or screen
DATA:   repeat(1) TYPE c.
DATA: nast_anzal LIKE nast-anzal.      "Number of outputs (Orig. + Cop.)
DATA: nast_tdarmod LIKE nast-tdarmod.  "Archiving only one time

* current language for read buffered.
DATA: gf_language LIKE sy-langu.

DATA: it_header           TYPE yprfinv_head_vss_tt,
      gt_header           TYPE yprfinv_head_vss_tt,
      gs_header           TYPE yprfinv_head_vss_st,
      it_labor_details    TYPE yserv_inv_item_pdf_tt,
      it_parts_details    TYPE yserv_inv_item_pdf_tt,
      it_consumab_details TYPE yserv_inv_item_pdf_tt,
      it_addition_details TYPE yserv_inv_item_pdf_tt,
      lv_tax_perc         TYPE string,
      ts_ctrlparms        TYPE ssfctrlop,
      gs_customer         TYPE zsd_inv_head_mid,
      gs_company          TYPE zsd_inv_head_mid.
DATA:fp_docparams    TYPE sfpdocparams,    " Structure  SFPDOCPARAMS Short Description  Form Parameters for Form Processing
     fp_outputparams TYPE sfpoutputparams.

*&---------------------------------------------------------------------*
*& Include          ZVSS_ORDER_DETAIL_NEW_SCR
*&---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK b_1 WITH FRAME TITLE TEXT-000.

SELECT-OPTIONS: p_ordr FOR /DBE/vbak_db-vbeln MODIF ID gr1,   "DBE Order No.
                p_ddat FOR ekko-aedat  MODIF ID gr1 , "DBE Document Date   "remove mandatory
                p_sl_org FOR /DBE/vbak_db-vkorg MODIF ID gr1,        "sales org.

                p_pernr FOR /DBE/vbak_db-pernr MODIF ID gr1,   "Sales/Serv Adviser
                p_cust FOR /DBE/splhdr_db-kunnr MODIF ID gr3,     "customer
                p_prt_no FOR /DBE/vbap-matnr18 MODIF ID gr3,            "Part number
                p_plant FOR /DBE/vbak_db-werks  MODIF ID gr3 NO INTERVALS, "plant              "remove mandatory
                p_supp FOR /DBE/vbak_db-mfrnr MODIF ID gr2,   "supplier
                p_bsart FOR   ekko-bsart NO INTERVALS MODIF ID gr2, " PO type
                p_po FOR ekko-ebeln MODIF ID gr2,  "PO Order
                p_pdat FOR ekko-aedat MODIF ID gr2 ,  "Purchase Order Date
                p_esart FOR   eban-bsart NO INTERVALS MODIF ID gr2, "PR Type
                p_pr FOR ekpo-banfn MODIF ID gr2,   "Purchase Requistion

                p_mtart FOR ekpo-mtart NO INTERVALS DEFAULT 'YPOM' OBLIGATORY  MODIF ID gr3 .  "Material Type

PARAMETERS: p_rd1 RADIOBUTTON GROUP g1 DEFAULT 'X'  USER-COMMAND rad,
            p_rd2 RADIOBUTTON GROUP g1.
SELECTION-SCREEN SKIP.
PARAMETERS: p_email AS CHECKBOX DEFAULT ''.

DATA: lv_days TYPE pea_scrdd.

SELECTION-SCREEN END OF BLOCK b_1 .

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-group1 = 'GR1' .
      IF p_rd1 = 'X'.
        screen-input = 1.
        CLEAR:   p_po[],p_pr[] , p_pdat[], p_supp[],p_bsart[], p_esart[].
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ELSEIF   screen-group1 = 'GR2' .
      IF p_rd2 = 'X'.
        screen-input = 1.
        CLEAR: p_ordr[] , p_ddat[],p_sl_org[], p_pernr[] .
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ELSEIF   screen-group1 = 'GR3' .
      screen-input = 1.
      MODIFY SCREEN.
    ENDIF.
*  ENDIF.
  ENDLOOP.

  AT SELECTION-SCREEN .

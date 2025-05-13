*&---------------------------------------------------------------------*
*& Include          ZVSS_ORDER_DETAIL_NEW_SUB
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_order_details .

  TYPES: BEGIN OF ty_vbelnt,
           vbeln TYPE /DBE/vbeln_va,
         END OF ty_vbelnt.

  DATA: it_order_no_del TYPE  STANDARD TABLE OF ty_vbelnt,
        lw_order_no_del TYPE ty_vbelnt.
  CLEAR: it_order_no_del.

  CLEAR: it_po_t2.

  CLEAR: lw_vbak_com,lt_vbak_com,ra_ord.
  "Read the Order Items and filter from heade result
  SELECT vbak~vbeln erdat_tmstp   FROM /DBE/vbak_db AS vbak
          INNER JOIN /DBE/splhdr_db AS splhdr
          ON splhdr~vbeln = vbak~vbeln
          AND splhdr~splnr = 1
          INNER JOIN /DBE/vbap
          ON /DBE/vbap~vbeln = vbak~vbeln INTO CORRESPONDING FIELDS OF TABLE lt_vbak_com
          WHERE           vkorg             IN ra_vkorg
                    AND   vbak~werks             IN p_plant
                      AND   splhdr~kunnr             IN ra_kunnr
                      AND   vbak~vbeln        IN p_ordr
                      AND vbak~pernr IN ra_pernr
                    AND vbak~audat IN p_ddat
                    AND   vbak~engine IN ('CS', 'MM')
                      AND vbak~mfrnr IN ra_mfrnr
                      AND /DBE/vbap~matnr18 IN ra_matnr
          ORDER BY erdat_tmstp DESCENDING.

  SORT lt_vbak_com BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_vbak_com COMPARING vbeln.
  "to delete all billed DBE orders...
  IF  lt_vbak_com[] IS NOT INITIAL.
    CLEAR :it_order_no_del.
    SELECT vbeln FROM /DBE/oe_vbakst INTO TABLE it_order_no_del FOR ALL ENTRIES IN   lt_vbak_com WHERE vbeln =  lt_vbak_com-vbeln AND
                                                                                    action             = 'BILLING_CREATE' AND
                                                                                    status             = 'C'.


    IF sy-subrc EQ 0 AND it_order_no_del IS NOT INITIAL.
      LOOP AT it_order_no_del INTO lw_order_no_del.
*        cleaR: ls_vbak_com.
        READ TABLE lt_vbak_com TRANSPORTING NO FIELDS WITH KEY vbeln = lw_order_no_del-vbeln.
        IF sy-subrc EQ 0.
*          DELETE et_vbak_com INDEX sy-tabix.
          DELETE lt_vbak_com WHERE vbeln EQ lw_order_no_del-vbeln.  "to delete all billed DBE orders...
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

*----filling data DBEorder data....
  DATA: ls_orderlist LIKE LINE OF it_orderlist,
        ls_vbak_com  TYPE /DBE/vbak_com,
        ls_kna1      TYPE kna1.

  CLEAR: ls_orderlist,ls_vbak_com , ls_kna1 .
*--fetching all other data..
  IF lt_vbak_com IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbak_com  ##too_many_itab_fields
                                        FROM /DBE/vbak_db AS vbak
                                     INNER JOIN /DBE/splhdr_db AS splhdr
                                     ON splhdr~vbeln = vbak~vbeln
                                     AND splhdr~splnr = 1
                                     FOR ALL ENTRIES IN lt_vbak_com
                                          WHERE vbak~vbeln = lt_vbak_com-vbeln.
  ENDIF.

*--> fill the temporary fields in header structure
  CALL FUNCTION '/DBE/ORD_INT_FILL_HEADER_COM'
    EXPORTING
      iv_docflow               = space
      iv_mass_reading_call     = 'X'
      iv_skip_archived_vehicle = 'X'
    CHANGING
      ct_vbak_com              = lt_vbak_com
    EXCEPTIONS
      error_occured            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
*--> don't do anything, because it's mass-processing
  ENDIF.

*--> fill the orderlist
  LOOP AT lt_vbak_com INTO ls_vbak_com.
    CLEAR ls_orderlist.
    MOVE-CORRESPONDING ls_vbak_com TO ls_orderlist.
    APPEND ls_orderlist TO it_orderlist.
  ENDLOOP.
*--fetching vbap details...
  CLEAR: it_vbap.
  IF it_orderlist IS NOT INITIAL.    "ADDED BY ISMAIL
    SELECT vbeln
      matnr18
      posnr
      zmeng
      jobs
      FROM /DBE/vbap
      INTO TABLE it_vbap
      FOR ALL ENTRIES IN it_orderlist
      WHERE vbeln = it_orderlist-vbeln AND
            itcanc NE 'X'.   "added by ismail
    IF sy-subrc = 0.
      SORT it_vbap ASCENDING BY vbeln posnr matnr.
    ENDIF.
  ENDIF.

*--here fetching Purchase requisition
  LOOP AT lt_vbak_com INTO lw_vbak_com.
    ra_ord-low = lw_vbak_com-vbeln.
    CONCATENATE 'BUS2400*'  lw_vbak_com-vbeln '*' INTO ra_ord-low.
    ra_ord-option = 'CP'.
    ra_ord-sign = 'I'.
    APPEND ra_ord.
  ENDLOOP.

  CLEAR:  it_ord1.
  IF ra_ord IS NOT INITIAL.
    SELECT instid_a instid_b   "#EC CI_NO_TRANSFORM #EC CI_NO_TRANSFORM
   INTO TABLE  it_ord1
   FROM /DBE/ord_docflow
   WHERE instid_a IN ra_ord
   AND instid_b LIKE 'BUS2105%'.
  ENDIF.
  CLEAR : lt_ebant,lw_ebant.
  LOOP AT it_ord1 INTO DATA(wa_ord1).
    lw_ebant-banfn = wa_ord1-pr+13(10).
    lw_ebant-bnfpo = wa_ord1-pr+26(5).
    lw_ebant-vbeln = wa_ord1-DBE_ordr+10(10).
    lw_ebant-posnr = wa_ord1-DBE_ordr+20(6).
    APPEND  lw_ebant TO lt_ebant.
  ENDLOOP.

  IF lt_ebant IS NOT INITIAL.
    CLEAR: lt_ebantp.
    lt_ebantp[] = lt_ebant[].
    SORT lt_ebantp  BY  banfn.
    DELETE ADJACENT DUPLICATES FROM lt_ebantp COMPARING banfn.
    SELECT
          eban~banfn
          eban~bnfpo
          eban~bsart
          eban~menge
          eban~ebeln
          eban~ebelp
          FROM eban
          INTO CORRESPONDING FIELDS OF TABLE it_ban
          FOR ALL ENTRIES IN lt_ebantp
          WHERE eban~banfn = lt_ebantp-banfn.
    CLEAR: lt_ebantp.

    IF it_ban IS NOT INITIAL.
      CLEAR :it_po,it_po.
      SELECT
      ekpo~ebeln
      ekpo~ebelp
      ekpo~matnr
      ekpo~menge
      ekpo~werks
      ekpo~kunnr
      ekpo~mfrnr
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE it_po
        FOR ALL ENTRIES IN it_ban
      WHERE ekpo~ebeln EQ  it_ban-ebeln AND
            ekpo~ebelp EQ  it_ban-ebelp
      AND ekpo~loekz  EQ ''   "ismail
      AND ekpo~werks IN p_plant
      AND ekpo~matnr IN p_prt_no
      AND ekpo~aedat IN p_pdat
      AND ekpo~mtart IN p_mtart  "by ismail
      AND ekpo~bednr NE ''.

      FIELD-SYMBOLS : <fs_po> LIKE LINE OF it_po.
      LOOP AT it_po  ASSIGNING  <fs_po> .
        READ TABLE it_ban INTO DATA(ls_ban) WITH KEY ebeln = <fs_po>-ebeln ebelp = <fs_po>-ebelp.
        IF sy-subrc EQ 0.
          <fs_po>-banfn = ls_ban-banfn.
          <fs_po>-bnfpo = ls_ban-bnfpo.
          <fs_po>-bsart = ls_ban-bsart.
          <fs_po>-menge = ls_ban-menge.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDIF.

  IF   it_po IS NOT INITIAL. "by ismail
    CLEAR: it_ekko,it_eket,it_lips,it_vbup.
    SELECT
      ebeln
      lifnr
      frgke
      aedat
       bsart    "by ismail
      FROM ekko
      INTO TABLE it_ekko
      FOR ALL ENTRIES IN it_po
      WHERE ebeln = it_po-ebeln
      AND bsart IN  p_bsart    " added by ismail
      AND lifnr IN p_supp.

    SELECT
    ebeln
    ebelp
    eindt
    FROM eket
    INTO TABLE it_eket
    FOR ALL ENTRIES IN it_po
    WHERE ebeln = it_po-ebeln
      AND ebelp = it_po-ebelp+1(5).

    SELECT
    i~vgbel
    i~vgpos
    i~vbeln
    i~posnr
    i~erdat
    h~vbtyp
    FROM lips AS i
    INNER JOIN likp AS h
    ON i~vbeln = h~vbeln
    INTO TABLE it_lips
    FOR ALL ENTRIES IN it_po
    WHERE vgbel = it_po-ebeln
    AND vgpos = it_po-ebelp.

    IF it_lips IS NOT INITIAL.
      SELECT
        vbeln
        posnr
        wbsta
         FROM vbup
         INTO TABLE it_vbup
        FOR ALL ENTRIES IN it_lips
         WHERE vbeln = it_lips-vbeln
         AND posnr = it_lips-posnr.
    ENDIF.
  ENDIF. "by ismail


*------------preparing final
  SORT it_orderlist BY vbeln .
  CLEAR: lt_t16fb,lw_t16fb.
  SELECT *
    FROM t16fb
    INTO TABLE lt_t16fb.
  IF sy-subrc = 0.
    SORT lt_t16fb.
  ENDIF.

*---------activated becuase  *---adding new logic by ismail for delevery status.....
  CLEAR: it_lips1,it_vbup1.
*  IF it_vbap IS NOT INITIAL.
*    SELECT
*    i~vgbel
*    i~vgpos
*    i~vbeln
*    i~posnr
*    i~matnr
*    i~erdat
*       i~/DBE/vbeln
*      i~/DBE/posnr
*    h~vbtyp
*    FROM lips AS i
*    INNER JOIN likp AS h
*    ON i~vbeln = h~vbeln
*    INTO TABLE it_lips1
*    FOR ALL ENTRIES IN it_vbap
*    WHERE matnr = it_vbap-matnr AND
**          werks IN  p_plant AND
*          /DBE/vbeln = it_vbap-vbeln
*    AND /DBE/posnr = it_vbap-posnr.

  CLEAR: lt_ebant2,ra_ord[] .
  lt_ebant2[] = lt_ebant[].
  SORT  lt_ebant2 BY vbeln.
  DELETE ADJACENT DUPLICATES FROM  lt_ebant2 COMPARING vbeln.
*--here fetching Purchase requisition
  LOOP AT lt_ebant2 INTO DATA(wa2).
    CONCATENATE 'BUS2400*'  wa2-vbeln '*' INTO ra_ord-low.
    ra_ord-option = 'CP'.
    ra_ord-sign = 'I'.
    APPEND ra_ord.
  ENDLOOP.
  CLEAR: it_ord_lips.
  IF ra_ord IS NOT INITIAL.
    SELECT instid_a instid_b   "#EC CI_NO_TRANSFORM #EC CI_NO_TRANSFORM
   INTO TABLE  it_ord_lips
   FROM /DBE/ord_docflow
   WHERE instid_a IN ra_ord
   AND instid_b LIKE 'LIKP%'.
  ENDIF.
  CLEAR : it_lips1,it_lips2.
  DATA: lw_lips1 LIKE LINE OF it_lips1.
  LOOP AT it_ord_lips INTO DATA(wa_ord_lips).
    CLEAR: lw_lips1.
    lw_lips1-vbeln = wa_ord_lips-pr+13(10).
    lw_lips1-posnr = wa_ord_lips-pr+29(2).
*    lw_ebant-vbeln = wa_ord_LIPS-DBE_ordr+10(10).
*    lw_ebant-posnr = wa_ord_LIPS-DBE_ordr+20(6).
    APPEND   lw_lips1 TO it_lips2.
  ENDLOOP.

  "Read LiPS from LIKP Header table
  IF it_lips2 IS NOT INITIAL.
    "Read VBUP from LIKP - VBELN header table
    SELECT
    i~vbeln
    i~posnr
    i~matnr
    i~erdat
    i~vgbel
    i~vgpos
     i~/DBE/vbeln
    i~/DBE/posnr
*    h~vbtyp
    FROM lips AS i
*    INNER JOIN likp AS h
*    ON i~vbeln = h~vbeln
    INTO CORRESPONDING FIELDS OF TABLE it_lips1
    FOR ALL ENTRIES IN it_lips2
    WHERE
*          matnr = it_vbap-matnr AND
*          werks IN  p_plant AND
           vbeln = it_lips2-vbeln.
*    AND /DBE/posnr = it_vbap-posnr.

    IF sy-subrc EQ 0.
      it_lips1_t[] = it_lips1[].
      SORT it_lips1_t BY vbeln.
      DELETE ADJACENT DUPLICATES FROM it_lips1_t COMPARING vbeln.
*    ENDIF.
      SELECT
        vbeln
        vbtyp
        FROM likp INTO TABLE it_likp_h  FOR ALL ENTRIES IN it_lips1_t
                                      WHERE vbeln = it_lips1_t-vbeln.


      FIELD-SYMBOLS : <fs_lips1> LIKE LINE OF it_lips1.
      LOOP AT it_lips1  ASSIGNING <fs_lips1>.
        READ TABLE it_likp_h INTO DATA(wa) WITH KEY vbeln = <fs_lips1>-vbeln.
        IF sy-subrc EQ 0.
          <fs_lips1>-vbtyv  =  wa-vbtyp.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF it_lips1 IS NOT INITIAL.
      SELECT
        vbeln
        posnr
        wbsta
         FROM vbup
         INTO TABLE it_vbup1
        FOR ALL ENTRIES IN it_lips1
         WHERE vbeln = it_lips1-vbeln
         AND posnr = it_lips1-posnr.
    ENDIF.
  ENDIF.
*ENDIF.

*  SORT lt_ebant BY banfn bnfpo.
*  LOOP AT lt_ebant INTO lw_ebant.
*
*    READ TABLE it_ban INTO ls_ban
*    WITH KEY banfn = lw_ebant-banfn bnfpo = lw_ebant-bnfpo.
*    IF sy-subrc = 0.
*      "Fill the PR details
*      ts_order-banfn = ls_ban-banfn.
*      ts_order-bnfpo = ls_ban-bnfpo.
*
*      "Read the Purchase Order details
*      READ TABLE it_po INTO ts_po WITH KEY ebeln = ls_ban-ebeln ebelp = ls_ban-ebelp.
*      IF sy-subrc = 0.
*        ts_order-bstnk = ts_po-ebeln.
*        ts_order-ebelp = ts_po-ebelp.
**        ts_order-banfn = ts_po-banfn.
**        ts_order-bnfpo = ts_po-bnfpo.
*        ts_order-mfrnr = ts_po-mfrnr.
**    ts_order-po_quan = ts_po-po_quan.
*        ts_order-po_quan = ts_po-menge.
*        ts_order-pr_quan = ts_po-pr_quan.
*        ts_order-eb_bsart = ts_po-bsart. " by ismail
*
*        CONCATENATE ts_po-ebeln ts_po-ebelp+1(5) INTO tdnam.
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            id                      = tdid
*            language                = tdspras
*            name                    = tdnam
*            object                  = tdobject
*          TABLES
*            lines                   = tdlines
*          EXCEPTIONS
*            id                      = 1
*            language                = 2
*            name                    = 3
*            not_found               = 4
*            object                  = 5
*            reference_check         = 6
*            wrong_access_to_archive = 7
*            OTHERS                  = 8.
*        IF sy-subrc = 0.
*          READ TABLE tdlines
*          INTO ts_lines INDEX 1.
*          IF sy-subrc = 0.
*            ts_order-po_text = ts_lines-tdline.
*          ENDIF.
*        ENDIF.
*        CALL FUNCTION 'CONVERSION_EXIT_MATN2_OUTPUT'
*          EXPORTING
*            input  = ts_po-matnr
*          IMPORTING
*            output = ts_order-matnr.
*
*        READ TABLE it_ekko
*          INTO ts_ekko
*          WITH KEY ebeln = ts_po-ebeln.
*        IF sy-subrc = 0.
*          ts_order-lifnr = ts_ekko-lifnr.
*          ts_order-po_date = ts_ekko-aedat.
*          ts_order-ek_bsart = ts_ekko-bsart. "by ismail
*        ENDIF.
*
*
**----added by ismail to fileter only thos doc type entered in selection screen
*
*        IF ts_order-ek_bsart NOT IN p_bsart OR  ts_order-eb_bsart NOT IN  p_esart.
*          CONTINUE.
*        ENDIF.
*
**-- end of addition by ismail
*
*        CLEAR: ts_lips.
*        READ TABLE it_lips
*        INTO ts_lips
*        WITH KEY ebeln = ts_po-ebeln
*        ebelp = ts_po-ebelp
*        vbtyv = 'J'.
*        IF sy-subrc = 0.
*          ts_order-outb_no = ts_lips-vbeln.
*          ts_order-outb_item = ts_lips-posnr.
*          ts_order-outb_dat = ts_lips-erdat.
*        ENDIF.
*
*        CLEAR: ts_lips.
*        READ TABLE it_lips
*        INTO ts_lips
*        WITH KEY ebeln = ts_po-ebeln
*        ebelp = ts_po-ebelp
*        vbtyv = '7'.
*        IF sy-subrc = 0.
*          ts_order-inb_no = ts_lips-vbeln.
*          ts_order-inb_item = ts_lips-posnr.
*          ts_order-inb_dat = ts_lips-erdat.
*        ENDIF.
*
*        CLEAR: ts_order-po_status.
*        IF ts_order-inb_no IS NOT INITIAL OR ts_order-outb_no IS NOT INITIAL.
*          IF ts_order-inb_no IS NOT INITIAL AND ts_order-inb_item IS NOT INITIAL.
*            READ TABLE it_vbup TRANSPORTING NO FIELDS
*              WITH KEY vbeln = ts_order-inb_no
*                       posnr = ts_order-inb_item
*                       wbsta = 'C'.
*            IF sy-subrc = 0 .
*              ts_order-po_status = 'GR Completed'.
*            ELSEIF ts_order-outb_no IS NOT INITIAL AND ts_order-outb_item IS NOT INITIAL.
*              READ TABLE it_vbup TRANSPORTING NO FIELDS
*                WITH KEY vbeln = ts_order-outb_no
*                         posnr = ts_order-outb_item
*                         wbsta = 'C'.
*              IF sy-subrc <> 0.
*                ts_order-po_status = 'Outbound Created'.
*              ELSE.
*                ts_order-po_status = 'Inbound Created'.
*              ENDIF.
*
*            ELSE. "added by ismail....to fix status inbound creation
*              ts_order-po_status = 'Inbound Created'.
*            ENDIF.
*          ELSE.
*            READ TABLE it_vbup TRANSPORTING NO FIELDS
*              WITH KEY vbeln = ts_order-outb_no
*               posnr = ts_order-outb_item
*               wbsta = 'C'.
*            IF sy-subrc = 0.
*              ts_order-po_status = 'GI Completed'.
*            ELSE.
*              ts_order-po_status = 'Outbound Created'.
*            ENDIF.
*          ENDIF.
*
*        ELSEIF ts_ekko-ebeln IS NOT INITIAL.
*
*          CLEAR: lw_t16fb  .
*          READ TABLE lt_t16fb INTO lw_t16fb WITH KEY frgke = ts_ekko-frgke.
*          IF sy-subrc EQ 0.
**      IF ts_ekko-frgke = 'R'.
*            IF lw_t16fb-kzfre IS NOT INITIAL.
*              ts_order-po_status = 'PO Released'.
*            ELSE.
*              ts_order-po_status = 'PO yet to Release'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
*        READ TABLE it_eket
*        INTO ts_eket
*        WITH KEY ebeln = ts_po-ebeln
*        ebelp = ts_po-ebelp+1(5).
*        IF sy-subrc = 0.
*          IF ts_lips-erdat IS NOT INITIAL AND
*            ts_eket-eindt IS NOT INITIAL.
*            IF ts_eket-eindt < ts_lips-erdat.
*              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
*                EXPORTING
*                  date1         = ts_lips-erdat
*                  date2         = ts_eket-eindt
*                  output_format = '03'
*                IMPORTING
*                  days          = lv_day.
*            ELSE.
*              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
*                EXPORTING
*                  date1         = ts_eket-eindt
*                  date2         = ts_lips-erdat
*                  output_format = '03'
*                IMPORTING
*                  days          = lv_day.
*            ENDIF.
*            ts_order-dif_dt = lv_day .
*            CLEAR :lv_day.
*          ENDIF.
*          CONCATENATE  ts_eket-eindt+6(2) '.' ts_eket-eindt+4(2) '.' ts_eket-eindt+0(4) INTO ts_order-exdate.
**      ts_order-exdate = ts_eket-eindt.
*        ENDIF.
**
**        CLEAR: lw_ebant.
**        READ TABLE lt_ebant
**        INTO lw_ebant
**        WITH KEY banfn = ts_po-banfn bnfpo = ts_po-bnfpo.
**        IF sy-subrc = 0.
*      ENDIF.
*      READ TABLE it_orderlist INTO ts_orderlist
*      WITH KEY vbeln = lw_ebant-vbeln.
*      IF sy-subrc = 0.
*        MOVE-CORRESPONDING ts_orderlist TO ts_order.
*        ts_order-bstnk = ts_po-ebeln.
*        ts_order-ebelp = ts_po-ebelp.
**        ts_order-banfn = ts_po-banfn.
**        ts_order-po_quan = ts_po-po_quan.
*        ts_order-po_quan = ts_po-menge.
*
**            LOOP AT it_vbap
**              INTO ts_vbap
**              WHERE vbeln = lw_ebant-vbeln
**          AND posnr = lw_ebant-posnr.
**              AND matnr = ts_po-matnr.
*        "Read the DBE order details
*        READ TABLE it_vbap INTO ts_vbap
*          WITH KEY vbeln = lw_ebant-vbeln
*          posnr = lw_ebant-posnr.
*        IF sy-subrc = 0.
*          ts_order-posnr = ts_vbap-posnr.
*          ts_order-ord_quan = ts_vbap-zmeng.
*
**---adding new logic by ismail for delevery status.....
*          CLEAR: ts_lips1,ts_order-del_stat.
*          READ TABLE it_lips1
*          INTO ts_lips1
*          WITH KEY /DBE/vbeln = ts_vbap-vbeln
*                  /DBE/posnr = ts_vbap-posnr.
*          IF sy-subrc EQ 0.
*            ts_order-del_stat = 'Delivery Created'.
*            READ TABLE it_vbup1 TRANSPORTING NO FIELDS
*              WITH KEY vbeln = ts_lips1-vbeln
*                       posnr = ts_lips1-posnr
*                       wbsta = 'C'.
*            IF sy-subrc = 0 .
*              ts_order-del_stat = 'Goods issued'.
*            ENDIF.
*          ENDIF.
**            APPEND ts_order TO it_order.
**            lv_flag = 1.
**        ENDLOOP.
*        ENDIF.
*      ENDIF.
**        ENDIF.
**--Commenting by ismail to not to show if it is not DBE order....
**    IF lv_flag = 0.
**      APPEND ts_order TO it_order.
**    ELSE.
**      lv_flag = 0.
**    ENDIF.
*
*
*      APPEND ts_order TO it_order.
*      CLEAR :ts_order,
*              ts_po,
*              ts_ekko,
*              ts_eket,
*              ts_lips,
*              ts_vbup,
*              ts_vbap,
*              ts_vbeln_pr,
*              ts_orderlist.
*
*    ENDIF.
*  ENDLOOP.


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_RANGE_TBL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_range_tbl .
* prepare range table for FM
  LOOP AT p_cust.
    ts_kunnr-sign = p_cust-sign.
    ts_kunnr-option = p_cust-option.
    ts_kunnr-low = p_cust-low.
    ts_kunnr-high = p_cust-high.
    APPEND ts_kunnr TO ra_kunnr.
  ENDLOOP.
  LOOP AT p_ordr.
    ts_vbeln-sign = p_ordr-sign.
    ts_vbeln-option = p_ordr-option.
    ts_vbeln-low = p_ordr-low.
    ts_vbeln-high = p_ordr-high.
    APPEND ts_vbeln TO ra_vbeln.
  ENDLOOP.
  LOOP AT p_prt_no.
    ts_matnr-sign = p_prt_no-sign.
    ts_matnr-option = p_prt_no-option.
    ts_matnr-low = p_prt_no-low.
    ts_matnr-high = p_prt_no-high.
    APPEND ts_matnr TO ra_matnr.
  ENDLOOP.
  LOOP AT p_plant.
    ts_werks-sign = p_plant-sign.
    ts_werks-option = p_plant-option.
    ts_werks-low = p_plant-low.
    ts_werks-high = p_plant-high.
    APPEND ts_werks TO ra_werks.
  ENDLOOP.
  LOOP AT p_sl_org.
    ts_vkorg-sign = p_sl_org-sign.
    ts_vkorg-option = p_sl_org-option.
    ts_vkorg-low = p_sl_org-low.
    ts_vkorg-high = p_sl_org-high.
    APPEND ts_vkorg TO ra_vkorg.
  ENDLOOP.
  LOOP AT p_supp.
    ts_mfrnr-sign = p_supp-sign.
    ts_mfrnr-option = p_supp-option.
    ts_mfrnr-low = p_supp-low.
    ts_mfrnr-high = p_supp-high.
    APPEND ts_mfrnr TO ra_mfrnr.
  ENDLOOP.
  LOOP AT p_po.
    ts_ebeln-sign = p_po-sign.
    ts_ebeln-option = p_po-option.
    ts_ebeln-low = p_po-low.
    ts_ebeln-high = p_po-high.
    APPEND ts_ebeln TO ra_ebeln.
  ENDLOOP.
  LOOP AT p_pr.
    ts_pr-sign = p_pr-sign.
    ts_pr-option = p_pr-option.
    ts_pr-low = p_pr-low.
    ts_pr-high = p_pr-high.
    APPEND ts_pr TO ra_pr.
  ENDLOOP.
  LOOP AT p_pernr.
    ts_pernr-sign = p_pernr-sign.
    ts_pernr-option = p_pernr-option.
    ts_pernr-low = p_pernr-low.
    ts_pernr-high = p_pernr-high.
    APPEND ts_pernr TO ra_pernr.
  ENDLOOP.

*--added by ismail
  LOOP AT p_ddat.
    ts_ddate-sign = p_ddat-sign.
    ts_ddate-option = p_ddat-option.
    ts_ddate-low = p_ddat-low.
    ts_ddate-high = p_ddat-high.
    APPEND ts_ddate TO ra_ddate.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_VBAP_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_vbap_details .

  IF it_orderlist IS NOT INITIAL.    "ADDED BY ISMAIL
    SELECT vbeln
      matnr18
      posnr
      zmeng
      jobs
      FROM /DBE/vbap
      INTO TABLE it_vbap
      FOR ALL ENTRIES IN it_orderlist
      WHERE vbeln = it_orderlist-vbeln AND
            itcanc NE 'X'.   "added by ismail
    IF sy-subrc = 0.
      SORT it_vbap ASCENDING BY vbeln posnr matnr.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_PO_ADD_DET_INB_DETS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_po_add_det_inb_dets .


  IF   it_po IS NOT INITIAL. "by ismail
    SELECT
      ebeln
      lifnr
      frgke
      aedat
       bsart    "by ismail
      FROM ekko
      INTO TABLE it_ekko
      FOR ALL ENTRIES IN it_po
      WHERE ebeln = it_po-ebeln
      AND bsart IN  p_bsart    " added by ismail
      AND lifnr IN p_supp.

    SELECT
    ebeln
    ebelp
    eindt
    FROM eket
    INTO TABLE it_eket
    FOR ALL ENTRIES IN it_po
    WHERE ebeln = it_po-ebeln
      AND ebelp = it_po-ebelp+1(5).

    SELECT
    i~vgbel
    i~vgpos
    i~vbeln
    i~posnr
    i~erdat
    h~vbtyp
    FROM lips AS i
    INNER JOIN likp AS h
    ON i~vbeln = h~vbeln
    INTO TABLE it_lips
    FOR ALL ENTRIES IN it_po
    WHERE vgbel = it_po-ebeln
    AND vgpos = it_po-ebelp.

    IF it_lips IS NOT INITIAL.
      SELECT
        vbeln
        posnr
        wbsta
         FROM vbup
         INTO TABLE it_vbup
        FOR ALL ENTRIES IN it_lips
         WHERE vbeln = it_lips-vbeln
         AND posnr = it_lips-posnr.
    ENDIF.
  ENDIF. "by ismail
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_alv .
  DATA : wa_layout             TYPE slis_layout_alv,
         it_order_alv_fieldcat TYPE slis_t_fieldcat_alv.

  DATA : it_events2 TYPE slis_t_event.
  DATA : ts_events2 TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    IMPORTING
      et_events = it_events2.

* To set header
  READ TABLE it_events2 INTO ts_events2
     WITH KEY name = slis_ev_top_of_page .
  ts_events2-form = slis_ev_top_of_page .
  MODIFY it_events2 FROM ts_events2 INDEX sy-tabix .

*  for hotspot
  ts_events2-name =  TEXT-u01.
  ts_events2-form = TEXT-u01.
  APPEND ts_events2 TO it_events2.

  wa_layout-colwidth_optimize = abap_true .
  PERFORM f_create_fcat CHANGING it_order_alv_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program    = sy-repid
      is_layout             = wa_layout
      it_fieldcat           = it_order_alv_fieldcat "PASS FIELD CATALOG TO ALV
      i_screen_start_column = 0
      i_screen_start_line   = 0
      i_screen_end_column   = 0
      i_screen_end_line     = 0
      i_save                = 'X'
      it_events             = it_events2
    TABLES
      t_outtab              = it_order
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_fcat CHANGING it_order_alv_fieldcat TYPE slis_t_fieldcat_alv.
*VELO03_FIELDCATALOG_MERGE
  DATA : it_fieldcat           TYPE lvc_t_fcat,
         ts_fieldcat           TYPE lvc_s_fcat,
         ts_order_alv_fieldcat TYPE slis_fieldcat_alv,
         lv_count              TYPE int3 VALUE 1.

  FIELD-SYMBOLS : <fs__order_alv_fieldcat> LIKE LINE OF it_order_alv_fieldcat.

  CALL FUNCTION 'VELO03_FIELDCATALOG_MERGE'
    EXPORTING
      structure_name_iv       = '/DBE/ORDERLIST_ICON'
      client_never_display_iv = 'X'
    CHANGING
      fieldcat_ct             = it_fieldcat
    EXCEPTIONS
      error_occured           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT it_fieldcat INTO ts_fieldcat.
    ts_order_alv_fieldcat-col_pos = ts_fieldcat-col_pos.
    ts_order_alv_fieldcat-fieldname = ts_fieldcat-fieldname.
    ts_order_alv_fieldcat-seltext_l = ts_fieldcat-scrtext_l.
    ts_order_alv_fieldcat-seltext_m = ts_fieldcat-scrtext_m.
    ts_order_alv_fieldcat-seltext_s = ts_fieldcat-scrtext_s.
    ts_order_alv_fieldcat-outputlen = ts_fieldcat-outputlen.
    IF ts_order_alv_fieldcat-fieldname = 'VGUID' OR
       ts_order_alv_fieldcat-fieldname = 'SLCTD' OR
       ts_order_alv_fieldcat-fieldname = 'CI_DBE_ORDERLIST' OR
       ts_order_alv_fieldcat-fieldname = 'VALID_FR_TSTMP' OR
       ts_order_alv_fieldcat-fieldname = 'VALID_TO_TSTMP'.
      ts_order_alv_fieldcat-tech = abap_true..
    ENDIF.
    IF ts_order_alv_fieldcat-fieldname = 'ICON_TEST_DRIVE'.
      ts_order_alv_fieldcat-icon         = abap_true.
      ts_order_alv_fieldcat-outputlen    = '2'.
    ENDIF.
    IF ts_order_alv_fieldcat-fieldname = 'HEADER_STATUS_ICON'.
      ts_order_alv_fieldcat-icon = abap_true.               "N:1784651
    ENDIF.
    APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
    CLEAR ts_order_alv_fieldcat.
  ENDLOOP.

  LOOP AT it_order_alv_fieldcat ASSIGNING <fs__order_alv_fieldcat>.
    IF <fs__order_alv_fieldcat>-fieldname = 'BSTNK'.
      <fs__order_alv_fieldcat>-SELTEXT_S = 'Purchase PO'.
       <fs__order_alv_fieldcat>-SELTEXT_M = 'Purchase PO'.
      <fs__order_alv_fieldcat>-col_pos = 8.
      <fs__order_alv_fieldcat>-hotspot = abap_true.
      lv_count = lv_count - 1.
    ELSEIF <fs__order_alv_fieldcat>-fieldname = 'HSTAT'.
      <fs__order_alv_fieldcat>-col_pos = 4.
      lv_count = lv_count - 1.
    ELSE.
      <fs__order_alv_fieldcat>-col_pos = lv_count.
    ENDIF.
    IF <fs__order_alv_fieldcat>-fieldname = 'VBELN'.
      <fs__order_alv_fieldcat>-col_pos = 1.
      <fs__order_alv_fieldcat>-hotspot = abap_true.
    ENDIF.
    .
    IF lv_count <> 1.
      lv_count = lv_count + 1.
    ELSE.
      lv_count = 21.
    ENDIF.
  ENDLOOP.

  ts_order_alv_fieldcat-col_pos = 2.
  ts_order_alv_fieldcat-fieldname = 'POSNR'.
*  ts_order_alv_fieldcat-hotspot = abap_true.
  ts_order_alv_fieldcat-seltext_l = TEXT-209.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 3.
  ts_order_alv_fieldcat-fieldname = 'JOBS'.
  ts_order_alv_fieldcat-seltext_l = TEXT-221.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 4.
  ts_order_alv_fieldcat-fieldname = 'ORD_QUAN'.
  ts_order_alv_fieldcat-seltext_l = TEXT-210.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.



  ts_order_alv_fieldcat-col_pos = 5.
  ts_order_alv_fieldcat-fieldname = 'BANFN'.
  ts_order_alv_fieldcat-hotspot = abap_true.
  ts_order_alv_fieldcat-seltext_l = TEXT-202.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.


  ts_order_alv_fieldcat-col_pos = 6.
  ts_order_alv_fieldcat-fieldname = 'BNFPO'.
  ts_order_alv_fieldcat-seltext_l = TEXT-206.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 7.
  ts_order_alv_fieldcat-fieldname = 'PR_QUAN'.
  ts_order_alv_fieldcat-seltext_l = TEXT-208.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 9.
  ts_order_alv_fieldcat-fieldname = 'EBELP'.
  ts_order_alv_fieldcat-seltext_l = TEXT-205.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 10.
  ts_order_alv_fieldcat-fieldname = 'PO_QUAN'.
  ts_order_alv_fieldcat-seltext_l = TEXT-207.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 11.
  ts_order_alv_fieldcat-fieldname = 'PO_STATUS'.
  ts_order_alv_fieldcat-seltext_l = TEXT-211.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 12.
  ts_order_alv_fieldcat-fieldname = 'PO_DATE'.
  ts_order_alv_fieldcat-seltext_l = TEXT-215.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 13.
  ts_order_alv_fieldcat-fieldname = 'PO_TEXT'.
  ts_order_alv_fieldcat-seltext_l = TEXT-217.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 14.
  ts_order_alv_fieldcat-fieldname = 'INB_NO'.
  ts_order_alv_fieldcat-hotspot = abap_true.
  ts_order_alv_fieldcat-seltext_l = TEXT-212.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 15.
  ts_order_alv_fieldcat-fieldname = 'INB_ITEM'.
  ts_order_alv_fieldcat-seltext_l = TEXT-213.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 16.
  ts_order_alv_fieldcat-fieldname = 'INB_DAT'.
  ts_order_alv_fieldcat-seltext_l = TEXT-214.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 17.
  ts_order_alv_fieldcat-fieldname = 'MATNR'.
  ts_order_alv_fieldcat-hotspot = abap_true.
  ts_order_alv_fieldcat-seltext_l = TEXT-201.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 18.
  ts_order_alv_fieldcat-fieldname = 'EXDATE'.
  ts_order_alv_fieldcat-seltext_l = TEXT-204.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 19.
  ts_order_alv_fieldcat-fieldname = 'DIF_DT'.
  ts_order_alv_fieldcat-seltext_l = TEXT-216.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

*---added by ismail
  ts_order_alv_fieldcat-col_pos = 20.
  ts_order_alv_fieldcat-fieldname = 'EK_BSART'.
  ts_order_alv_fieldcat-seltext_l = TEXT-219.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 21.
  ts_order_alv_fieldcat-fieldname = 'EB_BSART'.
  ts_order_alv_fieldcat-seltext_l = TEXT-218.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

  ts_order_alv_fieldcat-col_pos = 22.
  ts_order_alv_fieldcat-fieldname = 'DEL_STAT'.
  ts_order_alv_fieldcat-seltext_l = TEXT-220.
  APPEND ts_order_alv_fieldcat TO it_order_alv_fieldcat.
  CLEAR ts_order_alv_fieldcat.

*-- end of addition

ENDFORM.
FORM user_command USING p_ucomm LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.
  DATA: rxm0_35 TYPE i.

  DATA ts_order TYPE ty_vbak_com.
  IF  rs_selfield-fieldname = 'VBELN' AND rs_selfield-value IS NOT INITIAL.
    READ TABLE it_order INTO ts_order INDEX rs_selfield-tabindex.
    IF sy-subrc = 0.
      PERFORM f_navigate_to_DBEorder USING ts_order.
    ENDIF.
  ENDIF.
  IF  rs_selfield-fieldname = 'BSTNK' AND rs_selfield-value IS NOT INITIAL.
    READ TABLE it_order INTO ts_order INDEX rs_selfield-tabindex.
    IF sy-subrc = 0.
      PERFORM f_navigate_to_porder USING ts_order.
    ENDIF.
  ENDIF.
  IF  rs_selfield-fieldname = 'BANFN'AND rs_selfield-value IS NOT INITIAL.
    READ TABLE it_order INTO ts_order INDEX rs_selfield-tabindex.
    IF sy-subrc = 0.
      PERFORM f_navigate_to_pr USING ts_order.
    ENDIF.
  ENDIF.
  IF  rs_selfield-fieldname = 'MATNR'AND rs_selfield-value IS NOT INITIAL.
    READ TABLE it_order INTO ts_order INDEX rs_selfield-tabindex.
    IF sy-subrc = 0.
      PERFORM f_navigate_to_mm03 USING ts_order.
    ENDIF.
  ENDIF.
  IF  rs_selfield-fieldname = 'INB_NO' AND rs_selfield-value IS NOT INITIAL.
    READ TABLE it_order INTO ts_order INDEX rs_selfield-tabindex.
    IF sy-subrc = 0.
      PERFORM f_navigate_to_inb USING ts_order.
    ENDIF.
  ENDIF.
ENDFORM.
FORM f_navigate_to_DBEorder  USING    p_ts_alv1 TYPE ty_vbak_com.

  SET PARAMETER ID '/DBE/ORDER_NUMBER' FIELD p_ts_alv1-vbeln.
  CALL TRANSACTION '/DBE/ORDER03' AND SKIP FIRST SCREEN.
ENDFORM.
FORM f_navigate_to_mm03  USING    p_ts_alv1 TYPE ty_vbak_com.
  SET PARAMETER ID 'MAT' FIELD  p_ts_alv1-matnr.

  SET PARAMETER ID 'MXX' FIELD 'K'.

  CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
ENDFORM.
FORM f_navigate_to_porder  USING    p_ts_alv1 TYPE ty_vbak_com.
  DATA lv_ebeln TYPE ebeln.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_ts_alv1-bstnk
    IMPORTING
      output = lv_ebeln.

  SET PARAMETER ID 'BES' FIELD lv_ebeln .

  CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
ENDFORM.
FORM f_navigate_to_pr  USING    p_ts_alv1 TYPE ty_vbak_com.
  SET PARAMETER ID 'BAN' FIELD p_ts_alv1-banfn.
  CALL TRANSACTION 'ME53N'AND SKIP FIRST SCREEN.
ENDFORM.
FORM f_navigate_to_inb  USING    p_ts_alv1 TYPE ty_vbak_com.
  SET PARAMETER ID 'VLM' FIELD p_ts_alv1-inb_no.
  CALL TRANSACTION 'VL33N'AND SKIP FIRST SCREEN.
ENDFORM.
FORM top_of_page .

  DATA: it_header  TYPE slis_t_listheader,
        wa_header  TYPE slis_listheader,
        lv_lines   TYPE int8,
        lv_date    TYPE char15,
        lv_date_to TYPE char15,
        lv_tem     TYPE string.
  DESCRIBE TABLE it_order LINES lv_lines.
  CONCATENATE  sy-datum+6(2) '-' sy-datum+4(2) '-' sy-datum+0(4) INTO lv_date.
  wa_header-typ = 'S'.
  wa_header-key = TEXT-t03.
  wa_header-info = lv_lines.
  APPEND wa_header TO it_header.
  CLEAR wa_header.

  wa_header-typ = 'S'.
  wa_header-key = TEXT-t04.
  wa_header-info = lv_date.
  APPEND wa_header TO it_header.
  CLEAR wa_header.

  wa_header-typ = 'S'.
  wa_header-key =  TEXT-t05.
  wa_header-info = sy-uname.
  APPEND wa_header TO it_header.
  CLEAR wa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_header.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_PO_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_po_details .

  TYPES: BEGIN OF ty_vbelnt,
           vbeln TYPE /DBE/vbeln_va,
         END OF ty_vbelnt.

  DATA: it_order_no_del TYPE  STANDARD TABLE OF ty_vbelnt,
        lw_order_no_del TYPE ty_vbelnt.
  CLEAR: it_order_no_del.

  CLEAR: it_po_t2.
  DATA:
    ts_po  TYPE ty_po,
    ts_po1 TYPE ty_po,
    ts_ban TYPE ty_ban.
  PERFORM f_prepare_range_tbl.
  DATA: it_po_t2      TYPE TABLE OF ty_po.
  FIELD-SYMBOLS : <fs_po> LIKE LINE OF it_po_t.

  CLEAR: it_po_t2.


  CLEAR :it_po_t,it_ban_t,it_po.
  " Only if eithr Purchase Order or Purchase Ordr Date
  IF p_po IS NOT INITIAL OR
    p_pdat IS NOT INITIAL.

    CLEAR: it_ekko_t,it_po.
    SELECT
   ebeln
   lifnr
   frgke
   aedat
    bsart    "by ismail
   FROM ekko
   INTO TABLE it_ekko_t
   WHERE ebeln  IN p_po
  AND  aedat IN p_pdat
   AND bsart IN  p_bsart    " added by ismail
   AND lifnr IN p_supp.
*   AND   frgke NE ''.

    IF sy-subrc EQ 0.
      SELECT
      ekpo~ebeln
      ekpo~ebelp
      ekpo~matnr
      ekpo~menge
      ekpo~werks
      ekpo~kunnr
      ekpo~mfrnr
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE it_po
        FOR ALL ENTRIES IN it_ekko_t
      WHERE ekpo~ebeln = it_ekko_t-ebeln
      AND ekpo~loekz  EQ ''   "ismail
      AND ekpo~werks IN p_plant
      AND ekpo~matnr IN p_prt_no
*      AND ekpo~aedat IN p_pdat
      AND ekpo~mtart IN p_mtart  "by ismail
      AND ekpo~bednr NE ''.
    ENDIF.
    SORT it_po BY ebeln.
    it_po_t2 = it_po .
    DELETE ADJACENT DUPLICATES FROM   it_po_t2 COMPARING ebeln.

    SELECT
      eban~banfn
      eban~bnfpo
      eban~bsart
      eban~menge
      eban~ebeln
      eban~ebelp
      FROM eban
      INTO CORRESPONDING FIELDS OF TABLE it_ban_t
      FOR ALL ENTRIES IN it_po_t2
      WHERE eban~ebeln = it_po_t2-ebeln
*       AND eban~ebelp = it_po_t-ebelp1
      AND eban~banfn IN p_pr.
  ELSE.
    SELECT
    eban~banfn
    eban~bnfpo
    eban~bsart
    eban~menge
    eban~ebeln
    eban~ebelp
    FROM eban
    INTO CORRESPONDING FIELDS OF TABLE it_ban_t
    WHERE eban~banfn IN p_pr
      AND eban~bsart IN p_esart .
    IF sy-subrc = 0.
      SELECT
      ekpo~ebeln
      ekpo~ebelp
      ekpo~matnr
      ekpo~menge
      ekpo~werks
      ekpo~kunnr
      ekpo~mfrnr
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE it_po
              FOR ALL ENTRIES IN it_ban_t
      WHERE ekpo~ebeln = it_ban_t-ebeln
      AND ekpo~loekz  EQ ''   "ismail
      AND ekpo~werks IN p_plant
      AND ekpo~matnr IN p_prt_no
      AND ekpo~aedat IN p_pdat
      AND ekpo~mtart IN p_mtart  "by ismail
      AND ekpo~bednr NE ''.
    ENDIF.
  ENDIF.

  IF it_ban_t IS INITIAL.
    MESSAGE 'No Purchase Requisition Document found' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*************************************************************************
*---fettcing DBE order based on PR's
  RANGES ra_ord FOR /DBE/ord_docflow-instid_a.
  DATA: it_ord  TYPE  TABLE OF ty_vbeln_order.
  CLEAR: it_ord.
  SORT it_ban_t BY ebeln.
  DELETE ADJACENT DUPLICATES FROM it_ban_t.
  CLEAR: ra_ord.
  LOOP AT it_ban_t INTO DATA(ts_prs).
    CONCATENATE 'BUS2105*' ts_prs-banfn '*' INTO ra_ord-low.
    ra_ord-option = 'CP'.
    ra_ord-sign = 'I'.
    APPEND ra_ord.
  ENDLOOP.

  SORT ra_ord BY low.
  DELETE ADJACENT DUPLICATES FROM ra_ord COMPARING low.

  IF lines( ra_ord ) > 0.
    SELECT instid_a instid_b
      INTO TABLE it_ord
      FROM /DBE/ord_docflow
      WHERE instid_b IN ra_ord .
  ENDIF.

  LOOP AT it_ord INTO DATA(ts_ord1).
    ts_order_no-sign = 'I'.
    ts_order_no-option = 'EQ'.
    ts_order_no-low = ts_ord1-DBE_ordr+10(10)..
    APPEND ts_order_no TO it_order_no_temp.

    lw_ebant-banfn = ts_ord1-pr+13(10).
    lw_ebant-bnfpo = ts_ord1-pr+26(5).
    lw_ebant-vbeln = ts_ord1-DBE_ordr+10(10).
    lw_ebant-posnr = ts_ord1-DBE_ordr+20(6).
    APPEND  lw_ebant TO lt_ebant.
  ENDLOOP.


  CLEAR: lw_vbak_com,lt_vbak_com,ra_ord.
  "Read the Order Items and filter from heade result
  SELECT vbak~vbeln erdat_tmstp  FROM /DBE/vbak_db AS vbak
          INNER JOIN /DBE/splhdr_db AS splhdr
          ON splhdr~vbeln = vbak~vbeln
          AND splhdr~splnr = 1
          INNER JOIN /DBE/vbap
          ON /DBE/vbap~vbeln = vbak~vbeln INTO CORRESPONDING FIELDS OF TABLE lt_vbak_com
          WHERE           vkorg             IN ra_vkorg
                    AND   vbak~werks             IN p_plant
                      AND   splhdr~kunnr             IN ra_kunnr
                      AND   vbak~vbeln        IN it_order_no_temp
                      AND vbak~pernr IN ra_pernr
                    AND vbak~audat IN p_ddat
                    AND   vbak~engine IN ('CS', 'MM')
                      AND vbak~mfrnr IN ra_mfrnr
                      AND /DBE/vbap~matnr18 IN ra_matnr
          ORDER BY erdat_tmstp DESCENDING.

  SORT lt_vbak_com BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_vbak_com COMPARING vbeln.
  "to delete all billed DBE orders...
  IF  lt_vbak_com[] IS NOT INITIAL.
    CLEAR :it_order_no_del.
    SELECT vbeln FROM /DBE/oe_vbakst INTO TABLE it_order_no_del FOR ALL ENTRIES IN   lt_vbak_com WHERE vbeln =  lt_vbak_com-vbeln AND
                                                                                    action             = 'BILLING_CREATE' AND
                                                                                    status             = 'C'.


    IF sy-subrc EQ 0 AND it_order_no_del IS NOT INITIAL.
      LOOP AT it_order_no_del INTO lw_order_no_del.
*        cleaR: ls_vbak_com.
        READ TABLE lt_vbak_com TRANSPORTING NO FIELDS WITH KEY vbeln = lw_order_no_del-vbeln.
        IF sy-subrc EQ 0.
*          DELETE et_vbak_com INDEX sy-tabix.
          DELETE lt_vbak_com WHERE vbeln EQ lw_order_no_del-vbeln.  "to delete all billed DBE orders...
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDIF.

*---read from it_ban_t if not found delete
  DATA: lv_tabix TYPE sy-tabix.
  CLEAR: lv_tabix .
  LOOP AT lt_ebant  INTO lw_ebant.
    lv_tabix  = sy-tabix.
    READ TABLE  lt_vbak_com TRANSPORTING NO FIELDS WITH KEY vbeln = lw_ebant-vbeln.
    IF sy-subrc NE 0.
      DELETE lt_ebant INDEX lv_tabix.
    ENDIF.
  ENDLOOP.

*----filling data DBEorder data....
  DATA: ls_orderlist LIKE LINE OF it_orderlist,
        ls_vbak_com  TYPE /DBE/vbak_com,
        ls_kna1      TYPE kna1.


*--fetching all other data..
  IF lt_vbak_com IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbak_com  ##too_many_itab_fields
                                        FROM /DBE/vbak_db AS vbak
                                     INNER JOIN /DBE/splhdr_db AS splhdr
                                     ON splhdr~vbeln = vbak~vbeln
                                     AND splhdr~splnr = 1
                                     FOR ALL ENTRIES IN lt_vbak_com
                                          WHERE vbak~vbeln = lt_vbak_com-vbeln.
  ENDIF.

*--> fill the temporary fields in header structure
  CALL FUNCTION '/DBE/ORD_INT_FILL_HEADER_COM'
    EXPORTING
      iv_docflow               = space
      iv_mass_reading_call     = 'X'
      iv_skip_archived_vehicle = 'X'
    CHANGING
      ct_vbak_com              = lt_vbak_com
    EXCEPTIONS
      error_occured            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
*--> don't do anything, because it's mass-processing
  ENDIF.

*--> fill the orderlist
  LOOP AT lt_vbak_com INTO ls_vbak_com.
    CLEAR ls_orderlist.
    MOVE-CORRESPONDING ls_vbak_com TO ls_orderlist.
    APPEND ls_orderlist TO it_orderlist.
  ENDLOOP.
*--fetching vbap details...
  IF it_orderlist IS NOT INITIAL.    "ADDED BY ISMAIL
    SELECT vbeln
      matnr18
      posnr
      zmeng
      jobs
      FROM /DBE/vbap
      INTO TABLE it_vbap
      FOR ALL ENTRIES IN it_orderlist
      WHERE vbeln = it_orderlist-vbeln AND
            itcanc NE 'X'.   "added by ismail
    IF sy-subrc = 0.
      SORT it_vbap ASCENDING BY vbeln posnr matnr.
    ENDIF.
  ENDIF.

***********************************


*    LOOP AT it_ban_t INTO DATA(wa_ban).
*      CLEAR: ts_po,ts_po1.
*      READ TABLE it_po_t INTO ts_po WITH KEY ebeln = wa_ban-ebeln ebelp = wa_ban-ebelp.
*      ts_po1-ebeln = wa_ban-ebeln.
*      ts_po1-ebelp =  wa_ban-ebelp.
*      ts_po1-banfn = wa_ban-banfn.
*      ts_po1-bsart = wa_ban-bsart.
*      ts_po1-matnr = ts_po-matnr.
*      ts_po1-menge =  ts_po-menge.
*      ts_po1-pr_quan =  wa_ban-menge.
*      ts_po1-werks = ts_po-werks.
*      ts_po1-kunnr =  ts_po-kunnr .
*      ts_po1-mfrnr = ts_po-mfrnr.
*      ts_po1-bnfpo = ts_po-bnfpo.
*      APPEND ts_po1 TO it_po.
*    ENDLOOP.
*--end of changes by ismail to split query..

  IF   it_po IS NOT INITIAL. "by ismail
    CLEAR: it_ekko,it_eket,it_lips,it_vbup.
    SELECT
      ebeln
      lifnr
      frgke
      aedat
       bsart    "by ismail
      FROM ekko
      INTO TABLE it_ekko
      FOR ALL ENTRIES IN it_po
      WHERE ebeln = it_po-ebeln
      AND bsart IN  p_bsart    " added by ismail
      AND lifnr IN p_supp.

    SELECT
    ebeln
    ebelp
    eindt
    FROM eket
    INTO TABLE it_eket
    FOR ALL ENTRIES IN it_po
    WHERE ebeln = it_po-ebeln
      AND ebelp = it_po-ebelp+1(5).

    SELECT
    i~vgbel
    i~vgpos
    i~vbeln
    i~posnr
    i~erdat
    h~vbtyp
    FROM lips AS i
    INNER JOIN likp AS h
    ON i~vbeln = h~vbeln
    INTO TABLE it_lips
    FOR ALL ENTRIES IN it_po
    WHERE vgbel = it_po-ebeln
    AND vgpos = it_po-ebelp.

    IF it_lips IS NOT INITIAL.
      SELECT
        vbeln
        posnr
        wbsta
         FROM vbup
         INTO TABLE it_vbup
        FOR ALL ENTRIES IN it_lips
         WHERE vbeln = it_lips-vbeln
         AND posnr = it_lips-posnr.
    ENDIF.
  ENDIF. "by ismail


*------------preparing final
  SORT it_orderlist BY vbeln .
  CLEAR: lt_t16fb,lw_t16fb.
  SELECT *
    FROM t16fb
    INTO TABLE lt_t16fb.
  IF sy-subrc = 0.
    SORT lt_t16fb.
  ENDIF.

*---------activated becuase  *---adding new logic by ismail for delevery status.....
  CLEAR: it_lips1,it_vbup1.


  "Read LiPS from LIKP Header table
  CLEAR: lt_ebant2,ra_ord[] .
  lt_ebant2[] = lt_ebant[].
  SORT  lt_ebant2 BY vbeln.
  DELETE ADJACENT DUPLICATES FROM  lt_ebant2 COMPARING vbeln.
*--here fetching Purchase requisition
  LOOP AT lt_ebant2 INTO DATA(wa2).
    CONCATENATE 'BUS2400*'  wa2-vbeln '*' INTO ra_ord-low.
    ra_ord-option = 'CP'.
    ra_ord-sign = 'I'.
    APPEND ra_ord.
  ENDLOOP.
  CLEAR: it_ord_lips.
  IF ra_ord IS NOT INITIAL.
    SELECT instid_a instid_b   "#EC CI_NO_TRANSFORM #EC CI_NO_TRANSFORM
   INTO TABLE  it_ord_lips
   FROM /DBE/ord_docflow
   WHERE instid_a IN ra_ord
   AND instid_b LIKE 'LIKP%'.
  ENDIF.
  CLEAR : it_lips1,it_lips2.
  DATA: lw_lips1 LIKE LINE OF it_lips1.
  LOOP AT it_ord_lips INTO DATA(wa_ord_lips).
    CLEAR: lw_lips1.
    lw_lips1-vbeln = wa_ord_lips-pr+13(10).
    lw_lips1-posnr = wa_ord_lips-pr+24(6).
*    lw_ebant-vbeln = wa_ord_LIPS-DBE_ordr+10(10).
*    lw_ebant-posnr = wa_ord_LIPS-DBE_ordr+20(6).
    APPEND   lw_lips1 TO it_lips2.
  ENDLOOP.

  "Read LiPS from LIKP Header table
  IF it_lips2 IS NOT INITIAL.
    "Read VBUP from LIKP - VBELN header table
    SELECT
    i~vbeln
    i~posnr
    i~matnr
    i~erdat
    i~vgbel
    i~vgpos
     i~/DBE/vbeln
    i~/DBE/posnr
*    h~vbtyp
    FROM lips AS i
*    INNER JOIN likp AS h
*    ON i~vbeln = h~vbeln
    INTO CORRESPONDING FIELDS OF TABLE it_lips1
    FOR ALL ENTRIES IN it_lips2
    WHERE
*          matnr = it_vbap-matnr AND
*          werks IN  p_plant AND
           vbeln = it_lips2-vbeln.
*    AND /DBE/posnr = it_vbap-posnr.

    IF sy-subrc EQ 0.
      it_lips1_t[] = it_lips1[].
      SORT it_lips1_t BY vbeln.
      DELETE ADJACENT DUPLICATES FROM it_lips1_t COMPARING vbeln.
*    ENDIF.
      SELECT
        vbeln
        vbtyp
        FROM likp INTO TABLE it_likp_h  FOR ALL ENTRIES IN it_lips1_t
                                      WHERE vbeln = it_lips1_t-vbeln.


      FIELD-SYMBOLS : <fs_lips1> LIKE LINE OF it_lips1.
      LOOP AT it_lips1  ASSIGNING <fs_lips1>.
        READ TABLE it_likp_h INTO DATA(wa) WITH KEY vbeln = <fs_lips1>-vbeln.
        IF sy-subrc EQ 0.
          <fs_lips1>-vbtyv  =  wa-vbtyp.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF it_lips1 IS NOT INITIAL.
      SELECT
        vbeln
        posnr
        wbsta
         FROM vbup
         INTO TABLE it_vbup1
        FOR ALL ENTRIES IN it_lips1
         WHERE vbeln = it_lips1-vbeln
         AND posnr = it_lips1-posnr.
    ENDIF.
  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREPARE_FINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_final .

*
**--Begin of chages added by ismail...
*
*  SORT it_orderlist BY vbeln .
*  CLEAR: lt_t16fb,lw_t16fb.
*  SELECT *
*    FROM t16fb
*    INTO TABLE lt_t16fb.
*  IF sy-subrc = 0.
*    SORT lt_t16fb.
*  ENDIF.
*
*  CLEAR: it_lips1,it_vbup1.
*  IF it_vbap IS NOT INITIAL.
*    SELECT
*    i~vgbel
*    i~vgpos
*    i~vbeln
*    i~posnr
*    i~matnr
*    i~erdat
*       i~/DBE/vbeln
*      i~/DBE/posnr
*    h~vbtyp
*    FROM lips AS i
*    INNER JOIN likp AS h
*    ON i~vbeln = h~vbeln
*    INTO TABLE it_lips1
*    FOR ALL ENTRIES IN it_vbap
*    WHERE matnr = it_vbap-matnr AND
**          werks IN  p_plant AND
*          /DBE/vbeln = it_vbap-vbeln
*    AND /DBE/posnr = it_vbap-posnr.
*
*    IF it_lips1 IS NOT INITIAL.
*      SELECT
*        vbeln
*        posnr
*        wbsta
*         FROM vbup
*         INTO TABLE it_vbup1
*        FOR ALL ENTRIES IN it_lips1
*         WHERE vbeln = it_lips1-vbeln
*         AND posnr = it_lips1-posnr.
*    ENDIF.
*  ENDIF.
*
*  LOOP AT it_po INTO ts_po.
*    ts_order-bstnk = ts_po-ebeln.
*    ts_order-ebelp = ts_po-ebelp.
*    ts_order-banfn = ts_po-banfn.
*    ts_order-bnfpo = ts_po-bnfpo.
*    ts_order-mfrnr = ts_po-mfrnr.
**    ts_order-po_quan = ts_po-po_quan.
*    ts_order-po_quan = ts_po-menge.
*    ts_order-pr_quan = ts_po-pr_quan.
*    ts_order-eb_bsart = ts_po-bsart. " by ismail
*
*    CONCATENATE ts_po-ebeln ts_po-ebelp+1(5) INTO tdnam.
*    CALL FUNCTION 'READ_TEXT'
*      EXPORTING
**       CLIENT                  = SY-MANDT
*        id                      = tdid
*        language                = tdspras
*        name                    = tdnam
*        object                  = tdobject
*      TABLES
*        lines                   = tdlines
*      EXCEPTIONS
*        id                      = 1
*        language                = 2
*        name                    = 3
*        not_found               = 4
*        object                  = 5
*        reference_check         = 6
*        wrong_access_to_archive = 7
*        OTHERS                  = 8.
*    IF sy-subrc = 0.
*      READ TABLE tdlines
*      INTO ts_lines INDEX 1.
*      IF sy-subrc = 0.
*        ts_order-po_text = ts_lines-tdline.
*      ENDIF.
*    ENDIF.
*    CALL FUNCTION 'CONVERSION_EXIT_MATN2_OUTPUT'
*      EXPORTING
*        input  = ts_po-matnr
*      IMPORTING
*        output = ts_order-matnr.
*    READ TABLE it_ekko
*    INTO ts_ekko
*    WITH KEY ebeln = ts_po-ebeln.
*    IF sy-subrc = 0.
*      ts_order-lifnr = ts_ekko-lifnr.
*      ts_order-po_date = ts_ekko-aedat.
*      ts_order-ek_bsart = ts_ekko-bsart. "by ismail
*    ENDIF.
*
**----added by ismail to fileter only thos doc type entered in selection screen
*
*    IF ts_order-ek_bsart NOT IN p_bsart OR  ts_order-eb_bsart NOT IN  p_esart.
*      CONTINUE.
*    ENDIF.
*
**-- end of addition by ismail
*
*    CLEAR: ts_lips.
*    READ TABLE it_lips
*    INTO ts_lips
*    WITH KEY ebeln = ts_po-ebeln
*    ebelp = ts_po-ebelp
*    vbtyv = 'J'.
*    IF sy-subrc = 0.
*      ts_order-outb_no = ts_lips-vbeln.
*      ts_order-outb_item = ts_lips-posnr.
*      ts_order-outb_dat = ts_lips-erdat.
*    ENDIF.
*
*    CLEAR: ts_lips.
*    READ TABLE it_lips
*    INTO ts_lips
*    WITH KEY ebeln = ts_po-ebeln
*    ebelp = ts_po-ebelp
*    vbtyv = '7'.
*    IF sy-subrc = 0.
*      ts_order-inb_no = ts_lips-vbeln.
*      ts_order-inb_item = ts_lips-posnr.
*      ts_order-inb_dat = ts_lips-erdat.
*    ENDIF.
*
*    CLEAR: ts_order-po_status.
*    IF ts_order-inb_no IS NOT INITIAL OR ts_order-outb_no IS NOT INITIAL.
*      IF ts_order-inb_no IS NOT INITIAL AND ts_order-inb_item IS NOT INITIAL.
*        READ TABLE it_vbup TRANSPORTING NO FIELDS
*          WITH KEY vbeln = ts_order-inb_no
*                   posnr = ts_order-inb_item
*                   wbsta = 'C'.
*        IF sy-subrc = 0 .
*          ts_order-po_status = 'GR Completed'.
*        ELSEIF ts_order-outb_no IS NOT INITIAL AND ts_order-outb_item IS NOT INITIAL.
*          READ TABLE it_vbup TRANSPORTING NO FIELDS
*            WITH KEY vbeln = ts_order-outb_no
*                     posnr = ts_order-outb_item
*                     wbsta = 'C'.
*          IF sy-subrc <> 0.
*            ts_order-po_status = 'Outbound Created'.
*          ELSE.
*            ts_order-po_status = 'Inbound Created'.
*          ENDIF.
*
*        ELSE. "added by ismail....to fix status inbound creation
*          ts_order-po_status = 'Inbound Created'.
*        ENDIF.
*      ELSE.
*        READ TABLE it_vbup TRANSPORTING NO FIELDS
*          WITH KEY vbeln = ts_order-outb_no
*           posnr = ts_order-outb_item
*           wbsta = 'C'.
*        IF sy-subrc = 0.
*          ts_order-po_status = 'GI Completed'.
*        ELSE.
*          ts_order-po_status = 'Outbound Created'.
*        ENDIF.
*      ENDIF.
*
*    ELSEIF ts_ekko-ebeln IS NOT INITIAL.
*
*      CLEAR: lw_t16fb  .
*      READ TABLE lt_t16fb INTO lw_t16fb WITH KEY frgke = ts_ekko-frgke.
*      IF sy-subrc EQ 0.
**      IF ts_ekko-frgke = 'R'.
*        IF lw_t16fb-kzfre IS NOT INITIAL.
*          ts_order-po_status = 'PO Released'.
*        ELSE.
*          ts_order-po_status = 'PO yet to Release'.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    READ TABLE it_eket
*    INTO ts_eket
*    WITH KEY ebeln = ts_po-ebeln
*    ebelp = ts_po-ebelp+1(5).
*    IF sy-subrc = 0.
*      IF ts_lips-erdat IS NOT INITIAL AND
*        ts_eket-eindt IS NOT INITIAL.
*        IF ts_eket-eindt < ts_lips-erdat.
*          CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
*            EXPORTING
*              date1         = ts_lips-erdat
*              date2         = ts_eket-eindt
*              output_format = '03'
*            IMPORTING
*              days          = lv_day.
*        ELSE.
*          CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
*            EXPORTING
*              date1         = ts_eket-eindt
*              date2         = ts_lips-erdat
*              output_format = '03'
*            IMPORTING
*              days          = lv_day.
*        ENDIF.
*        ts_order-dif_dt = lv_day .
*        CLEAR :lv_day.
*      ENDIF.
*      CONCATENATE  ts_eket-eindt+6(2) '.' ts_eket-eindt+4(2) '.' ts_eket-eindt+0(4) INTO ts_order-exdate.
**      ts_order-exdate = ts_eket-eindt.
*    ENDIF.
**
*    READ TABLE it_vbeln_pr
*    INTO ts_vbeln_pr
*    WITH KEY pr = ts_po-banfn.
*    IF sy-subrc = 0.
*      READ TABLE it_orderlist INTO ts_orderlist
*      WITH KEY vbeln = ts_vbeln_pr-vbeln.
*      IF sy-subrc = 0.
*        MOVE-CORRESPONDING ts_orderlist TO ts_order.
*        ts_order-bstnk = ts_po-ebeln.
*        ts_order-ebelp = ts_po-ebelp.
*        ts_order-banfn = ts_po-banfn.
**        ts_order-po_quan = ts_po-po_quan.
*        ts_order-po_quan = ts_po-menge.
*
*        LOOP AT it_vbap
*          INTO ts_vbap
*          WHERE vbeln = ts_orderlist-vbeln
**          AND posnr = ts_vbeln_pr-posnr.  "commented by ismail
*          AND matnr = ts_po-matnr.
*          ts_order-posnr = ts_vbap-posnr.
*          ts_order-ord_quan = ts_vbap-zmeng.
*
**---adding new logic by ismail for delevery status.....
*          CLEAR: ts_lips1,ts_order-del_stat.
*          READ TABLE it_lips1
*          INTO ts_lips1
*          WITH KEY /DBE/vbeln = ts_vbap-vbeln
*                  /DBE/posnr = ts_vbap-posnr.
*          IF sy-subrc EQ 0.
*            ts_order-del_stat = 'Delivery Created'.
*            READ TABLE it_vbup1 TRANSPORTING NO FIELDS
*              WITH KEY vbeln = ts_lips1-vbeln
*                       posnr = ts_lips1-posnr
*                       wbsta = 'C'.
*            IF sy-subrc = 0 .
*              ts_order-del_stat = 'Goods issued'.
*            ENDIF.
*          ENDIF.
*          APPEND ts_order TO it_order.
*          lv_flag = 1.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
**--Commenting by ismail to not to show if it is not DBE order....
**    IF lv_flag = 0.
**      APPEND ts_order TO it_order.
**    ELSE.
**      lv_flag = 0.
**    ENDIF.
*    CLEAR :ts_order,
*           ts_po,
*           ts_ekko,
*           ts_eket,
*           ts_lips,
*           ts_vbup,
*           ts_vbap,
*           ts_vbeln_pr,
*           ts_orderlist.
*  ENDLOOP.

ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  F_EMAIL
*&---------------------------------------------------------------------*
FORM f_email .
***cmn decl
  CONSTANTS:
    lc_htm  TYPE char3   VALUE 'HTM',
    lc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
    lc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

  DATA: "lt_contents       TYPE STANDARD TABLE OF solisti1,
    "lw_contents       TYPE solisti1,
    w_document        TYPE REF TO cl_document_bcs,
    l_send_request    TYPE REF TO cl_bcs,
    l_document        TYPE REF TO cl_document_bcs,
    l_sender          TYPE REF TO cl_sapuser_bcs,
    l_recipient       TYPE REF TO if_recipient_bcs,
    l_bcs_exception   TYPE REF TO cx_bcs,
    tl_contents       TYPE STANDARD TABLE OF soli,
    l_doc_len         TYPE so_obj_len,
    l_cnt             TYPE sy-tabix,
    l_rcv_email       TYPE adr6-smtp_addr, "VALUE 'YMULTIPROGRAM@EAJB.COM.SA',
    l_result          TYPE sy-binpt,
    l_sub             TYPE so_obj_des,
    l_subj            TYPE string,
    lv_string         TYPE string,
    lt_binary_content TYPE solix_tab,
    lv_size           TYPE so_obj_len,
    l_attsub          TYPE so_obj_des,
    l_att_type        TYPE soodk-objtp,
    i_copy            TYPE c.

  DATA: lv_netwr  TYPE c LENGTH 15,
        lv_netwr1 TYPE c LENGTH 15,
        lv_netwr2 TYPE c LENGTH 15,
        lv_netwr3 TYPE c LENGTH 15.

***  end
  CONSTANTS:  gc_email    TYPE subty     VALUE '0010'.

  DATA: lv_email      TYPE p0105-usrid_long.


  DATA lwf_userid TYPE syuname.
  DATA lwf_pernr TYPE pernr_d.
  DATA int_pernr TYPE pernr_us_tab.
  lwf_userid = sy-uname.
  DATA lfs_pernr TYPE pernr_us.
*      * Get perner from employee userid
  CALL FUNCTION 'HR_GET_EMPLOYEES_FROM_USER'
    EXPORTING
      user              = lwf_userid
      begda             = sy-datum
      endda             = sy-datum
      iv_with_authority = ''
    TABLES
      ee_tab            = int_pernr.

  READ TABLE int_pernr INTO lfs_pernr INDEX 1.

  MOVE lfs_pernr-pernr TO lwf_pernr.
* following addition by shahid 8100004362 starts.
  IF lv_sv_adv_rm = 'SA'.
    lwf_pernr = ts_email-pernr.
  ENDIF.

  IF lv_sv_adv_rm NE 'RM'.
    SELECT SINGLE usrid_long  FROM pa0105 INTO lv_email
          WHERE pernr = lwf_pernr AND subty = gc_email AND endda >= sy-datum AND begda <= sy-datum.
  ELSE.
    lv_email = dls_entries-member_adr.
  ENDIF.
* "shahid 8100004362 ends.
*  select
  TRY.
      IF lv_sv_adv_rm = '  '.
        CONCATENATE 'Dear,' lc_new_line lc_new_line INTO lw_contents-line.
        APPEND lw_contents TO lt_contents.
        CONCATENATE 'Please find the attached output of the YPOTR report in the attachments.'lc_new_line lc_new_line INTO lw_contents-line.
        APPEND lw_contents TO lt_contents.
        CONCATENATE 'Regards,' lc_new_line  INTO lw_contents-line.
        APPEND lw_contents TO lt_contents.
        CONCATENATE 'SAP Team.'  lc_new_line INTO lw_contents-line.
        APPEND lw_contents TO lt_contents.
**-- Subject of the Mail
        CONCATENATE 'YPOTR- ' sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4) INTO lv_mail_subj.
      ELSE.
        PERFORM prepare_email_body_subj.
      ENDIF.
**-- Get the length of the Document
      DESCRIBE TABLE tl_contents LINES l_cnt.
      READ TABLE tl_contents INTO lw_contents INDEX l_cnt.
      l_doc_len = ( l_cnt - 1 ) * 255 + strlen( lw_contents ).
*-- Subject of the mail
      l_sub = lv_mail_subj.
*
**-- Create persistent send request
      l_send_request = cl_bcs=>create_persistent( ).
      tl_contents[] = lt_contents[].

**-- Get the length of the Document
      DESCRIBE TABLE tl_contents LINES l_cnt.
      READ TABLE tl_contents INTO lw_contents INDEX l_cnt.
      l_doc_len = ( l_cnt - 1 ) * 255 + strlen( lw_contents ).
**-- Subject of the mail
      l_sub = lv_mail_subj.
*
**-- Create Document
      l_document = cl_document_bcs=>create_document(
                   i_type       = lc_htm
                   i_text       = tl_contents
                   i_length     = l_doc_len
                   i_subject    = l_sub
                   i_language   = sy-langu
                   i_importance = '1' ).
      w_document = l_document.
*
      TRY.
*-- Set the Message Subject
          CALL METHOD l_send_request->set_message_subject
            EXPORTING
              ip_subject = lv_mail_subj. "l_subj.
        CATCH cx_sy_dyn_call_illegal_method.
      ENDTRY.
*
**-- Add document to send request
      CALL METHOD l_send_request->set_document( l_document ).
*
**-- Do send delivery info for successful mails
      CALL METHOD l_send_request->set_status_attributes
        EXPORTING
          i_requested_status = 'E'
          i_status_mail      = 'A'.
*
**-- Set sender
      l_sender = cl_sapuser_bcs=>create( sy-uname ).
      CALL METHOD l_send_request->set_sender
        EXPORTING
          i_sender = l_sender.

*****  column names
      CONCATENATE '' 'CCode to be billed' 'Company Name' 'Plant' 'Plant Name' 'Sales Organization' 'Sales Org. Description' 'Distribution Channe' 'Dist Chan. Descr.' 'Division'
      'Control Code' 'Control Code Desc.' 'Order Type' 'Order Type' 'DBE Order' 'Order item' 'Jobs' 'Order Qty' 'Order Status'  'PR Number' 'PR item' 'PR Quantity' 'PR document type'
      'Purchase order no' 'PO document type' 'Item Number' 'PO Quantity' 'PO Status' 'PO Date'  'Delivery Status' 'INB delivery' 'INB item' 'INB del date' 'Parts Number'
      'ET Date' 'GR Diff. Date' 'Document Date' 'Customer' 'Customer Name'
        INTO lv_string SEPARATED BY lc_tab.
      CONCATENATE lv_string lc_crlf INTO lv_string.
*
**-- Converting file to binary
      LOOP AT it_order INTO DATA(wa).
        CASE lv_sv_adv_rm.
          WHEN 'RM'.                                                                       "shahid 8100004362.
            READ TABLE lt_pono3 INTO ts_pono WITH KEY vbeln = wa-vbeln jobs = wa-jobs.     "shahid 8100004362.
            CHECK sy-subrc = 0.                                                            "shahid 8100004362.
            CHECK wa-del_stat IS INITIAL.                                                  "shahid 8100004362.
          WHEN 'SA'.                                                                       "shahid 8100004362.
            READ TABLE lt_pono3 INTO ts_pono WITH KEY vbeln = wa-vbeln jobs = wa-jobs.     "shahid 8100004362.
            CHECK sy-subrc = 0.                                                            "shahid 8100004362.
            CHECK wa-pernr = ts_email-pernr.                                               "shahid 8100004362.
            CHECK wa-del_stat IS INITIAL.                                                  "shahid 8100004362.
        ENDCASE.                                                                           "shahid 8100004362.
*        lv_netwr = wa-netwr.
        CONCATENATE
                lv_string
               wa-bukrs_vf  wa-bukrs_txt
               wa-werks wa-werks_txt  wa-vkorg wa-vkorg_txt wa-vtweg   wa-vtweg_txt wa-spart wa-engine  wa-engine_txt
                wa-aufart  wa-aufart_txt wa-vbeln   wa-posnr  wa-jobs  wa-ord_quan  wa-hstat wa-banfn   wa-bnfpo wa-pr_quan
                wa-eb_bsart wa-bstnk    wa-ek_bsart  wa-ebelp wa-po_quan wa-po_status  wa-po_date wa-del_stat
                wa-inb_no    wa-inb_item  wa-inb_dat wa-matnr
                wa-exdate  wa-dif_dt wa-audat  wa-partner wa-debitor_name
                INTO lv_string SEPARATED BY lc_tab.

        CONCATENATE lv_string lc_crlf INTO lv_string.
      ENDLOOP.

      TRY.
          cl_bcs_convert=>string_to_solix(
            EXPORTING
              iv_string   = lv_string
              iv_codepage = '4103'  "suitable for MS Excel, leave empty
              iv_add_bom  = 'X'     "for other doc types
            IMPORTING
              et_solix  = lt_binary_content
              ev_size   = lv_size ).
        CATCH cx_bcs.
          MESSAGE e445(so).
      ENDTRY.


      IF lt_binary_content[] IS NOT INITIAL.
*-- Subject of the Attachment

        CONCATENATE 'YPOTR_' sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4) INTO l_attsub   .
*-- Format of the Attachment
        l_att_type = 'XLS'."w_extn.


        TRY.
*-- Add Attachment to the Document
            CALL METHOD w_document->add_attachment
              EXPORTING
                i_attachment_type    = l_att_type
                i_attachment_subject = l_attsub
                i_att_content_hex    = lt_binary_content.
          CATCH cx_document_bcs.
        ENDTRY.
      ENDIF.

*-- Add the recipients to the Send mail
*      LOOP AT lt_email INTO lw_email WHERE zrule = pv_rule.
*      l_rcv_email = 'YMULTIPROGRAM@EAJB.COM.SA'."'bhagat.dharm@eajb.com.sa' email address
*        i_copy = lw_email-ccopy." To/cc

      l_rcv_email =  lv_email .
      CHECK NOT l_rcv_email IS INITIAL.
      l_recipient = cl_cam_address_bcs=>create_internet_address(
                                                    l_rcv_email ).
      CALL METHOD l_send_request->add_recipient
        EXPORTING
          i_recipient = l_recipient
*         i_copy      = lw_email-ccopy "i_copy
          i_express   = 'X'.
*        CLEAR: lw_email.
*      ENDLOOP.

*-- Send Email
      CALL METHOD l_send_request->send(
        EXPORTING
          i_with_error_screen = space
        RECEIVING
          result              = l_result ).

      IF l_result = 'X'.
        MESSAGE s999(zz) WITH
        'Notification sent successfully'(003).
      ENDIF.

    CATCH cx_bcs INTO l_bcs_exception.
      IF l_result NE 'X'.
        MESSAGE s999(zz) WITH
        'Sending notification failed'(004).
      ENDIF.
  ENDTRY.
  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_fill_data .

  IF it_ban IS INITIAL.
    it_ban[] = it_ban_t[].
  ELSEIF it_ban_t IS INITIAL.
    it_ban_t[] = it_ban[].
  ENDIF.
  SORT lt_ebant BY banfn bnfpo.
  LOOP AT lt_ebant INTO lw_ebant.

    READ TABLE it_ban INTO DATA(ls_ban)
    WITH KEY banfn = lw_ebant-banfn bnfpo = lw_ebant-bnfpo.
    IF sy-subrc = 0.
      "Fill the PR details
      ts_order-banfn = ls_ban-banfn.
      ts_order-bnfpo = ls_ban-bnfpo.
      ts_order-pr_quan = ls_ban-menge.
      ts_order-eb_bsart = ls_ban-bsart.
      "Read the Purchase Order details
      READ TABLE it_po INTO ts_po WITH KEY ebeln = ls_ban-ebeln ebelp = ls_ban-ebelp.
      IF sy-subrc = 0.
        ts_order-bstnk = ts_po-ebeln.
        ts_order-ebelp = ts_po-ebelp.
*        ts_order-banfn = ts_po-banfn.
*        ts_order-bnfpo = ts_po-bnfpo.
        ts_order-mfrnr = ts_po-mfrnr.
*    ts_order-po_quan = ts_po-po_quan.
        ts_order-po_quan = ts_po-menge.
*        ts_order-pr_quan = ts_po-pr_quan.
        ts_order-ek_bsart = ts_po-bsart. " by ismail

        CONCATENATE ts_po-ebeln ts_po-ebelp+1(5) INTO tdnam.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT                  = SY-MANDT
            id                      = tdid
            language                = tdspras
            name                    = tdnam
            object                  = tdobject
          TABLES
            lines                   = tdlines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
          READ TABLE tdlines
          INTO ts_lines INDEX 1.
          IF sy-subrc = 0.
            ts_order-po_text = ts_lines-tdline.
          ENDIF.
        ENDIF.
        CALL FUNCTION 'CONVERSION_EXIT_MATN2_OUTPUT'
          EXPORTING
            input  = ts_po-matnr
          IMPORTING
            output = ts_order-matnr.

        READ TABLE it_ekko
          INTO ts_ekko
          WITH KEY ebeln = ts_po-ebeln.
        IF sy-subrc = 0.
          ts_order-lifnr = ts_ekko-lifnr.
          ts_order-po_date = ts_ekko-aedat.
          ts_order-ek_bsart = ts_ekko-bsart. "by ismail
        ENDIF.


*----added by ismail to fileter only thos doc type entered in selection screen

        IF ts_order-ek_bsart NOT IN p_bsart OR  ts_order-eb_bsart NOT IN  p_esart.
          CONTINUE.
        ENDIF.

*-- end of addition by ismail

        CLEAR: ts_lips.
        READ TABLE it_lips
        INTO ts_lips
        WITH KEY ebeln = ts_po-ebeln
        ebelp = ts_po-ebelp
        vbtyv = 'J'.
        IF sy-subrc = 0.
          ts_order-outb_no = ts_lips-vbeln.
          ts_order-outb_item = ts_lips-posnr.
          ts_order-outb_dat = ts_lips-erdat.
        ENDIF.

        CLEAR: ts_lips.
        READ TABLE it_lips
        INTO ts_lips
        WITH KEY ebeln = ts_po-ebeln
        ebelp = ts_po-ebelp
        vbtyv = '7'.
        IF sy-subrc = 0.
          ts_order-inb_no = ts_lips-vbeln.
          ts_order-inb_item = ts_lips-posnr.
          ts_order-inb_dat = ts_lips-erdat.
        ENDIF.

        CLEAR: ts_order-po_status.
        IF ts_order-inb_no IS NOT INITIAL OR ts_order-outb_no IS NOT INITIAL.
          IF ts_order-inb_no IS NOT INITIAL AND ts_order-inb_item IS NOT INITIAL.
            READ TABLE it_vbup TRANSPORTING NO FIELDS
              WITH KEY vbeln = ts_order-inb_no
                       posnr = ts_order-inb_item
                       wbsta = 'C'.
            IF sy-subrc = 0 .
              ts_order-po_status = 'GR Completed'.
            ELSEIF ts_order-outb_no IS NOT INITIAL AND ts_order-outb_item IS NOT INITIAL.
              READ TABLE it_vbup TRANSPORTING NO FIELDS
                WITH KEY vbeln = ts_order-outb_no
                         posnr = ts_order-outb_item
                         wbsta = 'C'.
              IF sy-subrc <> 0.
                ts_order-po_status = 'Outbound Created'.
              ELSE.
                ts_order-po_status = 'Inbound Created'.
              ENDIF.

            ELSE. "added by ismail....to fix status inbound creation
              ts_order-po_status = 'Inbound Created'.
            ENDIF.
          ELSE.
            READ TABLE it_vbup TRANSPORTING NO FIELDS
              WITH KEY vbeln = ts_order-outb_no
               posnr = ts_order-outb_item
               wbsta = 'C'.
            IF sy-subrc = 0.
              ts_order-po_status = 'GI Completed'.
            ELSE.
              ts_order-po_status = 'Outbound Created'.
            ENDIF.
          ENDIF.

        ELSEIF ts_ekko-ebeln IS NOT INITIAL.

          CLEAR: lw_t16fb  .
          READ TABLE lt_t16fb INTO lw_t16fb WITH KEY frgke = ts_ekko-frgke.
          IF sy-subrc EQ 0.
*      IF ts_ekko-frgke = 'R'.
            IF lw_t16fb-kzfre IS NOT INITIAL.
              ts_order-po_status = 'PO Released'.
            ELSE.
              ts_order-po_status = 'PO yet to Release'.
            ENDIF.
          ENDIF.
        ENDIF.

        READ TABLE it_eket
        INTO ts_eket
        WITH KEY ebeln = ts_po-ebeln
        ebelp = ts_po-ebelp+1(5).
        IF sy-subrc = 0.
          IF ts_lips-erdat IS NOT INITIAL AND
            ts_eket-eindt IS NOT INITIAL.
            IF ts_eket-eindt < ts_lips-erdat.
              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
                EXPORTING
                  date1         = ts_lips-erdat
                  date2         = ts_eket-eindt
                  output_format = '03'
                IMPORTING
                  days          = lv_day.
            ELSE.
              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
                EXPORTING
                  date1         = ts_eket-eindt
                  date2         = ts_lips-erdat
                  output_format = '03'
                IMPORTING
                  days          = lv_day.
            ENDIF.
            ts_order-dif_dt = lv_day .
            CLEAR :lv_day.
          ENDIF.
          CONCATENATE  ts_eket-eindt+6(2) '.' ts_eket-eindt+4(2) '.' ts_eket-eindt+0(4) INTO ts_order-exdate.
*      ts_order-exdate = ts_eket-eindt.
        ENDIF.
*
*        CLEAR: lw_ebant.
*        READ TABLE lt_ebant
*        INTO lw_ebant
*        WITH KEY banfn = ts_po-banfn bnfpo = ts_po-bnfpo.
*        IF sy-subrc = 0.
      ENDIF.
      READ TABLE it_orderlist INTO ts_orderlist
      WITH KEY vbeln = lw_ebant-vbeln.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ts_orderlist TO ts_order.
        ts_order-bstnk = ts_po-ebeln.
        ts_order-ebelp = ts_po-ebelp.
*        ts_order-banfn = ts_po-banfn.
*        ts_order-po_quan = ts_po-po_quan.
        ts_order-po_quan = ts_po-menge.

*            LOOP AT it_vbap
*              INTO ts_vbap
*              WHERE vbeln = lw_ebant-vbeln
*          AND posnr = lw_ebant-posnr.
*              AND matnr = ts_po-matnr.
        "Read the DBE order details
        READ TABLE it_vbap INTO ts_vbap
          WITH KEY vbeln = lw_ebant-vbeln
          posnr = lw_ebant-posnr.
        IF sy-subrc = 0.
          ts_order-posnr = ts_vbap-posnr.
          ts_order-ord_quan = ts_vbap-zmeng.
          ts_order-jobs     = ts_vbap-jobs.

*---adding new logic by ismail for delevery status.....
          CLEAR: ts_lips1,ts_order-del_stat.
          READ TABLE it_lips1
          INTO ts_lips1
          WITH KEY /DBE/vbeln = ts_vbap-vbeln
                  /DBE/posnr = ts_vbap-posnr.
          IF sy-subrc EQ 0.
            ts_order-del_stat = 'Delivery Created'.
            READ TABLE it_vbup1 TRANSPORTING NO FIELDS
              WITH KEY vbeln = ts_lips1-vbeln
                       posnr = ts_lips1-posnr
                       wbsta = 'C'.
            IF sy-subrc = 0 .
              ts_order-del_stat = 'Goods issued'.
            ENDIF.
          ENDIF.
*            APPEND ts_order TO it_order.
*            lv_flag = 1.
*        ENDLOOP.
        ENDIF.
      ENDIF.
*        ENDIF.
*--Commenting by ismail to not to show if it is not DBE order....
*    IF lv_flag = 0.
*      APPEND ts_order TO it_order.
*    ELSE.
*      lv_flag = 0.
*    ENDIF.
      "shahid added following 4 lines 8100004362
      READ TABLE lt_vbak_com INTO lw_vbak_com  WITH KEY vbeln = ts_order-outb_no.
      IF sy-subrc EQ 0.
        ts_order-pernr = lw_vbak_com-pernr.
        ts_order-werks = lw_vbak_com-werks.
      ENDIF.
      "Shahid added following five lines
      IF ts_order-po_status IS INITIAL.
        IF ts_order-inb_no IS NOT INITIAL AND ts_order-outb_no IS NOT INITIAL.
          ts_order-po_status = 'PO Created'.
        ENDIF.
      ENDIF.

 READ TABLE IT_VBAP INTO data(LW_VBAP)  WITH KEY vbeln = ts_order-vbeln
                                                 posnr = ts_order-posnr.
      IF sy-subrc EQ 0.
        ts_order-matnr = lw_vbap-matnr.
*        ts_order-matnr = lw_vbap-matnr.
      ENDIF.


      APPEND ts_order TO it_order.
      CLEAR :ts_order,
              ts_po,
              ts_ekko,
              ts_eket,
              ts_lips,
              ts_vbup,
              ts_vbap,
              ts_vbeln_pr,
              ts_orderlist.

    ENDIF.
  ENDLOOP.

  DELETE  it_order WHERE posnr IS INITIAL.
ENDFORM.

FORM prepare_email_body_subj.
  lv_id = 'ST'.
  lv_lang = 'EN'.
  lv_name = 'YPOTR_BODY'.
  lv_object = 'TEXT'.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT   = SY-MANDT
      id       = lv_id
      language = lv_lang
      name     = lv_name
      object   = lv_object
*     ARCHIVE_HANDLE                = 0
*     LOCAL_CAT                     = ' '
* IMPORTING
*     HEADER   =
*     OLD_LINE_COUNTER              =
    TABLES
      lines    = lt_lines.
* EXCEPTIONS
*     ID       = 1
*     LANGUAGE = 2
*     NAME     = 3
*     NOT_FOUND                     = 4
*     OBJECT   = 5
*     REFERENCE_CHECK               = 6
*     WRONG_ACCESS_TO_ARCHIVE       = 7
*     OTHERS   = 8
  .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
*  l_email      = p_email.
*  IF rb_53 = 'X'.
*    lv_mail_subj = |Upcoming Daimler shipment Notification|.
*  ELSE.
*    lv_mail_subj = |Backorder Daimler Shipment Notification|.
*  ENDIF.

  CLEAR: lt_contents.

  LOOP AT lt_lines INTO ts_lines.
*    lw_contents = ts_lines-tdline. "'Dear All,'.
*    CONCATENATE lw_contents lc_new_line INTO lw_contents.
    CASE ts_lines-tdformat.
      WHEN '*'. CONCATENATE ts_lines-tdline lc_new_line INTO lw_contents SEPARATED BY space.
*      	WHEN .
      WHEN OTHERS. CONCATENATE ts_lines-tdline '' INTO lw_contents SEPARATED BY space.
    ENDCASE.
    APPEND lw_contents TO lt_contents.

*  lw_contents = 'Here is attached upcoming Daimler shipment details for your further action, please check and do the needful. '.
*  CONCATENATE lw_contents lc_new_line INTO lw_contents.
*  APPEND lw_contents TO lt_contents.

*  lw_contents = lc_new_line.
*  APPEND lw_contents TO lt_contents.
  ENDLOOP.

  CLEAR lt_lines.
  lv_id = 'ST'.
  lv_lang = 'EN'.
  lv_name = 'YPOTR_HEADER'.
  lv_object = 'TEXT'.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT   = SY-MANDT
      id       = lv_id
      language = lv_lang
      name     = lv_name
      object   = lv_object
*     ARCHIVE_HANDLE                = 0
*     LOCAL_CAT                     = ' '
* IMPORTING
*     HEADER   =
*     OLD_LINE_COUNTER              =
    TABLES
      lines    = lt_lines.
* EXCEPTIONS
*     ID       = 1
*     LANGUAGE = 2
*     NAME     = 3
*     NOT_FOUND                     = 4
*     OBJECT   = 5
*     REFERENCE_CHECK               = 6
*     WRONG_ACCESS_TO_ARCHIVE       = 7
*     OTHERS   = 8
  .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  READ TABLE lt_lines INTO ls_lines INDEX 1.
  lv_mail_subj = ls_lines-tdline.

ENDFORM.

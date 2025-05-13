FUNCTION ydbe_inv_head_partnr_adrs.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(LV_INVOICE_NO) TYPE  VBELN_VF
*"  EXPORTING
*"     REFERENCE(ES_SELLER) TYPE  ZSD_INV_HEAD_MID
*"     REFERENCE(ES_BUYER) TYPE  ZSD_INV_HEAD_MID
*"----------------------------------------------------------------------
  DATA:

    l_adrno_s TYPE adrc-addrnumber,
    l_adrno_p TYPE adrc-addrnumber,
    l_pernr   TYPE p0002-pernr.

  DATA: lv_kunnr  TYPE vbrk-kunag,
        lv_bukrs  TYPE vbrk-bukrs,
        lv_fkart  TYPE vbrk-fkart,
        lv_stceg  TYPE vbrk-stceg,
        lv_cstceg TYPE vbrk-stceg,
        lv_cadrnr TYPE kna1-adrnr.

  CLEAR: lv_kunnr , lv_bukrs, lv_fkart,  lv_stceg,lv_cadrnr,lv_cstceg .

  SELECT SINGLE
       kunag " account number
       bukrs " company code
       fkart " invoice type (eg : pro forma invoice , invoice etc )
       stceg  "vat
       INTO ( lv_kunnr , lv_bukrs, lv_fkart,  lv_stceg )
       FROM vbrk
       WHERE vbeln = lv_invoice_no.

  es_buyer-cust_no = lv_kunnr.

  "*buyer addr no
  IF lv_kunnr IS NOT INITIAL .
    SELECT SINGLE
      adrnr " address number
       stceg  "cust vat
      INTO ( l_adrno_p, lv_cstceg )
      FROM kna1
      WHERE
      kunnr = lv_kunnr.
  ENDIF.
*      seller address no
  SELECT SINGLE adrnr FROM t001 INTO l_adrno_s WHERE bukrs = lv_bukrs.
  IF sy-subrc EQ 0.

  ENDIF.

*------left and right mid headers--------------------------------------------------------------------------------------*
*    seller
  IF l_adrno_s IS NOT INITIAL.
    SELECT addrnumber,date_from,nation,name1,name2,city1,city2,building,country,street, post_code1 ,po_box, sort2 FROM adrc
         INTO TABLE @DATA(it_adrc)
         WHERE addrnumber = @l_adrno_s.

    READ TABLE it_adrc INTO DATA(wa_adr_en) WITH KEY nation = space.

    READ TABLE it_adrc INTO DATA(wa_adr_ar) WITH KEY nation = 'A'.
*    es_seller-name = |{ wa_adr_ar-name1 } { wa_adr_ar-name2 } { cl_abap_char_utilities=>newline } { wa_adr_en-name1 } { wa_adr_en-name2 }|.
    es_seller-name = |{ wa_adr_en-name2 } { cl_abap_char_utilities=>newline } { wa_adr_en-name1 } |.
    es_seller-build_no = |{ wa_adr_en-building }|. "{ cl_abap_char_utilities=>newline }{ wa_adr_ar-building }|.
*    es_seller-street_name = |{ wa_adr_ar-street }{ cl_abap_char_utilities=>newline }{ wa_adr_en-street }|.
    es_seller-street_name = | { wa_adr_en-street } { wa_adr_ar-street }|.
*    es_seller-district = |{ wa_adr_ar-city2 }{ cl_abap_char_utilities=>newline }{ wa_adr_en-city2 }|.
    es_seller-district = |  { wa_adr_en-city2 } { wa_adr_ar-city2 }|.
*    es_seller-city = |{ wa_adr_ar-city1 }{ cl_abap_char_utilities=>newline }{ wa_adr_en-city1 }|.

    SELECT spras,land1,  landx,  natio,  landx50,  natio50 FROM t005t
      INTO TABLE @DATA(it_t005t) WHERE land1 = @wa_adr_en-country.
    IF sy-subrc EQ 0.
      READ TABLE it_t005t INTO DATA(wa_t005e) WITH KEY spras = sy-langu.
      READ TABLE it_t005t INTO DATA(wa_t005a) WITH KEY spras = 'A'.
*      es_seller-country = |{ wa_t005a-landx50 }{ cl_abap_char_utilities=>newline }{ wa_t005e-landx50 } |.
*      es_seller-country = | { wa_t005e-landx50 } { '/' } { wa_t005a-landx50 } { '/' } { wa_adr_en-post_code1 }  |.

      es_seller-city = | { wa_adr_en-city1 } { '/' }  { wa_adr_ar-city1 } { '/' } { wa_t005a-landx50 }|.
*  postal Code:
      es_seller-postal_code = wa_adr_en-post_code1.
*  additional Number:
      es_seller-add_no = wa_adr_en-po_box.
*  vat Number: taken from header details
*  Other buyer ID:
      es_seller-obuyer_id = wa_adr_en-sort2.
      SELECT SINGLE stceg FROM t001 INTO es_seller-vat_no WHERE bukrs = lv_bukrs.
    ENDIF.
  ENDIF.
*   Buyer
  IF l_adrno_p IS NOT INITIAL.
    SELECT addrnumber,date_from,nation,name1,name2,city1,city2,building,country,street, post_code1 ,po_box, sort2 FROM adrc
       INTO TABLE @DATA(it_adrcb)
       WHERE addrnumber = @l_adrno_p.

    READ TABLE it_adrcb INTO DATA(wa_adr_en1) WITH KEY nation = space.

    READ TABLE it_adrcb INTO DATA(wa_adr_ar1) WITH KEY nation = 'A'.

    es_buyer-name = |{ wa_adr_ar1-name1 } { wa_adr_ar1-name2 } { cl_abap_char_utilities=>newline } { wa_adr_en1-name1 } { wa_adr_en1-name2 }|.
    es_buyer-build_no = |{ wa_adr_en1-building }|. "{ cl_abap_char_utilities=>newline }{ wa_adr_ar-building }|.
*    es_buyer-street_name = |{ wa_adr_ar1-street }{ cl_abap_char_utilities=>newline }{ wa_adr_en1-street }|.
    es_buyer-street_name = |  { wa_adr_en1-street } { wa_adr_ar1-street }|.
*    es_buyer-district = |{ wa_adr_ar1-city2 }{ cl_abap_char_utilities=>newline }{ wa_adr_en1-city2 }|.
    es_buyer-district = |  { wa_adr_en1-city2 } { wa_adr_ar1-city2 }|.
*    es_buyer-city = |{ wa_adr_ar1-city1 }{ cl_abap_char_utilities=>newline }{ wa_adr_en1-city1 }|.
*    es_buyer-city = | { wa_adr_en1-city1 } { wa_adr_ar1-city1 }|.
    SELECT spras,land1,  landx,  natio,  landx50,  natio50 FROM t005t
      INTO TABLE @DATA(it_t005t1) WHERE land1 = @wa_adr_en1-country.
    IF sy-subrc EQ 0.
      READ TABLE it_t005t1 INTO DATA(wa_t005e1) WITH KEY spras = sy-langu.

      READ TABLE it_t005t1 INTO DATA(wa_t005a1) WITH KEY spras = 'A'.
*      es_buyer-country = |{ wa_t005a1-landx50 }{ cl_abap_char_utilities=>newline }{ wa_t005e1-landx50 } |.
*      es_buyer-country = | { wa_t005e1-landx50 } { '/' } { wa_t005a1-landx50 } { '/' } { wa_adr_en1-post_code1 } |.
       es_buyer-city = | { wa_adr_en1-city1 } { '/' }  { wa_adr_ar1-city1 } { '/' } { wa_t005a1-landx50 }|.
    ENDIF.
*  postal Code:
    es_buyer-postal_code = wa_adr_en1-post_code1.
*  additional Number:
    es_buyer-add_no = wa_adr_en1-po_box.
*  vat Number: taken from header details
*  Other buyer ID:
    es_buyer-obuyer_id = wa_adr_en1-sort2.
    es_buyer-vat_no = lv_cstceg.

  ENDIF.


ENDFUNCTION.

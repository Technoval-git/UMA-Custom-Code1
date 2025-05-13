class ZCL_MM_SALES_RPT_UTIL definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_items,
        vbeln TYPE vbeln,
        posnr TYPE /dbe/posnr,
      END OF ty_items .
  types:
    tt_items TYPE TABLE OF ty_items .
  types:
    BEGIN OF ty_item_price,
        vbeln          TYPE vbeln,
        posnr          TYPE /dbe/posnr,
        unit_price     TYPE kwert,
        head_disc      TYPE kwert,
        head_disc_perc TYPE kbetr,
        item_disc      TYPE kwert,
        item_disc_perc TYPE kbetr,
        cg_discount    TYPE kwert,
        head_surch     TYPE kwert,
        item_surch     TYPE kwert,
        vat            TYPE kwert,
        gross_value    TYPE kwert,
        cost           TYPE kwert,
      END OF ty_item_price .
  types:
    tt_item_price TYPE TABLE OF ty_item_price .
  types:
    tr_ord_type TYPE RANGE OF /dbe/c_ordertp-aufart .
  types:
    tr_plant  TYPE RANGE OF /dbe/vbak_db-werks .
  types:
    tr_s_org   TYPE RANGE OF /dbe/vbak_db-vkorg .
  types:
    tr_div    TYPE RANGE OF  /dbe/vbak_db-spart .
  types:
    tr_odr_tp TYPE RANGE OF  /dbe/vbap-aufart .
  types:
    tr_cr_dat TYPE RANGE OF  /dbe/vbak_db-audat .
  types:
    tr_inv_dt TYPE RANGE OF  vbrk-fkdat .
  types:
    tr_odr_no TYPE RANGE OF  /dbe/vbak_db-vbeln .
  types:
    tr_odr_st TYPE RANGE OF  /dbe/vbak_db-hstat .
  types:
    tr_sr_adv TYPE RANGE OF  /dbe/vbak_db-pernr .
  types:
    tr_mtrl   TYPE RANGE OF  /dbe/vbap-matnr40 .
  types:
    tr_c_a_id TYPE RANGE OF  /dbe/vbpa-kunnr .
  types:
    tr_bl_usr TYPE RANGE OF  vbrk-ernam .
  types:
    BEGIN OF ty_vbak,
        vbeln           TYPE vbeln,
        audat           TYPE audat,
        pernr           TYPE /dbe/servcons,
        vguid           TYPE vlcvehicle-vguid,
        werks           TYPE /dbe/vbak_db-werks,
        vkorg           TYPE vkorg,
        vtweg           TYPE vtweg,
        spart           TYPE spart,
        hstat           TYPE /dbe/vbak_db-hstat,
        pl_comp_dat     TYPE /dbe/vbak_db-fert_date_tmstp,
        licpl           TYPE /dbe/vbak_db-licpl,
        visit_start_tst TYPE /dbe/vbak_db-visit_start_tst,
        visit_end_tst   TYPE /dbe/vbak_db-visit_end_tst,
      END OF ty_vbak .

  class-methods GET_ITEM_PRICE
    importing
      !IT_ITEMS type TT_ITEMS
      !IV_INVOICE type CRMT_BOOLEAN optional
    exporting
      !ET_ITEM_PRICE type TT_ITEM_PRICE .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MM_SALES_RPT_UTIL IMPLEMENTATION.


  METHOD get_item_price.
    TYPES: BEGIN OF ty_knumv,
             vbeln TYPE vbeln,
             knumv TYPE knumv,
           END OF ty_knumv.

    DATA: lt_knumv      TYPE TABLE OF ty_knumv,
          ls_knumv      TYPE ty_knumv,
          lt_items      TYPE tt_items,
          ls_items      TYPE ty_items,
          ls_item_price TYPE ty_item_price,
          lt_pricing    TYPE TABLE OF prcd_elements,
          ls_pricing    TYPE prcd_elements,
          lv_tabix      TYPE sy-tabix.

    lt_items = it_items.
    SORT lt_items BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_items COMPARING vbeln.
    DELETE lt_items WHERE vbeln IS INITIAL.

    IF lt_items IS NOT INITIAL.
      IF iv_invoice = abap_true.
        SELECT vbeln knumv FROM vbrk
          INTO TABLE lt_knumv
          FOR ALL ENTRIES IN lt_items
          WHERE vbeln = lt_items-vbeln.
      ELSE.
        SELECT vbeln h_knumv FROM /dbe/vbak_db
          INTO TABLE lt_knumv
          FOR ALL ENTRIES IN lt_items
          WHERE vbeln = lt_items-vbeln.
      ENDIF.
      IF lt_knumv IS NOT INITIAL.
        SELECT * FROM prcd_elements INTO TABLE lt_pricing
          FOR ALL ENTRIES IN lt_knumv
          WHERE knumv = lt_knumv-knumv AND kinak = ''.
      ENDIF.
    ENDIF.

    SORT lt_knumv BY vbeln.
    SORT lt_pricing BY knumv kposn.
    LOOP AT it_items INTO ls_items.
      CLEAR: ls_item_price, ls_knumv.
      READ TABLE lt_knumv INTO ls_knumv
        WITH KEY vbeln = ls_items-vbeln
        BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_pricing TRANSPORTING NO FIELDS
          WITH KEY knumv = ls_knumv-knumv kposn = ls_items-posnr
          BINARY SEARCH.
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          LOOP AT lt_pricing INTO ls_pricing FROM lv_tabix.
            IF ls_pricing-knumv <> ls_knumv-knumv
              OR ls_pricing-kposn <> ls_items-posnr.
              EXIT.
            ENDIF.
            CASE ls_pricing-kschl.
              WHEN 'YP01' ."Sales price
                ls_item_price-unit_price = ls_pricing-kbetr * ls_pricing-kkurs.
              WHEN 'QSML' ."Manual Price
                ls_item_price-unit_price = ls_pricing-kbetr * ls_pricing-kkurs.
              WHEN 'YSML' ."Manual Price
                ls_item_price-unit_price = ls_pricing-kbetr * ls_pricing-kkurs.
              WHEN 'QPRT' ."Manual Price
                ls_item_price-unit_price = ls_pricing-kbetr * ls_pricing-kkurs.
              WHEN 'YSP1'.
                ls_item_price-unit_price = ls_pricing-kbetr * ls_pricing-kkurs.
              WHEN 'YCP1'.
                ls_item_price-unit_price = ls_pricing-kbetr * ls_pricing-kkurs.
              WHEN 'YPRS'.
                ls_item_price-unit_price = ls_pricing-kbetr * ls_pricing-kkurs.
              WHEN 'QRTK'."Header discount
                ls_item_price-head_disc = ls_pricing-kwert *  ls_pricing-kkurs.
                ls_item_price-head_disc_perc = ls_pricing-kbetr / 10.
              WHEN 'YRPO'."Item discount
                ls_item_price-item_disc = ls_pricing-kwert * ls_pricing-kkurs.
                ls_item_price-item_disc_perc = ls_pricing-kbetr ."/ 10.
              WHEN 'YP05'."Cust Grp Discount
                ls_item_price-cg_discount = ls_pricing-kwert.
              WHEN 'QZTK'."Header Surcharge
                ls_item_price-head_surch = ls_pricing-kwert  * ls_pricing-kkurs.
              WHEN 'YCHP'."Item Surcharge
                ls_item_price-item_surch = ls_pricing-kwert * ls_pricing-kkurs.
              WHEN 'MWST'."TAX
                ls_item_price-vat = ls_pricing-kwert. " * ls_pricing-kkurs.
              WHEN 'KUMU'."Gross Value
                ls_item_price-gross_value = ls_pricing-kwert * ls_pricing-kkurs.
              WHEN 'QPRS'. "Cost
                ls_item_price-cost = ls_pricing-kwert. "* ls_pricing-kkurs. "new calculation.
            ENDCASE.
          ENDLOOP.
          ls_item_price-vbeln = ls_items-vbeln.
          ls_item_price-posnr = ls_items-posnr.
          ls_item_price-gross_value = ls_item_price-gross_value + ls_item_price-vat.
          APPEND ls_item_price TO et_item_price.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

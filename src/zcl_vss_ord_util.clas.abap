CLASS zcl_vss_ord_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_item,
        vbeln   TYPE /dbe/vbeln_va,
        posnr   TYPE /dbe/posnr,
        zmeng   TYPE /dbe/amount, "Billed qty
        vrkme   TYPE vrkme, "Sales Unit
        meins   TYPE meins, "Base Unit of Measure
        matnr40 TYPE /dbe/matnr, " Material Number
        descr1  TYPE /dbe/s_descr_1, "Short text for sales order item
        h_knumv TYPE knumv,
        netwr   TYPE netwr,
      END OF ty_item .
    TYPES:
      tt_item_prc_det TYPE TABLE OF zst_item_prc_det .

    CLASS-METHODS get_price_details
      IMPORTING
        !iv_knumv     TYPE knumv
        !iv_order_no  TYPE /dbe/vbeln_va
        !iv_posnr     TYPE /dbe/posnr
      EXPORTING
        !es_price_det TYPE zst_item_prc_det .
    CLASS-METHODS get_partner_details
      IMPORTING
        !iv_order_no TYPE /dbe/vbeln_va
      EXPORTING
        !et_part_det TYPE ztt_ord_prtr_det .
    CLASS-METHODS get_header_details
      IMPORTING
        !iv_order_no   TYPE /dbe/vbeln_va
      EXPORTING
        !es_header_det TYPE zst_ord_hdr_det .
    CLASS-METHODS get_order_details
      IMPORTING
        !iv_order_no   TYPE /dbe/vbeln_va
      EXPORTING
        !es_header_det TYPE zst_ord_hdr_det
        !et_part_det   TYPE ztt_ord_prtr_det
        !et_item_det   TYPE ztt_ord_item_det .
    CLASS-METHODS get_item_details
      IMPORTING
        !iv_order_no TYPE /dbe/vbeln_va
      EXPORTING
        !et_item_det TYPE ztt_ord_item_det .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VSS_ORD_UTIL IMPLEMENTATION.


  METHOD get_header_details.

    SELECT SINGLE * FROM /dbe/vbak_db INTO @DATA(ls_vbak)
      WHERE vbeln = @iv_order_no.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT SINGLE zterm FROM /dbe/splhdr_db INTO es_header_det-pyt_terms
      WHERE vbeln = iv_order_no.
    IF sy-subrc = 0.
      SELECT SINGLE vtext FROM tvzbt INTO es_header_det-pyt_terms_a
      WHERE spras = 'A' AND zterm = es_header_det-pyt_terms.

      SELECT SINGLE vtext FROM tvzbt INTO es_header_det-pyt_terms_en
         WHERE spras = 'E' AND zterm = es_header_det-pyt_terms.

    ENDIF.

    es_header_det-order_no = ls_vbak-vbeln.
    es_header_det-created_on = ls_vbak-audat.
    es_header_det-exp_date = ls_vbak-bnddt.
    es_header_det-plant_code = ls_vbak-werks.
    es_header_det-vat_no = ls_vbak-stceg.

    SELECT SINGLE werks FROM /dbe/vbap INTO es_header_det-plant_code
       WHERE vbeln = iv_order_no.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM t001w INTO @DATA(ls_t001w)
          WHERE werks = @es_header_det-plant_code
            AND spras = 'E'.

      es_header_det-plant_name = ls_t001w-name1.
      es_header_det-plant_addr = ls_t001w-stras.
      es_header_det-plant_pocode = ls_t001w-pstlz.
      es_header_det-plant_city = ls_t001w-ort01.
      es_header_det-plant_cntry = ls_t001w-land1.
      es_header_det-plant_region = ls_t001w-regio.

      CLEAR:ls_t001w.
      SELECT SINGLE * FROM t001w INTO ls_t001w
          WHERE werks = es_header_det-plant_code
           AND  spras = 'A'.

      es_header_det-plant_name_ar = ls_t001w-name1.
      es_header_det-plant_addr_ar = ls_t001w-stras.
      es_header_det-plant_pocode_ar = ls_t001w-pstlz.
      es_header_det-plant_city_ar = ls_t001w-ort01.

      SELECT SINGLE natio50 FROM t005t INTO es_header_det-plant_cntry_a
        WHERE spras = 'A' AND land1 = ls_t001w-land1.

      SELECT SINGLE natio50 FROM t005t INTO es_header_det-plant_cntry_en
        WHERE spras = 'E' AND land1 = ls_t001w-land1.
    ENDIF.
*** Get seller CR & VAT
    " CR
    SELECT werks,kunnr FROM t001w INTO TABLE @DATA(lt_werks)
      WHERE werks = @es_header_det-plant_code.

    IF lt_werks[] IS NOT INITIAL.
      SELECT partner,idnumber FROM but0id INTO TABLE @DATA(lt_but0id)
        FOR ALL ENTRIES IN @lt_werks
        WHERE partner = @lt_werks-kunnr
          AND    type = 'CR'.

      READ TABLE lt_but0id INTO DATA(ls_but0id) INDEX 1.
      IF sy-subrc EQ 0.
        es_header_det-cr_seller = ls_but0id-idnumber.
      ENDIF.
      " VAT
      SELECT partner,taxnum FROM dfkkbptaxnum INTO TABLE @DATA(lt_taxnum)
        FOR ALL ENTRIES IN @lt_werks
        WHERE partner = @lt_werks-kunnr
          AND taxtype = 'SA0'.

      READ TABLE lt_taxnum INTO DATA(ls_taxnum) INDEX 1.
      IF sy-subrc EQ 0.
        es_header_det-vat_seller = ls_taxnum-taxnum.
      ENDIF.
    ENDIF.

*    SELECT SINGLE * FROM /dbe/vbak_db INTO @DATA(ls_vbak) WHERE vbeln EQ @iv_order_no.
*    IF sy-subrc EQ 0.
    es_header_det-veh_job_no = ls_vbak-vbeln.
    es_header_det-veh_odo_met = ls_vbak-mileage.
    IF ls_vbak-vguid IS NOT INITIAL.
      SELECT SINGLE * FROM vlcvehicle INTO @DATA(ls_vehicle) WHERE vguid EQ @ls_vbak-vguid.
      IF sy-subrc EQ 0.
        es_header_det-veh_vin = ls_vehicle-vhvin.
        es_header_det-veh_plat = ls_vehicle-/dbe/licext.
        SELECT SINGLE * FROM /dbe/v_model INTO @DATA(ls_model) WHERE mcodesd EQ @ls_vehicle-matnr.
        IF sy-subrc EQ 0.
          SELECT SINGLE * FROM /dbe/v_modelt INTO @DATA(ls_modelt) WHERE model_guid EQ @ls_model-model_guid.
          es_header_det-veh_model = ls_model-mcodesd.
          es_header_det-veh_mod_dec = ls_modelt-motext1.
        ENDIF.
        SELECT SINGLE * FROM /dbe/v_imodel INTO @DATA(ls_veh_model) WHERE product_guid EQ @ls_vehicle-/dbe/iobjguid.
        IF sy-subrc EQ 0.
          es_header_det-veh_mod_year = ls_veh_model-modyear.
        ENDIF.
      ENDIF.
    ENDIF.
*    ENDIF.
**** Get Toll free number TVARVC
DATA: lv_name TYPE char30.
      CONCATENATE 'ZTOLLFREE_' ls_vbak-spart INTO lv_name.
      CONDENSE lv_name.

   SELECT SINGLE low FROM tvarvc INTO es_header_det-toll_freeno
     WHERE name = lv_name.

  ENDMETHOD.


  METHOD get_item_details.

    DATA: ls_items        TYPE ty_item,
          lt_items        TYPE TABLE OF ty_item,
          ls_ord_item_det TYPE zst_ord_item_det,
          lv_knumv        TYPE knumv.

    SELECT * FROM /dbe/vbap INTO CORRESPONDING FIELDS OF TABLE
        lt_items WHERE vbeln = iv_order_no AND abgru  EQ ''.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF lt_items[] IS NOT INITIAL.
      SELECT matnr,maktx FROM makt INTO TABLE @DATA(lt_makt)
        FOR ALL ENTRIES IN @lt_items
        WHERE matnr = @lt_items-matnr40
          AND spras = 'A'.
    ENDIF.

    SELECT SINGLE h_knumv FROM /dbe/vbak_db INTO lv_knumv
      WHERE vbeln = iv_order_no.

    LOOP AT lt_items INTO ls_items.
      ls_ord_item_det-order_no = ls_items-vbeln.
      ls_ord_item_det-posnr = ls_items-posnr.
      ls_ord_item_det-matnr = ls_items-matnr40.
      ls_ord_item_det-mat_desc = ls_items-descr1.
      ls_ord_item_det-qty = ls_items-zmeng.
      ls_ord_item_det-uom = ls_items-meins.

      READ TABLE lt_makt INTO DATA(ls_makt) WITH KEY matnr = ls_items-matnr40.
      IF sy-subrc EQ 0.
        ls_ord_item_det-mat_desc_ar = ls_makt-maktx.
      ENDIF.

      CALL METHOD zcl_vss_ord_util=>get_price_details
        EXPORTING
          iv_order_no  = ls_items-vbeln
          iv_posnr     = ls_items-posnr
          iv_knumv     = lv_knumv
        IMPORTING
          es_price_det = ls_ord_item_det-prc_det.
      IF ls_ord_item_det-prc_det-unit_price1 IS NOT INITIAL.
        clear  ls_ord_item_det-prc_det-unit_price.
        ls_ord_item_det-prc_det-unit_price  = ls_items-netwr / ls_ord_item_det-qty.
      ENDIF.
      INSERT ls_ord_item_det INTO TABLE et_item_det.
      CLEAR ls_ord_item_det.
    ENDLOOP.

  ENDMETHOD.


  METHOD GET_ORDER_DETAILS.

    CALL METHOD get_header_details
      EXPORTING
        iv_order_no = iv_order_no
      IMPORTING
        es_header_det = es_header_det.

    CALL METHOD get_partner_details
      EXPORTING
        iv_order_no = iv_order_no
      IMPORTING
        et_part_det   = et_part_det.


    CALL METHOD zcl_vss_ord_util=>get_item_details
      EXPORTING
        iv_order_no = iv_order_no
      IMPORTING
        et_item_det   = et_item_det.


  ENDMETHOD.


  METHOD get_partner_details.

    DATA: lt_vbpa_temp TYPE TABLE OF /dbe/vbpa,
          lt_part_det  TYPE ztt_inv_prtr_det,
          ls_part_det  TYPE zst_inv_prtr_det,
          ls_per_data  TYPE bapibus1006_central_person,
          ls_org_data  TYPE bapibus1006_central_organ,
          lt_but000    TYPE STANDARD TABLE OF but000,
          ls_but000    TYPE but000,
          lt_adrp      TYPE STANDARD TABLE OF adrp,
          ls_adrp      TYPE adrp,
          lt_adrc      TYPE STANDARD TABLE OF adrc,
          ls_adrc      TYPE adrc,
          lt_but021_fs TYPE STANDARD TABLE OF but021_fs,
          ls_but021_fs TYPE but021_fs.

    SELECT * FROM /dbe/vbpa INTO TABLE @DATA(lt_vbpa) WHERE vbeln = @iv_order_no.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lt_vbpa_temp = lt_vbpa.

    SORT lt_vbpa_temp BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_vbpa_temp COMPARING kunnr.

    SELECT * FROM but000 INTO TABLE lt_but000
             FOR ALL ENTRIES IN lt_vbpa_temp WHERE  partner EQ lt_vbpa_temp-kunnr.
    IF lt_but000 IS NOT INITIAL.

      SELECT * FROM but021_fs INTO TABLE lt_but021_fs
               FOR ALL ENTRIES IN  lt_but000 WHERE partner EQ lt_but000-partner.

      IF lt_but021_fs IS NOT INITIAL.
        SELECT * FROM adrc INTO TABLE lt_adrc
                 FOR ALL ENTRIES IN lt_but021_fs WHERE addrnumber EQ lt_but021_fs-addrnumber.

      ENDIF.
      SELECT * FROM adrp INTO TABLE lt_adrp
               FOR ALL ENTRIES IN lt_but000 WHERE persnumber EQ lt_but000-persnumber.
    ENDIF.

    LOOP AT lt_vbpa_temp INTO DATA(ls_vbpa_temp).

      CLEAR ls_part_det.
      ls_part_det-invoice = iv_order_no.
      CALL FUNCTION 'BAPI_BUPA_ADDRESS_GETDETAIL'
        EXPORTING
          businesspartner = ls_vbpa_temp-kunnr
        IMPORTING
          addressdata     = ls_part_det-addr_data.

      CALL FUNCTION 'BAPI_BUPA_CENTRAL_GETDETAIL'
        EXPORTING
          businesspartner         = ls_vbpa_temp-kunnr
*         VALID_DATE              = SY-DATLO
*         IV_REQ_MASK             = ' '
        IMPORTING
*         CENTRALDATA             =
          centraldataperson       = ls_per_data
          centraldataorganization = ls_org_data.
      IF ls_per_data IS NOT INITIAL.
        CONCATENATE ls_per_data-firstname ls_per_data-middlename ls_per_data-lastname
          INTO ls_part_det-full_name SEPARATED BY ' '.
      ELSEIF ls_org_data IS NOT INITIAL.
        CONCATENATE ls_org_data-name1 ls_org_data-name2 ls_org_data-name3
          INTO ls_part_det-full_name SEPARATED BY ' ' .
      ENDIF.

      SELECT * FROM but0id INTO TABLE ls_part_det-id_details
        WHERE partner = ls_vbpa_temp-kunnr.

      SELECT * FROM dfkkbptaxnum INTO TABLE ls_part_det-tax_data
        WHERE partner = ls_vbpa_temp-kunnr.

      LOOP AT lt_vbpa INTO DATA(ls_vbpa) WHERE kunnr = ls_vbpa_temp-kunnr.
        CLEAR : ls_part_det-bp_type, ls_part_det-adrp_en, ls_part_det-adrp_ar, ls_part_det-adrc_ar, ls_part_det-adrc_en.
        READ TABLE lt_but000 INTO ls_but000 WITH KEY partner = ls_vbpa-kunnr.
        IF sy-subrc EQ 0.
          ls_part_det-bp_type = ls_but000-type.
          IF ls_but000-bu_group NE 'ZONT'.
          IF ls_part_det-bp_type EQ '1'.
              READ TABLE lt_adrp INTO ls_adrp WITH KEY persnumber = ls_but000-persnumber nation = ''.
              IF sy-subrc EQ 0.
                MOVE-CORRESPONDING ls_adrp TO ls_part_det-adrp_en.
              ENDIF.
              READ TABLE lt_adrp INTO ls_adrp WITH KEY persnumber = ls_but000-persnumber nation = 'A'.
              IF sy-subrc EQ 0.
                MOVE-CORRESPONDING ls_adrp TO ls_part_det-adrp_ar.
              ENDIF.
            ENDIF.
            READ TABLE lt_but021_fs INTO ls_but021_fs WITH KEY partner = ls_but000-partner.
            IF sy-subrc EQ 0.
              READ TABLE lt_adrc INTO ls_adrc WITH KEY addrnumber = ls_but021_fs-addrnumber nation = ''.
              IF sy-subrc EQ 0.
                MOVE-CORRESPONDING ls_adrc TO ls_part_det-adrc_en.
              ENDIF.
              READ TABLE lt_adrc INTO ls_adrc WITH KEY addrnumber = ls_but021_fs-addrnumber nation = 'A'.
              IF sy-subrc EQ 0.
                MOVE-CORRESPONDING ls_adrc TO ls_part_det-adrc_ar.
              ENDIF.
            ENDIF.
          ELSE.
            SELECT * FROM adrc INTO TABLE @DATA(lt_adrc1) WHERE addrnumber EQ @ls_vbpa-adrnr.
            IF lt_adrc1 IS NOT INITIAL .
              READ TABLE lt_adrc1 INTO ls_adrc WITH KEY addrnumber = ls_vbpa-adrnr nation = ''.
              IF sy-subrc EQ 0.
                CONCATENATE ls_adrc-name1 ls_adrc-name2 INTO ls_part_det-full_name SEPARATED BY ' '.
                MOVE-CORRESPONDING ls_adrc TO ls_part_det-adrc_en.
              ENDIF.
              READ TABLE lt_adrc1 INTO ls_adrc WITH KEY addrnumber = ls_vbpa-adrnr nation = 'A'.
              IF sy-subrc EQ 0.
                CONCATENATE ls_adrc-name1 ls_adrc-name2 INTO ls_part_det-full_name SEPARATED BY ' '.
                MOVE-CORRESPONDING ls_adrc TO ls_part_det-adrc_ar.
              ENDIF.
            ENDIF.
          ENDIF.
*          IF ls_part_det-bp_type EQ '1'.
*            READ TABLE lt_adrp INTO ls_adrp WITH KEY persnumber = ls_but000-persnumber nation = ''.
*            IF sy-subrc EQ 0.
*              MOVE-CORRESPONDING ls_adrp TO ls_part_det-adrp_en.
*            ENDIF.
*            READ TABLE lt_adrp INTO ls_adrp WITH KEY persnumber = ls_but000-persnumber nation = 'A'.
*            IF sy-subrc EQ 0.
*              MOVE-CORRESPONDING ls_adrp TO ls_part_det-adrp_ar.
*            ENDIF.
*          ENDIF.
*          READ TABLE lt_but021_fs INTO ls_but021_fs WITH KEY partner = ls_but000-partner.
*          IF sy-subrc EQ 0.
*            READ TABLE lt_adrc INTO ls_adrc WITH KEY addrnumber = ls_but021_fs-addrnumber nation = ''.
*            IF sy-subrc EQ 0.
*              MOVE-CORRESPONDING ls_adrc TO ls_part_det-adrc_en.
*            ENDIF.
*            READ TABLE lt_adrc INTO ls_adrc WITH KEY addrnumber = ls_but021_fs-addrnumber nation = 'A'.
*            IF sy-subrc EQ 0.
*              MOVE-CORRESPONDING ls_adrc TO ls_part_det-adrc_ar.
*            ENDIF.
*          ENDIF.
        ENDIF.

        ls_part_det-parvw = ls_vbpa-parvw.
        ls_part_det-kunnr = ls_vbpa-kunnr.

        INSERT ls_part_det INTO TABLE et_part_det.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_price_details.

    SELECT * FROM prcd_elements INTO TABLE @DATA(lt_prd_ele)
        WHERE knumv = @iv_knumv AND kposn = @iv_posnr.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    es_price_det-knumv = iv_knumv.

    "Read Condition Type Details from Invoice

    SELECT * FROM t685a INTO TABLE @DATA(lt_t685a)
        FOR ALL ENTRIES IN @lt_prd_ele
        WHERE kschl = @lt_prd_ele-kschl AND
              kappl = 'V'.

    "Unit Price
    LOOP AT lt_t685a INTO DATA(ls_t685a) WHERE koaid = 'B'.
      READ TABLE lt_prd_ele INTO DATA(ls_prd_ele)
        WITH KEY kschl = ls_t685a-kschl kinak = ' ' kstat = ' '.
      IF sy-subrc = 0.
        es_price_det-unit_price = ls_prd_ele-kbetr.
      ENDIF.
      IF ( ls_t685a-kschl = 'YWP1' or ls_t685a-kschl = 'YSP1' ).
        es_price_det-unit_price1 = ls_prd_ele-kbetr.
      ENDIF.
    ENDLOOP.

    "Discount Rate
    LOOP AT lt_t685a INTO ls_t685a WHERE koaid = 'A' AND knega ='X' AND krech = 'A'.
      READ TABLE lt_prd_ele INTO ls_prd_ele WITH KEY kschl = ls_t685a-kschl  kinak = ' '.
      IF sy-subrc = 0.
        es_price_det-dis_rate  = es_price_det-dis_rate + ls_prd_ele-kbetr.
        es_price_det-dis_amount  = es_price_det-dis_amount  + ls_prd_ele-kwert.
      ENDIF.
    ENDLOOP.

    "Discount Price
    LOOP AT lt_t685a INTO ls_t685a WHERE koaid = 'A' AND knega ='X' AND krech = 'B'.
      READ TABLE lt_prd_ele INTO ls_prd_ele WITH KEY kschl = ls_t685a-kschl kinak = ' '.
      IF sy-subrc = 0.
        es_price_det-dis_amount  = es_price_det-dis_amount  + ls_prd_ele-kwert.
      ENDIF.
    ENDLOOP.

    "Surcharge
    LOOP AT lt_t685a INTO ls_t685a WHERE koaid = 'A' AND knega ='A' AND krech = 'B'.
      READ TABLE lt_prd_ele INTO ls_prd_ele WITH KEY kschl = ls_t685a-kschl kinak = ' '.
      IF sy-subrc = 0.
        es_price_det-surcharge_amt  = es_price_det-surcharge_amt + ls_prd_ele-kwert.
      ENDIF.
    ENDLOOP.

    "VAT
    READ TABLE lt_prd_ele INTO ls_prd_ele WITH KEY kschl = 'MWST' kinak = ' '.
    IF sy-subrc = 0.
      es_price_det-vat_rate    = ls_prd_ele-kbetr.
      es_price_det-vat_amount  = ls_prd_ele-kwert.
    ENDIF.

    "Net Price
    READ TABLE lt_prd_ele INTO ls_prd_ele WITH KEY kschl = 'KUMU' kinak = ' '.
    IF sy-subrc = 0.
      es_price_det-net_value    = ls_prd_ele-kbetr.
    ENDIF.

    "Gross Price
    es_price_det-gross_value    = ls_prd_ele-kbetr + es_price_det-vat_amount + es_price_det-surcharge_amt.


  ENDMETHOD.
ENDCLASS.

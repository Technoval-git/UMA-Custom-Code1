class ZCL_INVOICE_UTIL definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_item,
        vbeln      TYPE vbeln_vf,
        posnr      TYPE posnr_vf,
        fkimg      TYPE fkimg, "Billed qty
        vrkme      TYPE vrkme, "Sales Unit
        meins      TYPE meins, "Base Unit of Measure
        matnr      TYPE  matnr, " Material Number
        arktx      TYPE arktx, "Short text for sales order item
        knumv_ana  TYPE knumv,
        /dbe/vbeln TYPE /dbe/vbeln_va,
        /dbe/posnr TYPE /dbe/posnr,
      END OF ty_item .
  types:
    tt_item_prc_det TYPE TABLE OF zst_item_prc_det .

  class-methods GET_PRICE_DETAILS
    importing
      !IV_KNUMV type KNUMV
      !IV_KPOSN type KPOSN
    exporting
      !ES_PRICE_DET type ZST_ITEM_PRC_DET .
  class-methods GET_PARTNER_DETAILS
    importing
      !IV_INVOICE_NO type VBELN
    exporting
      !ET_PART_DET type ZTT_INV_PRTR_DET .
  class-methods GET_HEADER_DETAILS
    importing
      !IV_INVOICE_NO type VBELN
    exporting
      !ES_HEADER_DET type ZST_INV_HDR_DET .
  class-methods GET_INVOICE_DETAILS
    importing
      !IV_INVOICE_NO type VBELN
    exporting
      !ES_HEADER_DET type ZST_INV_HDR_DET
      !ET_PART_DET type ZTT_INV_PRTR_DET
      !ET_ITEM_DET type ZTT_INV_ITEM_DET .
  class-methods GET_ITEM_DETAILS
    importing
      !IV_INVOICE_NO type VBELN
    exporting
      !ET_ITEM_DET type ZTT_INV_ITEM_DET .
  class-methods GET_PREP_QR_CODE
    importing
      value(IV_INVOICE_NO) type VBELN optional
    exporting
      !EV_QR_CODE type XSTRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INVOICE_UTIL IMPLEMENTATION.


  METHOD get_header_details.

    SELECT SINGLE * FROM vbrk INTO @DATA(ls_vbrk)
      WHERE vbeln = @iv_invoice_no.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    es_header_det-invoice_no = ls_vbrk-vbeln.
    es_header_det-invoiced_on = ls_vbrk-fkdat.
    es_header_det-plant_code = ls_vbrk-waerk.
    es_header_det-pric_proc = ls_vbrk-kalsm.
    es_header_det-pyt_terms = ls_vbrk-zterm.
    es_header_det-vat_no = ls_vbrk-stceg.

    SELECT SINGLE werks FROM vbrp INTO es_header_det-plant_code
       WHERE vbeln = iv_invoice_no.
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


    SELECT SINGLE vtext FROM tvzbt INTO es_header_det-pyt_terms_a
       WHERE spras = 'A' AND zterm = ls_vbrk-zterm.

    SELECT SINGLE vtext FROM tvzbt INTO es_header_det-pyt_terms_en
       WHERE spras = 'E' AND zterm = ls_vbrk-zterm.
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
*        FOR ALL ENTRIES IN @lt_werks
        WHERE partner = 'P1200'
          AND taxtype = 'SA0'.

      READ TABLE lt_taxnum INTO DATA(ls_taxnum) INDEX 1.
      IF sy-subrc EQ 0.
        es_header_det-vat_seller = ls_taxnum-taxnum.
      ENDIF.
    ENDIF.
    DATA(lv_vbeln) = ls_vbrk-zuonr+3(10).
    SELECT SINGLE * FROM /dbe/vbak_db INTO @DATA(ls_vbak) WHERE vbeln EQ @lv_vbeln.
    IF sy-subrc EQ 0.
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
    ENDIF.

*** Get Toll free number TVARVC
DATA: lv_name TYPE char30.
      CONCATENATE 'ZTOLLFREE_' ls_vbrk-spart INTO lv_name.
      CONDENSE lv_name.

   SELECT SINGLE low FROM tvarvc INTO es_header_det-toll_freeno
     WHERE name = lv_name.
  ENDMETHOD.


  METHOD get_invoice_details.

    CALL METHOD get_header_details
      EXPORTING
        iv_invoice_no = iv_invoice_no
      IMPORTING
        es_header_det = es_header_det.

    CALL METHOD get_partner_details
      EXPORTING
        iv_invoice_no = iv_invoice_no
      IMPORTING
        et_part_det   = et_part_det.


    CALL METHOD zcl_invoice_util=>get_item_details
      EXPORTING
        iv_invoice_no = iv_invoice_no
      IMPORTING
        et_item_det   = et_item_det.


  ENDMETHOD.


  METHOD get_item_details.

    DATA: ls_items          TYPE ty_item,
          lt_items          TYPE TABLE OF ty_item,
          ls_inv_item_det   TYPE zst_inv_item_det,
          ls_veh_inv_detail TYPE zst_veh_inv_det,
          ls_vlcvehicle     TYPE vlcvehicle,
          lt_vbap           TYPE STANDARD TABLE OF /dbe/vbap,
          ls_vbap           TYPE /dbe/vbap,
          lv_2tone          TYPE c.

    SELECT * FROM vbrp INTO CORRESPONDING FIELDS OF TABLE
        lt_items WHERE vbeln = iv_invoice_no.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    IF lt_items[] IS NOT INITIAL.
    SELECT matnr,maktx FROM makt INTO TABLE @DATA(lt_makt)
      FOR ALL ENTRIES IN @lt_items
      WHERE matnr = @lt_items-matnr
        AND spras = 'A'.
    ENDIF.

    READ TABLE lt_items INTO ls_items INDEX 1.

    SELECT * FROM /dbe/vbap INTO TABLE lt_vbap WHERE vbeln EQ ls_items-/dbe/vbeln.

    SELECT SINGLE zuonr FROM vbrk  INTO @DATA(lv_zuonr) WHERE vbeln EQ @iv_invoice_no.

    SELECT * FROM /dbe/split INTO TABLE @DATA(lt_split) WHERE vbeln EQ @ls_items-/dbe/vbeln AND
                                                              splnr EQ @lv_zuonr+14(4).

    LOOP AT lt_items INTO ls_items.
      READ TABLE lt_vbap INTO ls_vbap WITH KEY vbeln = ls_items-/dbe/vbeln posnr = ls_items-/dbe/posnr.
      ls_inv_item_det-invoice_no = ls_items-vbeln.
      ls_inv_item_det-posnr = ls_items-posnr.
      ls_inv_item_det-matnr = ls_items-matnr.
      ls_inv_item_det-mat_desc = ls_items-arktx.
      ls_inv_item_det-qty = ls_items-fkimg.
      ls_inv_item_det-uom = ls_items-meins.

      READ TABLE lt_makt INTO DATA(ls_makt) WITH KEY matnr = ls_items-matnr.
      IF sy-subrc EQ 0.
      ls_inv_item_det-mat_desc_ar = ls_makt-maktx.
      ENDIF.

      CALL METHOD zcl_invoice_util=>get_price_details
        EXPORTING
          iv_knumv     = ls_items-knumv_ana
          iv_kposn     = ls_inv_item_det-posnr
        IMPORTING
          es_price_det = ls_inv_item_det-prc_det.

      IF ls_vbap-itcat EQ 'P001' OR  ls_vbap-itcat EQ 'P008'.
*        ls_inv_item_det-prc_det-unit_price = ls_inv_item_det-prc_det-unit_price * ls_inv_item_det-qty.
        ls_inv_item_det-qty = 1.
      ENDIF.

      ls_inv_item_det-prc_det-unit_price = ls_inv_item_det-prc_det-unit_price /  ls_inv_item_det-qty.

      IF ls_vbap-main_item IS INITIAL AND ls_vbap-itcat EQ 'P003'.
        SELECT SINGLE * FROM vlcvehicle INTO ls_vlcvehicle WHERE vguid EQ ls_vbap-vguid.
        IF sy-subrc EQ 0.
          IF sy-subrc EQ 0.
            ls_veh_inv_detail-vin_num = ls_vlcvehicle-vhvin.
            SELECT SINGLE * FROM /dbe/v_model INTO @DATA(ls_model) WHERE mcodesd EQ @ls_vlcvehicle-matnr.
            IF sy-subrc EQ 0.
              ls_veh_inv_detail-model = ls_model-mcodesd.
              SELECT SINGLE * FROM /dbe/v_modelt INTO @DATA(ls_modelt) WHERE model_guid EQ @ls_model-model_guid.
              ls_veh_inv_detail-eng_arabic =  ls_modelt-motext1.
              ls_veh_inv_detail-desc_arabic =  ls_modelt-motext2.
            ENDIF.
            SELECT SINGLE * FROM /dbe/v_imodel INTO @DATA(ls_veh_model) WHERE product_guid EQ @ls_vlcvehicle-/dbe/iobjguid.
            IF sy-subrc EQ 0.
              ls_veh_inv_detail-mod_year = ls_veh_model-modyear.
            ENDIF.
            SELECT SINGLE * FROM /dbe/v_ivehicle INTO @DATA(ls_i_vehicle) WHERE product_guid EQ @ls_vlcvehicle-/dbe/iobjguid.
            IF sy-subrc EQ 0.
              ls_veh_inv_detail-eng_no = ls_i_vehicle-engcode.
            ENDIF.
            SELECT SINGLE * FROM /dbe/v_ioptiont INTO @DATA(ls_i_options) WHERE product_guid EQ @ls_vlcvehicle-/dbe/iobjguid AND
                                                                                opclass EQ 'C'.
            IF sy-subrc EQ 0.
              ls_veh_inv_detail-ext_color = ls_i_options-optext1.
              IF ls_i_options-opkey CA '+'.
                lv_2tone = 'X'.
              ENDIF.
            ENDIF.
            SELECT SINGLE * FROM /dbe/v_ioptiont INTO ls_i_options WHERE product_guid EQ ls_vlcvehicle-/dbe/iobjguid AND
                                                                                opclass EQ 'I'.
            IF sy-subrc EQ 0.
              ls_veh_inv_detail-int_color = ls_i_options-optext1.
            ENDIF.
          ENDIF.
          ls_inv_item_det-veh_details = ls_veh_inv_detail.
        ENDIF.
      ENDIF.
      IF ls_vbap-opclass NE 'C'  AND ls_vbap-opclass NE 'I'.
        INSERT ls_inv_item_det INTO TABLE et_item_det.
        CLEAR ls_inv_item_det.
      ENDIF.
      IF lv_2tone EQ 'X' AND ls_vbap-opclass EQ 'C'.
        INSERT ls_inv_item_det INTO TABLE et_item_det.
        CLEAR ls_inv_item_det.
        CLEAR lv_2tone.
      ENDIF.

    ENDLOOP.

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

    SELECT SINGLE zuonr FROM vbrk INTO @DATA(lv_zuonr) WHERE vbeln = @iv_invoice_no.

    SELECT * FROM /dbe/vbpa INTO TABLE @DATA(lt_vbpa) WHERE vbeln = @lv_zuonr+3(10)." AND split EQ @lv_zuonr+14(4).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    READ TABLE lt_vbpa INTO DATA(ls_vbpa1) WITH KEY parvw = 'RE' split = lv_zuonr+14(4).
    IF sy-subrc EQ 0 AND ls_vbpa1-split NE '0001'.
      DELETE  lt_vbpa WHERE split = '0001' AND parvw = 'RE'.
      ls_vbpa1-split = '0001'.
      MODIFY TABLE lt_vbpa FROM ls_vbpa1.
      DELETE  lt_vbpa WHERE split = lv_zuonr+14(4).

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
      ls_part_det-invoice = iv_invoice_no.
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

        ENDIF.
        ls_part_det-parvw = ls_vbpa-parvw.
        ls_part_det-kunnr = ls_vbpa-kunnr.
        INSERT ls_part_det INTO TABLE et_part_det.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  method GET_PREP_QR_CODE.

    DATA:

      lv_source_key TYPE edoc_source_key,

      lv_edoc_guid  TYPE edoc_guid,

      lv_qr_code_x  TYPE edoc_sa_xstring,

      lv_qr_code    TYPE string,

      lv_bitmap     TYPE xstring.

    CONSTANTS:

      lc_module_size      TYPE i VALUE '6',

      lc_mode             TYPE char1 VALUE 'U',

      lc_error_correction TYPE char1 VALUE 'M'.

    "Get Data from eDocument Table for SD/FI Source Document

    DATA :

      lv_belnr TYPE belnr_d,

      lv_bukrs TYPE bukrs,

      lv_gjahr TYPE gjahr,

      lv_fkdat TYPE datum.


    CLEAR ev_qr_code.


    SELECT SINGLE fkdat bukrs FROM vbrk INTO (lv_fkdat,lv_bukrs)
      WHERE vbeln = iv_invoice_no.

    lv_belnr = iv_invoice_no.
    lv_gjahr = lv_fkdat+0(4).

*    cl_edoc_source_fi_invoice=>pack_key(
*
*    EXPORTING
*
*     iv_bukrs = lv_bukrs
*
*    iv_gjahr = lv_gjahr
*
*    iv_belnr = lv_belnr
*
*    IMPORTING ev_key = lv_source_key ).

   lv_source_key =  lv_belnr.

*****    "Make sure to populate the variable lv_source_key according to your
*****
*****    "Source Document ( SD/FI )
*****
*****    "Also eDocument should be in GeneratedAndStored or SentToCustomer Status
*****
    SELECT SINGLE edoc_guid FROM edocument INTO lv_edoc_guid

    WHERE source_key = lv_source_key AND proc_status <> 'CREATED'.

    IF lv_edoc_guid IS NOT INITIAL.

      "Get QR Code Data from KSA Specific Database Table using eDocument GUID

      SELECT SINGLE qr_code FROM edosainv INTO lv_qr_code_x WHERE edoc_guid = lv_edoc_guid.

      IF lv_qr_code_x IS NOT INITIAL.

        lv_qr_code = cl_http_utility=>if_http_utility~encode_x_base64( unencoded = lv_qr_code_x ).

        "Convert to BMP formatted QR Code

        IF lv_qr_code IS NOT INITIAL.

          cl_rstx_barcode_renderer=>qr_code(

           EXPORTING

          i_module_size = lc_module_size

          i_mode = lc_mode

           i_error_correction = lc_error_correction

           i_barcode_text = lv_qr_code

          IMPORTING

          e_bitmap = ev_qr_code ).

        ENDIF.

      ENDIF.

     ENDIF.



  endmethod.


  METHOD get_price_details.

    SELECT * FROM prcd_elements INTO TABLE @DATA(lt_prd_ele)
        WHERE knumv = @iv_knumv AND kposn = @iv_kposn.
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
        WITH KEY kschl = 'QPK3'.
      IF sy-subrc = 0.

        READ TABLE lt_prd_ele INTO ls_prd_ele
        WITH KEY kschl = 'KUMU'.
        IF sy-subrc = 0.
          es_price_det-unit_price = ls_prd_ele-kwert.
        ENDIF.

      ENDIF.
**      "Start DS4K903141
*      IF es_price_det-unit_price IS INITIAL.
      READ TABLE lt_prd_ele INTO DATA(ls_prd_ele1)
       WITH KEY kschl = 'ZMG1'.
      IF sy-subrc = 0.
        READ TABLE lt_prd_ele INTO ls_prd_ele1
        WITH KEY kschl = 'KUMU'.
        IF sy-subrc = 0.
          es_price_det-unit_price = ls_prd_ele1-kwert.
        ENDIF.
      ENDIF.
*      ENDIF.
**      "End DS4K903141
      IF es_price_det-unit_price IS INITIAL.
        READ TABLE lt_prd_ele INTO ls_prd_ele
          WITH KEY kschl = ls_t685a-kschl kinak = ' ' kstat = ' '.
        IF sy-subrc = 0.
          es_price_det-unit_price = ls_prd_ele-kwert.
        ENDIF.
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

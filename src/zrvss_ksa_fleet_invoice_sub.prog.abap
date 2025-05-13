*&---------------------------------------------------------------------*
*& Report ZVSS_VEHICLE_retail_INVOICE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
************************************************************************
* Author                 :  Karmegam Balaraman                         *
* Creation date          :  12.08.2024                                 *
* Functional Responsible :  Venkateswaran & Manikandan                 *
* Description            :  Vehicle Fleet(Bulk) invoice driver program *
*______________________________________________________________________*
REPORT zrvss_ksa_fleet_invoice_sub.

TABLES: nast, tnapr.

DATA: wg_fm_name          TYPE rs38l_fnam ##NEEDED,      " FM Name
      wg_fp_docparams     TYPE sfpdocparams ##NEEDED,
      wg_fp_outputparams  TYPE fpformoutput ##NEEDED,
      wg_job_outputparams TYPE sfpoutputparams  ##NEEDED,
      wg_result           TYPE sfpjoboutput ##NEEDED.

DATA : lv_device TYPE output_device,
       BEGIN OF gs_nast.
         INCLUDE STRUCTURE nast.
DATA: email_addr TYPE ad_smtpadr,
       END OF gs_nast,
       gv_screen_display TYPE char1,
       gv_language       TYPE sylangu,
       gv_dummy          TYPE char1,
       g_msgv1           TYPE sy-msgv1,
       g_form_name       TYPE fpname.

DATA:gt_item_det   TYPE zvss_retail_item_det,
     gs_item_det   TYPE zvss_s_retail_item,
     gs_item_temp  TYPE zvss_s_retail_item,
     gs_header     TYPE zvss_retail_hdr_info,
     gs_item_total TYPE zvss_retail_total.
DATA:obj_inv_util    TYPE REF TO zcl_invoice_util_veh,
     gs_inv_hdr_det  TYPE zst_inv_hdr_det,
     gt_inv_item_det TYPE ztt_inv_item_det,
     gt_inv_part_det TYPE ztt_inv_prtr_det.

DATA : lv_pcount TYPE string,
       lv_licext TYPE vlcvehicle-/dbe/licext.

*CONSTANTS : c_form_name TYPE fpname VALUE 'ZSDAD_MCPL_INVOICE'.


START-OF-SELECTION.

FORM entry USING return_code us_screen.

  DATA: lf_retcode TYPE sy-subrc.
*  xscreen = us_screen.
  gv_screen_display = us_screen.
  gs_nast           = nast.
  gv_language = gs_nast-spras.
  PERFORM processing USING    us_screen
                     CHANGING lf_retcode.
  IF lf_retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM PROCESSING                                               *
*---------------------------------------------------------------------*
FORM processing USING    proc_screen
                CHANGING cf_retcode.

* Get Header & Buyer information

  DATA:lv_curr  TYPE vbrp-waerk,
       lv_kunnr TYPE kunnr.

  CREATE OBJECT obj_inv_util.
  REFRESH: gt_item_det,gt_inv_part_det,gt_inv_item_det.
  CLEAR:gs_header,gs_inv_hdr_det,gs_item_total.

  gs_header-invoice_no = gs_nast-objky.



*** Getting invoice details
  CALL METHOD obj_inv_util->get_invoice_details
    EXPORTING
      iv_invoice_no = gs_header-invoice_no
    IMPORTING
      es_header_det = gs_inv_hdr_det
      et_part_det   = gt_inv_part_det
      et_item_det   = gt_inv_item_det.

***Generate QR CODE
  CALL METHOD obj_inv_util->get_prep_qr_code
    EXPORTING
      iv_invoice_no = gs_header-invoice_no
    IMPORTING
      ev_qr_code    = gs_header-qr_code.
**----------------------------To Concatenate footer Address--------------
  CONCATENATE 'P' gs_inv_hdr_det-plant_code INTO lv_kunnr.
*  BREAK-POINT.
  SELECT SINGLE * INTO @DATA(ls_kna1)
    FROM kna1
    WHERE kunnr = @lv_kunnr.
  IF ls_kna1-adrnr IS NOT INITIAL.
    SELECT SINGLE * FROM adrc INTO @DATA(ls_adrc)
    WHERE addrnumber = @ls_kna1-adrnr
      AND nation = ''.
*    BREAK-POINT.
    IF ls_adrc-house_num1 IS INITIAL.
      CONCATENATE  ls_adrc-street ',' ls_adrc-city1 ',' ls_adrc-po_box INTO gs_inv_hdr_det-plant_addr SEPARATED BY space.
    ELSE.
      CONCATENATE ls_adrc-house_num1 ',' ls_adrc-street ',' ls_adrc-city1 ',' ls_adrc-po_box INTO gs_inv_hdr_det-plant_addr SEPARATED BY space.
    ENDIF.
    CONDENSE gs_inv_hdr_det-plant_addr.
    CLEAR:ls_adrc.
    SELECT SINGLE * FROM adrc INTO ls_adrc
      WHERE addrnumber = ls_kna1-adrnr
        AND nation = 'A'.
    IF ( ls_adrc-house_num1 IS INITIAL OR ls_adrc-street IS INITIAL OR ls_adrc-city1 IS INITIAL OR ls_adrc-po_box IS INITIAL ).
*          CONCATENATE ls_adrc-house_num1 ',' ls_adrc-street ',' ls_adrc-city1 ',' ls_adrc-po_box INTO gs_inv_hdr_det-plant_addr_ar SEPARATED BY space.
    ELSE.
      CONCATENATE ls_adrc-house_num1 ',' ls_adrc-street ',' ls_adrc-city1 ',' ls_adrc-po_box INTO gs_inv_hdr_det-plant_addr_ar SEPARATED BY space.
    ENDIF.
    CONDENSE gs_inv_hdr_det-plant_addr_ar.
  ENDIF.
*-----------------------------------

  gs_header-name1_ft     =  gs_inv_hdr_det-plant_name.
  gs_header-street_ft    = gs_inv_hdr_det-plant_addr.
  gs_header-city_ft      = gs_inv_hdr_det-plant_city.
  gs_header-plant_pocode = gs_inv_hdr_det-plant_pocode.
  gs_header-plant_cntry  = gs_inv_hdr_det-plant_cntry.

  gs_header-name1_ar_ft     = gs_inv_hdr_det-plant_name_ar.
  gs_header-street_ar_ft = gs_inv_hdr_det-plant_addr_ar.
  gs_header-city_ar_ft  = gs_inv_hdr_det-plant_city_ar.
  gs_header-plant_pocode_ar = gs_inv_hdr_det-plant_pocode_ar.
  gs_header-plant_cntry_ar  = gs_inv_hdr_det-plant_cntry_a.
  gs_header-cr_seller   = gs_inv_hdr_det-cr_seller.
  gs_header-vat_seller  = gs_inv_hdr_det-vat_seller.
  gs_header-order_no    = gs_inv_hdr_det-veh_job_no.
  gs_header-toll_freeno = gs_inv_hdr_det-toll_freeno.
  gs_header-telephone   = gs_inv_hdr_det-telephone.

*          "Start -DS4K903204 Header Text.
  SELECT SINGLE konda FROM /dbe/splhdr_db INTO @DATA(ls_splhdr)
    WHERE vbeln = @gs_header-order_no
    AND splnr = '0001'.
  IF ls_splhdr = '16'.
    gs_header-headings_en = 'Tax Invoice - Fleet Export'.
*    gs_header-headings_ar = 'فاتورة ضريبية - تصدير الأسطول'.
    gs_header-headings_ar = 'فاتورة ضريبية - مبيعات الجملة -تصدير'.
  ELSE.
    gs_header-headings_en = 'Tax Invoice - Fleet'.
    gs_header-headings_ar = 'فاتورة ضريبية - مبيعات الجملة'.
  ENDIF.

*          "End -DS4K903204 Header Text.

  SELECT SINGLE spart FROM vbrp INTO gs_header-spart
      WHERE vbeln = gs_header-invoice_no
        AND posnr = '000010'.

  SELECT SINGLE waerk FROM vbrp INTO lv_curr
   WHERE vbeln = gs_header-invoice_no.
  IF lv_curr IS NOT INITIAL.
    CONCATENATE 'Invoice Total Payable Amount('lv_curr')' INTO gs_header-curr_words SEPARATED BY space.
    CONDENSE gs_header-curr_words.

    IF lv_curr = 'SAR'.

      gs_header-curr_words_ar = '(سعودي ريال'.

      CONCATENATE '(إجاملي مبلغ الفاتورة المستحق للدفع' gs_header-curr_words_ar INTO gs_header-curr_words_ar SEPARATED BY space.

      CONDENSE gs_header-curr_words_ar.

    ELSEIF lv_curr = 'USD'.

      gs_header-curr_words_ar = '(دولار امريكى'.

      CONCATENATE '(إجمالي مبلغ الفاتورة المستحقة للدفع' gs_header-curr_words_ar INTO gs_header-curr_words_ar SEPARATED BY space.

      CONDENSE gs_header-curr_words_ar.

    ENDIF.
  ENDIF.

**------------------ To Concatenate Header Address---------------------------

  CONCATENATE gs_inv_hdr_det-plant_code '-' gs_inv_hdr_det-plant_name INTO gs_inv_hdr_det-plant_city SEPARATED BY space.

*-------------------------------------

* BREAK-POINT.
  IF gt_inv_item_det[] IS NOT INITIAL.

    gs_header-invoice_date  = gs_inv_hdr_det-invoiced_on.
    gs_header-date_received = gs_inv_hdr_det-invoiced_on.
    gs_header-branch        = gs_inv_hdr_det-plant_city.
*    gs_header-vat_regno     = gs_inv_hdr_det-vat_no.
    gs_header-curr_date     = sy-datum.
    gs_header-telephone     = gs_inv_hdr_det-telephone.
    gs_header-email         = gs_inv_hdr_det-email.
*         SELECT partner,idnumber FROM but0id INTO TABLE @DATA(lt_but0id1)
*    FOR ALL ENTRIES IN @lt_werks
*    WHERE partner = @lt_werks-kunnr
*      AND    type = 'GOVID'.
    gs_header-national_id   = gs_inv_hdr_det-national_id.
    gs_header-fleet_type    = gs_inv_hdr_det-fleet_type.
    gs_header-fleet_segment = gs_inv_hdr_det-fleet_segment.

    " Buyer Information
    READ TABLE gt_inv_part_det INTO DATA(ls_inv_part_det) WITH KEY parvw = 'RE'.
    IF sy-subrc EQ 0.
*     IF ls_inv_part_det-bp_type = '1'.
      gs_header-customer_ref  = ls_inv_part_det-kunnr.
      data(lv_kunnr1) = ls_inv_part_det-kunnr.
      gs_header-customer_name = ls_inv_part_det-full_name.

      gs_header-customer_ref_ar  = ls_inv_part_det-kunnr.
      gs_header-customer_name_ar = ls_inv_part_det-adrp_ar-name_text.

      READ TABLE ls_inv_part_det-tax_data INTO DATA(ls_tax_data) INDEX 1.
      IF sy-subrc EQ 0.
        gs_header-vat_regno     = ls_tax_data-taxnum.
      ENDIF.

*     ELSE.

      IF gs_header-customer_name IS INITIAL.
        gs_header-customer_name = ls_inv_part_det-adrc_en-name1.
      ENDIF.

      IF gs_header-customer_name_ar IS INITIAL.
        gs_header-customer_name_ar = ls_inv_part_det-adrc_ar-name1.
      ENDIF.
*      BREAK-POINT.

*      gs_header-bulding_no    = ls_inv_part_det-adrc_en-house_num1.
*      gs_header-bulding_no    = ls_adrc1-building.
      gs_header-street        = ls_inv_part_det-adrc_en-street.
      gs_header-city          = ls_inv_part_det-adrc_en-city1.
      gs_header-province      = ls_inv_part_det-adrc_en-country.
      gs_header-postal_code   = ls_inv_part_det-adrc_en-post_code1.

      gs_header-bulding_no_ar    = ls_inv_part_det-adrc_ar-house_num1.
      gs_header-street_ar        = ls_inv_part_det-adrc_ar-street.
      gs_header-city_ar          = ls_inv_part_det-adrc_ar-city1.
      gs_header-province_ar      = ls_inv_part_det-adrc_ar-country.
      gs_header-postal_code_ar   = ls_inv_part_det-adrc_ar-post_code1.

*    ENDIF.
    ENDIF.
    "" Start DS4K903435
    DATA:lv_vkorg    TYPE /dbe/vbak_db-vkorg,
         lv_natpfers TYPE but000-natpers.

    SELECT SINGLE vkorg FROM /dbe/vbak_db INTO lv_vkorg
      WHERE vbeln = gs_inv_hdr_det-veh_job_no.
    SELECT SINGLE bstnk FROM /dbe/vbak_db INTO @DATA(lv_bstnk)
 WHERE vbeln = @gs_inv_hdr_det-veh_job_no.
*      BREAK-POINT.
    gs_header-lpo_no = lv_bstnk.
    "" End DS4K903435

    " Ship to party information
    CLEAR:ls_inv_part_det.
    READ TABLE gt_inv_part_det INTO ls_inv_part_det WITH KEY parvw = 'WE'.

    IF sy-subrc EQ 0.
*      BREAK-POINT.
      SELECT SINGLE * FROM but0id INTO  @DATA(ls_but0id1)
 WHERE partner = @ls_inv_part_det-kunnr
   AND    type = 'GOVTID'.
*        BREAK-POINT.
      SELECT SINGLE kunnr,adrnr FROM kna1 INTO @DATA(ls_kna2) WHERE kunnr = @lv_kunnr1.
      SELECT SINGLE addrnumber,building FROM adrc INTO @DATA(ls_adrc1)
      WHERE addrnumber = @ls_kna2-adrnr
        AND nation = ''.
      gs_header-bulding_no = ls_adrc1-building.
*        BREAK-POINT.
      IF sy-subrc = 0.
        gs_header-national_id   = ls_but0id1-idnumber.
      ENDIF.
      gs_header-ship_to = ls_inv_part_det-full_name.
      gs_header-ship_no = ls_inv_part_det-kunnr.
      gs_header-ship_to_ar = ls_inv_part_det-adrp_ar-name_text.

      IF gs_header-ship_to IS INITIAL.
        gs_header-ship_to = ls_inv_part_det-adrc_en-name1.
      ENDIF.
      gs_header-telephone = ls_inv_part_det-adrc_en-tel_number.
      IF gs_header-ship_to_ar IS INITIAL.
        gs_header-ship_to_ar = ls_inv_part_det-adrc_ar-name1.
      ENDIF.

      CONCATENATE ls_inv_part_det-adrc_en-house_num1 ls_inv_part_det-adrc_en-street
                  ls_inv_part_det-adrc_en-city1 ls_inv_part_det-adrc_en-country "ls_inv_part_det-adrc_en-post_code1
                  INTO gs_header-ship_to_address SEPARATED BY space.

      CONCATENATE ls_inv_part_det-adrc_ar-house_num1 ls_inv_part_det-adrc_ar-street
                  ls_inv_part_det-adrc_ar-city1 ls_inv_part_det-adrc_ar-country "ls_inv_part_det-adrc_ar-post_code1
                   INTO gs_header-ship_to_address_ar SEPARATED BY space.

    ENDIF.

    IF gs_header-telephone IS INITIAL.

      SELECT SINGLE adrnr FROM kna1 INTO @DATA(lv_adrnr)
        WHERE kunnr = @ls_inv_part_det-kunnr.

      IF sy-subrc = 0.

        SELECT SINGLE tel_number FROM adrc INTO gs_header-telephone
          WHERE addrnumber = lv_adrnr.

      ENDIF.

    ENDIF.
    DATA:lv_vat  TYPE string,
         lv_dis  TYPE string,
         lv_dis1 TYPE string,
         lv_dis2 TYPE string.
    DATA:lv_vat_rate TYPE char4 .

**    ""start-DS4K903285.
    SELECT vbeln,posnr,matnr40,matkl,itcat ,main_item,charg
      FROM /dbe/vbap
      INTO TABLE @DATA(lt_/dbe/vbap)
      WHERE vbeln = @gs_header-order_no
      AND matkl = 'Y00118'
      AND itcat = 'P090'.

    IF lt_/dbe/vbap IS NOT INITIAL.
      SELECT vbeln, charg,posnr,matnr40 FROM /dbe/vbap INTO TABLE @DATA(lt_/dbe/vbap1)
        FOR ALL ENTRIES IN @lt_/dbe/vbap
        WHERE posnr = @lt_/dbe/vbap-main_item
        AND vbeln = @gs_header-order_no.

      IF lt_/dbe/vbap1 IS NOT INITIAL.
        SELECT /dbe/licext,charg FROM vlcvehicle INTO TABLE @DATA(lt_vlcvehicle)
          FOR ALL ENTRIES IN @lt_/dbe/vbap1
          WHERE charg = @lt_/dbe/vbap1-charg.
      ENDIF.
    ENDIF.
    ""  start of DS4K903435
    SELECT vbeln,posnr,charg
          FROM /dbe/vbap
          INTO TABLE @DATA(lt_vbap)
          WHERE vbeln = @gs_header-order_no.
    IF lt_vbap IS NOT INITIAL .
      SELECT /dbe/licext,charg, pcount,/dbe/iobjguid FROM vlcvehicle INTO TABLE @DATA(lt_vlcv)
                FOR ALL ENTRIES IN @lt_vbap
                WHERE charg = @lt_vbap-charg.
    ENDIF.
    IF lt_vlcv IS NOT INITIAL.
      SELECT product_guid,modline,modguid
         FROM /dbe/v_imodel INTO TABLE @DATA(lt_model)
         FOR ALL ENTRIES IN @lt_vlcv
         WHERE product_guid EQ @lt_vlcv-/dbe/iobjguid.
    ENDIF.
    IF lt_model[] IS NOT INITIAL.
      SELECT model_guid,motext1 FROM /dbe/v_modelt INTO TABLE @DATA(lt_vmodel)
      FOR ALL ENTRIES IN @lt_model
      WHERE model_guid = @lt_model-modguid.
*          AND    spras = 'E'.
    ENDIF.
    "" End of  DS4K903435

    DATA : lv_jobs TYPE /dbe/vbap-jobs.
    DATA :  lv_sub_unt_prc TYPE vfprc_element_amount.
    DATA :  lv_sub_unt_prc1 TYPE vfprc_element_amount.
    DATA :  lv_sub_unt_prc_tot TYPE vfprc_element_amount.
    DATA: discount1        TYPE  vfprc_element_amount,
          tot_amt_exc_vat1 TYPE  vfprc_element_amount,
          vat_rate1        TYPE  char4,
          vat_amount1      TYPE  vfprc_element_amount,
          tot_amt_inc_vat1 TYPE  vfprc_element_amount.

**    ""end-DS4K903285.
    " Item Details
*    BREAK-POINT.
*    SORT gt_inv_item_det BY jobs.

    SORT gt_inv_item_det BY posnr jobs DESCENDING.
    SORT gt_inv_item_det BY posnr jobs ASCENDING.
    SORT gt_inv_item_det BY jobs.
    SORT gt_inv_item_det BY posnr jobs ASCENDING.
    SORT gt_inv_item_det BY  jobs posnr ASCENDING.
*BREAK-POINT.
    LOOP AT gt_inv_item_det INTO DATA(ls_inv_item_det).
*      AT NEW jobs.
      CLEAR:lv_vat,lv_dis.

      IF ls_inv_item_det-veh_details-vin_num IS NOT INITIAL.
        IF lv_vkorg = '1080'.
          READ TABLE lt_vbap INTO DATA(ls_vbap) WITH KEY posnr = ls_inv_item_det-posnr.
          IF sy-subrc = 0.
            READ TABLE lt_vlcv INTO DATA(ls_vlcv) WITH KEY charg = ls_vbap-charg.
            IF sy-subrc = 0.
              READ TABLE lt_model INTO DATA(ls_model) WITH KEY product_guid = ls_vlcv-/dbe/iobjguid.
              IF sy-subrc = 0.
                READ TABLE lt_vmodel INTO DATA(ls_vmodel) WITH KEY model_guid = ls_model-modguid.
                IF sy-subrc = 0.
                  lv_licext = ls_vlcv-/dbe/licext.
                  lv_pcount = ls_vlcv-pcount.
                  DATA(lv_motext) = ls_vmodel-motext1.
                  DATA: lv_mileage_str TYPE string.
                  DATA: lv_newline TYPE string VALUE cl_abap_char_utilities=>cr_lf.
                  CONCATENATE 'Des: ' lv_motext lv_newline
                              'Plate No: ' lv_licext lv_newline
                              'Mileage: ' lv_pcount
                  INTO gs_item_det-prod_desc.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          CONCATENATE ls_inv_item_det-veh_details-eng_arabic  ls_inv_item_det-veh_details-model 'Year:'ls_inv_item_det-veh_details-mod_year
                      ls_inv_item_det-veh_details-eng_no ls_inv_item_det-veh_details-desc_arabic
                      'Color:' ls_inv_item_det-veh_details-ext_color 'TRIM:' ls_inv_item_det-veh_details-int_color
                      INTO gs_item_det-prod_desc SEPARATED BY space.
        ENDIF.
      ELSE.
        gs_item_det-prod_desc       = ls_inv_item_det-mat_desc.
      ENDIF.
      gs_item_det-vin_number      = ls_inv_item_det-veh_details-vin_num.
**      "start-DS4K903285
      IF gs_item_det-vin_number IS INITIAL.
        READ TABLE lt_/dbe/vbap INTO DATA(ls_/dbe/vbap) WITH KEY posnr = ls_inv_item_det-posnr.
        IF sy-subrc = 0.
          READ TABLE lt_/dbe/vbap1 INTO DATA(ls_/dbe/vbap1) WITH KEY posnr = ls_/dbe/vbap-main_item.
          IF sy-subrc = 0.
            READ TABLE lt_vlcvehicle INTO DATA(ls_vlcvehicle) WITH KEY charg = ls_/dbe/vbap1-charg.
            IF sy-subrc = 0.
              gs_item_det-vin_number = ls_vlcvehicle-/dbe/licext.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
**      "end-DS4K903285
      gs_item_det-unit_price      = ls_inv_item_det-prc_det-unit_price.
      gs_item_det-quantity        = ls_inv_item_det-qty.
      gs_item_det-discount        = ls_inv_item_det-prc_det-dis_amount.
      lv_dis                      = ls_inv_item_det-prc_det-dis_rate.
      gs_item_det-tot_amt_exc_vat = ls_inv_item_det-prc_det-unit_price * ls_inv_item_det-qty.
      gs_item_det-tot_amt_exc_vat =  gs_item_det-tot_amt_exc_vat + ls_inv_item_det-prc_det-dis_amount.
      lv_vat                      = ls_inv_item_det-prc_det-vat_rate.
      gs_item_det-vat_amount      = ls_inv_item_det-prc_det-vat_amount * ls_inv_item_det-qty.
*      gs_item_det-tot_amt_inc_vat  = ls_inv_item_det-prc_det-gross_value * ls_inv_item_det-qty.
      gs_item_det-tot_amt_inc_vat =  gs_item_det-tot_amt_exc_vat + gs_item_det-vat_amount.


      IF ls_inv_item_det-prc_det-vat_rate NE '0'.
        CONCATENATE lv_vat+0(2) '%' INTO lv_vat SEPARATED BY space.
        CONDENSE lv_vat.

        gs_item_det-vat_rate = lv_vat.
**        "Start -DS4K903204
      ELSE.

        CONCATENATE '0' '%' INTO lv_vat_rate SEPARATED BY space.
        CONDENSE lv_vat_rate.
        gs_item_det-vat_rate = lv_vat_rate.
**        "End - DS4K903204.
      ENDIF.

*       IF ls_inv_item_det-prc_det-dis_rate IS NOT INITIAL.
*         SPLIT lv_dis AT '.' INTO lv_dis1 lv_dis2.
*    CONCATENATE lv_dis1 '%' INTO lv_dis1 SEPARATED BY space.
*    CONDENSE lv_dis1.
*
*      gs_item_det-discount = lv_dis1.
*    ENDIF.
      IF ls_inv_item_det-prc_det-vat_rate NE '0'.""
        gs_item_total-tot_gross_amt     = gs_item_total-tot_gross_amt + gs_item_det-unit_price * ls_inv_item_det-qty.
      ENDIF.
      gs_item_total-tot_discount_amt  = gs_item_total-tot_discount_amt + ls_inv_item_det-prc_det-dis_amount.
      gs_item_total-tot_vat_amt       = gs_item_total-tot_vat_amt + gs_item_det-vat_amount.
      IF ls_inv_item_det-prc_det-vat_rate NE '0'.
        gs_item_total-inv_gross_tot_amt = gs_item_total-inv_gross_tot_amt + gs_item_det-tot_amt_inc_vat.
      ENDIF.
      IF ls_inv_item_det-prc_det-vat_rate EQ '0'.
*        gs_item_total-non_tax_amount = gs_item_total-non_tax_amount + gs_item_det-unit_price * ls_inv_item_det-qty. "DS4K903196 Existing
        gs_item_total-non_tax_amount = gs_item_total-non_tax_amount + gs_item_det-unit_price * ls_inv_item_det-qty + ls_inv_item_det-prc_det-dis_amount. "DS4K903196 New
      ENDIF.


*      BREAK-POINT.
      IF lv_jobs <> ls_inv_item_det-jobs .
        IF lv_jobs IS NOT INITIAL .
          gs_item_temp-gv_sub_flag = 'X'.
          lv_sub_unt_prc_tot = lv_sub_unt_prc.
          IF gs_item_temp-gv_sub_flag = abap_true.
            gs_item_temp-prod_desc = 'Sub Total' .
            gs_item_temp-unit_price = lv_sub_unt_prc_tot .
            gs_item_temp-discount = discount1 .
            gs_item_temp-tot_amt_exc_vat = tot_amt_exc_vat1 .
            gs_item_temp-vat_amount = vat_amount1 .
            gs_item_temp-tot_amt_inc_vat  = tot_amt_inc_vat1  .
            APPEND gs_item_temp  TO gt_item_det.
            CLEAR : lv_sub_unt_prc_tot ,lv_sub_unt_prc ,lv_jobs,
            gs_item_temp,discount1,tot_amt_exc_vat1,vat_amount1,tot_amt_inc_vat1  .
          ENDIF.
        ENDIF.
        lv_jobs = ls_inv_item_det-jobs .
      ENDIF.
      lv_sub_unt_prc += gs_item_det-unit_price .
      discount1  +=  gs_item_det-discount.
      tot_amt_exc_vat1  += gs_item_det-tot_amt_exc_vat.
      vat_amount1  += gs_item_det-vat_amount.
      tot_amt_inc_vat1  += gs_item_det-tot_amt_inc_vat.
*      BREAK-POINT.
*      lv_jobs = ls_inv_item_det-jobs.
      gs_item_det-jobs = ls_inv_item_det-jobs.
      APPEND gs_item_det TO gt_item_det.

      CLEAR:gs_item_det,ls_inv_item_det.
*      ENDAT.
    ENDLOOP.
*   BREAK-POINT .
    IF lv_jobs IS NOT INITIAL .
      gs_item_temp-gv_sub_flag = 'X'.
      lv_sub_unt_prc_tot = lv_sub_unt_prc.
      IF gs_item_temp-gv_sub_flag = abap_true.
        gs_item_temp-prod_desc = 'Sub Total'.
        gs_item_temp-unit_price = lv_sub_unt_prc_tot .
        gs_item_temp-discount = discount1 .
        gs_item_temp-tot_amt_exc_vat = tot_amt_exc_vat1 .
        gs_item_temp-vat_amount = vat_amount1 .
        gs_item_temp-tot_amt_inc_vat  = tot_amt_inc_vat1  .
        APPEND gs_item_temp  TO gt_item_det.
        CLEAR : lv_sub_unt_prc_tot ,lv_sub_unt_prc ,lv_jobs,
        gs_item_temp,discount1,tot_amt_exc_vat1,vat_amount1,tot_amt_inc_vat1  .
      ENDIF.
    ENDIF.


    LOOP AT gt_item_det ASSIGNING FIELD-SYMBOL(<fs_item>).
      IF <fs_item>-gv_sub_flag = abap_true.
        IF <fs_item>-discount < 0.
          <fs_item>-discount = <fs_item>-discount * -1.
        ENDIF.
      ELSE.
        <fs_item>-unit_price = space.
        <fs_item>-discount = space.
        <fs_item>-tot_amt_exc_vat = space.
        <fs_item>-vat_amount = space.
        <fs_item>-tot_amt_inc_vat = space.
      ENDIF.
    ENDLOOP.
    gs_item_total-inv_gross_tot_amt = gs_item_total-inv_gross_tot_amt +  gs_item_total-non_tax_amount.
    gs_item_total-down_payment = gs_inv_hdr_det-down_payment.
    gs_item_total-tot_tax_amt  = gs_item_total-tot_gross_amt + gs_item_total-tot_discount_amt.
    gs_item_total-inv_tot_payable_amt = gs_item_total-inv_gross_tot_amt - gs_item_total-down_payment.

    SELECT SINGLE waerk FROM /dbe/vbap INTO @DATA(lv_waerk)
     WHERE vbeln = @gs_header-invoice_no.

    IF lv_waerk IS NOT INITIAL.

      CONCATENATE 'Invoice Total Payable Amount' '('lv_waerk')' INTO gs_item_total-inv_tot_pay_desc SEPARATED BY space.

    ENDIF.
**Passing the form name
    CLEAR g_form_name.
    g_form_name = tnapr-sform.
    CLEAR:wg_job_outputparams.
*     wg_job_outputparams-getpdf = 'X'.
*     wg_job_outputparams-dest = 'LP01'.
*     wg_job_outputparams-nodialog = abap_true.
*     wg_job_outputparams-dest = 'LOCL'.
    wg_job_outputparams-preview = 'X'.
    wg_job_outputparams-noprint = ' '.
*     wg_job_outputparams-reqnew = abap_true.
*     wg_job_outputparams-reqimm = abap_true.

    wg_job_outputparams-nodialog = 'X'.
    wg_job_outputparams-dest = gs_nast-ldest.
*    wg_job_outputparams-dest = 'PDF1'.
*    wg_job_outputparams-device = 'PRINTER'.
    wg_job_outputparams-reqimm = gs_nast-dimme.
    wg_job_outputparams-reqdel = gs_nast-delet.
    wg_job_outputparams-copies = gs_nast-anzal.
    wg_job_outputparams-dataset = gs_nast-dsnam.
    wg_job_outputparams-suffix1 = gs_nast-dsuf1.
    wg_job_outputparams-suffix2 = gs_nast-dsuf2.
    wg_job_outputparams-covtitle = gs_nast-tdcovtitle.
    wg_job_outputparams-cover = gs_nast-tdocover.
    wg_job_outputparams-receiver = gs_nast-tdreceiver.
    wg_job_outputparams-division = gs_nast-tddivision.
    wg_job_outputparams-reqfinal = 'X'.
    wg_job_outputparams-arcmode = gs_nast-tdarmod.
    wg_job_outputparams-schedule = gs_nast-tdschedule.
    wg_job_outputparams-senddate = gs_nast-vsdat.
    wg_job_outputparams-sendtime = gs_nast-vsura.

**&&~~ Form Processing: Call Form - Open
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = wg_job_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
      " Suitable Error Handling
    ENDIF.

    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = g_form_name
          IMPORTING
            e_funcname = wg_fm_name.

      CATCH cx_fp_api_internal.
      CATCH cx_fp_api_usage.
      CATCH cx_fp_api_repository.
    ENDTRY.
*    BREAK-POINT.
    CALL FUNCTION wg_fm_name "'/1BCDWB/SM00000013'
      EXPORTING
        /1bcdwb/docparams  = wg_fp_docparams
        header_info        = gs_header
        item_det           = gt_item_det
        item_totals        = gs_item_total
      IMPORTING
        /1bcdwb/formoutput = wg_fp_outputparams
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION 'FP_JOB_CLOSE'
      IMPORTING
        e_result       = wg_result
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    TRY.

        PERFORM protocol_update USING g_msgv1.
      CATCH cx_send_req_bcs.
        RETURN.
    ENDTRY.
  ENDIF.


ENDFORM.
FORM protocol_update USING msgv1 TYPE sy-msgv1.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = sy-msgid
      msg_nr    = sy-msgno
      msg_ty    = sy-msgty
      msg_v1    = msgv1
      msg_v2    = sy-msgv2
      msg_v3    = sy-msgv3
      msg_v4    = sy-msgv4
    EXCEPTIONS
      OTHERS    = 0.
ENDFORM.

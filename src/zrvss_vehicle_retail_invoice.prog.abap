*&---------------------------------------------------------------------*
*& Report ZRVSS_VEHICLE_RETAIL_INVOICE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrvss_vehicle_retail_invoice.
TYPE-POOLS szadr.
INCLUDE rvadtabl.

DATA: retcode   LIKE sy-subrc.         "Returncode
DATA: xscreen(1) TYPE c.               "Output on printer or screen
DATA: repeat(1) TYPE c.
DATA: nast_anzal LIKE nast-anzal.      "Number of outputs (Orig. + Cop.)
DATA: nast_tdarmod LIKE nast-tdarmod.  "Archiving only one time
DATA: gv_qr            TYPE string.
DATA: is_seller       TYPE  zsd_inv_head_mid,
      it_ydbm_invc    TYPE TABLE OF ydbe_invc2,
      ts_ydbm_invc    LIKE LINE OF it_ydbm_invc,
      is_buyer        TYPE  zsd_inv_head_mid,
      gt_inv_item_det TYPE ztt_vss_inv_item_det,
      gt_item_det     TYPE zvss_retail_item_det,
      gs_item_det     TYPE zvss_s_retail_item,
      gs_header1      TYPE zvss_retail_hdr_info,
      gs_inv_hdr_det  TYPE zst_inv_hdr_det,
      gs_item_total   TYPE zvss_retail_total,
      es_header_det1  TYPE zst_inv_hdr_det.
DATA:
*      gs_header TYPE yst_jipco_mm_inv_head,
*      gs_footer TYPE yst_jipco_mm_inv_footer,
*      gt_item   TYPE yst_jipco_mm_inv_item_tb,
  gs_header  TYPE  ycl_dbm_veh_crdt_inv_frm_util=>ty_header,
  gt_body    TYPE  ycl_dbm_veh_crdt_inv_frm_util=>tt_body_str,
  gs_footer  TYPE  ycl_dbm_veh_crdt_inv_frm_util=>ty_footer_str,
  gt_vehicle TYPE  ycl_dbm_veh_crdt_inv_frm_util=>tt_vehicle.

INCLUDE rlb_print_forms.

*---------------------------------------------------------------------*
*       FORM ENTRY
*---------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  DATA: lf_retcode TYPE sy-subrc.
  CLEAR retcode.
  xscreen = us_screen.
  PERFORM processing USING us_screen
                     CHANGING lf_retcode.
  IF lf_retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.

ENDFORM.                    "ENTRY

*---------------------------------------------------------------------*
*       FORM PROCESSING                                               *
*---------------------------------------------------------------------*
FORM processing USING proc_screen
                CHANGING cf_retcode.

  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: lf_formname           TYPE tdsfname.
  DATA: lv_invoice_no         TYPE vbeln_vf.
  DATA:fp_docparams    TYPE sfpdocparams,
       fp_outputparams TYPE sfpoutputparams,
       es_header_data  TYPE  ycl_dbm_veh_crdt_inv_frm_util=>ty_header,
       ev_salesman     TYPE  so_adrnam,
       es_header_det1  TYPE	zst_inv_hdr_det.
* SmartForm from customizing table TNAPR
  lf_formname = tnapr-sform.

* BEGIN: Country specific extension for Hungary
  DATA: lv_ccnum TYPE idhuccnum,
        lv_error TYPE c.


  SELECT SINGLE ccnum INTO lv_ccnum FROM idhubillingout WHERE
    kschl = nast-kschl.

  IF sy-subrc EQ 0.
    IF lv_ccnum IS INITIAL.
      lv_ccnum = 1.
    ENDIF.

    IF ( nast-delet IS INITIAL OR nast-dimme IS INITIAL ).

      nast-delet = 'X'.
      nast-dimme = 'X'.

      sy-msgid = 'IDFIHU'.
      sy-msgty = 'W'.
      sy-msgno = 201.
      sy-msgv1 = nast-objky.

      CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
        EXPORTING
          msg_arbgb = sy-msgid
          msg_nr    = sy-msgno
          msg_ty    = sy-msgty
          msg_v1    = sy-msgv1
          msg_v2    = ''
          msg_v3    = ''
          msg_v4    = ''
        EXCEPTIONS
          OTHERS    = 1.
    ENDIF.
  ELSE.
    CLEAR lv_ccnum.
  ENDIF.

  lv_invoice_no = nast-objky.

  TRY.
      CALL FUNCTION 'YDBE_JET_VEH_CRDT_INVOICE'
        EXPORTING
          iv_invoice_no = lv_invoice_no
          iv_sf         = ''
          iv_langu      = nast-spras
        IMPORTING
          es_header     = gs_header
          et_body       = gt_body
          es_footer     = gs_footer
          et_vehicle    = gt_vehicle.
      .
    CATCH cx_sy_dyn_call_param_missing INTO DATA(ls_catch1).
      DATA(ls_msg1) = ls_catch1->get_text( ).
  ENDTRY.

  SELECT SINGLE spart FROM vbrp INTO gs_header-spart
    WHERE vbeln = lv_invoice_no
      AND posnr = '000010'.

  CALL METHOD ycl_dbm_veh_crdt_inv_frm_util=>items_data
    EXPORTING
      iv_invoice_number = lv_invoice_no                " Billing Document
    IMPORTING
      et_item_det       = gt_inv_item_det.               " Invoice Item Details

  CALL METHOD ycl_dbm_veh_crdt_inv_frm_util=>header_data
    EXPORTING
      iv_invoice_number = lv_invoice_no
*     iv_langu          = SY-LANGU
    IMPORTING
      es_header_data    = es_header_data
      ev_salesman       = ev_salesman
      es_header_det1    = es_header_det1.                 " Invoice Header Details


  gs_header1-name1_ft     =  es_header_det1-plant_name.
  gs_header1-street_ft    = es_header_det1-plant_addr.
  gs_header1-city_ft      = es_header_det1-plant_city.
  gs_header1-plant_pocode = es_header_det1-plant_pocode.
  gs_header1-plant_cntry  = es_header_det1-plant_cntry.

  gs_header1-name1_ar_ft     = es_header_det1-plant_name_ar.
  gs_header1-street_ar_ft = es_header_det1-plant_addr_ar.
  gs_header1-city_ar_ft  = es_header_det1-plant_city_ar.
  gs_header1-plant_pocode_ar = es_header_det1-plant_pocode_ar.
  gs_header1-plant_cntry_ar  = es_header_det1-plant_cntry_a.
  gs_header1-cr_seller   = es_header_det1-cr_seller.
  gs_header1-vat_seller  = es_header_det1-vat_seller.
  gs_header1-order_no    = es_header_det1-veh_job_no.
  gs_header1-toll_freeno = es_header_det1-toll_freeno.
  gs_header1-telephone   = es_header_det1-telephone.

  DATA:lv_vkorg1   TYPE /dbe/vbak_db-vkorg,
       lv_natpers1 TYPE but000-natpers.

  SELECT SINGLE vkorg FROM /dbe/vbak_db INTO lv_vkorg1
    WHERE vbeln = gs_header-order_no.

  SELECT SINGLE konda FROM /dbe/splhdr_db INTO @DATA(ls_splhdr)
  WHERE vbeln = @gs_header-order_no
  AND splnr = '0001'.
*  IF ls_splhdr = '16'.
*    gs_footer-title_eng = 'Tax Invoice - Fleet Export'.
**    gs_header-headings_ar = 'فاتورة ضريبية - تصدير الأسطول'.
*    gs_footer-title_ar = 'فاتورة ضريبية - مبيعات الجملة -تصدير'.
*  ELSE.
*    gs_footer-title_eng = 'Tax Invoice - Fleet'.
*    gs_footer-title_ar = 'فاتورة ضريبية - مبيعات الجملة'.
*  ENDIF.


  SELECT SINGLE natpers FROM but000 INTO lv_natpers1
    WHERE partner = gs_header-financer.

  SELECT SINGLE fksto,fkart FROM vbrk INTO @DATA(ls_vbrk1)
    WHERE vbeln = @lv_invoice_no.
  IF ( ls_vbrk1-fksto = 'X' OR ls_vbrk1-fkart = 'S1' ) AND gs_footer-title_eng
     IS INITIAL AND gs_footer-title_ar IS INITIAL  .
    gs_footer-title_eng = 'Vehicles Credit Memo'.
    gs_footer-title_ar = 'مذكرة الائتمان'.

  ELSE.
    "*---------------------"End-DS4K903182.
*
    IF lv_natpers1 = 'X' AND gs_footer-title_eng IS INITIAL AND gs_footer-title_ar IS INITIAL .

      IF lv_vkorg1 = '1000'.

        gs_footer-title_eng = 'Simplified Tax Invoice - New Vehicle'.
        gs_footer-title_ar = 'فاتورة ضريبية مبسطة -  سيارات جديدة'.

      ELSEIF lv_vkorg1 = '1080'.

        gs_footer-title_eng = 'Simplified Tax Invoice - Used Vehicle'.
        gs_footer-title_ar = 'فاتورة ضريبية مبسطة -  سيارات مستعملة'.

      ENDIF.

    ELSE.
      IF lv_vkorg1 = '1000' AND gs_footer-title_eng IS INITIAL AND gs_footer-title_ar IS INITIAL.
        gs_footer-title_eng = 'Tax Invoice - New Vehicle'.
        gs_footer-title_ar = 'فاتورة ضريبية -  سيارات جديدة'.
      ELSEIF lv_vkorg1 = '1080'.
        gs_footer-title_eng = 'Tax Invoice - Used Vehicle'.
        gs_footer-title_ar = 'فاتورة ضريبية -  سيارات مستعملة'.
      ENDIF.
    ENDIF.
  ENDIF.




*--billing type logic..
  "Title
  IF gs_header-fkart = 'F2'.
*    gs_footer-title_eng = 'Tax Invoice'.
*    gs_footer-title_ar = 'فاتورة ضريبية'.
  ELSE.
*    gs_footer-title_eng = 'Return Tax Invoice'.
*    gs_footer-title_ar = 'فاتورة مرتجع ضريبية'.

    DATA: lt_original_ord TYPE /dbe/docflow_documents_tt.
    CALL FUNCTION '/DBE/OE_MAIN_DOCFLOW_READ_ALL'
      EXPORTING
        iv_vbeln       = gs_header-order_no
        iv_borobj      = 'BUS2400'
      IMPORTING
        et_documents   = lt_original_ord
      EXCEPTIONS
        internal_error = 1
        OTHERS         = 2.
    IF sy-subrc = 0.
      READ TABLE lt_original_ord INTO DATA(ls_org_ord) INDEX 1.
      IF sy-subrc = 0.
        gs_header-origin_ord = ls_org_ord-docnum.
      ENDIF.
    ENDIF.
  ENDIF.


*---call FM to get the address of seller and buyer..
  CLEAR:  is_seller, is_buyer.
  CALL FUNCTION 'YDBE_INV_HEAD_PARTNR_ADRS'
    EXPORTING
      lv_invoice_no = lv_invoice_no
    IMPORTING
      es_seller     = is_seller
      es_buyer      = is_buyer.

  DATA: l_amtwords    TYPE string,
        l_amtwords_ar TYPE string.
*--amount in workds
  CALL FUNCTION 'Z_AMT_IN_WORDS_INV'
    EXPORTING
      amount       = gs_footer-final_amt
      currency     = 'SAR'
      language     = sy-langu
    IMPORTING
      amt_in_words = l_amtwords.  "   wf_amt_in_words.

  REPLACE  ALL OCCURRENCES OF 'Amount includes VAT'  IN l_amtwords WITH 'Inclusive of VAT' .
* arabic
  CALL FUNCTION 'Z_AMT_IN_WORDS_INV'
    EXPORTING
      amount       = gs_footer-final_amt
      currency     = 'SAR'
      language     = 'A'
    IMPORTING
      amt_in_words = l_amtwords_ar.  "   wf_amt_in_words.


*QR Code
  CLEAR: gv_qr.
  CALL FUNCTION 'ZSD_GETINV_QRDATA'
    EXPORTING
      l_vbeln   = lv_invoice_no
*     l_vat_amt = ls_bil_invoice-hd_gen-bil_tax
      l_vat_amt = gs_footer-vat
*     l_total   = ls_bil_invoice-hd_gen-bil_netwr
      l_total   = gs_footer-final_amt
    IMPORTING
      ls_qr     = gv_qr.


  IF cf_retcode = 0.
* determine Adope Form function module for invoice
    CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
        i_name     = lf_formname
      IMPORTING
        e_funcname = lf_fm_name.
    IF sy-subrc <> 0.
*   error handling
      cf_retcode = sy-subrc.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

*call smartform here

  IF cf_retcode = 0.
    PERFORM check_repeat.
    IF ls_composer_param-tdcopies EQ 0.
      nast_anzal = 1.
    ELSE.
      nast_anzal = ls_composer_param-tdcopies.
    ENDIF.
    ls_composer_param-tdcopies = 1.

    DO nast_anzal TIMES.
* In case of repetition only one time archiving
      IF sy-index > 1 AND nast-tdarmod = 3.
        nast_tdarmod = nast-tdarmod.
        nast-tdarmod = 1.
        ls_composer_param-tdarmod = 1.
      ENDIF.
      IF sy-index NE 1 AND repeat IS INITIAL.
        repeat = 'X'.
      ENDIF.
* BEGIN: Country specific extension for Hungary
      IF lv_ccnum IS NOT INITIAL.
        IF nast-repid IS INITIAL.
          nast-repid = 1.
        ELSE.
          nast-repid = nast-repid + 1.
        ENDIF.
        nast-pfld1 = lv_ccnum.
      ENDIF.


      " Item Details***************************************************************
      DATA : lv_pcount TYPE string,
             lv_licext TYPE vlcvehicle-/dbe/licext.
      SELECT SINGLE * FROM vbrk INTO @DATA(ls_vbrk)
       WHERE vbeln = @lv_invoice_no.
      DATA(lv_vbeln) = ls_vbrk-zuonr+3(10).
      SELECT SINGLE * FROM /dbe/vbak_db INTO @DATA(ls_vbak) WHERE vbeln EQ @lv_vbeln.
      SELECT vbeln,posnr,charg
        FROM /dbe/vbap
        INTO TABLE @DATA(lt_vbap)
        WHERE vbeln = @ls_vbak-vbeln.
      IF lt_vbap IS NOT INITIAL .
        SELECT /dbe/licext,charg, pcount,/dbe/iobjguid FROM vlcvehicle INTO TABLE @DATA(lt_vlcv)
                  FOR ALL ENTRIES IN @lt_vbap
                  WHERE charg = @lt_vbap-charg. "#EC CI_NOFIELD.
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
      SELECT vbeln,posnr,matnr40,matkl,itcat ,main_item,charg
    FROM /dbe/vbap
    INTO TABLE @DATA(lt_/dbe/vbap)
    WHERE vbeln = @ls_vbak-vbeln
    AND matkl = 'Y00118'
    AND itcat = 'P090'.
      IF lt_/dbe/vbap IS NOT INITIAL.
        SELECT vbeln, charg,posnr,matnr40 FROM /dbe/vbap INTO TABLE @DATA(lt_/dbe/vbap1)
          FOR ALL ENTRIES IN @lt_/dbe/vbap
          WHERE posnr = @lt_/dbe/vbap-main_item
          AND vbeln = @ls_vbak-vbeln.

        IF lt_/dbe/vbap1 IS NOT INITIAL.
          SELECT /dbe/licext,charg, pcount,/dbe/iobjguid
            FROM vlcvehicle INTO TABLE @DATA(lt_vlcvehicle)
            FOR ALL ENTRIES IN @lt_/dbe/vbap1
            WHERE charg = @lt_/dbe/vbap1-charg. "#EC CI_NOFIELD.
        ENDIF.
      ENDIF.

      DATA:lv_vat  TYPE string,
           lv_dis  TYPE string,
           lv_dis1 TYPE string,
           lv_dis2 TYPE string.
      DATA:lv_vkorg   TYPE /dbe/vbak_db-vkorg,
           lv_natpers TYPE but000-natpers.
      LOOP AT gt_inv_item_det INTO DATA(ls_inv_item_det).
        CLEAR:lv_vat,lv_dis.
        IF ls_inv_item_det-veh_details-vin_num IS NOT INITIAL.
          ""start of DS4K903348 vehicle desc
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
*            CONCATENATE ls_inv_item_det-veh_details-eng_arabic  ls_inv_item_det-veh_details-model 'Year:' ls_inv_item_det-veh_details-mod_year
            CONCATENATE '       Model :' ls_inv_item_det-veh_details-model
                         cl_abap_char_utilities=>cr_lf
                         '         Desc :' ls_inv_item_det-veh_details-eng_arabic ' ' ls_inv_item_det-veh_details-desc_arabic
                          cl_abap_char_utilities=>cr_lf
                         'Model Year:' ls_inv_item_det-veh_details-mod_year
                          cl_abap_char_utilities=>cr_lf
                          'Chasis :' : ls_inv_item_det-veh_details-vin_num
                           cl_abap_char_utilities=>cr_lf
                        ls_inv_item_det-veh_details-eng_no
                        'Color:' ls_inv_item_det-veh_details-ext_color 'TRIM:' ls_inv_item_det-veh_details-int_color
                        INTO gs_item_det-prod_desc SEPARATED BY space.
          ENDIF.
        ELSE.
          gs_item_det-prod_desc       = ls_inv_item_det-mat_desc.
        ENDIF.
        gs_item_det-vin_number      = ls_inv_item_det-veh_details-vin_num.

        IF gs_item_det-vin_number IS INITIAL.
          READ TABLE lt_/dbe/vbap INTO ls_/dbe/vbap WITH KEY posnr = ls_inv_item_det-posnr.
          IF sy-subrc = 0.
            READ TABLE lt_/dbe/vbap1 INTO ls_/dbe/vbap1 WITH KEY posnr = ls_/dbe/vbap-main_item.
            IF sy-subrc = 0.
              READ TABLE lt_vlcvehicle INTO ls_vlcvehicle WITH KEY charg = ls_/dbe/vbap1-charg.
              IF sy-subrc = 0.
                gs_item_det-vin_number = ls_vlcvehicle-/dbe/licext.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

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
        ENDIF.
        IF ls_inv_item_det-prc_det-vat_rate NE '0'.
          gs_item_total-tot_gross_amt     = gs_item_total-tot_gross_amt + gs_item_det-unit_price * ls_inv_item_det-qty.
        ENDIF.
        gs_item_total-tot_discount_amt  = gs_item_total-tot_discount_amt + ls_inv_item_det-prc_det-dis_amount.
        gs_item_total-tot_vat_amt       = gs_item_total-tot_vat_amt + gs_item_det-vat_amount.
        IF ls_inv_item_det-prc_det-vat_rate NE '0'.
          gs_item_total-inv_gross_tot_amt = gs_item_total-inv_gross_tot_amt + gs_item_det-tot_amt_inc_vat.
        ENDIF.
        IF ls_inv_item_det-prc_det-vat_rate EQ '0'.
          gs_item_total-non_tax_amount = gs_item_total-non_tax_amount + gs_item_det-unit_price * ls_inv_item_det-qty.
        ENDIF.

        APPEND gs_item_det TO gt_item_det.
        CLEAR:gs_item_det,ls_inv_item_det.

      ENDLOOP.
      gs_item_total-inv_gross_tot_amt = gs_item_total-inv_gross_tot_amt +  gs_item_total-non_tax_amount.
*      gs_item_total-down_payment = gs_inv_hdr_det-down_payment.
      gs_item_total-down_payment = es_header_det1-down_payment.
      gs_item_total-tot_tax_amt  = gs_item_total-tot_gross_amt + gs_item_total-tot_discount_amt.
      gs_item_total-inv_tot_payable_amt = gs_item_total-inv_gross_tot_amt - gs_item_total-down_payment.

      gs_footer-final_amt = gs_item_total-inv_gross_tot_amt.

      CALL FUNCTION 'Z_AMT_IN_WORDS_INV'
        EXPORTING
          amount       = gs_item_total-inv_tot_payable_amt
          currency     = 'SAR'
          language     = sy-langu
        IMPORTING
          amt_in_words = l_amtwords.  "   wf_amt_in_words.

      REPLACE  ALL OCCURRENCES OF 'Amount includes VAT'  IN l_amtwords WITH 'Inclusive of VAT' .
* arabic
      CALL FUNCTION 'Z_AMT_IN_WORDS_INV'
        EXPORTING
          amount       = gs_item_total-inv_tot_payable_amt
          currency     = 'SAR'
          language     = 'A'
        IMPORTING
          amt_in_words = l_amtwords_ar.  "   wf_amt_in_words.


*BREAK-POINT.

* Language and country setting
      fp_docparams-langu   = nast-spras.
*      fp_docparams-country = 'US'.
* Sets the output parameters and opens the spool job
      " tech1.
      fp_outputparams-nodialog = 'X'.
      fp_outputparams-preview = 'X'.
*      IF nast-spras = 'A'.
      fp_outputparams-reqnew = 'X'.
      fp_outputparams-device = 'PRINTER'.
      fp_outputparams-dest = 'PDF1'.
      fp_outputparams-reqdel = 'X'.
*      ENDIF.
      CALL FUNCTION 'FP_JOB_OPEN'
        CHANGING
          ie_outputparams = fp_outputparams
        EXCEPTIONS
          cancel          = 1
          usage_error     = 2
          system_error    = 3
          internal_error  = 4
          OTHERS          = 5.

*--- adding conditions to not to print invoice if status from ZATCA rejected if
*-- Adding code to check ZATCA accepted or not..
      DATA: lv_source_key TYPE edoc_source_key,
            lv_edoc_guid  TYPE edoc_guid,
            lv_approve,
            lv_title_en   TYPE char30,
            lv_title_ar   TYPE char30,
            lv_person,
            lv_cust_id    TYPE bu_partner.

      CLEAR: lv_source_key ,lv_edoc_guid, lv_approve,lv_title_en,lv_title_ar,lv_person,lv_cust_id.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gs_header-inv_number                " C field
        IMPORTING
          output = gs_header-inv_number.
      cl_edoc_source_sd_invoice=>pack_key(
        EXPORTING
          iv_vbeln = gs_header-inv_number
        IMPORTING
          ev_key   = lv_source_key ).

      lv_cust_id = gs_header-ac_number.

      CALL FUNCTION 'YEDOC_INV_TITLE_STATUS'
        EXPORTING
          source_key = lv_source_key
          partner    = lv_cust_id
        IMPORTING
          approved   = lv_approve
          title_en   = lv_title_en
          title_ar   = lv_title_ar
          person     = lv_person.
      IF lv_title_en IS NOT INITIAL AND lv_title_ar IS NOT INITIAL.
        gs_footer-title_eng = lv_title_en.
        gs_footer-title_ar = lv_title_ar.
      ENDIF.
********************************************
      CLEAR repeat.
      ts_ydbm_invc-kschl = nast-kschl.
      ts_ydbm_invc-vbeln = gs_header-inv_number.
      SELECT SINGLE * FROM ydbe_invc2 INTO ts_ydbm_invc WHERE kschl = nast-kschl AND vbeln = gs_header-inv_number.
      IF sy-subrc <> 0.
        repeat = ''.
        ts_ydbm_invc-kschl = nast-kschl.
        ts_ydbm_invc-vbeln = gs_header-inv_number.
        ts_ydbm_invc-usnam = sy-uname.
        ts_ydbm_invc-erdat = sy-datum.
        ts_ydbm_invc-erzet = sy-uzeit.
        MODIFY ydbe_invc2 FROM ts_ydbm_invc.
      ELSE.
        repeat = 'X'.
      ENDIF.

*      IF  lv_approve = 'X'  .
      CALL FUNCTION lf_fm_name
        EXPORTING
          /1bcdwb/docparams = fp_docparams
          is_head           = gs_header
          gv_qr             = gv_qr
          it_body           = gt_body
          is_footer         = gs_footer
          is_repeat         = repeat
          gs_seller         = is_seller
          gs_buyer          = is_buyer
          l_amtwords        = l_amtwords
          l_amtwords_ar     = l_amtwords_ar
          it_vehicle        = gt_vehicle
          item_det          = gt_item_det
          item_totals       = gs_item_total
          gs_header1        = gs_header1
*       IMPORTING
*         /1BCDWB/FORMOUTPUT       = /1BCDWB/FORMOUTPUT
        EXCEPTIONS
          usage_error       = 1
          system_error      = 2
          internal_error    = 3.
      IF sy-subrc <> 0.
*        *   error handling
        cf_retcode = sy-subrc.
        PERFORM protocol_update.
      ENDIF.

*      ELSE.
*        MESSAGE 'Invoice cannot be printed as edocument not accepted by ZATCA ' TYPE 'E'.
*        MESSAGE e000(zedosa). "Invoice can't be printed until ZATCA approved. Please try later
*      ENDIF.
*&---- Close the spool job
      CALL FUNCTION 'FP_JOB_CLOSE'
*    IMPORTING
*     E_RESULT             =
        EXCEPTIONS
          usage_error    = 1
          system_error   = 2
          internal_error = 3
          OTHERS         = 4.
      IF sy-subrc <> 0.
*        *   error handling
        cf_retcode = sy-subrc.
        PERFORM protocol_update.
      ENDIF.
    ENDDO.

  ENDIF.

ENDFORM.                    "PROCESSING

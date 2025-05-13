CLASS ycl_dbe_prt_crdt_inv_frm_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF  ty_plant_address,
        comp_name    TYPE name1,
        comp_name_ar TYPE name2,
        postal_code  TYPE pstlz,
        city         TYPE ort01,
*    country_key type LAND1,
        country      TYPE landx,
*    adrnr type ADRNR,
      END OF ty_plant_address .
    TYPES:
      BEGIN OF ty_header,
        inv_number       TYPE vbeln_vf,
        inv_date         TYPE fkdat,
        inv_time         TYPE erzet,
        ac_number        TYPE kunag,
        financer         TYPE kunag,
        cus_name         TYPE name1_gp,
        cus_city         TYPE ad_city1,
        cus_vat          TYPE bptaxnum,
        fin_vat          TYPE bptaxnum,
        bustype          TYPE /dbe/descr,
        order_no         TYPE  /dbe/vbeln_va,
        ordr_date        TYPE erdat,
        addr_no          TYPE adrnr,
        v_guid           TYPE vlc_guid,
        created_by_uname TYPE ernam,
        company_code     TYPE bukrs,
        comp_vat         TYPE stceg,
        pmnt_term_txt    TYPE bezei20,
        quotation        TYPE vbeln_vf,  "quotation
        sales_man        TYPE ernam,      "salesman
        sales_man_name   TYPE string,      "salesman
        cust_po          TYPE bstnk,
        center_code      TYPE string,
        inv_date_time    TYPE string,
        supply_date      TYPE fkdat,
        due_date         TYPE fkdat,
        division         TYPE spart,
        currency         TYPE string,
        fkart            TYPE fkart,   "billing type
        origin_ord       TYPE /dbe/vbeln_va,
        spart            TYPE spart,
      END OF ty_header .
    TYPES:
      BEGIN OF ty_split,
        splnr TYPE /dbe/splhdr_db-splnr,
        kunnr TYPE /dbe/splhdr_db-kunnr,
      END OF ty_split .
    TYPES:
      BEGIN OF ty_body,
        itm_no         TYPE vbrp-posnr,
        product_number TYPE vbrp-matnr,
        qty            TYPE vbrp-fkimg,
        price_date     TYPE vbrp-prsdt,
        total_price    TYPE vbrp-netwr,
        desc           TYPE maktx,
        main_item      TYPE /dbe/vbap-main_item,
        vat            TYPE string,
        vat_rate       TYPE string,
        bismt          TYPE matnr,
        tbd            TYPE string,
        surcharge      TYPE string,
        disc_percent   TYPE string,
        discount       TYPE string,
        taxable_amt    TYPE string,
        total_inc_vat  TYPE string,
        unit_price     TYPE string,
        unit_price2    TYPE string,
        qty_str        TYPE string,
      END OF ty_body .
    TYPES:
      BEGIN OF ty_body_str,
        product_number TYPE string,
        qty            TYPE string,
        mcodesd        TYPE /dbe/vbap-mcodesd,
        vehicle        TYPE vlcvehicle-vhcle,
        chassis        TYPE string,
        commission     TYPE string,
        vat            TYPE string,
        vat_rate       TYPE string,
        bismt          TYPE matnr,
        desc           TYPE string,
        disc_percent   TYPE string,
        discount       TYPE string,
        taxable_amt    TYPE string,
        total_inc_vat  TYPE string,
        tbd            TYPE string,
        unit_price     TYPE string,
        ext_price      TYPE string,
      END OF ty_body_str .
    TYPES:
      BEGIN OF ty_material_desc,
        product_number TYPE matnr,
        spras          TYPE spras,
        desc           TYPE maktx,
      END OF ty_material_desc .
    TYPES:
      tt_material_desc TYPE HASHED TABLE OF ty_material_desc WITH UNIQUE KEY product_number spras .
    TYPES:
      tt_body TYPE TABLE OF ty_body .
    TYPES:
      tt_body_str TYPE TABLE OF ty_body_str .
    TYPES:
      BEGIN OF ty_footer,
        salesman        TYPE so_adrnam,
        gross_amount    TYPE string,
        discount        TYPE string,
        vat             TYPE string,
        disc_percent    TYPE string,
        surcharge       TYPE string,
        taxable_amt     TYPE string,
        regist_amt      TYPE string,
        tot_inv_grs_amt TYPE string,
        final_amt       TYPE string,
        net_price       TYPE string,
        netpr_in_words  TYPE string,
      END OF ty_footer .
    TYPES:
      BEGIN OF ty_footer_str,
        salesman        TYPE string,
        gross_amount    TYPE string,
        discount        TYPE string,
        vat             TYPE string,
        disc_percent    TYPE string,
        taxable_amt     TYPE string,
        regist_amt      TYPE string,
        tot_inv_grs_amt TYPE string,
        final_amt       TYPE string,
        net_price       TYPE string,
        netpr_in_words  TYPE string,
      END OF ty_footer_str .

    CLASS-DATA gt_body_items TYPE tt_body .

    CLASS-METHODS header_data
      IMPORTING
        !iv_invoice_number TYPE vbeln_vf
        !iv_langu          TYPE sy-langu DEFAULT sy-langu
      EXPORTING
        !es_header_data    TYPE ty_header
        !ev_salesman       TYPE so_adrnam .
    CLASS-METHODS items_data
      IMPORTING
        !iv_invoice_no TYPE vbeln_vf OPTIONAL
        !iv_order_no   TYPE /dbe/vbeln_va OPTIONAL
        !iv_langu      TYPE sy-langu DEFAULT sy-langu
      EXPORTING
        !et_items      TYPE tt_body
        !es_footer     TYPE ty_footer
      CHANGING
        !ct_return     TYPE bapiret2_t .
    CLASS-METHODS footer_data
      EXPORTING
        !es_footer TYPE ty_footer .
    CLASS-METHODS display_sf
      IMPORTING
        !is_header TYPE ty_header
        !it_body   TYPE tt_body_str
        !is_footer TYPE ty_footer_str
        !iv_langu  TYPE sy-langu DEFAULT sy-langu
        !iv_otf    TYPE c DEFAULT space
      EXPORTING
        !et_otf    TYPE tsfotf
      CHANGING
        !ct_return TYPE bapiret2_tab .
    CLASS-METHODS company_address
      IMPORTING
        !iv_bukrs         TYPE bukrs
        !iv_langu         TYPE sy-langu DEFAULT sy-langu
      EXPORTING
        !es_plant_address TYPE ty_plant_address .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS get_user_full_name
      EXPORTING
        !ev_fullname TYPE so_adrnam .
    CLASS-METHODS order_number
      IMPORTING
        !iv_invoice_no   TYPE vbeln_vf
      EXPORTING
        !ev_order_number TYPE /dbe/vbeln_va .
ENDCLASS.



CLASS YCL_DBE_PRT_CRDT_INV_FRM_UTIL IMPLEMENTATION.


  METHOD company_address.

    SELECT SINGLE
      t001w~name1 " name of company
      t001w~name2 " arabic name
      t001w~pstlz " postal code
      t001w~ort01 " city
      t005t~landx " country
      INTO es_plant_address
      FROM t001w INNER JOIN t005t
      ON t001w~land1 = t005t~land1
      WHERE t001w~werks = iv_bukrs AND
      t001w~spras = yif_dbm_jet_constants=>gc_lang_en AND
      t005t~spras = yif_dbm_jet_constants=>gc_lang_en .

  ENDMETHOD.


  METHOD display_sf.

    DATA: lc_sfname TYPE char30 VALUE 'YDBM_JACO_CRDT_INVOICE',
          lv_fname  TYPE char30.
    DATA: ts_outoptions  TYPE ssfcompop,
          ts_ctrlparms   TYPE ssfctrlop,
          "Internal table to hold OTF data recd from the SMARTFORM
          it_otf_from_fm TYPE ssfcrescl,
          ts_return      LIKE LINE OF ct_return,
          ts_stxfadm     TYPE stxfadm.

    "language
    ts_ctrlparms-langu = yif_dbm_jet_constants=>gc_lang_ar.
    ts_ctrlparms-preview = space.
    IF iv_otf = abap_true.
      ts_ctrlparms-getotf = abap_true.
    ENDIF.
    "get smartform FM name.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = lc_sfname
      IMPORTING
        fm_name            = lv_fname
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    IF sy-subrc <> 0.
      CLEAR ts_return.
      MESSAGE e016(ymsg_jet_dbm) INTO ts_return-message.
      ts_return-id = yif_dbm_jet_constants=>gc_msg_class_id.
      ts_return-type = yif_dbm_jet_constants=>gc_value_e.
      ts_return-number = 016.
      APPEND ts_return TO ct_return.
    ELSE.
      "Calling the fm of the smartform
      ts_ctrlparms-langu = 'AR'."iv_langu.
      CALL FUNCTION lv_fname
        EXPORTING
          control_parameters = ts_ctrlparms
          output_options     = ts_outoptions
          user_settings      = abap_false
          is_header          = is_header
          it_body            = it_body
          is_footer          = is_footer
        IMPORTING
          job_output_info    = it_otf_from_fm
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
        MESSAGE w016(ymsg_jet_dbm) INTO ts_return-message.
        ts_return-id = yif_dbm_jet_constants=>gc_msg_class_id.
        ts_return-type = yif_dbm_jet_constants=>gc_value_w.
        ts_return-number = 016.
        APPEND ts_return TO ct_return.
      ENDIF.
      "the otf data is stored
      et_otf = it_otf_from_fm-otfdata.
    ENDIF.
  ENDMETHOD.


  METHOD footer_data.




  ENDMETHOD.


  METHOD get_user_full_name.

    DATA: ls_user_data TYPE soudatai1,
          ls_user      TYPE soudnamei1,
          l_fullname   TYPE so_adrnam.

* give the logged on user id
    ls_user-sapname = sy-uname.

* get the user data
    CALL FUNCTION 'SO_USER_READ_API1'
      EXPORTING
        user      = ls_user
      IMPORTING
        user_data = ls_user_data.

* get the user full name
    ev_fullname = ls_user_data-fullname.



  ENDMETHOD.


  METHOD header_data.
    DATA : erdat_timestamp     TYPE timestamp,
           lv_created_by_uname TYPE /dbe/ange_user,
           lv_fkart            TYPE fkart,
           it_split            TYPE TABLE OF ty_split,
           ts_split            TYPE   ty_split,

           erdat_timestamp_str TYPE string.
    DATA lv_aufart TYPE /dbe/aufart_s.
    DATA lv_zterm TYPE dzterm.
    CONSTANTS: lc_quot TYPE /dbe/vbtyp VALUE 'B'.
    "get invoice data
    es_header_data-inv_number = iv_invoice_number.
    SELECT SINGLE
*      erzet "Invoice time
*      erdat " invoice date
*      kunag " account number
*      bukrs " company code
*      fkart " invoice type (eg : pro forma invoice , invoice etc )
*      zterm
          vbrk~vbeln
          vbrk~fkart
          vbrk~erzet
          vbrk~fkdat
          tvfkt~vtext
          vbrk~bukrs
          vbrk~spart
          vbrp~vgbel
          vbrp~werks
*          vbrk~kunag
          vbrk~waerk
       INTO (es_header_data-inv_number   ,  es_header_data-fkart, es_header_data-inv_time    , es_header_data-inv_date,
             es_header_data-pmnt_term_txt , es_header_data-company_code, es_header_data-division,
             es_header_data-order_no     , es_header_data-center_code,  es_header_data-currency)

     FROM vbrk INNER JOIN vbrp ON vbrk~vbeln EQ vbrp~vbeln
     INNER JOIN tvfkt ON tvfkt~fkart EQ vbrk~fkart
     WHERE vbrk~vbeln EQ iv_invoice_number
            AND vbrk~fksto = ''
            AND tvfkt~spras = iv_langu.

    SELECT SINGLE
*          /dbe/vbak_db~spart
*          /dbe/vbak_db~stell
*          /dbe/vbap~model_guid
          /dbe/vbap~kunnr
     INTO es_header_data-ac_number
     FROM /dbe/vbak_db INNER JOIN /dbe/vbap ON /dbe/vbak_db~vbeln EQ /dbe/vbap~vbeln
     WHERE /dbe/vbak_db~vbeln EQ es_header_data-order_no.


    IF es_header_data-ac_number IS NOT INITIAL .
      "customer details
      SELECT SINGLE
        name1 " customer name
        adrnr " address number
        INTO (es_header_data-cus_name,es_header_data-addr_no)
        FROM kna1
        WHERE
        kunnr = es_header_data-ac_number.

      IF es_header_data-addr_no IS NOT INITIAL .
        SELECT SINGLE
          city1 " customer city
          FROM adrc
          INTO es_header_data-cus_city
          WHERE addrnumber = es_header_data-addr_no.
      ENDIF.

    ENDIF.

    "inv date and time
    es_header_data-inv_date_time = |{ es_header_data-inv_date(4) }-{ es_header_data-inv_date+4(2) }-{ es_header_data-inv_date+6(2) } - { es_header_data-inv_time(2) }:{ es_header_data-inv_time+2(2) }:{ es_header_data-inv_time+4(2) }|.

    IF es_header_data-company_code IS NOT INITIAL .
      SELECT SINGLE stceg
        INTO es_header_data-comp_vat
        FROM t001
        WHERE bukrs = es_header_data-company_code.
    ENDIF.

    SELECT SINGLE aufart zterm FROM /dbe/splhdr_db
      INTO ( lv_aufart , lv_zterm )
      WHERE vbeln = es_header_data-order_no
        AND splnr = '0001'.
    IF sy-subrc = 0..
      CASE lv_aufart.
        WHEN 'ZP05' OR 'ZP55'.
*          gs_headerdata-header_text_en = 'RETURN SALES INVOICE'.
*          gs_headerdata-header_text_ar = 'فـاتـورة مـبـيـعـات مـرجـعـة'.
*          gv_ret_inv = 'X'.
********************************
*          SELECT SINGLE pay_term FROM ydbmc_crdt_pay_t
*            INTO lv_temp_payt WHERE pay_term = lv_zterm.
*          IF sy-subrc = 0.
*            gs_headerdata-header_text_en = 'CREDIT RETURN INVOICE'.
*            gs_headerdata-header_text_ar = 'فاتورة مرتجع آجلة'.
*          ELSE.
*            gs_headerdata-header_text_en = 'CASH RETURN INVOICE'.
*            gs_headerdata-header_text_ar = 'فاتورة مرتجع نقدية'.
*          ENDIF.

*******************************
        WHEN 'ZP06' OR 'ZP56'.
*          gs_headerdata-header_text_en = 'CREDIT-MEMO SALES INVOICE'.
**          gs_headerdata-header_text_ar = 'مذكرة فاتورة مبيعات أجلة'.   "commented by ismail
*          gs_headerdata-header_text_ar = 'إشعار دائن'.
        WHEN OTHERS.
*          DATA: lv_temp_payt TYPE dzterm.
*          SELECT SINGLE pay_term FROM ydbmc_crdt_pay_t
*            INTO @DATA(lv_temp_payt) WHERE pay_term = @lv_zterm.
          IF sy-subrc = 0.
*            gs_headerdata-header_text_en = 'CREDIT SALES INVOICE'.
*            gs_headerdata-header_text_ar = 'فـاتـورة مـبـيـعـات آجـلـة'.
            es_header_data-pmnt_term_txt  = 'Credit Invoice'.
*            gs_headerdata-header_text_ar = 'فاتورة آجلة'.
          ELSE.
*            gs_headerdata-header_text_en = 'CASH SALES INVOICE'.
*            gs_headerdata-header_text_ar = 'فاتورة مبيعات نقدية'.
            es_header_data-pmnt_term_txt  = 'Cash Invoice'.
*            gs_headerdata-header_text_ar = 'فاتورة نقدية'.
          ENDIF.
      ENDCASE.
    ENDIF.
*    IF lv_zterm = 'Z001'.
*      es_header_data-inv_type_text = 'Cash Sale'.
*    ELSE.
*      es_header_data-inv_type_text = 'Credit Sale'.
*    ENDIF.

    SELECT SINGLE vtext FROM tvzbt
      INTO es_header_data-pmnt_term_txt
      WHERE spras = sy-langu
        AND zterm = lv_zterm.
    IF sy-subrc = 0.
      CONCATENATE lv_zterm ':' es_header_data-pmnt_term_txt
        INTO es_header_data-pmnt_term_txt  SEPARATED BY space.
      SELECT SINGLE ztag2 INTO @DATA(lv_days) FROM t052
        WHERE zterm = @lv_zterm.
      es_header_data-due_date = es_header_data-inv_date + lv_days.
    ENDIF.

*    CONCATENATE 'BUS2400   ' es_header_data-order_no '%' INTO DATA(l_instid_a) RESPECTING BLANKS.
*    SELECT SINGLE instid_b
*      FROM /dbe/ord_docflow
*      INTO @DATA(l_instid_b) "gs_headerdata-sale_q_no
*     WHERE reltype = 'VONA'
*       AND instid_a LIKE @l_instid_a "gs_headerdata-sale_o_no
*       AND instid_b LIKE 'BUS2400%'.
*    IF sy-subrc = 0.
*      es_header_data-quotation = l_instid_b+13(10).  "BUS2400   0013100129420  00001000000000
*    ENDIF.

*    IF lv_fkart IS NOT INITIAL .
*      " get invoice type from TVFKT table
*      SELECT SINGLE  vtext
*        FROM tvfkt
*        INTO es_header_data-inv_type_text
*        WHERE fkart = lv_fkart AND
*        spras = yif_dbm_jet_constants=>gc_lang_en.
**        spras = sy-langu.
*    ENDIF.

    "order number
*    CALL METHOD ycl_dbm_prt_crdt_inv_frm_util=>order_number
*      EXPORTING
*        iv_invoice_no   = iv_invoice_number
*      IMPORTING
*        ev_order_number = es_header_data-order_no.
    DATA: it_docs TYPE  /dbe/docflow_documents_tt,
          wa_docs LIKE LINE OF it_docs.
    IF es_header_data-order_no IS NOT INITIAL.

*--here adding for quotation..
*      *--added this FM to get all the docflow table enntries for this DBM order ..
*      CALL FUNCTION '/dbe/OE_MAIN_DOCFLOW_READ_ALL'
      CALL FUNCTION '/DBE/OE_MAIN_DOCFLOW_READ_ALL'
        EXPORTING
          iv_vbeln       = es_header_data-order_no
        IMPORTING
          et_documents   = it_docs
        EXCEPTIONS
          internal_error = 1
          OTHERS         = 2.
      DATA: lv_quotation TYPE /dbe/vbeln_va.
      CLEAR: wa_docs.
      READ TABLE it_docs INTO wa_docs WITH KEY objtype = 'BUS2400'.
      IF sy-subrc EQ 0.
        lv_quotation = wa_docs-docnum.
        SELECT SINGLE aufart FROM /dbe/splhdr_db
          INTO @DATA(lv_quot_type)
          WHERE vbeln = @lv_quotation
            AND splnr = '0001'.
        IF sy-subrc = 0.
          SELECT SINGLE vbtyp FROM /dbe/c_ordertp
            INTO @DATA(lv_quot_vbtyp)
            WHERE aufart = @lv_quot_type.
          IF sy-subrc = 0 AND lv_quot_vbtyp = lc_quot.
            es_header_data-quotation = lv_quotation.
          ENDIF.
        ENDIF.
      ENDIF.
*----end of addtion

*      SELECT
*        splnr
*        kunnr
*        FROM /dbe/splhdr_db
*        INTO TABLE it_split
*        WHERE vbeln = es_header_data-order_no.
*      IF sy-subrc = 0.
*        SORT it_split ASCENDING BY splnr.
*        IF lines( it_split ) > 1.
*          READ TABLE it_split INTO ts_split INDEX 2.
*          IF sy-subrc = 0.
*            es_header_data-financer = ts_split-kunnr.
*          ENDIF.
*        ENDIF.
*      ENDIF.
      "get order details
      SELECT SINGLE
        vguid
        erdat_tmstp
*        ernam
        ange_user
        bstnk
        werks
        INTO (es_header_data-v_guid,erdat_timestamp,lv_created_by_uname, es_header_data-cust_po, es_header_data-center_code)
        FROM /dbe/vbak_db
        WHERE vbeln = es_header_data-order_no.
      IF sy-subrc = 0.
        "convert into date from timestamp
        IF erdat_timestamp IS NOT INITIAL.
          erdat_timestamp_str = erdat_timestamp.
          CALL FUNCTION 'CACS_TIMESTAMP_GET_DATE'
            EXPORTING
              i_timestamp = erdat_timestamp_str
            IMPORTING
              e_date      = es_header_data-ordr_date.
        ENDIF.
        IF es_header_data-center_code IS NOT INITIAL.
          SELECT SINGLE name1 FROM t001w INTO @DATA(lv_plantt) WHERE werks = @es_header_data-center_code.
          IF sy-subrc EQ 0.
            es_header_data-center_code = | { es_header_data-center_code } { '-' } { lv_plantt } { 'Spare Parts' } |.
          ENDIF.
        ENDIF.

*        IF es_header_data-v_guid IS NOT INITIAL.
*          "vehicle type eg : new vehicle , pre-owned etc.
*          SELECT SINGLE
*            bustype~descr
*            FROM
*            /dbe/v_bustypet AS bustype
*            INNER JOIN vlcvehicle
*            ON vlcvehicle~dbm_bustype = bustype~bustype
*            INTO es_header_data-bustype
*            WHERE
*              vlcvehicle~vguid = es_header_data-v_guid.
*        ENDIF.


        "get full name of salesman
        es_header_data-sales_man = lv_created_by_uname.
*        CALL METHOD ycl_dbm_veh_crdt_inv_frm_util=>get_user_full_name
*          EXPORTING
*            iv_sys_name = lv_created_by_uname
*          IMPORTING
*            ev_fullname = ev_salesman.
        DATA: ls_user_data TYPE soudatai1,
              ls_user      TYPE soudnamei1,
              l_fullname   TYPE so_adrnam.

* give the logged on user id
        ls_user-sapname = lv_created_by_uname.
* get the user data
        IF lv_created_by_uname IS NOT INITIAL.
          CALL FUNCTION 'SO_USER_READ_API1'
            EXPORTING
              user      = ls_user
            IMPORTING
              user_data = ls_user_data.

* get the user full name
          l_fullname = ls_user_data-fullname.
          es_header_data-sales_man_name = l_fullname.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD items_data.

    CONSTANTS : lc_currency LIKE sy-waers VALUE 'SAR'.

*    TYPES: BEGIN OF ty_model,
*             mcodesd TYPE dbm_modcode_sale,
*             motext  TYPE string,
*           END OF ty_model.

    TYPES:BEGIN OF ty_konv,
*            knumv TYPE konv-knumv,
*            kposn TYPE konv-kposn,
*            kschl TYPE konv-kschl,
*            kbetr TYPE konv-kbetr,
*            waers TYPE konv-waers,
*            kwert TYPE konv-kwert,
            knumv TYPE v_konv_cds-knumv,
            kposn TYPE v_konv_cds-kposn,
            kschl TYPE v_konv_cds-kschl,
            kbetr TYPE v_konv_cds-kbetr,
            waers TYPE v_konv_cds-waers,
            kwert TYPE v_konv_cds-kwert,
          END OF ty_konv,

          BEGIN OF ty_item_desc,
            part_number TYPE matnr,
            lang        TYPE spras,
            desc        TYPE maktx,
          END OF ty_item_desc.

*    TYPES:BEGIN OF ty_konv,
**            knumv TYPE konv-knumv,
**            kposn TYPE konv-kposn,
**            kschl TYPE konv-kschl,
**            kdatu TYPE konv-kdatu,
**            kawrt TYPE konv-kawrt,
**            kbetr TYPE konv-kbetr,
**            waers TYPE konv-waers,
**            kwert TYPE konv-kwert,
*            knumv TYPE konv-knumv,
*            kposn TYPE konv-kposn,
*            kschl TYPE konv-kschl,
*            kbetr TYPE konv-kbetr,
*            waers TYPE konv-waers,
*            kwert TYPE konv-kwert,
*          END OF ty_konv.

*    DATA: lt_model TYPE TABLE OF ty_model,
*          ls_model LIKE LINE OF lt_model.

    DATA : lt_material_desc TYPE tt_material_desc,
           ls_material_desc LIKE LINE OF lt_material_desc,
           ls_spell         TYPE spell.

    FIELD-SYMBOLS : <fs_mat_desc> TYPE ty_body.

    DATA: lt_items TYPE tt_body.

    DATA: lt_discount TYPE TABLE OF ydbmc_jet_slcond,
          lt_konv     TYPE TABLE OF ty_konv.

    DATA ls_konv LIKE LINE OF lt_konv.
    DATA lv_knumv TYPE knumv.
    DATA ts_return    LIKE LINE OF ct_return.
    DATA: lv_disc TYPE konv-kwert.
    DATA: lv_order TYPE vbeln_va.
    DATA: lv_cur TYPE string.
    DATA: lv_desc TYPE string.
    DATA: lv_percentage TYPE p DECIMALS 2.
    DATA: lv_amount TYPE kwert.
    DATA: lv_kwert TYPE kwert.
    DATA: lv_pack TYPE p DECIMALS 2.

*    SELECT SINGLE h_knumv FROM /dbe/vbak_db INTO lv_knumv WHERE vbeln = iv_order_no.

*    SELECT
*      /dbe/vbap~posnr
*      /dbe/vbap~matnr18 " product number
*      /dbe/vbap~zmeng " quantity
**      /dbe/vbap~netwr " unit price
**      /dbe/vbap~netpr " net price.
*      /dbe/vbap~mcodesd
*      /dbe/vbap~vhcle
*      /dbe/vbap~descr1
*      /dbe/vbap~main_item
*    FROM /dbe/vbap
*    INTO TABLE lt_items
*    WHERE /dbe/vbap~vbeln = iv_order_no
*      AND pstyv <> 'G2TX'
*      AND itcanc <> abap_true.
*
*    IF sy-subrc = 0.
*      DATA: lt_vehicle TYPE TABLE OF vlcvehicle,
*            ls_vehicle LIKE LINE OF lt_vehicle.
*
*      SELECT * FROM vlcvehicle INTO TABLE lt_vehicle
*        FOR ALL ENTRIES IN lt_items WHERE vhcle = lt_items-vehicle.
*
*      "get material description
*      DATA: lt_disc_type TYPE RANGE OF ydbmc_jet_slcond-cond_type,
*            ls_disc_type LIKE LINE OF lt_disc_type.
*      SELECT cond_type AS low FROM ydbmc_jet_slcond INTO CORRESPONDING FIELDS OF TABLE lt_disc_type WHERE act_type = '02'.
*      IF sy-subrc = 0.
*        ls_disc_type-sign = 'I'.
*        ls_disc_type-option = 'EQ'.
*        MODIFY lt_disc_type FROM ls_disc_type TRANSPORTING sign option WHERE low <> space.
*      ENDIF.
**      SELECT * FROM ydbmc_jet_slcond INTO TABLE lt_discount WHERE act_type = '02'.
*
*      IF sy-subrc = 0.
*        SELECT
*          knumv
*          kposn
*          kschl
*          kdatu
*          kawrt
*          kbetr
*          waers
*          kwert
*         FROM konv INTO TABLE lt_konv
**          FOR ALL ENTRIES IN lt_discount
*          WHERE knumv = lv_knumv AND kinak = ''
*          AND kinak <> abap_true.
**          AND ( kschl = lt_discount-cond_type OR kschl = 'MWST').
*
*      ENDIF.
*      IF lt_items IS NOT INITIAL.
*        SELECT
*        makt~matnr
*        mara~bismt
*        makt~maktx
*        FROM makt
*        INNER JOIN mara
*        ON makt~matnr = mara~matnr
*        INTO TABLE lt_material_desc
*        FOR ALL ENTRIES IN lt_items
*        WHERE mara~matnr = lt_items-product_number AND
*        makt~spras = yif_dbm_jet_constants=>gc_lang_en. "#EC CI_NO_TRANSFORM
**        makt~spras = sy-langu.                      "#EC CI_NO_TRANSFORM
*
*        SELECT
*          /dbe/v_model~mcodesd
*          /dbe/v_modelt~motext1
*          FROM /dbe/v_model
*          INNER JOIN /dbe/v_modelt
*          ON /dbe/v_model~model_guid = /dbe/v_modelt~model_guid
*          INTO TABLE lt_model FOR ALL ENTRIES IN lt_items
*          WHERE mcodesd = lt_items-mcodesd
*              AND spras = yif_dbm_jet_constants=>gc_lang_en.
**              AND spras = sy-langu.
*
*      ENDIF.

    FIELD-SYMBOLS: <fs_item> LIKE LINE OF et_items.
    DATA: ls_item LIKE LINE OF lt_items.

    SELECT
    vbrp~posnr "Item number
    vbrp~matnr "Part number
    vbrp~fkimg " Quamtity
    vbrp~prsdt "Pricing date
    vbrp~netwr "Total price
*    vbrp~vgbel "dbm order no
*    vbrp~vrkme "Sales unit
*    vbap~kbetr "Unit price
    INTO TABLE lt_items            "lt_items
    FROM vbrp INNER JOIN /dbe/vbap AS vbap ON vbrp~vgbel EQ vbap~vbeln
     AND vbrp~vgpos EQ vbap~posnr
    WHERE vbrp~vbeln EQ iv_invoice_no .


    IF lt_items IS NOT INITIAL.
      SELECT
        makt~matnr
        makt~spras
        makt~maktx
      INTO TABLE lt_material_desc
        FROM makt FOR ALL ENTRIES IN lt_items
        WHERE matnr EQ lt_items-product_number.
    ENDIF.
**********************************************************************
*    Prepare pricing details                                                *
**********************************************************************

    IF sy-subrc = 0 .
      SELECT SINGLE vgbel FROM vbrp INTO lv_order WHERE vbrp~vbeln = iv_invoice_no.
      IF sy-subrc EQ 0.
        SELECT SINGLE aufart FROM /dbe/splhdr_db
        INTO @DATA(lv_ord_type)
              WHERE vbeln = @lv_order
              AND splnr = '0001'.
        IF sy-subrc EQ 0.

        ENDIF.
      ENDIF.
      SELECT SINGLE knumv FROM vbrk INTO lv_knumv WHERE vbeln = iv_invoice_no.

      IF sy-subrc = 0.
*        SELECT knumv kposn kschl kbetr waers kwert FROM konv INTO TABLE lt_konv WHERE knumv = lv_knumv AND kinak  = ''.
        SELECT knumv kposn kschl kbetr waers kwert FROM v_konv_cds INTO TABLE lt_konv WHERE knumv = lv_knumv AND kinak  = ''. "8754
        IF sy-subrc = 0.
          LOOP AT lt_konv INTO ls_konv .
            IF ls_konv-kschl = 'YP01'."Gross Price
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-unit_price =  ls_konv-kbetr.
                <fs_item>-unit_price2 =  ls_konv-kwert.
              ENDIF.
            ELSEIF ls_konv-kschl = 'QSML'."Manual price
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-unit_price = ls_konv-kbetr.
                <fs_item>-unit_price2 = ls_konv-kwert.
              ENDIF.
            ELSEIF ls_konv-kschl = 'QPRT'."Part price
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-unit_price = ls_konv-kbetr.
                <fs_item>-unit_price2 = ls_konv-kwert.
              ENDIF.
            ELSEIF ls_konv-kschl = 'YSP1'."Part price
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-unit_price = ls_konv-kbetr.
                <fs_item>-unit_price2 = ls_konv-kwert.
              ENDIF.
            ELSEIF ls_konv-kschl = 'QRTK'."Header Discount
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
              ENDIF.
            ELSEIF ls_konv-kschl = 'YRPO'."Item Discount
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
              ENDIF.
            ELSEIF ls_konv-kschl = 'YP05'."Customer Group Discount
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
              ENDIF.
            ELSEIF ls_konv-kschl = 'YZTK'."Header Surcharge
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-surcharge = <fs_item>-surcharge + ls_konv-kwert.
              ENDIF.
            ELSEIF ls_konv-kschl = 'YCHP'."Item Surcharge
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-surcharge = <fs_item>-surcharge + ls_konv-kwert.
              ENDIF.
            ELSEIF ls_konv-kschl = 'YP11'."Gross Price
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-unit_price =  ( ls_konv-kwert / <fs_item>-qty ).
              ENDIF.
            ELSEIF ls_konv-kschl = 'MWST'."Tax
              READ TABLE lt_items ASSIGNING <fs_item> WITH KEY itm_no = ls_konv-kposn.
              IF sy-subrc = 0.
                <fs_item>-vat = <fs_item>-vat + ls_konv-kwert.
                <fs_item>-total_price =  <fs_item>-total_price + ls_konv-kwert.
                IF <fs_item>-vat_rate IS INITIAL OR <fs_item>-vat_rate = 0.
                  <fs_item>-vat_rate = ls_konv-kbetr / 10.
                  <fs_item>-vat_rate = | { <fs_item>-vat_rate }% |.
                ENDIF.
              ENDIF.
            ENDIF.
*            <fs_item>-disc_percent = <fs_item>-discount / <fs_item>-unit_price * 100.
            IF <fs_item> IS ASSIGNED. "8754
              <fs_item>-taxable_amt = <fs_item>-unit_price * <fs_item>-qty + <fs_item>-discount.
              <fs_item>-total_inc_vat = <fs_item>-taxable_amt + <fs_item>-vat.
            ENDIF. "8754
          ENDLOOP.
        ENDIF.
      ENDIF.
    ELSE.
      "write Error log
      CLEAR ts_return.
      MESSAGE w020(ymsg_jet_dbm) INTO ts_return-message.
      ts_return-id = yif_dbm_jet_constants=>gc_msg_class_id..
      ts_return-type =  yif_dbm_jet_constants=>gc_value_w.
      ts_return-number = 017.
      APPEND ts_return TO ct_return.
    ENDIF.

    LOOP AT lt_items ASSIGNING <fs_mat_desc>.
      CLEAR: ls_material_desc, lv_desc.
      READ TABLE lt_material_desc INTO ls_material_desc WITH KEY product_number = <fs_mat_desc>-product_number
                                                                 spras = 'E'.
      IF sy-subrc = 0.
        lv_desc = ls_material_desc-desc.
      ENDIF.
      READ TABLE lt_material_desc INTO ls_material_desc WITH KEY product_number = <fs_mat_desc>-product_number
                                                                 spras = 'A'.
      IF sy-subrc = 0.
        CONCATENATE lv_desc ls_material_desc-desc INTO <fs_mat_desc>-desc SEPARATED BY cl_abap_char_utilities=>newline.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = <fs_mat_desc>-product_number
        IMPORTING
          output = <fs_mat_desc>-product_number.

      lv_pack = <fs_mat_desc>-discount / <fs_mat_desc>-unit_price2 * 100.
      <fs_mat_desc>-disc_percent = lv_pack.
      es_footer-tot_inv_grs_amt = es_footer-tot_inv_grs_amt + <fs_mat_desc>-unit_price2. " + <fs_mat_desc>-discount.
      es_footer-discount = es_footer-discount + <fs_mat_desc>-discount.
      es_footer-taxable_amt = es_footer-taxable_amt + <fs_mat_desc>-taxable_amt.
      es_footer-vat = es_footer-vat + <fs_mat_desc>-vat.
      es_footer-final_amt = es_footer-final_amt + <fs_mat_desc>-taxable_amt + <fs_mat_desc>-vat.
    ENDLOOP.

    et_items = lt_items.


*        READ TABLE lt_vehicle INTO ls_vehicle WITH KEY vhcle = <fs_mat_desc>-vehicle.
*        IF sy-subrc = 0.
*          <fs_mat_desc>-chassis = ls_vehicle-vhvin.
*          <fs_mat_desc>-commission = ls_vehicle-vhcex.
*        ENDIF.
*
*
*        "calculate Discount, total amount and VAT
*        CLEAR lv_disc.
*
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_mat_desc>-posnr kschl = 'QSBP'."DBM Gross Price
*        IF sy-subrc = 0.
*          <fs_mat_desc>-ext_price  = ls_konv-kwert.
*          <fs_mat_desc>-unit_price =  ls_konv-kbetr.
*          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*            EXPORTING
**             CLIENT           = SY-MANDT
*              date             = ls_konv-kdatu
*              foreign_amount   = ls_konv-kbetr
*              foreign_currency = ls_konv-waers
*              local_currency   = 'SAR'
*            IMPORTING
*              local_amount     = <fs_mat_desc>-unit_price.
*        ENDIF.
*
*        LOOP AT lt_konv INTO ls_konv WHERE kposn = <fs_mat_desc>-posnr AND kschl IN lt_disc_type.
*          lv_disc = lv_disc + ls_konv-kwert.
*        ENDLOOP.
*
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_mat_desc>-posnr kschl = 'MWST'."Tax
*        IF sy-subrc = 0.
*          <fs_mat_desc>-vat = ls_konv-kwert.
*          es_footer-vat = es_footer-vat + ls_konv-kwert.
*        ENDIF.
*
*        <fs_mat_desc>-ext_price = <fs_mat_desc>-ext_price + <fs_mat_desc>-vat.
*        es_footer-gross_amount = es_footer-gross_amount + <fs_mat_desc>-ext_price. " gross amount
*        es_footer-discount = es_footer-discount + lv_disc ."Discount
*        es_footer-net_price = es_footer-net_price + <fs_mat_desc>-ext_price. " net amount
*
*        SHIFT <fs_mat_desc>-product_number LEFT DELETING LEADING '0'.
*        SHIFT <fs_mat_desc>-bismt LEFT DELETING LEADING '0'.
*      ENDLOOP.
*    ENDIF.

    "Calculate Gross Amount
*    es_footer-gross_amount = es_footer-net_price + es_footer-vat - es_footer-discount.
*    es_footer-final_amt = es_footer-net_price + es_footer-vat - es_footer-discount + es_footer-regist_amt.
*
*    "calculate discount percentage
*    IF es_footer-discount NE 0.
**    es_footer-net_price = es_footer-net_price - es_footer-discount.
*      IF es_footer-gross_amount > 0.
*        lv_percentage = ( es_footer-discount ) / es_footer-net_price * 100.
*        es_footer-disc_percent =  lv_percentage.
*      ELSE.
*        es_footer-disc_percent = '0.0'.
*      ENDIF.
*    ENDIF.
*
**--here adding new logic to calculate other fields
*    <fs_item>-taxable_amt = es_footer-net_price - es_footer-discount.   "taxable amount
*    <fs_item>-disc_percent = es_footer-disc_percent.                    "
*    <fs_item>-discount = es_footer-discount.
*    <fs_item>-total_inc_vat =  <fs_item>-taxable_amt +  <fs_item>-vat.  "total inclusive vat
*    es_footer-tot_inv_grs_amt = <fs_item>-taxable_amt + es_footer-regist_amt.
*    es_footer-taxable_amt  = <fs_item>-taxable_amt.
*
*    lv_kwert = es_footer-discount.
*    es_footer-discount = lv_kwert.
*    lv_kwert = es_footer-gross_amount.
*    es_footer-gross_amount = lv_kwert.
*    lv_kwert = es_footer-net_price.
*    es_footer-net_price = lv_kwert.
*    lv_kwert = es_footer-regist_amt.
*    es_footer-regist_amt = lv_kwert.
*    lv_kwert = es_footer-vat.
*    es_footer-vat = lv_kwert.
*
*************
*    lv_kwert = <fs_item>-taxable_amt.
*    <fs_item>-taxable_amt =  lv_kwert.
*    lv_kwert =  <fs_item>-discount.
*    <fs_item>-discount =  lv_kwert.
*    lv_kwert =  <fs_item>-total_inc_vat.
*    <fs_item>-total_inc_vat =  lv_kwert.
*    lv_kwert =   es_footer-tot_inv_grs_amt.
*    es_footer-tot_inv_grs_amt =  lv_kwert.
*    lv_kwert =    es_footer-taxable_amt.
*    es_footer-taxable_amt =  lv_kwert.
*
    " price in words
    lv_kwert = es_footer-final_amt.
    CALL FUNCTION 'SPELL_AMOUNT'
      EXPORTING
        amount   = lv_kwert
        currency = lc_currency
        language = iv_langu
      IMPORTING
        in_words = ls_spell.
    es_footer-final_amt = lv_kwert.
    es_footer-netpr_in_words = ls_spell-word.

    IF iv_langu = yif_dbm_jet_constants=>gc_lang_ar.
      lv_amount = es_footer-disc_percent.
      lv_amount = es_footer-discount.
      lv_amount = es_footer-gross_amount.
      lv_amount = es_footer-vat.
      lv_amount = es_footer-net_price.

      TRANSLATE es_footer-disc_percent USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
      TRANSLATE es_footer-discount USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
      TRANSLATE es_footer-gross_amount USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
      TRANSLATE es_footer-vat USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
      TRANSLATE es_footer-net_price USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
      TRANSLATE es_footer-regist_amt USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
      TRANSLATE es_footer-final_amt USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
    ENDIF.

*    et_items = lt_items.

  ENDMETHOD.


  METHOD order_number.

    SELECT SINGLE
      /dbe/vbeln " dbm order number
      INTO ev_order_number
      FROM vbrp
      WHERE
      vbeln = iv_invoice_no.


  ENDMETHOD.
ENDCLASS.

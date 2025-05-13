class YCL_DBM_VEH_CRDT_INV_FRM_UTIL definition
  public
  final
  create public .

public section.

  interfaces YIF_DBM_JET_CONSTANTS .

  types:
    BEGIN OF  ty_plant_address,
        comp_name    TYPE name1,
        comp_name_ar TYPE name2,
        postal_code  TYPE pstlz,
        city         TYPE ort01,
*    country_key type LAND1,
        country      TYPE landx,
*    adrnr type ADRNR,
      END OF ty_plant_address .
  types:
    BEGIN OF ty_header,
        inv_number       TYPE  vbeln_vf,
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
        inv_type_text    TYPE char50,
        quotation        TYPE  vbeln_vf,  "quotation
        sales_man        TYPE ernam,      "salesman
        sales_man_name   TYPE string,      "salesman
        cust_po          TYPE bstnk,
        center_code      TYPE string,
        inv_date_time    TYPE string,
        fkart            TYPE fkart,   "billing type
        origin_ord       TYPE /dbe/vbeln_va,
        spart            TYPE spart,
      END OF ty_header .
  types:
    BEGIN OF ty_split,
        splnr TYPE /dbe/splhdr_db-splnr,
        kunnr TYPE /dbe/splhdr_db-kunnr,
      END OF ty_split .
  types:
    BEGIN OF ty_body,
        posnr          TYPE /dbe/vbap-posnr,
        product_number TYPE matnr,
        qty            TYPE /dbe/vbap-zmeng,
        mcodesd        TYPE /dbe/vbap-mcodesd,
        vehicle        TYPE vlcvehicle-vhcle,
        desc           TYPE maktx,
        main_item      TYPE /dbe/vbap-main_item,
        aufart         TYPE /dbe/vbap-aufart,    "doc type
        itcat          TYPE /dbe/vbap-itcat,
        chassis        TYPE string,
        commission     TYPE string,
        vat            TYPE string,
        vat_rate       TYPE string,
        bismt          TYPE matnr,
        tbd            TYPE string,
        disc_percent   TYPE string,
        discount       TYPE string,
        taxable_amt    TYPE string,
        total_inc_vat  TYPE string,
        unit_price     TYPE string,
        ext_price      TYPE string,
        qty_str        TYPE string,
      END OF ty_body .
  types:
    BEGIN OF ty_vehicle,
        product_code TYPE matnr,
        chassis      TYPE string,
        commission   TYPE string,
      END OF ty_vehicle .
  types:
    tt_vehicle TYPE TABLE OF ty_vehicle .
  types:
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
  types:
    BEGIN OF ty_material_desc,
        product_number TYPE matnr,
        bismt          TYPE bismt,
        desc           TYPE maktx,
      END OF ty_material_desc .
  types:
    tt_material_desc TYPE HASHED TABLE OF ty_material_desc WITH UNIQUE KEY product_number .
  types:
    tt_body TYPE TABLE OF ty_body .
  types:
    tt_body_str TYPE TABLE OF ty_body_str .
  types:
    BEGIN OF ty_footer,
        salesman        TYPE so_adrnam,
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
        title_eng       TYPE string,
        title_ar        TYPE string,
        veh_dep         TYPE string,
      END OF ty_footer .
  types:
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
        title_eng       TYPE string,
        title_ar        TYPE string,
        veh_dep         TYPE string,
      END OF ty_footer_str .

  class-data GT_BODY_ITEMS type TT_BODY .

  class-methods HEADER_DATA
    importing
      !IV_INVOICE_NUMBER type VBELN_VF
      !IV_LANGU type SY-LANGU default SY-LANGU
    exporting
      !ES_HEADER_DATA type TY_HEADER
      !EV_SALESMAN type SO_ADRNAM
      !ES_HEADER_DET1 type ZST_INV_HDR_DET .
  class-methods ITEMS_DATA
    importing
      !IV_ORDER_NO type /DBE/VBELN_VA optional
      !IV_LANGU type SY-LANGU default SY-LANGU
      !IV_INVOICE_NUMBER type VBELN_VF optional
    exporting
      !ET_ITEMS type TT_BODY
      !ES_FOOTER type TY_FOOTER
      !ET_VEHICLE type TT_VEHICLE
      !ET_ITEM_DET type ZTT_VSS_INV_ITEM_DET .
  class-methods FOOTER_DATA
    exporting
      !ES_FOOTER type TY_FOOTER .
  class-methods DISPLAY_SF
    importing
      !IS_HEADER type TY_HEADER
      !IT_BODY type TT_BODY_STR
      !IS_FOOTER type TY_FOOTER_STR
      !IV_LANGU type SY-LANGU default SY-LANGU
      !IV_OTF type C default SPACE
    exporting
      !ET_OTF type TSFOTF
    changing
      !CT_RETURN type BAPIRET2_TAB .
  class-methods COMPANY_ADDRESS
    importing
      !IV_BUKRS type BUKRS
      !IV_LANGU type SY-LANGU default SY-LANGU
    exporting
      !ES_PLANT_ADDRESS type TY_PLANT_ADDRESS .
  class-methods ITEM_NEW
    importing
      !IV_INVOICE type VBELN_VF
      !IV_ORDER_NO type /DBE/VBELN_VA
      !IV_LANGU type SY-LANGU optional
    exporting
      !ET_ITEMS type TT_BODY
      !ES_FOOTER type TY_FOOTER
      !ET_VEHICLE type TT_VEHICLE .
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



CLASS YCL_DBM_VEH_CRDT_INV_FRM_UTIL IMPLEMENTATION.


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
      t005t~spras = yif_dbm_jet_constants=>gc_lang_en.

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

*    vlcvehicle~dbe_bustype

    DATA : erdat_timestamp     TYPE timestamp,
           lv_created_by_uname TYPE ernam,
           lv_fkart            TYPE fkart,
           it_split            TYPE TABLE OF ty_split,
           ts_split            TYPE   ty_split,
           erdat_timestamp_str TYPE string.
    CONSTANTS: lc_quot TYPE /dbe/vbtyp VALUE 'B'.
    "get invoice data
    es_header_data-inv_number = iv_invoice_number.
    SELECT SINGLE fkart
      erzet "Invoice time
      erdat " invoice date
      kunag " account number
      bukrs " company code
      fkart " invoice type (eg : pro forma invoice , invoice etc )
      zterm
      INTO (es_header_data-fkart, es_header_data-inv_time, es_header_data-inv_date, es_header_data-ac_number,es_header_data-company_code,lv_fkart,es_header_data-inv_type_text )
      FROM vbrk
      WHERE vbeln = iv_invoice_number.
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

    IF es_header_data-inv_type_text = 'Z001'.
*      es_header_data-inv_type_text = 'Cash Sale-مبيعات نقدية'.
      CONCATENATE 'Cash Sale' '-' 'مبيعات نقدية' INTO   es_header_data-inv_type_text SEPARATED BY space.
    ELSE.
*      = 'Credit Sale-مبيعات آجلة'.
      CONCATENATE 'Credit Sale' '-' 'مبيعات آجلة' INTO   es_header_data-inv_type_text SEPARATED BY space.
    ENDIF.

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
    CALL METHOD ycl_dbm_veh_crdt_inv_frm_util=>order_number
      EXPORTING
        iv_invoice_no   = iv_invoice_number
      IMPORTING
        ev_order_number = es_header_data-order_no.
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

      SELECT
        splnr
        kunnr
        FROM /dbe/splhdr_db
        INTO TABLE it_split
        WHERE vbeln = es_header_data-order_no.
      IF sy-subrc = 0.
        SORT it_split ASCENDING BY splnr.
        IF lines( it_split ) > 1.
          READ TABLE it_split INTO ts_split INDEX 2.
          IF sy-subrc = 0.
            es_header_data-financer = ts_split-kunnr.
          ENDIF.
        ENDIF.
      ENDIF.
      "get order details
      SELECT SINGLE
        vguid
        erdat_tmstp
        ernam
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
*            es_header_data-center_code = | { es_header_data-center_code } { '-' } { lv_plantt } { 'Showroom' } |.
            es_header_data-center_code = | { lv_plantt } { 'Showroom' } |.
          ENDIF.
        ENDIF.

        IF es_header_data-v_guid IS NOT INITIAL.
          "vehicle type eg : new vehicle , pre-owned etc.
          SELECT SINGLE
            bustype~descr
            FROM
            /dbe/v_bustypet AS bustype
            INNER JOIN vlcvehicle
            ON vlcvehicle~/dbe/bustype = bustype~bustype
            INTO es_header_data-bustype
            WHERE
              vlcvehicle~vguid = es_header_data-v_guid.
        ENDIF.


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


    SELECT SINGLE * FROM vbrk INTO @DATA(ls_vbrk)
     WHERE vbeln = @iv_invoice_number.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    es_header_det1-invoice_no = ls_vbrk-vbeln.
    es_header_det1-invoiced_on = ls_vbrk-fkdat.
    es_header_det1-plant_code = ls_vbrk-waerk.
    es_header_det1-pric_proc = ls_vbrk-kalsm.
    es_header_det1-pyt_terms = ls_vbrk-zterm.
    es_header_det1-vat_no = ls_vbrk-stceg.

    SELECT SINGLE werks FROM vbrp INTO es_header_det1-plant_code
       WHERE vbeln = iv_invoice_number.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM t001w INTO @DATA(ls_t001w)
          WHERE werks = @es_header_det1-plant_code
            AND spras = 'E'.

      es_header_det1-plant_name = ls_t001w-name1.
      es_header_det1-plant_addr = ls_t001w-stras.
      es_header_det1-plant_pocode = ls_t001w-pstlz.
      es_header_det1-plant_city = ls_t001w-ort01.
      es_header_det1-plant_cntry = ls_t001w-land1.
      es_header_det1-plant_region = ls_t001w-regio.

      CLEAR:ls_t001w.
      SELECT SINGLE * FROM t001w INTO ls_t001w
          WHERE werks = es_header_det1-plant_code
           AND  spras = 'A'.

      es_header_det1-plant_name_ar = ls_t001w-name1.
      es_header_det1-plant_addr_ar = ls_t001w-stras.
      es_header_det1-plant_pocode_ar = ls_t001w-pstlz.
      es_header_det1-plant_city_ar = ls_t001w-ort01.

      SELECT SINGLE natio50 FROM t005t INTO es_header_det1-plant_cntry_a
        WHERE spras = 'A' AND land1 = ls_t001w-land1.

      SELECT SINGLE natio50 FROM t005t INTO es_header_det1-plant_cntry_en
        WHERE spras = 'E' AND land1 = ls_t001w-land1.
    ENDIF.
*** Get seller CR & VAT
    " CR
    SELECT werks,kunnr FROM t001w INTO TABLE @DATA(lt_werks)
      WHERE werks = @es_header_det1-plant_code.

    IF lt_werks[] IS NOT INITIAL.
      SELECT partner,idnumber FROM but0id INTO TABLE @DATA(lt_but0id)
        FOR ALL ENTRIES IN @lt_werks
        WHERE partner = @lt_werks-kunnr
          AND    type = 'CR'.

      READ TABLE lt_but0id INTO DATA(ls_but0id) INDEX 1.
      IF sy-subrc EQ 0.
        es_header_det1-cr_seller = ls_but0id-idnumber.
      ENDIF.
      " VAT
      SELECT partner,taxnum FROM dfkkbptaxnum INTO TABLE @DATA(lt_taxnum)
*        FOR ALL ENTRIES IN @lt_werks
        WHERE partner = 'P1200'
          AND taxtype = 'SA0'.

      READ TABLE lt_taxnum INTO DATA(ls_taxnum) INDEX 1.
      IF sy-subrc EQ 0.
        es_header_det1-vat_seller = ls_taxnum-taxnum.
      ENDIF.
    ENDIF.



    SELECT SINGLE vtext FROM tvzbt INTO es_header_det1-pyt_terms_a
       WHERE spras = 'A' AND zterm = ls_vbrk-zterm.

    SELECT SINGLE vtext FROM tvzbt INTO es_header_det1-pyt_terms_en
       WHERE spras = 'E' AND zterm = ls_vbrk-zterm.
    ls_vbrk-zuonr+17(1) = 1.

    SELECT * FROM bsid INTO TABLE @DATA(lt_bsid) WHERE zuonr EQ  @ls_vbrk-zuonr AND awtyp EQ 'DBMDP'.
    IF sy-subrc EQ 0.
      LOOP AT lt_bsid INTO DATA(ls_bsid).
        es_header_det1-down_payment =  es_header_det1-down_payment + ls_bsid-dmbtr.
      ENDLOOP.
    ELSE.

      DATA:lv_string TYPE string.
      lv_string = ls_vbrk-zuonr.
      REPLACE 'DBE' IN lv_string WITH 'DBM'.
      ls_vbrk-zuonr = lv_string.
      SELECT * FROM bsid INTO TABLE lt_bsid WHERE zuonr EQ  ls_vbrk-zuonr AND awtyp EQ 'DBMDP'.
      IF sy-subrc EQ 0.
        LOOP AT lt_bsid INTO ls_bsid.
          es_header_det1-down_payment =  es_header_det1-down_payment + ls_bsid-dmbtr.
        ENDLOOP.
      ENDIF.
    ENDIF.

    DATA(lv_vbeln) = ls_vbrk-zuonr+3(10).
    SELECT SINGLE * FROM /dbe/vbak_db INTO @DATA(ls_vbak) WHERE vbeln EQ @lv_vbeln.
    IF sy-subrc EQ 0.
      es_header_det1-veh_job_no = ls_vbak-vbeln.
      es_header_det1-veh_odo_met = ls_vbak-mileage.
      IF ls_vbak-vguid IS NOT INITIAL.
        SELECT SINGLE * FROM vlcvehicle INTO @DATA(ls_vehicle) WHERE vguid EQ @ls_vbak-vguid.
        IF sy-subrc EQ 0.
          es_header_det1-veh_vin = ls_vehicle-vhvin.
          es_header_det1-veh_plat = ls_vehicle-/dbe/licext.
          SELECT SINGLE * FROM /dbe/v_model INTO @DATA(ls_model) WHERE mcodesd EQ @ls_vehicle-matnr.
          IF sy-subrc EQ 0.
            SELECT SINGLE * FROM /dbe/v_modelt INTO @DATA(ls_modelt) WHERE model_guid EQ @ls_model-model_guid.
            es_header_det1-veh_model = ls_model-mcodesd.
            es_header_det1-veh_mod_dec = ls_modelt-motext1.
          ENDIF.
          SELECT SINGLE * FROM /dbe/v_imodel INTO @DATA(ls_veh_model) WHERE product_guid EQ @ls_vehicle-/dbe/iobjguid.
          IF sy-subrc EQ 0.
            es_header_det1-veh_mod_year = ls_veh_model-modyear.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

**** Get Toll free number TVARVC
    DATA: lv_name TYPE char30.
    CONCATENATE 'ZTOLLFREE_' ls_vbrk-spart INTO lv_name.
    CONDENSE lv_name.

    SELECT SINGLE low FROM tvarvc INTO es_header_det1-toll_freeno
      WHERE name = lv_name.

  ENDMETHOD.


  METHOD items_data.

    TYPES:
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
        matnr40    TYPE /dbe/matnr,
        zmeng      TYPE /dbe/amount,
        zieme      TYPE dzieme,
      END OF ty_item .

    DATA: ls_items          TYPE ty_item,
          lt_items          TYPE TABLE OF ty_item,
          ls_inv_item_det   TYPE zst_vss_inv_item_det,
          ls_veh_inv_detail TYPE zst_veh_inv_det,
          ls_vlcvehicle     TYPE vlcvehicle,
          lt_vbap           TYPE STANDARD TABLE OF /dbe/vbap,
          ls_vbap           TYPE /dbe/vbap,
          lv_2tone          TYPE c,
          lv_knumv          TYPE knumv.
*    BREAK-POINT.
    SELECT * FROM vbrp INTO CORRESPONDING FIELDS OF TABLE
        lt_items WHERE vbeln = iv_invoice_number.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    READ TABLE lt_items INTO ls_items INDEX 1.
    IF sy-subrc EQ 0.
      REFRESH lt_items.
      SELECT * FROM /dbe/vbap INTO CORRESPONDING FIELDS OF TABLE lt_items WHERE vbeln EQ ls_items-/dbe/vbeln.
      SELECT * FROM /dbe/vbap INTO TABLE lt_vbap WHERE vbeln EQ ls_items-/dbe/vbeln.
    ENDIF.



    SELECT SINGLE h_knumv FROM /dbe/vbak_db INTO lv_knumv
      WHERE vbeln = ls_items-/dbe/vbeln.
    SORT lt_items ASCENDING BY posnr.
    LOOP AT lt_items INTO ls_items.
      READ TABLE lt_vbap INTO ls_vbap WITH KEY vbeln = ls_items-vbeln posnr = ls_items-posnr.
      ls_inv_item_det-invoice_no = ls_items-vbeln.
      ls_inv_item_det-posnr = ls_items-posnr.
      ls_inv_item_det-matnr = ls_items-matnr40.
      ls_inv_item_det-mat_desc = ls_items-arktx.
*      ls_inv_item_det-qty = ls_items-fkimg.
*      ls_inv_item_det-uom = ls_items-meins.
      ls_inv_item_det-qty = ls_items-zmeng.
      ls_inv_item_det-uom = ls_items-zieme.

      CALL METHOD zcl_invoice_util_veh=>get_price_details
        EXPORTING
          iv_knumv     = lv_knumv   "ls_items-knumv_ana
          iv_kposn     = ls_inv_item_det-posnr
        IMPORTING
          es_price_det = ls_inv_item_det-prc_det.

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
        READ TABLE et_item_det INTO DATA(ls_inv_item_det1) WITH KEY posnr = ls_vbap-main_item.
        IF sy-subrc EQ 0.
          ls_inv_item_det1-prc_det-unit_price = ls_inv_item_det1-prc_det-unit_price + ls_inv_item_det-prc_det-unit_price.
          ls_inv_item_det1-prc_det-dis_rate = ls_inv_item_det1-prc_det-dis_rate + ls_inv_item_det-prc_det-dis_rate.
          ls_inv_item_det1-prc_det-dis_amount = ls_inv_item_det1-prc_det-dis_amount + ls_inv_item_det-prc_det-dis_amount.
          ls_inv_item_det1-prc_det-surcharge_amt = ls_inv_item_det1-prc_det-surcharge_amt + ls_inv_item_det-prc_det-surcharge_amt.
*          ls_inv_item_det1-prc_det-vat_rate = ls_inv_item_det1-prc_det-vat_rate + ls_inv_item_det-prc_det-vat_rate.
          ls_inv_item_det1-prc_det-vat_amount = ls_inv_item_det1-prc_det-vat_amount + ls_inv_item_det-prc_det-vat_amount.
          ls_inv_item_det1-prc_det-net_value = ls_inv_item_det1-prc_det-net_value + ls_inv_item_det-prc_det-net_value.
          ls_inv_item_det1-prc_det-gross_value = ls_inv_item_det1-prc_det-gross_value + ls_inv_item_det-prc_det-gross_value.
*          INSERT ls_inv_item_det INTO TABLE et_item_det.
          MODIFY et_item_det FROM ls_inv_item_det1 INDEX sy-tabix.
          CLEAR : ls_inv_item_det, ls_inv_item_det1.
        ENDIF.
        CLEAR lv_2tone.
      ENDIF.

    ENDLOOP.

















*    CONSTANTS : lc_currency LIKE sy-waers VALUE 'SAR'.
*
*    TYPES: BEGIN OF ty_model,
*             mcodesd TYPE /dbe/modcode_sale,
*             motext  TYPE string,
*           END OF ty_model.
*
*    TYPES:BEGIN OF ty_konv,
*            knumv TYPE konv-knumv,
*            kposn TYPE konv-kposn,
*            kschl TYPE konv-kschl,
*            kdatu TYPE konv-kdatu,
*            kawrt TYPE konv-kawrt,
*            kbetr TYPE konv-kbetr,
*            waers TYPE konv-waers,
*            kwert TYPE konv-kwert,
*          END OF ty_konv.
*
*    DATA: lt_model TYPE TABLE OF ty_model,
*          ls_model LIKE LINE OF lt_model.
*
*    DATA : lt_material_desc TYPE tt_material_desc,
*           ls_material_desc LIKE LINE OF lt_material_desc,
*           ls_spell         TYPE spell.
*
*    FIELD-SYMBOLS : <fs_mat_desc> TYPE ty_body.
*
*    DATA: lt_items TYPE tt_body.
*
*    DATA: lt_discount TYPE TABLE OF ydbmc_jet_slcond,
*          lt_konv     TYPE TABLE OF ty_konv.
*
*    DATA ls_konv LIKE LINE OF lt_konv.
*    DATA lv_knumv TYPE knumv.
*
*    DATA: lv_disc TYPE konv-kwert.
*    DATA: lv_cur TYPE string.
*    DATA: lv_percentage TYPE p DECIMALS 2.
*    DATA: lv_amount TYPE kwert.
*    DATA: lv_kwert TYPE kwert.
*
*    SELECT SINGLE h_knumv FROM /dbe/vbak_db INTO lv_knumv WHERE vbeln = iv_order_no.
*
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
*      /dbe/vbap~aufart
*      /dbe/vbap~itcat
*    FROM /dbe/vbap
*    INTO TABLE lt_items
*    WHERE /dbe/vbap~vbeln = iv_order_no
*      AND pstyv <> 'G2TX'.
**      AND itcanc <> abap_true.
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
**        makt~spras = 'EN'."yif_dbm_jet_constants=>gc_lang_en'. "#EC CI_NO_TRANSFORM
**        makt~spras = sy-langu.                      "#EC CI_NO_TRANSFORM
*
*        SELECT * FROM makt
*          INTO TABLE @DATA(lt_makt)
*          FOR ALL ENTRIES IN @lt_items
*          WHERE matnr = @lt_items-product_number.
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
**              AND spras = 'EN'. "yif_dbm_jet_constants=>gc_lang_en.
**              AND spras = sy-langu.
*
*      ENDIF.
*
*      FIELD-SYMBOLS: <fs_item> LIKE LINE OF et_items.
*      DATA: ls_item LIKE LINE OF lt_items,
*            ls_veh  TYPE ty_vehicle.
*
*      LOOP AT lt_items INTO ls_item.
*        CLEAR: ls_veh.
*        IF ls_item-itcat = 'P030' OR ls_item-itcat = 'P031'.
*          READ TABLE lt_makt INTO DATA(ls_makt) WITH KEY matnr = ls_item-product_number spras = 'E'.
*          IF sy-subrc = 0.
*            ls_item-desc = ls_makt-maktx.
*            READ TABLE lt_makt INTO ls_makt WITH KEY matnr = ls_item-product_number spras = 'A'.
*            IF sy-subrc = 0.
*              CONCATENATE ls_item-desc ls_makt-maktx INTO ls_item-desc SEPARATED BY space.
*            ENDIF.
*          ENDIF.
*          APPEND ls_item TO et_items ASSIGNING <fs_item>.
*        ELSE.
*          READ TABLE et_items ASSIGNING <fs_item> WITH KEY posnr = ls_item-main_item.
*          IF sy-subrc <> 0.
*            CLEAR ls_material_desc.
*            READ TABLE lt_model INTO ls_model WITH KEY mcodesd =  ls_item-mcodesd.
*            IF sy-subrc = 0.
*              ls_item-desc = ls_model-motext.
*              READ TABLE lt_material_desc INTO ls_material_desc WITH KEY product_number = ls_item-product_number.
*              IF sy-subrc = 0.
*                ls_item-bismt = ls_material_desc-bismt.
*              ENDIF.
*            ELSE.
*              READ TABLE lt_material_desc INTO ls_material_desc WITH KEY product_number = ls_item-product_number.
*              IF sy-subrc = 0.
*                ls_item-desc = ls_material_desc-desc.
*                ls_item-bismt = ls_material_desc-bismt.
*              ENDIF.
*            ENDIF.
*
*            ls_veh-product_code = ls_item-product_number.
*            READ TABLE lt_vehicle INTO ls_vehicle WITH KEY vhcle = ls_item-vehicle.
*            IF sy-subrc = 0.
*              ls_veh-chassis = ls_vehicle-vhvin.
*              ls_item-chassis = ls_vehicle-vhvin.
*              ls_veh-commission = ls_vehicle-vhcex.
*              ls_item-commission = ls_vehicle-vhcex.
*            ENDIF.
*            APPEND ls_veh TO et_vehicle.
*
*            SHIFT ls_item-product_number LEFT DELETING LEADING '0'.
*            SHIFT ls_item-bismt LEFT DELETING LEADING '0'.
*
*            APPEND ls_item TO et_items ASSIGNING <fs_item>.
*          ENDIF.
*        ENDIF.
*
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_item-posnr kschl = 'QSBP'."DBM Gross Price
*        IF sy-subrc = 0.
**          <fs_item>-ext_price  = <fs_item>-ext_price + ls_konv-kwert.
**          <fs_item>-unit_price = <fs_item>-unit_price +  ls_konv-kbetr.
*          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*            EXPORTING
**             CLIENT           = SY-MANDT
*              date             = ls_konv-kdatu
*              foreign_amount   = ls_konv-kbetr
*              foreign_currency = ls_konv-waers
*              local_currency   = 'SAR'
*            IMPORTING
*              local_amount     = lv_cur.
*          <fs_item>-unit_price = <fs_item>-unit_price + lv_cur.
*          <fs_item>-ext_price = <fs_item>-ext_price + lv_cur * ls_item-qty.
*          es_footer-net_price = es_footer-net_price + lv_cur * ls_item-qty.
*        ELSE.
*          READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_item-posnr kschl = 'QSML'."DBM Manual Price
*          IF sy-subrc = 0.
*            CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*              EXPORTING
**               CLIENT           = SY-MANDT
*                date             = ls_konv-kdatu
*                foreign_amount   = ls_konv-kbetr
*                foreign_currency = ls_konv-waers
*                local_currency   = 'SAR'
*              IMPORTING
*                local_amount     = lv_cur.
*            <fs_item>-unit_price = <fs_item>-unit_price + lv_cur.
*            <fs_item>-ext_price = <fs_item>-ext_price + lv_cur * ls_item-qty.
*            es_footer-net_price = es_footer-net_price + lv_cur * ls_item-qty.
*          ENDIF.
*        ENDIF.
*
*        LOOP AT lt_konv INTO ls_konv WHERE kposn = ls_item-posnr AND kschl IN lt_disc_type.
*          <fs_item>-discount = <fs_item>-discount - ls_konv-kwert.
*          es_footer-discount = es_footer-discount - ls_konv-kwert.
*        ENDLOOP.
*        <fs_item>-disc_percent = ( <fs_item>-discount * 100 ) / <fs_item>-ext_price .
*
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_item-posnr kschl = 'MWST'."Tax
*        IF sy-subrc = 0.
*          <fs_item>-vat = <fs_item>-vat + ls_konv-kwert.
**          <fs_item>-ext_price    = <fs_item>-ext_price + ls_konv-kwert.
*          es_footer-vat = es_footer-vat + ls_konv-kwert.
*          <fs_item>-vat_rate =  ls_konv-kbetr / 10.  "for vat percentage
*          CONDENSE <fs_item>-vat_rate .
*          <fs_item>-vat_rate = | { <fs_item>-vat_rate } { '%' }|.
*
**          es_footer-net_price = es_footer-net_price + ls_konv-kwert.
*        ENDIF.
*
*        <fs_item>-taxable_amt = <fs_item>-ext_price - <fs_item>-discount.
*        es_footer-taxable_amt  = es_footer-taxable_amt + <fs_item>-taxable_amt.
*        <fs_item>-total_inc_vat = <fs_item>-taxable_amt + <fs_item>-vat.
*
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_item-posnr kschl = 'YJRC'."Registration number
*        IF sy-subrc = 0.
*          es_footer-regist_amt = es_footer-regist_amt + ls_konv-kwert.
*        ENDIF.
*
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_item-posnr kschl = 'QDIF'."Invoice Gross Total (inclusive of VAT)
*        IF sy-subrc = 0.
*          es_footer-tot_inv_grs_amt =  ls_konv-kwert.
*        ENDIF.
*        "Sale type
*        IF ls_item-aufart = 'ZJOR' OR ls_item-aufart = 'ZJRR' OR ls_item-aufart = 'ZJSR'.
*          es_footer-veh_dep  = 'New'.
*
*        ELSEIF ls_item-aufart = 'ZJFO' OR ls_item-aufart = 'ZJFR'.
*          es_footer-veh_dep  = 'Fleet'.
*        ELSEIF ls_item-aufart = 'ZJUO' OR ls_item-aufart = 'ZJUR' OR ls_item-aufart = 'ZJPO'.
*          es_footer-veh_dep  = 'Used'.
*        ENDIF.
**        "Title
**        IF ls_item-aufart = 'ZJOR' OR ls_item-aufart = 'ZJFO' OR ls_item-aufart = 'ZJUO'.
**          es_footer-title_eng = 'Tax Invoice'.
**          es_footer-title_ar = 'فاتورة ضريبية'.
**
**        ELSEIF ls_item-aufart = 'ZJFR' OR ls_item-aufart = 'ZJRR' OR ls_item-aufart = 'ZJSR' OR ls_item-aufart = 'ZJUR'..
**          es_footer-title_eng = 'Return Tax Invoice'.
**          es_footer-title_ar = 'فاتورة مرتجع ضريبية'.
**        ENDIF.
*
*        lv_kwert = <fs_item>-taxable_amt.
*        <fs_item>-taxable_amt =  lv_kwert.
*        lv_kwert =  <fs_item>-discount.
*        <fs_item>-discount =  lv_kwert.
*        lv_kwert =  <fs_item>-total_inc_vat.
*        <fs_item>-total_inc_vat =  lv_kwert.
*      ENDLOOP.
*
*
*    ENDIF.
*
*    "Calculate Gross Amount
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
**    IF <fs_item> IS ASSIGNED.
**      <fs_item>-taxable_amt = es_footer-net_price - es_footer-discount.   "taxable amount
**      <fs_item>-disc_percent = es_footer-disc_percent.                    "
**      <fs_item>-discount = es_footer-discount.
**      <fs_item>-total_inc_vat =  <fs_item>-taxable_amt +  <fs_item>-vat.  "total inclusive vat
**    ENDIF.
*
*    es_footer-tot_inv_grs_amt = es_footer-taxable_amt + es_footer-regist_amt.
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
*    lv_kwert =   es_footer-tot_inv_grs_amt.
*    es_footer-tot_inv_grs_amt =  lv_kwert.
*    lv_kwert =    es_footer-taxable_amt.
*    es_footer-taxable_amt =  lv_kwert.
*
*    " price in words
*    lv_kwert = es_footer-final_amt.
*    CALL FUNCTION 'SPELL_AMOUNT'
*      EXPORTING
*        amount   = lv_kwert
*        currency = lc_currency
*        language = iv_langu
*      IMPORTING
*        in_words = ls_spell.
*    es_footer-final_amt = lv_kwert.
*    es_footer-netpr_in_words = ls_spell-word.
*
*    IF iv_langu = yif_dbm_jet_constants=>gc_lang_ar.
*      lv_amount = es_footer-disc_percent.
*      lv_amount = es_footer-discount.
*      lv_amount = es_footer-gross_amount.
*      lv_amount = es_footer-vat.
*      lv_amount = es_footer-net_price.
*
*      TRANSLATE es_footer-disc_percent USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
*      TRANSLATE es_footer-discount USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
*      TRANSLATE es_footer-gross_amount USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
*      TRANSLATE es_footer-vat USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
*      TRANSLATE es_footer-net_price USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
*      TRANSLATE es_footer-regist_amt USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
*      TRANSLATE es_footer-final_amt USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
*    ENDIF.

*    et_items = lt_items.

  ENDMETHOD.


  METHOD item_new.
    CONSTANTS : lc_currency LIKE sy-waers VALUE 'SAR'.

    TYPES:BEGIN OF ty_konv,
            knumv TYPE konv-knumv,
            kposn TYPE konv-kposn,
            kschl TYPE konv-kschl,
            kdatu TYPE konv-kdatu,
            kbetr TYPE konv-kbetr,
            waers TYPE konv-waers,
            kwert TYPE konv-kwert,
          END OF ty_konv.

    DATA: lt_disc_type TYPE RANGE OF ydbmc_jet_slcond-cond_type,
          ls_disc_type LIKE LINE OF lt_disc_type.
    DATA: lt_konv     TYPE TABLE OF ty_konv.
    DATA: ls_konv LIKE LINE OF lt_konv.
    DATA: lv_knumv TYPE knumv.
    DATA: lv_disc TYPE konv-kwert.
    DATA: lv_cur TYPE string.
    DATA: lv_percentage TYPE p DECIMALS 2.
    DATA: lv_amount TYPE kwert.
    DATA: lv_kwert TYPE kwert.
    DATA: ls_spell TYPE spell.

    SELECT cond_type AS low FROM ydbmc_jet_slcond INTO CORRESPONDING FIELDS OF TABLE lt_disc_type WHERE act_type = '02'.
    IF sy-subrc = 0.
      ls_disc_type-sign = 'I'.
      ls_disc_type-option = 'EQ'.
      MODIFY lt_disc_type FROM ls_disc_type TRANSPORTING sign option WHERE low <> space.
    ENDIF.

    SELECT SINGLE vbeln, knumv FROM vbrk
      INTO @DATA(ls_vbrk)
      WHERE vbeln = @iv_invoice.
    IF sy-subrc = 0.
      SELECT
        knumv
        kposn
        kschl
        kdatu
        kbetr
        waers
        kwert
        FROM konv INTO TABLE lt_konv
        WHERE knumv = ls_vbrk-knumv AND kinak = ''.
    ENDIF.

    SELECT vbeln, posnr, fkimg, matnr, arktx, charg, matkl, /dbe/vbeln, /dbe/posnr
      FROM vbrp
      INTO TABLE @DATA(lt_vbrp)
      WHERE vbeln = @iv_invoice.
    IF sy-subrc = 0 AND lt_vbrp IS NOT INITIAL.
      SELECT * FROM makt
        INTO TABLE @DATA(lt_makt)
        FOR ALL ENTRIES IN @lt_vbrp
        WHERE matnr = @lt_vbrp-matnr.
    ENDIF.
    SELECT
      vbeln    ,
      posnr    ,
      matnr18  ,
      zmeng    ,
      mcodesd  ,
      vhcle    ,
      descr1   ,
      main_item,
      itcat
      FROM /dbe/vbap
      INTO TABLE @DATA(lt_vbap)
      WHERE /dbe/vbap~vbeln = @iv_order_no
        AND itcanc  = ''.
    IF sy-subrc = 0 AND lt_vbap IS NOT INITIAL.
      SELECT
        /dbe/v_model~mcodesd,
        /dbe/v_modelt~motext1
        FROM /dbe/v_model
        INNER JOIN /dbe/v_modelt
        ON /dbe/v_model~model_guid = /dbe/v_modelt~model_guid
        INTO TABLE @DATA(lt_model) FOR ALL ENTRIES IN @lt_vbap
        WHERE mcodesd = @lt_vbap-mcodesd
            AND spras = @yif_dbm_jet_constants=>gc_lang_en.

      DATA: lt_vbap_tmp LIKE lt_vbap.
      lt_vbap_tmp = lt_vbap.
      DELETE lt_vbap_tmp WHERE vhcle IS INITIAL.
      SORT lt_vbap_tmp BY vhcle.
      DELETE ADJACENT DUPLICATES FROM lt_vbap_tmp COMPARING vhcle.
      IF lt_vbap_tmp IS NOT INITIAL.
        SELECT * FROM vlcvehicle INTO TABLE @DATA(lt_vehicle)
          FOR ALL ENTRIES IN @lt_vbap_tmp WHERE vhcle = @lt_vbap_tmp-vhcle.
      ENDIF.
    ENDIF.

    DATA: ls_item TYPE ty_body,
          ls_veh  TYPE ty_vehicle.
    FIELD-SYMBOLS: <fs_item> TYPE ty_body.
    LOOP AT lt_vbrp INTO DATA(ls_vbrp).
      CLEAR: ls_item, ls_veh.
      ls_item-posnr = ls_vbrp-posnr.
      ls_item-product_number = ls_vbrp-matnr.
      ls_item-qty = ls_vbrp-fkimg.

      READ TABLE lt_vbap INTO DATA(ls_vbap) WITH KEY posnr = ls_vbrp-posnr.
      IF sy-subrc = 0.
        ls_item-main_item = ls_vbap-main_item.
        IF ls_vbap-main_item IS INITIAL.
          ls_item-mcodesd = ls_vbap-mcodesd.
          ls_item-vehicle = ls_vbap-vhcle.

          ls_veh-product_code = ls_vbrp-matnr.
          READ TABLE lt_vehicle INTO DATA(ls_vehicle) WITH KEY vhcle = ls_vbap-vhcle.
          IF sy-subrc = 0.
            ls_veh-commission = ls_vehicle-vhcex.
            ls_veh-chassis = ls_vehicle-vhvin.
          ENDIF.
          APPEND ls_veh TO et_vehicle.
          READ TABLE lt_model INTO DATA(ls_model) WITH KEY mcodesd = ls_vbap-mcodesd.
          IF sy-subrc = 0.
            ls_item-desc = ls_model-motext1.
          ELSE.
            READ TABLE lt_makt INTO DATA(ls_makt) WITH KEY matnr = ls_vbrp-matnr spras = 'E'.
            IF sy-subrc = 0.
              ls_item-desc = ls_makt-maktx.
              READ TABLE lt_makt INTO ls_makt WITH KEY matnr = ls_vbrp-matnr spras = 'A'.
              IF sy-subrc = 0.
                CONCATENATE ls_item-desc ls_makt-maktx INTO ls_item-desc SEPARATED BY space.
              ENDIF.
            ENDIF.
          ENDIF.
          APPEND ls_item TO et_items ASSIGNING <fs_item>.
        ELSEIF ls_vbap-itcat = 'P030' OR ls_vbap-itcat = 'P031'.
          READ TABLE lt_makt INTO ls_makt WITH KEY matnr = ls_vbrp-matnr spras = 'E'.
          IF sy-subrc = 0.
            ls_item-desc = ls_makt-maktx.
            READ TABLE lt_makt INTO ls_makt WITH KEY matnr = ls_vbrp-matnr spras = 'A'.
            IF sy-subrc = 0.
              CONCATENATE ls_item-desc ls_makt-maktx INTO ls_item-desc SEPARATED BY space.
            ENDIF.
          ENDIF.
          APPEND ls_item TO et_items ASSIGNING <fs_item>.
        ELSE.
          READ TABLE et_items ASSIGNING <fs_item> WITH KEY posnr = ls_vbap-main_item.
        ENDIF.
      ENDIF.

      READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_vbrp-posnr kschl = 'QSBP'."DBM Gross Price
      IF sy-subrc = 0.
*          <fs_item>-ext_price  = <fs_item>-ext_price + ls_konv-kwert.
*          <fs_item>-unit_price = <fs_item>-unit_price +  ls_konv-kbetr.
        CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
          EXPORTING
*           CLIENT           = SY-MANDT
            date             = ls_konv-kdatu
            foreign_amount   = ls_konv-kbetr
            foreign_currency = ls_konv-waers
            local_currency   = 'SAR'
          IMPORTING
            local_amount     = lv_cur.
        <fs_item>-unit_price = <fs_item>-unit_price + lv_cur.
        <fs_item>-ext_price = <fs_item>-ext_price + lv_cur * ls_item-qty.
        es_footer-net_price = es_footer-net_price + lv_cur * ls_item-qty.
      ELSE.
        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_vbrp-posnr kschl = 'QSML'."DBM Manual Price
        IF sy-subrc = 0.
          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
            EXPORTING
*             CLIENT           = SY-MANDT
              date             = ls_konv-kdatu
              foreign_amount   = ls_konv-kbetr
              foreign_currency = ls_konv-waers
              local_currency   = 'SAR'
            IMPORTING
              local_amount     = lv_cur.
          <fs_item>-unit_price = <fs_item>-unit_price + lv_cur.
          <fs_item>-ext_price = <fs_item>-ext_price + lv_cur * ls_item-qty.
          es_footer-net_price = es_footer-net_price + lv_cur * ls_item-qty.
        ENDIF.
      ENDIF.

      LOOP AT lt_konv INTO ls_konv WHERE kposn = ls_vbrp-posnr AND kschl IN lt_disc_type.
        <fs_item>-discount = <fs_item>-discount - ls_konv-kwert.
        es_footer-discount = es_footer-discount - ls_konv-kwert.
      ENDLOOP.
      <fs_item>-disc_percent = ( <fs_item>-discount * 100 ) / <fs_item>-ext_price .

      READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_vbrp-posnr kschl = 'MWST'."Tax
      IF sy-subrc = 0.
        <fs_item>-vat = <fs_item>-vat + ls_konv-kwert.
*          <fs_item>-ext_price    = <fs_item>-ext_price + ls_konv-kwert.
        es_footer-vat = es_footer-vat + ls_konv-kwert.
        <fs_item>-vat_rate =  ls_konv-kbetr / 10.  "for vat percentage
        CONDENSE <fs_item>-vat_rate .
        <fs_item>-vat_rate = | { <fs_item>-vat_rate } { '%' }|.
      ENDIF.

      <fs_item>-taxable_amt = <fs_item>-ext_price - <fs_item>-discount.
      es_footer-taxable_amt  = es_footer-taxable_amt + <fs_item>-taxable_amt.
      <fs_item>-total_inc_vat = <fs_item>-taxable_amt + <fs_item>-vat.

      READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_vbrp-posnr kschl = 'YJRC'."Registration number
      IF sy-subrc = 0.
        es_footer-regist_amt = es_footer-regist_amt + ls_konv-kwert.
      ENDIF.

      READ TABLE lt_konv INTO ls_konv WITH KEY kposn = ls_vbrp-posnr kschl = 'QDIF'."Invoice Gross Total (inclusive of VAT)
      IF sy-subrc = 0.
        es_footer-tot_inv_grs_amt =  ls_konv-kwert.
      ENDIF.

      lv_kwert = <fs_item>-taxable_amt.
      <fs_item>-taxable_amt =  lv_kwert.
      lv_kwert =  <fs_item>-discount.
      <fs_item>-discount =  lv_kwert.
      lv_kwert =  <fs_item>-total_inc_vat.
      <fs_item>-total_inc_vat =  lv_kwert.
    ENDLOOP.
    "Calculate Gross Amount
    es_footer-gross_amount = es_footer-net_price + es_footer-vat - es_footer-discount.
    es_footer-final_amt = es_footer-net_price + es_footer-vat - es_footer-discount + es_footer-regist_amt.

    "calculate discount percentage
    IF es_footer-discount NE 0.
*    es_footer-net_price = es_footer-net_price - es_footer-discount.
      IF es_footer-gross_amount > 0.
        lv_percentage = ( es_footer-discount ) / es_footer-net_price * 100.
        es_footer-disc_percent =  lv_percentage.
      ELSE.
        es_footer-disc_percent = '0.0'.
      ENDIF.
    ENDIF.

    es_footer-tot_inv_grs_amt = es_footer-taxable_amt + es_footer-regist_amt.
    lv_kwert = es_footer-discount.
    es_footer-discount = lv_kwert.
    lv_kwert = es_footer-gross_amount.
    es_footer-gross_amount = lv_kwert.
    lv_kwert = es_footer-net_price.
    es_footer-net_price = lv_kwert.
    lv_kwert = es_footer-regist_amt.
    es_footer-regist_amt = lv_kwert.
    lv_kwert = es_footer-vat.
    es_footer-vat = lv_kwert.
    lv_kwert =   es_footer-tot_inv_grs_amt.
    es_footer-tot_inv_grs_amt =  lv_kwert.
    lv_kwert =    es_footer-taxable_amt.
    es_footer-taxable_amt =  lv_kwert.

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

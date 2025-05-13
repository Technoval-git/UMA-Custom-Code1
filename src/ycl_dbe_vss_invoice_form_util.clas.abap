CLASS ycl_dbe_vss_invoice_form_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_vbeln,
        vbeln TYPE char10,
      END OF ty_vbeln .
    TYPES:
      tt_vbeln TYPE TABLE OF ty_vbeln .
    TYPES:
      BEGIN OF ty_down_pay ,
        customer TYPE kunnr,
        amount   TYPE netwr,
      END OF ty_down_pay .
    TYPES:
      tt_down_pay TYPE TABLE OF  ty_down_pay .
    TYPES:
      BEGIN OF ty_pa0002,
        vorna TYPE pad_vorna,
        nach2 TYPE pad_nach2,
        nachn TYPE pad_nachn,
        fnamr TYPE p22j_pfnmr,
        lnamr TYPE p22j_plnmr,
      END OF ty_pa0002 .
    TYPES:
      BEGIN OF ty_t001w,
        werks TYPE werks_d,
        name1 TYPE name1,
        adrnr TYPE adrnr,
      END OF ty_t001w .
    TYPES:
      BEGIN OF ty_splhdr_db,
        aufart TYPE /dbe/aufart_s,
        augru  TYPE augru,
        kunnr  TYPE kunag,
      END OF ty_splhdr_db .
    TYPES:
      BEGIN OF ty_vbrk,
        vbeln TYPE vbeln_vf,
        fkart TYPE fkart,
        fkdat TYPE fkdat,
        erzet TYPE erzet,
        rfbsk TYPE rfbsk,
        zuonr TYPE ordnr_v,
        zlsch TYPE schzw_bseg,
        land1 TYPE lland,
        knumv TYPE knumv,
        spart TYPE spart,
        waerk TYPE waerk,
        bukrs TYPE vbrk-bukrs,
        fksto TYPE vbrk-fksto,
      END OF ty_vbrk .
    TYPES:
      BEGIN OF ty_vbap,
        vbeln      TYPE vbrp-vbeln,
        posnr      TYPE /dbe/vbap-posnr,
        matnr18    TYPE /dbe/vbap-matnr18,
        pstyv      TYPE /dbe/vbap-pstyv,
        descr1     TYPE /dbe/s_descr_1,
        zmeng      TYPE /dbe/vbap-zmeng,
        matkl      TYPE /dbe/vbap-matkl,
        netpr      TYPE kwert,
        discount   TYPE kwert,
        netwr      TYPE kwert,
        tax        TYPE kwert,
        netpay     TYPE kwert,
        unit_price TYPE kwert,
        itobjid    TYPE /dbe/vbap-itobjid,
        tax_rate   TYPE char15,
      END OF ty_vbap .
    TYPES:
      BEGIN OF ty_adrc,
        street     TYPE ad_street,
        city1      TYPE ad_city1,
        city2      TYPE ad_city2,
        post_code1 TYPE ad_pstcd1,
        post_code2 TYPE ad_pstcd2,
        tel_number TYPE ad_tlnmbr1,
      END OF ty_adrc .
    TYPES:
      BEGIN OF ty_/dbe/vbak_db,
        vbeln            TYPE /dbe/vbeln_va,
        werks            TYPE werks_d,
        mileage          TYPE vlc_pcount,
        licpl            TYPE /dbe/v_licext,
        visit_start_tst  TYPE /dbe/sch_visit_startst,
        erdat_tmstp      TYPE timestamp,
        audat            TYPE audat,
        pernr            TYPE /dbe/servcons,
        vguid            TYPE vlc_guid,
        ange_user        TYPE /dbe/ange_user,
        visit_start_date TYPE dats,
        erdat            TYPE dats,
      END OF ty_/dbe/vbak_db .
    TYPES:
      BEGIN OF ty_/dbe/vbpa,
        vbeln TYPE /dbe/vbeln_va,
        kunnr TYPE kunnr,
      END OF ty_/dbe/vbpa .
    TYPES:
      BEGIN OF ty_kna1,
        kunnr  TYPE kunag,
        name1  TYPE name1_gp,
        telf1  TYPE  telf1,
        adrnr  TYPE  ad_addrnum,
        anred  TYPE anred,
        aname1 TYPE name1_gp,
      END OF ty_kna1 .
    TYPES:
      BEGIN OF ty_bsid,
        belnr TYPE belnr_d,
        dmbtr TYPE dmbtr,
        mwsts TYPE mwsts,
      END OF ty_bsid .
    TYPES:
      BEGIN OF ty_vlcvehicle,
        vguid    TYPE /dbe/vbeln_va,
        iobjguid TYPE comt_product_guid,
        vhvin    TYPE vlc_vhvin,
        vhcle    TYPE vlc_vhcle,
      END OF ty_vlcvehicle .
    TYPES:
      BEGIN OF ty_/dbe/v_imodel,
        product_guid TYPE comt_product_guid,
        modguid      TYPE /dbe/model_guid,
        mcodesd      TYPE /dbe/modcode_sale,
        modyear      TYPE /dbe/modyear,
      END OF ty_/dbe/v_imodel .
    TYPES:
      BEGIN OF ty_/dbe/v_modelt,
        model_guid TYPE /dbe/model_guid,
        motext1    TYPE /dbe/model_guid,
      END OF ty_/dbe/v_modelt .
    TYPES:
      BEGIN OF ty_description,
        spras   TYPE spras,
        descrip TYPE char30,
      END OF ty_description .
    TYPES:
      BEGIN OF ty_makt,
        matnr TYPE matnr,
        spras TYPE spras,
        maktx TYPE maktx,
      END OF ty_makt .

    CLASS-METHODS set_header_data
      IMPORTING
        !it_billing_doc  TYPE tt_vbeln
        !iv_proforma     TYPE tdbool OPTIONAL
        !iv_langu        TYPE sy-langu DEFAULT sy-langu
      EXPORTING
        !ev_salesorderno TYPE /dbe/vbeln_va
      CHANGING
        !ct_return       TYPE bapiret2_tab
        !ct_header       TYPE yprfinv_head_vss_tt .
    CLASS-METHODS set_item_data
      IMPORTING
        !it_billing_doc      TYPE tt_vbeln
      EXPORTING
        !ev_tax_perc         TYPE string
      CHANGING
        !ct_header           TYPE yprfinv_head_vss_tt
        !ct_labor_details    TYPE yprfinv_item_vss_tt
        !ct_addition_details TYPE yprfinv_item_vss_tt
        !ct_consumab_details TYPE yprfinv_item_vss_tt
        !ct_parts_details    TYPE yprfinv_item_vss_tt .
    CLASS-METHODS display_sf
      IMPORTING
        !iv_otf              TYPE char1 DEFAULT space
        !it_header           TYPE yprfinv_head_vss_tt
        !it_labor_details    TYPE yprfinv_item_vss_tt
        !it_addition_details TYPE yprfinv_item_vss_tt
        !it_consumab_details TYPE yprfinv_item_vss_tt
        !it_parts_details    TYPE yprfinv_item_vss_tt
        !iv_print            TYPE crmt_boolean OPTIONAL
        !iv_proforma         TYPE crmt_boolean OPTIONAL
        !iv_tax_perc         TYPE string
      CHANGING
        !ct_otf              TYPE tsfotf
        !ct_return           TYPE bapiret2_tab .
    CLASS-METHODS set_item_data_pdf
      IMPORTING
        !it_billing_doc      TYPE tt_vbeln
      EXPORTING
        !ev_tax_perc         TYPE string
      CHANGING
        !ct_header           TYPE yprfinv_head_vss_tt
        !ct_labor_details    TYPE yserv_inv_item_pdf_tt
        !ct_addition_details TYPE yserv_inv_item_pdf_tt
        !ct_consumab_details TYPE yserv_inv_item_pdf_tt
        !ct_parts_details    TYPE yserv_inv_item_pdf_tt .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS: get_vbrk_invoice_details
      IMPORTING
        iv_bill_doc TYPE vbeln_va
      EXPORTING
        es_vbrk     TYPE ty_vbrk.
    CLASS-METHODS:
      get_payment_method
        IMPORTING
          iv_country_key    TYPE land1
          iv_payment_method TYPE dzlsch
        EXPORTING
          ev_text_en        TYPE char30
          ev_text_ar        TYPE char30.
    CLASS-METHODS
      get_amount_bsid
        IMPORTING
          iv_zuonr     TYPE dzuonr
        EXPORTING
          ev_amount    TYPE char15
          ev_deduct    TYPE char15
          ev_netpayble TYPE char15.
    CLASS-METHODS
      get_dbm_vbak_db_details
        IMPORTING
          iv_order_no TYPE /dbe/vbeln_va
        EXPORTING
          es_vbak_db  TYPE ty_/dbe/vbak_db.
    CLASS-METHODS
      get_location_details
        IMPORTING
          iv_plant_code TYPE werks_d
          ct_return     TYPE bapiret2_tab
        EXPORTING
          ev_locname    TYPE name1
          ev_locaddr    TYPE string
          ev_telf       TYPE ad_tlnmbr1.
    CLASS-METHODS
      get_vehicle_description
        IMPORTING
          iv_vguid          TYPE vlc_guid
        EXPORTING
          ev_vehicle_descip TYPE /dbe/modtext1
          es_vlcvehicle     TYPE ty_vlcvehicle
          ev_model_year     TYPE /dbe/modyear.
    CLASS-METHODS
      get_servadv_details
        IMPORTING
          iv_pernr     TYPE persno
        EXPORTING
          ev_paname_en TYPE char120
          ev_paname_ar TYPE char120
          ev_telno     TYPE telnr.
    CLASS-METHODS
      get_ordertype_data
        IMPORTING
          iv_order_no     TYPE /dbe/vbeln_va
        EXPORTING
          ev_ordertype_en TYPE /dbe/descr30
          ev_ordertype_ar TYPE /dbe/descr30.
    CLASS-METHODS
      get_customer_details
        IMPORTING
          iv_billing TYPE vbeln_vf
        EXPORTING
          es_kna1    TYPE ty_kna1.
    CLASS-METHODS
      get_dbm_vbap
        IMPORTING
          it_billing_doc      TYPE tt_vbeln
        EXPORTING
          ev_tax_perc         TYPE string
        CHANGING
          ct_header           TYPE yprfinv_head_vss_tt
          ct_labor_details    TYPE yprfinv_item_vss_tt
          ct_addition_details TYPE yprfinv_item_vss_tt
          ct_consumab_details TYPE yprfinv_item_vss_tt
          ct_parts_details    TYPE yprfinv_item_vss_tt.
    CLASS-METHODS
      get_dbm_vbap_pdf
        IMPORTING
          it_billing_doc      TYPE tt_vbeln
        EXPORTING
          ev_tax_perc         TYPE string
        CHANGING
          ct_header           TYPE yprfinv_head_vss_tt
          ct_labor_details    TYPE yserv_inv_item_pdf_tt
          ct_addition_details TYPE yserv_inv_item_pdf_tt
          ct_consumab_details TYPE yserv_inv_item_pdf_tt
          ct_parts_details    TYPE yserv_inv_item_pdf_tt.

ENDCLASS.



CLASS YCL_DBE_VSS_INVOICE_FORM_UTIL IMPLEMENTATION.


  METHOD display_sf.

    CONSTANTS: lv_destination_name TYPE rvari_val_255 VALUE 'Y/dbe/DESTINATION_DEVICE'.

    DATA: lc_sfname TYPE char30 VALUE
          'Y/dbe/JET_SERV_INVOICE_FORM'
*          'Y/dbe/JET_PROFORMA_INV_FORM2'
          ,
          lv_fname  TYPE char30.
    DATA: ls_header   TYPE yprfinv_head_vss_st,
          iv_division TYPE spart.
    DATA: ts_outoptions  TYPE ssfcompop,
          ts_ctrlparms   TYPE ssfctrlop,
          "Internal table to hold OTF data recd from the SMARTFORM
          it_otf_from_fm TYPE ssfcrescl,
          ts_return      LIKE LINE OF ct_return.
    "setting the SF printer settings
*  ts_outoptions-tddest = TEXT-002. "LP01 printer

*  ts_ctrlparms-langu = 'A'.
*  ts_ctrlparms-langu = 'E'.

*    ts_ctrlparms-preview = space.
*  ts_ctrlparms-no_dialog = abap_true.
    IF iv_otf = abap_true.
      ts_ctrlparms-getotf = abap_true.
    ENDIF.

    "getting the fm of the corresponding smartform
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
    ENDIF.

    "Calling the fm of the smartform
    ts_ctrlparms-langu = 'AR'.

    IF iv_print = abap_true.
      ts_ctrlparms-no_dialog  = abap_true.
      ts_ctrlparms-preview  = space.
      ts_outoptions-tdnoprev = abap_true.
      ts_outoptions-tdimmed = abap_true.

      SELECT SINGLE low FROM tvarvc
        INTO ts_outoptions-tddest
        WHERE
         name = lv_destination_name.
    ELSE.
      ts_ctrlparms-preview  = abap_true.
    ENDIF.
*--begin of addition by ismail for division
    CLEAR: iv_division,ls_header.
    READ TABLE it_header INTO ls_header INDEX 1.
    iv_division = ls_header-division.
*--End of addition by ismail for division

    ts_outoptions-tddelete = 'X'.
    CALL FUNCTION lv_fname
      EXPORTING
        control_parameters  = ts_ctrlparms
        output_options      = ts_outoptions
        user_settings       = abap_true
        it_header           = it_header
        it_item_labour      = it_labor_details
        it_item_parts       = it_parts_details
        it_item_consumab    = it_consumab_details
        it_item_addition    = it_addition_details
        iv_proforma_invoice = iv_proforma
        iv_division         = iv_division   "added by ismail
        iv_tax_perc         = iv_tax_perc
      IMPORTING
        job_output_info     = it_otf_from_fm
      EXCEPTIONS
        formatting_error    = 1
        internal_error      = 2
        send_error          = 3
        user_canceled       = 4
        OTHERS              = 5.
    IF sy-subrc <> 0.
      MESSAGE w016(ymsg_jet_dbm) INTO ts_return-message.
      ts_return-id = yif_dbm_jet_constants=>gc_msg_class_id.
      ts_return-type = yif_dbm_jet_constants=>gc_value_w.
      ts_return-number = 016.
      APPEND ts_return TO ct_return.
    ENDIF.
    "the otf data is stored
    ct_otf = it_otf_from_fm-otfdata.


  ENDMETHOD.


  METHOD get_amount_bsid.
    TYPES:BEGIN OF ty_vbrk,
            belnr TYPE vbeln_vf,
          END OF ty_vbrk.

    DATA: lt_bsid   TYPE TABLE OF ty_bsid,
          ts_bsid   TYPE ty_bsid,
          lv_netpay TYPE dmbtr,
          lt_vbrk   TYPE TABLE OF ty_vbrk.
    SELECT
      bsid_view~belnr,
      bsid_view~dmbtr,
      bsid_view~mwsts
      FROM bsid_view
      INTO TABLE @lt_bsid
      WHERE bsid_view~zuonr = @iv_zuonr.
    IF sy-subrc = 0.
      SELECT vbeln FROM vbrk INTO TABLE lt_vbrk FOR ALL ENTRIES IN lt_bsid
        WHERE vbeln = lt_bsid-belnr.

      LOOP AT lt_bsid INTO ts_bsid.
        READ TABLE lt_vbrk TRANSPORTING NO FIELDS WITH KEY belnr = ts_bsid-belnr.
        IF sy-subrc <> 0.
*    IF sy-subrc = 0.
*          ev_amount = ev_amount + ts_bsid-dmbtr.
          ev_deduct = ev_deduct + ts_bsid-mwsts.
          lv_netpay = lv_netpay + ( ts_bsid-dmbtr + ts_bsid-mwsts ).
          ev_netpayble = ev_netpayble + lv_netpay.
          CONDENSE: ev_deduct,ev_amount,ev_netpayble.
*    ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_customer_details.
    DATA: ts_/dbe/vbpa TYPE ty_/dbe/vbpa.
    "Select kunnr frin ts_/dbe/vbpa
*    SELECT SINGLE vbeln kunnr INTO
*      ts_/dbe/vbpa FROM /dbe/vbpa
*      WHERE vbeln = iv_order_no.
    SELECT SINGLE vbeln kunrg FROM vbrk
      INTO ts_/dbe/vbpa
      WHERE vbeln = iv_billing.

    IF sy-subrc = 0.
      "select ty_kna1
      SELECT SINGLE kunnr name1 telf1 adrnr anred INTO
        es_kna1 FROM kna1
        WHERE kunnr = ts_/dbe/vbpa-kunnr.
      "Selecting arabic name of the customer
      IF sy-subrc = 0.
        CONCATENATE es_kna1-anred es_kna1-name1 INTO es_kna1-name1
          SEPARATED BY space.
        SELECT SINGLE name1 AS aname1 INTO es_kna1-aname1
           FROM adrc
          WHERE nation = yif_dbm_jet_constants=>gc_value_a
          AND addrnumber = es_kna1-adrnr.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_dbm_vbak_db_details.
    "Fillling the details from table /dbe/VBAK_DB passing VBELN
    SELECT SINGLE vbeln werks mileage licpl visit_start_tst erdat_tmstp
      audat pernr vguid ange_user INTO  es_vbak_db
      FROM /dbe/vbak_db WHERE vbeln = iv_order_no.

    IF sy-subrc = 0.
      IF es_vbak_db-visit_start_tst IS NOT INITIAL.
        CALL FUNCTION 'ABI_TIMESTAMP_CONVERT_FROM'
          EXPORTING
            iv_timestamp     = es_vbak_db-visit_start_tst
          IMPORTING
            o_date           = es_vbak_db-visit_start_date
          EXCEPTIONS
            conversion_error = 1
            OTHERS           = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
      ENDIF.
      IF es_vbak_db-erdat_tmstp IS NOT INITIAL.
        CALL FUNCTION 'ABI_TIMESTAMP_CONVERT_FROM'
          EXPORTING
            iv_timestamp     = es_vbak_db-erdat_tmstp
          IMPORTING
            o_date           = es_vbak_db-erdat
          EXCEPTIONS
            conversion_error = 1
            OTHERS           = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_dbm_vbap.
    TYPES: BEGIN OF ty_konv,
             knumv TYPE knumv,
             kposn TYPE kposn,
             kschl TYPE kscha,
             kbetr TYPE kbetr,
             kwert TYPE kwert,
           END OF ty_konv.

*    TYPES: BEGIN OF ty_items,
*             vbeln   TYPE vbrp-vbeln,
*             posnr   TYPE /dbe/vbap-posnr,
*             matnr18 TYPE /dbe/vbap-matnr18,
*             pstyv   TYPE /dbe/vbap-pstyv,
*             arktx   TYPE /dbe/vbap-arktx,
*             zmeng   TYPE /dbe/vbap-zmeng,
*             matkl   TYPE /dbe/vbap-matkl,
*           END OF ty_items.

    "Data declartion
    DATA: lt_items_temp TYPE TABLE OF ty_vbap,
          ls_items_temp LIKE LINE OF lt_items_temp,
          it_makt       TYPE TABLE OF ty_makt,
          ts_makt       LIKE LINE OF it_makt,
          ts_details    TYPE yprfinv_item_vss_st.

    DATA: lv_labour        TYPE int4 VALUE 0,
          lv_parts         TYPE int4 VALUE 0,
          lv_consum        TYPE int4 VALUE 0,
          lv_addit         TYPE int4 VALUE 0,
          lv_gross_labor   TYPE netwr_ap VALUE '0.00',
          lv_gross_parts   TYPE netwr_ap VALUE 0,
          lv_gross_oil     TYPE netwr_ap VALUE 0,
          lv_gross_paint   TYPE netwr_ap VALUE 0,
          lv_gross_sublet  TYPE netwr_ap VALUE 0,
          lv_gross_brgout  TYPE netwr_ap VALUE 0,
          lv_gross_addserv TYPE netwr_ap VALUE 0,
          lv_gross_consumb TYPE netwr_ap VALUE 0,
          lv_gross_labor2  TYPE netwr_ap VALUE 0,
          lv_disc_labor2   TYPE netwr_ap VALUE 0,
          lv_net_labor2    TYPE netwr_ap VALUE 0,
          lv_gross_part2   TYPE netwr_ap VALUE 0,
          lv_disc_part2    TYPE netwr_ap VALUE 0,
          lv_net_part2     TYPE netwr_ap VALUE 0,
          lv_gross_consm2  TYPE netwr_ap VALUE 0,
          lv_disc_consm2   TYPE netwr_ap VALUE 0,
          lv_net_consm2    TYPE netwr_ap VALUE 0,
          lv_gross_addtn2  TYPE netwr_ap VALUE 0,
          lv_disc_addtn2   TYPE netwr_ap VALUE 0,
          lv_net_addtn2    TYPE netwr_ap VALUE 0,
          lt_konv          TYPE TABLE OF ty_konv,
          ls_konv          TYPE ty_konv,
          ls_billin_doc    LIKE LINE OF it_billing_doc.

    DATA: it_material_category TYPE TABLE OF ydbmc_prfinv_cat,
          ts_material_category LIKE LINE OF  it_material_category,
          lt_header_temp       TYPE yprfinv_head_vss_tt.

    FIELD-SYMBOLS: <fs_item> TYPE ty_vbap.

    CONSTANTS: lc_labour     TYPE char20 VALUE 'LABOUR',
               lc_parts      TYPE char20 VALUE 'PART',
               lc_consumable TYPE char20 VALUE 'CONSUMABLE',
               lc_additional TYPE char20 VALUE 'ADDITIONAL'.

    CONSTANTS: lc_gross_labour     TYPE char20 VALUE 'LABOUR',
               lc_gross_parts      TYPE char20 VALUE 'PART',
               lc_gross_oil        TYPE char20 VALUE 'OIL',
               lc_baught_out       TYPE char20 VALUE 'PAINT',
               lc_paint            TYPE char20 VALUE 'BOUGHT',
               lc_gross_sublet     TYPE char20 VALUE 'SUBLET',
               lc_gross_consumable TYPE char20 VALUE 'CONSUMABLE',
               lc_gross_additional TYPE char20 VALUE 'ADDITIONAL'.

*    DATA: lt_bseg TYPE TABLE OF bseg.

    FIELD-SYMBOLS <fs_header> LIKE LINE OF ct_header.

    TYPES: BEGIN OF ty_down_pay,
             bukrs TYPE  /dbe/t_op_line-bukrs,
             vbeln TYPE  /dbe/t_op_line-vbeln,
             oppos TYPE  /dbe/t_op_line-oppos,
             zuonr TYPE  /dbe/t_op_line-zuonr,
             kunnr TYPE  /dbe/t_op_line-kunnr,
             dmbtr TYPE  /dbe/t_op_line-dmbtr,
           END OF ty_down_pay.

    DATA: lt_down_pay      TYPE TABLE OF ty_down_pay,
          lt_down_pay_temp TYPE TABLE OF ty_down_pay,
          ls_down_pay      TYPE ty_down_pay,
          ls_down_pay_temp TYPE ty_down_pay.

    DATA: lt_items  TYPE TABLE OF ty_vbap.
    TYPES:BEGIN OF ty_descr,
            vbeln   TYPE /dbe/vbap-vbeln,
            posnr   TYPE /dbe/vbap-posnr,
            zmeng   TYPE /dbe/vbap-zmeng,
            descr1  TYPE /dbe/vbap-descr1,
            matkl   TYPE /dbe/vbap-matkl,
            pstyv   TYPE /dbe/vbap-pstyv,
            itobjid TYPE /dbe/vbap-itobjid,
          END OF ty_descr.
    DATA: lt_desr   TYPE TABLE OF ty_descr,
          ls_desr   TYPE ty_descr,
          ls_header TYPE yprfinv_head_vss_st,
          lw_tvkwz  TYPE tvkwz,       "CR 8100003994
          lv_kalks  TYPE knvv-kalks.  "CR 8100003994

    FIELD-SYMBOLS: <fs_down_pay> TYPE ty_down_pay,
                   <fs_items>    LIKE LINE OF lt_items.

*    READ TABLE ct_header INTO ls_header INDEX 1.
    IF ct_header IS NOT INITIAL.
      SELECT bukrs vbeln oppos zuonr kunnr dmbtr
        FROM /dbe/t_op_line
        INTO TABLE lt_down_pay_temp
         FOR ALL ENTRIES IN ct_header
       WHERE umskz = 'A'
         AND zuonr = ct_header-zuonr.
      IF sy-subrc = 0.
        LOOP AT lt_down_pay_temp INTO ls_down_pay_temp.
          READ TABLE lt_down_pay ASSIGNING <fs_down_pay> WITH KEY zuonr = ls_down_pay_temp-zuonr.
          IF sy-subrc = 0.
            <fs_down_pay>-dmbtr = <fs_down_pay>-dmbtr + ls_down_pay_temp-dmbtr.
          ELSE.
            ls_down_pay = ls_down_pay_temp.
            INSERT ls_down_pay INTO TABLE lt_down_pay.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    SELECT knumv kposn kschl kbetr kwert
      FROM konv
      INTO TABLE lt_konv
       FOR ALL ENTRIES IN ct_header
     WHERE knumv = ct_header-knumv
       AND kinak = ''.

*    lt_header_temp = ct_header.
*    SORT lt_header_temp BY zuonr.
*    DELETE ADJACENT DUPLICATES FROM lt_header_temp COMPARING zuonr.
*    DELETE lt_header_temp WHERE zuonr IS INITIAL.
*    IF lt_header_temp IS NOT INITIAL.
*      SELECT * FROM bseg INTO TABLE lt_bseg
*        FOR ALL ENTRIES IN lt_header_temp
*        WHERE zuonr = lt_header_temp-zuonr.
*    ENDIF.
*    SELECT
*      vbrp~vbeln
*      /dbe/vbap~posnr
*      /dbe/vbap~matnr18
*      /dbe/vbap~pstyv
*      /dbe/vbap~descr1
*      /dbe/vbap~zmeng
*      /dbe/vbap~matkl
*      FROM /dbe/vbap
*      JOIN vbrp
*      ON vbrp~posnr = /dbe/vbap~posnr
*      INTO TABLE lt_items
*      FOR ALL ENTRIES IN ct_header
*      WHERE /dbe/vbap~vbeln = ct_header-serv_ord_num
*        AND vbrp~vbeln = ct_header-invoice_no.
*    SELECT
*    vbrp~vbeln
*    vbrp~posnr
*    vbrp~matnr
*    vbrp~pstyv
*    /dbe/vbap~descr1
*    /dbe/vbap~zmeng
*    vbrp~matkl
*      FROM vbrp
*      JOIN /dbe/vbap
*      ON vbrp~posnr = /dbe/vbap~posnr
*      INTO TABLE lt_items
*      FOR ALL ENTRIES IN ct_header
*      WHERE vbrp~vbeln = ct_header-invoice_no
*      AND /dbe/vbap~vbeln = ct_header-serv_ord_num.

    SELECT vbeln posnr matnr
      FROM vbrp
      INTO TABLE lt_items
       FOR ALL ENTRIES IN ct_header
     WHERE vbeln = ct_header-invoice_no.
    IF sy-subrc = 0.
      SELECT vbeln posnr zmeng descr1 matkl pstyv itobjid
        FROM /dbe/vbap
        INTO TABLE lt_desr
         FOR ALL ENTRIES IN ct_header
       WHERE vbeln = ct_header-serv_ord_num.

*     Getting all the material description
      SELECT makt~matnr makt~spras makt~maktx
        INTO TABLE it_makt
        FROM makt
         FOR ALL ENTRIES IN lt_items               "#EC CI_NO_TRANSFORM
       WHERE makt~matnr = lt_items-matnr18
         AND ( makt~spras = yif_dbm_jet_constants=>gc_value_e OR
               makt~spras = yif_dbm_jet_constants=>gc_value_a ).

      SELECT *
        FROM ydbmc_prfinv_cat
        INTO TABLE it_material_category
         FOR ALL ENTRIES IN lt_desr    "Item list
       WHERE pstyv = lt_desr-pstyv. "Material Group
    ENDIF.

    LOOP AT lt_items ASSIGNING <fs_items>.
      READ TABLE lt_desr INTO ls_desr WITH KEY  posnr = <fs_items>-posnr.
      IF sy-subrc = 0.
        <fs_items>-zmeng = ls_desr-zmeng.
        <fs_items>-descr1 = ls_desr-descr1.
        <fs_items>-matkl = ls_desr-matkl.
        <fs_items>-pstyv = ls_desr-pstyv.
        <fs_items>-itobjid = ls_desr-itobjid.
      ENDIF.
    ENDLOOP.

    DATA: lt_inv_cond TYPE TABLE OF ydbmc_srinv_cond,
          ls_inv_cond TYPE ydbmc_srinv_cond.

    SELECT *
      FROM ydbmc_srinv_cond
      INTO TABLE lt_inv_cond.
    LOOP AT ct_header ASSIGNING <fs_header>.
      "Begin CR 8000003994 - Issue: invoice for Juffali family printed with zero value
      SELECT SINGLE * FROM tvkwz INTO lw_tvkwz
       WHERE werks = <fs_header>-plant.
      IF sy-subrc = 0.
        SELECT SINGLE kalks FROM knvv INTO lv_kalks
         WHERE kunnr = <fs_header>-cust_id
           AND vkorg = lw_tvkwz-vkorg
           AND vtweg = lw_tvkwz-vtweg.
      ENDIF.
      "End CR 8000003994
      lt_items_temp = lt_items.
      LOOP AT lt_items_temp ASSIGNING <fs_item> WHERE vbeln = <fs_header>-invoice_no.
        LOOP AT lt_inv_cond INTO ls_inv_cond WHERE kalks = lv_kalks AND type = 'UNIT_PRICE'.  "CR 8100003994
          READ TABLE lt_konv
          INTO ls_konv
          WITH KEY kposn = <fs_item>-posnr
                   kschl = ls_inv_cond-cond_type
                   knumv = <fs_header>-knumv.
          IF sy-subrc = 0.
            <fs_item>-netpr = <fs_item>-netpr + ls_konv-kwert.
            IF <fs_item>-zmeng <> 0.
              <fs_item>-unit_price = <fs_item>-unit_price + ( ls_konv-kwert / <fs_item>-zmeng ).
            ENDIF.
          ENDIF.
        ENDLOOP.

*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'QSBP' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-netpr = <fs_item>-netpr + ls_konv-kwert.
*        ENDIF.

        LOOP AT lt_inv_cond INTO ls_inv_cond WHERE kalks = lv_kalks AND type = 'DISCOUNT'.  "CR 8100003994
          READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr
                                                   kschl = ls_inv_cond-cond_type
                                                   knumv = <fs_header>-knumv.
          IF sy-subrc = 0.
            <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
*            <fs_item>-disc_per = <fs_item>-disc_per + ls_konv-kbetr.
          ENDIF.
        ENDLOOP.

*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'YRPO' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
*        ENDIF.
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'QRTK' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
*        ENDIF.
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'QRAK' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
*        ENDIF.
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'KUMU' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
        <fs_item>-netwr = <fs_item>-netpr + <fs_item>-discount.
*        ENDIF.

        LOOP AT lt_inv_cond INTO ls_inv_cond WHERE kalks = lv_kalks AND type = 'TAX'. "CR 8100003994
          READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr
                                                   kschl = ls_inv_cond-cond_type
                                                   knumv = <fs_header>-knumv.
          IF sy-subrc = 0.
            <fs_item>-tax = <fs_item>-tax + ls_konv-kwert.
            IF ev_tax_perc IS INITIAL OR ev_tax_perc = '0'.
              ev_tax_perc = ls_konv-kbetr / 10.
            ENDIF.
            DATA: lv_tax_rate TYPE string.
            lv_tax_rate = ls_konv-kbetr / 10.
            CONCATENATE lv_tax_rate '%' INTO <fs_item>-tax_rate SEPARATED BY space.
          ENDIF.
        ENDLOOP.
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'MWST' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-tax = <fs_item>-tax + ls_konv-kwert.
*        ENDIF.

        <fs_item>-netpay = <fs_item>-netwr + <fs_item>-tax.
      ENDLOOP.

      IF lt_items_temp IS NOT INITIAL.
        IF sy-subrc = 0.
          SORT it_makt BY matnr spras.
        ENDIF.

        LOOP AT lt_items_temp INTO ls_items_temp WHERE vbeln = <fs_header>-invoice_no.
          CLEAR ts_details.
          MOVE-CORRESPONDING ls_items_temp TO ts_details.
          ts_details-vbeln = <fs_header>-invoice_no.
          ts_details-kbetr = ls_items_temp-netpr.
          ts_details-vat_valu = ls_items_temp-tax.
          ts_details-vat_per = ls_items_temp-tax_rate.
          DATA: lv_disc_perc TYPE string.
          lv_disc_perc = ( ls_items_temp-discount / ls_items_temp-netpr ) * 100.
          CONCATENATE lv_disc_perc '%' INTO ts_details-disc_per SEPARATED BY space.
          ts_details-total = ls_items_temp-netpr.

          IF it_makt IS NOT INITIAL.
            CLEAR ts_makt.
            READ TABLE it_makt INTO ts_makt WITH KEY matnr = ls_items_temp-matnr18
                                    spras = yif_dbm_jet_constants=>gc_value_e.
            IF sy-subrc = 0.
              ts_details-descr_en = ts_makt-maktx.
            ENDIF.

            READ TABLE it_makt INTO ts_makt
            WITH KEY matnr = ls_items_temp-matnr18
                     spras = yif_dbm_jet_constants=>gc_value_a.
            IF sy-subrc = 0.
              ts_details-descr_ar = ts_makt-maktx.
            ENDIF.
            CONCATENATE ts_details-descr_en cl_abap_char_utilities=>cr_lf
                        ts_details-descr_ar INTO ts_details-descr.
          ENDIF.

          READ TABLE it_material_category INTO ts_material_category
          WITH KEY pstyv = ls_items_temp-pstyv
                   matkl = ls_items_temp-matkl.

          IF sy-subrc = 0.
            "Labour
            IF ts_material_category-group_summary = lc_gross_labour.
              lv_gross_labor = lv_gross_labor + ls_items_temp-netpr.

              "Parts
            ELSEIF ts_material_category-group_summary = lc_gross_parts.
              lv_gross_parts = lv_gross_parts + ls_items_temp-netpr.

              "Oil
            ELSEIF ts_material_category-group_summary = lc_gross_oil.
              lv_gross_oil = lv_gross_oil + ls_items_temp-netpr.

              "Paint
            ELSEIF ts_material_category-group_summary = lc_paint.
              lv_gross_paint = lv_gross_paint + ls_items_temp-netpr.

              "Bought out
            ELSEIF ts_material_category-group_summary = lc_baught_out.
              lv_gross_brgout = lv_gross_brgout + ls_items_temp-netpr.

              "Sublet
            ELSEIF ts_material_category-group_summary = lc_gross_sublet.
              lv_gross_sublet = lv_gross_sublet + ls_items_temp-netpr.

              "Consumables
            ELSEIF ts_material_category-group_summary = lc_gross_consumable.
              lv_gross_consumb = lv_gross_consumb + ls_items_temp-netpr.

              "Additional service
            ELSEIF ts_material_category-group_summary = lc_gross_additional.
              lv_gross_addserv = lv_gross_addserv + ls_items_temp-netpr.
            ENDIF.
          ELSE.
            READ TABLE it_material_category INTO ts_material_category
            WITH KEY pstyv = ls_items_temp-pstyv matkl = ''.
            IF sy-subrc = 0.
              "Labour
              IF ts_material_category-group_summary = lc_gross_labour.
                lv_gross_labor = lv_gross_labor + ls_items_temp-netpr.

                "Parts
              ELSEIF ts_material_category-group_summary = lc_gross_parts.
                lv_gross_parts = lv_gross_parts + ls_items_temp-netpr.

                "Oil
              ELSEIF ts_material_category-group_summary = lc_gross_oil.
                lv_gross_oil = lv_gross_oil + ls_items_temp-netpr.

                "Paint
              ELSEIF ts_material_category-group_summary = lc_paint.
                lv_gross_paint = lv_gross_paint + ls_items_temp-netpr.

                "Bought out
              ELSEIF ts_material_category-group_summary = lc_baught_out.
                lv_gross_brgout = lv_gross_brgout + ls_items_temp-netpr.

                "Sublet
              ELSEIF ts_material_category-group_summary = lc_gross_sublet.
                lv_gross_sublet = lv_gross_sublet + ls_items_temp-netpr.

                "Consumables
              ELSEIF ts_material_category-group_summary = lc_gross_consumable.
                lv_gross_consumb = lv_gross_consumb + ls_items_temp-netpr.

                "Additional service
              ELSEIF ts_material_category-group_summary = lc_gross_additional.
                lv_gross_addserv = lv_gross_addserv + ls_items_temp-netpr.
              ENDIF.
            ENDIF.
          ENDIF.

          READ TABLE it_material_category INTO ts_material_category
          WITH KEY pstyv = ls_items_temp-pstyv
                   matkl = ls_items_temp-matkl.
          IF sy-subrc = 0.

            MOVE-CORRESPONDING ls_items_temp TO ts_details.
            ts_details-descr_en = ls_items_temp-descr1.
            ts_details-gross_price = ls_items_temp-netwr.
            ts_details-net_price = ls_items_temp-netpay .
            CONCATENATE ts_details-descr_en cl_abap_char_utilities=>cr_lf
                        ts_details-descr_ar INTO ts_details-descr.
            IF ts_material_category-group_detail = lc_labour.
              lv_labour = lv_labour + 1.
              ts_details-srno = lv_labour.
              CONDENSE ts_details-srno.
              lv_gross_labor2 = lv_gross_labor2 + ls_items_temp-netpr.
              lv_disc_labor2 = lv_disc_labor2 + ls_items_temp-discount.
              lv_net_labor2 = lv_net_labor2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_labor_details.

            ELSEIF ts_material_category-group_detail = lc_parts.
              lv_parts = lv_labour + 1.
              ts_details-srno = lv_parts.
              CONDENSE ts_details-srno.
              lv_gross_part2 = lv_gross_part2 + ls_items_temp-netpr.
              lv_disc_part2 = lv_disc_part2 + ls_items_temp-discount.
              lv_net_part2 = lv_net_part2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_parts_details.

            ELSEIF ts_material_category-group_detail = lc_consumable.
              lv_consum = lv_consum + 1.
              ts_details-srno = lv_consum.
              CONDENSE ts_details-srno.
              lv_gross_consm2 = lv_gross_consm2 + ls_items_temp-netpr.
              lv_disc_consm2 = lv_disc_consm2 + ls_items_temp-discount.
              lv_net_consm2 = lv_net_consm2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_consumab_details.
            ELSEIF ts_material_category-group_detail = lc_additional.
              lv_addit = lv_addit + 1.
              ts_details-srno = lv_addit.
              CONDENSE ts_details-srno.
              lv_gross_addtn2 = lv_gross_addtn2 + ls_items_temp-netpr.
              lv_disc_addtn2 = lv_disc_addtn2 + ls_items_temp-discount.
              lv_net_addtn2 = lv_net_addtn2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_addition_details.
            ENDIF.
          ELSE.
            READ TABLE it_material_category INTO ts_material_category
                WITH KEY pstyv = ls_items_temp-pstyv matkl = ''.
            IF sy-subrc = 0.
              MOVE-CORRESPONDING ls_items_temp TO ts_details.
              ts_details-descr_en = ls_items_temp-descr1.
              ts_details-gross_price = ls_items_temp-netwr.
              ts_details-net_price = ls_items_temp-netpay .

              IF ts_material_category-group_summary = lc_labour.
                lv_labour = lv_labour + 1.
                ts_details-srno = lv_labour.
                CONDENSE ts_details-srno.
                lv_gross_labor2 = lv_gross_labor2 + ls_items_temp-netpr.
                lv_disc_labor2 = lv_disc_labor2 + ls_items_temp-discount.
                lv_net_labor2 = lv_net_labor2 + ls_items_temp-netwr.
                APPEND ts_details TO ct_labor_details.

              ELSEIF ts_material_category-group_summary = lc_parts.
                lv_parts = lv_labour + 1.
                ts_details-srno = lv_parts.
                CONDENSE ts_details-srno.
                lv_gross_part2 = lv_gross_part2 + ls_items_temp-netpr.
                lv_disc_part2 = lv_disc_part2 + ls_items_temp-discount.
                lv_net_part2 = lv_net_part2 + ls_items_temp-netwr.
                APPEND ts_details TO ct_parts_details.

              ELSEIF ts_material_category-group_summary = lc_consumable.
                lv_consum = lv_consum + 1.
                ts_details-srno = lv_consum.
                CONDENSE ts_details-srno.
                lv_gross_consm2 = lv_gross_consm2 + ls_items_temp-netpr.
                lv_disc_consm2 = lv_disc_consm2 + ls_items_temp-discount.
                lv_net_consm2 = lv_net_consm2 + ls_items_temp-netwr.
                APPEND ts_details TO ct_consumab_details.
              ELSE.
                lv_addit = lv_addit + 1.
                ts_details-srno = lv_addit.
                CONDENSE ts_details-srno.
                lv_gross_addtn2 = lv_gross_addtn2 + ls_items_temp-netpr.
                lv_disc_addtn2 = lv_disc_addtn2 + ls_items_temp-discount.
                lv_net_addtn2 = lv_net_addtn2 + ls_items_temp-netwr.
                APPEND ts_details TO ct_addition_details.
              ENDIF.
            ELSE.
              MOVE-CORRESPONDING ls_items_temp TO ts_details.
              ts_details-descr_en = ls_items_temp-descr1.
              ts_details-gross_price = ls_items_temp-netwr.
              ts_details-net_price = ls_items_temp-netpay .

              CLEAR ts_makt.
              READ TABLE it_makt INTO ts_makt
              WITH KEY matnr = ls_items_temp-matnr18
                       spras = yif_dbm_jet_constants=>gc_value_a.
              IF sy-subrc = 0.
                ts_details-descr_ar = ts_makt-maktx.
              ENDIF.
              CONCATENATE ts_details-descr_en cl_abap_char_utilities=>cr_lf
                          ts_details-descr_ar INTO ts_details-descr.
              lv_gross_addserv = lv_gross_addserv + ls_items_temp-netpr.
              lv_addit = lv_addit + 1.
              ts_details-srno = lv_addit.
              CONDENSE ts_details-srno.
              lv_gross_addtn2 = lv_gross_addtn2 + ls_items_temp-netpr.
              lv_disc_addtn2 = lv_disc_addtn2 + ls_items_temp-discount.
              lv_net_addtn2 = lv_net_addtn2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_addition_details.
            ENDIF.
          ENDIF.

          <fs_header>-netpr = <fs_header>-netpr + ls_items_temp-netpr.
          <fs_header>-discount = <fs_header>-discount + ls_items_temp-discount.
          <fs_header>-netwr = <fs_header>-netwr + ls_items_temp-netwr.
          <fs_header>-tax = <fs_header>-tax + ls_items_temp-tax.
          <fs_header>-net_payable = <fs_header>-net_payable + ls_items_temp-netpay.

        ENDLOOP.

        <fs_header>-gross_labour    = lv_gross_labor.   "Gross labour amount
        <fs_header>-gross_parts     = lv_gross_parts.   "Gross parts amount
        <fs_header>-oil             = lv_gross_oil.     "Oil amount
        <fs_header>-paint           = lv_gross_paint.   "Paint amount
        <fs_header>-sublet          = lv_gross_sublet.  "Sublet amount
        <fs_header>-bought_out      = lv_gross_brgout.  "Bought out amount
        <fs_header>-addition_servic = lv_gross_addserv. "Additional service amount
        <fs_header>-cconsumables    = lv_gross_consumb. "Consumables amount
        <fs_header>-gross_labor2 = lv_gross_labor2.
        <fs_header>-gross_parts2 = lv_gross_part2.
        <fs_header>-gross_consm2 = lv_gross_consm2.
        <fs_header>-gross_addtn2 = lv_gross_addtn2.
        <fs_header>-disc_labor2  = lv_disc_labor2.
        <fs_header>-disc_parts2  = lv_disc_part2.
        <fs_header>-disc_consm2  = lv_disc_consm2.
        <fs_header>-disc_addtn2  = lv_disc_addtn2.
        <fs_header>-net_labor2   = lv_net_labor2.
        <fs_header>-net_parts2   = lv_net_part2.
        <fs_header>-net_consm2   = lv_net_consm2.
        <fs_header>-net_addtn2   = lv_net_addtn2.
        <fs_header>-total   = <fs_header>-netwr + <fs_header>-tax .

        READ TABLE lt_down_pay ASSIGNING <fs_down_pay> WITH KEY zuonr = <fs_header>-zuonr.
        IF sy-subrc = 0.
          <fs_header>-deposit_amount = <fs_down_pay>-dmbtr.
*          IF <fs_header>-net_payable > <fs_down_pay>-dmbtr.
*            <fs_down_pay>-dmbtr = 0.
*          ELSE.
*            <fs_down_pay>-dmbtr = <fs_down_pay>-dmbtr - <fs_header>-net_payable.
*          ENDIF.
          <fs_header>-net_payable  = <fs_header>-net_payable - <fs_header>-deposit_amount.
        ENDIF.

        CLEAR: lv_gross_labor,
               lv_gross_parts,
               lv_gross_oil,
               lv_gross_paint,
               lv_gross_sublet,
               lv_gross_brgout,
               lv_gross_addserv,
               lv_gross_consumb,
               lv_gross_labor2,
               lv_gross_part2,
               lv_gross_consm2,
               lv_gross_addtn2,
               lv_disc_labor2,
               lv_disc_part2,
               lv_disc_consm2,
               lv_disc_addtn2,
               lv_net_labor2,
               lv_net_part2,
               lv_net_consm2,
               lv_net_addtn2.

        CONDENSE: <fs_header>-gross_labour,
                  <fs_header>-gross_parts,
                  <fs_header>-oil,
                  <fs_header>-paint,
                  <fs_header>-sublet,
                  <fs_header>-bought_out,
                  <fs_header>-addition_servic,
                  <fs_header>-cconsumables,
                  <fs_header>-netpr,
                  <fs_header>-netwr,
                  <fs_header>-net_payable,
                  <fs_header>-tax,
                  <fs_header>-discount,
                  <fs_header>-deposit_amount,
                  <fs_header>-gross_labor2,
                  <fs_header>-gross_parts2,
                  <fs_header>-gross_consm2,
                  <fs_header>-gross_addtn2,
                  <fs_header>-disc_labor2 ,
                  <fs_header>-disc_parts2 ,
                  <fs_header>-disc_consm2 ,
                  <fs_header>-disc_addtn2 ,
                  <fs_header>-net_labor2  ,
                  <fs_header>-net_parts2  ,
                  <fs_header>-net_consm2  ,
                  <fs_header>-net_addtn2  .

      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_dbm_vbap_pdf.
    TYPES: BEGIN OF ty_konv,
             knumv TYPE knumv,
             kposn TYPE kposn,
             kschl TYPE kscha,
             kbetr TYPE kbetr,
             kwert TYPE kwert,
           END OF ty_konv.

*    TYPES: BEGIN OF ty_items,
*             vbeln   TYPE vbrp-vbeln,
*             posnr   TYPE /dbe/vbap-posnr,
*             matnr18 TYPE /dbe/vbap-matnr18,
*             pstyv   TYPE /dbe/vbap-pstyv,
*             arktx   TYPE /dbe/vbap-arktx,
*             zmeng   TYPE /dbe/vbap-zmeng,
*             matkl   TYPE /dbe/vbap-matkl,
*           END OF ty_items.

    "Data declartion
    DATA: lt_items_temp TYPE TABLE OF ty_vbap,
          ls_items_temp LIKE LINE OF lt_items_temp,
          it_makt       TYPE TABLE OF ty_makt,
          ts_makt       LIKE LINE OF it_makt,
          ts_details    TYPE yserv_inv_item_pdf_st.

    DATA: lv_labour        TYPE int4 VALUE 0,
          lv_parts         TYPE int4 VALUE 0,
          lv_consum        TYPE int4 VALUE 0,
          lv_addit         TYPE int4 VALUE 0,
          lv_gross_labor   TYPE netwr_ap VALUE '0.00',
          lv_gross_parts   TYPE netwr_ap VALUE 0,
          lv_gross_oil     TYPE netwr_ap VALUE 0,
          lv_gross_paint   TYPE netwr_ap VALUE 0,
          lv_gross_sublet  TYPE netwr_ap VALUE 0,
          lv_gross_brgout  TYPE netwr_ap VALUE 0,
          lv_gross_addserv TYPE netwr_ap VALUE 0,
          lv_gross_consumb TYPE netwr_ap VALUE 0,
          lv_gross_labor2  TYPE netwr_ap VALUE 0,
          lv_disc_labor2   TYPE netwr_ap VALUE 0,
          lv_net_labor2    TYPE netwr_ap VALUE 0,
          lv_gross_part2   TYPE netwr_ap VALUE 0,
          lv_disc_part2    TYPE netwr_ap VALUE 0,
          lv_net_part2     TYPE netwr_ap VALUE 0,
          lv_gross_consm2  TYPE netwr_ap VALUE 0,
          lv_disc_consm2   TYPE netwr_ap VALUE 0,
          lv_net_consm2    TYPE netwr_ap VALUE 0,
          lv_gross_addtn2  TYPE netwr_ap VALUE 0,
          lv_disc_addtn2   TYPE netwr_ap VALUE 0,
          lv_net_addtn2    TYPE netwr_ap VALUE 0,
          lt_konv          TYPE TABLE OF ty_konv,
          ls_konv          TYPE ty_konv,
          ls_billin_doc    LIKE LINE OF it_billing_doc.

    DATA: it_material_category TYPE TABLE OF ydbmc_prfinv_cat,
          ts_material_category LIKE LINE OF  it_material_category,
          lt_header_temp       TYPE yprfinv_head_vss_tt.

    FIELD-SYMBOLS: <fs_item> TYPE ty_vbap.

    CONSTANTS: lc_labour     TYPE char20 VALUE 'LABOUR',
               lc_parts      TYPE char20 VALUE 'PART',
               lc_consumable TYPE char20 VALUE 'CONSUMABLE',
               lc_additional TYPE char20 VALUE 'ADDITIONAL'.

    CONSTANTS: lc_gross_labour     TYPE char20 VALUE 'LABOUR',
               lc_gross_parts      TYPE char20 VALUE 'PART',
               lc_gross_oil        TYPE char20 VALUE 'OIL',
               lc_baught_out       TYPE char20 VALUE 'PAINT',
               lc_paint            TYPE char20 VALUE 'BOUGHT',
               lc_gross_sublet     TYPE char20 VALUE 'SUBLET',
               lc_gross_consumable TYPE char20 VALUE 'CONSUMABLE',
               lc_gross_additional TYPE char20 VALUE 'ADDITIONAL'.

*    DATA: lt_bseg TYPE TABLE OF bseg.

    FIELD-SYMBOLS <fs_header> LIKE LINE OF ct_header.

    TYPES: BEGIN OF ty_down_pay,
             bukrs TYPE  /dbe/t_op_line-bukrs,
             vbeln TYPE  /dbe/t_op_line-vbeln,
             oppos TYPE  /dbe/t_op_line-oppos,
             zuonr TYPE  /dbe/t_op_line-zuonr,
             kunnr TYPE  /dbe/t_op_line-kunnr,
             dmbtr TYPE  /dbe/t_op_line-dmbtr,
           END OF ty_down_pay.

    DATA: lt_down_pay      TYPE TABLE OF ty_down_pay,
          lt_down_pay_temp TYPE TABLE OF ty_down_pay,
          ls_down_pay      TYPE ty_down_pay,
          ls_down_pay_temp TYPE ty_down_pay.

    DATA: lt_items  TYPE TABLE OF ty_vbap.
    TYPES:BEGIN OF ty_descr,
            vbeln   TYPE /dbe/vbap-vbeln,
            posnr   TYPE /dbe/vbap-posnr,
            zmeng   TYPE /dbe/vbap-zmeng,
            descr1  TYPE /dbe/vbap-descr1,
            matkl   TYPE /dbe/vbap-matkl,
            pstyv   TYPE /dbe/vbap-pstyv,
            itobjid TYPE /dbe/vbap-itobjid,
          END OF ty_descr.
    DATA: lt_desr   TYPE TABLE OF ty_descr,
          ls_desr   TYPE ty_descr,
          ls_header TYPE yprfinv_head_vss_st,
          lw_tvkwz  TYPE tvkwz,       "CR 8100003994
          lv_kalks  TYPE knvv-kalks.  "CR 8100003994

    FIELD-SYMBOLS: <fs_down_pay> TYPE ty_down_pay,
                   <fs_items>    LIKE LINE OF lt_items.

*    READ TABLE ct_header INTO ls_header INDEX 1.
    IF ct_header IS NOT INITIAL.
      SELECT bukrs vbeln oppos zuonr kunnr dmbtr
        FROM /dbe/t_op_line
        INTO TABLE lt_down_pay_temp
         FOR ALL ENTRIES IN ct_header
       WHERE umskz = 'A'
         AND zuonr = ct_header-zuonr.
      IF sy-subrc = 0.
        LOOP AT lt_down_pay_temp INTO ls_down_pay_temp.
          READ TABLE lt_down_pay ASSIGNING <fs_down_pay> WITH KEY zuonr = ls_down_pay_temp-zuonr.
          IF sy-subrc = 0.
            <fs_down_pay>-dmbtr = <fs_down_pay>-dmbtr + ls_down_pay_temp-dmbtr.
          ELSE.
            ls_down_pay = ls_down_pay_temp.
            INSERT ls_down_pay INTO TABLE lt_down_pay.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    SELECT knumv kposn kschl kbetr kwert
      FROM konv
      INTO TABLE lt_konv
       FOR ALL ENTRIES IN ct_header
     WHERE knumv = ct_header-knumv.

*    lt_header_temp = ct_header.
*    SORT lt_header_temp BY zuonr.
*    DELETE ADJACENT DUPLICATES FROM lt_header_temp COMPARING zuonr.
*    DELETE lt_header_temp WHERE zuonr IS INITIAL.
*    IF lt_header_temp IS NOT INITIAL.
*      SELECT * FROM bseg INTO TABLE lt_bseg
*        FOR ALL ENTRIES IN lt_header_temp
*        WHERE zuonr = lt_header_temp-zuonr.
*    ENDIF.
*    SELECT
*      vbrp~vbeln
*      /dbe/vbap~posnr
*      /dbe/vbap~matnr18
*      /dbe/vbap~pstyv
*      /dbe/vbap~descr1
*      /dbe/vbap~zmeng
*      /dbe/vbap~matkl
*      FROM /dbe/vbap
*      JOIN vbrp
*      ON vbrp~posnr = /dbe/vbap~posnr
*      INTO TABLE lt_items
*      FOR ALL ENTRIES IN ct_header
*      WHERE /dbe/vbap~vbeln = ct_header-serv_ord_num
*        AND vbrp~vbeln = ct_header-invoice_no.
*    SELECT
*    vbrp~vbeln
*    vbrp~posnr
*    vbrp~matnr
*    vbrp~pstyv
*    /dbe/vbap~descr1
*    /dbe/vbap~zmeng
*    vbrp~matkl
*      FROM vbrp
*      JOIN /dbe/vbap
*      ON vbrp~posnr = /dbe/vbap~posnr
*      INTO TABLE lt_items
*      FOR ALL ENTRIES IN ct_header
*      WHERE vbrp~vbeln = ct_header-invoice_no
*      AND /dbe/vbap~vbeln = ct_header-serv_ord_num.

    SELECT vbeln posnr matnr
      FROM vbrp
      INTO TABLE lt_items
       FOR ALL ENTRIES IN ct_header
     WHERE vbeln = ct_header-invoice_no.
    IF sy-subrc = 0.
      SELECT vbeln posnr zmeng descr1 matkl pstyv itobjid
        FROM /dbe/vbap
        INTO TABLE lt_desr
         FOR ALL ENTRIES IN ct_header
       WHERE vbeln = ct_header-serv_ord_num.

*     Getting all the material description
      SELECT makt~matnr makt~spras makt~maktx
        INTO TABLE it_makt
        FROM makt
         FOR ALL ENTRIES IN lt_items               "#EC CI_NO_TRANSFORM
       WHERE makt~matnr = lt_items-matnr18
         AND ( makt~spras = yif_dbm_jet_constants=>gc_value_e OR
               makt~spras = yif_dbm_jet_constants=>gc_value_a ).

      SELECT *
        FROM ydbmc_prfinv_cat
        INTO TABLE it_material_category
         FOR ALL ENTRIES IN lt_desr    "Item list
       WHERE pstyv = lt_desr-pstyv. "Material Group
    ENDIF.

    LOOP AT lt_items ASSIGNING <fs_items>.
      READ TABLE lt_desr INTO ls_desr WITH KEY  posnr = <fs_items>-posnr.
      IF sy-subrc = 0.
        <fs_items>-zmeng = ls_desr-zmeng.
        <fs_items>-descr1 = ls_desr-descr1.
        <fs_items>-matkl = ls_desr-matkl.
        <fs_items>-pstyv = ls_desr-pstyv.
        <fs_items>-itobjid = ls_desr-itobjid.
      ENDIF.
    ENDLOOP.

    DATA: lt_inv_cond TYPE TABLE OF ydbmc_srinv_cond,
          ls_inv_cond TYPE ydbmc_srinv_cond.

    SELECT *
      FROM ydbmc_srinv_cond
      INTO TABLE lt_inv_cond.
    LOOP AT ct_header ASSIGNING <fs_header>.
      "Begin CR 8000003994 - Issue: invoice for Juffali family printed with zero value
      SELECT SINGLE * FROM tvkwz INTO lw_tvkwz
       WHERE werks = <fs_header>-plant.
      IF sy-subrc = 0.
        SELECT SINGLE kalks FROM knvv INTO lv_kalks
         WHERE kunnr = <fs_header>-cust_id
           AND vkorg = lw_tvkwz-vkorg
           AND vtweg = lw_tvkwz-vtweg.
      ENDIF.
      "End CR 8000003994
      lt_items_temp = lt_items.
      LOOP AT lt_items_temp ASSIGNING <fs_item> WHERE vbeln = <fs_header>-invoice_no.
        LOOP AT lt_inv_cond INTO ls_inv_cond WHERE kalks = lv_kalks AND type = 'UNIT_PRICE'.  "CR 8100003994
          READ TABLE lt_konv
          INTO ls_konv
          WITH KEY kposn = <fs_item>-posnr
                   kschl = ls_inv_cond-cond_type
                   knumv = <fs_header>-knumv.
          IF sy-subrc = 0.
            <fs_item>-netpr = <fs_item>-netpr + ls_konv-kwert.
            IF <fs_item>-zmeng <> 0.
              <fs_item>-unit_price = <fs_item>-unit_price + ( ls_konv-kwert / <fs_item>-zmeng ).
            ENDIF.
          ENDIF.
        ENDLOOP.

*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'QSBP' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-netpr = <fs_item>-netpr + ls_konv-kwert.
*        ENDIF.

        LOOP AT lt_inv_cond INTO ls_inv_cond WHERE kalks = lv_kalks AND type = 'DISCOUNT'.  "CR 8100003994
          READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr
                                                   kschl = ls_inv_cond-cond_type
                                                   knumv = <fs_header>-knumv.
          IF sy-subrc = 0.
            <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
          ENDIF.
        ENDLOOP.

*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'YRPO' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
*        ENDIF.
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'QRTK' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
*        ENDIF.
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'QRAK' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-discount = <fs_item>-discount + ls_konv-kwert.
*        ENDIF.
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'KUMU' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
        <fs_item>-netwr = <fs_item>-netpr + <fs_item>-discount.
*        ENDIF.

        LOOP AT lt_inv_cond INTO ls_inv_cond WHERE kalks = lv_kalks AND type = 'TAX'. "CR 8100003994
          READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr
                                                   kschl = ls_inv_cond-cond_type
                                                   knumv = <fs_header>-knumv.
          IF sy-subrc = 0.
            <fs_item>-tax = <fs_item>-tax + ls_konv-kwert.
            IF ev_tax_perc IS INITIAL OR ev_tax_perc = '0'.
              ev_tax_perc = ls_konv-kbetr / 10.
            ENDIF.
            <fs_item>-tax_rate = ls_konv-kbetr / 10.
            CONCATENATE <fs_item>-tax_rate ' %' INTO <fs_item>-tax_rate RESPECTING BLANKS.
          ENDIF.
        ENDLOOP.
*        READ TABLE lt_konv INTO ls_konv WITH KEY kposn = <fs_item>-posnr kschl = 'MWST' knumv = <fs_header>-knumv.
*        IF sy-subrc = 0.
*          <fs_item>-tax = <fs_item>-tax + ls_konv-kwert.
*        ENDIF.

        <fs_item>-netpay = <fs_item>-netwr + <fs_item>-tax.
      ENDLOOP.

      IF lt_items_temp IS NOT INITIAL.
        IF sy-subrc = 0.
          SORT it_makt BY matnr spras.
        ENDIF.

        LOOP AT lt_items_temp INTO ls_items_temp WHERE vbeln = <fs_header>-invoice_no.
          CLEAR ts_details.
          MOVE-CORRESPONDING ls_items_temp TO ts_details.
          ts_details-vbeln = <fs_header>-invoice_no.
          ts_details-kbetr = ls_items_temp-netpr.
          ts_details-tax_rate = ls_items_temp-tax_rate.
          ts_details-taxamount = ls_items_temp-tax.
          ts_details-netpay = ls_items_temp-netpay.

          IF it_makt IS NOT INITIAL.
            CLEAR ts_makt.
            READ TABLE it_makt INTO ts_makt WITH KEY matnr = ls_items_temp-matnr18
                                    spras = yif_dbm_jet_constants=>gc_value_e.
            IF sy-subrc = 0.
              ts_details-descr_en = ts_makt-maktx.
            ENDIF.

            READ TABLE it_makt INTO ts_makt
            WITH KEY matnr = ls_items_temp-matnr18
                     spras = yif_dbm_jet_constants=>gc_value_a.
            IF sy-subrc = 0.
              ts_details-descr_ar = ts_makt-maktx.
            ENDIF.
          ENDIF.

          READ TABLE it_material_category INTO ts_material_category
          WITH KEY pstyv = ls_items_temp-pstyv
                   matkl = ls_items_temp-matkl.

          IF sy-subrc = 0.
            "Labour
            IF ts_material_category-group_summary = lc_gross_labour.
              lv_gross_labor = lv_gross_labor + ls_items_temp-netpr.

              "Parts
            ELSEIF ts_material_category-group_summary = lc_gross_parts.
              lv_gross_parts = lv_gross_parts + ls_items_temp-netpr.

              "Oil
            ELSEIF ts_material_category-group_summary = lc_gross_oil.
              lv_gross_oil = lv_gross_oil + ls_items_temp-netpr.

              "Paint
            ELSEIF ts_material_category-group_summary = lc_paint.
              lv_gross_paint = lv_gross_paint + ls_items_temp-netpr.

              "Bought out
            ELSEIF ts_material_category-group_summary = lc_baught_out.
              lv_gross_brgout = lv_gross_brgout + ls_items_temp-netpr.

              "Sublet
            ELSEIF ts_material_category-group_summary = lc_gross_sublet.
              lv_gross_sublet = lv_gross_sublet + ls_items_temp-netpr.

              "Consumables
            ELSEIF ts_material_category-group_summary = lc_gross_consumable.
              lv_gross_consumb = lv_gross_consumb + ls_items_temp-netpr.

              "Additional service
            ELSEIF ts_material_category-group_summary = lc_gross_additional.
              lv_gross_addserv = lv_gross_addserv + ls_items_temp-netpr.
            ENDIF.
          ELSE.
            READ TABLE it_material_category INTO ts_material_category
            WITH KEY pstyv = ls_items_temp-pstyv matkl = ''.
            IF sy-subrc = 0.
              "Labour
              IF ts_material_category-group_summary = lc_gross_labour.
                lv_gross_labor = lv_gross_labor + ls_items_temp-netpr.

                "Parts
              ELSEIF ts_material_category-group_summary = lc_gross_parts.
                lv_gross_parts = lv_gross_parts + ls_items_temp-netpr.

                "Oil
              ELSEIF ts_material_category-group_summary = lc_gross_oil.
                lv_gross_oil = lv_gross_oil + ls_items_temp-netpr.

                "Paint
              ELSEIF ts_material_category-group_summary = lc_paint.
                lv_gross_paint = lv_gross_paint + ls_items_temp-netpr.

                "Bought out
              ELSEIF ts_material_category-group_summary = lc_baught_out.
                lv_gross_brgout = lv_gross_brgout + ls_items_temp-netpr.

                "Sublet
              ELSEIF ts_material_category-group_summary = lc_gross_sublet.
                lv_gross_sublet = lv_gross_sublet + ls_items_temp-netpr.

                "Consumables
              ELSEIF ts_material_category-group_summary = lc_gross_consumable.
                lv_gross_consumb = lv_gross_consumb + ls_items_temp-netpr.

                "Additional service
              ELSEIF ts_material_category-group_summary = lc_gross_additional.
                lv_gross_addserv = lv_gross_addserv + ls_items_temp-netpr.
              ENDIF.
            ENDIF.
          ENDIF.

          READ TABLE it_material_category INTO ts_material_category
          WITH KEY pstyv = ls_items_temp-pstyv
                   matkl = ls_items_temp-matkl.
          IF sy-subrc = 0.

            MOVE-CORRESPONDING ls_items_temp TO ts_details.
*            ts_
            ts_details-descr_en = ls_items_temp-descr1.
            ts_details-gross_price = ls_items_temp-netwr.
            ts_details-net_price = ls_items_temp-netpay .

            IF ts_material_category-group_detail = lc_labour.
              lv_labour = lv_labour + 1.
              ts_details-srno = lv_labour.
              CONDENSE ts_details-srno.
              lv_gross_labor2 = lv_gross_labor2 + ls_items_temp-netpr.
              lv_disc_labor2 = lv_disc_labor2 + ls_items_temp-discount.
              lv_net_labor2 = lv_net_labor2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_labor_details.

            ELSEIF ts_material_category-group_detail = lc_parts.
              lv_parts = lv_labour + 1.
              ts_details-srno = lv_parts.
              CONDENSE ts_details-srno.
              lv_gross_part2 = lv_gross_part2 + ls_items_temp-netpr.
              lv_disc_part2 = lv_disc_part2 + ls_items_temp-discount.
              lv_net_part2 = lv_net_part2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_parts_details.

            ELSEIF ts_material_category-group_detail = lc_consumable.
              lv_consum = lv_consum + 1.
              ts_details-srno = lv_consum.
              CONDENSE ts_details-srno.
              lv_gross_consm2 = lv_gross_consm2 + ls_items_temp-netpr.
              lv_disc_consm2 = lv_disc_consm2 + ls_items_temp-discount.
              lv_net_consm2 = lv_net_consm2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_consumab_details.
            ELSEIF ts_material_category-group_detail = lc_additional.
              lv_addit = lv_addit + 1.
              ts_details-srno = lv_addit.
              CONDENSE ts_details-srno.
              lv_gross_addtn2 = lv_gross_addtn2 + ls_items_temp-netpr.
              lv_disc_addtn2 = lv_disc_addtn2 + ls_items_temp-discount.
              lv_net_addtn2 = lv_net_addtn2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_addition_details.
            ENDIF.
          ELSE.
            READ TABLE it_material_category INTO ts_material_category
                WITH KEY pstyv = ls_items_temp-pstyv matkl = ''.
            IF sy-subrc = 0.
              MOVE-CORRESPONDING ls_items_temp TO ts_details.
              ts_details-descr_en = ls_items_temp-descr1.
              ts_details-gross_price = ls_items_temp-netwr.
              ts_details-net_price = ls_items_temp-netpay .

              IF ts_material_category-group_summary = lc_labour.
                lv_labour = lv_labour + 1.
                ts_details-srno = lv_labour.
                CONDENSE ts_details-srno.
                lv_gross_labor2 = lv_gross_labor2 + ls_items_temp-netpr.
                lv_disc_labor2 = lv_disc_labor2 + ls_items_temp-discount.
                lv_net_labor2 = lv_net_labor2 + ls_items_temp-netwr.
                APPEND ts_details TO ct_labor_details.

              ELSEIF ts_material_category-group_summary = lc_parts.
                lv_parts = lv_labour + 1.
                ts_details-srno = lv_parts.
                CONDENSE ts_details-srno.
                lv_gross_part2 = lv_gross_part2 + ls_items_temp-netpr.
                lv_disc_part2 = lv_disc_part2 + ls_items_temp-discount.
                lv_net_part2 = lv_net_part2 + ls_items_temp-netwr.
                APPEND ts_details TO ct_parts_details.

              ELSEIF ts_material_category-group_summary = lc_consumable.
                lv_consum = lv_consum + 1.
                ts_details-srno = lv_consum.
                CONDENSE ts_details-srno.
                lv_gross_consm2 = lv_gross_consm2 + ls_items_temp-netpr.
                lv_disc_consm2 = lv_disc_consm2 + ls_items_temp-discount.
                lv_net_consm2 = lv_net_consm2 + ls_items_temp-netwr.
                APPEND ts_details TO ct_consumab_details.
              ELSE.
                lv_addit = lv_addit + 1.
                ts_details-srno = lv_addit.
                CONDENSE ts_details-srno.
                lv_gross_addtn2 = lv_gross_addtn2 + ls_items_temp-netpr.
                lv_disc_addtn2 = lv_disc_addtn2 + ls_items_temp-discount.
                lv_net_addtn2 = lv_net_addtn2 + ls_items_temp-netwr.
                APPEND ts_details TO ct_addition_details.
              ENDIF.
            ELSE.
              MOVE-CORRESPONDING ls_items_temp TO ts_details.
              ts_details-descr_en = ls_items_temp-descr1.
              ts_details-gross_price = ls_items_temp-netwr.
              ts_details-net_price = ls_items_temp-netpay .

              CLEAR ts_makt.
              READ TABLE it_makt INTO ts_makt
              WITH KEY matnr = ls_items_temp-matnr18
                       spras = yif_dbm_jet_constants=>gc_value_a.
              IF sy-subrc = 0.
                ts_details-descr_ar = ts_makt-maktx.
              ENDIF.

              lv_gross_addserv = lv_gross_addserv + ls_items_temp-netpr.
              lv_addit = lv_addit + 1.
              ts_details-srno = lv_addit.
              CONDENSE ts_details-srno.
              lv_gross_addtn2 = lv_gross_addtn2 + ls_items_temp-netpr.
              lv_disc_addtn2 = lv_disc_addtn2 + ls_items_temp-discount.
              lv_net_addtn2 = lv_net_addtn2 + ls_items_temp-netwr.
              APPEND ts_details TO ct_addition_details.
            ENDIF.
          ENDIF.

          <fs_header>-netpr = <fs_header>-netpr + ls_items_temp-netpr.
          <fs_header>-discount = <fs_header>-discount + ls_items_temp-discount.
          <fs_header>-netwr = <fs_header>-netwr + ls_items_temp-netwr.
          <fs_header>-tax = <fs_header>-tax + ls_items_temp-tax.
          <fs_header>-net_payable = <fs_header>-net_payable + ls_items_temp-netpay.

        ENDLOOP.

        <fs_header>-gross_labour    = lv_gross_labor.   "Gross labour amount
        <fs_header>-gross_parts     = lv_gross_parts.   "Gross parts amount
        <fs_header>-oil             = lv_gross_oil.     "Oil amount
        <fs_header>-paint           = lv_gross_paint.   "Paint amount
        <fs_header>-sublet          = lv_gross_sublet.  "Sublet amount
        <fs_header>-bought_out      = lv_gross_brgout.  "Bought out amount
        <fs_header>-addition_servic = lv_gross_addserv. "Additional service amount
        <fs_header>-cconsumables    = lv_gross_consumb. "Consumables amount
        <fs_header>-gross_labor2 = lv_gross_labor2.
        <fs_header>-gross_parts2 = lv_gross_part2.
        <fs_header>-gross_consm2 = lv_gross_consm2.
        <fs_header>-gross_addtn2 = lv_gross_addtn2.
        <fs_header>-disc_labor2  = lv_disc_labor2.
        <fs_header>-disc_parts2  = lv_disc_part2.
        <fs_header>-disc_consm2  = lv_disc_consm2.
        <fs_header>-disc_addtn2  = lv_disc_addtn2.
        <fs_header>-net_labor2   = lv_net_labor2.
        <fs_header>-net_parts2   = lv_net_part2.
        <fs_header>-net_consm2   = lv_net_consm2.
        <fs_header>-net_addtn2   = lv_net_addtn2.
        <fs_header>-total   = <fs_header>-netwr + <fs_header>-tax .

        READ TABLE lt_down_pay ASSIGNING <fs_down_pay> WITH KEY zuonr = <fs_header>-zuonr.
        IF sy-subrc = 0.
          <fs_header>-deposit_amount = <fs_down_pay>-dmbtr.
*          IF <fs_header>-net_payable > <fs_down_pay>-dmbtr.
*            <fs_down_pay>-dmbtr = 0.
*          ELSE.
*            <fs_down_pay>-dmbtr = <fs_down_pay>-dmbtr - <fs_header>-net_payable.
*          ENDIF.
          <fs_header>-net_payable  = <fs_header>-net_payable - <fs_header>-deposit_amount.
        ENDIF.

        CLEAR: lv_gross_labor,
               lv_gross_parts,
               lv_gross_oil,
               lv_gross_paint,
               lv_gross_sublet,
               lv_gross_brgout,
               lv_gross_addserv,
               lv_gross_consumb,
               lv_gross_labor2,
               lv_gross_part2,
               lv_gross_consm2,
               lv_gross_addtn2,
               lv_disc_labor2,
               lv_disc_part2,
               lv_disc_consm2,
               lv_disc_addtn2,
               lv_net_labor2,
               lv_net_part2,
               lv_net_consm2,
               lv_net_addtn2.

        CONDENSE: <fs_header>-gross_labour,
                  <fs_header>-gross_parts,
                  <fs_header>-oil,
                  <fs_header>-paint,
                  <fs_header>-sublet,
                  <fs_header>-bought_out,
                  <fs_header>-addition_servic,
                  <fs_header>-cconsumables,
                  <fs_header>-netpr,
                  <fs_header>-netwr,
                  <fs_header>-net_payable,
                  <fs_header>-tax,
                  <fs_header>-discount,
                  <fs_header>-deposit_amount,
                  <fs_header>-gross_labor2,
                  <fs_header>-gross_parts2,
                  <fs_header>-gross_consm2,
                  <fs_header>-gross_addtn2,
                  <fs_header>-disc_labor2 ,
                  <fs_header>-disc_parts2 ,
                  <fs_header>-disc_consm2 ,
                  <fs_header>-disc_addtn2 ,
                  <fs_header>-net_labor2  ,
                  <fs_header>-net_parts2  ,
                  <fs_header>-net_consm2  ,
                  <fs_header>-net_addtn2  .

      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_location_details.
    DATA: ts_t001w  TYPE ty_t001w,
          it_adress TYPE string_table,
          ts_adrc   TYPE ty_adrc.

    FIELD-SYMBOLS: <fs_adress> LIKE LINE OF it_adress.
    "getlocation name
    SELECT SINGLE werks name1 adrnr FROM t001w
      INTO ts_t001w
      WHERE werks = iv_plant_code.

    IF sy-subrc = 0.
      ev_locname = ts_t001w-name1.
      "Fetching address
      SELECT SINGLE street city1 city2 post_code1
       post_code2 tel_number FROM adrc
       INTO ts_adrc WHERE addrnumber = ts_t001w-adrnr.
      IF sy-subrc = 0.
        ev_telf = ts_adrc-tel_number.
        APPEND ts_adrc-street TO it_adress.
        APPEND ts_adrc-city1 TO it_adress.
        APPEND ts_adrc-city2 TO it_adress.
        APPEND ts_adrc-post_code1 TO it_adress.
        APPEND ts_adrc-post_code2 TO it_adress.
        LOOP AT it_adress ASSIGNING <fs_adress>.
          IF <fs_adress> IS NOT INITIAL AND ev_locaddr IS INITIAL.
            ev_locaddr = <fs_adress>.
          ELSEIF <fs_adress> IS NOT INITIAL.
            CONCATENATE ev_locaddr `, ` <fs_adress> INTO ev_locaddr.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_ordertype_data.
    "Data declartion
    DATA: aufart       TYPE /dbe/aufart,
          it_ordertype TYPE TABLE OF ty_description,
          ts_ordertype LIKE LINE OF it_ordertype.
*    ts_ordertype-descrip
*    ts_ordertype-spras
    "Gettinig the data from /dbe/vbak_db table
    SELECT SINGLE  aufart
           FROM /dbe/vbap
           INTO aufart
           WHERE vbeln = iv_order_no.
    IF sy-subrc = 0.
      "Getting and inserting the description for sales type into header Struct
      " where aufart is Equal to the aufart and spras EQ 'E' or spras EQ 'A'
      SELECT spras bezei AS descrip FROM /dbe/c_ordertpt
        INTO  TABLE it_ordertype
        WHERE aufart = aufart AND
              ( spras = yif_dbm_jet_constants=>gc_value_e OR
                spras = yif_dbm_jet_constants=>gc_value_a ).
      "Sorting for binary search
      SORT it_ordertype BY spras.
      IF sy-subrc = 0.
        READ TABLE it_ordertype INTO ts_ordertype WITH KEY spras = yif_dbm_jet_constants=>gc_value_e.
        IF sy-subrc = 0.
          ev_ordertype_en = ts_ordertype-descrip.
        ENDIF.
        CLEAR ts_ordertype.
        READ TABLE it_ordertype INTO ts_ordertype WITH KEY spras = yif_dbm_jet_constants=>gc_value_a.
        IF sy-subrc = 0.
          ev_ordertype_ar = ts_ordertype-descrip.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_payment_method.
    "Data declaration
    DATA: it_payment TYPE TABLE OF ty_description,
          ts_payment LIKE LINE OF it_payment.
    "Selecting the payment method
    SELECT spras text2 AS descrip FROM t042zt INTO TABLE it_payment
      WHERE ( spras = yif_dbm_jet_constants=>gc_value_e
      OR spras = yif_dbm_jet_constants=>gc_value_a )
      AND land1 = iv_country_key AND zlsch = iv_payment_method.
    "Sorting for binary search
    SORT it_payment BY spras.
    IF sy-subrc = 0.
      READ TABLE it_payment INTO ts_payment WITH KEY spras = yif_dbm_jet_constants=>gc_value_e.
      IF sy-subrc = 0.
        ev_text_en = ts_payment-descrip.
      ENDIF.
      CLEAR ts_payment.
      READ TABLE it_payment INTO ts_payment WITH KEY spras = yif_dbm_jet_constants=>gc_value_a.
      IF sy-subrc = 0.
        ev_text_ar = ts_payment-descrip.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_servadv_details.
    "Data declaration
    DATA: ts_pa0002 TYPE ty_pa0002.
    "Selecting the name
    SELECT SINGLE vorna nach2 nachn fnamr lnamr
       INTO ts_pa0002 FROM pa0002 WHERE pernr = iv_pernr.
    "if successfully executed
    IF sy-subrc = 0.
      ev_paname_en = ts_pa0002-vorna.
      IF ev_paname_en IS NOT INITIAL.
        CONCATENATE: ev_paname_en ts_pa0002-nach2 INTO ev_paname_en SEPARATED BY space.
      ELSE.
        ev_paname_en = ts_pa0002-nach2.
      ENDIF.

      IF ev_paname_en IS NOT INITIAL.
        CONCATENATE: ev_paname_en  ts_pa0002-nachn INTO ev_paname_en  SEPARATED BY space.
      ELSE.
        ev_paname_en = ts_pa0002-nachn.
      ENDIF.

      CONCATENATE ts_pa0002-fnamr ts_pa0002-lnamr INTO ev_paname_ar SEPARATED BY space.

    ENDIF.
    "Selecting the telephone number
    SELECT SINGLE telnr AS ev_telno INTO ev_telno FROM pa0006 WHERE pernr = iv_pernr.

  ENDMETHOD.


  METHOD get_vbrk_invoice_details.

    SELECT SINGLE vbeln fkart fkdat erzet rfbsk zuonr zlsch land1 knumv spart waerk bukrs fksto
      FROM vbrk INTO  es_vbrk WHERE
      vbeln = iv_bill_doc."AND fksto = ''.
    IF sy-subrc = 0 AND es_vbrk-bukrs = '2100'.
      IF es_vbrk-fksto IS NOT INITIAL.
        CLEAR: es_vbrk.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_vehicle_description.
    "data declaration
    DATA: ts_/dbe/v_imodel TYPE ty_/dbe/v_imodel,
          ts_/dbe/v_modelt TYPE ty_/dbe/v_modelt.

    "vlcvehicle
*    SELECT SINGLE vguid /dbe/iobvhvin vhcle INTO
    SELECT SINGLE vguid /dbe/iobjguid vhcle INTO
*    SELECT SINGLE vguid vhvin vhcle INTO
     es_vlcvehicle FROM vlcvehicle
     WHERE vguid = iv_vguid.

    IF sy-subrc = 0.
      "Select the model GUID
      SELECT SINGLE product_guid modguid mcodesd modyear  INTO
        ts_/dbe/v_imodel FROM /dbe/v_imodel
        WHERE product_guid = es_vlcvehicle-iobjguid.

      "Selecting the text
      IF sy-subrc = 0.
        SELECT SINGLE model_guid motext1  INTO
         ts_/dbe/v_modelt FROM /dbe/v_modelt
         WHERE model_guid = ts_/dbe/v_imodel-modguid
          AND spras = yif_dbm_jet_constants=>gc_value_e.
        IF sy-subrc = 0.
          ev_vehicle_descip = ts_/dbe/v_modelt-motext1.
        ENDIF.
      ENDIF.
      ev_model_year = ts_/dbe/v_imodel-modyear.
    ENDIF.
  ENDMETHOD.


  METHOD set_header_data.

    DATA cs_header LIKE LINE OF ct_header.

    "Local data declaration
    DATA: ts_/dbe/vbak_db TYPE ty_/dbe/vbak_db,
          ts_vbrk         TYPE ty_vbrk,
          ts_vlcvehicle   TYPE ty_vlcvehicle,
          ts_kna1         TYPE ty_kna1,
          lv_zterm        TYPE dzterm,
          it_tvzbt        TYPE TABLE OF tvzbt,
          ts_tvzbt        TYPE tvzbt,
          ts_return       LIKE LINE OF ct_return.

    DATA: lv_zuonr    TYPE vbrk-zuonr,
*          lt_invoice  TYPE TABLE OF ty_invoice,
          ls_invoice  LIKE LINE OF it_billing_doc,
          lv_bill_doc TYPE vbeln_va,
          lv_low      TYPE rvari_val_255.
*    TYPES:BEGIN OF ty_op_line,
*            zuonr TYPE /dbe/t_op_line-zuonr,
*            dmbtr TYPE /dbe/t_op_line-dmbtr,
*          END OF ty_op_line.
*    DATA:lt_op_line TYPE TABLE OF ty_op_line,
*         ls_op_line LIKE LINE OF lt_op_line.
    DATA: lv_vbtyp TYPE vbrk-vbtyp.

    "Get order number
    READ TABLE it_billing_doc INTO ls_invoice INDEX 1.
    IF sy-subrc = 0.
      SELECT SINGLE zuonr FROM vbrk INTO lv_zuonr WHERE vbeln = ls_invoice-vbeln.
      IF sy-subrc = 0.
        ev_salesorderno = lv_zuonr+3(10).
      ENDIF.
    ENDIF.

    LOOP AT it_billing_doc INTO ls_invoice.
      CLEAR cs_header.
      lv_bill_doc = ls_invoice-vbeln.
      "getting the data from vbrk table
      get_vbrk_invoice_details(
        EXPORTING
          iv_bill_doc = lv_bill_doc    " DBM Order Number
        IMPORTING
          es_vbrk     = ts_vbrk
      ).
      "If vbrk data exists
      IF ts_vbrk IS NOT INITIAL.
*        ev_salesorderno = ts_vbrk-zuonr+3(10).
        cs_header-invoice_no = ts_vbrk-vbeln.
        cs_header-zuonr = ts_vbrk-zuonr.
        cs_header-knumv = ts_vbrk-knumv.
        cs_header-division = ts_vbrk-spart.
        cs_header-currency_en = ts_vbrk-waerk.
        "Invoice date and time
        CONCATENATE: ts_vbrk-fkdat+6(02)
                     '-'
                     ts_vbrk-fkdat+4(02)
                     '-'
                     ts_vbrk-fkdat(04)
                     ` `
                     ts_vbrk-erzet(02)
                     ':'
                     ts_vbrk-erzet+2(02)
                     INTO cs_header-invoice_dat_tm.

        SELECT SINGLE low FROM tvarvc "CLIENT SPECIFIED
          INTO lv_low
          WHERE name = 'YSERV_INV_APPT_TEL_NO'.
        IF sy-subrc = 0.
          cs_header-tel_appt = lv_low.
        ENDIF.
        "Getting payment method
        get_payment_method(
          EXPORTING
            iv_country_key    = ts_vbrk-land1    " Country Key
            iv_payment_method = ts_vbrk-zlsch    " Payment Method
          IMPORTING
            ev_text_ar        = cs_header-payment_ar    " 30 Characters
            ev_text_en        = cs_header-payment_en    " 30 Characters
        ).


        "Getting the total amount and debuctibale amount
        get_amount_bsid(
          EXPORTING
            iv_zuonr  = ts_vbrk-zuonr   " Assignment number
          IMPORTING
*           ev_amount = cs_header-deposit_amount    " Char 15
            ev_deduct = cs_header-debuctibale   " Char 15
*           ev_netpayble = cs_header-net_payable
        ).

      ENDIF.


      IF ev_salesorderno IS NOT INITIAL.
        "get vbak_db_details
        get_dbm_vbak_db_details(
          EXPORTING
            iv_order_no = ev_salesorderno  " DBM Order Number
          IMPORTING
            es_vbak_db  = ts_/dbe/vbak_db  " vbak db details
        ).
        IF ts_/dbe/vbak_db IS NOT INITIAL.
          cs_header-meter_reading = ts_/dbe/vbak_db-mileage.
          cs_header-regist_number = ts_/dbe/vbak_db-licpl.
          cs_header-serv_ord_num = ts_/dbe/vbak_db-vbeln.
          cs_header-date_in = ts_/dbe/vbak_db-visit_start_date.
          "if visit_start_date is empty
          IF cs_header-date_in IS INITIAL.
            cs_header-date_in = ts_/dbe/vbak_db-audat.
          ENDIF.

          "Get Location details
          get_location_details(
            EXPORTING
              iv_plant_code = ts_/dbe/vbak_db-werks   " Plant
              ct_return     = ct_return   " Error Messages
            IMPORTING
              ev_locname    = cs_header-location_name   " Name
              ev_locaddr    = cs_header-location_addr
              ev_telf       = cs_header-loc_telf ).

          cs_header-plant = ts_/dbe/vbak_db-werks.

          "Get vehicle information
          get_vehicle_description(
            EXPORTING
              iv_vguid          = ts_/dbe/vbak_db-vguid    " Vehicle GUID (Globally Unique IDentifier)
            IMPORTING
              es_vlcvehicle     = ts_vlcvehicle    " vlcvvehicle struct
              ev_vehicle_descip = cs_header-vehicl_descri    " Vehicle Model description
              ev_model_year     = cs_header-modyear    " Vehicle model year
          ).

          IF ts_vlcvehicle IS NOT INITIAL.
            cs_header-vin_no = ts_vlcvehicle-vhvin.
            SELECT SINGLE saledate FROM /dbe/v_ivehicle
              INTO cs_header-date_of_purch
              WHERE product_guid = ts_vlcvehicle-iobjguid.
          ENDIF.

*          get_erdat(
*            EXPORTING
*              iv_vhcle = ts_vlcvehicle-vhcle    " Internal Vehicle Number
*            IMPORTING
*              ev_erdat =  ts_/dbe/vbak_db-erdat    " Date on which record was Created
*          ).

          SELECT SINGLE pernr FROM pa0001 INTO ts_/dbe/vbak_db-pernr
            WHERE uname = ts_/dbe/vbak_db-ange_user.
          get_servadv_details(
            EXPORTING
              iv_pernr     = ts_/dbe/vbak_db-pernr   " Personnel number
            IMPORTING
              ev_paname_en = cs_header-serv_adv_nm_en   " Formatted Name of Employee or Applicant
              ev_paname_ar = cs_header-serv_adv_nm_ar   " Employee's Name (Sortable by LAST NAME FIRST NAME)
              ev_telno     = cs_header-serv_adv_telno
          ).

          "get order type
          get_ordertype_data(
            EXPORTING
              iv_order_no     = ev_salesorderno   " DBM Order Number
            IMPORTING
              ev_ordertype_en = cs_header-order_type_en    " Description
              ev_ordertype_ar = cs_header-order_type_ar    " Description
          ).

        ENDIF.
        "Get customer details
        get_customer_details(
          EXPORTING
            iv_billing = ls_invoice-vbeln    " DBM Order Number
          IMPORTING
            es_kna1    = ts_kna1   " Customer details
        ).
        IF ts_kna1 IS NOT INITIAL.
          cs_header-cust_id = ts_kna1-kunnr.

          DATA: gv_title TYPE ad_title,
                gv_name1 TYPE bu_nameor2,
                gv_name2 TYPE bu_nameor2,
                gv_name  TYPE string.

          SELECT SINGLE name_org1 name_org2 title
            INTO ( gv_name1, gv_name2, gv_title )
             FROM but000 WHERE partner = cs_header-cust_id.
          IF sy-subrc = 0.
            IF gv_title = '0003'.
              CONCATENATE gv_name1 ' ' gv_name2 INTO gv_name.
              MOVE gv_name TO cs_header-cust_name.
            ELSE.
              cs_header-cust_name = ts_kna1-name1.
              cs_header-cust_name_ar = ts_kna1-aname1.
            ENDIF.
          ENDIF.
          cs_header-cust_mob = ts_kna1-telf1.
        ENDIF.
      ELSE.
        CLEAR ts_return.
        MESSAGE e043(ymsg_jet_dbm) WITH lv_bill_doc INTO ts_return-message.

        ts_return-id = yif_dbm_jet_constants=>gc_msg_class_id.
        ts_return-type = yif_dbm_jet_constants=>gc_value_e.
        ts_return-number = 43.
        APPEND ts_return TO ct_return.
      ENDIF.

      "get payment term .
      SELECT SINGLE zterm FROM /dbe/splhdr_db
       INTO  lv_zterm
         WHERE vbeln = ev_salesorderno
           AND splnr = '0001'.
      IF sy-subrc = 0.
        "Get description for payment term
        SELECT * FROM tvzbt
          INTO TABLE it_tvzbt
            WHERE
              zterm = lv_zterm.
        IF sy-subrc = 0.
          READ TABLE it_tvzbt INTO ts_tvzbt
          WITH KEY spras = yif_dbm_jet_constants=>gc_lang_en.
          IF sy-subrc = 0.
            CONCATENATE  lv_zterm ':' ts_tvzbt-vtext
              INTO cs_header-pay_term_en  SEPARATED BY space.
          ENDIF.
          READ TABLE it_tvzbt INTO ts_tvzbt
          WITH KEY spras = yif_dbm_jet_constants=>gc_lang_ar.
          IF sy-subrc = 0.
            CONCATENATE lv_zterm ':' ts_tvzbt-vtext
              INTO cs_header-pay_term_ar SEPARATED BY space.
          ENDIF.
        ENDIF.

        IF lv_zterm = 'Z001' OR lv_zterm = '0001'.
*      es_header_data-inv_type_text = 'Cash Sale-مبيعات نقدية'.
          CONCATENATE 'Cash Sale' '-' 'مبيعات نقدية' INTO   cs_header-invoice_type SEPARATED BY space.
        ELSE.
*      = 'Credit Sale-مبيعات آجلة'.
          CONCATENATE 'Credit Sale' '-' 'مبيعات آجلة' INTO   cs_header-invoice_type SEPARATED BY space.
        ENDIF.
      ENDIF.

      DATA: it_docs TYPE  /dbe/docflow_documents_tt,
            wa_docs LIKE LINE OF it_docs.
      CALL FUNCTION '/DBE/OE_MAIN_DOCFLOW_READ_ALL'
        EXPORTING
          iv_vbeln       = cs_header-serv_ord_num
        IMPORTING
          et_documents   = it_docs
        EXCEPTIONS
          internal_error = 1
          OTHERS         = 2.
      DATA: lv_quotation TYPE /dbe/vbeln_va.
      CONSTANTS: lc_quot TYPE /dbe/vbtyp VALUE 'B'.
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
            cs_header-quotation = lv_quotation.
          ENDIF.
        ENDIF.
      ENDIF.
*      LOOP AT lt_op_line INTO ls_op_line WHERE zuonr = ls_invoice-zuonr.
*        cs_header-deposit_amount = cs_header-deposit_amount + ls_op_line-dmbtr.
*      ENDLOOP.
*      CONDENSE cs_header-deposit_amount.
      APPEND cs_header TO ct_header.
    ENDLOOP.
  ENDMETHOD.


  METHOD set_item_data.
    IF it_billing_doc IS NOT INITIAL.
      "Call the method which fills up all the global table required

      CLEAR :ct_labor_details,ct_consumab_details,ct_addition_details,ct_parts_details.
      get_dbm_vbap(
        EXPORTING
          it_billing_doc      = it_billing_doc     " Sales Document
        IMPORTING
          ev_tax_perc         = ev_tax_perc
        CHANGING
          ct_header           = ct_header
          ct_labor_details    = ct_labor_details
          ct_consumab_details = ct_consumab_details
          ct_parts_details    = ct_parts_details
          ct_addition_details = ct_addition_details ).
    ENDIF.

    DELETE ct_labor_details WHERE net_price LE 0.
    DELETE ct_addition_details WHERE net_price LE 0.
    DELETE ct_consumab_details WHERE net_price LE 0.
    DELETE ct_parts_details WHERE net_price LE 0.
  ENDMETHOD.


  METHOD set_item_data_pdf.
    IF it_billing_doc IS NOT INITIAL.
      "Call the method which fills up all the global table required

      CLEAR :ct_labor_details,ct_consumab_details,ct_addition_details,ct_parts_details.
      get_dbm_vbap_pdf(
        EXPORTING
          it_billing_doc      = it_billing_doc     " Sales Document
        IMPORTING
          ev_tax_perc         = ev_tax_perc
        CHANGING
          ct_header           = ct_header
          ct_labor_details    = ct_labor_details
          ct_consumab_details = ct_consumab_details
          ct_parts_details    = ct_parts_details
          ct_addition_details = ct_addition_details ).
    ENDIF.

    DELETE ct_labor_details WHERE net_price LE 0.
    DELETE ct_addition_details WHERE net_price LE 0.
    DELETE ct_consumab_details WHERE net_price LE 0.
    DELETE ct_parts_details WHERE net_price LE 0.
  ENDMETHOD.
ENDCLASS.

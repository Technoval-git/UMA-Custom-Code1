class ZCL_EDOC_ADAPTOR definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EDOC_ADAPTOR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_EDOC_ADAPTOR IMPLEMENTATION.


  METHOD if_edoc_adaptor~change_edocument_type.

    DATA: ls_accdn      TYPE accdn,
          lv_mwart      TYPE bseg-mwart,
          lv_source     TYPE edoc_src_header,
          lv_source_key TYPE edoc_source_key,
          ls_fi_invoice TYPE edoc_src_data_fi_invoice,
          ls_sd_invoice TYPE edoc_src_data_sd_invoice,
          lv_wrbtr1     TYPE wrbtr.


    FIELD-SYMBOLS: <ls_source_data> TYPE any,
                   <fs_DI>          TYPE edoc_bseg_tab,
                   <fs_otc>         TYPE  edoc_bsec_tab,
                   <fs_otc_sd>      TYPE edoc_vbpa_tab,
                   <fs_bseg>        TYPE edoc_bseg_tab.
*              BREAK-POINT.


    data lv_edoc_type type edoc_type.

    Case cv_edoc_type.
      WHEN 'SA_INV'.
       lv_edoc_type = 'SA_INV_SI'.
     WHEN 'SA_INV_CR'.
       lv_edoc_type = 'SA_INV_SCR'.
     WHEN 'SA_INV_DB'.
       lv_edoc_type = 'SA_INV_SDB'.

     When OTHERS.
        lv_edoc_type = cv_edoc_type.

    ENDCASE.


    IF io_source->mv_source_type EQ 'FI_INVOICE'.
      ASSIGN ls_fi_invoice TO <ls_source_data>.
      io_source->get_data( IMPORTING es_data = <ls_source_data> ).

      TRY.
          CALL METHOD io_source->get_blart
            RECEIVING
              rv_blart = DATA(lv_blart1).
        CATCH cx_edocument .
      ENDTRY.
      IF lv_blart1 NE 'DY'.
        ASSIGN COMPONENT 'ONETIME_CUSTOMER' OF STRUCTURE <ls_source_data> TO <fs_otc>.

        READ TABLE <fs_otc> INTO DATA(lw_otc) INDEX 1.
        IF sy-subrc = 0.
          IF lw_otc-stkzn = ' '.
            ASSIGN COMPONENT 'DOCUMENT_ITEM' OF STRUCTURE <ls_source_data> TO <fs_bseg>.
            LOOP AT <fs_bseg> INTO DATA(lw_bseg) WHERE kunnr NE '' AND koart = 'D' AND buzei = '001'.
              SELECT SINGLE  natpers FROM but000 INTO @DATA(lw_natpers) WHERE partner = @lw_bseg-kunnr.
              IF sy-subrc = 0 AND lw_natpers = 'X'.

                cv_edoc_type = lv_edoc_type. "'SA_INV_SI'.
              ENDIF.
              EXIT.
            ENDLOOP.
          ENDIF.
        ELSE.

          ASSIGN COMPONENT 'DOCUMENT_ITEM' OF STRUCTURE <ls_source_data> TO <fs_DI>.
          LOOP AT <fs_DI> INTO DATA(lw_DI) WHERE kunnr NE ''. "AND koart = 'D' AND buzei = '001'.
            SELECT SINGLE  natpers FROM but000 INTO @DATA(lw_natpers_DI) WHERE partner = @lw_DI-kunnr.
            IF sy-subrc = 0 AND lw_natpers_DI = 'X'.

              cv_edoc_type = lv_edoc_type. "'SA_INV_SI'.
            ENDIF.
            EXIT.
          ENDLOOP.
        ENDIF.
      ENDIF.





    ELSEIF   io_source->mv_source_type EQ 'SD_INVOICE'.
      ASSIGN ls_sd_invoice TO <ls_source_data>.
      io_source->get_data( IMPORTING es_data = <ls_source_data> ).

      TRY.
          CALL METHOD io_source->get_blart
            RECEIVING
              rv_blart = DATA(lv_blart).
        CATCH cx_edocument .
      ENDTRY.
      IF lv_blart NE 'DY'.

        ASSIGN COMPONENT 'PARTNER_DATA' OF STRUCTURE <ls_source_data> TO <fs_otc_sd>.
        READ TABLE <fs_otc_sd> INTO DATA(lw_otc1) INDEX 1.
        IF sy-subrc = 0.
*      IF lw_otc1-stkzn = ' ' and lw_otc1-XCPDK = 'X' and lw_otc1-kunnr NE ' ' .
          SELECT SINGLE  natpers FROM but000 INTO @DATA(lw_natpers1) WHERE partner = @lw_otc1-kunnr.
          IF sy-subrc = 0 AND lw_natpers1 = 'X'.
            cv_edoc_type = lv_edoc_type. "'SA_INV_SI'.
          ENDIF.
*        ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.

*
*    DATA(ld_data) = io_source->get_data_reference( ).
*
*    ASSIGN ld_data->* TO FIELD-SYMBOL(<ls_data>).
*    data(lw_otc)  = |{ <ls_data> } |.
*    ASSIGN COMPONENT onetime_customer OF STRUCTURE ld_data to FIELD-SYMBOL(<lw_otc>).
*    ASSIGN ('(ld_data)onetime_customer[]') to FIELD-SYMBOL(<lw_otc>).
*    data(lw_otc) = ld_Data->onetime_customer( ).

*    READ TABLE  <LS_DATA>-DOCUMENT_HEADER[] INTO DATA(lw_otc) INDEX 1.
*    READ TABLE <LS_DATA>-ONETIME_CUSTOMER ASSIGNING FIELD-SYMBOL(<lw_otc>).
*    data(lw_otc) =  <ls_data>-onetime_customer.
*    ASSIGN  <ls_data>-onetime_customer to FIELD-SYMBOL(<lw_otc>).
*    IF sy-subrc = 0.
*      IF lw_otc-stkzn = ' '.
*        READ TABLE <ls_data>-document_item INTO DATA(lw_doc_item) WITH KEY koart = 'D' buzei = '001'.
*        IF sy-subrc = 0  AND lw_doc_item-kunnr NE ''.
*          SELECT SINGLE  natpers FROM but000 INTO data(lw_natpers)WHERE partner = lw_doc_item-kunnr.
*          IF sy-subrc = 0 AND lw_natpes = 'X'.
*            cv_edoc_type = 'SA_INV_SI'.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.

  ENDMETHOD.


  method IF_EDOC_ADAPTOR~GET_VARIABLE_KEY.
  endmethod.


  METHOD if_edoc_adaptor~is_relevant.



*    FIELD-SYMBOLS: <ls_source_data> TYPE any,
*                   <fs_DI>          TYPE edoc_bseg_tab,
*                   <fs_otc>         TYPE  edoc_bsec_tab,
*                   <fs_otc_sd>      TYPE edoc_vbpa_tab,
*                   <fs_bseg>        TYPE edoc_bseg_tab.



    DATA:
      lv_source     TYPE edoc_src_header,
      lv_source_key TYPE edoc_source_key,
      ls_fi_invoice TYPE edoc_src_data_fi_invoice,
      ls_sd_invoice TYPE edoc_src_data_sd_invoice.


    FIELD-SYMBOLS: <ls_source_data> TYPE any,
                   <fs_bseg>        TYPE edoc_bseg_tab,
                   <doc_item>       TYPE edoc_vbrpvb_tab  , "edoc_bseg_tab,
                   <fs_otc_sd>      TYPE edoc_vbpa_tab.




    IF io_source->mv_source_type EQ 'FI_INVOICE'.
      TRY.
          CALL METHOD io_source->get_blart
            RECEIVING
              rv_blart = DATA(lv_blart).
        CATCH cx_edocument .
      ENDTRY.
      IF lv_blart = 'DA'.
        cx_relevant = abap_false.
      ENDIF.

    ENDIF.





    IF io_source->mv_source_type EQ 'FI_INVOICE'.
      ASSIGN ls_fi_invoice TO <ls_source_data>.
      io_source->get_data( IMPORTING es_data = <ls_source_data> ).


      ASSIGN COMPONENT 'DOCUMENT_ITEM' OF STRUCTURE <ls_source_data> TO <fs_bseg>.
      LOOP AT <fs_bseg> INTO DATA(lw_bseg) WHERE kunnr NE '' .
        SELECT SINGLE * FROM zfi_zatca_cust INTO @DATA(lw_zatca_cust) WHERE  bukrs = @lw_bseg-bukrs  AND kunnr = @lw_bseg-kunnr.
        IF sy-subrc = 0.
          cx_relevant = abap_false.
        ENDIF.
        EXIT.
      ENDLOOP.





    ELSEIF   io_source->mv_source_type EQ 'SD_INVOICE'.
      ASSIGN ls_sd_invoice TO <ls_source_data>.
      io_source->get_data( IMPORTING es_data = <ls_source_data> ).



      ASSIGN COMPONENT 'PARTNER_DATA' OF STRUCTURE <ls_source_data> TO <fs_otc_sd>.
      LOOP AT <fs_otc_sd> INTO DATA(lw_otc1) WHERE kunnr NE '' .
*        SELECT SINGLE * FROM zfi_zatca_cust INTO @DATA(lw_zatca_cust1) WHERE  bukrs = @lw_otc1-bukrs  AND kunnr = @lw_otc1-kunnr.
        SELECT SINGLE * FROM zfi_zatca_cust INTO @DATA(lw_zatca_cust1) WHERE  kunnr = @lw_otc1-kunnr.

        IF sy-subrc = 0.
          cx_relevant = abap_false.
        ENDIF.
        EXIT.
      ENDLOOP.


      ASSIGN COMPONENT 'DOCUMENT_ITEM' OF STRUCTURE <ls_source_data> TO <doc_item>.
      LOOP AT <doc_item> INTO DATA(doc_it) .


        SELECT SINGLE netwr FROM /dbe/splhdr_db  INTO @DATA(lv_netwr) WHERE vbeln = @doc_it-vgbel AND splnr = '0001' and kunnr = @lw_otc1-kunnr.
        IF sy-subrc = 0 AND lv_netwr = 0.
          cx_relevant = abap_false.
          EXIT.
        ENDIF.

      ENDLOOP.


    ENDIF.







  ENDMETHOD.


  method IF_EDOC_ADAPTOR~SET_FIX_VALUES.
  endmethod.


METHOD if_edoc_adaptor~set_output_data.




  DATA: ls_fi_invoice         TYPE edoc_src_data_fi_invoice,
        ls_sd_invoice         TYPE edoc_src_data_sd_invoice,
        ls_mm_invoice         TYPE edoc_src_data_invoice_verif,
        wa_edo_sa_invoice_tab TYPE edo_sa_invoice1.


  FIELD-SYMBOLS <fs_item> TYPE edo_sa_invoice_line.

  FIELD-SYMBOLS: <ls_source_data>     TYPE any,
                 <ls_output_data>     TYPE edo_sa_invoice_request_type,
                 <ls_output_data2>    TYPE edo_sa_standard_business_docum,
                 <fs_edo_sa_invoice1> TYPE edo_sa_invoice1,
                 <sd_inv>             TYPE edoc_vbrpvb.
  ASSIGN wa_edo_sa_invoice_tab  TO <fs_edo_sa_invoice1>.


  DATA ls_refer TYPE edo_sa_billing_reference.
  IF iv_interface_id EQ 'SA_INVOICE_TRANSM'.
    ASSIGN cs_output_data TO <ls_output_data>.
  ELSEIF iv_interface_id EQ 'SA_INV_SEND_REQUEST'.
    ASSIGN cs_output_data TO <ls_output_data2>.
  ELSEIF iv_interface_id EQ 'SA_INV_SEND_SIGNED'.
    ASSIGN cs_output_data TO <ls_output_data2>.
  ENDIF.
  TRY.
      CALL METHOD io_source->get_blart
        RECEIVING
          rv_blart = DATA(lv_blart).
    CATCH cx_edocument .
  ENDTRY.

  IF  lv_blart = 'DG'.
    CASE io_source->mv_source_type.
      WHEN 'FI_INVOICE'.
        ASSIGN ls_fi_invoice TO <ls_source_data>.

        io_source->get_data( IMPORTING es_data = <ls_source_data> ).

        IF ls_fi_invoice-cleareddoc_data[] IS NOT INITIAL.
          LOOP AT <ls_output_data2>-invoice ASSIGNING <fs_edo_sa_invoice1> .
            CLEAR ls_refer-invoice_document_reference-id-base-base-content.
            READ TABLE ls_fi_invoice-cleareddoc_data INTO DATA(wa_item) INDEX 1.
            IF wa_item-belnr IS NOT INITIAL.
              ls_refer-invoice_document_reference-id-base-base-content = wa_item-belnr.
            ENDIF.
            APPEND ls_refer TO <fs_edo_sa_invoice1>-billing_reference.
            EXIT.
          ENDLOOP.

        ENDIF.

      WHEN 'SD_INVOICE'.

      WHEN 'INV_VERIF'.

    ENDCASE.
  ENDIF.

  IF ( iv_edoc_type = 'SA_INV_CR' OR iv_edoc_type = 'SA_INV_SCR' ) AND  io_source->mv_source_type = 'SD_INVOICE'.

    ASSIGN ls_sd_invoice TO <ls_source_data>.

    io_source->get_data( IMPORTING es_data = <ls_source_data> ).

    IF ls_refer-invoice_document_reference-id-base-base-content IS INITIAL.
      LOOP AT <ls_output_data2>-invoice ASSIGNING <fs_edo_sa_invoice1> .
        LOOP AT ls_sd_invoice-document_item ASSIGNING <sd_inv>.
          SELECT SINGLE bstnk FROM /dbe/vbak_db INTO @DATA(lv_bstnk) WHERE vbeln = @<sd_inv>-vgbel.
          IF sy-subrc = 0. " and lv_bstnk is not INITIAL.
            IF lv_bstnk <> ''.
              ls_refer-invoice_document_reference-id-base-base-content = lv_bstnk.
              APPEND ls_refer TO <fs_edo_sa_invoice1>-billing_reference.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

  ENDIF.
ENDMETHOD.


  method IF_EDOC_ADAPTOR~SET_VALUE_MAPPING.
  endmethod.


  method IF_EDOC_ADAPTOR~RESTRICT_CANCEL.
  endmethod.
ENDCLASS.

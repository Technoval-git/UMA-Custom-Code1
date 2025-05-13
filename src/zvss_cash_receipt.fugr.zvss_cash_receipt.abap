FUNCTION ZVSS_CASH_RECEIPT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      T_DOC_LINE STRUCTURE  /DBE/T_DOC_LINE_COM
*"      T_OP_LINE STRUCTURE  /DBE/T_OP_LINE_COM
*"      T_BOOK_DOC STRUCTURE  /DBE/T_DOC_BOOK_COM
*"      T_RETURN STRUCTURE  BAPIRET2
*"  CHANGING
*"     VALUE(CS_DOC_HEAD) LIKE  /DBE/T_DOC_HEAD_COM STRUCTURE
*"        /DBE/T_DOC_HEAD_COM
*"     VALUE(CS_SESSION) LIKE  /DBE/T_SESSION_COM STRUCTURE
*"        /DBE/T_SESSION_COM
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

*INCLUDE rle_delnote_forms.
*INCLUDE rle_print_forms.

tables: NAST.




  TYPES: BEGIN OF ty_bseg,
           buzei TYPE buzei,
           shkzg TYPE shkzg,
           dmbtr TYPE dmbtr,
           mwsts TYPE hwste,
         END OF ty_bseg.

  TYPES: BEGIN OF ty_tax,
           buzei TYPE buzei,
           mwskz TYPE mwskz,
           hwste TYPE hwste,
         END OF ty_tax.

  DATA: lv_fmname             TYPE rs38l_fnam,
        lv_langu              TYPE sy-langu,
        lv_return             LIKE bapiret2,
        wa_log_wp             TYPE /dbe/t_log_wp,
        lv_archive_index      TYPE toa_dara,
        lv_archive_index_tab  TYPE tsfdara,
        lv_archive_parameters TYPE arc_params,
        lv_control_parameters TYPE ssfctrlop,
        lv_composer_param     TYPE ssfcompop,
        lv_mail_appl_obj      TYPE swotobjid,
        lv_mail_recipient     TYPE swotobjid,
        lv_mail_sender        TYPE swotobjid,
        lv_output_options     TYPE ssfcompop,
        lv_user_settings      TYPE tdbool,
        it_stxh               TYPE TABLE OF stxh,
        lv_bil_invoice        TYPE lbbil_invoice,
        lv_nast               TYPE nast,
        lv_db_data_to_read    TYPE lbbil_print_data_to_read,
        lv_hd_kond            TYPE lbbil_hd_kond,
        it_hd_kond            TYPE STANDARD TABLE OF lbbil_hd_kond WITH NON-UNIQUE KEY bil_number,
        lv_it_gen             TYPE lbbil_it_gen,
        it_it_gen             TYPE STANDARD TABLE OF lbbil_it_gen WITH NON-UNIQUE KEY bil_number itm_number,
        lv_it_kond            TYPE lbbil_it_kond,
        it_it_kond            TYPE STANDARD TABLE OF lbbil_it_kond WITH NON-UNIQUE KEY bil_number itm_number,
        lv_hd_komk            TYPE lbbil_hd_komk,
        it_hd_komk            TYPE STANDARD TABLE OF lbbil_hd_komk WITH NON-UNIQUE KEY table_line,
        la_nast               TYPE /dbe/order_print,
        lv_retcode            TYPE sy-subrc,
        ls_addr_key           LIKE addr_key,
        ls_pri_params         TYPE pri_params,
        lv_mode               TYPE sy-callr,
        ls_vbak               TYPE /dbe/vbak_com,
        ls_vat                TYPE ydbe_cash_recpt_vat,
        ls_book_doc           TYPE /dbe/t_doc_book_com,
        lv_subrc              LIKE sy-subrc,
        lt_temp_op            TYPE TABLE OF /dbe/t_op_line_com,
        ls_temp_op            TYPE /dbe/t_op_line_com.

  DATA: lv_text_type            TYPE /dbe/t_wp_text-text_type.
  DATA: ls_op_line TYPE /dbe/t_op_line_com.
  DATA: ls_billing TYPE /dbe/t_op_line_com.
  DATA: ls_op_temp TYPE /dbe/t_op_line_com.

  DATA: ls_wp_text TYPE /dbe/t_wp_text,
        ls_sh_prin TYPE sh_prin.

  DATA: lv_ordnum   TYPE /dbe/split_com-vbeln.
  DATA: lv_splitnum TYPE /dbe/split_com-splnr.
  DATA: lv_dpr_flag(1) TYPE c.
  DATA: lv_rev_doc_flag TYPE xfeld.
  DATA: lv_doc_print    TYPE /dbe/t_print.

  DATA: lt_dpr_head TYPE TABLE OF /dbe/ord_dprheader_s,
        lt_dpr_item TYPE TABLE OF /dbe/ord_dpritem_s,
        lt_split    TYPE TABLE OF /dbe/split_com,
        lt_vbap     TYPE TABLE OF /dbe/vbap_com.

  DATA: ls_dpr_head TYPE /dbe/ord_dprheader_s,
        ls_dpr_item TYPE /dbe/ord_dpritem_s,
        ls_split    TYPE /dbe/split_com,
        ls_vbap     TYPE /dbe/vbap_com.

  DATA: lt_split_act TYPE TABLE OF /dbe/split_com.
  DATA: lt_vbap_act  TYPE TABLE OF /dbe/vbap_com.
  DATA: lt_bkpf  TYPE TABLE OF bkpf,
        lt_bseg  TYPE TABLE OF bseg,
        lt_acchd TYPE TABLE OF acchd.

  DATA: lt_acct_doc TYPE TABLE OF ty_bseg,
        ls_acct_doc TYPE ty_bseg.
  DATA: lt_tax TYPE TABLE OF ty_tax,
        ls_tax TYPE ty_tax.

  FIELD-SYMBOLS:
    <bkpf>   TYPE bkpf,
    <bseg>   TYPE bseg,
    <acchd>  TYPE acchd,
    <opline> TYPE /dbe/t_op_line_com.

  CONSTANTS: fb_name(50) TYPE c VALUE '/DBE/TP_TILL_AC_BON_PRINT'.

* Clear all lokal Data first
  CLEAR:
  wa_log_wp, lv_archive_index, lv_archive_index_tab,
  lv_archive_parameters, lv_control_parameters, lv_mail_appl_obj,
  lv_mail_recipient, lv_mail_sender, lv_output_options,
  lv_user_settings, it_stxh[], lv_bil_invoice, it_hd_kond[],
  lv_hd_kond, it_it_gen[], lv_it_gen, it_it_kond[], lv_it_kond,
  lv_hd_komk, it_hd_komk[].

  lv_rev_doc_flag = cs_doc_head-rev_doc_flag.               "N.1509208
  lv_doc_print    = cs_doc_head-doc_print.
  PERFORM set_print_user_exit USING cs_doc_head
                              CHANGING lv_rev_doc_flag
                                       lv_doc_print.

  CHECK cs_doc_head-book_stat EQ 'C' OR t_op_line[] IS INITIAL. "1303592

*Bondruck durchführen ?
  IF lv_doc_print = 'X' AND lv_rev_doc_flag IS INITIAL.

* Get printer name and text sceme
    SELECT SINGLE * FROM /dbe/t_log_wp INTO wa_log_wp
                      WHERE wp_log = cs_doc_head-wp_log.
    IF sy-subrc > 0.
***      PERFORM select_msg TABLES t_return
***                     USING  '/dbe/TILL' 'E' '009'
***                            '/dbe/T_LOG_WP' space
***                            space space lv_return.
      message E009(/DBE/TILL).
*      Bitte pflegen Sie die Customizing-Tabelle /dbe/T_LOG_WP
      EXIT.
    ENDIF.

* Decide whether Down Payment
    LOOP AT t_op_line TRANSPORTING NO FIELDS WHERE umskz = 'F' AND umsks IS NOT INITIAL.
      lv_dpr_flag = 'X'.
      EXIT.
    ENDLOOP.

* Set text type
    PERFORM set_text_type USING cs_doc_head lv_dpr_flag CHANGING lv_text_type.

* Get header and footer names
    SELECT SINGLE * FROM /dbe/t_wp_text
                    INTO ls_wp_text
                    WHERE wp_log    = cs_doc_head-wp_log
                      AND doc_type  = cs_doc_head-doc_type
                      AND text_type = lv_text_type. "Bon print

    IF sy-subrc <> 0.
      MESSAGE e009(/dbe/till) WITH '/dbe/T_WP_TEXT' RAISING error.
*      Bitte pflegen Sie die Customizing-Tabelle &1
      EXIT.
    ENDIF.
    SELECT * FROM stxh  INTO CORRESPONDING FIELDS OF TABLE it_stxh
           WHERE
                 ( tdobject EQ 'TEXT' AND
                   tdname EQ ls_wp_text-name_header AND
                   tdid   EQ ls_wp_text-id_header AND
                   tdspras EQ sy-langu )
              OR ( tdobject EQ 'TEXT' AND
                   tdname EQ ls_wp_text-name_footer AND
                   tdid   EQ ls_wp_text-id_footer AND
                   tdspras EQ sy-langu ).
* Get Position Data
    lv_db_data_to_read-hd_gen = 'X'.
    lv_db_data_to_read-hd_adr = 'X'.
    lv_db_data_to_read-hd_gen_descript = 'X'.
    lv_db_data_to_read-hd_org = 'X'.
    lv_db_data_to_read-hd_part_add = 'X'.
    lv_db_data_to_read-hd_kond = 'X'.
    lv_db_data_to_read-hd_fin = 'X'.
    lv_db_data_to_read-it_gen = 'X'.
    lv_db_data_to_read-it_price = 'X'.
    lv_db_data_to_read-it_kond = 'X'.
    lv_db_data_to_read-it_fin = 'X'.
    lv_db_data_to_read-it_reford = 'X'.

    IF lv_dpr_flag IS INITIAL.
      LOOP AT t_op_line ASSIGNING <opline>.
        lv_nast-objky = <opline>-xblnr.
        lv_nast-parvw = 'RE'.
        lv_nast-parnr = <opline>-kunnr.
        lv_nast-erdat = sy-datum.
        lv_nast-eruhr = sy-uzeit.
        lv_nast-spras = sy-langu.
        lv_nast-usnam = sy-uname.

        CALL FUNCTION 'FI_DOCUMENT_READ'                    "1241556
          EXPORTING
            i_bukrs     = <opline>-bukrs
            i_belnr     = <opline>-belnr
            i_gjahr     = <opline>-gjahr
          TABLES
            t_acchd     = lt_acchd
            t_bkpf      = lt_bkpf
            t_bseg      = lt_bseg
          EXCEPTIONS
            wrong_input = 1
            not_found   = 2
            OTHERS      = 3.

        READ TABLE lt_acchd ASSIGNING <acchd> INDEX 1.

        CHECK sy-subrc EQ 0.
        IF <acchd>-awtyp <> 'BKPF'.                         "1241556
          DATA is_possible_read_bil_inv TYPE c.
          IF <acchd>-awtyp <> 'VBRK'.
            IF <opline>-xblnr IS INITIAL.
              is_possible_read_bil_inv = 'X'.
            ELSE.
              CLEAR is_possible_read_bil_inv.
            ENDIF.
          ELSE.
            lv_nast-objky = <acchd>-awref.                  "2321509
            is_possible_read_bil_inv = 'X'.
          ENDIF.

          IF is_possible_read_bil_inv = 'X'.
            CALL FUNCTION 'LB_BIL_INV_OUTP_READ_PRTDATA'
              EXPORTING
                if_bil_number         = lv_nast-objky
                is_print_data_to_read = lv_db_data_to_read
                if_parvw              = lv_nast-parvw
                if_parnr              = lv_nast-parnr
                if_language           = sy-langu
              IMPORTING
                es_bil_invoice        = lv_bil_invoice
              EXCEPTIONS
                records_not_found     = 1
                records_not_requested = 2
                OTHERS                = 3.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ELSE.
              MOVE lv_bil_invoice-hd_komk TO lv_hd_komk.
              APPEND lv_hd_komk TO it_hd_komk.
              LOOP AT lv_bil_invoice-hd_kond INTO lv_hd_kond.
                APPEND lv_hd_kond TO it_hd_kond.
                CLEAR lv_hd_kond.
              ENDLOOP.
              LOOP AT lv_bil_invoice-it_gen INTO lv_it_gen.
                APPEND lv_it_gen TO it_it_gen.
                CLEAR lv_it_gen.
              ENDLOOP.
              LOOP AT lv_bil_invoice-it_kond INTO lv_it_kond.
                APPEND lv_it_kond TO it_it_kond.
                CLEAR lv_it_kond.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.

      LOOP AT t_op_line ASSIGNING <opline>.
        CLEAR: ls_dpr_item, ls_dpr_head.

        lv_ordnum   = <opline>-zuonr+3(10).
        lv_splitnum = <opline>-zuonr+14(4).

        SELECT * FROM /dbe/split INTO CORRESPONDING FIELDS OF TABLE lt_split_act "#EC CI_NO_TRANSFORM
          WHERE vbeln = lv_ordnum
          AND   splnr = lv_splitnum.
        CHECK sy-subrc EQ 0.

        SELECT * FROM /dbe/vbap INTO CORRESPONDING FIELDS OF TABLE lt_vbap_act "#EC CI_NO_TRANSFORM
          FOR ALL ENTRIES IN lt_split_act
          WHERE vbeln = lv_ordnum
          AND   posnr = lt_split_act-posnr.
        CHECK sy-subrc EQ 0.

        CALL FUNCTION 'FI_DOCUMENT_READ'
          EXPORTING
            i_bukrs     = <opline>-bukrs
            i_belnr     = <opline>-belnr
            i_gjahr     = <opline>-gjahr
          TABLES
            t_acchd     = lt_acchd
            t_bkpf      = lt_bkpf
            t_bseg      = lt_bseg
          EXCEPTIONS
            wrong_input = 1
            not_found   = 2
            OTHERS      = 3.
        CHECK sy-subrc EQ 0.

        ls_dpr_head-vbeln = lv_ordnum.
        ls_dpr_head-splnr = lv_splitnum.
        ls_dpr_head-bukrs = <opline>-bukrs.
        ls_dpr_head-belnr = <opline>-belnr.

        READ TABLE lt_acchd ASSIGNING <acchd> INDEX 1.
        CHECK sy-subrc EQ 0.

        MOVE <acchd>-bktxt TO ls_dpr_head-bktxt.
        ls_dpr_head-awtyp = <acchd>-awtyp.
        ls_dpr_head-awref = <acchd>-awref.
        ls_dpr_head-aworg = <acchd>-aworg.

        READ TABLE lt_bkpf ASSIGNING <bkpf> INDEX 1.
        CHECK sy-subrc EQ 0.

        ls_dpr_head-gjahr = <bkpf>-gjahr.
        ls_dpr_head-monat = <bkpf>-monat.
        ls_dpr_head-waers = <bkpf>-waers.
        ls_dpr_head-budat = <bkpf>-budat.
        ls_dpr_head-bldat = <bkpf>-bldat.
        ls_dpr_head-blart = <bkpf>-blart.
        ls_dpr_head-bstat = <bkpf>-bstat.

        READ TABLE lt_bseg ASSIGNING <bseg> INDEX 1.
        CHECK sy-subrc EQ 0.

        MOVE-CORRESPONDING <bseg> TO ls_dpr_item.

        APPEND ls_dpr_item TO lt_dpr_item.
        APPEND ls_dpr_head TO lt_dpr_head.
        LOOP AT lt_split_act INTO ls_split.
          APPEND ls_split TO lt_split.
        ENDLOOP.
        LOOP AT lt_vbap_act INTO ls_vbap.
          APPEND ls_vbap TO lt_vbap.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
* get Printing Parameter
    IF wa_log_wp-spld_bon IS INITIAL.
      lv_mode = 'CURRENT'.
      CALL FUNCTION 'GET_PRINT_PARAMETERS'
        EXPORTING
          mode                   = lv_mode
          no_dialog              = 'X'
        IMPORTING
          out_parameters         = ls_pri_params
        EXCEPTIONS
          archive_info_not_found = 1
          invalid_print_params   = 2
          invalid_archive_params = 3
          OTHERS                 = 4.
      IF sy-subrc NE 0.
        lv_subrc = sy-subrc.
      ELSE.
        lv_subrc = sy-subrc.
      ENDIF.
    ELSE.
      lv_mode = 'DEFVALS'.
      CALL FUNCTION 'GET_PRINT_PARAMETERS'
        EXPORTING
          mode                   = lv_mode
          no_dialog              = 'X'
        IMPORTING
          out_parameters         = ls_pri_params
        EXCEPTIONS
          archive_info_not_found = 1
          invalid_print_params   = 2
          invalid_archive_params = 3
          OTHERS                 = 4.
      IF sy-subrc NE 0.
        lv_subrc = sy-subrc.
      ELSE.
        lv_subrc = sy-subrc.
      ENDIF.
      ls_pri_params-pdest = wa_log_wp-spld_bon.

      CALL FUNCTION 'GET_PRINT_PARAMETERS'
        EXPORTING
          no_dialog              = 'X'
          in_parameters          = ls_pri_params
          list_name              = 'NEW-LIST'
        IMPORTING
          out_parameters         = ls_pri_params
        EXCEPTIONS
          archive_info_not_found = 1
          invalid_print_params   = 2
          invalid_archive_params = 3
          OTHERS                 = 4.
      IF sy-subrc NE 0.
        lv_subrc = sy-subrc.
      ELSE.
        lv_subrc = sy-subrc.
      ENDIF.
    ENDIF.

    IF lv_subrc EQ 0.
      la_nast-mandt      = sy-mandt.
      la_nast-ldest      = ls_pri_params-pdest.
      la_nast-spras      = sy-langu.
      la_nast-usnam      = sy-uname.
      la_nast-erdat      = sy-datum.
      la_nast-eruhr      = sy-uzeit.
      la_nast-anzal      = ls_pri_params-prcop.
      la_nast-dsnam      = ls_pri_params-plist.
      la_nast-nacha      = ls_pri_params-armod.
      la_nast-dimme      = ls_pri_params-primm.
      la_nast-delet      = ls_pri_params-prrel.
      la_nast-vsztp      = '4'.
      la_nast-tdreceiver = ls_pri_params-prrec.
      la_nast-tdarmod    = '1'.
      la_nast-tdspras    = sy-langu.
*  perform form123.

*      MOVE-CORRESPONDING la_nast TO nast.
      PERFORM set_print_param USING    ls_addr_key
                              CHANGING lv_control_parameters
                                       lv_composer_param
                                       lv_mail_recipient
                                       lv_mail_sender
                                       lv_retcode.
      lv_composer_param-tdnewid = ls_pri_params-prnew.
      SELECT SINGLE * FROM sh_prin
                      INTO ls_sh_prin
                      WHERE padest EQ lv_composer_param-tddest.
      IF sy-subrc EQ 0.
        lv_composer_param-tdprinter = ls_sh_prin-lname.
      ENDIF.
    ELSE.
      lv_retcode = sy-subrc.
      PERFORM protocol_update.
      MESSAGE e200(/dbe/till).
    ENDIF.

"Start of Comment by M.Sameer 8 July 2024
*    IF lv_retcode IS INITIAL.
*        lv_langu = sy-langu.
"End of Comment by M.Sameer 8 July 2024

"START OF CODE ADDED by M.Sameer 8 July 2024
IF lv_langu <> 'E'.
    lv_langu = 'E'.
  ENDIF.
"END OF CODE ADDED by M.Sameer 8 July 2024

   IF   lv_langu = sy-langu.

*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
* Get function module name
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = ls_wp_text-fname
        IMPORTING
          fm_name            = lv_fmname
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

      IF sy-subrc <> 0.
*        PERFORM select_msg TABLES t_return
*                       USING  sy-msgid sy-msgty sy-msgno
*                              sy-msgv1 sy-msgv2
*                              sy-msgv3 sy-msgv4 lv_return.
        EXIT.
      ENDIF.
*Insert new print function module
      MOVE-CORRESPONDING lv_composer_param TO lv_output_options.

      IF cs_doc_head-bukrs = '2100' OR cs_doc_head-bukrs = '2200' OR cs_doc_head-bukrs = '2300' or cs_doc_head-bukrs = '2101'
        or cs_doc_head-bukrs = '1000'  or cs_doc_head-bukrs = '1100'  ."Added by M.Sameer on 18-08-2024
        lv_control_parameters-langu = 'A' ."yif_dbm_jet_constants=>gc_value_a.
      ENDIF.

      SELECT SINGLE taxnum FROM dfkkbptaxnum
        INTO ls_vat-cust_vat_no
        WHERE partner = cs_doc_head-kunnr
          AND taxtype = 'CA2'.

      SELECT SINGLE stceg FROM t001
        INTO ls_vat-co_vat_no
        WHERE bukrs = cs_doc_head-bukrs.

      READ TABLE t_op_line[] INTO ls_op_temp INDEX 1.
      IF sy-subrc = 0.
        READ TABLE t_op_line INTO ls_op_line WITH KEY belnr = ls_op_temp-augbl.
        IF sy-subrc = 0.
          SELECT buzei shkzg dmbtr mwsts FROM bseg
            INTO TABLE lt_acct_doc
            WHERE bukrs = ls_op_line-bukrs
              AND belnr = ls_op_line-belnr
              AND gjahr = ls_op_line-gjahr
              AND koart = 'D'.
          IF sy-subrc = 0.
            IF lv_dpr_flag IS INITIAL.
              LOOP AT lt_acct_doc INTO ls_acct_doc.
                IF ls_acct_doc-shkzg = 'S'.
                  ls_acct_doc-dmbtr = ls_acct_doc-dmbtr * -1.
                ENDIF.
                ls_vat-total = ls_vat-total + ls_acct_doc-dmbtr.
              ENDLOOP.
              LOOP AT t_op_line INTO ls_billing WHERE belnr = ls_op_line-belnr.
                SELECT buzei mwskz hwste  FROM bset
                  INTO TABLE lt_tax
                  WHERE bukrs = ls_billing-bukrs
                   AND belnr = ls_billing-belnr
                   AND gjahr = ls_billing-gjahr.
                IF sy-subrc = 0.
                  LOOP AT lt_tax INTO ls_tax.
                    READ TABLE lt_acct_doc INTO ls_acct_doc
                      WITH KEY buzei = ls_tax-buzei.
                    IF sy-subrc = 0.
                      IF ls_acct_doc-shkzg = 'S'.
                        ls_tax-hwste = ls_tax-hwste * -1.
                      ENDIF.
                      ls_vat-vat = ls_vat-vat + ls_tax-hwste.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDLOOP.
              ls_vat-gross = ls_vat-total - ls_vat-vat.
            ELSE.
              SELECT buzei mwskz hwste  FROM bset
                INTO TABLE lt_tax
                WHERE bukrs = ls_op_line-bukrs
                 AND belnr = ls_op_line-belnr
                 AND gjahr = ls_op_line-gjahr .
              LOOP AT lt_acct_doc INTO ls_acct_doc.
                IF ls_acct_doc-shkzg = 'S'.
                  ls_acct_doc-dmbtr = ls_acct_doc-dmbtr * -1.
                  ls_acct_doc-mwsts = ls_acct_doc-mwsts * -1.
                ENDIF.
                ls_vat-gross = ls_vat-gross + ls_acct_doc-dmbtr.
                ls_vat-vat = ls_vat-vat + ls_acct_doc-mwsts.
              ENDLOOP.
               ls_vat-gross = ls_vat-gross - ls_vat-vat.  " added by M.ISLAM  11/11/24
              ls_vat-total = ls_vat-gross + ls_vat-vat.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        READ TABLE t_book_doc INTO ls_book_doc INDEX 1.
        IF sy-subrc = 0.
          SELECT buzei shkzg dmbtr mwsts FROM bseg
            INTO TABLE lt_acct_doc
            WHERE bukrs = ls_book_doc-bukrs
              AND belnr = ls_book_doc-belnr
              AND gjahr = ls_book_doc-gjahr
              AND koart = 'D'.
          IF sy-subrc = 0.
            SELECT buzei mwskz hwste  FROM bset
              INTO TABLE lt_tax
              WHERE bukrs = ls_book_doc-bukrs
               AND belnr = ls_book_doc-belnr
               AND gjahr = ls_book_doc-gjahr .
            LOOP AT lt_acct_doc INTO ls_acct_doc.
              IF ls_acct_doc-shkzg = 'S'.
                ls_acct_doc-dmbtr = ls_acct_doc-dmbtr * -1.
                ls_acct_doc-mwsts = ls_acct_doc-mwsts * -1.
              ENDIF.
              ls_vat-gross = ls_vat-gross +  ls_acct_doc-dmbtr .
              ls_vat-vat = ls_vat-vat + ls_acct_doc-mwsts.
            ENDLOOP.
            ls_vat-gross = ls_vat-gross - ls_vat-vat.  " added by M.ISLAM  11/11/24
            ls_vat-total = ls_vat-gross + ls_vat-vat.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lt_tax IS NOT INITIAL.
        READ TABLE lt_tax INTO ls_tax INDEX 1.
        IF sy-subrc = 0.
          SELECT SINGLE k~kbetr FROM a003 AS a
            INNER JOIN konp AS k
            ON a~knumh = k~knumh
            INTO @DATA(lv_tax_perc)
            WHERE a~aland = 'SA'
              AND a~mwskz = @ls_tax-mwskz.
          IF sy-subrc = 0.
            lv_tax_perc = abs( lv_tax_perc / 10 ).
            DATA: lv_tax_str TYPE string.
            DATA: lv_tax_int TYPE int4.
            lv_tax_int = lv_tax_perc.
            lv_tax_str = lv_tax_int.
          ENDIF.
        ENDIF.
      ENDIF.
      IF lv_tax_str IS INITIAL.
        lv_tax_str = '0'.
      ENDIF.
      IF lv_dpr_flag IS INITIAL.

* Call print function
        CALL FUNCTION lv_fmname
          EXPORTING
            archive_index      = lv_archive_index
            archive_index_tab  = lv_archive_index_tab
            archive_parameters = lv_archive_parameters
            control_parameters = lv_control_parameters
            mail_appl_obj      = lv_mail_appl_obj
            mail_recipient     = lv_mail_recipient
            mail_sender        = lv_mail_sender
            output_options     = lv_output_options
            user_settings      = lv_user_settings
            i_till_doc_head    = cs_doc_head
            i_till_session     = cs_session
            i_langu            = lv_langu
            i_text_sc          = ls_wp_text
            i_bil_invoice      = lv_bil_invoice
            i_vbak             = ls_vbak
            is_vat             = ls_vat
            iv_tax_perc        = lv_tax_str
          TABLES
            t_till_doc_line    = t_doc_line
            t_till_op_line     = t_op_line
            t_book_doc         = t_book_doc
            t_stxh             = it_stxh
            t_hd_kond          = it_hd_kond
            t_hd_komk          = it_hd_komk
            t_it_gen           = it_it_gen
            t_it_kond          = it_it_kond
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.
        IF sy-subrc <> 0.
          lv_retcode = sy-subrc.
          PERFORM protocol_update.
*     get SmartForm protocoll and store it in the NAST protocoll
          PERFORM add_smfrm_prot.                  "INS_HP_335958
        ENDIF.

      ELSE.
* Call print function
        CALL FUNCTION lv_fmname
          EXPORTING
            archive_index      = lv_archive_index
            archive_index_tab  = lv_archive_index_tab
            archive_parameters = lv_archive_parameters
            control_parameters = lv_control_parameters
            mail_appl_obj      = lv_mail_appl_obj
            mail_recipient     = lv_mail_recipient
            mail_sender        = lv_mail_sender
            output_options     = lv_output_options
            user_settings      = lv_user_settings
            i_till_doc_head    = cs_doc_head
            i_till_session     = cs_session
            i_langu            = lv_langu
            i_text_sc          = ls_wp_text
            i_vbak             = ls_vbak
            is_vat             = ls_vat
            iv_tax_perc        = lv_tax_str
          TABLES
            t_till_doc_line    = t_doc_line
            t_till_op_line     = t_op_line
            t_book_doc         = t_book_doc
            t_stxh             = it_stxh
            t_split            = lt_split
            t_vbap             = lt_vbap
            t_dpr_head         = lt_dpr_head
            t_dpr_item         = lt_dpr_item
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.
        IF sy-subrc <> 0.
          lv_retcode = sy-subrc.
          PERFORM protocol_update.
*     get SmartForm protocoll and store it in the NAST protocoll
          PERFORM add_smfrm_prot.                  "INS_HP_335958
        ENDIF.
      ENDIF.
    ENDIF.
    IF cs_doc_head-printed IS INITIAL.
      cs_doc_head-printed = 'X'.

      CALL FUNCTION '/DBE/TDL_HEAD_MODIFY' IN UPDATE TASK
        EXPORTING
          i_head = cs_doc_head.

      MESSAGE s142(/dbe/till) WITH cs_doc_head-vbeln.
    ENDIF.
  ENDIF.
*INCLUDE rle_delnote_forms.
*INCLUDE rle_print_forms.
ENDFUNCTION.
* definition of forms
INCLUDE rle_delnote_forms.
INCLUDE rle_print_forms.




*ENDFUNCTION.

class ZCL_FI_001_CUST_VAT_INV definition
  public
  create public .

public section.

  types GTY_INTF type ZFI_CREDIT_DEBIT_NOTE_S .
  types GTY_INTF_IN type ZFI_CREDIT_DEBIT_NOTE_IN_S .

  methods CONSTRUCTOR
    importing
      !IS_INTF_IN type GTY_INTF_IN optional .
  methods M_INIT_FORM_PROCESSING
    importing
      !IS_INTF_IN type GTY_INTF_IN optional
    exporting
      !ES_INTF type GTY_INTF .
protected section.

  methods M_CLEAR .
  methods M_INITIALIZE
    importing
      !IS_INTF_IN type GTY_INTF_IN .
  methods M_PREPARE_FORM_INFO
    importing
      !IS_INTF_IN type GTY_INTF_IN optional
    exporting
      !ES_INTF type GTY_INTF .
  methods M_PREP_HEADER_INFO
    importing
      !IS_INTF_IN type GTY_INTF_IN
    changing
      !CS_INTF type GTY_INTF .
  methods M_PREP_ITEM_INFO
    importing
      !IS_INTF_IN type GTY_INTF_IN optional
    changing
      !CS_INTF type GTY_INTF optional .
  methods M_PREP_GENERAL_INFO
    importing
      !IS_INTF_IN type GTY_INTF_IN optional
    changing
      !CS_INTF type GTY_INTF optional .
  methods M_GET_LOGO_NAME
    importing
      !IS_INTF_IN type GTY_INTF_IN optional
      !IS_INTF type GTY_INTF optional
    exporting
      !EV_LOGO type TDOBNAME .
  methods M_PREP_LOGO
    importing
      !IV_BTYPE type TDBTYPE default 'BCOL'
      !IV_ID type TDIDGR default 'BMAP'
      !IV_OBJECT type TDOBJECTGR default 'GRAPHICS'
      !IV_NAME type TDOBNAME optional
    exporting
      !EV_LOGO type XSTRING .
  methods M_PREP_ADDR_ARABIC
    importing
      !IV_ADRNR type ADRNR optional
      !IV_KUNNR type KUNNR optional
    exporting
      !ET_ADDR type ZSZADR_PRINTFORM_TABLE_LINE_TT
      !EV_NAME type AD_NAME1 .
  methods M_GET_ADDRESS_FROM_ADRNR
    importing
      !IV_ADRNR type ADRNR optional
    exporting
      !EV_MAIL type AD_SMTPADR
      !ES_ADDR_TEXT type ADDR1_TEXT
      !ES_SADR type SADR
      !ES_ADDR_COMPLETE type SZADR_ADDR1_COMPLETE
      !ET_ADDR_TABLE type ZSZADR_PRINTFORM_TABLE_LINE_TT .
  methods M_PREP_QR_CODE
    importing
      !IS_INTF_IN type GTY_INTF_IN optional
      !IS_INTF type GTY_INTF optional
    exporting
      !EV_QR_CODE type XSTRING .
private section.
ENDCLASS.



CLASS ZCL_FI_001_CUST_VAT_INV IMPLEMENTATION.


  method CONSTRUCTOR.

    m_clear( ).

    m_initialize( is_intf_in = is_intf_in ).

  endmethod.


  method M_CLEAR.
  endmethod.


  METHOD M_GET_ADDRESS_FROM_ADRNR.



    DATA :

      lv_addr_number TYPE addr1_sel-addrnumber,

      lv_read_texts   TYPE xfeld,

      ls_addr_sel     TYPE addr1_sel,

      ls_addr_text   TYPE addr1_text,

      ls_sadr         TYPE sadr.

    CLEAR :

      es_addr_text,

      es_sadr.

    ls_addr_sel-addrnumber = iv_adrnr.

    CALL FUNCTION 'ADDR_GET'

      EXPORTING

        address_selection = ls_addr_sel

        read_texts        = abap_true

      IMPORTING

        address_text      = es_addr_text

        sadr              = es_sadr

      EXCEPTIONS

        parameter_error   = 1

        address_not_exist = 2

        version_not_exist = 3

        internal_error    = 4

        address_blocked   = 5

        OTHERS            = 6.

    CALL FUNCTION 'ADDR_GET_COMPLETE'

      EXPORTING

        addrnumber              = iv_adrnr

      IMPORTING

        addr1_complete          = es_addr_complete

      EXCEPTIONS

        parameter_error         = 1

        address_not_exist       = 2

        internal_error          = 3

        wrong_access_to_archive = 4

        address_blocked         = 5

        OTHERS                  = 6.

    ev_mail = VALUE #( es_addr_complete-adsmtp_tab[ 1 ]-adsmtp-smtp_addr OPTIONAL ).

    et_addr_table = VALUE #( BASE et_addr_table

                              ( line_type = '' address_line = es_sadr-name1 )    "Inserted blank line to display all lines

                              ( line_type = 'S' address_line = es_sadr-stras )

                              ( line_type = 'O' address_line = es_sadr-ort01 )

                              ( line_type = 'L' address_line = es_addr_text-landx )

                             ).

    DELETE et_addr_table WHERE address_line IS INITIAL.

  ENDMETHOD.


  METHOD m_get_logo_name.


    DATA: lv_bukrs TYPE bukrs.
    lv_bukrs = is_intf-header-bukrs.
    CASE lv_bukrs.
      WHEN '2100'.
        ev_logo = 'ALTAWKILAT_LOGO'. "'ZALTAWKILAT_LOGO'.

      when OTHERS.
        ev_logo = 'ALTAWKILAT_LOGO'. "'ZALTAWKILAT_LOGO'.

    ENDCASE.

  ENDMETHOD.


  method M_INITIALIZE.


  endmethod.


  METHOD m_init_form_processing.

    FREE es_intf.
    DATA(ls_intf_in) = is_intf_in.
    m_prepare_form_info(
    EXPORTING
    is_intf_in = ls_intf_in
    IMPORTING
    es_intf = es_intf
    ).
  ENDMETHOD.


  METHOD m_prepare_form_info.


*
*
*    Prepare header data
    m_prep_header_info(
    EXPORTING
    is_intf_in = is_intf_in
    CHANGING
    cs_intf = es_intf ).
*    Prepare item data
    m_prep_item_info(

    EXPORTING
    is_intf_in = is_intf_in
    CHANGING
    cs_intf = es_intf
    ).

*    Prepare general data
    m_prep_general_info(
        EXPORTING
        is_intf_in = is_intf_in
        CHANGING
        cs_intf = es_intf

        ).
  ENDMETHOD.


  METHOD M_PREP_ADDR_ARABIC.


    DATA :

      lt_addr_vers_org TYPE bapiad1vd_t,

      lt_address       TYPE zszadr_printform_table_line_tt.

    CALL FUNCTION 'BUPA_ADDRESS_READ_DETAIL'

      EXPORTING

        iv_partner            = iv_kunnr

*       IV_PARTNER_GUID       =

*       IV_VALID_TIME         =

*       IV_RESET_BUFFER       =

        iv_addrnumber         = iv_adrnr

*       IV_ADDRGUID           =

*       IV_XADDRESS           = 'X'

*       IV_XADTEL             = ' '

*       IV_XADFAX             = ' '

*       IV_XADTTX             = ' '

*       IV_XADTLX             = ' '

*       IV_XADSMTP            = ' '

*       IV_XADRML             = ' '

*       IV_XADX400            = ' '

*       IV_XADRFC             = ' '

*       IV_XADPRT             = ' '

*       IV_XADSSF             = ' '

*       IV_XADURI             = ' '

*       IV_XADPAG             = ' '

*       IV_XAD_REM            = ' '

*       IV_XADCOMREM          = ' '

*       IV_XADUSE             = ' '

*       IV_VALID_DATE         =

*       IV_REQ_BLK_MSG        = ' '

*     IMPORTING

*       ES_ADDRESS            =

      TABLES

*       ET_ADTEL              =

*       ET_ADFAX              =

*       ET_ADTTX              =

*       ET_ADTLX              =

*       ET_ADSMTP             =

*       ET_ADRML              =

*       ET_ADX400             =

*       ET_ADRFC              =

*       ET_ADPRT              =

*       ET_ADSSF              =

*       ET_ADURI              =

*       ET_ADPAG              =

*       ET_AD_REM             =

*       ET_COMREM             =

*       ET_ADUSE              =

        et_addr_vers_org      = lt_addr_vers_org

*       ET_ADDR_VERS_PERS     =

      EXCEPTIONS

        no_partner_specified  = 1

        no_valid_record_found = 2

        not_found             = 3

        blocked_partner       = 4

        OTHERS                = 5.

    IF sy-subrc EQ 0.

      READ TABLE lt_addr_vers_org INTO DATA(ls_addr_vers_org) WITH KEY addr_vers = 'A'.

      IF sy-subrc EQ 0.

        ev_name = ls_addr_vers_org-name.

        lt_address = VALUE #( BASE lt_address

                              ( line_type = '' address_line = ls_addr_vers_org-name )    "Inserted blank line to display all lines

*                              ( line_type = '2' address_line = ls_addr_vers_org-name_2 )

                              ( line_type = 'S' address_line = ls_addr_vers_org-street )

                              ( line_type = 'O' address_line = ls_addr_vers_org-city )

                              ( line_type = 'C' address_line = ls_addr_vers_org-county )

                             ).

        et_addr = lt_address.

      ENDIF.

    ENDIF.

    DELETE et_addr WHERE address_line IS INITIAL.

  ENDMETHOD.


  METHOD m_prep_general_info.

    DATA lv_word TYPE string.
    DATA lv_bwert TYPE bwert.
    DATA:  lv_spell_amt TYPE spell.

    DATA(ls_general) = cs_intf-general.

* Get form title

    ls_general-form_title = 'Credit Note / اشعار دائن'.

* Get logo
    m_get_logo_name(
      EXPORTING
        is_intf_in =  is_intf_in                " Credit Debit Note Input structure
        is_intf    =  cs_intf
  IMPORTING
       ev_logo       = DATA(lv_logo_name)                  " Name
    ).
    IF lv_logo_name IS NOT INITIAL.
      m_prep_logo(
        EXPORTING
          iv_btype  = 'BCOL' "'BMON'  "'BCOL'           " Graphic type
          iv_id     = 'BMAP'           " SAPscript Graphics Management: ID
          iv_object = 'GRAPHICS'       " SAPscript Graphics Management: Application object
          iv_name   = lv_logo_name           " TDIC text name
        IMPORTING
          ev_logo   = ls_general-logo
      ).
    ENDIF.

* Get QR Code
    m_prep_qr_code(
      EXPORTING
        is_intf_in = is_intf_in                 " Credit Debit Note Input structure
        is_intf    = cs_intf
        IMPORTING
        ev_qr_code   = ls_general-qr_code
    ).

* Get Totals

    LOOP AT cs_intf-items INTO DATA(ls_item).
      ls_general-tot_price    = ls_general-tot_price    + ls_item-price.
      ls_general-tot_disc_amt = ls_general-tot_disc_amt + ls_item-disc_amt.
      ls_general-tot_vat_amt  = ls_general-tot_vat_amt  + ls_item-vat_amount.
      ls_general-tot_wo_vat   = ls_general-tot_wo_vat   + ls_item-price.
      ls_general-tot_amount   = ls_general-tot_amount   + ls_item-tot_amount.
    ENDLOOP.


    READ TABLE is_intf_in-lt_item INTO DATA(lv_item) INDEX 1.


    lv_bwert = ls_general-tot_amount.
    CALL FUNCTION 'ZMM_AMOUNT_TO_WORDS'
      EXPORTING
        amount = lv_bwert   "ls_general-tot_amount
*       waers  = 'AED'
        waers  = lv_item-waers " ls_general-currency
      IMPORTING
        a_word = lv_word.
    CONDENSE lv_word.
    ls_general-tot_amount_word = lv_word.


    ls_general-e_tot_vat_amt = 'VAT Total'.
    ls_general-e_tot_wo_vat = 'Total Without VAT'.
*concatenate 'Grant Total(' 'AED'  ')' into  ls_general-E_TOT_AMOUNT .
    CONCATENATE 'Grant Total(' lv_item-waers  ')' INTO  ls_general-e_tot_amount .

    ls_general-a_tot_vat_amt = '     ضريبة القيمة المضافة  '.
    ls_general-a_tot_wo_vat = '     الإجمالي بدون الضريبة'.
    ls_general-a_tot_amount = '      المجموع الإجمالي'.

*****
*****    DATA: gs_spell     TYPE spell,
*****
*****          lv_net_val   TYPE char20,
*****
*****          lv_vat_val   TYPE char20,
*****
*****          lv_spell_val TYPE char20,
*****
*****          lv_tot1      TYPE char20,
*****
*****          lv_val       TYPE char30,
*****
*****          lv_cnt       TYPE char2.
*****
*****
*****
*****    WRITE ls_general-tot_amount TO lv_spell_val.
*****
*****    CONDENSE lv_spell_val.
*****
*****
*****    CALL FUNCTION 'SPELL_AMOUNT'
*****
*****      EXPORTING
*****
*****        amount    = lv_spell_val  "gs_header-tot_net_vat
*****
*****        currency  = 'SAR'"lv_curr
*****
******       FILLER    = ' '
*****
*****        language  = 'E'   "sy-langu
*****
*****      IMPORTING
*****
*****        in_words  = gs_spell
*****
*****      EXCEPTIONS
*****
*****        not_found = 1
*****
*****        too_large = 2
*****
*****        OTHERS    = 3.
*****
*****    IF sy-subrc = 0.
*****
*****      CONCATENATE gs_spell-word 'RIYALS AND'
*****
*****                  gs_spell-decword 'HALALA'
*****
*****             INTO ls_general-tot_amount_word
*****
*****     SEPARATED BY space.
*****
*****    ENDIF.
*****
*

**-- below code is to remove one decimal out of 3 .

*CLEAR:lv_cnt, lv_spell_val.

*

*WRITE gs_header-net_amt TO lv_spell_val.

*CONDENSE lv_spell_val.

*lv_cnt     = strlen( lv_spell_val ) .

*lv_cnt     = lv_cnt - 1.

*lv_net_val = lv_spell_val+0(lv_cnt).

*

*CLEAR:lv_cnt, lv_spell_val.

*WRITE gs_header-vat_amt TO lv_spell_val.

*CONDENSE lv_spell_val.

*lv_cnt       = strlen( lv_spell_val ) .

*lv_cnt       = lv_cnt - 1.

*lv_vat_val   = lv_spell_val+0(lv_cnt).

*

**-- End

**WRITE gs_header-net_amt     TO lv_net_val. " CURRENCY lv_curr.

**WRITE gs_header-vat_amt     TO lv_vat_val. " CURRENCY lv_curr.

**WRITE gs_header-tot_net_vat TO lv_tot_val. " CURRENCY lv_curr.

**lv_net_val = gs_header-net_amt.

**lv_vat_val = gs_header-vat_amt.

**lv_tot_val = gs_header-tot_net_vat.

*

*CONCATENATE lv_curr lv_net_val   INTO gv_net_amt_text     SEPARATED BY space.

*CONCATENATE lv_curr lv_vat_val   INTO gv_vat_amt_text     SEPARATED BY space.

*CONCATENATE lv_curr lv_tot_val   INTO gv_tot_net_vat_text SEPARATED BY space.

*--End   of Majed for Amount in Words ----*

****************************************************************************************

* Pass back the values

    cs_intf-general = ls_general.

  ENDMETHOD.


  METHOD m_prep_header_info.


data lv_country type adrc-country.

    DATA :

      ls_hdr_out   TYPE gty_intf-header,

      ls_addr1_sel TYPE addr1_sel,

      lt_address   TYPE zszadr_printform_table_line_tt.

    DATA(ls_hdr_in) = is_intf_in-ls_header.

    DATA(lt_items_in) = is_intf_in-lt_item.

    DELETE lt_items_in WHERE koart NE 'D'.

    ls_hdr_out = VALUE #( bukrs = ls_hdr_in-bukrs

                          gjahr = ls_hdr_in-gjahr

                          belnr = ls_hdr_in-belnr

                          kunnr = ls_hdr_in-konto

                          adrnr = ls_hdr_in-adrnr

                          currency = ls_hdr_in-hwaer

                          invoice_dt = ls_hdr_in-datum

                          due_date = VALUE #( lt_items_in[ 1 ]-netdt OPTIONAL )

                        ).



*****    SELECT SINGLE adrnr,stceg FROM t001 INTO @DATA(ls_t001) WHERE bukrs EQ @ls_hdr_out-bukrs.
*****
*****    IF sy-subrc = 0.
*****
*****      ls_hdr_out-taxnum = ls_t001-stceg.

*****      IF ls_t001-adrnr IS NOT INITIAL.
*****
*****        m_get_address_from_adrnr(
*****
*****        EXPORTING
*****
*****          iv_adrnr         = ls_t001-adrnr
*****
*****        IMPORTING
*****
*****          es_addr_text     = DATA(ls_addr_text_cust)
*****
*****          es_sadr          = DATA(ls_sadr_cust)
*****
*****          et_addr_table    = ls_hdr_out-en_kunnr_addr ).
*****
*****        ls_hdr_out-sellar_addr = ls_sadr_cust-name1.
*****
*****        ls_hdr_out-sellar_addr = |{ ls_hdr_out-sellar_addr }  { ls_sadr_cust-stras } { ',' } { ls_sadr_cust-pstlz } { ',' } { ls_sadr_cust-ort01 } { ',' } { ls_sadr_cust-land1 }|.
*****
*****        CONDENSE: ls_hdr_out-sellar_addr.
*****
*****      ENDIF.

*****    ENDIF.


*****    SELECT SINGLE taxnum FROM dfkkbptaxnum INTO @ls_hdr_out-vat_num WHERE partner EQ @ls_hdr_out-kunnr
*****
*****                                                                      AND taxtype EQ 'SA0'.


    SELECT SINGLE bukrs, belnr, gjahr, blart, budat,bldat,xblnr, cputm

      FROM bkpf

      INTO @DATA(ls_bkpf)

     WHERE bukrs EQ @ls_hdr_out-bukrs

       AND belnr EQ @ls_hdr_out-belnr

       AND gjahr EQ @ls_hdr_out-gjahr.

    IF sy-subrc EQ 0.

      ls_hdr_out-doc_typ    = ls_bkpf-blart.

      ls_hdr_out-invoice_dt = ls_bkpf-budat.
      ls_hdr_out-xblnr      = ls_bkpf-xblnr.
      ls_hdr_out-bldat      = ls_bkpf-bldat.


      CASE ls_bkpf-blart.

        WHEN 'DR' OR 'DG' or 'DD'. " Customer

          SELECT SINGLE name1, adrnr, stceg

            FROM kna1

            INTO @DATA(ls_kna1)

           WHERE kunnr EQ @ls_hdr_out-kunnr.

          IF sy-subrc EQ 0.

            ls_hdr_out-cust_name = ls_kna1-name1.

            DATA(lv_addrnumber) = ls_kna1-adrnr.

*            ls_hdr_out-cust_name
            ls_hdr_out-E_STceg = ls_kna1-stceg.

          ENDIF.

        WHEN 'KR' OR 'KG' or 'KD'. " Vendor

          SELECT SINGLE name1, adrnr ,stceg

            FROM lfa1

            INTO @DATA(ls_lfa1)

           WHERE lifnr EQ @ls_hdr_out-kunnr.

          IF sy-subrc EQ 0.

            ls_hdr_out-cust_name = ls_lfa1-name1.
*            ls_hdr_out-cust_name = CS_INTF-HEADER-KUNNR.

            lv_addrnumber = ls_lfa1-adrnr.
            ls_hdr_out-e_stceg = ls_lfa1-stceg.

          ENDIF.

      ENDCASE.

      IF lv_addrnumber IS NOT INITIAL.

        SELECT SINGLE house_num1 street city1 region post_code1 FROM adrc INTO ( ls_hdr_out-e_house_num,
                                                                                     ls_hdr_out-e_street,
          ls_hdr_out-e_city1, ls_hdr_out-e_region, ls_hdr_out-e_post_code1 )
            WHERE addrnumber = lv_addrnumber.

        SELECT SINGLE name1 house_num1 street city1 region post_code1 country FROM adrc INTO ( ls_hdr_out-a_cust_name, ls_hdr_out-a_house_num,
                                                                                     ls_hdr_out-a_street,
          ls_hdr_out-a_city1, ls_hdr_out-a_region, ls_hdr_out-a_post_code1, lv_country )
            WHERE addrnumber = lv_addrnumber AND nation = 'A'.

*           ls_hdr_out-a_cust_name = CS_INTF-HEADER-KUNNR.

          select single bezei from t005u into ls_hdr_out-a_region_b where spras = 'A' and land1 = lv_country and bland = ls_hdr_out-a_region.
          select single bezei from t005u into ls_hdr_out-E_region_b where spras = 'E' and land1 = lv_country and bland = ls_hdr_out-a_region.
        DATA lv_type TYPE but0id-type.
        SELECT SINGLE type , idnumber FROM but0id INTO (  @lv_type , @ls_hdr_out-E_idnumber ) WHERE partner = @ls_hdr_out-kunnr.
          ls_hdr_out-A_idnumber = ls_hdr_out-E_idnumber.
*        SELECT SINGLE text FROM tb039b INTO ls_hdr_out-E_idnumber WHERE spras = 'E' AND type = lv_type.
*        SELECT SINGLE text FROM tb039b INTO ls_hdr_out-a_idnumber WHERE spras = 'A' AND type = lv_type.
            SELECT SINGLE text FROM tb039b INTO ls_hdr_out-E_type WHERE spras = 'E' AND type = lv_type.
        SELECT SINGLE text FROM tb039b INTO ls_hdr_out-a_type WHERE spras = 'A' AND type = lv_type.
*****
*****        CLEAR : ls_addr_text_cust,ls_sadr_cust.
*****
*****        m_get_address_from_adrnr(
*****
*****        EXPORTING
*****
*****          iv_adrnr         = lv_addrnumber
*****
*****        IMPORTING
*****
*****          es_addr_text     = ls_addr_text_cust
*****
*****          es_sadr          = ls_sadr_cust
*****
*****          et_addr_table    = ls_hdr_out-en_kunnr_addr ).
*****
*****        ls_hdr_out-cust_name = |{ ls_hdr_out-cust_name } { ls_sadr_cust-name2 }|.
*****
*****        ls_hdr_out-address =  |{ ls_sadr_cust-stras } { ls_sadr_cust-pstlz }|.
*****
*****        ls_hdr_out-address = |{ ls_hdr_out-address } { ls_sadr_cust-ort01 } { ls_sadr_cust-land1 }|.
*****
*****        CONDENSE: ls_hdr_out-cust_name, ls_hdr_out-address.
*****
*****      ENDIF.
*****
*****      CLEAR: ls_bkpf, ls_kna1, ls_lfa1, lv_addrnumber.
*****
*****    ENDIF.
*****
*****    SELECT SINGLE bukrs, belnr, gjahr, rebzg, zterm, zbd1t, sgtxt FROM bseg INTO @DATA(ls_bseg) WHERE bukrs EQ @ls_hdr_out-bukrs
*****
*****                                                                             AND belnr EQ @ls_hdr_out-belnr
*****
*****                                                                             AND gjahr EQ @ls_hdr_out-gjahr
*****
*****                                                                             AND koart EQ 'D'.
*****
*****    IF sy-subrc EQ 0.
*****
*****      ls_hdr_out = VALUE #( BASE ls_hdr_out
*****
*****                            sgtxt = ls_bseg-sgtxt
*****
*****                            zterm = ls_bseg-zterm
*****
*****                            cash_disc_days = ls_bseg-zbd1t
*****
*****                           ).
*****
*****      SELECT SINGLE text1 FROM t052u INTO @ls_hdr_out-zterm_text
*****
*****        WHERE spras EQ @sy-langu AND zterm EQ @ls_bseg-zterm." AND ztagg
*****
      ENDIF.

    ENDIF.
    cs_intf-header = ls_hdr_out.




  ENDMETHOD.


  METHOD m_prep_item_info.


    DATA(lt_items_in) = is_intf_in-lt_item.

    DATA(lt_items_out) = cs_intf-items.

    DATA ls_items_out TYPE zfi_credit_debit_itm_s.

    DATA(ls_hdr_out) = cs_intf-header.

data lv_vat_rate type char6.

    SELECT g~bukrs,

           g~belnr,

           g~gjahr,

           g~buzei,

           g~buzid,

           g~sgtxt,

           g~dmbtr,

           g~gvtyp,

           g~koart

      FROM bseg AS g INNER JOIN @lt_items_in AS lt_items_in

        ON ( lt_items_in~bukrs = g~bukrs AND

             lt_items_in~belnr = g~belnr AND

             lt_items_in~gjahr = g~gjahr )

     ORDER BY g~bukrs, g~belnr, g~gjahr, g~buzei

      INTO TABLE @DATA(lt_items_bseg).

    IF sy-subrc EQ 0.

      LOOP AT lt_items_bseg ASSIGNING FIELD-SYMBOL(<lfs_items_bseg>).

        IF <lfs_items_bseg>-koart EQ 'D' OR " Customer

           <lfs_items_bseg>-koart EQ 'K'.   " Vendor

          DATA(lv_tot_amount) = <lfs_items_bseg>-dmbtr.

          ls_items_out-sgtxt = <lfs_items_bseg>-sgtxt.

          CONTINUE.

        ELSEIF <lfs_items_bseg>-buzid EQ 'T'.

          DATA(lv_vat_amount) = <lfs_items_bseg>-dmbtr.

          CONTINUE.

        ELSE.

          CONTINUE.

        ENDIF.

      ENDLOOP.

      ls_items_out-tot_amount = lv_tot_amount.

      ls_items_out-vat_amount = lv_vat_amount.

      ls_items_out-price      = ls_items_out-tot_wo_vat = lv_tot_amount - lv_vat_amount.

 lv_vat_rate   = ( ls_items_out-vat_amount / ls_items_out-price ) * 100.
*      ls_items_out-vat_rate   = ( ls_items_out-vat_amount / ls_items_out-price ) * 100.
      CONCATENATE lv_vat_rate '%' INTO ls_items_out-vat_rate.

      APPEND ls_items_out TO lt_items_out.

      CLEAR: ls_items_out.

    ENDIF.

    cs_intf-items = lt_items_out.

  ENDMETHOD.


  METHOD m_prep_logo.


    cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp(
    EXPORTING
     p_object = iv_object
     p_name = iv_name
    p_id  = iv_id
    p_btype = iv_btype

    RECEIVING
    p_bmp = ev_logo
    EXCEPTIONS
    not_found = 1
    internal_error = 2
    OTHERS = 3
    ).
  ENDMETHOD.


  METHOD M_PREP_QR_CODE.


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

      lv_gjahr TYPE gjahr.

    CLEAR ev_qr_code.

    "Fill this variable with relevant Billing Document Number

    "along with leading zeros

    lv_belnr = is_intf-header-belnr.

    lv_bukrs = is_intf-header-bukrs.

    lv_gjahr = is_intf-header-gjahr.

    cl_edoc_source_fi_invoice=>pack_key(

    EXPORTING

     iv_bukrs = lv_bukrs

    iv_gjahr = lv_gjahr

    iv_belnr = lv_belnr

    IMPORTING ev_key = lv_source_key ).

*    ev_QR_code = lv_source_key.

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

  ENDMETHOD.
ENDCLASS.

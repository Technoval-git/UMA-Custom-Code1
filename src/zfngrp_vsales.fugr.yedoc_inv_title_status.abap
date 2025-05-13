FUNCTION yedoc_inv_title_status .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(SOURCE_KEY) TYPE  EDOC_SOURCE_KEY
*"     REFERENCE(PARTNER) TYPE  BU_PARTNER OPTIONAL
*"     REFERENCE(IS_QR) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     REFERENCE(APPROVED) TYPE  CHAR1
*"     REFERENCE(TITLE_EN) TYPE  CHAR30
*"     REFERENCE(TITLE_AR) TYPE  CHAR30
*"     REFERENCE(PERSON) TYPE  CHAR1
*"     REFERENCE(LS_QR) TYPE  STRING
*"----------------------------------------------------------------------


  DATA: lv_source_key  TYPE edoc_source_key,
        lv_edoc_guid   TYPE edoc_guid,
        lv_edoc_type   TYPE edoc_type,
        ls_return      TYPE int1,
        lv_proc_status TYPE edoc_status.
  " Internal display of INPUT, any category

* break tech2.
  SELECT SINGLE vbeln, fkdat, erdat, fkart, erzet, bukrs, vbtyp FROM vbrk
    INTO @DATA(ls_vbrk)
    WHERE vbeln = @source_key.
  IF sy-subrc EQ 0.

  ENDIF.
  SELECT SINGLE * FROM edosaintactdate INTO @DATA(ls_efind) WHERE bukrs = @ls_vbrk-bukrs AND act_date LE @ls_vbrk-fkdat. "changing this to billing date we need it for old invoices QRcode
  IF sy-subrc EQ 0.
    CLEAR: lv_edoc_type,lv_edoc_guid,lv_proc_status.
    SELECT SINGLE edoc_guid edoc_type proc_status FROM edocument INTO ( lv_edoc_guid, lv_edoc_type, lv_proc_status )
     WHERE source_key = source_key.
**************************
*    IF sy-subrc EQ 0 .
*      IF ls_vbrk-bukrs  = '2100'.
*        IF lv_edoc_type EQ 'SA_INV_SI' OR lv_edoc_type EQ 'SA_INV_SCR' OR lv_edoc_type  EQ 'SA_INV_SDB'. "if Simplified  invoices then no need validation
*          approved = 'X'.
*        ELSEIF   lv_proc_status = 'ACCEPTED'..
*          approved = 'X'.
*        ENDIF.
*      ELSEIF  lv_proc_status = 'ACCEPTED'..
*        approved = 'X'.
*      ENDIF.
*
*    ENDIF.
**************************
    IF sy-subrc EQ 0 .
      IF ls_vbrk-bukrs  = '2100'.
        IF lv_edoc_type EQ 'SA_INV_SI' OR lv_edoc_type EQ 'SA_INV_SCR' OR lv_edoc_type  EQ 'SA_INV_SDB'. "if Simplified invoices then no need validation
          approved = 'X'.
        ELSEIF lv_proc_status = 'ACCEPTED'.
          approved = 'X'.
        ENDIF.
      ELSEIF ls_vbrk-bukrs  = '2200'.
        IF lv_proc_status = 'ACCEPTED'.
          approved = 'X'.
        ENDIF.
      ELSE.
        SELECT SINGLE bukrs, fkart FROM zbil_typ_cash INTO @DATA(zbil_typ)  "This will return that the invoice is cash type for a particular company code
          WHERE bukrs = @ls_vbrk-bukrs
            AND fkart = @ls_vbrk-fkart.
        IF sy-subrc = 0.  "no need zatca approval for cash invoices for particular companies mentioned in zbil_typ_cash
*          approved = 'X'.
          IF is_qr <> 'X'.
            CALL FUNCTION 'DEQUEUE_E_EDOC_SOURCE'
              EXPORTING
*               MODE_EDOC_SRC_HEADER       = 'E'
*               LAND          =
                bukrs         = ls_vbrk-bukrs
                source_type   = 'SD_INVOICE'
                source_key    = source_key
*               X_LAND        = ' '
                x_bukrs       = abap_true
                x_source_type = abap_true
                x_source_key  = abap_true
*               _SCOPE        = '3'
*               _SYNCHRON     = ' '
*               _COLLECT      = ' '
              .
            CALL FUNCTION 'YEDOC_INV_SIMP_SIGNED'
              EXPORTING
                p_act     = 'SIGN'
                p_proc    = 'SASIINV'
*               p_bukrs   = ls_vbrk-bukrs
*               p_cre_date = ls_vbrk-erdat
                p_prsta   = 'CREATED'
*               p_cpu_pe  = 10
*               p_thread  = 10
                p_billno  = ls_vbrk-vbeln
*               p_tot_vat =
*               p_tot_inv_amt =
              IMPORTING
                ls_qr     = ls_qr
                ls_return = ls_return.
            IF ls_return = 0.
              approved = 'X'.
            ENDIF.
          ELSE.
            approved = 'X'.
          ENDIF.
        ELSEIF lv_proc_status = 'ACCEPTED'.
          approved = 'X'.
        ENDIF.
      ENDIF.

    ENDIF.
    IF lv_edoc_type IS NOT INITIAL.
      SELECT SINGLE * FROM yedoc_inv_titles INTO @DATA(ls_yedoc_inv_titles) WHERE bukrs = @ls_vbrk-bukrs AND edoc_type = @lv_edoc_type.
      IF sy-subrc EQ 0.
        title_en = ls_yedoc_inv_titles-title_en.
        title_ar = ls_yedoc_inv_titles-title_ar.
      ENDIF.
    ENDIF.

  ELSE.

    approved = 'X'.
  ENDIF.
*    ENDIF.


*--bp category
*    IF partner IS NOT INITIAL.
*      SELECT SINGLE * FROM but000 INTO @DATA(ls_but000) WHERE partner = @partner.
*      IF sy-subrc EQ 0 AND ls_but000-type = '1'.
*        person = 'X'.
*      ENDIF.
*    ENDIF.
*  IF  title_en IS INITIAL AND  title_ar IS INITIAL.
*    IF person = 'X'.
*      title_en = 'Tax Invoice'.
*      title_ar = 'فاتورة ضريبة'.
*    ELSE.
*      title_en = 'Simplified Tax Invoice'.
*      title_ar = 'فاتورة ضريبة مبسطة'.
*    ENDIF.
*  ENDIF.


ENDFUNCTION.

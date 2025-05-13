FUNCTION zvss_fi_doc_status_fm.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_BILLING_NO) TYPE  VBELN OPTIONAL
*"     REFERENCE(IV_LOGSYS) TYPE  ACCHD-AWSYS DEFAULT SPACE
*"     REFERENCE(IV_BUKRS) TYPE  ACCIT-BUKRS OPTIONAL
*"     REFERENCE(IV_GJAHR) TYPE  BSEG-GJAHR OPTIONAL
*"     REFERENCE(IV_FKDAT) TYPE  VBRK-FKDAT OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_CLEARED) TYPE  BOOLEAN
*"----------------------------------------------------------------------

  DATA: lv_xblnr  TYPE xblnr1,
        lv_status TYPE char1,
        lv_gjahr  TYPE bseg-gjahr,
        da_gjahr  LIKE t009y-gjahr,
        da_poper  LIKE t009-anzbp.

  DATA: BEGIN OF xbseg OCCURS 1.
          INCLUDE STRUCTURE bseg.
  DATA: END   OF xbseg.
*
  DATA: BEGIN OF xbkpf OCCURS 1.
          INCLUDE STRUCTURE bkpf.
  DATA: END OF xbkpf.
  DATA: BEGIN OF lt_bkpf OCCURS 1.
  DATA:   belnr LIKE bkpf-belnr.
  DATA: END OF lt_bkpf.
  DATA: BEGIN OF lt_bseg OCCURS 1.
  DATA:   belnr LIKE bseg-belnr.
  DATA: END OF lt_bseg.
  lv_xblnr = iv_billing_no.
  lv_gjahr = iv_gjahr.

  CALL FUNCTION 'FI_DOCUMENT_READ'
    EXPORTING
      i_awtyp     = 'VBRK'
      i_awref     = iv_billing_no
      i_awsys     = iv_logsys
      i_bukrs     = iv_bukrs
      i_gjahr     = lv_gjahr
    TABLES
      t_bkpf      = xbkpf
      t_bseg      = xbseg
    EXCEPTIONS
      wrong_input = 1
      not_found   = 2.

  DESCRIBE TABLE xbkpf LINES sy-tabix.
  IF sy-tabix NE 0.
*         Delete documents from other fiscal year
    IF sy-tabix > 1.
      CALL FUNCTION 'FI_PERIOD_DETERMINE'
        EXPORTING
          i_budat        = iv_fkdat
          i_bukrs        = iv_bukrs
        IMPORTING
          e_gjahr        = da_gjahr
          e_poper        = da_poper
        EXCEPTIONS
          fiscal_year    = 1
          period         = 2
          period_version = 3
          posting_period = 4
          special_period = 5
          version        = 6
          posting_date   = 7
          OTHERS         = 8.
      IF sy-subrc = 0.
        CONCATENATE da_gjahr da_poper INTO lv_gjahr.
        LOOP AT xbkpf WHERE gjahr EQ lv_gjahr.
          lt_bkpf-belnr = xbkpf-belnr.
          APPEND lt_bkpf.
        ENDLOOP.
        LOOP AT lt_bkpf.
          DELETE xbkpf WHERE belnr EQ lt_bkpf-belnr AND
                             gjahr NE lv_gjahr.
        ENDLOOP.
        LOOP AT xbseg WHERE gjahr EQ lv_gjahr.
          lt_bseg-belnr = xbseg-belnr.
          APPEND lt_bseg.
        ENDLOOP.
        LOOP AT lt_bseg.
          DELETE xbseg WHERE belnr EQ lt_bseg-belnr AND
                             gjahr NE lv_gjahr.
        ENDLOOP.
      ENDIF.
    ENDIF.
    LOOP AT xbkpf.
      CLEAR lv_status.
      LOOP AT xbseg WHERE bukrs EQ xbkpf-bukrs
                    AND   belnr EQ xbkpf-belnr
                    AND   gjahr EQ xbkpf-gjahr
                    AND   ( koart EQ 'D' OR koart EQ 'K' ).
      ENDLOOP.
      IF sy-subrc NE 0.
*          l_xdoc_num-status = 'C'.
        lv_status = abap_true.
      ELSE.
        LOOP AT xbseg WHERE NOT augbl IS INITIAL
                      AND bukrs EQ xbkpf-bukrs
                      AND   ( koart EQ 'D' OR koart EQ 'K' ).
        ENDLOOP.
        IF NOT sy-subrc IS INITIAL.
*               SET STATUS TO 'No items are cleared'
          lv_status = abap_false.
          EXIT.
        ELSE.
          LOOP AT xbseg WHERE augbl IS INITIAL
                        AND bukrs EQ xbkpf-bukrs
                        AND   umskz NE 'A'
                        AND   vorgn NE 'AZUM'
                        AND   ( koart EQ 'D' OR koart EQ 'K' ).
          ENDLOOP.
          IF NOT sy-subrc IS INITIAL.
*                 Set status to 'All items are cleared'
            lv_status = abap_true.
          ELSE.
            EXIT.
          ENDIF.
        ENDIF.
* Otherwise: If there are customer/vendor positions where AUGBL is
* filled and some other ones where AUGBL is blank then set status
* to 'Partially cleared'
        IF lv_status <> abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ELSE.
    lv_status = abap_false.
  ENDIF.

  ev_cleared = lv_status.




ENDFUNCTION.

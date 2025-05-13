"Name: \TY:/DBE/CL_TILL_ACTION_IMPL\ME:FILL_SCREEN_0300\SE:END\EI
ENHANCEMENT 0 ZFI_VSS_CASHDESK_ENH.

  SELECT SINGLE * FROM /dbe/t_wp_paytyp INTO @DATA(lv_paytyp) WHERE wp_log EQ @is_doc_head-wp_log AND
                                                                  payment_type EQ @is_doc_head-payment_type.
  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM zvss_house_bank INTO @DATA(lv_house_bank) WHERE bukrs EQ @is_doc_head-bukrs AND
                                                                         wp_log EQ @is_doc_head-wp_log AND
                                                                         payment_type EQ @is_doc_head-payment_type.
    IF sy-subrc EQ 0.
*      PERFORM bdc_dynpro  IN PROGRAM /DBE/sapltill_book    USING 'SAPMF05A' '0300'.

*      DELETE bdcdata WHERE fval = '=SL'.
*
*      PERFORM bdc_field   IN PROGRAM /DBE/sapltill_book    USING 'BDC_OKCODE'
*                                 '=ZK'.
      PERFORM bdc_field   IN PROGRAM /dbe/sapltill_book     USING 'BSEG-HBKID'
                                     lv_house_bank-hbkid.
      PERFORM bdc_field   IN PROGRAM /dbe/sapltill_book     USING 'BSEG-HKTID'
                                     lv_house_bank-hktid.
*      PERFORM bdc_field   IN PROGRAM /dbe/sapltill_book     USING 'DKACB-FMORE'
*                                    'X'.
*      PERFORM bdc_dynpro IN PROGRAM /dbe/sapltill_book    USING 'SAPLKACB' '0002'.
*      PERFORM bdc_field  IN PROGRAM /dbe/sapltill_book     USING 'BDC_CURSOR'
*                                    'COBL-KOSTL'.
*      PERFORM bdc_field  IN PROGRAM /dbe/sapltill_book     USING 'BDC_OKCODE'
*                                    '=ENTE'.
*      PERFORM bdc_dynpro  IN PROGRAM /dbe/sapltill_book    USING 'SAPMF05A' '0330'.
*      PERFORM bdc_field   IN PROGRAM /dbe/sapltill_book     USING 'BDC_CURSOR'
*                                    'BSEG-XREF3'.
**      PERFORM bdc_field   IN PROGRAM /dbe/sapltill_book    USING 'BDC_OKCODE'
**                                    '=BU'.
*
*      PERFORM bdc_field   IN PROGRAM /dbe/sapltill_book     USING 'BSEG-XREF3'
*                                     lv_house_bank-spanid.

    ENDIF.
  ENDIF.

  FREE MEMORY ID 'ZCASH'.

ENDENHANCEMENT.

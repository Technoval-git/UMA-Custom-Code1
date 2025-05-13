*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF60 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_TAX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_calculate_tax ."using er_data_changed .
  DATA: lv_netvalue   TYPE rmwwr,
        lt_taxes      TYPE TABLE OF rtax1u15,
        ls_taxes      LIKE LINE OF lt_taxes,
        lv_taxamount  LIKE vlcactdata_head_s-tax_amount,
        lv_bukrs      TYPE bkpf-bukrs,
        lv_werks      TYPE werks,
        lv_returncode TYPE sy-subrc,
        lv_index      TYPE i,
        lv_old_value  TYPE rmwwr,
        lv_wrbtr_temp TYPE wrbtr.

  FIELD-SYMBOLS : <ls_invoice_info>     LIKE LINE OF gt_ininvoice_info,
                  <ls_invoice_old_info> LIKE LINE OF gt_ininvoice_info.

  IF vlcactdata_head_s-tax_code IS INITIAL.
*   Tax not calculated, fill tax code first.
    MESSAGE i227(/dbe/vehicle_master).
  ENDIF.

  LOOP AT gt_ininvoice_info ASSIGNING <ls_invoice_info>.
    lv_index = lv_index + 1.
    IF ( <ls_invoice_info>-tax_amount IS INITIAL OR <ls_invoice_info>-gross_amount IS INITIAL )
         AND vlcactdata_head_s-tax_code IS NOT INITIAL.
* tax code filled, tax not, we calculate it
*   Get company code from plant
      MOVE <ls_invoice_info>-werks TO lv_werks.
      CALL FUNCTION 'VELO25_DETERM_BUKRS_FROM_WERKS'
        EXPORTING
          werks_iv  = lv_werks
        IMPORTING
          bukrs_ev  = lv_bukrs
*         BWKEY_EV  =
*         WAERS_EV  =
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      IF <ls_invoice_info>-gross_amount IS INITIAL AND NOT <ls_invoice_info>-netpr IS INITIAL.
*   calculate from net price
        lv_wrbtr_temp = lv_netvalue = <ls_invoice_info>-netpr.
        CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
          EXPORTING
            i_bukrs           = lv_bukrs
            i_mwskz           = vlcactdata_head_s-tax_code
*           I_TXJCD           = ' '
            i_waers           = <ls_invoice_info>-currency
            i_wrbtr           = lv_wrbtr_temp
*           I_ZBD1P           = 0
*           I_PRSDT           =
*           I_PROTOKOLL       =
*           I_TAXPS           =
*           I_ACCNT_EXT       =
*       IMPORTING
*           E_FWNAV           =
*           E_FWNVV           =
*           E_FWSTE           =
*           E_FWAST           =
          TABLES
            t_mwdat           = lt_taxes
          EXCEPTIONS
            bukrs_not_found   = 1
            country_not_found = 2
            mwskz_not_defined = 3
            mwskz_not_valid   = 4
            ktosl_not_found   = 5
            kalsm_not_found   = 6
            parameter_error   = 7
            knumh_not_found   = 8
            kschl_not_found   = 9
            unknown_error     = 10
            account_not_found = 11
            txjcd_not_valid   = 12
            OTHERS            = 13.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          <ls_invoice_info>-gross_amount = lv_netvalue.
          CLEAR <ls_invoice_info>-tax_amount.
          LOOP AT lt_taxes INTO ls_taxes.
            <ls_invoice_info>-gross_amount = <ls_invoice_info>-gross_amount + ls_taxes-wmwst.
            <ls_invoice_info>-tax_amount = <ls_invoice_info>-tax_amount + ls_taxes-wmwst.
          ENDLOOP.
*       Tax (re)calculated using net price.
          MESSAGE s225(/dbe/vehicle_master).
        ENDIF.

      ELSEIF NOT <ls_invoice_info>-gross_amount IS INITIAL.
        lv_wrbtr_temp = <ls_invoice_info>-gross_amount.

*   calculate from gross amount
        CALL FUNCTION 'CALCULATE_TAX_FROM_GROSSAMOUNT'
          EXPORTING
            i_bukrs                 = lv_bukrs
            i_mwskz                 = vlcactdata_head_s-tax_code
*           I_TXJCD                 = ' '
            i_waers                 = <ls_invoice_info>-currency
            i_wrbtr                 = lv_wrbtr_temp
*           I_ZBD1P                 = 0
*           I_PRSDT                 =
*           I_PROTOKOLL             =
*           I_TAXPS                 =
*           I_ACCNT_EXT             =
*           IS_ENHANCEMENT          =
*       IMPORTING
*           E_FWNAV                 =
*           E_FWNVV                 =
*           E_FWSTE                 =
*           E_FWAST                 =
          TABLES
            t_mwdat                 = lt_taxes
          EXCEPTIONS
            bukrs_not_found         = 1
            country_not_found       = 2
            mwskz_not_defined       = 3
            mwskz_not_valid         = 4
            account_not_found       = 5
            different_discount_base = 6
            different_tax_base      = 7
            txjcd_not_valid         = 8
            not_found               = 9
            ktosl_not_found         = 10
            kalsm_not_found         = 11
            parameter_error         = 12
            knumh_not_found         = 13
            kschl_not_found         = 14
            unknown_error           = 15
            OTHERS                  = 16.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          <ls_invoice_info>-netpr = <ls_invoice_info>-gross_amount.
          CLEAR <ls_invoice_info>-tax_amount.
          LOOP AT lt_taxes INTO ls_taxes.
            <ls_invoice_info>-netpr = <ls_invoice_info>-netpr - ls_taxes-wmwst.
            <ls_invoice_info>-tax_amount = <ls_invoice_info>-tax_amount + ls_taxes-wmwst.
          ENDLOOP.
*       Tax (re)calculated using gross price.
          MESSAGE s226(/dbe/vehicle_master).
        ENDIF.
      ELSE.
*     NO amount given, no tax calculation required.
      ENDIF.
    ELSEIF vlcactdata_head_s-tax_code IS NOT INITIAL.
*   calculate from gross amount, check if tax amount is OK
*   Get company code from plant
      MOVE <ls_invoice_info>-werks TO lv_werks.
      CALL FUNCTION 'VELO25_DETERM_BUKRS_FROM_WERKS'
        EXPORTING
          werks_iv  = lv_werks
        IMPORTING
          bukrs_ev  = lv_bukrs
*         BWKEY_EV  =
*         WAERS_EV  =
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      IF gv_netprice_flag IS NOT INITIAL.
*   calculate from net price
        lv_wrbtr_temp = lv_netvalue = <ls_invoice_info>-netpr.
        CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
          EXPORTING
            i_bukrs           = lv_bukrs
            i_mwskz           = vlcactdata_head_s-tax_code
*           I_TXJCD           = ' '
            i_waers           = <ls_invoice_info>-currency
            i_wrbtr           = lv_wrbtr_temp
*           I_ZBD1P           = 0
*           I_PRSDT           =
*           I_PROTOKOLL       =
*           I_TAXPS           =
*           I_ACCNT_EXT       =
*       IMPORTING
*           E_FWNAV           =
*           E_FWNVV           =
*           E_FWSTE           =
*           E_FWAST           =
          TABLES
            t_mwdat           = lt_taxes
          EXCEPTIONS
            bukrs_not_found   = 1
            country_not_found = 2
            mwskz_not_defined = 3
            mwskz_not_valid   = 4
            ktosl_not_found   = 5
            kalsm_not_found   = 6
            parameter_error   = 7
            knumh_not_found   = 8
            kschl_not_found   = 9
            unknown_error     = 10
            account_not_found = 11
            txjcd_not_valid   = 12
            OTHERS            = 13.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          READ TABLE gt_ininvoice_old_info ASSIGNING <ls_invoice_old_info> INDEX lv_index.
          IF sy-subrc = 0.
            lv_old_value = <ls_invoice_old_info>-netpr.
            CALL FUNCTION 'MRM_TOLERANCE_CHECK'
              EXPORTING
                i_akt_wert           = lv_old_value
                i_bukrs              = lv_bukrs
                i_tolsl              = 'BD' " Form small differences automatically
                i_vergleichswert     = lv_netvalue
              IMPORTING
                e_returncode         = lv_returncode
              EXCEPTIONS
                tolerance_not_active = 1
                OTHERS               = 2.
            IF lv_returncode = 0 AND sy-subrc = 0.
              CONTINUE.
            ENDIF.
          ENDIF.
          <ls_invoice_info>-gross_amount = lv_netvalue.
          CLEAR <ls_invoice_info>-tax_amount.
          LOOP AT lt_taxes INTO ls_taxes.
            <ls_invoice_info>-gross_amount = <ls_invoice_info>-gross_amount + ls_taxes-wmwst.
            <ls_invoice_info>-tax_amount = <ls_invoice_info>-tax_amount + ls_taxes-wmwst.
          ENDLOOP.
*       Tax (re)calculated using net price.
          MESSAGE s225(/dbe/vehicle_master).
        ENDIF.
      ELSEIF gv_grossamt_flag IS NOT INITIAL.
        lv_wrbtr_temp = <ls_invoice_info>-gross_amount.
        CALL FUNCTION 'CALCULATE_TAX_FROM_GROSSAMOUNT'
          EXPORTING
            i_bukrs                 = lv_bukrs
            i_mwskz                 = vlcactdata_head_s-tax_code
*           I_TXJCD                 = ' '
            i_waers                 = <ls_invoice_info>-currency
            i_wrbtr                 = lv_wrbtr_temp
*           I_ZBD1P                 = 0
*           I_PRSDT                 =
*           I_PROTOKOLL             =
*           I_TAXPS                 =
*           I_ACCNT_EXT             =
*           IS_ENHANCEMENT          =
*       IMPORTING
*           E_FWNAV                 =
*           E_FWNVV                 =
*           E_FWSTE                 =
*           E_FWAST                 =
          TABLES
            t_mwdat                 = lt_taxes
          EXCEPTIONS
            bukrs_not_found         = 1
            country_not_found       = 2
            mwskz_not_defined       = 3
            mwskz_not_valid         = 4
            account_not_found       = 5
            different_discount_base = 6
            different_tax_base      = 7
            txjcd_not_valid         = 8
            not_found               = 9
            ktosl_not_found         = 10
            kalsm_not_found         = 11
            parameter_error         = 12
            knumh_not_found         = 13
            kschl_not_found         = 14
            unknown_error           = 15
            OTHERS                  = 16.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          READ TABLE gt_ininvoice_old_info ASSIGNING <ls_invoice_old_info> INDEX lv_index.
          IF sy-subrc = 0.
            lv_old_value = <ls_invoice_old_info>-gross_amount.
            CALL FUNCTION 'MRM_TOLERANCE_CHECK'
              EXPORTING
                i_akt_wert           = lv_old_value
                i_bukrs              = lv_bukrs
                i_tolsl              = 'BD' " Form small differences automatically
                i_vergleichswert     = <ls_invoice_info>-gross_amount
              IMPORTING
                e_returncode         = lv_returncode
              EXCEPTIONS
                tolerance_not_active = 1
                OTHERS               = 2.
            IF lv_returncode = 0 AND sy-subrc = 0.
              CONTINUE.
            ENDIF.
          ENDIF.
          <ls_invoice_info>-netpr = <ls_invoice_info>-gross_amount.
          CLEAR <ls_invoice_info>-tax_amount.
          LOOP AT lt_taxes INTO ls_taxes.
            <ls_invoice_info>-netpr = <ls_invoice_info>-netpr - ls_taxes-wmwst.
            <ls_invoice_info>-tax_amount = <ls_invoice_info>-tax_amount + ls_taxes-wmwst.
          ENDLOOP.
*       Tax (re)calculated using gross price.
          MESSAGE s226(/dbe/vehicle_master).
        ENDIF.
      ELSEIF gv_taxamount_flag IS NOT INITIAL.
        READ TABLE gt_ininvoice_old_info ASSIGNING <ls_invoice_old_info> INDEX lv_index.
        IF sy-subrc = 0.
          IF <ls_invoice_old_info>-tax_amount <> <ls_invoice_info>-tax_amount.
            MESSAGE s228(/dbe/vehicle_master) WITH <ls_invoice_info>-tax_amount <ls_invoice_old_info>-tax_amount.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR : gv_inc_flag, gv_tax_amount, gv_grossamount ,gv_netprice.

* Collect the prices and calculate thetax amount an dgross amount at header level.
  LOOP AT gt_ininvoice_info ASSIGNING <ls_invoice_info>.
    <ls_invoice_info>-tax_code = vlcactdata_head_s-tax_code.
    gv_netprice     = gv_netprice    + <ls_invoice_info>-netpr.
    gv_grossamount  = gv_grossamount + <ls_invoice_info>-gross_amount.
    gv_tax_amount   = gv_tax_amount   + <ls_invoice_info>-tax_amount. "#EC CI_FLDEXT_OK[2610650]
    gv_inc_flag = abap_true.
  ENDLOOP.

ENDFORM.                    " F_CALCULATE_TAX

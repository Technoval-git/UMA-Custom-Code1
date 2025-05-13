*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI59 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CALCULATE_TAX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE calculate_tax INPUT.

  PERFORM calculate_tax_ac.

ENDMODULE.                 " CALCULATE_TAX  INPUT
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_TAX_AC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM calculate_tax_ac .

  DATA: lv_bukrs_adc    TYPE bkpf-bukrs,
        lv_netvalue_adc TYPE wrbtr,
        lt_taxes_adc    TYPE TABLE OF rtax1u15,
        ls_taxes_adc    LIKE LINE OF lt_taxes_adc,
        lv_werks_adc    TYPE werks,
        lv_tax_amount   TYPE /dbe/wmwst,
        lv_valid_adc    TYPE boole_d.

  FIELD-SYMBOLS : <ls_ac_post> LIKE LINE OF gt_ac_post.

  CLEAR : ls_ac_post ,lv_tax_amount.

  IF gv_netamt < '0'.
    RETURN.
  ENDIF.

*  IF gv_netamt > '0'.

  LOOP AT gt_ac_post ASSIGNING <ls_ac_post>.
    IF vlcactdata_head_s-tax_code IS NOT INITIAL.
*   Get company code from plant
      MOVE vlcactdata_head_s-werks TO lv_werks_adc.
      CALL FUNCTION 'VELO25_DETERM_BUKRS_FROM_WERKS'
        EXPORTING
          werks_iv  = lv_werks_adc
        IMPORTING
          bukrs_ev  = lv_bukrs_adc
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*   Calculate from net price
      IF gv_action = /dbe/if_vms_constants=>c_qadc.
        lv_netvalue_adc = vlcactdata_head_s-/dbe/ext_srv_netamt.
      ELSEIF gv_action = /dbe/if_vms_constants=>c_qain.
        lv_netvalue_adc =  <ls_ac_post>-cost.
      ENDIF.

      CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
        EXPORTING
          i_bukrs           = lv_bukrs_adc
          i_mwskz           = vlcactdata_head_s-tax_code
          i_waers           = vlcactdata_head_s-currency
          i_wrbtr           = lv_netvalue_adc
        TABLES
          t_mwdat           = lt_taxes_adc
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
        vlcactdata_head_s-gross_amount = lv_netvalue_adc. "#EC CI_FLDEXT_OK[2610650]
        CLEAR: vlcactdata_head_s-tax_amount, <ls_ac_post>-tax_amount.

        IF gv_action = /dbe/if_vms_constants=>c_qadc.
          LOOP AT lt_taxes_adc INTO ls_taxes_adc.
            vlcactdata_head_s-gross_amount = vlcactdata_head_s-gross_amount + ls_taxes_adc-wmwst.
            vlcactdata_head_s-tax_amount = vlcactdata_head_s-tax_amount + ls_taxes_adc-wmwst. "#EC CI_FLDEXT_OK[2610650]
          ENDLOOP.

        ELSE.
          LOOP AT lt_taxes_adc INTO ls_taxes_adc.
*          vlcactdata_head_s-gross_amount = vlcactdata_head_s-gross_amount + ls_taxes1-wmwst.
            <ls_ac_post>-tax_amount  = <ls_ac_post>-tax_amount  + ls_taxes_adc-wmwst.
          ENDLOOP.
        ENDIF.
*       Tax (re)calculated using net price.
*        MESSAGE s225(/DBE/vehicle_master).
      ENDIF.

      IF gv_action = /dbe/if_vms_constants=>c_qadc.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF go_gr_create IS BOUND.
    CALL METHOD go_gr_create->check_changed_data
      IMPORTING
        e_valid = lv_valid_adc.

*  Refresh the ALV table to show the updated values
    CALL METHOD go_gr_create->refresh_table_display.
  ENDIF.

* Collect the prices and calculate thetax amount an dgross amount at header level.
  LOOP AT gt_ac_post INTO ls_ac_post.
*      lv_net_price    = lv_net_price    + ls_invoice_info-netpr.
*      lv_ac_gros_amount = lv_ac_gros_amount + ls_invoice_info-gross_amount.
    lv_tax_amount   = lv_tax_amount   + ls_ac_post-tax_amount.
  ENDLOOP.

  IF gv_action NE /dbe/if_vms_constants=>c_qadc.
    vlcactdata_head_s-tax_amount   = lv_tax_amount. "#EC CI_FLDEXT_OK[2610650]
*  vlcactdata_head_s-gross_amount = lv_gross_amount.
  ENDIF.

  gv_tax_calculated = abap_true.

*  ENDIF.

ENDFORM.                    " CALCULATE_TAX_AC
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_LAST_SERVICE_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM calculate_last_service_date USING pv_vguid TYPE vlc_guid
      lt_ordtyp TYPE /dbe/c_tt_ordertp
      lt_vbak_com TYPE /dbe/vbak_com_tt
      CHANGING cs_vsresult TYPE /dbe/vsresult.

  DATA: ls_vbak_com     TYPE /dbe/vbak_com,
        lv_last_service TYPE tzntstmps,
        lv_status       TYPE /dbe/status_vb.
  CLEAR gs_vsresult-audat_ls.

  IF lt_vbak_com IS INITIAL.
*   No service orders exist for the vehicle
    RETURN.
  ENDIF.
  CLEAR lv_last_service.
  LOOP AT lt_vbak_com INTO ls_vbak_com WHERE vguid = pv_vguid.
*   Check if the document is an order
    READ TABLE lt_ordtyp WITH KEY aufart = ls_vbak_com-aufart vbtyp = 'C' TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
*     Not order, maybe quotation or returns
      CONTINUE.
    ELSE.
*     Check if order is  technically confirmed
      CLEAR lv_status.
      SELECT SINGLE status INTO lv_status FROM /dbe/oe_vbakst WHERE vbeln = ls_vbak_com-vbeln AND action = 'TECH_CONF'.
      IF lv_status = /dbe/cl_oe_status_handling=>c_complete.
        cs_vsresult-audat_ls = ls_vbak_com-audat.
        EXIT.
      ELSE.
* The order isn't technically completed or the customer doesn't use this status, therefore
* the status ord_close is  checked
        CLEAR lv_status.
        SELECT SINGLE status INTO lv_status FROM /dbe/oe_vbakst WHERE vbeln = ls_vbak_com-vbeln AND action = 'ORD_CLOSE'.
        IF lv_status = /dbe/cl_oe_status_handling=>c_complete.
          cs_vsresult-audat_ls = ls_vbak_com-audat.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CALCULATE_LAST_SERVICE_DATE

*&---------------------------------------------------------------------*
*&      Form  calculate_ealiest_next_service_Date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM calculate_next_service_date USING    pv_vguid    TYPE vlc_guid
                                 CHANGING cs_vsresult TYPE /dbe/vsresult.
  DATA:
    ls_v_isint TYPE /dbe/v_isint_dynp_ext.

  FIELD-SYMBOLS:
    <f_iobj_multi> TYPE /dbe/iobj_data_multi_com_s.

  "Populate the lowest next service date
  CLEAR cs_vsresult-datnext.
  READ TABLE gt_iobj_multi ASSIGNING <f_iobj_multi>
         WITH KEY /dbe/v_vehicle-vguid = pv_vguid BINARY SEARCH.
  IF sy-subrc EQ 0.
    LOOP AT <f_iobj_multi>-/dbe/v_isint INTO ls_v_isint
            WHERE datnext IS NOT INITIAL.
      IF cs_vsresult-datnext IS INITIAL.
        cs_vsresult-datnext = ls_v_isint-datnext.
      ELSEIF cs_vsresult-datnext > ls_v_isint-datnext.
        cs_vsresult-datnext = ls_v_isint-datnext.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "calculate_ealiest_next_service_Date
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_RECALL_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_VEHICLES_VHVIN  text
*      <--P_GS_VSRESULT  text
*----------------------------------------------------------------------*
FORM calculate_recall_status  USING    ps_vehicles    TYPE vlcdiavehi
                                       ps_iobj_single TYPE /dbe/iobj_data_single_txt_s
                                       ps_iobj_multi  TYPE /dbe/iobj_data_multi_txt_s
                              CHANGING cs_vsresult    TYPE /dbe/vsresult.

  DATA: ls_iobj_data_single_com TYPE /dbe/iobj_data_single_com_s,
        ls_iobj_data_multi_com  TYPE /dbe/iobj_data_multi_com_s,
        lt_bapireturn           TYPE bapiret2_tab,
        ls_rcl                  TYPE /dbe/v_ircl_dynp_ext.

  CLEAR: cs_vsresult-rclstat,
         cs_vsresult-rclstat_desc.

  CALL FUNCTION '/DBE/VM10_GET_RECALLDATA'
    EXPORTING
      iv_action               = ' '
    CHANGING
      cs_vlcdiavehi           = ps_vehicles
      cs_iobj_data_single     = ps_iobj_single
      cs_iobj_data_multi      = ps_iobj_multi
      cs_iobj_data_single_com = ls_iobj_data_single_com
      cs_iobj_data_multi_com  = ls_iobj_data_multi_com
      ct_bapireturn           = lt_bapireturn
    EXCEPTIONS
      error_after_get         = 1
      OTHERS                  = 2.
  IF sy-subrc EQ 0.
    LOOP AT ls_iobj_data_multi_com-/dbe/v_ircl INTO ls_rcl
            WHERE rclstat EQ '1'.
      cs_vsresult-rclstat = ls_rcl-rclstat.
      cs_vsresult-rclstat_desc = ls_rcl-rclstat_desc.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " CALCULATE_RECALL_STATUS
*&---------------------------------------------------------------------*
*&      Form  DISTRIBUTE_NETAMT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM distribute_netamt .

  DATA: ls_adc_post   TYPE /dbe/vmass_adc,
        lv_totcost    TYPE /dbe/netamt,
        lv_costdiff   TYPE /dbe/netamt,
        lv_editedcost TYPE /dbe/netamt,
        lv_costcnt    TYPE numb,
        lv_roundflag  TYPE boolean.

  CLEAR: gv_adc_flag, gv_ac_flag, lv_totcost, lv_roundflag, lv_costdiff, lv_editedcost.

  gv_netamt = vlcactdata_head_s-/dbe/ext_srv_netamt.

  IF sy-ucomm EQ gc_ac_all AND sy-ucomm NE gc_error AND gv_netamt > '0'.

    IF badi_dist_adc IS BOUND.
      CALL BADI badi_dist_adc->distribute_additional_cost
        EXPORTING
          iv_netamt  = gv_netamt
        CHANGING
          ct_ac_post = gt_ac_post.

      LOOP AT gt_ac_post INTO ls_adc_post.
        lv_totcost = lv_totcost + ls_adc_post-cost.
        CLEAR ls_adc_post-flag.
      ENDLOOP.

      IF lv_totcost <> gv_netamt.
        gv_adc_flag = abap_true.
        MESSAGE e442(/dbe/vehicle_master).
      ENDIF.
    ELSE.
      IF gv_netamt IS INITIAL.   " OR gv_netamt LE 0.
        MESSAGE i001(/dbe/vehicle_master) WITH 'Net Amount'(413).
      ELSE.
        DESCRIBE TABLE gt_ac_post LINES gv_costcnt.
*--Cost of each vehicle is Net Amount / No. of Vehicles
        IF gv_costcnt IS NOT INITIAL.
          gv_vehcost = gv_netamt / gv_costcnt.
        ENDIF.
        IF gv_vehcost EQ 0.
          MESSAGE e438(/dbe/vehicle_master).
          EXIT.
        ENDIF.
        lv_totcost = gv_vehcost * gv_costcnt.

*--Rounding Off
        IF gv_netamt NE lv_totcost.
          lv_costdiff = gv_netamt - lv_totcost.
*--Add the differenced value only to the first row which is not edited
          lv_editedcost  =   gv_vehcost + lv_costdiff.
          IF lv_editedcost LE 0.
            MESSAGE e444(/dbe/vehicle_master).
            lv_roundflag = abap_true.
          ENDIF.
        ENDIF.

        IF lv_roundflag IS INITIAL.
          LOOP AT gt_ac_post INTO ls_adc_post.
            IF sy-tabix EQ 1.
              ls_adc_post-cost =  lv_costdiff + gv_vehcost.
            ELSE.
              ls_adc_post-cost =  gv_vehcost.
            ENDIF.
            ls_adc_post-currency = vlcactdata_head_s-currency.
            CLEAR ls_adc_post-flag.
            MODIFY gt_ac_post INDEX sy-tabix FROM ls_adc_post.
          ENDLOOP.
        ENDIF.

      ENDIF.
    ENDIF.

    CALL METHOD go_ac_create->refresh_table_display.
    CLEAR sy-ucomm.
  ENDIF.

ENDFORM.                    " DISTRIBUTE_NETAMT

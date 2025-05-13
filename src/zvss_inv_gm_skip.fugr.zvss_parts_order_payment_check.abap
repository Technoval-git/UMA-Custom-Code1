FUNCTION ZVSS_PARTS_ORDER_PAYMENT_CHECK.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_ORD_NO) TYPE  /DBE/VBELN_VA OPTIONAL
*"     VALUE(IV_DEL_NO) TYPE  VBELN_VL OPTIONAL
*"  EXPORTING
*"     VALUE(EV_PAID) TYPE  CRMT_BOOLEAN
*"----------------------------------------------------------------------

TYPES: BEGIN OF lty_clearing_date ,
           belnr TYPE belnr_d,
           augdt TYPE augdt,
         END OF lty_clearing_date.

  TYPES: BEGIN OF lty_billing,
           vbeln  TYPE vbeln,
           fkdat  TYPE fkdat,
           gjahr  TYPE gjahr,
           bukrs  TYPE bukrs,
           logsys TYPE logsystem,
         END OF lty_billing.

  DATA:
    lv_zuonr          TYPE dzuonr,
    lo_order          TYPE REF TO /dbe/cl_order,
    lw_dialog_control TYPE /dbe/oe_dialog_control,
    lw_vbakst         TYPE /dbe/oe_vbakst,
    ls_billing        TYPE lty_billing,
    lv_bill_paid      TYPE boolean,
    ls_objects        TYPE /dbe/ord_objects,
    lo_dpr            TYPE REF TO /dbe/cl_ord_dpr,
    lv_amt_paid       TYPE /dbe/vbap_com-netwr,
    lv_ord_amt        TYPE /dbe/vbap_com-netwr,
    ls_dpr_item       TYPE /dbe/ord_dpritem_com,
    ls_dpr_hdr        TYPE /dbe/ord_dprheader_com,
    lw_vbap           TYPE /dbe/vbap_com,
    ls_splhdr_com     TYPE /dbe/splhdr_com.

  CONSTANTS: lc_umskz  TYPE umskz VALUE 'A',
             lc_fkart  TYPE fkart VALUE 'YPBI',
             lc_f2     TYPE fkart VALUE 'ZPF1',
             lc_zterm  TYPE dzterm VALUE '0001',
             lc_action TYPE /dbe/oe_action VALUE 'BILLING_CREATE'.

  CLEAR: ev_paid.

  DATA : io_order TYPE REF TO /dbe/cl_order.

  DATA : lv_check TYPE c.

  DATA : lv_ord_no TYPE /dbe/vbeln_va.


  IF iv_del_no IS NOT INITIAL AND iv_ord_no IS INITIAL.
    SELECT SINGLE /dbe/vbeln FROM lips
                             INTO lv_ord_no WHERE vbeln EQ iv_del_no.
  ELSE.
    lv_ord_no = iv_ord_no.
  ENDIF.

  IF io_order IS NOT BOUND.
    lw_dialog_control-actvt = /dbe/cl_order_engine=>c_actvt_display.
    lw_dialog_control-dialog = space.

    CALL FUNCTION '/DBE/OE_MAIN_GET'
      EXPORTING
        iv_vbeln          = lv_ord_no
        is_dialog_control = lw_dialog_control
      IMPORTING
        eo_order          = lo_order
      EXCEPTIONS
        internal_error    = 1
        nothing_selected  = 2
        action_error      = 3
        OTHERS            = 4.
  ELSE.
    lo_order = io_order.
  ENDIF.
  CLEAR lv_check.
  IF lo_order->ms_vbak_com-vtweg EQ '10'.
    lv_check = 'X'.
  ENDIF.

  IF lv_check = 'X'..

*..<< If Bill amount is zero, mark it as paid and exit the FM >>
    READ TABLE lo_order->mt_splhdr_com INTO ls_splhdr_com
      WITH KEY splnr = '0001'.
    IF sy-subrc = 0 AND ls_splhdr_com-netwr = 0.
      ev_paid = abap_true.
      RETURN.
    ENDIF.

*...<< checking if the action ZNJD is executed >>
*    SELECT SINGLE * FROM /dbe/oe_vbakst INTO lw_vbakst
*      WHERE vbeln  = lv_ord_no
*        AND action = lc_action
*        AND status = 'C'.
*    IF sy-subrc <> 0.
*...<< if payment term is other than 0001, payment is considered as paid >>
      IF lo_order->ms_vbak_com-zterm = lc_zterm
        OR lo_order->ms_vbak_com-zterm = '0001'.
        CONCATENATE 'DBE' lv_ord_no '-0001' INTO lv_zuonr.

*...<< fetching the billing document number >>
        SELECT SINGLE vbeln fkdat gjahr bukrs logsys FROM vbrk
          INTO ls_billing
          WHERE ( fkart = lc_fkart
             OR fkart = lc_f2 )
            AND zuonr = lv_zuonr
            AND fksto = ''.
        IF sy-subrc = 0 AND ls_billing-vbeln IS NOT INITIAL ."AND lo_order->ms_vbak_com-vkorg NE '2200'.
          CALL FUNCTION 'ZVSS_FI_DOC_STATUS_FM'
            EXPORTING
              iv_billing_no = ls_billing-vbeln    " Sales and Distribution Document Number
              iv_logsys     = ls_billing-logsys    " Logical System
              iv_bukrs      = ls_billing-bukrs    " Company Code
              iv_gjahr      = ls_billing-gjahr    " Fiscal Year
              iv_fkdat      = ls_billing-fkdat    " Billing Date for Billing Index and Printout
            IMPORTING
              ev_cleared    = ev_paid.
        ELSE.
          READ TABLE lo_order->mt_objects INTO ls_objects
            WITH KEY classname = '/DBE/CL_ORD_DPR'.
          IF sy-subrc = 0.
            lo_dpr ?= ls_objects-objref.
            LOOP AT lo_dpr->mt_header_com INTO ls_dpr_hdr WHERE status = 'C'.
              LOOP AT lo_dpr->mt_item_com INTO ls_dpr_item WHERE hdr_guid = ls_dpr_hdr-hdr_guid.
                lv_amt_paid = lv_amt_paid + ls_dpr_item-wrbtr.   "amount
*              lv_amt_paid = lv_amt_paid + ls_dpr_item-wmwst.   "tax
              ENDLOOP.
            ENDLOOP.
          ENDIF.
          lv_amt_paid = ceil( lv_amt_paid ).
          LOOP AT lo_order->mt_vbap_com INTO lw_vbap WHERE itcanc = abap_false.
            lv_ord_amt = lv_ord_amt + lw_vbap-netwr.
          ENDLOOP.

          IF lv_ord_amt LE lv_amt_paid.
            ev_paid = abap_true.
          ENDIF.
        ENDIF.
*      ELSE.
*        ev_paid = abap_true.
*      ENDIF.
    ELSE.
      ev_paid = abap_true.
    ENDIF.
  ELSE.
    ev_paid = abap_true.
  ENDIF.



ENDFUNCTION.

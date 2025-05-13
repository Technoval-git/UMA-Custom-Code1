class ZCL_ORD_AP_SD_BILLING_CANC definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_OE_ACTION_PRE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ORD_AP_SD_BILLING_CANC IMPLEMENTATION.


  METHOD /dbe/if_oe_action_pre~prepare.
    DATA lo_order         TYPE REF TO /dbe/cl_order.
    DATA lo_billing       TYPE REF TO /dbe/cl_ord_billing_documents.
    DATA lv_dummy         TYPE string.

    FIELD-SYMBOLS <splhdr_com>
                      TYPE /dbe/splhdr_com.
    FIELD-SYMBOLS <header_com>
                          LIKE LINE OF lo_billing->mt_header_com.
    FIELD-SYMBOLS <header_com1>
                          LIKE LINE OF lo_billing->mt_header_com.


*-> get order instance
    lo_order ?= io_ord_object.

*-> get flowerpot instance for billing cancellation
    lo_billing ?= lo_order->object_get(
                  iv_classname  = '/DBE/CL_ORD_BILLING_DOCUMENTS'
                  iv_key        = space ).


    LOOP AT lo_billing->mt_header_com
                      ASSIGNING <header_com>
                      WHERE doctype = '01'
                      AND slctd_ext = 'X'.
      lo_order->mo_posting_date->add_date_on_key(
         EXPORTING
           iv_date                   = sy-datum
           is_action                 = is_action
           iv_splnr                  = <header_com>-splnr
         EXCEPTIONS
           wrong_parameter           = 1
           abort_date_conflict       = 2
           proposed_date_conflict    = 3
           validation_already_closed = 4
           OTHERS                    = 5  ).
      IF sy-subrc <> 0.
        CASE sy-subrc.
          WHEN 3.
            MESSAGE e088(/dbe/co) WITH sy-msgv1 sy-msgv2 INTO lv_dummy.
            lo_order->bal_add_symessage( ).
            RAISE EXCEPTION TYPE /dbe/cx_oe_action_denied.
          WHEN OTHERS.
            lo_order->bal_add_symessage( ).
            RAISE EXCEPTION TYPE /dbe/cx_oe_action_denied.
        ENDCASE.
      ENDIF.


    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

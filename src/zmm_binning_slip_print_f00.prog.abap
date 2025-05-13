*&---------------------------------------------------------------------*
*& Include          ZMM_PICKING_SLIP_PRINT_F00
*&---------------------------------------------------------------------*
"Entry Point, This form will trigger from NACE Configuration
FORM entry USING ent_retco TYPE sy-subrc
                 ent_screen TYPE c.

*  "Get Instance of Standard class to get data of Purchase Order Output
*  go_output_po = NEW cl_purchase_order_output(
*    c_mode     = lc_prntev_new
*    es_nast    = nast
*    iv_preview = ent_screen  ).
*
*  "Check if it bound
*  IF go_output_po IS BOUND.
*    go_output_po->read( ). "Read PO Data and update to buffer.
*  ENDIF.

  "Instantiate Local Claas
  go_print_form = NEW lcl_print_form( ).
  IF go_print_form IS BOUND.
    go_print_form->call_form(
      CHANGING
        ch_retcode = ent_retco
        ch_preview = ent_screen ).
  ENDIF.

ENDFORM.

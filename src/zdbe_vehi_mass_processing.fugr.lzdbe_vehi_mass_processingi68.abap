*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI68 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_TAXCODE_AT_ITEMS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_taxcode_at_items INPUT.

  LOOP AT gt_ininvoice_info INTO ls_invoice_info.
    ls_invoice_info-tax_code = vlcactdata_head_s-tax_code.
  ENDLOOP.

ENDMODULE.                 " DISPLAY_TAXCODE_AT_ITEMS  INPUT

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO53 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SUM_OF_ITEMS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE sum_of_items OUTPUT.

  IF gv_inc_flag IS NOT INITIAL.
    vlcactdata_head_s-netpr        = gv_netprice.
    vlcactdata_head_s-tax_amount   = gv_tax_amount.
    vlcactdata_head_s-gross_amount = gv_grossamount.
  ENDIF.

ENDMODULE.                 " SUM_OF_ITEMS  OUTPUT

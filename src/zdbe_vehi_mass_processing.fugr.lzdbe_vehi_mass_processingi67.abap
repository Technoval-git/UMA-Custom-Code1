*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI67 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SUM_OF_ITEMS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE sum_of_items INPUT.

  IF sy-ucomm EQ 'ENTER' AND gv_inc_flag IS NOT INITIAL.
    vlcactdata_head_s-netpr        = gv_netprice.
    vlcactdata_head_s-tax_amount   = gv_tax_amount.
    vlcactdata_head_s-gross_amount = gv_grossamount.
  ENDIF.

ENDMODULE.                 " SUM_OF_ITEMS  INPUT

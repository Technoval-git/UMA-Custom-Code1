*----------------------------------------------------------------------*
***INCLUDE /DBE/LVM06O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  badi_put_res_data_to_screen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module badi_put_res_data_to_screen output.

  gv_badi_program = sy-repid.
  gv_badi_dynpro = sy-dynnr.

  perform badi_put_res_data_to_screen using gv_badi_program
                                            gv_badi_dynpro.

endmodule.                 " badi_put_res_data_to_screen  OUTPUT

*&---------------------------------------------------------------------*
*& Report ZMM_BIN_OBD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_BIN_OBD.
data gv_dlv type char10.

START-OF-SELECTION.


call screen 9100.
*&---------------------------------------------------------------------*
*& Module STATUS_9100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9100 OUTPUT.
 SET PF-STATUS 'ZSTANDARD'.
 SET TITLEBAR 'Inbound Delivery ( Binning) / Outbound Delivery / Stock'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9100 INPUT.

CASE sy-ucomm.
    WHEN 'INDL'.
      gv_dlv = 'Inbound'.
      export gv_dlv = gv_dlv to memory id 'ZMM_BIN_OBD'.
      submit zmm_bin_obd_indl and RETURN.
    WHEN 'OBDL'.
     gv_dlv = 'Outbound'.
      export gv_dlv = gv_dlv to memory id 'ZMM_BIN_OBD'.
      submit zmm_bin_obd_indl and RETURN.
    WHEN 'STOCK'.

      submit zmm_bin_obd_stock and RETURN.
    WHEN 'CLOSE'.
      leave program.
  ENDCASE.
ENDMODULE.

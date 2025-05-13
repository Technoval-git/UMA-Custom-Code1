*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI54 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_TRANSFER_DEL_PO_INFO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_transfer_del_po_info INPUT.

  PERFORM f_transfer_del_po_info.                            "N:2304203

ENDMODULE.                 " M_TRANSFER_DEL_PO_INFO  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_TRANSFER_DEL_PO_INFO                          N:2304203
*&---------------------------------------------------------------------*
FORM f_transfer_del_po_info.
  DATA lo_veh_buf         TYPE REF TO /DBE/cl_veh_buf.

  CALL METHOD /DBE/cl_veh_buf=>get_instance
    RECEIVING
      ro_instance = lo_veh_buf.
  TRY.
      CALL METHOD lo_veh_buf->set_all .
    CATCH /DBE/cx_veh_error_occured .
    CATCH cx_static_check .
  ENDTRY.

ENDFORM.

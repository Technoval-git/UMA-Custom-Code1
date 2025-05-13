*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI43 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_exit INPUT.

  PERFORM f_user_command_exit.                               "N:2304203

ENDMODULE.                 " USER_COMMAND_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND_EXIT                             N:2304203
*&---------------------------------------------------------------------*
FORM f_user_command_exit.

  DATA lo_veh_buf         TYPE REF TO /DBE/cl_veh_buf.
  FIELD-SYMBOLS <ls_bob>  TYPE /DBE/s_veh_bob.

  " On closing popup , unlock and remove the vehciles from buffer
  IF lo_veh_buf IS NOT BOUND.
    CALL METHOD /DBE/cl_veh_buf=>get_instance
      RECEIVING
        ro_instance = lo_veh_buf.
  ENDIF.

  CALL METHOD lo_veh_buf->rem_bob.
  CLEAR: gv_action ,gv_tax_calculated,gv_ok_code,vlcactdata_head_s ,vlcactdata_item_s,gv_netamt.

  " Leave to calling screen
  LEAVE TO SCREEN 0.

ENDFORM.

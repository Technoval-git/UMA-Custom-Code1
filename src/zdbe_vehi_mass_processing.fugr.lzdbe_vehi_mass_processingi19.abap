*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI19 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3000 INPUT.

  CALL FUNCTION '/DBE/VMASS_GET_OK_CODE'
    IMPORTING
      ev_ok_code = gv_ok_code.

  CASE gv_ok_code .
    WHEN gc_exec_fc .
      " Once action is successfully executed , update the vehicle status
      " of selected vehicles in the worklist
      PERFORM refresh_table_data.
      PERFORM populate_main_message.
      CLEAR gv_ok_code.
      CLEAR :gv_action , gv_action_tobe_executed .
      CLEAR gt_bapireturn.
      CLEAR : vlcactdata_head_s ,vlcactdata_item_s.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_3000  INPUT

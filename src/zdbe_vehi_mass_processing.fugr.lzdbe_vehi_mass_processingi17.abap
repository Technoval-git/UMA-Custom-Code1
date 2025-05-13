*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI17 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1210 INPUT.

  DATA: lv_ok_code  TYPE sy-ucomm.

  lv_ok_code = ok_code.

  clear: ok_code.

  CASE lv_ok_code.
    WHEN gc_save_fc.
      PERFORM f_check_svar_to_set.
      LEAVE TO SCREEN 0.

    WHEN gc_cancel_fc.
      CALL FUNCTION '/DBE/VMASS_GET_VARIANT_BUFFER'  .
      LEAVE TO SCREEN 0.

    WHEN gc_create_fc.
      CALL METHOD grid->raise_event
        EXPORTING
          i_ucomm = ok_code.

    WHEN gc_delete_fc.
      CALL METHOD grid->raise_event
        EXPORTING
          i_ucomm = ok_code.
  ENDCASE.

  CALL METHOD cl_gui_cfw=>dispatch.

ENDMODULE.                 " USER_COMMAND_1210  INPUT

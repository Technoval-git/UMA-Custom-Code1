*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI11 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_0100 INPUT.                           "#EC CALLED
  CASE gv_ok_code.
    WHEN gc_exec_fc.
      IF gv_action  = /DBE/if_vms_constants=>c_qcrb .
        PERFORM execute_action.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " M_USER_COMMAND_0100  INPUT

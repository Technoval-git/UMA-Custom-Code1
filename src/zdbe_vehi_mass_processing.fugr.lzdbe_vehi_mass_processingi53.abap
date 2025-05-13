*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI53 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_CHECK_ENTRY_FIELDS_FILLED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_entry_fields_filled INPUT.

  gv_ok_code = sy-ucomm.

  IF gv_ok_code EQ 'MASS_FC2' OR gv_ok_code EQ 'ACT_EXE' .
    PERFORM f_check_entry_fields_filled.
  ENDIF.

ENDMODULE.                 " M_CHECK_ENTRY_FIELDS_FILLED  INPUT

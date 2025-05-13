*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO39 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_DETERMINE_OBLIGATORY_FIELDS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_determine_obligatory_fields OUTPUT.

  IF gv_ok_code NE gc_opclass AND gv_ok_code NE gc_load_okcode.
    PERFORM f_determine_oblig_fields.
  ENDIF.
  IF gv_ok_code EQ 'MASS_FC2'.
    gv_disable_button_qcre = abap_false.
  ENDIF.
ENDMODULE.                 " M_DETERMINE_OBLIGATORY_FIELDS  OUTPUT

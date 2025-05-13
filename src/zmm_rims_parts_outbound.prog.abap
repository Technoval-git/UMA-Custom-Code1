*&---------------------------------------------------------------------*
*& Report ZMM_RIMS_PARTS_OUTBOUND
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_rims_parts_outbound.

INCLUDE zimm_rims_parts_out_dec.
INCLUDE zimm_rims_parts_out_sub.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
  PERFORM get_file_name.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_infile.

  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = p_infile
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

START-OF-SELECTION.

  PERFORM fetch_data.

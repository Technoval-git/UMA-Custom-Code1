*&------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Report ZBP_UPLOAD_PRG
*&**********************************************************************

REPORT zbp_upload_prg.

INCLUDE zbp_upload_prg_dec.
INCLUDE zbp_upload_prg_sel.
INCLUDE zbp_upload_prg_forms.


INITIALIZATION.
  PERFORM f_initialization.

***********************************************************************
*                         START-OF-SELECTION                          *
***********************************************************************
START-OF-SELECTION.
  PERFORM f_bal_create_log.

*  * Downloads the file into an internal table
  PERFORM f_read_file.

*--create BP based on input..
  PERFORM f_create_bp.

*--display log
  PERFORM f_bal_display_log.

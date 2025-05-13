*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF62 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PAI_EXIT_COMMAND_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_exit_command_1000 .

  DATA : save_ok TYPE sy-ucomm.
  DATA : lv_count TYPE i.

  save_ok = ok_code.
  CLEAR ok_code.

  CASE save_ok.

    WHEN gc_exit_fc OR gc_cancel_fc.
      IF sy-calld = abap_true AND sy-cprog = '/DBE/SAPLVEHI_MASS_PROCESSING'.
        LEAVE PROGRAM.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDFORM.                    " PAI_EXIT_COMMAND_1000

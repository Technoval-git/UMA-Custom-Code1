*&---------------------------------------------------------------------*
*& Report ZR_EWM_PARTNO_PRINT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*REPORT zr_ewm_partno_print.

INCLUDE zi_ewm_partno_print_top.
INCLUDE zi_ewm_partno_print_f01.


AT SELECTION-SCREEN.
  PERFORM validations_all.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM print_form.

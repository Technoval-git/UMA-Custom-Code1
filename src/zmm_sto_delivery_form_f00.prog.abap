*&---------------------------------------------------------------------*
*& Include          ZMM_STO_DELIVERY_FORM_F00
*&---------------------------------------------------------------------*
FORM entry USING ent_retco TYPE sy-subrc
                 ent_screen TYPE c.
  "Instantiate Local Claas
  go_print_form = NEW lcl_print_form( ).
  IF go_print_form IS BOUND.
    go_print_form->call_form(
      CHANGING
        ch_retcode = ent_retco
        ch_preview = ent_screen ).
  ENDIF.

ENDFORM.

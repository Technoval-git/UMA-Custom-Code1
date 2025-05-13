*----------------------------------------------------------------------*
***INCLUDE LZWTYO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  CALL METHOD cl_ppeliwty_cntl=>get_mode
    EXPORTING
      iv_header_guid = wty_pnh_dynpro-pnguid
    IMPORTING
      ev_mode        = gv_mode.

  IF gv_mode EQ 'R'.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'WTY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'WTY'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.

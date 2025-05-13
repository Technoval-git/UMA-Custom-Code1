*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI18 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.

  ok_code = sy-ucomm.

  CASE ok_code.

    WHEN gc_back_fc.
      IF mass-activetab = gc_createveh_fc OR "mass-activetab = gc_searchvm_fc OR
         mass-activetab = gc_worklist_fc OR mass-activetab = gc_log_fc.
        g_find-pressed_tab    =   gc_searchvm_fc.
        PERFORM search_subscreen_set.
      ELSE.
        IF sy-calld = abap_true AND sy-cprog = '/DBE/SAPLVEHI_MASS_PROCESSING'.
          LEAVE PROGRAM.
        ELSE.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.

    WHEN 'LOG'.
      PERFORM log_display .

    WHEN gc_load_okcode.
      IF sy-cprog = '/DBE/SAPLVEHI_MASS_PROCESSING'.
        CLEAR: sy-ucomm.
      ENDIF.

    WHEN gc_uspara_fc.
      CALL SCREEN 1001 STARTING AT 5 4 ENDING AT 60 4.
    WHEN OTHERS.

  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                    "user_command_1000 INPUT
" USER_COMMAND_1000  INPUT

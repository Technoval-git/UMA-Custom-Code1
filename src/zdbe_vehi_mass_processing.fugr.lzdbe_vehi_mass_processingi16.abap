*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI16 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1100 INPUT.

  DATA : lv_count TYPE i.

  gv_main_ok_code = ok_code.

  clear: ok_code.

  CASE gv_main_ok_code.

    WHEN gc_searchvm_fc.
      PERFORM search_subscreen_set.

    WHEN gc_worklist_fc.
      PERFORM overview_subscreen_set.

    WHEN gc_execute_fc.
      IF mass-activetab = gc_searchvm_fc.
        CLEAR ok_code.
      ENDIF.

      IF gv_error_search IS NOT INITIAL.
        RETURN.
      ENDIF.
      CLEAR: gv_error_search.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT

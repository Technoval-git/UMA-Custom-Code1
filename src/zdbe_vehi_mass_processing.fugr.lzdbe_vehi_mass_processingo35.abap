*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO35 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  BADI_GET_SCREEN_INFO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE badi_get_screen_info OUTPUT.

  DATA: lv_calling_screen TYPE scradnum.
  DATA: lv_called_screen  TYPE scradnum.
  DATA: lv_calling_prog_name TYPE sy-repid.
  DATA: lt_filter TYPE badi_filter_bindings.

  gv_badi_program = sy-repid.
  gv_badi_dynpro  = sy-dynnr.

  lv_calling_prog_name  = gv_badi_program.
  lv_calling_screen     = gv_badi_dynpro.

  IF badi_search_ui IS BOUND.
    TRY.
        CALL METHOD cl_enh_badi_runtime_functions=>get_prog_and_dynp_for_subscr
          EXPORTING
            badi_name       = '/DBE/BADI_VMASS_SEARCH_UI'
            calling_dynpro  = lv_calling_screen
            calling_program = lv_calling_prog_name
            filter_values   = lt_filter
            subscreen_area  = 'SUBSCREEN1'
          IMPORTING
            called_dynpro   = lv_called_screen
            called_program  = gv_badi_program.
      CATCH cx_enh_badi_inconsistent
            cx_enh_badi_no_such_extension
            cx_enh_badi_not_found
            cx_enh_badi_mulitple_impls
            cx_enh_badi_filter_missing.
    ENDTRY.
    gv_badi_dynpro = lv_called_screen.
  ENDIF.

  IF lv_called_screen IS INITIAL AND lv_calling_screen = gc_first_subscreen_dynpro.
    gv_badi_dynpro    = gc_mass_crit_subscreen_dynpro.
  ELSEIF lv_called_screen IS INITIAL AND lv_calling_screen = gc_result_subscr_dynpro1.
    gv_badi_dynpro    = gc_result_subscr_dynpro.
  ENDIF.

ENDMODULE.                 " BADI_GET_SCREEN_INFO  OUTPUT

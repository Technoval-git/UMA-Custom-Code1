*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO46 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  BADI_GET_RESULT_SCREEN_INFO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE badi_get_result_screen_info OUTPUT.

  DATA: lv_res_calling_screen TYPE scradnum.
  DATA: lv_res_called_screen  TYPE scradnum.
  DATA: lv_res_calling_prog_name TYPE sy-repid.
  DATA: lt_res_filter TYPE badi_filter_bindings.

  gv_badi_program = sy-repid.
  gv_badi_dynpro  = sy-dynnr.

  lv_res_calling_prog_name  = gv_badi_program.
  lv_res_calling_screen     = gv_badi_dynpro.

  IF badi_search_ui IS BOUND.
    TRY.
        CALL METHOD cl_enh_badi_runtime_functions=>get_prog_and_dynp_for_subscr
          EXPORTING
            badi_name       = '/DBE/BADI_VMASS_RESULTALV'
            calling_dynpro  = lv_res_calling_screen
            calling_program = lv_res_calling_prog_name
            filter_values   = lt_res_filter
            subscreen_area  = 'SUBSCREEN1'
          IMPORTING
            called_dynpro   = lv_res_called_screen
            called_program  = gv_badi_program.
      CATCH cx_enh_badi_inconsistent
            cx_enh_badi_no_such_extension
            cx_enh_badi_not_found
            cx_enh_badi_mulitple_impls
            cx_enh_badi_filter_missing.
    ENDTRY.
    gv_badi_dynpro = lv_res_called_screen.
  ELSE.
    gv_badi_dynpro =  gc_result_subscr_dynpro.
  ENDIF.

ENDMODULE.                 " BADI_GET_RESULT_SCREEN_INFO  OUTPUT

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVM06F04 .

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BADI_PUT_RES_DATA_TO_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM badi_put_res_data_to_screen USING pv_prog_name TYPE sy-repid
                                       pv_dynnr_name TYPE sy-dynnr.

DATA: lt_filter TYPE BADI_FILTER_BINDINGS.
DATA: lv_calling_screen TYPE scradnum.
DATA: lv_called_screen  TYPE scradnum.
DATA: lv_calling_prog_name TYPE sy-repid.

lv_calling_prog_name = pv_prog_name.
lv_calling_screen = pv_dynnr_name.

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
          called_program  = pv_prog_name.
    CATCH cx_enh_badi_inconsistent
          cx_enh_badi_no_such_extension
          cx_enh_badi_not_found
          cx_enh_badi_mulitple_impls
          cx_enh_badi_filter_missing.
  ENDTRY.

pv_dynnr_name = lv_called_screen.

ENDFORM.

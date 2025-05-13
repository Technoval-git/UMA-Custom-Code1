FUNCTION ZDBE_GET_VEHICLE_STOCK_AGEING.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_VARID) TYPE  VARID-VARIANT OPTIONAL
*"     REFERENCE(IT_MASS_SEARCH_CRIT) TYPE  /DBE/VEH_SEARCHCRIT_T
*"         OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_VSRESULT) TYPE  /DBE/VSRESULT_T
*"     REFERENCE(ET_VEHICLES) TYPE  VLCDIAVEHI_T
*"  EXCEPTIONS
*"      NO_VARIANT_ID
*"      NO_SEARCH_CRITERIA
*"      NO_VEHICLE_FOUND
*"--------------------------------------------------------------------

  DATA: lv_svariant TYPE /DBE/svariant.

  PERFORM badi_search_initialize.
  PERFORM badi_result_initialize.

  IF badi_search_ui IS NOT BOUND.
    IF iv_varid IS NOT INITIAL.
      MOVE iv_varid TO lv_svariant.
      gv_subscreen_dynpro   = gc_variant_subscreen.
      gv_subscreen_program  = gc_mass_main_program.
      gv_prog_name          = gv_subscreen_program.
      CLEAR gv_skip_search_crit_prepare.
      CALL FUNCTION '/DBE/VMASS_VARIANT_READ_DB'.
      CALL FUNCTION '/DBE/VMASS_GET_VARIANT_BUFFER'.
      PERFORM f_load_variant USING lv_svariant.
    ELSE.
      RAISE no_variant_id.
    ENDIF.
  ELSE.
    IF it_mass_search_crit IS NOT INITIAL.
      gt_mass_search_crit = it_mass_search_crit.
      gv_skip_search_crit_prepare = abap_true.
    ELSE.
      RAISE no_search_criteria.
    ENDIF.
  ENDIF.

  CLEAR gv_maxsel. "Clear the maximum selection
  PERFORM execute_search.
  PERFORM authchk_populate_result.

  CLEAR: et_vsresult, et_vehicles.
  APPEND LINES OF gt_vsresult TO et_vsresult.
  APPEND LINES OF gt_vehicles TO et_vehicles.
  IF gt_vehicles IS INITIAL.
    RAISE no_vehicle_found.
  ENDIF.

ENDFUNCTION.

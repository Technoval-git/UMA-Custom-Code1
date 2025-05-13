FUNCTION ZDBE_VMASS_LAUNCH_VSEARCH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IO_PARAMS) TYPE REF TO /DBE/CL_OE_PARAMETER_CAPSULE
*"  EXPORTING
*"     REFERENCE(ET_BAPIRETURN) TYPE  BAPIRET2_TAB
*"--------------------------------------------------------------------
  DATA:
  lt_vlcdisplalv        TYPE TABLE OF vlcdisplalv,
  ls_vlcdisplalv        TYPE vlcdisplalv,
  lr_selected_vehicles  TYPE REF TO /DBE/vlc_guid_t,
  ls_selected_vehicle   TYPE vlc_guid,
  ls_user_sv_value      TYPE /DBE/vm_svval,
  ls_user_sv_criteria   TYPE /DBE/vm_svcrit,
  ls_sv_text            TYPE /DBE/vm_svartxt,
  ls_selection_variant  TYPE /DBE/vm_svariant.

  PERFORM f_global_init.

  mass-activetab = gc_searchvm_fc.

  TRY.
      GET BADI badi_search_ui.
    CATCH cx_badi_not_implemented
          cx_badi_multiply_implemented.
  ENDTRY.

  LOOP AT gt_mass_user_svval_buf INTO ls_user_sv_value.
    MOVE-CORRESPONDING ls_user_sv_value TO ls_user_sv_criteria.
    INSERT ls_user_sv_criteria INTO TABLE gt_mass_user_svcrit_buf.
  ENDLOOP.

  MOVE-CORRESPONDING ls_user_sv_criteria TO ls_sv_text.
  ls_sv_text-spras = sy-langu.
  ls_sv_text-svart = 'Vehicle Assignment'(001).
  INSERT ls_sv_text INTO TABLE gt_mass_svartxt_buf.

  MOVE-CORRESPONDING ls_sv_text TO ls_selection_variant.
  INSERT ls_selection_variant INTO TABLE gt_mass_svariant_buf.

*  SET PARAMETER ID gc_mass_svariant_def FIELD space. "gc_assign_fc.
*  gv_external_function = gv_mass_svariant_def. " = gc_assign_fc.
  gv_mass_usparam_exists = abap_true.

  io_params->get_param( EXPORTING iv_name = 'NOARCHIVE' IMPORTING ev_value = gv_no_archive_search ).

  CALL SCREEN 1100.

  SET PARAMETER ID '/DBE/V_SVARDEF' FIELD space.
  et_bapireturn = gt_bapireturn.
ENDFUNCTION.

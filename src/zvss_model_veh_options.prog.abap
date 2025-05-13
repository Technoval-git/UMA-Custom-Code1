*&---------------------------------------------------------------------*
*& Report ZVSS_MODEL_VEH_OPTIONS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_model_veh_options.

INCLUDE zvss_model_veh_options_top.

INCLUDE zvss_model_veh_options_sel.

INCLUDE zvss_model_veh_options_frm.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR pv_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
    IMPORTING
      file_name     = pv_file.

START-OF-SELECTION.

  PERFORM form_get_data_pc_file.

  PERFORM update_model_options.

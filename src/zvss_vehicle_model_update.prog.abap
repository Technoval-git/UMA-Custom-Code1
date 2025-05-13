*&---------------------------------------------------------------------*
*& Report ZVSS_VEHICLE_MODEL_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_vehicle_model_update.

INCLUDE zvss_vehicle_model_update_top.

INCLUDE zvss_vehicle_model_update_sel.

INCLUDE zvss_vehicle_model_update_frm.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR pv_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
    IMPORTING
      file_name     = pv_file.

START-OF-SELECTION.

  PERFORM form_get_data_pc_file.

  PERFORM update_vehicle.

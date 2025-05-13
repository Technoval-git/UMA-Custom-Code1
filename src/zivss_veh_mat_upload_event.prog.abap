*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEH_MAT_UPLOAD_EVENT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
  IF rb_pi IS INITIAL.
    PERFORM f_file_value.
  ELSE.
    PERFORM f_at_sel_scr_on_val_req_pi USING p_fname.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_log.

  PERFORM f_at_sel_scr_on_val_req_pi USING p_log.



*&--------------------------------------------------------------------*
*&                START-OF-SELECTION
*&--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_validate_log_path.
  "Read file data
  PERFORM f_prepare_loaddata.
  "Split File and chech all mandat fields are filled
  PERFORM f_split_and_check_mandat.
  IF lt_log IS NOT INITIAL.
    "Display Mandat Error
    PERFORM f_upload_log_to_server.
    PERFORM f_display_alv.
  ELSE.
    PERFORM f_get_values_from_db.
    PERFORM f_validate_data.
    IF lt_log IS NOT INITIAL.
      "Display Mandat Error
      PERFORM f_upload_log_to_server.
      PERFORM f_display_alv.
    ELSE.
      "Process file data
      PERFORM f_prepare_data.
    ENDIF.
  ENDIF.

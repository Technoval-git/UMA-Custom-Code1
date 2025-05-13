*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF33 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_SVAR_TO_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_svar_to_set .

  DATA: lt_selected_rows  TYPE lvc_t_roid.
  DATA: ls_selected_row   TYPE lvc_s_roid.
  DATA: lv_lines          TYPE i.
  DATA: ls_alv_var        TYPE /DBE/alv_var.
  DATA: lv_new_alvvar_row TYPE i.
  DATA: lv_flag TYPE boolean.

field-SYMBOLS: <fs_alv_var> type /DBE/alv_var.
*Trigger event to check for duplicates and
*validate changes by method handle_data_changed
  CALL METHOD grid->check_changed_data.
*Check for empty keys
  READ TABLE gt_mass_alv_var WITH KEY svar = space TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
*Key field must not be empty!
    MESSAGE e410(/DBE/vehicle_master).
  ENDIF.
*Check for new entry
  READ TABLE gt_mass_alv_var ASSIGNING <fs_alv_var> WITH KEY orig = space.
  IF sy-subrc EQ 0.
    " DBM 8.0 all variants will we pushed to stock ageing standard variant
    " So Variant Name should be unique Key
    TRANSLATE <fs_alv_var>-svar TO UPPER CASE.
    lv_new_alvvar_row = sy-tabix.
  ENDIF.
*Get number of selected rows
  CALL METHOD grid->get_selected_rows
    IMPORTING
      et_row_no = lt_selected_rows.
  DESCRIBE TABLE lt_selected_rows LINES lv_lines.
  IF lv_lines GT 1 OR lv_lines EQ 1 AND NOT lv_new_alvvar_row IS INITIAL.
*Only one selection variant can be updated at a time!
    MESSAGE i035(/DBE/vehicle_master).
    RETURN.
  ELSEIF lv_lines EQ 1 AND lv_new_alvvar_row IS INITIAL.
*If there's only one row selected to update from screen,
*set row as if it were a new variant and get search criteria
    PERFORM f_search_data_get CHANGING gt_mass_search_crit.
    IF gt_mass_search_crit IS INITIAL.
* There are no search criteria to store!
      MESSAGE i409(/DBE/vehicle_master).
      RETURN.
    ENDIF.
* Get the selected row and set index variable to point to that
    READ TABLE lt_selected_rows INTO ls_selected_row INDEX 1.
    READ TABLE gt_mass_alv_var INTO ls_alv_var INDEX ls_selected_row-row_id.
    IF sy-subrc EQ 0.
      lv_new_alvvar_row = ls_selected_row-row_id.
    ENDIF.
  ENDIF.

  CALL FUNCTION '/DBE/VMASS_SET_VARIANT_BUFFER'
    EXPORTING
      iv_var_row_id = lv_new_alvvar_row
      iv_flag       = 'X'.


  CALL FUNCTION '/DBE/VMASS_GET_VARIANT_BUFFER'
*   EXPORTING
*     IV_FLAG       =
            .

ENDFORM.                    " F_CHECK_SVAR_TO_SET

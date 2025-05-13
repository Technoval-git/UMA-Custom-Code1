*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF29 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_fields .

  DATA: lt_control     TYPE vlcsearchcontrol_t.
  DATA: ls_control     TYPE vlcsearchcontrol.
  DATA: lv_critname    TYPE string.
  DATA: lt_search_crit TYPE /DBE/veh_searchcrit_t.
  DATA: ls_search_crit TYPE /DBE/veh_searchcrit.

  FIELD-SYMBOLS: <lt_crittable> TYPE ANY TABLE,
                 <lv_criteria>  TYPE any.

  CALL FUNCTION 'VELO14_READ_SEARCHCONTROL'
    TABLES
      control_et       = lt_control
    EXCEPTIONS
      no_entries_found = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID 'VELO' TYPE 'E' NUMBER '196'.
  ENDIF.

  LOOP AT lt_control INTO ls_control.
    CONCATENATE '(' gv_prog_name ')' ls_control-scinterfacefield '[]' INTO lv_critname.
    ASSIGN (lv_critname) TO <lt_crittable>.
    IF sy-subrc NE 0.
      CONTINUE. "no such select-option on VMS-interface
    ENDIF.
    CLEAR <lt_crittable>.
  ENDLOOP.

* In order that not only select-options get cleared but
* parameter fields as well, this part is also needed.
* This part is not sufficient to clear all the fields,
* as without the coding above the VMS fm-s fail in the
* form f_search_data_get!
  IF NOT gv_subscreen_program IS INITIAL.
    PERFORM f_search_data_get CHANGING lt_search_crit.
    PERFORM f_find_tab_text_set.
    LOOP AT lt_search_crit INTO ls_search_crit.
      CONCATENATE '(' gv_prog_name ')' ls_search_crit-qual '[]' INTO lv_critname.
      ASSIGN (lv_critname) TO <lv_criteria>.
      IF sy-subrc NE 0.
        CONCATENATE '(' gv_prog_name ')' ls_search_crit-qual INTO lv_critname.
        ASSIGN (lv_critname) TO <lv_criteria>.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
      ENDIF.
      CLEAR <lv_criteria>.
    ENDLOOP.
  ENDIF.

  CLEAR: gt_mcodesd, gt_mcodesd[].

ENDFORM.                    " F_CLEAR_FIELDS

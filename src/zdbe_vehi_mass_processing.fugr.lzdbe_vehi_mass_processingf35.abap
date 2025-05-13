*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF35 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  POPULATE_ACTION_DROPDOWN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_action_dropdown ."using e_object TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET .

  DATA :   ls_cvlc03t      TYPE cvlc03t,
           lt_cvlc03t      TYPE TABLE OF cvlc03t,
           action_list     TYPE vrm_values ,
           value           TYPE vrm_value,
           lt_actions      TYPE /DBE/vms_actions,
           lt_tech_details TYPE /DBE/t_veh_cvlc03,
           ls_actions      LIKE LINE OF lt_actions,
           ls_act_details  LIKE LINE OF lt_tech_details,
           lt_vlcdisplalv  TYPE TABLE OF vlcdisplalv ,
           ls_selection    TYPE vlcdisplalv .

TYPES: BEGIN OF TTY_VLC_AKTIONt,
       AKTION LIKE CVLC03T-AKTION,
       AKTIONT LIKE CVLC03T-AKTIONT,
       END OF TTY_VLC_AKTIONt.

 data : LT_ALLOWED_ACTIONS TYPE TABLE OF  TTY_VLC_AKTIONt .
 data : LS_ALLOWED_ACTIONS TYPE  TTY_VLC_AKTIONt .
 data : lv_fcode type ui_func.
DATA:
           lt_index TYPE lvc_t_row,
           lt_rowid TYPE lvc_t_roid,

           ls_vehi  TYPE /DBE/vsresult,
           ls_rowid TYPE LINE OF lvc_t_roid.
*
*  CASE ok_code.
*    WHEN  gc_set_action.
*    WHEN OTHERS.
*Get index and row-id of selected vehicles from ALV Grid
      g_alv_grid->get_selected_rows( IMPORTING et_index_rows = lt_index et_row_no = lt_rowid ).

      REFRESH gt_vsresult_selection.

*Get selected vehicles
      LOOP AT lt_rowid INTO ls_rowid.

        READ TABLE gt_vsresult INTO ls_vehi INDEX ls_rowid-row_id.
        APPEND ls_vehi TO gt_vsresult_selection.

      ENDLOOP.
*  ENDCASE.
*  IF gt_vsresult_selection IS NOT INITIAL.
*    PERFORM populate_action_dropdown.
*  ENDIF.
DATA : cur_txn_name(20) TYPE c.

  IMPORT current_txn_name TO cur_txn_name FROM MEMORY ID 'TXN_NAME'.


  CLEAR :  value , action_list .

  IF gt_vsresult_selection IS INITIAL ."and gt_bulk_actions is initial.
    CALL FUNCTION 'VELO01_GET_POSSIBLE_ACTIONS' "#EC CI_USAGE_OK[2438110]
      EXPORTING
        username_iv            = sy-uname
        all_actions_iv         = abap_true
        no_internal_actions_iv = abap_false
      TABLES
*       vlcdisplalv_it         = lt_vlcdisplalv
        actionlist_et          = lt_actions
        actions_lt             = lt_tech_details.

  ELSE.
    LOOP AT gt_vsresult_selection INTO gs_selection.
      MOVE-CORRESPONDING gs_selection TO ls_selection.
      APPEND ls_selection TO lt_vlcdisplalv.
    ENDLOOP.

    CALL FUNCTION 'VELO01_GET_POSSIBLE_ACTIONS' "#EC CI_USAGE_OK[2438110]
      EXPORTING
        username_iv            = sy-uname
        all_actions_iv         = abap_false
        no_internal_actions_iv = abap_false
      TABLES
        vlcdisplalv_it         = lt_vlcdisplalv
        actionlist_et          = lt_actions
        actions_lt             = lt_tech_details.
  ENDIF.

  LOOP AT lt_tech_details INTO ls_act_details WHERE /DBE/bulk_actn = abap_true.
    READ TABLE lt_actions INTO ls_actions WITH KEY aktion = ls_act_details-aktion.
    IF sy-subrc = 0.
      value-key = ls_actions-aktion.
      value-text = ls_actions-aktiont.
      APPEND value TO action_list.
      MOVE-CORRESPONDING ls_act_details TO gs_bulk_actions.
      MOVE-CORRESPONDING LS_ACT_DETAILS TO LS_ALLOWED_ACTIONS.
      MOVE ls_actions-aktiont  TO LS_aLLOWED_ACTIONS-AKTIONT.
      APPEND LS_ALLOWED_ACTIONS TO LT_ALLOWED_ACTIONS.
      APPEND gs_bulk_actions TO gt_bulk_actions.

*
*        lv_fcode  = ls_actions-aktion.
*        CALL METHOD e_object->add_function
*          EXPORTING
*            fcode = lv_fcode
*            text  = ls_actions-aktiont.

    ENDIF.
  ENDLOOP.

*  CALL FUNCTION 'VRM_SET_VALUES'
*    EXPORTING
*      id     = gc_action
*      values = action_list.

data lt_return type table of DDSHRETVAL.
data ls_return type DDSHRETVAL.
data lt_mapping type table of dselc.
data ls_mapping type  dselc.
ls_mapping-fldname = 'AKTION'.
ls_mapping-DYFLDNAME = 'CVLC03-AKTION'.
append ls_mapping to lt_mapping.

CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'CVLC03-AKTION'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = LT_ALLOWED_ACTIONS
        RETURN_TAB      = lt_return
        DYNPFLD_MAPPING = lt_mapping
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.

IF sy-subrc <> 0.
* Implement suitable error handling here
  else.

read table lt_return into ls_return index 1.
CVLC03-AKTION = ls_return-FIELDVAL.
ENDIF.

ENDFORM.                    " POPULATE_ACTION_DROPDOWN

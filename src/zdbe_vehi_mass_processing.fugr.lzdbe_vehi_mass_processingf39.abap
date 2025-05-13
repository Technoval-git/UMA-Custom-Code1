*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF39 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_SUBSCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_subscreen .

  DATA : lv_def_col_1  TYPE i,
         lv_def_col_2  TYPE i.

  CLEAR gs_bulk_actions.
  READ TABLE gt_bulk_actions INTO gs_bulk_actions
      WITH KEY  aktion = cvlc03-aktion ."active = abap_true.
  IF sy-subrc = 0.
    IF gs_bulk_actions-creaact <> 'X' AND gt_vsresult_selection IS INITIAL.
      MESSAGE e402(/DBE/vehicle_master).
    ENDIF.
    gv_action   = gs_bulk_actions-aktion.
    gv_action_screen_program = gs_bulk_actions-vlcprog.
    gv_action_screen_dynpro  = gs_bulk_actions-vlcdynpr.
    CLEAR cvlc03-aktion.
    CASE gv_action.
      WHEN /DBE/if_vms_constants=>c_qcrb OR /DBE/if_vms_constants=>c_qgrb OR
          /DBE/if_vms_constants=>c_qgcb OR /DBE/if_vms_constants=>c_qirb.
        lv_def_col_1  = '80'.
        lv_def_col_2  = '30'.
      WHEN /DBE/if_vms_constants=>c_qorb OR /DBE/if_vms_constants=>c_qmob OR
        /DBE/if_vms_constants=>c_qdob OR /DBE/if_vms_constants=>c_qinb.
        lv_def_col_1  = '100'.
        lv_def_col_2  = '30'.
      WHEN OTHERS.
*Badi needed?
        lv_def_col_1  = '80'.
        lv_def_col_2  = '30'.
    ENDCASE.
    CALL SCREEN 3001 STARTING AT 10 10 ENDING AT lv_def_col_1 lv_def_col_2.
  ELSE.
  ENDIF.
ENDFORM.                    " SET_SUBSCREEN
*&---------------------------------------------------------------------*
*&      Module  M_FILL_COMMON_DELDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_fill_common_deldate INPUT.

    PERFORM f_fill_common_del_date .

ENDMODULE.                 " M_FILL_COMMON_DELDATE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_ENTRY_FIELDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_entry_fields INPUT.

    PERFORM f_check_entry_fields.

ENDMODULE.                 " CHECK_ENTRY_FIELDS  INPUT
" GET_SCREEN_COORDINATES

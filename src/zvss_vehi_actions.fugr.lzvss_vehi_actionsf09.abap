*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ACTIONSF09.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREPARE_ACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_action CHANGING cs_error TYPE bapiret2.

  DATA: ls_action TYPE action_type.
  DATA: lt_bapireturn TYPE bapiret2_t.

*Get the selected action
  CALL FUNCTION '/DBE/VM08_SELECTED_ACTION_GET'
    IMPORTING
      es_sel_action = ls_action-action.

  IF ls_action-action-aktion IS NOT INITIAL.
    CALL FUNCTION '/DBE/VM01_VEHICLE_ACTION_PREP'
      EXPORTING
        iv_action     = ls_action-action-aktion
      IMPORTING
        et_bapireturn = lt_bapireturn
      EXCEPTIONS
        error_prepare = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      IF sy-msgty IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                INTO cs_error-message.
        cs_error-id = sy-msgid.
        cs_error-type = sy-msgty.
        cs_error-number = sy-msgno.
        cs_error-message_v1 = sy-msgv1.
        cs_error-message_v2 = sy-msgv2.
        cs_error-message_v3 = sy-msgv3.
        cs_error-message_v4 = sy-msgv4.
        APPEND cs_error TO lt_bapireturn.
      ENDIF.
    ENDIF.
    CALL FUNCTION '/DBE/VM08_ERROR_SET'
      EXPORTING
*        iv_error      = This parameter is only to be set to TRUE if error happened during vehicle set
        it_bapireturn = lt_bapireturn.
  ENDIF.

ENDFORM.                    " F_PREPARE_ACTION

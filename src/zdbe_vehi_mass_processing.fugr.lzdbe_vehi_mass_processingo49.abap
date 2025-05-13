*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO49 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SHOW_HIDE_FIELDS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_hide_fields OUTPUT.

  PERFORM show_hide_fields.


ENDMODULE.                 " SHOW_HIDE_FIELDS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_FIELDS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_fields OUTPUT.

  LOOP AT SCREEN.
    CASE gv_action.
      WHEN /DBE/if_vms_constants=>c_qaic OR /DBE/if_vms_constants=>c_qacc .
        IF screen-group1 EQ 'GR1' .
          screen-active = 1.
          screen-required = 1.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.
      WHEN /DBE/if_vms_constants=>c_qapc.
        IF screen-group1 EQ 'GR1' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN /DBE/if_vms_constants=>c_qagc.
        IF screen-name EQ 'VLCACTDATA_HEAD_S-BUDAT' .
          screen-active = 1.
          MODIFY SCREEN.
        ELSE.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
ENDMODULE.                 " SET_SCREEN_FIELDS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_INPUT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_input INPUT.

  PERFORM validate_input.

ENDMODULE.                 " VALIDATE_INPUT  INPUT
*&---------------------------------------------------------------------*
*&      Form  INITIALIZE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_data .

  IF gv_ok_code NE gc_exec_fc.
    IF vlcactdata_head_s-budat IS INITIAL.
      vlcactdata_head_s-budat = sy-datum.
    ENDIF.
  ENDIF.

  IF gv_ok_code EQ gc_exec_fc OR gv_ok_code EQ gc_ente_fc.

    IF gv_action EQ /DBE/if_vms_constants=>c_qacc OR  gv_action EQ /DBE/if_vms_constants=>c_qaic
       OR  gv_action EQ /DBE/if_vms_constants=>c_qapc OR gv_action EQ  /DBE/if_vms_constants=>c_qagc.

      READ TABLE gt_ac_cancel WITH KEY is_selected = abap_true TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        LOOP AT SCREEN.
          IF screen-name = 'VLCACTDATA_HEAD_S-REVREASON' OR screen-name = 'VLCACTDATA_HEAD_S-BUDAT'.
            screen-input = 1.
            screen-required = 1.
            screen-active = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.

        MESSAGE e432(/DBE/vehicle_master).
        RETURN.

      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " INITIALIZE_DATA
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_input .

  DATA:  lt_dynpfields TYPE TABLE OF  dynpread,
         ls_dynpfields TYPE dynpread.

  IF gv_action EQ /DBE/if_vms_constants=>c_qacc.

    ls_dynpfields-fieldname = 'VLCACTDATA_HEAD_S-BUDAT'.

    APPEND ls_dynpfields TO lt_dynpfields.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname     = sy-repid
        dynumb     = sy-dynnr
      TABLES
        dynpfields = lt_dynpfields
      EXCEPTIONS
        OTHERS     = 01.

    IF sy-subrc EQ 0.
      READ TABLE lt_dynpfields INDEX 1 INTO ls_dynpfields TRANSPORTING fieldvalue .

      IF sy-subrc EQ 0.
        IF ls_dynpfields-fieldvalue IS INITIAL.

          vlcactdata_head_s-budat = '00000000'.
          MESSAGE e441(/DBE/vehicle_master).
          RETURN.
        ELSE.
          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
            EXPORTING
              date_external            = ls_dynpfields-fieldvalue
            IMPORTING
              date_internal            = vlcactdata_head_s-budat
            EXCEPTIONS
              date_external_is_invalid = 1.

          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.

    IF vlcactdata_head_s-budat LT sy-datum.
      MESSAGE e430(/DBE/vehicle_master).
    ENDIF.
  ENDIF.
ENDFORM.                    " VALIDATE_INPUT

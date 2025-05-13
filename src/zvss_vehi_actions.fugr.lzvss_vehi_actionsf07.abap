*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ACTIONSF07.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_IOBJ_MULTI_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_iobj_multi_set .

  DATA: ls_iobj_multi_control TYPE control_type.
  DATA: lv_valid TYPE c.
  DATA: lv_error TYPE c.
  DATA: ls_protocol TYPE lvc_s_msg1.

*Loop over registered controls and get newest data
  LOOP AT gt_iobj_multi_control INTO ls_iobj_multi_control
    WHERE progname EQ sy-repid AND
          dynnr    EQ sy-dynnr.
    IF ls_iobj_multi_control-alv_ref IS BOUND.
      CALL METHOD ls_iobj_multi_control-alv_ref->check_changed_data
        IMPORTING
          e_valid = lv_valid.
*If error occured then stop the process
      IF lv_valid IS INITIAL.
        lv_error = GC_XFLAG.
*Update an error flag and return table
        CALL FUNCTION '/DBE/VM08_ERROR_SET'
          EXPORTING
            iv_error = lv_error.
*Get error message
        READ TABLE
ls_iobj_multi_control-event_receiver_ref->mo_protocol->mt_protocol
          INTO ls_protocol WITH KEY msgty = 'E'.
        IF sy-subrc EQ 0.
          MESSAGE ID ls_protocol-msgid TYPE ls_protocol-msgty
            NUMBER ls_protocol-msgno
             WITH ls_protocol-msgv1 ls_protocol-msgv2 ls_protocol-msgv3
                   ls_protocol-msgv4.
        ELSE.
          MESSAGE e001(/DBE/vehicle_master) WITH space.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_IOBJ_MULTI_SET

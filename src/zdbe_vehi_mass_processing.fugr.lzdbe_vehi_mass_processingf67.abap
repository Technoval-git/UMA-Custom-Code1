*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF67 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  POPULATE_MAIN_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_main_message .

  DATA: lo_vbuf TYPE REF TO /DBE/cl_veh_buf,
        lo_vehi TYPE REF TO /DBE/cl_veh_dbmvehicle,
        ls_msg_return  TYPE bapiret2,
        ls_bob_info TYPE /DBE/s_veh_bob,
        lt_bob_info TYPE /DBE/t_veh_bob.

  CALL METHOD /DBE/cl_veh_buf=>get_instance
    RECEIVING
      ro_instance = lo_vbuf.
  TRY.
    CALL METHOD lo_vbuf->get_all
      RECEIVING
        rt_bob = lt_bob_info.
  ENDTRY.

  LOOP AT gt_vsresult_selection INTO gs_selection.
    READ TABLE lt_bob_info INTO ls_bob_info WITH KEY guid = gs_selection-vguid.
    IF sy-subrc = 0.
      lo_vehi ?= ls_bob_info-bobref.
      IF lo_vehi->mo_bal IS BOUND.
*          Set main message
        CLEAR ls_msg_return.
        CALL METHOD lo_vehi->mo_bal->get_and_refresh_main_message
          IMPORTING
            es_main_message = ls_msg_return
          EXCEPTIONS
            nothing_found   = 0
            OTHERS          = 0.

*   Show main message which must be generic ; so based on the success/failure of action
*   convert them to DBM generic messages
        IF ls_msg_return-type = 'S'.
          IF gv_action EQ /DBE/if_vms_constants=>c_qpdi.
            MESSAGE ID '/DBE/VEHICLE_MASTER'
                  TYPE 'S'
                  NUMBER 458.
          ELSE.
            MESSAGE ID '/DBE/VEHICLE_MASTER' "ls_msg_return-id
                    TYPE 'S'
                    NUMBER 407
                    WITH ls_msg_return-message_v1 .
          ENDIF.
        ELSEIF ls_msg_return-type = 'E'  .
          MESSAGE ID '/DBE/VEHICLE_MASTER' "ls_msg_return-id
                 TYPE 'S'
                 NUMBER '408'
                 WITH ls_msg_return-message_v1 DISPLAY LIKE 'E'.
*          gv_action_status  = 'E'.
        ELSEIF  ls_msg_return-type = 'W' . " if the log contains warnings, main messagae also will hold W ,in that case display as warning
          MESSAGE ID '/DBE/VM' "ls_msg_return-id
                    TYPE 'S'
                    NUMBER '002'
                    WITH ls_msg_return-message_v1 ls_msg_return-message_v2 DISPLAY LIKE 'W'.

        ENDIF.

        CLEAR ls_msg_return.
      ENDIF.

    ENDIF.
  ENDLOOP.
  TRY.
      lo_vbuf->unlock( ).
*     CALL METHOD lo_vbuf->rem_bob.
    CATCH /DBE/cx_veh_error_occured .
  ENDTRY.
ENDFORM.                    " POPULATE_MAIN_MESSAGE

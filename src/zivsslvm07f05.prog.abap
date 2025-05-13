*&---------------------------------------------------------------------*
*& Include          ZIVSSLVM07F05
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SHOW_STANDARDDOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*----------------------------------------------------------------------*
FORM f_show_standarddocument  USING e_row LIKE lvc_s_row.

  DATA rcode TYPE i.
  DATA lv_vguid LIKE vlcvehicle-vguid.
  DATA lv_action LIKE cvlc03-aktion.
  DATA ls_detail_history TYPE hist_out.
  DATA lt_clicked_row TYPE lvc_t_row.
  DATA lt_bapiret     TYPE bapiret2_t.
  DATA ls_mess     TYPE string.
  DATA ls_message  TYPE bapiret2.
  DATA lv_confirm  TYPE char1.

* Lookup the modell on which the double click happened.
  READ TABLE gt_detail_history INDEX e_row-index
    INTO ls_detail_history.

  lv_vguid  = ls_detail_history-vguid.
  lv_action = ls_detail_history-action.

* Mark the clicked row.
  REFRESH lt_clicked_row.
  APPEND e_row TO lt_clicked_row.
  CALL METHOD go_dethistory_alv->set_selected_rows
    EXPORTING
      it_index_rows = lt_clicked_row.


  CALL FUNCTION '/DBE/VM08_VEHICLE_TRANS_EXIT'
    IMPORTING
      ev_confirm = lv_confirm.
  IF lv_confirm <> 'C'.                           "only when vehicle save was not canceled N:1851391
*   Call the corresponding transaction.
    CALL FUNCTION 'VELO02_CALL_TRANSACTION'
      EXPORTING
        vguid_iv             = lv_vguid
        tstamp_iv            = ls_detail_history-tstmp
        actdoctype_iv        = ls_detail_history-actdoctype
        action_iv            = lv_action
      EXCEPTIONS
        not_supported_action = 1
        not_defined_action   = 2
        no_document_found    = 3
        internal_error       = 4
        OTHERS               = 5.

    IF sy-subrc NE 0.
      CASE sy-subrc.
        WHEN 2.
          MESSAGE w094(VELO) INTO ls_mess.
        WHEN OTHERS.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO INTO ls_mess
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDCASE.
      ls_message-message = ls_mess.
      ls_message-type = SY-MSGTY.
      ls_message-id = SY-MSGID.
      ls_message-number = SY-MSGNO.
      ls_message-message_v1 = sy-msgv1.
      ls_message-message_v2 = sy-msgv2.
      ls_message-message_v3 = sy-msgv3.
      ls_message-message_v4 = sy-msgv4.
      APPEND ls_message TO lt_bapiret.
      CALL FUNCTION '/DBE/VM08_ERROR_SET'
        EXPORTING
*           IV_ERROR            =
          it_bapireturn       = lt_bapiret.
    ENDIF.

*     Return to transaction, vehicle lock handling
    CALL FUNCTION '/DBE/VM08_VEHICLE_TRANS_RETURN'
      EXPORTING
        iv_vguid = lv_vguid.
  ENDIF.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = gc_xxxx_fc
    IMPORTING
      rc       = rcode.

ENDFORM.                    " F_SHOW_STANDARDDOCUMENT

FUNCTION zvss_wy_iv_data_get.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_RCODE) TYPE  WTY_RCODE_TAB OPTIONAL
*"     REFERENCE(IV_RCODE_MAX) TYPE  SYSUBRC OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  WTY_MODE OPTIONAL
*"     REFERENCE(IV_ACODE) TYPE  WTY_ACODE OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_RETURN_CODE) TYPE  SYSUBRC
*"     REFERENCE(EV_SAVE_DATA) TYPE  C
*"  CHANGING
*"     REFERENCE(CT_PRELID) TYPE  PRWTY_TAB OPTIONAL
*"     REFERENCE(CS_PNWTYH_DIA) TYPE  WTY_PNWTYH_DIA OPTIONAL
*"     REFERENCE(CT_PNWTYV_DIA) TYPE  WTY_PNWTYV_DIA_TAB OPTIONAL
*"     REFERENCE(CT_PVWTY_DIA) TYPE  WTY_PVWTY_DIA_TAB OPTIONAL
*"----------------------------------------------------------------------

  DATA: lo_log      TYPE REF TO zvss_ifm_cl_x_log,
        lt_messages TYPE bapiret2_t.

  IF iv_rcode_max > 0.
    ev_return_code = 2.
    EXIT.
  ENDIF.


************************************************************************
*  Create a log
************************************************************************
*  TRY .
*      CREATE OBJECT lo_log
*        EXPORTING
*          iv_object    = 'YDBM_ID1'    " Application log: Object name (Application code)
*          iv_subobject = 'YDBM_ID1_SPICS'    " Application Log: Subobject
*          iv_ext_no    = space.   " Application Log: External ID
*
*    CATCH zvss_cx_ifm_log.
*      ev_return_code = 4.
*      ev_save_data   = abap_false.
*      RETURN.
*  ENDTRY.



************************************************************************
*  Clear messages
************************************************************************
  CALL FUNCTION 'WTY07_CLEAR_DFLMESSAGES'
    EXPORTING
      iv_dflmsg = 'RW'
      iv_pnguid = cs_pnwtyh_dia-pnguid.

  TRY .
************************************************************************
*  Run processing
************************************************************************
*      lo_i02_claim->process( EXPORTING
*                                 io_log         = lo_log
*                             CHANGING
*                                 cs_pnwtyh_dia  = cs_pnwtyh_dia
*                                 ct_pnwtyv_dia  = ct_pnwtyv_dia[]
*                                 ct_pvwty_dia   = ct_pvwty_dia[] ).

      CALL FUNCTION 'ZWTY_UPLOAD_TEMP'
        EXPORTING
*         wty_upload    =
          cs_pnwtyh_dia = cs_pnwtyh_dia
          ct_pnwtyv_dia = ct_pnwtyv_dia
          ct_pvwty_dia  = ct_pvwty_dia
*     IMPORTING
*         RETURN        =
        .


************************************************************************
*  Set status after success
************************************************************************

      ev_return_code = 0.
      ev_save_data   = abap_true.

*      lo_i02_claim->set_status(
*          io_log           = lo_log
*          iv_status        = ycl_dbm_jet_id1_i02_claim=>mc_status-success ).

    CATCH zvss_cx_ifm_log.
************************************************************************
*  Set status after fail
************************************************************************

      ev_return_code = 4.
      ev_save_data   = abap_false.

*      lo_i02_claim->set_status(
*          io_log           = lo_log
*          iv_status        = ycl_dbm_jet_id1_i02_claim=>mc_status-error ).

  ENDTRY.


************************************************************************
*  Collect messages from the log
************************************************************************
*  lt_messages = lo_log->get_messages( ).
*  LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<ls_messages>).
*    IF <ls_messages>-type IS INITIAL.
*      <ls_messages>-type = 'E'.
*    ENDIF.
*    MESSAGE ID <ls_messages>-id
*    TYPE <ls_messages>-type
*    NUMBER <ls_messages>-number
*    WITH <ls_messages>-message_v1
*         <ls_messages>-message_v2
*         <ls_messages>-message_v3
*         <ls_messages>-message_v4 INTO zvss_ifm_cl_x_log=>mv_dummy.
*
*    CALL FUNCTION 'WTY07_MESSAGE_PROCESSING_SYST'
*      EXPORTING
*        iv_dflmsg = 'RW'
*        iv_pnguid = cs_pnwtyh_dia-pnguid.
*  ENDLOOP.



ENDFUNCTION.

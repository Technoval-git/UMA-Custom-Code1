class ZCX_ERROR definition
  public
  inheriting from CX_RS_MSG
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  class-data MV_DUMMY type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      value(MSGID) type SYMSGID optional
      value(MSGNO) type SYMSGNO optional
      value(MSGTY) type SYMSGTY optional
      value(MSGV1) type SYMSGV optional
      value(MSGV2) type SYMSGV optional
      value(MSGV3) type SYMSGV optional
      value(MSGV4) type SYMSGV optional
      !MV_DUMMY type STRING optional .
  methods APPEND_MESSAGE
    importing
      value(IV_MSGID) type SYMSGID optional
      value(IV_MSGTY) type SYMSGTY default 'E'
      value(IV_MSGNO) type SYMSGNO
      !IV_MSGV1 type ANY optional
      !IV_MSGV2 type ANY optional
      !IV_MSGV3 type ANY optional
      !IV_MSGV4 type ANY optional .
  methods APPEND_BAPI_MSG
    importing
      !IS_MSG type BAPIRET2 .
  methods APPEND_BAPI_MSGS
    importing
      !IT_MSG type BAPIRET2_T .
  methods APPEND_SY_MSG .
  class-methods RAISE_SY_MSG
    raising
      ZCX_ERROR .
  class-methods CONTAIN_ERROR
    importing
      !IT_MSG type BAPIRET2_T
    returning
      value(RV_ERROR) type ABAP_BOOL .
  methods IS_ERROR
    returning
      value(RV_ERROR) type ABAP_BOOL .
  methods GET_BAPI_MSGS
    returning
      value(RT_MSG) type BAPIRET2_T .
  methods GET_BAPI_MSG
    returning
      value(RS_BAPIRET2) type BAPIRET2 .
  methods DISPLAY_AS_POPUP .
protected section.
private section.

  data MS_MSG type BAPIRET2 .
  data MT_MSG type BAPIRET2_T .
  constants C_STACK_LEVEL type I value 2 ##NO_TEXT.
  constants C_STACK_SEPARATOR type CHAR1 value '/' ##NO_TEXT.

  methods PREPARE_STACK_MESSAGE
    importing
      !IT_CALLSTACK type ABAP_CALLSTACK
    returning
      value(RV_TEXT) type STRING .
ENDCLASS.



CLASS ZCX_ERROR IMPLEMENTATION.


  METHOD append_bapi_msg.

    ms_msg = is_msg.

    APPEND ms_msg TO mt_msg.

  ENDMETHOD.


  METHOD append_bapi_msgs.

    LOOP AT it_msg ASSIGNING FIELD-SYMBOL(<ls_msg>).
      CALL METHOD append_message
        EXPORTING
          iv_msgid = <ls_msg>-id    " Message Class
          iv_msgty = <ls_msg>-type    " Message Type
          iv_msgno = <ls_msg>-number    " Message Number
          iv_msgv1 = <ls_msg>-message_v1
          iv_msgv2 = <ls_msg>-message_v2
          iv_msgv3 = <ls_msg>-message_v3
          iv_msgv4 = <ls_msg>-message_v4.
    ENDLOOP.

  ENDMETHOD.


  METHOD APPEND_MESSAGE.

    DATA:
      lv_dummy     TYPE string,
      lv_source    TYPE string,
      lt_callstack TYPE abap_callstack.

    IF iv_msgid IS INITIAL.
      CALL FUNCTION 'SYSTEM_CALLSTACK'
        EXPORTING
          max_level = c_stack_level
        IMPORTING
          callstack = lt_callstack.

      lv_source = prepare_stack_message( lt_callstack ).

      MESSAGE e205(ts) WITH lv_source INTO lv_dummy.
      ms_msg-id = sy-msgid.
      ms_msg-type = sy-msgty.
      ms_msg-number = sy-msgno.
      ms_msg-message_v1 = sy-msgv1.
      ms_msg-message_v2 = sy-msgv2.
      ms_msg-message_v3 = sy-msgv3.
      ms_msg-message_v4 = sy-msgv4.
    ELSE.
      ms_msg-id = iv_msgid.
      ms_msg-type = iv_msgty.
      ms_msg-number = iv_msgno.
      ms_msg-message_v1 = iv_msgv1.
      ms_msg-message_v2 = iv_msgv2.
      ms_msg-message_v3 = iv_msgv3.
      ms_msg-message_v4 = iv_msgv4.
    ENDIF.



    MESSAGE ID ms_msg-id TYPE ms_msg-type NUMBER ms_msg-number
    WITH ms_msg-message_v1 ms_msg-message_v2 ms_msg-message_v3 ms_msg-message_v4
    INTO ms_msg-message.

    APPEND ms_msg TO mt_msg.

  ENDMETHOD.


  METHOD append_sy_msg.

    CALL METHOD append_message
      EXPORTING
        iv_msgid = sy-msgid
        iv_msgty = sy-msgty
        iv_msgno = sy-msgno
        iv_msgv1 = sy-msgv1
        iv_msgv2 = sy-msgv2
        iv_msgv3 = sy-msgv3
        iv_msgv4 = sy-msgv4.

  ENDMETHOD.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSGID = MSGID
MSGNO = MSGNO
MSGTY = MSGTY
MSGV1 = MSGV1
MSGV2 = MSGV2
MSGV3 = MSGV3
MSGV4 = MSGV4
.
me->MV_DUMMY = MV_DUMMY .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD contain_error.

    rv_error = abap_false.

    LOOP AT it_msg TRANSPORTING NO FIELDS
    WHERE type CA 'EAX'.
      rv_error = abap_true.
      RETURN.
    ENDLOOP.

  ENDMETHOD.


  METHOD display_as_popup.

    DATA(lo_log) = cf_reca_message_list=>create( ).

    lo_log->add_from_bapi( it_bapiret = me->mt_msg ).

    CALL FUNCTION 'RECA_GUI_MSGLIST_POPUP'
      EXPORTING
        io_msglist = lo_log.

  ENDMETHOD.


  METHOD get_bapi_msg.

    rs_bapiret2 = ms_msg.

  ENDMETHOD.


  METHOD GET_BAPI_MSGS.

    rt_msg = mt_msg.

  ENDMETHOD.


  method IS_ERROR.

  rv_error = abap_false.

  LOOP AT mt_msg TRANSPORTING NO FIELDS
  WHERE TYPE CA 'EAX'.
    rv_error = abap_true.
    RETURN.
  ENDLOOP.

  endmethod.


  METHOD PREPARE_STACK_MESSAGE.

    READ TABLE it_callstack ASSIGNING FIELD-SYMBOL(<ls_callstack>)
    INDEX c_stack_level .
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    CONCATENATE
    <ls_callstack>-mainprogram
    <ls_callstack>-include
    <ls_callstack>-blocktype
    INTO rv_text
    SEPARATED BY c_stack_separator.

  ENDMETHOD.


  METHOD raise_sy_msg.

    DATA(lo_ex) = NEW zcx_error( ).

    lo_ex->append_sy_msg( ).

    RAISE EXCEPTION lo_ex.

  ENDMETHOD.
ENDCLASS.

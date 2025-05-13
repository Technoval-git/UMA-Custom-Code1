*----------------------------------------------------------------------*
***INCLUDE LZVSS_CUS_ACTIONSF02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  messages_give
*&---------------------------------------------------------------------*
FORM messages_give TABLES it_return TYPE bapiret2_t.

*-> local declaration
  DATA: ls_mesg   TYPE smesg,
        ls_return TYPE bapiret2.

  DATA: lt_mesg   TYPE tsmesg.

************************************************************************


*-> get messages
  CALL FUNCTION 'MESSAGES_GIVE'
    TABLES
      t_mesg = lt_mesg.

  LOOP AT lt_mesg INTO ls_mesg
                  WHERE msgty = 'A'
                  OR    msgty = 'E'.

    ls_return-type       = ls_mesg-msgty.
    ls_return-message    = ls_mesg-text.
    ls_return-id         = ls_mesg-arbgb.
    ls_return-number     = ls_mesg-txtnr.
    ls_return-message_v1 = ls_mesg-msgv1.
    ls_return-message_v2 = ls_mesg-msgv2.
    ls_return-message_v3 = ls_mesg-msgv3.
    ls_return-message_v4 = ls_mesg-msgv4.

    APPEND ls_return TO it_return.
  ENDLOOP.

ENDFORM.                    " messages_give

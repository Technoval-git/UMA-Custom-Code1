class ZCL_FI_CASHDESK_ENH definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_EX_TILL_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_CASHDESK_ENH IMPLEMENTATION.


  method /DBE/IF_EX_TILL_BADI~RBKP_VALUE_REQUEST.
  endmethod.


  method /DBE/IF_EX_TILL_BADI~SEARCH_VALUES.
  endmethod.


  METHOD /dbe/if_ex_till_badi~till_logon.

    TYPES: BEGIN OF ls_cashdesk,
             cashdesk TYPE /dbe/t_log_wp-wp_log,
           END OF ls_cashdesk.

    DATA: lv_uname        LIKE sy-uname,
          lv_wp_cn        TYPE /dbe/t_wp_cn,
          lv_wp_log       TYPE /dbe/t_wp_log,
          lv_count        TYPE sy-dbcnt,
          lt_valuetab     TYPE STANDARD TABLE OF ls_cashdesk,
          lt_return_value TYPE STANDARD TABLE OF ddshretval,
          lt_cdwcs        TYPE STANDARD TABLE OF zcash_desk_user,
          lw_cdwcs        TYPE zcash_desk_user,
          lv_return       TYPE bapiret2,
          enqueu_list     TYPE TABLE OF seqg3,
          ls_valuetab     TYPE ls_cashdesk,
          ls_return_value TYPE ddshretval.


    CONSTANTS: fb_name(50) TYPE c VALUE '/DBE/TC_TILL_LOGON'.

    DATA: ls_return TYPE bapiret2.

***get logon user
    lv_uname = sy-uname.

* Get the CDWCs the user is authorized for
    SELECT * FROM zcash_desk_user INTO TABLE lt_cdwcs
      WHERE uname = lv_uname.
    IF lines( lt_cdwcs ) = 0.
      CLEAR lv_return.
      MESSAGE ID '/DBE/TILL' TYPE 'E' NUMBER '005'
              INTO lv_return-message WITH fb_name.
      lv_return-id = sy-msgid.
      lv_return-type = sy-msgty.
      lv_return-number = sy-msgno.
      lv_return-message_v1  = fb_name.
      lv_return-message_v2  = sy-msgv2.
      lv_return-message_v3  = sy-msgv3.
      lv_return-message_v4  = sy-msgv4.
      APPEND lv_return TO et_return.
      EXIT.

    ELSEIF lines( lt_cdwcs ) = 1.
      READ TABLE lt_cdwcs INTO lw_cdwcs INDEX 1.
      IF sy-subrc = 0.
        lv_wp_log = lw_cdwcs-wp_log.
      ENDIF.
    ELSE. ">1 CDWCs
      LOOP AT lt_cdwcs INTO lw_cdwcs.
        APPEND lw_cdwcs-wp_log TO lt_valuetab.
      ENDLOOP.
      IF lines( lt_valuetab ) > 0.
        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
            retfield        = 'CASHDESK'
            dynpprog        = '/DBE/SAPLTILL_COMMON'
            value_org       = 'S'
          TABLES
            value_tab       = lt_valuetab
            return_tab      = lt_return_value
          EXCEPTIONS
            parameter_error = 1
            no_values_found = 2
            OTHERS          = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        IF NOT lt_return_value IS INITIAL.
          READ TABLE lt_return_value INTO ls_return_value INDEX 1.
          IF sy-subrc = 0.
            lv_wp_log = ls_return_value-fieldval.
          ENDIF.
        ELSE.
          CLEAR lv_return.
          MESSAGE ID '/DBE/TILL' TYPE 'E' NUMBER '005'
                  INTO lv_return-message WITH fb_name.
          lv_return-id = sy-msgid.
          lv_return-type = sy-msgty.
          lv_return-number = sy-msgno.
          lv_return-message_v1  = fb_name.
          lv_return-message_v2  = sy-msgv2.
          lv_return-message_v3  = sy-msgv3.
          lv_return-message_v4  = sy-msgv4.
          APPEND lv_return TO et_return.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_wp_log IS INITIAL.
      CLEAR lv_return.
      MESSAGE ID '/DBE/TILL' TYPE 'E' NUMBER '005'
              INTO lv_return-message WITH fb_name.
      lv_return-id = sy-msgid.
      lv_return-type = sy-msgty.
      lv_return-number = sy-msgno.
      lv_return-message_v1  = fb_name.
      lv_return-message_v2  = sy-msgv2.
      lv_return-message_v3  = sy-msgv3.
      lv_return-message_v4  = sy-msgv4.
      APPEND lv_return TO et_return.
      EXIT.
    ENDIF.


*lock the till work place

    CALL FUNCTION 'ENQUEUE_/DBE/E_LOG_WP'
      EXPORTING
        mode_/dbe/t_log_wp = 'E'
        mandt              = sy-mandt
        wp_log             = lv_wp_log
        x_wp_log           = ' '
        _scope             = '3'
        _wait              = ' '
        _collect           = ' '
      EXCEPTIONS
        foreign_lock       = 1
        system_failure     = 2
        OTHERS             = 3.

    IF sy-subrc <> 0.

      CLEAR lv_return.

      MESSAGE ID '/DBE/TILL' TYPE 'E' NUMBER '008'
              INTO lv_return-message WITH sy-msgv1 sy-msgv1 sy-msgv2 sy-msgv3.

      lv_return-id = sy-msgid.
      lv_return-type = sy-msgty.
      lv_return-number = sy-msgno.
      lv_return-message_v1  = sy-msgv1.
      lv_return-message_v2  = sy-msgv2.
      lv_return-message_v3  = sy-msgv3.
      lv_return-message_v4  = sy-msgv4.
      APPEND lv_return TO et_return.
      EXIT.
    ENDIF.

*ok
    es_till_wp_log = lv_wp_log.
    ev_success = 'X'.
  ENDMETHOD.


  METHOD /dbe/if_ex_till_badi~user_command.

    DATA : lv_export(30) TYPE c.

    IF cv_ok_code EQ 'SAVE' OR
       cv_ok_code EQ 'BOOK' OR
       cv_ok_code EQ 'BOOK_PRINT'.
      CONCATENATE cs_till_session-wp_log '-' cs_work_line-payment_type INTO lv_export.
      EXPORT zcash_desk FROM lv_export TO MEMORY ID 'ZCASH'.
      DATA : lv_cash_desk TYPE  /dbe/t_wp_log.
      EXPORT lv_cash_desk FROM cs_twp_detail-wp_log TO MEMORY ID 'CASHDESK_ID'.
    ENDIF.

  ENDMETHOD.


  METHOD /dbe/if_ex_till_badi~user_command_analyse.
  ENDMETHOD.


  method /DBE/IF_EX_TILL_BADI~USER_STATUS.
  endmethod.
ENDCLASS.

FUNCTION zdbe_co_act_create_settle_rule.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_ACTION) TYPE  /DBE/OE_ACTION
*"     REFERENCE(IO_ORDER) TYPE REF TO  /DBE/CL_ORDER
*"     REFERENCE(LT_AUFNR_LIST) TYPE  ANY
*"  EXCEPTIONS
*"      INTERNAL_ERROR
*"      NOTHING_DONE
*"      ACTION_ERROR
*"----------------------------------------------------------------------

*-> local declaration
  DATA: lv_rule_ins    TYPE sy-batch.
  DATA: lv_erkrs       TYPE tka01-erkrs.
  DATA: lv_aufart      TYPE /dbe/vbak_com-aufart.
  DATA: lv_objnr       TYPE aufk-objnr.
  DATA: lv_no_zuo      TYPE c.
  DATA: lv_werks       TYPE werks_d.
  DATA: lv_kokrs       TYPE kokrs.
  DATA: lv_bukrs       TYPE bukrs.
  DATA: lv_mdummy      TYPE string.
  DATA: lv_count(6)    TYPE n.
  DATA: lv_aufnr_rec   TYPE aufnr.
  DATA: lv_prctr       TYPE prctr.
  DATA: lv_index       TYPE kauf-auf_index.
  DATA: lv_acas_typ    TYPE /dbe/s_acas_typ.

  DATA: ls_tka01       TYPE tka01.
  DATA: ls_splhdr      TYPE /dbe/splhdr_com.
  DATA: ls_srules      TYPE srules_ext.
  DATA: ls_criteria    TYPE bapi_copa_data.
  DATA: ls_settle      TYPE /dbe/co_settle.
  DATA: ls_settle_work TYPE t_settle_work.
  DATA: ls_ordertp     TYPE /dbe/c_ordertp.
  DATA: ls_ordertpt    TYPE /dbe/c_ordertpt.
  DATA: ls_auart_re    TYPE /dbe/co_auart_re.
  DATA: ls_return      TYPE bapiret2.
  DATA: ls_mseg        TYPE smesg.
  DATA: ls_coas        TYPE coas.
  DATA: ls_kauf        TYPE kauf.
  DATA: ls_tkb1a       TYPE tkb1a.

  DATA: lt_srules      LIKE TABLE OF ls_srules.
  DATA: lt_criteria    LIKE TABLE OF ls_criteria.
  DATA: lt_settle      LIKE TABLE OF ls_settle.
  DATA: lt_settle_work LIKE TABLE OF ls_settle_work.
  DATA: lt_mseg        TYPE tsmesg.

  DATA: ls_vbak    TYPE /dbe/vbak_com,
        t_splhdr   TYPE /dbe/splhdr_com_tt,
        lt_return  TYPE bapiret2_t,
        lv_success TYPE /dbe/success.

  FIELD-SYMBOLS: <cobl> TYPE cobl.

  TYPES: BEGIN OF t_aufnr_list,
           vguid TYPE vlc_guid,
           aufnr TYPE aufnr,
         END OF t_aufnr_list.
  TYPES: tt_aufnr_list TYPE STANDARD TABLE OF t_aufnr_list.

  DATA : lt_vehi_list TYPE tt_aufnr_list.
  DATA : lt_splt_com TYPE /dbe/split_com_tt,
         ls_splt_com TYPE /dbe/split_com.
  DATA : lt_vbap TYPE /dbe/vbap_com_tt,
         ls_vbap TYPE /dbe/vbap_com.
************************************************************************
  lt_vehi_list = lt_aufnr_list.


  BREAK-POINT ID /dbe/co_settlem_rule.

*-> mapping
  ls_vbak          = io_order->ms_vbak_com.
  t_splhdr         = io_order->mt_splhdr_com.
  lt_splt_com      = io_order->mt_split_com.
  lt_vbap          = io_order->mt_vbap_com.

*-> initialization
  REFRESH lt_srules.    CLEAR ls_srules.
  REFRESH lt_criteria.  CLEAR ls_criteria.
  REFRESH lt_settle.    CLEAR ls_settle.
  lv_success = 'X'.

*-> determine, if creation of settlement rule is necessary
*  READ TABLE t_splhdr INTO ls_splhdr
*                      WITH KEY slctd = 'X'.

  LOOP AT t_splhdr INTO ls_splhdr WHERE slctd = 'X'.
    LOOP AT lt_splt_com INTO ls_splt_com WHERE vbeln EQ ls_splhdr-vbeln AND splnr EQ ls_splhdr-splnr.
      READ TABLE lt_vbap INTO ls_vbap WITH KEY vbeln = ls_splt_com-vbeln posnr = ls_splt_com-posnr.
      IF sy-subrc EQ 0.
        READ TABLE lt_vehi_list INTO DATA(ls_vehi_list) WITH KEY vguid = ls_vbap-vguid.
        IF sy-subrc EQ 0.

*  IF sy-subrc <> 0.
*    MESSAGE e020 INTO lv_mdummy.
*    io_order->bal_add_symessage( ).
*    EXIT.
*  ENDIF.

*-> mapping
          lv_aufart     = ls_splhdr-aufart.
          lv_werks      = ls_vbak-werks.
          lv_kokrs      = ls_vbak-kokrs.
          lv_aufnr_rec  = ls_vehi_list-aufnr.    "ls_splhdr-aufnr_rec.
          lv_bukrs      = ls_vbak-bukrs_vf.

*-> check, if internal order number for receiver is filled
          IF lv_aufnr_rec IS INITIAL.
*-> Internal error; internal order & not transferred to split header
            MESSAGE e039(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
            io_order->bal_add_symessage( ).
            EXIT.
          ENDIF.

*-> refresh buffer
          CALL FUNCTION 'KAUF_ORDER_RESET'
            EXPORTING
              i_aufnr             = lv_aufnr_rec
              i_index             = 0
              i_reset_all         = ' '
            EXCEPTIONS
              order_not_in_buffer = 1
              illegal_input       = 2
              OTHERS              = 3.

          IF sy-subrc GT 1.
            MESSAGE e046(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
            io_order->bal_add_symessage( ).
            EXIT.
          ENDIF.

*-> activate message handler
          CALL FUNCTION 'MESSAGES_INITIALIZE'.

*-> read profit center from internal order bill-to party
          CALL FUNCTION 'KAUF_ORDER_READ'
            EXPORTING
              i_actvt                = '02'
              i_aufnr                = lv_aufnr_rec
*             i_enqueued             = 'X'
            IMPORTING
              e_coas                 = ls_coas
              e_kauf                 = ls_kauf
            EXCEPTIONS
              auart_not_found        = 1
              foreign_lock           = 2
              no_authority           = 3
              order_not_found        = 4
              order_type_not_valid   = 5
              wrong_input            = 6
              logsystem_inconsistent = 7
              OTHERS                 = 8.

          IF sy-subrc = 0.
            lv_prctr = ls_coas-prctr.
            lv_index = ls_kauf-auf_index.

          ELSE.
*-> Internal order & could not be read
            MESSAGE e052(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
            io_order->bal_add_symessage( ).

*-> check message handler
            PERFORM messages_give TABLES lt_return.

            IF lt_return[] IS NOT INITIAL.
              io_order->bal_add_bapiret2( lt_return ).
              REFRESH lt_return.
            ENDIF.

            EXIT.
          ENDIF.


*-> retrieve object number of internal order for receiver
          CALL FUNCTION 'K_AUFNR_OBJECT_KEY_GET'
            EXPORTING
              aufnr = lv_aufnr_rec
              kokrs = lv_kokrs
            IMPORTING
              objnr = lv_objnr.

*-> check, if normal settlement rule already
*-> exists for internal order
          CALL FUNCTION 'STATUS_CHECK'
            EXPORTING
              objnr             = lv_objnr
              status            = 'I0028'
            EXCEPTIONS
              object_not_found  = 1
              status_not_active = 2
              OTHERS            = 3.

          IF sy-subrc = 0.
*-> Settlement rule for internal order & already exists
            MESSAGE i045(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
            io_order->bal_add_symessage( ).
            EXIT.

          ELSEIF sy-subrc = 2.
*-> check, if easy settlement rule already
*-> exists for internal order
            CALL FUNCTION 'STATUS_CHECK'
              EXPORTING
                objnr             = lv_objnr
                status            = 'I0027'
              EXCEPTIONS
                object_not_found  = 1
                status_not_active = 2
                OTHERS            = 3.

            IF sy-subrc = 0.
*->   Settlement rule for internal order & already exists
              MESSAGE i045(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
              io_order->bal_add_symessage( ).
              EXIT.

            ENDIF.
          ENDIF.

*-> read order type customizing
          CALL FUNCTION '/DBE/C_GET_ORDER_PARAMETER'
            EXPORTING
              i_aufart    = lv_aufart
              i_kokrs     = lv_kokrs
              i_ac_as_typ = ls_splhdr-ac_as_typ
            IMPORTING
              e_ordertp   = ls_ordertp
              e_ordertpt  = ls_ordertpt
              e_auart_re  = ls_auart_re
            EXCEPTIONS
              not_found   = 1
              OTHERS      = 2.

          IF sy-subrc <> 0
          OR ls_ordertp-auart_co IS INITIAL.
*-> CO order type not found
            MESSAGE e860(/dbe/common) INTO lv_mdummy.
            io_order->bal_add_symessage( ).
            EXIT.
          ENDIF.

          IF ls_ordertp-int_ord   = 'X'
         AND ls_auart_re-int_bill = space.
**-> no settlement into CO-PA, because settlement rule has already
**-> been created with internal order creation
**-> No settlement carried out for order type & in Profitability
**-> Analysis
*    MESSAGE i022 WITH lv_aufart INTO lv_mdummy.
*    io_order->bal_add_symessage( ).
*    EXIT.

            ls_srules-settl_type = 'PER'.
            ls_srules-percentage = '100'.
            ls_srules-comp_code  = ls_vbak-bukrs_vf.

            CALL FUNCTION '/DBE/CO_ACAS_TYP_GET'
              EXPORTING
                iv_ac_as_typ = ls_splhdr-ac_as_typ
              IMPORTING
                es_acas_typ  = lv_acas_typ
              EXCEPTIONS
                not_found    = 1
                OTHERS       = 2.

            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_mdummy.
              io_order->bal_add_symessage( ).
            ENDIF.

            CASE lv_acas_typ-typ.
              WHEN '1'.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_splhdr-kostl
                  IMPORTING
                    output = ls_srules-costcenter.

              WHEN '2'.
                CLEAR ls_srules.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_splhdr-kostl
                  IMPORTING
                    output = ls_coas-kostl.

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_splhdr-kstar
                  IMPORTING
                    output = ls_coas-kstar.

*->     activate message handler
                CALL FUNCTION 'MESSAGES_INITIALIZE'.

*->     store fields in buffer
                CALL FUNCTION 'KAUF_ORDER_STORE'
                  EXPORTING
                    i_check             = 'A'
                    i_coas              = ls_coas
                    i_kauf              = ls_kauf
                    i_save_flag         = 'X'
                  EXCEPTIONS
                    illegal_change      = 1
                    order_not_in_buffer = 2
                    OTHERS              = 3.

                IF sy-subrc = 0.
                  CALL FUNCTION 'KAUF_ORDER_SAVE'
                    EXPORTING
                      i_index = lv_index
                      i_check = ' '.

                  EXIT.

                ELSE.
*->       check message handler
                  PERFORM messages_give TABLES lt_return.

                  IF lt_return[] IS NOT INITIAL.
                    io_order->bal_add_bapiret2( lt_return ).
                    REFRESH lt_return.
                  ENDIF.

                  EXIT.
                ENDIF.

              WHEN '3'.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_splhdr-int_ord
                  IMPORTING
                    output = ls_srules-orderid.

              WHEN '4'.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_splhdr-kdauf_aufk
                  IMPORTING
                    output = ls_srules-sales_ord.

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_splhdr-kdpos_aufk
                  IMPORTING
                    output = ls_srules-s_ord_item.

              WHEN OTHERS.
            ENDCASE.

            IF NOT ls_srules IS INITIAL.
              APPEND ls_srules TO lt_srules.

*->   activate message handler
              CALL FUNCTION 'MESSAGES_INITIALIZE'.

*->   refresh buffer
              ASSIGN ('(SAPLKOBS)COBL') TO <cobl>.
              IF sy-subrc = 0.
                CLEAR <cobl>.
              ENDIF.

              PERFORM set_dbm_call_flag.                    "N.1854869

              DATA : lv_vss(3) TYPE c.
              EXPORT lv_vss TO MEMORY ID 'YVSS'.

*->   add settlement rules according to customizing rule set
              CALL FUNCTION '/DBE/CO_KOBS_K_ORDER_SRULE_ADD' "2020.05.06 KAM, instead of obsolete 'K_ORDER_SRULE_ADD'
                EXPORTING
                  object_no            = lv_objnr
                IMPORTING
                  flg_rule_inserted    = lv_rule_ins
                TABLES
                  srules               = lt_srules
                  criteria             = lt_criteria
                EXCEPTIONS
                  wrong_input          = 1
                  error_occurred       = 2
                  object_not_found     = 3
                  activity_not_allowed = 4
                  OTHERS               = 5.

              FREE MEMORY ID 'YVSS'.

              PERFORM reset_dbm_call_flag.                  "N.1854869

              IF sy-subrc <> 0.
                CASE sy-subrc.
                  WHEN '1'.
                    MESSAGE e032(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
                  WHEN '2'.
                    MESSAGE e033(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
                  WHEN '3'.
                    MESSAGE e034(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
                  WHEN '4'.
                    MESSAGE e035(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
                  WHEN OTHERS.
                    MESSAGE e036(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
                ENDCASE.
                io_order->bal_add_symessage( ).
                REFRESH lt_srules.    CLEAR ls_srules.
                REFRESH lt_criteria.  CLEAR ls_criteria.
                REFRESH lt_settle.    CLEAR ls_settle.

*->     check message handler
                PERFORM messages_give TABLES lt_return.

                IF lt_return[] IS NOT INITIAL.
                  io_order->bal_add_bapiret2( lt_return ).
                  REFRESH lt_return.
                ENDIF.

                EXIT.
              ENDIF.
            ENDIF.
            EXIT.
          ENDIF.


          IF ls_ordertp-collect_int_ord EQ 'X'.
*-> Receiver & is a collective order; no settlement rule was created
            MESSAGE i025(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
            io_order->bal_add_symessage( ).
            EXIT.
          ENDIF.

*-> Settlement rule created for internal order & automatically
          MESSAGE i038(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
          io_order->bal_add_symessage( ).

*-> get operating concern
          CALL FUNCTION 'CO_TA_TKA01_READ'
            EXPORTING
              kokrs_imp = lv_kokrs
            IMPORTING
              struct    = ls_tka01
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.

          IF sy-subrc <> 0.
*>  No operating concern found for controlling area &
            MESSAGE e019(/dbe/co) WITH ls_vbak-kokrs INTO lv_mdummy.
            io_order->bal_add_symessage( ).
            EXIT.
          ENDIF.
          lv_erkrs = ls_tka01-erkrs.

*-> get settlement profile of internal order
          CALL FUNCTION 'K_OBJECT_APROF_GET'
            EXPORTING
              i_objnr   = lv_objnr
            IMPORTING
              e_tkb1a   = ls_tkb1a
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.

          IF sy-subrc <> 0.
*-> Settlement profile for order & not found
            MESSAGE e054(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
            io_order->bal_add_symessage( ).
            EXIT.
          ENDIF.

*-> get data for settlement rule from customizing table /DBE/CO_SETTLE
          CALL FUNCTION '/DBE/CO_DB_GET_SETLE_PAR'
            EXPORTING
              iv_auart     = lv_aufart
              iv_erkrs     = lv_erkrs
              iv_ursch     = ls_tkb1a-ursch
            IMPORTING
              et_co_settle = lt_settle
            EXCEPTIONS
              not_found    = 1
              OTHERS       = 2.

*-> check, if customizing table is empty
          IF lt_settle[] IS INITIAL OR sy-subrc NE 0.
*-> Define settlement parameters for order type & in Customizing
            MESSAGE w021(/dbe/co) WITH lv_aufart INTO lv_mdummy.
            io_order->bal_add_symessage( ).
            EXIT.
          ELSE.
*-> Customizing entries for settlement rule creation found; &
            MESSAGE i037(/dbe/co) WITH lv_aufart INTO lv_mdummy.
            io_order->bal_add_symessage( ).
            lv_success = 'X'.
          ENDIF.

**-> activate message handler
*  CALL FUNCTION 'MESSAGES_INITIALIZE'.
*
**-> read profit center from internal order bill-to party
*  CALL FUNCTION 'KAUF_ORDER_READ'
*    EXPORTING
*      i_actvt                = '03'
*      i_aufnr                = lv_aufnr_rec
*    IMPORTING
*      e_coas                 = ls_coas
*    EXCEPTIONS
*      auart_not_found        = 1
*      foreign_lock           = 2
*      no_authority           = 3
*      order_not_found        = 4
*      order_type_not_valid   = 5
*      wrong_input            = 6
*      logsystem_inconsistent = 7
*      OTHERS                 = 8.
*
*  IF sy-subrc = 0.
*    lv_prctr = ls_coas-prctr.
*  ELSE.
**-> Internal order & could not be read
*    MESSAGE e052 WITH lv_aufnr_rec INTO lv_mdummy.
*    io_order->bal_add_symessage( ).
*
**-> check message handler
*    CALL FUNCTION 'MESSAGES_GIVE'
*      TABLES
*        t_mesg = lt_mseg.
*
*    LOOP AT lt_mseg INTO ls_mseg.
*      ls_return-type       = ls_mseg-msgty.
*      ls_return-message    = ls_mseg-text.
*      ls_return-id         = ls_mseg-arbgb.
*      ls_return-number     = ls_mseg-txtnr.
*      ls_return-message_v1 = ls_mseg-msgv1.
*      ls_return-message_v2 = ls_mseg-msgv2.
*      ls_return-message_v3 = ls_mseg-msgv3.
*      ls_return-message_v4 = ls_mseg-msgv4.
*
*      APPEND ls_return TO lt_return.
*    ENDLOOP.
*
*    IF lt_return[] IS NOT INITIAL.
*      io_order->bal_add_bapiret2( lt_return ).
*      REFRESH lt_return.
*    ENDIF.
*
*    EXIT.
*  ENDIF.

*-> fill values of settlement table from service order tables
*-> if necessary
          PERFORM co_fill_settle_value TABLES  lt_settle
                                               lt_settle_work
                                       USING   ls_splhdr
                                               ls_vbak.

          SORT lt_settle_work BY urzuo.
          READ TABLE lt_settle_work INTO ls_settle_work INDEX 1.
          IF ls_settle_work-urzuo IS INITIAL.
            lv_no_zuo = 'X'.
          ENDIF.


*-> fill input parameter for function module to create
*-> the settlement rule
          lv_count = 1.
          LOOP AT lt_settle_work INTO ls_settle_work.
            ls_criteria-record_id = lv_count.
            ls_criteria-fieldname = ls_settle_work-merkmal.
            ls_criteria-value     = ls_settle_work-value.
            IF ls_criteria-fieldname EQ 'RKAUFNR'.
              ls_criteria-value = ls_vehi_list-aufnr.
            ENDIF.
            APPEND ls_criteria TO lt_criteria.
            AT END OF urzuo.
              IF lv_no_zuo EQ ' '.
                ls_criteria-record_id = lv_count.
                ls_criteria-fieldname = 'WERKS'.
                ls_criteria-value     = lv_werks.
                APPEND ls_criteria TO lt_criteria.

                IF lv_prctr <> space.
                  CLEAR ls_criteria.
                  ls_criteria-record_id = lv_count.
                  ls_criteria-fieldname = 'PRCTR'.
                  ls_criteria-value     = lv_prctr.
                  APPEND ls_criteria TO lt_criteria.
                ENDIF.
                ls_srules-record_id  = lv_count.
                ls_srules-settl_type = 'PER'.
                ls_srules-percentage = '100'.
                ls_srules-source     = ls_settle_work-urzuo.
                ls_srules-comp_code  = lv_bukrs.
                APPEND ls_srules TO lt_srules.
                ADD 1 TO lv_count.
              ENDIF.
            ENDAT.
          ENDLOOP.
          IF lv_no_zuo EQ 'X'.
            ls_criteria-record_id = lv_count.
            ls_criteria-fieldname = 'WERKS'.
            ls_criteria-value     = lv_werks.
            APPEND ls_criteria TO lt_criteria.

            IF lv_prctr <> space.
              CLEAR ls_criteria.
              ls_criteria-record_id = lv_count.
              ls_criteria-fieldname = 'PRCTR'.
              ls_criteria-value     = lv_prctr.
              APPEND ls_criteria TO lt_criteria.
            ENDIF.
            ls_srules-record_id  = lv_count.
            ls_srules-settl_type = 'PER'.
            ls_srules-percentage = '100'.
            ls_srules-comp_code  = lv_bukrs.
            APPEND ls_srules TO lt_srules.
          ENDIF.


*-> activate message handler
          CALL FUNCTION 'MESSAGES_INITIALIZE'.

*-> refresh buffer
          ASSIGN ('(SAPLKOBS)COBL') TO <cobl>.
          IF sy-subrc = 0.
            CLEAR <cobl>.
          ENDIF.

          PERFORM set_dbm_call_flag.                        "N.1854869

          EXPORT lv_vss TO MEMORY ID 'YVSS'.

*-> add settlement rules according to customizing rule set
          CALL FUNCTION '/DBE/CO_KOBS_K_ORDER_SRULE_ADD' "2020.05.06 KAM, instead of obsolete 'K_ORDER_SRULE_ADD'
            EXPORTING
              object_no            = lv_objnr
            IMPORTING
              flg_rule_inserted    = lv_rule_ins
            TABLES
              srules               = lt_srules
              criteria             = lt_criteria
            EXCEPTIONS
              wrong_input          = 1
              error_occurred       = 2
              object_not_found     = 3
              activity_not_allowed = 4
              OTHERS               = 5.

          FREE MEMORY ID 'YVSS'.

          PERFORM reset_dbm_call_flag.                      "N.1854869

          REFRESH lt_srules.    CLEAR ls_srules.
          REFRESH lt_criteria.  CLEAR ls_criteria.
          REFRESH lt_settle.    CLEAR ls_settle.

          IF sy-subrc <> 0.
            CASE sy-subrc.
              WHEN '1'.
                MESSAGE e032(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
              WHEN '2'.
                MESSAGE e033(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
              WHEN '3'.
                MESSAGE e034(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
              WHEN '4'.
                MESSAGE e035(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
              WHEN OTHERS.
                MESSAGE e036(/dbe/co) WITH lv_aufnr_rec INTO lv_mdummy.
            ENDCASE.
            io_order->bal_add_symessage( ).

*-> check message handler
            PERFORM messages_give TABLES lt_return.

            IF lt_return[] IS NOT INITIAL.
              io_order->bal_add_bapiret2( lt_return ).
              REFRESH lt_return.
            ENDIF.

            EXIT.

**-> check message handler
*    CALL FUNCTION 'MESSAGES_GIVE'
*      TABLES
*        t_mesg = lt_mseg.
*
*    LOOP AT lt_mseg INTO ls_mseg.
*      ls_return-type       = ls_mseg-msgty.
*      ls_return-id         = ls_mseg-arbgb.
*      ls_return-number     = ls_mseg-txtnr.
*      ls_return-message    = ls_mseg-text.
*      ls_return-message_v1 = ls_mseg-msgv1.
*      ls_return-message_v2 = ls_mseg-msgv2.
*      ls_return-message_v3 = ls_mseg-msgv3.
*      ls_return-message_v4 = ls_mseg-msgv4.
*      APPEND ls_return TO lt_return.
*    ENDLOOP.
*
*    IF lt_return[] IS NOT INITIAL.
*      io_order->bal_add_bapiret2( lt_return ).
*      REFRESH lt_return.
*    ENDIF.
*
**-> activate message handler
*    CALL FUNCTION 'MESSAGES_INITIALIZE'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Include          ZIVSS_WTY_HQ_A_UPL_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form process_claim
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_claim.

  CONSTANTS: lc_error   TYPE c VALUE 'E',
             lc_abort   TYPE c VALUE 'A',
             lc_success TYPE c VALUE 'S'.

  SELECT * FROM pnwtyh INTO TABLE lt_pnwtyh
    WHERE clmno IN  s_clmno AND
          astate IN ('B010', 'B020').

  IF lt_pnwtyh IS NOT INITIAL.
    SELECT * FROM zwty_hng_table INTO TABLE @DATA(lt_hng_table)
      FOR ALL ENTRIES IN @lt_pnwtyh
      WHERE clmno EQ @lt_pnwtyh-clmno AND
            status NE 'U'.

    LOOP AT lt_pnwtyh INTO ls_pnwtyh.

      READ TABLE lt_hng_table INTO DATA(ls_hng_table) WITH KEY clmno = ls_pnwtyh-clmno hng_clm_no =  ls_pnwtyh-zoem_claim.
      IF sy-subrc EQ 0 AND ls_hng_table-tot_grs_approved IS NOT INITIAL.
        IF ls_pnwtyh-astate EQ 'B010'.

          CALL FUNCTION 'BAPI_WARRANTYCLAIM_SET_ACTION'
            EXPORTING
              claim                 = ls_pnwtyh-clmno
              action                = gc_incoming
            IMPORTING
              ev_not_exist          = lv_clm_not_exit
              ev_action_not_allowed = lv_clm_not_allow
            TABLES
              return                = it_return
              rule_result           = it_smesg.

        ELSEIF ls_pnwtyh-astate EQ 'B020'.
          CALL FUNCTION 'BAPI_WARRANTYCLAIM_SET_ACTION'
            EXPORTING
              claim                 = ls_pnwtyh-clmno
              action                = gc_simultae
            IMPORTING
              ev_not_exist          = lv_clm_not_exit
              ev_action_not_allowed = lv_clm_not_allow
            TABLES
              return                = it_return
              rule_result           = it_smesg.
        ENDIF.

        LOOP AT it_return INTO DATA(ls_return) WHERE type EQ lc_error OR
                                                     type EQ lc_abort.
          DATA(lv_error) = 'X'.
          EXIT.
        ENDLOOP.

        IF lv_error EQ 'X'.
          ls_hng_table-status = 'E'.
        ELSE.
          ls_hng_table-status = 'U'.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.


          REFRESH: t_bdcdata.
          CLEAR fs_bdcdata.
          PERFORM populate_bdcdata.
          PERFORM insert_data.


*          CALL FUNCTION 'BAPI_WARRANTYCLAIM_SET_ACTION'
*            EXPORTING
*              claim                 = ls_pnwtyh-clmno
*              action                = gc_postclm
*            IMPORTING
*              ev_not_exist          = lv_clm_not_exit
*              ev_action_not_allowed = lv_clm_not_allow
*            TABLES
*              return                = it_return
*              rule_result           = it_smesg.
*
*          LOOP AT it_return INTO ls_return WHERE type EQ lc_error OR
*                                                 type EQ lc_abort.
*            lv_error = 'X'.
*            EXIT.
*          ENDLOOP.
*
*          IF lv_error EQ 'X'.
*
*          ELSE.
*
*            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*              EXPORTING
*                wait = 'X'.
*          ENDIF.
          MODIFY zwty_hng_table FROM ls_hng_table.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POPULATE_BDCDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_bdcdata .
  DATA : lv_date(10) TYPE c.

  CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum+0(4) INTO lv_date.

  PERFORM :
    fill_bdc_data USING 'SAPLPVSUIWTY' '0050' 'X'  ' '  ' ',
    fill_bdc_data USING  ''  ''  ''   'WTY_PNH_DYNPRO-CLMNO' ls_pnwtyh-clmno,
    fill_bdc_data USING  ''  ''  ''   'BDC_CURSOR' 'WTY_PNH_DYNPRO-CLMNO',
    fill_bdc_data USING  ''  ''  ''   'BDC_OKCODE' '=OK',

    fill_bdc_data USING 'SAPLPVSUIWTY' '0060' 'X'  ' '  ' ',
    fill_bdc_data USING  ''  ''  ''   'BDC_OKCODE' '=TOGG',

    fill_bdc_data USING 'SAPLPVSUIWTY' '0060' 'X'  ' '  ' ',
    fill_bdc_data USING  ''  ''  ''   'BDC_OKCODE' '=TAB01',

    fill_bdc_data USING 'SAPLPVSUIWTY' '0060' 'X'  ' '  ' ',
    fill_bdc_data USING  ''  ''  ''   'WTY_PNH_DYNPRO-RELDT' lv_date,
    fill_bdc_data USING  ''  ''  ''    'BDC_CURSOR' 'WTY_PNH_DYNPRO-RELDT',
    fill_bdc_data USING  ''  ''  ''   'BDC_OKCODE' '=SAVE',

    fill_bdc_data USING 'SAPLSPO1' '0500' 'X'  ' '  ' ',
    fill_bdc_data USING  ''  ''  ''   'BDC_OKCODE' '=OPT1'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INSERT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data .

  DATA:
    t_msg      TYPE TABLE OF bdcmsgcoll,   " Collecting Error messages
    w_msg      TYPE bdcmsgcoll,
    w_msg1(51).
  DATA : lv_mode TYPE c VALUE 'N',
         lv_upd  TYPE c VALUE 'S'.

  CALL TRANSACTION 'WTY' USING t_bdcdata
    MODE lv_mode
    UPDATE lv_upd
    MESSAGES INTO t_msg.

ENDFORM.

FORM fill_bdc_data USING VALUE(p_program)
                      VALUE(p_dynpro)
                      VALUE(p_dynbegin)
                      VALUE(p_fnam)
                      VALUE(p_fval).
  CLEAR fs_bdcdata .
  IF p_dynbegin = 'X' .
    fs_bdcdata-program = p_program .
    fs_bdcdata-dynpro  = p_dynpro .
    fs_bdcdata-dynbegin = p_dynbegin .
    APPEND fs_bdcdata TO t_bdcdata.
  ELSE.
    fs_bdcdata-fnam = p_fnam.
    fs_bdcdata-fval = p_fval.
    CONDENSE fs_bdcdata-fval.
    APPEND fs_bdcdata TO t_bdcdata.
  ENDIF.                               " IF p_dynbeg..

ENDFORM .

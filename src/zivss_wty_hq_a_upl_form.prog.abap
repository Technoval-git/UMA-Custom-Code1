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

  SELECT * FROM pnwtyh INTO TABLE @DATA(lt_pnwtyh)
    WHERE clmno IN  @s_clmno AND
          astate EQ 'B010'.

  IF lt_pnwtyh IS NOT INITIAL.
    SELECT * FROM zwty_hng_table INTO TABLE @DATA(lt_hng_table)
      FOR ALL ENTRIES IN @lt_pnwtyh
      WHERE clmno EQ @lt_pnwtyh-clmno AND
            status NE 'U'.

    LOOP AT lt_pnwtyh INTO DATA(ls_pnwtyh).

      READ TABLE lt_hng_table INTO DATA(ls_hng_table) WITH KEY clmno = ls_pnwtyh-clmno.
      IF sy-subrc EQ 0.

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



          CALL FUNCTION 'BAPI_WARRANTYCLAIM_SET_ACTION'
            EXPORTING
              claim                 = ls_pnwtyh-clmno
              action                = gc_postclm
            IMPORTING
              ev_not_exist          = lv_clm_not_exit
              ev_action_not_allowed = lv_clm_not_allow
            TABLES
              return                = it_return
              rule_result           = it_smesg.

          LOOP AT it_return INTO ls_return WHERE type EQ lc_error OR
                                                 type EQ lc_abort.
            lv_error = 'X'.
            EXIT.
          ENDLOOP.

          IF lv_error EQ 'X'.

          ELSE.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ENDIF.
          MODIFY zwty_hng_table FROM ls_hng_table.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.

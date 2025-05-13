*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF06 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_STATUS_1100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_status_1100 .

*  DATA: lv_fcode LIKE sy-ucomm,
*        lt_fcode TYPE TABLE OF sy-ucomm.
*  CLEAR: gv_last_sy_ucomm.

* on the overview tabstrip the search button should not be available
*  IF gv_subscreen_dynpro = '1100'.
*    lv_fcode = gc_execute_fc.
*    APPEND lv_fcode TO lt_fcode.
*  ENDIF.
ENDFORM.                    " F_STATUS_1100
*&---------------------------------------------------------------------*
*&      Form  m_error_show
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM m_error_show .
  TYPES: BEGIN OF is_bapiretsort,
             index TYPE i,
             bapiretsort TYPE bapiret2,
           END OF is_bapiretsort.


  DATA:
  lv_index              TYPE i,
  ls_bapiretsort        TYPE is_bapiretsort,
  ls_bapireturn         LIKE LINE OF gt_bapireturn,
  lt_bapiretsort        TYPE STANDARD TABLE OF is_bapiretsort.

  IF gt_bapireturn IS NOT INITIAL.

    LOOP AT gt_bapireturn INTO ls_bapiretsort-bapiretsort.
      ls_bapiretsort-index = lv_index.
      APPEND ls_bapiretsort TO lt_bapiretsort.
      lv_index = lv_index + 1.
    ENDLOOP.

    SORT lt_bapiretsort BY bapiretsort-type bapiretsort-id
    bapiretsort-number bapiretsort-message_v1 bapiretsort-message_v2
    bapiretsort-message_v3 bapiretsort-message_v4.

    DELETE ADJACENT DUPLICATES FROM lt_bapiretsort COMPARING
    bapiretsort-type bapiretsort-id bapiretsort-number
    bapiretsort-message_v1 bapiretsort-message_v2
    bapiretsort-message_v3 bapiretsort-message_v4.

    SORT lt_bapiretsort BY index.

    REFRESH gt_bapireturn.

    LOOP AT lt_bapiretsort INTO ls_bapiretsort.
      APPEND ls_bapiretsort-bapiretsort TO gt_bapireturn.
    ENDLOOP.

*    CALL FUNCTION '/DBE/CO_APLG_MSG_DISP_POPUP'
*      EXPORTING
*        it_error_tab2 = gt_bapireturn.
    READ TABLE gt_bapireturn INTO ls_bapireturn WITH KEY type = 'E'.
    IF sy-subrc = 0 .

      IF ls_bapireturn-id <> '/DBE/COMMON'.
        MESSAGE ID ls_bapireturn-id
                        TYPE 'I' "ls_bapireturn-type
                        NUMBER ls_bapireturn-number
                        WITH ls_bapireturn-message_v1 DISPLAY LIKE 'E'.
      ELSE.
        MESSAGE ID ls_bapireturn-id
                  TYPE 'W'
                  NUMBER ls_bapireturn-number
                  WITH ls_bapireturn-message_v1 DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
    CLEAR gt_bapireturn.

  ENDIF.

  CLEAR gv_block_navigation.
ENDFORM.                    " m_error_show
*&---------------------------------------------------------------------*
*&      Module  M_ERRORS_SHOW  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_errors_show OUTPUT.
  PERFORM m_error_show.
ENDMODULE.                 " M_ERRORS_SHOW  OUTPUT

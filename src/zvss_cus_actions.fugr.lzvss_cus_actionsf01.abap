*----------------------------------------------------------------------*
***INCLUDE LZVSS_CUS_ACTIONSF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  co_fill_settle_value
*&---------------------------------------------------------------------*
FORM co_fill_settle_value TABLES  it_settle      TYPE /dbe/co_settle_tt
                                  it_settle_work TYPE tt_settle_work
                          USING   is_splhdr      TYPE /dbe/splhdr_com
                                  is_vbak        TYPE /dbe/vbak_com.

*-> local declaration
  DATA: lv_field       TYPE /dbe/co_settle-merkmal.

  DATA: ls_settle      TYPE /dbe/co_settle,
        ls_com         TYPE /dbe/co_io_com,
        ls_settle_work TYPE t_settle_work.

  FIELD-SYMBOLS <f_value> TYPE any.

************************************************************************


*-> mapping
  MOVE-CORRESPONDING is_vbak   TO ls_com.
  MOVE-CORRESPONDING is_splhdr TO ls_com.


  LOOP AT it_settle INTO ls_settle.
    MOVE-CORRESPONDING ls_settle TO ls_settle_work.

    IF ls_settle-value IS INITIAL.
      UNASSIGN <f_value>.
      lv_field = ls_settle-field.
      ASSIGN COMPONENT lv_field OF STRUCTURE ls_com TO <f_value>.

      CHECK <f_value> IS ASSIGNED.
      IF NOT <f_value> IS INITIAL.
        ls_settle_work-value = <f_value>.
      ENDIF.
    ENDIF.

    APPEND ls_settle_work TO it_settle_work.
  ENDLOOP.

ENDFORM.                    " CO_FILL_SETTLE_VALUE

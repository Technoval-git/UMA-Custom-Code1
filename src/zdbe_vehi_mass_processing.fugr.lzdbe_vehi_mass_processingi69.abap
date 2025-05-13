*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI69.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_CHECK_DATE_FIELDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_date_fields INPUT.
  PERFORM check_date_fields.
ENDMODULE.                 " M_CHECK_DATE_FIELDS  INPUT

*&---------------------------------------------------------------------*
*&      Form  check_date_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_date_fields.
  DATA:
          lv_dummy_var      TYPE char1,
          lv_date1          TYPE char10,
          lv_date2          TYPE char10,
          lv_time1          TYPE char8,
          lv_time2          TYPE char8.

  IF sy-ucomm EQ gc_enter_fcode OR sy-ucomm = gc_exe_action_fcode.
    IF  /DBE/vbak_com-visit_start_date IS INITIAL AND /DBE/vbak_com-visit_start_time IS NOT INITIAL.
      IF /DBE/vbak_com-visit_start_time NE ''.
        SET CURSOR FIELD '/DBE/VBAK_COM-VISIT_START_DATE'.
        CLEAR gv_ok_code.
        MESSAGE e010(/DBE/scheduling).
      ENDIF.
    ELSEIF  /DBE/vbak_com-visit_end_date IS INITIAL AND /DBE/vbak_com-visit_end_time IS NOT INITIAL.
      IF /DBE/vbak_com-visit_end_time NE ''.
        SET CURSOR FIELD '/DBE/VBAK_COM-VISIT_END_DATE'.
        CLEAR gv_ok_code.
        MESSAGE e012(/DBE/scheduling) .
      ENDIF.
    ELSEIF /DBE/vbak_com-visit_start_date IS NOT INITIAL AND /DBE/vbak_com-visit_start_date IS NOT INITIAL.
      IF /DBE/vbak_com-visit_start_date > /DBE/vbak_com-visit_end_date.
        SET CURSOR FIELD '/DBE/VBAK_COM-VISIT_START_DATE'.
        CLEAR gv_ok_code.
        WRITE /DBE/vbak_com-visit_start_date TO lv_date1.
        WRITE /DBE/vbak_com-visit_end_date TO lv_date2.
        MESSAGE e014(/DBE/scheduling) WITH lv_date1 lv_date2 .
      ELSEIF /DBE/vbak_com-visit_start_date = /DBE/vbak_com-visit_end_date.
        IF /DBE/vbak_com-visit_start_time > /DBE/vbak_com-visit_end_time.
          SET CURSOR FIELD '/DBE/VBAK_COM-VISIT_START_TIME'.
          CLEAR gv_ok_code.
          WRITE /DBE/vbak_com-visit_start_time TO lv_time1.
          WRITE /DBE/vbak_com-visit_end_time TO lv_time2.
          MESSAGE e015(/DBE/scheduling) WITH lv_time1 lv_time2 .
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "check_date_fields

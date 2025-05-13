*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO54.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_GET_OS_PARAMETERS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_get_veh_parameters OUTPUT.

  PERFORM f_get_veh_parameters.

ENDMODULE.                 " M_GET_OS_PARAMETERS  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_GET_OS_PARAMETERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_veh_parameters .

  DATA:
       lt_parameters_ext   TYPE ustyp_t_parameters WITH HEADER LINE,
       lv_uname            LIKE sy-uname.

  FIELD-SYMBOLS:
    <parameters>        LIKE LINE OF lt_parameters_ext.

* read actual user parameters
  lv_uname = sy-uname.
  CALL FUNCTION 'SUSR_USER_PARAMETERS_GET'
    EXPORTING
      user_name       = lv_uname
    TABLES
      user_parameters = lt_parameters_ext
    EXCEPTIONS
      OTHERS          = 1.
  IF sy-subrc <> 0.
    MESSAGE i124(01) WITH lv_uname.
    EXIT.
  ENDIF.

* fill screen fields with user parameter values
  LOOP AT lt_parameters_ext ASSIGNING <parameters>.
    CASE <parameters>-parid.
      WHEN gc_maxsel.
        gv_maxsel = <parameters>-parva.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " F_GET_OS_PARAMETERS

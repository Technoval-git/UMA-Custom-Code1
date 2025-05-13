*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI72.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
  CASE ok_code.
    WHEN gc_back_fc OR gc_canc_fc OR gc_exit_fc OR gc_okay_fc.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN 'SAVE' OR gc_ente_fc.        "N:2299402
      PERFORM f_save_user_parameter.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SAVE_USER_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_user_parameter .
  DATA:
        lt_parameters_ext   TYPE ustyp_t_parameters WITH HEADER LINE,
        lt_parameters       TYPE ustyp_t_parameters WITH HEADER LINE,
        ls_parameters       LIKE LINE OF lt_parameters,
        lv_uname            LIKE sy-uname.

  FIELD-SYMBOLS:
      <param>             LIKE LINE OF lt_parameters.

* read actual parameters
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

** update internal parameter table
  ls_parameters-parid = gc_maxsel.
  ls_parameters-parva = gv_maxsel.
  ls_parameters-partext = ''.
  APPEND ls_parameters TO lt_parameters.

* update external parameter table
  LOOP AT lt_parameters ASSIGNING <param>.
    READ TABLE lt_parameters_ext WITH KEY parid = <param>-parid.
    IF sy-subrc = 0.
      IF lt_parameters_ext-parva <> <param>-parva.
        MODIFY lt_parameters_ext INDEX sy-tabix
          FROM <param> TRANSPORTING parva.
      ENDIF.
    ELSE.
      APPEND <param> TO lt_parameters_ext.
    ENDIF.
  ENDLOOP.

* save new parameters
  CALL FUNCTION 'SUSR_USER_PARAMETERS_PUT'
    EXPORTING
      user_name       = lv_uname
    TABLES
      user_parameters = lt_parameters_ext
    EXCEPTIONS
      OTHERS          = 1.
  IF sy-subrc <> 0.
    MESSAGE i124(01) WITH lv_uname.
    EXIT.
  ELSE.
    CALL FUNCTION 'SUSR_USER_BUFFERS_TO_DB'
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SAVE_USER_PARAMETER

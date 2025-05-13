*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI12 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_MODEL_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_model_f4 INPUT.


  DATA ls_dynpread TYPE dynpread.
  DATA lt_dynpread TYPE TABLE OF dynpread.

  ok_code = gc_f4_fc.
  PERFORM f_model_f4.

  IF gv_ok_code NE 'ACT_EXE' AND gv_ok_code NE 'OPCLASS'
  AND gv_ok_code NE gc_expand_fcode
  AND gv_ok_code NE gc_collapse_fcode.

    IF /DBE/V_IMODEL IS NOT INITIAL.
      CLEAR:
        gt_optionalv,
        gt_optionalv_all.
      CALL METHOD go_alv_opt_grid->refresh_table_display( ).
    ENDIF.
  ENDIF.
  IF /DBE/V_IMODEL IS NOT INITIAL.
    PERFORM f_get_modtext.

    ls_dynpread-fieldname = '/DBE/V_MODELT-MOTEXT1'.
    ls_dynpread-fieldvalue = /DBE/v_modelt-motext1.
    APPEND ls_dynpread TO lt_dynpread.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname               = gc_mass_main_program
        dynumb               = sy-dynnr
      TABLES
        dynpfields           = lt_dynpread
      EXCEPTIONS
        invalid_abapworkarea = 1
        invalid_dynprofield  = 2
        invalid_dynproname   = 3
        invalid_dynpronummer = 4
        invalid_request      = 5
        no_fielddescription  = 6
        undefind_error       = 7.
    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.


ENDMODULE.                 " M_MODEL_F4  INPUT

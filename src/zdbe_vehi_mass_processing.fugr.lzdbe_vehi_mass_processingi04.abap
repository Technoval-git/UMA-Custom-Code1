*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_MODEL_CHK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_model_chk .
  DATA lv_modguid TYPE /DBE/MODEL_GUID.
  lv_modguid = /DBE/V_IMODEL-modguid.
  PERFORM f_model_f4.

  IF gv_ok_code NE gc_exec_fc AND gv_ok_code NE gc_opclass
    AND gv_ok_code NE gc_createveh_fc
    AND gv_ok_code NE gc_expand_fcode
    AND gv_ok_code NE gc_collapse_fcode
    AND gv_ok_code NE space
    OR lv_modguid NE /DBE/V_IMODEL-modguid AND gv_ok_code EQ gc_exec_fc.
    "Populate DBM Option OpClass dropdown
    PERFORM f_option_dropdown.
    "Populate DBM model option alv
    PERFORM f_populate_optionalv.

  ENDIF.


ENDMODULE.                 " M_MODEL_CHK  INPUT

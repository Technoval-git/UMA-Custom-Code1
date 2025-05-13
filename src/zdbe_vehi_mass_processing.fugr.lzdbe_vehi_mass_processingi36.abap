*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI36 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_CHECK_ENTRY_BSART  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_entry_bsart INPUT.
  PERFORM f_check_entry_bsart.
ENDMODULE.                 " M_CHECK_ENTRY_BSART  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_CHECK_ENTRY_KOSTL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_entry_kostl INPUT.

  DATA lv_pricing_type TYPE /dbe/veh_pricingtype.
  CLEAR lv_pricing_type.

  CALL FUNCTION '/DBE/VM08_FIND_PRICING_TYPE'  "NOTE: 2093139
    EXPORTING
      is_vlcactdata_head   = vlcactdata_head_s
    IMPORTING
      ev_pricingtype       = lv_pricing_type
    EXCEPTIONS
      determination_failed = 1
      OTHERS               = 2.

  IF lv_pricing_type EQ gv_pricing_used.
    PERFORM f_check_entry_kostl.
  ENDIF.

ENDMODULE.                 " M_CHECK_ENTRY_KOSTL  INPUT

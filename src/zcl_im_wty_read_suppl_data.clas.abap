class ZCL_IM_WTY_READ_SUPPL_DATA definition
  public
  final
  create public .

public section.

  interfaces IF_EX_WTY_READ_SUPPL_DATA .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_WTY_READ_SUPPL_DATA IMPLEMENTATION.


  method IF_EX_WTY_READ_SUPPL_DATA~EXTERNAL_BUFFER_REFRESH.
  endmethod.


  METHOD if_ex_wty_read_suppl_data~external_buffer_save.

  ENDMETHOD.


  method IF_EX_WTY_READ_SUPPL_DATA~MEASUREMENT_POINT_DETERMINE.
  endmethod.


  method IF_EX_WTY_READ_SUPPL_DATA~REGISTER_IN_BUFFER.
  endmethod.


  METHOD if_ex_wty_read_suppl_data~wty_read_suppl_data.
    CALL FUNCTION '/DBE/S_WTY_UE_R_SUPP_DAT_READ'
      IMPORTING
        et_counter    = et_counter
      CHANGING
        ct_pnwtyh_dia = ct_pnwtyh_dia
        ct_pnwtyv_dia = ct_pnwtyv_dia
        ct_pvwty_dia  = ct_pvwty_dia.
  ENDMETHOD.
ENDCLASS.

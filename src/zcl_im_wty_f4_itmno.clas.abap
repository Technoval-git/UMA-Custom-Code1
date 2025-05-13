class ZCL_IM_WTY_F4_ITMNO definition
  public
  final
  create public .

public section.

  interfaces IF_EX_WTY_F4_ITMNO .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_WTY_F4_ITMNO IMPLEMENTATION.


  METHOD if_ex_wty_f4_itmno~change_itmno.
    CALL FUNCTION '/DBE/S_WTY_UE_F4_ITMNO_CHANGE'
      EXPORTING
        iv_poskt         = iv_poskt
        iv_defct         = iv_defct
        is_pnwtyv_dynpro = is_pnwtyv_dynpro
        is_pnwtyh_dynpro = is_pnwtyh_dynpro
        is_pvwty_dynpro  = is_pvwty_dynpro
      IMPORTING
        ev_itmtx         = ev_itmtx
        ev_quant         = ev_quant
        ev_meinh         = ev_meinh
      CHANGING
        cv_matnr         = cv_matnr
        cv_itmno         = cv_itmno.
  ENDMETHOD.
ENDCLASS.

class ZCL_VSS_CREDIT_EXCLU definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_EX_BADI_FSCM .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VSS_CREDIT_EXCLU IMPLEMENTATION.


  METHOD /dbe/if_ex_badi_fscm~change_dcd_case.
    DATA : lv_credit TYPE c.
    EXPORT lv_credit = 'X' TO MEMORY ID 'ZCREDIT'.
  ENDMETHOD.
ENDCLASS.

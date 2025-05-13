class ZCL_VSS_MASS_RESULTALV definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_EX_VMASS_SEARCH .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VSS_MASS_RESULTALV IMPLEMENTATION.


  METHOD /dbe/if_ex_vmass_search~change_result_data.
  ENDMETHOD.


  METHOD /dbe/if_ex_vmass_search~vehicle_overview_req_data.
  ENDMETHOD.
ENDCLASS.

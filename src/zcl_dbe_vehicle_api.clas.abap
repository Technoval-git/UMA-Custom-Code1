class ZCL_DBE_VEHICLE_API definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_EX_VEHICLE_API .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DBE_VEHICLE_API IMPLEMENTATION.


  method /DBE/IF_EX_VEHICLE_API~AFTER_VEHICLE_GET.
  endmethod.


  method /DBE/IF_EX_VEHICLE_API~AFTER_VEHICLE_GET_LIST.
  endmethod.


  METHOD /dbe/if_ex_vehicle_api~before_vehicle_save.

  ENDMETHOD.


  method /DBE/IF_EX_VEHICLE_API~BEFORE_VEHICLE_SET.
  endmethod.
ENDCLASS.

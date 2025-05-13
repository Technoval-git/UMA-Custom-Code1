class ZCL_IM__PHYS_INV_PRINT definition
  public
  final
  create public .

public section.

  interfaces IF_EX_EXEC_METHODCALL_PPF .

  methods CONSTRUCTOR .
  methods GET_APPL_DATA .
protected section.
private section.

  data MO_IF_PI_CUST type ref to /LIME/IF_PI_CUST .
  data MV_LGNUM type /SCWM/LGNUM .
  data MO_STOCK_MAPPING type ref to /SCWM/CL_UI_STOCK_FIELDS .
  data MO_SCWM_CUST type ref to /SCWM/IF_PI_CUST .

  methods ADD_LOG_TO_UI_PROTOCOL .
  methods CONVERT_APPL_DATA .
ENDCLASS.



CLASS ZCL_IM__PHYS_INV_PRINT IMPLEMENTATION.


  method ADD_LOG_TO_UI_PROTOCOL.
  endmethod.


  method CONSTRUCTOR.
  endmethod.


  method CONVERT_APPL_DATA.
  endmethod.


  method GET_APPL_DATA.
  endmethod.


  method IF_EX_EXEC_METHODCALL_PPF~EXECUTE.
  endmethod.
ENDCLASS.

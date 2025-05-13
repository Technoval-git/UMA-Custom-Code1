interface ZIF_EXEC_METHODCALL_PPF
  public .


  methods EXECUTE
    importing
      value(FLT_VAL) type PPFDFLTVAL
      !IO_APPL_OBJECT type ref to OBJECT
      !IO_PARTNER type ref to CL_PARTNER_PPF
      !IP_APPLICATION_LOG type BALLOGHNDL
      !IP_PREVIEW type CHAR1
      !II_CONTAINER type ref to IF_SWJ_PPF_CONTAINER
      !IP_ACTION type PPFDTT optional
    returning
      value(RP_STATUS) type PPFDTSTAT .
endinterface.

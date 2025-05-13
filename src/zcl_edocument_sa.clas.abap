class ZCL_EDOCUMENT_SA definition
  public
  inheriting from CL_EDOCUMENT_SA
  final
  create public

  global friends CL_EDOC_PROCESS .

public section.

  methods CONSTRUCTOR
    importing
      !IO_SOURCE_DATA type ref to CL_EDOC_SOURCE optional
      !IV_EDOC_GUID type EDOC_GUID optional
      !IV_LAND type LAND optional
      !IV_GENERIC_BADI_FILTER_ADAPTOR type EDOC_GENERIC_BADI_FILTER optional
      !IV_UPDATE_TASK type SAP_BOOL optional .
protected section.
private section.
ENDCLASS.



CLASS ZCL_EDOCUMENT_SA IMPLEMENTATION.


  METHOD constructor.



* Call Constructor of the superclass
    super->constructor( io_source_data   = io_source_data
                        iv_edoc_guid     = iv_edoc_guid
                        iv_land          = iv_land
                        iv_generic_badi_filter_adaptor = iv_generic_badi_filter_adaptor
                        iv_update_task   = iv_update_task ).

    me->ms_edocument-edocument_class = 'ZCL_EDOCUMENT_SA'.
  ENDMETHOD.
ENDCLASS.

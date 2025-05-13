class ZCL_VSS_DB_ACCESS definition
  public
  final
  create public .

public section.

  class-data MV_DUMMY type STRING .

  class-methods GET_MODEL_GUID_FOR_MOD_SAL_COD
    importing
      !IV_MODEL_SALES_CODE type /DBE/MODCODE_SALE
    returning
      value(RV_MODEL_GUID) type /DBE/MODEL_GUID
    raising
      ZCX_ERROR .
  class-methods GET_OEM_MODEL_MASTER_MAPPING
    importing
      !IV_MODEL_GUID type /DBE/MODEL_GUID
    returning
      value(RT_MAPPING) type ZVSS_MM_OPT_MAP_TT
    raising
      ZCX_ERROR .
  class-methods GET_OEM_MODEL_MASTER_MAP_TEXT
    importing
      !IV_MODEL_GUID type /DBE/MODEL_GUID
    returning
      value(RT_MAPPING_TEXT) type ZVSS_MT_OPT_MAP_TT
    raising
      ZCX_ERROR .
  class-methods GET_VM_OPTIONS
    importing
      !IV_MCATALOG type /DBE/MCATALOG
    returning
      value(RT_OPTIONS) type ZVSS_VM_OPTIONS_TT
    raising
      ZCX_ERROR .
  class-methods GET_VM_OPTIONS_TXT
    importing
      !IV_MCATALOG type /DBE/MCATALOG
    returning
      value(RT_OPTIONS) type ZVSS_VM_OPTIONST_TT
    raising
      ZCX_ERROR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VSS_DB_ACCESS IMPLEMENTATION.


  METHOD get_model_guid_for_mod_sal_cod.

    SELECT SINGLE model_guid FROM /dbe/v_model
      WHERE mcodesd = @iv_model_sales_code INTO @rv_model_guid.
    IF sy-subrc <> 0.
      MESSAGE e010(zmsg_vss01) WITH iv_model_sales_code INTO zcx_error=>mv_dummy.
      zcx_error=>raise_sy_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_oem_model_master_mapping.

    SELECT * FROM zvss_mm_opt_map INTO CORRESPONDING FIELDS OF TABLE rt_mapping
     WHERE model_guid = iv_model_guid.
    IF sy-subrc <> 0.
      MESSAGE e011(zmsg_vss01) WITH 'ZVSS_MM_OPT_MAP' iv_model_guid INTO mv_dummy.
      zcx_error=>raise_sy_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_oem_model_master_map_text.

    SELECT * FROM zvss_mt_opt_map INTO CORRESPONDING FIELDS OF TABLE rt_mapping_text
    WHERE model_guid = iv_model_guid.
    IF sy-subrc <> 0.
      MESSAGE e011(zmsg_vss01) WITH 'ZVSS_MT_OPT_MAP' iv_model_guid INTO mv_dummy.
      zcx_error=>raise_sy_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_vm_options.
    SELECT * FROM /dbe/vm_options INTO CORRESPONDING FIELDS OF TABLE rt_options
  WHERE mcatalog = iv_mcatalog.
    IF sy-subrc <> 0.
      MESSAGE e011(zmsg_vss01) WITH '/DBM/VM_OPTIONS' iv_mcatalog INTO mv_dummy.
      zcx_error=>raise_sy_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_vm_options_txt.
    SELECT * FROM /dbe/vm_optionst INTO CORRESPONDING FIELDS OF TABLE rt_options
WHERE mcatalog = iv_mcatalog.
    IF sy-subrc <> 0.
      MESSAGE e011(zmsg_vss01) WITH '/DBM/VM_OPTIONST' iv_mcatalog INTO mv_dummy.
      zcx_error=>raise_sy_msg( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

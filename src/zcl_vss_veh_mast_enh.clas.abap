class ZCL_VSS_VEH_MAST_ENH definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_EX_VEHICLE_API .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VSS_VEH_MAST_ENH IMPLEMENTATION.


  method /DBE/IF_EX_VEHICLE_API~AFTER_VEHICLE_GET.
  endmethod.


  method /DBE/IF_EX_VEHICLE_API~AFTER_VEHICLE_GET_LIST.
  endmethod.


  method /DBE/IF_EX_VEHICLE_API~BEFORE_VEHICLE_SAVE.
  endmethod.


  METHOD /dbe/if_ex_vehicle_api~before_vehicle_set.

    DATA : ls_model       TYPE /dbe/v_imodel_dynp_sv.

* Single-line extension DBM_V_IMODEL
* Move model data from COM structure to internal structure
    MOVE-CORRESPONDING is_iobj_data_single_com-/dbe/v_imodel
    TO   cs_iobj_data_single-/dbe/v_imodel.
    BREAK vsubbiah.
    IF iv_action EQ 'QCRE'.
      MOVE-CORRESPONDING cs_iobj_data_single-/dbe/v_imodel TO ls_model.
      ls_model-modyear = sy-datum+0(4).
      MOVE-CORRESPONDING ls_model TO cs_iobj_data_single-/dbe/v_imodel.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

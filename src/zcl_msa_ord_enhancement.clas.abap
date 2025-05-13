class ZCL_MSA_ORD_ENHANCEMENT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBME/MD8_IF_E_ORDER .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MSA_ORD_ENHANCEMENT IMPLEMENTATION.


  method /DBME/MD8_IF_E_ORDER~AFTER_ORDER_GET_DETAIL.
  endmethod.


  method /DBME/MD8_IF_E_ORDER~AFTER_ORDER_SAVED_CHANGE.
  endmethod.


  METHOD /dbme/md8_if_e_order~before_order_create.
    SELECT SINGLE * FROM zmsa_ord_area INTO @DATA(lv_msa_ord_area) WHERE werks EQ @iv_werks.
    IF sy-subrc EQ 0.
      cs_vbak-vkorg = lv_msa_ord_area-vkorg.
      cs_vbak-vtweg = lv_msa_ord_area-vtweg.
    ENDIF.
  ENDMETHOD.


  method /DBME/MD8_IF_E_ORDER~BEFORE_ORDER_SAVED_CHANGE.
  endmethod.


  method /DBME/MD8_IF_E_ORDER~FILL_JOB.
  endmethod.
ENDCLASS.

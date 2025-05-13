class ZCL_VSS_VEHI_SALES definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_EX_VEHICLE_SALES .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VSS_VEHI_SALES IMPLEMENTATION.


  METHOD /dbe/if_ex_vehicle_sales~after_positions_create.
    FIELD-SYMBOLS:
    <ls_item_detail>   LIKE LINE OF ct_item_detail.
    DATA : lv_object TYPE /dbe/exts_ouid.

    READ TABLE ct_item_detail ASSIGNING  <ls_item_detail> WITH KEY charg = cs_vlcdiavehi-charg.
    IF sy-subrc = 0.
      SELECT SINGLE vhvin /dbe/iobjguid FROM vlcvehicle INTO (<ls_item_detail>-vhvin, lv_object)  WHERE vguid EQ <ls_item_detail>-vguid.
      IF sy-subrc EQ 0.
        SELECT SINGLE mcodesd modyear FROM /dbe/v_imodel INTO ( <ls_item_detail>-mcodesd, <ls_item_detail>-modyear ) WHERE product_guid EQ lv_object.
        <ls_item_detail>-zmcodesd = <ls_item_detail>-mcodesd.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD /dbe/if_ex_vehicle_sales~before_ord_new.
  ENDMETHOD.


  METHOD /dbe/if_ex_vehicle_sales~before_positions_create.

  ENDMETHOD.


  method /DBE/IF_EX_VEHICLE_SALES~BEFORE_RETURN.
  endmethod.
ENDCLASS.

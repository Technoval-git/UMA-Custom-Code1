class ZCL_ORD_AP_BILLING_CREATE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_OE_ACTION_PRE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ORD_AP_BILLING_CREATE IMPLEMENTATION.


  METHOD /dbe/if_oe_action_pre~prepare.

    DATA: lo_order    TYPE REF TO /dbe/cl_order,
          ls_vbap_com TYPE /dbe/vbap_com,
          lv_dummy    TYPE c.

************************************************************************
* 010 mapping...
    lo_order ?= io_ord_object.
************************************************************************

    LOOP AT lo_order->mt_vbap_com INTO ls_vbap_com WHERE itcanc EQ ' ' AND
                                                         itcat EQ 'P003'.
      SELECT SINGLE * FROM vlcvehicle INTO @DATA(ls_vlcvehicle) WHERE vguid EQ @ls_vbap_com-vguid.
      IF sy-subrc EQ 0 AND
        ls_vbap_com-werks NE ls_vlcvehicle-werks AND
        ls_vbap_com-lgort NE ls_vlcvehicle-lgort.
        MESSAGE w024(zmsg_vss01) WITH ls_vlcvehicle-vhvin ls_vbap_com-werks INTO lv_dummy.
        lo_order->bal_add_symessage( ).
        RAISE EXCEPTION TYPE /dbe/cx_oe_action_denied.
      ELSE.

      ENDIF.
    ENDLOOP.

    IF lo_order->ms_header_detail-engcode EQ 'CS'.

    ENDIF.

  ENDMETHOD.
ENDCLASS.

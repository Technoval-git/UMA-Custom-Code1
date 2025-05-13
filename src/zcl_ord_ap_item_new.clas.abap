class ZCL_ORD_AP_ITEM_NEW definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_OE_ACTION_PRE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ORD_AP_ITEM_NEW IMPLEMENTATION.


  METHOD /dbe/if_oe_action_pre~prepare.
    DATA:
      lo_order              TYPE REF TO /dbe/cl_order,
      ls_item_detail        LIKE LINE OF lo_order->mt_item_detail,
      lt_item_detail        LIKE lo_order->mt_item_detail,
      lt_item_detail_buffer LIKE lo_order->mt_item_detail.
    DATA: ls_sub_item_detail TYPE /dbe/s_pos.
    DATA : lv_object     TYPE /dbe/exts_ouid,
           ls_vbap_com   LIKE LINE OF lo_order->mt_vbap_com,
           ls_vbap_com_1 LIKE LINE OF lo_order->mt_vbap_com.

    FIELD-SYMBOLS:
      <item_detail>      LIKE LINE OF lt_item_detail,
      <main_item_detail> LIKE LINE OF lt_item_detail,
      <vbap_com>         LIKE LINE OF lo_order->mt_vbap_com.
* --> get instance
    lo_order ?= io_ord_object.

    REFRESH lt_item_detail.

    LOOP AT lo_order->mt_vbap_com INTO ls_vbap_com  WHERE itcat EQ 'P003' AND itcanc EQ '' AND slctd EQ 'X'.
      MOVE-CORRESPONDING ls_vbap_com TO ls_item_detail.
      SELECT SINGLE vhvin /dbe/iobjguid  FROM vlcvehicle INTO (ls_item_detail-vhvin, lv_object)  WHERE vguid EQ ls_item_detail-vguid.
      IF sy-subrc EQ 0.
        SELECT SINGLE mcodesd modyear FROM /dbe/v_imodel INTO (ls_item_detail-mcodesd, ls_item_detail-modyear) WHERE product_guid EQ lv_object.
        APPEND ls_item_detail TO lt_item_detail.
        CLEAR ls_item_detail.
      ENDIF.
    ENDLOOP.

    LOOP AT lo_order->mt_vbap_com INTO ls_vbap_com WHERE main_item IS NOT INITIAL.
      MOVE-CORRESPONDING ls_vbap_com TO ls_item_detail.
      READ TABLE lo_order->mt_vbap_com INTO ls_vbap_com_1 WITH KEY posnr = ls_vbap_com-main_item itcanc = ''  slctd = 'X'.
      IF sy-subrc EQ 0.
        ls_item_detail-mcodesd = ls_vbap_com_1-mcodesd.
        ls_item_detail-zmcodesd = ls_vbap_com_1-mcodesd.
        APPEND ls_item_detail TO lt_item_detail.
        CLEAR ls_item_detail.
      ENDIF.
    ENDLOOP.
    IF lt_item_detail IS NOT INITIAL.
      lo_order->mt_item_detail = lt_item_detail.
      lo_order->item_change( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

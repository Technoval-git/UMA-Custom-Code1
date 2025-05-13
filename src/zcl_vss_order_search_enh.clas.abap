class ZCL_VSS_ORDER_SEARCH_ENH definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_EX_ORDER_UI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VSS_ORDER_SEARCH_ENH IMPLEMENTATION.


  method /DBE/IF_EX_ORDER_UI~EXIT_COMMAND_2000.
  endmethod.


  METHOD /dbe/if_ex_order_ui~item_search.
    DATA : lv_object TYPE /dbe/exts_ouid,
           lv_vguid  TYPE  vlc_guid.
    IF  cs_item_detail-itcat EQ 'P002' OR cs_item_detail-itcat EQ 'D020' OR
       cs_item_detail-itcat EQ 'P010'  OR cs_item_detail-itcat EQ 'Z004' OR
       cs_item_detail-itcat EQ 'P011'.
      cs_item_detail-spart = ''.
      cs_item_detail-mfrnr = ''.
    ENDIF.
    IF cs_item_detail-itcat EQ 'P090'.
      cs_item_detail-spart = ''.
      cs_item_detail-mfrnr = ''.
      cs_item_detail-mtart = ''.
    ENDIF.

    IF cs_item_detail-itcat EQ 'P003'.
      SELECT SINGLE vguid vhvin FROM vlcvehicle INTO (lv_vguid, cs_item_detail-vhvin) WHERE vhcle EQ cs_item_detail-vhcle.
      IF sy-subrc EQ 0.
        SELECT SINGLE /dbe/iobjguid FROM vlcvehicle INTO lv_object  WHERE vguid EQ lv_vguid.
        IF sy-subrc EQ 0.
          SELECT SINGLE mcodesd modyear FROM /dbe/v_imodel INTO (cs_item_detail-mcodesd, cs_item_detail-modyear) WHERE product_guid EQ lv_object.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  method /DBE/IF_EX_ORDER_UI~USER_COMMAND_1000.
  endmethod.


  method /DBE/IF_EX_ORDER_UI~USER_COMMAND_1101.
  endmethod.


  METHOD /dbe/if_ex_order_ui~user_command_2000.
    DATA : ls_item_detail        LIKE LINE OF io_order->mt_item_detail,
           lt_item_detail        LIKE io_order->mt_item_detail,
           lt_item_detail_buffer LIKE io_order->mt_item_detail.

    DATA: ls_sub_item_detail TYPE /dbe/s_pos,
          lv_object          TYPE /dbe/exts_ouid,
          ls_vbap_com        LIKE LINE OF io_order->mt_vbap_com,
          ls_vbap_com_1      LIKE LINE OF io_order->mt_vbap_com.

    FIELD-SYMBOLS: <item_detail> LIKE LINE OF lt_item_detail.

    REFRESH lt_item_detail.

    LOOP AT io_order->mt_item_detail ASSIGNING <item_detail> WHERE main_item IS NOT INITIAL.
      READ TABLE io_order->mt_vbap_com INTO ls_vbap_com_1 WITH KEY posnr = <item_detail>-main_item.
      IF sy-subrc EQ 0.
        <item_detail>-zmcodesd = ls_vbap_com_1-mcodesd.
      ENDIF.
    ENDLOOP.



  ENDMETHOD.
ENDCLASS.

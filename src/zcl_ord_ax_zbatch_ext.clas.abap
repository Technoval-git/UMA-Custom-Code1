class ZCL_ORD_AX_ZBATCH_EXT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_OE_ACTION_EXE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ORD_AX_ZBATCH_EXT IMPLEMENTATION.


  METHOD /dbe/if_oe_action_exe~execution.
    DATA : lo_order     TYPE REF TO /dbe/cl_order.
    DATA: lt_vbap_com TYPE /dbe/vbap_com_tt,
          ls_vbap_com TYPE /dbe/vbap_com.

    DATA: headdata   TYPE bapimathead,
          bapi_mbew1 TYPE bapi_mbew,
          bapi_mbewx TYPE bapi_mbewx,
          return     TYPE bapiret2.

    DATA : lt_rettab TYPE  STANDARD TABLE OF bapiret2.

    DATA : lv_object     TYPE bapi1003_key-object,
           lt_object     TYPE STANDARD TABLE OF bapi1003_object_keys,
           lw_object     TYPE bapi1003_object_keys,
           lv_matnr18    TYPE matnr18,
           lw_batch_attr TYPE bapibatchatt.

    lo_order ?= io_ord_object.

    lt_vbap_com = lo_order->mt_vbap_com.

    LOOP AT lt_vbap_com INTO ls_vbap_com WHERE itcat EQ 'P003'.
      SELECT SINGLE * FROM mcha INTO @DATA(ls_mcha) WHERE matnr EQ @ls_vbap_com-matnr18 AND werks EQ @ls_vbap_com-werks AND charg EQ @ls_vbap_com-charg.
      IF sy-subrc NE 0.
        SELECT SINGLE * FROM mbew INTO @DATA(ls_mbew) WHERE matnr EQ @ls_vbap_com-matnr18 AND bwtar EQ @ls_vbap_com-charg.

        headdata-material = ls_vbap_com-matnr18.
        headdata-account_view = 'X'.
        bapi_mbew1-val_area = ls_vbap_com-werks.
        bapi_mbew1-val_type = ls_vbap_com-charg.
        bapi_mbewx-val_area = ls_vbap_com-werks.
        bapi_mbewx-val_type = ls_vbap_com-charg.

        bapi_mbew1-val_class = ls_mbew-bklas.
        bapi_mbewx-val_class = ls_mbew-bklas.
        bapi_mbew1-price_ctrl = ls_mbew-vprsv.
        bapi_mbewx-price_ctrl = 'X'.

        CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
          EXPORTING
            headdata       = headdata
            valuationdata  = bapi_mbew1
            valuationdatax = bapi_mbewx
          IMPORTING
            return         = return.

        lv_matnr18 = ls_vbap_com-matnr18.

        lw_batch_attr-val_type = ls_vbap_com-charg.

        CALL FUNCTION 'BAPI_BATCH_CREATE'
          EXPORTING
            material             = lv_matnr18
            batch                = ls_vbap_com-charg
            plant                = ls_vbap_com-werks
            batchstoragelocation = ls_vbap_com-lgort
            batchattributes      = lw_batch_attr
          TABLES
            return               = lt_rettab.


* Fetch Object key by passing Material, Plant and Batch
* Fill Material Number
        lw_object-key_field = 'MATNR'.
        lw_object-value_int = ls_vbap_com-matnr18.
        APPEND lw_object TO lt_object.
        CLEAR : lw_object.

* Fill Plant
        lw_object-key_field = 'WERKS'.
        lw_object-value_int = ls_vbap_com-werks.
        APPEND lw_object TO lt_object.
        CLEAR : lw_object.

* Fill Batch
        lw_object-key_field = 'CHARG'.
        lw_object-value_int = ls_vbap_com-charg.
        APPEND lw_object TO lt_object.
        CLEAR : lw_object.

* Concatenate Object Key
        CALL FUNCTION 'BAPI_OBJCL_CONCATENATEKEY'
          EXPORTING
            objecttable    = 'MCH1'
          IMPORTING
            objectkey_conc = lv_object
          TABLES
            objectkeytable = lt_object
            return         = lt_rettab.


      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

*----------------------------------------------------------------------*
***INCLUDE LZDBE_VEHI_MASS_PROCESSINGI03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_TRANSFER_DATA_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_transfer_data_9002 INPUT.
  PERFORM f_transfer_data_9002.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      FORM f_transfer_data_9002                             N:2426282
*&---------------------------------------------------------------------*
FORM f_transfer_data_9002.
  DATA: lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
        lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
        lt_bob             TYPE /dbe/t_veh_bob,
        ls_bob             TYPE /dbe/s_veh_bob,
        lr_data            TYPE REF TO data,
        lr_item_data       TYPE REF TO data,
        ls_ac_post         TYPE /dbe/vmass_adc,
        lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
        lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
        ls_invoice_info    TYPE tty_invoice_info.

* Header data
  MOVE-CORRESPONDING vlcactdata_head_s TO gs_vlcactdata_head.
* Item data
  MOVE-CORRESPONDING vlcactdata_item_s TO gs_vlcactdata_item.

* Get Buffer instance
  lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
  TRY.
      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob.
  ENDTRY.

  LOOP AT lt_bob INTO ls_bob .
    lo_vehicle ?= ls_bob-bobref.
    TRY.
        lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_data IS BOUND.
      lr_vlcactdata_head ?= lr_data.

      lr_vlcactdata_head->werks = vlcactdata_head_s-werks.
      lr_vlcactdata_head->lgort = vlcactdata_head_s-lgort.

      lr_vlcactdata_head->umwerks = vlcactdata_head_s-umwerks.
      lr_vlcactdata_head->umlgo = vlcactdata_head_s-umlgo.

      lr_vlcactdata_head->bldat = vlcactdata_head_s-bldat.
      lr_vlcactdata_head->bldat = vlcactdata_head_s-budat.

      lr_vlcactdata_head->lbeln = vlcactdata_head_s-lbeln.
    ENDIF.
  ENDLOOP.

* Set data in Vehicle buffer
  TRY.
      CALL METHOD lo_veh_buf->set_all.
    CATCH /dbe/cx_veh_error_occured .
    CATCH cx_static_check.
  ENDTRY.

ENDFORM.

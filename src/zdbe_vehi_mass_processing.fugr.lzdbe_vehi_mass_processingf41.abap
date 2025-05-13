*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF41 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ACTION_EXECUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM action_execute .

  DATA : lo_veh_buf     TYPE REF TO /DBE/cl_veh_buf,
         lo_vehicle     TYPE REF TO /DBE/cl_veh_dbmvehicle,
         lt_bob         TYPE /DBE/t_veh_bob,"/DBE/t_veh_bobget,
         ls_bob         TYPE /DBE/s_veh_bob,
         lt_bob_details TYPE /DBE/t_veh_bob,
         ls_bob_details TYPE /DBE/s_veh_bob,
         ls_vehicle     LIKE LINE OF   lt_bob,
         lr_data        TYPE REF TO data,
         lr_item_data   TYPE REF TO data,
         lr_vlcactdata_head      TYPE REF TO vlcactdata_head_s,
         lr_vlcactdata_item      TYPE REF TO vlcactdata_item_s,
         lo_ref         TYPE REF TO cx_root,
         lv_result      TYPE string ,
         lv_action      TYPE vlc_action,
         lt_return      TYPE TABLE OF bapiret2,
         ls_bapireturn  TYPE bapiret2,
         lx_root        TYPE REF TO cx_root,
         ls_req_data    TYPE /DBE/req_vehicle_data ,
         lv_gr          TYPE boolean,
         lv_inv         TYPE boolean,
         lt_bapireturn  type bapiret2_t.

  CLEAR: lv_gr, lv_inv.

* get instance of the buffer...
  lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).

  TRY.
    CALL METHOD lo_veh_buf->get_all
      RECEIVING
        rt_bob = lt_bob.
  ENDTRY.

  IF gv_action NE /DBE/if_vms_constants=>c_qgcb
     AND  gv_action NE /DBE/if_vms_constants=>c_qirb AND gv_action NE /DBE/if_vms_constants=>c_qgrb.
    LOOP AT lt_bob INTO ls_bob  .
      lo_vehicle ?= ls_bob-bobref.

      TRY.
* VLCACTDATA HEAD from COM
          lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
      IF lr_data IS BOUND.
        lr_vlcactdata_head ?= lr_data.
        MOVE-CORRESPONDING gs_vlcactdata_head TO  lr_vlcactdata_head->*.

      ENDIF.
      TRY.
          lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
      IF lr_item_data IS BOUND.
        lr_vlcactdata_item ?= lr_item_data.
        READ TABLE gt_vsresult_selection INTO gs_selection WITH KEY vguid = lr_vlcactdata_item->*-vguid. "batch no
        IF sy-subrc = 0.
          IF gs_vlcactdata_item-eindt_changed IS NOT INITIAL.
            lr_vlcactdata_item->*-eindt_changed = gs_vlcactdata_item-eindt_changed.
          ELSE.
            lr_vlcactdata_item->*-eindt_changed = gs_vlcactdata_head-eindt.
          ENDIF.
          lr_vlcactdata_item->*-netpr = gs_vlcactdata_item-netpr.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_gr IS NOT INITIAL.
      MESSAGE i416(/DBE/vehicle_master) WITH 'Goods Receipt'(006).
    ENDIF.
    IF lv_inv IS NOT INITIAL.
      MESSAGE i416(/DBE/vehicle_master) WITH 'Incoming Invoice'(007).
    ENDIF.

* Set data in Vehicle buffer
    TRY.
        CALL METHOD lo_veh_buf->set_all.
      CATCH /DBE/cx_veh_error_occured .
      CATCH cx_static_check.
    ENDTRY.

  ELSE.
  ENDIF.

* Trigger buffer save ,which in turn triggers action execution and mass save of vehicle class
  TRY.
      CALL METHOD lo_veh_buf->save
        EXPORTING
          it_bob = lt_bob.
    CATCH /DBE/cx_veh_error_occured INTO lx_root .
  ENDTRY.
  CLEAR lt_bapireturn.
  TRY.
    lo_veh_buf->get_messages( EXPORTING io_cx_root    = lx_root
                              IMPORTING et_bapireturn = lt_bapireturn ).
  ENDTRY.
  APPEND LINES OF lt_bapireturn TO gt_bapireturn.
  READ TABLE gt_bapireturn INTO ls_bapireturn WITH KEY type = gc_err_msgtype   .
  IF sy-subrc = 0 OR gv_action_status = 'E'..
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.
  CLEAR gv_action_status.

* Get data from Work Layer to COM layer

  LOOP AT lt_bob INTO ls_bob.
    lo_vehicle ?= ls_bob-bobref.
    TRY.
        CALL METHOD lo_vehicle->/DBE/if_veh_bob~fill_com.
      CATCH /DBE/cx_veh_static_check .
    ENDTRY.
  ENDLOOP.

ENDFORM.                    " ACTION_EXECUTE

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO43 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_VEHICLES_FOR_ACTION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_vehicles_for_action OUTPUT.

  PERFORM f_vehicles_for_action.                         "N:2304203

ENDMODULE.                 " M_VEHICLES_FOR_ACTION  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  M_VEHICLES_FOR_ACTION                       N:2304203
*&---------------------------------------------------------------------*
FORM f_vehicles_for_action.
  DATA: lo_buf               TYPE REF TO /DBE/cl_veh_buf,
        lt_bob               TYPE /DBE/t_veh_bob,
        ls_bob               LIKE LINE OF lt_bob,
        lv_modelguid         TYPE /DBE/MODEL_GUID ,
        lo_veh               TYPE REF TO /DBE/cl_veh_dbmvehicle,
        lr_vlcactdata_head   TYPE REF TO vlcactdata_head_s,
        lr_vlcactdata_item   TYPE REF TO vlcactdata_item_s,
        lr_iobj_single       TYPE REF TO /DBE/iobj_data_single_com_s,
        ls_iobj_single       TYPE /DBE/iobj_data_single_com_s,
        lt_guids             TYPE TABLE OF vlcguid,
        ls_guid              TYPE vlcguid.

** This indicates that actins are triggered by mass vehicle interface
  export cur_txn_name TO MEMORY ID 'TXN_NAME'.
*
** Get Vehicles from database and fill the buffer
** If action is performed via the serach result , unless and until an action is
** executed, vehicle details will not be loaded to buffer.
** The below subroutine does the job of gettting vehicles to buffer
*
*  PERFORM retrieve_vehicles.
* get instance of the buffer...
  lo_buf = /DBE/cl_veh_buf=>get_instance( ).
* Read the buffer data
  TRY.
    CALL METHOD lo_buf->get_all
      RECEIVING
        rt_bob = lt_bob.
  ENDTRY.

  CLEAR lv_modelguid.
  LOOP AT gt_vsresult_selection INTO gs_selection.
    READ TABLE lt_bob INTO ls_bob WITH KEY guid = gs_selection-vguid.
    IF sy-subrc = 0.

      lo_veh ?= ls_bob-bobref.

      TRY.
          CALL METHOD lo_veh->set_action
            EXPORTING
              iv_action     = gv_action
              iv_wo_prepare = abap_false.
        CATCH /DBE/cx_veh_action_not_defined .
        CATCH /DBE/cx_veh_static_check .
      ENDTRY.

*---------------can be avoided---------------------------------------*
      TRY.
          lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.

      TRY.
          lr_vlcactdata_item ?=  lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.

      TRY.
          lr_iobj_single ?=  lo_veh->get_data_com( lo_veh->gc_iobj_data_single_com_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
*--------------------------------------------------------------------------------------*
      IF lr_iobj_single IS BOUND.
        MOVE-CORRESPONDING  lr_iobj_single->* TO ls_iobj_single.
      ENDIF.
      IF lr_vlcactdata_head IS BOUND.
        " If the selected vehicles belong to differet models,table has to be invoked
        lv_modelguid = ls_iobj_single-/DBE/V_IMODEL-modguid.
        IF ls_iobj_single-/DBE/V_IMODEL-modguid <> lv_modelguid.
          gv_enable_alv = abap_true.
        ENDIF.
        MOVE ls_iobj_single-/DBE/V_IMODEL-purcprice_c TO lr_vlcactdata_head->*-currency.
        MOVE-CORRESPONDING lr_vlcactdata_head->* TO vlcactdata_head_s.
      ENDIF.

      IF lr_vlcactdata_item IS BOUND.
        MOVE ls_iobj_single-/DBE/V_IMODEL-purcprice TO lr_vlcactdata_item->*-netpr.
        MOVE-CORRESPONDING  lr_vlcactdata_item->* TO vlcactdata_item_s.
      ENDIF.

    ENDIF.

    ls_guid-vguid = ls_bob-guid.
    APPEND ls_guid TO lt_guids.
  ENDLOOP.
*
  MOVE sy-datum TO vlcactdata_head_s-/dbe/report_date.

  TRY.
      CALL METHOD lo_buf->set_all.
    CATCH /DBE/cx_veh_error_occured .
    CATCH cx_static_check.
  ENDTRY.

ENDFORM.

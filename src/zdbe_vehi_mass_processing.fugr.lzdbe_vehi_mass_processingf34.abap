*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF34 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  EXECUTE_ACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM execute_action .

  DATA:
    lv_no_in_char(2)   TYPE c,
    lv_dummy_guid      TYPE /dbe/veh_guid,
    lv_number          TYPE i,
    lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
    lt_bob_details     TYPE /dbe/t_veh_bob,
    ls_bob_details     TYPE /dbe/s_veh_bob,
    lv_action          TYPE vlc_action,
    ls_req_data        TYPE /dbe/req_vehicle_data,
    lt_veh_bob         TYPE /dbe/t_veh_bob,
    ls_veh_bob         TYPE /dbe/s_veh_bob,
    rs_vlcdiavehi      TYPE REF TO vlcdiavehi,
    lo_ref             TYPE REF TO cx_root,
    ls_bapireturn      TYPE bapiret2,
    ls_bob             TYPE /dbe/s_veh_bobget,
    lt_bob             TYPE /dbe/t_veh_bobget,
    lt_dummy_bob       TYPE /dbe/t_veh_bobget,
    lv_vehicles        TYPE i,
    lo_cx_root         TYPE REF TO cx_root,
    lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
    ls_new_vehicle     TYPE /dbe/s_veh_bobnew,
    lt_new_vehicles    TYPE /dbe/t_veh_bobnew,
    lt_vehicles        TYPE /dbe/t_veh_bob,
    ls_vehicles        TYPE /dbe/s_veh_bob,
    ls_vlcactdata_head TYPE vlcactdata_head_s,
    lr_iobj_single_com TYPE REF TO /dbe/iobj_data_single_com_s,
    lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
    lo_iobject         TYPE REF TO /dbe/cl_veh_iobject_vehicle,
    lv_category_id     TYPE /dbe/exts_category_id VALUE 'DBM_PASSENGERCAR',
    lv_new             TYPE boole_d,
    ls_iobj_single     TYPE /dbe/iobj_data_single_com_s,
    ls_v_imodel        TYPE /dbe/v_imodel_dynp,
    ls_v_ivehicle      TYPE /dbe/v_vehicle_data,
    ls_v_icond         TYPE /dbe/v_icond_dynp,
    ls_v_ileasing      TYPE /dbe/v_ileasing_dynp,
    ls_v_ifinanc       TYPE /dbe/v_ifinanc_dynp,
    ls_v_iprices       TYPE /dbe/v_iprices_dynp,
    result             TYPE i.

  "Create an instance of the buffer...
  lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).

  CALL METHOD lo_veh_buf->get_all
    RECEIVING
      rt_bob = lt_bob_details.

  LOOP AT lt_bob_details INTO ls_bob_details .
    lo_vehicle ?= ls_bob_details-bobref.

    lv_dummy = lo_vehicle->is_guid_dummy( ).
    IF lv_dummy = abap_true.
      ls_bob-guid = ls_bob_details-guid.
      ls_bob-bobtype  = '/DBE/CL_VEH_DBMVEHICLE'.
      APPEND ls_bob TO lt_dummy_bob.
    ELSE.
      DELETE  lt_bob_details.
    ENDIF.
  ENDLOOP.

* Dependency Check
  TRY.
      lo_veh_buf->dependency_check( lt_vehicles ).
*      lo_veh_buf->save(  ).
      TRY.
          CALL METHOD lo_veh_buf->save
            EXPORTING
              it_bob = lt_bob_details.
        CATCH /dbe/cx_veh_error_occured .
      ENDTRY.

      CLEAR lt_bob_details.

      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob_details.
*
      CLEAR lt_bob.


      LOOP AT lt_bob_details INTO ls_bob_details .
        CLEAR: lv_dummy,
               lv_new.
        lo_vehicle ?= ls_bob_details-bobref.
        lv_dummy = lo_vehicle->is_guid_dummy( ).
        IF lv_dummy <> abap_true .
          ls_bob-guid = ls_bob_details-guid.
          ls_bob-bobtype  = ls_bob_details-bobtype.
          APPEND ls_bob TO lt_bob.
        ENDIF.
      ENDLOOP.

*     Request for Iobject text
      ls_req_data-iobj_gentext = 'X'.
*     Get the data of DBM vehicle from DB
      CALL METHOD /dbe/cl_veh_dbmvehicle=>get_dbmvehicle
        EXPORTING
          it_bobget   = lt_bob
          is_req_data = ls_req_data
          iv_iobj_req = 'X'
        IMPORTING
          et_bob      = lt_bob_details.

      CLEAR: gt_vsresult,
             gt_iobj_single.

      LOOP AT lt_bob_details INTO ls_veh_bob .
        "We know that the interface reference returned in ls_veh_bob is a DBMVEHICLE
        "Need to cast to DBMVEHICLE, to get access to the COM layer
        lo_vehicle ?= ls_veh_bob-bobref.
        rs_vlcdiavehi ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcdiavehi ).
        gs_vlcdiavehi  = rs_vlcdiavehi->*.
        MOVE-CORRESPONDING gs_vlcdiavehi TO  gs_vsresult.
        CLEAR lr_iobj_single_com.
        "Get single iobject to populate data on worklist
        lr_iobj_single_com ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
        ls_iobj_single = lr_iobj_single_com->*.
        ls_v_imodel = ls_iobj_single-/dbe/v_imodel.
        MOVE-CORRESPONDING ls_v_imodel TO gs_vsresult.
        ls_v_icond = ls_iobj_single-/dbe/v_icond.
        MOVE-CORRESPONDING ls_v_icond TO gs_vsresult.
        ls_v_ileasing = ls_iobj_single-/dbe/v_ileasing.
        MOVE-CORRESPONDING ls_v_ileasing TO gs_vsresult.
        ls_v_iprices = ls_iobj_single-/dbe/v_iprices.
        MOVE-CORRESPONDING ls_v_iprices TO gs_vsresult.
        ls_v_ifinanc = ls_iobj_single-/dbe/v_ifinanc.
        MOVE-CORRESPONDING ls_v_ifinanc TO gs_vsresult.

        IF gs_vsresult-vhcle IS INITIAL.
          DELETE lt_bob_details WHERE guid = ls_veh_bob-guid.
          CONTINUE.
        ENDIF.
        APPEND  gs_vsresult TO gt_vsresult.
      ENDLOOP.

      SORT gt_vsresult BY vhcle DESCENDING.


    CATCH  /dbe/cx_veh_layer_not_found INTO lo_cx_root.
      CALL METHOD lo_veh_buf->get_messages
        EXPORTING
          io_cx_root    = lo_cx_root
        IMPORTING
          et_bapireturn = gt_bapireturn.
    CATCH /dbe/cx_veh_error_occured INTO lo_cx_root.

      CALL METHOD lo_veh_buf->get_messages
        EXPORTING
          io_cx_root    = lo_cx_root
        IMPORTING
          et_bapireturn = gt_bapireturn.

    CATCH cx_static_check INTO lo_cx_root.
      CALL METHOD lo_veh_buf->get_messages
        EXPORTING
          io_cx_root    = lo_cx_root
        IMPORTING
          et_bapireturn = gt_bapireturn.

  ENDTRY.

ENDFORM.                    " EXECUTE_ACTION

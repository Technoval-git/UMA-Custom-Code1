*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data  ."#EC CALLED
  DATA:
*    lv_vguid           TYPE vlc_guid,
    lt_bapireturn      TYPE TABLE OF bapiret2,
*    ls_return          TYPE bapiret2,
    lv_error_set       TYPE c,
    ls_req_data        TYPE /DBE/req_vehicle_data,
    ls_reg_settype     TYPE scr_settype_type,
    ls_iobj_exttext    TYPE comt_frgtype_id,
    lv_after_action    TYPE boole_d VALUE abap_false,
    lo_veh_buf         TYPE REF TO /DBE/cl_veh_buf,
    lo_vehicle         TYPE REF TO /DBE/cl_veh_dbmvehicle,
    ls_vehicle         TYPE /DBE/s_veh_bob,
    lt_vehicles        TYPE /DBE/t_veh_bob,
    lr_vlcdiavehi      TYPE REF TO vlcdiavehi,
    lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
    lr_vlcadddata      TYPE REF TO vlcadddata_item_t,
    lr_iobj_single     TYPE REF TO /DBE/iobj_data_single_com_s,
    lr_iobj_multi      TYPE REF TO /DBE/iobj_data_multi_com_s,
    ls_selected_action TYPE cvlc03,
    lv_vehicle_action  TYPE vlc_action,
    lo_iobject         TYPE REF TO /DBE/cl_veh_iobject_vehicle,
    lx_layer_not_found TYPE REF TO /DBE/cx_veh_layer_not_found.

* Request vehicle texts
*  ls_req_data-iobj_gentext = 'X'.
  ls_req_data-vms_text     = 'X'.

*Get the settypes required by the current screen
  LOOP AT gt_registered_settypes INTO ls_reg_settype
  WHERE progname = sy-repid AND dynnr = sy-dynnr.
    ls_iobj_exttext = ls_reg_settype-settype_name.
    APPEND ls_iobj_exttext TO ls_req_data-iobj_exttext.
  ENDLOOP.

*Get the vehicle data from the buffer if no errors occured during the
*set method
*  IF lv_error_set IS INITIAL.
  lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).
  lt_vehicles = lo_veh_buf->get_all( ).


  CLEAR: gs_vlcdiavehi, gs_vlcactdata_head, gs_vlcactdata_item,
        gt_vlcadddata[], gs_iobj_single, gs_iobj_multi.
  LOOP AT  lt_vehicles INTO ls_vehicle .

    lo_vehicle ?= ls_vehicle-bobref.
    lo_vehicle->get_action( IMPORTING ev_action = lv_vehicle_action ).

*     Vehicle found in the buffer and the action set for it matches the action selected on the ui.
*     That means the action data has already been prepared in the com layer which would be spoiled
*     by calling the /DBE/VM01_VEHICLE_GET as it overwrites com layer data with work layer data.
    IF lo_vehicle IS BOUND AND lv_after_action = abap_false
      AND ls_selected_action-aktion = lv_vehicle_action AND ls_selected_action-creaact = abap_false.
      TRY.
          lr_vlcdiavehi ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcdiavehi ).
          gs_vlcdiavehi = lr_vlcdiavehi->*.
          lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
          gs_vlcactdata_item = lr_vlcactdata_item->*.
          lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
          gs_vlcactdata_head = lr_vlcactdata_head->*.
          lr_vlcadddata ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcadddata_item_t ).
          gt_vlcadddata = lr_vlcadddata->*.
          lr_iobj_single ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
          gs_iobj_single = lr_iobj_single->*.
          lr_iobj_multi ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_multi_com_s ).
          gs_iobj_multi = lr_iobj_multi->*.
          lo_iobject ?= lo_vehicle->iobject_get( ).
          gv_iobj_catid = lo_iobject->get_category_id( ).
        CATCH /DBE/cx_veh_layer_not_found INTO lx_layer_not_found.
          lo_veh_buf->get_messages( EXPORTING io_cx_root = lx_layer_not_found
                                    IMPORTING et_bapireturn = lt_bapireturn ).
      ENDTRY.
    ELSE.
    ENDIF.
  ENDLOOP.
*    ENDIF.
*  ENDIF.

*At the begining the head and item structures are empty, only
*the vlcdiavehi strucutre contain data, in next steps head and
*item structuers are updated
  IF gs_vlcactdata_head IS INITIAL AND
    gs_vlcactdata_item IS INITIAL AND
    gs_vlcdiavehi IS NOT INITIAL.
    MOVE-CORRESPONDING gs_vlcdiavehi TO gs_vlcactdata_head.
    MOVE-CORRESPONDING gs_vlcdiavehi TO gs_vlcactdata_item.
*Convert PDDATUM from time stamp
    IF gs_vlcdiavehi-pdtsp IS NOT INITIAL.
      CALL FUNCTION '/DBE/C_CONVERT_FROM_TIMESTAMP'
        EXPORTING
          iv_timestamp      = gs_vlcdiavehi-pdtsp
*         IV_LONG_TIMESTAMP =
          iv_zonlo          = sy-zonlo
        IMPORTING
          ev_datlo          = vlcactdata_head_s-pddatu
*         EV_TIMLO          =
        EXCEPTIONS
          data_missing      = 1
          OTHERS            = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
  ENDIF.
*Fill out the vms subscreen's structures
  vlcactdata_head_s = gs_vlcactdata_head.
  vlcactdata_item_s = gs_vlcactdata_item.

*Fill out the vlcdiavehic structure
  IF gs_vlcdiavehi IS NOT INITIAL.
  vlcdiavehi = gs_vlcdiavehi.
  ENDIF.

*Move screen IObject single from buffer to the screen structures
  IF lv_error_set IS INITIAL.
    PERFORM iobj_single_move USING gc_0.
  ENDIF.

*  CALL FUNCTION '/DBE/VM08_ERROR_SET'
*   EXPORTING
**   IV_ERROR            =
*     it_bapireturn       = lt_bapireturn.
*
** Set the cursor position
*  IF NOT gv_cursor_field IS INITIAL.
*    SET CURSOR FIELD gv_cursor_field.
*    CLEAR gv_cursor_field.
*  ELSE.
*    SET CURSOR 0 0.
*  ENDIF.


ENDFORM.                    " F_PREPARE_DATA

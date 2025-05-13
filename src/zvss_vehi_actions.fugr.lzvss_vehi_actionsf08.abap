*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ACTIONSF08.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_TRANSFER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_transfer_data .

  DATA:
    lv_is_crea_screen   TYPE c,
    lt_bapireturn       TYPE TABLE OF bapiret2,
    lv_error            TYPE c,
    ls_action           TYPE cvlc03,
    lv_veh_mode         TYPE c,
    lv_view_mode        TYPE c,
    lv_subrc            TYPE sy-subrc,
    lv_naventry         TYPE /dbe/naventry,
    ls_bapireturn       TYPE bapiret2,
    lv_block_navigation TYPE boole_d VALUE abap_false,
    lv_subscreen_mode   TYPE c,

    lo_veh_buf          TYPE REF TO /dbe/cl_veh_buf,
    lo_vehicle          TYPE REF TO /dbe/cl_veh_dbmvehicle,
    lt_bob              TYPE /dbe/t_veh_bob,
    ls_bob              TYPE /dbe/s_veh_bob,
    lr_item_data        TYPE REF TO data,
    lr_vlcactdata_head  TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item  TYPE REF TO vlcactdata_item_s.


  lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
  TRY.
      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob.
  ENDTRY.

*Set global structures from subscreen's data
* Additional data is updating directly in the table controll.

*Get selected action
  CALL FUNCTION '/DBE/VM08_SELECTED_ACTION_GET'
    IMPORTING
      es_sel_action = ls_action
*     EV_SEL_ACTIONT       =
*     EV_AUTHORITY  =
      ev_naventry   = lv_naventry.


*Get vehicle mode
  CALL FUNCTION '/DBE/VM08_VEHICLE_MODE_GET'
    EXPORTING
      iv_subscreen      = sy-dynnr                   "N:2212051
    IMPORTING
      ev_veh_mode       = lv_veh_mode
      ev_subscreen_mode = lv_subscreen_mode.         "N:2212051

* check also subscreen mode                           N:2212051
  IF lv_veh_mode <> '0' AND lv_veh_mode IS NOT INITIAL AND lv_subscreen_mode IS NOT INITIAL.
    IF lv_subscreen_mode IS NOT INITIAL.
      lv_veh_mode = lv_subscreen_mode.
    ENDIF.
  ENDIF.

*Get view mode
  CALL FUNCTION '/DBE/VM08_VEHICLE_VIEW_MOD_GET'
    IMPORTING
      ev_view_mode = lv_view_mode.


  "<late_vehicle_locking>
  " check if the vehicle is locked
  IF gs_vlcactdata_item-vguid IS NOT INITIAL AND
    /dbe/cl_veh_dbmvehicle=>is_dbmvehicle_locked( iv_guid = gs_vlcactdata_item-vguid ) = abap_false.
    lv_veh_mode = gc_0.
  ENDIF.
  "</late_vehicle_locking>

*Get creation screen flag
  CALL FUNCTION '/DBE/VM08_IS_CREA_SCREEN_GET'
    IMPORTING
      ev_is_crea_screen = lv_is_crea_screen.

* Store vehicle net price for incoming invoice process          "N.2051187
  IF vlcactdata_head_s-netpr <> vlcactdata_item_s-item_amount "#EC CI_FLDEXT_OK[2610650]
    OR vlcactdata_head_s-currency <> vlcactdata_item_s-item_currency.
    vlcactdata_item_s-item_amount   = vlcactdata_head_s-netpr.
    vlcactdata_item_s-item_currency = vlcactdata_head_s-currency.
  ENDIF.

* Header data
  MOVE-CORRESPONDING vlcactdata_head_s TO gs_vlcactdata_head.
* Item data
  MOVE-CORRESPONDING vlcactdata_item_s TO gs_vlcactdata_item.

* Move screen IObject single structures to the buffer
  PERFORM iobj_single_move USING gc_1.

* Store the newest vehicle data in the buffer
  IF lv_veh_mode NE gc_0 AND lv_veh_mode IS NOT INITIAL.
    CALL FUNCTION '/DBE/VM01_VEHICLE_SET'
      EXPORTING
        iv_iobj_catid           = gv_iobj_catid
        is_iobj_data_single_com = gs_iobj_single
        is_iobj_data_multi_com  = gs_iobj_multi
        iv_action               = ls_action-aktion
        is_vlcactdata_head      = gs_vlcactdata_head
        is_vlcactdata_item      = gs_vlcactdata_item
        it_vlcadddata           = gt_vlcadddata
      IMPORTING
        et_bapireturn           = lt_bapireturn
        ev_iobj_catid           = gv_iobj_catid
      EXCEPTIONS
        error_iobject           = 1
        error_badi              = 2
        error_vms               = 3
        OTHERS                  = 4.
    IF sy-subrc <> 0.
      lv_subrc = sy-subrc.
*     Set error flag
      lv_error = gc_xflag.
    ELSE.
*     Set ok flag
      CLEAR: lv_error.
    ENDIF.

*   In creation of the new vehicle process an exception means that
*   not all obligatory field have been filled out e.g. category id, model
    IF lv_view_mode EQ gc_2.
      IF lv_subrc NE 0 AND
        lv_naventry EQ gc_init.
        lv_is_crea_screen = gc_1.
      ELSE.
        IF lv_is_crea_screen EQ gc_1 OR
          lv_is_crea_screen IS INITIAL.
          lv_is_crea_screen = gc_2.
*         call prepare action
          PERFORM f_prepare_action CHANGING ls_bapireturn.
        ENDIF.
      ENDIF.
*     Set first creation screen
      CALL FUNCTION '/DBE/VM08_IS_CREA_SCREEN_SET'
        EXPORTING
          iv_is_crea_screen = lv_is_crea_screen.
    ENDIF.
  ENDIF.

* Set the cursor to the error, if any
  LOOP AT lt_bapireturn INTO ls_bapireturn WHERE
    type = gc_e AND parameter NE space AND field NE space.

    CONCATENATE ls_bapireturn-parameter '-' ls_bapireturn-field
    INTO gv_cursor_field.
*   Check if field can be found on current screen.
    LOOP AT SCREEN.
      IF screen-name = gv_cursor_field.
        lv_block_navigation = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_block_navigation = abap_true.
      EXIT.
    ENDIF.
*   Loop at screen cannot check multiline settypes, check them here
    READ TABLE gt_registered_settypes WITH KEY progname = sy-repid
      dynnr = sy-dynnr settype_name = ls_bapireturn-parameter TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      lv_block_navigation = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.

*Update an error flag and return table
  IF lv_block_navigation = abap_true.
    CALL FUNCTION '/DBE/VM08_ERROR_SET'
      EXPORTING
        iv_error            = lv_error
        it_bapireturn       = lt_bapireturn
        iv_block_navigation = lv_block_navigation.
  ELSE.
    CALL FUNCTION '/DBE/VM08_ERROR_SET'
      EXPORTING
        iv_error      = lv_error
        it_bapireturn = lt_bapireturn.
  ENDIF.

* If no error, then set cursor to where it was
  IF gv_cursor_field IS INITIAL.
    GET CURSOR FIELD gv_cursor_field.
  ENDIF.

  READ TABLE lt_bob INTO ls_bob WITH KEY guid = gs_vlcactdata_item-vguid.
  IF sy-subrc = 0.
    lo_vehicle ?= ls_bob-bobref.
    TRY.
        lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_item_data IS BOUND.
      lr_vlcactdata_item ?= lr_item_data.
    ENDIF.
  ENDIF.

  TRY.
      CALL METHOD lo_veh_buf->set_all.
    CATCH /dbe/cx_veh_error_occured.
    CATCH cx_static_check.
  ENDTRY.

ENDFORM.                    " F_TRANSFER_DATA

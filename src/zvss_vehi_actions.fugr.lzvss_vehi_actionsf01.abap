*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ACTIONSF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form f_prepare_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_prepare_data .
  DATA:
    lv_vguid           TYPE vlc_guid,
    lt_bapireturn      TYPE TABLE OF bapiret2,
    ls_return          TYPE bapiret2,
    lv_error_set       TYPE c,
    ls_req_data        TYPE /dbe/req_vehicle_data,
    ls_reg_settype     TYPE scr_settype_type,
    lv_after_action    TYPE boole_d VALUE abap_false,
    lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
    lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
    ls_vehicle         TYPE /dbe/s_veh_bob,
    lt_vehicles        TYPE /dbe/t_veh_bob,
    lr_vlcdiavehi      TYPE REF TO vlcdiavehi,
    lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
    lr_vlcadddata      TYPE REF TO vlcadddata_item_t,
    lr_iobj_single     TYPE REF TO /dbe/iobj_data_single_com_s,
    lr_iobj_multi      TYPE REF TO /dbe/iobj_data_multi_com_s,
    ls_selected_action TYPE cvlc03,
    lv_vehicle_action  TYPE vlc_action,
    lo_iobject         TYPE REF TO /dbe/cl_veh_iobject_vehicle,
    lx_layer_not_found TYPE REF TO /dbe/cx_veh_layer_not_found,
    it_vlcporder       TYPE TABLE OF vlcporder,
    wa_vlcporder       TYPE vlcporder,
    wa_lips            TYPE lips.

  CALL FUNCTION '/DBE/VM08_ERROR_GET'
    IMPORTING
      ev_error = lv_error_set.

* Get selected vehicle - in case of existing vehicle
  CALL FUNCTION '/DBE/VM08_VEHICLE_VGUID_GET'
    IMPORTING
      ev_vguid = lv_vguid.

* Get vehicle mode - importanta at the begining
  CALL FUNCTION '/DBE/VM08_VEHICLE_MODE_GET'.

* Get info if before action or after action execution
  CALL FUNCTION '/DBE/VM08_BEFORE_AFTER_GET'
    IMPORTING
      ev_state = lv_after_action.

  CALL FUNCTION '/DBE/VM08_SELECTED_ACTION_GET'
    IMPORTING
      es_sel_action = ls_selected_action.

* Request vehicle texts
  ls_req_data-vms_text = 'X'.

* Get the settypes required by the current screen
  LOOP AT gt_registered_settypes INTO ls_reg_settype
       WHERE progname = sy-repid AND
             dynnr    = sy-dynnr.
    APPEND ls_reg_settype-settype_name TO ls_req_data-iobj_exttext.
  ENDLOOP.

* Get the vehicle data from the buffer if no errors occured during the
* set method
  IF lv_error_set IS INITIAL.
    CLEAR: gs_vlcdiavehi,
           gs_vlcactdata_head,
           gs_vlcactdata_item,
           gt_vlcadddata[],
           gs_iobj_single,
           gs_iobj_multi.

    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    lt_vehicles = lo_veh_buf->get_all( ).

    IF lv_vguid IS NOT INITIAL.
      READ TABLE lt_vehicles INTO ls_vehicle WITH KEY guid = lv_vguid.
    ELSE.
      READ TABLE lt_vehicles INTO ls_vehicle INDEX 1.
    ENDIF.
    IF sy-subrc = 0.
      lo_vehicle ?= ls_vehicle-bobref.
      lo_vehicle->get_action( IMPORTING ev_action = lv_vehicle_action ).
    ENDIF.

*   Vehicle found in the buffer and the action set for it matches the action selected on the ui.
*   That means the action data has already been prepared in the com layer which would be spoiled
*   by calling the /DBE/VM01_VEHICLE_GET as it overwrites com layer data with work layer data.
    IF lo_vehicle IS BOUND AND
       lv_after_action = abap_false AND
       ls_selected_action-aktion = lv_vehicle_action AND
       ls_selected_action-creaact = abap_false.
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
        CATCH /dbe/cx_veh_layer_not_found INTO lx_layer_not_found.
          lo_veh_buf->get_messages( EXPORTING io_cx_root    = lx_layer_not_found
                                    IMPORTING et_bapireturn = lt_bapireturn ).
      ENDTRY.
    ELSE.
*     read texts as well: Generic Reading of Individual Object Texts
      ls_req_data-iobj_gentext = abap_true.
      CLEAR ls_req_data-iobj_exttext.
      CALL FUNCTION '/DBE/VM01_VEHICLE_GET'
        EXPORTING
          iv_vguid                = lv_vguid    " can be empty
          is_req_data             = ls_req_data
        IMPORTING
          es_vlcdiavehi           = gs_vlcdiavehi
          es_vlcactdata_head      = gs_vlcactdata_head
          es_vlcactdata_item      = gs_vlcactdata_item
          et_vlcadddata           = gt_vlcadddata
          ev_category_id          = gv_iobj_catid
          es_iobj_data_single_com = gs_iobj_single
          es_iobj_data_multi_com  = gs_iobj_multi
          et_bapireturn           = lt_bapireturn
        EXCEPTIONS
          error_vms_get           = 1
          error_iobj_get          = 2
          error_badi              = 3
          OTHERS                  = 4.
      IF sy-subrc <> 0.
*       Append exception error to the table
        CALL FUNCTION 'BALW_BAPIRETURN_GET2'
          EXPORTING
            type   = sy-msgty
            cl     = sy-msgid
            number = sy-msgno
            par1   = sy-msgv1
            par2   = sy-msgv2
            par3   = sy-msgv3
            par4   = sy-msgv4
          IMPORTING
            return = ls_return.
        APPEND ls_return TO lt_bapireturn.
      ENDIF.
    ENDIF.
  ENDIF.

* At the begining the head and item structures are empty, only
* the vlcdiavehi strucutre contain data, in next steps head and
* item structuers are updated
  IF gs_vlcactdata_head IS INITIAL AND
     gs_vlcactdata_item IS INITIAL AND
     gs_vlcdiavehi      IS NOT INITIAL.
    MOVE-CORRESPONDING gs_vlcdiavehi TO: gs_vlcactdata_head, gs_vlcactdata_item.
*   Convert PDDATUM from time stamp
    IF gs_vlcdiavehi-pdtsp IS NOT INITIAL.
      CALL FUNCTION '/DBE/C_CONVERT_FROM_TIMESTAMP'
        EXPORTING
          iv_timestamp = gs_vlcdiavehi-pdtsp
          iv_zonlo     = sy-zonlo
        IMPORTING
          ev_datlo     = vlcactdata_head_s-pddatu
        EXCEPTIONS
          data_missing = 1
          OTHERS       = 2.
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
  ENDIF.
*
  SELECT SINGLE low FROM tvarvc CLIENT SPECIFIED
  INTO @DATA(lv_yub)
  WHERE mandt = '000'
    AND name = 'ZVSS_BSART'.
  SELECT SINGLE low FROM tvarvc CLIENT SPECIFIED
INTO @DATA(lv_ynln)
WHERE mandt = '000'
AND name = 'ZVSS_PSTYV_YNLN'.


  SELECT SINGLE low FROM tvarvc CLIENT SPECIFIED
INTO @DATA(lv_ynln_b)
WHERE mandt = '000'
AND name = 'ZVSS_PSTYV_YNLN_B'.

  IF gs_vlcactdata_head-bsart IS INITIAL.
    SELECT SINGLE low FROM tvarvc CLIENT SPECIFIED
  INTO @DATA(lv_yeln)
  WHERE mandt = '000'
  AND name = 'ZVSS_PSTYV_YELN'.

    IF sy-dynnr EQ '0300'. " STO purchase order screen
      gs_vlcactdata_head-bsart = lv_yub.
    ENDIF.
  ENDIF.



  SELECT * FROM vlcporder INTO TABLE it_vlcporder
    WHERE vguid EQ gs_vlcdiavehi-vguid AND actdoctype EQ 'ZSTO'
    AND xgore EQ ' ' AND xiniv EQ ' '.
  SORT it_vlcporder BY tstmp DESCENDING.
  READ TABLE it_vlcporder INTO wa_vlcporder INDEX 1.
  IF sy-subrc EQ 0.
    IF sy-dynnr EQ '0350'. " Goods issue Screen
      SELECT SINGLE * FROM lips INTO wa_lips WHERE charg EQ gs_vlcdiavehi-charg AND vgbel EQ wa_vlcporder-ebeln AND pstyv EQ lv_ynln AND matnr EQ gs_vlcdiavehi-matnr.
      IF sy-subrc EQ 0.
        MOVE wa_lips-vbeln TO gs_vlcactdata_head-lbeln.
      ELSE.
        SELECT SINGLE * FROM lips INTO wa_lips WHERE charg EQ gs_vlcdiavehi-charg AND vgbel EQ wa_vlcporder-ebeln AND pstyv EQ lv_ynln_b AND matnr EQ gs_vlcdiavehi-matnr.
        IF sy-subrc EQ 0.
          MOVE wa_lips-vbeln TO gs_vlcactdata_head-lbeln.
        ELSE.
          ls_return-id = 'ZMSG_VSS01'.
          ls_return-number = '026'.
          ls_return-type = 'E'.
          APPEND ls_return TO lt_bapireturn.
        ENDIF.
      ENDIF.
      gs_vlcactdata_head-bldat = sy-datum.
      gs_vlcactdata_head-wadat_ist = sy-datum.
    ENDIF.
    IF sy-dynnr EQ '0360'. " Goods Receipt Screen
      SELECT SINGLE * FROM lips INTO wa_lips WHERE charg EQ gs_vlcdiavehi-charg AND vgbel EQ wa_vlcporder-ebeln AND pstyv EQ lv_yeln AND matnr EQ gs_vlcdiavehi-matnr.
      IF sy-subrc EQ 0.
        MOVE wa_lips-vbeln TO gs_vlcactdata_head-lbeln.
        MOVE wa_lips-werks TO gs_vlcactdata_head-umwerks.
        MOVE wa_lips-lgort TO gs_vlcactdata_head-umlgo.
      ELSE.
        ls_return-id = 'ZMSG_VSS01'.
        ls_return-number = '025'.
        ls_return-type = 'E'.
        APPEND ls_return TO lt_bapireturn.
*         MESSAGE E025(ZMSG_VSS01).
      ENDIF.
      gs_vlcactdata_head-bldat = sy-datum.
      gs_vlcactdata_head-budat = sy-datum.
    ENDIF.
  ENDIF.

* Fill out the vms subscreen's structures
  vlcactdata_head_s = gs_vlcactdata_head.
  vlcactdata_item_s = gs_vlcactdata_item.

* Fill out the vlcdiavehic structure
  vlcdiavehi = gs_vlcdiavehi.

* Move screen IObject single from buffer to the screen structures
  IF lv_error_set IS INITIAL.
    PERFORM iobj_single_move USING gc_0.
  ENDIF.

  CALL FUNCTION '/DBE/VM08_ERROR_SET'
    EXPORTING
      it_bapireturn = lt_bapireturn.

* Set the cursor position
  IF gv_cursor_field IS NOT INITIAL.
    SET CURSOR FIELD gv_cursor_field.
    CLEAR gv_cursor_field.
  ELSE.
    SET CURSOR 0 0.
  ENDIF.

ENDFORM.

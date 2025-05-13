*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF85 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REFRESH_TABLE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_table_data .

  DATA:  lo_vbuf       TYPE REF TO /DBE/cl_veh_buf,
         rs_vlcdiavehi TYPE REF TO vlcdiavehi,
         ls_vlcdiavehi TYPE vlcdiavehi,
         lo_dbmvehicle TYPE REF TO /DBE/cl_veh_dbmvehicle,
         lv_gridtitle  TYPE lvc_title,
         lv_action_number(7) TYPE c,
         lt_bob_all     TYPE /DBE/t_veh_bob,
         ls_bob         LIKE LINE OF lt_bob_all.

  FIELD-SYMBOLS <ls_selection>  TYPE /DBE/vsresult.


  CALL METHOD /DBE/cl_veh_buf=>get_instance
    RECEIVING
      ro_instance = lo_vbuf.
  TRY.
    CALL METHOD lo_vbuf->get_all
      RECEIVING
        rt_bob = lt_bob_all.
  ENDTRY.

  LOOP AT gt_vsresult_selection INTO gs_selection.
    IF lt_bob_all IS NOT INITIAL .
      " action has been executed on vehicle and status change has taken place
      READ TABLE lt_bob_all INTO ls_bob WITH KEY guid = gs_selection-vguid.
      IF sy-subrc = 0.
        lo_dbmvehicle ?= ls_bob-bobref.
        TRY.
            rs_vlcdiavehi ?= lo_dbmvehicle->get_data_com( lo_dbmvehicle->gc_vlcdiavehi ).
            ls_vlcdiavehi  = rs_vlcdiavehi->*.
            PERFORM fill_selection USING ls_vlcdiavehi.
          CATCH /DBE/cx_veh_layer_not_found .
        ENDTRY.
        " retrieve updated data of vehicle from VLCDAIVEHI
        " TO DO : Additional IObject details needs to be fetched ?
        READ TABLE gt_vsresult ASSIGNING <ls_selection> WITH KEY vguid  = ls_bob-guid.
        IF sy-subrc  = 0.
          MOVE-CORRESPONDING  gs_selection TO  <ls_selection> .
          CLEAR gs_selection.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* data lv_gridtitle type LVC_TITLE.
* DATA:  lv_action_number(7) TYPE c.
* prepare title with nr of found vehicles
  DESCRIBE TABLE gt_vsresult LINES lv_action_number.
  CONDENSE lv_action_number.


*  IF lv_action_number = '1'.
*    CONCATENATE lv_action_number text-013 INTO lv_gridtitle SEPARATED BY ' '.
*  ELSEIF lv_action_number = '0'.
*    CONCATENATE  text-610 text-013 INTO lv_gridtitle SEPARATED BY ' '.
*  ELSE.
*    CONCATENATE lv_action_number text-011 INTO lv_gridtitle SEPARATED BY ' '.
*  ENDIF.
*
*  CONDENSE lv_gridtitle.

  IF gs_bulk_actions-creaact = 'X'.  "Note: 2093139
     IF lv_action_number = '0'.
      MESSAGE i471(/DBE/vehicle_master) WITH text-610 INTO lv_gridtitle.
    ELSEIF lv_action_number = '1'.
      MESSAGE i471(/DBE/vehicle_master) WITH lv_action_number INTO lv_gridtitle.
    ELSE.
      MESSAGE i473(/DBE/vehicle_master) WITH lv_action_number INTO lv_gridtitle.
    ENDIF.
    CONDENSE lv_gridtitle.
    CLEAR gv_action_for_alv.
  ELSEIF gv_action_for_alv IS INITIAL.
    IF lv_action_number = '0'.
      MESSAGE i472(/DBE/vehicle_master) WITH text-610 INTO lv_gridtitle.
    ELSEIF lv_action_number = '1'.
      MESSAGE i472(/DBE/vehicle_master) WITH lv_action_number INTO lv_gridtitle.
    ELSE.
      MESSAGE i474(/DBE/vehicle_master) WITH lv_action_number INTO lv_gridtitle.
    ENDIF.
    CONDENSE lv_gridtitle.
    CLEAR gv_action_for_alv.

  ENDIF.


*
  CALL METHOD g_alv_grid->set_gridtitle( lv_gridtitle ).
*  DATA: lt_row_no         TYPE lvc_t_roid.
  g_alv_grid->set_selected_rows( EXPORTING  it_row_no = gt_rowid ).

ENDFORM.                    " REFRESH_TABLE_DATA
*&---------------------------------------------------------------------*
*& Form fill_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM fill_selection  USING    is_vlcdiavehi TYPE vlcdiavehi.

  MOVE-CORRESPONDING is_vlcdiavehi TO gs_selection.
  gs_selection-stock_age   = is_vlcdiavehi-/dbe/stock_age.
  gs_selection-stock_date  = is_vlcdiavehi-/dbe/stock_date.
  gs_selection-report_date = is_vlcdiavehi-/dbe/report_date.

ENDFORM.

*----------------------------------------------------------------------*
***INCLUDE LZDBE_VEHI_MASS_PROCESSINGO45.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module M_PREPARE_DATA_9002 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE m_prepare_data_9002 OUTPUT.
  PERFORM f_prepare_data_9002.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  f_prepare_data_9002                             N:2426282
*&---------------------------------------------------------------------*
FORM f_prepare_data_9002.
  gv_action = 'ZSIB'.
  PERFORM f_prepare_action_zsgi_data USING ok_code gv_action.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  f_prepare_action_qvtb_data                      N:2426282
*&---------------------------------------------------------------------*
FORM f_prepare_action_zsgi_data  USING p_ok_code
                                       p_gv_action.

  DATA : lo_buf             TYPE REF TO /dbe/cl_veh_buf,
         lo_veh             TYPE REF TO /dbe/cl_veh_dbmvehicle,
         lt_bob             TYPE /dbe/t_veh_bob,
         lt_veh_bob         TYPE /dbe/t_veh_bob,
         lt_bob_all         TYPE /dbe/t_veh_bob,
         ls_bob             TYPE /dbe/s_veh_bob,
         lr_data            TYPE REF TO data,
         lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
         lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
         lr_vlcdiavehi      TYPE REF TO vlcdiavehi,
         lt_guids           TYPE TABLE OF vlcguid,
         ls_guid            TYPE vlcguid,
         lv_werks           TYPE werks,
         lv_diff_werks      TYPE abap_bool,
         lv_lgort           TYPE lgort_d,
         lv_diff_lgort      TYPE abap_bool,
         it_vlcporder       TYPE TABLE OF vlcporder,
         wa_vlcporder       TYPE vlcporder,
         wa_lips            TYPE lips,
         wa_ekpo            TYPE ekpo.

  DATA lr_item_data TYPE REF TO data.
*  DATA lr_vlcactdata_item TYPE REF TO vlcactdata_item_s.

* get instance of the buffer...
  lo_buf = /dbe/cl_veh_buf=>get_instance( ).
* Read the buffer data
  CALL METHOD lo_buf->get_all
    RECEIVING
      rt_bob = lt_bob.


  LOOP AT lt_bob INTO ls_bob.

    lo_veh ?= ls_bob-bobref.

    TRY.
        CALL METHOD lo_veh->set_action
          EXPORTING
            iv_action = gv_action.
      CATCH /dbe/cx_veh_action_not_defined .
      CATCH /dbe/cx_veh_static_check .
    ENDTRY.

    TRY.                                                    "N:2744222
        lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
      CATCH /dbe/cx_veh_layer_not_found.
      CATCH cx_sy_move_cast_error.
    ENDTRY.

    TRY.
        lr_item_data  = lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_item_data IS BOUND.
      lr_vlcactdata_item ?= lr_item_data.
    ENDIF.

**   check different plants
*    IF lv_werks IS INITIAL.
*      lv_werks = lr_vlcactdata_head->werks.
*    ELSEIF lv_werks <> lr_vlcactdata_head->werks.
*      lv_diff_werks = abap_true.
*    ENDIF.
*
**   chekl different storage locations
*    IF lv_lgort IS INITIAL.
*      lv_lgort = lr_vlcactdata_head->lgort.
*    ELSEIF lv_lgort <> lr_vlcactdata_head->lgort.
*      lv_diff_lgort = abap_true.
*    ENDIF.

    SELECT SINGLE low FROM tvarvc CLIENT SPECIFIED
    INTO @DATA(lv_yub)
    WHERE mandt = '000'
      AND name = 'ZVSS_BSART'.
    SELECT SINGLE low FROM tvarvc CLIENT SPECIFIED
  INTO @DATA(lv_ynln)
  WHERE mandt = '000'
  AND name = 'ZVSS_PSTYV_YNLN'.

    SELECT * FROM vlcporder INTO TABLE it_vlcporder
      WHERE vguid EQ lr_vlcactdata_item->*-vguid AND actdoctype EQ 'ZSTO'
      AND xgore EQ ' ' AND xiniv EQ ' '.
    SORT it_vlcporder BY tstmp DESCENDING.
    READ TABLE it_vlcporder INTO wa_vlcporder INDEX 1.
    IF sy-subrc EQ 0.
      SELECT SINGLE * FROM ekpo INTO wa_ekpo WHERE ebeln EQ wa_vlcporder-ebeln AND ebelp EQ wa_vlcporder-ebelp.
      IF sy-subrc EQ 0.
        MOVE wa_ekpo-werks TO lr_vlcactdata_head->*-umwerks.
        MOVE wa_ekpo-lgort TO lr_vlcactdata_head->*-umlgo.
      ENDIF.
      SELECT SINGLE * FROM lips INTO wa_lips WHERE charg EQ lr_vlcactdata_item->*-vhcle AND vgbel EQ wa_vlcporder-ebeln AND pstyv EQ lv_ynln AND matnr EQ lr_vlcactdata_item->*-matnr.
      IF sy-subrc EQ 0.
        MOVE wa_lips-vbeln TO lr_vlcactdata_head->*-lbeln.
      ENDIF.
    ENDIF.


    MOVE-CORRESPONDING lr_vlcactdata_head->* TO vlcactdata_head_s.

    ls_guid-vguid = ls_bob-guid.
    APPEND ls_guid TO lt_guids.
  ENDLOOP.

*  IF lv_diff_werks = abap_true.
*    CLEAR: vlcactdata_head_s-werks, vlcactdata_head_s-lgort.
*  ELSEIF lv_diff_lgort = abap_true.
*    CLEAR vlcactdata_head_s-lgort.
*  ENDIF.

* Set data in Vehicle buffer
  IF lo_buf IS BOUND.
    TRY.
        CALL METHOD lo_buf->set_all.
      CATCH /dbe/cx_veh_error_occured .
      CATCH cx_static_check.
    ENDTRY.
  ENDIF.
ENDFORM.                    " F_PREPARE_ACTION_DATA

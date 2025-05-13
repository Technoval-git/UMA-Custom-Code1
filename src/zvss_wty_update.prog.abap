*&---------------------------------------------------------------------*
*& Report ZVSS_WTY_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_wty_update.

DATA : BEGIN OF i_upload OCCURS 0,
         line(1000),
       END OF i_upload.
*
*TYPES: BEGIN OF ty_msg,
*         msg TYPE bapiret2-message,
*       END OF ty_msg.
TYPES: BEGIN OF ty_veh_data,
         vguid TYPE vlc_guid,
         vhcle TYPE vlc_vhcle,
         vhvin TYPE vlc_vhvin,
*         dbm_bustype TYPE /dbm/bustype,
       END OF ty_veh_data.

TYPES : BEGIN OF ty_itab ,
          vhvin      TYPE   vlc_vhvin,
*          dbm_bustype TYPE   /dbm/bustype,
*          wtytype     TYPE dbm_wty_type_ui,
          wtynum     TYPE /dbe/wtynum,
          wtyrtime   TYPE char3,
          wtyrtime_u TYPE comt_attr_unit,
          wtydatab   TYPE /dbe/wtydate,
        END OF ty_itab.

DATA :lv_count TYPE sy-dbcnt .
DATA :it_vehicle TYPE TABLE OF ty_veh_data.
DATA :it_msg TYPE  bapiret2_t.
DATA :itab TYPE TABLE OF ty_itab.

************************************************************************
*                 Selection Screen
************************************************************************

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-001.
*PARAMETERS: p_pgrp TYPE dbm_lab_costrate OBLIGATORY MATCHCODE OBJECT h_t188.
  PARAMETERS: p_filnam LIKE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK blk1.

************************************************************************
*                 At Selection-screen
************************************************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filnam.


* Get upload file path

  PERFORM get_filename USING p_filnam .


************************************************************************
*                 Start of Selection
************************************************************************

START-OF-SELECTION.
* Load data from file

  PERFORM load_data.

* Split data into Internal Table

  PERFORM split_data.
*
* Update data

  PERFORM read_data.
*
** Display Report
*
  PERFORM display_report.


************************************************************************
*                 End of Selection
************************************************************************

END-OF-SELECTION.



*&---------------------------------------------------------------------*
*&      Form  get_filename
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FILNAM  text
*----------------------------------------------------------------------*

FORM get_filename USING p_p_filnam.


* Function to get Filename

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      program_name  = sy-repid
    CHANGING
      file_name     = p_filnam
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.

ENDFORM. " get_filename
*&---------------------------------------------------------------------*
*&      Form  load_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM load_data .

  DATA: wa_file_name TYPE string.

  wa_file_name = p_filnam.

  IF p_filnam IS NOT INITIAL.


* Function to upload the excel sheet saved in csv

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename        = wa_file_name
      TABLES
        data_tab        = i_upload
      EXCEPTIONS
        file_open_error = 1
        file_read_error = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

  IF i_upload[] IS NOT INITIAL.
    LOOP AT i_upload.
      TRANSLATE i_upload TO UPPER CASE.
      MODIFY i_upload.
    ENDLOOP.
  ENDIF.

ENDFORM. " load_data


*&---------------------------------------------------------------------*
*&      Form  split_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM split_data .

* Move uploaded data into internal table for processing
  DATA lv_date TYPE string.
  DATA ts_itab TYPE ty_itab.
  IF i_upload[] IS NOT INITIAL.
    LOOP AT i_upload.
      CLEAR lv_date .
      SPLIT i_upload AT cl_abap_char_utilities=>horizontal_tab
      INTO
      ts_itab-vhvin
*      ts_itab-dbm_bustype
*      ts_itab-wtytype
      ts_itab-wtynum
      ts_itab-wtyrtime
      ts_itab-wtyrtime_u
      lv_date.
      ts_itab-wtydatab = lv_date.
      APPEND ts_itab TO itab.
    ENDLOOP.
  ENDIF.

*  DELETE itab WHERE vhcex = space OR dbm_bustype = space.

ENDFORM. " split_data
FORM read_data.
  SELECT vguid vhcle vhvin "dbm_bustype
      FROM vlcvehicle
      INTO  TABLE it_vehicle
*      PACKAGE SIZE 100 UP TO 1000 ROWS
      FOR ALL ENTRIES IN itab
      WHERE vhvin = itab-vhvin.
*      AND dbm_bustype = itab-dbm_bustype.
  IF sy-subrc = 0.
    PERFORM upd_data.
    CLEAR it_vehicle.
  ENDIF.
*  ENDSELECT.

*  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*    EXPORTING
*      wait = 'X'.
ENDFORM.

FORM upd_data.

  DATA: ls_vehicle             LIKE LINE OF it_vehicle,
        it_veh_bobget          TYPE /dbe/t_veh_bobget,
        ts_veh_bobget          LIKE LINE OF it_veh_bobget,
        it_veh_bob             TYPE /dbe/t_veh_bob,
        ts_veh_bob             LIKE LINE OF it_veh_bob,
        ls_iobj_data_multi_com TYPE REF TO /dbe/iobj_data_multi_com_s,
        lt_dbm_v_iwty          TYPE /dbe/v_iwty_dynp_ext_t,
        ls_dbm_v_iwty          TYPE /dbe/v_iwty_dynp_ext,
        ts_itab                LIKE LINE OF itab,
        it_bapiret2            TYPE bapiret2_t,
        lv_month               TYPE int4,
        ts_bapiret2            TYPE bapiret2,
        it_guid                TYPE /dbe/vlc_guid_t,
        lt_wtydata             TYPE TABLE OF /dbe/wtydata,
        ls_wtydata             TYPE          /dbe/wtydata,
        lt_wtydata_txt         TYPE TABLE OF /dbe/wtydata_tx,
        it_bob_str             TYPE zcl_vehicle_util=>tt_bob_structures,
        ts_bob_str             TYPE zcl_vehicle_util=>ty_bob_structures,
        lv_error_x             TYPE boolean,
        lv_vguid               TYPE vlc_guid.

  DATA : ls_wty  TYPE /dbe/v_iwty_dynp_ext, " /dbe/v_iwty_dynp_sv,
         ls_wty1 TYPE  /dbe/v_iwty_dynp_ext,
         ls_wty2 TYPE  /dbe/v_iwty_dynp_ext,
         ls_wty3 TYPE  /dbe/v_iwty_dynp_ext,
         lv_mon  TYPE int4.
  DATA : lv_enddate TYPE datum.
  DATA: lo_veh_dbmvehicle       TYPE REF TO /dbe/cl_veh_dbmvehicle.

  FIELD-SYMBOLS: <fs_veh_bob> LIKE LINE OF it_veh_bob,
                 <fs_wty>     TYPE /dbe/v_iwty_dynp_sv_ext.
  CLEAR it_guid.
  "Prepare Vehicle Buffer table
  LOOP AT it_vehicle INTO ls_vehicle.
    APPEND ls_vehicle-vguid TO it_guid.
  ENDLOOP.
  CLEAR : it_bob_str, it_bapiret2.
  zcl_vehicle_util=>get_vehicle_bob_db(
         EXPORTING
           it_vguid          = it_guid    " Vehicle GUID (Globally Unique IDentifier)
         IMPORTING
           et_bapiret2       =  it_bapiret2   " Proxy Table Type (generated)
           et_bob_structures = it_bob_str
       ).

  LOOP AT it_bapiret2
       INTO ts_bapiret2
       WHERE type = 'E'.
    APPEND ts_bapiret2 TO it_msg.
    CLEAR ts_bapiret2.
    lv_error_x = abap_true.
  ENDLOOP.
  "Loop vehicles to read vehicle objects and update warranty information
  LOOP AT it_vehicle INTO ls_vehicle.


    READ TABLE it_bob_str INTO  ts_bob_str WITH KEY vguid = ls_vehicle-vguid.
    IF sy-subrc EQ 0.
      CLEAR lt_dbm_v_iwty.

      CALL FUNCTION '/DBE/S_GET_DEFAULT_WTY'
        EXPORTING
          iv_vkcode      = ts_bob_str-ts_iobj_data_single_com-/dbe/v_imodel-mcodesd
          iv_spart       = ts_bob_str-ts_vlcactdata_item-/dbe/spart
          iv_land_dealer = 'AE'
          iv_wty_kind    = '1'
*         iv_structure_name = 'VLCACTDATA_HEAD_S'
*         is_struc       = ts_bob_str-ts_vlcactdata_head
        TABLES
          et_wtydata     = lt_wtydata
          et_wtydata_txt = lt_wtydata_txt
        EXCEPTIONS
          no_standard    = 0
          not_found      = 0
          OTHERS         = 0.


      READ TABLE itab INTO ts_itab WITH KEY vhvin = ls_vehicle-vhvin.
      IF sy-subrc = 0.
        LOOP AT lt_wtydata INTO ls_wtydata.
          ls_dbm_v_iwty-wtytype = ls_wtydata-wty_type.
          ls_dbm_v_iwty-wtyrtime = ls_wtydata-wtytime.
          ls_dbm_v_iwty-wtyrtime_u = ts_itab-wtyrtime_u.
          ls_dbm_v_iwty-wtynum = ts_itab-wtynum .
          ls_dbm_v_iwty-wtydatab = ts_itab-wtydatab .
          APPEND ls_dbm_v_iwty TO lt_dbm_v_iwty.
        ENDLOOP.
      ENDIF.
      CLEAR ts_bob_str-ts_iobj_data_multi_com-/dbe/v_iwty.
      ts_bob_str-ts_iobj_data_multi_com-/dbe/v_iwty  = lt_dbm_v_iwty.
      CLEAR it_bapiret2.
      zcl_vehicle_util=>update_vehicle_bob(
           EXPORTING
             iv_vguid                = ts_bob_str-vguid    " Vehicle GUID (Globally Unique IDentifier)
             is_iobj_data_multi_com  =  ts_bob_str-ts_iobj_data_multi_com   " DBM: Comm. Struct. f. Ind. Object Data: Multiline Extensions
*               iv_save_needed          = abap_false
         IMPORTING
           ct_bapireturn           =  it_bapiret2    " Error Messages
         ).
*      LOOP AT it_bapiret2
*    INTO ts_bapiret2
*    WHERE type = 'E'.
*        ts_bapiret2-message_v1 = ls_vehicle-vhvin.
*        APPEND ts_bapiret2 TO it_msg.
*        CLEAR ts_bapiret2.
*        lv_error_x = abap_true.
*      ENDLOOP.
*      IF lv_error_x = abap_false.
*        "sucees message
**        ts_bapiret2-id = yif_dbm_jet_constants=>gc_msg_class_id.
**        ts_bapiret2-number =  355.
**        ts_bapiret2-type = yif_dbm_jet_constants=>gc_value_s.
*        MESSAGE ID ts_bapiret2-id
*                TYPE ts_bapiret2-type
*                NUMBER ts_bapiret2-number
*                INTO ts_bapiret2-message.
*        CONCATENATE ts_bapiret2-message 'Commission number:' ls_vehicle-vhvin
*        INTO ts_bapiret2-message SEPARATED BY space.
*        APPEND ts_bapiret2 TO it_msg.
*        CLEAR ts_bapiret2.
*      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_report .
  DATA : lo_alv     TYPE REF TO cl_salv_table,
         lo_display TYPE REF TO cl_salv_display_settings,
         lo_funct   TYPE REF TO cl_salv_functions,
         lo_columns TYPE REF TO cl_salv_columns_table,
         lo_column  TYPE REF TO cl_salv_column_table,
         lo_aggrs   TYPE REF TO cl_salv_aggregations,
         lo_header  TYPE REF TO cl_salv_form_layout_grid,
         lo_h_label TYPE REF TO cl_salv_form_label,
         lo_h_flow  TYPE REF TO cl_salv_form_layout_flow,
         lo_sorts   TYPE REF TO cl_salv_sorts,
         lv_head    TYPE string,
         lv_count   TYPE num10.
*  WRITE: lv_count, 'rows updated'.
  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = abap_true                                       "Get SALV factory instance
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = it_msg.
    CATCH cx_salv_msg ##NO_HANDLER.
  ENDTRY.
  lo_alv->display( ).

ENDFORM.

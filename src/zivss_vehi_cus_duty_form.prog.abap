*&---------------------------------------------------------------------*
*& Include          ZIVSS_HONGQI_VEHI_PROCESS_FORM
*&---------------------------------------------------------------------*
FORM form_on_val_req_file .
  DATA: lv_window_title      TYPE string,
        lv_rc                TYPE sysubrc,
        lv_default_file_name TYPE string,
        lt_file_table        TYPE filetable.

  CONSTANTS : lc_err TYPE i VALUE -1,
              lc_suc TYPE i VALUE 1.

  lv_window_title = TEXT-003.
  lv_default_file_name = TEXT-004.

* Method to provide value help for input file name
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_window_title
      default_filename        = lv_default_file_name
    CHANGING
      file_table              = lt_file_table
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  IF lv_rc EQ lc_err.
    MESSAGE ID sy-msgid
          TYPE sy-msgty
        NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSEIF lv_rc EQ lc_suc.
    READ TABLE lt_file_table INDEX 1 INTO p_file.
    IF sy-subrc <> 0.
      CLEAR p_file.
    ENDIF.
  ENDIF.
  CLEAR lt_file_table.
ENDFORM.
FORM form_on_val_req_pi  USING p_p_file TYPE localfile.
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = p_p_file
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_HIDE_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_LOG  text
*----------------------------------------------------------------------*
FORM form_hide_field  USING    p_lc_log.
  LOOP AT SCREEN.
    IF screen-group1 = p_lc_log.
      screen-input = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_UNHIDE_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_LOG  text
*----------------------------------------------------------------------*
FORM form_unhide_field  USING    p_lc_log.
  LOOP AT SCREEN.
    IF screen-group1 = p_lc_log.
      screen-input = 1.
      screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_FILE_EXTENSION_ALLOWED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_file_extension_allowed .

* FM to determine the extension of the specified input file
  IF sy-ucomm = 'ONLI'.
    IF p_file IS NOT INITIAL.
      CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
        EXPORTING
          filename  = p_file
        IMPORTING
          extension = lv_extension.

* Throw an error message
* if the extension of the input file is not equal
* the pre-determined extension
      TRANSLATE lv_extension TO UPPER CASE.

      IF ( ( lv_extension NS gc_ext1 ) AND
         ( lv_extension NE gc_ext2 ) ).
        MESSAGE TEXT-004 TYPE gc_err.
      ENDIF.
    ENDIF.


* Throw an error message
* if entered value in both File Path and Logical File Name
    IF p_file IS NOT INITIAL AND p_logicl IS NOT INITIAL.
      MESSAGE TEXT-007 TYPE gc_err.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_FETCH_FILEPATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_SLOGIC  text
*      <--P_P_SUCC  text
*----------------------------------------------------------------------*
FORM form_fetch_filepath  USING    p_logical
                          CHANGING p_cv_file TYPE localfile.
  IF p_logical IS NOT INITIAL.
    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
*       CLIENT           = SY-MANDT
        logical_filename = p_logical
      IMPORTING
        file_name        = p_cv_file
      EXCEPTIONS
        file_not_found   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
      EXIT.
    ENDIF.
  ENDIF.

  IF p_logical IS NOT INITIAL.
    CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
      EXPORTING
        filename  = p_cv_file
      IMPORTING
        extension = lv_extension.

* Throw an error message
* if the extension of the input file is not equal
* the pre-determined extension
    TRANSLATE lv_extension TO UPPER CASE.

    IF ( ( lv_extension NS gc_ext1 ) AND
       ( lv_extension NE gc_ext2 ) ).
      MESSAGE TEXT-004 TYPE gc_err.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_READ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PR_PI  text
*----------------------------------------------------------------------*
FORM form_read_file  USING p_pr_pi TYPE char1.
* To call the appropriate sub-routine to upload
* the respective input file based on the server
  IF p_pr_pi IS INITIAL.
* Extracting Data from Presentation Server File
    PERFORM form_get_data_pc_file.
  ELSE.
* Extracting Data from Application Server File
    PERFORM form_get_data_pi_file.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_GET_DATA_PC_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_get_data_pc_file .
* To call the appropriate sub-routine to upload the respective
* input file based on the file type
  IF lv_extension CS gc_ext1.
* Sub-routine to upload an excel file
    PERFORM form_upload_file_pc USING gc_csv_sep.
  ELSEIF lv_extension EQ gc_ext2.
* Sub-routine to upload a text file
    PERFORM form_upload_file_pc USING gc_txt_sep.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_GET_DATA_PI_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_get_data_pi_file .
* To call the appropriate sub-routine to upload the respective
* input file based on the file type
  IF lv_extension CS gc_ext1.
* Sub-routine to upload an excel file
    PERFORM form_upload_pi USING gc_csv_sep.
  ELSEIF lv_extension EQ gc_ext2.
* Sub-routine to upload a text file
    PERFORM form_upload_pi USING gc_txt_sep.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_UPLOAD_FILE_PC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CN_CSV_SEP  text
*----------------------------------------------------------------------*
FORM form_upload_file_pc  USING p_file_sep.

* Variable for passing the input file name
  DATA: lv_file_name          TYPE string,
* Variable for passing the virus scan profile
        lv_virus_sacn_profile TYPE vscan_profile,
* Internal table to which data in the input file will be uploaded
        it_data_tab           TYPE stringtab,
* Work area for the above internal table
        ts_data_tab           TYPE string.
  lv_file_name = p_file.

* Method to upload the text file specified as input into internal table
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_file_name
      virus_scan_profile      = lv_virus_sacn_profile
    CHANGING
      data_tab                = it_data_tab
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  CLEAR it_source.
  LOOP AT it_data_tab INTO ts_data_tab FROM 3.
* Map the data to structure
    PERFORM form_map_to_structure USING p_file_sep
                                        ts_data_tab.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_UPLOAD_PI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_CSV_SEP  text
*----------------------------------------------------------------------*
FORM form_upload_pi  USING    p_lc_sep.
  DATA : ts_row      TYPE string.
  CLEAR it_source.
  OPEN DATASET p_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
    DO.
      READ DATASET p_file INTO ts_row.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        IF sy-index GT 1.
* Map the data to structure
          PERFORM form_map_to_structure USING p_lc_sep
                                              ts_row.
        ENDIF.
      ENDIF.
    ENDDO.
    CLOSE DATASET p_file.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_MAP_TO_STRUCTURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FILE_SEP  text
*      -->P_TS_DATA_TAB  text
*      -->P_ENDLOOP  text
*----------------------------------------------------------------------*
FORM form_map_to_structure  USING    p_p_file_sep
                                     p_ts_data_tab.
  DATA: ts_source   TYPE ty_source_fields.
  SPLIT p_ts_data_tab AT p_p_file_sep
  INTO ts_source-ord_no
ts_source-model
ts_source-exterior
ts_source-interior
ts_source-company
ts_source-pur_org
ts_source-pur_grp
ts_source-plant
ts_source-division
ts_source-vendor
ts_source-yv01
ts_source-y100
ts_source-y101
ts_source-y102
ts_source-y103
ts_source-y104
ts_source-y105
ts_source-y106
ts_source-y107
ts_source-y108
ts_source-y109
ts_source-y110
ts_source-y111
ts_source-y112
ts_source-y113.



  IF ts_source IS NOT INITIAL.
    APPEND ts_source TO it_source.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_VALIDATE_INBDEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM  form_process_vehicle.
  TYPES: BEGIN OF ty_exist_inb,
           vbeln TYPE vbeln_vl,
           verur TYPE verur_vl,
           charg TYPE charg_d,
         END OF ty_exist_inb.

  DATA: ts_source      LIKE LINE OF it_source,
        ts_source_copy LIKE LINE OF it_source,
        it_veh         TYPE TABLE OF ty_veh,
        it_veh_zbat    TYPE TABLE OF ty_veh,
        it_po          TYPE TABLE OF ty_po,
        ts_veh         TYPE ty_veh,
        ts_po          TYPE ty_po,
        it_komdlgn     TYPE TABLE OF komdlgn,
        ts_komdlgn     TYPE  komdlgn,
        it_kom         TYPE TABLE OF komdlgn,
        it_wueb        TYPE TABLE OF wueb,
        it_wueb_copy   TYPE TABLE OF wueb,
        ts_wueb        TYPE wueb,
        it_errors      TYPE TABLE OF wuebs,
        ts_lips_temp   TYPE lipsvb,
        ts_errors      TYPE wuebs,
        lv_error       TYPE boolean,
        ts_log         TYPE ty_log,
        lv_del_no      TYPE likp-vbeln,
        it_return      TYPE TABLE OF bapireturn,
        ts_return      TYPE bapireturn,
        lt_log_temp    TYPE TABLE OF ty_log,
        lv_vguid       TYPE vlc_guid,
        lv_vhcex       TYPE vlc_vhcex,
        lt_vhcex       TYPE TABLE OF vlc_vhcex,
        lt_exist_inb   TYPE TABLE OF ty_exist_inb,
        ls_exist_inb   TYPE ty_exist_inb,
        lv_verur       TYPE verur_vl,
        lt_verur       TYPE TABLE OF verur_vl.
  DATA: ts_vlcdiavehi_fm   TYPE vlcdiavehi,
        lt_vlcdiavehi_fm   TYPE vlcdiavehi_t,
        ts_actdata_item_fm TYPE vlcactdata_item_s,
        lt_actdata_item_fm TYPE vlcactdata_item_t,
        ts_vlcactdata      TYPE vlcactdata,
        ts_fm_message      TYPE vlch_mssg_ps,
        lt_fm_message      TYPE vlch_mssg_pt.
  CLEAR:         it_log.

  DATA : mr_log TYPE REF TO zvss_ifm_cl_x_log.
  CHECK it_source IS NOT INITIAL.

  CLEAR: lt_vhcex.
  LOOP AT it_source INTO ts_source.
    lv_vhcex = ts_source-ord_no.
    APPEND lv_vhcex TO lt_vhcex.
  ENDLOOP.


  IF lt_vhcex IS NOT INITIAL.
    SELECT *  FROM vlcvehicle INTO TABLE @DATA(lt_vehicle)
       FOR ALL ENTRIES IN @lt_vhcex
        WHERE vhcex EQ @lt_vhcex-table_line.

    IF lt_vehicle IS NOT INITIAL.

      SELECT * FROM vlcporder INTO TABLE @DATA(lt_vlcporder)
         FOR ALL ENTRIES IN @lt_vehicle
          WHERE vguid EQ @lt_vehicle-vguid.

    ENDIF.
  ENDIF.

  LOOP AT it_source INTO ts_source.

    CONSTANTS:
      lc_ctrl_object TYPE /dbe/ctrl_object VALUE '/DBE/V_ACT_CREATE'.

    DATA: lv_vguid_v              TYPE vlc_guid,
          ls_model                TYPE /dbe/v_model,
          ls_vlcactdata_head      TYPE vlcactdata_head_s,
          ls_vlcactdata_item      TYPE vlcactdata_item_s,
          lt_vlcadddata           TYPE vlcadddata_item_t,
          lv_category_id          TYPE comt_category_id VALUE 'DBM_PASSENGERCAR',
          ls_iobj_data_single_com TYPE /dbe/iobj_data_single_com_s,
          ls_iobj_data_multi_com  TYPE /dbe/iobj_data_multi_com_s,
          lv_action               TYPE vlc_action,
          lv_ctrl_value           TYPE /dbe/ctrl_value,
          lt_return               TYPE bapiret2_t,
          lo_ex                   TYPE REF TO zcx_error,
          ls_vlcdiavehi           TYPE vlcdiavehi.

    DATA : lv_bapi_po_number TYPE bapimepoheader-po_number,
           ls_bapi_header    TYPE bapimepoheader,
           ls_bapi_headerx   TYPE bapimepoheaderx,
           lt_bapi_item      TYPE STANDARD TABLE OF bapimepoitem,
           ls_bapi_item      TYPE bapimepoitem,
           lt_bapi_itemx     TYPE STANDARD TABLE OF bapimepoitemx,
           ls_bapi_itemx     TYPE bapimepoitemx,
           lt_bapi_schedule  TYPE STANDARD TABLE OF bapimeposchedule,
           ls_bapi_schedule  TYPE bapimeposchedule,
           lt_bapi_schedulex TYPE STANDARD TABLE OF bapimeposchedulx,
           ls_bapi_schedulex TYPE bapimeposchedulx,
           lt_bapi_partner   TYPE STANDARD TABLE OF bapiekkop,
           ls_bapi_partner   TYPE bapiekkop,
           lt_bapi_return    TYPE STANDARD TABLE OF bapiret2,
           ls_bapi_return    TYPE bapiret2,
           lt_pocond         TYPE STANDARD TABLE OF  bapimepocond,
           ls_pocond         TYPE bapimepocond,
           lt_pocondx        TYPE STANDARD TABLE OF  bapimepocondx,
           ls_pocondx        TYPE bapimepocondx,
           lt_options        TYPE STANDARD TABLE OF /dbe/v_ioption_dynp,
           ls_options        TYPE /dbe/v_ioption_dynp.
    DATA : lv_item TYPE i.

    IF rb_veh EQ 'X'.
      READ TABLE lt_vehicle INTO DATA(ls_vehicle) WITH KEY vhcex = ts_source-ord_no.
      IF sy-subrc NE 0.

        SELECT SINGLE * FROM /dbe/v_model INTO ls_model WHERE mcodesd EQ ts_source-model.
        IF sy-subrc EQ 0.
          ls_vlcactdata_head-/dbe/bustype = 'NEC'.
          ls_vlcactdata_head-werks = ts_source-plant.
          ls_vlcactdata_head-spart = ts_source-division.
          ls_vlcactdata_head-/dbe/spart = ls_vlcactdata_head-spart.
          ls_vlcactdata_item-/dbe/spart = ls_vlcactdata_head-spart.
          ls_vlcactdata_head-matnr = ls_model-matnr.

          ls_vlcactdata_item-vhcex = ts_source-ord_no..
*          ls_vlcactdata_item-vhvin = ms_data-rbuakern-chassis_nr.

          ls_iobj_data_single_com-/dbe/v_imodel-modguid = ls_model-model_guid.
          ls_iobj_data_single_com-/dbe/v_imodel-mcodesd = ls_model-mcodesd.

          SELECT SINGLE * FROM /dbe/v_moptions INTO @DATA(lv_opt_guid)
             WHERE model_guid EQ @ls_model-model_guid AND opclass EQ 'C' AND optyp EQ  'CLR' AND
              opkey EQ @ts_source-exterior.
          IF sy-subrc EQ 0.
            ls_options-opclass = 'C'.
            ls_options-opkey = ts_source-exterior.
            ls_options-optyp = 'CLR'.
            ls_options-opmatnr = lv_opt_guid-matnr.
            ls_options-opguid = lv_opt_guid-option_guid.
            APPEND ls_options TO lt_options.
            CLEAR ls_options.
          ENDIF.


          CONCATENATE '0' ts_source-interior INTO ts_source-interior.

          SELECT SINGLE * FROM /dbe/v_moptions INTO @lv_opt_guid
             WHERE model_guid EQ @ls_model-model_guid AND opclass EQ 'I' AND optyp EQ  'UPH' AND
              opkey EQ @ts_source-interior.
          IF sy-subrc EQ 0.
            ls_options-opclass = 'I'.
            ls_options-opkey = ts_source-interior.
            ls_options-optyp = 'UPH'.
            ls_options-opmatnr = lv_opt_guid-matnr.
            ls_options-opguid = lv_opt_guid-option_guid.
            APPEND ls_options TO lt_options.
            CLEAR ls_options.
          ENDIF.
          ls_iobj_data_multi_com-/dbe/v_ioption[] = lt_options[].
          REFRESH lt_options.

*--------------------------------------------------------------------*
*   refresh
          CALL FUNCTION '/DBE/VM01_VEHICLE_REFRESH'.

*--------------------------------------------------------------------*
*   get generic CREATE action (usually QVCR)
          CLEAR lt_return.
          CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
            EXPORTING
              object               = lc_ctrl_object
            IMPORTING
              value                = lv_ctrl_value
            EXCEPTIONS
              object_not_defined   = 1
              value_not_maintained = 2
              OTHERS               = 3.
          IF sy-subrc <> 0.
*            MESSAGE e012(zmsg_vss01) WITH lc_ctrl_object INTO zcx_error=>mv_dummy.
*            zcx_error=>raise_sy_msg( ).
          ENDIF.

          lv_action = lv_ctrl_value.
*--------------------------------------------------------------------*
*   vehicle set
          CLEAR lt_return.
          CALL FUNCTION '/DBE/VM01_VEHICLE_SET'
            EXPORTING
              iv_iobj_catid           = lv_category_id
              is_iobj_data_single_com = ls_iobj_data_single_com
              is_iobj_data_multi_com  = ls_iobj_data_multi_com
              iv_action               = lv_action
              is_vlcactdata_head      = ls_vlcactdata_head
              is_vlcactdata_item      = ls_vlcactdata_item
              it_vlcadddata           = lt_vlcadddata
            IMPORTING
              et_bapireturn           = lt_return
*             ev_iobj_catid           =
            EXCEPTIONS
              error_iobject           = 1
              error_badi              = 2
              error_vms               = 3
              OTHERS                  = 4.
          IF sy-subrc <> 0." OR
*           zcx_error=>contain_error( lt_return ) = abap_true.
*            CREATE OBJECT lo_ex.
*            lo_ex->append_bapi_msgs( lt_return ).
*            RAISE EXCEPTION lo_ex.
          ENDIF.

*          mr_log->add_msg_from_bapiret( it_bapiret = lt_return ).

*--------------------------------------------------------------------*
*   vehicle save
          CLEAR lt_return.
          CALL FUNCTION '/DBE/VM01_VEHICLE_SAVE'
            EXPORTING
              iv_action           = lv_action
              iv_dialogue_allowed = abap_false
            IMPORTING
              ev_vguid            = lv_vguid
              et_bapireturn       = lt_return
            EXCEPTIONS
              error_iobj_save     = 1
              error_vms_save      = 2
              error_vehicle_get   = 3
              error_vehicle_set   = 4
              error_badi          = 5
              OTHERS              = 6.
          IF sy-subrc <> 0. " OR
*           zcx_error=>contain_error( lt_return ) = abap_true.
*            CREATE OBJECT lo_ex.
*            lo_ex->append_bapi_msgs( lt_return ).
*            RAISE EXCEPTION lo_ex.
          ENDIF.

*   VDIT51: Vehicle master has been created (Commission no/external no: &1).
*          MESSAGE s013(zmsg_vss01) WITH ls_vlcactdata_item-vhcex INTO zcx_error=>mv_dummy.
*          mr_log->add_msg( ).

*--------------------------------------------------------------------*
*   return vhcex
*          rv_vhcex = ls_vlcactdata_item-vhcex.

*--------------------------------------------------------------------*
*   refresh
*          CALL FUNCTION '/DBM/VM01_VEHICLE_REFRESH'.
          IF lv_vguid IS NOT INITIAL.
            CLEAR ts_log.
            READ TABLE lt_return INTO ts_return WITH KEY type = 'S' id = 'VELO' number = '317'.
            MESSAGE e015(zmsg_vss01) WITH ts_source-ord_no ts_return-message_v2 INTO ts_log-long_text.
            ts_log-message = gc_success.
            ts_log-vhcex =  ts_source-ord_no.
            APPEND ts_log TO it_log.
          ENDIF.

        ELSE.
          CLEAR ts_log.
          READ TABLE lt_return INTO ts_return WITH KEY type = 'S' id = 'VELO' number = '317'.
          MESSAGE e018(zmsg_vss01) WITH ts_source-model INTO ts_log-long_text.
          ts_log-message = gc_error.
          ts_log-vhcex =  ts_source-ord_no.
          APPEND ts_log TO it_log.
        ENDIF.



      ELSE.
        "ERROR
        CLEAR ts_log.
        MESSAGE e014(zmsg_vss01) WITH ts_source-ord_no ls_vehicle-vhcle INTO ts_log-long_text.
        ts_log-message = gc_error.
        ts_log-vhcex =  ts_source-ord_no.
        APPEND ts_log TO it_log.
      ENDIF.
    ELSEIF rb_po EQ 'X'.
      READ TABLE lt_vehicle INTO ls_vehicle WITH KEY vhcex = ts_source-ord_no.
      IF sy-subrc EQ 0.
        READ TABLE lt_vlcporder INTO DATA(ls_vlcporder) WITH KEY vguid = ls_vehicle-vguid.
        IF sy-subrc NE 0.

          lv_action = 'QORD'.
          ls_bapi_header-vendor     = ts_source-vendor.
          ls_bapi_header-purch_org  = ts_source-pur_org.
          ls_bapi_header-pur_group  = ts_source-pur_grp.
          ls_bapi_header-comp_code  = ts_source-company.
          ls_bapi_header-doc_type   = 'YVPO'.
          ls_bapi_header-doc_date   = sy-datum.

          ls_bapi_headerx-vendor     = 'X'.
          ls_bapi_headerx-purch_org  = 'X'.
          ls_bapi_headerx-pur_group  = 'X'.
          ls_bapi_headerx-comp_code  = 'X'.
          ls_bapi_headerx-doc_type   = 'X'.
          ls_bapi_headerx-doc_date   = 'X'.

          lv_item = lv_item + 1.
          ls_bapi_item-po_item = lv_item.
          ls_bapi_item-material = ts_source-model.
          ls_bapi_item-quantity = 1.
          ls_bapi_item-po_unit = 'EA'.
          ls_bapi_item-plant = ts_source-plant.
          ls_bapi_item-stge_loc = 'V001'.
          ls_bapi_item-batch = ls_vehicle-vhcle.
          ls_bapi_item-val_type = ls_vehicle-vhcle.
          APPEND ls_bapi_item TO lt_bapi_item.

          ls_bapi_itemx-po_item = lv_item.
          ls_bapi_itemx-po_itemx = 'X'.
          ls_bapi_itemx-material = 'X'.
          ls_bapi_itemx-quantity = 'X'.
          ls_bapi_itemx-po_unit = 'X'.
          ls_bapi_itemx-plant = 'X'.
          ls_bapi_itemx-stge_loc = 'X'.
          ls_bapi_itemx-batch = 'X'.
          ls_bapi_itemx-val_type = 'X'.
          APPEND ls_bapi_itemx TO lt_bapi_itemx.



          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'YV01'.
          ls_pocond-cond_value = ts_source-yv01.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.
          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y100'.
          ls_pocond-cond_value = ts_source-y100.
          ls_pocond-currency = '%'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y101'.
          ls_pocond-cond_value = ts_source-y101.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
          ls_pocondx-cond_p_unt = 'X'.
*        ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR  ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y102'.
          ls_pocond-cond_value = ts_source-y102.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y103'.
          ls_pocond-cond_value = ts_source-y103.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y104'.
          ls_pocond-cond_value = ts_source-y104.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y105'.
          ls_pocond-cond_value = ts_source-y105.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y106'.
          ls_pocond-cond_value = ts_source-y106.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y107'.
          ls_pocond-cond_value = ts_source-y107.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y108'.
          ls_pocond-cond_value = ts_source-y108.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y109'.
          ls_pocond-cond_value = ts_source-y109.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y110'.
          ls_pocond-cond_value = ts_source-y110.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y111'.
          ls_pocond-cond_value = ts_source-y111.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y112'.
          ls_pocond-cond_value = ts_source-y112.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          ls_pocond-itm_number = lv_item.
          ls_pocond-cond_type = 'Y113'.
          ls_pocond-cond_value = ts_source-y113.
          ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          APPEND ls_pocond TO lt_pocond.
          CLEAR ls_pocond.

          ls_pocondx-itm_number = lv_item.
          ls_pocondx-itm_numberx = 'X'.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.
          CLEAR ls_pocondx.

          AT LAST.

            CLEAR: lt_bapi_return.
            CALL FUNCTION 'BAPI_PO_CREATE1'
              EXPORTING
                poheader         = ls_bapi_header
                poheaderx        = ls_bapi_headerx
              IMPORTING
                exppurchaseorder = lv_bapi_po_number
              TABLES
                return           = lt_bapi_return
                poitem           = lt_bapi_item
                poitemx          = lt_bapi_itemx
                poschedule       = lt_bapi_schedule
                poschedulex      = lt_bapi_schedulex
                pocond           = lt_pocond
                pocondx          = lt_pocondx
                popartner        = lt_bapi_partner.

            IF lv_bapi_po_number IS NOT INITIAL.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = 'X'.

              DATA: lt_vlchistory TYPE STANDARD TABLE OF  vlchistory,
                    ls_vlchistory TYPE vlchistory,
                    lt_vlcorder   TYPE STANDARD TABLE OF  vlcporder,
                    ls_vlcorder   TYPE vlcporder.




              LOOP AT it_source INTO ts_source.
                READ TABLE lt_vehicle INTO ls_vehicle WITH KEY vhcex = ts_source-ord_no.
                IF sy-subrc EQ 0.
                  READ TABLE lt_bapi_item INTO ls_bapi_item WITH KEY batch = ls_vehicle-vhcle.
                  IF sy-subrc EQ 0.
                    CLEAR ts_log.
                    READ TABLE lt_return INTO ts_return WITH KEY type = 'S' id = 'VELO' number = '317'.
                    MESSAGE e016(zmsg_vss01) WITH ts_source-ord_no ts_return-message_v2 INTO ts_log-long_text.
                    ts_log-message = gc_success.
                    ts_log-vhcex =  ts_source-ord_no.
                    ts_log-po = lv_bapi_po_number.
                    ts_log-po_item = ls_bapi_item-po_item.
                    APPEND ts_log TO it_log.

                    UPDATE vlcvehicle SET  mmsta = 'QP30' WHERE vguid EQ ls_vehicle-vguid.
                    IF sy-subrc EQ 0.
                      COMMIT WORK.
                    ENDIF.

                    CLEAR: ls_vlchistory.
                    GET TIME STAMP FIELD ls_vlchistory-tstmp.
                    ls_vlchistory-vguid = ls_vehicle-vguid.
                    ls_vlchistory-actdoctype = 'QORD'.
                    ls_vlchistory-action = 'QORD'.

                    ls_vlchistory-cuobj = ls_vehicle-cuobj.
                    ls_vlchistory-mmctr = ls_vehicle-mmctr.
                    ls_vlchistory-mmsta_old = ls_vehicle-mmsta.
                    ls_vlchistory-mmsta_new = ls_vehicle-mmsta.
                    ls_vlchistory-sdctr = ls_vehicle-sdctr.
                    ls_vlchistory-sdsta_old = ls_vehicle-sdsta.
                    ls_vlchistory-sdsta_new = ls_vehicle-sdsta.
                    ls_vlchistory-kunnr = ls_vehicle-kunnr.
                    ls_vlchistory-ernam = sy-uname.
                    ls_vlchistory-/dbe/bustype = ls_vehicle-/dbe/bustype.
                    APPEND ls_vlchistory TO lt_vlchistory.


                    CLEAR ls_vlcporder.
                    ls_vlcporder-vguid = ls_vehicle-vguid.
                    ls_vlcporder-tstmp = ls_vlchistory-tstmp.
                    ls_vlcporder-actdoctype = 'QORD'.
                    ls_vlcporder-ebeln = lv_bapi_po_number.
                    ls_vlcporder-ebelp = ls_bapi_item-po_item.
                    ls_vlcporder-ernam = sy-uname.
                    APPEND ls_vlcporder TO lt_vlcporder.
                  ENDIF.
                ENDIF.
              ENDLOOP.
              MODIFY vlchistory FROM TABLE lt_vlchistory.
              MODIFY vlcporder FROM TABLE lt_vlcporder.
            ELSE.


            ENDIF.

          ENDAT.
        ELSE.
          MESSAGE e017(zmsg_vss01) WITH ts_source-ord_no  ls_vlcporder-ebeln ls_vlcporder-ebelp INTO ts_log-long_text.
          ts_log-message = gc_error.
          ts_log-vhcex =  ts_source-ord_no.
          ts_log-po = ls_vlcporder-ebeln.
          ts_log-po_item = ls_vlcporder-ebelp.
          APPEND ts_log TO it_log.
        ENDIF.
      ENDIF.
    ELSEIF rb_chk EQ 'X'.

      READ TABLE lt_vehicle INTO ls_vehicle WITH KEY vhcex = ts_source-ord_no.
      IF sy-subrc EQ 0.

        CALL FUNCTION 'BAPI_PO_GETDETAIL1'
          EXPORTING
            purchaseorder = ts_source-ord_no
*           ACCOUNT_ASSIGNMENT       = ' '
*           ITEM_TEXT     = ' '
*           HEADER_TEXT   = ' '
*           DELIVERY_ADDRESS         = ' '
*           VERSION       = ' '
*           SERVICES      = ' '
*           SERIALNUMBERS = ' '
*           INVOICEPLAN   = ' '
*     IMPORTING
*           POHEADER      =
*           POEXPIMPHEADER           =
          TABLES
*           RETURN        =
            poitem        = lt_bapi_item
*           POADDRDELIVERY           =
*           POSCHEDULE    =
*           POACCOUNT     =
*           POCONDHEADER  =
            pocond        = lt_pocond
*           POLIMITS      =
*           POCONTRACTLIMITS         =
*           POSERVICES    =
*           POSRVACCESSVALUES        =
*           POTEXTHEADER  =
*           POTEXTITEM    =
*           POEXPIMPITEM  =
*           POCOMPONENTS  =
*           POSHIPPINGEXP =
*           POHISTORY     =
*           POHISTORY_TOTALS         =
*           POCONFIRMATION           =
*           ALLVERSIONS   =
*           POPARTNER     =
*           EXTENSIONOUT  =
*           SERIALNUMBER  =
*           INVPLANHEADER =
*           INVPLANITEM   =
*           POHISTORY_MA  =
          .

      ENDIF.

    ELSEIF rb_upd EQ 'X'.
      READ TABLE lt_vehicle INTO ls_vehicle WITH KEY vhcex = ts_source-ord_no.
      IF sy-subrc EQ 0.
        READ TABLE lt_vlcporder INTO ls_vlcporder WITH KEY vguid = ls_vehicle-vguid.
        IF sy-subrc EQ 0.
          IF ls_vlcporder-xgore EQ 'X' OR ls_vlcporder-xiniv EQ 'X'.
            CLEAR ts_log.
            MESSAGE e019(zmsg_vss01)  INTO ts_log-long_text.
            ts_log-message = gc_error.
            ts_log-vhcex =  ts_source-ord_no.
            ts_log-po = ls_vlcporder-ebeln.
            ts_log-po_item = ls_vlcporder-ebelp.
            APPEND ts_log TO it_log.
          ELSE.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'YV01'.
            ls_pocond-cond_value = ts_source-yv01.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.
            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y100'.
            ls_pocond-cond_value = ts_source-y100.
            ls_pocond-currency = '%'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y101'.
            ls_pocond-cond_value = ts_source-y101.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
            ls_pocondx-cond_p_unt = 'X'.
*        ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR  ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y102'.
            ls_pocond-cond_value = ts_source-y102.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y103'.
            ls_pocond-cond_value = ts_source-y103.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y104'.
            ls_pocond-cond_value = ts_source-y104.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y105'.
            ls_pocond-cond_value = ts_source-y105.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y106'.
            ls_pocond-cond_value = ts_source-y106.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y107'.
            ls_pocond-cond_value = ts_source-y107.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y108'.
            ls_pocond-cond_value = ts_source-y108.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y109'.
            ls_pocond-cond_value = ts_source-y109.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y110'.
            ls_pocond-cond_value = ts_source-y110.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y111'.
            ls_pocond-cond_value = ts_source-y111.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y112'.
            ls_pocond-cond_value = ts_source-y112.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y113'.
            ls_pocond-cond_value = ts_source-y113.
            ls_pocond-currency = 'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            CALL FUNCTION 'BAPI_PO_CHANGE'
              EXPORTING
                purchaseorder = ls_vlcporder-ebeln
              TABLES
                return        = lt_bapi_return
                pocond        = lt_pocond
                pocondx       = lt_pocondx.

            READ TABLE lt_bapi_return INTO ls_bapi_return WITH KEY type = 'S'.
            IF sy-subrc EQ 0.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = 'X'.

              CLEAR ts_log.
              MESSAGE e020(zmsg_vss01)  INTO ts_log-long_text.
              ts_log-message = gc_success.
              ts_log-vhcex =  ts_source-ord_no.
              ts_log-po = ls_vlcporder-ebeln.
              ts_log-po_item = ls_vlcporder-ebelp.
              APPEND ts_log TO it_log.

            ENDIF.
            REFRESH : lt_pocond, lt_pocondx, lt_bapi_return.

          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.


  va_total_records = lines( it_log ).
  lt_log_temp = it_log.
  DELETE lt_log_temp WHERE message EQ gc_success.   "to find no of error records.
  va_fail_records = lines( lt_log_temp ).
  va_succ_records = va_total_records - va_fail_records.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_ALPHA_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TS_WUEB_EBELN  text
*      <--P_TS_SOURCE_COPY_EBELN  text
*----------------------------------------------------------------------*
FORM form_alpha_input  USING    p_input
                       CHANGING p_output.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_input
    IMPORTING
      output = p_output.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FORM_SERVR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_servr_log USING p_mtype TYPE char07.
  CONSTANTS: lc_dot           TYPE char01 VALUE '.',
             lc_underscore    TYPE char01 VALUE '_',
             lc_pattern       TYPE string VALUE '(.*)(\.{1}(?:csv|txt){1})$', " end with extension
             lc_last_f_sls    TYPE string VALUE '.*/$', "end with /
             lc_not_full_path TYPE string VALUE '(\.\w+)?$'.
  DATA : ts_data                TYPE  string,
         lv_path                TYPE  rcgfiletr-ftappl,
         ts_log                 TYPE  ty_log,
         lv_extension           TYPE  char5,
         ts_result              TYPE  match_result,
         lv_offset              TYPE  i,
         lv_file                TYPE localfile,
         lv_sub_path_file       TYPE string,
         lv_sub_path_extension  TYPE string,
         lv_user_path           TYPE string,
         lt_result_tab          TYPE match_result_tab,
         ts_submatch_result_tab TYPE match_result,
         lv_ext_tmp             TYPE string,
         lv_file_1              TYPE string.

  CLEAR: lv_path, ts_result, lv_offset, lv_extension,lv_user_path.
  lv_file = COND #( WHEN p_mtype EQ gc_error THEN p_error ELSE p_succ ).

  "copy path to local variable type string to omit succedding string space.
  lv_user_path = lv_file.
  CHECK lv_file IS NOT INITIAL.
  CALL METHOD zcl_common_util=>get_path_params
    EXPORTING
      iv_path      = lv_file
    IMPORTING
      ev_directory = lv_sub_path_file
      ev_file_name = lv_file_1
      ev_extension = lv_sub_path_extension.

  CONCATENATE lv_sub_path_file lv_file_1 TEXT-001 lc_underscore
              sy-datum sy-uzeit lv_sub_path_extension INTO lv_path.
  OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc IS INITIAL.
    CONCATENATE gc_message TEXT-017 TEXT-011 TEXT-010 INTO ts_data.
    TRANSFER ts_data TO lv_path.
    LOOP AT it_log INTO ts_log WHERE message EQ p_mtype.
      ts_data = ts_log.
      TRANSFER ts_data TO lv_path.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDLOOP.
    CLOSE DATASET lv_path.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_log.
*write error log
  PERFORM form_servr_log USING gc_error.
*write success log
  PERFORM form_servr_log USING gc_success.
*ALV
  PERFORM form_display_alv.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_display_alv .
  " LOCAL TABLES Declaration
  DATA  it_fcat    TYPE TABLE OF  slis_fieldcat_alv.
  " LOCAL WORK AREAS Declaration
  DATA: ts_fcat   TYPE        slis_fieldcat_alv,
        ts_layout TYPE        slis_layout_alv.
  DATA : lv_top TYPE slis_formname VALUE 'F_ALV_HEADER'.

*Field Catalog
  CLEAR ts_fcat.
  ts_fcat-fieldname = gc_message.
  ts_fcat-tabname   = gc_it_source.
  ts_fcat-outputlen   = 07.
  ts_fcat-seltext_l   = TEXT-009.
  APPEND ts_fcat TO it_fcat.

*  CLEAR ts_fcat.
*  ts_fcat-fieldname = gc_verur.
*  ts_fcat-tabname   = gc_it_source.
*  ts_fcat-outputlen   = 015.
*  ts_fcat-seltext_l   = TEXT-017.
*  APPEND ts_fcat TO it_fcat.


  CLEAR ts_fcat.
  ts_fcat-fieldname = gc_vhcex.
  ts_fcat-tabname   = gc_it_source.
  ts_fcat-outputlen   = 10.
  ts_fcat-seltext_l   = TEXT-011.
  APPEND ts_fcat TO it_fcat.


  CLEAR ts_fcat.
  ts_fcat-fieldname = gc_po.
  ts_fcat-tabname   = gc_it_source.
  ts_fcat-outputlen   = 10.
  ts_fcat-seltext_l   = TEXT-024.
  APPEND ts_fcat TO it_fcat.


  CLEAR ts_fcat.
  ts_fcat-fieldname = gc_po_item.
  ts_fcat-tabname   = gc_it_source.
  ts_fcat-outputlen   = 10.
  ts_fcat-seltext_l   = TEXT-025.
  APPEND ts_fcat TO it_fcat.

  CLEAR ts_fcat.
  ts_fcat-fieldname = gc_long_text.
  ts_fcat-tabname   = gc_it_source.
  ts_fcat-outputlen   = 60.
  ts_fcat-seltext_l   = TEXT-010.
  APPEND ts_fcat TO it_fcat.
  " Setting Layout for the Alv.
  ts_layout-zebra             = abap_true.
  ts_layout-colwidth_optimize = abap_true.

  IF it_log IS NOT INITIAL.
*    SORT it_log BY identifiers.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program     = sy-cprog
        i_callback_top_of_page = lv_top
        is_layout              = ts_layout
        it_fieldcat            = it_fcat
      TABLES
        t_outtab               = it_log
      EXCEPTIONS
        program_error          = 1
        OTHERS                 = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_ALV_HEADER
*&---------------------------------------------------------------------*
* To Display Success and error records (top_of_page)
*----------------------------------------------------------------------*
FORM f_alv_header ##called.

  " LOCAL TABLES Declaration
  DATA  lt_head      TYPE STANDARD TABLE OF slis_listheader.
  " LOCAL WORK AREAS Declaration
  DATA  lw_head      TYPE slis_listheader.

  CONSTANTS: lc_head TYPE c VALUE  'H',
             lc_sel  TYPE c VALUE  'S'.

  lw_head-typ  = lc_head.
  lw_head-info = TEXT-019.
  APPEND lw_head TO  lt_head.
  CLEAR lw_head.

  " Record count for ALV header display
  lw_head-typ  = lc_sel.
  CONCATENATE TEXT-020
              va_total_records      INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR lw_head.

  lw_head-typ  = lc_sel.
  CONCATENATE TEXT-021
              va_succ_records    INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR lw_head.

  lw_head-typ  = lc_sel.
  CONCATENATE TEXT-022
              va_fail_records     INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR lw_head.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_head.
ENDFORM           ##called.                    " F_ALV_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_LOG_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_log_path .
  DATA : lv_succ_directory  TYPE string,
         lv_error_directory TYPE string.
  IF p_succ IS NOT INITIAL.
    CALL METHOD zcl_common_util=>get_path_params
      EXPORTING
        iv_path      = p_succ
      IMPORTING
        ev_directory = lv_succ_directory.
    OPEN DATASET lv_succ_directory FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc  <> 0.
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  027
*              WITH    TEXT-l10.
    ENDIF.
    CLOSE DATASET lv_succ_directory.
  ENDIF.
  IF p_error IS NOT INITIAL.
    CALL METHOD zcl_common_util=>get_path_params
      EXPORTING
        iv_path      = p_error
      IMPORTING
        ev_directory = lv_error_directory.

    OPEN DATASET lv_error_directory FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc  <> 0.
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  027
*              WITH    TEXT-l11.
    ENDIF.
    CLOSE DATASET lv_error_directory.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_REPLACE_JUNK_FROM_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TS_SOURCE  text
*----------------------------------------------------------------------*
FORM f_replace_junk_from_no  CHANGING cv_number.

  REPLACE ALL OCCURRENCES OF ',' IN cv_number WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN cv_number WITH ''.
  CONDENSE cv_number NO-GAPS.
ENDFORM.

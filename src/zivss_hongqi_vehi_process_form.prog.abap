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
  CLEAR ls_source_ven.
  READ TABLE it_data_tab INTO ts_data_tab INDEX 3.
  IF sy-subrc EQ 0.
    SPLIT ts_data_tab AT p_file_sep
  INTO ls_source_ven-ord_no
ls_source_ven-model
ls_source_ven-modyear
ls_source_ven-exterior
ls_source_ven-interior
ls_source_ven-company
ls_source_ven-pur_org
ls_source_ven-pur_grp
ls_source_ven-plant
ls_source_ven-division
ls_source_ven-vendor
ls_source_ven-yv01
ls_source_ven-y100
ls_source_ven-y101
ls_source_ven-y102
ls_source_ven-y103
ls_source_ven-y104
ls_source_ven-y105
ls_source_ven-y106
ls_source_ven-y107
ls_source_ven-y108
ls_source_ven-y109
ls_source_ven-y110
ls_source_ven-y111
ls_source_ven-y112
ls_source_ven-y113
ls_source_ven-y114
ls_source_ven-y115
ls_source_ven-y116.
  ENDIF.
  CLEAR ls_source_cur.
  READ TABLE it_data_tab INTO ts_data_tab INDEX 4.
  IF sy-subrc EQ 0.
    SPLIT ts_data_tab AT p_file_sep
  INTO ls_source_cur-ord_no
ls_source_cur-model
ls_source_cur-modyear
ls_source_cur-exterior
ls_source_cur-interior
ls_source_cur-company
ls_source_cur-pur_org
ls_source_cur-pur_grp
ls_source_cur-plant
ls_source_cur-division
ls_source_cur-vendor
ls_source_cur-yv01
ls_source_cur-y100
ls_source_cur-y101
ls_source_cur-y102
ls_source_cur-y103
ls_source_cur-y104
ls_source_cur-y105
ls_source_cur-y106
ls_source_cur-y107
ls_source_cur-y108
ls_source_cur-y109
ls_source_cur-y110
ls_source_cur-y111
ls_source_cur-y112
ls_source_cur-y113
ls_source_cur-y114
ls_source_cur-y115
ls_source_cur-y116.

  ENDIF.

  CLEAR it_source.
  LOOP AT it_data_tab INTO ts_data_tab FROM 5.
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
ts_source-modyear
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
ts_source-y113
ts_source-y114
ts_source-y115
ts_source-y116.

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
        ls_return               TYPE bapiret2,
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
         lt_pocond_u       TYPE STANDARD TABLE OF  bapimepocond,
         ls_pocond         TYPE bapimepocond,
         lt_pocondx        TYPE STANDARD TABLE OF  bapimepocondx,
         ls_pocondx        TYPE bapimepocondx,
         lt_options        TYPE STANDARD TABLE OF /dbe/v_ioption_dynp,
         ls_options        TYPE /dbe/v_ioption_dynp,
         lt_optionst       TYPE STANDARD TABLE OF /dbe/v_ioptiont_dynp,
         ls_optionst       TYPE /dbe/v_ioptiont_dynp.
  DATA : lv_item TYPE i.


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
          WHERE vguid EQ @lt_vehicle-vguid AND
                actdoctype EQ 'QORD'.

    ENDIF.
  ENDIF.


  READ TABLE lt_vlcporder INTO DATA(ls_vlcporder_n) INDEX 1.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_PO_GETDETAIL1'
      EXPORTING
        purchaseorder = ls_vlcporder_n-ebeln
      TABLES
        poitem        = lt_bapi_item
        pocond        = lt_pocond.
  ENDIF.


  LOOP AT it_source INTO ts_source.

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
          ls_iobj_data_single_com-/dbe/v_imodel-modyear = ts_source-modyear.
          IF ts_source-division EQ '13'.
            DATA(lv_len) = strlen( ts_source-exterior ).
            IF lv_len EQ 2.
              CONCATENATE '0' ts_source-exterior INTO ts_source-exterior.
            ELSEIF lv_len EQ 1.
              CONCATENATE '00' ts_source-exterior INTO ts_source-exterior.
            ENDIF.
          ENDIF.

          SELECT SINGLE * FROM /dbe/v_moptions INTO @DATA(lv_opt_guid)
             WHERE model_guid EQ @ls_model-model_guid AND opclass EQ 'C' AND optyp EQ  'CLR' AND
              opkey EQ @ts_source-exterior.
          IF sy-subrc EQ 0.
            SELECT SINGLE * FROM /dbe/v_moptionst INTO @DATA(lv_opt_text) WHERE option_guid EQ @lv_opt_guid-option_guid.
            ls_options-opclass = 'C'.
            ls_options-opkey = ts_source-exterior.
            ls_options-optyp = 'CLR'.
            ls_options-opmatnr = lv_opt_guid-matnr.
            ls_options-opguid = lv_opt_guid-option_guid.
            ls_options-mmnoord = 'X'.
*            ls_options-opkey_desc = lv_opt_text-optext1.
*            ls_options-optyp_desc = lv_opt_text-optext1.
            APPEND ls_options TO lt_options.
            CLEAR ls_options.
            ls_optionst-opkey = ts_source-exterior.
            ls_optionst-opclass = 'C'.
            ls_optionst-oplangu = 'EN'.
            ls_optionst-optext1 = lv_opt_text-optext1.
            APPEND ls_optionst TO lt_optionst.
            CLEAR ls_optionst.
          ELSE.
            CONCATENATE 'Exterior Color ' ts_source-exterior ' not available in ' ts_source-model INTO ts_log-long_text.
*            ts_log-long_text = ls_return-message.
            ts_log-message = gc_error.
            ts_log-vhcex =  ts_source-ord_no.
            APPEND ts_log TO it_log.
            CLEAR ts_log.
            CONTINUE.
          ENDIF.
          IF ts_source-division EQ '13'.
            lv_len = strlen( ts_source-interior ).
            IF lv_len EQ 2.
              CONCATENATE '0' ts_source-interior INTO ts_source-interior.
            ELSEIF lv_len EQ 1.
              CONCATENATE '00' ts_source-interior INTO ts_source-interior.
            ENDIF.
          ENDIF.

          SELECT SINGLE * FROM /dbe/v_moptions INTO @lv_opt_guid
             WHERE model_guid EQ @ls_model-model_guid AND opclass EQ 'I' AND optyp EQ  'UPH' AND
              opkey EQ @ts_source-interior.
          IF sy-subrc EQ 0.
            SELECT SINGLE * FROM /dbe/v_moptionst INTO lv_opt_text WHERE option_guid EQ lv_opt_guid-option_guid.
            ls_options-opclass = 'I'.
            ls_options-opkey = ts_source-interior.
            ls_options-optyp = 'UPH'.
            ls_options-opmatnr = lv_opt_guid-matnr.
            ls_options-opguid = lv_opt_guid-option_guid.
            ls_options-mmnoord = 'X'.
*            ls_options-opkey_desc = lv_opt_text-optext1.
*            ls_options-optyp_desc = lv_opt_text-optext1.
            APPEND ls_options TO lt_options.
            CLEAR ls_options.
            ls_optionst-opkey = ts_source-interior.
            ls_optionst-opclass = 'I'.
            ls_optionst-oplangu = 'EN'.
            ls_optionst-optext1 = lv_opt_text-optext1.
            APPEND ls_optionst TO lt_optionst.
            CLEAR ls_optionst.
          ELSE.
            CONCATENATE 'Interior Color ' ts_source-interior ' not available in ' ts_source-model INTO ts_log-long_text.
*            ts_log-long_text = ls_return-message.
            ts_log-message = gc_error.
            ts_log-vhcex =  ts_source-ord_no.
            APPEND ts_log TO it_log.
            CLEAR ts_log.
            CONTINUE.
          ENDIF.
          ls_iobj_data_multi_com-/dbe/v_ioption[] = lt_options[].
          REFRESH lt_options.
          ls_iobj_data_multi_com-/dbe/v_ioptiont[] = lt_optionst[].
          REFRESH lt_optionst.

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


*          ls_iobj_data_single_com-/dbe/v_imodel-modyear = ts_source-modyear.
*          mr_log->add_msg_from_bapiret( it_bapiret = lt_return ).
          READ TABLE lt_return INTO ls_return WITH  KEY type = 'E'.
          IF sy-subrc NE 0.
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
            READ TABLE lt_return INTO ls_return WITH  KEY type = 'E'.
            IF sy-subrc EQ 0.
              ts_log-long_text = ls_return-message.
              ts_log-message = gc_error.
              ts_log-vhcex =  ts_source-ord_no.
              APPEND ts_log TO it_log.
              CLEAR ts_log.
            ENDIF.
          ELSE.
            ts_log-long_text = ls_return-message.
            ts_log-message = gc_error.
            ts_log-vhcex =  ts_source-ord_no.
            APPEND ts_log TO it_log.
            CLEAR ts_log.
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
            SELECT SINGLE /dbe/iobjguid FROM vlcvehicle INTO @DATA(lv_prd_guid) WHERE vguid EQ @lv_vguid.
            IF sy-subrc EQ 0.
              UPDATE /dbe/v_imodel SET modyear = ts_source-modyear WHERE product_guid EQ lv_prd_guid.
            ENDIF.

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
      DATA: lv_tabix TYPE i.
      READ TABLE lt_vehicle INTO ls_vehicle WITH KEY vhcex = ts_source-ord_no.
      IF sy-subrc EQ 0.
        READ TABLE lt_vlcporder INTO DATA(ls_vlcporder) WITH KEY vguid = ls_vehicle-vguid.
        IF sy-subrc NE 0.

          lv_action = 'QORD'.
          ls_bapi_header-vendor     = ts_source-vendor.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_bapi_header-vendor
            IMPORTING
              output = ls_bapi_header-vendor.

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
          ls_pocond-currency = ls_source_cur-yv01.  "'USD'.
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
          ls_pocond-currency = ls_source_cur-y100.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y100 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y100.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y101.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y101 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y101.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y102.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y102 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y102.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y103.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y103 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y103.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y104.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y104 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y104.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y105.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y105 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y105.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y106.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y106 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y106.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y107.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y107 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y107.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y108.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y108 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y108.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y109.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y109 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y109.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y110.  "'USD'..
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y110 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y110.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y111.  "'USD'..
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y111 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y111.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y112.  "'USD'..
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y112 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y112.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-currency = ls_source_cur-y113.  "'USD'..
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y113 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y113.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-cond_type = 'Y114'.
          ls_pocond-cond_value = ts_source-y114.
          ls_pocond-currency = ls_source_cur-y114.  "'USD'..
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y114 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y114.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-cond_type = 'Y115'.
          ls_pocond-cond_value = ts_source-y115.
          ls_pocond-currency = ls_source_cur-y115.  "'USD'..
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y115 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y115.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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
          ls_pocond-cond_type = 'Y116'.
          ls_pocond-cond_value = ts_source-y116.
          ls_pocond-currency = ls_source_cur-y116.  "'USD'..
*        ls_pocond-cond_p_unt = 'EA'.
          ls_pocond-change_id = 'I'.
          IF ls_source_ven-y116 IS NOT INITIAL.
            ls_pocond-vendor_no = ls_source_ven-y116.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_pocond-vendor_no
              IMPORTING
                output = ls_pocond-vendor_no.
            ls_pocondx-vendor_no = 'X'.
          ENDIF.
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

              ts_log-message = gc_error.
              ts_log-vhcex =  ts_source-ord_no.
              ts_log-po = ls_vlcporder-ebeln.
              ts_log-po_item = ls_vlcporder-ebelp.
              LOOP AT lt_bapi_return INTO ls_bapi_return WHERE type EQ 'E'.
                IF ls_bapi_return-id NE 'BAPI' AND ls_bapi_return-id NE 'MEPO'.
                  IF ts_log-long_text IS INITIAL .
                    ts_log-long_text = ls_bapi_return-message.
                  ELSE.
                    CONCATENATE  ts_log-long_text ','  ls_bapi_return-message INTO ts_log-long_text.
                  ENDIF.
                ENDIF.
              ENDLOOP.
              APPEND ts_log TO it_log.
              CLEAR ts_log.

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
*      REFRESH:lt_bapi_item,lt_pocond.
      READ TABLE lt_vehicle INTO ls_vehicle WITH KEY vhcex = ts_source-ord_no.
      IF sy-subrc EQ 0.
        READ TABLE lt_vlcporder INTO ls_vlcporder WITH KEY vguid = ls_vehicle-vguid.
        IF sy-subrc EQ 0.
*          CALL FUNCTION 'BAPI_PO_GETDETAIL1'
*            EXPORTING
*              purchaseorder = ls_vlcporder-ebeln
*            TABLES
*              poitem        = lt_bapi_item
*              pocond        = lt_pocond.

          gs_final-ord_no   = ts_source-ord_no.
          gs_final-model    = ts_source-model.
          gs_final-exterior = ts_source-exterior.
          gs_final-interior = ts_source-interior.
          gs_final-company  = ts_source-company.
          gs_final-pur_org  = ts_source-pur_org.
          gs_final-pur_grp  = ts_source-pur_grp.
          gs_final-plant    = ts_source-plant.
          gs_final-division = ts_source-division.
          gs_final-vendor   = ts_source-vendor.

          READ TABLE lt_bapi_item INTO DATA(ls_item) WITH KEY batch = ls_vehicle-vhcle.

          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'YV01' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-yv01   = ceil( ls_pocond-cond_value ).
            gs_final-yv01_n = ts_source-yv01.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y100' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y100   = ceil( ls_pocond-cond_value ).
            gs_final-y100_n = ts_source-y100.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y101' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y101   = ceil( ls_pocond-cond_value ).
            gs_final-y101_n = ts_source-y101.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y102' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y102   = ceil( ls_pocond-cond_value ).
            gs_final-y102_n = ts_source-y102.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y103' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y103   = ceil( ls_pocond-cond_value ).
            gs_final-y103_n = ts_source-y103.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y104' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y104   = ceil( ls_pocond-cond_value ).
            gs_final-y104_n = ts_source-y104.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y105' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y105   = ceil( ls_pocond-cond_value ).
            gs_final-y105_n = ts_source-y105.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y106' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y106   = ceil( ls_pocond-cond_value ).
            gs_final-y106_n = ts_source-y106.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y107' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y107   = ceil( ls_pocond-cond_value ).
            gs_final-y107_n = ts_source-y107.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y108' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y108   = ceil( ls_pocond-cond_value ).
            gs_final-y108_n = ts_source-y108.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y109' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y109   = ceil( ls_pocond-cond_value ).
            gs_final-y109_n = ts_source-y109.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y110' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y110   = ceil( ls_pocond-cond_value ).
            gs_final-y110_n = ts_source-y110.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y111' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y111   = ceil( ls_pocond-cond_value ).
            gs_final-y111_n = ts_source-y111.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y112' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y112   = ceil( ls_pocond-cond_value ).
            gs_final-y112_n = ts_source-y112.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y113' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y113   = ceil( ls_pocond-cond_value ).
            gs_final-y113_n = ts_source-y113.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y114' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y114   = ceil( ls_pocond-cond_value ).
            gs_final-y114_n = ts_source-y114.
          ENDIF.
          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y115' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y115   = ceil( ls_pocond-cond_value ).
            gs_final-y115_n = ts_source-y115.
          ENDIF.

          READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item
                                                       cond_type  = 'Y116' condisacti = ''.
          IF sy-subrc EQ 0.
            gs_final-y116   = ceil( ls_pocond-cond_value ).
            gs_final-y116_n = ts_source-y116.
          ENDIF.
          APPEND gs_final TO it_final.
          CLEAR:gs_final,ls_pocond.



        ENDIF.
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

*            CALL FUNCTION 'BAPI_PO_GETDETAIL1'
*              EXPORTING
*                purchaseorder = ls_vlcporder-ebeln
*              TABLES
*                poitem        = lt_bapi_item
*                pocond        = lt_pocond.

*            READ TABLE lt_bapi_item INTO ls_item WITH KEY batch = ls_vehicle-vhcle.
*
*            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_item-po_item cond_type  = 'YV01' condisacti = ''.

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'YV01' condisacti = ''.
            lv_tabix = sy-tabix.
            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'YV01'.
            ls_pocond-cond_value = ts_source-yv01.
            ls_pocond-currency = ls_source_cur-yv01.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            APPEND ls_pocond TO lt_pocond_u.
*            MODIFY lt_pocond FROM ls_pocond INDEX lv_tabix.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
            CLEAR ls_pocond.
            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
*            MODIFY lt_pocondx FROM ls_pocondx INDEX lv_tabix.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.
            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y100' condisacti = ''.
            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y100'.
            ls_pocond-cond_value = ts_source-y100.
            ls_pocond-currency = ls_source_cur-y100.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y100 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y100.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
*            ls_pocondx-currency = 'X'.
*        ls_pocondx-cond_p_unt = 'X'.
            ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR ls_pocondx.

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y101' condisacti = ''.
            lv_tabix = sy-tabix.
            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y101'.
            ls_pocond-cond_value = ts_source-y101.
            ls_pocond-currency = ls_source_cur-y101.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y101 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y101.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
            CLEAR ls_pocond.

            ls_pocondx-itm_number = ls_vlcporder-ebelp.
            ls_pocondx-itm_numberx = 'X'.
            ls_pocondx-cond_type = 'X'.
            ls_pocondx-cond_value = 'X'.
            ls_pocondx-currency = 'X'.
*            ls_pocondx-cond_p_unt = 'X'.
*        ls_pocondx-change_id = 'X'.
            APPEND ls_pocondx TO lt_pocondx.
            CLEAR  ls_pocondx.

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y102' condisacti = ''.
            lv_tabix = sy-tabix.
            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y102'.
            ls_pocond-cond_value = ts_source-y102.
            ls_pocond-currency = ls_source_cur-y102.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y102 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y102.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y103' condisacti = ''.
            lv_tabix = sy-tabix.
            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y103'.
            ls_pocond-cond_value = ts_source-y103.
            ls_pocond-currency = ls_source_cur-y103.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y103 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y103.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y104' condisacti = ''.
            lv_tabix = sy-tabix.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y104'.
            ls_pocond-cond_value = ts_source-y104.
            ls_pocond-currency = ls_source_cur-y104.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y104 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y104.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y105' condisacti = ''.
            lv_tabix = sy-tabix.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y105'.
            ls_pocond-cond_value = ts_source-y105.
            ls_pocond-currency = ls_source_cur-y105.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y105 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y105.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y106' condisacti = ''.
            lv_tabix = sy-tabix.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y106'.
            ls_pocond-cond_value = ts_source-y106.
            ls_pocond-currency = ls_source_cur-y106.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y106 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y106.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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


            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y107' condisacti = ''.
            lv_tabix = sy-tabix.
            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y107'.
            ls_pocond-cond_value = ts_source-y107.
            ls_pocond-currency = ls_source_cur-y107.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y107 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y107.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y108' condisacti = ''.
            lv_tabix = sy-tabix.
            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y108'.
            ls_pocond-cond_value = ts_source-y108.
            ls_pocond-currency = ls_source_cur-y108.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y108 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y108.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y109' condisacti = ''.
            lv_tabix = sy-tabix.
            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y109'.
            ls_pocond-cond_value = ts_source-y109.
            ls_pocond-currency = ls_source_cur-y109.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y109 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y109.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y110' condisacti = ''.
            lv_tabix = sy-tabix.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y110'.
            ls_pocond-cond_value = ts_source-y110.
            ls_pocond-currency = ls_source_cur-y110.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y110 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y110.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y111' condisacti = ''.
            lv_tabix = sy-tabix.
            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y111'.
            ls_pocond-cond_value = ts_source-y111.
            ls_pocond-currency = ls_source_cur-y111.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y111 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y111.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y112' condisacti = ''.
            lv_tabix = sy-tabix.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y112'.
            ls_pocond-cond_value = ts_source-y112.
            ls_pocond-currency = ls_source_cur-y112.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y112 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y112.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y113' condisacti = ''.
            lv_tabix = sy-tabix.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y113'.
            ls_pocond-cond_value = ts_source-y113.
            ls_pocond-currency = ls_source_cur-y113.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y113 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y113.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y114' condisacti = ''.
            lv_tabix = sy-tabix.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y114'.
            ls_pocond-cond_value = ts_source-y114.
            ls_pocond-currency = ls_source_cur-y114.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y114 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y114.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y115' condisacti = ''.
            lv_tabix = sy-tabix.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y115'.
            ls_pocond-cond_value = ts_source-y115.
            ls_pocond-currency = ls_source_cur-y115.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y115 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y115.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            READ TABLE lt_pocond INTO ls_pocond WITH KEY itm_number = ls_vlcporder-ebelp  cond_type = 'Y116' condisacti = ''.
            lv_tabix = sy-tabix.

            ls_pocond-itm_number = ls_vlcporder-ebelp.
            ls_pocond-cond_type = 'Y116'.
            ls_pocond-cond_value = ts_source-y116.
            ls_pocond-currency = ls_source_cur-y116.  "'USD'.
*        ls_pocond-cond_p_unt = 'EA'.
            ls_pocond-change_id = 'U'.
            IF ls_source_ven-y116 IS NOT INITIAL.
              ls_pocond-vendor_no = ls_source_ven-y116.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_pocond-vendor_no
                IMPORTING
                  output = ls_pocond-vendor_no.
              ls_pocondx-vendor_no = 'X'.
            ENDIF.
            APPEND ls_pocond TO lt_pocond_u.
            ls_pocondx-condition_no = ls_pocond-condition_no.
            ls_pocondx-cond_st_no = ls_pocond-cond_st_no.
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

            AT LAST.

              CALL FUNCTION 'BAPI_PO_CHANGE'
                EXPORTING
                  purchaseorder = ls_vlcporder-ebeln
                TABLES
                  return        = lt_bapi_return
                  pocond        = lt_pocond_u
                  pocondx       = lt_pocondx.

*              READ TABLE lt_bapi_return INTO ls_bapi_return WITH KEY type = 'S'.
              READ TABLE lt_bapi_return INTO ls_bapi_return WITH KEY type = 'S' id = '06' number = '023'.
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
              ELSE.
                ts_log-message = gc_error.
                ts_log-vhcex =  ts_source-ord_no.
                ts_log-po = ls_vlcporder-ebeln.
                ts_log-po_item = ls_vlcporder-ebelp.
                LOOP AT lt_bapi_return INTO ls_bapi_return WHERE type EQ 'E'.
                  IF ls_bapi_return-id NE 'BAPI' AND ls_bapi_return-id NE 'MEPO'.
                    IF ts_log-long_text IS INITIAL .
                      ts_log-long_text = ls_bapi_return-message.
                    ELSE.
                      CONCATENATE  ts_log-long_text ','  ls_bapi_return-message INTO ts_log-long_text.
                    ENDIF.
                  ENDIF.
                ENDLOOP.
                APPEND ts_log TO it_log.
                CLEAR ts_log.

              ENDIF.

              REFRESH : lt_pocond, lt_pocond_u, lt_pocondx, lt_bapi_return.
            ENDAT.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF it_final IS NOT INITIAL.

    IF rb_chk = 'X'.

      PERFORM f_create_catalog.

      DATA :it_sort TYPE  slis_t_sortinfo_alv,
            ts_sort LIKE LINE OF it_sort.


      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = sy-repid
*         i_grid_title             = TEXT-t01
          i_callback_pf_status_set = 'SUB_PF_STATUS'
*         i_callback_user_command  = 'USER_COMMAND'
          is_layout                = wa_layout
          it_sort                  = it_sort
          it_fieldcat              = it_fcat "PASS FIELD CATALOG TO ALV
          i_screen_start_column    = 0
          i_screen_start_line      = 0
          i_screen_end_column      = 0
          i_screen_end_line        = 0
*         it_events                = it_events2
          i_save                   = 'A'
        TABLES
          t_outtab                 = it_final
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDIF.

  ENDIF.


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
*&---------------------------------------------------------------------*
*& Form f_create_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_create_catalog .

  DATA lv_col TYPE i VALUE 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'ORD_NO'.
  wa_fcat-seltext_m = 'Order Number' .
  wa_fcat-outputlen = 18.
  wa_fcat-key       = abap_true.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'MODEL'.
  wa_fcat-seltext_m = 'Model' .
  wa_fcat-outputlen = 18.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'EXTERIOR'.
  wa_fcat-seltext_m = 'Exterior' .
  wa_fcat-outputlen = 18.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'INTERIOR'.
  wa_fcat-seltext_m = 'Interior' .
  wa_fcat-outputlen = 18.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'COMPANY'.
  wa_fcat-seltext_m = 'Company' .
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'PUR_ORG'.
  wa_fcat-seltext_m = 'Purchase Organization' .
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'PUR_GRP'.
  wa_fcat-seltext_m = 'Purchase Group' .
  wa_fcat-outputlen = 18.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'PLANT'.
  wa_fcat-seltext_m = 'Plant' .
  wa_fcat-outputlen = 18.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'DIVISION'.
  wa_fcat-seltext_m = 'Division' .
  wa_fcat-outputlen = 18.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'VENDOR'.
  wa_fcat-seltext_m = 'Vendor' .
  wa_fcat-outputlen = 18.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'YV01'.
  wa_fcat-seltext_m = 'Vehicle Invoice Val' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 18.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'YV01_N'.
  wa_fcat-seltext_m = 'Vehicle Invoice Val New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y100'.
  wa_fcat-seltext_m = 'Consignment Adjustmt' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y100_N'.
  wa_fcat-seltext_m = 'Consignment Adjustmt New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y101'.
  wa_fcat-seltext_m = 'Freight Forward Fee' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y101_N'.
  wa_fcat-seltext_m = 'Freight Forward Fee New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y102'.
  wa_fcat-seltext_m = 'Ocean Freight Crg' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y102_N'.
  wa_fcat-seltext_m = 'Ocean Freight Crg New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y103'.
  wa_fcat-seltext_m = 'Port Charges' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y103_N'.
  wa_fcat-seltext_m = 'Port Charges New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y104'.
  wa_fcat-seltext_m = 'Marine Insurance' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y104_N'.
  wa_fcat-seltext_m = 'Marine Insurance New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y105'.
  wa_fcat-seltext_m = 'Local Clearing Crg' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y105_N'.
  wa_fcat-seltext_m = 'Local Clearing Crg New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y106'.
  wa_fcat-seltext_m = 'Custom Duties' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y106_N'.
  wa_fcat-seltext_m = 'Custom Duties New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y107'.
  wa_fcat-seltext_m = 'Document Charges' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y107_N'.
  wa_fcat-seltext_m = 'Document Charges New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y108'.
  wa_fcat-seltext_m = 'Delivery Order Crg' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y108_N'.
  wa_fcat-seltext_m = 'Delivery Order Crg New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y109'.
  wa_fcat-seltext_m = 'Bank Charges' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y109_N'.
  wa_fcat-seltext_m = 'Bank Charges New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y110'.
  wa_fcat-seltext_m = 'Other Foreign Charge' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y110_N'.
  wa_fcat-seltext_m = 'Other Foreign Charge New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y111'.
  wa_fcat-seltext_m = 'Transportation C Por' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y111_N'.
  wa_fcat-seltext_m = 'Transportation C Por New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y112'.
  wa_fcat-seltext_m = 'Storage & Washing' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y112_N'.
  wa_fcat-seltext_m = 'Storage & Washing New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y113'.
  wa_fcat-seltext_m = 'Other Cost Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y113_N'.
  wa_fcat-seltext_m = 'Other Cost Value New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y114'.
  wa_fcat-seltext_m = 'POM Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y114_N'.
  wa_fcat-seltext_m = 'POM New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y115'.
  wa_fcat-seltext_m = 'Road Assistance Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y115_N'.
  wa_fcat-seltext_m = 'Road Assistance New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y116'.
  wa_fcat-seltext_m = 'PDI Cost' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = 'Y116_N'.
  wa_fcat-seltext_m = 'PDI Cost New Value' .
  wa_fcat-decimals_out = '0'.
  wa_fcat-outputlen = 25.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  sub_pf_status
*&---------------------------------------------------------------------*
*  Sub-Routine to Set the PF status
*----------------------------------------------------------------------*
FORM sub_pf_status USING rt_extab TYPE slis_t_extab..
  SET PF-STATUS 'YSTANDARD'.
ENDFORM.                    "sub_pf_status

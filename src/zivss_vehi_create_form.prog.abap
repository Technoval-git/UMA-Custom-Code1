*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_CREATE_FORM
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
  LOOP AT it_data_tab INTO ts_data_tab FROM 2.
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
                     INTO ts_source-odr_no
                          ts_source-veh_type
                          ts_source-vin
                          ts_source-engine_no
                          ts_source-factory
                          ts_source-weight
                          ts_source-cbm
                          ts_source-cub_cap
                          ts_source-dest
                          ts_source-vessel
                          ts_source-ats
                          ts_source-eta
                          ts_source-bill_no
                          ts_source-mrn.

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
FORM  form_create_validate_inbdel.
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

  CHECK it_source IS NOT INITIAL.

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

  CLEAR ts_fcat.
  ts_fcat-fieldname = gc_verur.
  ts_fcat-tabname   = gc_it_source.
  ts_fcat-outputlen   = 015.
  ts_fcat-seltext_l   = TEXT-017.
  APPEND ts_fcat TO it_fcat.


  CLEAR ts_fcat.
  ts_fcat-fieldname = gc_inbdel.
  ts_fcat-tabname   = gc_it_source.
  ts_fcat-outputlen   = 10.
  ts_fcat-seltext_l   = TEXT-011.
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

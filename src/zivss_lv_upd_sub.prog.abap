*&---------------------------------------------------------------------*
*& Include          ZIVSS_LV_UPD_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_SCREEN_PARAMETERS
*&---------------------------------------------------------------------*
*       To get current value of screen parameter
*----------------------------------------------------------------------*
*      <--P_VA_LOGICAL_FILE  text
*      <--P_VA_PHYSICAL_FILE  text
*----------------------------------------------------------------------*
FORM f_get_screen_parameters  CHANGING cv_logical_file.

  DATA : lt_sel_fields TYPE TABLE OF  dynpread,   "table for reading the screen parameter values at runtime
         wa_sel_fields TYPE dynpread.

  wa_sel_fields-fieldname = 'R_SERVER' .
  APPEND wa_sel_fields TO lt_sel_fields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = lt_sel_fields.

  READ TABLE lt_sel_fields INTO wa_sel_fields
    WITH KEY fieldname = 'R_SERVER'.
  IF sy-subrc = 0.
    cv_logical_file = wa_sel_fields-fieldvalue.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_F4_SERVER_FILENAME
*&---------------------------------------------------------------------*
*  F4 Help for server filename
*----------------------------------------------------------------------*
*      <--CV_HEADER  text
*----------------------------------------------------------------------*
FORM f_f4_server_filename  CHANGING cv_header TYPE file_table-filename.
  TYPES : BEGIN OF ty_filenameci,
            fileintern TYPE filenameci-fileintern,
            fileextern TYPE filenameci-fileextern,
          END OF ty_filenameci.

  DATA lt_values    TYPE TABLE OF ty_filenameci.
  DATA lt_selected  TYPE TABLE OF ddshretval.
  DATA lw_selected  TYPE ddshretval.

  "load the logical file names from the table
  SELECT fileintern fileextern FROM filenameci INTO TABLE lt_values. "#EC CI_GENBUFF
  "F4 help for logical file selection
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'FILEINTERN'
      window_title    = 'Logical Files'
      value_org       = 'S'
    TABLES
      value_tab       = lt_values
*     FIELD_TAB       =
      return_tab      = lt_selected
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  "Get the logical file name
  READ TABLE lt_selected INTO lw_selected INDEX 1.

  cv_header = lw_selected-fieldval. "selected value

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_F4_PRESENTATION_FILE
*&---------------------------------------------------------------------*
*  F4 Help for presentation file upload
*----------------------------------------------------------------------*
*      <--P_P_HEADER  text
*----------------------------------------------------------------------*
FORM f_f4_presentation_file  CHANGING cv_header.
  DATA : lt_file_table TYPE filetable,
         lw_file       TYPE file_table,
         lv_rc         TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table = lt_file_table
      rc         = lv_rc.

  IF lv_rc = 1.
    READ TABLE lt_file_table INTO lw_file INDEX 1.
    IF sy-subrc = 0.
      cv_header = lw_file-filename.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
*  Form to handle value request of multiple parameters
*----------------------------------------------------------------------*
*      <--P_VA_LOGICAL_FILE  text
*      <--P_P_HEADER  text
*----------------------------------------------------------------------*
FORM f_value_request  CHANGING cv_logical_file
                               cv_header.
  " get screen parameter values
  PERFORM f_get_screen_parameters CHANGING cv_logical_file.

  IF cv_logical_file EQ abap_true.      " logical file option
    " F4 help for header file
    PERFORM f_f4_server_filename CHANGING cv_header.
  ELSE.       " logical file option
    " f4 help for Local file
    PERFORM f_f4_presentation_file CHANGING cv_header.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_READ_HEADER_FILE_APP
*&---------------------------------------------------------------------*
*    Read file from presentation server
*----------------------------------------------------------------------*
*      <--P_IT_HEADER_FILE  text
*----------------------------------------------------------------------*
FORM f_read_file USING iv_filename TYPE file_table-filename
              CHANGING ct_file.
  DATA: lv_filename TYPE string.

  lv_filename = iv_filename.
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = 'ASC'
      has_field_separator     = 'X'
    CHANGING
      data_tab                = ct_file
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
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_READ_FILE_APP
*&---------------------------------------------------------------------*
*      Read file from Application server
*----------------------------------------------------------------------*
*      -->P_0253   text
*      -->P_P_HEADER  text
*      <--P_IT_HEADER_FILE  text
*----------------------------------------------------------------------*
FORM f_read_file_app  USING    iv_type      TYPE c
                               iv_filename
                      CHANGING ct_file.
  DATA: lv_filepath TYPE file_table-filename,
        lv_line     TYPE string,
        lv_msg      TYPE string,
        lv_filename TYPE filename-fileintern.

  lv_filename = iv_filename.

  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      logical_filename = lv_filename
    IMPORTING
      file_name        = lv_filepath
    EXCEPTIONS
      file_not_found   = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.

    OPEN DATASET lv_filepath FOR INPUT IN TEXT MODE ENCODING DEFAULT MESSAGE lv_msg.
    IF sy-subrc = 0.
      DO.
        READ DATASET lv_filepath INTO lv_line.

        IF sy-subrc = 0.
          PERFORM f_map_to_tab USING iv_type lv_line CHANGING ct_file.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
      CLOSE DATASET lv_filepath.
    ELSE.
      MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MAP_TO_TAB
*&---------------------------------------------------------------------*
*       Map file to structure
*----------------------------------------------------------------------*
*      -->P_IV_TYPE  text
*      -->P_LV_LINE  text
*      <--P_CT_FILE  text
*----------------------------------------------------------------------*
FORM f_map_to_tab  USING    iv_type TYPE c
                            iv_line TYPE string
                   CHANGING ct_file TYPE table.

  DATA: lw_header TYPE ty_header_file,
        lw_text   TYPE ty_text_file,
        lw_time   TYPE ty_time_file.

  DATA: lr_dynamic_line   TYPE REF TO data.
  FIELD-SYMBOLS: <fs_data> TYPE any.

  CASE iv_type.
    WHEN 'H'.
*.. << Mapping header data to internal table >>
      SPLIT iv_line AT cl_abap_char_utilities=>horizontal_tab
         INTO lw_header-identifier
              lw_header-lbrcat
              lw_header-labval
              lw_header-multilog
              lw_header-matnr
              lw_header-lbrgroup
              lw_header-matchcode
              lw_header-srv_it_grp
              lw_header-descr1.

      REPLACE ALL OCCURRENCES OF  cl_abap_char_utilities=>cr_lf(1) " carriage return
        IN lw_header WITH space.
      REPLACE ALL OCCURRENCES OF  cl_abap_char_utilities=>cr_lf+1(1) " line feed
        IN lw_header WITH space.

      ASSIGN lw_header TO <fs_data>.
      APPEND <fs_data> TO ct_file.

    WHEN 'T'.
*.. << Mapping text data to internal table >>
      SPLIT iv_type AT cl_abap_char_utilities=>horizontal_tab INTO
            lw_text-identifier
            lw_text-lbrcat
            lw_text-labval
            lw_text-tdid
            lw_text-tdline
            lw_text-flag.

      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf(1) " carriage return
        IN lw_text WITH space.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf+1(1) " line feed
        IN lw_text WITH space.

      ASSIGN lw_text TO <fs_data>.
      APPEND <fs_data> TO ct_file.

    WHEN 'V'.
*.. << Mapping time data to internal table >>
      SPLIT iv_line AT cl_abap_char_utilities=>horizontal_tab
        INTO lw_time-identifier
             lw_time-lbrcat
             lw_time-labval
             lw_time-labval_type
             lw_time-value.

      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf(1) " carriage return
        IN lw_time WITH ''.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf+1(1) " line feed
        IN lw_time WITH ''.

      ASSIGN lw_time TO <fs_data>.
      APPEND <fs_data> TO ct_file.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       Fill field catalog for ALV
*----------------------------------------------------------------------*
*      <--P_IT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM f_fill_field_catalog  CHANGING ct_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: lw_fcat TYPE slis_fieldcat_alv.

  DEFINE m_cat ##NEEDED.
    lw_fcat-fieldname   = &1.
    lw_fcat-tabname     = &2.
    lw_fcat-seltext_l   = &3.
    lw_fcat-outputlen   = &4.
    APPEND lw_fcat TO ct_fieldcat.
  END-OF-DEFINITION.

  m_cat 'TYPE'           'IT_LOG' TEXT-004 TEXT-008.
  m_cat 'LBRCAT'         'IT_LOG' TEXT-005 TEXT-008.
  m_cat 'LABVAL'         'IT_LOG' TEXT-006 TEXT-008.
  m_cat 'MESSAGE'        'IT_LOG' TEXT-007 TEXT-009.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*       Create/Update the uploaded data
*----------------------------------------------------------------------*
*      -->P_IT_HEADER_FILE  text
*      -->P_IT_TEXT_FILE  text
*      -->P_IT_TIME_FILE  text
*----------------------------------------------------------------------*
FORM f_process_data  USING    it_header_file TYPE tt_header_file
                              it_text_file   TYPE tt_text_file
                    CHANGING  ct_time_file   TYPE tt_time_file.
  DATA: lw_header_file        TYPE ty_header_file,
        lw_time_file          TYPE ty_time_file,
        lw_text_file          TYPE ty_text_file,
        lw_header_lbr         TYPE /dbe/lbrop_rfc,
        lt_time_lbr           TYPE TABLE OF /dbe/lbrop_time_rfc,
        lw_time_lbr           TYPE /dbe/lbrop_time_rfc,
        lw_text_lbr           TYPE /dbe/lbropt_rfc,
        lt_text_lbr           TYPE TABLE OF /dbe/lbropt_rfc,
        lv_dec_check          TYPE char12, "ntsp-twert,
        lw_log                TYPE ty_log,
        lv_message            TYPE string,
        lt_return             TYPE STANDARD TABLE OF bapiret2, "bapiret2tab,
        ls_return             TYPE bapiret2,
        lv_time_value_skipped TYPE crmt_boolean.

  FIELD-SYMBOLS: <fs_time_file> TYPE ty_time_file.

  LOOP AT ct_time_file ASSIGNING <fs_time_file>.
*...<< Labor value has to be in uppercase >>
    CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
      EXPORTING
        i_input  = <fs_time_file>-labval
        i_langu  = sy-langu
      IMPORTING
        e_output = <fs_time_file>-labval.
  ENDLOOP.

  va_total_records = lines( it_header_file ).

  LOOP AT it_header_file INTO lw_header_file.
    CLEAR: lw_header_lbr, lt_time_lbr, lt_text_lbr,
           lw_text_lbr, lv_time_value_skipped.

*...<< Labor value has to be in uppercase >>
    CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
      EXPORTING
        i_input  = lw_header_file-labval
        i_langu  = sy-langu
      IMPORTING
        e_output = lw_header_file-labval.
    MOVE-CORRESPONDING lw_header_file TO lw_header_lbr.

    lw_text_lbr-spras = sy-langu.
    lw_text_lbr-lbrcat = lw_header_file-lbrcat."is_header_file-lbrcat.
    lw_text_lbr-labval = lw_header_file-labval."is_header_file-labval.
    lw_text_lbr-descr1 = lw_header_file-descr1."is_header_file-descr1.
    lw_text_lbr-descr2 = lw_header_file-descr2.
    lw_text_lbr-descr3 = lw_header_file-descr3.
    lw_text_lbr-descr4 = lw_header_file-descr4.
    lw_text_lbr-matchcode = lw_header_file-matchcode."is_header_file-matchcode.
    APPEND lw_text_lbr TO lt_text_lbr.

    LOOP AT ct_time_file INTO lw_time_file
      WHERE lbrcat = lw_header_lbr-lbrcat
        AND labval = lw_header_lbr-labval.

      CLEAR: lw_time_lbr, lv_dec_check.

*...<< assigning value to decimal variable, hence converting . to , >>
      REPLACE ALL OCCURRENCES OF ',' IN lw_time_file-value WITH '.'.
      lw_time_lbr-value = lw_time_file-value.
      WRITE lw_time_lbr-value TO lv_dec_check.
      CONDENSE lv_dec_check.

*...<< Checking if the time passed is decimal >>
*      CALL FUNCTION 'ISH_CHECK_FIELD_TYPE'
*        EXPORTING
*          decimalplaces             = 2
*          input                     = lv_dec_check
*          input_type                = 'N'
*          length                    = 7
*        EXCEPTIONS
*          input_too_long            = 1
*          not_numeric               = 2
*          no_decimalpoint           = 3
*          param_decimalplaces_wrong = 4
*          param_length_wrong        = 5
*          too_many_decimalplaces    = 6
*          wrong_input_source        = 7
*          wrong_input_type          = 8
*          OTHERS                    = 9.
*      IF sy-subrc = 0.

      lw_time_lbr-lbrcat      = lw_time_file-lbrcat.
      lw_time_lbr-labval      = lw_time_file-labval.
      lw_time_lbr-labval_type = lw_time_file-labval_type.
      lw_time_lbr-value_uom   = 'H'.

      APPEND lw_time_lbr TO lt_time_lbr.
*      ELSE.
**...<< If time is not valid, record is not updated >>
*        CALL FUNCTION 'FORMAT_MESSAGE'
*          EXPORTING
*            id   = sy-msgid
*            lang = sy-langu
*            no   = sy-msgno
*            v1   = sy-msgv1
*            v2   = sy-msgv2
*            v3   = sy-msgv3
*            v4   = sy-msgv4
*          IMPORTING
*            msg  = lv_message.
*        lw_log-type = sy-msgty.
*        lw_log-lbrcat = lw_header_file-lbrcat.
*        lw_log-labval = lw_header_file-labval.
*        lw_log-message = lv_message .
*        APPEND lw_log TO it_log.
*
**...<< Custom message >>
*        lw_log-type = 'E'.
*        lw_log-lbrcat = lw_header_file-lbrcat.
*        lw_log-labval = lw_header_file-labval.
*        lw_log-message = TEXT-010.
*        REPLACE FIRST OCCURRENCE OF '&1' IN lw_log-message
*          WITH lw_time_file-labval_type.
*        APPEND lw_log TO it_log.
*
*        lv_time_value_skipped = abap_true.
*      ENDIF.

    ENDLOOP.

*...<< Creation/Updation of Labour catalog >>
    CALL FUNCTION '/DBE/LBR_OP_RFC_CHANGE'
      EXPORTING
        iv_lbrcat         = lw_header_lbr-lbrcat
        iv_labval         = lw_header_lbr-labval
        is_lbrop_rfc      = lw_header_lbr
        iv_create_allowed = 'X'
        iv_check_data     = 'X'
      TABLES
        it_lbropt_rfc     = lt_text_lbr
        it_lbrop_time_rfc = lt_time_lbr
        et_return         = lt_return.

    IF lt_return[] IS NOT INITIAL.
      LOOP AT lt_return INTO ls_return.
        CLEAR lw_log.
        MOVE-CORRESPONDING ls_return TO lw_log.
        lw_log-lbrcat = lw_header_lbr-lbrcat.
        lw_log-labval = lw_header_lbr-labval.
        APPEND lw_log TO it_log.
      ENDLOOP.

      CLEAR: lw_log.
      lw_log-lbrcat = lw_header_lbr-lbrcat.
      lw_log-labval = lw_header_lbr-labval.
      lw_log-type   = 'E'.
      lw_log-message = TEXT-011.
      APPEND lw_log TO it_log.

      va_fail_records = va_fail_records + 1.

    ELSE.
*...<< Commiting if creation is successful >>
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      CLEAR lw_log.
      lw_log-lbrcat = lw_header_lbr-lbrcat.
      lw_log-labval = lw_header_lbr-labval.
      lw_log-type = 'S'.
      lw_log-message = TEXT-012.
      APPEND lw_log TO it_log.

*..<< Even if labour value is created, but any of the time value is skipped,
*..   it is considered as error  >>
      IF lv_time_value_skipped = abap_true.
        va_fail_records = va_fail_records + 1.
      ELSE.
        va_succ_records = va_succ_records + 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

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
  " LOCAL VARIABLES Declaration
  DATA  lv_no_of_records TYPE string.

  CONSTANTS: lc_head TYPE c VALUE  'H',
             lc_sel  TYPE c VALUE  'S'.

  lw_head-typ  = lc_head.
  lw_head-info = TEXT-013.
  APPEND lw_head TO  lt_head.
  CLEAR lw_head.

  " Record count for ALV header display
  lw_head-typ  = lc_sel.
  lv_no_of_records = va_total_records.
  CONCATENATE TEXT-014
              lv_no_of_records   INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR: lw_head, lv_no_of_records.

  lw_head-typ  = lc_sel.
  lv_no_of_records = va_succ_records.
  CONCATENATE TEXT-015
              lv_no_of_records    INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR: lw_head, lv_no_of_records.

  lw_head-typ  = lc_sel.
  lv_no_of_records = va_fail_records.
  CONCATENATE TEXT-016
              lv_no_of_records    INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR: lw_head, lv_no_of_records.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_head.
ENDFORM           ##called.                    " F_ALV_HEADER

*&---------------------------------------------------------------------*
*& Include          ZIVSS_JOB_CARD_UPDATE_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form form_get_data_pc_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM form_get_data_pc_file .
  PERFORM form_upload_file_pc USING gc_csv_sep.

  FIELD-SYMBOLS : <gt_data_h> TYPE STANDARD TABLE,
                  <gt_data_l> TYPE ANY TABLE,
                  <gt_table>  TYPE STANDARD TABLE,
                  <gs_table>  TYPE any.
  DATA : lv_filename      TYPE string,
         lt_records       TYPE solix_tab,
         lv_headerxstring TYPE xstring,
         lv_filelength    TYPE i.

  lv_filename = pv_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_filelength
      header                  = lv_headerxstring
    TABLES
      data_tab                = lt_records
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
      OTHERS                  = 17.

  "convert binary data to xstring
  "if you are using cl_fdt_xl_spreadsheet in odata then skips this step
  "as excel file will already be in xstring
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_filelength
    IMPORTING
      buffer       = lv_headerxstring
    TABLES
      binary_tab   = lt_records
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    "Implement suitable error handling here
  ENDIF.

  DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet .

  TRY .
      lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
        document_name = lv_filename
        xdocument     = lv_headerxstring ).
    CATCH cx_fdt_excel_core.
    CATCH  cx_sy_ref_is_initial INTO DATA(lv_catch_ref).
      DATA(lv_ref_tex) = lv_catch_ref->get_text( ).
  ENDTRY .

  "Get List of Worksheets
  lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
    IMPORTING
      worksheet_names = DATA(lt_worksheets) ).

  IF NOT lt_worksheets IS INITIAL.
    LOOP AT lt_worksheets INTO DATA(lv_woksheetname).

      DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
        lv_woksheetname ).
      "now you have excel work sheet data in dyanmic internal table
      ASSIGN lo_data_ref->* TO <gt_data_h>.
*    *-- Excel work sheet data in dyanmic internal table
      ASSIGN lo_data_ref->* TO <gt_data_h>.

*-Checking table strcuture componet count value
      IF lv_woksheetname EQ 'Sheet1'.
        DATA(lr_descr) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( gw_source ) ).
      ENDIF.

      DATA(l_count) = lines( lr_descr->components ).
      DATA :dref TYPE REF TO data.
      CREATE DATA dref LIKE LINE OF <gt_data_h>.
      ASSIGN dref->* TO  <gs_table>.
*-Checking excel file from PWC strcuture componet count value
      DATA(lr_descr1) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( <gs_table> ) ).
      DATA(l_count1) = lines( lr_descr->components ).

*-Deleting Excel  header
      DATA:lv_int TYPE i.
      LOOP AT <gt_data_h> ASSIGNING FIELD-SYMBOL(<ls_datah>) FROM 2.
        LOOP AT lr_descr1->components[] ASSIGNING FIELD-SYMBOL(<ls_compnt>) FROM 1 TO l_count.
          lv_int = sy-tabix.

          DATA(ls_compont) = lr_descr->components[ lv_int ].
          ASSIGN COMPONENT <ls_compnt>-name OF STRUCTURE <ls_datah> TO FIELD-SYMBOL(<ls_fld>).
          IF sy-subrc IS INITIAL.
            IF lv_woksheetname EQ 'Sheet1'.
              ASSIGN COMPONENT ls_compont-name OF STRUCTURE gw_source TO FIELD-SYMBOL(<ls_file>).
            ENDIF.
            IF sy-subrc IS INITIAL.
              <ls_file> = <ls_fld>.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF gw_source IS NOT INITIAL AND lv_woksheetname EQ 'Sheet1'.
          APPEND gw_source TO gt_source.
        ENDIF.
        CLEAR :gw_source.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_job_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_job_info .

  DATA : ls_head TYPE thead,
         lv_ord  TYPE /dbe/vbeln_va,
         lv_job  TYPE /dbe/jobnr,
         lv_inc  TYPE i.

  DATA : lt_line       TYPE STANDARD TABLE OF tline,
         ls_line       TYPE tline,
         lt_line_split TYPE STANDARD TABLE OF tline,
         ls_line_split TYPE tline.

  DATA : lt_zvss_job_man_tim TYPE STANDARD TABLE OF zvss_job_man_tim,
         ls_zvss_job_man_tim TYPE zvss_job_man_tim.

  SORT gt_source ASCENDING BY ord_no job_no.

  LOOP AT gt_source ASSIGNING FIELD-SYMBOL(<ls_source>).

    CALL FUNCTION 'CONVERSION_EXIT_ALPH0_INPUT'
      EXPORTING
        input  = <ls_source>-ord_no
      IMPORTING
        output = <ls_source>-ord_no.

    CALL FUNCTION 'CONVERSION_EXIT_ALPH0_INPUT'
      EXPORTING
        input  = <ls_source>-job_no
      IMPORTING
        output = <ls_source>-job_no.

  ENDLOOP.

  SELECT * FROM /dbe/job INTO TABLE @DATA(lt_job) FOR ALL ENTRIES IN @gt_source
    WHERE vbeln EQ @gt_source-ord_no AND
          jobnr EQ @gt_source-job_no.

  LOOP AT gt_source INTO gw_source.
    READ TABLE lt_job INTO DATA(ls_job) WITH KEY vbeln = gw_source-ord_no
                                                 jobnr = gw_source-job_no.
    IF sy-subrc EQ 0.

      IF ls_job-vbeln EQ lv_ord AND ls_job-jobnr EQ lv_job.
        CLEAR lv_inc.
        lv_inc  = 1.
      ELSE.
        lv_inc = lv_inc + 1.
      ENDIF.

      lv_ord = ls_job-vbeln.
      lv_job = ls_job-jobnr.

      ls_head-tdobject = '/DBE/O_JOB'.
      ls_head-tdid  = '0001'.
      ls_head-tdspras = 'E'.
      CONCATENATE ls_job-vbeln ls_job-jobnr INTO ls_head-tdname.


      CALL FUNCTION 'IDMX_DI_SPLIT_TEXT'
        EXPORTING
          iv_character_chain = gw_source-concern
          iv_length          = 132
        IMPORTING
          et_string_table    = lt_line_split.


      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
          client          = sy-mandt
          header          = ls_head
          savemode_direct = 'X'
        TABLES
          lines           = lt_line_split.

      REFRESH lt_line_split.

      CALL FUNCTION 'IDMX_DI_SPLIT_TEXT'
        EXPORTING
          iv_character_chain = gw_source-cause
          iv_length          = 132
        IMPORTING
          et_string_table    = lt_line_split.

      ls_head-tdid  = '0002'.


      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
          client          = sy-mandt
          header          = ls_head
          savemode_direct = 'X'
        TABLES
          lines           = lt_line_split.

      REFRESH lt_line_split.

      CALL FUNCTION 'IDMX_DI_SPLIT_TEXT'
        EXPORTING
          iv_character_chain = gw_source-correction
          iv_length          = 132
        IMPORTING
          et_string_table    = lt_line_split.


      ls_head-tdid  = '0003'.

      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
          client          = sy-mandt
          header          = ls_head
          savemode_direct = 'X'
        TABLES
          lines           = lt_line_split.

      REFRESH lt_line_split.

      CLEAR lt_line_split.
      ls_zvss_job_man_tim-vbeln = ls_job-vbeln.
      ls_zvss_job_man_tim-jobnr = ls_job-jobnr.
      ls_zvss_job_man_tim-inc = lv_inc.
      ls_zvss_job_man_tim-pernr = gw_source-tech.
      CONDENSE gw_source-start_date.
*      CONCATENATE gw_source-start_date+6(4) gw_source-start_date+3(2) gw_source-start_date+0(2) INTO ls_zvss_job_man_tim-start_date.
      CONCATENATE gw_source-start_date+0(4) gw_source-start_date+5(2) gw_source-start_date+8(2) INTO ls_zvss_job_man_tim-start_date.
      CONDENSE ls_zvss_job_man_tim-start_date.
      CONDENSE gw_source-start_time.
      CONCATENATE gw_source-start_time+0(2) gw_source-start_time+3(2) gw_source-start_time+6(2) INTO ls_zvss_job_man_tim-start_time.
      CONDENSE ls_zvss_job_man_tim-start_time.
      CONDENSE gw_source-end_date.
*      CONCATENATE gw_source-end_date+6(4) gw_source-end_date+3(2) gw_source-end_date+0(2) INTO ls_zvss_job_man_tim-end_date.
      CONCATENATE gw_source-end_date+0(4) gw_source-end_date+5(2) gw_source-end_date+8(2) INTO ls_zvss_job_man_tim-end_date.
      CONDENSE ls_zvss_job_man_tim-end_date.
      CONDENSE gw_source-end_time.
      CONCATENATE gw_source-end_time+0(2) gw_source-end_time+3(2) gw_source-end_time+6(2) INTO ls_zvss_job_man_tim-end_time.
      CONDENSE ls_zvss_job_man_tim-end_time.
      MODIFY zvss_job_man_tim FROM ls_zvss_job_man_tim.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form form_upload_file_pc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_CSV_SEP
*&---------------------------------------------------------------------*
FORM form_upload_file_pc  USING p_file_sep.


** Variable for passing the input file name
*  DATA: lv_file_name          TYPE string,
** Variable for passing the virus scan profile
*        lv_virus_sacn_profile TYPE vscan_profile,
** Internal table to which data in the input file will be uploaded
*        it_data_tab           TYPE stringtab,
** Work area for the above internal table
*        ts_data_tab           TYPE string.
*  lv_file_name = pv_file.
*
** Method to upload the text file specified as input into internal table
*  CALL METHOD cl_gui_frontend_services=>gui_upload
*    EXPORTING
*      filename                = lv_file_name
*      virus_scan_profile      = lv_virus_sacn_profile
*    CHANGING
*      data_tab                = it_data_tab
*    EXCEPTIONS
*      file_open_error         = 1
*      file_read_error         = 2
*      no_batch                = 3
*      gui_refuse_filetransfer = 4
*      invalid_type            = 5
*      no_authority            = 6
*      unknown_error           = 7
*      bad_data_format         = 8
*      header_not_allowed      = 9
*      separator_not_allowed   = 10
*      header_too_long         = 11
*      unknown_dp_error        = 12
*      access_denied           = 13
*      dp_out_of_memory        = 14
*      disk_full               = 15
*      dp_timeout              = 16
*      not_supported_by_gui    = 17
*      error_no_gui            = 18
*      OTHERS                  = 19.
*
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*  CLEAR gt_source.
*
*  LOOP AT it_data_tab INTO ts_data_tab FROM 2.
** Map the data to structure
*    PERFORM form_map_to_structure USING p_file_sep
*                                        ts_data_tab.
*  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form form_map_to_structure
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_FILE_SEP
*&      --> TS_DATA_TAB
*&---------------------------------------------------------------------*
FORM form_map_to_structure  USING    p_p_file_sep
                                     p_ts_data_tab.


*  DATA: gw_source   TYPE ty_source_fields.
  SPLIT p_ts_data_tab AT p_p_file_sep
  INTO   gw_source-ord_no
         gw_source-job_no
         gw_source-concern
         gw_source-cause
         gw_source-correction
         gw_source-tech
         gw_source-start_date
         gw_source-start_time
         gw_source-end_date
         gw_source-end_time.

  APPEND gw_source TO gt_source.

ENDFORM.

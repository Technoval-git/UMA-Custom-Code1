*&---------------------------------------------------------------------*
*& Report ZVSS_LABOUR_VALUE_UPLAOD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZVSS_LABOUR_VALUE_UPLAOD.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: r_local  RADIOBUTTON GROUP r1 DEFAULT 'X',
            r_server RADIOBUTTON GROUP r1,
            p_header TYPE file_table-filename,
            p_text   TYPE file_table-filename,
            p_time   TYPE file_table-filename.
SELECTION-SCREEN END OF BLOCK b1.

INCLUDE zivss_lv_upd_data.

INCLUDE zivss_lv_upd_sub.

**********************************************************************
*..Step 1:  Value Request for Screen parameters                      *
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_header.

  PERFORM f_value_request CHANGING va_logical_file p_header.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_text.

  PERFORM f_value_request CHANGING va_logical_file p_text.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_time.

  PERFORM f_value_request CHANGING va_logical_file p_time.

*...<< START OF SELECTION >>
START-OF-SELECTION.

**********************************************************************
*..Step 2:  Read files                                               *
**********************************************************************
  IF p_header IS INITIAL.
    MESSAGE TEXT-002 TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.                       "================>>>>
  ENDIF.

  IF r_server = abap_true.
*..<< Reading from Application Server >>
    PERFORM f_read_file_app USING 'H' p_header CHANGING it_header_file.
    IF p_text IS NOT INITIAL.
      PERFORM f_read_file_app USING 'T' p_text CHANGING it_text_file.
    ENDIF.
    IF p_time IS NOT INITIAL.
      PERFORM f_read_file_app USING 'V' p_time CHANGING it_time_file.
    ENDIF.

  ELSE.
*..<< Reading from Presentation Server >>
    PERFORM f_read_file USING p_header CHANGING it_header_file..
    IF p_text IS NOT INITIAL.
      PERFORM f_read_file USING p_text CHANGING it_text_file..
    ENDIF.
    IF p_time IS NOT INITIAL.
      PERFORM f_read_file USING p_time CHANGING it_time_file..
    ENDIF.
  ENDIF.

**********************************************************************
*..Step 3:  Process Data                                             *
**********************************************************************
  PERFORM f_process_data USING it_header_file
                               it_text_file
                               it_time_file.

**********************************************************************
*..Step 4:  Display Log                                              *
**********************************************************************
  IF it_log[] IS NOT INITIAL.

    PERFORM f_fill_field_catalog CHANGING it_fieldcat.

    wa_layout-zebra             = abap_true.
    wa_layout-colwidth_optimize = abap_true.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program     = sy-cprog
        i_callback_top_of_page = va_top
        i_grid_title           = TEXT-003
        is_layout              = wa_layout
        it_fieldcat            = it_fieldcat
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

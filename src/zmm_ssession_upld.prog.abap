*&---------------------------------------------------------------------*
*& Report ZMM_SSESSION_UPLD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_ssession_upld.

TABLES:mara,sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_upload RADIOBUTTON GROUP g1 DEFAULT 'X',
              p_update RADIOBUTTON GROUP g1,
              p_report RADIOBUTTON GROUP g1.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 4(60) TEXT-003.
  SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK b1.

*Update

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-004.
  PARAMETERS: p_matnr TYPE mara-matnr MODIF ID sc1 MEMORY ID mat.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 4(60) TEXT-005 MODIF ID sc1.
  SELECTION-SCREEN END   OF LINE.
  SELECTION-SCREEN:
  PUSHBUTTON /2(40) update USER-COMMAND upd MODIF ID sc1.
SELECTION-SCREEN END OF BLOCK b2.


*Report
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-006.
  SELECT-OPTIONS: s_matnr FOR mara-matnr MODIF ID sc2 .
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 4(60) TEXT-007 MODIF ID sc2.
  SELECTION-SCREEN END   OF LINE.
  SELECTION-SCREEN:
  PUSHBUTTON /2(40) report USER-COMMAND rep MODIF ID sc2.
SELECTION-SCREEN END OF BLOCK b3.


*Upload
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-008.
  PARAMETERS: pv_file TYPE localfile MODIF ID sc3.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 4(60) TEXT-009 MODIF ID sc3.
  SELECTION-SCREEN END   OF LINE.
  SELECTION-SCREEN:
  PUSHBUTTON /2(40) upload USER-COMMAND upld MODIF ID sc3.
SELECTION-SCREEN END OF BLOCK b4.


INITIALIZATION.


  report = 'Report'.
  update = 'Update'.
  upload = 'Upload'.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_okay
      text   = 'Report'
      info   = 'Click to Continue'
    IMPORTING
      result = report
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_okay
      text   = 'Update'
      info   = 'Click to Continue'
    IMPORTING
      result = update
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_okay
      text   = 'Upload'
      info   = 'Click to Continue'
    IMPORTING
      result = upload
    EXCEPTIONS
      OTHERS = 0.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR pv_file.


  DATA: l_window_title      TYPE string,
        l_rc                TYPE sysubrc,
        l_default_file_name TYPE string.

  DATA lt_file_table TYPE filetable.
  CONSTANTS : lc_err TYPE i VALUE -1,
              lc_suc TYPE i VALUE 1.

  l_window_title = 'Excel File'.


* Method to provide value help for input file name
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = l_window_title
      default_filename        = l_default_file_name
      default_extension       = 'XLS'
    CHANGING
      file_table              = lt_file_table
      rc                      = l_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc = 0.
    IF l_rc EQ lc_err.
      MESSAGE ID sy-msgid
            TYPE sy-msgty
          NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSEIF l_rc EQ lc_suc.
      READ TABLE lt_file_table INDEX 1 INTO pv_file.
      IF sy-subrc IS NOT INITIAL.
        CLEAR pv_file.
      ENDIF.
    ENDIF.
  ENDIF.
  FREE lt_file_table.

AT SELECTION-SCREEN OUTPUT.


  IF p_update = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'SC1' .
        screen-active = '1'.
      ELSEIF  screen-group1 = 'SC2' OR screen-group1 = 'SC3'.
        screen-active = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF p_report = 'X'.

    LOOP AT SCREEN.
      IF screen-group1 = 'SC2' .
        screen-active = '1'.
      ELSEIF  screen-group1 = 'SC1' OR screen-group1 = 'SC3'.
        screen-active = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF p_upload = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'SC3' .
        screen-active = '1'.
      ELSEIF  screen-group1 = 'SC2' OR screen-group1 = 'SC1'.
        screen-active = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

AT SELECTION-SCREEN.
  CASE sscrfields.
    WHEN 'UPD'.

      INCLUDE zmm_ssession_upld_upd.

    WHEN 'REP'.

      INCLUDE zmm_ssession_upld_rep.

    WHEN 'UPLD'.

      include zmm_ssession_upld_upld.
  ENDCASE.


START-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Report ZMM_CONSUMPTION_UPLD1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_CONSUMPTION_UPLD1.

*&---------------------------------------------------------------------*
*& Report ZMM_CONSUMPTION_UPLD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*REPORT zmm_consumption_upld.

TYPES: BEGIN OF ty_alsmex,
         row   TYPE num06,
         col   TYPE num06,
         value TYPE char50,
       END OF ty_alsmex.
TYPES: BEGIN OF ty_data,
         mandt(3)   TYPE c, "  LIKE mveg_ueb-mandt,
         matnr(40)  TYPE c, "  LIKE mveg_ueb-matnr,
         werks(4)   TYPE c, "  LIKE mveg_ueb-werks,
         ertag(8)   TYPE c, " LIKE mveg_ueb-ertag,
         gvbwrt(16) TYPE c, " LIKE mveg_ueb-vbwrt,
         gkovbw(16) TYPE c, " LIKE mveg_ueb-kovbw,
         gantei(6)  TYPE c, " LIKE mveg_ueb-antei,
         uvbwrt(16) TYPE c, " LIKE mveu_ueb-vbwrt,
         ukovbw(16) TYPE c, " LIKE mveu_ueb-kovbw,
         uantei(6)  TYPE c, " LIKE mveu_ueb-antei,
       END OF ty_data.
DATA: lt_con  TYPE STANDARD TABLE OF ty_data,
      wa_con  TYPE ty_data,
      lv_file TYPE string,
      lv_path TYPE string,
      lv_rc   TYPE i.
DATA lt_file_info TYPE filetable.

DATA : itab1 LIKE alsmex_tabline OCCURS 0 WITH HEADER LINE.
DATA lt_tab TYPE STANDARD TABLE OF alsmex_tabline.
DATA wa_tab TYPE  alsmex_tabline.
DATA cn_txt_sep TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.


DATA: BEGIN OF wa_vb,
        mandt  LIKE mveg_ueb-mandt,
        matnr  LIKE mveg_ueb-matnr,
        werks  LIKE mveg_ueb-werks,
        ertag  LIKE  mveg_ueb-ertag,
        gvbwrt LIKE mveg_ueb-vbwrt,
        gkovbw LIKE mveg_ueb-kovbw,
        gantei LIKE mveg_ueb-antei,
        uvbwrt LIKE mveu_ueb-vbwrt,
        ukovbw LIKE mveu_ueb-kovbw,
        uantei LIKE mveu_ueb-antei.
DATA: END OF wa_vb.

DATA: wa_vb_tab LIKE wa_vb OCCURS 0 WITH HEADER LINE.
*                   WITH FRAME TITLE t%%_t_1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.

  PARAMETERS: pv_file TYPE localfile.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 4(60) TEXT-003.
  SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK b1.


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


START-OF-SELECTION.
  IF pv_file CA '.xls' OR pv_file CA '.xlsx'.
  ELSE.
    MESSAGE ' Please enter excel file only' TYPE 'E'.
  ENDIF.


  CONCATENATE '/usr/sap/trans/Consumption_' sy-datum '_' sy-uzeit '.dat' INTO lv_path.




  DATA lt_raw TYPE truxs_t_text_data.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
      i_line_header        = abap_true
      i_tab_raw_data       = lt_raw
      i_filename           = pv_file
*     I_STEP               = 1
    TABLES
      i_tab_converted_data = lt_con
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  LOOP AT lt_con INTO wa_con.

    CLEAR wa_vb_tab.
    wa_vb_tab-mandt = wa_con-mandt.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = wa_con-matnr
      IMPORTING
        output       = wa_con-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    wa_vb_tab-matnr = wa_con-matnr.
    wa_vb_tab-werks = wa_con-werks.
    wa_vb_tab-ertag = wa_con-ertag.
    wa_vb_tab-gvbwrt = wa_con-gvbwrt.
    wa_vb_tab-gkovbw = wa_con-gkovbw.
    wa_vb_tab-gantei = wa_con-gantei.
    wa_vb_tab-uvbwrt = wa_con-uvbwrt.
    wa_vb_tab-ukovbw = wa_con-ukovbw.
    wa_vb_tab-uantei = wa_con-uantei.
    APPEND wa_vb_tab.
  ENDLOOP.


  DATA: big_wa LIKE tedata-data OCCURS 0 WITH HEADER LINE.
  DATA: wa LIKE tedata-data.
  SORT wa_vb_tab BY mandt matnr werks.

  LOOP AT wa_vb_tab.


    CLEAR wa.
    CLASS cl_abap_container_utilities DEFINITION LOAD.        "Unicode
    CALL METHOD cl_abap_container_utilities=>fill_container_c
      EXPORTING
        im_value               = wa_vb_tab
      IMPORTING
        ex_container           = wa
      EXCEPTIONS
        illegal_parameter_type = 1
        OTHERS                 = 2.

    big_wa = wa.
    APPEND big_wa.
  ENDLOOP.




*
*  OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
*  IF sy-subrc NE 0.
*    MESSAGE e002(mg) WITH lv_path.
*  ENDIF.
*  LOOP AT big_wa.
*    TRANSFER big_wa TO lv_path.
*    IF sy-subrc NE 0.
*      MESSAGE e001(mg) WITH lv_path.
*    ENDIF.
*  ENDLOOP.
*  CLOSE DATASET lv_path.
*
*
*  SUBMIT mver_di WITH %%%_r_p = 'X'
*                   WITH   %%%_phy = lv_path .

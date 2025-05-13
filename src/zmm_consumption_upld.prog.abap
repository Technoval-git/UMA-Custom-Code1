*&---------------------------------------------------------------------*
*& Report ZMM_CONSUMPTION_UPLD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_consumption_upld.

TYPES: BEGIN OF ty_alsmex,
         row   TYPE num06,
         col   TYPE num06,
         value TYPE char50,
       END OF ty_alsmex.
*TYPES: BEGIN OF ty_data,
*         mandt(3)   TYPE c, "  LIKE mveg_ueb-mandt,
*         matnr(40)  TYPE c, "  LIKE mveg_ueb-matnr, Part
*         werks(4)   TYPE c, "  LIKE mveg_ueb-werks, Plant
*         ertag(8)   TYPE c, " LIKE mveg_ueb-ertag,  Period
*         gvbwrt(16) TYPE c, " LIKE mveg_ueb-vbwrt,
*         gkovbw(16) TYPE c, " LIKE mveg_ueb-kovbw, corrected consumption
*         gantei(6)  TYPE c, " LIKE mveg_ueb-antei,
*         uvbwrt(16) TYPE c, " LIKE mveu_ueb-vbwrt,
*         ukovbw(16) TYPE c, " LIKE mveu_ueb-kovbw,
*         uantei(6)  TYPE c, " LIKE mveu_ueb-antei,
*       END OF ty_data.
TYPES: BEGIN OF ty_data,
         matnr(40)   TYPE c, "  LIKE mveg_ueb-matnr, Part
         maktx(40)   TYPE c,
         werks(4)    TYPE c, "  LIKE mveg_ueb-werks, Plant
         dec2024(16) TYPE  c, "mveg_ueb-kovbw,
         nov2024(16) TYPE c,
         oct2024(16) TYPE c,
         sep2024(16) TYPE c,
         aug2024(16) TYPE c,
         jul2024(16) TYPE c,
         jun2024(16) TYPE c,
         may2024(16) TYPE c,
         apr2024(16) TYPE c,
         mar2024(16) TYPE c,
         feb2024(16) TYPE c,
         jan2024(16) TYPE c,
         dec2023(16) TYPE  c, "mveg_ueb-kovbw,
         nov2023(16) TYPE c,
         oct2023(16) TYPE c,
         sep2023(16) TYPE c,
         aug2023(16) TYPE c,
         jul2023(16) TYPE c,
         jun2023(16) TYPE c,
         may2023(16) TYPE c,
         apr2023(16) TYPE c,
         mar2023(16) TYPE c,
         feb2023(16) TYPE c,
         jan2023(16) TYPE c,
         dec2022(16) TYPE c,
         nov2022(16) TYPE c,
         oct2022(16) TYPE c,
         sep2022(16) TYPE c,
         aug2022(16) TYPE c,
         jul2022(16) TYPE c,
         jun2022(16) TYPE c,
         may2022(16) TYPE c,
         apr2022(16) TYPE c,
         mar2022(16) TYPE c,
         feb2022(16) TYPE c,
         jan2022(16) TYPE c,
         dec2021(16) TYPE c,
         nov2021(16) TYPE c,
         oct2021(16) TYPE c,
         sep2021(16) TYPE c,
         aug2021(16) TYPE c,
         jul2021(16) TYPE c,
         jun2021(16) TYPE c,
         may2021(16) TYPE c,
         apr2021(16) TYPE c,
         mar2021(16) TYPE c,
         feb2021(16) TYPE c,
         jan2021(16) TYPE c,

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

TYPES: BEGIN OF wa_VB_row,
         mandt   TYPE mandt,
         matnr   LIKE mveg_ueb-matnr,
         maktx   LIKE makt-maktx,
         werks   LIKE mveg_ueb-werks,
         dec2024 TYPE  mveg_ueb-kovbw,
         nov2024 TYPE mveg_ueb-kovbw,
         oct2024 TYPE mveg_ueb-kovbw,
         sep2024 TYPE mveg_ueb-kovbw,
         aug2024 TYPE mveg_ueb-kovbw,
         jul2024 TYPE mveg_ueb-kovbw,
         jun2024 TYPE mveg_ueb-kovbw,
         may2024 TYPE mveg_ueb-kovbw,
         apr2024 TYPE mveg_ueb-kovbw,
         mar2024 TYPE mveg_ueb-kovbw,
         feb2024 TYPE mveg_ueb-kovbw,
         jan2024 TYPE mveg_ueb-kovbw,
         dec2023 TYPE  mveg_ueb-kovbw,
         nov2023 TYPE mveg_ueb-kovbw,
         oct2023 TYPE mveg_ueb-kovbw,
         sep2023 TYPE mveg_ueb-kovbw,
         aug2023 TYPE mveg_ueb-kovbw,
         jul2023 TYPE mveg_ueb-kovbw,
         jun2023 TYPE mveg_ueb-kovbw,
         may2023 TYPE mveg_ueb-kovbw,
         apr2023 TYPE mveg_ueb-kovbw,
         mar2023 TYPE mveg_ueb-kovbw,
         feb2023 TYPE mveg_ueb-kovbw,
         jan2023 TYPE mveg_ueb-kovbw,
         dec2022 TYPE  mveg_ueb-kovbw,
         nov2022 TYPE mveg_ueb-kovbw,
         oct2022 TYPE mveg_ueb-kovbw,
         sep2022 TYPE mveg_ueb-kovbw,
         aug2022 TYPE mveg_ueb-kovbw,
         jul2022 TYPE mveg_ueb-kovbw,
         jun2022 TYPE mveg_ueb-kovbw,
         may2022 TYPE mveg_ueb-kovbw,
         apr2022 TYPE mveg_ueb-kovbw,
         mar2022 TYPE mveg_ueb-kovbw,
         feb2022 TYPE mveg_ueb-kovbw,
         jan2022 TYPE mveg_ueb-kovbw,
         dec2021 TYPE  mveg_ueb-kovbw,
         nov2021 TYPE mveg_ueb-kovbw,
         oct2021 TYPE mveg_ueb-kovbw,
         sep2021 TYPE mveg_ueb-kovbw,
         aug2021 TYPE mveg_ueb-kovbw,
         jul2021 TYPE mveg_ueb-kovbw,
         jun2021 TYPE mveg_ueb-kovbw,
         may2021 TYPE mveg_ueb-kovbw,
         apr2021 TYPE mveg_ueb-kovbw,
         mar2021 TYPE mveg_ueb-kovbw,
         feb2021 TYPE mveg_ueb-kovbw,
         jan2021 TYPE mveg_ueb-kovbw,

       END OF wa_vb_row.

DATA: it_vb_tab_row TYPE STANDARD TABLE OF  wa_vb_row.
DATA: wa_vb_tab_row TYPE wa_vb_row.
TYPES: BEGIN OF wa_vb,
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
TYPES: END OF wa_vb.

DATA: it_vb_tab TYPE STANDARD TABLE OF wa_vb,
      wa_vb_tab TYPE wa_vb.
*DATA: wa_vb_tab LIKE wa_vb OCCURS 0 WITH HEADER LINE.
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
      IF sy-subrc > 0.
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
    wa_vb_tab-mandt = sy-mandt.
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
    wa_vb_tab-gvbwrt = ''.
    wa_vb_tab-gantei = ''.
    wa_vb_tab-uvbwrt = ''.
    wa_vb_tab-ukovbw = ''.
    wa_vb_tab-uantei = ''.


IF wa_con-dec2024 > 0.
      wa_vb_tab-ertag = '20241201'.
      wa_vb_tab-gkovbw = wa_con-dec2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.

    IF wa_con-nov2024 > 0.
      wa_vb_tab-ertag = '20241101'.
      wa_vb_tab-gkovbw = wa_con-nov2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-oct2024 > 0.
      wa_vb_tab-ertag = '20241001'.
      wa_vb_tab-gkovbw = wa_con-oct2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-sep2024 > 0.
      wa_vb_tab-ertag = '20240901'.
      wa_vb_tab-gkovbw = wa_con-sep2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-aug2024 > 0.
      wa_vb_tab-ertag = '20240801'.
      wa_vb_tab-gkovbw = wa_con-aug2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jul2024 > 0.
      wa_vb_tab-ertag = '20240701'.
      wa_vb_tab-gkovbw = wa_con-jul2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jun2024 > 0.
      wa_vb_tab-ertag = '20240601'.
      wa_vb_tab-gkovbw = wa_con-jun2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-may2024 > 0.
      wa_vb_tab-ertag = '20240501'.
      wa_vb_tab-gkovbw = wa_con-may2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-apr2024 > 0.
      wa_vb_tab-ertag = '20240401'.
      wa_vb_tab-gkovbw = wa_con-apr2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-mar2024 > 0.
      wa_vb_tab-ertag = '20240301'.
      wa_vb_tab-gkovbw = wa_con-mar2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-feb2024 > 0.
      wa_vb_tab-ertag = '20240201'.
      wa_vb_tab-gkovbw = wa_con-feb2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jan2024 > 0.
      wa_vb_tab-ertag = '20240101'.
      wa_vb_tab-gkovbw = wa_con-jan2024.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.


    IF wa_con-dec2023 > 0.
      wa_vb_tab-ertag = '20231201'.
      wa_vb_tab-gkovbw = wa_con-dec2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.

    IF wa_con-nov2023 > 0.
      wa_vb_tab-ertag = '20231101'.
      wa_vb_tab-gkovbw = wa_con-nov2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-oct2023 > 0.
      wa_vb_tab-ertag = '20231001'.
      wa_vb_tab-gkovbw = wa_con-oct2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-sep2023 > 0.
      wa_vb_tab-ertag = '20230901'.
      wa_vb_tab-gkovbw = wa_con-sep2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-aug2023 > 0.
      wa_vb_tab-ertag = '20230801'.
      wa_vb_tab-gkovbw = wa_con-aug2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jul2023 > 0.
      wa_vb_tab-ertag = '20230701'.
      wa_vb_tab-gkovbw = wa_con-jul2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jun2023 > 0.
      wa_vb_tab-ertag = '20230601'.
      wa_vb_tab-gkovbw = wa_con-jun2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-may2023 > 0.
      wa_vb_tab-ertag = '20230501'.
      wa_vb_tab-gkovbw = wa_con-may2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-apr2023 > 0.
      wa_vb_tab-ertag = '20230401'.
      wa_vb_tab-gkovbw = wa_con-apr2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-mar2023 > 0.
      wa_vb_tab-ertag = '20230301'.
      wa_vb_tab-gkovbw = wa_con-mar2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-feb2023 > 0.
      wa_vb_tab-ertag = '20230201'.
      wa_vb_tab-gkovbw = wa_con-feb2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jan2023 > 0.
      wa_vb_tab-ertag = '20230101'.
      wa_vb_tab-gkovbw = wa_con-jan2023.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-dec2022 > 0.
      wa_vb_tab-ertag = '20221201'.
      wa_vb_tab-gkovbw = wa_con-dec2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-nov2022 > 0.
      wa_vb_tab-ertag = '20221101'.
      wa_vb_tab-gkovbw = wa_con-nov2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-oct2022 > 0.
      wa_vb_tab-ertag = '20221001'.
      wa_vb_tab-gkovbw = wa_con-oct2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-sep2022 > 0.
      wa_vb_tab-ertag = '20220901'.
      wa_vb_tab-gkovbw = wa_con-sep2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-aug2022 > 0.
      wa_vb_tab-ertag = '20220801'.
      wa_vb_tab-gkovbw = wa_con-aug2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jul2022 > 0.
      wa_vb_tab-ertag = '20220701'.
      wa_vb_tab-gkovbw = wa_con-jul2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jun2022 > 0.
      wa_vb_tab-ertag = '20220601'.
      wa_vb_tab-gkovbw = wa_con-jun2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-may2022 > 0.
      wa_vb_tab-ertag = '20220501'.
      wa_vb_tab-gkovbw = wa_con-may2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-apr2022 > 0.
      wa_vb_tab-ertag = '20220401'.
      wa_vb_tab-gkovbw = wa_con-apr2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-mar2022 > 0.
      wa_vb_tab-ertag = '20220301'.
      wa_vb_tab-gkovbw = wa_con-mar2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-feb2022 > 0.
      wa_vb_tab-ertag = '20220201'.
      wa_vb_tab-gkovbw = wa_con-feb2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jan2022 > 0.
      wa_vb_tab-ertag = '20220101'.
      wa_vb_tab-gkovbw = wa_con-jan2022.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-dec2021 > 0.
      wa_vb_tab-ertag = '20211201'.
      wa_vb_tab-gkovbw = wa_con-dec2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-nov2021 > 0.
      wa_vb_tab-ertag = '20211101'.
      wa_vb_tab-gkovbw = wa_con-nov2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-oct2021 > 0.
      wa_vb_tab-ertag = '20211001'.
      wa_vb_tab-gkovbw = wa_con-oct2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-sep2021 > 0.
      wa_vb_tab-ertag = '20210901'.
      wa_vb_tab-gkovbw = wa_con-sep2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-aug2023 > 0.
      wa_vb_tab-ertag = '20210801'.
      wa_vb_tab-gkovbw = wa_con-aug2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jul2021 > 0.
      wa_vb_tab-ertag = '20210701'.
      wa_vb_tab-gkovbw = wa_con-jul2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jun2021 > 0.
      wa_vb_tab-ertag = '20210601'.
      wa_vb_tab-gkovbw = wa_con-jun2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-may2021 > 0.
      wa_vb_tab-ertag = '20210501'.
      wa_vb_tab-gkovbw = wa_con-may2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-apr2021 > 0.
      wa_vb_tab-ertag = '20210401'.
      wa_vb_tab-gkovbw = wa_con-apr2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-mar2021 > 0.

      wa_vb_tab-ertag = '20210301'.

      wa_vb_tab-gkovbw = wa_con-mar2021.

      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-feb2021 > 0.
      wa_vb_tab-ertag = '20210201'.
      wa_vb_tab-gkovbw = wa_con-feb2021.

      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.
    IF wa_con-jan2021 > 0.
      wa_vb_tab-ertag = '20210101'.
      wa_vb_tab-gkovbw = wa_con-jan2021.
      APPEND wa_vb_tab TO it_vb_tab.
    ENDIF.

  ENDLOOP.


  DATA: big_wa LIKE tedata-data OCCURS 0 WITH HEADER LINE.
  DATA: wa LIKE tedata-data.
  SORT it_vb_tab BY mandt matnr werks.

  LOOP AT it_vb_tab INTO wa_vb_tab.


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


  OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc NE 0.
    MESSAGE e002(mg) WITH lv_path.
  ENDIF.
  LOOP AT big_wa.
    TRANSFER big_wa TO lv_path.
    IF sy-subrc NE 0.
      MESSAGE e001(mg) WITH lv_path.
    ENDIF.
  ENDLOOP.
  CLOSE DATASET lv_path.


  SUBMIT mver_di WITH %%%_r_p = 'X'
                   WITH   %%%_phy = lv_path .

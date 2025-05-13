*&---------------------------------------------------------------------*
*& Report ZMM_STORAGE_BIN_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_storage_bin_update MESSAGE-ID m7 NO STANDARD PAGE HEADING LINE-SIZE 170.

TABLES: mard.
TYPES: BEGIN OF ty_bin_upld,
         matnr TYPE matnr,
         werks TYPE werks_d,
         lgort TYPE lgort_d,
         lgpbe TYPE lgpbe,
       END OF ty_bin_upld.

DATA: gt_bin_upld TYPE TABLE OF ty_bin_upld.
DATA: lt_con TYPE TABLE OF ty_bin_upld.
DATA: wa_con TYPE ty_bin_upld.
TYPES: BEGIN OF ty_messages,
         matnr TYPE matnr_ext,
         werks TYPE werks_d,
         lgort TYPE lgort_d.
         INCLUDE TYPE bapiret2.
TYPES: END OF ty_messages.

TYPES: BEGIN OF ty_main.
         INCLUDE TYPE ty_bin_upld.
TYPES:   last_gr_date TYPE dats,
       END OF ty_main.
DATA: gt_maintain TYPE TABLE OF ty_main,
      gt_mn_fcat  TYPE lvc_t_fcat.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive ,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.

DATA: gr_alv_m TYPE REF TO cl_gui_alv_grid,
      gr_cc_m  TYPE REF TO cl_gui_custom_container,
      gr_event TYPE REF TO lcl_event_handler.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_toolbar.
    PERFORM handle_toolbar USING e_object.
  ENDMETHOD.                    "handle_toolbar_soc_ct

  METHOD handle_user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.
ENDCLASS.

INCLUDE zimm_storage_bin_mb52.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: rb_upld RADIOBUTTON GROUP rb1 USER-COMMAND usr1 DEFAULT 'X',
              rb_main RADIOBUTTON GROUP rb1,
              rb_rprt RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS : p_f_path TYPE 	localfile MODIF ID md1.
  SELECT-OPTIONS: s_matnr FOR mard-matnr NO INTERVALS MODIF ID md2,
                  s_werks FOR mard-werks NO INTERVALS NO-EXTENSION MODIF ID md2,
                  s_lgort FOR mard-lgort MODIF ID md2.

  SELECTION-SCREEN BEGIN OF BLOCK abgrenzung WITH FRAME TITLE TEXT-081.

    SELECT-OPTIONS:
      matnr  FOR mara-matnr MEMORY ID mat MATCHCODE OBJECT mat1 MODIF ID md3,
      werks  FOR t001l-werks  MEMORY ID wrk MODIF ID md3,   "718285
      lgort  FOR t001l-lgort  MEMORY ID lag MODIF ID md3,
      charg  FOR mchb-charg  MEMORY ID cha MATCHCODE OBJECT mch1 MODIF ID md3.

  SELECTION-SCREEN END OF BLOCK abgrenzung.

*----------------------------------------------------------------------*

  SELECTION-SCREEN BEGIN OF BLOCK lbs WITH FRAME TITLE TEXT-082.

    SELECT-OPTIONS:
      matart FOR mara-mtart MODIF ID md3,
      matkla FOR mara-matkl MODIF ID md3,
      ekgrup FOR marc-ekgrp MODIF ID md3.
*ENHANCEMENT-POINT RM07MLBS_3 SPOTS ES_RM07MLBS STATIC .

  SELECTION-SCREEN END OF BLOCK lbs.

*----------------------------------------------------------------------*

* for the selection os special stocks
  SELECTION-SCREEN BEGIN OF BLOCK lb2 WITH FRAME TITLE TEXT-083.

* for the selection os special stocks
    PARAMETERS : pa_sond       LIKE      rmmmb-kzlso
                               DEFAULT   'X' MODIF ID md3.

    SELECT-OPTIONS:
      so_sobkz                 FOR  mkol-sobkz MODIF ID md3.

  SELECTION-SCREEN END OF BLOCK lb2.

*----------------------------------------------------------------------*

  SELECTION-SCREEN BEGIN OF BLOCK lb1 WITH FRAME TITLE TEXT-084.

* select only lines who contain at least one negative stock
    PARAMETERS: negativ LIKE am07m-seneg MODIF ID md3.

* Documentation for parameter XMCHB improved                "n494306
    PARAMETERS: xmchb            LIKE      am07m-mb52_xmchb "n494306
                                 DEFAULT   'X' MODIF ID md3.

* Checkbox to eliminate lines with zero stocks
    PARAMETERS: nozero   LIKE rmmmb-kznul MODIF ID md3.

* Checkbox to disable value processing.
* Documentation for parameter NOVALUES improved             "n494306
    PARAMETERS: novalues         LIKE      am07m-mb52_noval MODIF ID md3. "n494306


  SELECTION-SCREEN END OF BLOCK lb1.

*----------------------------------------------------------------------*

  SELECTION-SCREEN BEGIN OF BLOCK liste WITH FRAME TITLE TEXT-085.

* choose flat or hierarchic list                            "n531604
    SELECTION-SCREEN BEGIN OF LINE.                         "n531604
      SELECTION-SCREEN         POSITION 1.                  "n531604
      PARAMETERS : pa_hsq      LIKE  am07m-mb52_alv_hsq  "#EC SEL_WRONG
                               DEFAULT  'X'                 "n531604
                               RADIOBUTTON GROUP alvv       "n531604
                               USER-COMMAND alvv MODIF ID md3. "n531604
      SELECTION-SCREEN         COMMENT 3(40)  TEXT-086      "n531604
        FOR FIELD pa_hsq MODIF ID md3.                      "n531604
    SELECTION-SCREEN END OF LINE.                           "n531604
                                                            "n531604
    SELECTION-SCREEN BEGIN OF LINE.                         "n531604
      SELECTION-SCREEN         POSITION 1.                  "n531604
      PARAMETERS : pa_flt      LIKE  am07m-mb52_alv_flt  "#EC SEL_WRONG
                               RADIOBUTTON GROUP alvv MODIF ID md3. "n531604
      SELECTION-SCREEN         COMMENT 3(40)  TEXT-087      "n531604
        FOR FIELD pa_flt MODIF ID md3.                      "n531604
    SELECTION-SCREEN END OF LINE.                           "n531604

*  parameters :
*    pa_grid                  type  MB_XFELD
*                             default 'X'
*                             radiobutton group alv1,
*    pa_class                 type  MB_XFELD
*                             radiobutton group alv1.

    PARAMETERS: p_vari LIKE disvariant-variant MODIF ID md3.

  SELECTION-SCREEN END OF BLOCK liste.

SELECTION-SCREEN END OF BLOCK b2.

* F4-Help for variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_f_path.
  PERFORM f_file_browser.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE 'X'.
      WHEN rb_upld.
        IF screen-group1 = 'MD1'.
          screen-invisible = 0.
          screen-active = 1.
        ELSEIF screen-group1 IS NOT INITIAL.
          screen-invisible = 1.
          screen-active = 0.
        ENDIF.
      WHEN rb_main.
        IF screen-group1 = 'MD2'.
          screen-invisible = 0.
          screen-active = 1.
        ELSEIF screen-group1 IS NOT INITIAL.
          screen-invisible = 1.
          screen-active = 0.
        ENDIF.
      WHEN rb_rprt.
        IF screen-group1 = 'MD3'.
          screen-invisible = 0.
          screen-active = 1.
        ELSEIF screen-group1 IS NOT INITIAL.
          screen-invisible = 1.
          screen-active = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

  IF lines( s_matnr[] ) GT 20.
    SET CURSOR FIELD 'S_MATNR-LOW'.
    RETURN.
  ENDIF.

  IF rb_upld = 'X' AND p_f_path IS INITIAL.
    SET CURSOR FIELD 'P_F_PATH'.
    RETURN.
  ENDIF.

  IF rb_main = 'X'.
    IF s_matnr[] IS INITIAL.
      SET CURSOR FIELD 'S_MATNR-LOW'.
      RETURN.
    ENDIF.
    IF s_werks[] IS INITIAL.
      SET CURSOR FIELD 'S_WERKS-LOW'.
      RETURN.
    ENDIF.
    IF s_lgort[] IS INITIAL..
      SET CURSOR FIELD 'S_LGORT-LOW'.
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT s_matnr.
    IF s_matnr-low CS '*'.
      SET CURSOR FIELD 'S_MATNR-LOW'.
      RETURN.
    ENDIF.
  ENDLOOP.

  IF s_werks-low CS '*'.
    SET CURSOR FIELD 'S_WERKS-LOW'.
    RETURN.
  ENDIF.

  IF rb_rprt IS NOT INITIAL.
    IF  g_flag_initialization IS INITIAL.                   "n667256
*   the process time INITIALIZATION was not done, so        "n667256
*   carry out the functions here                            "n667256
      MOVE  'X'                TO g_flag_initialization.    "n667256
                                                            "n667256
      PERFORM                  f0000_get_print_settings.    "n667256
                                                            "n667256
*   look for the setting of the parameters from the         "n667256
*   last run                                                "n667256
      PERFORM                  f0100_settings_init.         "n667256
                                                            "n667256
      PERFORM                  initialisierung.             "n667256
    ENDIF.                                                  "n667256
  ENDIF.

AT SELECTION-SCREEN.

  IF rb_upld = 'X' AND p_f_path IS INITIAL.
    MESSAGE TEXT-004 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF rb_main = 'X'.
    IF lines( s_matnr[] ) GT 20.
      MESSAGE TEXT-003 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    IF s_matnr[] IS INITIAL.
      MESSAGE TEXT-005 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    IF s_werks[] IS INITIAL.
      MESSAGE TEXT-006 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    IF s_lgort[] IS INITIAL.
      MESSAGE TEXT-090 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT s_matnr.
    IF s_matnr-low CS '*'.
      MESSAGE TEXT-008 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.

  IF s_werks-low CS '*'.
    MESSAGE TEXT-009 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF rb_rprt IS NOT INITIAL.
* check radiobuttons                                          "n667256
    IF  pa_hsq IS INITIAL.                                  "n667256
      IF  pa_flt IS INITIAL.                                "n667256
*     not allowed                                             "n667256
        MOVE  'X'              TO  pa_hsq.                  "n667256
        ADD  1                 TO  g_cnt_variant_error.     "n667256
      ENDIF.                                                "n667256
    ELSE.                                                   "n667256
      IF  pa_flt IS INITIAL.                                "n667256
      ELSE.                                                 "n667256
*     not allowed                                             "n667256
        CLEAR                  pa_flt.                      "n667256
        ADD  1                 TO  g_cnt_variant_error.     "n667256
      ENDIF.                                                "n667256
    ENDIF.                                                  "n667256
                                                            "n667256
* the user will get the info about the old variant only once  "n667256
    IF  g_cnt_variant_error = 1.                            "n667256
      IF  NOT sy-slset IS INITIAL.                          "n667256
        MESSAGE i634(db)       WITH  sy-slset sy-repid.     "n667256
      ENDIF.                                                "n667256
    ENDIF.                                                  "n667256

* has the user changed the radiobuttons for the mode of the "n531604
* SAP-LIST-VIEWER ?                                         "n531604
    IF  sscrfields-ucomm  =  'ALVV'.
*   yes, restore the old entry if extists                   "n531604
      IF      NOT pa_hsq IS INITIAL.
        MOVE  g_f_vari_hsq     TO  p_vari.
      ELSEIF  NOT  pa_flt IS INITIAL.
*     for flat ( simple ) list
        MOVE  g_f_vari_flt     TO  p_vari.
      ENDIF.

    ELSE.
*   save the display variant depending on the selected mode "n531604
*   of the SAP-LIST-VIEWER
      IF      NOT pa_hsq IS INITIAL.
*     for hierarchic seq. list
        MOVE p_vari            TO  g_f_vari_hsq.

      ELSEIF  NOT  pa_flt IS INITIAL.
*     for flat ( simple ) list
        MOVE p_vari            TO  g_f_vari_flt.

      ENDIF.
    ENDIF.

* it is necessary to set flag xmchb if batch has been entered because
* otherwise MCHB will not be read and non suitable items can't be
* be removed later on in form data_selection
    IF NOT charg[] IS INITIAL. xmchb = 'X'. ENDIF.    "note 311770

* send a warning if the user starts this report without any "n531604
* restrictions for the database selection                   "n531604
* only when this report is started                          "n531604
    IF matnr IS INITIAL AND                                 "n531604
       werks IS INITIAL AND                                 "n531604
       lgort IS INITIAL AND                                 "n531604
       charg IS INITIAL.                                    "n531604
      IF  sy-ucomm  =  'ONLI'  OR                           "n531604
          sy-ucomm  =  'PRIN'.                              "n531604
*ENHANCEMENT-SECTION EHP604_RM07MLBS_43 SPOTS ES_RM07MLBS .
        MESSAGE  w689.    "The selection was not restricted   "n531604
*END-ENHANCEMENT-SECTION.
      ENDIF.                                                "n531604
    ENDIF.                                                  "n531604
* go on only if the user wants to launch this report        "n667256
* the authorization check should be always processed        "n829722
    IF sy-ucomm = 'ONLI' OR                                 "n829722
       sy-ucomm = 'PRIN' OR                                 "n829722
       sy-ucomm = 'SJOB' OR                                 "n829722
       sy-ucomm = space.                                    "n829722
      MOVE 'X' TO t_flag_launched.                          "n829722
    ELSE.                                                   "n829722
      IF sy-ucomm <> space.                                 "n829722
        CLEAR t_flag_launched.                              "n829722
      ENDIF.                                                "n829722
    ENDIF.                                                  "n829722
    CHECK t_flag_launched = 'X'.                            "n829722

    PERFORM organisation.

    PERFORM check_entry.

    PERFORM check_authorization.

* save the parameters of this run in database table ESDUS   "n531604
    PERFORM                    f0200_settings_save.         "n531604
  ENDIF.

*------------------------ Initialisierung -----------------------------*
INITIALIZATION.
*ENHANCEMENT-POINT RM07MLBS_05 SPOTS ES_RM07MLBS.
  PERFORM                    f0000_get_print_settings.      "n531604

* look for the setting of the parameters from the last run  "n531604
  PERFORM                    f0100_settings_init.           "n531604

  PERFORM initialisierung.

* set flag when INITILIZATION is processed                  "n667256
  MOVE  'X'        TO  g_flag_initialization.               "n667256

START-OF-SELECTION.
  PERFORM f_scrn_validation.

  CASE 'X'.
    WHEN rb_upld.
      PERFORM f_read_file.
      PERFORM f_update_bin.
    WHEN rb_main.
      PERFORM f_read_maintn.
      PERFORM f_disp_alv.
    WHEN rb_rprt.
      PERFORM f_read_rprt_data.
  ENDCASE.

*------------------------- End of selection ---------------------------*
END-OF-SELECTION.
  IF rb_rprt IS NOT INITIAL.
    PERFORM f_dis_rprt_alv.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  F_READ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_read_file .
  DATA lwf_filename LIKE  rlgrap-filename.
  DATA intern      TYPE STANDARD TABLE OF alsmex_tabline.
  DATA: wf_row_number TYPE i,
        fs_record     LIKE LINE OF gt_bin_upld,
        lv_matnr_ext  TYPE matnr_ext.

  CLEAR: gt_bin_upld.
  lwf_filename = p_f_path.


*  BREAK-POINT.

  FIELD-SYMBOLS : <gt_data_h> TYPE STANDARD TABLE,
                  <gt_data_l> TYPE ANY TABLE,
                  <gt_table>  TYPE STANDARD TABLE,
                  <gs_table>  TYPE any.
  DATA : lv_filename      TYPE string,
         lt_records       TYPE solix_tab,
         lv_headerxstring TYPE xstring,
         lv_filelength    TYPE i.
  lv_filename = p_f_path.
*  lv_filename = pv_file.

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
*      IF lv_woksheetname EQ 'Sheet1'.
      IF lv_woksheetname is NOT INITIAL.
        DATA(lr_descr) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( wa_con ) ).
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
*            IF lv_woksheetname EQ 'Sheet1'.
*            BREAK-POINT.
            IF lv_woksheetname is not INITIAL.
              ASSIGN COMPONENT ls_compont-name OF STRUCTURE wa_con TO FIELD-SYMBOL(<ls_file>).
            ENDIF.
            IF sy-subrc IS INITIAL.
              <ls_file> = <ls_fld>.
            ENDIF.
          ENDIF.
        ENDLOOP.
*        IF wa_con IS NOT INITIAL AND lv_woksheetname EQ 'Sheet1'.
        IF wa_con IS NOT INITIAL.
          APPEND wa_con TO gt_bin_upld.
        ENDIF.
        CLEAR :wa_con.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

*  BREAK-POINT.

*  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
*    EXPORTING
*      filename                = lwf_filename
*      i_begin_col             = 1
*      i_begin_row             = 2
*      i_end_col               = 10
*      i_end_row               = 10000
*    TABLES
*      intern                  = intern
*    EXCEPTIONS
*      inconsistent_parameters = 1
*      upload_ole              = 2.
*
*  IF sy-subrc = 0.
*
*    LOOP AT intern ASSIGNING FIELD-SYMBOL(<fs_cell>).
*
*      IF wf_row_number IS INITIAL.
*        wf_row_number = <fs_cell>-row.
*        CLEAR fs_record.
*      ELSEIF <fs_cell>-row <> wf_row_number.
*        APPEND fs_record TO gt_bin_upld.
*        wf_row_number = <fs_cell>-row.
*        CLEAR fs_record.
*      ENDIF.
*
*      CASE <fs_cell>-col.
*        WHEN 1."material number
*          lv_matnr_ext = <fs_cell>-value.
*          CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
*            EXPORTING
*              input        = lv_matnr_ext
*            IMPORTING
*              output       = fs_record-matnr
*            EXCEPTIONS
*              length_error = 1
*              OTHERS       = 2.
*        WHEN 2."plant
*          fs_record-werks = <fs_cell>-value.
*        WHEN 3."storage location
*          fs_record-lgort = <fs_cell>-value.
*        WHEN 4."Bin
*          fs_record-lgpbe = <fs_cell>-value.
*        WHEN OTHERS.
*      ENDCASE.
*
*    ENDLOOP.
*
*    IF fs_record IS NOT INITIAL.
*      APPEND fs_record TO gt_bin_upld.
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_BIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_bin .


  DATA: ls_head      TYPE bapimathead,
        ls_return    TYPE bapiret2,
        lt_return    TYPE bapiret2_t,
        ls_stor_loc  TYPE bapi_mard,
        ls_stor_locx TYPE bapi_mardx,
        lt_messages  TYPE TABLE OF ty_messages,
        ls_messages  TYPE ty_messages,
        ls_variant   TYPE disvariant,
        lt_fldcat    TYPE slis_t_fieldcat_alv,
        ls_fldcat    LIKE LINE OF lt_fldcat.

  LOOP AT gt_bin_upld INTO DATA(ls_bin).
    ls_head-material = ls_bin-matnr.
    ls_head-storage_view = 'X'.

    ls_stor_loc-plant = ls_bin-werks.
    ls_stor_loc-stge_loc = ls_bin-lgort.
    ls_stor_loc-stge_bin = ls_bin-lgpbe.

    ls_stor_locx-plant = ls_bin-werks.
    ls_stor_locx-stge_loc = ls_bin-lgort.
    ls_stor_locx-stge_bin = 'X'.

    CLEAR: ls_return.
    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata             = ls_head
        storagelocationdata  = ls_stor_loc
        storagelocationdatax = ls_stor_locx
      IMPORTING
        return               = ls_return
      TABLES
        returnmessages       = lt_return.
    CLEAR: ls_messages.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = ls_bin-matnr
      IMPORTING
        output = ls_messages-matnr.
    ls_messages-werks = ls_bin-werks.
    ls_messages-lgort = ls_bin-lgort.

    READ TABLE lt_return TRANSPORTING NO FIELDS
      WITH KEY type = 'E'.
    IF sy-subrc = 0.
      LOOP AT lt_return INTO ls_return.
        MOVE-CORRESPONDING ls_return TO ls_messages.
        APPEND ls_messages TO lt_messages.
      ENDLOOP.
    ELSE.
      ls_messages-id = 'YMSG_JET_DBM'.
      ls_messages-number = '470'.
      ls_messages-type = 'S'.
      ls_messages-message_v1 = ls_bin-lgpbe.
      ls_messages-message_v2 = ls_bin-matnr.
      ls_messages-message_v3 = ls_bin-werks.
      ls_messages-message_v4 = ls_bin-lgort.
      MESSAGE ID ls_messages-id TYPE ls_messages-type
        NUMBER ls_messages-number WITH ls_messages-message_v1
        ls_messages-message_v2 ls_messages-message_v3 ls_messages-message_v4
        INTO ls_messages-message.
      APPEND ls_messages TO lt_messages.
    ENDIF.
  ENDLOOP.

  IF lt_messages IS NOT INITIAL.
    ls_variant-report = sy-repid.
    ls_variant-handle = '0001'.

    PERFORM f_messages_fcat CHANGING lt_fldcat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_structure_name = 'LT_MESSAGES'    " Internal output table structure name
        it_fieldcat      = lt_fldcat    " Field catalog with field descriptions
        i_save           = 'X'    " Variants can be saved
        is_variant       = ls_variant    " Variant information
*       i_screen_start_column       = 0    " Coordinates for list in dialog box
*       i_screen_start_line         = 0    " Coordinates for list in dialog box
*       i_screen_end_column         = 0    " Coordinates for list in dialog box
*       i_screen_end_line           = 0    " Coordinates for list in dialog box
      TABLES
        t_outtab         = lt_messages    " Table with data to be displayed
      EXCEPTIONS
        program_error    = 1
        OTHERS           = 2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILE_BROWSER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_file_browser .
  DATA file_table        TYPE filetable.
  DATA rc                TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    CHANGING
      file_table              = file_table
      rc                      = rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
  ).
  IF rc = 1.

    READ TABLE file_table ASSIGNING FIELD-SYMBOL(<fs_filename>) INDEX 1.
    IF sy-subrc = 0.
      p_f_path = <fs_filename>-filename.
    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_ADD_TO_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0442   text
*      -->P_0443   text
*      -->P_0444   text
*      -->P_0445   text
*      <--P_LT_FLDCAT  text
*----------------------------------------------------------------------*
FORM f_add_to_fcat  USING iv_field TYPE string
                          iv_table TYPE string
                          iv_text TYPE string
                          iv_key TYPE string
                    CHANGING ct_fldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fcat LIKE LINE OF ct_fldcat.

  ls_fcat-fieldname = iv_field.
  ls_fcat-tabname = iv_table.
  ls_fcat-seltext_s = ls_fcat-seltext_m = ls_fcat-seltext_l = iv_text.
  ls_fcat-key = iv_key.
  INSERT ls_fcat INTO ct_fldcat INDEX 1.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_READ_MAINTN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_read_maintn .

  DATA: ls_maintain TYPE ty_main.
  SELECT matnr, werks, lgort, lgpbe
    FROM mard
    INTO TABLE @DATA(lt_mard)
    WHERE matnr IN @s_matnr
      AND werks IN @s_werks
  AND lgort IN @s_lgort.
  SELECT matnr, werks, lgort, MAX( budat_mkpf ) AS budat_mkpf
    FROM mseg
    INTO TABLE @DATA(lt_mseg)
    WHERE matnr IN @s_matnr
      AND werks IN @s_werks
      AND lgort IN @s_lgort
  GROUP BY matnr, werks, lgort.

  LOOP AT lt_mard INTO DATA(ls_mard).

    MOVE-CORRESPONDING ls_mard TO ls_maintain.
    READ TABLE lt_mseg INTO DATA(ls_mseg)
      WITH KEY matnr = ls_maintain-matnr
               werks = ls_maintain-werks
               lgort = ls_maintain-lgort.
    IF sy-subrc = 0 .
      ls_maintain-last_gr_date = ls_mseg-budat_mkpf.
    ENDIF.

    APPEND ls_maintain TO gt_maintain.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISP_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_disp_alv .
  CALL SCREEN 1001.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  STATUS_1001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  DATA: ls_layout  TYPE lvc_s_layo,
        ls_variant TYPE disvariant.
  SET PF-STATUS 'MAINTN'.
*  SET TITLEBAR 'xxx'.
  IF gr_alv_m IS NOT BOUND.
    IF gr_cc_m IS NOT BOUND.
      CREATE OBJECT gr_cc_m
        EXPORTING
          container_name              = 'CC_MN'
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          OTHERS                      = 6.
    ENDIF.

    CREATE OBJECT gr_alv_m
      EXPORTING
        i_parent          = gr_cc_m    " Parent Container
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.

    IF gr_alv_m IS BOUND.

      CREATE OBJECT gr_event.
      SET HANDLER gr_event->handle_toolbar FOR gr_alv_m.
      SET HANDLER gr_event->handle_user_command FOR gr_alv_m.

      PERFORM f_fill_fcat_m CHANGING gt_mn_fcat.
      ls_variant-report = sy-repid.
      ls_variant-handle = '0003'.
      ls_layout-zebra = 'X'.
      CALL METHOD gr_alv_m->set_table_for_first_display
        EXPORTING
          is_variant                    = ls_variant    " Layout
          i_save                        = 'X'    " Save Layout
          i_default                     = 'X'    " Default Display Variant
          is_layout                     = ls_layout    " Layout
        CHANGING
          it_outtab                     = gt_maintain    " Output Table
          it_fieldcatalog               = gt_mn_fcat    " Field Catalog
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4.
    ENDIF.
  ELSE.
    CALL METHOD gr_alv_m->refresh_table_display.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
  IF sy-ucomm = 'BACK'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*----------------------------------------------------------------------*
FORM handle_toolbar  USING    p_e_object TYPE REF TO cl_alv_event_toolbar_set.
  DATA: ts_toolbar TYPE stb_button.

  CLEAR ts_toolbar.
  MOVE 'FC_UPD' TO ts_toolbar-function.                     "#EC NOTEXT
  MOVE icon_system_save TO ts_toolbar-icon.
  MOVE 'Update' TO ts_toolbar-text.
  MOVE 'Update' TO ts_toolbar-quickinfo.                    "#EC NOTEXT
  APPEND ts_toolbar TO p_e_object->mt_toolbar.

  DELETE p_e_object->mt_toolbar WHERE function = '&CHECK'.
  DELETE p_e_object->mt_toolbar WHERE function = '&REFRESH'.
  DELETE p_e_object->mt_toolbar WHERE function = '&&SEP01'.
  DELETE p_e_object->mt_toolbar WHERE function = '&LOCAL&CUT'.
  DELETE p_e_object->mt_toolbar WHERE function = '&LOCAL&COPY'.
  DELETE p_e_object->mt_toolbar WHERE function = '&LOCAL&PASTE'.
  DELETE p_e_object->mt_toolbar WHERE function = '&LOCAL&UNDO'.
  DELETE p_e_object->mt_toolbar WHERE function = '&&SEP02'.
  DELETE p_e_object->mt_toolbar WHERE function = '&LOCAL&APPEND'.
  DELETE p_e_object->mt_toolbar WHERE function = '&LOCAL&INSERT_ROW'.
  DELETE p_e_object->mt_toolbar WHERE function = '&LOCAL&DELETE_ROW'.
  DELETE p_e_object->mt_toolbar WHERE function = '&LOCAL&COPY_ROW'.
  DELETE p_e_object->mt_toolbar WHERE function = '&&SEP03'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM handle_user_command  USING    p_e_ucomm TYPE syucomm.
  CASE  p_e_ucomm.
    WHEN 'FC_UPD'.
      PERFORM f_upd_m.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FCAT_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_fill_fcat_m CHANGING ct_fcat TYPE lvc_t_fcat.
  PERFORM f_add_field_fcat_m USING 'MATNR' 'GT_MAINTAIN' 'Material' '' '' CHANGING ct_fcat.
  PERFORM f_add_field_fcat_m USING 'WERKS' 'GT_MAINTAIN' 'Plant' '' '' CHANGING ct_fcat.
  PERFORM f_add_field_fcat_m USING 'LGORT' 'GT_MAINTAIN' 'Storage Loc.' '' '' CHANGING ct_fcat.
  PERFORM f_add_field_fcat_m USING 'LAST_GR_DATE' 'GT_MAINTAIN' 'Last Gr Date' '' '' CHANGING ct_fcat.
  PERFORM f_add_field_fcat_m USING 'LGPBE' 'GT_MAINTAIN' 'Stor. Bin' '' 'X' CHANGING ct_fcat.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_ADD_FIELD_FCAT_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1159   text
*      -->P_1160   text
*      -->P_1161   text
*      -->P_1162   text
*      -->P_1163   text
*      <--P_CT_FCAT  text
*----------------------------------------------------------------------*
FORM f_add_field_fcat_m  USING iv_field TYPE string
                               iv_tab TYPE string
                               iv_desc TYPE string
                               iv_key TYPE string
                               iv_edit TYPE string
                         CHANGING ct_fcat TYPE lvc_t_fcat.
  DATA:ls_fcat TYPE lvc_s_fcat.

  ls_fcat-fieldname = iv_field.
  ls_fcat-tabname = iv_tab.
  ls_fcat-scrtext_s = ls_fcat-scrtext_m = ls_fcat-scrtext_l = iv_desc.
  ls_fcat-key = iv_key.
  ls_fcat-edit = iv_edit.
  APPEND ls_fcat TO ct_fcat.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UPD_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_upd_m .
  DATA: lt_row_ids TYPE lvc_t_roid,
        ls_row_id  TYPE lvc_s_roid.
  DATA: ls_head      TYPE bapimathead,
        ls_return    TYPE bapiret2,
        lt_return    TYPE bapiret2_t,
        ls_stor_loc  TYPE bapi_mard,
        ls_stor_locx TYPE bapi_mardx,
        lt_messages  TYPE TABLE OF ty_messages,
        ls_messages  TYPE ty_messages,
        ls_variant   TYPE disvariant,
        lt_fldcat    TYPE slis_t_fieldcat_alv,
        ls_fldcat    LIKE LINE OF lt_fldcat.

  CLEAR: lt_messages.
  CALL METHOD gr_alv_m->get_selected_rows
    IMPORTING
      et_row_no = lt_row_ids.

  IF lt_row_ids IS INITIAL.
    MESSAGE TEXT-007 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  LOOP AT lt_row_ids INTO ls_row_id.
    READ TABLE gt_maintain INTO DATA(ls_maintain)
      INDEX ls_row_id-row_id.
    IF sy-subrc = 0.
      CLEAR: ls_head, ls_stor_loc, ls_stor_locx,
             ls_return, lt_return.
      ls_head-material = ls_maintain-matnr.
      ls_head-storage_view = 'X'.

      ls_stor_loc-plant = ls_maintain-werks.
      ls_stor_loc-stge_loc = ls_maintain-lgort.
      ls_stor_loc-stge_bin = ls_maintain-lgpbe.

      ls_stor_locx-plant = ls_maintain-werks.
      ls_stor_locx-stge_loc = ls_maintain-lgort.
      ls_stor_locx-stge_bin = 'X'.

      CLEAR: ls_return.
      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          headdata             = ls_head
          storagelocationdata  = ls_stor_loc
          storagelocationdatax = ls_stor_locx
        IMPORTING
          return               = ls_return
        TABLES
          returnmessages       = lt_return.
      CLEAR: ls_messages.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = ls_maintain-matnr
        IMPORTING
          output = ls_messages-matnr.
      ls_messages-werks = ls_maintain-werks.
      ls_messages-lgort = ls_maintain-lgort.

      READ TABLE lt_return TRANSPORTING NO FIELDS
        WITH KEY type = 'E'.
      IF sy-subrc = 0.
        LOOP AT lt_return INTO ls_return.
          MOVE-CORRESPONDING ls_return TO ls_messages.
          APPEND ls_messages TO lt_messages.
        ENDLOOP.
      ELSE.
        ls_messages-id = 'YMSG_JET_DBM'.
        ls_messages-number = '470'.
        ls_messages-type = 'S'.
        ls_messages-message_v1 = ls_maintain-lgpbe.
        ls_messages-message_v2 = ls_maintain-matnr.
        ls_messages-message_v3 = ls_maintain-werks.
        ls_messages-message_v4 = ls_maintain-lgort.
        MESSAGE ID ls_messages-id TYPE ls_messages-type
          NUMBER ls_messages-number WITH ls_messages-message_v1
          ls_messages-message_v2 ls_messages-message_v3 ls_messages-message_v4
          INTO ls_messages-message.
        APPEND ls_messages TO lt_messages.
      ENDIF.

    ENDIF.
  ENDLOOP.

  IF lt_messages IS NOT INITIAL.
    ls_variant-report = sy-repid.
    ls_variant-handle = '0005'.

    PERFORM f_messages_fcat CHANGING lt_fldcat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_structure_name      = 'LT_MESSAGES'    " Internal output table structure name
        it_fieldcat           = lt_fldcat    " Field catalog with field descriptions
        i_save                = 'X'    " Variants can be saved
        is_variant            = ls_variant    " Variant information
        i_screen_start_column = 10    " Coordinates for list in dialog box
        i_screen_start_line   = 5    " Coordinates for list in dialog box
        i_screen_end_column   = 150    " Coordinates for list in dialog box
        i_screen_end_line     = 18    " Coordinates for list in dialog box
      TABLES
        t_outtab              = lt_messages    " Table with data to be displayed
      EXCEPTIONS
        program_error         = 1
        OTHERS                = 2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MESSAGES_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_FLDCAT  text
*----------------------------------------------------------------------*
FORM f_messages_fcat  CHANGING ct_fldcat TYPE slis_t_fieldcat_alv.

  CLEAR: ct_fldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'LT_MESSAGES'
      i_structure_name       = 'BAPIRET2'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = ct_fldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  PERFORM f_add_to_fcat USING 'LGORT' 'LT_MESSAGES' 'Storage Location' 'X' CHANGING ct_fldcat.
  PERFORM f_add_to_fcat USING 'WERKS' 'LT_MESSAGES' 'Plant' 'X' CHANGING ct_fldcat.
  PERFORM f_add_to_fcat USING 'MATNR' 'LT_MESSAGES' 'Material' 'X' CHANGING ct_fldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_READ_RPRT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_read_rprt_data .
  IF  g_cnt_variant_error > 0.                              "n667256
    IF  NOT sy-slset IS INITIAL.                            "n667256
      MESSAGE e634(db)       WITH  sy-slset sy-repid.       "n667256
    ENDIF.                                                  "n667256
  ENDIF.                                                    "n667256

* does the user restrict the storage locations and want to  "n577268
* suppress stock objects from plant level ?                 "n577268
  CLEAR                      collector-lgort.               "n577268
                                                            "n577268
  IF  collector-lgort IN lgort.                             "n577268
    CLEAR                    g_flag_suppress_init_lgort.    "n577268
  ELSE.                                                     "n577268
    MOVE  'X'                TO  g_flag_suppress_init_lgort. "n577268
  ENDIF.                                                    "n577268

  BREAK-POINT ID mmim_rep_mb52.                             "n1795093

  IF newsel = '1'.                                          "n1795093
    IF novalues IS INITIAL.
      PERFORM data_selection_join.
    ELSE.
      PERFORM data_selection_new.
    ENDIF.
  ELSEIF newsel = 'X'.
    PERFORM data_selection_new.
  ELSE.                                                     "n1795093
    PERFORM data_selection.                                 "n1795093
  ENDIF.

  PERFORM fill_custom_data.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DIS_RPRT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_dis_rprt_alv .
  READ TABLE bestand INDEX 1 TRANSPORTING NO FIELDS.

  IF sy-subrc = 0.
*   the fieldcatalog depends on the type of list            "n531604
    IF      NOT pa_hsq IS INITIAL.                          "n531604
*     create hierarchic list                                "n531604
      PERFORM                fieldcatalog.                  "n531604
    ELSEIF  NOT  pa_flt IS INITIAL.                         "n531604
      PERFORM                f0300_fieldcat_flat.           "n531604
    ENDIF.                                                  "n531604

    IF  g_flag_mess_333 = 'X'.
*     "The list is incomplete due to lacking authorization
      MESSAGE                s333.
    ENDIF.

    PERFORM list_output.
  ELSE.
    MESSAGE s843.
*   Zu den vorgegebenen Daten ist kein Bestand vorhanden
    IF NOT sy-calld IS INITIAL.                             "307852
      LEAVE.                                                "307852
    ELSE.                                                   "307852
*      LEAVE TO TRANSACTION sy-tcode.                            "n1590783
*     SELECT-OPTIONS will be lost with leave to transaction..    "n1590783
*     Change logic to submit and provide select-options          "n1590783
      SUBMIT rm07mlbs                                       "n1590783
       WITH matnr    IN matnr                               "n1590783
       WITH werks    IN werks                               "n1590783
       WITH lgort    IN lgort                               "n1590783
       WITH charg    IN charg                               "n1590783
       WITH matart   IN matart                              "n1590783
       WITH matkla   IN matkla                              "n1590783
       WITH ekgrup   IN ekgrup                              "n1590783
       WITH pa_sond  =  pa_sond                             "n1590783
       WITH so_sobkz IN so_sobkz                            "n1590783
       WITH negativ  =  negativ                             "n1590783
       WITH xmchb    = xmchb                                "n1590783
       WITH nozero   = nozero                               "n1590783
       WITH novalues = novalues                             "n1590783
       WITH pa_hsq   = pa_hsq                               "n1590783
       WITH pa_flt   = pa_flt                               "n1590783
       WITH p_vari   = p_vari                               "n1590783
       VIA SELECTION-SCREEN.                                "n1590783
    ENDIF.                                                  "307852
  ENDIF.
ENDFORM.

INCLUDE zmm_storage_bin_mb52_sub.
*&---------------------------------------------------------------------*
*&      Form  F_SCRN_VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_scrn_validation .
  IF rb_upld = 'X' AND p_f_path IS INITIAL.
    MESSAGE TEXT-004 TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF rb_main = 'X'.
    IF lines( s_matnr[] ) GT 20.
      MESSAGE TEXT-003 TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
    IF s_matnr[] IS INITIAL.
      MESSAGE TEXT-005 TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
    IF s_werks[] IS INITIAL.
      MESSAGE TEXT-006 TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
    IF s_lgort[] IS INITIAL.
      MESSAGE TEXT-090 TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.

    LOOP AT s_matnr.
      IF s_matnr-low CS '*'.
        MESSAGE TEXT-008 TYPE 'S' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDLOOP.

    IF s_werks-low CS '*'.
      MESSAGE TEXT-009 TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.
ENDFORM.

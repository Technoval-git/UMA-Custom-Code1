*&---------------------------------------------------------------------*
*& Include          ZIMAT_PRICING_UPD_FORM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  OPEN_DIALOG_PRES_SERVER
*&---------------------------------------------------------------------*
*  Sub-routine for the provision of value help for the input field
*  from Presentation server
*----------------------------------------------------------------------*
FORM f_open_dialog_pres_server .

*  Data declarations
  DATA: lv_window_title      TYPE string,
        lv_rc                TYPE sysubrc,
        lv_default_file_name TYPE string,
        it_file_table        TYPE filetable.

*  Constants
  CONSTANTS : lc_err TYPE i VALUE -1,
              lc_suc TYPE i VALUE 1.

  lv_window_title = TEXT-009.            "Choose filename without extension

* Method to provide value help for input file name
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_window_title
      default_filename        = lv_default_file_name
    CHANGING
      file_table              = it_file_table
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF lv_rc EQ lc_err OR sy-subrc <> 0.
    MESSAGE ID sy-msgid
          TYPE sy-msgty
        NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSEIF lv_rc EQ lc_suc.
*  Read the name of the first file selected
    READ TABLE it_file_table INDEX 1 INTO p_file.
    IF sy-subrc IS NOT INITIAL.
      CLEAR p_file.
    ENDIF.
  ENDIF.

  FREE it_file_table.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_OPEN_DIALOG_APP_SERVER
*&---------------------------------------------------------------------*
*       F4 help for application server paths
*----------------------------------------------------------------------*
*      -->o_va_FILEP -- Filepath of the selected
*----------------------------------------------------------------------*
FORM f_open_dialog_app_server CHANGING i_va_filep TYPE localfile.
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = i_va_filep
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SEL_SCREEN
*&---------------------------------------------------------------------*
*       Validate the filenames/paths
*----------------------------------------------------------------------*
FORM f_validate_sel_screen .

*  data decalrations
  DATA: lv_path        TYPE draw-filep,    "path to be checked for exixtance
        lv_exists      TYPE c,
        l_extension(3) TYPE c.             "file extension

*  constants
  CONSTANTS: lc_xls TYPE char3 VALUE 'XLS',
             lc_txt TYPE char3 VALUE 'TXT'.

  lv_path = p_file.
  IF p_rb_pre EQ abap_true.
    CALL FUNCTION 'CV120_DOC_FILE_EXISTENCE_CHECK'
      EXPORTING
        pf_file   = lv_path
      IMPORTING
        pfx_exist = lv_exists
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.
    IF sy-subrc EQ 0 AND lv_exists IS INITIAL.
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  030.
    ENDIF.
  ENDIF.

* FM to determine the extension of the specified input file
  IF p_file IS NOT INITIAL.
    CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
      EXPORTING
        filename  = p_file
      IMPORTING
        extension = l_extension.

* Throw an error message
* if the extension of the input file is not equal the pre-determined extension
    IF l_extension NE lc_xls AND p_rb_pre EQ abap_true.
      SET CURSOR FIELD 'P_FILE'.
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  029
*              WITH    lc_xls.
    ELSEIF l_extension NE lc_txt AND p_rb_app EQ abap_true.
      SET CURSOR FIELD 'P_FILE'.
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  029
*              WITH    lc_txt.
    ENDIF.
  ELSE.
*    MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*            TYPE    yif_dbm_jet_constants=>gc_value_e
*            NUMBER  027
*            WITH    TEXT-001.
  ENDIF.

* Check if success log path is empty
  IF p_succ IS INITIAL .
*    MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*            TYPE    yif_dbm_jet_constants=>gc_value_e
*            NUMBER  028
*            WITH    TEXT-010.
  ELSE.

* Check if success log path is valid

    OPEN DATASET p_succ FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc  <> 0.
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  027
*              WITH    TEXT-010.
    ENDIF.
    CLOSE DATASET p_succ.
  ENDIF.

* Check if error log path is empty
  IF p_error IS INITIAL.
*    MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*            TYPE    yif_dbm_jet_constants=>gc_value_e
*            NUMBER  028
*            WITH    TEXT-011.
  ELSE.

* Check if error log path is valid
    OPEN DATASET p_error FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc  <> 0.
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  027
*              WITH    TEXT-011.
    ENDIF.
    CLOSE DATASET p_error.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GUI_UPLOAD
*&---------------------------------------------------------------------*
*      Read data from the excel file selected
*----------------------------------------------------------------------*
FORM f_gui_upload .
*Data decleration.
  DATA : lv_file           TYPE rlgrap-filename,                      "To pass upload Function module
         lv_index          TYPE i,                                    "index for iteration
         it_intern         TYPE STANDARD TABLE OF alsmex_tabline,     "internal table for converting excel to sap
         ls_intern         TYPE alsmex_tabline,                       "internal table for converting excel to sap
         lv_endc           TYPE i VALUE   256 ##str_num,              "end coloumn
         lv_brow           TYPE i VALUE -9998,                        "begin row
         lv_erow           TYPE i,                                    "end row
         lv_nlin           TYPE i VALUE '1000000'  ##STR_NUM,         "max no of lines
         lv_one            TYPE i VALUE 1,                            "begin coloumn
         ts_file_col_name  TYPE ty_colname,
         ts_file_col_name1 TYPE ty_colname1,
         lv_row_no         TYPE int4.


* Field Symbols
  FIELD-SYMBOLS:<lfs_intern> LIKE LINE OF it_intern,          "field symbol for ALSM output
                <lfs_aux>    TYPE any.                        "auxillary node values

* Constants
  CONSTANTS: lc_null    TYPE char4 VALUE 'NULL',
             lc_one     TYPE syindex VALUE 1,
             lc_row_one TYPE kcd_ex_row_n VALUE 0001,
             lc_row_two TYPE kcd_ex_row_n VALUE 0002,
             lc_col_two TYPE kcd_ex_col_n VALUE 0002.

  CLEAR: ts_file_data.
  "assigning F4 file pateh  to Upload FM
  lv_file  =  p_file.

* To avoid the FM to look for 1000000 rows at once, fetching
* is done in steps of 9999
  WHILE lv_erow < lv_nlin.

*increment the counter
    ADD 9999 TO lv_brow.
    ADD 9999 TO lv_erow.

*To fetch data from the excel file
*The FM returs data in ---> row,col,value format
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = lv_file
        i_begin_col             = lv_one
        i_begin_row             = lv_brow
        i_end_col               = lv_endc
        i_end_row               = lv_erow
      TABLES
        intern                  = it_intern
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*   Checking the table having Records or not
    IF it_intern IS NOT INITIAL.
      SORT it_intern BY row col.
      IF sy-index EQ lc_one.
        DELETE it_intern WHERE row = lc_row_one.       " to delete the fisrt rom which hold the table field names.
      ENDIF.

      READ TABLE it_intern INTO ls_intern
        WITH KEY row = lc_row_two col = lc_col_two.
      IF sy-subrc = 0.
        IF ( r_mm IS NOT INITIAL AND ls_intern-value <> 'LIFNR' )
          OR ( r_sales IS NOT INITIAL AND ls_intern-value <> 'VKORG' ) .
          MESSAGE TEXT-029 TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
      DELETE it_intern WHERE row = lc_row_two.
    ELSE.
      EXIT.
    ENDIF.

*  The data is in in the form of row,col,value
    LOOP AT it_intern ASSIGNING <lfs_intern>.
      IF <lfs_intern>-value NE lc_null.
        MOVE <lfs_intern>-col TO lv_index.
        IF r_mm IS NOT INITIAL.
          ASSIGN COMPONENT lv_index OF STRUCTURE ts_file_col_name TO <lfs_aux>.
        ELSE.
          ASSIGN COMPONENT lv_index OF STRUCTURE ts_file_col_name1 TO <lfs_aux>.
        ENDIF.
        IF sy-subrc = 0.
          MOVE <lfs_intern>-value TO <lfs_aux>.
        ENDIF.
        AT END OF row.
          ADD 1 TO lv_row_no  .
          PERFORM f_convert_text_to_fields    "store the splitted data to internal tables
                      USING
                         ts_file_col_name
                         ts_file_col_name1
                         lv_row_no.
          CLEAR: ts_file_col_name, ts_file_col_name1.

*            APPEND ts_file_data TO it_file_data.
*            CLEAR ts_file_data.
        ENDAT.
      ENDIF.
    ENDLOOP.

  ENDWHILE.

  FREE: it_intern.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_READ_DATASET
*&---------------------------------------------------------------------*
*       If application server is selected, data should be read
*        from dataset
*----------------------------------------------------------------------*
FORM f_read_dataset .

* Data declaration
  DATA : lv_row           TYPE string,
         ts_rec           TYPE ty_colname,
         ts_rec1          TYPE ty_colname1,
*        lv_lang          TYPE sylangu,
         lv_dummy         TYPE string,
         lv_unwanted_char TYPE xstring VALUE '0D',
         lv_xstring       TYPE xstring,
         lv_empty         TYPE xstring,
         lv_string        TYPE string,
         lv_row_no        TYPE int4,
         lv_index         TYPE sy-index.

  CONSTANTS: lc_delim TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.

*to retain the original language
*  lv_lang = sy-langu.
*  SET LOCALE LANGUAGE 'A'.
*open the file in the app. server for reading
  OPEN DATASET p_file FOR INPUT IN TEXT MODE ENCODING NON-UNICODE."DEFAULT.
  IF sy-subrc IS INITIAL.
    DO.
      READ DATASET p_file INTO lv_row.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        lv_index = sy-index.
        IF lv_index = 1.
          CONTINUE.
        ENDIF.
*  extract all the fields with comma as delimeter (.CSV file)
        IF r_mm IS NOT INITIAL.
          SPLIT lv_row  AT lc_delim INTO
*                         ts_rec-application
                           "ts_rec-table
                           ts_rec-cond_type
                           ts_rec-vendor ts_rec-pur_grp ts_rec-mat_grp4
                           " ts_rec-division         ts_rec-mvgr4
                           ts_rec-amount
                           ts_rec-amount_unit      ts_rec-cond_pr_unit           ts_rec-cond_pr_unit_unit  "ts_rec-krech
                           ts_rec-valid_from     ts_rec-valid_to    lv_dummy  .
        ELSE.
          SPLIT lv_row  AT lc_delim INTO
*                         ts_rec-application
                           " ts_rec1-table
                            ts_rec1-cond_type
                            ts_rec1-sales_org
                            ts_rec1-vtweg
                            ts_rec1-spart
                            ts_rec1-aufart
                            ts_rec1-kdgrp
                            ts_rec1-kunnr
                            ts_rec1-material
                            " ts_rec-division         ts_rec-mvgr4
                            ts_rec1-amount
                            ts_rec1-amount_unit      ts_rec1-cond_pr_unit           ts_rec1-cond_pr_unit_unit  "ts_rec1-krech
                            ts_rec1-valid_from     ts_rec1-valid_to    lv_dummy  .
        ENDIF.
        IF lv_index = 2.
          IF ( r_mm IS NOT INITIAL AND ts_rec-vendor <> 'LIFNR' )
            OR ( r_sales IS NOT INITIAL AND ts_rec1-sales_org <> 'VKORG' ).
            MESSAGE TEXT-029 TYPE 'S' DISPLAY LIKE 'E'.
            EXIT.
          ENDIF.
        ENDIF.

        ADD 1 TO lv_row_no.
        PERFORM f_convert_text_to_fields    "store the splitted data to internal tables
                    USING
                       ts_rec
                       ts_rec1
                       lv_row_no.

        CLEAR: lv_row,ts_rec, ts_rec1.
      ENDIF.
    ENDDO.
    CLOSE DATASET p_file.
  ELSE.
*    MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id    "Reading upload file failed
*            TYPE    yif_dbm_jet_constants=>gc_value_e
*            NUMBER  026.
  ENDIF.

*set the language back to orginal
*  SET LOCALE LANGUAGE lv_lang.
*  CLEAR lv_lang.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PRICING_REC_PROCESSING
*&---------------------------------------------------------------------*
*       It is used to fill the table and upload the data
*----------------------------------------------------------------------*
FORM f_pricing_rec_processing .
*Data Declaration
  DATA :
    it_bapiret2 TYPE TABLE OF  bapiret2,
    ts_bapiret2 TYPE bapiret2,
    lv_row      TYPE int4,
    lv_knumhs   TYPE knumhs.

* Iiterating through the support values in the excel
  IF r_mm IS NOT INITIAL.
    LOOP AT it_file_data INTO ts_file_data.
      lv_row = sy-tabix.
*  Fill the structures and call the FM to upload data
      CLEAR: it_bapiret2, lv_knumhs.
      PERFORM f_fill_n_upload_fm_data USING ts_file_data
                                            ts_file_data1
                             CHANGING it_bapiret2
                                      lv_knumhs. "new condition number
      PERFORM f_record_log  USING it_bapiret2 lv_knumhs lv_row.
    ENDLOOP.
  ELSE.
    LOOP AT it_file_data1 INTO ts_file_data1.
      lv_row = sy-tabix.
*  Fill the structures and call the FM to upload data
      CLEAR: it_bapiret2, lv_knumhs.
      PERFORM f_fill_n_upload_fm_data USING ts_file_data
                                            ts_file_data1
                             CHANGING it_bapiret2
                                      lv_knumhs. "new condition number
      PERFORM f_record_log  USING it_bapiret2 lv_knumhs lv_row.
    ENDLOOP.
  ENDIF.



  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    IMPORTING
      return = ts_bapiret2.
  IF ts_bapiret2 IS NOT INITIAL.
    CLEAR it_bapiret2.
    APPEND ts_bapiret2 TO it_bapiret2.
    CLEAR: lv_knumhs, lv_row.
    PERFORM f_record_log  USING it_bapiret2 lv_knumhs lv_row.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FM_DATA
*&---------------------------------------------------------------------*
*       It is used to fill the table from internal table that has excel data
*----------------------------------------------------------------------*
FORM f_fill_n_upload_fm_data  USING    i_ts_file_data TYPE ty_final
                                       i_ts_file_data1 TYPE ty_final1
                              CHANGING ct_bapiret2 TYPE bapiret2_tab
                                       cv_knumhs   TYPE knumhs .
* Data declaration
  DATA :
    it_condit TYPE TABLE OF bapicondit,
    it_condhd TYPE TABLE OF bapicondhd,
    it_condct TYPE TABLE OF bapicondct,
    it_condqs TYPE TABLE OF bapicondqs,
    it_condvs TYPE TABLE OF  bapicondvs,
    it_knumhs TYPE TABLE OF bapiknumhs,
    lv_matnr  TYPE matnr_int.

  DATA : ts_condct   TYPE bapicondct,
         ts_condhd   TYPE bapicondhd,
         ts_condit   TYPE bapicondit,
         ts_bapiret2 TYPE bapiret2,
         ts_knumhs   TYPE bapiknumhs,
         lv_varkey   TYPE char128,
         lv_cond_tbl TYPE kotabnr,
         lv_appl     TYPE kappl,
         lv_caltype  TYPE krech,
         lv_negative TYPE knega.
  DATA  it_mem_initial TYPE TABLE OF cnd_mem_initial.
*  constant declaration
  CONSTANTS:
    lc_operation        TYPE char4 VALUE '009',  "operation type insert
    lc_cond_no          TYPE char10 VALUE '$000000001', "temporary cond no
    lc_cond_count       TYPE char2 VALUE '01', "condi"tion count
    lc_cond_usg_pricing TYPE kvewe VALUE 'A', "Pricing
    lc_appl_v           TYPE char1 VALUE 'V',
    lc_appl_m           TYPE char1 VALUE 'M'.

*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = i_ts_file_data-division
*    IMPORTING
*      output = i_ts_file_data-division.

*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = i_ts_file_data-mvgr4
*    IMPORTING
*      output = i_ts_file_data-mvgr4.

*  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
*    EXPORTING
*      input  = i_ts_file_data-varkey+6
*    IMPORTING
*      output = lv_matnr.
  CASE 'X'.
    WHEN r_mm.
      CASE 'X'.
        WHEN r_044.
*          CONCATENATE i_ts_file_data-pur_grp i_ts_file_data-vendor INTO lv_varkey RESPECTING BLANKS.
*          lv_cond_tbl = '044'.
*        WHEN r_971.
*          CONCATENATE i_ts_file_data-vendor i_ts_file_data-pur_grp i_ts_file_data-mat_grp4 INTO lv_varkey RESPECTING BLANKS.
*          lv_cond_tbl = '971'.
      ENDCASE.
    WHEN r_sales.
      MOVE-CORRESPONDING i_ts_file_data1 TO i_ts_file_data.
      CASE 'X'.
        WHEN r_902.
          CONCATENATE i_ts_file_data1-sales_org i_ts_file_data1-vtweg i_ts_file_data1-spart i_ts_file_data1-aufart
                      i_ts_file_data1-kunnr  i_ts_file_data1-material(18)
            INTO lv_varkey RESPECTING BLANKS.
          lv_cond_tbl = '902'.
        WHEN r_903.
          CONCATENATE i_ts_file_data1-sales_org i_ts_file_data1-vtweg i_ts_file_data1-spart i_ts_file_data1-aufart
                      i_ts_file_data1-kdgrp  i_ts_file_data1-material(18)
            INTO lv_varkey RESPECTING BLANKS.
          lv_cond_tbl = '903'.
        WHEN r_900.
          CONCATENATE i_ts_file_data1-sales_org i_ts_file_data1-vtweg i_ts_file_data1-spart i_ts_file_data1-aufart
                      i_ts_file_data1-material(18)
            INTO lv_varkey RESPECTING BLANKS.
          lv_cond_tbl = '900'.
        WHEN r_901.
          CONCATENATE i_ts_file_data1-sales_org i_ts_file_data1-vtweg i_ts_file_data1-spart
                      i_ts_file_data1-kunnr  i_ts_file_data1-material(18)
            INTO lv_varkey RESPECTING BLANKS.
          lv_cond_tbl = '901'.
        WHEN r_904.
          CONCATENATE i_ts_file_data1-sales_org i_ts_file_data1-vtweg i_ts_file_data1-spart
                      i_ts_file_data1-kdgrp  i_ts_file_data1-material(18)
            INTO lv_varkey RESPECTING BLANKS.
          lv_cond_tbl = '904'.
        WHEN r_905.
          CONCATENATE i_ts_file_data1-sales_org i_ts_file_data1-vtweg i_ts_file_data1-spart
                      i_ts_file_data1-material(18)
            INTO lv_varkey RESPECTING BLANKS.
          lv_cond_tbl = '905'.
        WHEN r_004.
          CONCATENATE i_ts_file_data1-sales_org i_ts_file_data1-vtweg
                      i_ts_file_data1-material(18)
            INTO lv_varkey RESPECTING BLANKS.
          lv_cond_tbl = '004'.
      ENDCASE.
  ENDCASE.

*  lv_varkey = i_ts_file_data-varkey.
*  lv_cond_tbl = i_ts_file_data-table.

  IF r_mm IS NOT INITIAL.
    lv_appl = lc_appl_m.
  ELSE.
    lv_appl = lc_appl_v.
  ENDIF.

  SELECT SINGLE krech knega FROM t685a
    INTO ( lv_caltype, lv_negative )
    WHERE kappl = lv_appl
      AND kschl = i_ts_file_data-cond_type.

  ts_condct-table_no = lv_cond_tbl.
  ts_condct-applicatio = lv_appl.
  ts_condct-cond_type = i_ts_file_data-cond_type.
  ts_condct-operation = lc_operation.   "operation type insert
  ts_condct-cond_usage = lc_cond_usg_pricing .
  ts_condct-varkey = lv_varkey.
  CONCATENATE i_ts_file_data-valid_to+6(4)
              i_ts_file_data-valid_to+3(2)
              i_ts_file_data-valid_to+0(2)
              INTO ts_condct-valid_to .
  CONCATENATE i_ts_file_data-valid_from+6(4)
                i_ts_file_data-valid_from+3(2)
                i_ts_file_data-valid_from+0(2)
                INTO ts_condct-valid_from .
*  ts_condct-valid_to = i_ts_file_data-valid_to.
*  ts_condct-valid_from = i_ts_file_data-valid_from.
  ts_condct-cond_no = lc_cond_no. "temp cond no
  APPEND ts_condct TO it_condct.

  ts_condhd-operation = lc_operation.
  ts_condhd-cond_no = lc_cond_no.
  ts_condhd-created_by = sy-uname.
  ts_condhd-creat_date = sy-datum.
  ts_condhd-cond_usage = lc_cond_usg_pricing .
  ts_condhd-table_no = lv_cond_tbl.
  ts_condhd-applicatio = lv_appl.
  ts_condhd-cond_type = i_ts_file_data-cond_type.
  ts_condhd-varkey = lv_varkey.
  ts_condhd-valid_from = ts_condct-valid_from..
  ts_condhd-valid_to = ts_condct-valid_to.
  APPEND ts_condhd TO it_condhd.

  ts_condit-operation = lc_operation.
  ts_condit-cond_no = lc_cond_no.
  ts_condit-cond_count = lc_cond_count. "condition count
  ts_condit-applicatio = lv_appl.
  ts_condit-cond_type = i_ts_file_data-cond_type.
  ts_condit-cond_unit = i_ts_file_data-cond_pr_unit_unit.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = ts_condit-cond_unit    " external display of unit of measurement
    IMPORTING
      output         = ts_condit-cond_unit    " internal display of unit of measurement
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
  ts_condit-cond_p_unt = i_ts_file_data-cond_pr_unit.
  IF lv_negative = 'X' AND i_ts_file_data-amount GT 0.
    ts_condit-cond_value = 0 - i_ts_file_data-amount.
  ELSE.
    ts_condit-cond_value = i_ts_file_data-amount.
  ENDIF.
  ts_condit-calctypcon = lv_caltype.
  IF lv_caltype = 'A'.
    ts_condit-condcurr = '%'.
  ELSE.
    ts_condit-condcurr = i_ts_file_data-amount_unit.
  ENDIF.
  APPEND ts_condit TO it_condit.

  CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
    TABLES
      ti_bapicondct  = it_condct
      ti_bapicondhd  = it_condhd
      ti_bapicondit  = it_condit
      ti_bapicondqs  = it_condqs
      ti_bapicondvs  = it_condvs
      to_bapiret2    = ct_bapiret2
      to_bapiknumhs  = it_knumhs
      to_mem_initial = it_mem_initial.

  READ TABLE it_knumhs INTO ts_knumhs INDEX 1.

  cv_knumhs = ts_knumhs-cond_no_new.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_RECORD_LOG
*&---------------------------------------------------------------------*
*       Fetch and format the FM return messages
*----------------------------------------------------------------------*
*      -->TT_RETURN  return table
*
*----------------------------------------------------------------------*
FORM f_record_log  USING   i_it_bapiret2 TYPE bapiret2_tab
                           i_lv_knumhs TYPE knumhs
                           pv_tabix TYPE int4 .

*data delcaration
  DATA: ts_ret     TYPE bapiret2       ##NEEDED,
        ts_return  TYPE bapiret2,
        lv_message TYPE bapiret2-message.

  LOOP AT i_it_bapiret2 INTO ts_return.
*format message
    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        id         = ts_return-id
        number     = ts_return-number
        language   = sy-langu
        textformat = lc_non
        message_v1 = ts_return-message_v1
        message_v2 = ts_return-message_v2
        message_v3 = ts_return-message_v3
        message_v4 = ts_return-message_v4
      IMPORTING
        message    = lv_message
        return     = ts_ret.

*Success logs
    IF ( ts_return-type = lc_s OR ts_return-type = lc_w ).
      ts_succ_log-row_no = pv_tabix.
      ts_succ_log-knumhs = i_lv_knumhs.
      ts_succ_log-type = ts_return-type.            "message type  and lv_index mod 2 <> 0
      ts_succ_log-msg = lv_message.                  "message
      APPEND ts_succ_log TO it_succ_log.
      CLEAR ts_succ_log.
    ENDIF.

*Error logs
    IF ts_return-type = lc_e.
      ts_err_log-row_no = pv_tabix.
      ts_err_log-knumhs = ' '.
      ts_err_log-type = ts_return-type.              "message type
      ts_err_log-msg = lv_message.                    "message
      APPEND ts_err_log TO it_err_log.
      CLEAR ts_err_log.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LOG_UPLOAD_TO_SERVER
*&---------------------------------------------------------------------*
*      Upload the logs into app server for reference
*----------------------------------------------------------------------*
FORM f_log_upload_to_server .

*  data delclarations
  DATA : lv_path       TYPE rcgfiletr-ftappl,
         l_temp_string TYPE char260,
         lv_extension  TYPE string,
         ls_result     TYPE match_result,
         lv_offset     TYPE i,
         lv_strlen     TYPE int4,
         lv_dir        TYPE string,
         lv_filename   TYPE string.
* constants for headings
  CONSTANTS: lc_msg  TYPE char50 VALUE 'MESSAGE',
             lc_type TYPE char50 VALUE 'TYPE'.

*** Success Log
  CLEAR: lv_path, ls_result, lv_offset,lv_dir,lv_filename.

*  FIND FIRST OCCURRENCE OF '.' IN p_succ RESULTS ls_result.
*  IF sy-subrc = 0.
*    lv_path = p_succ(ls_result-offset).
*    lv_offset = ls_result-offset + 1.
*    lv_extension = p_succ+lv_offset.
*  ELSE.
*    lv_path = p_succ.
*  ENDIF.
*  IF lv_extension IS INITIAL.
*    lv_extension = 'txt'.
*  ENDIF.
*
*  lv_strlen = strlen( lv_path ).
*  lv_strlen = lv_strlen - 1.
*  IF lv_path+lv_strlen(1) = '/'.
**  append '/' file name and timestamp to the log file
*    CONCATENATE lv_path TEXT-003
*    sy-datum sy-uzeit TEXT-004 '.' lv_extension INTO lv_path.
*  ELSE.
*    CONCATENATE lv_path '/' TEXT-003
*   sy-datum sy-uzeit TEXT-004 '.' lv_extension INTO lv_path.
*  ENDIF.
  zcl_common_util=>get_path_params(
  EXPORTING
    iv_path      = p_succ    " success file path
*    iv_prefix    =     " prefix
  IMPORTING
    ev_directory =  lv_dir    " created path
    ev_file_name = lv_filename    " FILE NAME
    ev_extension =  lv_extension   " file extension
).

  CONCATENATE lv_dir lv_filename TEXT-003
              sy-datum sy-uzeit TEXT-004 lv_extension INTO lv_path.



  DELETE it_succ_log WHERE type = lc_w.

*  create and open file for write
  OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc <> 0.
    CONCATENATE  TEXT-003
            sy-datum sy-uzeit TEXT-004  lv_extension INTO lv_path.
    OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  ENDIF.
  IF sy-subrc IS INITIAL.

*transfer heading
    CONCATENATE
    lc_type      lc_msg INTO l_temp_string SEPARATED BY space.
    TRANSFER  l_temp_string TO lv_path.

    CLEAR: ts_succ_log,l_temp_string.

**transfer data
    LOOP AT it_succ_log INTO ts_succ_log.
*      TRANSFER  ts_succ_log TO lv_path.
      CONCATENATE
      ts_succ_log-type      ts_succ_log-msg INTO l_temp_string SEPARATED BY space.
      TRANSFER l_temp_string TO lv_path.
      CLEAR: ts_succ_log,l_temp_string.
      IF sy-subrc IS NOT INITIAL.
        EXIT.
      ENDIF.
      CLEAR ts_succ_log.
    ENDLOOP.
    CLOSE DATASET lv_path.
  ENDIF.

*** Error Log
  CLEAR: lv_path, ls_result, lv_offset,lv_strlen,lv_dir,lv_filename.


*  create and open file for write
  zcl_common_util=>get_path_params(
     EXPORTING
       iv_path      = p_error    " success file path
*    iv_prefix    =     " prefix
     IMPORTING
       ev_directory =  lv_dir    " created path
       ev_file_name = lv_filename    " FILE NAME
       ev_extension =  lv_extension   " file extension
   ).

  CONCATENATE lv_dir lv_filename TEXT-005
              sy-datum sy-uzeit TEXT-004 lv_extension INTO lv_path.

  OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc <> 0.
    CONCATENATE TEXT-005
            sy-datum sy-uzeit TEXT-004  lv_extension INTO lv_path.
    OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  ENDIF.
  IF sy-subrc IS INITIAL.

*transfer heading
    CONCATENATE  lc_type
    lc_msg INTO l_temp_string SEPARATED BY space.
    TRANSFER  l_temp_string TO lv_path.
    CLEAR: ts_succ_log,l_temp_string.

*transfer data
    LOOP AT it_err_log INTO ts_err_log.
*      TRANSFER  ts_err_log TO lv_path.
      CONCATENATE
      ts_err_log-type      ts_err_log-msg INTO l_temp_string SEPARATED BY space.
      TRANSFER l_temp_string TO lv_path.
      IF sy-subrc IS NOT INITIAL.
        EXIT.
      ENDIF.
      CLEAR ts_err_log.
    ENDLOOP.
    CLOSE DATASET lv_path.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ALV_LOG_DISPLAY
*&---------------------------------------------------------------------*
*       ALV report display
*----------------------------------------------------------------------*
FORM f_alv_log_display .

* data declarations
  DATA : lo_alv     TYPE REF TO cl_salv_table,
         it_log     TYPE STANDARD TABLE OF ty_slog,
         ts_log     TYPE ty_slog,
         ts_elog    TYPE ty_elog,
         lo_funct   TYPE REF TO cl_salv_functions,
         lo_header  TYPE REF TO cl_salv_form_header_info,
         lo_column  TYPE REF TO cl_salv_column_table,
         lo_columns TYPE REF TO cl_salv_columns_table.

*Combine error and success logs into 1 table
  APPEND LINES OF it_succ_log[] TO it_log[].
  LOOP AT it_err_log INTO ts_elog.
    ts_log-row_no = ts_elog-row_no.
    ts_log-type = ts_elog-type.            "message type
    ts_log-msg = ts_elog-msg.              "message

    APPEND ts_log TO it_log.
    CLEAR ts_log.
  ENDLOOP.

  TRY.
      CALL METHOD cl_salv_table=>factory "get SALV factory instance
        EXPORTING
          list_display = abap_true
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = it_log.
    CATCH cx_salv_msg ##NO_HANDLER.
  ENDTRY.

  CREATE OBJECT lo_header
    EXPORTING
      text = TEXT-019.               "#EC NOTEXT
  lo_alv->set_top_of_list( lo_header ).
  lo_funct = lo_alv->get_functions( ).
  lo_funct->set_all( abap_true ).

  TRY.
      lo_columns = lo_alv->get_columns( ).
      lo_column ?= lo_columns->get_column( 'ROW_NO' ) ##TEXT_POOL.
      lo_column->set_long_text( 'Row Number'(008)  ) ##TEXT_POOL.
      lo_column->set_medium_text( 'Row Number'(008) ) ##TEXT_POOL.
      lo_column ?= lo_columns->get_column( 'KNUMHS' ) ##TEXT_POOL.
      lo_column->set_long_text( TEXT-012  ) ##TEXT_POOL.
      lo_column->set_medium_text( TEXT-013 ) ##TEXT_POOL.
      lo_columns->set_optimize( abap_true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
    CATCH cx_salv_existing.                             "#EC NO_HANDLER
    CATCH cx_salv_data_error.                           "#EC NO_HANDLER
  ENDTRY.
  lo_alv->display( ). "display grid
  FREE: it_log.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FREE_TABLES
*&---------------------------------------------------------------------*
*       Free Global Internal Tables
*----------------------------------------------------------------------*
FORM f_free_tables .
  FREE:
  it_err_log,
  it_succ_log,
  it_file_data.
ENDFORM.
*&--------------------------------------------------------------------*
*&      Form  f_hide_field
*&--------------------------------------------------------------------*
* Hiding Fields
*---------------------------------------------------------------------*
*      -->i_va_group1  text
*---------------------------------------------------------------------*
FORM f_hide_field  USING iv_group1 ##PERF_NO_TYPE.
  LOOP AT SCREEN.
    IF screen-group1 = iv_group1.
      screen-input = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " f_hide_field
*&--------------------------------------------------------------------*
*&      Form  f_unhide_field
*&--------------------------------------------------------------------*
* Unhiding Fields
*---------------------------------------------------------------------*
*      -->i_va_group1  text
*---------------------------------------------------------------------*
FORM f_unhide_field  USING iv_group1  ##PERF_NO_TYPE.
  LOOP AT SCREEN.
    IF screen-group1 = iv_group1.
      screen-input = 1.
      screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&--------------------------------------------------------------------*
*&      Form  f_fetch_filepath
*&--------------------------------------------------------------------*
* Fetching file path for given logical file name
*---------------------------------------------------------------------*
*      -->i_va_p_logicl  text
*      <--i_va_p_file  text
*---------------------------------------------------------------------*
FORM f_fetch_filepath  USING    iv_logicl
CHANGING   cv_file TYPE localfile ##PERF_NO_TYPE.

  DATA: lv_extension(3) TYPE c.

  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
*     CLIENT           = SY-MANDT
      logical_filename = iv_logicl
    IMPORTING
      file_name        = cv_file
    EXCEPTIONS
      file_not_found   = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    EXIT.
  ENDIF.

  IF p_file IS NOT INITIAL.
    CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
      EXPORTING
        filename  = cv_file
      IMPORTING
        extension = lv_extension.

    TRANSLATE lv_extension TO UPPER CASE.

* Throw an error message
* if the extension of the input file is not equal
* the pre-determined extension

    IF ( ( lv_extension NS lc_ext1 ) AND
    ( lv_extension NE lc_ext2 ) ).
*      SET CURSOR FIELD TEXT-003.
      MESSAGE TEXT-072 TYPE 'E'.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_fetch_filepath
FORM f_convert_text_to_fields  USING    i_ts_rec TYPE ty_colname
                                        i_ts_rec1 TYPE ty_colname1
                                        pv_row_no.

  DATA : lo_root    TYPE REF TO cx_root,
         lv_message TYPE string,
         lv_mat_ext TYPE matnr_ext,
         lv_mat_int TYPE matnr.
  TRY.
      IF r_mm IS NOT INITIAL.
        MOVE-CORRESPONDING i_ts_rec TO ts_file_data.

*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*          EXPORTING
*            input  = ts_file_data-mat_grp4    " C field
*          IMPORTING
*            output = ts_file_data-mat_grp4.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ts_file_data-vendor    " C field
          IMPORTING
            output = ts_file_data-vendor.

        APPEND ts_file_data TO it_file_data.
        CLEAR : ts_file_data.
      ELSE.
        CLEAR: lv_mat_ext, lv_mat_int.
        lv_mat_ext = i_ts_rec1-material.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input        = lv_mat_ext
          IMPORTING
            output       = lv_mat_int
          EXCEPTIONS
            length_error = 1
            OTHERS       = 2.
        i_ts_rec1-material = lv_mat_int.

        MOVE-CORRESPONDING i_ts_rec1 TO ts_file_data1.

*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*          EXPORTING
*            input  = ts_file_data1-mat_grp4    " C field
*          IMPORTING
*            output = ts_file_data1-mat_grp4.   " Internal display of INPUT, any category
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*          EXPORTING
*            input  = ts_file_data1-mat_grp5    " C field
*          IMPORTING
*            output = ts_file_data1-mat_grp5.

        APPEND ts_file_data1 TO it_file_data1.
        CLEAR : ts_file_data1.
      ENDIF.
    CATCH cx_root INTO lo_root.
      lv_message = lo_root->get_text( ).
      ts_err_log-row_no = pv_row_no.
      ts_err_log-knumhs = ' '.
      ts_err_log-type = 'E'.              "message type
      ts_err_log-msg = lv_message.                    "message
      APPEND ts_err_log TO it_err_log.
      CLEAR ts_err_log.
  ENDTRY.


ENDFORM.

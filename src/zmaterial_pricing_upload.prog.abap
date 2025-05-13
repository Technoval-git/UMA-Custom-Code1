*&---------------------------------------------------------------------*
*& Report ZMATERIAL_PRICING_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmaterial_pricing_upload.

" TOP INCLUDE
INCLUDE zimat_pricing_upd_top.


*Selection screen elements are declared here.
*Block b1 contains elements related to reading Excel file
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-006.
  PARAMETERS:
    p_rb_pre RADIOBUTTON GROUP rad2  MODIF ID b3             "presentaion server
                        DEFAULT 'X' USER-COMMAND select,
    p_rb_app RADIOBUTTON GROUP rad2  MODIF ID b3,            "application server
    p_file   TYPE localfile LOWER CASE .                      "Excel uplaod filepath
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-020.
  PARAMETERS: r_mm    RADIOBUTTON GROUP rd1 DEFAULT 'X' USER-COMMAND rd1.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 8.
    PARAMETERS: r_044   RADIOBUTTON GROUP rd2 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (50) TEXT-021 FOR FIELD r_044.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 8.
    PARAMETERS: r_971   RADIOBUTTON GROUP rd2.
    SELECTION-SCREEN COMMENT (50) TEXT-022 FOR FIELD r_971.
  SELECTION-SCREEN END OF LINE.

  PARAMETERS: r_sales RADIOBUTTON GROUP rd1.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 8.
    PARAMETERS: r_902 RADIOBUTTON GROUP rd3 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (50) TEXT-023 FOR FIELD r_902.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 8.
    PARAMETERS: r_903 RADIOBUTTON GROUP rd3.
    SELECTION-SCREEN COMMENT (50) TEXT-024 FOR FIELD r_903.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 8.
    PARAMETERS: r_900 RADIOBUTTON GROUP rd3.
    SELECTION-SCREEN COMMENT (50) TEXT-025 FOR FIELD r_900.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 8.
    PARAMETERS: r_901 RADIOBUTTON GROUP rd3.
    SELECTION-SCREEN COMMENT (50) TEXT-026 FOR FIELD r_901.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 8.
    PARAMETERS: r_904 RADIOBUTTON GROUP rd3.
    SELECTION-SCREEN COMMENT (50) TEXT-027 FOR FIELD r_904.
  SELECTION-SCREEN END OF LINE.
    SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 8.
    PARAMETERS: r_905 RADIOBUTTON GROUP rd3.
    SELECTION-SCREEN COMMENT (50) TEXT-028 FOR FIELD r_905.
  SELECTION-SCREEN END OF LINE.
    SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 8.
    PARAMETERS: r_004 RADIOBUTTON GROUP rd3.
    SELECTION-SCREEN COMMENT (50) TEXT-029 FOR FIELD r_004.
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-007.
  PARAMETERS: rb_file  RADIOBUTTON GROUP rad1 DEFAULT 'X' MODIF ID b4 USER-COMMAND file,
              rb_logic RADIOBUTTON GROUP rad1 MODIF ID b4,
              p_succ   TYPE localfile  MODIF ID fil DEFAULT '/tmp',         "Success Log filepath
              p_error  TYPE localfile  MODIF ID fil DEFAULT '/tmp',         "Error Log filepath
              p_slogic TYPE filename-fileintern MODIF ID lgc,
              p_elogic TYPE filename-fileintern MODIF ID lgc.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN: FUNCTION KEY 1.

*Subroutines are written here
INCLUDE zimat_pricing_upd_form.
*INCLUDE YMM_PRICING_FORM.
*&-----------------------------------------------------------------*
*&                AT SELECTION SCREEN OUTPUT
*&-----------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.

    IF screen-name CS 'R_044'
      OR screen-name CS 'R_971'.
      IF r_mm = 'X'.
        screen-invisible = 0.
        screen-active = 1.
      ELSE.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ELSEIF screen-name CS 'R_934'
        OR screen-name CS 'R_931'
        OR screen-name CS 'R_912'
        OR screen-name CS 'R_932'
        OR screen-name CS 'R_406'.
      IF r_sales = 'X'.
        screen-invisible = 0.
        screen-active = 1.
      ELSE.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.



  ENDLOOP.
  IF sy-batch IS INITIAL.
* Clear File Path and Logical File Name when server change
    ON CHANGE OF rb_logic.
      CLEAR : p_file,p_slogic.
    ENDON.

    ON CHANGE OF rb_file.
      CLEAR : p_succ,p_error,p_slogic,p_elogic.
      IF rb_file = abap_true.
        p_succ = '/tmp'.
        p_error = '/tmp'.
      ENDIF.
    ENDON.
  ENDIF.
  IF rb_file IS NOT INITIAL.
** Hide the Success & Error Logical File Name Fields
    PERFORM f_hide_field USING lc_lgc.
** Unhide the Success & Error File Path Fields
    PERFORM f_unhide_field USING lc_fil.
  ELSE.
** Hide the Success & Error File Path Fields
    PERFORM f_hide_field USING lc_fil.
** Unhide the Success & Error Logical File Name Fields
    PERFORM f_unhide_field USING lc_lgc.
  ENDIF.
*&-----------------------------------------------------------------*
*&                AT SELECTION SCREEN VALUE-REQUEST
*&-----------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

*Based on the selection, app server or presentation server,
*call the approriate subroutine to open either of them
  IF p_rb_pre IS NOT INITIAL.
*Open a dialog box to choose file from presentaion server
    PERFORM f_open_dialog_pres_server.
  ELSEIF p_rb_app IS NOT INITIAL.
*Open a dialog box to choose file from Application server
    PERFORM f_open_dialog_app_server CHANGING p_file.
  ENDIF.

*Choose file paths for success and error logs on app. server
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_succ.
*Open a dialog box to choose a filepath for success log
  PERFORM f_open_dialog_app_server CHANGING p_succ.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_error.
*Open a dialog box to choose a filepath for error log
  PERFORM f_open_dialog_app_server CHANGING p_error.


************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

* Fetching Success file path for given Success logical file name
  IF p_slogic IS NOT INITIAL.
    PERFORM f_fetch_filepath USING p_slogic CHANGING p_succ.
  ENDIF.

* Fetching Error file path for given Error logical file name
  IF p_elogic IS NOT INITIAL.
    PERFORM f_fetch_filepath USING p_elogic CHANGING p_error.
  ENDIF.

*Validation of selection screen values is performed
  PERFORM f_validate_sel_screen.

*Read the excel data from either presentation or application
  IF p_rb_pre = abap_true.
    PERFORM f_gui_upload.
  ELSEIF p_rb_app = abap_true.
    PERFORM f_read_dataset.
  ENDIF.

  IF it_err_log IS INITIAL.
    IF it_file_data IS INITIAL AND it_file_data1 IS INITIAL.
*    MESSAGE TEXT-066 TYPE lc_e. "'No data exists in the file'(066)
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  025. "'No data exists in the file'(066)
    ENDIF.

* The subroutnine creates new data and stores in tables
    PERFORM f_pricing_rec_processing.

*The success and error logs of creation/change is uplaoded to
* app. server
    PERFORM f_log_upload_to_server.
  ENDIF.
************************************************************************
* END-OF-SELECTION
************************************************************************
END-OF-SELECTION.
*ALV display
  PERFORM f_alv_log_display.
*  Free global internal tables
  PERFORM f_free_tables.

****------------------------------END-------------------------------------

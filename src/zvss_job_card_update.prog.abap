*&---------------------------------------------------------------------*
*& Report ZVSS_JOB_CARD_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_job_card_update.

INCLUDE zivss_job_card_update_top.
INCLUDE zivss_job_card_update_sel.
INCLUDE zivss_job_card_update_frm.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pv_file.
*  CALL FUNCTION 'F4_FILENAME'
*    EXPORTING
*      program_name  = syst-cprog
*      dynpro_number = syst-dynnr
*    IMPORTING
*      file_name     = pv_file.

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

  PERFORM form_get_data_pc_file.

  PERFORM update_job_info.

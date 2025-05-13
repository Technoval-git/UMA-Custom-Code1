*&---------------------------------------------------------------------*
*& Report ZCML_CONTRACT_UPLD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcml_contract_upld.

INCLUDE zclm_contract_upld_top.

INCLUDE zclm_contract_upld_sub.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_f4.

AT SELECTION-SCREEN.
  PERFORM f_value_scr_field.

START-OF-SELECTION.
*****  IF p_job IS INITIAL.
    PERFORM upload_excel.

    CONCATENATE 'ZRE_CONTRACT_CREATE' '_' sy-datum '_' sy-uzeit INTO gv_jobname.
*      Read Print Parameters
    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
        report                 = sy-cprog
        mode                   = gc_mode
        no_dialog              = gc_x1
      IMPORTING
        out_parameters         = lwa_priparams
      EXCEPTIONS
        archive_info_not_found = 1
        invalid_print_params   = 2
        invalid_archive_params = 3
        OTHERS                 = 4.
    IF sy-subrc NE 0.
      IF sy-msgid IS NOT INITIAL AND sy-msgno IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE gc_error NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
*****
*****    CALL FUNCTION 'JOB_OPEN'
*****      EXPORTING
*****        jobname  = gv_jobname
*****      IMPORTING
*****        jobcount = gv_jobcount.
*****    IF sy-subrc <> 0.
*****      IF NOT sy-msgid IS INITIAL.
*****        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*****          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*****      ENDIF.
*****    ENDIF.
*****    gv_repname = sy-repid.
*****
*****    MESSAGE 'Job Scheduled in background mode' TYPE 'S' DISPLAY LIKE 'S'.
*****
*****    SUBMIT (gv_repname)
*****           WITH p_file EQ p_file
*****           WITH r1_simu EQ r1_simu
*****           WITH r2_updt EQ r2_updt
*****           WITH p_job EQ gc_x1
*****               TO SAP-SPOOL SPOOL PARAMETERS lwa_priparams
*****      WITHOUT SPOOL DYNPRO
*****      VIA JOB gv_jobname NUMBER gv_jobcount
*****      AND RETURN.
*****
*****    CALL FUNCTION 'JOB_CLOSE'
*****      EXPORTING
*****        jobcount             = gv_jobcount
*****        jobname              = gv_jobname
*****        strtimmed            = gc_x1
*****      EXCEPTIONS
*****        cant_start_immediate = 1
*****        invalid_startdate    = 2
*****        jobname_missing      = 3
*****        job_close_failed     = 4
*****        job_nosteps          = 5
*****        job_notex            = 6
*****        lock_failed          = 7
*****        invalid_target       = 8
*****        OTHERS               = 9.
*****    IF sy-subrc <> 0.
*****      IF NOT sy-msgid IS INITIAL.
*****        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*****                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*****      ENDIF.
*****    ELSE.
*****      MESSAGE TEXT-055 TYPE 'S'.
*****    ENDIF.
*****
*****  ENDIF.
*****  IF p_job IS NOT INITIAL.
    IMPORT gt_contract FROM DATABASE indx(id) ID 'ZREFX_CONTRACT_TAB'.
    IMPORT gt_conditions FROM DATABASE indx(id) ID 'ZREFX_CONDITIONS_TAB'.
    IF gt_contract[] IS  NOT INITIAL AND gt_conditions[] IS NOT INITIAL.
      PERFORM upload_file_valid.
      PERFORM call_bapi.
      PERFORM display.
    ENDIF.
*****  ENDIF.

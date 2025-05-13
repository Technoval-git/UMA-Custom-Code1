*&---------------------------------------------------------------------*
*& Report ZVSS_HONGQI_VEHICLE_PROCESS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_hongqi_vehicle_process.

INCLUDE zivss_hongqi_vehi_process_top.
INCLUDE zivss_hongqi_vehi_process_sel.
INCLUDE zivss_hongqi_vehi_process_form.

***********************************************************************
* AT SELECTION-SCREEN ON VALUE REUEST                                 *
***********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  IF pr_pi IS INITIAL.
    PERFORM form_on_val_req_file.
  ELSE.
    PERFORM form_on_val_req_pi USING p_file.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_succ.
  PERFORM form_on_val_req_pi USING p_succ.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_error.
  PERFORM form_on_val_req_pi USING p_error.

***********************************************************************
* AT SELECTION-SCREEN OUTPUT                                          *
***********************************************************************

AT SELECTION-SCREEN OUTPUT.
  IF sy-batch IS INITIAL.
* Clear File Path and Logical File Name when server change
    ON CHANGE OF pr_pi.
      CLEAR : p_file,p_logicl.
    ENDON.

    ON CHANGE OF pr_file.
      CLEAR : p_slogic,p_elogic. "p_succ,p_error,
    ENDON.
  ENDIF.

  IF pr_pc IS NOT INITIAL.   " Presentation server.
** Hide the Logical File Name Field when Presentation Server selected
    PERFORM form_hide_field USING gc_log.
  ELSE.
** Unhide the Logical File Name Field when Application Server selected
    PERFORM form_unhide_field USING gc_log.
  ENDIF.

  IF pr_file IS NOT INITIAL.
* Hide the Success & Error Logical File Name Fields
    PERFORM form_hide_field USING gc_lgc.
* Unhide the Success & Error File Path Fields
    PERFORM form_unhide_field USING gc_fil.
  ELSE.
* Hide the Success & Error File Path Fields
    PERFORM form_hide_field USING gc_fil.
* Unhide the Success & Error Logical File Name Fields
    PERFORM form_unhide_field USING gc_lgc.
  ENDIF.

***********************************************************************
* AT SELECTION-SCREEN                                                 *
***********************************************************************

AT SELECTION-SCREEN.
  PERFORM form_file_extension_allowed.

***********************************************************************
* START-OF-SELECTION                                                  *
***********************************************************************
START-OF-SELECTION.
* Fetching Success file path for given Success logical file name
  IF p_slogic IS NOT INITIAL.
    PERFORM form_fetch_filepath USING p_slogic CHANGING p_succ.
  ENDIF.

* Fetching Error file path for given Error logical file name
  IF p_elogic IS NOT INITIAL.
    PERFORM form_fetch_filepath USING p_elogic CHANGING p_error.
  ENDIF.
*
* Fetching file path for given logical file name
  PERFORM form_fetch_filepath USING p_logicl CHANGING p_file.
  PERFORM f_validate_log_path.

* Extract data from file
  PERFORM form_read_file USING pr_pi.

  IF it_source IS NOT INITIAL.
* Validate and create Inbound delivery for the given data
    PERFORM form_process_vehicle.
    PERFORM form_log.
  ELSE.
* Message to inform that the specified file contains no data
    MESSAGE TEXT-008 TYPE gc_succ DISPLAY LIKE gc_err.
  ENDIF.

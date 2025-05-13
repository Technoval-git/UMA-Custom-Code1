*&---------------------------------------------------------------------*
*&  Include           /DBE/LVEHI_MASS_PROCESSINGF63

MODULE log_creation OUTPUT.
  DATA :display_profile_ls  TYPE bal_s_prof.
  DATA :lo_bal TYPE REF TO /DBE/cl_bal.
  DATA :lt_log_handle TYPE bal_t_logh.
  DATA :lo_vehicless TYPE REF TO /DBE/cl_veh_dbmvehicle.
  DATA :lo_buff TYPE REF TO /DBE/cl_veh_buf.
  DATA :lo_bobb TYPE /DBE/t_veh_bob.
  DATA :ls_bobb TYPE /DBE/s_veh_bob.
  DATA :ls_msg_fcat LIKE bal_s_fcat.
  DATA :ls_bal_sort TYPE bal_s_sort.

  FIELD-SYMBOLS <fs_msg_fcat> TYPE bal_s_fcat.

  CALL FUNCTION 'BAL_DSP_PROFILE_NO_TREE_GET'
    IMPORTING
      e_s_display_profile = display_profile_ls.


  LOOP AT display_profile_ls-mess_fcat ASSIGNING <fs_msg_fcat>.
    CASE <fs_msg_fcat>-ref_field.
      WHEN 'T_MSG'.
        <fs_msg_fcat>-col_pos = 3.
    ENDCASE.
  ENDLOOP.

  CLEAR ls_msg_fcat.
  ls_msg_fcat-ref_table = 'BAL_S_SHOW'.
  ls_msg_fcat-ref_field = 'MSG_DATE'.
  ls_msg_fcat-col_pos = '1'.
  ls_msg_fcat-outputlen = '00008'.
  ls_msg_fcat-colddictxt = 'S'.
  APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

  CLEAR ls_msg_fcat.
  ls_msg_fcat-ref_table = 'BAL_S_SHOW'.
  ls_msg_fcat-ref_field = 'MSG_TIME'.
  ls_msg_fcat-col_pos = '2'.
  ls_msg_fcat-outputlen = '00008'.
  ls_msg_fcat-colddictxt = 'S'.
  APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

  IF  gv_action_log EQ /DBE/if_vms_constants=>c_qpdi.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_msg_fcat-ref_field = 'VHCLE'.
    ls_msg_fcat-col_pos = '4'.
    ls_msg_fcat-outputlen = '00012'.
    ls_msg_fcat-coltext = text-127.
    ls_msg_fcat-hotspot = 'X'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_msg_fcat-ref_field = 'VHVIN'.
    ls_msg_fcat-col_pos = '5'.
    ls_msg_fcat-outputlen = '15'.
    ls_msg_fcat-colddictxt = 'S'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_msg_fcat-ref_field = 'VHCEX'.
    ls_msg_fcat-col_pos = '6'.
    ls_msg_fcat-outputlen = '15'.
    ls_msg_fcat-colddictxt = 'S'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_msg_fcat-ref_field = 'CU_NAME1'.
    ls_msg_fcat-col_pos = '7'.
    ls_msg_fcat-outputlen = '10'.
    ls_msg_fcat-colddictxt = 'S'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_msg_fcat-ref_field = 'WERKS'.
    ls_msg_fcat-coltext = text-160.
    ls_msg_fcat-col_pos = '7'.
    ls_msg_fcat-outputlen = '6'.
    ls_msg_fcat-colddictxt = 'S'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_msg_fcat-ref_field = 'MMSTA'.
    ls_msg_fcat-col_pos = '8'.
    ls_msg_fcat-outputlen = '8'.
    ls_msg_fcat-colddictxt = 'S'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_msg_fcat-ref_field = 'SDSTA'.
    ls_msg_fcat-col_pos = '9'.
    ls_msg_fcat-outputlen = '8'.
    ls_msg_fcat-colddictxt = 'S'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_msg_fcat-ref_field = 'MATNR'.
    ls_msg_fcat-col_pos = '10'.
    ls_msg_fcat-outputlen = '15'.
    ls_msg_fcat-coltext = text-408.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_msg_fcat-ref_field = 'VBELN'.
    ls_msg_fcat-col_pos = '10'.
    ls_msg_fcat-outputlen = '15'.
    ls_msg_fcat-colddictxt = 'S'.
    ls_msg_fcat-hotspot = 'X'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    "Sorting Criteria
    CLEAR display_profile_ls-mess_sort.
    CLEAR ls_bal_sort.
    ls_bal_sort-spos = 1.
    ls_bal_sort-up = 'X'.
    ls_bal_sort-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_bal_sort-ref_field = 'VHCLE'.
    APPEND ls_bal_sort TO display_profile_ls-mess_sort.
    CLEAR ls_bal_sort.
    ls_bal_sort-spos = 2.
    ls_bal_sort-up = 'X'.
    ls_bal_sort-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_bal_sort-ref_field = 'VHVIN'.
    APPEND ls_bal_sort TO display_profile_ls-mess_sort.
    CLEAR ls_bal_sort.
    ls_bal_sort-spos = 3.
    ls_bal_sort-up = 'X'.
    ls_bal_sort-ref_table = '/DBE/VLCMSGCONTXT_EXT'.
    ls_bal_sort-ref_field = 'VBELN'.
    APPEND ls_bal_sort TO display_profile_ls-mess_sort.
  ELSE.
    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = 'VLCMSGCONTXT'.
    ls_msg_fcat-ref_field = 'VHCLE'.
    ls_msg_fcat-hotspot = 'X'.
    ls_msg_fcat-col_pos = '4'.
    ls_msg_fcat-outputlen = '00012'.
    ls_msg_fcat-coltext = text-127.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = 'VLCMSGCONTXT'.
    ls_msg_fcat-ref_field = 'VHVIN'.
    ls_msg_fcat-col_pos = '5'.
    ls_msg_fcat-outputlen = '15'.
    ls_msg_fcat-colddictxt = 'S'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    CLEAR ls_msg_fcat.
    ls_msg_fcat-ref_table = 'VLCMSGCONTXT'.
    ls_msg_fcat-ref_field = 'VHCEX'.
    ls_msg_fcat-col_pos = '6'.
    ls_msg_fcat-outputlen = '15'.
    ls_msg_fcat-colddictxt = 'S'.
    APPEND ls_msg_fcat TO display_profile_ls-mess_fcat.

    "Sorting Criteria
    CLEAR display_profile_ls-mess_sort.
    CLEAR ls_bal_sort.
    ls_bal_sort-spos = 1.
    ls_bal_sort-up = 'X'.
    ls_bal_sort-ref_table = 'VLCMSGCONTXT'.
    ls_bal_sort-ref_field = 'VHCLE'.
    APPEND ls_bal_sort TO display_profile_ls-mess_sort.

    CLEAR ls_bal_sort.
    ls_bal_sort-spos = 2.
    ls_bal_sort-up = 'X'.
    ls_bal_sort-ref_table = 'VLCMSGCONTXT'.
    ls_bal_sort-ref_field = 'VHVIN'.
    APPEND ls_bal_sort TO display_profile_ls-mess_sort.

  ENDIF.

  "Call back routing for order navigation from log
  display_profile_ls-clbk_ucom-userexitp = '/DBE/SAPLVEHI_MASS_PROCESSING'.
  display_profile_ls-clbk_ucom-userexitf = 'LOG_CALLBACK_ORDER'.
  display_profile_ls-clbk_ucom-userexitt = ' '.
  display_profile_ls-use_grid = 'X'.

  CALL FUNCTION 'BAL_DSP_OUTPUT_INIT'
    EXPORTING
      i_s_display_profile = display_profile_ls
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD /DBE/cl_veh_buf=>get_instance
    RECEIVING
      ro_instance = lo_buff.
  TRY.
    CALL METHOD lo_buff->get_all
      RECEIVING
        rt_bob = lo_bobb.
  ENDTRY.
  REFRESH lt_log_handle.

  LOOP AT lo_bobb INTO ls_bobb.
    lo_vehicless ?= ls_bobb-bobref.
    lo_bal = lo_vehicless->mo_bal.
    IF lo_vehicless->mo_bal IS BOUND.
      INSERT lo_bal->mv_log_handle_tmp  INTO TABLE lt_log_handle.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'BAL_DSP_OUTPUT_SET_DATA'
    EXPORTING
      i_t_log_handle       = lt_log_handle
      i_srt_by_timstmp     = abap_false
    EXCEPTIONS
      internal_error       = 1
      profile_inconsistent = 2
      OTHERS               = 3.
ENDMODULE.                    "log_creation OUTPUT

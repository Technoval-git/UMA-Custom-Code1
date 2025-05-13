*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  FIND_ACTIVE_TAB_SET  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE find_active_tab_set OUTPUT.
  mass-activetab = g_find-pressed_tab.
  CASE g_find-pressed_tab.
    WHEN gc_find-gc_tab1.
      g_find-subscreen = gv_default_search_screen.
      gv_subscreen_program = gc_mass_main_program.
      gv_subscreen_dynpro =  g_find-subscreen.
    WHEN gc_find-gc_tab2.
      g_find-subscreen = gc_create_subscreen.
      gv_subscreen_program = gc_mass_main_program.
      gv_subscreen_dynpro =  g_find-subscreen.
    WHEN gc_find-gc_tab3.
      g_find-subscreen = gc_result_subscreen.
      gv_subscreen_program = gc_mass_main_program.
      gv_subscreen_dynpro =  g_find-subscreen.
    WHEN gc_find-gc_tab4.
      g_find-subscreen = gc_log_subscreen.
*      gv_subscreen_program = 'SAPLSBAL_DISPLAY'.
*      gv_subscreen_dynpro =  '0101'.
      gv_subscreen_program = gc_mass_main_program.
      gv_subscreen_dynpro =  g_find-subscreen.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
*  gv_subscreen_program = gc_mass_main_program.
*  gv_subscreen_dynpro =  g_find-subscreen.

*  if sy-uname = 'BHATTANO' and gv_subscreen_dynpro = gc_log_subscreen.
**data display_profile_ls type BAL_S_PROF.
*  CALL FUNCTION 'VELO03_BAL_DSP_PROFILE_GET'
*    EXPORTING
*      protokoll_ab_datum_iv = sy-datum
*      protokoll_ab_uzeit_iv = sy-uzeit
*    IMPORTING
*      display_profile_es    = display_profile_ls.
*
*  display_profile_ls-use_grid = 'X'.
*  CALL FUNCTION 'BAL_DSP_OUTPUT_INIT'
*    EXPORTING
*      i_s_display_profile = display_profile_ls.
*
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
** data : lo_buf1 type ref to /DBE/cl_veh_buf.
**  data : lt_bob1 type /DBE/t_veh_bob.
**  data ls_bob1 like line of lt_bob1.
**  data lo_vehicle1 type ref to /DBE/cl_veh_dbmvehicle.
**  data lo_bal type ref to /DBE/cl_bal.
**  data lt_log_handle type BAL_T_LOGH .
*CALL METHOD /DBE/cl_veh_buf=>get_instance
*     RECEIVING
*       ro_instance = lo_buf1     .
*  TRY.
*   CALL METHOD lo_buf1->get_all
*     RECEIVING
*       rt_bob = lt_bob1       .
*   ENDTRY.
**  LOOP AT gt_vsresult_selection INTO gs_selection.
*
*
*  loop at lt_bob1 into ls_bob1 ."with key guid = gs_selection-vguid.
**   if sy-subrc = 0 .
*
*     lo_vehicle1 ?= ls_bob1-bobref.
**
**     CALL METHOD lo_vehicle1->get_instance_bal
**       EXPORTING
**         iv_guid     = ls_bob1-guid
**         iv_context  = 'VLCMSGCONTXT'
**       receiving
**         ro_instance = lo_bal .
*lo_bal = lo_vehicle1->mo_bal.
*
**    REFRESH io_bal->mt_log_handle.
*    APPEND lo_bal->mv_log_handle_tmp TO lt_log_handle.
**    endif.
*  ENDLOOP.
*
*  CALL FUNCTION 'BAL_DSP_OUTPUT_SET_DATA'
*    EXPORTING
*      i_t_log_handle       = lt_log_handle
*    EXCEPTIONS
*      internal_error       = 1
*      profile_inconsistent = 2
*      OTHERS               = 3.
*
** g_subscreen_prog      = 'SAPLSBAL_DISPLAY'.
**  g_subscreen_dynp      = '0101'.
**  g_tabstrip-activetab  = 'TAB4'.
**  CALL SCREEN 100.
**  CALL FUNCTION 'BAL_DSP_OUTPUT_FREE'.
*
*
*  endif.

ENDMODULE.                 " FIND_ACTIVE_TAB_SET  OUTPUT

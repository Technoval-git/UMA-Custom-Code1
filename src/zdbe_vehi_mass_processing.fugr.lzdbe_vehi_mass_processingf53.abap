*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF53 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  log_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form log_display .
    DATA :
        display_profile_ls  TYPE bal_s_prof,
        protocol_handle_gt TYPE bal_t_logh.

  CALL FUNCTION '/DBE/VMASS_PROFILE_GET'
    EXPORTING
      protokoll_ab_datum_iv = sy-datum
      protokoll_ab_uzeit_iv = sy-uzeit
    IMPORTING
      display_profile_es    = display_profile_ls.



  CALL FUNCTION 'VELO03_BAL_DSP_LOG_DISPLAY'
    EXPORTING
      t_log_handle_iv    = protocol_handle_gt
      i_amodal_iv        = abap_false
      display_profile_is = display_profile_ls.

                " PBO_1500_LOG  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_DYNPRO_SET  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE screen_dynpro_set OUTPUT.
**  gv_tab_subscreen_program = gv_badi_program = sy-repid.
**  gv_tab_subscreen_dynpro = gv_badi_dynpro = sy-dynnr.
*ENDMODULE.                 " SCREEN_DYNPRO_SET  OUTPUT

endform.                    " log_display

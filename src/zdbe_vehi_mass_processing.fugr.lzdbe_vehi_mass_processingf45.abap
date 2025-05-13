*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF45 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GLOBAL_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_global_init .

  IF go_option_search_alv IS BOUND.
    go_option_search_alv->free( ).
  ENDIF.
  IF grid IS BOUND.
    grid->free( ).
  ENDIF.
*IF go_option_search_container IS BOUND.
*  go_option_search_container->free( ).
*ENDIF.
  IF go_selvar_container IS BOUND.
    go_selvar_container->free( ).
  ENDIF.
  IF go_tree IS BOUND.
    go_tree->free( ).
  ENDIF.
  IF go_tree_container IS BOUND.
    go_tree_container->free( ).
  ENDIF.

  CLEAR:
  go_tree_container,
  badi_search_ui,
  mass,
  ok_code,
  gv_subscreen_program,
  gv_subscreen_dynpro,
  gv_tab_subscreen_program,
  gv_tab_subscreen_dynpro,
  gv_main_subscreen_program,
  gv_main_subscreen_dynpro,
  gv_badi_program,
  gv_badi_dynpro,
  gv_searchstring,
  gv_searchmode,
  gt_vlcdiavehi,
  gt_bapireturn,
  gv_error_search,
  grid,
  go_selvar_container,
  gt_mass_alv_var,
  gv_mass_icon_okay,
  gv_mass_icon_cancel,
  gt_mass_svariant_buf,
  gt_mass_svariant,
  gt_mass_svartxt_buf,
  gt_mass_svartxt,
  gt_mass_user_svcrit_buf,
  gt_mass_user_svcrit,
  gt_mass_user_svval_buf,
  gt_mass_user_svval,
  gv_mass_svariant_def,
  gv_external_function,
  gt_mass_search_crit,
  gt_search_crit_ext,
  gt_mass_search_crit_buf,
  gt_mass_usparam,
  gv_mass_usparam_exists,
  gv_prog_name,
  gv_prog_name_ext,
  gv_dynnr_name,
  gv_dynnr_name_ext,
  gv_mass_search_filled,
  gv_extsearch_filled,
  event_receiver,
  vlcselvehi,
  vlcvehicle,
  /DBE/V_IPRICES,
  /DBE/V_IPARTNER,
  /DBE/V_IMODEL,
  /DBE/v_model,
  vlcsearchcrit_lt,
  controlerr_lt,
  gv_external_mode,
  go_option_search_alv,
  suche_tab,
  searchtab2.

  IF <gf_varlistitem_shown> IS ASSIGNED.
    UNASSIGN:
    <gf_varlistitem_shown>,
    <gf_text>,
    <gf_fuzzy>,
    <gf_exact>.
*  <gf_stockage>.
  ENDIF.

  REFRESH:
  gt_vlcdiavehi,
  gt_bapireturn,
  gt_mass_alv_var,
  gt_mass_svariant_buf,
  gt_mass_svariant,
  gt_mass_svartxt_buf,
  gt_mass_svartxt,
  gt_mass_user_svcrit_buf,
  gt_mass_user_svcrit,
  gt_mass_user_svval_buf,
  gt_mass_user_svval,
  gt_mass_search_crit,
  gt_search_crit_ext,
  gt_mass_search_crit_buf,
  gt_mass_usparam,
  vlcsearchcrit_lt,
  controlerr_lt.

ENDFORM.                    " f_global_init
*&---------------------------------------------------------------------*
*&      Module  M_CHECK_CREATE_AUTHORIZATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_create_authorization INPUT.

  IF gv_ok_code EQ 'ACT_EXE'.
    PERFORM check_mass_actions_authority USING gv_action.
  ENDIF.

ENDMODULE.                 " M_CHECK_CREATE_AUTHORIZATION  INPUT

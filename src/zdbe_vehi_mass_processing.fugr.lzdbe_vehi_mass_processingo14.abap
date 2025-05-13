*----------------------------------------------------------------------*
***INCLUDE /DBE/LVM06O03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  result_screen_dynpro_set  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE result_screen_dynpro_set OUTPUT.

  PERFORM result_screen_dynpro_set.

ENDMODULE.                 " result_screen_dynpro_set  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CLEAR_FIELDS_1300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_fields_1300 INPUT.
  "Uncheck the diabling flag for create vehicle button in pop up.
  gv_disable_button_qcre = abap_false.
  "Clear the custome container for screen 101 if it is bound
  IF go_options_container IS BOUND.
            CLEAR :gt_optionalv, gt_optionalv_all.
    IF go_alv_opt_grid IS BOUND.
      CLEAR go_alv_opt_grid.
    ENDIF.
*      CLEAR: gt_optionalv, gt_optionalv_all.
*      go_alv_opt_grid->refresh_table_display( ).
*    ENDIF.
    TRY.
    CALL METHOD go_options_container->free.
    ENDTRY.
    CLEAR go_options_container.
  ENDIF.
*  IF go_alv_opt_grid IS BOUND.
*    CLEAR gs_layout_optalv-grid_title.
*    CLEAR: gt_optionalv, gt_optionalv_all.
*    go_alv_opt_grid->refresh_table_display( ).
*  ENDIF.
ENDMODULE.                 " CLEAR_FIELDS_1300  INPUT

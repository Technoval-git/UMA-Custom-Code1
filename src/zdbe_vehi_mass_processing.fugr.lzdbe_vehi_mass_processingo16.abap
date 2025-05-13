*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO16 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_INITIALIZE_CREA_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_initialize_crea_screen OUTPUT.

  IF gv_ok_code EQ gc_opclass AND gv_ok_code EQ gc_load_okcode.
    RETURN.
  ENDIF.

  IF gv_ok_code EQ 'WORKLIST'.
    CLEAR :
           vlcactdata_head_s-werks,
           vlcactdata_item_s-/dbe/spart,
           gt_optionalv,
           gt_optionalv_all.

    IF go_alv_opt_grid IS BOUND.
      CALL METHOD go_alv_opt_grid->refresh_table_display( ).
    ENDIF.
  ENDIF.
  IF vlcactdata_head_s-werks IS INITIAL AND
    vlcactdata_item_s-/dbe/spart IS INITIAL.
    PERFORM f_check_catalog.
    CLEAR :
      vlcactdata_item_s,
      vlcactdata_head_s,
      /dbe/v_imodel-mcodesd,
      gv_mcatalog.
  ENDIF.

*Currently we are supporting only 'New Vehicle' buis transaction type.
  vlcactdata_head_s-/dbe/bustype = 'NEC'.
  IF vlcactdata_head_s-numofvehi EQ 0.
    vlcactdata_head_s-numofvehi = 1.
  ENDIF.

  PERFORM f_initialize_crea_screen.

  "clear this flag on initialization
  CLEAR gv_block_navigation.

  LOOP AT SCREEN.
    IF screen-name EQ 'EXEC' .
      IF gv_disable_button_qcre EQ abap_true.
        screen-invisible = 1.
      ELSE.
        screen-invisible = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.


ENDMODULE.                 " M_INITIALIZE_CREA_SCREEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_UPDATE_SCREEN_ELEMENT_101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_show_optionalv_101 OUTPUT.

  PERFORM f_create_options.
ENDMODULE.                 " M_UPDATE_SCREEN_ELEMENT_101  OUTPUT
*----------------------------------------------------------------------*
*  MODULE set_cursor OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.
  CASE gv_cursor_on_field.
    WHEN '/DBE/V_IMODEL-MCODESD'.
      SET CURSOR FIELD '/DBE/V_IMODEL-MCODESD'.
    WHEN 'GV_OPCLASS'.
      SET CURSOR FIELD 'GV_OPCLASS'.
    WHEN 'VLCACTDATA_ITEM_S-/DBE/SPART'.
      SET CURSOR FIELD 'VLCACTDATA_ITEM_S-/DBE/SPART'.
    WHEN 'VLCACTDATA_HEAD_S-WERKS'.
      SET CURSOR FIELD 'VLCACTDATA_HEAD_S-WERKS'.
    WHEN 'BUT_OPTION'.
      SET CURSOR FIELD 'BUT_OPTION'.
    WHEN OTHERS.
  ENDCASE.
  CLEAR gv_cursor_on_field.
ENDMODULE.                    "set_cursor INPUT

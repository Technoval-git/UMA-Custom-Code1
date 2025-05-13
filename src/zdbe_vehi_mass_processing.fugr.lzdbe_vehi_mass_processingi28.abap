*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI28 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command INPUT.
 "ty_optionalv.
  DATA:
        ls_bapiret2 TYPE bapiret2,
        change_flag     TYPE abap_bool.

  CALL FUNCTION '/DBE/VMASS_GET_OK_CODE'
    IMPORTING
      ev_ok_code = gv_ok_code.


  IF gv_adc_flag IS INITIAL AND sy-ucomm NE gc_error."
    CASE gv_ok_code.
      WHEN gc_exec_fc.
        IF gv_create_action = abap_true.
          CLEAR gt_vsresult.
          PERFORM execute_action.
          IF gt_vsresult IS INITIAL.
            gv_block_navigation = abap_true.
            MESSAGE i466(/DBE/vehicle_master) DISPLAY LIKE 'E'.
            RETURN.
          ENDIF.
          "For worklist alv title, don't clear it
          gv_action_for_alv = gv_action.
          CLEAR :    gv_create_action ,
                     gv_action.

          PERFORM update_configuration_list.

          CALL METHOD cl_gui_cfw=>flush.
          CLEAR : vlcactdata_head_s ,vlcactdata_item_s.

        ELSE.
          gv_tax_calculated = abap_false.
          PERFORM action_execute.
          gv_action_log = gv_action.
          CLEAR :
                 gv_action,
                 vlcactdata_head_s ,
                 vlcactdata_item_s,
                 gt_ac_post,gt_ac_cancel.
          PERFORM populate_main_message.
        ENDIF.
      WHEN gc_save_fc.                                      "2066130
        gv_tax_calculated = abap_false.
        gv_action_log = gv_action.
        CLEAR:
          gv_action,
          vlcactdata_head_s ,
          vlcactdata_item_s,
          gt_ac_post,gt_ac_cancel.
      WHEN 'WORKLIST' OR 'SEARCHVM' OR 'MASS_FC4'.
        CLEAR :   gt_optionalv, gt_optionalv_all.
        IF go_alv_opt_grid IS BOUND.
          CLEAR gs_layout_optalv-grid_title.
          go_alv_opt_grid->refresh_table_display( ).
        ENDIF.

        CLEAR :
              vlcactdata_head_s,
              vlcactdata_item_s,
              go_alv_opt_grid.

        IF go_options_container IS NOT INITIAL.
          TRY.
              CALL METHOD go_options_container->free.
            CATCH cx_sy_ref_is_initial.
          ENDTRY.
          CLEAR:go_options_container.
        ENDIF.
        CALL METHOD cl_gui_cfw=>flush.

        CALL FUNCTION 'VRM_DELETE_VALUES'
          EXPORTING
            id           = 'GV_OPCLASS'
          EXCEPTIONS
            id_not_found = 1
            OTHERS       = 2.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDMODULE.                 " M_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Form  UPDATE_CONFIGURATION_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_configuration_list .
  "data declaration
  FIELD-SYMBOLS:  <fs_optionalv> TYPE /DBE/v_options .

  LOOP AT gt_optionalv_all ASSIGNING <fs_optionalv>.
    IF <fs_optionalv>-copy_rel EQ abap_true.
      <fs_optionalv>-sel_option = abap_true.
    ELSE.
      <fs_optionalv>-sel_option = abap_false.
    ENDIF.
  ENDLOOP.

  gt_optionalv = gt_optionalv_all.
  gv_opclass = text-002.
  CLEAR : gt_optionalv,  gt_optionalv_all.

  IF go_alv_opt_grid IS BOUND.
    go_alv_opt_grid->refresh_table_display( ).
  ENDIF.
  CLEAR :go_alv_opt_grid.
  IF go_options_container IS NOT INITIAL.
    TRY.
        CALL METHOD go_options_container->free.
      CATCH cx_sy_ref_is_initial.
    ENDTRY.
    CLEAR:go_options_container.
  ENDIF.

ENDFORM.                    " UPDATE_CONFIGURATION_LIST

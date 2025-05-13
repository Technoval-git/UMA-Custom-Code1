**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGP03 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&       Class (Implementation)  lcl_tree_application
**&---------------------------------------------------------------------*
**        Text
**----------------------------------------------------------------------*
*class lcl_tree_application implementation.
*
*  METHOD  handle_checkbox_change.
*
*    DATA: lv_go_group TYPE /DBE/veh_gogr,
*          lv_gen_opt  TYPE /DBE/gen_opt.
*
*    FIELD-SYMBOLS: <fs_genopt> TYPE /DBE/s_veh_vs_tree_genopt.
*
*    lv_go_group = node_key+0(5).
*    lv_gen_opt  = node_key+5(5).
*
*    READ TABLE gt_genopt ASSIGNING <fs_genopt>
*                         WITH KEY go_group = lv_go_group
*                                  gen_opt  = lv_gen_opt.
*    IF <fs_genopt> IS ASSIGNED.
*      IF <fs_genopt>-checked IS INITIAL.
*        <fs_genopt>-checked = abap_true.
*      ELSE.
*        CLEAR: <fs_genopt>-checked.
*      ENDIF.
*    ENDIF.
*
*    lcl_tree_group_icon=>update_group_icon(
*      EXPORTING
*        iv_go_group = lv_go_group
*        iv_col_name = gc_column-column_1
*      ).
*    set_data_changed( ).
*  ENDMETHOD.                    "HANDLE_CHECKBOX_CHANGE
*
*  METHOD is_data_changed.
*    ev_changed = mv_changed.
*    mv_changed = abap_undefined.
*  ENDMETHOD.
*
*  METHOD set_data_changed.
*    mv_changed = abap_true.
*  ENDMETHOD.
*
*endclass.               "lcl_tree_application

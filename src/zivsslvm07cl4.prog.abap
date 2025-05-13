*&---------------------------------------------------------------------*
*& Include          ZIVSSLVM07CL4
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcl_tree_application DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_tree_application_u DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS:
      handle_checkbox_change
      FOR EVENT checkbox_change
                  OF        cl_gui_column_tree
        IMPORTING node_key item_name checked.               "#EC NEEDED

ENDCLASS.                    "lcl_tree_application DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_tree_application IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_tree_application_u IMPLEMENTATION.

  METHOD handle_checkbox_change.

    DATA: lv_go_group TYPE /dbe/veh_gogr,
          lv_gen_opt  TYPE /dbe/gen_opt,
          ls_igenopt  TYPE /dbe/v_igenopt_dynp.

    FIELD-SYMBOLS: <fs_genopt> TYPE /dbe/s_veh_vs_tree_genopt.

    lv_go_group = node_key+0(5).
    lv_gen_opt  = node_key+5(5).

    READ TABLE gt_genopt ASSIGNING <fs_genopt>
                         WITH KEY go_group = lv_go_group
                                  gen_opt  = lv_gen_opt.
    IF <fs_genopt> IS ASSIGNED.
      IF <fs_genopt>-checked IS INITIAL.
        <fs_genopt>-checked = abap_true.
      ELSE.
        CLEAR: <fs_genopt>-checked.
      ENDIF.
    ENDIF.

    lcl_tree_group_icon=>update_group_icon(
      EXPORTING
        iv_go_group = lv_go_group
        iv_col_name = gc_column-column_1 ).

*   Update ALL iObject data
    CLEAR gs_iobj_multi-/dbe/v_igenopt[].

    LOOP AT gt_genopt ASSIGNING <fs_genopt>
                      WHERE checked = abap_true.
      CLEAR ls_igenopt.
      MOVE <fs_genopt>-gen_opt TO ls_igenopt-genopt.
      APPEND ls_igenopt TO gs_iobj_multi-/dbe/v_igenopt.
    ENDLOOP.

*   Move generic options iObject data to buffer
    PERFORM f_transfer_data.

  ENDMETHOD.                    "HANDLE_CHECKBOX_CHANGE

ENDCLASS.                    "lcl_tree_application IMPLEMENTATION

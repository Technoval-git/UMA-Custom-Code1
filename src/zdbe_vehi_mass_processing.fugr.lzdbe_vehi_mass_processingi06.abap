**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGI06 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Module  USER_COMMAND_1000  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE user_command_1000 INPUT.
*
**Set OK_code
**
**  CASE ok_code.
**    WHEN 'BACK'.
**      LEAVE TO SCREEN 0.
**    WHEN 'CANCEL'.
**      LEAVE TO SCREEN 0.
**    WHEN 'EXIT'.
**      LEAVE TO SCREEN 0.
**    WHEN OTHERS.
**  ENDCASE.
*
*  DATA : save_ok TYPE sy-ucomm.
*  DATA : lv_count TYPE i.
*
*  save_ok = ok_code.
*  CLEAR ok_code.
*
*  CASE save_ok.
*
*    WHEN gc_searchvm_fc.
*
*      PERFORM search_subscreen_set.
**
**    WHEN gc_extsearchvm_fc.
**
**      PERFORM ext_search_subscreen_set.
**
*    WHEN gc_worklist_fc.
*
*      MOVE mass-activetab TO gv_last_search_tab.
*      PERFORM overview_subscreen_set.
*
*
*    WHEN gc_execute_fc.
**
*      IF mass-activetab = gc_searchvm_fc.
**        OR
**         tabstrip-activetab = gc_extsearchvm_fc.
*        PERFORM execute_search.
*      ENDIF.
*
*      IF gv_error_search IS NOT INITIAL.
*        RETURN.
*      ENDIF.
*
*      MOVE mass-activetab TO gv_last_search_tab.
*
*      DESCRIBE TABLE gt_vehicles LINES lv_count.
*
*      IF lv_count EQ 1 AND gv_external_function NE gc_assign_fc.
**        PERFORM vahicle_master_trans_call USING space.
*      ELSE.
*        PERFORM overview_subscreen_set.
*      ENDIF.
*
**      CLEAR: gv_error_search.
**
**    WHEN gc_new_fc.
**
**      CLEAR: gt_bapireturn[].
**      PERFORM vahicle_master_trans_call USING gc_x.
*
**    WHEN gc_back_fc.
**
**      IF tabstrip-activetab = gc_searchvm_fc    OR
**         tabstrip-activetab = gc_extsearchvm_fc.
**        IF sy-calld = abap_true AND sy-cprog = '/DBE/SAPLVM05'.
**          LEAVE PROGRAM.
**        ELSE.
**          LEAVE TO SCREEN 0.
**        ENDIF.
**      ELSE.
**        CLEAR: gt_bapireturn[].
**
**        IF gv_last_search_tab = gc_searchvm_fc.
**          PERFORM search_subscreen_set.
**        ELSE.
**          PERFORM ext_search_subscreen_set.
**        ENDIF.
**
**      ENDIF.
*
*  ENDCASE.
*
*ENDMODULE.                 " USER_COMMAND_1000  INPUT

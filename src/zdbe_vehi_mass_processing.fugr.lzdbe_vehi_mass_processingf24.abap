**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGF24 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Form  PAI_USER_COMMAND_1200
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*form PAI_USER_COMMAND_1200 .
*
*  DATA: lv_svariant        TYPE /DBE/svariant,
*        lt_search_crit     TYPE /DBE/veh_searchcrit_t,
*        lt_search_crit_tmp TYPE /DBE/veh_searchcrit_t,
*        lt_search_crit_buf TYPE /DBE/veh_searchcrit_t,
*        lt_search_crit_2   TYPE /DBE/veh_searchcrit_t.
*  DATA: lv_tabix      TYPE sy-tabix.
*
*  FIELD-SYMBOLS: <fs_search_crit> TYPE /DBE/veh_searchcrit.
*
*  CASE ok_code.
*    WHEN gc_svar_fc.
*      CALL SCREEN 1210 STARTING AT 25 6.
*
*    WHEN gc_listbox_fc.
*      PERFORM f_clear_fields.
*      CLEAR: gv_search_filled, gv_extsearch_filled, gt_search_crit_ext[],
*             gt_search_crit_buf.
*      lv_svariant = <gf_varlistitem_shown>.
*      PERFORM f_load_variant USING lv_svariant.
*      PERFORM f_find_tab_text_set .
*      gv_read_oem_opt_texts = abap_true.
*      PERFORM f_search_data_get CHANGING gt_search_crit_buf.
*
*    WHEN gc_clear_fc.
*      PERFORM f_clear_fields.
*      CLEAR: gv_search_filled, gv_extsearch_filled, gt_search_crit_ext[],
*             gt_search_crit_buf.
*      PERFORM f_find_tab_text_set .
*      CLEAR <gf_varlistitem_shown>.
*
*    WHEN gc_execute_fc.
*      if go_option_search_alv IS BOUND.
*        go_option_search_alv->raise_event( EXPORTING i_ucomm = 'EXECUTE' ).
*      endif.
*      PERFORM f_search_data_get CHANGING lt_search_crit.
*      IF lt_search_crit IS INITIAL OR gt_search_crit NE lt_search_crit.
*        IF gt_search_crit_buf NE lt_search_crit.
*          CLEAR: <gf_varlistitem_shown>, gt_search_crit_buf.
*        ENDIF.
*      ENDIF.
**     Clear engine performance unit in case when the performance has not been set
*      READ TABLE lt_search_crit WITH KEY tab = '/DBE/V_IMODEL' qual = 'ENG_PERFO_U' TRANSPORTING NO FIELDS.
*      IF sy-subrc EQ 0.
*        lv_tabix = sy-tabix.
*        READ TABLE lt_search_crit WITH KEY tab = '/DBE/V_IMODEL' qual = 'ENG_PERFO' TRANSPORTING NO FIELDS.
*          IF sy-subrc NE 0.
*            DELETE lt_search_crit INDEX lv_tabix.
*          ENDIF.
*        CLEAR lv_tabix.
*      ENDIF.
*
*    WHEN OTHERS.
**     check whether the criteria are the same as before user activity
**     (e.g. multiple selection popup, tabstrip change, etc.)
*      lt_search_crit_tmp = gt_search_crit.
*      lt_search_crit_buf = gt_search_crit_buf.
*      PERFORM f_search_data_get CHANGING lt_search_crit.
*      lt_search_crit_2 = lt_search_crit.
*      LOOP AT lt_search_crit ASSIGNING <fs_search_crit> WHERE sign CA 'AB'.
*        IF <fs_search_crit>-sign = 'A'.
*          <fs_search_crit>-sign = 'I'.
*        ELSE.
*          <fs_search_crit>-sign = 'E'.
*        ENDIF.
*      ENDLOOP.
*      LOOP AT lt_search_crit_buf ASSIGNING <fs_search_crit> WHERE sign CA 'AB'.
*        IF <fs_search_crit>-sign = 'A'.
*          <fs_search_crit>-sign = 'I'.
*        ELSE.
*          <fs_search_crit>-sign = 'E'.
*        ENDIF.
*      ENDLOOP.
*      SORT lt_search_crit     BY tab  ASCENDING qual   ASCENDING
*                                 sign ASCENDING option ASCENDING
*                                 low  ASCENDING high   ASCENDING.
*      SORT lt_search_crit_tmp BY tab  ASCENDING qual   ASCENDING
*                                 sign ASCENDING option ASCENDING
*                                 low  ASCENDING high   ASCENDING.
*      SORT lt_search_crit_buf BY tab  ASCENDING qual   ASCENDING
*                                 sign ASCENDING option ASCENDING
*                                 low  ASCENDING high   ASCENDING.
*      DELETE ADJACENT DUPLICATES FROM lt_search_crit     COMPARING ALL FIELDS.
*      DELETE ADJACENT DUPLICATES FROM lt_search_crit_tmp COMPARING ALL FIELDS.
*      DELETE ADJACENT DUPLICATES FROM lt_search_crit_buf COMPARING ALL FIELDS.
*      IF ( lt_search_crit IS INITIAL OR lt_search_crit_tmp NE lt_search_crit AND lt_search_crit_tmp IS NOT INITIAL )
*        OR ( go_tree_application IS BOUND AND go_tree_application->is_data_changed( ) = abap_true )
*        OR ( go_alvopt_handler IS BOUND AND go_alvopt_handler->is_data_changed( ) = abap_true )
*        OR ( lt_search_crit_buf IS NOT INITIAL AND lt_search_crit_buf NE lt_search_crit ).
*        CLEAR: <gf_varlistitem_shown>, gt_search_crit_buf.
*      ENDIF.
**     Search criteria buffer table is used to store the search criteria data
**     which was loaded with variant. If any changes were made on the sreen
**     fields then the selected load variant will be unselected from the variant dropdown.
*      if     <gf_varlistitem_shown> is     ASSIGNED
*         AND <gf_varlistitem_shown> IS NOT INITIAL.
*        gt_search_crit_buf = lt_search_crit_2.
*      endif.
*
*  ENDCASE.
*
*  gv_subscreen_dynpro = gc_variant_subscreen.
*
*endform.                    " PAI_USER_COMMAND_1200

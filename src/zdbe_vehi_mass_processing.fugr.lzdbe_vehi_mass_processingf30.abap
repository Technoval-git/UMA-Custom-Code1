*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF30 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SEARCH_DATA_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_SEARCH_CRIT  text
*----------------------------------------------------------------------*
FORM f_search_data_get  CHANGING lt_search_crit TYPE /DBE/veh_searchcrit_t.

  DATA: lt_vlcextcrit TYPE vlch_searchcrit_pt.
  DATA: ls_searchcrit TYPE /DBE/veh_searchcrit.
  DATA: lt_control    TYPE vlcsearchcontrol_t.
  DATA: ls_control    TYPE vlcsearchcontrol.
  DATA: lv_tabix      TYPE sy-tabix.
  DATA: lt_vlcsearchcrit TYPE vlch_searchcrit_pt.

  CLEAR: gt_mass_search_crit.

*Get the selection criteria from customer screen
  IF gv_subscreen_program NE gc_mass_main_program.
    CALL FUNCTION '/DBE/VMASS_SEARCHVIEWS_GETDATA'
*      IMPORTING
**        ev_text       = text
*        ev_fuzzy      = fuzzy
*        ev_exact      = exact
      TABLES
        et_vlcextcrit = lt_vlcextcrit
        et_contrerror = controlerr_lt
      EXCEPTIONS
        controlerror  = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
*get search criteria from the screen
    CALL FUNCTION '/DBE/MASS_VSEARCH_DATA_GET'
      TABLES
        vlcvehicrit_et = lt_vlcsearchcrit
        contrerror_et  = controlerr_lt
      EXCEPTIONS
        controlerror   = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

  APPEND LINES OF lt_vlcsearchcrit TO lt_search_crit.

*  READ TABLE lt_search_crit WITH KEY tab = '/DBE/V_IMODEL' qual = 'ENG_PERFO_U' TRANSPORTING NO FIELDS.
*  IF sy-subrc EQ 0.
*    lv_tabix = sy-tabix.
*    READ TABLE lt_search_crit WITH KEY tab = '/DBE/V_IMODEL' qual = 'ENG_PERFO' TRANSPORTING NO FIELDS.
*      IF sy-subrc NE 0.
*        DELETE lt_search_crit INDEX lv_tabix.
*      ENDIF.
*    CLEAR lv_tabix.
*  ENDIF.

  APPEND LINES OF lt_vlcextcrit TO lt_search_crit.

  CALL FUNCTION 'VELO14_READ_SEARCHCONTROL'
    TABLES
      control_et       = lt_control
    EXCEPTIONS
      no_entries_found = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT lt_search_crit INTO ls_searchcrit.
    lv_tabix = sy-tabix.
    READ TABLE lt_control INTO ls_control
                          WITH KEY sctable = ls_searchcrit-tab
                                   sctablefield = ls_searchcrit-qual.
    IF sy-subrc EQ 0.
      ls_searchcrit-qual = ls_control-scinterfacefield.
      MODIFY lt_search_crit FROM ls_searchcrit INDEX lv_tabix.
    ENDIF.
  ENDLOOP.

*  IF <gf_stockage> IS ASSIGNED.
*    IF NOT <gf_stockage> IS INITIAL.
*      ls_searchcrit-qual = 'STOCKAGE'.
*      ls_searchcrit-sign = 'I'.
*      ls_searchcrit-option = 'EQ'.
*      ls_searchcrit-low = <gf_stockage>.
*      APPEND ls_searchcrit TO lt_search_crit.
*    ENDIF.
*  ENDIF.

  IF lt_search_crit IS NOT INITIAL.
    MOVE gc_x       TO gv_mass_search_filled.
  ELSE.
    MOVE abap_false TO gv_mass_search_filled.
  ENDIF.

*"  APPEND LINES OF gt_search_crit_ext TO gt_search_crit.
  APPEND LINES OF gt_search_crit_ext TO lt_search_crit.

  IF gt_search_crit_ext IS NOT INITIAL.
    MOVE gc_x       TO gv_extsearch_filled.
  ELSE.
    MOVE abap_false TO gv_extsearch_filled.
  ENDIF.

ENDFORM.                    " F_SEARCH_DATA_GET

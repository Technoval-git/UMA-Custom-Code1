*&---------------------------------------------------------------------*
*& Report YSCC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT yscc_exaplme.
INCLUDE YSCC_TOP.
*INCLUDE YSCC1_TOP.
*INCLUDE YSCC_TOP.
INCLUDE YSCC_SEL.
*INCLUDE YSCC1_SELC.
*INCLUDE YSCC_selc.
INCLUDE YSCC_CLAS.
*INCLUDE YSCC1_CLAS.
*INCLUDE yscc_clas.
INITIALIZATION.
 comm1 = ' Please Update Golive date for all the plants in ZMM_GOLIVE table'.

AT SELECTION-SCREEN.
if rb_upd = 'X' or rb_rep = 'X'.
  IF p_region IS NOT INITIAL AND s_werks IS INITIAL.
    CLEAR s_werks.
    SELECT cpd , branch FROM zmm_cpd_plants INTO TABLE @DATA(lt_plants) WHERE region_sa = @p_region.
    IF lt_plants IS INITIAL.
      MESSAGE 'Region does not exit' TYPE 'E'.
    ENDIF.
    LOOP AT lt_plants INTO DATA(lw_plants).
      IF sy-tabix = 1.
        lw_werks-sign = 'I'.
        lw_werks-option = 'EQ'.
        lw_werks-low = lw_plants-cpd.
        APPEND lw_werks TO s_werks.
      ENDIF.
      lw_werks-sign = 'I'.
      lw_werks-option = 'EQ'.
      lw_werks-low = lw_plants-branch.
      APPEND lw_werks TO s_werks.
    ENDLOOP.

  ENDIF.
*  IF p_region IS INITIAL AND s_werks IS INITIAL.
*    MESSAGE 'Please Enter Region or Plant' TYPE 'E'.
*  ENDIF.
endif.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL METHOD lcl_scc=>f4help. " F4 HELP
AT SELECTION-SCREEN OUTPUT.
    SELECT region_sa cpd branch branch_cp cpd_pr FROM zmm_cpd_plants INTO TABLE lt_cpd_plants.

  CALL METHOD lcl_scc=>validation. " VALIDATION RADIO BUTTON
START-OF-SELECTION.
  DATA(obj) = NEW lcl_scc( ).
  CASE 'X'.
    WHEN rb_upl.
      IF p_file IS NOT INITIAL.
        call METHOD obj->xsl_to_tabel " xsl UPLOAD TO INTERNAL TABLE
          RECEIVING
            rr_table = data(lv_data).
        endif.
        if lv_data is NOT INITIAL.
        CALL METHOD obj->bapi_save_data " SAVE DATA ON STANDARD TABLE using bapi
          IMPORTING
            le_table = lv_data.
              ENDIF.
    WHEN  rb_rep.
      CALL METHOD obj->getdata. " GET SSF DATA BY REPORT
    WHEN rb_upd.
      CALL METHOD obj->get_material. " get material data for UPDATE
      IF lt_final IS NOT INITIAL.
*        CALL METHOD obj->get_dates. "dates seles q
        CALL METHOD obj->get_finaldata. " finadata on SSF CALUTION
        IF cb_sim = 'X'.
          CALL METHOD obj->display_update. " DISPLAY UPDATE SSF STOCK
        ELSE.
          CALL METHOD obj->update " UPDATE THE SSF STOCK
           RECEIVING
             rr_tabud = data(lt_update) .
          if lt_update is NOT INITIAL.
        CALL METHOD obj->bapi_save_data " UPDATE FOR SF STOCK
          IMPORTING
            le_table = lt_update.
        endif.
        ENDIF. "get Dates
      ENDIF.
  ENDCASE.

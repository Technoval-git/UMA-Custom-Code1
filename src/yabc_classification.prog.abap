*&---------------------------------------------------------------------*
*& Report YABC_CLASSIFICATION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT yabc_classification.


INCLUDE yabc_i_classification_top.
INCLUDE yabc_i_classification_selc.
INCLUDE yabc_i_classification_cls_im_1.
INCLUDE yabc_i_classification_cls_imp.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  lcl_selectionscreen=>file_f4help( ).

AT SELECTION-SCREEN OUTPUT.
  lcl_selectionscreen=>screen_validation( ).

  SELECT region_sa cpd branch branch_cp cpd_pr FROM zmm_cpd_plants INTO TABLE lt_cpd_plants.

AT SELECTION-SCREEN.

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
  IF p_region IS INITIAL AND s_werks IS INITIAL.
    MESSAGE 'Please Enter Region or Plant' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.

  CREATE OBJECT go_abc_main.

  CASE 'X'.
    WHEN rb_upl.
      go_abc_main->upload_file( ).
    WHEN rb_upd.

*      go_abc_main->calculate_dates(  ).
      go_abc_main->update_data(  ).
    WHEN rb_rep.
      go_abc_main->display_report( ).
  ENDCASE.

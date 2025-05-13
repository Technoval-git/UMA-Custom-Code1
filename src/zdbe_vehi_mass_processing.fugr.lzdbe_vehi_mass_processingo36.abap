*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO36 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_DETERMINE_LAYOUT_FOR_CPD  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_determine_layout_for_cpd OUTPUT.
  PERFORM f_determine_layout_for_cpd.
ENDMODULE.                 " M_DETERMINE_LAYOUT_FOR_CPD  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_LAYOUT_FOR_CPD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_determine_layout_for_cpd .
  CONSTANTS: lc_cpd(3) TYPE c VALUE 'CPD'.

* If the vendor is of type CPD, payment terms have to be provided.
* In this case this field has to be an input field on the screen.
* In case of a normal vendor with existing supplier master data,
* payment terms are invisible on the action screen.

  IF vlcactdata_head_s-ktokk CS lc_cpd.
    LOOP AT SCREEN.
      IF screen-name = 'VLCACTDATA_HEAD_S-PMNTTRMS'.
        screen-input = 1.
        screen-invisible = 0.
        screen-group1 = gc_ftype_in1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  IF has_diff_delv_date EQ abap_true.
*    LOOP AT SCREEN.
*      IF screen-name = 'VLCACTDATA_HEAD_S-EINDT'.
*        screen-active = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

ENDFORM.                    " F_DETERMINE_LAYOUT_FOR_CPD

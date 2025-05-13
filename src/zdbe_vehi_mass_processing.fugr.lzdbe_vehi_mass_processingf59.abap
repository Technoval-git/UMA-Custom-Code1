*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF59 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_READ_CREDITOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_read_creditor .

  DATA: ls_lfa1         TYPE lfa1,
        lv_before_after TYPE i.

  CONSTANTS: lc_cpd(3) TYPE c VALUE 'CPD'.

* read creditor master data and find out, if the supplier typed in
* is of class CPD
* In this case it is necessary to push the CPD-button and enter
* the creditor´s address manually.
* Since this address is stored in CAM´s global memory,
* it is necessary to create an address handle

  CALL FUNCTION 'VELO09_GET_BEFORE_AFTER'
    IMPORTING
      before_after_ev = lv_before_after.

  IF  lv_before_after = before_act_gc.
    IF NOT vlcactdata_head_s-lifnr IS INITIAL.
      CALL FUNCTION 'READ_LFA1'
        EXPORTING
          xlifnr         = vlcactdata_head_s-lifnr
        IMPORTING
          xlfa1          = ls_lfa1
        EXCEPTIONS
          key_incomplete = 1
          not_authorized = 2
          not_found      = 3
          OTHERS         = 4.
      IF sy-subrc <> 0.
        MESSAGE e239(velo) WITH vlcactdata_head_s-lifnr.
      ELSE.
        vlcactdata_head_s-ktokk = ls_lfa1-ktokk.
      ENDIF.
      IF sy-ucomm = fc_supp_gc.
        IF vlcactdata_head_s-ktokk NS lc_cpd.
*         Creditor is not of class CPD,
*         but address button has been pushed
          MESSAGE e236(velo).
        ENDIF.
      ENDIF.
    ELSE.
*     Creditor is initial
*      message e239(VELO).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_READ_CREDITOR

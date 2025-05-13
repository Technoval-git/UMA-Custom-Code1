*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF14 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DIVISION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_division .

*-- Data Declaration
  DATA: ls_tspa TYPE tspa.
  CONSTANTS: lc_catalog(25)    TYPE c VALUE '/DBE/V_MCATALOGT-MCATALOG',
           lc_catalog_txt(22) TYPE c VALUE '/DBE/V_MCATALOGT-DESCR'.

  IF vlcactdata_item_s-/DBE/spart IS NOT INITIAL.
    SELECT SINGLE * FROM  tspa
                    INTO  ls_tspa
                    WHERE spart =  vlcactdata_item_s-/DBE/spart.
    IF sy-subrc <> 0.
      gv_cursor_on_field = 'VLCACTDATA_ITEM_S-/DBE/SPART'.
      MESSAGE e098(cz) WITH vlcactdata_item_s-/DBE/spart.
    ENDIF.

    IF gv_old_division NE vlcactdata_item_s-/DBE/spart.
      gv_old_division = vlcactdata_item_s-/DBE/spart.
      CLEAR /DBE/V_IMODEL-mcodesd.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_DIVISION

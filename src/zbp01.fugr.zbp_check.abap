FUNCTION ZBP_CHECK.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(BU_SORT2) TYPE  BU_SORT2
*"  EXPORTING
*"     REFERENCE(FLAG) TYPE  CHAR1
*"     REFERENCE(BPARTNER) TYPE  BU_PARTNER
*"----------------------------------------------------------------------

  DATA: lv_bp_number(10).

  CLEAR: lv_bp_number.

  SELECT SINGLE partner INTO lv_bp_number FROM but000 WHERE bu_sort2 = bu_sort2.

  IF sy-subrc = 0.

    flag = 'X'.

    bpartner = lv_bp_number.

  ENDIF.



ENDFUNCTION.

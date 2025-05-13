*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF87 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_DRDN_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_drdn_table .

*§1.Define a dropdown table and pass it to ALV.
*   One listbox is referenced by a handle, e.g., '1'.
*   For each entry that shall appear in this listbox
*   you have to append a line to the dropdown table
*   with handle '1'.
*   This handle can be assigned to several columns
*   of the output table using the field catalog.
  DATA: ls_gr_create LIKE LINE OF gt_gr_create.
  DATA: lt_dropdown TYPE lvc_t_drop.
  DATA: ls_dropdown TYPE lvc_s_drop.
  DATA: lt_lgort TYPE TABLE OF t001l.
  DATA: ls_lgort LIKE t001l.

  LOOP AT gt_gr_create INTO ls_gr_create.
    SELECT * FROM t001l INTO CORRESPONDING FIELDS OF TABLE lt_lgort
             WHERE werks = ls_gr_create-werks.

    LOOP AT lt_lgort INTO ls_lgort.
      ls_dropdown-handle = '1'.
      ls_dropdown-value = ls_lgort-lgort.
      MOVE-CORRESPONDING ls_dropdown TO ls_gr_create.
      APPEND ls_dropdown TO lt_dropdown.
    ENDLOOP.
    IF go_gr_create IS BOUND.
      go_gr_create->set_drop_down_table(
        it_drop_down = lt_dropdown ).
    ENDIF.
    CLEAR: lt_lgort, lt_dropdown.
  ENDLOOP.

ENDFORM.                    " SET_DRDN_TABLE

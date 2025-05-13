*&---------------------------------------------------------------------*
*& Report ZVSS_OPEN_CLOSED_ORDER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_open_closed_order.

TABLES : /dbe/vbak_db.

PARAMETERS : p_order TYPE /dbe/vbak_db-vbeln,
             p_stat  TYPE /dbe/closed.

START-OF-SELECTION.

  SELECT SINGLE * FROM /dbe/vbak_db INTO @DATA(ls_vbak_db) WHERE vbeln EQ @p_order.
  IF sy-subrc EQ 0.
    UPDATE /dbe/vbak_db SET closed = p_stat WHERE vbeln EQ ls_vbak_db-vbeln.
    IF sy-subrc EQ 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.

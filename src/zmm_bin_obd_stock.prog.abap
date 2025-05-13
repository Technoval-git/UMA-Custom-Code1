*&---------------------------------------------------------------------*
*& Report ZMM_BIN_OBD_STOCK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_bin_obd_stock.
TABLES: mard.

DATA : it_fcat TYPE slis_t_fieldcat_alv,

       wa_fcat TYPE slis_fieldcat_alv.
TYPES: BEGIN OF TY_MarD,
         matnr TYPE matnr,
         werks TYPE werks_d,
         lgort TYPE lgort_d,
         labst TYPE labst,
       END OF ty_mard.

DATA: lt_mard TYPE  STANDARD TABLE OF ty_mard,
      ls_mARd TYPE ty_mard.

PARAMETERS: pv_matnr TYPE matnr OBLIGATORY.

START-OF-SELECTION.
  SELECT matnr werks lgort labst
    INTO TABLE lt_mard
    FROM MarD
    WHERE matnr = pv_matnr.

  PERFORM fill_alv USING '1' 'IT_DIS' 'MATNR' 'Material Number'.
  PERFORM fill_alv USING '1' 'IT_DIS' 'WERKS' 'Plant'.
  PERFORM fill_alv USING '1' 'IT_DIS' 'LGORT' 'Storage Location'.
  PERFORM fill_alv USING '1' 'IT_DIS' 'LABST' 'Availabe Stock'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat = it_fcat
    TABLES
      t_outtab    = lt_mard.


FORM fill_alv USING val1 val2 val3 val4.
  wa_fcat-col_pos = val1.
  wa_fcat-tabname = val2.
  wa_fcat-fieldname = val3.
  wa_fcat-seltext_m = val4.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.
ENDFORM.

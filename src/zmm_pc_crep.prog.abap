*----------------------------------------------------------------------*
***INCLUDE ZMM_PC_CREP.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zmm_pc_crep
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zmm_pc_crep .

  IF p_ac = 'X'.
    SELECT * FROM zmm_ac INTO TABLE gt_ac WHERE ac_delco IN s_matnr.
    CALL FUNCTION 'ZMM_ALV_POPUP'
      EXPORTING
        i_start_column = 5
        i_start_line   = 5
        i_end_column   = 200
        i_end_line     = 100
        i_title        = 'ALV'
        i_popup        = 'X'
      TABLES
        it_alv         = gt_ac.



  ELSEIF p_hq = 'X'.
    SELECT * FROM zmm_hq INTO TABLE gt_hq WHERE hq_matnr IN s_matnr.
    CALL FUNCTION 'ZMM_ALV_POPUP'
      EXPORTING
        i_start_column = 5
        i_start_line   = 5
        i_end_column   = 200
        i_end_line     = 100
        i_title        = 'ALV'
        i_popup        = 'X'
      TABLES
        it_alv         = gt_hq.

  ELSEIF p_gm = 'X'.
    SELECT * FROM zmm_gm INTO TABLE gt_gm WHERE gm_matnr IN s_matnr.
    CALL FUNCTION 'ZMM_ALV_POPUP'
      EXPORTING
        i_start_column = 5
        i_start_line   = 5
        i_end_column   = 200
        i_end_line     = 100
        i_title        = 'ALV'
        i_popup        = 'X'
      TABLES
        it_alv         = gt_gm.
  ELSEIF p_df = 'X'.
    SELECT * FROM zmm_df INTO TABLE gt_df WHERE df_matnr IN s_matnr.
    CALL FUNCTION 'ZMM_ALV_POPUP'
      EXPORTING
        i_start_column = 5
        i_start_line   = 5
        i_end_column   = 200
        i_end_line     = 100
        i_title        = 'ALV'
        i_popup        = 'X'
      TABLES
        it_alv         = gt_df.
  ELSEIF p_ma = 'X'.
    SELECT * FROM zmm_ma INTO TABLE gt_ma WHERE ma_matnr IN s_matnr.
    CALL FUNCTION 'ZMM_ALV_POPUP'
      EXPORTING
        i_start_column = 5
        i_start_line   = 5
        i_end_column   = 200
        i_end_line     = 100
        i_title        = 'ALV'
        i_popup        = 'X'
      TABLES
        it_alv         = gt_ma.
  ENDIF.


ENDFORM.

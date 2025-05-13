*&---------------------------------------------------------------------*
*& Report ZMM_MAP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_map.

TABLES: mseg, mbew, t001k, mara.



TYPES: BEGIN OF lty_final,
         matnr TYPE matnr,
         maktx TYPE maktx,
         mtart TYPE mtart,
         matkl TYPE matkl,
         verpr TYPE verpr,
         werks TYPE werks,
         bukrs TYPE bukrs,
         bwtar TYPE bwart,
       END OF lty_final.

DATA: BEGIN OF gs_material,
        matnr      TYPE matnr,
        budat_mkpf TYPE budat,
        update     TYPE c LENGTH 1,
      END OF gs_material,
      lt_mbew      TYPE TABLE OF mbew,
      lv_num       TYPE i,
      wa_fcat      TYPE slis_fieldcat_alv,
      it_fcat      TYPE slis_t_fieldcat_alv,
      wa_layout    TYPE slis_layout_alv,
      lv_verpr     TYPE mbew-verpr,
      lt_return    TYPE TABLE OF bapiret2,
      ltt_return   TYPE TABLE OF bapiret2,
      it_final     TYPE TABLE OF lty_final,
      lwa_final    TYPE lty_final,
      lv_pricedate TYPE bapi_matval_pricedate,
      lt_PRICES    TYPE STANDARD TABLE OF bapi_matval_prices,
      ls_prices    TYPE bapi_matval_prices,
      lv_newverpr  TYPE salk3.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
  s_matnr FOR gs_material-matnr,
  s_matkl FOR mara-matkl OBLIGATORY,
  S_mtart FOR mara-mtart OBLIGATORY,
  s_bwtar FOR mseg-bwtar,
  s_bukrs FOR t001k-bukrs.

  PARAMETERS:
    p_budat TYPE budat OBLIGATORY,   " Posting Date BUDAT_MKPF
    p_simu  AS CHECKBOX USER-COMMAND simu.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS:
    p_update RADIOBUTTON GROUP rb DEFAULT 'X' USER-COMMAND update,
    p_report RADIOBUTTON GROUP rb.
SELECTION-SCREEN END OF BLOCK b2.

START-OF-SELECTION.


  IF p_update = 'X' ."and p_simu = ' '.
    " Update Logic

    SELECT a~bwtar,
      a~mjahr,
    b~matnr,
    a~werks,
    a~bukrs,
    a~dmbtr,
    a~waers
    FROM mseg AS a INNER JOIN mara AS b ON a~matnr = b~matnr
    WHERE a~matnr IN @s_matnr
      AND a~bwart = '101'
      AND a~dmbtr IS NOT INITIAL
      AND a~budat_mkpf = @p_budat
      AND b~matkl IN @s_matkl
      AND b~mtart IN @s_mtart
*      AND a~bwtar IS NOT INITIAL
      ORDER BY a~bwtar, a~matnr, a~werks, a~bukrs
    INTO TABLE @DATA(lt_head).


    DELETE ADJACENT DUPLICATES FROM lt_head COMPARING ALL FIELDS.




    SELECT a~matnr,
           a~lbkum  AS lbkum,
           a~salk3 AS salk3",

      FROM zcds_map_price AS a
      "INNER JOIN lt_head as b on a~matnr = b~matnr
      FOR ALL ENTRIES IN @lt_head
      WHERE a~matnr = @lt_head-matnr
      INTO TABLE @DATA(lt_mbew_head).



    SELECT  bwkey FROM ckml_price_send INTO TABLE @DATA(lt_bwkey).    "  Need all entries.
    LOOP AT lt_head INTO DATA(lwa_head).

      IF gs_material-matnr <> lwa_head-matnr.
        SELECT SINGLE matnr , bwkey , bwtar , verpr,  peinh
                     INTO @DATA(lv_mbew)
                     FROM mbew
                     WHERE matnr = @lwa_head-matnr
                       AND bwkey = @lwa_head-werks
                       AND bwtar  = @lwa_head-bwtar.


        IF sy-subrc = 0 AND lv_mbew IS NOT INITIAL.
          SELECT a~bwkey FROM t001k AS a
              INNER JOIN mbew AS b ON a~bwkey = b~bwkey
              WHERE b~matnr = @lwa_head-matnr
                AND b~bwtar  = @lwa_head-bwtar
                AND a~bukrs = @lwa_head-bukrs
                     INTO  TABLE @DATA(lt_ZBWKEY).     "#EC CI_BUFFJOIN



          gs_material-matnr = lwa_head-matnr.

          READ TABLE lt_mbew_head INTO DATA(lw_mbew_head) WITH KEY matnr = lwa_head-matnr.

          CLEAR lv_newverpr .
**          lv_newverpr = lw_mbew_head-salk3 / lw_mbew_head-lbkum.
          lv_newverpr = lw_mbew_head-salk3.
          DIVIDE lv_newverpr BY lw_mbew_head-lbkum.

          LOOP AT lt_ZBWKEY INTO DATA(lw_zbwkey).
*            SELECT SINGLE bwkey FROM ckml_price_send INTO @DATA(lw_bwkey) WHERE bwkey = @lw_zbwkey-bwkey.
            READ TABLE lt_bwkey INTO DATA(lw_bwkey) WITH KEY bwkey = lw_zbwkey-bwkey.
            IF sy-subrc = 0.
              CALL FUNCTION 'DATE_TO_PERIOD_CONVERT'
                EXPORTING
                  i_date         = sy-datum "p_budat
*                 I_MONMIT       = 00
                  i_periv        = 'K4'
                IMPORTING
                  e_buper        = lv_pricedate-fisc_period
                  e_gjahr        = lv_pricedate-fisc_year
                EXCEPTIONS
                  input_false    = 1
                  t009_notfound  = 2
                  t009b_notfound = 3
                  OTHERS         = 4.


              lv_pricedate-price_date =  sy-datum. "p_budat .

              ls_prices-valuation_view = 0.
              ls_prices-curr_type = '10'.
              ls_prices-price = lv_newverpr. "lwa_head-dmbtr.
              ls_prices-currency = lwa_head-waers.

              ls_prices-price_unit =  lv_mbew-peinh.
              APPEND ls_prices TO lt_prices.



              CALL FUNCTION 'BAPI_MATVAL_PRICE_CHANGE'
                EXPORTING
*                 material      = gs_material-matnr
                  valuationarea = lw_zbwkey-bwkey
                  valuationtype = lwa_head-bwtar
                  pricedate     = lv_pricedate
                  material_long = gs_material-matnr
                TABLES
                  prices        = lt_prices
                  return        = lt_return.

              READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<abcd>) INDEX 1.
              IF sy-subrc = 0.
                CONCATENATE lw_zbwkey-bwkey   <abcd>-message INTO <abcd>-message SEPARATED BY space.
              ENDIF.
              APPEND  LINES OF lt_return[] TO ltt_return[].
              CLEAR : lt_return, lt_return[],lt_prices[].
              IF sy-subrc = 0.
                IF p_simu = ' '.
                  COMMIT WORK .
                ELSE.
*                  ROLLBACK WORK.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.


    IF ltt_return[] IS NOT INITIAL.
      CALL FUNCTION 'ZMM_ALV_POPUP'
        EXPORTING
          i_start_column = 5
          i_start_line   = 5
          i_end_column   = 150
          i_end_line     = 100
          i_title        = 'ALV'
          i_popup        = 'X'
        TABLES
          it_alv         = ltt_return.
    ENDIF.
  ENDIF.


  IF p_report = 'X'.
    SELECT b~matnr,
      b~bwtar,
      b~bwkey,
      c~maktx,
      d~mtart,
      d~matkl,
      b~verpr
      INTO TABLE @DATA(lt_report)
      FROM  mbew AS b
      INNER JOIN makt AS c ON b~matnr = c~matnr
      INNER JOIN mara AS d ON b~matnr = c~matnr
      WHERE b~matnr IN @s_matnr
        AND d~mtart IN @s_mtart
        AND d~matkl IN @s_matkl
        AND b~bwtar IN @s_bwtar
        AND b~laepr = @sy-datum
        AND c~spras = 'E'
         ORDER BY bwkey ,mtart, matkl.


    DELETE ADJACENT DUPLICATES FROM lt_report COMPARING bwkey mtart matkl matnr.

    LOOP AT lt_report INTO DATA(ls_report).
      lwa_final-matnr = ls_report-matnr.
      lwa_final-maktx = ls_report-maktx.
      lwa_final-mtart = ls_report-mtart.
      lwa_final-matkl = ls_report-matkl.
      lwa_final-verpr = ls_report-verpr.
      lwa_final-werks = ls_report-bwkey.
      lwa_final-bwtar = ls_report-bwtar.
      APPEND lwa_final TO it_final.
      CLEAR: lwa_final.
    ENDLOOP.


    PERFORM fill_fcat USING 'MATNR'               'Material code'.
    PERFORM fill_fcat USING 'MAKTX'               'Material description'.
    PERFORM fill_fcat USING 'MATKL'               'Material group'.
    PERFORM fill_fcat USING 'MTART'               'Material type'.
    PERFORM fill_fcat USING 'VERPR'               'Current MAP'.
    PERFORM fill_fcat USING 'BWKEY'               'Plant'.
    PERFORM fill_fcat USING 'BWTAR'               'Valuation Type'.


    PERFORM display_data.


  ENDIF.

FORM fill_fcat USING VALUE(p1)
                     VALUE(p2).
  lv_num = lv_num + 1.
  wa_fcat-fieldname = p1.
  wa_fcat-col_pos = lv_num.
  wa_fcat-seltext_l = p2.
  wa_fcat-tabname = 'lt_report'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.
ENDFORM.

FORM display_data.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-cprog
      is_layout          = wa_layout
      it_fieldcat        = it_fcat
      i_save             = 'A'
    TABLES
      t_outtab           = lt_report.

ENDFORM.

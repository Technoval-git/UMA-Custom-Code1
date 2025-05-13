FUNCTION zmm_sales_history.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(MATNR) TYPE  MATNR
*"     REFERENCE(WERKS) TYPE  WERKS_D
*"     REFERENCE(MONTHS) TYPE  NUMC2 DEFAULT 03
*"     REFERENCE(GOLIVEDATE) TYPE  SY-DATUM DEFAULT '20240201'
*"  EXPORTING
*"     REFERENCE(FKLMG) TYPE  FKLMG
*"----------------------------------------------------------------------
  TYPES: ty_r_dates        TYPE RANGE OF sy-datum.
  DATA ir_period  TYPE ty_r_dates.
  DATA :lv_startdate   TYPE sy-datum,
        lv_enddate     TYPE sy-datum,
        lv_golivedate1 TYPE sy-datum,
        lv_months      TYPE i,
        lv_months1     TYPE i,
        lv_sum         TYPE fklmg,
        lv_ind         TYPE sy-index,
        lv_mon         TYPE numc2,
        lv_year        TYPE numc4,
        date1          TYPE sy-datum,
        lv_prsdt_from  TYPE sy-datum,
        lv_prsdt_to    TYPE sy-datum,
        vbrp_month     TYPE i.




  CALL FUNCTION 'OIL_LAST_DAY_OF_PREVIOUS_MONTH'
    EXPORTING
      i_date_old = sy-datum
    IMPORTING
      e_date_new = lv_startdate.


*  lv_startdate = sy-datum.

  lv_months    = months * -1 .

  IF lv_months IS INITIAL.
    lv_months = 1.

  ENDIF.


  CALL FUNCTION 'BKK_ADD_MONTH_TO_DATE'
    EXPORTING
      months  = lv_months
      olddate = lv_startdate
    IMPORTING
      newdate = lv_enddate.
  lv_enddate = lv_enddate + 1.  " adding one day

*  IF golivedate < lv_startdate AND golivedate >= lv_enddate.

  lv_golivedate1 = golivedate .

*  lv_golivedate1 = golivedate - 1.


  IF lv_golivedate1 IS NOT INITIAL.


    CALL FUNCTION 'BKK_ADD_MONTH_TO_DATE'
      EXPORTING
        months  = 01
        olddate = lv_startdate
      IMPORTING
        newdate = lv_prsdt_to.

    IF months IS INITIAL.
      vbrp_month = 1.
    ELSE.
      vbrp_month = months * -1.
    ENDIF.
    CALL FUNCTION 'BKK_ADD_MONTH_TO_DATE'
      EXPORTING
        months  = vbrp_month
        olddate = lv_startdate
      IMPORTING
        newdate = lv_prsdt_from.
    lv_prsdt_from = lv_prsdt_from + 1. " Adding one day
*    lv_prsdt_from = lv_prsdt_from + 2. " Adding one day

*    IF lv_golivedate1 LE lv_prsdt_from.
    APPEND VALUE #( sign   = 'I'
                          option = 'BT'
                          low    = lv_prsdt_from
                          high   = lv_prsdt_to )
                     TO ir_period.


    "start of code by sameer

*    SELECT name,numb,low FROM tvarvc INTO TABLE @DATA(lt_tvarvc) WHERE name = 'ZBI_RETURN'.
*    DATA(ls_doc_typ1) = VALUE #( lt_tvarvc[ 1 ] OPTIONAL  ).
*    DATA(ls_doc_typ2) = VALUE #( lt_tvarvc[ 2 ] OPTIONAL  ).
*    BREAK-POINT.
*
*    SELECT fklmg  INTO TABLE @DATA(fklmgx1) FROM vbrp
*       WHERE   prsdt IN @ir_period   AND sfakn_ana = ' ' AND vf_status_ana NE 'C' AND matnr = @matnr
**    AND fkart_ana = @ls_doc_typ1-low
*       AND shkzg = ' '
*       AND werks = @werks
*       AND netwr NE 0.
**    GROUP BY matnr, werks.
*
*    DATA : lv_sum1 TYPE i.
*    lv_sum1 = 0.
*
*    LOOP AT fklmgx1 ASSIGNING FIELD-SYMBOL(<fs>).
*      lv_sum1 += <fs>-fklmg.
*    ENDLOOP.

*    BREAK-POINT.

*
    SELECT SINGLE matnr, werks ,  SUM( fklmg )  AS fklmg INTO @DATA(fklmgx) FROM vbrp
    WHERE   prsdt IN @ir_period   AND sfakn_ana = ' ' AND vf_status_ana NE 'C' AND matnr = @matnr
    AND shkzg = 'X'
    AND werks = @werks
    AND netwr NE 0
    GROUP BY matnr, werks.", fklmg.
*
*    BREAK-POINT.
    SELECT SINGLE matnr, werks , SUM( fklmg )  AS fklmg INTO @DATA(fklmgy) FROM vbrp
    WHERE   prsdt IN @ir_period   AND sfakn_ana = ' ' AND vf_status_ana NE 'C' AND matnr = @matnr
      AND shkzg <> 'X'
    AND werks = @werks
    AND netwr <> 0
    GROUP BY matnr, werks.", fklmg.

*    BREAK-POINT.
    IF ( fklmgx IS NOT INITIAL OR fklmgy IS NOT INITIAL ).
      fklmg = fklmgy-fklmg - fklmgx-fklmg .
    ENDIF.
    "end of code by sameer
*    SELECT SINGLE matnr, werks , SUM( fklmg ) AS fklmg INTO @DATA(es_salse_data) FROM vbrp
*      WHERE   prsdt IN @ir_period   AND sfakn_ana = ' ' AND vf_status_ana NE 'C' AND matnr = @matnr
*       AND werks = @werks
*      AND netwr NE 0
*        GROUP BY matnr, werks.", fklmg.
*    IF sy-subrc = 0.
*      fklmg = es_salse_data-fklmg.
*    ENDIF.


*    ENDIF.
*    SELECT SINGLE
*           b~matnr AS matnr,
*           b~werks AS werks,
*           SUM( b~fklmg ) AS fklmg  " get past sales data
*      INTO @DATA(es_salse_data)
*      FROM vbrk AS a INNER JOIN
*           vbrp AS b ON a~vbeln = b~vbeln
*     WHERE a~fkdat <= @lv_startdate AND a~fkdat >= @lv_golivedate1
**       AND a~fksto EQ ''
*       AND b~matnr = @matnr
*       AND b~werks = @werks
*  GROUP BY b~matnr,
*           b~werks.
*
*** Cancel data
*    SELECT SINGLE
*           b~matnr AS matnr,
*           b~werks AS werks,
*           SUM( b~fklmg ) AS fklmg  " get past sales data
*      INTO @DATA(ls_salse_data_c)
*      FROM vbrk AS a INNER JOIN
*           vbrp AS b ON a~vbeln = b~vbeln
*     WHERE a~fkdat <= @lv_startdate AND a~fkdat >= @lv_golivedate1
*       AND a~fksto EQ 'X'
*       AND b~matnr = @matnr
*       AND b~werks = @werks
*  GROUP BY b~matnr,
*           b~werks.
*
*
*    fklmg = es_salse_data-fklmg -  ls_salse_data_c-fklmg.

    CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
      EXPORTING
        i_date_from    = lv_enddate
        i_date_to      = golivedate
        i_flg_round_up = 'X'
      IMPORTING
        e_months       = lv_months1.

    SELECT  matnr,
               werks,
               gjahr,
               perkz,
               zahlr,
               mgv01,
               mgv02,
               mgv03,
               mgv04,
               mgv05,
               mgv06,
               mgv07,
               mgv08,
               mgv09,
               mgv10,
               mgv11,
               mgv12,
               mgv13
          FROM mver INTO TABLE  @DATA(lt_mver)
         WHERE matnr = @matnr                               "'HQ90010'
           AND werks = @werks "'2100'
*           AND ( gjahr = '2023' or gjahr = '2024' )
           AND perkz = 'M'.

    DO lv_months1 TIMES.

      lv_ind = sy-index * -1.
      CLEAR date1.
      CALL FUNCTION 'BKK_ADD_MONTH_TO_DATE'
        EXPORTING
          months  = lv_ind
          olddate = golivedate
        IMPORTING
          newdate = date1.

      lv_year = date1+0(4).
      lv_mon = date1+4(2).
*      BREAK-POINT.
      READ TABLE lt_mver INTO DATA(lv_mver) WITH KEY gjahr = lv_year.
      IF sy-subrc = 0.
        CASE lv_mon.
          WHEN 12.
            lv_sum = lv_sum + lv_mver-mgv12.
          WHEN 11.
            lv_sum = lv_sum + lv_mver-mgv11.
          WHEN 10.
            lv_sum = lv_sum + lv_mver-mgv10.
          WHEN 09.
            lv_sum = lv_sum + lv_mver-mgv09.
          WHEN 08.
            lv_sum = lv_sum + lv_mver-mgv08.
          WHEN 07.
            lv_sum = lv_sum + lv_mver-mgv07.
          WHEN 06.
            lv_sum = lv_sum + lv_mver-mgv06.
          WHEN 05.
            lv_sum = lv_sum + lv_mver-mgv05.
          WHEN 04.
            lv_sum = lv_sum + lv_mver-mgv04.
          WHEN 03.
            lv_sum = lv_sum + lv_mver-mgv03.
          WHEN 02.
            lv_sum = lv_sum + lv_mver-mgv02.
          WHEN 01.
            lv_sum = lv_sum + lv_mver-mgv01.
        ENDCASE.
      ENDIF.
    ENDDO.
*    BREAK-POINT.
    fklmg = fklmg + lv_sum.

*  ELSE.

*    SELECT SINGLE
*           b~matnr AS matnr,
*           b~werks AS werks,
*           SUM( b~fklmg ) AS fklmg  " get past sales data
*      INTO @es_salse_data
*      FROM vbrk AS a INNER JOIN
*           vbrp AS b ON a~vbeln = b~vbeln
*     WHERE a~fkdat <= @lv_startdate AND a~fkdat >= @lv_enddate
**       AND a~fksto EQ ''
*       AND b~matnr = @matnr
*       AND b~werks = @werks
*  GROUP BY b~matnr,
*           b~werks.
*
*** Cancel data
*    SELECT SINGLE
*           b~matnr AS matnr,
*           b~werks AS werks,
*           SUM( b~fklmg ) AS fklmg  " get past sales data
*      INTO @ls_salse_data_c
*      FROM vbrk AS a INNER JOIN
*           vbrp AS b ON a~vbeln = b~vbeln
*     WHERE a~fkdat <= @lv_startdate AND a~fkdat >= @lv_enddate
*       AND a~fksto EQ 'X'
*       AND b~matnr = @matnr
*       AND b~werks = @werks
*  GROUP BY b~matnr,
*           b~werks.
*
*
*    fklmg = es_salse_data-fklmg -  ls_salse_data_c-fklmg.



  ENDIF.


ENDFUNCTION.

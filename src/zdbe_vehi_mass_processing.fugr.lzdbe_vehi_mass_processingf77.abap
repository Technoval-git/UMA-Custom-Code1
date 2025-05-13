**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGF77 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Form  CALCULATE_LAST_SEVICEDATE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM calculate_last_sevicedate .
*
*  DATA:   lv_wtyend           TYPE /DBE/wty_end,
*          lv_serv             TYPE /DBE/last_service_date,
*          lv_isint            TYPE /DBE/V_ISINT.
*
*  CONSTANTS:
*         lc_d TYPE isocd_unit VALUE 'D',
*         lc_y TYPE isocd_unit VALUE 'YR',
*         lc_m TYPE isocd_unit VALUE 'MON',
*         lc_c TYPE isocd_unit VALUE 'DAY',
*         lc_w TYPE isocd_unit VALUE 'WK'.
*
**Get the service dates
*  SELECT SINGLE datnext scount scount_u FROM /DBE/V_ISINT INTO CORRESPONDING FIELDS OF lv_isint WHERE product_guid = gs_vehicles-iobjguid.
*
*  DATA: lv_period_serv LIKE vtbbewe-atage.
*  lv_period_serv =  - lv_isint-scount.
*
*  IF NOT lv_isint IS INITIAL AND lv_isint-datnext NE '00000000'.
*    CASE lv_isint-scount_u.
*      WHEN lc_m.
*
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date   = lv_isint-datnext
*            i_months = lv_period_serv
*          IMPORTING
*            e_date   = lv_serv.
*      WHEN lc_d.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date = lv_isint-datnext
*            i_days = lv_period_serv
*          IMPORTING
*            e_date = lv_serv.
*      WHEN lc_y.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date  = lv_isint-datnext
*            i_years = lv_period_serv
*          IMPORTING
*            e_date  = lv_serv.
*      WHEN lc_c.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date          = lv_isint-datnext
*            i_calendar_days = lv_period_serv
*          IMPORTING
*            e_date          = lv_serv.
*      WHEN lc_w.
*        lv_period_serv = lv_period_serv * 7.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date          = lv_isint-datnext
*            i_calendar_days = lv_period_serv
*          IMPORTING
*            e_date          = lv_serv.
*    ENDCASE.
*
*    IF gs_mass_dates_search_crit-low = lv_serv.
*      "If low value check criteria satisfied
*      sy-subrc = '0'.
*    ELSEIF gs_mass_dates_search_crit-high IS NOT INITIAL
*      AND gs_mass_dates_search_crit-low < lv_serv
*      AND gs_mass_dates_search_crit-high >= lv_serv.
*      "If high value check is failed
*      sy-subrc = '0'.
*    ELSE.
*      sy-subrc = '1'.
*    ENDIF.
*  ELSE.
*    sy-subrc = '1'.
*  ENDIF.
*
*ENDFORM.                    " CALCULATE_LAST_SEVICEDATE

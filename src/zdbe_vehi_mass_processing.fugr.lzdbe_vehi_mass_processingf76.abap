**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGF76 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Form  CALCULATE_WARRANTY_ENDDATE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM calculate_warranty_enddate .
*
*  DATA:
*         lv_wtyend           TYPE /DBE/wty_end,
*         lv_wty              TYPE /DBE/V_IWTY,
*         lv_period           LIKE vtbbewe-atage,
*         no_of_lines         TYPE i.
*
**Get the Warranty Period and Warranty Start Date
*  SELECT SINGLE wtytype wtyrtime wtyrtime_u wtydatab FROM /DBE/V_IWTY INTO CORRESPONDING FIELDS OF lv_wty WHERE product_guid = gs_vehicles-iobjguid.
*
*  CONSTANTS:
*       lc_d TYPE isocd_unit VALUE 'D',
*       lc_y TYPE isocd_unit VALUE 'YR',
*       lc_m TYPE isocd_unit VALUE 'MON',
*       lc_c TYPE isocd_unit VALUE 'DAY',
*       lc_w TYPE isocd_unit VALUE 'WK'.
*
*  lv_period =  lv_wty-wtyrtime.
*
*  IF NOT lv_wty IS INITIAL AND lv_wty-wtydatab NE '00000000'.
*    CASE lv_wty-wtyrtime_u.
*      WHEN lc_m.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date   = lv_wty-wtydatab
*            i_months = lv_period
*          IMPORTING
*            e_date   = lv_wtyend.
*      WHEN lc_d.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date = lv_wty-wtydatab
*            i_days = lv_period
*          IMPORTING
*            e_date = lv_wtyend.
*      WHEN lc_y.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date  = lv_wty-wtydatab
*            i_years = lv_period
*          IMPORTING
*            e_date  = lv_wtyend.
*      WHEN lc_c.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date          = lv_wty-wtydatab
*            i_calendar_days = lv_period
*          IMPORTING
*            e_date          = lv_wtyend.
*      WHEN lc_w.
*        lv_period = lv_period * 7.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date          = lv_wty-wtydatab
*            i_calendar_days = lv_period
*          IMPORTING
*            e_date          = lv_wtyend.
*    ENDCASE.
*
*    IF gs_mass_dates_search_crit-low = lv_wtyend.
*      "If low value check criteria satisfied
*      sy-subrc = '0'.
*    ELSEIF gs_mass_dates_search_crit-high IS NOT INITIAL
*      AND gs_mass_dates_search_crit-low < lv_wtyend
*      AND gs_mass_dates_search_crit-high >= lv_wtyend.
*      "If high value check is failed
*      sy-subrc = '0'.
*    ELSE.
*      sy-subrc = '1'.
*    ENDIF.
*  ELSE.
*    sy-subrc = '1'.
*  ENDIF.
*
*ENDFORM.                    " CALCULATE_WARRANTY_ENDDATE

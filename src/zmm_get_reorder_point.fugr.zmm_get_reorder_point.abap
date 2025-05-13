FUNCTION zmm_get_reorder_point.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(MATNR) TYPE  MATNR
*"     REFERENCE(WERKS) TYPE  WERKS_D
*"     REFERENCE(MATKL) TYPE  MATKL
*"  EXPORTING
*"     REFERENCE(MINBE) TYPE  MINBE
*"----------------------------------------------------------------------
  DATA lv_fklmg TYPE fklmg.
  DATA lv_das TYPE fklmg. " Daily average sale.
  DATA lv_pdc TYPE fklmg. " per day consumption
  DATA lv_eisbe TYPE eisbe. " safty stock quantity

  SELECT SINGLE eisbe FROM marc INTO lv_eisbe WHERE matnr = matnr AND werks = werks.


  SELECT SINGLE golive_date  FROM zmm_golive INTO @DATA(lv_golive_date) WHERE werks = @werks AND matkl = @matkl.
  CALL FUNCTION 'ZMM_SALES_HISTORY'
    EXPORTING
      matnr      = matnr
      werks      = werks
      months     = 12
      golivedate = lv_golive_date
    IMPORTING
      fklmg      = lv_fklmg.

  lv_fklmg = lv_fklmg / 12.

  SELECT SINGLE wdays FROM zmm_workingdays INTO @DATA(lv_wdays) WHERE werks = @werks.

  IF lv_wdays IS NOT INITIAL.
    lv_das = lv_fklmg / lv_wdays.
  ELSE.
    lv_das = lv_fklmg / 22.
  ENDIF.
  SELECT SINGLE pdt FROM ymm_mrp_plt INTO @DATA(lv_pdt) WHERE werks = @werks.

  lv_pdc = lv_pdt * lv_das.

  minbe = lv_pdc + lv_eisbe.

  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 0
      input         = minbe
      sign          = '-'
    IMPORTING
      output        = minbe
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFUNCTION.

"Name: \PR:/DBME/KMA_MATC\TY:LCL_LIST_1004\ME:ME_PROCESS\SE:BEGIN\EI
ENHANCEMENT 0 ZMM_MAT_COCKPIT.
*

 FIELD-SYMBOLS: <fs_data> LIKE LINE OF mt_data.
 DATA lv_knumh TYPE knumh.
 DATA : lt_golive TYPE STANDARD TABLE OF zmm_golive.


 SELECT * FROM zmm_golive INTO TABLE lt_golive.

 LOOP AT mt_data ASSIGNING <fs_data> .

   SELECT SINGLE lgpbe FROM mard INTO <fs_data>-zmm_mrp_storage_bin
         WHERE matnr = <fs_data>-matnr AND werks = <fs_data>-werks AND lgort = 'P001'.

   READ TABLE lt_golive INTO DATA(ls_golive) WITH KEY werks = <fs_data>-werks matkl = <fs_data>-matkl.
   IF sy-subrc = 0.
     CALL FUNCTION 'ZMM_SALES_HISTORY'
       EXPORTING
         matnr      = <fs_data>-matnr
         werks      = <fs_data>-werks
         months     = 03
         golivedate = ls_golive-golive_date
       IMPORTING
         fklmg      = <fs_data>-zmm_mrp_sold3.

     CALL FUNCTION 'ZMM_SALES_HISTORY'
       EXPORTING
         matnr      = <fs_data>-matnr
         werks      = <fs_data>-werks
         months     = 18
         golivedate = ls_golive-golive_date
       IMPORTING
         fklmg      = <fs_data>-zmm_mrp_sold18.


     CALL FUNCTION 'ZMM_SALES_HISTORY'
       EXPORTING
         matnr      = <fs_data>-matnr
         werks      = <fs_data>-werks
         months     = 06
         golivedate = ls_golive-golive_date
       IMPORTING
         fklmg      = <fs_data>-zmm_mrp_sold6.

     CALL FUNCTION 'ZMM_SALES_HISTORY'
       EXPORTING
         matnr      = <fs_data>-matnr
         werks      = <fs_data>-werks
         months     = 09
         golivedate = ls_golive-golive_date
       IMPORTING
         fklmg      = <fs_data>-zmm_mrp_sold9.

     CALL FUNCTION 'ZMM_SALES_HISTORY'
       EXPORTING
         matnr      = <fs_data>-matnr
         werks      = <fs_data>-werks
         months     = 12
         golivedate = ls_golive-golive_date
       IMPORTING
         fklmg      = <fs_data>-zmm_mrp_sold12.



     CALL FUNCTION 'ZMM_SALES_HISTORY'
       EXPORTING
         matnr      = <fs_data>-matnr
         werks      = <fs_data>-werks
         months     = 00
         golivedate = ls_golive-golive_date
       IMPORTING
         fklmg      = <fs_data>-zmm_mrp_sold0.


     CALL FUNCTION 'ZMM_SALES_HISTORY'
       EXPORTING
         matnr      = <fs_data>-matnr
         werks      = <fs_data>-werks
         months     = 01
         golivedate = ls_golive-golive_date
       IMPORTING
         fklmg      = <fs_data>-zmm_mrp_sold1.

     CALL FUNCTION 'ZMM_SALES_HISTORY'
       EXPORTING
         matnr      = <fs_data>-matnr
         werks      = <fs_data>-werks
         months     = 02
         golivedate = ls_golive-golive_date
       IMPORTING
         fklmg      = <fs_data>-zmm_mrp_sold2.

   ENDIF.

   SELECT SINGLE verpr FROM mbew INTO <fs_data>-verpr WHERE  matnr      = <fs_data>-matnr AND
           bwkey      = <fs_data>-werks AND bwtar = ' '.

*   sales price
   CLEAR lv_knumh.
   SELECT SINGLE knumh FROM a004 INTO lv_knumh WHERE kappl = 'V' AND kschl = 'YP01' AND
                                                     vkorg = <fs_data>-vkorg AND
                                                     vtweg = <fs_data>-vtweg AND
                                                     matnr = <fs_data>-matnr AND
                                                     datbi > sy-datum AND
                                                     datab <= sy-datum.
   IF sy-subrc = 0.
     SELECT SINGLE kbetr INTO <fs_data>-kbetr FROM konp WHERE knumh = lv_knumh.
   ENDIF.

*special  sales price
   CLEAR lv_knumh.
   SELECT SINGLE knumh FROM a004 INTO lv_knumh WHERE kappl = 'V' AND kschl = 'YSP1' AND
                                                     vkorg = <fs_data>-vkorg AND
                                                     vtweg = <fs_data>-vtweg AND
                                                     matnr = <fs_data>-matnr AND
                                                     datbi > sy-datum AND
                                                     datab <= sy-datum.
   IF sy-subrc = 0.
     SELECT SINGLE kbetr INTO <fs_data>-zmm_mrp_special_price FROM konp WHERE knumh = lv_knumh.
   ENDIF.
*   warranty price
   CLEAR lv_knumh.
   SELECT SINGLE knumh FROM a900 INTO lv_knumh WHERE kappl = 'V' AND kschl = 'YWP1' AND
                                                  vkorg = <fs_data>-vkorg AND
                                                  vtweg = <fs_data>-vtweg AND
                                                  matnr = <fs_data>-matnr AND
                                                  datbi > sy-datum AND
                                                  datab <= sy-datum.
   IF sy-subrc = 0.
     SELECT SINGLE kbetr INTO <fs_data>-zmm_mrp_warranty_pirce FROM konp WHERE knumh = lv_knumh.
   ENDIF.



   IF <fs_data>-matnr+0(2) = 'AC' .
     SELECT SINGLE ac_price  ac_COUR_SURC FROM ZMM_ac INTO ( <fs_data>-zmm_mrp_fob_price , <fs_data>-zmm_mpr_coreprice ) WHERE ac_delco = <fs_data>-matnr+2(38).

   ELSEIF <fs_data>-matnr+0(2) = 'GM'.
     SELECT SINGLE gm_price  gm_cour_surc FROM zmm_gm INTO ( <fs_data>-zmm_mrp_fob_price , <fs_data>-zmm_mpr_coreprice ) WHERE gm_matnr = <fs_data>-matnr+2(38).
   ELSE.

  SELECT SINGLE e~netpr from eina as a INNER JOIN eine as e on a~infnr = e~infnr
       where a~matnr = @<fs_data>-matnr and e~werks = @<fs_data>-werks
       into @<fs_data>-ZMM_MRP_FOB_PRICE.
   ENDIF.

   select single name1 from t001w into <fs_data>-name1 where werks = <fs_data>-werks.

   select sum( bdmng ) as BDMNG from resb into @data(lv_bdmng_h)
     where matnr = @<fs_data>-matnr
        and werks = @<fs_data>-werks
        and kzear = ' '
        and shkzg = 'H'.

   select sum( Bdmng ) as BDMNG from resb into @data(lv_bdmng_s)
      where matnr = @<fs_data>-matnr
        and werks = @<fs_data>-werks
        and kzear = ' '
        and shkzg = 'S'.

   <fs_data>-zmm_res_qty = lv_bdmng_h - lv_bdmng_s.
   clear: lv_bdmng_h, lv_bdmng_s.

   select sum( LFIMG ) from LIPS into @data(lv_lfimg_dlv)
     where MATNR = @<fs_data>-matnr
       AND WERKS = @<fs_data>-werks
       AND WBSTA <> 'C'
       AND SHKZG <> 'X'
       AND kzbew = 'L'.

    <fs_data>-zmm_delvry_qty = lv_lfimg_dlv.

    select sum( LFIMG ) from LIPS into @data(lv_lfimg_reDlv)
      where MATNR = @<fs_data>-matnr
      AND WERKS = @<fs_data>-werks
      AND WBSTA <> 'C'
      AND SHKZG = 'X'
      AND kzbew = 'L'.

    <fs_data>-zmm_relvry_qty = lv_lfimg_reDlv.

    <fs_data>-zmm_avl_qty = ( <fs_data>-labst + <fs_data>-zmm_relvry_qty ) - ( <fs_data>-zmm_res_qty + <fs_data>-zmm_delvry_qty ). " Available Qty

    select single /dbe/backlog from mara into @data(lv_back_log)
      where matnr = @<fs_data>-matnr.

    IF lv_back_log = 'X'.
      <fs_data>-zmm_core_return = 'Yes'.
    else.
      <fs_data>-zmm_core_return = 'No'.
    ENDIF.

 ENDLOOP.
ENDENHANCEMENT.

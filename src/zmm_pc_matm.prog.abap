*----------------------------------------------------------------------*
***INCLUDE ZMM_PC_MATM.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zmm_pc_matm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zmm_pc_matm .
  DATA: ltt_return TYPE TABLE OF bapiret2,
        lt_zmm_gm  TYPE STANDARD TABLE OF zmm_gm,
        lt_zmm_hq  TYPE STANDARD TABLE OF zmm_hq,
        lt_zmm_ac  TYPE STANDARD TABLE OF zmm_ac,
        lt_zmm_df  TYPE STANDARD TABLE OF zmm_df,
        lt_zmm_ma  TYPE STANDARD TABLE OF zmm_ma,
        lv_matnr   TYPE zpc_matnr-pc_matnr, "matnr,
        lv_maktx   TYPE maktx,
        lv_price   TYPE netpr,
        lv_werks   TYPE werks_d,
        lv_refmat  TYPE matnr,
        lv_extwg   TYPE extwg,
        lv_vkorg   TYPE vkorg,
        lv_vtweg   TYPE vtweg.
*  LOOP AT s_matnr.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = s_matnr-low
*      IMPORTING
*        output = s_matnr-low.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = s_matnr-high
*      IMPORTING
*        output = s_matnr-high.
*    MODIFY s_matnr.
*  ENDLOOP.

  IF s_matnr[] IS NOT INITIAL.
    IF p_gm = 'X'.
      SELECT * FROM zmm_pc_autho  WHERE category = 'GM'
                                   AND uname = @sy-uname
                                   AND werks IS NOT INITIAL
                                 INTO TABLE @DATA(lt_autho_gm).
      SELECT * FROM zmm_gm INTO TABLE lt_zmm_gm WHERE gm_matnr IN s_matnr.
      LOOP AT lt_zmm_gm ASSIGNING FIELD-SYMBOL(<fs_gm>).
        LOOP AT lt_autho_gm ASSIGNING FIELD-SYMBOL(<lw_autho_gm>).
          IF <fs_gm>-gm_matnr+0(2) NE 'GM'.
            CONCATENATE 'GM' <fs_gm>-gm_matnr INTO <fs_gm>-gm_matnr.
          ENDIF.
          SELECT SINGLE matnr INTO lv_matnr FROM marc WHERE matnr =   <fs_gm>-gm_matnr and werks = <lw_autho_gm>-werks.
          IF sy-subrc = 0.
          CONTINUE.  " if material with plant exist then dont create material.
          ENDIF.
          lv_matnr = <fs_gm>-gm_matnr.
          lv_maktx = <fs_gm>-gm_maktx.
*          lv_price = <fs_gm>-gm_price + <fs_gm>-GM_COUR_SURC.
          lv_price = '1'.
          lv_werks = <lw_autho_gm>-werks.
          lv_refmat = <lw_autho_gm>-matnr.  " referance material
          lv_extwg = <fs_gm>-gm_extwg.
          lv_vkorg = <lw_autho_gm>-vkorg.
          lv_vtweg =  <lw_autho_gm>-vtweg.
          PERFORM zmm_mat_upload TABLES ltt_return USING  lv_matnr  lv_maktx lv_price lv_vkorg lv_vtweg lv_werks lv_refmat lv_extwg.
        ENDLOOP.
      ENDLOOP.

    ELSEIF p_HQ = 'X'.
      SELECT * FROM zmm_pc_autho  WHERE category = 'HQ'
                                  AND uname = @sy-uname
                                  AND werks IS NOT INITIAL
                                INTO TABLE @DATA(lt_autho_hq).
      SELECT * FROM zmm_hq INTO TABLE lt_zmm_hq WHERE hq_matnr IN s_matnr.
      LOOP AT lt_zmm_hq ASSIGNING FIELD-SYMBOL(<fs_hq>).
        LOOP AT lt_autho_hq ASSIGNING FIELD-SYMBOL(<lw_autho_hq>).
          IF <fs_hq>-hq_matnr+0(2) NE 'HQ'.
            CONCATENATE 'HQ' <fs_hq>-hq_matnr INTO <fs_hq>-hq_matnr.
          ENDIF.
          SELECT SINGLE matnr INTO lv_matnr FROM marc WHERE matnr =   <fs_hq>-hq_matnr and werks = <lw_autho_hq>-werks.
          IF sy-subrc = 0.
          CONTINUE.  " if material with plant exist then dont create material.
          ENDIF.
          lv_matnr = <fs_hq>-hq_matnr.
          lv_maktx = <fs_hq>-hq_maktx.
          lv_price = <fs_hq>-hq_price.
          lv_werks = <lw_autho_hq>-werks.
          lv_refmat = <lw_autho_hq>-matnr.  " referance material
          lv_extwg = ' '.
          lv_vkorg = <lw_autho_hq>-vkorg.
          lv_vtweg =  <lw_autho_hq>-vtweg.
          PERFORM zmm_mat_upload TABLES ltt_return USING  lv_matnr  lv_maktx lv_price lv_vkorg lv_vtweg lv_werks lv_refmat lv_extwg.
        ENDLOOP.
      ENDLOOP.

    ELSEIF p_ac = 'X'.
      SELECT * FROM zmm_pc_autho  WHERE category = 'AC'
                                 AND uname = @sy-uname
                                 AND werks IS NOT INITIAL
                               INTO TABLE @DATA(lt_autho_ac).
      SELECT * FROM zmm_ac INTO TABLE lt_zmm_ac WHERE ac_delco IN s_matnr.  "ac_matnr IN s_matnr.
      LOOP AT lt_zmm_ac ASSIGNING FIELD-SYMBOL(<fs_ac>).
        LOOP AT lt_autho_ac ASSIGNING FIELD-SYMBOL(<lw_autho_ac>).
          IF <fs_ac>-ac_delco+0(2) NE 'AC'.
            CONCATENATE 'AC' <fs_ac>-ac_delco INTO <fs_ac>-ac_delco.
          ENDIF.
          SELECT SINGLE matnr INTO lv_matnr FROM marc WHERE matnr =   <fs_ac>-ac_delco and werks = <lw_autho_ac>-werks.
          IF sy-subrc = 0.
          CONTINUE.  " if material with plant exist then dont create material.
          ENDIF.
          lv_matnr = <fs_ac>-ac_delco.
          lv_maktx = <fs_ac>-ac_maktx.
          lv_price = <fs_ac>-ac_price + <fs_ac>-AC_COUR_SURC.
          lv_werks = <lw_autho_ac>-werks.
          lv_refmat = <lw_autho_ac>-matnr.  " referance material
          lv_extwg = <fs_ac>-ac_extwg.
          lv_vkorg = <lw_autho_ac>-vkorg.
          lv_vtweg =  <lw_autho_ac>-vtweg.
          PERFORM zmm_mat_upload TABLES ltt_return USING  lv_matnr  lv_maktx lv_price lv_vkorg lv_vtweg lv_werks lv_refmat lv_extwg.
        ENDLOOP.
      ENDLOOP.
    ELSEIF p_df = 'X'.
      SELECT * FROM zmm_pc_autho  WHERE category = 'DF'
                                   AND uname = @sy-uname
                                   AND werks IS NOT INITIAL
                                 INTO TABLE @DATA(lt_autho_df).
      SELECT * FROM zmm_df INTO TABLE lt_zmm_df WHERE df_matnr IN s_matnr.
      LOOP AT lt_zmm_df ASSIGNING FIELD-SYMBOL(<fs_df>).
        LOOP AT lt_autho_df ASSIGNING FIELD-SYMBOL(<lw_autho_df>).
          IF <fs_df>-df_matnr+0(2) NE 'DF'.
            CONCATENATE 'DF' <fs_df>-df_matnr INTO <fs_df>-df_matnr.
          ENDIF.
          SELECT SINGLE matnr INTO lv_matnr FROM marc WHERE matnr =   <fs_df>-df_matnr and werks = <lw_autho_df>-werks.
          IF sy-subrc = 0.
          CONTINUE.  " if material with plant exist then dont create material.
          ENDIF.
          lv_matnr = <fs_df>-df_matnr.
          lv_maktx = <fs_df>-df_maktx.
          lv_price = <fs_df>-df_price.
          lv_werks = <lw_autho_df>-werks.
          lv_refmat = <lw_autho_df>-matnr.  " referance material
          lv_extwg = ' '.
          lv_vkorg = <lw_autho_df>-vkorg.
          lv_vtweg =  <lw_autho_df>-vtweg.
          PERFORM zmm_mat_upload TABLES ltt_return USING  lv_matnr  lv_maktx lv_price lv_vkorg lv_vtweg lv_werks lv_refmat lv_extwg.
        ENDLOOP.
      ENDLOOP.
    ELSEIF p_ma = 'X'.
      SELECT * FROM zmm_pc_autho  WHERE category = 'MS'
                                   AND uname = @sy-uname
                                   AND werks IS NOT INITIAL
                                 INTO TABLE @DATA(lt_autho_ma).
      SELECT * FROM zmm_ma INTO TABLE lt_zmm_ma WHERE ma_matnr IN s_matnr.
      LOOP AT lt_zmm_ma ASSIGNING FIELD-SYMBOL(<fs_ma>).
        LOOP AT lt_autho_ma ASSIGNING FIELD-SYMBOL(<lw_autho_ma>).
          IF <fs_ma>-ma_matnr+0(2) NE 'MS'.
            CONCATENATE 'MS' <fs_ma>-ma_matnr INTO <fs_ma>-ma_matnr.
          ENDIF.
          SELECT SINGLE matnr INTO lv_matnr FROM marc WHERE matnr =   <fs_ma>-ma_matnr and werks = <lw_autho_ma>-werks.
          IF sy-subrc = 0.
          CONTINUE.  " if material with plant exist then dont create material.
          ENDIF.
          lv_matnr = <fs_ma>-ma_matnr.
          lv_maktx = <fs_ma>-ma_maktx.
          lv_price = <fs_ma>-ma_price.
*          lv_price = '1'.
          lv_werks = <lw_autho_ma>-werks.
          lv_refmat = <lw_autho_ma>-matnr.  " referance material
          lv_extwg = ' '.
          lv_vkorg = <lw_autho_ma>-vkorg.
          lv_vtweg =  <lw_autho_ma>-vtweg.
          PERFORM zmm_mat_upload TABLES ltt_return USING  lv_matnr  lv_maktx lv_price lv_vkorg lv_vtweg lv_werks lv_refmat lv_extwg.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    IF ltt_return[] IS NOT INITIAL.
      CALL FUNCTION 'ZMM_ALV_POPUP'
        EXPORTING
          i_start_column = 5
          i_start_line   = 5
          i_end_column   = 100
          i_end_line     = 100
          i_title        = 'ALV'
          i_popup        = 'X'
        TABLES
          it_alv         = ltt_return.
    ENDIF.
  ENDIF.
ENDFORM.

FORM zmm_mat_upload TABLES   p_ltt_return STRUCTURE bapiret2
                    USING    p_lv_matnr
                             p_lv_maktx
                             p_lv_price
                             p_lv_vkorg
                             p_lv_vtweg
                             p_lv_werks
                             p_lv_refmat
                             p_lv_extwg .

  DATA:
    lt_zmm_mat_constant  TYPE STANDARD TABLE OF zmm_mat_constant,
    lwa_zmm_mat_constant TYPE zmm_mat_constant.
  DATA:
    lv_reference_material  TYPE mara-matnr,
    lv_quantity            TYPE ntgew,
    lv_uom                 TYPE meins,
    lt_return              TYPE bapiret2,
    ls_mathead             TYPE bapimathead,
    ls_mat_grp             TYPE bapi_mara,
    ls_mat_grpx            TYPE bapi_marax,
    lt_MATERIALDESCRIPTION TYPE TABLE OF bapi_makt,
    ls_MATERIALDESCRIPTION TYPE bapi_makt,
    lwa_sale               TYPE bapi_mvke,
    lwa_salex              TYPE bapi_mvkex,
    lwa_acc                TYPE bapi_mbew,
    lwa_accx               TYPE bapi_mbewx,
    lwa_store              TYPE bapi_mard,
    lwa_storex             TYPE bapi_mardx,
    lwa_forecast           TYPE bapi_mpop,
    lwa_forecastx          TYPE bapi_mpopx,
    lwa_ware               TYPE bapi_mlgn,
    lwa_warex              TYPE bapi_mlgnx.
  DATA :
    lv_PLANTDATA  LIKE  bapi_marc,
    lv_plantdatax LIKE bapi_marcx,
    lt_plantdata  TYPE STANDARD TABLE OF bapi_marc,
    lt_plantdatax TYPE STANDARD TABLE OF bapi_marcx.
  DATA lv_cat TYPE char2.
  DATA:
    lwa_tax TYPE bapi_mlan,
    it_tax  TYPE TABLE OF bapi_mlan.

  lv_cat = p_lv_matnr+0(2).  " First two character for category
  SELECT SINGLE mtart, mbrsh,matkl, meins FROM mara INTO @DATA(lv_mara) WHERE matnr = @p_lv_refmat. "@p_refmat.
*                                                                       matkl = lv_mara-matkl.
  SELECT SINGLE * FROM zmm_mat_constant INTO  lwa_ZMM_MAT_CONSTANT WHERE mtart = lv_mara-mtart
                                                                    AND matkl = lv_mara-matkl.
*  SELECT * FROM zmm_pc_autho  WHERE category = @lv_cat
*                                AND uname = @sy-uname
*                                AND werks IS NOT INITIAL
*                              INTO TABLE @DATA(lt_autho).
  ls_mathead-material_long = p_lv_matnr.
  ls_mathead-ind_sector    = lv_mara-mbrsh.  "'M'.
  ls_mathead-matl_type     = lv_mara-mtart. "'YPOM'.
  ls_mathead-basic_view    = 'X'.
  ls_mathead-sales_view    = 'X'.
  ls_mathead-purchase_view = 'X'.
  ls_mathead-account_view  = 'X'.
  ls_mathead-storage_view  = 'X'.
  ls_mathead-mrp_view      = 'X'.
  ls_mathead-forecast_view = 'X'.




  ls_mat_grp-matl_group = lv_mara-matkl.                    "'Y00050'.
  ls_mat_grpx-matl_group = 'X'.
  ls_mat_grp-base_uom = lv_mara-meins. "lv_uom.
  ls_mat_grpx-base_uom = 'X'.
  ls_mat_grp-pl_ref_mat = p_lv_refmat .
  ls_mat_grpx-pl_ref_mat = 'X' .
  ls_mat_grp-extmatlgrp = p_lv_extwg .
  IF p_lv_extwg IS NOT INITIAL.
    ls_mat_grpX-extmatlgrp = 'X'.
  ENDIF.

  ls_MATERIALDESCRIPTION-langu_iso = sy-langu.
  ls_MATERIALDESCRIPTION-langu = sy-langu.
  ls_MATERIALDESCRIPTION-matl_desc = p_lv_MAKTX.
  APPEND ls_MATERIALDESCRIPTION TO lt_MATERIALDESCRIPTION.

*************Plant data
*  LOOP AT lt_autho ASSIGNING FIELD-SYMBOL(<lv_autho>).
  lv_PLANTDATA-plant       = p_lv_werks. "<lv_autho>-werks.

*  SELECT SINGLE ekgrp FROM marc INTO lv_PLANTDATA-pur_group WHERE matnr = p_lv_refmat AND werks = '1100'. "p_lv_werks.
  IF lv_PLANTDATA-plant+0(1) = 1.
   lv_PLANTDATA-pur_group   = '103' .
  ELSEIF lv_PLANTDATA-plant+0(1) = 2.
    lv_PLANTDATA-pur_group   = '203' .
  ENDIF.
  lv_PLANTDATA-profit_ctr  = lwa_ZMM_MAT_CONSTANT-prctr.
  lv_PLANTDATA-availcheck  = lwa_ZMM_MAT_CONSTANT-mtvfp.
  lv_PLANTDATA-loadinggrp  = lwa_ZMM_MAT_CONSTANT-ladgr.
  lv_PLANTDATA-mrp_type    = lwa_ZMM_MAT_CONSTANT-dismm.
  lv_PLANTDATA-lotsizekey  = lwa_ZMM_MAT_CONSTANT-disls.
  lv_PLANTDATA-mrp_ctrler  = lwa_ZMM_MAT_CONSTANT-dispo.
  lv_PLANTDATA-serno_prof  = lwa_ZMM_MAT_CONSTANT-sernp.
  SELECT SINGLE mtart FROM t438m INTO lv_PLANTDATA-mrp_group WHERE werks = p_lv_werks. "<lv_autho>-werks.
*    APPEND lv_PLANTDATA TO lt_PLANTDATA.
  lv_PLANTDATAX-plant   = p_lv_werks. "<lv_autho>-werks.
  lv_PLANTDATAX-pur_group   = 'X'.
  lv_PLANTDATAX-profit_ctr  = 'X'.
  lv_PLANTDATAX-availcheck  = 'X'.
  lv_PLANTDATAX-loadinggrp  = 'X'.
  lv_PLANTDATAX-mrp_type    = 'X'.
  lv_PLANTDATAX-lotsizekey  = 'X'.
  lv_PLANTDATAX-mrp_ctrler  = 'X'.
  lv_PLANTDATAX-serno_prof  = 'X'.
  lv_PLANTDATAX-mrp_group   = 'X'.
*    APPEND lv_PLANTDATAX TO lt_PLANTDATAX.
*  ENDLOOP.


*****  Forecast data
  lwa_forecast-plant = p_lv_werks.
  lwa_forecast-fore_model = lwa_ZMM_MAT_CONSTANT-prmod. . "lwa_main-prmod.
  lwa_forecast-hist_vals  = '' . "lwa_main-peran.
  lwa_forecast-fore_pds = '' . "lwa_main-anzpr.
  lwa_forecast-fore_pds = '' . "lwa_main-anzpr.
  lwa_forecast-initialize = '' . "lwa_main-kzini.
  lwa_forecast-wtg_group = lwa_ZMM_MAT_CONSTANT-gewgr.

  lwa_forecastx-plant = lv_PLANTDATAX-plant.
  IF lwa_forecast-fore_model IS NOT INITIAL.
    lwa_forecastx-fore_model = 'X'.
  ENDIF.
  IF lwa_forecast-hist_vals IS NOT INITIAL.
    lwa_forecastx-hist_vals  = 'X'.
  ENDIF.
  IF lwa_forecast-fore_pds IS NOT INITIAL.
    lwa_forecastx-fore_pds = 'X'.
  ENDIF.
  IF lwa_forecast-initialize IS NOT INITIAL.
    lwa_forecastx-initialize = 'X'.
  ENDIF.
  "new entry
  IF lwa_forecast-wtg_group IS NOT INITIAL.
    lwa_forecastx-wtg_group = 'X'.
  ENDIF.
*****Storage Location
  lwa_store-plant     = lv_PLANTDATAX-plant.
  lwa_store-stge_loc  = 'P001'.
  lwa_store-stge_bin  = 'BIN1'."lwa_main-lgpbe'.

  lwa_storex-plant     = lv_PLANTDATAX-plant.
  lwa_storex-stge_loc  = 'P001'.
  lwa_storex-stge_bin  = 'X'.

*******Accouting data
  lwa_acc-val_area   = lv_PLANTDATAX-plant.
  lwa_acc-val_class  = '' . "lwa_main-bklas.
  lwa_acc-val_cat    = '' . "lwa_main-bwtty.
  lwa_acc-price_ctrl = 'V' . "lwa_main-vprsv.
  lwa_acc-moving_pr  =  p_lv_price."lwa_main-verpr.
  lwa_acc-price_unit = '1'. "lwa_main-peinh.
  lwa_acc-std_price  =  p_lv_price."lwa_main-stprs.
*  lwa_acc-std_price  =  '1'."lwa_main-stprs.

  lwa_accx-val_area   = lv_PLANTDATAX-plant.
  IF lwa_acc-val_cat  IS NOT INITIAL.
    lwa_accx-val_cat    = 'X'.
  ENDIF.
  IF lwa_acc-val_class  IS NOT INITIAL.
    lwa_accx-val_class  = 'X'.
  ENDIF.
  IF lwa_acc-price_ctrl  IS NOT INITIAL.
    lwa_accx-price_ctrl = 'X'.
  ENDIF.
  IF lwa_acc-moving_pr  IS NOT INITIAL.
    lwa_accx-moving_pr  = 'X'.
  ENDIF.
  IF lwa_acc-price_unit  IS NOT INITIAL.
    lwa_accx-price_unit = 'X'.
  ENDIF.
  IF lwa_acc-std_price  IS NOT INITIAL.
    lwa_accx-std_price  = 'X'.
  ENDIF.

  lwa_ware-whse_no = ''."lwa_main-lgnum.
  lwa_ware-stge_type = ''." lwa_main-lgtyp.
  lwa_warex-whse_no = ''."lwa_main-lgnum.
  IF lwa_ware-stge_type IS NOT INITIAL.
    lwa_warex-stge_type = 'X'.
  ENDIF.



********************************** Sales **********************************

  lwa_sale-sales_org   = p_lv_vkorg.
  lwa_sale-distr_chan  = p_lv_vtweg.
*    lwa_sale-item_cat    = lwa_main-mtpos_d.
*    lwa_sale-mat_pr_grp  = lwa_main-kondm.
  lwa_sale-acct_assgt  = lwa_ZMM_MAT_CONSTANT-ktgrm.
  lwa_sale-matl_stats = lwa_ZMM_MAT_CONSTANT-versg.
*    lwa_sale-min_order  = lwa_main-aumng.
*    lwa_sale-matl_grp_4  = lwa_main-matl_grp_4.
*    lwa_sale-matl_grp_3  = lwa_main-matl_grp_3.

  lwa_salex-sales_org   = p_lv_vkorg.
  lwa_salex-distr_chan  = p_lv_vtweg.
  IF lwa_sale-item_cat  IS NOT INITIAL.
    lwa_salex-item_cat    = 'X'.
  ENDIF.
  IF lwa_sale-mat_pr_grp  IS NOT INITIAL.
    lwa_salex-mat_pr_grp  = 'X'.
  ENDIF.
  IF lwa_sale-acct_assgt  IS NOT INITIAL.
    lwa_salex-acct_assgt  = 'X'.
  ENDIF.
  IF lwa_sale-min_order  IS NOT INITIAL.
    lwa_salex-min_order   = 'X'.
  ENDIF.
  IF lwa_sale-matl_grp_4  IS NOT INITIAL.
    lwa_salex-matl_grp_4 = 'X'.
  ENDIF.
  IF lwa_sale-matl_grp_3  IS NOT INITIAL.
    lwa_salex-matl_grp_3 = 'X'.
  ENDIF.
******TAX data
  CLEAR : lwa_tax-depcountry,lwa_tax-tax_type_1.
  SELECT SINGLE land1 INTO lwa_tax-depcountry FROM t001w WHERE werks = p_lv_werks.
  IF sy-subrc = 0 AND p_lv_werks CP '2***'.
    SELECT SINGLE tatyp INTO  lwa_tax-tax_type_1 FROM tstl WHERE talnd = lwa_tax-depcountry.
    lwa_tax-taxclass_1 = lwa_zmm_mat_constant-taklv."    lwa_main-taxm1.
    lwa_tax-tax_ind    = lwa_zmm_mat_constant-taxim.
    APPEND lwa_tax TO it_tax.
  ENDIF.
  CLEAR lwa_tax.
  lwa_tax-depcountry = 'SA'.
  SELECT SINGLE tatyp INTO  lwa_tax-tax_type_1 FROM tstl WHERE talnd = lwa_tax-depcountry.
  IF sy-subrc = 0 AND p_lv_werks CP '1***'.
    lwa_tax-taxclass_1 = lwa_zmm_mat_constant-taklv. " lwa_main-taxm1.
    lwa_tax-tax_ind    = lwa_zmm_mat_constant-taxim.
    APPEND lwa_tax TO it_tax.
  ENDIF.



  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata             = ls_mathead
      clientdata           = ls_mat_grp
      clientdatax          = ls_mat_grpx
      plantdata            = lv_plantdata
      plantdatax           = lv_plantdatax
      forecastparameters   = lwa_forecast
      forecastparametersx  = lwa_forecastx
      storagelocationdata  = lwa_store
      storagelocationdatax = lwa_storex
      valuationdata        = lwa_acc
      valuationdatax       = lwa_accx
      warehousenumberdata  = lwa_ware
      warehousenumberdatax = lwa_warex
      salesdata            = lwa_sale
      salesdatax           = lwa_salex
    IMPORTING
      return               = lt_return
    TABLES
      materialdescription  = lt_MATERIALDESCRIPTION
      taxclassifications   = it_tax.


  APPEND lt_return TO p_ltt_return.

ENDFORM.

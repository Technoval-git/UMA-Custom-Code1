*&---------------------------------------------------------------------*
*& Report ZMM_PRICE_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_price_update.
*
*This program will be scheduled in background for each brand for todays
*purpose is to create or update sales price




TABLES: mara.

TYPES: BEGIN OF ty_mseg ,
         mblnr TYPE mblnr,
         matnr TYPE matnr,
         waers TYPE waers,
         dmbtr TYPE dmbtr,
         menge type menge_d,
       END OF ty_mseg,
       BEGIN OF tyd_mseg ,
         mblnr TYPE mblnr,
         matnr TYPE matnr,
         dmbtr TYPE dmbtr,
         smbln TYPE mblnr,

       END OF tyd_mseg.

DATA: c_matnr      TYPE matnr,
      lv_brand     TYPE zmm_brand,
      lt_mseg      TYPE STANDARD TABLE OF ty_mseg,
      lw_mseg      TYPE ty_mseg,
      ltd_mseg     TYPE  STANDARD TABLE OF tyd_mseg,
      lwd_mseg     TYPE tyd_mseg,
      lt_factor    TYPE STANDARD TABLE OF zmm_pc_factor,
      lt_varkey1   TYPE char100,
      lt_ct        TYPE STANDARD TABLE OF bapicondct,
      lt_hd        TYPE STANDARD TABLE OF bapicondhd,
      lt_IT        TYPE STANDARD TABLE OF bapicondit,
      lt_qs        TYPE STANDARD TABLE OF bapicondqs,
      lt_vs        TYPE STANDARD TABLE OF bapicondvs,
      lt_BAPIRET2  TYPE STANDARD TABLE OF bapiret2,
      lt_KNUMHS    TYPE STANDARD TABLE OF bapiknumhs,
      lt_mem       TYPE STANDARD TABLE OF cnd_mem_initial,
      gv_matnr     TYPE matnr,
      gv_werks     TYPE werks_d,
      gv_ekorg     TYPE ekorg,
      gv_lifnr     TYPE lifnr,
      gv_price1    TYPE char15,
      gv_price2    TYPE char15,
      gv_vkorg     TYPE vkorg,
      gv_vtweg     TYPE vtweg,
      lwwwbapiret2 TYPE bapiret2,
      lt_BAPIRET3  TYPE STANDARD TABLE OF bapiret2,
      lw_ct        TYPE  bapicondct,
      tb_oper      TYPE msgfn,
      cond_usage   TYPE kvewe,
      table_no     TYPE  kotabnr,
      tb_kappl     TYPE kappl,
      tb_KSCHL     TYPE kscha,
      tb_VKORG     TYPE vkorg,
      tb_VTWEG     TYPE vtweg,
      tb_SPART     TYPE spart,
      tb_AUFART    TYPE /dbe/aufart,
      tb_matnr     TYPE zmm_matnr,
      tb_KNUMH     TYPE knumh,
      tb_KOPOS     TYPE kopos,
      tb_DATBI     TYPE kodatbi,
      tb_DATAB     TYPE kodatab,
      tb_meins     TYPE meins,
      tb_kpein     TYPE kpein,
      tb_stfkz     TYPE Stfkz,
      tb_krech     TYPE krech,
      tb_kstbm     TYPE kstbm,
      tb_kmein     TYPE kmein,
      tb_kumza     TYPE kumza,
      tb_kumne     TYPE kumne,
      tb_curr      TYPE konws,
      tb_curr_iso  TYPE bapiisocd,
      tb_price     TYPE netpr,
      tb_condidx   TYPE dzaehk_ind_short,
      tb_var       TYPE char100.
data GV_dmbtr type dmbtr.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
*  SELECTION-SCREEN BEGIN OF LINE.
*    PARAMETERS   p_hq RADIOBUTTON GROUP gr1  DEFAULT 'X' USER-COMMAND rb1sel .
*    SELECTION-SCREEN COMMENT 2(10) FOR FIELD p_hq.
*    PARAMETERS  p_MS RADIOBUTTON GROUP gr1 .
*    SELECTION-SCREEN COMMENT 17(10) FOR FIELD p_ms.
*    PARAMETERS  p_df RADIOBUTTON GROUP gr1.
*    SELECTION-SCREEN COMMENT 32(10) FOR FIELD p_df.
*  SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN SKIP.
  PARAMETERS :p_date  TYPE mseg-budat_mkpf OBLIGATORY.
*              p_matkl TYPE mara-matkl OBLIGATORY.
  SELECT-OPTIONS s_matkl FOR mara-matkl OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.
*  IF p_hq = 'X'.
**    CONCATENATE 'HQ' '%' INTO c_matnr.
*    lv_brand = 'HQ'.
*
*  ELSEIF p_MS = 'X'.
*    lv_brand = 'MS'.
**    CONCATENATE 'MS' '%' INTO c_matnr.
*  ELSEIF p_df = 'X'.
*    lv_brand = 'DF'.
**    CONCATENATE 'DF' '%' INTO c_matnr.
*  ENDIF.


  SELECT a~mblnr  a~matnr a~waers a~dmbtr a~menge FROM mseg AS a INNER JOIN ekko AS b
  ON a~ebeln = b~ebeln INNER JOIN mara AS c ON a~matnr = c~matnr
  INTO TABLE lt_mseg
  WHERE  a~bukrs = '1000'
     AND a~ebeln <> ''
     AND a~bwart = '101'
     AND a~budat_mkpf = p_date
*     AND a~matnr LIKE c_matnr
     AND ( b~bsart = 'YIPO' OR b~bsart = 'YLPO' or b~bsart = 'YVIP' or b~bsart = 'YWPO')
     AND c~matkl IN s_matkl.
sort lt_mseg by mblnr matnr waers ASCENDING  dmbtr DESCENDING.
  READ TABLE lt_mseg INTO lw_mseg INDEX 1.
  IF sy-subrc = 0.
    lv_brand = lw_mseg-matnr+0(2) .
    SELECT * FROM zmm_pc_factor INTO TABLE lt_factor WHERE brand = lv_brand.
  ENDIF.

  IF lt_mseg[] IS NOT INITIAL.
    SELECT mblnr  matnr dmbtr smbln FROM mseg INTO TABLE ltd_mseg FOR ALL ENTRIES IN lt_mseg
      WHERE smbln = lt_mseg-mblnr.
    LOOP AT ltd_mseg INTO  lwd_mseg.
      DELETE lt_mseg WHERE mblnr = lwd_mseg-smbln.
    ENDLOOP.
    SORT lt_mseg BY matnr mblnr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING matnr.
  ENDIF.


  sy-ucomm = 'SALE1'.  " this is for INCLUDE zmm_pc_info_sub2.

  LOOP AT lt_mseg INTO lw_mseg.
*       YP01 - sales price
    SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr = @lw_mseg-matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

    LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor>).

      READ TABLE lt_inforec ASSIGNING FIELD-SYMBOL(<fs_inforec>) WITH KEY matnr = lw_mseg-matnr
                                                                                    vkorg = <lw_factor>-vkorg
                                                                                    vtweg = <lw_factor>-vtweg
                                                                                    kschl = <lw_factor>-kschl.
      IF sy-subrc = 0.

        CONCATENATE  <fs_inforec>-vkorg <fs_inforec>-vtweg <fs_inforec>-matnr  INTO lt_varkey1.
        tb_oper     = '004'.
        cond_usage  =  'A'.
        table_no    = '004'.
        tb_kappl    = 'V'.
        tb_KSCHL    = <lw_factor>-kschl.
        tb_DATBI    = <fs_inforec>-datbi.
        tb_DATAB    = <fs_inforec>-datab.
        tb_KNUMH    = <fs_inforec>-knumh.
        tb_KOPOS    = <fs_inforec>-kopos.
        tb_meins    = <fs_inforec>-meins.
        tb_kpein    = '1'."<fs_inforec>-kpein.
        tb_stfkz    = <fs_inforec>-Stfkz.
        tb_krech    = <fs_inforec>-krech.
        tb_kstbm    = <fs_inforec>-kstbm.
        tb_kmein    = 'EA'. "<fs_inforec>-kmein.

        tb_kumza    = <fs_inforec>-kumza.
        tb_kumne    = <fs_inforec>-kumne.
        tb_curr     = lw_mseg-waers.
        tb_curr_iso = lw_mseg-waers.
        tb_var      = lt_varkey1.
        clear gv_dmbtr.
        gv_dmbtr = lw_mseg-dmbtr.
        divide gv_dmbtr by lw_mseg-menge.
        tb_price    = gv_dmbtr.  " lw_mseg-dmbtr." / <lw_factor>-factor.
        DIVIDE tb_price BY <lw_factor>-factor.


        CLEAR : gv_matnr,gv_vtweg,gv_vkorg,gv_price1,gv_price2.
        gv_matnr = lw_mseg-matnr.
        gv_vkorg = <fs_inforec>-vkorg.
        gv_vtweg  = <fs_inforec>-vtweg.
        gv_price1 = <fs_inforec>-kbetr.
        gv_price2 = tb_price.


        INCLUDE zmm_pc_info_sub2.

      ELSE."--------------------------------------------------
        CONCATENATE  <lw_factor>-vkorg <lw_factor>-vtweg lw_mseg-matnr  INTO lt_varkey1.
        tb_oper    = '009'.
        cond_usage =  'A'.
        table_no   = '004'.
        tb_kappl   = 'V'.
        tb_KSCHL   = <lw_factor>-kschl.
        tb_DATBI   = '99991231' .
        tb_DATAB   = sy-datum.
        tb_KNUMH   = '$000000001' .
        tb_KOPOS    = '01' .
        tb_meins   = 'EA'.
        tb_curr     = lw_mseg-waers.
        tb_curr_iso = lw_mseg-waers.
        tb_var      = lt_varkey1.
        clear gv_dmbtr.
        gv_dmbtr = lw_mseg-dmbtr.
        divide gv_dmbtr by lw_mseg-menge.


        tb_price    = gv_dmbtr. "lw_mseg-dmbtr. " / <lw_factor>-factor.
        DIVIDE tb_price BY <lw_factor>-factor.
        tb_kpein    = '1'.
        tb_kmein    = 'EA'.
        CLEAR : gv_matnr,gv_vtweg,gv_vkorg,gv_price1,gv_price2.
        gv_matnr = lw_mseg-matnr.
        gv_vkorg = <lw_factor>-vkorg.
        gv_vtweg  = <lw_factor>-vtweg.
        gv_price1 = 0.
        gv_price2 = tb_price.
        INCLUDE zmm_pc_info_sub2.

      ENDIF.
    ENDLOOP.
  ENDLOOP.


  IF lt_bapiret3[] IS NOT INITIAL.
    CALL FUNCTION 'ZMM_ALV_POPUP'
      EXPORTING
        i_start_column = 5
        i_start_line   = 5
        i_end_column   = 150
        i_end_line     = 100
        i_title        = 'ALV'
        i_popup        = 'X'
      TABLES
        it_alv         = lt_bapiret3.
    CLEAR lt_bapiret3.
  ENDIF.

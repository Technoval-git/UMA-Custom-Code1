*----------------------------------------------------------------------*
***INCLUDE ZMM_PC_SALE.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zmm_pc_sale
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zmm_pc_sale .
  TABLES : zmm_pc_factor.
  DATA :
    lt_ct       TYPE STANDARD TABLE OF bapicondct,
    lt_hd       TYPE STANDARD TABLE OF bapicondhd,
    lt_IT       TYPE STANDARD TABLE OF bapicondit,
    lt_qs       TYPE STANDARD TABLE OF bapicondqs,
    lt_vs       TYPE STANDARD TABLE OF bapicondvs,
    lt_BAPIRET2 TYPE STANDARD TABLE OF  bapiret2,
    lt_KNUMHS   TYPE STANDARD TABLE OF bapiknumhs,
    lt_mem      TYPE STANDARD TABLE OF cnd_mem_initial.
  DATA lt_varkey1 TYPE char100.

  DATA: ltt_return TYPE TABLE OF bapiret2,
        lt_zmm_gm  TYPE STANDARD TABLE OF zmm_gm,
        lt_zmm_hq  TYPE STANDARD TABLE OF zmm_hq,
        lt_zmm_ac  TYPE STANDARD TABLE OF zmm_ac,
        lt_zmm_df  TYPE STANDARD TABLE OF zmm_df,
        lt_zmm_ma  TYPE STANDARD TABLE OF zmm_ma,
        lv_matnr   TYPE matnr,
        lv_maktx   TYPE maktx.

  DATA :lt_factor TYPE STANDARD TABLE OF zmm_pc_factor,
        ls_factor TYPE zmm_pc_factor.
  DATA : lt_eina          TYPE  mewieina_mig_t,
         lt_einax         TYPE  mewieinax_t,
         lt_eine          TYPE  mewieine_t,
         lt_einex         TYPE  mewieinex_t,
         lt_return        TYPE  fs4mig_t_bapiret2,
         im_eina          TYPE mewieina_mig_t,
         im_eine          TYPE mewieine_t,
         ls_return        TYPE bapiret2,
         lt_COND_VALIDITY TYPE  mewivalidity_tt,
         lt_CONDITION     TYPE  mewicondition_tt.

  DATA:lv_price_s TYPE netpr, " selling price
       lv_price_w TYPE netpr,  " warranty price
       lv_cat     TYPE zmm_brand.

  IF p_gm = 'X'.
    lv_cat = 'GM'.
  ELSEIF  p_ac = 'X'.
    lv_cat = 'AC'.
  ELSEIF  p_HQ = 'X'.
    lv_cat = 'HQ'.
  ELSEIF  p_df = 'X'.
    lv_cat = 'DF'.
  ELSEIF  p_ma = 'X'.
    lv_cat = 'MS'.
  ENDIF.

*  *Need to select all data with all fields
  SELECT * FROM zmm_pc_factor INTO TABLE lt_factor WHERE brand = lv_cat.

  IF s_matnr[] IS NOT INITIAL.
    IF p_gm = 'X'. "-------------------------------------------------------------------------------

      SELECT * FROM zmm_gm INTO TABLE lt_zmm_gm WHERE gm_matnr IN s_matnr.

      IF lt_factor IS NOT INITIAL.
*        LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat>).
*          IF <mat>-low+0(2) NE 'GM' AND <mat>-low IS NOT INITIAL.
*            CONCATENATE 'GM' <mat>-low INTO <mat>-low.
*          ENDIF.
*          IF <mat>-high+0(2) NE 'GM' AND <mat>-high IS NOT INITIAL.
*            CONCATENATE 'GM' <mat>-high INTO <mat>-high.
*          ENDIF.
*        ENDLOOP.

        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'GM' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'GM' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'GM' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'GM' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.
*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.

      LOOP AT lt_zmm_gm ASSIGNING FIELD-SYMBOL(<fs_00>).
        IF <fs_00>-gm_matnr+0(2) NE 'GM'.
          CONCATENATE 'GM' <fs_00>-gm_matnr INTO <fs_00>-gm_matnr.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_00>-gm_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor>).
            IF <lw_factor>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
              CONTINUE.
            ENDIF.
            CLEAR :lv_price_s, lv_price_w.



            IF <lw_factor>-kschl = 'YP01'.
              PERFORM get_price TABLES lt_factor USING <fs_00>-gm_price
                                                     <fs_00>-gm_cour_surc
                                                     <lw_factor>-vkorg
                                                     <lw_factor>-vtweg
                                                     <lw_factor>-kschl
                                                      'S' " Selling price
                                             CHANGING lv_price_s.
              READ TABLE lt_inforec ASSIGNING FIELD-SYMBOL(<fs_inforec>) WITH KEY matnr = <fs_00>-gm_matnr
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
                tb_kpein    = <fs_inforec>-kpein.
                tb_stfkz    = <fs_inforec>-Stfkz.
                tb_krech    = <fs_inforec>-krech.
                tb_kstbm    = <fs_inforec>-kstbm.
                tb_kmein    = <fs_inforec>-kmein.
                tb_kumza    = <fs_inforec>-kumza.
                tb_kumne    = <fs_inforec>-kumne.
                tb_curr     = <fs_00>-gm_waers.
                tb_curr_iso = <fs_00>-gm_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.



                CLEAR : gv_matnr,gv_vtweg,gv_vkorg,gv_price1,gv_price2.
                gv_matnr = <fs_inforec>-matnr.
                gv_vkorg = <fs_inforec>-vkorg.
                gv_vtweg  = <fs_inforec>-vtweg.
                gv_price1 = <fs_inforec>-kbetr.
                gv_price2 = lv_price_s.


                INCLUDE zmm_pc_info_sub2.

              ELSE."--------------------------------------------------
                CONCATENATE  <lw_factor>-vkorg <lw_factor>-vtweg <fs_00>-gm_matnr  INTO lt_varkey1.
                tb_oper    = '009'.
                cond_usage =  'A'.
                table_no   = '004'.
                tb_kappl   = 'V'.
                tb_KSCHL   = <lw_factor>-kschl.
                tb_DATBI   = '99991231' .
                tb_DATAB   = sy-datum.
                tb_KNUMH   = '$000000001' .
                tb_KOPOS    = '01' ."<fs_inforec>-kopos.
                tb_meins   = 'EA'.
                tb_curr     = <fs_00>-gm_waers.
                tb_curr_iso = <fs_00>-gm_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.
                tb_kpein    = '1'.
                tb_kmein    = 'EA'.
                CLEAR : gv_matnr,gv_vtweg,gv_vkorg,gv_price1,gv_price2.
                gv_matnr = <fs_00>-gm_matnr.
                gv_vkorg = <lw_factor>-vkorg.
                gv_vtweg  = <lw_factor>-vtweg.
                gv_price1 = 0.
                gv_price2 = lv_price_s.
                INCLUDE zmm_pc_info_sub2.
              ENDIF.
            ENDIF.
*            for warranty price
            IF <lw_factor>-kschl = 'YWP1'.
              PERFORM get_price TABLES lt_factor USING <fs_00>-gm_price
                                                    <fs_00>-gm_cour_surc
                                                    <lw_factor>-vkorg
                                                    <lw_factor>-vtweg
                                                    <lw_factor>-kschl
                                                     'W' " Warranty Price
                                            CHANGING lv_price_w.
              CLEAR lt_varkey1.
              READ TABLE lt_inforec_w ASSIGNING FIELD-SYMBOL(<fs_inforec_w>) WITH KEY matnr = <fs_00>-gm_matnr
                                                                                vkorg = <lw_factor>-vkorg
                                                                                vtweg = <lw_factor>-vtweg
                                                                                kschl = <lw_factor>-kschl.
              IF sy-subrc = 0.
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor>-vkorg
                                      vtweg = <lw_factor>-vtweg
                                      kschl = <lw_factor>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  <fs_inforec_w>-vkorg <fs_inforec_w>-vtweg ls_factor-spart ls_factor-aufart <fs_inforec_w>-matnr  INTO lt_varkey1.
                  tb_oper     = '004'.
                  cond_usage  =  'A'.
                  table_no    = '900'.
                  tb_kappl    = 'V'.
                  tb_KSCHL    = <lw_factor>-kschl.
                  tb_DATBI    = <fs_inforec_w>-datbi.
                  tb_DATAB    = <fs_inforec_w>-datab.
                  tb_KNUMH    = <fs_inforec_w>-knumh.
                  tb_KOPOS    = <fs_inforec_w>-kopos.
                  tb_meins    = <fs_inforec_w>-meins.
                  tb_kpein    = <fs_inforec_w>-kpein.
                  tb_stfkz    = <fs_inforec_w>-Stfkz.
                  tb_krech    = <fs_inforec_w>-krech.
                  tb_kstbm    = <fs_inforec_w>-kstbm.
                  tb_kmein    = <fs_inforec_w>-kmein.
                  tb_kumza    = <fs_inforec_w>-kumza.
                  tb_kumne    = <fs_inforec_w>-kumne.
                  tb_curr     = <fs_00>-gm_waers.
                  tb_curr_iso = <fs_00>-gm_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.



                  CLEAR : gv_matnr,gv_vtweg,gv_vkorg,gv_price1,gv_price2.
                  gv_matnr = <fs_inforec_w>-matnr.
                  gv_vkorg = <fs_inforec_w>-vkorg.
                  gv_vtweg  = <fs_inforec_w>-vtweg.
                  gv_price1 = <fs_inforec_w>-kbetr.
                  gv_price2 = lv_price_w.


                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ELSE."--------------------------------------------------
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor>-vkorg
                                      vtweg = <lw_factor>-vtweg
                                      kschl = <lw_factor>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  ls_factor-vkorg ls_factor-vtweg ls_factor-spart ls_factor-aufart <fs_00>-gm_matnr  INTO lt_varkey1.
                  tb_oper    = '009'.
                  cond_usage =  'A'.
                  table_no   = '900'.
                  tb_kappl   = 'V'.
                  tb_KSCHL   = <lw_factor>-kschl.
                  tb_DATBI   = '99991231' .
                  tb_DATAB   = sy-datum.
                  tb_KNUMH   = '$000000001' .
                  tb_KOPOS    = '01' ."<fs_inforec>-kopos.
                  tb_meins   = 'EA'.
                  tb_curr     = <fs_00>-gm_waers.
                  tb_curr_iso = <fs_00>-gm_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.
                  tb_kpein    = '1'.
                  tb_kmein    = 'EA'.
                  CLEAR : gv_matnr,gv_vtweg,gv_vkorg,gv_price1,gv_price2.
                  gv_matnr = <fs_00>-gm_matnr.
                  gv_vkorg = <lw_factor>-vkorg.
                  gv_vtweg  = <lw_factor>-vtweg.
                  gv_price1 = 0.
                  gv_price2 = lv_price_w.
                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

    ELSEIF p_HQ = 'X'.  "-------------------------------------------------------------------------------------


      SELECT * FROM zmm_hq INTO TABLE lt_zmm_hq WHERE hq_matnr IN s_matnr.

      IF lt_factor IS NOT INITIAL.
*        LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat1>).
*          IF <mat1>-low+0(2) NE 'HQ' AND <mat1>-low IS NOT INITIAL.
*            CONCATENATE 'HQ' <mat1>-low INTO <mat1>-low.
*          ENDIF.
*          IF <mat1>-high+0(2) NE 'HQ' AND <mat1>-high IS NOT INITIAL.
*            CONCATENATE 'HQ' <mat1>-high INTO <mat1>-high.
*          ENDIF.
*        ENDLOOP.
        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'HQ' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'HQ' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'HQ' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'HQ' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.

*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec1) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w1) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.

      LOOP AT lt_zmm_hq ASSIGNING FIELD-SYMBOL(<fs_01>).

        IF <fs_01>-hq_matnr+0(2) NE 'HQ'.
          CONCATENATE 'HQ' <fs_01>-hq_matnr INTO <fs_01>-hq_matnr.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_01>-hq_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor1>).
            IF <lw_factor1>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
              CONTINUE.
            ENDIF.
            CLEAR :lv_price_s, lv_price_w.



            IF <lw_factor1>-kschl = 'YP01'.
              PERFORM get_price TABLES lt_factor USING <fs_01>-hq_price
                                                     ' '  "<fs_01>-hq_cour_surc
                                                     <lw_factor1>-vkorg
                                                     <lw_factor1>-vtweg
                                                     <lw_factor1>-kschl
                                                      'S' " Selling price
                                             CHANGING lv_price_s.
              READ TABLE lt_inforec1 ASSIGNING FIELD-SYMBOL(<fs_inforec1>) WITH KEY matnr = <fs_01>-hq_matnr
                                                                                  vkorg = <lw_factor1>-vkorg
                                                                                  vtweg = <lw_factor1>-vtweg
                                                                                  kschl = <lw_factor1>-kschl.
              IF sy-subrc = 0.
                CONCATENATE  <fs_inforec1>-vkorg <fs_inforec1>-vtweg <fs_inforec1>-matnr  INTO lt_varkey1.
                tb_oper     = '004'.
                cond_usage  =  'A'.
                table_no    = '004'.
                tb_kappl    = 'V'.
                tb_KSCHL    = <lw_factor1>-kschl.
                tb_DATBI    = <fs_inforec1>-datbi.
                tb_DATAB    = <fs_inforec1>-datab.
                tb_KNUMH    = <fs_inforec1>-knumh.
                tb_KOPOS    = <fs_inforec1>-kopos.
                tb_meins    = <fs_inforec1>-meins.
                tb_kpein    = <fs_inforec1>-kpein.
                tb_stfkz    = <fs_inforec1>-Stfkz.
                tb_krech    = <fs_inforec1>-krech.
                tb_kstbm    = <fs_inforec1>-kstbm.
                tb_kmein    = <fs_inforec1>-kmein.
                tb_kumza    = <fs_inforec1>-kumza.
                tb_kumne    = <fs_inforec1>-kumne.
                tb_curr     = <fs_01>-hq_waers.
                tb_curr_iso = <fs_01>-hq_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.
                INCLUDE zmm_pc_info_sub2.

              ELSE."--------------------------------------------------
                CONCATENATE  <lw_factor1>-vkorg <lw_factor1>-vtweg <fs_01>-hq_matnr  INTO lt_varkey1.
                tb_oper    = '009'.
                cond_usage =  'A'.
                table_no   = '004'.
                tb_kappl   = 'V'.
                tb_KSCHL   = <lw_factor1>-kschl.
                tb_DATBI   = '99991231' .
                tb_DATAB   = sy-datum.
                tb_KNUMH   = '$000000001' .
                tb_KOPOS    = '01' ."<fs_inforec>-kopos.
                tb_meins   = 'EA'.
                tb_curr     = <fs_01>-hq_waers.
                tb_curr_iso = <fs_01>-hq_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.

                tb_kpein    = '1'.
                tb_kmein    = 'EA'.


                INCLUDE zmm_pc_info_sub2.
              ENDIF.
            ENDIF.
*            for warranty price
            IF <lw_factor1>-kschl = 'YWP1'.
              PERFORM get_price TABLES lt_factor USING <fs_01>-hq_price
                                                   ' ' " <fs_01>-hq_cour_surc
                                                    <lw_factor1>-vkorg
                                                    <lw_factor1>-vtweg
                                                    <lw_factor1>-kschl
                                                     'W' " Warranty Price
                                            CHANGING lv_price_w.
              CLEAR lt_varkey1.
              READ TABLE lt_inforec_w1 ASSIGNING FIELD-SYMBOL(<fs_inforec_w1>) WITH KEY matnr = <fs_01>-hq_matnr
                                                                                vkorg = <lw_factor1>-vkorg
                                                                                vtweg = <lw_factor1>-vtweg
                                                                                kschl = <lw_factor1>-kschl.
              IF sy-subrc = 0.
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor1>-vkorg
                                      vtweg = <lw_factor1>-vtweg
                                      kschl = <lw_factor1>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  <fs_inforec_w1>-vkorg <fs_inforec_w1>-vtweg ls_factor-spart ls_factor-aufart <fs_inforec_w1>-matnr  INTO lt_varkey1.
                  tb_oper     = '004'.
                  cond_usage  =  'A'.
                  table_no    = '900'.
                  tb_kappl    = 'V'.
                  tb_KSCHL    = <lw_factor1>-kschl.
                  tb_DATBI    = <fs_inforec_w1>-datbi.
                  tb_DATAB    = <fs_inforec_w1>-datab.
                  tb_KNUMH    = <fs_inforec_w1>-knumh.
                  tb_KOPOS    = <fs_inforec_w1>-kopos.
                  tb_meins    = <fs_inforec_w1>-meins.
                  tb_kpein    = <fs_inforec_w1>-kpein.
                  tb_stfkz    = <fs_inforec_w1>-Stfkz.
                  tb_krech    = <fs_inforec_w1>-krech.
                  tb_kstbm    = <fs_inforec_w1>-kstbm.
                  tb_kmein    = <fs_inforec_w1>-kmein.
                  tb_kumza    = <fs_inforec_w1>-kumza.
                  tb_kumne    = <fs_inforec_w1>-kumne.
                  tb_curr     = <fs_01>-hq_waers.
                  tb_curr_iso = <fs_01>-hq_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.
                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ELSE."--------------------------------------------------
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor1>-vkorg
                                      vtweg = <lw_factor1>-vtweg
                                      kschl = <lw_factor1>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  ls_factor-vkorg ls_factor-vtweg ls_factor-spart ls_factor-aufart <fs_01>-hq_matnr  INTO lt_varkey1.
                  tb_oper    = '009'.
                  cond_usage =  'A'.
                  table_no   = '900'.
                  tb_kappl   = 'V'.
                  tb_KSCHL   = <lw_factor1>-kschl.
                  tb_DATBI   = '99991231' .
                  tb_DATAB   = sy-datum.
                  tb_KNUMH   = '$000000001' .
                  tb_KOPOS    = '01' ."<fs_inforec>-kopos.
                  tb_meins   = 'EA'.
                  tb_curr     = <fs_01>-hq_waers.
                  tb_curr_iso = <fs_01>-hq_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.
                  tb_kpein    = '1'.
                  tb_kmein    = 'EA'.
                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
*      SELECT * FROM zmm_pc_autho  WHERE category = 'HQ'
*                                           AND uname = @sy-uname
*                                           AND werks IS NOT INITIAL
*                                         INTO TABLE @DATA(lt_autho_hq).
*      SELECT * FROM zmm_hq INTO TABLE lt_zmm_hq WHERE hq_matnr IN s_matnr.
*
*      IF lt_autho_hq IS NOT INITIAL.
*        LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat1>).
*          IF <mat1>-low+0(2) NE 'HQ' AND <mat1>-low IS NOT INITIAL.
*            CONCATENATE 'HQ' <mat1>-low INTO <mat1>-low.
*          ENDIF.
*          IF <mat1>-high+0(2) NE 'HQ' AND <mat1>-high IS NOT INITIAL.
*            CONCATENATE 'HQ' <mat1>-high INTO <mat1>-high.
*          ENDIF.
*        ENDLOOP.
*        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
*          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
*          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec1) FOR ALL ENTRIES IN @lt_autho_hq
*          WHERE a~kappl = 'V' AND a~kschl = @lt_autho_hq-kschl AND a~vkorg = @lt_autho_hq-vkorg AND a~matnr IN @s_matnr
*            AND a~vtweg = @lt_autho_hq-vtweg  AND b~loevm_ko NE 'X'.
*      ENDIF.
*
*      LOOP AT lt_zmm_hq ASSIGNING FIELD-SYMBOL(<fs_hq>).
*        IF <fs_hq>-hq_matnr+0(2) NE 'HQ'.
*          CONCATENATE 'HQ' <fs_HQ>-hq_matnr INTO <fs_hq>-hq_matnr.
*        ENDIF.
*        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_hq>-hq_matnr.
*        IF sy-subrc = 0.
*          LOOP AT lt_autho_hq ASSIGNING FIELD-SYMBOL(<lw_autho_hq>).
*            IF <lw_autho_hq>-kschl IS INITIAL.
*              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
*              CONTINUE.
*            ENDIF.
*            READ TABLE lt_inforec1 ASSIGNING FIELD-SYMBOL(<fs_inforec1>) WITH KEY matnr = <fs_hq>-hq_matnr
*                                                                                vkorg = <lw_autho_hq>-vkorg
*                                                                                vtweg = <lw_autho_hq>-vtweg
*                                                                                kschl = <lw_autho_hq>-kschl.
*            IF sy-subrc = 0.
*              CLEAR : lt_ct,lt_hd,lt_it,lt_bapiret2,lt_knumhs,lt_varkey1.
*              CONCATENATE  <fs_inforec1>-vkorg <fs_inforec1>-vtweg <fs_inforec1>-matnr  INTO lt_varkey1.
*              lt_ct = VALUE #( ( operation  = '004'
*                                 cond_usage = 'A'
*                                 table_no   = '004'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_hq>-kschl
*                                 varkey     = lt_varkey1
*                                 valid_to   = <fs_inforec1>-datbi
*                                 valid_from = <fs_inforec1>-datab
*                                 cond_no    = <fs_inforec1>-knumh ) ).
*              lt_hd = VALUE #( ( operation  = '004'
*                                 cond_no    = <fs_inforec1>-knumh
*                                 cond_usage = 'A'
*                                 table_no   = '004'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_hq>-kschl
*                                 varkey     = lt_varkey1
*                                 valid_from = <fs_inforec1>-datab
*                                 valid_to   = <fs_inforec1>-datbi ) ).
*              lt_it = VALUE #( ( operation  = '004'
*                                 cond_no    = <fs_inforec1>-knumh
*                                 cond_count =  <fs_inforec1>-kopos
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_hq>-kschl
*                                 cond_value =  <fs_hq>-hq_price
*                                 base_uom   = <fs_inforec1>-meins
*                                 cond_p_unt = <fs_inforec1>-kpein
*                                 scaletype  = <fs_inforec1>-Stfkz
*                                 calctypcon = <fs_inforec1>-krech
*                                 scale_qty  = <fs_inforec1>-kstbm
*                                 cond_unit  =  <fs_inforec1>-kmein
*                                 numconvert = <fs_inforec1>-kumza
*                                 denominato = <fs_inforec1>-kumne
*                                 condcurr   = <fs_hq>-hq_waers
*                                 cond_iso   = <fs_hq>-hq_waers  ) ).
*              INCLUDE zmm_pc_info_sub2.
*
*            ELSE."--------------------------------------------------
*              CLEAR : lt_ct,lt_hd,lt_it,lt_bapiret2,lt_knumhs,lt_varkey1.
*              CONCATENATE  <lw_autho_hq>-vkorg <lw_autho_hq>-vtweg <fs_hq>-hq_matnr  INTO lt_varkey1.
*              lt_ct = VALUE #( ( operation  = '009'
*                                 cond_usage = 'A'
*                                 table_no   = '004'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_hq>-kschl
*                                 varkey     = lt_varkey1
*                                 valid_to   = '99991231'
*                                 valid_from = sy-datum
*                                 cond_no    = '$000000001' "<fs_inforec>-knumh
*                                  ) ).
*              lt_hd = VALUE #( ( operation  = '009'
*                                 cond_no    = '$000000001'
*                                 cond_usage = 'A'
*                                 table_no   = '004'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_hq>-kschl
*                                 varkey     = lt_varkey1
*                                 valid_from = sy-datum
*                                 valid_to   = '99991231' ) ).
*              lt_it = VALUE #( ( operation  = '009'
*                                 cond_no    = '$000000001'
*                                 cond_count =  '01'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_hq>-kschl
*                                 cond_value =  <fs_hq>-hq_price
*                                 base_uom   = 'EA' "<fs_inforec>-meins
*                                 condcurr   = <fs_hq>-hq_waers
*                                 cond_iso   = <fs_hq>-hq_waers  ) ).
*              INCLUDE zmm_pc_info_sub2.
*
*            ENDIF.
*          ENDLOOP.
*        ENDIF.
*      ENDLOOP.
*

    ELSEIF p_ac = 'X'. "---------------------------------------------------------------------------------------------------


      SELECT * FROM zmm_ac INTO TABLE lt_zmm_ac WHERE ac_delco IN s_matnr.

      IF lt_factor IS NOT INITIAL.
*        LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat2>).
*          IF <mat2>-low+0(2) NE 'AC' AND <mat2>-low IS NOT INITIAL.
*            CONCATENATE 'AC' <mat2>-low INTO <mat2>-low.
*          ENDIF.
*          IF <mat2>-high+0(2) NE 'AC' AND <mat2>-high IS NOT INITIAL.
*            CONCATENATE 'AC' <mat2>-high INTO <mat2>-high.
*          ENDIF.
*        ENDLOOP.
        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'AC' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'AC' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'AC' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'AC' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.
*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec2) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w2) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.

      LOOP AT lt_zmm_ac ASSIGNING FIELD-SYMBOL(<fs_02>).
        IF <fs_02>-ac_delco+0(2) NE 'AC'.
          CONCATENATE 'AC' <fs_02>-ac_delco INTO <fs_02>-ac_delco.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_02>-ac_delco.
        IF sy-subrc = 0.
          LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor2>).
            IF <lw_factor2>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
              CONTINUE.
            ENDIF.
            CLEAR :lv_price_s, lv_price_w.



            IF <lw_factor2>-kschl = 'YP01'.
              PERFORM get_price TABLES lt_factor USING <fs_02>-ac_price
                                                     <fs_02>-ac_cour_surc
                                                     <lw_factor2>-vkorg
                                                     <lw_factor2>-vtweg
                                                     <lw_factor2>-kschl
                                                      'S' " Selling price
                                             CHANGING lv_price_s.
              READ TABLE lt_inforec2 ASSIGNING FIELD-SYMBOL(<fs_inforec2>) WITH KEY matnr = <fs_02>-ac_delco
                                                                                  vkorg = <lw_factor2>-vkorg
                                                                                  vtweg = <lw_factor2>-vtweg
                                                                                  kschl = <lw_factor2>-kschl.
              IF sy-subrc = 0.
                CONCATENATE  <fs_inforec2>-vkorg <fs_inforec2>-vtweg <fs_inforec2>-matnr  INTO lt_varkey1.
                tb_oper     = '004'.
                cond_usage  =  'A'.
                table_no    = '004'.
                tb_kappl    = 'V'.
                tb_KSCHL    = <lw_factor2>-kschl.
                tb_DATBI    = <fs_inforec2>-datbi.
                tb_DATAB    = <fs_inforec2>-datab.
                tb_KNUMH    = <fs_inforec2>-knumh.
                tb_KOPOS    = <fs_inforec2>-kopos.
                tb_meins    = <fs_inforec2>-meins.
                tb_kpein    = <fs_inforec2>-kpein.
                tb_stfkz    = <fs_inforec2>-Stfkz.
                tb_krech    = <fs_inforec2>-krech.
                tb_kstbm    = <fs_inforec2>-kstbm.
                tb_kmein    = <fs_inforec2>-kmein.
                tb_kumza    = <fs_inforec2>-kumza.
                tb_kumne    = <fs_inforec2>-kumne.
                tb_curr     = <fs_02>-ac_waers.
                tb_curr_iso = <fs_02>-ac_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.
                INCLUDE zmm_pc_info_sub2.

              ELSE."--------------------------------------------------
                CONCATENATE  <lw_factor2>-vkorg <lw_factor2>-vtweg <fs_02>-ac_delco  INTO lt_varkey1.
                tb_oper    = '009'.
                cond_usage =  'A'.
                table_no   = '004'.
                tb_kappl   = 'V'.
                tb_KSCHL   = <lw_factor2>-kschl.
                tb_DATBI   = '99991231' .
                tb_DATAB   = sy-datum.
                tb_KNUMH   = '$000000001' .
                tb_KOPOS    = '01' ."<fs_inforec>-kopos.
                tb_meins   = 'EA'.
                tb_curr     = <fs_02>-ac_waers.
                tb_curr_iso = <fs_02>-ac_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.
                tb_kpein    = '1'.
                tb_kmein    = 'EA'.
                INCLUDE zmm_pc_info_sub2.
              ENDIF.
            ENDIF.
*            for warranty price
            IF <lw_factor2>-kschl = 'YWP1'.
              PERFORM get_price TABLES lt_factor USING <fs_02>-ac_price
                                                    <fs_02>-ac_cour_surc
                                                    <lw_factor2>-vkorg
                                                    <lw_factor2>-vtweg
                                                    <lw_factor2>-kschl
                                                     'W' " Warranty Price
                                            CHANGING lv_price_w.
              CLEAR lt_varkey1.
              READ TABLE lt_inforec_w2 ASSIGNING FIELD-SYMBOL(<fs_inforec_w2>) WITH KEY matnr = <fs_02>-ac_delco
                                                                                vkorg = <lw_factor2>-vkorg
                                                                                vtweg = <lw_factor2>-vtweg
                                                                                kschl = <lw_factor2>-kschl.
              IF sy-subrc = 0.
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor2>-vkorg
                                      vtweg = <lw_factor2>-vtweg
                                      kschl = <lw_factor2>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  <fs_inforec_w2>-vkorg <fs_inforec_w2>-vtweg ls_factor-spart ls_factor-aufart <fs_inforec_w2>-matnr  INTO lt_varkey1.
                  tb_oper     = '004'.
                  cond_usage  =  'A'.
                  table_no    = '900'.
                  tb_kappl    = 'V'.
                  tb_KSCHL    = <lw_factor2>-kschl.
                  tb_DATBI    = <fs_inforec_w2>-datbi.
                  tb_DATAB    = <fs_inforec_w2>-datab.
                  tb_KNUMH    = <fs_inforec_w2>-knumh.
                  tb_KOPOS    = <fs_inforec_w2>-kopos.
                  tb_meins    = <fs_inforec_w2>-meins.
                  tb_kpein    = <fs_inforec_w2>-kpein.
                  tb_stfkz    = <fs_inforec_w2>-Stfkz.
                  tb_krech    = <fs_inforec_w2>-krech.
                  tb_kstbm    = <fs_inforec_w2>-kstbm.
                  tb_kmein    = <fs_inforec_w2>-kmein.
                  tb_kumza    = <fs_inforec_w2>-kumza.
                  tb_kumne    = <fs_inforec_w2>-kumne.
                  tb_curr     = <fs_02>-ac_waers.
                  tb_curr_iso = <fs_02>-ac_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.
                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ELSE."--------------------------------------------------
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor2>-vkorg
                                      vtweg = <lw_factor2>-vtweg
                                      kschl = <lw_factor2>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  ls_factor-vkorg ls_factor-vtweg ls_factor-spart ls_factor-aufart <fs_02>-ac_delco  INTO lt_varkey1.
                  tb_oper    = '009'.
                  cond_usage =  'A'.
                  table_no   = '900'.
                  tb_kappl   = 'V'.
                  tb_KSCHL   = <lw_factor2>-kschl.
                  tb_DATBI   = '99991231' .
                  tb_DATAB   = sy-datum.
                  tb_KNUMH   = '$000000001' .
                  tb_KOPOS    = '01' ."<fs_inforec>-kopos.
                  tb_meins   = 'EA'.
                  tb_curr     = <fs_02>-ac_waers.
                  tb_curr_iso = <fs_02>-ac_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.
                  tb_kpein    = '1'.
                  tb_kmein    = 'EA'.
                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.


*
*      SELECT * FROM zmm_pc_autho  WHERE category = 'AC'
*                                           AND uname = @sy-uname
*                                           AND werks IS NOT INITIAL
*                                         INTO TABLE @DATA(lt_autho_ac).
*      SELECT * FROM zmm_ac INTO TABLE lt_zmm_ac WHERE ac_matnr IN s_matnr.
*
*      IF lt_autho_ac IS NOT INITIAL.
*        LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat2>).
*          IF <mat2>-low+0(2) NE 'AC' AND <mat2>-low IS NOT INITIAL.
*            CONCATENATE 'AC' <mat2>-low INTO <mat2>-low.
*          ENDIF.
*          IF <mat2>-high+0(2) NE 'AC' AND <mat2>-high IS NOT INITIAL.
*            CONCATENATE 'AC' <mat2>-high INTO <mat2>-high.
*          ENDIF.
*        ENDLOOP.
*        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
*          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
*          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec2) FOR ALL ENTRIES IN @lt_autho_ac
*          WHERE a~kappl = 'V' AND a~kschl = @lt_autho_ac-kschl AND a~vkorg = @lt_autho_ac-vkorg AND a~matnr IN @s_matnr
*            AND a~vtweg = @lt_autho_ac-vtweg  AND b~loevm_ko NE 'X'.
*      ENDIF.
*
*      LOOP AT lt_zmm_ac ASSIGNING FIELD-SYMBOL(<fs_ac>).
*        IF <fs_ac>-ac_matnr+0(2) NE 'AC'.
*          CONCATENATE 'AC' <fs_ac>-ac_matnr INTO <fs_ac>-ac_matnr.
*        ENDIF.
*        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_ac>-ac_matnr.
*        IF sy-subrc = 0.
*          LOOP AT lt_autho_ac ASSIGNING FIELD-SYMBOL(<lw_autho_ac>).
*            IF <lw_autho_ac>-kschl IS INITIAL.
*              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
*              CONTINUE.
*            ENDIF.
*            READ TABLE lt_inforec2 ASSIGNING FIELD-SYMBOL(<fs_inforec2>) WITH KEY  matnr = <fs_ac>-ac_matnr
*                                                                                vkorg = <lw_autho_ac>-vkorg
*                                                                                vtweg = <lw_autho_ac>-vtweg
*                                                                                kschl = <lw_autho_ac>-kschl.
*            IF sy-subrc = 0.
*              CLEAR : lt_ct,lt_hd,lt_it,lt_bapiret2,lt_knumhs,lt_varkey1.
*              CONCATENATE  <fs_inforec2>-vkorg <fs_inforec2>-vtweg <fs_inforec2>-matnr  INTO lt_varkey1.
*              lt_ct = VALUE #( ( operation  = '004'
*                                 cond_usage = 'A'
*                                 table_no   = '004'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_ac>-kschl
*                                 varkey     = lt_varkey1
*                                 valid_to   = <fs_inforec2>-datbi
*                                 valid_from = <fs_inforec2>-datab
*                                 cond_no    = <fs_inforec2>-knumh ) ).
*              lt_hd = VALUE #( ( operation  = '004'
*                                 cond_no    = <fs_inforec2>-knumh
*                                 cond_usage = 'A'
*                                 table_no   = '004'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_ac>-kschl
*                                 varkey     = lt_varkey1
*                                 valid_from = <fs_inforec2>-datab
*                                 valid_to   = <fs_inforec2>-datbi ) ).
*              lt_it = VALUE #( ( operation  = '004'
*                                 cond_no    = <fs_inforec2>-knumh
*                                 cond_count =  <fs_inforec2>-kopos
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_ac>-kschl
*                                 cond_value =  <fs_ac>-ac_price
*                                 base_uom   = <fs_inforec2>-meins
*                                 cond_p_unt = <fs_inforec2>-kpein
*                                 scaletype  = <fs_inforec2>-Stfkz
*                                 calctypcon = <fs_inforec2>-krech
*                                 scale_qty  = <fs_inforec2>-kstbm
*                                 cond_unit  =  <fs_inforec2>-kmein
*                                 numconvert = <fs_inforec2>-kumza
*                                 denominato = <fs_inforec2>-kumne
*                                 condcurr   = <fs_ac>-ac_waers
*                                 cond_iso   = <fs_ac>-ac_waers  ) ).
*              INCLUDE zmm_pc_info_sub2.
*            ELSE."--------------------------------------------------
*              CLEAR : lt_ct,lt_hd,lt_it,lt_bapiret2,lt_knumhs,lt_varkey1.
*              CONCATENATE  <lw_autho_ac>-vkorg <lw_autho_ac>-vtweg <fs_ac>-ac_matnr  INTO lt_varkey1.
*              lt_ct = VALUE #( ( operation  = '009'
*                                 cond_usage = 'A'
*                                 table_no   = '004'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_ac>-kschl
*                                 varkey     = lt_varkey1
*                                 valid_to   = '99991231'
*                                 valid_from = sy-datum
*                                 cond_no    = '$000000001' "<fs_inforec>-knumh
*                                  ) ).
*              lt_hd = VALUE #( ( operation  = '009'
*                                 cond_no    = '$000000001'
*                                 cond_usage = 'A'
*                                 table_no   = '004'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_ac>-kschl
*                                 varkey     = lt_varkey1
*                                 valid_from = sy-datum
*                                 valid_to   = '99991231' ) ).
*              lt_it = VALUE #( ( operation  = '009'
*                                 cond_no    = '$000000001'
*                                 cond_count =  '01'
*                                 applicatio = 'V'
*                                 cond_type  = <lw_autho_ac>-kschl
*                                 cond_value =  <fs_ac>-ac_price
*                                 base_uom   = 'EA' "<fs_inforec>-meins
*                                 condcurr   = <fs_ac>-ac_waers
*                                 cond_iso   = <fs_ac>-ac_waers  ) ).
*              INCLUDE zmm_pc_info_sub2.
*            ENDIF.
*          ENDLOOP.
*        ENDIF.
*      ENDLOOP.



    ELSEIF p_df = 'X'.  "-------------------------------------------------------------------------------------
      SELECT * FROM zmm_df INTO TABLE lt_zmm_df WHERE df_matnr IN s_matnr.

      IF lt_factor IS NOT INITIAL.
        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'DF' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'DF' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'DF' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'DF' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.
*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec3) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w3) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.

      LOOP AT lt_zmm_df ASSIGNING FIELD-SYMBOL(<fs_03>).
        IF <fs_03>-df_matnr+0(2) NE 'DF'.
          CONCATENATE 'DF' <fs_03>-df_matnr INTO <fs_03>-df_matnr.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_03>-df_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor3>).
            IF <lw_factor3>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
              CONTINUE.
            ENDIF.
            CLEAR :lv_price_s, lv_price_w.



            IF <lw_factor3>-kschl = 'YP01'.
              PERFORM get_price TABLES lt_factor USING <fs_03>-df_price
                                                   '' " ' <fs_03>-df_cour_surc
                                                     <lw_factor3>-vkorg
                                                     <lw_factor3>-vtweg
                                                     <lw_factor3>-kschl
                                                      'S' " Selling price
                                             CHANGING lv_price_s.
              READ TABLE lt_inforec ASSIGNING FIELD-SYMBOL(<fs_inforec3>) WITH KEY matnr = <fs_03>-df_matnr
                                                                                  vkorg = <lw_factor3>-vkorg
                                                                                  vtweg = <lw_factor3>-vtweg
                                                                                  kschl = <lw_factor3>-kschl.
              IF sy-subrc = 0.
                CONCATENATE  <fs_inforec3>-vkorg <fs_inforec3>-vtweg <fs_inforec3>-matnr  INTO lt_varkey1.
                tb_oper     = '004'.
                cond_usage  =  'A'.
                table_no    = '004'.
                tb_kappl    = 'V'.
                tb_KSCHL    = <lw_factor3>-kschl.
                tb_DATBI    = <fs_inforec3>-datbi.
                tb_DATAB    = <fs_inforec3>-datab.
                tb_KNUMH    = <fs_inforec3>-knumh.
                tb_KOPOS    = <fs_inforec3>-kopos.
                tb_meins    = <fs_inforec3>-meins.
                tb_kpein    = <fs_inforec3>-kpein.
                tb_stfkz    = <fs_inforec3>-Stfkz.
                tb_krech    = <fs_inforec3>-krech.
                tb_kstbm    = <fs_inforec3>-kstbm.
                tb_kmein    = <fs_inforec3>-kmein.
                tb_kumza    = <fs_inforec3>-kumza.
                tb_kumne    = <fs_inforec3>-kumne.
                tb_curr     = <fs_03>-df_waers.
                tb_curr_iso = <fs_03>-df_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.
                INCLUDE zmm_pc_info_sub2.

              ELSE."--------------------------------------------------
                CONCATENATE  <lw_factor3>-vkorg <lw_factor3>-vtweg <fs_03>-df_matnr  INTO lt_varkey1.
                tb_oper    = '009'.
                cond_usage =  'A'.
                table_no   = '004'.
                tb_kappl   = 'V'.
                tb_KSCHL   = <lw_factor3>-kschl.
                tb_DATBI   = '99991231' .
                tb_DATAB   = sy-datum.
                tb_KNUMH   = '$000000001' .
                tb_KOPOS    = '01' ."<fs_inforec3>-kopos.
                tb_meins   = 'EA'.
                tb_curr     = <fs_03>-df_waers.
                tb_curr_iso = <fs_03>-df_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.
                tb_kpein    = '1'.
                tb_kmein    = 'EA'.
                INCLUDE zmm_pc_info_sub2.
              ENDIF.
            ENDIF.
*            for warranty price
            IF <lw_factor3>-kschl = 'YWP1'.
              PERFORM get_price TABLES lt_factor USING <fs_03>-df_price
                                                   '' " <fs_03>-df_cour_surc
                                                    <lw_factor3>-vkorg
                                                    <lw_factor3>-vtweg
                                                    <lw_factor3>-kschl
                                                     'W' " Warranty Price
                                            CHANGING lv_price_w.
              CLEAR lt_varkey1.
              READ TABLE lt_inforec_w ASSIGNING FIELD-SYMBOL(<fs_inforec_w3>) WITH KEY matnr = <fs_03>-df_matnr
                                                                                vkorg = <lw_factor3>-vkorg
                                                                                vtweg = <lw_factor3>-vtweg
                                                                                kschl = <lw_factor3>-kschl.
              IF sy-subrc = 0.
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor3>-vkorg
                                      vtweg = <lw_factor3>-vtweg
                                      kschl = <lw_factor3>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  <fs_inforec_w3>-vkorg <fs_inforec_w3>-vtweg ls_factor-spart ls_factor-aufart <fs_inforec_w3>-matnr  INTO lt_varkey1.
                  tb_oper     = '004'.
                  cond_usage  =  'A'.
                  table_no    = '900'.
                  tb_kappl    = 'V'.
                  tb_KSCHL    = <lw_factor3>-kschl.
                  tb_DATBI    = <fs_inforec_w3>-datbi.
                  tb_DATAB    = <fs_inforec_w3>-datab.
                  tb_KNUMH    = <fs_inforec_w3>-knumh.
                  tb_KOPOS    = <fs_inforec_w3>-kopos.
                  tb_meins    = <fs_inforec_w3>-meins.
                  tb_kpein    = <fs_inforec_w3>-kpein.
                  tb_stfkz    = <fs_inforec_w3>-Stfkz.
                  tb_krech    = <fs_inforec_w3>-krech.
                  tb_kstbm    = <fs_inforec_w3>-kstbm.
                  tb_kmein    = <fs_inforec_w3>-kmein.
                  tb_kumza    = <fs_inforec_w3>-kumza.
                  tb_kumne    = <fs_inforec_w3>-kumne.
                  tb_curr     = <fs_03>-df_waers.
                  tb_curr_iso = <fs_03>-df_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.
                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ELSE."--------------------------------------------------
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor3>-vkorg
                                      vtweg = <lw_factor3>-vtweg
                                      kschl = <lw_factor3>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  ls_factor-vkorg ls_factor-vtweg ls_factor-spart ls_factor-aufart <fs_03>-df_matnr  INTO lt_varkey1.
                  tb_oper    = '009'.
                  cond_usage =  'A'.
                  table_no   = '900'.
                  tb_kappl   = 'V'.
                  tb_KSCHL   = <lw_factor3>-kschl.
                  tb_DATBI   = '99991231' .
                  tb_DATAB   = sy-datum.
                  tb_KNUMH   = '$000000001' .
                  tb_KOPOS    = '01' ."<fs_inforec3>-kopos.
                  tb_meins   = 'EA'.
                  tb_curr     = <fs_03>-df_waers.
                  tb_curr_iso = <fs_03>-df_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.
                  tb_kpein    = '1'.
                  tb_kmein    = 'EA'.
                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

    ELSEIF p_ma = 'X'.  "-------------------------------------------------------------------------------------

      SELECT * FROM zmm_ma INTO TABLE lt_zmm_ma WHERE ma_matnr IN s_matnr.

      IF lt_factor IS NOT INITIAL.
        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'MS' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'MS' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'MS' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'MS' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.
*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec4) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w4) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.

      LOOP AT lt_zmm_ma ASSIGNING FIELD-SYMBOL(<fs_04>).
        IF <fs_04>-ma_matnr+0(2) NE 'MS'.
          CONCATENATE 'MS' <fs_04>-ma_matnr INTO <fs_04>-ma_matnr.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_04>-ma_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor4>).
            IF <lw_factor4>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
              CONTINUE.
            ENDIF.
            CLEAR :lv_price_s, lv_price_w.



            IF <lw_factor4>-kschl = 'YP01'.
              PERFORM get_price TABLES lt_factor USING <fs_04>-ma_price
                                                   '' " ' <fs_04>-ma_cour_surc
                                                     <lw_factor4>-vkorg
                                                     <lw_factor4>-vtweg
                                                     <lw_factor4>-kschl
                                                      'S' " Selling price
                                             CHANGING lv_price_s.
              READ TABLE lt_inforec ASSIGNING FIELD-SYMBOL(<fs_inforec4>) WITH KEY matnr = <fs_04>-ma_matnr
                                                                                  vkorg = <lw_factor4>-vkorg
                                                                                  vtweg = <lw_factor4>-vtweg
                                                                                  kschl = <lw_factor4>-kschl.
              IF sy-subrc = 0.
                CONCATENATE  <fs_inforec4>-vkorg <fs_inforec4>-vtweg <fs_inforec4>-matnr  INTO lt_varkey1.
                tb_oper     = '004'.
                cond_usage  =  'A'.
                table_no    = '004'.
                tb_kappl    = 'V'.
                tb_KSCHL    = <lw_factor4>-kschl.
                tb_DATBI    = <fs_inforec4>-datbi.
                tb_DATAB    = <fs_inforec4>-datab.
                tb_KNUMH    = <fs_inforec4>-knumh.
                tb_KOPOS    = <fs_inforec4>-kopos.
                tb_meins    = <fs_inforec4>-meins.
                tb_kpein    = <fs_inforec4>-kpein.
                tb_stfkz    = <fs_inforec4>-Stfkz.
                tb_krech    = <fs_inforec4>-krech.
                tb_kstbm    = <fs_inforec4>-kstbm.
                tb_kmein    = <fs_inforec4>-kmein.
                tb_kumza    = <fs_inforec4>-kumza.
                tb_kumne    = <fs_inforec4>-kumne.
                tb_curr     = <fs_04>-ma_waers.
                tb_curr_iso = <fs_04>-ma_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.
                INCLUDE zmm_pc_info_sub2.

              ELSE."--------------------------------------------------
                CONCATENATE  <lw_factor4>-vkorg <lw_factor4>-vtweg <fs_04>-ma_matnr  INTO lt_varkey1.
                tb_oper    = '009'.
                cond_usage =  'A'.
                table_no   = '004'.
                tb_kappl   = 'V'.
                tb_KSCHL   = <lw_factor4>-kschl.
                tb_DATBI   = '99991231' .
                tb_DATAB   = sy-datum.
                tb_KNUMH   = '$000000001' .
                tb_KOPOS    = '01' ."<fs_inforec4>-kopos.
                tb_meins   = 'EA'.
                tb_curr     = <fs_04>-ma_waers.
                tb_curr_iso = <fs_04>-ma_waers.
                tb_var      = lt_varkey1.
                tb_price    = lv_price_s.
                tb_kpein    = '1'.
                tb_kmein    = 'EA'.
                INCLUDE zmm_pc_info_sub2.
              ENDIF.
            ENDIF.
*            for warranty price
            IF <lw_factor4>-kschl = 'YWP1'.
              PERFORM get_price TABLES lt_factor USING <fs_04>-ma_price
                                                   '' " <fs_04>-ma_cour_surc
                                                    <lw_factor4>-vkorg
                                                    <lw_factor4>-vtweg
                                                    <lw_factor4>-kschl
                                                     'W' " Warranty Price
                                            CHANGING lv_price_w.
              CLEAR lt_varkey1.
              READ TABLE lt_inforec_w ASSIGNING FIELD-SYMBOL(<fs_inforec_w4>) WITH KEY matnr = <fs_04>-ma_matnr
                                                                                vkorg = <lw_factor4>-vkorg
                                                                                vtweg = <lw_factor4>-vtweg
                                                                                kschl = <lw_factor4>-kschl.
              IF sy-subrc = 0.
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor4>-vkorg
                                      vtweg = <lw_factor4>-vtweg
                                      kschl = <lw_factor4>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  <fs_inforec_w4>-vkorg <fs_inforec_w4>-vtweg ls_factor-spart ls_factor-aufart <fs_inforec_w4>-matnr  INTO lt_varkey1.
                  tb_oper     = '004'.
                  cond_usage  =  'A'.
                  table_no    = '900'.
                  tb_kappl    = 'V'.
                  tb_KSCHL    = <lw_factor4>-kschl.
                  tb_DATBI    = <fs_inforec_w4>-datbi.
                  tb_DATAB    = <fs_inforec_w4>-datab.
                  tb_KNUMH    = <fs_inforec_w4>-knumh.
                  tb_KOPOS    = <fs_inforec_w4>-kopos.
                  tb_meins    = <fs_inforec_w4>-meins.
                  tb_kpein    = <fs_inforec_w4>-kpein.
                  tb_stfkz    = <fs_inforec_w4>-Stfkz.
                  tb_krech    = <fs_inforec_w4>-krech.
                  tb_kstbm    = <fs_inforec_w4>-kstbm.
                  tb_kmein    = <fs_inforec_w4>-kmein.
                  tb_kumza    = <fs_inforec_w4>-kumza.
                  tb_kumne    = <fs_inforec_w4>-kumne.
                  tb_curr     = <fs_04>-ma_waers.
                  tb_curr_iso = <fs_04>-ma_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.
                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ELSE."--------------------------------------------------
                CLEAR ls_factor.
                READ TABLE lt_factor INTO ls_factor
                             WITH KEY vkorg = <lw_factor4>-vkorg
                                      vtweg = <lw_factor4>-vtweg
                                      kschl = <lw_factor4>-kschl
                                      cond_cat = 'W'. "p_cond_cat'.  "'S'.
                IF sy-subrc = 0.
                  CONCATENATE  ls_factor-vkorg ls_factor-vtweg ls_factor-spart ls_factor-aufart <fs_04>-ma_matnr  INTO lt_varkey1.
                  tb_oper    = '009'.
                  cond_usage =  'A'.
                  table_no   = '900'.
                  tb_kappl   = 'V'.
                  tb_KSCHL   = <lw_factor4>-kschl.
                  tb_DATBI   = '99991231' .
                  tb_DATAB   = sy-datum.
                  tb_KNUMH   = '$000000001' .
                  tb_KOPOS    = '01' ."<fs_inforec4>-kopos.
                  tb_meins   = 'EA'.
                  tb_curr     = <fs_04>-ma_waers.
                  tb_curr_iso = <fs_04>-ma_waers.
                  tb_var      = lt_varkey1.
                  tb_price    = lv_price_w.
                  tb_kpein    = '1'.
                  tb_kmein    = 'EA'.
                  INCLUDE zmm_pc_info_sub2.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

    ENDIF.
*------------------------------------------------------------------------------------------------------------------
    LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat_1>).
      <mat_1>-low = <mat_1>-low+2(38).
      <mat_1>-high = <mat_1>-high+2(38).
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
  ENDIF.




ENDFORM.



FORM get_price  TABLES   p_lt_factor STRUCTURE zmm_pc_factor
                USING    p_price
                         p_price1
                         p_vkorg
                         p_vtweg
                         p_kschl
                         p_cond_cat
                CHANGING p_lv_price.
*  in this program condition catagory is selling price only
  READ TABLE p_lt_factor  ASSIGNING FIELD-SYMBOL(<factor>)
                               WITH KEY vkorg = p_vkorg
                                        vtweg = p_vtweg
                                        kschl = p_kschl
                                        cond_cat = p_cond_cat.  "'S'.
  IF sy-subrc = 0.
    IF <factor>-core_per IS NOT INITIAL.
      p_lv_price = ( p_price  * <factor>-factor ) + p_price1 + (  ( p_price1 * <factor>-core_per ) / 100 ).

    ELSE.
      p_lv_price = ( p_price + p_price1 ) * <factor>-factor.

    ENDIF.

  ELSE.
    p_lv_price = p_price.
  ENDIF.

ENDFORM.

FORM update_table  USING    p_tb_oper
                            p_cond_usage
                            p_table_no
                            p_tb_kappl
                            p_tb_kscha
                            p_tb_datbi
                            p_tb_datab
                            p_tb_knumh
                            p_tb_kopos
                            p_tb_meins
                            p_tb_kpein
                            p_tb_stfkz
                            p_tb_krech
                            p_tb_kstbm
                            p_tb_kmein
                            p_tb_kumza
                            p_tb_kumne
                            p_tb_curr
                            p_tb_curr_iso.





ENDFORM.

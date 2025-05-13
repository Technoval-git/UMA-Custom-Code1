*----------------------------------------------------------------------*
***INCLUDE ZMM_PC_PRICECOMPARE.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zmm_pc_pricecompare
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zmm_pc_pricecompare .


  DATA: ltt_return TYPE TABLE OF bapiret2,
        lt_zmm_gm  TYPE STANDARD TABLE OF zmm_gm,
        lt_zmm_hq  TYPE STANDARD TABLE OF zmm_hq,
        lt_zmm_ac  TYPE STANDARD TABLE OF zmm_ac,
        lt_zmm_df  TYPE STANDARD TABLE OF zmm_df,
        lt_zmm_ma  TYPE STANDARD TABLE OF zmm_ma,
        lv_matnr   TYPE matnr,
        lv_matkl   TYPE matkl,
        lv_maktx   TYPE maktx.

*
  DATA lw_PRICECOMP TYPE zmm_pc_pricecomp.
  DATA lt_pricecomp TYPE STANDARD TABLE OF zmm_pc_pricecomp.
  DATA :lt_factor TYPE STANDARD TABLE OF zmm_pc_factor,
        ls_factor TYPE zmm_pc_factor.
  DATA lv_price TYPE netpr.
  DATA lv_cat TYPE zmm_brand.
  DATA:lv_price_s TYPE netpr, " selling price
       lv_price_w TYPE netpr.  " warranty price

  IF p_gm = 'X'.
    lv_cat = 'GM'.
  ELSEIF  p_ac = 'X'.
    lv_cat = 'AC'.
  ELSEIF  p_HQ = 'X'.
    lv_cat = 'HQ'.
  ELSEIF  p_df = 'X'.
    lv_cat = 'DF'.
  ELSEIF  p_MA = 'X'.
    lv_cat = 'MS'.
  ENDIF.

*  *Need to select all data
  SELECT * FROM zmm_pc_factor INTO TABLE lt_factor WHERE brand = lv_cat.

  IF s_matnr[] IS NOT INITIAL.
    IF p_gm = 'X'. "-------------------------------------------------------------------------------

      SELECT * FROM zmm_pc_autho  WHERE category = 'GM'
                                      AND uname = @sy-uname
                                      AND werks IS NOT INITIAL
                                    INTO TABLE @DATA(lt_autho_gm).
      SELECT * FROM zmm_gm INTO TABLE lt_zmm_gm WHERE gm_matnr IN s_matnr.

      IF lt_autho_gm IS NOT INITIAL.
        LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat>).
          IF <mat>-low+0(2) NE 'GM' AND <mat>-low IS NOT INITIAL.
            CONCATENATE 'GM' <mat>-low INTO <mat>-low.
          ENDIF.
          IF <mat>-high+0(2) NE 'GM' AND <mat>-high IS NOT INITIAL.
            CONCATENATE 'GM' <mat>-high INTO <mat>-high.
          ENDIF.
        ENDLOOP.
*        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
*          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
*          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_v) FOR ALL ENTRIES IN @lt_autho_gm
*          WHERE a~kappl = 'V' AND a~kschl = @lt_autho_gm-kschl AND a~vkorg = @lt_autho_gm-vkorg AND a~matnr IN @s_matnr
*            AND a~vtweg = @lt_autho_gm-vtweg  AND b~loevm_ko NE 'X'.

        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
       b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
       ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_p) FOR ALL ENTRIES IN @lt_autho_gm
       WHERE a~kappl = 'M' AND a~kschl = @lt_autho_gm-kschl AND a~lifnr = @lt_autho_gm-lifnr AND a~matnr IN @s_matnr
         AND a~ekorg = @lt_autho_gm-ekorg AND a~werks = @lt_autho_gm-werks AND b~loevm_ko NE 'X'.


*        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg,a~spart, a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
*         b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
*         ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_W) FOR ALL ENTRIES IN @lt_autho_gm
*         WHERE a~kappl = 'V' AND a~kschl = 'YWP1'  AND a~vkorg = @lt_autho_gm-vkorg AND a~matnr IN @s_matnr
*           AND a~vtweg = @lt_autho_gm-vtweg  AND b~loevm_ko NE 'X'.
      ENDIF.

      IF lt_factor IS NOT INITIAL.

*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_v) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.
*
      LOOP AT lt_zmm_gm ASSIGNING FIELD-SYMBOL(<fs_11>).
        IF <fs_11>-gm_matnr+0(2) NE 'GM'.
          CONCATENATE 'GM' <fs_11>-gm_matnr INTO <fs_11>-gm_matnr.
        ENDIF.
        SELECT SINGLE matnr matkl  INTO ( lv_matnr, lv_matkl ) FROM mara WHERE matnr =   <fs_11>-gm_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_autho_gm ASSIGNING FIELD-SYMBOL(<lw_autho_gm>).
            IF <lw_autho_gm>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.

            lw_PRICECOMP-matnr = <fs_11>-gm_matnr.

            lw_PRICECOMP-werks      = <lw_autho_gm>-werks.

            lw_PRICECOMP-maktx      = <fs_11>-gm_maktx.
            lw_PRICECOMP-matkl      = lv_matkl.
            lw_PRICECOMP-extwg      = <fs_11>-gm_extwg.
*            READ TABLE lt_inforec_v ASSIGNING FIELD-SYMBOL(<fs_inforec>) WITH KEY matnr = <fs_gm>-gm_matnr
*                                                                                vkorg = <lw_autho_gm>-vkorg
*                                                                                vtweg = <lw_autho_gm>-vtweg
*                                                                                kschl = 'YP01'.
*            IF sy-subrc = 0.
*              CLEAR lv_price.
*              PERFORM get_price TABLES lt_factor
*                                USING <fs_gm>-gm_price
*                                     <fs_gm>-gm_cour_surc
*                                     <lw_autho_gm>-vkorg
*                                     <lw_autho_gm>-vtweg
*                                      'YP01'  " Hard coded since this program is for selling price only  <lw_autho_gm>-kschl
*                                      'S'  " Condition catagory 'S'  Selling price
*                                CHANGING lv_price.
**              lw_PRICECOMP-matnr = <fs_inforec>-matnr.
*              lw_PRICECOMP-werks = <lw_autho_gm>-werks.
*              lw_PRICECOMP-curr_sel =  <fs_inforec>-kbetr.
*              lw_PRICECOMP-future_sel = lv_price. "<fs_gm>-gm_price.    " Apply formula
*              lw_PRICECOMP-maktx = <fs_gm>-gm_maktx.
*              lw_PRICECOMP-matkl = lv_matkl.
*              lw_PRICECOMP-extwg = <fs_gm>-gm_extwg.
*            ENDIF.
*
            READ TABLE lt_inforec_p ASSIGNING FIELD-SYMBOL(<fs_inforec_p>) WITH KEY matnr = <fs_11>-gm_matnr
                                                                              lifnr = <lw_autho_gm>-lifnr
                                                                              ekorg = <lw_autho_gm>-ekorg
                                                                              werks = <lw_autho_gm>-werks
                                                                              kschl = 'YP01'.
            IF sy-subrc = 0.
              lw_PRICECOMP-curr_pur =  <fs_inforec_p>-kbetr.
              lw_PRICECOMP-future_pur =   <fs_11>-gm_price.
            ENDIF.
*            READ TABLE lt_inforec_W ASSIGNING FIELD-SYMBOL(<fs_inforec1>) WITH KEY matnr = <fs_gm>-gm_matnr
*                                                                                vkorg = <lw_autho_gm>-vkorg
*                                                                                vtweg = <lw_autho_gm>-vtweg
*                                                                                kschl = 'YWP1'.
*            IF sy-subrc = 0.
*              CLEAR lv_price.
*              PERFORM get_price1 TABLES lt_factor
*                                USING <fs_gm>-gm_price
*                                     <fs_gm>-gm_cour_surc
*                                     <lw_autho_gm>-vkorg
*                                     <lw_autho_gm>-vtweg
*                                     <fs_inforec1>-aufart
*                                      'YWP1'  " Hard coded since this program is for selling price only  <lw_autho_gm>-kschl
*                                      'W'  " Condition catagory 'S'  Selling price
*                                CHANGING lv_price.
*              lw_PRICECOMP-curr_war = <fs_inforec1>-kbetr.
*              lw_PRICECOMP-future_war = lv_price.   "<fs_inforec1>-kbetr. " Apply formula
*            ENDIF.

            LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor>).
              IF <lw_factor>-kschl IS INITIAL.
                MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
                CONTINUE.
              ENDIF.
              CLEAR :lv_price_s, lv_price_w.



              IF <lw_factor>-kschl = 'YP01'.
                PERFORM get_price TABLES lt_factor USING <fs_11>-gm_price
                                                       <fs_11>-gm_cour_surc
                                                       <lw_factor>-vkorg
                                                       <lw_factor>-vtweg
                                                       <lw_factor>-kschl
                                                        'S' " Selling price
                                               CHANGING lv_price_s.
                READ TABLE lt_inforec_v ASSIGNING FIELD-SYMBOL(<fs_inforec>) WITH KEY matnr = <fs_11>-gm_matnr
                                                                                    vkorg = <lw_factor>-vkorg
                                                                                    vtweg = <lw_factor>-vtweg
                                                                                    kschl = <lw_factor>-kschl.
                IF sy-subrc = 0.
*                  lw_PRICECOMP-werks      = <lw_autho_gm>-werks.
                  lw_PRICECOMP-curr_sel   =  <fs_inforec>-kbetr.
                  lw_PRICECOMP-future_sel = lv_price_s.
*                  lw_PRICECOMP-maktx      = <fs_11>-gm_maktx.
*                  lw_PRICECOMP-matkl      = lv_matkl.
*                  lw_PRICECOMP-extwg      = <fs_11>-gm_extwg.

                ENDIF.
              ENDIF.
*            for warranty price
              IF <lw_factor>-kschl = 'YWP1'.
                PERFORM get_price TABLES lt_factor USING <fs_11>-gm_price
                                                      <fs_11>-gm_cour_surc
                                                      <lw_factor>-vkorg
                                                      <lw_factor>-vtweg
                                                      <lw_factor>-kschl
                                                       'W' " Warranty Price
                                              CHANGING lv_price_w.

                READ TABLE lt_inforec_w ASSIGNING FIELD-SYMBOL(<fs_inforec_w>) WITH KEY matnr = <fs_11>-gm_matnr
                                                                                  vkorg = <lw_factor>-vkorg
                                                                                  vtweg = <lw_factor>-vtweg
                                                                                  kschl = <lw_factor>-kschl.
                IF sy-subrc = 0.
                  lw_PRICECOMP-curr_war = <fs_inforec_w>-kbetr.
                  lw_PRICECOMP-future_war = lv_price_w.
                ENDIF.
              ENDIF.
            ENDLOOP.




            IF lw_pricecomp-matnr IS NOT INITIAL.
              APPEND lw_pricecomp TO lt_pricecomp.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.



    ELSEIF p_HQ = 'X'.  "-------------------------------------------------------------------------------------

      SELECT * FROM zmm_pc_autho  WHERE category = 'HQ'
                                           AND uname = @sy-uname
                                           AND werks IS NOT INITIAL
                                         INTO TABLE @DATA(lt_autho_hq).
      SELECT * FROM zmm_hq INTO TABLE lt_zmm_hq WHERE hq_matnr IN s_matnr.

      IF lt_autho_hq IS NOT INITIAL.
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
          modify s_matnr.
        ENDLOOP.
        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
       b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
       ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_p1) FOR ALL ENTRIES IN @lt_autho_hq
       WHERE a~kappl = 'M' AND a~kschl = @lt_autho_hq-kschl AND a~lifnr = @lt_autho_hq-lifnr AND a~matnr IN @s_matnr
         AND a~ekorg = @lt_autho_hq-ekorg AND a~werks = @lt_autho_hq-werks AND b~loevm_ko NE 'X'.


      ENDIF.

      IF lt_factor IS NOT INITIAL.

*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_v1) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w1) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.
*
      LOOP AT lt_zmm_hq ASSIGNING FIELD-SYMBOL(<fs_22>).
        IF <fs_22>-hq_matnr+0(2) NE 'HQ'.
          CONCATENATE 'HQ' <fs_22>-hq_matnr INTO <fs_22>-hq_matnr.
        ENDIF.
        SELECT SINGLE matnr matkl  INTO ( lv_matnr, lv_matkl ) FROM mara WHERE matnr =   <fs_22>-hq_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_autho_hq ASSIGNING FIELD-SYMBOL(<lw_autho_hq1>).
            IF <lw_autho_hq1>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.

            lw_PRICECOMP-matnr = <fs_22>-hq_matnr.
            lw_PRICECOMP-werks      = <lw_autho_hq1>-werks.

            lw_PRICECOMP-maktx      = <fs_22>-hq_maktx.
            lw_PRICECOMP-matkl      = lv_matkl.
            lw_PRICECOMP-extwg      = ''."<fs_22>-hq_extwg.

            READ TABLE lt_inforec_p1 ASSIGNING FIELD-SYMBOL(<fs_inforec_p1>) WITH KEY matnr = <fs_22>-hq_matnr
                                                                              lifnr = <lw_autho_hq1>-lifnr
                                                                              ekorg = <lw_autho_hq1>-ekorg
                                                                              werks = <lw_autho_hq1>-werks
                                                                              kschl = 'YP01'.
            IF sy-subrc = 0.
              lw_PRICECOMP-curr_pur =  <fs_inforec_p1>-kbetr.
              lw_PRICECOMP-future_pur =   <fs_22>-hq_price.
            ENDIF.

            LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor1>).
              IF <lw_factor1>-kschl IS INITIAL.
                MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
                CONTINUE.
              ENDIF.
              CLEAR :lv_price_s, lv_price_w.



              IF <lw_factor1>-kschl = 'YP01'.
                PERFORM get_price TABLES lt_factor USING <fs_22>-hq_price
                                                      '' " <fs_22>-hq_cour_surc
                                                       <lw_factor1>-vkorg
                                                       <lw_factor1>-vtweg
                                                       <lw_factor1>-kschl
                                                        'S' " Selling price
                                               CHANGING lv_price_s.
                READ TABLE lt_inforec_v1 ASSIGNING FIELD-SYMBOL(<fs_inforec_v1>) WITH KEY matnr = <fs_22>-hq_matnr
                                                                                    vkorg = <lw_factor1>-vkorg
                                                                                    vtweg = <lw_factor1>-vtweg
                                                                                    kschl = <lw_factor1>-kschl.
                IF sy-subrc = 0.
*                  lw_PRICECOMP-werks      = <lw_autho_hq1>-werks.
                  lw_PRICECOMP-curr_sel   =  <fs_inforec_v1>-kbetr.
                  lw_PRICECOMP-future_sel = lv_price_s.
*                  lw_PRICECOMP-maktx      = <fs_22>-hq_maktx.
*                  lw_PRICECOMP-matkl      = lv_matkl.
*                  lw_PRICECOMP-extwg      = ''."<fs_22>-hq_extwg.

                ENDIF.
              ENDIF.
*            for warranty price
              IF <lw_factor1>-kschl = 'YWP1'.
                PERFORM get_price TABLES lt_factor USING <fs_22>-hq_price
                                                     '' " <fs_22>-hq_cour_surc
                                                      <lw_factor1>-vkorg
                                                      <lw_factor1>-vtweg
                                                      <lw_factor1>-kschl
                                                       'W' " Warranty Price
                                              CHANGING lv_price_w.

                READ TABLE lt_inforec_w1 ASSIGNING FIELD-SYMBOL(<fs_inforec_w1>) WITH KEY matnr = <fs_22>-hq_matnr
                                                                                  vkorg = <lw_factor1>-vkorg
                                                                                  vtweg = <lw_factor1>-vtweg
                                                                                  kschl = <lw_factor1>-kschl.
                IF sy-subrc = 0.
                  lw_PRICECOMP-curr_war = <fs_inforec_w1>-kbetr.
                  lw_PRICECOMP-future_war = lv_price_w.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF lw_pricecomp-matnr IS NOT INITIAL.
              APPEND lw_pricecomp TO lt_pricecomp.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

    ELSEIF p_ac = 'X'. "---------------------------------------------------------------------------------------------------

      SELECT * FROM zmm_pc_autho  WHERE category = 'AC'
                                            AND uname = @sy-uname
                                            AND werks IS NOT INITIAL
                                          INTO TABLE @DATA(lt_autho_ac1).
      SELECT * FROM zmm_ac INTO TABLE lt_zmm_ac WHERE ac_delco IN s_matnr.

      IF lt_autho_ac1 IS NOT INITIAL.
        LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat2>).
          IF <mat2>-low+0(2) NE 'AC' AND <mat2>-low IS NOT INITIAL.
            CONCATENATE 'AC' <mat2>-low INTO <mat2>-low.
          ENDIF.
          IF <mat2>-high+0(2) NE 'AC' AND <mat2>-high IS NOT INITIAL.
            CONCATENATE 'AC' <mat2>-high INTO <mat2>-high.
          ENDIF.
        ENDLOOP.

        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
       b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
       ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_p2) FOR ALL ENTRIES IN @lt_autho_ac1
       WHERE a~kappl = 'M' AND a~kschl = @lt_autho_ac1-kschl AND a~lifnr = @lt_autho_ac1-lifnr AND a~matnr IN @s_matnr
         AND a~ekorg = @lt_autho_ac1-ekorg AND a~werks = @lt_autho_ac1-werks AND b~loevm_ko NE 'X'.


      ENDIF.

      IF lt_factor IS NOT INITIAL.

*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_v2) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w2) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.
*
      LOOP AT lt_zmm_ac ASSIGNING FIELD-SYMBOL(<fs_33>).
        IF <fs_33>-ac_delco+0(2) NE 'AC'.
          CONCATENATE 'AC' <fs_33>-ac_delco INTO <fs_33>-ac_delco.
        ENDIF.
        SELECT SINGLE matnr matkl  INTO ( lv_matnr, lv_matkl ) FROM mara WHERE matnr =   <fs_33>-ac_delco.
        IF sy-subrc = 0.
          LOOP AT lt_autho_ac1 ASSIGNING FIELD-SYMBOL(<lw_autho_ac1>).
            IF <lw_autho_ac1>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.

            lw_PRICECOMP-matnr = <fs_33>-ac_delco.
            lw_PRICECOMP-werks      = <lw_autho_ac1>-werks.

            lw_PRICECOMP-maktx      = <fs_33>-ac_maktx.
            lw_PRICECOMP-matkl      = lv_matkl.
            lw_PRICECOMP-extwg      = <fs_33>-ac_extwg.
            READ TABLE lt_inforec_p2 ASSIGNING FIELD-SYMBOL(<fs_inforec_p2>) WITH KEY matnr = <fs_33>-ac_delco
                                                                              lifnr = <lw_autho_ac1>-lifnr
                                                                              ekorg = <lw_autho_ac1>-ekorg
                                                                              werks = <lw_autho_ac1>-werks
                                                                              kschl = 'YP01'.
            IF sy-subrc = 0.
              lw_PRICECOMP-curr_pur =  <fs_inforec_p2>-kbetr.
              lw_PRICECOMP-future_pur =   <fs_33>-ac_price.
            ENDIF.

            LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor2>).
              IF <lw_factor2>-kschl IS INITIAL.
                MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
                CONTINUE.
              ENDIF.
              CLEAR :lv_price_s, lv_price_w.



              IF <lw_factor2>-kschl = 'YP01'.
                PERFORM get_price TABLES lt_factor USING <fs_33>-ac_price
                                                       <fs_33>-ac_cour_surc
                                                       <lw_factor2>-vkorg
                                                       <lw_factor2>-vtweg
                                                       <lw_factor2>-kschl
                                                        'S' " Selling price
                                               CHANGING lv_price_s.
                READ TABLE lt_inforec_v2 ASSIGNING FIELD-SYMBOL(<fs_inforec_v2>) WITH KEY matnr = <fs_33>-ac_delco
                                                                                    vkorg = <lw_factor2>-vkorg
                                                                                    vtweg = <lw_factor2>-vtweg
                                                                                    kschl = <lw_factor2>-kschl.
                IF sy-subrc = 0.
*                  lw_PRICECOMP-werks      = <lw_autho_ac1>-werks.
                  lw_PRICECOMP-curr_sel   =  <fs_inforec_v2>-kbetr.
                  lw_PRICECOMP-future_sel = lv_price_s.
*                  lw_PRICECOMP-maktx      = <fs_33>-ac_maktx.
*                  lw_PRICECOMP-matkl      = lv_matkl.
*                  lw_PRICECOMP-extwg      = <fs_33>-ac_extwg.

                ENDIF.
              ENDIF.
*            for warranty price
              IF <lw_factor2>-kschl = 'YWP1'.
                PERFORM get_price TABLES lt_factor USING <fs_33>-ac_price
                                                     <fs_33>-ac_cour_surc
                                                      <lw_factor2>-vkorg
                                                      <lw_factor2>-vtweg
                                                      <lw_factor2>-kschl
                                                       'W' " Warranty Price
                                              CHANGING lv_price_w.

                READ TABLE lt_inforec_w2 ASSIGNING FIELD-SYMBOL(<fs_inforec_w2>) WITH KEY matnr = <fs_33>-ac_delco
                                                                                  vkorg = <lw_factor2>-vkorg
                                                                                  vtweg = <lw_factor2>-vtweg
                                                                                  kschl = <lw_factor2>-kschl.
                IF sy-subrc = 0.
                  lw_PRICECOMP-curr_war = <fs_inforec_w2>-kbetr.
                  lw_PRICECOMP-future_war = lv_price_w.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF lw_pricecomp-matnr IS NOT INITIAL.
              APPEND lw_pricecomp TO lt_pricecomp.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

    ELSEIF p_df = 'X'. "---------------------------------------------------------------------------------------------------

      SELECT * FROM zmm_pc_autho  WHERE category = 'DF'
                                           AND uname = @sy-uname
                                           AND werks IS NOT INITIAL
                                         INTO TABLE @DATA(lt_autho_df1).
      SELECT * FROM zmm_df INTO TABLE lt_zmm_df WHERE df_matnr IN s_matnr.

      IF lt_autho_df1 IS NOT INITIAL.
        LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat3>).
          IF <mat3>-low+0(2) NE 'DF' AND <mat3>-low IS NOT INITIAL.
            CONCATENATE 'DF' <mat3>-low INTO <mat3>-low.
          ENDIF.
          IF <mat3>-high+0(2) NE 'DF' AND <mat3>-high IS NOT INITIAL.
            CONCATENATE 'DF' <mat3>-high INTO <mat3>-high.
          ENDIF.
        ENDLOOP.

        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
       b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
       ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_p3) FOR ALL ENTRIES IN @lt_autho_df1
       WHERE a~kappl = 'M' AND a~kschl = @lt_autho_df1-kschl AND a~lifnr = @lt_autho_df1-lifnr AND a~matnr IN @s_matnr
         AND a~ekorg = @lt_autho_df1-ekorg AND a~werks = @lt_autho_df1-werks AND b~loevm_ko NE 'X'.


      ENDIF.

      IF lt_factor IS NOT INITIAL.

*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_v3) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w3) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.
*
      LOOP AT lt_zmm_df ASSIGNING FIELD-SYMBOL(<fs_44>).
        IF <fs_44>-df_matnr+0(2) NE 'DF'.
          CONCATENATE 'DF' <fs_44>-df_matnr INTO <fs_44>-df_matnr.
        ENDIF.
        SELECT SINGLE matnr matkl  INTO ( lv_matnr, lv_matkl ) FROM mara WHERE matnr =   <fs_44>-df_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_autho_df1 ASSIGNING FIELD-SYMBOL(<lw_autho_df1>).
            IF <lw_autho_df1>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.

            lw_PRICECOMP-matnr = <fs_44>-df_matnr.

            lw_PRICECOMP-werks      = <lw_autho_df1>-werks.

            lw_PRICECOMP-maktx      = <fs_44>-df_maktx.
            lw_PRICECOMP-matkl      = lv_matkl.
            lw_PRICECOMP-extwg      = ''."<fs_44>-df_extwg.


            READ TABLE lt_inforec_p3 ASSIGNING FIELD-SYMBOL(<fs_inforec_p3>) WITH KEY matnr = <fs_44>-df_matnr
                                                                              lifnr = <lw_autho_df1>-lifnr
                                                                              ekorg = <lw_autho_df1>-ekorg
                                                                              werks = <lw_autho_df1>-werks
                                                                              kschl = 'YP01'.
            IF sy-subrc = 0.
              lw_PRICECOMP-curr_pur =  <fs_inforec_p3>-kbetr.
              lw_PRICECOMP-future_pur =   <fs_44>-df_price.
            ENDIF.

            LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor3>).
              IF <lw_factor3>-kschl IS INITIAL.
                MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
                CONTINUE.
              ENDIF.
              CLEAR :lv_price_s, lv_price_w.



              IF <lw_factor3>-kschl = 'YP01'.
                PERFORM get_price TABLES lt_factor USING <fs_44>-df_price
                                                      '' " <fs_44>-df_cour_surc
                                                       <lw_factor3>-vkorg
                                                       <lw_factor3>-vtweg
                                                       <lw_factor3>-kschl
                                                        'S' " Selling price
                                               CHANGING lv_price_s.
                READ TABLE lt_inforec_v3 ASSIGNING FIELD-SYMBOL(<fs_inforec_v3>) WITH KEY matnr = <fs_44>-df_matnr
                                                                                    vkorg = <lw_factor3>-vkorg
                                                                                    vtweg = <lw_factor3>-vtweg
                                                                                    kschl = <lw_factor3>-kschl.
                IF sy-subrc = 0.
*                  lw_PRICECOMP-werks      = <lw_autho_df1>-werks.
                  lw_PRICECOMP-curr_sel   =  <fs_inforec_v3>-kbetr.
                  lw_PRICECOMP-future_sel = lv_price_s.
*                  lw_PRICECOMP-maktx      = <fs_44>-df_maktx.
*                  lw_PRICECOMP-matkl      = lv_matkl.
*                  lw_PRICECOMP-extwg      = ''."<fs_44>-df_extwg.

                ENDIF.
              ENDIF.
*            for warranty price
              IF <lw_factor3>-kschl = 'YWP1'.
                PERFORM get_price TABLES lt_factor USING <fs_44>-df_price
                                                     '' " <fs_44>-df_cour_surc
                                                      <lw_factor3>-vkorg
                                                      <lw_factor3>-vtweg
                                                      <lw_factor3>-kschl
                                                       'W' " Warranty Price
                                              CHANGING lv_price_w.

                READ TABLE lt_inforec_w3 ASSIGNING FIELD-SYMBOL(<fs_inforec_w3>) WITH KEY matnr = <fs_44>-df_matnr
                                                                                  vkorg = <lw_factor3>-vkorg
                                                                                  vtweg = <lw_factor3>-vtweg
                                                                                  kschl = <lw_factor3>-kschl.
                IF sy-subrc = 0.
                  lw_PRICECOMP-curr_war = <fs_inforec_w3>-kbetr.
                  lw_PRICECOMP-future_war = lv_price_w.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF lw_pricecomp-matnr IS NOT INITIAL.
              APPEND lw_pricecomp TO lt_pricecomp.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

    ELSEIF p_ma = 'X'. "---------------------------------------------------------------------------------------------------

      SELECT * FROM zmm_pc_autho  WHERE category = 'MA'
                                           AND uname = @sy-uname
                                           AND werks IS NOT INITIAL
                                         INTO TABLE @DATA(lt_autho_ma1).
      SELECT * FROM zmm_ma INTO TABLE lt_zmm_ma WHERE ma_matnr IN s_matnr.

      IF lt_autho_ma1 IS NOT INITIAL.
        LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat4>).
          IF <mat4>-low+0(2) NE 'MS' AND <mat4>-low IS NOT INITIAL.
            CONCATENATE 'MS' <mat4>-low INTO <mat4>-low.
          ENDIF.
          IF <mat4>-high+0(2) NE 'MS' AND <mat4>-high IS NOT INITIAL.
            CONCATENATE 'MS' <mat4>-high INTO <mat4>-high.
          ENDIF.
        ENDLOOP.

        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
       b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
       ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_p4) FOR ALL ENTRIES IN @lt_autho_ma1
       WHERE a~kappl = 'M' AND a~kschl = @lt_autho_ma1-kschl AND a~lifnr = @lt_autho_ma1-lifnr AND a~matnr IN @s_matnr
         AND a~ekorg = @lt_autho_ma1-ekorg AND a~werks = @lt_autho_ma1-werks AND b~loevm_ko NE 'X'.


      ENDIF.

      IF lt_factor IS NOT INITIAL.

*       YP01 - sales price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~matnr,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a004 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_v4) FOR ALL ENTRIES IN @lt_factor
          WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
            AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

*      YWP1 - warranty price
        SELECT a~kappl, a~kschl, a~vkorg, a~vtweg, a~spart,a~aufart, a~matnr,a~datbi,a~datab,a~knumh,
      b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~kmein,b~meins ,b~kumza, b~kumne FROM a900 AS a INNER JOIN konp AS b
      ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec_w4) FOR ALL ENTRIES IN @lt_factor
      WHERE a~kappl = 'V' AND a~kschl = @lt_factor-kschl AND a~vkorg = @lt_factor-vkorg AND a~matnr IN @s_matnr
        AND a~vtweg = @lt_factor-vtweg  AND b~loevm_ko NE 'X'.

      ENDIF.
*
      LOOP AT lt_zmm_ma ASSIGNING FIELD-SYMBOL(<fs_55>).
        IF <fs_55>-ma_matnr+0(2) NE 'MS'.
          CONCATENATE 'MS' <fs_55>-ma_matnr INTO <fs_55>-ma_matnr.
        ENDIF.
        SELECT SINGLE matnr matkl  INTO ( lv_matnr, lv_matkl ) FROM mara WHERE matnr =   <fs_55>-ma_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_autho_ma1 ASSIGNING FIELD-SYMBOL(<lw_autho_ma1>).
            IF <lw_autho_ma1>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.

            lw_PRICECOMP-matnr = <fs_55>-ma_matnr.

            lw_PRICECOMP-werks      = <lw_autho_ma1>-werks.

            lw_PRICECOMP-maktx      = <fs_55>-ma_maktx.
            lw_PRICECOMP-matkl      = lv_matkl.
            lw_PRICECOMP-extwg      = ''."<fs_55>-ma_extwg.
            READ TABLE lt_inforec_p4 ASSIGNING FIELD-SYMBOL(<fs_inforec_p4>) WITH KEY matnr = <fs_55>-ma_matnr
                                                                              lifnr = <lw_autho_ma1>-lifnr
                                                                              ekorg = <lw_autho_ma1>-ekorg
                                                                              werks = <lw_autho_ma1>-werks
                                                                              kschl = 'YP01'.
            IF sy-subrc = 0.
              lw_PRICECOMP-curr_pur =  <fs_inforec_p4>-kbetr.
              lw_PRICECOMP-future_pur =   <fs_55>-ma_price.
            ENDIF.

            LOOP AT lt_factor ASSIGNING FIELD-SYMBOL(<lw_factor4>).
              IF <lw_factor4>-kschl IS INITIAL.
                MESSAGE 'Condition Type not maintained in table ZMM_PC_FACTOR' TYPE 'E'.
                CONTINUE.
              ENDIF.
              CLEAR :lv_price_s, lv_price_w.



              IF <lw_factor4>-kschl = 'YP01'.
                PERFORM get_price TABLES lt_factor USING <fs_55>-ma_price
                                                      '' " <fs_55>-ma_cour_surc
                                                       <lw_factor4>-vkorg
                                                       <lw_factor4>-vtweg
                                                       <lw_factor4>-kschl
                                                        'S' " Selling price
                                               CHANGING lv_price_s.
                READ TABLE lt_inforec_v4 ASSIGNING FIELD-SYMBOL(<fs_inforec_v4>) WITH KEY matnr = <fs_55>-ma_matnr
                                                                                    vkorg = <lw_factor4>-vkorg
                                                                                    vtweg = <lw_factor4>-vtweg
                                                                                    kschl = <lw_factor4>-kschl.
                IF sy-subrc = 0.
*                  lw_PRICECOMP-werks      = <lw_autho_ma1>-werks.
                  lw_PRICECOMP-curr_sel   =  <fs_inforec_v4>-kbetr.
                  lw_PRICECOMP-future_sel = lv_price_s.
*                  lw_PRICECOMP-maktx      = <fs_55>-ma_maktx.
*                  lw_PRICECOMP-matkl      = lv_matkl.
*                  lw_PRICECOMP-extwg      = ''."<fs_55>-ma_extwg.

                ENDIF.
              ENDIF.
*            for warranty price
              IF <lw_factor4>-kschl = 'YWP1'.
                PERFORM get_price TABLES lt_factor USING <fs_55>-ma_price
                                                     '' " <fs_55>-ma_cour_surc
                                                      <lw_factor4>-vkorg
                                                      <lw_factor4>-vtweg
                                                      <lw_factor4>-kschl
                                                       'W' " Warranty Price
                                              CHANGING lv_price_w.

                READ TABLE lt_inforec_w4 ASSIGNING FIELD-SYMBOL(<fs_inforec_w4>) WITH KEY matnr = <fs_55>-ma_matnr
                                                                                  vkorg = <lw_factor4>-vkorg
                                                                                  vtweg = <lw_factor4>-vtweg
                                                                                  kschl = <lw_factor4>-kschl.
                IF sy-subrc = 0.
                  lw_PRICECOMP-curr_war = <fs_inforec_w4>-kbetr.
                  lw_PRICECOMP-future_war = lv_price_w.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF lw_pricecomp-matnr IS NOT INITIAL.
              APPEND lw_pricecomp TO lt_pricecomp.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

    ENDIF.
*------------------------------------------------------------------------------------------------------------------

    IF lt_pricecomp[] IS NOT INITIAL.
      CALL FUNCTION 'ZMM_ALV_POPUP'
        EXPORTING
          i_start_column = 5
          i_start_line   = 5
          i_end_column   = 200
          i_end_line     = 100
          i_title        = 'ALV'
          i_popup        = 'X'
        TABLES
          it_alv         = lt_pricecomp.
    ENDIF.


    LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat_1>).
      <mat_1>-low = <mat_1>-low+2(38).
      <mat_1>-high = <mat_1>-high+2(38).
    ENDLOOP.


  ELSE.
    MESSAGE 'Please enter part number' TYPE 'E'.
  ENDIF.

ENDFORM.


FORM get_price1  TABLES   p_lt_factor STRUCTURE zmm_pc_factor
                USING    p_price
                         p_price1
                         p_vkorg
                         p_vtweg
                         p_AUFART
                         p_kschl
                         p_cond_cat
                CHANGING p_lv_price.
*  in this program condition catagory is selling price only
  READ TABLE p_lt_factor  ASSIGNING FIELD-SYMBOL(<factor>)
                               WITH KEY vkorg = p_vkorg
                                        vtweg = p_vtweg
                                        kschl = p_kschl
                                        aufart = p_AUFART
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

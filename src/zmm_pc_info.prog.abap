*----------------------------------------------------------------------*
***INCLUDE ZMM_PC_INFO.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zmm_pc_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zmm_pc_info .

  DATA : lv_timess TYPE p DECIMALS 1.

  DATA :
    lt_ct       TYPE STANDARD TABLE OF bapicondct,
    lt_hd       TYPE STANDARD TABLE OF bapicondhd,
    lt_IT       TYPE STANDARD TABLE OF bapicondit,
    lt_qs       TYPE STANDARD TABLE OF bapicondqs,
    lt_vs       TYPE STANDARD TABLE OF bapicondvs,
    lt_BAPIRET2 TYPE STANDARD TABLE OF bapiret2 ,
    lt_KNUMHS   TYPE STANDARD TABLE OF bapiknumhs,
    lt_mem      TYPE STANDARD TABLE OF cnd_mem_initial.

FIELD-SYMBOLS <fs_bapiret2> TYPE bapiret2.
  DATA lt_varkey1 TYPE char100.


  DATA: ltt_return TYPE TABLE OF bapiret2,
        lt_zmm_gm  TYPE STANDARD TABLE OF zmm_gm,
        lt_zmm_hq  TYPE STANDARD TABLE OF zmm_hq,
        lt_zmm_ac  TYPE STANDARD TABLE OF zmm_ac,
        lt_zmm_df  TYPE STANDARD TABLE OF zmm_df,
        lt_zmm_ma  TYPE STANDARD TABLE OF zmm_ma,
        lv_matnr   TYPE matnr,
        lv_maktx   TYPE maktx.


  DATA : lt_eina          TYPE  mewieina_mig,
         lt_einax         TYPE  mewieinax_ty, "mewieinax,
         lt_eine          TYPE  mewieine_ty, "mewieine,
         lt_einex         TYPE  mewieinex_ty, "mewieinex,
         lt_return        TYPE  fs4mig_t_bapiret2,
         im_eina          TYPE mewieina_mig_t,
         im_eine          TYPE mewieine_t,
         ls_return        TYPE bapiret2,

         lt_COND_VALIDITY TYPE  mewivalidity_ty , "mewivalidity_tt,
         lt_CONDITION     TYPE  mewicondition_ty. "mewicondition_tt.

  DATA : ltt_eina          TYPE  mewieina_mig_t,
         ltt_einax         TYPE  mewieinax_t,
         ltt_eine          TYPE  mewieine_t,
         ltt_einex         TYPE  mewieinex_t,
         ltt_COND_VALIDITY TYPE  mewivalidity_tt,
         ltt_CONDITION     TYPE  mewicondition_tt.

  DATA :l3t_eina          TYPE  mewieina_mig_t,
        l3t_einax         TYPE  mewieinax_t,
        l3t_eine          TYPE  mewieine_t,
        l3t_einex         TYPE  mewieinex_t,
        l3t_COND_VALIDITY TYPE  mewivalidity_tt,
        l3t_CONDITION     TYPE  mewicondition_tt.

  DATA : ls_eina          TYPE  mewieina_mig,
         ls_einax         TYPE  mewieinax_ty, "mewieinax,
         ls_eine          TYPE  mewieine_ty, "mewieine,
         ls_einex         TYPE  mewieinex_ty, "mewieinex,
         ls_COND_VALIDITY TYPE  mewivalidity_ty , "mewivalidity_tt,
         ls_CONDITION     TYPE  mewicondition_ty.
  DATA: v1      TYPE num , "numc2,
        v2      TYPE num, "numc2,
        v3      TYPE numc5,
        d1      TYPE numc5,
        lv_indx TYPE num.
  DATA lv_new TYPE char2.

  IF s_matnr[] IS NOT INITIAL.
    IF p_gm = 'X'. "-------------------------------------------------------------------------------

      SELECT * FROM zmm_pc_autho  WHERE category = 'GM'
                                      AND uname = @sy-uname
                                      AND werks IS NOT INITIAL
                                    INTO TABLE @DATA(lt_autho_gm).
      SORT lt_autho_gm BY category uname ekorg werks.
      DELETE ADJACENT DUPLICATES FROM lt_autho_gm COMPARING category uname ekorg werks.
      SELECT * FROM zmm_gm INTO TABLE lt_zmm_gm WHERE gm_matnr IN s_matnr.

      IF lt_autho_gm IS NOT INITIAL.


        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'GM' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'GM' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'GM' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'GM' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.

        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~zaehk_ind,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec) FOR ALL ENTRIES IN @lt_autho_gm
          WHERE a~kappl = 'M' AND a~kschl = @lt_autho_gm-kschl AND a~lifnr = @lt_autho_gm-lifnr AND a~matnr IN @s_matnr
            AND a~ekorg = @lt_autho_gm-ekorg AND a~werks = @lt_autho_gm-werks AND b~loevm_ko NE 'X'.
      ENDIF.

      LOOP AT lt_zmm_gm ASSIGNING FIELD-SYMBOL(<fs_gm>).
        IF <fs_gm>-gm_matnr+0(2) NE 'GM'.
          CONCATENATE 'GM' <fs_gm>-gm_matnr INTO <fs_gm>-gm_matnr.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_gm>-gm_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_autho_gm ASSIGNING FIELD-SYMBOL(<lw_autho_gm>).
            IF <lw_autho_gm>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.
            READ TABLE lt_inforec ASSIGNING FIELD-SYMBOL(<fs_inforec>) WITH KEY matnr = <fs_gm>-gm_matnr
                                                                                lifnr = <lw_autho_gm>-lifnr
                                                                                ekorg = <lw_autho_gm>-ekorg
                                                                                werks = <lw_autho_gm>-werks.
            IF sy-subrc = 0.
              CLEAR lt_varkey1.
              CONCATENATE  <fs_inforec>-lifnr <fs_inforec>-matnr <fs_inforec>-ekorg <fs_inforec>-werks <fs_inforec>-esokz INTO lt_varkey1.
              tb_oper     = '017'.
              cond_usage  =  'A'.
              table_no    = '017'.
              tb_kappl    = 'M'.
              tb_KSCHL    = <lw_autho_gm>-kschl.
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
              tb_curr     = <fs_gm>-gm_waers.
              tb_curr_iso = <fs_gm>-gm_waers.
              tb_var      = lt_varkey1.
              tb_price    = <fs_gm>-gm_price + <fs_gm>-GM_COUR_SURC.


 clear : gv_matnr,gv_lifnr,gv_werks,gv_ekorg,gv_price1,gv_price2.
              gv_matnr = <fs_inforec>-matnr.
              gv_lifnr = <fs_inforec>-lifnr.
              gv_werks = <fs_inforec>-werks.
              gv_ekorg = <fs_inforec>-ekorg.
              gv_price1 = <fs_inforec>-kbetr.
              gv_price2 = tb_price.


              INCLUDE zmm_pc_info_sub2.
              SUBMIT rm06inp0 WITH if_lifnr-low  = <fs_inforec>-lifnr WITH tk_matnr-low = <fs_inforec>-matnr  WITH wq_simul = ' ' WITH method = ' '
              EXPORTING LIST TO MEMORY AND RETURN  .
            ELSE."--------------------------------------------------
              lt_eina = VALUE #(  material = <fs_gm>-gm_matnr  vendor = <lw_autho_gm>-lifnr     ).
              lt_einax = VALUE #(  material = 'X'  vendor = 'X'     ).
              lt_eine = VALUE #(  min_po_qty = <fs_gm>-gm_min_ord_qty
                               nrm_po_qty = <fs_gm>-gm_min_ord_qty
                               plnd_delry = 010
                               orderpr_un = 'EA'
                               plant      =  <lw_autho_gm>-werks
                               purch_org  = <lw_autho_gm>-ekorg
                               net_price = ( <fs_gm>-gm_price + <fs_gm>-GM_COUR_SURC )
                               currency = <fs_gm>-gm_waers ) .
              lt_einex = VALUE #(  min_po_qty = 'X' nrm_po_qty = 'X'
                                    plnd_delry = 'X' orderpr_un = 'X' net_price = 'X'
                                    purch_org  = 'X'
                                    plant      = 'X'
                                    currency = 'X'
                                     ) .
              lt_condition = VALUE #(  cond_type = 'YP01'
                                     cond_value =  ( <fs_gm>-gm_price + <fs_gm>-GM_COUR_SURC )
                                     currency = <fs_gm>-gm_waers
                                    currency_iso = <fs_gm>-gm_waers "'SAR'
                                    base_uom = 'EA'
                                    cond_p_unt = '1'
                                    change_id = 'I'  ).

              lt_COND_VALIDITY = VALUE #(  plant = <lw_autho_gm>-werks
                                  valid_from = sy-datum
                                  valid_to = '99991231' ) .
              APPEND :    lt_eina TO ltt_eina,
                         lt_einax TO  ltt_einax  ,
                         lt_eine  TO ltt_eine ,
                         lt_einex TO ltt_einex ,
                         lt_condition  TO ltt_condition,
                         lt_COND_VALIDITY TO ltt_COND_VALIDITY.
*              INCLUDE zmm_pc_info_sub.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

      IF ltt_eina[] IS NOT INITIAL.
        INCLUDE zmm_pc_info_sub.
        CLEAR : ltt_eina[], ltt_einax[],ltt_eine[],ltt_einex[] ,ltt_condition[], ltt_cond_validity[].
      ENDIF.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        IMPORTING
          return = ls_return.

    ELSEIF p_HQ = 'X'.  "-------------------------------------------------------------------------------------

      SELECT * FROM zmm_pc_autho  WHERE category = 'HQ'
                                           AND uname = @sy-uname
                                           AND werks IS NOT INITIAL
                                         INTO TABLE @DATA(lt_autho_hq).
      SORT lt_autho_hq BY category uname ekorg werks.
      DELETE ADJACENT DUPLICATES FROM lt_autho_hq COMPARING category uname ekorg werks.
      SELECT * FROM zmm_hq INTO TABLE lt_zmm_hq WHERE hq_matnr IN s_matnr.

      IF lt_autho_hq IS NOT INITIAL.

        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'HQ' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'HQ' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'HQ' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'HQ' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.


        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~zaehk_ind,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec1) FOR ALL ENTRIES IN @lt_autho_hq
          WHERE a~kappl = 'M' AND a~kschl = @lt_autho_hq-kschl AND a~lifnr = @lt_autho_hq-lifnr AND a~matnr IN @s_matnr
            AND a~ekorg = @lt_autho_hq-ekorg AND a~werks = @lt_autho_hq-werks AND b~loevm_ko NE 'X'.
      ENDIF.

      LOOP AT lt_zmm_hq ASSIGNING FIELD-SYMBOL(<fs_hq>).
        IF <fs_hq>-hq_matnr+0(2) NE 'HQ'.
          CONCATENATE 'HQ' <fs_hq>-hq_matnr INTO <fs_hq>-hq_matnr.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_hq>-hq_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_autho_hq ASSIGNING FIELD-SYMBOL(<lw_autho_hq>).
            IF <lw_autho_hq>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.
            READ TABLE lt_inforec1 ASSIGNING FIELD-SYMBOL(<fs_inforec1>) WITH KEY matnr = <fs_hq>-hq_matnr
                                                                                lifnr = <lw_autho_hq>-lifnr
                                                                                ekorg = <lw_autho_hq>-ekorg
                                                                                werks = <lw_autho_hq>-werks.
            IF sy-subrc = 0.
              CLEAR lt_varkey1.
              CONCATENATE  <fs_inforec1>-lifnr <fs_inforec1>-matnr <fs_inforec1>-ekorg <fs_inforec1>-werks <fs_inforec1>-esokz INTO lt_varkey1.
              tb_oper     = '017'.
              cond_usage  =  'A'.
              table_no    = '017'.
              tb_kappl    = 'M'.
              tb_KSCHL    = <lw_autho_hq>-kschl.
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
              tb_curr     = <fs_hq>-hq_waers.
              tb_curr_iso = <fs_hq>-hq_waers.
              tb_var      = lt_varkey1.
              tb_price    = <fs_hq>-hq_price.

              clear : gv_matnr,gv_lifnr,gv_werks,gv_ekorg,gv_price1,gv_price2.
              gv_matnr = <fs_inforec1>-matnr.
              gv_lifnr = <fs_inforec1>-lifnr.
              gv_werks = <fs_inforec1>-werks.
              gv_ekorg = <fs_inforec1>-ekorg.
              gv_price1 = <fs_inforec1>-kbetr.
              gv_price2 = tb_price.

              INCLUDE zmm_pc_info_sub2.
              SUBMIT rm06inp0 WITH if_lifnr-low  = <fs_inforec1>-lifnr WITH tk_matnr-low = <fs_inforec1>-matnr  WITH wq_simul = ' ' WITH method = ' '
              EXPORTING LIST TO MEMORY AND RETURN  .
            ELSE."--------------------------------------------------
*              CLEAR : lt_eina[], lt_einax[],lt_eine[],lt_einex[] ,lt_condition[], lt_cond_validity[].
              lt_eina = VALUE #(  material = <fs_hq>-hq_matnr  vendor = <lw_autho_hq>-lifnr     ).
              lt_einax = VALUE #(  material = 'X'  vendor = 'X'     ).
              lt_eine = VALUE #(  min_po_qty = <fs_hq>-hq_pack_qty
                               nrm_po_qty = <fs_hq>-hq_pack_qty
                               plnd_delry = 010
                               orderpr_un = 'EA'
                               plant      =  <lw_autho_hq>-werks
                               purch_org  = <lw_autho_hq>-ekorg
                               net_price = <fs_hq>-hq_price
                               currency = <fs_hq>-hq_waers  ).
              lt_einex = VALUE #(  min_po_qty = 'X' nrm_po_qty = 'X'
                                    plnd_delry = 'X' orderpr_un = 'X' net_price = 'X'
                                    purch_org  = 'X'
                                    plant      = 'X'
                                    currency = 'X'
                                     ) .
              lt_condition = VALUE #(  cond_type = 'YP01'
                                     cond_value = <fs_hq>-hq_price
                                     currency = <fs_hq>-hq_waers
                                    currency_iso = <fs_hq>-hq_waers "'SAR'
                                    base_uom = 'EA'
                                    cond_p_unt = '1'
                                    change_id = 'I'  ).

              lt_COND_VALIDITY = VALUE #(
                                  plant = <lw_autho_hq>-werks

                                  valid_from = sy-datum
                                  valid_to = '99991231'  ).
              APPEND :    lt_eina TO ltt_eina,
     lt_einax TO  ltt_einax  ,
     lt_eine  TO ltt_eine ,
     lt_einex TO ltt_einex ,
     lt_condition  TO ltt_condition,
     lt_COND_VALIDITY TO ltt_COND_VALIDITY.
*              INCLUDE zmm_pc_info_sub.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
      IF ltt_eina[] IS NOT INITIAL.
        INCLUDE zmm_pc_info_sub.
        CLEAR : ltt_eina[], ltt_einax[],ltt_eine[],ltt_einex[] ,ltt_condition[], ltt_cond_validity[].
      ENDIF.


      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        IMPORTING
          return = ls_return.
    ELSEIF p_ac = 'X'. "---------------------------------------------------------------------------------------------------



      SELECT * FROM zmm_pc_autho  WHERE category = 'AC'
                                      AND uname = @sy-uname
                                      AND werks IS NOT INITIAL
                                    INTO TABLE @DATA(lt_autho_ac).
      SORT lt_autho_ac BY category uname ekorg werks.
      DELETE ADJACENT DUPLICATES FROM lt_autho_ac COMPARING category uname ekorg werks.
      SELECT * FROM zmm_ac INTO TABLE lt_zmm_ac WHERE ac_delco IN s_matnr.

      IF lt_autho_ac IS NOT INITIAL.

        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'AC' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'AC' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'AC' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'AC' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.
        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~zaehk_ind,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec2) FOR ALL ENTRIES IN @lt_autho_ac
          WHERE a~kappl = 'M' AND a~kschl = @lt_autho_ac-kschl AND a~lifnr = @lt_autho_ac-lifnr AND a~matnr IN @s_matnr
            AND a~ekorg = @lt_autho_ac-ekorg AND a~werks = @lt_autho_ac-werks AND b~loevm_ko NE 'X'.
      ENDIF.

      LOOP AT lt_zmm_ac ASSIGNING FIELD-SYMBOL(<fs_ac>).
        IF <fs_ac>-ac_delco+0(2) NE 'AC'.
          CONCATENATE 'AC' <fs_ac>-ac_delco INTO <fs_ac>-ac_delco.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_ac>-ac_delco.
        IF sy-subrc = 0.
          LOOP AT lt_autho_ac ASSIGNING FIELD-SYMBOL(<lw_autho_ac>).
            IF <lw_autho_ac>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.
            READ TABLE lt_inforec2 ASSIGNING FIELD-SYMBOL(<fs_inforec2>) WITH KEY matnr = <fs_ac>-ac_delco
                                                                                lifnr = <lw_autho_ac>-lifnr
                                                                                ekorg = <lw_autho_ac>-ekorg
                                                                                werks = <lw_autho_ac>-werks.
            IF sy-subrc = 0.
              CLEAR lt_varkey1.
              CONCATENATE  <fs_inforec2>-lifnr <fs_inforec2>-matnr <fs_inforec2>-ekorg <fs_inforec2>-werks <fs_inforec2>-esokz INTO lt_varkey1.
              tb_oper     = '017'.
              cond_usage  =  'A'.
              table_no    = '017'.
              tb_kappl    = 'M'.
              tb_KSCHL    = <lw_autho_ac>-kschl.
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
              tb_curr     = <fs_ac>-ac_waers.
              tb_curr_iso = <fs_ac>-ac_waers.
              tb_var      = lt_varkey1.
              tb_price    = <fs_ac>-ac_price + <fs_ac>-AC_COUR_SURC.


 clear : gv_matnr,gv_lifnr,gv_werks,gv_ekorg,gv_price1,gv_price2.
              gv_matnr = <fs_inforec2>-matnr.
              gv_lifnr = <fs_inforec2>-lifnr.
              gv_werks = <fs_inforec2>-werks.
              gv_ekorg = <fs_inforec2>-ekorg.
              gv_price1 = <fs_inforec2>-kbetr.
              gv_price2 = tb_price.


              INCLUDE zmm_pc_info_sub2.
              SUBMIT rm06inp0 WITH if_lifnr-low  = <fs_inforec2>-lifnr WITH tk_matnr-low = <fs_inforec2>-matnr  WITH wq_simul = ' ' WITH method = ' '
              EXPORTING LIST TO MEMORY AND RETURN  .
            ELSE."--------------------------------------------------
*              CLEAR : lt_eina[], lt_einax[],lt_eine[],lt_einex[] ,lt_condition[], lt_cond_validity[].
              lt_eina = VALUE #(  material = <fs_ac>-ac_delco  vendor = <lw_autho_ac>-lifnr     ).
              lt_einax = VALUE #(  material = 'X'  vendor = 'X'    ).
              lt_eine = VALUE #(  min_po_qty = <fs_ac>-ac_min_ord_qty
                               nrm_po_qty = <fs_ac>-ac_min_ord_qty
                               plnd_delry = 010
                               orderpr_un = 'EA'
                               plant      =  <lw_autho_ac>-werks
                               purch_org  = <lw_autho_ac>-ekorg
                               net_price = ( <fs_ac>-ac_price + <fs_ac>-AC_COUR_SURC )
                               currency = <fs_ac>-ac_waers  ).
              lt_einex = VALUE #(  min_po_qty = 'X' nrm_po_qty = 'X'
                                    plnd_delry = 'X' orderpr_un = 'X' net_price = 'X'
                                    purch_org  = 'X'
                                    plant      = 'X'
                                    currency = 'X'
                                      ).
              lt_condition = VALUE #(  cond_type = 'YP01'
                                     cond_value = ( <fs_ac>-ac_price + <fs_ac>-AC_COUR_SURC )
                                     currency = <fs_ac>-ac_waers
                                    currency_iso = <fs_ac>-ac_waers "'SAR'
                                    base_uom = 'EA'
                                    cond_p_unt = '1'
                                    change_id = 'I'  ).

              lt_COND_VALIDITY = VALUE #(
                                  plant = <lw_autho_ac>-werks

                                  valid_from = sy-datum
                                  valid_to = '99991231'  ).
              APPEND :    lt_eina TO ltt_eina,
     lt_einax TO  ltt_einax  ,
     lt_eine  TO ltt_eine ,
     lt_einex TO ltt_einex ,
     lt_condition  TO ltt_condition,
     lt_COND_VALIDITY TO ltt_COND_VALIDITY.
*              INCLUDE zmm_pc_info_sub.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
      IF ltt_eina[] IS NOT INITIAL.
        INCLUDE zmm_pc_info_sub.
        CLEAR : ltt_eina[], ltt_einax[],ltt_eine[],ltt_einex[] ,ltt_condition[], ltt_cond_validity[].
      ENDIF.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        IMPORTING
          return = ls_return.
    ELSEIF p_DF = 'X'.


      SELECT * FROM zmm_pc_autho  WHERE category = 'DF'
                                      AND uname = @sy-uname
                                      AND werks IS NOT INITIAL
                                    INTO TABLE @DATA(lt_autho_df).
      SORT lt_autho_df BY category uname ekorg werks.
      DELETE ADJACENT DUPLICATES FROM lt_autho_df COMPARING category uname ekorg werks.
      SELECT * FROM zmm_df INTO TABLE lt_zmm_df WHERE df_matnr IN s_matnr.

      IF lt_autho_df IS NOT INITIAL.


        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'DF' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'DF' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'DF' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'DF' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.


        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~zaehk_ind,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec3) FOR ALL ENTRIES IN @lt_autho_df
          WHERE a~kappl = 'M' AND a~kschl = @lt_autho_df-kschl AND a~lifnr = @lt_autho_df-lifnr AND a~matnr IN @s_matnr
            AND a~ekorg = @lt_autho_df-ekorg AND a~werks = @lt_autho_df-werks AND b~loevm_ko NE 'X'.
      ENDIF.

      LOOP AT lt_zmm_df ASSIGNING FIELD-SYMBOL(<fs_df>).
        IF <fs_df>-df_matnr+0(2) NE 'DF'.
          CONCATENATE 'DF' <fs_df>-df_matnr INTO <fs_df>-df_matnr.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_df>-df_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_autho_df ASSIGNING FIELD-SYMBOL(<lw_autho_df>).
            IF <lw_autho_df>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.
            READ TABLE lt_inforec3 ASSIGNING FIELD-SYMBOL(<fs_inforec3>) WITH KEY matnr = <fs_df>-df_matnr
                                                                                lifnr = <lw_autho_df>-lifnr
                                                                                ekorg = <lw_autho_df>-ekorg
                                                                                werks = <lw_autho_df>-werks.
            IF sy-subrc = 0.
              CLEAR lt_varkey1.
              CONCATENATE  <fs_inforec3>-lifnr <fs_inforec3>-matnr <fs_inforec3>-ekorg <fs_inforec3>-werks <fs_inforec3>-esokz INTO lt_varkey1.
              tb_oper     = '017'.
              cond_usage  =  'A'.
              table_no    = '017'.
              tb_kappl    = 'M'.
              tb_KSCHL    = <lw_autho_df>-kschl.
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
              tb_curr     = <fs_df>-df_waers.
              tb_curr_iso = <fs_df>-df_waers.
              tb_var      = lt_varkey1.
              tb_price    = <fs_df>-df_price.

 clear : gv_matnr,gv_lifnr,gv_werks,gv_ekorg,gv_price1,gv_price2.
              gv_matnr = <fs_inforec3>-matnr.
              gv_lifnr = <fs_inforec3>-lifnr.
              gv_werks = <fs_inforec3>-werks.
              gv_ekorg = <fs_inforec3>-ekorg.
              gv_price1 = <fs_inforec3>-kbetr.
              gv_price2 = tb_price.

              INCLUDE zmm_pc_info_sub2.
              SUBMIT rm06inp0 WITH if_lifnr-low  = <fs_inforec3>-lifnr WITH tk_matnr-low = <fs_inforec3>-matnr  WITH wq_simul = ' ' WITH method = ' '
              EXPORTING LIST TO MEMORY AND RETURN  .
            ELSE."--------------------------------------------------
              CLEAR : lt_eina, lt_einax,lt_eine,lt_einex ,lt_condition, lt_cond_validity.
              lt_eina = VALUE #(  material = <fs_df>-df_matnr  vendor = <lw_autho_df>-lifnr     ).
              lt_einax = VALUE #(  material = 'X'  vendor = 'X'     ).
              lt_eine = VALUE #(  min_po_qty = <fs_df>-df_qty
                               nrm_po_qty = <fs_df>-df_qty
                               plnd_delry = 010
                               orderpr_un = 'EA'
                               plant      =  <lw_autho_df>-werks
                               purch_org  = <lw_autho_df>-ekorg
                               net_price = <fs_df>-df_price
                               currency = <fs_df>-df_waers  ).
              lt_einex = VALUE #(  min_po_qty = 'X' nrm_po_qty = 'X'
                                    plnd_delry = 'X' orderpr_un = 'X' net_price = 'X'
                                    purch_org  = 'X'
                                    plant      = 'X'
                                    currency = 'X'
                                      ).
              lt_condition = VALUE #(  cond_type = 'YP01'
                                     cond_value = <fs_df>-df_price
                                     currency = <fs_df>-df_waers
                                    currency_iso = <fs_df>-df_waers "'SAR'
                                    base_uom = 'EA'
                                    cond_p_unt = '1'
                                    change_id = 'I'  ).

              lt_COND_VALIDITY = VALUE #(
                                  plant = <lw_autho_df>-werks

                                  valid_from = sy-datum
                                  valid_to = '99991231' ).
              APPEND :    lt_eina TO ltt_eina,
                          lt_einax TO  ltt_einax  ,
                          lt_eine  TO ltt_eine ,
                          lt_einex TO ltt_einex ,
                          lt_condition  TO ltt_condition,
                          lt_COND_VALIDITY TO ltt_COND_VALIDITY.
*              INCLUDE zmm_pc_info_sub.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

      IF ltt_eina[] IS NOT INITIAL.
        INCLUDE zmm_pc_info_sub.
        CLEAR : ltt_eina[], ltt_einax[],ltt_eine[],ltt_einex[] ,ltt_condition[], ltt_cond_validity[].
      ENDIF.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        IMPORTING
          return = ls_return.


    ELSEIF p_ma = 'X'.


      SELECT * FROM zmm_pc_autho  WHERE category = 'MS'
                                      AND uname = @sy-uname
                                      AND werks IS NOT INITIAL
                                    INTO TABLE @DATA(lt_autho_ma).
      SORT lt_autho_ma BY category uname ekorg werks.
      DELETE ADJACENT DUPLICATES FROM lt_autho_ma COMPARING category uname ekorg werks.
      SELECT * FROM zmm_ma INTO TABLE lt_zmm_ma WHERE ma_matnr IN s_matnr.

      IF lt_autho_ma IS NOT INITIAL.


        LOOP AT s_matnr .
          IF s_matnr-low+0(2) NE 'MS' AND s_matnr-low IS NOT INITIAL.
            CONCATENATE 'MS' s_matnr-low INTO s_matnr-low.
          ENDIF.
          IF s_matnr-high+0(2) NE 'MS' AND s_matnr-high IS NOT INITIAL.
            CONCATENATE 'MS' s_matnr-high INTO s_matnr-high.
          ENDIF.
          MODIFY s_matnr.
        ENDLOOP.



        SELECT a~kappl, a~kschl, a~lifnr, a~matnr, a~ekorg,a~werks,a~esokz,a~datbi,a~datab,a~knumh,
          b~kopos,b~stfkz,b~krech,b~kbetr,b~kstbm, b~konwa,b~kpein,b~zaehk_ind,b~kmein,b~meins ,b~kumza, b~kumne FROM a017 AS a INNER JOIN konp AS b
          ON a~knumh = b~knumh   INTO TABLE @DATA(lt_inforec4) FOR ALL ENTRIES IN @lt_autho_ma
          WHERE a~kappl = 'M' AND a~kschl = @lt_autho_ma-kschl AND a~lifnr = @lt_autho_ma-lifnr AND a~matnr IN @s_matnr
            AND a~ekorg = @lt_autho_ma-ekorg AND a~werks = @lt_autho_ma-werks AND b~loevm_ko NE 'X'.
      ENDIF.

      LOOP AT lt_zmm_ma ASSIGNING FIELD-SYMBOL(<fs_ma>).
        IF <fs_ma>-ma_matnr+0(2) NE 'MS'.
          CONCATENATE 'MS' <fs_ma>-ma_matnr INTO <fs_ma>-ma_matnr.
        ENDIF.
        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE matnr =   <fs_ma>-ma_matnr.
        IF sy-subrc = 0.
          LOOP AT lt_autho_ma ASSIGNING FIELD-SYMBOL(<lw_autho_ma>).
            IF <lw_autho_ma>-kschl IS INITIAL.
              MESSAGE 'Condition Type not maintained in table ZMM_PC_AUTHO' TYPE 'E'.
              CONTINUE.
            ENDIF.
            READ TABLE lt_inforec4 ASSIGNING FIELD-SYMBOL(<fs_inforec4>) WITH KEY matnr = <fs_ma>-ma_matnr
                                                                                lifnr = <lw_autho_ma>-lifnr
                                                                                ekorg = <lw_autho_ma>-ekorg
                                                                                werks = <lw_autho_ma>-werks.
            IF sy-subrc = 0.
              CLEAR lt_varkey1.
              CONCATENATE  <fs_inforec4>-lifnr <fs_inforec4>-matnr <fs_inforec4>-ekorg <fs_inforec4>-werks <fs_inforec4>-esokz INTO lt_varkey1.
              tb_oper     = '017'.
              cond_usage  =  'A'.
              table_no    = '017'.
              tb_kappl    = 'M'.
              tb_KSCHL    = <lw_autho_ma>-kschl.
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
              tb_curr     = <fs_ma>-ma_waers.
              tb_curr_iso = <fs_ma>-ma_waers.
              tb_var      = lt_varkey1.
              tb_price    = <fs_ma>-ma_price.

 clear : gv_matnr,gv_lifnr,gv_werks,gv_ekorg,gv_price1,gv_price2.
              gv_matnr = <fs_inforec4>-matnr.
              gv_lifnr = <fs_inforec4>-lifnr.
              gv_werks = <fs_inforec4>-werks.
              gv_ekorg = <fs_inforec4>-ekorg.
              gv_price1 = <fs_inforec4>-kbetr.
              gv_price2 = tb_price.

              INCLUDE zmm_pc_info_sub2.
              SUBMIT rm06inp0 WITH if_lifnr-low  = <fs_inforec4>-lifnr WITH tk_matnr-low = <fs_inforec4>-matnr  WITH wq_simul = ' ' WITH method = ' '
              EXPORTING LIST TO MEMORY AND RETURN  .
            ELSE."--------------------------------------------------
*              CLEAR : lt_eina[], lt_einax[],lt_eine[],lt_einex[] ,lt_condition[], lt_cond_validity[].
              lt_eina = VALUE #(   material = <fs_ma>-ma_matnr  vendor = <lw_autho_ma>-lifnr     ).
              lt_einax = VALUE #(  material = 'X'  vendor = 'X'     ).
              lt_eine = VALUE #(  min_po_qty = <fs_ma>-ma_qty
                               nrm_po_qty = <fs_ma>-ma_qty
                               plnd_delry = 010
                               orderpr_un = 'EA'
                               plant      =  <lw_autho_ma>-werks
                               purch_org  = <lw_autho_ma>-ekorg
                               net_price = <fs_ma>-ma_price
                               currency = <fs_ma>-ma_waers  ).
              lt_einex = VALUE #(  min_po_qty = 'X' nrm_po_qty = 'X'
                                    plnd_delry = 'X' orderpr_un = 'X' net_price = 'X'
                                    purch_org  = 'X'
                                    plant      = 'X'
                                    currency = 'X'
                                     ) .
              lt_condition = VALUE #(  cond_type = 'YP01'
                                     cond_value = <fs_ma>-ma_price
                                     currency = <fs_ma>-ma_waers
                                    currency_iso = <fs_ma>-ma_waers "'SAR'
                                    base_uom = 'EA'
                                    cond_p_unt = '1'
                                    change_id = 'I'  ).

              lt_COND_VALIDITY = VALUE #(
                                  plant = <lw_autho_ma>-werks

                                  valid_from = sy-datum
                                  valid_to = '99991231'  ).
              APPEND :    lt_eina TO ltt_eina,
     lt_einax TO  ltt_einax  ,
     lt_eine  TO ltt_eine ,
     lt_einex TO ltt_einex ,
     lt_condition  TO ltt_condition,
     lt_COND_VALIDITY TO ltt_COND_VALIDITY.
*              INCLUDE zmm_pc_info_sub.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
      IF ltt_eina[] IS NOT INITIAL.
        INCLUDE zmm_pc_info_sub.
        CLEAR : ltt_eina[], ltt_einax[],ltt_eine[],ltt_einex[] ,ltt_condition[], ltt_cond_validity[].
      ENDIF.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        IMPORTING
          return = ls_return.

    ENDIF.
*------------------------------------------------------------------------------------------------------------------
    LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<mat_1>).
      <mat_1>-low = <mat_1>-low+2(38).
      <mat_1>-high = <mat_1>-high+2(38).
    ENDLOOP.
    IF lt_return[] IS NOT INITIAL.
      CALL FUNCTION 'ZMM_ALV_POPUP'
        EXPORTING
          i_start_column = 5
          i_start_line   = 5
          i_end_column   = 150
          i_end_line     = 100
          i_title        = 'ALV'
          i_popup        = 'X'
        TABLES
          it_alv         = lt_return.

    ELSEIF lt_bapiret3[] IS NOT INITIAL.
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
    ENDIF.
  ENDIF.


ENDFORM.

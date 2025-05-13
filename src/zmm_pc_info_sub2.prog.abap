*&---------------------------------------------------------------------*
*& Include          ZMM_PC_INFO_SUB2
*&---------------------------------------------------------------------*



   lt_ct = VALUE #( ( operation  = tb_oper
                                 cond_usage = cond_usage
                                 table_no   = table_no
                                 applicatio = tb_kappl
                                 cond_type  = tb_KSCHL
                                 varkey_long     = tb_var
                                 valid_to   = tb_datbi
                                 valid_from = tb_datab
                                 cond_no    = tb_knumh ) ).
   lt_hd = VALUE #( ( operation  = tb_oper
                      cond_no    = tb_knumh
                      cond_usage = cond_usage
                      table_no   = table_no
                      applicatio = tb_kappl
                      cond_type  = tb_kschl
                      varkey_long     = lt_varkey1
                      valid_from = tb_datab
                      valid_to   = tb_datbi ) ).
   lt_it = VALUE #( ( operation  = tb_oper
                      cond_no    = tb_knumh
                      cond_count = tb_kopos
                      applicatio = tb_kappl
                      cond_type  = tb_kschl
                      cond_value = tb_price
                      conditidx  = tb_condidx "'1'
                      base_uom   = tb_meins
                      cond_p_unt = tb_kpein
                      scaletype  = tb_Stfkz
                      calctypcon = tb_krech
                      scale_qty  = tb_kstbm
                      cond_unit  =  tb_kmein
                      numconvert = tb_kumza
                      denominato = tb_kumne
                      condcurr   = tb_curr
                      cond_iso   = tb_curr  ) ).

   CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
     TABLES
       ti_bapicondct  = lt_ct
       ti_bapicondhd  = lt_hd
       ti_bapicondit  = lt_it
       ti_bapicondqs  = lt_qs
       ti_bapicondvs  = lt_vs
       to_bapiret2    = lt_bapiret2
       to_bapiknumhs  = lt_knumhs
       to_mem_initial = lt_mem
     EXCEPTIONS
       update_error   = 1
       OTHERS         = 2.

   DELETE  lt_bapiret2 WHERE type = 'W'.

*move lt_bapiret2 to lt_bapiret3.

   READ TABLE lt_ct INTO lw_ct INDEX 1.
   IF sy-subrc = 0.
     READ TABLE lt_bapiret2 INTO lwwwbapiret2 INDEX 1.
     IF sy-subrc = 0.
       CASE lw_ct-cond_type.
         WHEN 'YP01'.
           IF sy-ucomm = 'INFO'.

             CONCATENATE 'Vendor:' gv_lifnr 'Material:' gv_matnr 'Pur Org:' gv_ekorg 'Plant:' gv_werks
             'Old Price:' gv_price1 'New Price:' gv_price2  INTO lwwwbapiret2-message SEPARATED BY space.


           ELSEIF sy-ucomm = 'SALE1'.

             CONCATENATE  'Sales Price   -' 'Material:' gv_matnr   'Sales Org:' gv_vkorg 'Dist.Channel:' gv_vtweg
                          'Old Price:' gv_price1 'New Price:' gv_price2  INTO lwwwbapiret2-message SEPARATED BY space.

           ENDIF.


         WHEN 'YWP1'.
           CONCATENATE 'Warranty Price-' 'Material:' gv_matnr  'Sales Org:' gv_vkorg 'Dist.Channel:' gv_vtweg
                                  'Old Price:' gv_price1 'New Price:' gv_price2  INTO lwwwbapiret2-message SEPARATED BY space.


       ENDCASE.
       APPEND lwwwbapiret2 TO lt_bapiret3.
     ENDIF.
   ENDIF.
   CLEAR: lt_bapiret2, lwwwbapiret2,lw_ct.



   CLEAR :tb_oper,cond_usage,table_no,tb_kappl,tb_KSCHL ,tb_var, tb_datbi, tb_datab, tb_knumh,tb_kopos,
           tb_price,tb_meins,tb_kpein,tb_Stfkz, tb_krech,tb_kstbm,tb_kmein,tb_kumza,tb_kumne,tb_curr,tb_curr  .
   CLEAR : lt_ct,lt_hd,lt_it,lt_qs,lt_vs,lt_knumhs,lt_mem.

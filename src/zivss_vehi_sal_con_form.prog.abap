*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_SAL_CON_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  CONSTANTS: lc_soldtoparty TYPE parvw    VALUE 'AG',
             lc_payer       TYPE parvw    VALUE 'RG',
             lc_billtoparty TYPE parvw    VALUE 'RE'.

  IF p_veh EQ ' '.

    SELECT vbeln,vbtyp,fkdat,bukrs,vkorg,vtweg,knumv,spart,kunrg,kunag
    FROM vbrk INTO TABLE @DATA(lt_vbrk)
    WHERE fkdat IN @s_fkdat
      AND fkart IN @s_fkart
      AND fksto NE 'X'
      AND bukrs IN @s_bukrs
      AND vkorg IN @s_vkorg
      AND vtweg IN @s_vtweg
      AND spart IN @s_spart.

    SELECT * FROM zvss_mod_con_map INTO TABLE @DATA(lt_vss_mod_map).

    IF lt_vbrk IS NOT INITIAL.

      SELECT * FROM prcd_elements INTO TABLE @DATA(lt_prcd_elements)
               FOR ALL ENTRIES IN @lt_vbrk
               WHERE knumv = @lt_vbrk-knumv.

      SELECT vbeln,posnr,kursk,netwr,mwsbp,bwtar,charg,pstyv,werks,/dbe/vbeln,/dbe/posnr
    FROM vbrp INTO TABLE @DATA(lt_vbrp)
    FOR ALL ENTRIES IN @lt_vbrk
    WHERE vbeln = @lt_vbrk-vbeln.

      IF lt_vbrp IS NOT  INITIAL.
        SELECT vguid,vhcle,bwtar,vhvin,werks,matnr,/dbe/iobjguid FROM vlcvehicle INTO TABLE @DATA(lt_vlcvehicle)
        FOR ALL ENTRIES IN @lt_vbrp
        WHERE vhcle = @lt_vbrp-charg
         AND  vhvin IN @s_vhvin.

        IF lt_vlcvehicle IS  NOT INITIAL.
          SELECT * FROM zvss_vehi_cont INTO TABLE @DATA(lt_vss_vehi_cont)
            FOR ALL ENTRIES IN @lt_vlcvehicle
            WHERE vguid EQ @lt_vlcvehicle-vguid.
        ENDIF.
      ENDIF.
    ENDIF.

    DATA : lv_date TYPE d,
           lv_day  TYPE i.

    LOOP AT lt_vbrp INTO DATA(ls_vbrp) WHERE pstyv = 'QDBM' AND bwtar NE ''.
      READ TABLE lt_vbrk INTO DATA(ls_vbrk) WITH KEY vbeln = ls_vbrp-vbeln.
      IF sy-subrc EQ 0.
        READ TABLE lt_prcd_elements INTO DATA(ls_prcd_elements) WITH KEY knumv = ls_vbrk-knumv kposn = ls_vbrp-posnr
                                                                         kschl = 'ZPOM' kinak = ''.
        IF p_pom EQ 'X'.
          sy-subrc = 0.
        ENDIF.
        IF sy-subrc EQ 0.
          READ TABLE lt_vlcvehicle INTO DATA(ls_vlcvehicle) WITH KEY vhcle = ls_vbrp-charg.
          IF sy-subrc EQ 0.
            READ TABLE lt_vss_vehi_cont INTO DATA(ls_vss_vehi_cont) WITH KEY vguid = ls_vlcvehicle-vguid.
            IF sy-subrc NE 0.
              CLEAR lv_inc.

              ls_header-doc_type   = 'ZUCF'.
              ls_header-sales_org  = ls_vbrk-vkorg.
              ls_header-distr_chan = ls_vbrk-vtweg.
              ls_header-division   = ls_vbrk-spart.

              ls_partners-partn_role = lc_soldtoparty.
              ls_partners-partn_numb = ls_vbrk-kunag.
              APPEND ls_partners TO lt_partners.
              CLEAR ls_partners.

              ls_partners-partn_role = lc_payer.
              ls_partners-partn_numb = ls_vbrk-kunrg.
              APPEND ls_partners TO lt_partners.
              CLEAR ls_partners.

              ls_partners-partn_role = lc_billtoparty.
              ls_partners-partn_numb = ls_vbrk-kunrg.
              APPEND ls_partners TO lt_partners.
              CLEAR ls_partners.

              LOOP AT lt_vss_mod_map INTO DATA(ls_vss_mod_map) WHERE bukrs EQ ls_vbrk-bukrs AND
                                                                     vkorg EQ ls_vbrk-vkorg AND
                                                                     vtweg EQ ls_vbrk-vtweg AND
                                                                     spart EQ ls_vbrk-spart AND
                                                                     mcodesd EQ ls_vlcvehicle-matnr AND
                                                                     sales_rel EQ 'X'.

                lv_inc = lv_inc + 10.
                ls_ctrdata-itm_number = lv_inc.
                ls_ctrdata-con_st_dat = ls_vbrk-fkdat.
                IF ls_ctrdata-con_en_dat IS INITIAL.
                  ls_ctrdata-con_en_dat = ls_ctrdata-con_st_dat.
                ENDIF.

                lv_date = ls_ctrdata-con_en_dat.
                lv_day = ls_vss_mod_map-period.

                CALL FUNCTION 'HR_PSD_DATES_ADD_MONTHS'
                  EXPORTING
                    v_date       = lv_date "ls_ctrdata-con_en_dat
                    v_months     = lv_day
                  IMPORTING
                    e_date       = lv_date "ls_ctrdata-con_st_dat
                  EXCEPTIONS
                    not_positive = 1
                    OTHERS       = 2.
                ls_ctrdata-con_en_dat = lv_date.
                APPEND ls_ctrdata TO lt_ctrdata.
                CLEAR ls_ctrdata.

                ls_items-itm_number = lv_inc.
                ls_items-material   = ls_vss_mod_map-matnr.
                ls_items-plant      = ls_vbrp-werks.
                ls_items-target_qty = 1.
                APPEND ls_items TO lt_items.
                CLEAR ls_items.

                ls_vehi_com-posnr = lv_inc.
                GET TIME STAMP FIELD ls_vehi_com-tmstp.
                ls_vehi_com-vguid = ls_vlcvehicle-vguid.
                APPEND ls_vehi_com TO lt_vehi_com.
                CLEAR ls_vehi_com.
              ENDLOOP.

              CALL FUNCTION 'BAPI_CONTRACT_CREATEFROMDATA'
                EXPORTING
                  contract_header_in      = ls_header
                IMPORTING
                  salesdocument           = lv_order
                TABLES
                  return                  = lt_return
                  contract_items_in       = lt_items
                  contract_partners       = lt_partners
                  contract_data_in        = lt_ctrdata
                  contract_conditions_in  = lt_cond
                  contract_conditions_inx = lt_condx
                  extensionin             = lt_extensionin.

              READ TABLE lt_return INTO ls_return WITH KEY type = 'S'.

              IF sy-subrc EQ 0 AND lv_order IS NOT INITIAL.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = 'X'
*               IMPORTING
*                   RETURN        =
                  .

                LOOP AT lt_vehi_com ASSIGNING FIELD-SYMBOL(<fs_vehi_com>).
                  <fs_vehi_com>-vbeln = lv_order.
*              UPDATE veda SET mileage_start =  ls_vss_mod_map-km_from
                ENDLOOP.


                CALL FUNCTION '/DBE/CNT_VEHI_LIST_WRITE'
                  EXPORTING
                    it_vehi_db  = lt_vehi_db
                    it_vehi_com = lt_vehi_com.


              ENDIF.

              CLEAR : ls_header, lv_order.
              REFRESH : lt_return, lt_items, lt_partners, lt_ctrdata, lt_cond, lt_condx, lt_extensionin,lt_vehi_com.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ELSE.

    SELECT * FROM zvss_mod_con_map INTO TABLE @lt_vss_mod_map.

    SELECT vguid,vhcle,bwtar,vhvin,werks,matnr,/dbe/iobjguid FROM vlcvehicle INTO TABLE @lt_vlcvehicle
    WHERE  vhvin IN @s_vhvin.
    IF lt_vlcvehicle IS NOT INITIAL.
      SELECT * FROM zvss_vehi_cont INTO TABLE @lt_vss_vehi_cont
        FOR ALL ENTRIES IN @lt_vlcvehicle
        WHERE vguid EQ @lt_vlcvehicle-vguid.
      LOOP AT lt_vlcvehicle INTO ls_vlcvehicle.
        READ TABLE lt_vss_vehi_cont INTO ls_vss_vehi_cont WITH KEY vguid = ls_vlcvehicle-vguid.
        IF sy-subrc NE 0.
          CLEAR lv_inc.

          ls_header-doc_type   = 'ZUCF'.
          ls_header-sales_org  = ls_vbrk-vkorg.
          ls_header-distr_chan = ls_vbrk-vtweg.
          ls_header-division   = ls_vbrk-spart.

          ls_partners-partn_role = lc_soldtoparty.
          ls_partners-partn_numb = ls_vbrk-kunag.
          APPEND ls_partners TO lt_partners.
          CLEAR ls_partners.

          ls_partners-partn_role = lc_payer.
          ls_partners-partn_numb = ls_vbrk-kunrg.
          APPEND ls_partners TO lt_partners.
          CLEAR ls_partners.

          ls_partners-partn_role = lc_billtoparty.
          ls_partners-partn_numb = ls_vbrk-kunrg.
          APPEND ls_partners TO lt_partners.
          CLEAR ls_partners.

          LOOP AT lt_vss_mod_map INTO ls_vss_mod_map WHERE bukrs EQ ls_vbrk-bukrs AND
                                                           vkorg EQ ls_vbrk-vkorg AND
                                                           vtweg EQ ls_vbrk-vtweg AND
                                                           spart EQ ls_vbrk-spart AND
                                                           mcodesd EQ ls_vlcvehicle-matnr AND
                                                           sales_rel EQ 'X'.

            lv_inc = lv_inc + 10.
            ls_ctrdata-itm_number = lv_inc.
            ls_ctrdata-con_st_dat = ls_vbrk-fkdat.
            IF ls_ctrdata-con_en_dat IS INITIAL.
              ls_ctrdata-con_en_dat = ls_ctrdata-con_st_dat.
            ENDIF.

            lv_date = ls_ctrdata-con_en_dat.
            lv_day = ls_vss_mod_map-period.

            CALL FUNCTION 'HR_PSD_DATES_ADD_MONTHS'
              EXPORTING
                v_date       = lv_date "ls_ctrdata-con_en_dat
                v_months     = lv_day
              IMPORTING
                e_date       = lv_date "ls_ctrdata-con_st_dat
              EXCEPTIONS
                not_positive = 1
                OTHERS       = 2.
            ls_ctrdata-con_en_dat = lv_date.
            APPEND ls_ctrdata TO lt_ctrdata.
            CLEAR ls_ctrdata.

            ls_items-itm_number = lv_inc.
            ls_items-material   = ls_vss_mod_map-matnr.
            ls_items-plant      = ls_vbrp-werks.
            ls_items-target_qty = 1.
            APPEND ls_items TO lt_items.
            CLEAR ls_items.

            ls_vehi_com-posnr = lv_inc.
            GET TIME STAMP FIELD ls_vehi_com-tmstp.
            ls_vehi_com-vguid = ls_vlcvehicle-vguid.
            APPEND ls_vehi_com TO lt_vehi_com.
            CLEAR ls_vehi_com.
          ENDLOOP.

          CALL FUNCTION 'BAPI_CONTRACT_CREATEFROMDATA'
            EXPORTING
              contract_header_in      = ls_header
            IMPORTING
              salesdocument           = lv_order
            TABLES
              return                  = lt_return
              contract_items_in       = lt_items
              contract_partners       = lt_partners
              contract_data_in        = lt_ctrdata
              contract_conditions_in  = lt_cond
              contract_conditions_inx = lt_condx
              extensionin             = lt_extensionin.

          READ TABLE lt_return INTO ls_return WITH KEY type = 'S'.

          IF sy-subrc EQ 0 AND lv_order IS NOT INITIAL.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'
*               IMPORTING
*               RETURN        =
              .

            LOOP AT lt_vehi_com ASSIGNING <fs_vehi_com>.
              <fs_vehi_com>-vbeln = lv_order.
*              UPDATE veda SET mileage_start =  ls_vss_mod_map-km_from
            ENDLOOP.


            CALL FUNCTION '/DBE/CNT_VEHI_LIST_WRITE'
              EXPORTING
                it_vehi_db  = lt_vehi_db
                it_vehi_com = lt_vehi_com.


          ENDIF.

          CLEAR : ls_header, lv_order.
          REFRESH : lt_return, lt_items, lt_partners, lt_ctrdata, lt_cond, lt_condx, lt_extensionin,lt_vehi_com.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDIF.



ENDFORM.

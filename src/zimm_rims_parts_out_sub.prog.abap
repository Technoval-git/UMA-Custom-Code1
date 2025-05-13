*&---------------------------------------------------------------------*
*& Include          ZIMM_RIMS_PARTS_OUT_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .

  DATA : lv_date1 TYPE sy-datum,
         lv_date2 TYPE sy-datum.

  DATA : lt_year TYPE trgr_posting_year,
         ls_year TYPE trgs_posting_year.

  lv_date1 = s_date-low.
  ls_date-dates = lv_date1.
  APPEND ls_date TO lt_date.
  CLEAR ls_date.

  ls_year-sign = 'I'.
  ls_year-option = 'EQ'.
  ls_year-low = lv_date1+0(4).
  APPEND ls_year TO lt_year.
  CLEAR ls_year.

  IF s_date-low IS NOT INITIAL AND s_date-high IS NOT INITIAL.
    WHILE lv_date1 LE s_date-high.
      lv_date1 = lv_date1 + 1.
      ls_date-dates = lv_date1.
      APPEND ls_date TO lt_date.
      CLEAR ls_date.

      ls_year-sign = 'I'.
      ls_year-option = 'EQ'.
      ls_year-low = lv_date1+0(4).
      APPEND ls_year TO lt_year.
      CLEAR ls_year.

      ls_monyear-monyear = lv_date1+0(6).
      APPEND ls_monyear TO lt_monyear.
      CLEAR ls_monyear.
    ENDWHILE.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM lt_year COMPARING low.
  DELETE ADJACENT DUPLICATES FROM lt_monyear COMPARING monyear.

  SELECT * FROM zmm_golive INTO TABLE @DATA(lt_golive).

  SELECT * FROM mara INTO TABLE @DATA(lt_mara) WHERE matnr IN @s_matnr AND
                                                     mtart IN @s_mtart AND
                                                     matkl IN @s_matkl AND
                                                     bismt NE ''.

  IF lt_mara IS NOT INITIAL.

    SELECT * FROM zmm_gm INTO TABLE @DATA(lt_mm_gm)
            FOR ALL ENTRIES IN @lt_mara
            WHERE gm_matnr EQ @lt_mara-bismt.

    SELECT * FROM marc INTO TABLE @DATA(lt_marc) FOR ALL ENTRIES IN @lt_mara
      WHERE matnr EQ @lt_mara-matnr AND
            werks IN @s_werks AND
            dismm IN @s_dismm.

    SELECT * FROM mard INTO TABLE @DATA(lt_mard) FOR ALL ENTRIES IN @lt_mara
       WHERE matnr EQ @lt_mara-matnr AND
             werks IN @s_werks AND
             lgort EQ 'P001'.


    SELECT * FROM a004 INTO TABLE @DATA(lt_a004)
               FOR ALL ENTRIES IN @lt_mara
               WHERE matnr = @lt_mara-matnr AND kschl = 'YP01'
              AND  vkorg IN @s_vkorg
                AND datbi GE @sy-datum AND datab LE @sy-datum .

    SELECT * FROM resb INTO TABLE @DATA(lt_resb) FOR ALL ENTRIES IN @lt_mard
        WHERE matnr EQ @lt_mard-matnr AND
              werks EQ @lt_mard-werks AND
              lgort EQ @lt_mard-lgort." AND
*              kzear NE 'X'.


    SELECT * FROM ekpo INTO TABLE @DATA(lt_ekpo) FOR ALL ENTRIES IN @lt_mard
              WHERE matnr EQ @lt_mard-matnr AND
                    werks EQ @lt_mard-werks AND
                    lgort EQ @lt_mard-lgort AND
                    loekz EQ '' AND
                    elikz EQ '' AND
                    mtart IN @s_mtart AND
                    matkl IN @s_matkl.

    SELECT * FROM ekko INTO TABLE @DATA(lt_ekko) FOR ALL ENTRIES IN @lt_ekpo
             WHERE ebeln EQ @lt_ekpo-ebeln AND
                   bsart IN @s_bsart.

    SELECT * FROM ekbe INTO TABLE @DATA(lt_ekbe) FOR ALL ENTRIES IN @lt_ekko
             WHERE ebeln EQ @lt_ekko-ebeln.

    SELECT * FROM matdoc INTO TABLE @DATA(lt_matdoc) FOR ALL ENTRIES IN @lt_mard
                   WHERE matnr EQ @lt_mard-matnr AND
              werks EQ @lt_mard-werks AND
              lgort EQ @lt_mard-lgort AND
              bwart IN ( '261',  '901' , '641' , '262' , '902' , '642' ) AND
              bldat IN @s_date.

    SELECT * FROM mver INTO TABLE @DATA(lt_mver) FOR ALL ENTRIES IN @lt_mard
                       WHERE matnr EQ @lt_mard-matnr AND
                             werks EQ @lt_mard-werks AND
                             gjahr IN @lt_year.


    SELECT * FROM cdhdr INTO TABLE @DATA(lt_cdhdr)
             WHERE objectclas EQ '/DBE/ORDER'  AND
                   udate IN @s_date.

    SELECT * FROM cdpos INTO TABLE @DATA(lt_cdpos) FOR ALL ENTRIES IN @lt_cdhdr
             WHERE objectclas EQ '/DBE/ORDER'  AND
                   objectid EQ @lt_cdhdr-objectid AND
                   changenr EQ @lt_cdhdr-changenr AND
                   tabname EQ '/DBE/VBAP' AND
                   fname EQ 'ABGRU'.

    LOOP AT lt_cdpos INTO DATA(ls_cdpos).
      ls_vbeln-vbeln = ls_cdpos-objectid.
      APPEND ls_vbeln TO lt_vbeln.
      CLEAR ls_vbeln.
    ENDLOOP.

    SELECT * FROM /dbe/vbap INTO TABLE @DATA(lt_vbap) FOR ALL ENTRIES IN @lt_vbeln
         WHERE vbeln EQ @lt_vbeln-vbeln AND
               itcat IN ( 'P002', 'D020' ) AND
               abgru NE ''.

*    SELECT * FROM cdpos INTO TABLE lt_cdpos FOR ALL ENTRIES IN lt_cdhdr
*             WHERE objectclas EQ '/DBE/ORDER'  AND
*                   objectid EQ lt_cdhdr-objectid AND
*                   changenr EQ lt_cdhdr-changenr AND
*                   tabname EQ '/DBE/OE_VBAPST' AND
*                   tabkey LIKE '%ORD_CLOSE' AND
*                   fname EQ 'STATUS' AND
*                   value_new EQ 'C'.
*
*
*    REFRESH lt_vbeln.
*    LOOP AT lt_cdpos INTO ls_cdpos.
*      ls_vbeln-vbeln = ls_cdpos-objectid.
*      APPEND ls_vbeln TO lt_vbeln.
*      CLEAR ls_vbeln.
*    ENDLOOP.
*
*    SELECT * FROM /dbe/vbap INTO TABLE @DATA(lt_vbap_close) FOR ALL ENTRIES IN @lt_vbeln
*         WHERE vbeln EQ @lt_vbeln-vbeln AND
*               itcat IN ( 'P002', 'D020' ) AND
*               itstat EQ 'I070'.

    SELECT * FROM vbrk INTO TABLE @DATA(lt_vbrk) WHERE
        fkdat IN @s_date AND
        vkorg IN @s_vkorg AND
        spart IN @s_spart AND
        vbtyp IN ( 'M', 'N', 'O', 'S' ).

    IF lt_vbrk IS NOT INITIAL.
      SELECT * FROM vbrp INTO TABLE @DATA(lt_vbrp) FOR ALL ENTRIES IN @lt_vbrk
             WHERE vbeln EQ @lt_vbrk-vbeln AND
                   matkl IN  @s_matkl AND
                   werks IN @s_werks.
    ENDIF.

  ENDIF.

  DATA : date           TYPE sy-datum,
         lv_file_no(10) TYPE c.

  DATA : lv_unres            TYPE i,
         lv_unres_s(10)      TYPE c,
         lv_sold             TYPE i,
         lv_sold_s(10)       TYPE c,
         lv_last_sale        TYPE i,
         lv_last_sale_s(10)  TYPE c,
         lv_order            TYPE i,
         lv_order_s(10)      TYPE c,
         lv_back_order       TYPE i,
         lv_back_order_s(10) TYPE c,
         lv_reserv           TYPE i,
         lv_reserv_s(10)     TYPE c,
         lv_no_of_rec        TYPE i,
         lv_no_of_rec_s(10)  TYPE c,
         lv_lgpbe            TYPE lgpbe,
         lv_min              TYPE i,
         lv_min_s(10)        TYPE c,
         lv_max              TYPE i,
         lv_max_s(10)        TYPE c,
         lv_inv_p_class(2)   TYPE c,
         lv_part_code(10)    TYPE c,
         lv_reord_point(10)  TYPE c,
         lv_12m_s(10)        TYPE c,
         lv_12m_lost_s(10)   TYPE c,
         lv_return_d         TYPE i,
         lv_return(10)       TYPE c,
         lv_retail_p(10)     TYPE c,
         lv_stocking(10)     TYPE c,
         lv_mon_no_sale(10)  TYPE c,
         lv_qty_avail(10)    TYPE c,
         lv_replv_code(10)   TYPE c,
         lv_last_s_date(10)  TYPE c,
         lv_gi               TYPE i.


  date = sy-datum. "Today
  date+6(2) = '01'. "First day of this month
  date = date - 1. "Previous day before first day of this month = last day of last month

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZRIM_FILE'
    IMPORTING
      number      = lv_file_no.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  CONCATENATE 'PV.IDENT:' 'KW' ',' 'VSS 5.0' ',' '1.0' ',' sy-datum ',' sy-uzeit ',' p_dcode ',' '' ',' ' ' ',' 'GM' ',' 'RIM' ',' '' ',' 'GMME' ',' 'R24333' ',' '' ',' '' ',' '' ',' '' ',' '' ',' '' ',' '' INTO
  ls_tab-string.
  APPEND ls_tab TO lt_tab.
  CONCATENATE 'PV.HEADER:' date ',' '' ',' '' ',' lv_file_no INTO ls_tab-string.
  APPEND ls_tab TO lt_tab.

  SORT lt_mard ASCENDING BY matnr.

  LOOP AT lt_mard INTO DATA(ls_mard).

    lv_unres = lv_unres + ls_mard-labst.
    lv_lgpbe = ls_mard-lgpbe.

    READ TABLE lt_mara INTO DATA(la_mara) WITH KEY matnr = ls_mard-matnr.

    READ TABLE lt_marc INTO DATA(ls_marc) WITH KEY matnr = ls_mard-matnr werks = ls_mard-werks.
    IF sy-subrc EQ 0.
      lv_inv_p_class = ls_marc-maabc.
      lv_reord_point = ls_marc-minbe.
    ENDIF.

    LOOP AT lt_mver INTO DATA(ls_mver) WHERE matnr EQ ls_mard-matnr AND
                                            werks EQ ls_mard-werks.

      READ TABLE lt_golive INTO DATA(ls_golive) WITH KEY werks = ls_mard-werks matkl = la_mara-matkl.

      READ TABLE lt_date INTO ls_date WITH KEY dates = ls_golive-golive_date.
      IF sy-subrc EQ 0.
        LOOP AT lt_monyear INTO ls_monyear WHERE monyear+0(4) = ls_mver-gjahr.
          CASE ls_monyear+4(2).
            WHEN '01'.
              lv_sold = lv_sold + ls_mver-mgv01.
            WHEN '02'.
              lv_sold = lv_sold + ls_mver-mgv02.
            WHEN '03'.
              lv_sold = lv_sold + ls_mver-mgv03.
            WHEN '04'.
              lv_sold = lv_sold + ls_mver-mgv04.
            WHEN '05'.
              lv_sold = lv_sold + ls_mver-mgv05.
            WHEN '06'.
              lv_sold = lv_sold + ls_mver-mgv06.
            WHEN '07'.
              lv_sold = lv_sold + ls_mver-mgv07.
            WHEN '08'.
              lv_sold = lv_sold + ls_mver-mgv08.
            WHEN '09'.
              lv_sold = lv_sold + ls_mver-mgv09.
            WHEN '10'.
              lv_sold = lv_sold + ls_mver-mgv10.
            WHEN '11'.
              lv_sold = lv_sold + ls_mver-mgv11.
            WHEN '12'.
              lv_sold = lv_sold + ls_mver-mgv12.
          ENDCASE.

        ENDLOOP.
*      ELSE.
        LOOP AT lt_matdoc INTO DATA(ls_matdoc) WHERE matnr EQ ls_mard-matnr AND
                                              werks EQ ls_mard-werks AND
                                               lgort EQ ls_mard-lgort.
*          lv_sold = lv_sold + ls_matdoc-menge.
          IF ls_matdoc-bwart EQ '641'." OR ls_matdoc-bwart EQ '901' OR ls_matdoc-bwart EQ '261'.
            lv_sold = lv_sold - ls_matdoc-consumption_qty.
          ENDIF.

          IF ls_matdoc-bwart EQ '642'.
            lv_sold = lv_sold + ls_matdoc-consumption_qty.
          ENDIF.
        ENDLOOP.
      ELSE.

*        LOOP AT lt_matdoc INTO ls_matdoc WHERE matnr EQ ls_mard-matnr AND
*                                              werks EQ ls_mard-werks AND
*                                               lgort EQ ls_mard-lgort.
*          IF ls_matdoc-bwart EQ '901' OR ls_matdoc-bwart EQ '261'.
*            lv_sold = lv_sold + ls_matdoc-menge.
*          ENDIF.
*          IF ls_matdoc-bwart EQ '902' OR ls_matdoc-bwart EQ '262'.
*            lv_sold = lv_sold - ls_matdoc-menge.
*          ENDIF.
*        ENDLOOP.

*        LOOP AT lt_vbap_close INTO DATA(ls_vbap_close) WHERE matnr40 EQ ls_mard-matnr AND
*                                             werks EQ ls_mard-werks AND
*                                              lgort EQ ls_mard-lgort.
*          lv_sold = lv_sold + ls_vbap_close-zmeng.
*        ENDLOOP.

        LOOP AT lt_vbrp INTO DATA(ls_vbrp) WHERE matnr EQ ls_mard-matnr AND
                                                    werks EQ ls_mard-werks AND
                                                     lgort EQ ls_mard-lgort.
          READ TABLE lt_vbrk INTO DATA(ls_vbrk) WITH KEY vbeln = ls_vbrp-vbeln.
          IF sy-subrc EQ 0.
            IF ls_vbrk-vbtyp EQ 'M' OR ls_vbrk-vbtyp EQ 'S'.
              lv_sold = lv_sold + ls_vbrp-fklmg.
            ELSEIF ls_vbrk-vbtyp EQ 'N' OR ls_vbrk-vbtyp EQ 'O'.
              lv_sold = lv_sold - ls_vbrp-fklmg.
            ENDIF.

            IF ls_vbrk-vbtyp EQ 'O'.
              lv_return_d = lv_return_d + ls_vbrp-fklmg.
            ELSEIF ls_vbrk-vbtyp EQ 'S'.
              lv_return_d = lv_return_d - ls_vbrp-fklmg.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_resb INTO DATA(ls_resb) WHERE matnr EQ ls_mard-matnr AND
                                                 werks EQ ls_mard-werks AND
                                                  lgort EQ ls_mard-lgort.
      IF ls_resb-kzear NE 'X'.
        CASE ls_resb-shkzg .
          WHEN 'S'.    lv_reserv = lv_reserv - ls_resb-bdmng.
          WHEN OTHERS. lv_reserv = lv_reserv + ls_resb-bdmng.
        ENDCASE.
      ELSEIF ls_resb-kzear EQ 'X'.
        LOOP  AT lt_vbrp INTO DATA(ls_vbrp_r) WHERE matnr = ls_resb-matnr AND
                                                    werks = ls_resb-werks AND
*                                                    lgort = ls_resb-lgort AND
                                                    /dbe/vbeln = ls_resb-sgtxt+8(10) AND
                                                    /dbe/posnr = ls_resb-sgtxt+19(6) AND
                                                    /dbe/splnr = ls_resb-sgtxt+26(4).
          READ TABLE lt_vbrk INTO DATA(ls_vbrk_r) WITH KEY vbeln = ls_vbrp_r-vbeln.
          IF ls_vbrk_r-vbtyp EQ 'M' OR ls_vbrk_r-vbtyp EQ 'S'.
            lv_gi = lv_gi + ls_vbrp_r-fklmg.
          ELSEIF ls_vbrk_r-vbtyp EQ 'N' OR ls_vbrk_r-vbtyp EQ 'O'.
            lv_gi = lv_gi - ls_vbrp_r-fklmg.
          ENDIF.
        ENDLOOP.

        IF lv_gi EQ 0.
          lv_reserv = lv_reserv + ls_resb-bdmng.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_ekpo INTO DATA(ls_ekpo) WHERE matnr EQ ls_mard-matnr AND
                                                 werks EQ ls_mard-werks AND
                                                  lgort EQ ls_mard-lgort.
      READ TABLE lt_ekko INTO DATA(ls_ekko) WITH KEY ebeln = ls_ekpo-ebeln.
      IF sy-subrc EQ 0.
        lv_order = lv_order + ls_ekpo-menge.
        LOOP AT lt_ekbe INTO DATA(ls_ekbe) WHERE ebeln EQ ls_ekpo-ebeln AND ebelp EQ ls_ekpo-ebelp.
          CASE  ls_ekbe-shkzg.
            WHEN 'S'.
              lv_order = lv_order - ls_ekbe-menge.
            WHEN OTHERS.
              lv_order = lv_order + ls_ekbe-menge.
          ENDCASE.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_vbap INTO DATA(ls_vbap) WHERE matnr40 EQ ls_mard-matnr AND
                                                 werks EQ ls_mard-werks AND
                                                  lgort EQ ls_mard-lgort.
      lv_last_sale = lv_last_sale + ls_vbap-zmeng.
    ENDLOOP.

    READ TABLE lt_mm_gm INTO DATA(ls_mm_gm) WITH KEY gm_matnr = la_mara-bismt.
    IF sy-subrc EQ 0.
      lv_min = ls_mm_gm-gm_min_ord_qty.
      lv_max = ls_mm_gm-gm_merch_qty.
    ENDIF.
    lv_min = ceil( lv_min ).
    lv_max = ceil( lv_max ).
    lv_min_s = lv_min.
    lv_max_s = lv_max.
    AT END OF matnr.
      lv_no_of_rec  = lv_no_of_rec + 1.
*      DATA(lv_len) = strlen( la_mara-bismt ).
      DATA(lv_len) = strlen( la_mara-mfrpn ).
      DATA : lv_rem TYPE i.
      lv_rem = 18 - lv_len.
      DO lv_rem TIMES.
*        CONCATENATE '0' la_mara-bismt INTO la_mara-bismt.
        CONCATENATE '0' la_mara-mfrpn INTO la_mara-mfrpn.
      ENDDO.
      lv_unres = ceil( lv_unres ).
      lv_unres_s = lv_unres.
      IF lv_sold < 0.
        lv_sold = 0.
      ENDIF.
      lv_sold = ceil( lv_sold ).
      lv_sold_s = lv_sold.
      lv_last_sale = ceil( lv_last_sale ).
      lv_last_sale_s = lv_last_sale.
      lv_order = ceil( lv_order ).
      lv_order_s = lv_order.
      lv_back_order = ceil( lv_back_order ).
      lv_back_order_s = lv_back_order.
      lv_reserv = ceil( lv_reserv  ).
      lv_reserv_s = lv_reserv.
      lv_return_d = ceil( lv_return_d ).
      lv_return = lv_return_d.
      CONCATENATE 'PV.LINEITEM:' la_mara-mfrpn ',' lv_unres_s ',' lv_sold_s ',' lv_last_sale_s ',' lv_inv_p_class ',' lv_part_code ','  lv_order_s ',' lv_reord_point ','
                                 lv_12m_s ',' lv_lgpbe ',' lv_12m_lost_s ',' lv_back_order_s ',' lv_return ',' lv_reserv_s  ',' lv_retail_p ',' lv_stocking ',' lv_mon_no_sale ','
                                 lv_qty_avail ',' lv_replv_code ',' lv_last_s_date ',' lv_min_s ',' lv_max_s INTO ls_tab-string.
      CONDENSE ls_tab-string.
      APPEND ls_tab TO lt_tab.
      CLEAR: ls_tab, lv_unres, lv_unres_s, lv_sold, lv_sold_s, lv_last_sale, lv_last_sale_s, lv_order, lv_order_s, lv_back_order, lv_back_order_s, lv_reserv,lv_reserv_s,
             lv_min, lv_min_s, lv_max, lv_max_s.
    ENDAT.
  ENDLOOP.
  lv_no_of_rec_s = lv_no_of_rec.
  CONCATENATE 'PV.TRAILER:' lv_no_of_rec_s INTO ls_tab-string.
  APPEND ls_tab TO lt_tab.



  DATA : v_fname TYPE string,
         dummy   TYPE c.


  IF p_fname IS NOT INITIAL.
    v_fname = p_fname.
    SPLIT v_fname AT '.' INTO v_fname dummy.
    CONCATENATE v_fname '.txt' INTO v_fname.

    IF sy-batch NE abap_true.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename              = v_fname
          filetype              = 'ASC'
          write_field_separator = 'X'
        TABLES
          data_tab              = lt_tab.
      IF sy-subrc = 0.
        MESSAGE 'DATA IS SUCCESSFULLY DOWNLOADED' TYPE 'I'.
      ENDIF.
    ELSE.

      DATA lv_tab_str TYPE string.
      CONCATENATE p_infile '.txt' INTO p_infile.

      OPEN DATASET p_infile FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

      LOOP AT lt_tab INTO ls_tab.

        lv_tab_str = ls_tab-string.
        TRANSFER lv_tab_str TO p_infile.

      ENDLOOP.



      CLOSE DATASET p_infile.
    ENDIF.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_FILE_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_file_name .
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      program_name  = syst-repid
      dynpro_number = syst-dynnr
      field_name    = 'P_FNAME'
    CHANGING
      file_name     = p_fname.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.

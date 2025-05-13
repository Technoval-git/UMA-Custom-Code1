FUNCTION zwty_upload_temp.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(WTY_UPLOAD) TYPE  ZWTY_HNG_TABLE OPTIONAL
*"     REFERENCE(CS_PNWTYH_DIA) TYPE  WTY_PNWTYH_DIA
*"     REFERENCE(CT_PNWTYV_DIA) TYPE  WTY_PNWTYV_DIA_TAB
*"     REFERENCE(CT_PVWTY_DIA) TYPE  WTY_PVWTY_DIA_TAB
*"  EXPORTING
*"     REFERENCE(RETURN) TYPE  BAPIRETURN
*"----------------------------------------------------------------------


  DATA: ls_pnwtyv_dia     TYPE wty_pnwtyv_dia,
        lt_pvwty_dia_ver  TYPE wty_pvwty_dia_tab,
        ls_pvwty_dia_ver  TYPE wty_pvwty_dia,
        lt_pvwty_dia_ver2 TYPE wty_pvwty_dia_tab,
        ls_admin_data     TYPE wty_admin_data.

  DATA : ls_pnwtyh TYPE pnwtyh,
         lt_pnwtyv TYPE STANDARD TABLE OF pnwtyv,
         ls_pnwtyv TYPE pnwtyv,
         lt_pvwty  TYPE STANDARD TABLE OF pvwty,
         ls_pvwty  TYPE pvwty.

  DATA : ls_komv        TYPE komv,
         lv_tot_lab     TYPE wty_betrg,
         lv_tot_mat     TYPE wty_betrg,
         lv_tot_sub     TYPE wty_betrg,
         lv_tot         TYPE wty_betrg,
         lv_tot_lab_per TYPE wty_betrg,
         lv_tot_mat_per TYPE wty_betrg,
         lv_tot_sub_per TYPE wty_betrg,
         lv_actual      TYPE wty_betrg.

  DATA : is_pnwtyh_dia TYPE  wty_pnwtyh_dia,
         is_pnwtyv_dia TYPE wty_pnwtyv_dia,
         ls_pvwty_dia  TYPE wty_pvwty_dia.

  DATA: lt_text  TYPE wty_texts_tab,
        ls_text  TYPE wty_texts,
        lt_lines TYPE TABLE OF tline,
        ls_lines TYPE tline.

  DATA : ls_wty_hng_table TYPE zwty_hng_table.

  FIELD-SYMBOLS: <fs_pvwty_dia> TYPE wty_pvwty_dia.

  SELECT * FROM zwty_cond_map INTO TABLE @DATA(lt_wty_cond_map).


  SELECT SINGLE * FROM zwty_hng_table INTO ls_wty_hng_table WHERE clmno EQ cs_pnwtyh_dia-clmno AND hng_clm_no EQ  cs_pnwtyh_dia-zoem_claim.

  IF sy-subrc EQ 0.

************************************************************************
*  Select the right version
************************************************************************
*    CALL METHOD zcl_vss_wty_util=>get_selected_version
*      EXPORTING
*        is_pnwtyh_dia    = cs_pnwtyh_dia
*        it_pnwtyv_dia    = ct_pnwtyv_dia
*        it_pvwty_dia     = ct_pvwty_dia
*      IMPORTING
*        es_pnwtyv_dia    = ls_pnwtyv_dia
*        et_pvwty_dia_ver = lt_pvwty_dia_ver.


    CALL METHOD cl_ppeliwty_cntl=>claim_read_buffer
      EXPORTING
        iv_with_long_texts = 'X'
        iv_header_guid     = cs_pnwtyh_dia-pnguid
      IMPORTING
        et_texts           = lt_text
      EXCEPTIONS
        header_not_found   = 1
        version_not_found  = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG.
    ENDIF.

    LOOP AT ct_pnwtyv_dia INTO is_pnwtyv_dia WHERE kateg EQ 'OV' AND lf_flag EQ 'X'.
      LOOP AT ct_pvwty_dia  ASSIGNING <fs_pvwty_dia> WHERE version_guid EQ is_pnwtyv_dia-pnguid.

        CALL FUNCTION 'WTY15_PRICING_KSCHL_GET'
          EXPORTING
            iv_kschl    = 'ZPRC'
            iv_posnr    = <fs_pvwty_dia>-posnr
            iv_ver_guid = is_pnwtyv_dia-pnguid
          IMPORTING
            es_komv     = ls_komv
          EXCEPTIONS
            not_found   = 1
            OTHERS      = 2.
        IF sy-subrc <> 0.
          CLEAR ls_komv.
        ENDIF.

        IF <fs_pvwty_dia>-poskt EQ 'FR'.
          lv_tot_lab = lv_tot_lab + ls_komv-kbetr.
        ELSEIF <fs_pvwty_dia>-poskt EQ 'MAT'.
          lv_tot_mat = lv_tot_mat + ls_komv-kbetr.
        ELSEIF <fs_pvwty_dia>-poskt EQ 'SUBL'.
          lv_tot_sub = lv_tot_sub + ls_komv-kbetr.
        ENDIF.
        lv_tot = lv_tot + ls_komv-kbetr.
      ENDLOOP.
    ENDLOOP.
    LOOP AT ct_pnwtyv_dia INTO is_pnwtyv_dia WHERE kateg EQ 'IV' AND lf_flag EQ 'X'.
      LOOP AT ct_pvwty_dia  ASSIGNING <fs_pvwty_dia> WHERE version_guid EQ is_pnwtyv_dia-pnguid.
        MOVE-CORRESPONDING <fs_pvwty_dia> TO ls_pvwty_dia.
        CALL FUNCTION 'WTY15_PRICING_KSCHL_GET'
          EXPORTING
            iv_kschl    = 'ZPRC'
            iv_posnr    = <fs_pvwty_dia>-posnr
            iv_ver_guid = is_pnwtyv_dia-pnguid
          IMPORTING
            es_komv     = ls_komv
          EXCEPTIONS
            not_found   = 1
            OTHERS      = 2.

        IF sy-subrc <> 0.
          CLEAR ls_komv.
        ENDIF.

        IF <fs_pvwty_dia>-poskt_cust EQ 'FR' OR <fs_pvwty_dia>-poskt_cust EQ 'FRS' OR <fs_pvwty_dia>-poskt_cust EQ 'FRC'.
          READ TABLE lt_wty_cond_map INTO DATA(lv_wty_cond_map) WITH KEY clmty = cs_pnwtyh_dia-clmty
                                                                         poskt_cust = <fs_pvwty_dia>-poskt_cust.
*          lv_tot_lab_per =  ( ls_komv-kbetr / lv_tot_lab ) * 100.
*          lv_actual = ( ls_wty_hng_table-tot_lab_approved * lv_tot_lab_per ) / 100.
          lv_tot_lab_per =  ( ls_komv-kbetr / lv_tot ) * 100.
          lv_actual = ( ls_wty_hng_table-tot_grs_approved * lv_tot_lab_per ) / 100.
          ls_pvwty_dia-kschl = lv_wty_cond_map-kschl.
          ls_pvwty_dia-betrg = lv_actual.
        ELSEIF <fs_pvwty_dia>-poskt_cust EQ 'MAT' OR <fs_pvwty_dia>-poskt_cust EQ 'MATS' OR <fs_pvwty_dia>-poskt_cust EQ 'MATC'.
          READ TABLE lt_wty_cond_map INTO lv_wty_cond_map WITH KEY clmty = cs_pnwtyh_dia-clmty
                                                                         poskt_cust = <fs_pvwty_dia>-poskt_cust.
*          lv_tot_mat_per = ( ls_komv-kbetr / lv_tot_mat ) * 100.
*           lv_actual = ( ls_wty_hng_table-tot_prt_approved * lv_tot_mat_per ) / 100.
          lv_tot_mat_per = ( ls_komv-kbetr / lv_tot ) * 100.
          lv_actual = ( ls_wty_hng_table-tot_grs_approved * lv_tot_mat_per ) / 100.
          ls_pvwty_dia-kschl = lv_wty_cond_map-kschl.
          ls_pvwty_dia-betrg = lv_actual.
        ELSEIF <fs_pvwty_dia>-poskt_cust EQ 'SUBL' OR <fs_pvwty_dia>-poskt_cust EQ 'SUBS'.
          READ TABLE lt_wty_cond_map INTO lv_wty_cond_map WITH KEY clmty = cs_pnwtyh_dia-clmty
                                                                         poskt_cust = <fs_pvwty_dia>-poskt_cust.
*          lv_tot_sub_per = ( ls_komv-kbetr / lv_tot_sub ) * 100.
*          lv_actual = ( ls_wty_hng_table-tot_con_approved * lv_tot_sub_per ) / 100.
          lv_tot_sub_per = ( ls_komv-kbetr / lv_tot ) * 100.
          lv_actual = ( ls_wty_hng_table-tot_grs_approved * lv_tot_sub_per ) / 100.
          ls_pvwty_dia-kschl = lv_wty_cond_map-kschl.
          ls_pvwty_dia-betrg = lv_actual.
        ENDIF.




        CALL FUNCTION 'WTY15_PRICING_COND_EXTERNAL'
          EXPORTING
            is_pnwtyh_dia = cs_pnwtyh_dia
            is_pnwtyv_dia = is_pnwtyv_dia
            is_pvwty_dia  = ls_pvwty_dia.


        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.


        CALL FUNCTION 'WTY15_PRICING_ITEM'
          EXPORTING
            is_pnwtyh_dia = cs_pnwtyh_dia
            is_pnwtyv_dia = is_pnwtyv_dia
            is_pvwty_dia  = ls_pvwty_dia
            iv_dchange    = 'M'.

      ENDLOOP.
    ENDLOOP.

  ENDIF.
ENDFUNCTION.

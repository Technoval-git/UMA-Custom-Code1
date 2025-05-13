CLASS zvss_wty_data_get DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA:
      mt_wt20_jet_tb TYPE STANDARD TABLE OF zwty_hng_table.

    CONSTANTS:
      BEGIN OF mc_status,
        success TYPE c VALUE 'S',
        error   TYPE c VALUE 'E',
      END OF mc_status .
    CONSTANTS mc_action TYPE wty_acode VALUE 'Z006' ##NO_TEXT.
    CONSTANTS mc_rejected TYPE wty_rejcd VALUE 'DE' ##NO_TEXT.
    DATA mv_rejected TYPE c .

    METHODS process
      IMPORTING
        !io_log        TYPE REF TO zvss_ifm_cl_x_log
      CHANGING
        !ct_pvwty_dia  TYPE wty_pvwty_dia_tab
        !cs_pnwtyh_dia TYPE wty_pnwtyh_dia
        !ct_pnwtyv_dia TYPE wty_pnwtyv_dia_tab
      RAISING
        ZVSS_CX_IFM_LOG.
*    METHODS set_status
*      IMPORTING
*        !io_log    TYPE REF TO ZVSS_IFM_CL_X_LOG
*        !iv_status TYPE C
*      RAISING
*        ZVSS_IFM_CL_X_LOG .
  PRIVATE SECTION.

*    DATA ms_config TYPE yid1_i02p_jet_tb .

*    METHODS read_i02_data
*      IMPORTING
*        !io_log         TYPE REF TO ZVSS_IFM_CL_X_LOG
**        !iv_vega_clmno  TYPE yid1_i02_clamno2_de
*        !lv_sap_clmno   TYPE /dbe/vbeln_va
*        !lv_sap_clmno_n TYPE wty_clmno
*      RAISING
*        ZVSS_CX_IFM_LOG.
*    METHODS job_condition_insert
*      IMPORTING
*        !iv_kschl      TYPE wty_kschl
*        !it_pvwty_dia  TYPE wty_pvwty_dia_tab
*        !iv_betrg      TYPE wty_betrg
**        !iv_dseqno     TYPE yid1_eva_damseq_de
*        !is_pnwtyh_dia TYPE wty_pnwtyh_dia
*        !is_pnwtyv_dia TYPE wty_pnwtyv_dia
*        !iv_poskt      TYPE wty_poskt .
*    METHODS job_condition_insert_prz
*      IMPORTING
*        !it_pvwty_dia  TYPE wty_pvwty_dia_tab
*        !iv_kschl      TYPE wty_kschl
*        !iv_betrg      TYPE wty_betrg
**        !iv_dseqno     TYPE yid1_eva_damseq_de
*        !is_pnwtyh_dia TYPE wty_pnwtyh_dia
*        !is_pnwtyv_dia TYPE wty_pnwtyv_dia .
*    METHODS text_line_add
*      IMPORTING
*        !iv_text      TYPE string
**        !iv_dseqno    TYPE yid1_eva_damseq_de
*        !it_pvwty_dia TYPE wty_pvwty_dia_tab
*      CHANGING
*        !ct_texts     TYPE wty_texts_tab .
*    METHODS job_condition_insert_claimed
*      IMPORTING
*        !iv_kschl      TYPE wty_kschl
*        !it_pvwty_dia  TYPE wty_pvwty_dia_tab
*        !iv_betrg      TYPE wty_betrg
**        !iv_dseqno     TYPE yid1_eva_damseq_de
*        !is_pnwtyh_dia TYPE wty_pnwtyh_dia
*        !is_pnwtyv_dia TYPE wty_pnwtyv_dia
*        !iv_poskt      TYPE wty_poskt .
ENDCLASS.



CLASS ZVSS_WTY_DATA_GET IMPLEMENTATION.


  METHOD process.

    DATA: ls_pnwtyv_dia     TYPE wty_pnwtyv_dia,
          lt_pvwty_dia_ver  TYPE wty_pvwty_dia_tab,
          ls_pvwty_dia_ver  TYPE wty_pvwty_dia,
          lt_pvwty_dia_ver2 TYPE wty_pvwty_dia_tab,
          ls_admin_data     TYPE wty_admin_data,
          lv_amount         TYPE wty_betrg,
          lv_text           TYPE string,
          lv_dummy          TYPE c,
          lv_posnr_job_max  TYPE wty_posnr,
          ls_pvwty_dia_new  TYPE wty_pvwty_dia,
          ls_komv           TYPE komv,
          lv_spl_ind        TYPE /dbe/split_indicator,
          lv_spl_ind_i_e    TYPE char01,
          ls_pvwty_dia      TYPE wty_pvwty_dia,
*          lv_damseq         TYPE yid1_eva_damseq_de,
*          lv_posseq         TYPE yid1_eva_posseq_de,
          lv_error          TYPE xfeld,
          lv_vkorg          TYPE vkorg,
          lv_matnr          TYPE matnr,
          lv_dummy_s        TYPE c,
          lv_core_p         TYPE wty_betrg,
          lv_core_h         TYPE wty_betrg.

    DATA : lt_core_comp    TYPE TABLE OF rvari_val_255.

    FIELD-SYMBOLS: <fs_pvwty_dia> TYPE wty_pvwty_dia.

************************************************************************
*  Read configuration
************************************************************************
*    SELECT SINGLE * FROM yid1_i02p_jet_tb CLIENT SPECIFIED
*    INTO ms_config
*    WHERE mandt = sy-mandt.
*    IF sy-subrc <> 0.
*      MESSAGE e129(ydbm_id1) INTO lv_dummy.
*      io_log->add_msg( ).
*      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG.
*    ENDIF.
*
*************************************************************************
**  Read data
*************************************************************************
*    read_i02_data( io_log        = io_log
**                   iv_vega_clmno = cs_pnwtyh_dia-yid1_vega_no
*                   lv_sap_clmno = cs_pnwtyh_dia-/dbe/vbeln
*                   lv_sap_clmno_n = cs_pnwtyh_dia-clmno ).
*
*************************************************************************
**  Select the right version
*************************************************************************
*    CALL METHOD zcl_vss_wty_util=>get_selected_version
*      EXPORTING
*        is_pnwtyh_dia    = cs_pnwtyh_dia
*        it_pnwtyv_dia    = ct_pnwtyv_dia
*        it_pvwty_dia     = ct_pvwty_dia
*      IMPORTING
*        es_pnwtyv_dia    = ls_pnwtyv_dia
*        et_pvwty_dia_ver = lt_pvwty_dia_ver.
*
*    SELECT SINGLE audat FROM /dbe/vbak_db
*      INTO @DATA(lv_vbak_audat)
*      WHERE vbeln = @cs_pnwtyh_dia-/dbe/vbeln.
*    IF sy-subrc = 0.
*      ls_pnwtyv_dia-prsdt = lv_vbak_audat.
*
**      SELECT SINGLE kbetr
**        FROM a939 AS a
**        INNER JOIN konp AS k
**        ON ( a~knumh = k~knumh
**        AND a~kschl = k~kschl )
**        INTO @DATA(lv_vat)
**        WHERE a~kappl = 'RW'
**          AND a~kschl = 'ZVAT'
**          AND a~wty_kateg = 'IV'
**          AND a~aland = 'SA'
**          AND a~land1 = 'SA'
**          AND a~datbi GE @lv_vbak_audat
**          AND a~datab LE @lv_vbak_audat.
**      IF sy-subrc = 0.
**        DATA: lv_total_perc TYPE int4.
**        lv_total_perc = 100 + ( lv_vat / 10 ).
**      ENDIF.
**    ENDIF.
*
*************************************************************************
**  Delete all previously inserted conditions
*************************************************************************
*    DATA: lt_kschl TYPE TABLE OF kschl,
*          lv_kschl TYPE kschl.
*
**    lv_kschl = ms_config-reduction_fr_abs.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reduction_handl_abs.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reduction_mat_abs.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-remaining_mat.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reduction_subl_abs.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reimb_fr.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reimb_fr_perc.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reimb_handl.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-cust_share_handl_perc.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reimb_handl_perc.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reimb_mat.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reimb_mat_perc.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reimb_subl.
**    APPEND lv_kschl TO lt_kschl.
**    lv_kschl = ms_config-reimb_subl_perc.
**    APPEND lv_kschl TO lt_kschl.
*    lv_kschl = 'ZL01'.
*    APPEND lv_kschl TO lt_kschl.
*    lv_kschl = 'ZM01'.
*    APPEND lv_kschl TO lt_kschl.
*    lv_kschl = 'ZS01'.
*    APPEND lv_kschl TO lt_kschl.
*
*    SELECT SINGLE vkorg FROM t001w
*                 INTO lv_vkorg
*                 WHERE werks EQ cs_pnwtyh_dia-werks.
*
*    SELECT low FROM tvarvc CLIENT SPECIFIED
*               INTO TABLE lt_core_comp
*               WHERE mandt = '000' AND
*               name  = 'CORE_COMP_VAL' AND
*               low = lv_vkorg.
*
*    ENDIF.
*
*
*
*
*    LOOP AT lt_pvwty_dia_ver ASSIGNING <fs_pvwty_dia>.
*
*      LOOP AT lt_kschl INTO lv_kschl.
*        CALL FUNCTION 'WTY15_PRICING_ITEM_DELETE'
*          EXPORTING
*            is_pnwtyv_dia = ls_pnwtyv_dia
*            iv_posnr      = <fs_pvwty_dia>-posnr
*            iv_kschl      = lv_kschl.
*      ENDLOOP.
*
*      CLEAR <fs_pvwty_dia>-rejcd.
*
*      MODIFY ct_pvwty_dia FROM <fs_pvwty_dia>
*             TRANSPORTING rejcd
*             WHERE pvguid = <fs_pvwty_dia>-pvguid.
*
*    ENDLOOP.
*
*************************************************************************
**  Read claim texts to update
*************************************************************************
*    DATA: lt_text  TYPE wty_texts_tab,
*          ls_text  TYPE wty_texts,
*          lt_lines TYPE TABLE OF tline,
*          ls_lines TYPE tline.
*
*
*    CALL METHOD cl_ppeliwty_cntl=>claim_read_buffer
*      EXPORTING
*        iv_with_long_texts = pwty_true
*        iv_header_guid     = cs_pnwtyh_dia-pnguid
*      IMPORTING
*        et_texts           = lt_text
*      EXCEPTIONS
*        header_not_found   = 1
*        version_not_found  = 2
*        OTHERS             = 3.
*    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG.
*    ENDIF.
*
*
*
** Process I02/20 ----------------------------------------------------
*    LOOP AT mt_wt20_jet_tb ASSIGNING FIELD-SYMBOL(<ls_wt20_jet_tb>).
**   Wenn alle Werte null sind, dann liefert Eva trotzdenm 100% als Prozentsatz.
**   In diesem Fall alle Prozentsätze auch auf null setzen.
*      IF <ls_wt20_jet_tb>-tot_lab_approved IS INITIAL AND
*         <ls_wt20_jet_tb>-tot_prt_approved IS INITIAL AND
*         <ls_wt20_jet_tb>-tot_con_approved IS INITIAL AND
*         <ls_wt20_jet_tb>-tot_mng_approved IS INITIAL.
*        mv_rejected = 'X'.
*      ENDIF.
*
*
*
*      IF sy-subrc <> 0 AND
*        ( <ls_wt20_jet_tb>-tot_lab_approved <> 0 OR
*          <ls_wt20_jet_tb>-tot_prt_approved <> 0 OR
*          <ls_wt20_jet_tb>-tot_con_approved <> 0 OR
*          <ls_wt20_jet_tb>-tot_con_approved <> 0 ).
*
**     get maximum item number of JOB-Items
*        CLEAR lv_posnr_job_max.
*        LOOP AT lt_pvwty_dia_ver ASSIGNING <fs_pvwty_dia>
*                WHERE poskt_cust = 'JOB'.
*          IF <fs_pvwty_dia>-posnr > lv_posnr_job_max.
*            lv_posnr_job_max = <fs_pvwty_dia>-posnr.
*          ENDIF.
*        ENDLOOP.
*        lv_posnr_job_max = lv_posnr_job_max + 1000.
*
*        CLEAR lt_pvwty_dia_ver2[].
*        lt_pvwty_dia_ver2 = lt_pvwty_dia_ver. "use other table, because it may not be appended to in the loop.
*
*        LOOP AT lt_pvwty_dia_ver ASSIGNING <fs_pvwty_dia>.
**                WHERE yid1_damseq = <ls_wt20_jet_tb>-dseqno.
*
*          CLEAR: ls_pvwty_dia_new, ls_komv.
*
*          CALL FUNCTION 'WTY15_PRICING_KSCHL_GET'
*            EXPORTING
*              iv_kschl    = 'ZPRC'
*              iv_posnr    = <fs_pvwty_dia>-posnr
*              iv_ver_guid = ls_pnwtyv_dia-pnguid
*            IMPORTING
*              es_komv     = ls_komv
*            EXCEPTIONS
*              not_found   = 1
*              OTHERS      = 2.
*          IF sy-subrc <> 0.
*            CLEAR ls_komv.
*          ENDIF.
*
*          ls_pvwty_dia_new-kschl = 'ZPRC'.
*          ls_pvwty_dia_new-betrg = ls_komv-kwert.
*
*          CALL FUNCTION 'WTY15_PRICING_COND_EXTERNAL'
*            EXPORTING
*              is_pnwtyh_dia = cs_pnwtyh_dia
*              is_pnwtyv_dia = ls_pnwtyv_dia
*              is_pvwty_dia  = ls_pvwty_dia_new.
*
*          IF ls_pvwty_dia_new-poskt EQ 'FR'.
*            ls_pvwty_dia_new-kschl = 'ZL01'.
*          ELSEIF ls_pvwty_dia_new-poskt EQ 'MAT'.
*            ls_pvwty_dia_new-kschl = 'ZM01'.
*          ELSEIF ls_pvwty_dia_new-poskt EQ 'SUBL'.
*            ls_pvwty_dia_new-kschl = 'ZS01'.
*          ENDIF.
*
*          ls_pvwty_dia_new-betrg = ls_komv-kwert.
*
*          CALL FUNCTION 'WTY15_PRICING_COND_EXTERNAL'
*            EXPORTING
*              is_pnwtyh_dia = cs_pnwtyh_dia
*              is_pnwtyv_dia = ls_pnwtyv_dia
*              is_pvwty_dia  = ls_pvwty_dia_new.
*
*        ENDLOOP.
*      ENDIF.
*
**   process record
*
*      lv_amount = <ls_wt20_jet_tb>-tot_lab_approved. " / 100.
**      IF <ls_wt20_jet_tb>-silabc = '-'.
**        lv_amount = lv_amount * ( -1 ).
**        CLEAR ls_tot_lab_approved_adjust.
**        READ TABLE lt_tot_lab_approved_adjust INTO ls_tot_lab_approved_adjust
**                   WITH KEY damseq = <ls_wt20_jet_tb>-dseqno.
**        IF ls_tot_lab_approved_adjust-adjust < 0.
**          ls_tot_lab_approved_adjust-adjust = ls_tot_lab_approved_adjust-adjust * ( -1 ).
**        ENDIF.
**        lv_amount = lv_amount + ls_tot_lab_approved_adjust-adjust.
**      ENDIF.
*
*      CALL METHOD me->job_condition_insert
*        EXPORTING
*          it_pvwty_dia  = lt_pvwty_dia_ver
*          iv_kschl      = 'ZL01'   "ms_config-reimb_fr
*          iv_poskt      = pwty_poskt-fr
*          iv_betrg      = lv_amount
**          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
*          is_pnwtyh_dia = cs_pnwtyh_dia
*          is_pnwtyv_dia = ls_pnwtyv_dia.
*
**      lv_amount = <ls_wt20_jet_tb>-plabcu.
***      CALL METHOD me->job_condition_insert_prz
**        EXPORTING
**          it_pvwty_dia  = lt_pvwty_dia_ver
**          iv_kschl      = ms_config-cust_share_fr_perc
**          iv_betrg      = lv_amount
***          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
**          is_pnwtyh_dia = cs_pnwtyh_dia
**          is_pnwtyv_dia = ls_pnwtyv_dia.
*
**      lv_amount = <ls_wt20_jet_tb>-plab.
**      CALL METHOD me->job_condition_insert_prz
**        EXPORTING
**          it_pvwty_dia  = lt_pvwty_dia_ver
**          iv_kschl      = ms_config-reimb_fr_perc
**          iv_betrg      = lv_amount
***          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
**          is_pnwtyh_dia = cs_pnwtyh_dia
**          is_pnwtyv_dia = ls_pnwtyv_dia.
*
*
*      lv_amount = <ls_wt20_jet_tb>-tot_prt_approved." / 100.
**      IF <ls_wt20_jet_tb>-sipart = '-'.
**        lv_amount = lv_amount * ( -1 ).
**        CLEAR ls_tot_prt_approved_adjust.
**        READ TABLE lt_tot_prt_approved_adjust INTO ls_tot_prt_approved_adjust
**                   WITH KEY damseq = <ls_wt20_jet_tb>-dseqno.
**        IF ls_tot_prt_approved_adjust-adjust < 0.
**          ls_tot_prt_approved_adjust-adjust = ls_tot_prt_approved_adjust-adjust * ( -1 ).
**        ENDIF.
**        lv_amount = lv_amount + ls_tot_prt_approved_adjust-adjust.
**      ENDIF.
*
*      CALL METHOD me->job_condition_insert
*        EXPORTING
*          it_pvwty_dia  = lt_pvwty_dia_ver
*          iv_kschl      = 'ZM01' "ms_config-reimb_mat
*          iv_poskt      = 'MAT' "pwty_poskt-mat
*          iv_betrg      = lv_amount
**          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
*          is_pnwtyh_dia = cs_pnwtyh_dia
*          is_pnwtyv_dia = ls_pnwtyv_dia.
*
**      lv_amount = <ls_wt20_jet_tb>-ppar.
**      CALL METHOD me->job_condition_insert_prz
**        EXPORTING
**          it_pvwty_dia  = lt_pvwty_dia_ver
**          iv_kschl      = ms_config-reimb_mat_perc
**          iv_betrg      = lv_amount
***          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
**          is_pnwtyh_dia = cs_pnwtyh_dia.
**          is_pnwtyv_dia = ls_pnwtyv_dia.
**
**      lv_amount = <ls_wt20_jet_tb>-pparcu.
**      CALL METHOD me->job_condition_insert_prz
**        EXPORTING
**          it_pvwty_dia  = lt_pvwty_dia_ver
**          iv_kschl      = ms_config-cust_share_mat_perc
**          iv_betrg      = lv_amount
***          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
**          is_pnwtyh_dia = cs_pnwtyh_dia
**          is_pnwtyv_dia = ls_pnwtyv_dia.
*
*      lv_amount = <ls_wt20_jet_tb>-tot_con_approved. " / 100.
**      IF <ls_wt20_jet_tb>-sisubl = '-'.
**        lv_amount = lv_amount * ( -1 ).
**        CLEAR ls_tot_con_approved_adjust.
**        READ TABLE lt_tot_con_approved_adjust INTO ls_tot_con_approved_adjust
**                   WITH KEY damseq = <ls_wt20_jet_tb>-dseqno.
**        IF ls_tot_con_approved_adjust-adjust < 0.
**          ls_tot_con_approved_adjust-adjust = ls_tot_con_approved_adjust-adjust * ( -1 ).
**        ENDIF.
**        lv_amount = lv_amount + ls_tot_con_approved_adjust-adjust.
**      ENDIF.
*      CALL METHOD me->job_condition_insert
*        EXPORTING
*          it_pvwty_dia  = lt_pvwty_dia_ver
*          iv_kschl      = 'ZS01'  "ms_config-reimb_subl
*          iv_poskt      = 'SUBL' "pwty_poskt-subl
*          iv_betrg      = lv_amount
**          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
*          is_pnwtyh_dia = cs_pnwtyh_dia
*          is_pnwtyv_dia = ls_pnwtyv_dia.
*
**      lv_amount = <ls_wt20_jet_tb>-psub.
**      CALL METHOD me->job_condition_insert_prz
**        EXPORTING
**          it_pvwty_dia  = lt_pvwty_dia_ver
**          iv_kschl      = ms_config-reimb_subl_perc
**          iv_betrg      = lv_amount
***          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
**          is_pnwtyh_dia = cs_pnwtyh_dia
**          is_pnwtyv_dia = ls_pnwtyv_dia.
**
**      lv_amount = <ls_wt20_jet_tb>-psubcu.
**      CALL METHOD me->job_condition_insert_prz
**        EXPORTING
**          it_pvwty_dia  = lt_pvwty_dia_ver
**          iv_kschl      = ms_config-cust_share_subl_perc
**          iv_betrg      = lv_amount
***          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
**          is_pnwtyh_dia = cs_pnwtyh_dia
**          is_pnwtyv_dia = ls_pnwtyv_dia.
*
*      lv_amount = <ls_wt20_jet_tb>-tot_mng_approved. " / 100.
**      IF <ls_wt20_jet_tb>-sihand = '-'.
**        lv_amount = lv_amount * ( -1 ).
**        CLEAR ls_tot_con_approved_adjust.
**        READ TABLE lt_tot_con_approved_adjust INTO ls_tot_con_approved_adjust
**                   WITH KEY damseq = <ls_wt20_jet_tb>-dseqno.
**        IF ls_tot_con_approved_adjust-adjust < 0.
**          ls_tot_con_approved_adjust-adjust = ls_tot_con_approved_adjust-adjust * ( -1 ).
**        ENDIF.
**        lv_amount = lv_amount + ls_tot_con_approved_adjust-adjust.
**      ENDIF.
*
*****      CALL METHOD me->job_condition_insert
*****        EXPORTING
*****          it_pvwty_dia  = lt_pvwty_dia_ver
*****          iv_kschl      = ms_config-reimb_handl
*****          iv_poskt      = pwty_poskt-mat
*****          iv_betrg      = lv_amount
******          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
*****          is_pnwtyh_dia = cs_pnwtyh_dia
*****          is_pnwtyv_dia = ls_pnwtyv_dia.
*
*
*
************ Added by Venki
*
*      CALL FUNCTION 'WTY15_PRICING_KSCHL_GET'
*        EXPORTING
*          iv_kschl    = 'ZPRC'
*          iv_posnr    = <fs_pvwty_dia>-posnr
*          iv_ver_guid = ls_pnwtyv_dia-pnguid
*        IMPORTING
*          es_komv     = ls_komv
*        EXCEPTIONS
*          not_found   = 1
*          OTHERS      = 2.
*      IF sy-subrc <> 0.
*        CLEAR ls_komv.
*      ENDIF.
*
*      lv_amount = ls_komv-kwert.
*
**      ls_pvwty_dia-betrg = lv_amount.
**
**      IF ls_pvwty_dia-poskt EQ 'FR'.
**        ls_pvwty_dia-kschl = 'ZL01'.
**      ELSEIF ls_pvwty_dia-poskt EQ 'MAT'.
**        ls_pvwty_dia-kschl = 'ZM01'.
**      ELSEIF ls_pvwty_dia-poskt EQ 'SUBL'.
**        ls_pvwty_dia-kschl = 'ZS01'.
**      ENDIF.
**
**
**      CALL FUNCTION 'WTY15_PRICING_COND_EXTERNAL'
**        EXPORTING
**          is_pnwtyh_dia = cs_pnwtyh_dia
**          is_pnwtyv_dia = ls_pnwtyv_dia
**          is_pvwty_dia  = ls_pvwty_dia.
*
*      lv_amount = ls_komv-kwert.
*
*      CALL METHOD me->job_condition_insert_claimed
*        EXPORTING
*          it_pvwty_dia  = lt_pvwty_dia_ver
*          iv_kschl      = 'ZM01'
*          iv_poskt      = pwty_poskt-mat
*          iv_betrg      = lv_amount
**          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
*          is_pnwtyh_dia = cs_pnwtyh_dia
*          is_pnwtyv_dia = ls_pnwtyv_dia.
*
*      lv_amount = ls_komv-kwert.
*
*      CALL METHOD me->job_condition_insert_claimed
*        EXPORTING
*          it_pvwty_dia  = lt_pvwty_dia_ver
*          iv_kschl      = 'ZL01'
*          iv_poskt      = pwty_poskt-fr
*          iv_betrg      = lv_amount
**          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
*          is_pnwtyh_dia = cs_pnwtyh_dia
*          is_pnwtyv_dia = ls_pnwtyv_dia.
*
*      lv_amount = ls_komv-kwert.
*
*      CALL METHOD me->job_condition_insert_claimed
*        EXPORTING
*          it_pvwty_dia  = lt_pvwty_dia_ver
*          iv_kschl      = 'ZS01'
*          iv_poskt      = pwty_poskt-subl
*          iv_betrg      = lv_amount
**          iv_dseqno     = <ls_wt20_jet_tb>-dseqno
*          is_pnwtyh_dia = cs_pnwtyh_dia
*          is_pnwtyv_dia = ls_pnwtyv_dia.
*
**      LOOP AT ct_pvwty_dia ASSIGNING <fs_pvwty_dia>.
**        CALL FUNCTION 'WTY15_PRICING_ITEM_DELETE'
**          EXPORTING
**            is_pnwtyv_dia = ls_pnwtyv_dia
**            iv_posnr      = <fs_pvwty_dia>-posnr
**            iv_kschl      = lv_kschl.
**      ENDLOOP.
*
*
********* Added by Venki
*      CLEAR mv_rejected.
*    ENDLOOP.
*    UNASSIGN <ls_wt20_jet_tb>.
*
*
** update texts ------------------------------------------------------
*    CALL METHOD cl_ppeliwty_cntl=>claim_update_buffer
*      EXPORTING
*        is_pnwtyh_dia = cs_pnwtyh_dia
*        it_texts      = lt_text
*      EXCEPTIONS
*        update_error  = 1
*        OTHERS        = 2.
*    IF sy-subrc <> 0.
**      MESSAGE e119(ydbm_id1) INTO /dbme/ifm_cl_x_log=>mv_dummy.
**      io_log->add_msg( ).
**      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG.
*    ENDIF.
*
*
*    CALL FUNCTION 'WTY15_PRICING_HEADER'
*      EXPORTING
*        is_pnwtyh_dia       = cs_pnwtyh_dia
*        is_pnwtyv_dia       = ls_pnwtyv_dia
*        iv_calculation_type = 'C'
**       IV_TXJCD            =
*      TABLES
*        it_pvwty_dia        = ct_pvwty_dia.


  ENDMETHOD.
ENDCLASS.

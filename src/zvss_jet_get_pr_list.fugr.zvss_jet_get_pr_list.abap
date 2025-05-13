FUNCTION zvss_jet_get_pr_list.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BANFN) TYPE  /ISDFPS/BANFN_RT OPTIONAL
*"     REFERENCE(IT_EKGRP) TYPE  BLGL_EKGRP_RANGE_TT OPTIONAL
*"     REFERENCE(IT_MATNR) TYPE  /LIME/R_APO_MATNR OPTIONAL
*"     REFERENCE(IT_MAKTL) TYPE  FIP_T_MATKL_RANGE OPTIONAL
*"     REFERENCE(IT_BEDNR) TYPE  TRG_CHAR10 OPTIONAL
*"     REFERENCE(IT_WERKS) TYPE  RANGE_T_WERKS OPTIONAL
*"     REFERENCE(IT_BSART) TYPE  BLGL_BSART_RANGE_TT OPTIONAL
*"     REFERENCE(IT_LFDAT) TYPE  MSR_T_INSP_LFDAT_RANGE OPTIONAL
*"     REFERENCE(IT_FRGDT) TYPE  MSR_T_INSP_LFDAT_RANGE OPTIONAL
*"     REFERENCE(IT_DISPO) TYPE  BLGL_DISPO_RANGE_TT OPTIONAL
*"     REFERENCE(IT_STATU) TYPE  /ISDFPS/TT_CTYPE_RANGE OPTIONAL
*"     REFERENCE(IT_FLIEF) TYPE  TRG_CHAR10 OPTIONAL
*"     REFERENCE(IT_BANPR) TYPE  TRG_CHAR2 OPTIONAL
*"     REFERENCE(IT_BLCKD) TYPE  /ISDFPS/TT_CTYPE_RANGE OPTIONAL
*"     REFERENCE(IV_AFNAM) TYPE  AFNAM OPTIONAL
*"     REFERENCE(IV_TXZ01) TYPE  TXZ01 OPTIONAL
*"     REFERENCE(IV_ZUGBA) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(IV_MEMORY) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(IV_ERLBA) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(IV_BSTBA) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(IV_FREIG) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(IV_SELGS) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(IV_SELPO) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(IT_REGION) TYPE  ZVSS_REGIO_R OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_EBAN) TYPE  CCRCTT_EBAN
*"----------------------------------------------------------------------

  CONSTANTS : lc_table      TYPE string VALUE 'EBAN',
              lc_pstyp_wagr VALUE '8'.
  TABLES : t001w,t001k,t001.
  DATA: BEGIN OF it_waers OCCURS 10,
          werks LIKE eban-werks,
          waers LIKE eban-waers,
        END OF it_waers.
  DATA : lt_afnam  TYPE facra_tt_afnam_range,
         ts_afnam  LIKE LINE OF lt_afnam,
         lt_txz01  TYPE  apo_bapi_char40_ranges_tab,
         ts_txz01  LIKE LINE OF lt_txz01,
         lt_zugba  TYPE RANGE OF dzugba,
         ts_option LIKE LINE OF lt_zugba,
         lt_memory TYPE RANGE OF dzugba,
         lt_erlba  TYPE RANGE OF dzugba,
         lt_loekz  TYPE RANGE OF dzugba,
         lt_bstba  TYPE RANGE OF dzugba,
         lt_reig   TYPE RANGE OF dzugba,
         lt_selgs  TYPE RANGE OF dzugba,
         lt_selpo  TYPE RANGE OF dzugba,
         lt_werks  TYPE TABLE OF werks_d,
         ls_werks  LIKE LINE OF lt_werks,
         lt_wer_r  TYPE range_t_werks,
         ls_wer_r  LIKE LINE OF lt_wer_r,
         lv_reject .
  FIELD-SYMBOLS : <fs_eban> TYPE eban.

  "select options
  DATA: selopt_dyn_sel   TYPE rsds_type,
        ts_clause        TYPE rsds_where,
        "trange table
        lt_trange        TYPE rsds_trange,
        ts_trange        LIKE LINE OF lt_trange,

        "ranges for each table
        lt_ranges_fi_rng TYPE rsds_frange_t,
        ts_ranges_fi_rng LIKE LINE OF lt_ranges_fi_rng,
        "select options table
        lt_sel_options   TYPE rsds_selopt_t,
        ts_sel_options   TYPE rsdsselopt.
  "condition creation variables
  FIELD-SYMBOLS: <dyn_sel> TYPE rsds_type.
  DATA: lf_name     TYPE c LENGTH 32,
        dyn_sel     TYPE rsds_type,
        ls_where    TYPE rsdswhere,
        l_tabix     TYPE sy-tabix,
        pba_ofba(1) TYPE c,
        lv_region   TYPE regio.
  "Create conditions
  "I have all range tables coming in
  "just put them in the Deep structure table

  CLEAR : ts_ranges_fi_rng,lt_ranges_fi_rng.



  "process afnam
  IF NOT iv_afnam IS INITIAL.
    CLEAR: ts_afnam,lt_afnam.
    ts_afnam-sign = 'I'.
    ts_afnam-option = 'CP'.
    ts_afnam-low = iv_afnam.
    APPEND ts_afnam TO lt_afnam.
  ENDIF.
  "process short text
  IF NOT iv_txz01 IS INITIAL.
    CLEAR: lt_txz01,ts_txz01.
    ts_txz01-sign = 'I'.
    ts_txz01-option = 'CP'.
    ts_txz01-low = iv_txz01.
    APPEND ts_txz01 TO lt_txz01.
  ENDIF.

  CLEAR: ts_option-low.

  "preprocessing
  ts_option-sign = 'I'.
  ts_option-option = 'EQ'.

  IF iv_erlba EQ space.
    CLEAR lt_loekz.
    APPEND ts_option TO lt_loekz.
    pba_ofba = 'X'.

* add memory                                                "1781942
    IF iv_memory IS INITIAL.
      APPEND ts_option TO lt_memory.
    ENDIF.

  ENDIF.
  IF iv_zugba EQ space.
    APPEND ts_option TO lt_zugba.
  ENDIF.

******    "process checkboxes
******  ts_option-low = iv_zugba.
******  APPEND ts_option TO lt_zugba .
******  "memory
  CLEAR: ts_option-low.
  ts_option-low = iv_memory.
  APPEND ts_option TO lt_memory.

  "erlba
  CLEAR: ts_option-low.
  ts_option-low = iv_erlba.
  APPEND ts_option TO lt_erlba.
  CLEAR: ts_option-low.
  "select options
  IF NOT pba_ofba IS INITIAL .                              "311324
    READ TABLE selopt_dyn_sel-clauses INTO ts_clause
            WITH KEY tablename = 'EBAN'.
    IF NOT sy-subrc IS INITIAL.
      ts_clause-tablename = 'EBAN'.
    ELSE.
      l_tabix = sy-tabix.
      IF NOT ts_clause-where_tab[] IS INITIAL.
        ls_where = 'AND'.
        APPEND ls_where TO ts_clause-where_tab.
      ENDIF.
    ENDIF.
    ls_where = '( LOEKZ EQ '''' AND EBAKZ EQ '''' AND ('.
    APPEND ls_where TO ts_clause-where_tab.

* EHP5 -> CPR: allow pur. agreement requisitions
    ls_where = '( ( BSMNG LT EBAN~MENGE OR PSTYP EQ ''8'' ) '.
    APPEND ls_where TO ts_clause-where_tab.
    ls_where =
     ' ) OR ( BSAKZ EQ ''R'' AND STATU NE ''K'' AND'.
******    ENDIF.
    APPEND ls_where TO ts_clause-where_tab.
    ls_where = 'STATU NE ''L'' ) ) )'.
    APPEND ls_where TO ts_clause-where_tab.

    IF l_tabix IS INITIAL.
      APPEND ts_clause TO selopt_dyn_sel-clauses.
    ELSE.
      MODIFY selopt_dyn_sel-clauses FROM ts_clause INDEX l_tabix.
    ENDIF.
  ENDIF.


  IF NOT pba_ofba IS INITIAL.
    FREE lt_erlba.
  ENDIF.

  IF it_region IS NOT INITIAL.
    SELECT werks FROM t001w INTO TABLE lt_werks
    WHERE regio IN it_region AND werks IN it_werks.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    ls_wer_r-sign = 'I'.
    ls_wer_r-option = 'EQ'.
    LOOP AT lt_werks INTO ls_werks.
      ls_wer_r-low = ls_werks.
      APPEND ls_wer_r TO lt_wer_r.
    ENDLOOP.
  ELSE.
    lt_wer_r = it_werks[].
  ENDIF.
  CALL FUNCTION 'ME_READ_EBAN_MULTIPLE'
    EXPORTING
      i_dynsel              = selopt_dyn_sel
*     I_DYNFIE              =
*     I_SEL_EBKN            = 'X'
*     I_SELECTION_LIMIT     =
      i_filter_by_eban_tech = abap_true
*   IMPORTING
*     E_REQS_WITHOUT_AUTH   =
*     E_LAST_ENTRY          =
    TABLES
      te_eban               = et_eban
*     TE_EBKN               =
*     TI_TACT               =
*     TI_FREIG_ZUS          =
      ti_banfn_range        = it_banfn
      ti_matnr_range        = it_matnr
      ti_matkl_range        = it_maktl
      ti_werks_range        = lt_wer_r
      ti_ekgrp_range        = it_ekgrp
*     ti_bsakz_range        = it_bsart
      ti_bsart_range        = it_bsart
*     TI_PSTYP_RANGE        =
*     TI_KNTTP_RANGE        =
      ti_lfdat_range        = it_lfdat
      ti_frgdt_range        = it_frgdt
      ti_dispo_range        = it_dispo
      ti_statu_range        = it_statu
*     TI_FLIEF_RANGE        =
*     TI_BEDNR_RANGE        =
*     TI_KONNR_RANGE        =
*     TI_RESWK_RANGE        =
*     TI_EKORG_RANGE        =
*     TI_VRTYP_RANGE        =
      ti_txz01_range        = lt_txz01
      ti_afnam_range        = lt_afnam
*     TI_FRGGR_RANGE        =
*     TI_FRGST_RANGE        =
*     TI_KOSTL_RANGE        =
*     TI_AUFNR_RANGE        =
*     TI_ANLN1_RANGE        =
*     TI_ANLN2_RANGE        =
*     TI_VBELN_RANGE        =
*     TI_VBELP_RANGE        =
*     TI_NPLNR_RANGE        =
*     TI_VORNR_RANGE        =
*     TI_ZUGBA_RANGE        =
*     TI_EBAKZ_RANGE        =
*     TI_FRGRL_RANGE        =
*     TI_FORDN_RANGE        =
*     TI_GSFRG_RANGE        =
*     TI_PS_PSP_PNR_RANGE   =
*     TI_PSPID_EXT_RANGE    =
      ti_eban_loekz_range   = lt_loekz
*     TI_EBKN_LOEKZ_RANGE   =
*     TI_IMKEYS             =
*     TI_BANPR_RANGE        =
*     TI_BESWK_RANGE        =
*     TI_BLCKD_RANGE        =
*     TI_MEMORY_RANGE       = lt_memory
*     TI_MPN_RANGE          =
*   EXCEPTIONS
*     WRONG_INPUT           = 1
*     UNCOMPLETE_SELECTED   = 2
*     OTHERS                = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  "post processing
  LOOP AT et_eban ASSIGNING <fs_eban>.
    "eban-werks
    "eban-waers
    IF <fs_eban>-waers  IS INITIAL.
      CHECK NOT <fs_eban>-werks IS INITIAL.
      READ TABLE it_waers WITH KEY <fs_eban>-werks BINARY SEARCH.
      IF sy-subrc EQ 0.
        <fs_eban>-waers = it_waers-waers.
        EXIT.
      ENDIF.
      l_tabix = sy-tabix.
      SELECT SINGLE * FROM t001w WHERE werks EQ <fs_eban>-werks.
      CHECK sy-subrc EQ 0.
      SELECT SINGLE * FROM t001k WHERE bwkey EQ t001w-bwkey.
      CHECK sy-subrc EQ 0.
      SELECT SINGLE * FROM t001  WHERE bukrs EQ t001k-bukrs.
      CHECK sy-subrc EQ 0.

      <fs_eban>-waers   = t001-waers.
      it_waers-werks = <fs_eban>-werks.
      it_waers-waers = t001-waers.
      INSERT it_waers INDEX l_tabix.
    ENDIF.
    " Record validations
    IF iv_afnam NE space.
      IF <fs_eban>-afnam NP iv_afnam.
        lv_reject = abap_true.
      ENDIF.
    ENDIF.
    CHECK lv_reject IS INITIAL .

    IF iv_zugba IS INITIAL.
      CHECK <fs_eban>-zugba IS INITIAL..
      IF <fs_eban>-flief IS NOT INITIAL.
        CHECK <fs_eban>-ekorg IS INITIAL.
      ENDIF.
      IF <fs_eban>-reswk IS NOT INITIAL.
        CHECK <fs_eban>-ekorg IS INITIAL.
      ENDIF.
    ENDIF.
    IF iv_erlba IS INITIAL.
      CHECK <fs_eban>-loekz IS INITIAL.
      CHECK <fs_eban>-ebakz IS INITIAL.
*    CHECK eban-bsmng < eban-menge.                        "121920
      IF <fs_eban>-bsakz EQ 'R'.              "88504/KB
        CHECK <fs_eban>-statu NE 'K'.         "88504/KB
        CHECK <fs_eban>-statu NE 'L'.         "88504/KB
      ELSE.
        CHECK <fs_eban>-bsmng LT <fs_eban>-menge OR         "121920
        <fs_eban>-pstyp EQ lc_pstyp_wagr.                   "121920
      ENDIF.                                                 "88504/KB
    ENDIF.

    IF iv_bstba IS INITIAL.
      IF <fs_eban>-loekz IS INITIAL AND
         <fs_eban>-ebakz IS INITIAL AND
         <fs_eban>-bsmng < <fs_eban>-menge.
        CHECK <fs_eban>-bsmng = 0.
      ENDIF.
    ENDIF.
*------- Check Release PReqs ------------------------------------------*
    IF iv_freig IS NOT INITIAL.
      CHECK <fs_eban>-frgrl IS INITIAL.
* inclomplete PR´s (hold/park) should not be taken into account
      CHECK <fs_eban>-memory IS INITIAL.                    "1449698
    ENDIF.

    IF NOT iv_selgs IS INITIAL AND iv_selpo IS INITIAL.
      CHECK NOT <fs_eban>-gsfrg IS INITIAL.
    ELSEIF iv_selgs IS INITIAL AND NOT iv_selpo IS INITIAL.
      CHECK <fs_eban>-gsfrg IS INITIAL.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.

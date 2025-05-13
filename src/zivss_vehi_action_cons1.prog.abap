*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_ACTION_CONS1
*&---------------------------------------------------------------------*
INCLUDE <icon>.
INCLUDE <color>.

* dummy data for calling get_ui_destination
DATA: gv_url_call       TYPE  comt_sce_html_data2,
 gv_url_data_line  TYPE comt_sce_html_data,
 gv_url_data_index TYPE sy-tabix,
 gt_url_data       TYPE comt_sce_html_data OCCURS 0,
 gv_user_destination(20) TYPE c VALUE ' ',
 gc_ipc_destination(14)            TYPE c VALUE 'SAPCRM_SPC_ITS'.



CONSTANTS:

*--> common constants
  xflag_gc                  TYPE c                VALUE 'X',
  noflag_gc                 TYPE c                VALUE ' ',
  true_gc                   TYPE c                VALUE 'X',
  false_gc                  TYPE c                VALUE space,

  yes_gc                    TYPE c                VALUE 'J',
  no_gc                     TYPE c                VALUE 'N',

  space_gc                  TYPE c                VALUE ' ',
  flag_1_gc                 TYPE c                VALUE '1',
  flag_2_gc                 TYPE c                VALUE '2',
  flag_3_gc                 TYPE c                VALUE '3',
  one_gc                    TYPE c                VALUE '1',

  sdqty_gc                  TYPE dzmeng            VALUE '1',
  sdunt_gc                  TYPE dzieme            VALUE 'ST',

  fact_ten_gc               TYPE i                 VALUE 10,

*--> constants about time
  resdays_gc(4)             TYPE n                VALUE '3',
  restime_gc(4)             TYPE n                VALUE '0',
  rescont_gc(4)             TYPE n                VALUE '20',
  vlc_time_low              TYPE sy-uzeit         VALUE '000001',
  vlc_time_high             TYPE sy-uzeit         VALUE '235959',

*       Needed for the timestamp of the (planned) production
*       date. For the production date only a date not a time
*       is displayed / entered by the user. To generate a
*       timestamp a time is needed anyway. For the production
*       date timestamp PRODTIME_GC is always used as time.
  prodtime_gc               TYPE systtimlo        VALUE '120000',
*       Same reason as PRODTIME_GC
  pshiptime_gc              TYPE systtimlo        VALUE '120000',
  confdtime_gc              TYPE systtimlo        VALUE '120000',
  lastdate_gc               TYPE d                VALUE '99991231',


*--> constants about languages
  language_english_gc       TYPE sy-langu         VALUE 'E',

*------------------------------------------------------------------

* CONSTANTS FOR ACTION NAMES

*--> Single MM - actions
  action_vh_create_gc       TYPE cvlc03-aktion    VALUE 'CREA',
  action_vh_creat1_gc       TYPE cvlc03-aktion    VALUE 'CRE1',
  action_vh_cvwt_gc         TYPE cvlc03-aktion    VALUE 'CVWT',
  action_vh_cvt1_gc         TYPE cvlc03-aktion    VALUE 'CVT1',
  action_vh_realvh_gc       TYPE cvlc03-aktion    VALUE 'REAL',
  action_vh_replvh_gc       TYPE cvlc03-aktion    VALUE 'REPL',
  action_vh_chconf_gc       TYPE cvlc03-aktion    VALUE 'CMOD',
  action_vh_porde1_gc       TYPE cvlc03-aktion    VALUE 'ORD1',
  action_vh_rword1_gc       TYPE cvlc03-aktion    VALUE 'UORD',
  action_vh_confpo_gc       TYPE cvlc03-aktion    VALUE 'CONF',
  action_vh_shpmnt_gc       TYPE cvlc03-aktion    VALUE 'SHMT',
  action_vh_incinv_gc       TYPE cvlc03-aktion    VALUE 'INIV',
  action_vh_ininvr_gc       TYPE cvlc03-aktion    VALUE 'IIVR',
  action_vh_paymnt_gc       TYPE cvlc03-aktion    VALUE 'PAY1',
  action_vh_delete_gc       TYPE cvlc03-aktion    VALUE 'VDEL',
  action_vh_modord_gc       TYPE cvlc03-aktion    VALUE 'MORD',
  action_vh_delord_gc       TYPE cvlc03-aktion    VALUE 'DORD',
  action_vh_poexuv_gc       TYPE cvlc03-aktion    VALUE 'POEU',
  action_vh_rwdord_gc       TYPE cvlc03-aktion    VALUE 'UDOR',
  action_vh_ineinv_gc       TYPE cvlc03-aktion    VALUE 'IEID',

*--> Combined MM - actions
  action_vh_porde2_gc       TYPE cvlc03-aktion    VALUE 'ORD2',

*--> Single SD - actions
  action_vh_inqiry_gc       TYPE cvlc03-aktion    VALUE 'IQRY',
  action_vh_dliqry_gc       TYPE cvlc03-aktion    VALUE 'DEIQ',
  action_vh_coffer_gc       TYPE cvlc03-aktion    VALUE 'OFFE',
  action_vh_dloffe_gc       TYPE cvlc03-aktion    VALUE 'DEOF',
  action_vh_reserv_gc       TYPE cvlc03-aktion    VALUE 'RSVN',
  action_vh_delres_gc       TYPE cvlc03-aktion    VALUE 'DERS',
  action_vh_resmrk_gc       TYPE cvlc03-aktion    VALUE 'RSVM',
  action_vh_delrrq_gc       TYPE cvlc03-aktion    VALUE 'DERQ',
  action_vh_cuorde_gc       TYPE cvlc03-aktion    VALUE 'CUOR',
  action_vh_chcuor_gc       TYPE cvlc03-aktion    VALUE 'CHCO',
  action_vh_cnco_gc         TYPE cvlc03-aktion    VALUE 'CNCO',
  action_vh_deleco_gc       TYPE cvlc03-aktion    VALUE 'DECO',
  action_vh_recrin_gc       TYPE cvlc03-aktion    VALUE 'RCIN',
  action_vh_recout_gc       TYPE cvlc03-aktion    VALUE 'ROUT',
  action_vh_delivy_gc       TYPE cvlc03-aktion    VALUE 'DELI',
  action_vh_deldel_gc       TYPE cvlc03-aktion    VALUE 'DEDE',
  action_vh_goodsi_gc       TYPE cvlc03-aktion    VALUE 'GOIS',
  action_vh_ouinvo_gc       TYPE cvlc03-aktion    VALUE 'OUIV',
  action_vh_recm_gc         TYPE cvlc03-aktion    VALUE 'RECM',
  action_vh_ouinre_gc       TYPE cvlc03-aktion    VALUE 'OIVR',
  action_vh_queues_gc       TYPE cvlc03-aktion    VALUE 'QEUE',
  action_vh_inform_gc       TYPE cvlc03-aktion    VALUE 'INFO',
  action_vh_redeli_gc       TYPE cvlc03-aktion    VALUE 'RELI',
  action_vh_return_gc       TYPE cvlc03-aktion    VALUE 'RETU',
  action_vh_regi_gc         TYPE cvlc03-aktion    VALUE 'REGI',
  action_vh_bupa_gc         TYPE cvlc03-aktion    VALUE 'BUPA',
  action_vh_soeu_gc         TYPE cvlc03-aktion    VALUE 'SOEU',
  action_vh_speu_gc         TYPE cvlc03-aktion    VALUE 'SPEU',
  action_vh_lors_gc         TYPE cvlc03-aktion    VALUE 'LORS',
  action_vh_tirs_gc         TYPE cvlc03-aktion    VALUE 'TIRS',
  action_vh_delr_gc         TYPE cvlc03-aktion    VALUE 'DELR',
  action_vh_detr_gc         TYPE cvlc03-aktion    VALUE 'DETR',
  action_vh_adcu_gc         TYPE cvlc03-aktion    VALUE 'ADCU',
  action_vh_trrq_gc         TYPE cvlc03-aktion    VALUE 'TRRQ',
  action_vh_trac_gc         TYPE cvlc03-aktion    VALUE 'TRAC',
  action_vh_trrj_gc         TYPE cvlc03-aktion    VALUE 'TRRJ',
  action_vh_trcn_gc         TYPE cvlc03-aktion    VALUE 'TRCN',
  action_vh_trak_gc         TYPE cvlc03-aktion    VALUE 'TRAK',
  action_vh_trex_gc         TYPE cvlc03-aktion    VALUE 'TREX',

*--> Combined MM - and SD - actions
  action_vh_ordcuo_gc       TYPE cvlc03-aktion    VALUE 'O2CO',
  action_vh_crecuo_gc       TYPE cvlc03-aktion    VALUE 'CRCO',

*--> Single LE-actions
  action_vh_goodsr_gc       TYPE cvlc03-aktion    VALUE 'GORE',
  action_vh_gorere_gc       TYPE cvlc03-aktion    VALUE 'GRER',
  action_vh_tpstol_gc       TYPE cvlc03-aktion    VALUE 'STOL',
  action_vh_cpgm_gc         TYPE cvlc03-aktion    VALUE 'CPGM',
  action_vh_goisre_gc       TYPE cvlc03-aktion    VALUE 'GISR',
  action_vh_rwgore_gc       TYPE cvlc03-aktion    VALUE 'UGRE',
  action_vh_rwgrer_gc       TYPE cvlc03-aktion    VALUE 'UGRR',
  action_vh_ieid_gc         TYPE cvlc03-aktion    VALUE 'IEID',
  action_vh_goiwod_gc       TYPE cvlc03-aktion    VALUE 'GIWD',
  action_vh_giwodr_gc       TYPE cvlc03-aktion    VALUE 'GIWR',
  action_vh_reus_gc         TYPE cvlc03-aktion    VALUE 'REUS',

*--> Single SM actions
  action_vh_crequi_gc       TYPE cvlc03-aktion    VALUE 'CREQ',
  action_vh_warnty_gc       TYPE cvlc03-aktion    VALUE 'WRTY',
  action_vh_genobj_gc       TYPE cvlc03-aktion    VALUE 'GEOB',
  action_vh_wtyvlc_gc       TYPE cvlc03-aktion    VALUE 'WYVH',
  action_vh_measmt_gc       TYPE cvlc03-aktion    VALUE 'MEAS',
  action_vh_smor_gc         TYPE cvlc03-aktion    VALUE 'SMOR',
  action_vh_smco_gc         TYPE cvlc03-aktion    VALUE 'SMCO',
  action_vh_smno_gc         TYPE cvlc03-aktion    VALUE 'SMNO',
  action_vh_smio_gc         TYPE cvlc03-aktion    VALUE 'SMIO',
  action_vh_rval_gc         TYPE cvlc03-aktion    VALUE 'RVAL',

*--> Used vehicles
  action_vh_cruv_gc         TYPE cvlc03-aktion    VALUE 'CRUV',
  action_vh_cscr_gc         TYPE cvlc03-aktion    VALUE 'CSCR',
  action_vh_uvsw_gc         TYPE cvlc03-aktion    VALUE 'UVSW',
  action_vh_bbdf_gc         TYPE cvlc03-aktion    VALUE 'BBDF',
  action_vh_csed_gc         TYPE cvlc03-aktion    VALUE 'CSED',
  action_vh_rtuv_gc         TYPE cvlc03-aktion    VALUE 'RTUV',


*--> Other actions
  action_vh_smodif_gc       TYPE cvlc03-aktion    VALUE 'SMOD',
  action_vh_addata_gc       TYPE cvlc03-aktion    VALUE 'ADAT',
  action_vh_vhshow_gc       TYPE cvlc03-aktion    VALUE 'SHOW',
  action_vh_vhhide_gc       TYPE cvlc03-aktion    VALUE 'HIDE',
  action_vh_vsblty_gc       TYPE cvlc03-aktion    VALUE 'VBTY',
  action_vh_mssout_gc       TYPE cvlc03-aktion    VALUE 'MSSO',
  action_vh_addo_gc         TYPE cvlc03-aktion    VALUE 'ADDO',
  action_vh_socd_gc         TYPE cvlc03-aktion    VALUE 'SOCD',
  action_vh_stwo_gc         TYPE cvlc03-aktion    VALUE 'STWO',
  action_vh_akns_gc         TYPE cvlc03-aktion    VALUE 'AKNS',
  action_vh_aknc_gc         TYPE cvlc03-aktion    VALUE 'AKNC',

* --> SCEM actions
  action_vh_emmi_gc         TYPE cvlc03-aktion    VALUE 'EMMI',

* --> CRM actions
  action_vh_crmv_gc         TYPE cvlc03-aktion    VALUE 'CRMV',
  action_vh_crms_gc         TYPE cvlc03-aktion    VALUE 'CRMS',

* --> Archive actions
  action_vh_arcs_gc         TYPE cvlc03-aktion    VALUE 'ARCS',
  action_vh_arcd_gc         TYPE cvlc03-aktion    VALUE 'ARCD',

  history_prior_vehicle_gc  TYPE cvlc03-crmrel    VALUE '1',
  history_after_vehicle_gc  TYPE cvlc03-crmrel    VALUE '2',
  history_combi_vehicle_gc  TYPE cvlc03-crmrel    VALUE '3',
*----------------------------------------------------------------------

* VEHICLE MANAGEMENT SYSTEM ACTION DOCUMENT TYPES  (the so called ABAs)

*--> MM - actions
  aba_ord1_gc       TYPE vlc_actdoctype    VALUE 'ORD1',
  aba_uord_gc       TYPE vlc_actdoctype    VALUE 'UORD',
  aba_poeu_gc       TYPE vlc_actdoctype    VALUE 'POEU',
  aba_iniv_gc       TYPE vlc_actdoctype    VALUE 'INIV',
  aba_iivr_gc       TYPE vlc_actdoctype    VALUE 'IIVR',
  aba_rval_gc       TYPE vlc_actdoctype    VALUE 'RVAL',

*--> SD - actions
  aba_offe_gc       TYPE vlc_actdoctype    VALUE 'OFFE',
  aba_cuor_gc       TYPE vlc_actdoctype    VALUE 'CUOR',
  aba_retu_gc       TYPE vlc_actdoctype    VALUE 'RETU',
  aba_reli_gc       TYPE vlc_actdoctype    VALUE 'RELI',
  aba_regi_gc       TYPE vlc_actdoctype    VALUE 'REGI',
  aba_ouiv_gc       TYPE vlc_actdoctype    VALUE 'OUIV',
  aba_recm_gc       TYPE vlc_actdoctype    VALUE 'RECM',
  aba_oivr_gc       TYPE vlc_actdoctype    VALUE 'OIVR',
  aba_qeue_gc       TYPE vlc_actdoctype    VALUE 'QEUE',
  aba_iqry_gc       TYPE vlc_actdoctype    VALUE 'IQRY',
  aba_chco_gc       TYPE vlc_actdoctype    VALUE 'CHCO',
  aba_deco_gc       TYPE vlc_actdoctype    VALUE 'DECO',
  aba_info_gc       TYPE vlc_actdoctype    VALUE 'INFO',
  aba_soeu_gc       TYPE vlc_actdoctype    VALUE 'SOEU',
  aba_speu_gc       TYPE vlc_actdoctype    VALUE 'SPEU',

*--> LE-actions
  aba_gore_gc       TYPE vlc_actdoctype    VALUE 'GORE',
  aba_grer_gc       TYPE vlc_actdoctype    VALUE 'GRER',
  aba_utpo_gc       TYPE vlc_actdoctype    VALUE 'UTPO',
  aba_utpr_gc       TYPE vlc_actdoctype    VALUE 'UTPR',
  aba_ugre_gc       TYPE vlc_actdoctype    VALUE 'UGRE',
  aba_stol_gc       TYPE vlc_actdoctype    VALUE 'STOL',
  aba_cpgm_gc       TYPE vlc_actdoctype    VALUE 'CPGM',
  aba_deli_gc       TYPE vlc_actdoctype    VALUE 'DELI',
  aba_gois_gc       TYPE vlc_actdoctype    VALUE 'GOIS',
  aba_gisr_gc       TYPE vlc_actdoctype    VALUE 'GISR',
  aba_ieid_gc       TYPE vlc_actdoctype    VALUE 'IEID',
  aba_ugrr_gc       TYPE vlc_actdoctype    VALUE 'UGRR',
  aba_reus_gc       TYPE vlc_actdoctype    VALUE 'REUS',

*--> SM - actions
  aba_wrty_gc       TYPE vlc_actdoctype    VALUE 'WRTY',
  aba_creq_gc       TYPE vlc_actdoctype    VALUE 'CREQ',
  aba_geob_gc       TYPE vlc_actdoctype    VALUE 'GEOB',
  aba_meas_gc       TYPE vlc_actdoctype    VALUE 'MEAS',
  aba_smor_gc       TYPE vlc_actdoctype    VALUE 'SMOR',
  aba_smno_gc       TYPE vlc_actdoctype    VALUE 'SMNO',
  aba_smco_gc       TYPE vlc_actdoctype    VALUE 'SMCO',
  aba_smio_gc       TYPE vlc_actdoctype    VALUE 'SMIO',
  aba_csbi_gc       TYPE vlc_actdoctype    VALUE 'CSBI',

* --> SCEM actions
  aba_emmi_gc       TYPE vlc_actdoctype    VALUE 'EMMI',


*----------------------------------------------------------------------



*----------------------------------------------------------------------

*--> function codes
  fc_expn_gc       TYPE sy-ucomm VALUE 'EXPN', " expand node
  fc_coln_gc       TYPE sy-ucomm VALUE 'COLN', " collapse node
  fc_seln_gc       TYPE sy-ucomm VALUE 'SELN', " select nodes
  fc_dsln_gc       TYPE sy-ucomm VALUE 'DSLN', " deselect nodes
  fc_xxxx_gc       TYPE sy-ucomm VALUE 'XXXX',              " PAI
  fc_erro_gc       TYPE sy-ucomm VALUE 'ERRO', " display message

  fc_ente_gc       TYPE sy-ucomm VALUE 'ENTE', " enter/return
  fc_over_gc       TYPE sy-ucomm VALUE 'OVER', " Show screen overview
  fc_detl_gc       TYPE sy-ucomm VALUE 'DETL', " Show screen detail
  fc_acti_gc       TYPE sy-ucomm VALUE 'ACTI', " Show screen action
  fc_wrty_gc       TYPE sy-ucomm VALUE 'WRTY', " Show screen warranty
  fc_asgn_gc       TYPE sy-ucomm VALUE 'ASGN', " Show screen assignment
  fc_ssdo_gc       TYPE sy-ucomm VALUE 'SSDO', " Assignmt: sdocs bar
  fc_kovg_gc       TYPE sy-ucomm VALUE 'KOVG', " Assignmt: configs
  fc_sres_gc       TYPE sy-ucomm VALUE 'SRES', " Assignmt: result bar
  fc_sveh_gc       TYPE sy-ucomm VALUE 'SVEH', " Assignmt: search vehis
  fc_sesd_gc       TYPE sy-ucomm VALUE 'SESD', " Assignmt: search for
                                               " sales documents
  fc_sehp_gc       TYPE sy-ucomm VALUE 'SEHP', " Assignmt: search help
                                               " for sales document
  fc_bsea_gc       TYPE sy-ucomm VALUE 'BSEA', " Show scrn vehi-search
  fc_itgl_gc       TYPE sy-ucomm VALUE 'ITGL', " Toggle search screens
  fc_suei_gc       TYPE sy-ucomm VALUE 'SUEI', " Search single vehicle
  fc_sear_gc       TYPE sy-ucomm VALUE 'SEAR', " Search vehicles
  fc_sepr_gc       TYPE sy-ucomm VALUE 'SEPR', " Load Search profile
  fc_spsa_gc       TYPE sy-ucomm VALUE 'SPSA', " Save Search profile
  fc_spde_gc       TYPE sy-ucomm VALUE 'SPDE', " Delete Search profile
  fc_konf_gc       TYPE sy-ucomm VALUE 'KONF', " leave to SCE
  fc_kovt_gc       TYPE sy-ucomm VALUE 'KOVT', " leave to SCE CVWT/CVT1
  fc_actn_gc       TYPE sy-ucomm VALUE 'ACTN', " Choose action
  fc_act1_gc       TYPE sy-ucomm VALUE 'ACT1', " action-button 1
  fc_act2_gc       TYPE sy-ucomm VALUE 'ACT2', " action-button 2
  fc_act3_gc       TYPE sy-ucomm VALUE 'ACT3', " action-button 3
  fc_act4_gc       TYPE sy-ucomm VALUE 'ACT4', " action-button 4
  fc_act?_gc       TYPE sy-ucomm VALUE 'ACT',  " all action buttons
  fc_aktn_gc       TYPE sy-ucomm VALUE 'AKTN', " Execute action
  fc_calc_gc       TYPE sy-ucomm VALUE 'CALC', " Call calculation sheet editor
  fc_sove_gc       TYPE sy-ucomm VALUE 'SOVE', " Vehicle Dtl Overview
  fc_scon_gc       TYPE sy-ucomm VALUE 'SCON', " Vehicle Detail Config
  fc_shis_gc       TYPE sy-ucomm VALUE 'SHIS', " Vehicle Detail History
  fc_scus_gc       TYPE sy-ucomm VALUE 'SCUS', " Vehicle Detail Dealer
  fc_sedc_gc       TYPE sy-ucomm VALUE 'SEDC', " Vehicle Detail EndCust
  fc_proc_gc       TYPE sy-ucomm VALUE 'PROC', " Show Protocoll
  fc_exit_gc       TYPE sy-ucomm VALUE 'EXIT',              " Exit
  fc_calcsh_gc     TYPE sy-ucomm VALUE 'CALCSH', " Calculation sheet
  fc_back_gc       TYPE sy-ucomm VALUE 'BACK',              " Back
  fc_canc_gc       LIKE sy-ucomm VALUE 'CANC',              " Cancel
  fc_rfrs_gc       TYPE sy-ucomm VALUE 'RFRS',              " Refresh
  fc_rfm1_gc       TYPE sy-ucomm VALUE 'RFM1', " refresh now
  fc_rfm2_gc       TYPE sy-ucomm VALUE 'RFM2', " refresh on request
  fc_addr_gc       TYPE sy-ucomm VALUE 'ADDR', " endcustomer data input
  fc_adok_gc       TYPE sy-ucomm VALUE 'ADOK', " OK endcustomer data.
  fc_adca_gc       TYPE sy-ucomm VALUE 'ADCA', " cancel endcustomerdata
  fc_adrl_gc       TYPE sy-ucomm VALUE 'ADRL', " endcustomer data input with role in variable
  fc_supp_gc       TYPE sy-ucomm VALUE 'SUPP', " supplier data input
  fc_adye_gc       TYPE sy-ucomm VALUE 'YES' , " Ja Bttn Confirm Popup
  fc_adno_gc       TYPE sy-ucomm VALUE 'NO'  , " Nein Confirm Popup
  fc_adp1_gc       TYPE sy-ucomm VALUE 'ADP1', " show location address
  fc_adp2_gc       TYPE sy-ucomm VALUE 'ADP2', " show oems address
  fc_adp3_gc       TYPE sy-ucomm VALUE 'ADP3', " show dealers address
  fc_zdat_gc       TYPE sy-ucomm VALUE 'ZDAT', " show additional data
  fc_shmm_gc       TYPE sy-ucomm VALUE 'SHMM', " show mm action matrix
  fc_shsd_gc       TYPE sy-ucomm VALUE 'SHSD', " show sd action matrix
  fc_dadmi_gc      TYPE sy-ucomm VALUE 'DADMI', " call Document System
  fc_outpu_gc      TYPE sy-ucomm VALUE 'OUTPU', " call Output Issue
  fc_scem_gc       TYPE sy-ucomm VALUE 'SCEM',  " call SCEM
  fc_reserv_gc     TYPE sy-ucomm VALUE 'RESERV',  " display reservations
  fc_orgdata_gc    TYPE sy-ucomm VALUE 'ORGD',    " define Orgdata
  fc_bdt_change    TYPE sy-ucomm VALUE 'BDT_CHANGE', "change buspartner
  fc_bdt_disp      TYPE sy-ucomm VALUE 'BDT_DISP', "display buspartner
  fc_bdt_create    TYPE sy-ucomm VALUE 'BDT_CREATE', "create buspartner
  fc_bdt_enter     TYPE sy-ucomm VALUE 'BDT_ENTER',         "enter
  fc_bdt_save      TYPE sy-ucomm VALUE 'BDT_SAVE',          "save
  fc_bdt_cancel    TYPE sy-ucomm VALUE 'BDT_CANCEL',        "cancel
  fc_ctpc_gc       TYPE sy-ucomm VALUE 'CTPC',    " CTP check (sales ord.)
  fc_noref_gc      TYPE sy-ucomm VALUE 'NOREF',   "without reference
  fc_new_gc        TYPE sy-ucomm VALUE 'NEW',     "create new document
  fc_item_gc       TYPE sy-ucomm VALUE 'ITEM',    "display items
  fc_crit_gc       TYPE sy-ucomm VALUE 'CRIT',    "create item
  fc_frst_gc       TYPE sy-ucomm VALUE 'FRST',    "first entry
  fc_prev_gc       TYPE sy-ucomm VALUE 'PREV',    "previous entry
  fc_next_gc       TYPE sy-ucomm VALUE 'NEXT',    "next entry
  fc_last_gc       TYPE sy-ucomm VALUE 'LAST',    "last entry
  fc_head_gc       TYPE sy-ucomm VALUE 'HEAD',    "show header data
  fc_hbak_gc       TYPE sy-ucomm VALUE 'HBAK',    "HTML: go back
  fc_hfwd_gc       TYPE sy-ucomm VALUE 'HFWD',    "HTML: go forward
  fc_hrfr_gc       TYPE sy-ucomm VALUE 'HRFR',    "HTML: do refresh
  fc_meas_gc       TYPE sy-ucomm VALUE 'MEAS',    "Button Measuring Pt.
  fc_refr_gc       TYPE sy-ucomm VALUE 'REFR',    "RefreshButton VehiALV
  fc_cfmap_gc      TYPE sy-ucomm VALUE 'CFMAP',    "Map configurations in CRUV
  fc_addcu_gc      TYPE sy-ucomm VALUE 'ADDCU',    "on change of business partner role
  fc_get_endcu_gc  TYPE sy-ucomm VALUE 'GET_ENDCU',    "Get endcustomer details

*--> authority object and authority activities
  vlc_authority_object_gc   TYPE tobj-objct       VALUE 'C_AUTO_VMS',
  vlc_actvt_admin_gc        TYPE tact-actvt       VALUE '70',


*--> number range objects and intervals
  nrobject_vlcvehi_gc       TYPE  inri-object     VALUE 'VLC_CH_01',
  nrobject_vlcvehi_cust_gc  TYPE  inri-object     VALUE 'VMS_VHL',
  nrange_vlcvehi_gc         TYPE  inri-nrrangenr  VALUE '01',
  nrobject_vlccntrl_gc      TYPE  inri-object     VALUE 'VLC_CR_01',
  nrange_vlccntrl_gc        TYPE  inri-nrrangenr  VALUE '01',
  nrobject_vlcchpro_gc      TYPE  inri-object     VALUE 'VLC_CP_01',
  nrange_vlcchpro_gc        TYPE  inri-nrrangenr  VALUE '01',

*--> dummy GUID for vehicles that have to be created.
  dummy_initial_guid_gc     TYPE  vlc_guid       VALUE 'VLC_DUMMYGUID',

*--> action handler posting variants
  action_syncpost_gc        TYPE c                VALUE 'S',
  action_asyncpost_gc       TYPE c                VALUE 'A',
  action_noposting_gc       TYPE c                VALUE 'N',


*--> icons
  ic_grey_gc(4)             TYPE c                VALUE '@BZ@',
  ic_red_gc(4)              TYPE c                VALUE '@5C@',
  ic_yell_gc(4)             TYPE c                VALUE '@5D@',
  ic_gree_gc(4)             TYPE c                VALUE '@5B@',


*--> splitter-control
  align_at_left_gc          TYPE i                VALUE   1,
  align_at_right_gc         TYPE i                VALUE   2,
  align_at_top_gc           TYPE i                VALUE   4,
  align_at_bottom_gc        TYPE i                VALUE   8,
  align_centered_gc         TYPE i                VALUE  16,
  set_at_left_gc            TYPE i                VALUE 128,
  set_at_right_gc           TYPE i                VALUE 256,
  set_at_top_gc             TYPE i                VALUE  32,
  set_at_bottom_gc          TYPE i                VALUE  64,
  set_centered_gc           TYPE i                VALUE 512,


*--> toolbar-control
  toolbar_height_gc         TYPE i                VALUE   5,


*--> tree width
  tree_width_gc             TYPE i                VALUE  30,


*--> alv-control: save modes for ALV variants
  alv_var_save_gc           TYPE c                VALUE 'A',


*--> nodes for tree_control
  node_root_gc(4)           TYPE c                VALUE 'ROOT',
  node_matnr_gc(5)          TYPE c                VALUE 'MATNR',
  node_avail_gc(5)          TYPE c                VALUE 'AVAIL',
  node_loctn_gc(5)          TYPE c                VALUE 'LOCTN',
  node_mmstat_gc(6)         TYPE c                VALUE 'MMSTAT',
  node_sdstat_gc(6)         TYPE c                VALUE 'SDSTAT',
  node_kunnr_gc(5)          TYPE c                VALUE 'KUNNR',
  node_conf_gc(4)           TYPE c                VALUE 'CONF',
  node_confc_gc(5)          TYPE c                VALUE 'CONFC',
  node_confv_gc(5)          TYPE c                VALUE 'CONFV',
  node_plant_gc(5)          TYPE c                VALUE 'PLANT',


*--> separator for multi-valuated characteristics
  multvalue_gc(3)           TYPE c                VALUE ', ',
*--> Class types - PA9K013443
 cltype_001_gc(3)          TYPE c                VALUE '001',
  cltype_300_gc(3)          TYPE c                VALUE '300',


*--> Configuration
  conf_syline_gc            TYPE i                   VALUE '1200',
  conf_syidlength_gc        TYPE i                   VALUE '12',
  conf_lastdate_gc          TYPE ib_valto       VALUE '99991231235959',
  conf_objtype_gc           TYPE ibobjkey            VALUE 'MARA',
  conf_ownint_gc            TYPE ibinttyp            VALUE '20',
  conf_own_gc               TYPE ibobjref_rt-objtyp VALUE 'VLCVEHICLE',
  conf_objc_tabname_gc      TYPE dcobjdef-name      VALUE 'VLCDIAVEHI',
  conf_objc_adddata_gc      TYPE dcobjdef-name      VALUE 'VLCADDDATA',
  conf_objc_vlcvehi_gc      TYPE dcobjdef-name      VALUE 'VLCVEHICLE',

  actl_conf_gc              TYPE c                   VALUE '1',

*--> the following constant determines wether VELO03_WRITE_SINGLE_CONFIG
*    will throw an exception in the case that a configuration is not
*    complete.
  check_complete_gc         TYPE c                   VALUE 'X',

*--> CTP-Check (Reservation Planning): not active (default... --> BADI)
  ctp_check_gc              TYPE c                   VALUE ' ',
  ctp_check_grp_gc(3)       TYPE c                   VALUE 'CTP',
  ctp_check_but_grp_gc(3)   TYPE c                   VALUE 'CT2',


*--> constant to set the detail overview subscreen that will be
* included
*    on subscreen 3100 (VELO02).
  detov_subdynr_gc          TYPE vlc_dynnr        VALUE '3150',
  detov_subprog_gc          TYPE vlc_program      VALUE 'SAPLVELO02',
  detco_subdynr_gc          TYPE vlc_dynnr        VALUE '3250',
  dethi_subdynr_gc          TYPE vlc_dynnr        VALUE '3350',

*--> constant to set the detail assignment subscreens that will be
* included on subscreen 7000 (VELO02).
  assignmt_search_gc        TYPE vlc_dynnr        VALUE '7100',
  assignmt_result_gc        TYPE vlc_dynnr        VALUE '7150',
  assignmt_config_gc        TYPE vlc_dynnr        VALUE '7250',
  assignmt_subprog_gc       TYPE vlc_program      VALUE 'SAPLVELO02',

*--> constants for dynamic search help for sales documents
  top_shlp_gc               TYPE shlpname         VALUE 'VMVA',
  subshlp_gc                TYPE subshlp          VALUE 'VMVAM',

*--> constants for sales document type (sales order, offer, inquiry)
  sdoc_type_so_gc           TYPE trvog            VALUE '0',
  sdoc_type_of_gc           TYPE trvog            VALUE '2',
  sdoc_type_in_gc           TYPE trvog            VALUE '1',

*--> splitter-control
  hsash_position_gc         TYPE i                VALUE   50,

*--> model class
  model_class_gc            TYPE klassenart       VALUE   '300',

*======================================================================
*======================================================================
* CONSTANTS FOR ACTIONS
*======================================================================
*======================================================================

* CONSTANTS FOR ACTION DYNPROS IN GENERAL
* =======================================

** ACTION SUBSCREEN STATUS
*  Dynpro control: Status before the "Action Execute" Button is pressed
before_act_gc            TYPE i                VALUE '1',
*  Dynpro control: Status after the "Action Execute" Button is pressed
after_act_gc             TYPE i                VALUE '2',

** INPUT-TYPE OF FIELDS THAT ARE INCLUDED ON THE ACTION-SCREENS
*  Mandatory entry fields
ftype_in1_gc(3)          TYPE c                VALUE 'IN1',
*  Not mandatory entry fields
ftype_in2_gc(3)          TYPE c                VALUE 'IN2',
*  Output fields only
ftype_ou1_gc(3)          TYPE c                VALUE 'OU1',

** BUTTONS ON ACTION DYNPROS
*  Configuration
button_konf_gc(11)        TYPE c                VALUE 'BUTTON_KONF',
* Calculation sheet
button_calc_gc(11)        TYPE c                VALUE 'BUTTON_CALC',
*  Action Execute
button_aktn_gc(11)        TYPE c                VALUE 'BUTTON_AKTN',
*  Maintain address data (final customer)
button_addr_gc(11)        TYPE c                VALUE 'BUTTON_ADDR',
* Maintain address for additional end customers
button_adrl_gc(11)        TYPE c                VALUE  'BUTTON_ADRL',
*  Maintain supplier data (CPD)
button_supp_gc(11)        TYPE c                VALUE 'BUTTON_SUPP',
* Calculation sheet
button_calc(11)           TYPE c                VALUE 'BUTTON_CALC',
*  Capable to promise check
button_ctpc_gc(11)        TYPE c                VALUE 'BUTTON_CTPC',
button_frst_gc(11)        TYPE c                VALUE 'BUTTON_FRST',
button_prev_gc(11)        TYPE c                VALUE 'BUTTON_PREV',
button_next_gc(11)        TYPE c                VALUE 'BUTTON_NEXT',
button_last_gc(11)        TYPE c                VALUE 'BUTTON_LAST',
button_head_gc(11)        TYPE c                VALUE 'BUTTON_HEAD',
button_item_gc(11)        TYPE c                VALUE 'BUTTON_ITEM',
button_crit_gc(11)        TYPE c                VALUE 'BUTTON_CRIT',

*  Input-type of fields that are included on the action-screens
mndfd_in1_gc(3)          TYPE c                VALUE 'M',

*  Position-type of fields that are defined for the attribute profile
ptype_sng_gc             TYPE cvlc17-ptype     VALUE 'S',
ptype_mlt_gc             TYPE cvlc17-ptype     VALUE 'M',

*---------------------------------------------------------------------

* THE DESEG ISSUE
* ===============

* Administration of active R/3 modules (see function module
* VELO09_ADMIN_ACTIVE_MODULES)
value_mm_gc               TYPE i                VALUE '1',
value_sd_gc               TYPE i                VALUE '2',
value_le_gc               TYPE i                VALUE '1',
value_sm_gc               TYPE i                VALUE '1',
value_uk_gc               TYPE i                VALUE '2',
max_value_gc              TYPE i                VALUE '3',

*---------------------------------------------------------------------

* CONSTANTS FOR ACTION CONFIGURATION HANDLING
* ===========================================

** VALUES FOR VLC_CFGTY (NEEDED FOR TABLE OF ADDITIONAL CONFIGURATIONS)
*  Qualifier for historical configurations: planned
cfgty_pl_gc        TYPE vlc_cfgty       VALUE 'PL',
*  Qualifier for historical configurations: before rework
cfgty_rw_gc        TYPE vlc_cfgty       VALUE 'RW',
*  Qualifier for original customer demand configurations
cfgty_cd_gc        TYPE vlc_cfgty       VALUE 'CD',

*  Function module VELO03_SET_SINGLE_CONFIG is sometimes called several
*  times by the same action. So the the ABA is not enough information
*  for the function module's BAdI in order to know, what to do with the
*  configuration. Therefore if VELO03_SET_SINGLE_CONFIG is used several
*  times by the same action, the function module has to be called with
*  a different CFGCALLID each time.
cfgcallid_1_gc            TYPE vlc_cfgcallid       VALUE '1',
cfgcallid_2_gc            TYPE vlc_cfgcallid       VALUE '2',
cfgcallid_3_gc            TYPE vlc_cfgcallid       VALUE '3',
cfgcallid_4_gc            TYPE vlc_cfgcallid       VALUE '4',
cfgcallid_5_gc            TYPE vlc_cfgcallid       VALUE '5',

*  Configuration possibilities in actions
can_config_gc             TYPE c                   VALUE '2',
must_config_gc            TYPE c                   VALUE '1',
mustnt_config_gc          TYPE c                   VALUE ' ',

*---------------------------------------------------------------------
* CONSTANTS FOR MM-ACTIONS
* =========================

* Purchasing order category in action ORD1 (original: 'F')
ord1_bstyp_gc             TYPE bstyp             VALUE 'F',
*---------------------------------------------------------------------

* CONSTANTS FOR SD-ACTIONS
* =========================

* SALES DOCUMENT CATEGORIES
* Offer
sd_doc_type_b_gc(1)       TYPE c                VALUE 'B',
* Order
sd_doc_type_c_gc(1)       TYPE c                VALUE 'C',
* Invoice
sd_doc_type_m_gc(1)       TYPE c                VALUE 'M',

* PARTNER
* Partner: sold-to party
part_ag_gc(2)             TYPE c                VALUE 'AG',
* Partner: ship-to party
part_we_gc(2)             TYPE c                VALUE 'WE',
* Partner: dealer
ag_gc                     TYPE parvw            VALUE 'AG',

* PARTNER DETERMINATION           (Note 496807, added on 19.02.2002)
* Partner type: Customer
part_type_ku_gc           TYPE nrart            VALUE 'KU',
* Partner type: Contact person
part_type_ap_gc           TYPE nrart            VALUE 'AP',
* Partner type: Supplier
part_type_li_gc           TYPE nrart            VALUE 'LI',
* Partner type: Personnel number
part_type_pe_gc           TYPE nrart            VALUE 'PE',

* Transfer Status
trstat_req_gc              TYPE VLC_TRANSSTAT    VALUE  'REQ',
trstat_acc_gc              TYPE VLC_TRANSSTAT    VALUE  'ACC',
trstat_cnf_gc              TYPE VLC_TRANSSTAT    VALUE  'CNF',
trstat_cnc_gc              TYPE VLC_TRANSSTAT    VALUE  'CNC',
trstat_rej_gc              TYPE VLC_TRANSSTAT    VALUE  'REJ',
trstat_akn_gc              TYPE VLC_TRANSSTAT    VALUE  'AKN',

* Dealer Type
dealtype_rqd_gc            TYPE VLC_DEALTYPE    VALUE   'RQD',
dealtype_dvd_gc            TYPE VLC_DEALTYPE    VALUE   'DVD',
*---------------------------------------------------------------------

* CONSTANTS FOR LE-ACTIONS
* =========================

* MOVEMENT TYPES
* Goods movement type in action GORE
gore_bwart_gc             TYPE bwart             VALUE '101',
* Goods movement type in action STOL
stol_bwart_gc             TYPE bwart             VALUE '311',
* Goods movement type in action UORD/UTPO
utpo_bwart_gc             TYPE bwart             VALUE '541',
* Goods movement type in action IEID
ieid_bwart_gc             TYPE bwart             VALUE '561',
* Goods movement type in action GIWD
giwd_bwart_gc             TYPE bwart             VALUE '601',
* Goods movement type in action CSCO
smco_bwart_gc             TYPE bwart             VALUE '261',
* Goods movement type in action REUS
reus_bwart_gc             TYPE bwart             VALUE '453',

* Goods movement type in action CPGM
cpgm_bwart_gc             TYPE bwart             VALUE '301',

* DELIV_TYPE_GC(4)          TYPE C                 VALUE 'L1',
* GOIS_MCODE_GC             TYPE BAPI2017_GM_CODE  VALUE '03',
* GOIS_KZBEW_GC             TYPE KZBEW             VALUE 'L',

*---------------------------------------------------------------------

*=====================================================================
*=====================================================================


* CONSTANTS FOR VMS-ACTIONS
* =========================

* output issue application
appl_rv_gc            TYPE t681a-kappl  VALUE  'RV',

* Workflow event
wfevent_gc            TYPE swr_struct-event VALUE 'ACTION_STARTED',

*=====================================================================
*=====================================================================

* CONSTANTS FOR IDOC Functions
* =========================

*--> IDOC Message Types
mestyp_cpo_gc             TYPE edidc-mestyp      VALUE 'VLCCPO',

*--> Vehicle IDOC-Segments
veh_ident_gc TYPE edidd-segnam VALUE 'E1VLCK1',
veh_head_gc  TYPE edidd-segnam VALUE 'E1VLCK2',
veh_conf1_gc TYPE edidd-segnam VALUE 'E1VLCC1',
veh_conf2_gc TYPE edidd-segnam VALUE 'E1VLCC2',
veh_conf3_gc TYPE edidd-segnam VALUE 'E1VLCC3',
veh_conf4_gc TYPE edidd-segnam VALUE 'E1VLCC4',
veh_addit_gc TYPE edidd-segnam VALUE 'E1VLCA1',
veh_check_gc TYPE edidd-segnam VALUE 'E1EDS01',

*--> Idoc-status
not_posted_gc TYPE teds1-status VALUE '51',
waiting_gc    TYPE teds1-status VALUE '52',
posted_gc     TYPE teds1-status VALUE '53',
no_further_processing_gc TYPE teds1-status VALUE '68',

*=====================================================================
*=====================================================================







*--> return_variables - workflow_result
wf_result_error_gc TYPE bdwfap_par-result VALUE '99999',
wf_result_ok_gc    TYPE bdwfap_par-result VALUE '0',

*--> Ranges constants
i_gc     TYPE c VALUE 'I',
e_gc     TYPE c VALUE 'E',
eq_gc(2) TYPE c VALUE 'EQ',
ne_gc(2) TYPE c VALUE 'NE',
bt_gc(2) TYPE c VALUE 'BT',

*--> Error Handling
eetype_gc TYPE bapireturn-type VALUE 'E',


*--> Change Types
vehich_gc     TYPE vlcmvepo-chtyp VALUE 'C10',
cuch_gc       TYPE vlcmvepo-chtyp VALUE 'C20',
adch_gc       TYPE vlcmvepo-chtyp VALUE 'C30',

* --> Time Constants
time_0_gc     TYPE edidc-updtim VALUE '000000',
time_24_gc    TYPE edidc-updtim VALUE '240000',


tabstrip_warranty_gc(17)  TYPE c   VALUE 'TABSTRIP_WARRANTY',
warranty_obj_type_gc(3)   TYPE c   VALUE 'IEQ',
warranty_obj_vlc_gc(3)    TYPE c   VALUE 'VLC',
warranty_obj_vh_gc(2)     TYPE c   VALUE 'VH',
warranty_obj_ie_gc(2)     TYPE c   VALUE 'IE',

gc_display(1)             TYPE c   VALUE 'D',
gc_change(1)              TYPE c   VALUE 'C',
inbound_warranty_gc       TYPE c   VALUE '1',
outbound_warranty_gc      TYPE c   VALUE '2',

vlc_mganr1_gc             TYPE mganr VALUE '178',
vlc_mganr2_gc             TYPE mganr VALUE '2000000010',

*--> SCEM (Supply Chain Event Manager)
scem_dynnr_em_gc          TYPE sydynnr VALUE '2050',
                                 " Subcreen for Event Manager
scem_dynnr_msg_gc         TYPE sydynnr VALUE '2051',
                                 " Subscreen for Messages and Status
scem_subscreen_program_gc TYPE sy-repid VALUE 'SAPLVMS_04',
                                 " Program for SCEM-Subscreens
scem_maintabdef_gc(30)    TYPE c VALUE 'VLCDIAVEHI',

* --> Action Log Object
actlog_idoc_gc    TYPE  balobj_d VALUE 'VMS_IDOC',
actlog_resv_gc    TYPE  balobj_d VALUE 'VMS_RESV',
actlog_actn_gc    TYPE  balobj_d VALUE 'VMS_ACTION',
actlog_assgnmt_gc TYPE  balobj_d VALUE 'VMS_ASSGNMT',


*** central address maintainance.

* All addresses created by vehicle locator are in the group
* 'VEHI'
addr_group_vehi_gc    TYPE ad_group     VALUE  'VEHI',

* Location addresses are of group LOCT
addr_group_loct_gc    TYPE ad_group     VALUE  'LOCT',

* the different modes, in which the subscreen can be called. in mode
* SHOW for example, all input fields are disabled.
mode_create_gc        TYPE ad_mntmd     VALUE  'CREATE',
mode_change_gc        TYPE ad_mntmd     VALUE  'CHANGE',
mode_display_gc       TYPE ad_mntmd     VALUE  'DISPLAY',


* Constants used for definition of Validation/Substitution/Rules

* Category Management ...
cm_valuser            TYPE gb03-valuser      VALUE 'VM',
cm_boolclass          TYPE gb02-boolclass    VALUE 'VM1',
cm_valevent           TYPE gb31-valevent     VALUE '0001',

* BOR Object
bus_return_gc        TYPE bapiusw01-objtype VALUE 'BUS2102',"return o
bus_obj_gc           TYPE borident-objtype  VALUE 'BUS1200',
bus_so_gc            TYPE bapiusw01-objtype VALUE 'BUS2032', "SalesOrder
bus_offer_gc         TYPE bapiusw01-objtype VALUE 'BUS2031', "offer
bus_delivery_gc      TYPE bapiusw01-objtype VALUE 'LIKP',
bus_inquiry_gc       TYPE bapiusw01-objtype VALUE 'BUS2030',"Inquiry
bus_po_gc           TYPE borident-objtype  VALUE 'BUS2012', "PurcahseOrd
bus_smorder_gc      TYPE borident-objtype  VALUE 'BUS2088', "ServiceOrd
bus_smnotif_gc      TYPE borident-objtype  VALUE 'BUS2080', "Srv_Ord_not
bus_equi_gc      TYPE borident-objtype  VALUE 'EQUI', "Equipment

bus_invoice_gc      TYPE borident-objtype  VALUE 'BUS2081', "Invoice inc
bus_ouinvo_gc      TYPE borident-objtype  VALUE 'BUS2037', "Invoice out
bus_goodsr_gc      TYPE borident-objtype  VALUE 'MKPF', "Goods receipt
bus_goodsmv_gc      TYPE borident-objtype  VALUE 'BUS2017',
*Goods Movement



class_type_bo_gc     TYPE bapibds01-classtype VALUE 'BO',

* Partner Role
role_gc              TYPE bus0rltyp-rltyp      VALUE 'VLC001',



* Default pattern for displayed status
stat_space_sug_gc   TYPE vlc_statu            VALUE '____',

* max columns in matrix
max_matrix_cols_gc        TYPE i                VALUE 9,

i1_gc                     TYPE i                VALUE   1,
i2_gc                     TYPE i                VALUE   2,
i3_gc                     TYPE i                VALUE   3,
i4_gc                     TYPE i                VALUE   4,



* LiveCache-Handling
lc_setback_gc             TYPE int4             VALUE '240024',
lc_nofound_gc             TYPE int4             VALUE '240001',


* Mid of month
mid_of_month_gc(2)        TYPE c                 VALUE '15',


* currency exchanges
type_of_rate_gc(1)        TYPE c                 VALUE 'M',

* Max. number of locations/range-searchcrits for search
maxrge_gc                 TYPE i                 VALUE 2000,

* constants for VELO13_SEARCH_VEHI_CORE
cv_livecache(10)          TYPE c              VALUE 'LiveCache',
cv_ibase(10)              TYPE c              VALUE 'IBase',

* constants for VELO02_SEARCHPROFILE_LOAD
cv_actdatu(10)            TYPE c              VALUE 'ACTDATU',

searchmode_gc             TYPE vlc_fieldname  VALUE 'SEARCHMODE',
validat_gc                TYPE vlc_fieldname  VALUE 'VALIDAT',

* constant for time unit in Customer Service
time_unit_gc              TYPE meins          VALUE 'H',

* Container name for alv grids
container_name1_gc(30)    TYPE c
                         VALUE    'VLCACTDATA_ALV_SUBITEMS_1',
container_name2_gc(30)    TYPE c
                         VALUE    'VLCACTDATA_ALV_SUBITEMS_2',
container_name3_gc(30)    TYPE c
                         VALUE    'VLCACTDATA_ALV_SUBITEMS_3',
* Container name for HTML-controls
html_cont_name1_gc(30)    TYPE c
                         VALUE    'VLCACTDATA_HTML',


* constants for service management
* ================================

* Control key for service order operations
steus_gc                  TYPE steus VALUE 'SM01',

* status values:
status_rueck_gc            TYPE j_status VALUE 'I0009',
status_truec_gc            TYPE j_status VALUE 'I0010',
status_maof_gc             TYPE j_status VALUE 'I0154',
status_maer_gc             TYPE j_status VALUE 'I0156',
status_tabg_gc             TYPE j_status VALUE 'I0045',
status_abgs_gc             TYPE j_status VALUE 'I0046',
status_mmab_gc             TYPE j_status VALUE 'I0072',
status_fakt_gc             TYPE j_status VALUE 'I0397',
status_tfak_gc             TYPE j_status VALUE 'I0398'.
* =================================

*** include the document types/categories used by SD/MM/SM actions !
INCLUDE lvelo02doc.

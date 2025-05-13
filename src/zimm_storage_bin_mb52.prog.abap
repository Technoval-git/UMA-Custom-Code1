*&---------------------------------------------------------------------*
*& Include          ZIMM_STORAGE_BIN_MB52
*&---------------------------------------------------------------------*

* Type pools
TYPE-POOLS: slis, imrep.

* Database tables
TABLES: mara, makt,  mchb, mkol, mslb, mska, msku, mssa, mspr,
        mssq, mbew, ebew, qbew, t134m, t001w, t001l, marc, t001, t001k,
        t023, t024.

TABLES : sscrfields.         "for the user-commands

* working table for the entries of all stock tables
DATA: BEGIN OF collector OCCURS 0,
        matnr    LIKE mara-matnr,
        werks    LIKE t001w-werks,
        lgort    LIKE mard-lgort,
        sobkz    LIKE mkol-sobkz,
        bwtar    LIKE mcha-bwtar,                           "1795093
        pspnr    LIKE  mspr-pspnr,
        vbeln    LIKE  mska-vbeln,
        posnr    LIKE  mska-posnr,
        lifnr    LIKE mslb-lifnr,
        kunnr    LIKE msku-kunnr,
        lvorm    LIKE  mard-lvorm,

        kzbws    LIKE mssa-kzbws,
        charg    LIKE mchb-charg,
        labst    LIKE mard-labst,
        insme    LIKE mard-insme,
        speme    LIKE mard-speme,
        einme    LIKE mard-einme,
        retme    LIKE mard-retme,
        umlme    LIKE mard-umlme,
        bwesb    LIKE  marc-bwesb,                          "AC0K020254
        glgmg    LIKE marc-glgmg,                           "n912093
        trame    LIKE marc-trame,                           "n912093
        umlmc    LIKE marc-umlmc,                           "n912093
        maktx    LIKE makt-maktx,                           "1795093
        xchar    LIKE marc-xchar,                           "1795093
        sgt_scat LIKE mchb-sgt_scat,
        lgpbe    LIKE mard-lgpbe.
*ENHANCEMENT-POINT EHP604_RM07MLBS_01 SPOTS ES_RM07MLBS STATIC .
DATA: END OF collector.

* Internal tables
DATA: BEGIN OF header OCCURS 0,
        matnr LIKE mara-matnr,
        maktx LIKE makt-maktx,
        werks LIKE t001w-werks,
        name1 LIKE t001w-name1,
        mtart LIKE mara-mtart,
        matkl LIKE mara-matkl.
*ENHANCEMENT-POINT EHP604_RM07MLBS_02 SPOTS ES_RM07MLBS STATIC .
  DATA: mfrnr TYPE mara-mfrnr,                              "CR 3472
        name2 type lfa1-name1.                              "CR 3472
  data: bismt type mara-bismt.    " 3785
DATA: END OF header.

DATA: BEGIN OF bestand OCCURS 0,
*        Key fields
        matnr      LIKE mara-matnr,
        werks      LIKE t001w-werks,
        lgort      LIKE mard-lgort,
        sobkz      LIKE mkol-sobkz,
        ssnum      LIKE  bickey-ssnum,                      "n531604
        pspnr      LIKE  mspr-pspnr,                        "n531604
        vbeln      LIKE  mska-vbeln,                        "n531604
        posnr      LIKE  mska-posnr,                        "n531604
        lifnr      LIKE mkol-lifnr,
        kunnr      LIKE msku-kunnr,
        kzbws      LIKE mssa-kzbws,
        charg      LIKE mchb-charg,
*        Additional data (texts, unit, ...)
        maktx      LIKE marav-maktx,
        bwkey      LIKE mbew-bwkey,
        mtart      LIKE marav-mtart,
        matkl      LIKE marav-matkl,
        meins      LIKE marav-meins,
        bwtty      LIKE marc-bwtty,
        xchar      LIKE marc-xchar,
        lgobe      LIKE t001l-lgobe,
        bwtar      LIKE mcha-bwtar,
        waers      LIKE t001-waers,
        name1      LIKE t001w-name1,
*        Quantities and currencies
        labst      LIKE mard-labst,
        wlabs      LIKE mbew-salk3,
        insme      LIKE mard-insme,
        winsm      LIKE mbew-salk3,
        speme      LIKE mard-speme,
        wspem      LIKE mbew-salk3,
        einme      LIKE mard-einme,
        weinm      LIKE mbew-salk3,
        retme      LIKE mard-retme,
        wretm      LIKE mbew-salk3,
        umlme      LIKE mard-umlme,
        wumlm      LIKE mbew-salk3,
        glgmg      LIKE marc-glgmg,                         "n912093
        wglgm      LIKE mbew-salk3,                         "n912093
        trame      LIKE marc-trame,                         "n912093
        wtram      LIKE mbew-salk3,                         "n912093
        umlmc      LIKE marc-umlmc,                         "n912093
        wumlc      LIKE mbew-salk3,                         "n912093

*        Dummy field
        dummy      TYPE  alv_dummy,
*        Colour
        farbe      TYPE slis_t_specialcol_alv,
        lvorm      LIKE  mard-lvorm,

*        valuated blocked GR stock                       "AC0K020254
        bwesb      LIKE  marc-bwesb,                        "AC0K020254
        wbwesb     LIKE  mbew-salk3,                        "AC0K020254
        sgt_scat   LIKE  mchb-sgt_scat,
        lgpbe      TYPE lgpbe,
        budat_mkpf TYPE budat.
*ENHANCEMENT-POINT EHP604_RM07MLBS_03 SPOTS ES_RM07MLBS STATIC .
* CR 8100003472: Addl fields: Manufacturer and Manufacturer name
  DATA: mfrnr TYPE mara-mfrnr,
        name2 type lfa1-name1.

  data: bismt type mara-bismt.    " CR 3785
DATA:  END OF bestand.

* define a lean table organ
TYPES : BEGIN OF stype_organ,
          werks LIKE  t001w-werks,
          bwkey LIKE  t001w-bwkey,
          name1 LIKE  t001w-name1,
          bukrs LIKE  t001-bukrs,
          waers LIKE  t001-waers,
        END OF stype_organ,

        stab_organ TYPE STANDARD TABLE OF
                             stype_organ
                             WITH DEFAULT KEY.

DATA: g_t_organ TYPE  stab_organ,
      g_s_organ TYPE  stype_organ.

* define a buffer table for the MARD entries with flag
* for deletion
TYPES : BEGIN OF stype_mard_lv,
          matnr LIKE  mard-matnr,
          werks LIKE  mard-werks,
          lgort LIKE  mard-lgort,
          lvorm LIKE  mard-lvorm,
        END OF stype_mard_lv,

        htab_mard_lv TYPE HASHED TABLE OF
                             stype_mard_lv
                   WITH UNIQUE KEY matnr werks lgort.

DATA : g_s_mard_lv TYPE  stype_mard_lv,
       g_t_mard_lv TYPE  htab_mard_lv.

* define a buffer table for the storage bins
TYPES : BEGIN OF stype_t001l,
          werks LIKE  t001l-werks,
          lgort LIKE  t001l-lgort,
          lgobe LIKE  t001l-lgobe,
        END OF stype_t001l,

        htab_t001l TYPE HASHED TABLE OF
                             stype_t001l
                             WITH UNIQUE KEY werks lgort.

DATA : g_s_t001l TYPE  stype_t001l,
       g_t_t001l TYPE  htab_t001l.

TYPES : BEGIN OF stype_t001w,                               "09122009
          werks TYPE  t001w-werks,                          "09122009
          bwkey TYPE  t001w-bwkey,                          "09122009
          name1 TYPE  t001w-name1,                          "09122009
        END OF stype_t001w.                                 "09122009
                                                            "09122009
DATA : gt_t001w              TYPE  STANDARD TABLE           "09122009
                                   OF stype_t001w.          "09122009

* define working areas for access table organ               "n531604
TYPES : BEGIN OF stype_buffer,                              "n531604
          werks LIKE  t001w-werks,
          bukrs LIKE  t001-bukrs,
          subrc LIKE  syst-subrc,
        END OF stype_buffer,

        stab_buffer TYPE STANDARD TABLE OF
              stype_buffer
              WITH DEFAULT KEY.

DATA : g_s_buffer TYPE  stype_buffer,
       g_t_buffer TYPE  stab_buffer.

* Data for listviewer
DATA: repid     LIKE sy-repid.
DATA: fieldcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA: keyinfo   TYPE slis_keyinfo_alv.
DATA: color     TYPE slis_t_specialcol_alv WITH HEADER LINE.
DATA: layout    TYPE slis_layout_alv.

DATA: sort      TYPE slis_t_sortinfo_alv WITH HEADER LINE.
DATA: excluding TYPE slis_t_extab WITH HEADER LINE.

* internal working table for events / for the headlines     "n667256
DATA: gs_events     TYPE slis_alv_event.                    "n667256
DATA: gt_events     TYPE slis_t_event.                      "n667256

                                                            "n667256
* for the header of the list, when alv grid is in use       "n667256
DATA : gt_ueb TYPE  slis_t_listheader,                      "n667256
       gs_ueb TYPE  slis_listheader.                        "n667256

* Variants
DATA: variante        LIKE disvariant,
      variante_flat   LIKE disvariant,
      def_variante    LIKE disvariant,
      def_variante_f4 LIKE disvariant,
      variant_exit(1) TYPE c.

*ENHANCEMENT-POINT RM07MLBS_01 SPOTS ES_RM07MLBS STATIC.
*ENHANCEMENT-POINT RM07MLBS_13 SPOTS ES_RM07MLBS STATIC .
DATA : g_f_vari_hsq LIKE  disvariant-variant,
       g_f_vari_flt LIKE  disvariant-variant.

* working fields to save the initial display variants       "n579976
DATA : g_f_vari_hsq_initial LIKE  disvariant-variant,       "n579976
       g_f_vari_flt_initial LIKE  disvariant-variant.       "n579976

* Global variables for handling ALV functionality
TABLES: mmim_rep_print.

DATA: alv_keyinfo      TYPE slis_keyinfo_alv.
DATA: alv_variant      LIKE disvariant.
DATA: alv_layout       TYPE slis_layout_alv.
DATA: alv_repid        LIKE sy-repid.
DATA: alv_print        TYPE slis_print_alv.
DATA: alv_detail_func(30) TYPE  c,
      alv_color           LIKE      mmim_rep_print-color.

* User settings for the checkboxes
DATA: oref_settings TYPE REF TO cl_mmim_userdefaults.

* define working fields
DATA : g_cnt_col_pos TYPE i,
       g_cnt_spos    TYPE i.

DATA : g_flag_ok(01)       TYPE c,
       g_flag_mess_333(01) TYPE c,
       g_flag_t001l(01)    TYPE c.

DATA : g_cnt_variant_error   TYPE i.                        "n667256

* does the user want to suppress objects from plant level ? "n577268
DATA : g_flag_suppress_init_lgort(01)  TYPE c.              "n577268

DATA : BEGIN OF g_flag_sobkz,
         vbeln(01) TYPE c,
         pspnr(01) TYPE c,
         lifnr(01) TYPE c,
         kunnr(01) TYPE c,
       END OF g_flag_sobkz.

CONSTANTS : c_no_out(01) TYPE c    VALUE 'X',
            c_out(01)    TYPE c    VALUE space.

* flag to be set when INITIALIZATION was processed          "n667256
DATA g_flag_initialization(01) TYPE c.                      "n667256

* authorization check should be always processed            "n829722
DATA t_flag_launched(01) TYPE c.                            "n829722

DATA:
  dbcon        TYPE dbcon_name,                             "n1710852
  newsel(01)   TYPE c,                                      "n1795093
  lv_dontpanic TYPE symsgv.                                 "n1795093

CONSTANTS:
  c_hdb_dbcon_get TYPE funcname VALUE 'MM_HDB_DBCON_GET',   "n1710852
  c_hdb_subappl   TYPE program  VALUE 'MB52'.               "n1710852

DATA:                                                       "n1795093
  collector_mard LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mchb LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mkol LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mska LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mssa LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mspr LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mssq LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mbew LIKE STANDARD TABLE OF collector,          "n1795093
  collector_ebew LIKE STANDARD TABLE OF collector,          "n1795093
  collector_msku LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mslb LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mstb LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mste LIKE STANDARD TABLE OF collector,          "n1795093
  collector_mstq LIKE STANDARD TABLE OF collector,          "n1795093
  collector_uml  LIKE STANDARD TABLE OF collector.          "n1795093

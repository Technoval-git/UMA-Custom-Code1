*  *&---------------------------------------------------------------------*
*& Include          YSCC_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_totmver,
          matnr TYPE matnr,
          werks TYPE werks_d,
  matkl type matkl,
          total TYPE gsvbr,
        END OF ty_totmver.
TYPES: BEGIN OF ty_final_update.
         INCLUDE TYPE yi_abc_classification.
TYPES:     END OF ty_final_update.
TYPES: BEGIN OF ty_mrpplt,
         werks TYPE werks_d,
         pdt   TYPE zdepdt,
       END OF ty_mrpplt.
TYPES: BEGIN OF ty_mrpssf,
         werks TYPE werks_d,
         maabc TYPE maabc,
         slev  TYPE zdeslev,
         serpv TYPE zdeserpv,
       END OF ty_mrpssf.
TYPES: BEGIN OF ty_vbrkrp,
*        vbeln TYPE vbeln_vf,
         matnr TYPE matnr,
         werks TYPE werks_d,
         fkimg TYPE  fkimg,
       END OF  ty_vbrkrp.
TYPES: BEGIN OF ty_vbrkrp2,
         vbeln TYPE vbeln_vf,
         fkart TYPE fkart,
         matnr TYPE matnr,
         werks TYPE werks_d,
         fkimg TYPE  fkimg,
       END OF  ty_vbrkrp2.
TYPES: BEGIN OF ty_monts,
         month TYPE string,
         year  TYPE gjahr,
       END OF ty_monts.

TYPES: lt_syrrage TYPE RANGE OF sy-datum.
DATA: lt_final          TYPE TABLE OF ty_final_update,
      lt_final_t        TYPE STANDARD TABLE OF ymm_ssf,
      lt_mrppl          TYPE TABLE OF  ty_mrpplt,
      lt_mrpssf         TYPE   TABLE OF ty_mrpssf,
      LT_pastsal        TYPE TABLE OF ty_vbrkrp,
      LT_pastsal2       TYPE TABLE OF ty_vbrkrp2,
      wa_pastsal        TYPE  ty_vbrkrp,
      get_livedate      TYPE string,
      go_DATE           TYPE sy-datum,
      count_moths       TYPE i,
      gv_cout           TYPE i,
      lv_date           TYPE sy-datum,
      st_year           TYPE sy-datum,
      total             TYPE gsvbr,
      lv_return(5)      TYPE c,
      lt_years          TYPE RANGE OF gjahr,
      lt_months         TYPE TABLE OF ty_monts,
      ls_get_marahed    TYPE bapi_mara_ga,
      ls_get_marcpla    TYPE bapi_marc_ga,
      lv_material       LIKE bapi_mara_ga-material,
      lv_plant          TYPE werks_d,
      lv_eislo          TYPE eisbe,
      lt_return         TYPE TABLE OF bapi_matreturn2,
      ls_bapimatrhead   TYPE bapimathead,
      ls_bapiplantdata  TYPE bapi_marc,
      ls_bapiplantdatax TYPE bapi_marcx,
      lv_rc             TYPE i,
      lv_file           TYPE filetable,
      lv_action         TYPE i,
      go_ida            TYPE REF TO if_salv_gui_table_ida,
      gv_user           TYPE sy-uname,
      lt_syrange        TYPE RANGE OF sy-datum,
      stc_year          TYPE gjahr,
      lv_coumon         TYPE numc2, "i,
      lt_tabtot         TYPE TABLE OF ty_totmver,
      wa_tabtot         TYPE  ty_totmver,
      lv_functions      TYPE REF TO cl_salv_functions,
      ssf               TYPE eislo,
      lt              TYPE eislo,
      valu type string,
        lv_ss type i.
FIELD-SYMBOLS: <lt_finaldis> TYPE ANY TABLE,
               <worksheet>   TYPE STANDARD TABLE.

DATA lt_cpd_plants TYPE STANDARD TABLE OF zmm_cpd_plants.
DATA lw_cpd_plants TYPE zmm_cpd_plants.




TYPES: BEGIN OF ty_werks,
         sign   TYPE c LENGTH 1,
         option TYPE c LENGTH 2,
         low    TYPE werks_d,
         high   TYPE werks_d,
       END OF ty_werks.
DATA lw_werks TYPE ty_werks.


*    CONSTANTS: co_tvr TYPE se16n_value VALUE 'ZABC_GOLIVE'.
*           co_tvr type  VALUE ''

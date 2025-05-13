*&---------------------------------------------------------------------*
*& Include          YABC_I_CLASSIFICATION_TOP
*&---------------------------------------------------------------------*

TABLES: mara,
        marc.

DATA lt_cpd_plants TYPE STANDARD TABLE OF zmm_cpd_plants.
DATA lw_cpd_plants TYPE zmm_cpd_plants.
TYPES: BEGIN OF ty_werks,
         sign   TYPE c LENGTH 1,
         option TYPE c LENGTH 2,
         low    TYPE werks_d,
         high   TYPE werks_d,
       END OF ty_werks.
DATA lw_werks TYPE ty_werks.

CLASS lcl_abc_main DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_material_data,
             material      TYPE matnr,
             abc_indicator TYPE string,
           END OF ty_material_data.
    TYPES:BEGIN OF ty_dates_intervel,
            date_year TYPE char4,
            date_mon  TYPE char2,
            date_from TYPE sy-datum,
            date_to   TYPE sy-datum,
          END OF ty_dates_intervel.

    TYPES: ty_r_dates        TYPE RANGE OF sy-datum,
           ty_r_matnr        TYPE RANGE OF matnr,
           ty_r_werks        TYPE RANGE OF werks_d,
           tt_dates_intervel
                      TYPE STANDARD TABLE OF ty_dates_intervel.
    TYPES: BEGIN OF ty_salse_data,
             material TYPE matnr,
             werks    TYPE werks_d,
             fklmg    TYPE fklmg,
           END OF ty_salse_data.

    TYPES: BEGIN OF ty_final_abc,
             material   TYPE matnr,
             werks      TYPE werks_d,
             abc_actual TYPE ymaabc_a,
             abc_target TYPE ymaabc_t,
             error      TYPE bapi_mtype,
           END OF ty_final_abc.

    METHODS: constructor,
      upload_file,
      update_data     IMPORTING iv_material TYPE matnr OPTIONAL,

      calculate_dates EXPORTING ev_count_bgl      TYPE i
                                ev_count_agl      TYPE i
                                et_dates_intervel TYPE tt_dates_intervel
                                et_dates_legacy   TYPE tt_dates_intervel
                                er_dates_first_3m TYPE ty_r_dates
                                er_dates_secod_3m TYPE ty_r_dates,
      display_report,
      applyfilter.

  PRIVATE SECTION.

    DATA: gt_material_data TYPE TABLE OF ty_material_data,
          go_ida           TYPE REF TO if_salv_gui_table_ida,
          gv_user          TYPE sy-uname,
          gv_golive        TYPE sy-datum,
          gv_factor        TYPE i,
          gv_div           TYPE i,
          gv_fmonth        TYPE i,
          gv_smonth        TYPE i,
          gv_date_intervel TYPE RANGE OF sy-datum,
          gt_custom_abc    TYPE STANDARD TABLE OF yabc.

    METHODS: update_material IMPORTING iv_material TYPE matnr
                                       iv_plant    TYPE werks_d
                                       iv_abc_id   TYPE maabc
                             EXPORTING ev_maabc    TYPE maabc
                                       ev_error    TYPE xfeld,

      display_update CHANGING it_table  TYPE table,

      get_salesdata   IMPORTING iv_material   TYPE matnr
                                iv_plant      TYPE werks_d
                                ir_period     TYPE ty_r_dates
                      EXPORTING es_salse_data TYPE ty_salse_data,

      get_mevr IMPORTING iv_material     TYPE matnr
                         iv_plant        TYPE werks_d
                         it_dates_legacy TYPE tt_dates_intervel
                         v_count_agl     TYPE i
               EXPORTING es_legacy_f3m   TYPE ty_salse_data
                         es_legacy_s3m   TYPE ty_salse_data.


ENDCLASS.
CLASS lcl_selectionscreen DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: screen_validation,
      file_f4help.
ENDCLASS.
DATA: go_abc_main TYPE REF TO lcl_abc_main.

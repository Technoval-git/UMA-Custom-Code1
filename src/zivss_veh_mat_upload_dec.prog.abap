*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEH_MAT_UPLOAD_DEC
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_main_char,
          matnr   TYPE     char20,
          mbrsh   TYPE     char20,
          mtart   TYPE     char20,
*          werks   TYPE     char20,
*          lgort   TYPE     char20,
*          vkorg   TYPE     char20,
          bukrs   TYPE     char20,
          vtweg   TYPE     char20,
          maktx   TYPE     char50,
          maktx_a TYPE     char50,
          meins   TYPE     char20,
          matkl   TYPE     char20,
          mtpos   TYPE     char20,
          bismt   TYPE     char20,
          class   TYPE     char20,
          bstme   TYPE     char20,
          spart   TYPE     char20,
          taxm1   TYPE     char20,
          kondm   TYPE     char20,
          ktgrm   TYPE     char20,
          mtpos_d TYPE     char20,
          mtvfp   TYPE     char20,
          tragr   TYPE     char20,
          ladgr   TYPE     char20,
          xchpf   TYPE     char20,
          bwtty   TYPE     char20,
          ekgrp   TYPE     char20,
          prctr   TYPE     char20,
          dismm   TYPE     char20,
          bklas   TYPE     char20,
          vprsv   TYPE     char20,
          verpr   TYPE     char20,
          peinh   TYPE     char20,
        END OF ty_main_char.
TYPES : BEGIN OF ty_main,
          matnr   TYPE     matnr,
          mbrsh   TYPE     mbrsh,
          mtart   TYPE     mtart,
          bukrs   TYPE     bukrs,
          werks   TYPE     werks_d,
          lgort   TYPE     lgort_d,
          vkorg   TYPE     vkorg,
          vtweg   TYPE     vtweg,
          maktx   TYPE     maktx,
          maktx_a TYPE     maktx,
          meins   TYPE     meins,
          matkl   TYPE     matkl,
          mtpos   TYPE     mtpos,
          bismt   TYPE     bismt,
          class   TYPE     class-class,                     "cd 8956
          bstme   TYPE     bstme,
          spart   TYPE     spart,
          taxm1   TYPE     taxkm,
          kondm   TYPE     kondm,
          ktgrm   TYPE     ktgrm,
          mtpos_d TYPE     mtpos,
          mtvfp   TYPE     mtvfp,
          tragr   TYPE     tragr,
          ladgr   TYPE     ladgr,
          xchpf   TYPE     xchpf,
          bwtty   TYPE     bwtty_d,
          ekgrp   TYPE     ekgrp,
          prctr   TYPE     prctr,
          dismm   TYPE     dismm,
          bklas   TYPE     bklas,
          vprsv   TYPE     vprsv,
          verpr   TYPE     verpr,
          peinh   TYPE     peinh,
        END OF ty_main.

DATA : lt_main              TYPE STANDARD TABLE OF ty_main,
       lwa_main             TYPE ty_main,
       lt_zmm_mat_constant  TYPE STANDARD TABLE OF zmm_mat_constant,
       lwa_zmm_mat_constant TYPE zmm_mat_constant,
       lwa_main_char        TYPE ty_main_char.

DATA: lwa_header    TYPE bapimathead,
      lwa_makt      TYPE bapi_makt, "Short Text
      lwa_longtxt   TYPE bapi_mltx, " Long Text
      lwa_client    TYPE bapi_mara,
      lwa_clientx   TYPE bapi_marax,
      lwa_unit      TYPE bapi_marm,
      lwa_unitx     TYPE bapi_marmx,
      lwa_plant     TYPE bapi_marc,
      lwa_plantx    TYPE bapi_marcx,
      lwa_sale      TYPE bapi_mvke,
      lwa_salex     TYPE bapi_mvkex,
      lwa_tax       TYPE bapi_mlan,
      lwa_acc       TYPE bapi_mbew,
      lwa_accx      TYPE bapi_mbewx,
      lwa_store     TYPE bapi_mard,
      lwa_storex    TYPE bapi_mardx,
      lwa_forecast  TYPE bapi_mpop,
      lwa_forecastx TYPE bapi_mpopx,
      lwa_ware      TYPE bapi_mlgn,
      lwa_warex     TYPE bapi_mlgnx,
      lwa_return    TYPE bapiret2,
      it_makt       TYPE TABLE OF bapi_makt,
      it_tax        TYPE TABLE OF bapi_mlan.

CONSTANTS : ca_check TYPE c       VALUE '0',
            ca_ftype TYPE char10  VALUE 'ASC'.

TYPES: BEGIN OF ty_file_data,
         file_record(1000) TYPE c,
       END OF ty_file_data.

DATA : i_file_data  TYPE STANDARD TABLE OF  ty_file_data,
       wa_file_data TYPE ty_file_data.
DATA : wa_file_name  TYPE file_table.
DATA : lv_tab        TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.
DATA : lv_split1(20)  TYPE c,
       lv_split2(20)  TYPE c,
       lv_split3(20)  TYPE c,
       lv_split4(20)  TYPE c,
       lv_split5(20)  TYPE c,
       lv_split6(20)  TYPE c,
       lv_split7(20)  TYPE c,
       lv_split8(20)  TYPE c,
       lv_split9(20)  TYPE c,
       lv_split10(20) TYPE c,
       lv_split11(20) TYPE c,
       lv_split12(20) TYPE c,
       lv_split13(20) TYPE c,
       lv_split14(20) TYPE c.

TYPES: BEGIN OF ty_log,
         old_matnr TYPE bismt,
         material  TYPE matnr,
         plant     TYPE werks_d,
         type      TYPE bapi_mtype,
         message   TYPE bapi_msg,
       END OF ty_log.

DATA : lt_log TYPE STANDARD TABLE OF ty_log,
       ls_log TYPE ty_log.
DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
       wa_layout   TYPE slis_layout_alv,
       ls_print    TYPE slis_print_alv.
DATA va_top           TYPE slis_formname VALUE 'F_ALV_HEADER'.
DATA : lt_material TYPE STANDARD TABLE OF bapimatinr,
       ls_material TYPE bapimatinr.
DATA : lv_matnr TYPE matnr.
DATA: it_num TYPE TABLE OF bapi1003_alloc_values_num,
      it_cha TYPE TABLE OF bapi1003_alloc_values_char,
      it_cur TYPE TABLE OF bapi1003_alloc_values_curr,
      it_ret TYPE TABLE OF bapiret2.
DATA: lwa_objkey TYPE bapi1003_key.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: rb_pc RADIOBUTTON GROUP rad2 DEFAULT 'X' MODIF ID b3 USER-COMMAND select,
              rb_pi RADIOBUTTON GROUP rad2  MODIF ID b3.
  PARAMETERS: p_fname TYPE rlgrap-filename.
  PARAMETERS: p_log   TYPE localfile MODIF ID fil.
*                        DEFAULT '/tmp'. "CR 8100002945
SELECTION-SCREEN END OF BLOCK b1.

TYPES : BEGIN OF ty_unit_details,
          unit  TYPE msehi,
          numer TYPE dzaehl,
          denom TYPE nennr,
        END OF ty_unit_details.

TYPES : BEGIN OF ty_matnr_bismt,
          old_material TYPE bismt,
          sap_material TYPE matnr,
        END OF ty_matnr_bismt.

TYPES : BEGIN OF ty_matnr_plant,
          sap_material TYPE matnr,
          plant        TYPE werks_d,
        END OF ty_matnr_plant.

DATA: it_obj_key      TYPE STANDARD TABLE OF object_key INITIAL SIZE 0,
      wg_obj_key      TYPE object_key,
      it_attrib       TYPE STANDARD TABLE OF cpro_attr INITIAL SIZE 0,
      wg_attrib       TYPE cpro_attr,
      it_uom          TYPE TABLE OF bapi_marm,
      ts_uom          TYPE bapi_marm,
      it_uom_x        TYPE TABLE OF bapi_marmx,
      ts_uom_x        TYPE bapi_marmx,
      it_unit_details TYPE TABLE OF ty_unit_details,
      ts_unit_details TYPE ty_unit_details,
      it_unit_list    TYPE TABLE OF msehi,
      lt_bismt_db     TYPE TABLE OF ty_matnr_bismt,
      ts_bismt_db     TYPE ty_matnr_bismt,
      lt_matnr_plant  TYPE TABLE OF ty_matnr_plant,
      lts_matnr_plant TYPE ty_matnr_plant.
*      ts_mat_bismat_map TYPE ymat_bismt_model,
*      it_mat_bismat_map TYPE TABLE OF ymat_bismt_model.

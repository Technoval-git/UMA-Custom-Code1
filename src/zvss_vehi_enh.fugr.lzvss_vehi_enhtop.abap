FUNCTION-POOL zvss_vehi_enh.                "MESSAGE-ID ..

* INCLUDE LZVSS_VEHI_ENHD...                 " Local class definition

TYPE-POOLS: vlcc, icon.

INCLUDE ifrecamsg.

TABLES /dbe/vm_fields_crea.

*Constants definition
INCLUDE: /dbe/lvm08con.
*Init constants and API constants
INCLUDE: /dbe/lvm01con.
*Type definition
INCLUDE: /dbe/lvm08typ.
*Comunication variables
INCLUDE: /dbe/lvm08var.
*Class definition/implementation for addtional data table view
INCLUDE /dbe/lvm08cl1.
*Class definition/implementation for multi Iobject table controll
INCLUDE /dbe/lvm08cl2.
*Communication pbo/pai
INCLUDE /dbe/lvm08com.

*Form errors_show.
*INCLUDE /DBE/LVM08F38.

* Class definition/implementation for options alv event receiver
*INCLUDE /DBE/LVM07CL2.

TABLES: /dbe/v_imodel,
*<< VSS 3.0 – add customizable value range for model lines
        /dbe/vm_modlinet,
*>>
        /dbe/v_imodelt_data,
        /dbe/v_mcatalogt,
        /dbe/v_ivehicle,
        /dbe/v_iprices,
        /dbe/v_ifinanc,
        /dbe/v_ileasing,
        /dbe/v_icond,
        /dbe/cu_nfts_read,
        riwo03,
        /dbe/c_veh_maket.

DATA: gv_mcatalog TYPE /dbe/mcatalog.

*data-table and fieldcatalogue of the history-alv
TYPES:
  BEGIN OF ty_hist_alv.
    INCLUDE TYPE hist_out.
TYPES: row_color TYPE c LENGTH 4,
  END OF ty_hist_alv.
TYPES ty_hist_alv_t TYPE STANDARD TABLE OF ty_hist_alv.

DATA: gt_detail_history TYPE ty_hist_alv_t.
DATA: gt_detail_history_alvfieldcat   TYPE lvc_t_fcat.

*define the history-alv-objects
DATA: go_dethistory_container TYPE REF TO cl_gui_custom_container,
      go_dethistory_alv       TYPE REF TO cl_alv_grid_xt. "cl_gui_alv_grid.

*structures for displaying the address-data
DATA: supplier_ls TYPE vlcc_supplier_ps.

*Errors table
*DATA: GT_BAPIRETURN        TYPE BAPIRET2_T.

************** OPTIONS SCREEN **************************************

*--> alv overview object
DATA: g_alv_opt_grid TYPE REF TO cl_gui_alv_grid,
      g_alv_not_grid TYPE REF TO cl_gui_alv_grid.

*--> container
DATA : g_options_container   TYPE REF TO cl_gui_custom_container,
       g_notification_cont   TYPE REF TO cl_gui_custom_container,
       g_notification_cont_t TYPE REF TO cl_gui_custom_container.

* field catalog stucture name
DATA : gv_tabname TYPE tabname VALUE '/DBE/MODELALV'.
DATA : gt_alv_fieldcat        TYPE lvc_t_fcat.
DATA : gv_opttabname TYPE tabname VALUE '/DBE/V_ALVOPTIONS'.
DATA : gt_alv_opt_fieldcat        TYPE lvc_t_fcat.

DATA : gt_optionalv TYPE STANDARD TABLE OF /dbe/v_alvoptions,
       gt_notif_alv TYPE STANDARD TABLE OF wqmfe.

DATA : gv_selected_option_class TYPE /dbe/v_optype-opclass.
DATA : opclass LIKE /dbe/v_optype-opclass.
DATA : gv_dropdown_init(1).
DATA : gv_salesprice TYPE /dbe/mod_saleprice_ui.

DATA : gt_options TYPE /dbe/v_moptions_t.

CONSTANTS :
  gc_optclass_domain(30)    VALUE '/DBE/VD_OPCLASS',
  gc_opt_container_name     TYPE scrfname VALUE 'OPTIONS_GRID_CTRL',
  gc_notification_cont_name TYPE scrfname VALUE 'NOTIFICATION_CONTAINER',
  gc_notification_cont_text TYPE scrfname VALUE 'NOTIFICATION_LONGTEXT',
  gc_genopt_container_name  TYPE scrfname VALUE 'GENOPT_CONTAINER'.

* alv options field names
CONSTANTS :
  gc_active(6)       VALUE 'ACTIVE',
  gc_option_guid(11) VALUE 'OPTION_GUID',
  gc_model_guid(10)  VALUE 'MODEL_GUID',
  gc_mcatalog(8)     VALUE 'MCATALOG',
  gc_opclass(7)      VALUE 'OPCLASS',
  gc_opkey(5)        VALUE 'OPKEY',
  gc_optyp(5)        VALUE 'OPTYP',
  gc_activ(5)        VALUE 'ACTIV',
  gc_matnr(5)        VALUE 'MATNR',
  gc_puprc(5)        VALUE 'PUPRC',
  gc_pkonwa(6)       VALUE 'PKONWA',
  gc_saprc(5)        VALUE 'SAPRC',
  gc_skonwa(6)       VALUE 'SKONWA',
  gc_descr(5)        VALUE 'DESCR',
  gc_norordrel(9)    VALUE 'NOORDREL',
  gc_mm_noord(7)     VALUE 'MMNOORD',
  gc_vehicle_sint    TYPE exit_def    VALUE '/DBE/VEHICLE_SINT',
  gc_all_options     TYPE c           VALUE '*',
* application modes
  gc_view_mode(1)    VALUE '0',
  gc_optextnr(8)     VALUE 'OPTEXTNR',
  gc_f4_fc(4)        TYPE c           VALUE 'F4SH',
* partner determination
  gc_parvw_ag        TYPE parvw_4     VALUE 'AG'. "sold-to prty

*-----------------------------------------------------------------
* Vehicle Partner Screen (Screen 1200)
TABLES:
  /dbe/s_ord_bp_rel_scr.

DATA:
  gs_ord_bp_rel_scr_old TYPE /dbe/s_ord_bp_rel_scr.

*-----------------------------------------------------------------
* Vehicle's iObject history (Screen 1300)

DATA:
* Variables for the ALV
  gv_container   TYPE        scrfname VALUE 'GRID_IOBJ_ATTRIBUTEHISTORY',
  go_grid        TYPE REF TO cl_gui_alv_grid,
  go_custom_cont TYPE REF TO cl_gui_custom_container,
* History data needs to be a global variable to enable the ALV's
* standard export functions, e. g. to Excel
  gt_history     TYPE        /dbe/exts_tab_xobj_history.

*-----------------------------------------------------------------
* Vehicle's text maintenance screen (Screen 1700)

DATA: go_ltext_ui TYPE REF TO /dbe/cl_ltext_ui.

*-----------------------------------------------------------------
* Vehicle's data overview (Screen 1500)

TABLES:
  /dbe/vehordcom,
  /dbe/vlcselvehi.

DATA:
  cnt_label_business(40) TYPE c,
  cnt_label_primar(40)   TYPE c,
  cnt_label_secu(40)     TYPE c,
  cnt_label_werk(40)     TYPE c,
  cnt_label_lgort(40)    TYPE c,
  cnt_label_vkorg(40)    TYPE c,
  cnt_label_vtweg(40)    TYPE c,
  cnt_label_resgrp(40)   TYPE c,
  cnt_label_org_unit(40) TYPE c.

DATA:
  gcl_vehicle_con       TYPE REF TO cl_gui_custom_container,
  gcl_vehicle_edit      TYPE REF TO cl_gui_textedit,
  gcl_cust_con          TYPE REF TO cl_gui_custom_container,
  gcl_cust_edit         TYPE REF TO cl_gui_textedit,
  gcl_fin_debitor_con   TYPE REF TO cl_gui_custom_container,
  gcl_fin_debitor_edit  TYPE REF TO cl_gui_textedit,
  gcl_lea_debitor_con   TYPE REF TO cl_gui_custom_container,
  gcl_lea_debitor_edit  TYPE REF TO cl_gui_textedit,
  gcl_nofification_edit TYPE REF TO cl_gui_textedit.

TYPES:
  BEGIN OF ty_textlines,
    text(40) TYPE c,
  END OF ty_textlines.

DATA:
  gt_textlines TYPE STANDARD TABLE OF ty_textlines,
  gs_textlines LIKE LINE OF gt_textlines.

DATA:
  gt_veh_chgd     TYPE STANDARD TABLE OF /dbe/v_change_doc.

TABLES:
* structure containing the last service date
  /dbe/scr_data_overview.


CONSTANTS:
* Fields on creation screen
  gc_werks(3) TYPE c VALUE 'WRK',                           "#EC *
  gc_spart(3) TYPE c VALUE 'SPA',                           "#EC *
  gc_x        TYPE c VALUE 'X'.                             "#EC *

CONSTANTS:
  gc_alv_stru_notif TYPE tabname VALUE 'WQMFE'.

* Vehicle's data overview (Screen 0700)
DATA gv_old_0700_purcprice_c TYPE /dbe/mod_purcprice_c.     "N:1269985
DATA gv_old_0700_saleprice_c TYPE /dbe/mod_saleprice_c.     "N:1269985
*-----------------------------------------------------------------
* Vehicle's prices for used vehicle (Screen 1900)
DATA gv_old_1900_estpurpri_c TYPE /dbe/est_purcprice_c.     ">>1276934
DATA gv_old_1900_estsalpri_c TYPE /dbe/est_saleprice_c.
DATA gv_old_1900_aimpurpri_c TYPE /dbe/aimed_purcprice_c.
DATA gv_old_1900_aimsalpri_c TYPE /dbe/aimed_saleprice_c.   "<<1276934
*------------------------------------------------------------------
* Indicator if PAI was triggered before PBO (screen 1900)
DATA: gv_pai_1900                    TYPE c,                ">>1278743
      gv_pai_1900_estpurpri_c_change TYPE c,
      gv_pai_1900_estsalpri_c_change TYPE c,
      gv_pai_1900_aimpurpri_c_change TYPE c,
      gv_pai_1900_aimsalpri_c_change TYPE c.                "<<1278743

*-----------------------------------------------------------------
* VMS configuration screen (Screen 2100)

*--> define the configuration-alv-objects
DATA: detconfig_container_go TYPE REF TO cl_gui_custom_container,
      detconfig_alv_go       TYPE REF TO cl_gui_alv_grid.

*--> data-table and fieldcatalogue of the congiguration-alv
DATA: detail_config_gt             LIKE conf_out OCCURS 0,
      real_config_gt               LIKE conf_out OCCURS 0,
      detail_config_alvfieldcat_gt TYPE lvc_t_fcat,
      detail_config_alvfieldcat_gs TYPE lvc_s_fcat.

*-----------------------------------------------------------------
* Financing / Leasing screen (Screen 2000)
DATA: gv_finvalp_filled VALUE abap_false,
      gv_fintype_filled VALUE abap_false.
TYPES: BEGIN OF ty_fintype,
         fintype TYPE /dbe/fin_type,
         descr   TYPE /dbe/descr,
       END OF ty_fintype,
       BEGIN OF ty_finvalp,
         finvalp TYPE /dbe/fin_valp,
         descr   TYPE /dbe/descr,
       END OF ty_finvalp.
DATA: gt_fintype TYPE STANDARD TABLE OF ty_fintype
                 WITH HEADER LINE.
DATA: gt_finvalp TYPE STANDARD TABLE OF ty_finvalp
                 WITH HEADER LINE.

DATA: gv_leavalp_filled VALUE abap_false,
      gv_leatype_filled VALUE abap_false.
TYPES: BEGIN OF ty_leatype,
         leatype TYPE /dbe/lea_type,
         descr   TYPE /dbe/descr,
       END OF ty_leatype,
       BEGIN OF ty_leavalp,
         leavalp TYPE /dbe/lea_valp,
         descr   TYPE /dbe/descr,
       END OF ty_leavalp.
DATA: gt_leatype TYPE STANDARD TABLE OF ty_leatype
                 WITH HEADER LINE.
DATA: gt_leavalp TYPE STANDARD TABLE OF ty_leavalp
                 WITH HEADER LINE.

*-----------------------------------------------------------------
* Vehicle's condition screen (Screen 2200)
DATA: gv_refresh_notif_data(1) TYPE c.

*-----------------------------------------------------------------
* Generic Options screen (Screen 2300)

CONSTANTS:
  BEGIN OF gc_node_keys,
    root TYPE tv_nodekey VALUE 'ROOT',
  END OF gc_node_keys,
  BEGIN OF gc_column,
    column_1 TYPE tv_itmname VALUE 'GO_GROUP',
    column_2 TYPE tv_itmname VALUE 'COLUMN_2',
  END OF gc_column.

* Column tree for Generic Options (with Groups)
CLASS cl_gui_column_tree DEFINITION LOAD.
CLASS cl_gui_cfw         DEFINITION LOAD.

TYPES: ty_item_table_type LIKE STANDARD TABLE OF mtreeitm
       WITH DEFAULT KEY.

DATA: gt_go_group TYPE TABLE OF /dbe/s_veh_vs_tree_group,
      gt_genopt   TYPE TABLE OF /dbe/s_veh_vs_tree_genopt.

CLASS lcl_tree_group_icon    DEFINITION DEFERRED.
CLASS lcl_tree_application_u   DEFINITION DEFERRED.

DATA: go_tree             TYPE REF TO cl_gui_column_tree.

DATA: go_tree_application TYPE REF TO lcl_tree_application_u.

DATA: gv_nodekey TYPE tv_itmname.

INCLUDE /dbe/lvm05cl3.

TABLES: /dbe/s_veh_financing_dynp_f.

*-----------------------------------------------------------------
* Short texts
TABLES: /dbe/v_bodyt,
        /dbe/v_classt,
        /dbe/v_fltypet,
        /dbe/v_modelt,
        /dbe/v_drtypet,
        /dbe/v_battypt.

**********************************
* Contact person
DATA gt_cvi_cust_ct_link TYPE TABLE OF cvi_cust_ct_link.
DATA gv_tabix_ap         TYPE sy-tabix.

CONSTANTS: gc_insert       TYPE c     VALUE 'I',
           gc_delete       TYPE c     VALUE 'D',
           gc_part_type_ap TYPE nrart VALUE 'AP',
           gc_part_type_ag TYPE nrart VALUE 'AG'.

*-----------------------------------------------------------------
* Service History screen (Screen 2400)
DATA go_serv_hist_alv           TYPE REF TO cl_gui_alv_grid.
DATA go_cust_cont_serv_hist_alv TYPE REF TO cl_gui_custom_container.

DATA gv_serv_hist_read TYPE c.

DATA gt_serv_hist_alv_fieldcat TYPE lvc_t_fcat.
DATA gt_serv_hist_list         TYPE /dbe/t_vm_ui_serv_his.

DATA:
  gs_ermeasmeth_desc TYPE /dbe/v_measmetht,
  gs_comeasmeth_desc TYPE /dbe/v_measmetht
  .

* VSS4.0: Measurement Point/Doc {
TABLES:
  /dbe/itob_str_meas_doc_hdr_ui.
* VSS4.0: Measurement Point/Doc }

*   Vehicle: Warranty of equipment (Screen 2600)
DATA: go_alv_wty_c TYPE REF TO cl_gui_alv_grid.
DATA: go_alv_wty_v TYPE REF TO cl_gui_alv_grid.
DATA: go_alv_cont_wty_c TYPE REF TO cl_gui_custom_container.
DATA: go_alv_cont_wty_v TYPE REF TO cl_gui_custom_container.
DATA: gt_wty_data_c TYPE /dbe/itob_tab_equi_warranty.
DATA: gt_wty_data_v TYPE /dbe/itob_tab_equi_warranty.
DATA: gv_wty_check_res_c TYPE sy-subrc.
DATA: gv_wty_check_res_v TYPE sy-subrc.
DATA: gv_wty_icon1_c TYPE icon_text. "icon_d.
DATA: gv_wty_icon1_v TYPE icon_text. "icon_d.
DATA: go_wty_reader TYPE REF TO /dbe/cl_itob_equi_warranty.
CONSTANTS: gc_wty_data_str_name TYPE tabname VALUE /dbe/cl_itob_equi_warranty=>mc_str_name_data1.

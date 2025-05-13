CLASS zcl_vss_oem_veh_process DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
*
*    DATA ms_data TYPE yid1_go_data_jet_st READ-ONLY .
*    CONSTANTS:
*      BEGIN OF mc_parent_seg_no,
*        no_parent TYPE edi_psgnum VALUE '000000',
*      END OF mc_parent_seg_no .
*    CONSTANTS:
*      BEGIN OF mc_update_mode,
*        create TYPE yid1_update_mode VALUE 'CR',
*        change TYPE yid1_update_mode VALUE 'CH',
*      END OF mc_update_mode .
*    CONSTANTS:
*      BEGIN OF mc_param,
*        prod_cat                  TYPE yid1_parameter_de VALUE 'DBM_PRODUCT_CAT',
*        dbm_bustype               TYPE yid1_parameter_de VALUE 'DBM_BUSTYPE',
*        plant                     TYPE yid1_parameter_de VALUE 'PLANT',
*        division                  TYPE yid1_parameter_de VALUE 'DIVISION',
*        go_ord_sta_scheduled      TYPE yid1_parameter_de VALUE 'GO_ORD_STA_SCHE',
*        go_ord_sta_dlv_compl      TYPE yid1_parameter_de VALUE 'GO_ORD_STA_DLCO',
*        act_po_create             TYPE yid1_parameter_de VALUE 'ACT_PO_CREATE',
*        act_po_change             TYPE yid1_parameter_de VALUE 'ACT_PO_CHANGE',
*        purch_org                 TYPE yid1_parameter_de VALUE 'PURCH_ORG',
*        purch_grp                 TYPE yid1_parameter_de VALUE 'PURCH_GRP',
*        purch_ord_doc_type        TYPE yid1_parameter_de VALUE 'PO_DOC_TYPE',
*        feat_cat_option           TYPE yid1_parameter_de VALUE 'FEAT_CAT_OPTION',
*        feat_cat_color_ext        TYPE yid1_parameter_de VALUE 'FEAT_CAT_COLEXT',
*        feat_cat_color_int        TYPE yid1_parameter_de VALUE 'FEAT_CAT_COLINT',
*        feat_cat_transmission     TYPE yid1_parameter_de VALUE 'FEAT_CAT_TRANSM',
*        feat_cat_upholsstery      TYPE yid1_parameter_de VALUE 'FEAT_CAT_UPHOLS',
*        feat_cat_std_opt          TYPE yid1_parameter_de VALUE 'FEAT_CAT_STDOPT',
*        storage_location          TYPE yid1_parameter_de VALUE 'STORAGE_LOC',
*        material_opt              TYPE yid1_parameter_de VALUE 'MATERIAL_OPT',
*        allow_del_opt_after_sched TYPE yid1_parameter_de VALUE 'DEL_OP_AFT_SCH',
*        activate_pr_upd           TYPE yid1_parameter_de VALUE 'ACTIVATE_PR_UPD',
*      END OF mc_param .
*    CONSTANTS mc_commission_no_suffix TYPE char1 VALUE 'Z' ##NO_TEXT.
*
*    METHODS constructor
*      IMPORTING
*        !is_data TYPE yid1_go_data_jet_st
*        !ir_log  TYPE REF TO ZVSS_IFM_CL_X_LOG
*      RAISING
*        YCX_ERROR .
*    CLASS-METHODS idoc_vdit51_2_structure
*      IMPORTING
*        !is_edidc      TYPE edidc
*        !it_edidd      TYPE edidd_tt
*      RETURNING
*        VALUE(rs_data) TYPE yid1_go_data_jet_st
*      RAISING
*        YCX_ERROR .
*    METHODS process
*      RAISING
*        YCX_ERROR .
*    METHODS get_feat_cat_def
*      IMPORTING
*        !iv_optyp              TYPE dbm_optyp
*      RETURNING
*        VALUE(rs_feat_cat_def) TYPE /dbm/v_optype
*      RAISING
*        YCX_ERROR .
  PROTECTED SECTION.
*
*    DATA mr_log TYPE REF TO ZVSS_IFM_CL_X_LOG .
*    DATA mt_param TYPE yid1_param_jet_tt .
*    DATA mo_model_master TYPE REF TO ycl_dbm_jet_id1_model_master .
*    DATA mv_vhcex TYPE vlc_vhcex .
*    DATA mv_vhcle TYPE vlc_vhcle .
*    DATA mv_vguid TYPE vlc_guid .
*    DATA mv_charg TYPE charg_d .
*    DATA mv_bwtar TYPE bwtar_d .
*    DATA mt_feat_cat TYPE ydbm_id1_v_optype_tt .
*
*    METHODS call_vehicle_valuation_service
*      IMPORTING
*        !iv_new_service_call TYPE abap_bool OPTIONAL
*      RAISING
*        YCX_ERROR .
*    CLASS-METHODS action_execute
*      IMPORTING
*        !ir_log                  TYPE REF TO ZVSS_IFM_CL_X_LOG
*        !iv_action               TYPE vlc_action
*        !is_vlcdiavehi           TYPE vlcdiavehi
*        !is_vlcactdata_head      TYPE vlcactdata_head_s
*        !is_vlcactdata_item      TYPE vlcactdata_item_s
*        !it_vlcadddata           TYPE vlcadddata_item_t
*        !is_iobj_data_single_com TYPE /dbm/iobj_data_single_com_s
*        !is_iobj_data_multi_com  TYPE /dbm/iobj_data_multi_com_s
*        !iv_category_id          TYPE comt_category_id
*      RAISING
*        YCX_ERROR .
*    CLASS-METHODS action_prepare
*      IMPORTING
*        !ir_log                  TYPE REF TO ZVSS_IFM_CL_X_LOG
*        !iv_vguid                TYPE vlc_guid
*        !iv_action               TYPE vlc_action
*      EXPORTING
*        !es_vlcdiavehi           TYPE vlcdiavehi
*        !es_vlcactdata_head      TYPE vlcactdata_head_s
*        !es_vlcactdata_item      TYPE vlcactdata_item_s
*        !et_vlcadddata           TYPE vlcadddata_item_t
*        !es_iobj_data_single_com TYPE /dbm/iobj_data_single_com_s
*        !es_iobj_data_multi_com  TYPE /dbm/iobj_data_multi_com_s
*        !ev_category_id          TYPE comt_category_id
*      RAISING
*        YCX_ERROR .
*    CLASS-METHODS delivery_for_bwtar_exist_check
*      IMPORTING
*        !iv_charg                 TYPE charg_d
*      RETURNING
*        VALUE(rv_delivery_exists) TYPE abap_bool .
*    CLASS-METHODS delivery_for_charg_exist_check
*      IMPORTING
*        !iv_bwtar                 TYPE bwtar_d
*      RETURNING
*        VALUE(rv_delivery_exists) TYPE abap_bool .
*    METHODS get_param_value
*      IMPORTING
*        !iv_param           TYPE yid1_parameter_de
*      RETURNING
*        VALUE(rv_paravalue) TYPE yid1_paravalue_de
*      RAISING
*        YCX_ERROR .
*    METHODS inb_delivery_create
*      RAISING
*        YCX_ERROR .
*    METHODS init_veh_key_attr
*      IMPORTING
*        !iv_vhcex TYPE vlc_vhcex
*      RAISING
*        YCX_ERROR .
*    METHODS model_master_prepare_opt
*      CHANGING
*        !ct_options           TYPE /dbm/tv_options
*        !ct_option_long_texts TYPE /dbm/lt_ltext_com_tt
*        !ct_option_texts      TYPE /dbm/tv_options_t
*      RAISING
*        YCX_ERROR .
*    METHODS model_master_update
*      RAISING
*        YCX_ERROR .
*    METHODS model_master_update_mapping
*      RAISING
*        YCX_ERROR .
*    METHODS model_master_update_vm_options
*      RAISING
*        YCX_ERROR .
*    METHODS po_create
*      RAISING
*        YCX_ERROR .
*    CLASS-METHODS po_for_charg_exist_check
*      IMPORTING
*        !iv_charg           TYPE charg_d
*      RETURNING
*        VALUE(rv_po_exists) TYPE abap_bool .
*    METHODS prepare_vehicle_data
*      CHANGING
*        !cs_vlcactdata_head      TYPE vlcactdata_head_s
*        !cs_vlcactdata_item      TYPE vlcactdata_item_s
*        !ct_vlcadddata           TYPE vlcadddata_item_t
*        !cs_iobj_data_single_com TYPE /dbm/iobj_data_single_com_s
*        !cs_iobj_data_multi_com  TYPE /dbm/iobj_data_multi_com_s
*      RAISING
*        YCX_ERROR .
*    METHODS vehicle_get
*      IMPORTING
*        !ir_log                  TYPE REF TO ZVSS_IFM_CL_X_LOG
*        !iv_vhcex                TYPE vlc_vhcex
*      EXPORTING
*        !es_vlcdiavehi           TYPE vlcdiavehi
*        !es_vlcactdata_head      TYPE vlcactdata_head_s
*        !es_vlcactdata_item      TYPE vlcactdata_item_s
*        !et_vlcadddata           TYPE vlcadddata_item_t
*        !es_iobj_data_single_com TYPE /dbm/iobj_data_single_com_s
*        !es_iobj_data_multi_com  TYPE /dbm/iobj_data_multi_com_s
*        !ev_category_id          TYPE comt_category_id
*      RAISING
*        YCX_ERROR .
*    METHODS vehicle_master_create
*      RETURNING
*        VALUE(rv_vhcex) TYPE vlc_vhcex
*      RAISING
*        YCX_ERROR .
*    METHODS vehicle_master_exist_check
*      IMPORTING
*        !iv_vhcex        TYPE vlc_vhcex
*      RETURNING
*        VALUE(rv_exists) TYPE abap_bool
*      RAISING
*        YCX_ERROR .
*    METHODS vehicle_master_status_change
*      IMPORTING
*        !iv_order_status TYPE yid1_go_order_status_de
*      RAISING
*        YCX_ERROR .
*    METHODS vehicle_master_update
*      RAISING
*        YCX_ERROR .
*    CLASS-METHODS vehicle_master_update_vhcex
*      IMPORTING
*        !iv_vguid TYPE vlc_guid
*        !iv_vhcex TYPE vlc_vhcex
*        !ir_log   TYPE REF TO ZVSS_IFM_CL_X_LOG
*      RAISING
*        YCX_ERROR .
*    METHODS order_version_store
*      RAISING
*        YCX_ERROR .
*    CLASS-METHODS check_order_status
*      IMPORTING
*        !iv_order_status TYPE yid1_go_order_status_de
*      RETURNING
*        VALUE(rv_result) TYPE abap_bool .
*    METHODS po_update
*      RAISING
*        YCX_ERROR .
*    METHODS check_active_status_of_54
*      RETURNING
*        VALUE(rv_result) TYPE abap_bool
*      RAISING
*        YCX_ERROR .
*    METHODS check_existing_invoices
*      RETURNING
*        VALUE(rv_result) TYPE abap_bool
*      RAISING
*        YCX_ERROR .
*    METHODS update_po_exchange_rate
*      RAISING
*        YCX_ERROR .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VSS_OEM_VEH_PROCESS IMPLEMENTATION.
ENDCLASS.

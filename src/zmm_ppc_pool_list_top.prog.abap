*&---------------------------------------------------------------------*
*& Include          ZMM_PPC_POOL_LIST_TOP
*&---------------------------------------------------------------------*

TABLES: eban, ebkn,t001w.
*TABLES: rm06b, prps, resb.
TYPES BEGIN OF ty_eban.
INCLUDE STRUCTURE eban.
TYPES po_doc        TYPE esart.
TYPES pr_type       TYPE char10.
TYPES region        TYPE bezei20.
TYPES avail_stock   TYPE labst2.
TYPES sales_hist_12 TYPE labst2.
*TYPES sales_hist_9  TYPE labst2.   "added by ismail
TYPES sales_hist_6  TYPE labst2.
TYPES sales_hist_3  TYPE labst2.
TYPES pipe_line     TYPE labst2.
TYPES reserves      TYPE labst2.
TYPES it_cell_tab   TYPE lvc_t_styl.
TYPES matnr_ext TYPE matnr_ext.
TYPES: extwg             TYPE mara-extwg,
       vrfmg             TYPE vrfmg,
       resvd             TYPE bdmng,         "OPEN SO
       rct_rsvd          TYPE bdmng,         "OPEN RO
       open_po           TYPE mseg-menge,     " on Order stock/Open PO
       umlmc             TYPE marc-umlmc, " stock transfer
       safe_stk          TYPE eisbe,      "Safety stock
       reorder_point     TYPE minbe,      "reordering point
       curr_mnt          TYPE fkimg,
       mrp_qty           TYPE menge1,    "mrp quntity
       b_ord_qty         TYPE menge1,
       maabc             TYPE marc-maabc,
*--begin of addition Ismail for MRP fields..
       sales_hist_9      TYPE labst2,
       central_sto       TYPE menge13,
       western_sto       TYPE menge13,
       eastern_sto       TYPE menge13,
       open_so           TYPE menge13,
       osto_to_cr        TYPE menge13,
       osto_to_wr        TYPE menge13,
       osto_to_er        TYPE menge13,
       open_po_mrp       TYPE menge13,
       osto_frm_cr       TYPE menge13,
       osto_frm_wr       TYPE menge13,
       osto_frm_er       TYPE menge13,
       avail_stock_mrp   TYPE menge13,
       lead_time         TYPE menge13,
       service_level     TYPE menge13,
       no_sales_days     TYPE menge13,
       total_sales       TYPE menge13,
       avg_sales         TYPE menge13,
       daily_avg         TYPE menge13,
       avail_free_stock  TYPE  menge13,
       safety_stock      TYPE  eisbe,
       lt_demand_qty     TYPE menge13,
       reorder_point_mrp TYPE  minbe,
       open_pr           TYPE menge13,
       expected_pr_qty   TYPE  menge13,
*-- End of addition Ismail for MRp fields
       po_qty            TYPE bstmg,
       balance_qty       TYPE bstmg,
       pr_crtd_by        TYPE ernam,
       pr_crtd_name      TYPE emnam,
       pr_crtd_date      TYPE aedat.
TYPES END OF ty_eban.
*-- Begin of addition Ismail for MRp fields
*DATA: lt_mrp_stg TYPE STANDARD TABLE OF ydbm_mat_mrp_stg,
*      lw_mrp_stg TYPE ydbm_mat_mrp_stg.
FIELD-SYMBOLS: <fs_eban1> TYPE ty_eban.
*-- End of addition Ismail for MRp fields
TYPES:BEGIN OF ty_po_doct,
        ebeln TYPE ebeln,
        bsart TYPE esart,
      END OF ty_po_doct.

TYPES: BEGIN OF ty_po_details,
         selected_row  TYPE int4,
         ebeln         TYPE ebeln,
         po_order_type TYPE esart,
         reswk         TYPE reswk,
         werks         TYPE werks,
         menge         TYPE bamng,
         matnr         TYPE matnr,
         txz01         TYPE txz01,
         lifnr         TYPE wlief,
       END OF ty_po_details.
TYPES: BEGIN OF ty_output,
         matnr         TYPE mara-matnr,
         maktx         TYPE makt-maktx,
         bukrs         TYPE bukrs,    "company code
         bezei         TYPE t005u-bezei, "Region ( T005U - BEZEI )
         werks         TYPE t001w-werks,
         lgort         TYPE mseg-lgort,

         mtart         TYPE mara-mtart,
         extwg         TYPE mara-extwg,
         matkl         TYPE mara-matkl,
         meins         TYPE mara-meins,


         vrfmg         TYPE vrfmg,
         labst         TYPE mardh-labst, " unrestricted use
         resvd         TYPE bdmng,
         rct_rsvd      TYPE bdmng,
         open_po       TYPE mseg-menge,     " on Order stock/Open PO
*         klabs   TYPE mard-klabs, " consignment Order
         umlmc         TYPE marc-umlmc, " stock transfer


         safe_stk      TYPE eisbe,
         reorder_point TYPE minbe,
         curr_mnt      TYPE fkimg,
         three_mnt     TYPE fkimg,
         twelve_mnt    TYPE fkimg,

         mrp_qty       TYPE menge1,
         b_ord_qty     TYPE menge1,
         maabc         TYPE marc-maabc,

       END OF ty_output.

TYPES: BEGIN OF ty_werks_info,
         werks TYPE werks_d,
         name1 TYPE name1,
         land1 TYPE land1,
         regio TYPE regio,
         bezei TYPE bezei20,
       END OF  ty_werks_info,
       BEGIN OF ty_eban_qty,
         matnr TYPE eban-matnr,
         werks TYPE eban-werks,
         lgort TYPE eban-lgort,
         menge TYPE eban-menge,
       END OF ty_eban_qty,
       BEGIN OF ty_mard,
         matnr TYPE mard-matnr,
         werks TYPE mard-werks,
         lgort TYPE mard-lgort,
         labst TYPE mard-labst,
         klabs TYPE mard-klabs,
       END OF ty_mard.

TYPES: tt_output TYPE TABLE OF ty_output.

DATA it_eban_c  TYPE TABLE OF eban.
DATA: it_output  TYPE  TABLE OF ty_output,
      fs_output  TYPE ty_output,
      it_mara    LIKE it_output,
      it_pre_out LIKE it_output.
*      it_pre_out type HASHED TABLE OF ty_output with UNIQUE key matnr werks.
DATA: it_matnr      TYPE STANDARD TABLE OF ty_output,
      it_werks_info TYPE STANDARD TABLE OF ty_werks_info,
      it_mard       TYPE STANDARD TABLE OF ty_mard,
      it_eban       TYPE STANDARD TABLE OF ty_eban,
      it_mard_blank TYPE STANDARD TABLE OF ty_mard,
      ls_mard_blank TYPE ty_mard.

DATA: it_jah_plants TYPE STANDARD TABLE OF t001k,
      ls_jah_plants TYPE t001k.

DATA : ls_lgort TYPE lgort.

TYPES : BEGIN OF ty_resb,
          rsnum TYPE resb-rsnum,
          rspos TYPE resb-rspos,
          matnr TYPE resb-matnr,
          werks TYPE resb-werks,
          lgort TYPE resb-lgort,
          bdmng TYPE resb-bdmng,
          shkzg TYPE shkzg,
        END OF ty_resb.

TYPES : BEGIN OF ty_resb_f,
          matnr TYPE resb-matnr,
          werks TYPE resb-werks,
*          lgort TYPE resb-lgort,
          bdmng TYPE resb-bdmng,
        END OF ty_resb_f.

TYPES : BEGIN OF ty_resb_r,
          matnr    TYPE resb-matnr,
          werks    TYPE resb-werks,
          lgort    TYPE resb-lgort,
          resvd    TYPE bdmng,
          rct_rsvd TYPE bdmng,
        END OF ty_resb_r.

TYPES: BEGIN OF ty_mat_stock,
         matnr      TYPE mara-matnr,
         maktx      TYPE makt-maktx,
         bukrs      TYPE bukrs,    "company code
         bezei      TYPE t005u-bezei, "Region ( T005U - BEZEI )
         werks      TYPE t001w-werks,
         lgort      TYPE mseg-lgort,

         mtart      TYPE mara-mtart,
         extwg      TYPE mara-extwg,
         matkl      TYPE mara-matkl,
         meins      TYPE mara-meins,


         vrfmg      TYPE vrfmg,
         labst      TYPE mardh-labst, " unrestricted use
         klabs      TYPE mard-klabs, "added|10.03.2019
         resvd      TYPE bdmng,
         rct_rsvd   TYPE bdmng,
         open_po    TYPE mseg-menge,     " on Order stock/Open PO
*         klabs   TYPE mard-klabs, " consignment Order
         umlmc      TYPE marc-umlmc, " stock transfer


         safe_stk   TYPE eisbe,
         curr_mnt   TYPE fkimg,
         three_mnt  TYPE fkimg,
         twelve_mnt TYPE fkimg,

         mrp_qty    TYPE menge1,
         b_ord_qty  TYPE menge1,
         maabc      TYPE marc-maabc,

       END OF ty_mat_stock.
DATA: it_mat_stock  TYPE  TABLE OF ty_mat_stock.

DATA : lt_resb   TYPE STANDARD TABLE OF ty_resb,
       ls_resb   TYPE ty_resb,
       lt_resb_f TYPE HASHED TABLE OF ty_resb_f WITH UNIQUE KEY matnr werks,
       ls_resb_f TYPE ty_resb_f,
       lt_resb_r TYPE TABLE OF ty_resb_r.

FIELD-SYMBOLS:  <fs_resb_r> TYPE ty_resb_r.
DATA: it_eban_qty TYPE TABLE OF ty_eban_qty.
DATA: it_eban_prev TYPE TABLE OF ty_eban.
DATA: it_ekko TYPE TABLE OF ty_po_doct.
DATA: it_ebkn LIKE ebkn OCCURS 0.
DATA: gs_po   TYPE ty_po_details.
DATA: gv_cn_po_type TYPE esart.
DATA: gv_cn_reswk   TYPE reswk.
DATA: gv_cn_lifnr   TYPE wlief.
DATA: gv_stock_matnr TYPE matnr.
DATA: ebkn_sel.

DATA:gr_cc                 TYPE REF TO cl_gui_custom_container,
     gr_mmbe               TYPE REF TO cl_gui_custom_container,
     gr_splitter           TYPE REF TO cl_gui_splitter_container,
     gr_prl_cont           TYPE REF TO cl_gui_container,
     gr_stk_cont           TYPE REF TO cl_gui_container,
     gr_prl_grid           TYPE REF TO cl_gui_alv_grid,
     gr_stock_grid         TYPE REF TO cl_gui_alv_grid,
     gr_stk_grid           TYPE REF TO cl_gui_alv_grid,
     gr_alv_toolbarmanager TYPE REF TO cl_alv_grid_toolbar_manager,
     gr_tree               TYPE REF TO cl_salv_tree.
CLASS lcl_handle_events DEFINITION DEFERRED.
DATA: gr_events TYPE REF TO lcl_handle_events.


CONSTANTS: gc_true TYPE sap_bool VALUE 'X'.
DATA:ts_prl_layo     TYPE lvc_s_layo,
     it_fcat         TYPE lvc_t_fcat,
     it_fcat_l       TYPE lvc_t_fcat,
     it_fcat_l_c     TYPE lvc_t_fcat,
     it_prl_graphics TYPE dtc_t_tc,
     ts_prl_variant  TYPE disvariant,
     it_sort         TYPE lvc_t_sort,
     it_cell_tab     TYPE lvc_t_styl,
     it_log          TYPE TABLE OF zvss_errstk_st,
     it_alv_mod_cell TYPE lvc_t_modi,
     it_exclude      TYPE ui_functions,
     ts_stk_layout   TYPE lvc_s_layo,
     lv_first_time   TYPE boolean VALUE abap_false,
     it_row          TYPE lvc_t_roid,
     gv_edit         TYPE crmt_boolean,
     lv_fields       TYPE string
     VALUE 'MATNR,REGION,WERKS,BANFN,BNFPO,MENGE,AVAIL_STOCK,SALES_HIST_12,SALES_HIST_6,SALES_HIST_3,PIPE_LINE,RESERVES,PR_TYPE,STATU,LOEKZ,EPSTP,KNTTP,EBELN,TXZ01,PO_DOC,MEINS,LFDAT,RESWK,LGORT,EKGRP,LIFNR,BEDNR,RESWK,EKORG,INFNR,MATNR_EXT,EXTWG'."VRFMG
CONCATENATE lv_fields ',RESVD,RCT_RSVD,OPEN_PO,UMLMC,SAFE_STK,REORDER_POINT,MRP_QTY,MAABC' INTO lv_fields.

*--Begin of addition ismail for MRP  fields..
CONCATENATE lv_fields ',CENTRAL_STO,WESTERN_STO,EASTERN_STO,OPEN_SO,OSTO_TO_CR,OSTO_TO_WR,OSTO_TO_ER,OSTO_FRM_CR,OSTO_FRM_WR,OSTO_FRM_ER,LEAD_TIME,SERVICE_LEVEL,NO_SALES_DAYS,TOTAL_SALES, AVG_SALES,DAILY_AVG,AVAIL_FREE_STOCK,SAFETY_STOCK 'INTO lv_fields.
CONCATENATE lv_fields ',SALES_HIST_9,OPEN_PO_MRP,AVAIL_STOCK_MRP,REORDER_POINT_MRP,LT_DEMAND_QTY,OPEN_PR,EXPECTED_PR_QTY,PO_QTY,BALANCE_QTY,PR_CRTD_BY,PR_CRTD_NAME,PR_CRTD_DATE' INTO lv_fields.


*--End of addition ismail for MRP  fields..


CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive ,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      handle_changed_data FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,
      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_column_id e_row_id es_row_no,
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column es_row_no.
ENDCLASS.                    "lcl_event_handler DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*---------------------------------------------------------------------*
*       ALV event handler
*---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_toolbar.
    PERFORM handle_toolbar USING e_object.
  ENDMETHOD.                    "handle_toolbar_soc_ct

  METHOD handle_user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.
  METHOD handle_changed_data.
    PERFORM handle_changed_data USING er_data_changed.
  ENDMETHOD.
  METHOD handle_hotspot_click.
    PERFORM handle_hotspot_click USING e_column_id e_row_id es_row_no.
  ENDMETHOD.
  METHOD handle_double_click.
    PERFORM handle_double_click USING es_row_no.
  ENDMETHOD.
ENDCLASS.                    "lcl_alv_toolbar IMPLEMENTATION


CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,
      on_before_user_command FOR EVENT before_salv_function OF cl_salv_events
        IMPORTING e_salv_function,
      on_after_user_command FOR EVENT after_salv_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.

CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.

    PERFORM f_to_excel.

  ENDMETHOD.                    "on_user_command

  METHOD on_before_user_command.
    PERFORM show_function_info USING e_salv_function TEXT-i09.
  ENDMETHOD.                    "on_before_user_command

  METHOD on_after_user_command.
    PERFORM show_function_info USING e_salv_function TEXT-i10.
  ENDMETHOD.                    "on_after_user_command

ENDCLASS.

DATA:gr_alv_event TYPE REF TO lcl_event_handler.

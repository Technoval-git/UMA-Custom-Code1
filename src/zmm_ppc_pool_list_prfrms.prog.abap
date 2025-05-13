*&---------------------------------------------------------------------*
*& Include          ZMM_PPC_POOL_LIST_PRFRMS
*&---------------------------------------------------------------------*
FORM split_container.
  IF gr_cc IS NOT BOUND.
    CREATE OBJECT gr_cc
      EXPORTING
        container_name              = 'GC_CONTAINER'   " Name of the Screen CustCtrl Name to Link Container To
        lifetime                    = 1
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc = 0.
*    CREATE OBJECT gr_splitter
*      EXPORTING
*        parent            = gr_cc    " Parent Container
*        rows              = 2    " Number of Rows to be displayed
*        columns           = 1    " Number of Columns to be Displayed
*      EXCEPTIONS
*        cntl_error        = 1
*        cntl_system_error = 2
*        OTHERS            = 3.
*    IF sy-subrc = 0.
*      PERFORM f_adjust_height USING 100.
      PERFORM f_display_prl.
*      PERFORM f_display_stk_log.
*      PERFORM f_set_selected_row.
*    ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : CALL_SCREEN                                *
*
*&**********************************************************************
*& Form Definition    : Call the module pool screen (DE1K905556)       *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM call_screen .
  CALL SCREEN 1001.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_DISPLAY_PRL                                *
*
*&**********************************************************************
*& Form Definition    : Display pool list ALV grid (DE1K905556)        *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_display_prl.

  IF gr_prl_grid IS NOT BOUND.
*    gr_splitter->get_container(
*            EXPORTING
*              row       = 1    " Row
*              column    = 1    " Column
*            RECEIVING
*              container = gr_prl_cont ).
    IF gr_cc IS BOUND.
      CREATE OBJECT gr_prl_grid
        EXPORTING
          i_appl_events     = 'X'
          i_parent          = gr_cc   " Parent Container
        EXCEPTIONS
          error_cntl_create = 1
          error_cntl_init   = 2
          error_cntl_link   = 3
          error_dp_create   = 4
          OTHERS            = 5.
      IF sy-subrc = 0.
        PERFORM f_get_prl_data.
        PERFORM f_prepare_prl_layout.
        PERFORM f_prepare_prl_variant.
        PERFORM f_prepare_prl_graphics.
        PERFORM f_prepare_fcat USING 'EBAN'
                            CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'PO_DOC'
                                       '2'
                                       'EKKO'
                                       'PO Doc. Type'
                                       'BSART'
                                       abap_true
                              CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'PR_TYPE'
                                       '1'
                                       ''
                                       'PR Doc. Type'
                                       ''
                                       abap_false
                              CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'REGION'
                                       'IT_EBAN'
                                       ''
                                       'Region'
                                       ''
                                       abap_false
                              CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'AVAIL_STOCK'
                                       'IT_EBAN'
                                       ''
                                       'Avl. Stock'
                                       ''
                                       abap_false
                              CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'SALES_HIST_12'
                                       'IT_EBAN'
                                       ''
                                       'SH 12 Mons'
                                       ''
                                       abap_false
                              CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'SALES_HIST_6'
                                        'IT_EBAN'
                                        ''
                                        'SH 6 Mons'
                                        ''
                                        abap_false
                               CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'SALES_HIST_3'
                                       'IT_EBAN'
                                       ''
                                       'SH 3 mons'
                                       ''
                                       abap_false
                              CHANGING it_fcat.
*        PERFORM f_add_field_fcat USING 'PIPE_LINE'
*                                      'IT_EBAIN'
*                                      ''
*                                      'Open PO Qty'
*                                      ''
*                                      abap_false
*                             CHANGING it_fcat.
*        PERFORM f_add_field_fcat USING 'RESERVES'
*                                        'IT_EBAIN'
*                                        ''
*                                        'Open Order Qty'
*                                        ''
*                                        abap_false
*                               CHANGING it_fcat.
*        PERFORM f_add_field_fcat USING 'RESERVES'
*                                       'IT_EBAIN'
*                                       ''
*                                       'Open Rsv. Qty'
*                                       ''
*                                       abap_false
*                              CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'EXTWG'
                'IT_EBAN'
                ''
                'Ext Material'
                ''
                abap_false
                CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'VRFMG'
              'IT_EBAN'
              ''
              'Avail. Qty'
              ''
              abap_false
              CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'RESVD'
              'IT_EBAN'
              ''
              'Open SO'
              ''
              abap_false
              CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'RCT_RSVD'
              'IT_EBAN'
              ''
              'Open RO'
              ''
              abap_false
              CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'UMLMC'
                 'IT_EBAN'
                 ''
                 'Stock Transfer'
                 ''
                 abap_false
                 CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'OPEN_PO'
               'IT_EBAN'
               ''
               'Open PO Qty'
               ''
               abap_false
               CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'SAFE_STK'
                 'IT_EBAN'
                 ''
                 'Safety Stock'
                 ''
                 abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'REORDER_POINT'
                 'IT_EBAN'
                 ''
                 'Reorder Point'
                 ''
                 abap_false
        CHANGING it_fcat.

*        PERFORM f_add_field_fcat USING 'CURR_MNT'
*                 'IT_EBAN'
*                 ''
*                 'Sold(cur)'
*                 ''
*                 abap_false
*                 CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'MRP_QTY'
                 'IT_EBAN'
                 ''
                 'MRP Qty'
                 ''
                 abap_false
        CHANGING it_fcat.
*        PERFORM f_add_field_fcat USING 'B_ORD_QTY'
*                'IT_EBAIN'
*                ''
*                'CBO'
*                ''
*                abap_false
*                CHANGING it_fcat.
        PERFORM f_add_field_fcat USING 'MAABC'
                  'IT_EBAN'
                  ''
                  'ABC ind.'
                  ''
                  abap_false
         CHANGING it_fcat.
*--Begin of  changes ismail fields from MRP
*CONCATENATE lv_fields ',CENTRAL_STO,WESTERN_STO,EASTERN_STO,OPEN_SO,OSTO_TO_CR,OSTO_TO_WR,OSTO_TO_ER,OSTO_FRM_CR,OSTO_FRM_WR,OSTO_FRM_ER,LEAD_TIME,SERVICE_LEVEL,NO_SALES_DAYS,TOTAL_SALES, AVG_SALES,DAILY_AVG,AVAIL_FREE_STOCK,SAFETY_STOCK 'INTO lv_fields.
*CONCATENATE lv_fields ',SALES_HIST_9,LT_DEMAND_QTY,OPEN_PR,EXPECTED_PR_QTY' INTO lv_fields.
        PERFORM f_add_field_fcat USING 'CENTRAL_STO'
                  'IT_EBAN'
                  ''
                  'STO To Central Region'
                  ''
                  abap_false
         CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'WESTERN_STO'
                    'IT_EBAN'
                    ''
                    'STO To Western Region'
                    ''
                    abap_false
           CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'EASTERN_STO'
               'IT_EBAN'
               ''
               'STO To Eastern Region'
               ''
               abap_false
      CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'OPEN_SO'
           'IT_EBAN'
           ''
           'Open Sales Orders'
           ''
           abap_false
         CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'OSTO_TO_CR'
        'IT_EBAN'
        ''
        'Open STO To CR'
        ''
        abap_false
       CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'OSTO_TO_WR'
          'IT_EBAN'
          ''
          'Open STO to WR'
          ''
          abap_false
          CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'OSTO_TO_ER'
         'IT_EBAN'
         ''
        'Open STO to ER'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'OSTO_FRM_CR'
       'IT_EBAN'
        ''
        'Open STO From CR'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'OSTO_FRM_WR'
        'IT_EBAN'
        ''
        'Open STO From WR'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'OSTO_FRM_ER'
        'IT_EBAN'
        ''
        'Open STO From ER'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'LEAD_TIME'
       'IT_EBAN'
       ''
       'Lead time'
       ''
       abap_false
       CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'SERVICE_LEVEL'
       'IT_EBAN'
       ''
       'MRP service level'
       ''
       abap_false
       CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'NO_SALES_DAYS'
        'IT_EBAN'
        ''
        'No of Sales days'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'TOTAL_SALES'
        'IT_EBAN'
        ''
        'Total Sales'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'AVG_SALES'
        'IT_EBAN'
        ''
        'Avg. Sales'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'DAILY_AVG'
        'IT_EBAN'
        ''
        'Daily Avg. Sales'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'SALES_HIST_9'
        'IT_EBAN'
        ''
        '9 Mon Sales History'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'OPEN_PO_MRP'
        'IT_EBAN'
        ''
        'Open PO MRP'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'AVAIL_STOCK_MRP'
        'IT_EBAN'
        ''
        'Available Stock MRP'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'REORDER_POINT_MRP'
       'IT_EBAN'
       ''
       'Reorder Point MRP'
       ''
       abap_false
       CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'AVAIL_FREE_STOCK'
        'IT_EBAN'
        ''
        'Available Free Stock'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'SAFETY_STOCK'
        'IT_EBAN'
        ''
        'Safety stock'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'LT_DEMAND_QTY'
        'IT_EBAN'
        ''
        'LT Demand Qty'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'OPEN_PR'
        'IT_EBAN'
        ''
        'Open PR'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'EXPECTED_PR_QTY'
        'IT_EBAN'
        ''
        'Expected PR Qty'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'PO_QTY'
        'IT_EBAN'
        ''
        'PO Qty'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'BALANCE_QTY'
        'IT_EBAN'
        ''
        'Balance Qty'
        ''
        abap_false
        CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'PR_CRTD_BY'
          'IT_EBAN'
          ''
          'PR Created by'
          ''
          abap_false
          CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'PR_CRTD_NAME'
          'IT_EBAN'
          ''
          'PR Created by (name)'
          ''
          abap_false
          CHANGING it_fcat.

        PERFORM f_add_field_fcat USING 'PR_CRTD_DATE'
          'IT_EBAN'
          ''
          'PR Created Date'
          ''
          abap_false
          CHANGING it_fcat.
*--------modifying current data based on pR number
*lt_mrp_stg TYPE STANDARD TABLE OF ydbm_mat_mrp_stg
*        CLEAR: lt_mrp_stg,lw_mrp_stg.
*        IF it_eban IS NOT INITIAL.
*          SELECT * FROM ydbm_mat_mrp_stg INTO TABLE lt_mrp_stg FOR ALL ENTRIES IN it_eban WHERE banfn = it_eban-banfn.
*          IF sy-subrc EQ 0 AND lt_mrp_stg IS NOT INITIAL.
*            SORT lt_mrp_stg BY banfn.
*            LOOP AT it_eban ASSIGNING <fs_eban1> .
*              CLEAR: lw_mrp_stg.
*              READ TABLE lt_mrp_stg INTO lw_mrp_stg WITH KEY banfn = <fs_eban1>-banfn.
*              IF sy-subrc EQ 0.
*                <fs_eban1>-sales_hist_9 =     lw_mrp_stg-sold_9.
*                <fs_eban1>-central_sto      = lw_mrp_stg-central_sto.
*                <fs_eban1>-western_sto      = lw_mrp_stg-western_sto.
*                <fs_eban1>-eastern_sto      = lw_mrp_stg-eastern_sto.
*                <fs_eban1>-open_so          = lw_mrp_stg-open_so.
*                <fs_eban1>-osto_to_cr       = lw_mrp_stg-osto_to_cr.
*                <fs_eban1>-osto_to_wr       = lw_mrp_stg-osto_to_wr.
*                <fs_eban1>-osto_to_er       = lw_mrp_stg-osto_to_er.
*                <fs_eban1>-open_po_mrp      = lw_mrp_stg-open_po.
*                <fs_eban1>-osto_frm_cr      = lw_mrp_stg-osto_frm_cr.
*                <fs_eban1>-osto_frm_wr      = lw_mrp_stg-osto_frm_wr.
*                <fs_eban1>-osto_frm_er      = lw_mrp_stg-osto_frm_wr.
*                <fs_eban1>-avail_stock_mrp  = lw_mrp_stg-avail_stock.
*                <fs_eban1>-lead_time        = lw_mrp_stg-lead_time.
*                <fs_eban1>-service_level    = lw_mrp_stg-service_level.
*                <fs_eban1>-no_sales_days    = lw_mrp_stg-no_sales_days.
*                <fs_eban1>-total_sales      = lw_mrp_stg-total_sales.
*                <fs_eban1>-avg_sales        = lw_mrp_stg-avg_sales.
*                <fs_eban1>-daily_avg        = lw_mrp_stg-daily_avg.
*                <fs_eban1>-avail_free_stock = lw_mrp_stg-avail_free_stock.
*                <fs_eban1>-safety_stock     = lw_mrp_stg-safety_stock .
*                <fs_eban1>-lt_demand_qty    = lw_mrp_stg-lt_demand_qty.
*                <fs_eban1>-reorder_point_mrp = lw_mrp_stg-reorder_point.
*                <fs_eban1>-open_pr         = lw_mrp_stg-open_pr.
*                <fs_eban1>-expected_pr_qty  = lw_mrp_stg-expected_pr_qty.
*
*              ENDIF.
*            ENDLOOP.
*
*          ENDIF.
*        ENDIF.

*--End of  changes ismail fields from MRP

        PERFORM f_rearrange_fields USING lv_fields CHANGING it_fcat.
        PERFORM f_prepare_sort CHANGING it_sort.
        PERFORM f_required_fields_pr USING lv_fields.
*        PERFORM f_set_field_edit.
        PERFORM f_field_editable.
*      PERFORM f_prepare_sort_table.
        PERFORM f_register_event.
*        PERFORM f_disable_alv_toolbar.

        it_eban_prev = it_eban.
        ts_prl_variant-report = sy-repid.
*        BREAK-POINT.
        gr_prl_grid->set_table_for_first_display(
          EXPORTING
            is_variant                    = ts_prl_variant    " Layout
            i_save                        = 'A'    " Save Layout
            is_layout                     = ts_prl_layo    " Layout
            it_toolbar_excluding          = it_exclude    " Excluded Toolbar Standard Functions
            it_alv_graphics               = it_prl_graphics    " Table of Structure DTC_S_TC,^,
          CHANGING
            it_outtab                     = it_eban    " Output Table
            it_fieldcatalog               = it_fcat    " Field Catalog
            it_sort                       = it_sort    " Sort Criteria
          EXCEPTIONS
            invalid_parameter_combination = 1
            program_error                 = 2
            too_many_lines                = 3
            OTHERS                        = 4 ).
        IF sy-subrc <> 0.
*         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
*  ELSE.
*    gr_prl_grid->refresh_table_display( ).
  ENDIF.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_DISPLAY_STK_LOG                              *
*
*&**********************************************************************
*& Form Definition    : Initiate the Log/Stock ALV grid (DE1K905556)   *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
*FORM f_display_stk_log.
*  FIELD-SYMBOLS: <fs_stk_fcat>   LIKE LINE OF  it_fcat_l.
*  DATA: lv_name TYPE lvc_title VALUE 'Stock Details/Messages Log'.
*  IF gr_stk_grid IS NOT BOUND.
*    ts_stk_layout-no_toolbar = abap_true.
*    ts_stk_layout-grid_title = lv_name.
*    ts_stk_layout-no_f4 = abap_true.
**    ts_stk_layout-excp_fname = 'LIGHTS'.
**    PERFORM f_adjust_height USING 100.
*    gr_splitter->get_container(
*           EXPORTING
*             row       = 2    " Row
*             column    = 1    " Column
*           RECEIVING
*             container = gr_stk_cont    " Container
*         ).
*    IF gr_stk_cont IS BOUND.
*      CREATE OBJECT gr_stk_grid
*        EXPORTING
**         i_appl_events     = 'X'
*          i_parent          = gr_stk_cont   " Parent Container
*        EXCEPTIONS
*          error_cntl_create = 1
*          error_cntl_init   = 2
*          error_cntl_link   = 3
*          error_dp_create   = 4
*          OTHERS            = 5.
*      IF sy-subrc = 0.
*        gr_stk_grid->set_gridtitle( i_gridtitle = lv_name ).
*        PERFORM f_prepare_fcat USING 'YDBM_JET_ERRSTK_ST' CHANGING it_fcat_l.
*        it_fcat_l_c = it_fcat_l.
*        LOOP AT it_fcat_l ASSIGNING <fs_stk_fcat> WHERE fieldname <> 'G_TYPE'.
*          <fs_stk_fcat>-no_out = abap_true.
*        ENDLOOP.
*        gr_stk_grid->set_table_for_first_display(
*          EXPORTING
**          i_buffer_active               =     " Buffering Active
**          i_bypassing_buffer            =     " Switch Off Buffer
**          i_consistency_check           =     " Starting Consistency Check for Interface Error Recognition
**          i_structure_name              = 'EBAN'    " Internal Output Table Structure Name
**          is_variant                    = ts_prl_variant    " Layout
**          i_save                        = 'A'    " Save Layout
**          i_default                     = 'X'    " Default Display Variant
*            is_layout                     = ts_stk_layout    " Layout
**          is_print                      =     " Print Control
**          it_special_groups             =     " Field Groups
**          it_toolbar_excluding          =     " Excluded Toolbar Standard Functions
**          it_hyperlink                  =     " Hyperlinks
**          it_alv_graphics               = it_prl_graphics    " Table of Structure DTC_S_TC
**          it_except_qinfo               =     " Table for Exception Quickinfo
**          ir_salv_adapter               =     " Interface ALV Adapter
*          CHANGING
*            it_outtab                     = it_log    " Output Table
*            it_fieldcatalog               = it_fcat_l    " Field Catalog
**          it_sort                       = it_sort    " Sort Criteria
**          it_filter                     =     " Filter Criteria
*          EXCEPTIONS
*            invalid_parameter_combination = 1
*            program_error                 = 2
*            too_many_lines                = 3
*            OTHERS                        = 4 ).
*        IF sy-subrc <> 0.
**       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ELSE.
*    gr_stk_grid->refresh_table_display( ).
*  ENDIF.
*ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_GET_PRL_DATA                              *
*
*&**********************************************************************
*& Form Definition    : Get data for pool list (DE1K905556)            *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_get_prl_data .

  TYPES: BEGIN OF ty_plant_region,
           plant  TYPE werks,
           region TYPE bezei20,
         END OF ty_plant_region.
  TYPES: BEGIN OF ty_avail_stock,
           matnr TYPE matnr,
           plant TYPE werks,
           lbkum TYPE lbkum,
         END OF ty_avail_stock.
  TYPES: BEGIN OF ty_hist_data,
           fkimg TYPE fkimg,
           matnr TYPE matnr,
           werks TYPE werks,
           fkdat TYPE fkdat,
         END OF ty_hist_data.
  TYPES: BEGIN OF ty_open_resv,
           matnr TYPE matnr,
           werks TYPE ewerk,
           bdmng TYPE bdmng,
         END OF ty_open_resv.
  TYPES: BEGIN OF ty_open_po,
           matnr TYPE matnr,
           werks TYPE ewerk,
           menge TYPE bstmg,
         END OF ty_open_po.
  TYPES: BEGIN OF ty_materialid,
           matnr_int TYPE matnr_int,
           matnr_ext TYPE matnr_ext,
         END OF ty_materialid.

  DATA ts_eban_c  TYPE eban.
  DATA ts_eban    LIKE LINE OF it_eban.
  DATA ts_ekko    LIKE LINE OF it_ekko.
  DATA lt_po_temp TYPE TABLE OF eban.
  DATA: lt_plant_region  TYPE TABLE OF ty_plant_region,
        ls_plant_region  TYPE ty_plant_region,
        lt_avail_stock   TYPE TABLE OF ty_avail_stock,
        ls_avail_stock   TYPE ty_avail_stock,
        lt_3mons_hist    TYPE zcl_parts_util=>tt_sales_hist_mseg,
        lt_6mons_hist    TYPE zcl_parts_util=>tt_sales_hist_mseg,
        lt_12mons_hist   TYPE zcl_parts_util=>tt_sales_hist_mseg,
        ls_hist_data     TYPE zcl_parts_util=>ty_sales_hist_mseg,
*        lt_open_resv       TYPE TABLE OF ty_open_resv,
*        lt_open_resv_final TYPE TABLE OF ty_open_resv,
        ls_open_resv     TYPE ty_open_resv,
        lt_open_po       TYPE TABLE OF ty_open_po,
        lt_open_po_final TYPE TABLE OF ty_open_po,
        ls_open_po       TYPE ty_open_po,
        lt_materialid    TYPE TABLE OF ty_materialid,
        ls_materialid    TYPE ty_materialid,
        lt_matnr         TYPE TABLE OF matnr.

  FIELD-SYMBOLS: <fs_open_po>   TYPE ty_open_po,
                 <fs_open_resv> TYPE ty_open_resv,
                 <fs_table>     TYPE ANY TABLE,
                 <fs_eban>      TYPE ty_eban,
                 <fs_hist>      TYPE ty_hist_data.

  CALL FUNCTION 'ZVSS_JET_GET_PR_LIST'
    EXPORTING
      it_banfn  = s_banfn[]
      it_ekgrp  = s_ekgrp[]
      it_matnr  = s_matnr[]
      it_maktl  = s_matkl[]
      it_bednr  = s_bednr[]
      it_werks  = s_werks[]
      it_bsart  = s_bsart[]
      it_lfdat  = s_lfdat[]
      it_frgdt  = s_frgdt[]
      it_dispo  = s_dispo[]
      it_statu  = s_statu[]
      it_flief  = s_flief[]
      it_banpr  = s_banpr[]
      it_blckd  = s_blckd[]
      iv_afnam  = p_afnam
      iv_txz01  = p_txz01
      iv_zugba  = p_zugba
      iv_memory = p_memory
      iv_erlba  = p_erlba
      iv_bstba  = p_bstba
      iv_freig  = p_freig
      iv_selgs  = p_selgs
      iv_selpo  = p_selpo
      it_region = s_region[]
    IMPORTING
      et_eban   = it_eban_c.
  IF it_eban_c IS NOT INITIAL.
    SELECT ebeln bsart FROM ekko INTO TABLE it_ekko FOR ALL ENTRIES IN it_eban_c
      WHERE ebeln = it_eban_c-ebeln ORDER BY PRIMARY KEY.

    SELECT menge, banfn, bnfpo FROM ekpo
      INTO TABLE @DATA(lt_po_qty)
      FOR ALL ENTRIES IN @it_eban_c
      WHERE banfn = @it_eban_c-banfn.
  ENDIF.

  lt_po_temp = it_eban_c.
  SORT lt_po_temp BY werks.
  DELETE ADJACENT DUPLICATES FROM lt_po_temp COMPARING werks.
  DELETE lt_po_temp WHERE werks IS INITIAL.
  IF lt_po_temp IS NOT INITIAL.
    SELECT p~werks t~bezei FROM t001w AS p
      INNER JOIN t005u AS t
      ON p~land1 = t~land1
      AND p~regio = t~bland
      INTO TABLE lt_plant_region
      FOR ALL ENTRIES IN lt_po_temp
      WHERE p~werks = lt_po_temp-werks
        AND t~spras = sy-langu.
  ENDIF.

  lt_po_temp = it_eban_c.
  SORT lt_po_temp BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_po_temp COMPARING matnr.
  DELETE lt_po_temp WHERE matnr IS INITIAL.
  IF lt_po_temp IS NOT INITIAL.
    SELECT matnr bwkey lbkum FROM mbew
      INTO TABLE lt_avail_stock
      FOR ALL ENTRIES IN lt_po_temp
      WHERE matnr = lt_po_temp-matnr.

*    SELECT i~fkimg i~matnr i~werks h~fkdat FROM vbrp AS i
*      INNER JOIN vbrk AS h ON i~vbeln = h~vbeln
*      INTO TABLE lt_hist_data
*      FOR ALL ENTRIES IN lt_po_temp
*      WHERE i~matnr = lt_po_temp-matnr
*        AND h~vbtyp = 'M'
*        AND h~fksto = ''
*        AND h~fkdat GE lv_12mons_back
*        AND h~fkdat LT lv_lastmonth_end.
    LOOP AT lt_po_temp INTO DATA(ls_po_temp).
      APPEND ls_po_temp-matnr TO lt_matnr.
    ENDLOOP.
    CALL METHOD zcl_parts_util=>get_sales_hist_mseg
      EXPORTING
        it_material = lt_matnr
      IMPORTING
        et_sales_3  = lt_3mons_hist
        et_sales_6  = lt_6mons_hist
        et_sales_12 = lt_12mons_hist.

*    SELECT mseg~erfmg mseg~matnr mseg~werks mkpf~budat
*      FROM mkpf INNER JOIN mseg
*        ON mkpf~mandt = mseg~mandt
*       AND mkpf~mblnr = mseg~mblnr
*       AND mkpf~mjahr = mseg~mjahr
*      INTO TABLE lt_hist_data
*      FOR ALL ENTRIES IN lt_po_temp
*      WHERE mkpf~budat GE lv_12mons_back
*        AND mkpf~budat LT lv_lastmonth_end
*        AND mseg~bwart IN ( '261' , '262' , 'Z61' , 'Z62' )
*        AND mseg~matnr = lt_po_temp-matnr.
*    IF sy-subrc = 0.
*      LOOP AT lt_hist_data INTO ls_hist_data.
*        READ TABLE lt_12mons_hist ASSIGNING <fs_hist>
*          WITH KEY matnr = ls_hist_data-matnr
*                   werks = ls_hist_data-werks.
*        IF sy-subrc = 0.
*          <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
*        ELSE.
*          APPEND ls_hist_data TO lt_12mons_hist.
*        ENDIF.
*
*        IF ls_hist_data-fkdat GE lv_6mons_back.
*          READ TABLE lt_6mons_hist ASSIGNING <fs_hist>
*            WITH KEY matnr = ls_hist_data-matnr
*                     werks = ls_hist_data-werks.
*          IF sy-subrc = 0.
*            <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
*          ELSE.
*            APPEND ls_hist_data TO lt_6mons_hist.
*          ENDIF.
*        ENDIF.
*
*        IF ls_hist_data-fkdat GE lv_3mons_back.
*          READ TABLE lt_3mons_hist ASSIGNING <fs_hist>
*            WITH KEY matnr = ls_hist_data-matnr
*                     werks = ls_hist_data-werks.
*          IF sy-subrc = 0.
*            <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
*          ELSE.
*            APPEND ls_hist_data TO lt_3mons_hist.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.

*    SELECT matnr werks menge FROM ekpo
*      INTO TABLE lt_open_po
*      FOR ALL ENTRIES IN lt_po_temp
*      WHERE matnr = lt_po_temp-matnr
*        AND elikz = ''.
*    IF sy-subrc = 0.
*      LOOP AT lt_open_po INTO ls_open_po.
*        READ TABLE lt_open_po_final ASSIGNING <fs_open_po>
*          WITH KEY matnr = ls_open_po-matnr
*                   werks = ls_open_po-werks.
*        IF sy-subrc = 0.
*          <fs_open_po>-menge = <fs_open_po>-menge + ls_open_po-menge.
*        ELSE.
*          APPEND ls_open_po TO lt_open_po_final.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.

*    SELECT matnr werks bdmng FROM resb
*      INTO TABLE lt_open_resv
*      FOR ALL ENTRIES IN lt_po_temp
*      WHERE matnr = lt_po_temp-matnr
*        AND kzear = ''.
*    IF sy-subrc = 0.
*      LOOP AT lt_open_resv INTO ls_open_resv.
*        READ TABLE lt_open_resv_final ASSIGNING <fs_open_resv>
*          WITH KEY matnr = ls_open_resv-matnr
*                   werks = ls_open_resv-werks.
*        IF sy-subrc = 0.
*          <fs_open_resv>-bdmng = <fs_open_resv>-bdmng + ls_open_resv-bdmng.
*        ELSE.
*          APPEND ls_open_resv TO lt_open_resv_final.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.

    SELECT matnr_int matnr_ext FROM materialid
      INTO TABLE lt_materialid
      FOR ALL ENTRIES IN lt_po_temp
      WHERE matnr_int = lt_po_temp-matnr.

  ENDIF.

  DATA : ts_pre_out TYPE ty_output.
  PERFORM f_mmbe_data.
  LOOP AT it_eban_c INTO ts_eban_c.
    CLEAR ts_eban.
    MOVE-CORRESPONDING ts_eban_c TO ts_eban.
    ts_eban-pr_crtd_by = ts_eban_c-ernam.
    ts_eban-pr_crtd_date = ts_eban_c-erdat.
    IF ts_eban-pr_crtd_by IS NOT INITIAL.
      CALL FUNCTION 'HR_GETEMPLOYEEDATA_FROMUSER'
        EXPORTING
          username                  = ts_eban-pr_crtd_by
        IMPORTING
          name                      = ts_eban-pr_crtd_name
        EXCEPTIONS
          user_not_found            = 1
          countrygrouping_not_found = 2
          infty_not_found           = 3
          OTHERS                    = 4.
    ENDIF.
    ts_eban-pr_type = ts_eban_c-bsart.
    CLEAR ts_ekko.
    READ TABLE it_ekko INTO ts_ekko
      WITH KEY ebeln = ts_eban-ebeln BINARY SEARCH.
    IF sy-subrc = 0.
      ts_eban-po_doc = ts_ekko-bsart.
    ENDIF.
    CALL FUNCTION 'CONVERSION_EXIT_MATN2_OUTPUT'
      EXPORTING
        input  = ts_eban_c-matnr
      IMPORTING
        output = ts_eban_c-matnr.
    READ TABLE it_pre_out
    INTO ts_pre_out
    WITH KEY matnr = ts_eban_c-matnr
      werks = ts_eban_c-werks.
*    lgort = ts_eban_c-lgort.
    IF sy-subrc = 0.
      ts_eban-extwg   =    ts_pre_out-extwg.
      ts_eban-vrfmg    = ts_pre_out-vrfmg .
      ts_eban-resvd      = ts_pre_out-resvd.
      ts_eban-rct_rsvd   = ts_pre_out-rct_rsvd .
      ts_eban-open_po    = ts_pre_out-open_po.
      ts_eban-umlmc      = ts_pre_out-umlmc.
      ts_eban-safe_stk  = ts_pre_out-safe_stk.
      ts_eban-reorder_point  = ts_pre_out-reorder_point.
      ts_eban-curr_mnt   = ts_pre_out-curr_mnt.
      ts_eban-mrp_qty   = ts_pre_out-mrp_qty.
      ts_eban-b_ord_qty  = ts_pre_out-b_ord_qty.
      ts_eban-maabc      = ts_pre_out-maabc.
    ENDIF.

    READ TABLE lt_plant_region INTO ls_plant_region
      WITH KEY plant = ts_eban-werks.
    IF sy-subrc = 0.
      ts_eban-region = ls_plant_region-region.
    ENDIF.

    READ TABLE lt_avail_stock INTO ls_avail_stock
      WITH KEY matnr = ts_eban-matnr plant = ts_eban-werks.
    IF sy-subrc = 0.
      ts_eban-avail_stock = ls_avail_stock-lbkum.
    ENDIF.

    CLEAR: ls_hist_data.
    READ TABLE lt_12mons_hist INTO ls_hist_data
      WITH KEY matnr = ts_eban-matnr
               werks = ts_eban-werks.
    IF sy-subrc = 0.
      ts_eban-sales_hist_12 = ls_hist_data-fkimg.
    ENDIF.

    CLEAR: ls_hist_data.
    READ TABLE lt_6mons_hist INTO ls_hist_data
      WITH KEY matnr = ts_eban-matnr
               werks = ts_eban-werks.
    IF sy-subrc = 0.
      ts_eban-sales_hist_6 = ls_hist_data-fkimg.
    ENDIF.

    CLEAR: ls_hist_data.
    READ TABLE lt_3mons_hist INTO ls_hist_data
      WITH KEY matnr = ts_eban-matnr
               werks = ts_eban-werks.
    IF sy-subrc = 0.
      ts_eban-sales_hist_3 = ls_hist_data-fkimg.
    ENDIF.

*    READ TABLE lt_open_po_final INTO ls_open_po
*      WITH KEY matnr = ts_eban-matnr
*               werks = ts_eban-werks.
*    IF sy-subrc = 0.
*      ts_eban-pipe_line = ls_open_po-menge.
*    ENDIF.

*    READ TABLE lt_open_resv_final INTO ls_open_resv
*      WITH KEY matnr = ts_eban-matnr
*               werks = ts_eban-werks.
*    IF sy-subrc = 0.
*      ts_eban-reserves = ls_open_resv-bdmng.
*    ENDIF.

    READ TABLE lt_materialid INTO ls_materialid
      WITH KEY matnr_int = ts_eban-matnr.
    IF sy-subrc = 0.
      ts_eban-matnr_ext = ls_materialid-matnr_ext.
    ENDIF.

    LOOP AT lt_po_qty INTO DATA(ls_po_qty)
      WHERE banfn = ts_eban_c-banfn AND bnfpo = ts_eban_c-bnfpo.
      ts_eban-po_qty = ts_eban-po_qty + ls_po_qty-menge.
    ENDLOOP.
    ts_eban-balance_qty = ts_eban-menge - ts_eban-po_qty.
    APPEND ts_eban TO it_eban.
  ENDLOOP.
  SORT it_eban BY matnr_ext region werks.

ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_PREPARE_PRL_LAYOUT                           *
*
*&**********************************************************************
*& Form Definition    : Prepare ALV grid Layout (DE1K905556)           *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_prepare_prl_layout .
  DATA: lv_name TYPE lvc_title VALUE 'Purchase Requisitions'.
  ts_prl_layo-zebra = abap_true.
  ts_prl_layo-no_rowmove = abap_true.
*  ts_prl_layo-no_f4 = abap_true.
  ts_prl_layo-sel_mode = 'D'.
  ts_prl_layo-stylefname = 'IT_CELL_TAB'.
  ts_prl_layo-grid_title = lv_name.
*  ts_prl_layo-edit = abap_true.
*  ts_prl_layo-no_toolbar = abap_true.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_PREPARE_VARIANT                              *
*
*&**********************************************************************
*& Form Definition    : Prepare pool list ALV grid Variant (DE1K905556)*
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_prepare_prl_variant .
  ts_prl_variant-report = sy-repid.
  ts_prl_variant-handle = '0001'.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_PREPARE_PRL_GRAPHICS                         *
*
*&**********************************************************************
*& Form Definition    : Prepare pool list ALV graphics (DE1K905556)    *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_prepare_prl_graphics .
  DATA ts_graphics  TYPE dtc_s_tc.
  ts_graphics-prop_id = 'FULLSCREEN_MODE'.
  ts_graphics-prop_val = abap_true.
  APPEND ts_graphics TO it_prl_graphics.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_PREPARE_FCAT                                 *
*
*&**********************************************************************
*& Form Definition    : Prepare field catalog for ALV grid (DE1K905556)*
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_prepare_fcat  USING    p_name TYPE tabname
                     CHANGING p_it_fcat TYPE lvc_t_fcat.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE        =
      i_structure_name       = p_name
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_BYPASSING_BUFFER     =
*     I_INTERNAL_TABNAME     =
    CHANGING
      ct_fieldcat            = p_it_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_ADJUST_HEIGHT                                *
*
*&**********************************************************************
*& Form Definition    : Adjust height for split container (DE1K905556) *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_adjust_height USING p_height TYPE i.
  IF gr_splitter IS BOUND.
    gr_splitter->set_row_mode(
      EXPORTING
        mode              = gr_splitter->mode_absolute     " Row Mode
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
    ).
    IF sy-subrc = 0.
      gr_splitter->set_row_height(
        EXPORTING
          id                = 2     " Row ID
          height            = p_height" 80    " Height
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3
      ).
      IF sy-subrc = 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_PREPARE_SORT_TABLE                           *
*
*&**********************************************************************
*& Form Definition    : Prepare a table for default sorting (DE1K905556)*
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_prepare_sort_table .
*  DATA ts_sort  TYPE lvc_s_sort.
*  ts_sort-fieldname = 'BANFN'.
*  ts_sort-expa = 'X'.
*  ts_sort-up = 'X'.
*  APPEND ts_sort TO it_sort.

*  ts_sort-fieldname = 'BNFPO'.
*  ts_sort-expa = 'X'.
*  ts_sort-up = 'X'.
*  APPEND ts_sort TO it_sort.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_FIELD_EDITABLE                               *
*
*&**********************************************************************
*& Form Definition    : ALV field edit using style (DE1K905556)        *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_field_editable.
  DATA ts_style  TYPE lvc_s_styl.
  DATA it_style  TYPE lvc_t_styl.
  DATA ts_eban   LIKE LINE OF it_eban.
*  data
*  CLEAR ts_style.
*  ts_style-fieldname = 'MATNR'.
*  ts_style-style = cl_gui_alv_grid=>mc_style_disabled.
**  ts_style-style2 = cl_gui_alv_grid=>mc_fc_sort_asc.
*  INSERT ts_style INTO TABLE it_style.
*  CLEAR ts_style.
*  ts_style-fieldname = 'REGION'.
*  ts_style-style = cl_gui_alv_grid=>mc_style_disabled.
**  ts_style-style2 = cl_gui_alv_grid=>mc_fc_sort_asc.
*  INSERT ts_style INTO TABLE it_style.
*  CLEAR ts_style.
*  ts_style-fieldname = 'WERKS'.
*  ts_style-style = cl_gui_alv_grid=>mc_style_disabled.
**  ts_style-style2 = cl_gui_alv_grid=>mc_fc_sort_asc.
*  INSERT ts_style INTO TABLE it_style.

  CLEAR ts_style.
  ts_style-fieldname = 'MENGE'.
  ts_style-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ts_style INTO TABLE it_style.

*  CLEAR ts_style.
*  ts_style-fieldname = 'FLIEF'.
*  ts_style-style = cl_gui_alv_grid=>mc_style_enabled.
*  INSERT ts_style INTO TABLE it_style.
  ts_eban-it_cell_tab = it_style.
  MODIFY it_eban FROM ts_eban TRANSPORTING it_cell_tab WHERE it_cell_tab IS INITIAL.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : HANDLE_TOOLBAR_SOC_CT                          *
*
*&**********************************************************************
*& Form Definition    : Add custom butttons in ALV (DE1K905556)        *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM handle_toolbar  USING    p_e_object TYPE REF TO cl_alv_event_toolbar_set.
  DATA: ts_toolbar TYPE stb_button.
*        it_roid    TYPE lvc_t_roid,
*        lv_change  TYPE char01.
*
*  CLEAR ts_toolbar.
*  MOVE 'FC_SAVE' TO ts_toolbar-function.                    "#EC NOTEXT
*  MOVE icon_system_save TO ts_toolbar-icon.
*  MOVE 'Save Purchase Requisition' TO ts_toolbar-quickinfo.
*  MOVE 'PR Save' TO ts_toolbar-text.                        "#EC NOTEXT
*  IF gr_stk_grid IS BOUND.
*    gr_stk_grid->check_changed_data(
*      IMPORTING
*        e_valid  = lv_change    " Entries are Consistent
*        ).
*    IF lv_change IS NOT INITIAL.
*      MOVE abap_false TO ts_toolbar-disabled.
*    ELSE.
*      MOVE abap_true TO ts_toolbar-disabled.
*    ENDIF.
*  ELSE.
*    MOVE abap_true TO ts_toolbar-disabled.
*  ENDIF.
*  APPEND ts_toolbar TO p_e_object->mt_toolbar.

*  CLEAR ts_toolbar.
*  MOVE 'FC_CRT' TO ts_toolbar-function.                     "#EC NOTEXT
*  MOVE icon_create TO ts_toolbar-icon.
*  MOVE 'PO Create' TO ts_toolbar-text.
*  MOVE 'PO Create' TO ts_toolbar-quickinfo.                 "#EC NOTEXT
**  IF gr_prl_grid IS BOUND.
**    gr_prl_grid->get_selected_rows(
**     IMPORTING
**       et_row_no     =  it_roid   " Numeric IDs of Selected Rows
**    ).
**    IF it_roid IS NOT INITIAL.
**      MOVE abap_false TO ts_toolbar-disabled.
**    ELSE.
**      MOVE abap_true TO ts_toolbar-disabled.
**    ENDIF.
**  ELSE.
**    MOVE abap_true TO ts_toolbar-disabled.
**  ENDIF.
*  APPEND ts_toolbar TO p_e_object->mt_toolbar.

*  CLEAR ts_toolbar.
*  MOVE 'FC_STK' TO ts_toolbar-function.                     "#EC NOTEXT
*  MOVE icon_display TO ts_toolbar-icon.
*  MOVE 'Display Stock' TO ts_toolbar-text.
*  MOVE 'Display Stock' TO ts_toolbar-quickinfo.             "#EC NOTEXT
*  APPEND ts_toolbar TO p_e_object->mt_toolbar.

  CLEAR ts_toolbar.
  MOVE 'FC_REFRESH' TO ts_toolbar-function.                 "#EC NOTEXT
  MOVE icon_refresh TO ts_toolbar-icon.
  MOVE 'REFRESH' TO ts_toolbar-text.
  MOVE 'REFRESH' TO ts_toolbar-quickinfo.                   "#EC NOTEXT
  APPEND ts_toolbar TO p_e_object->mt_toolbar.
*
*  CLEAR ts_toolbar.
*  MOVE 'FC_DETAIL' TO ts_toolbar-function.                  "#EC NOTEXT
*  MOVE icon_detail TO ts_toolbar-icon.
*  MOVE 'Details' TO ts_toolbar-text.
*  MOVE 'Details' TO ts_toolbar-quickinfo.                   "#EC NOTEXT
*  APPEND ts_toolbar TO p_e_object->mt_toolbar.

  IF gv_edit <> 'X'.
    CLEAR ts_toolbar.
    MOVE 'FC_CHG_PR' TO ts_toolbar-function.                "#EC NOTEXT
    MOVE icon_change TO ts_toolbar-icon.
    MOVE 'Change PR' TO ts_toolbar-text.
    MOVE 'Change PR' TO ts_toolbar-quickinfo.               "#EC NOTEXT
    APPEND ts_toolbar TO p_e_object->mt_toolbar.
  ENDIF.

  IF gv_edit = 'X'.
    CLEAR ts_toolbar.
    MOVE 'FC_DISP_PR' TO ts_toolbar-function.               "#EC NOTEXT
    MOVE icon_change TO ts_toolbar-icon.
    MOVE 'Display' TO ts_toolbar-text.
    MOVE 'Display' TO ts_toolbar-quickinfo.                 "#EC NOTEXT
    APPEND ts_toolbar TO p_e_object->mt_toolbar.
  ENDIF.

  CLEAR ts_toolbar.
  MOVE 'FC_DEL' TO ts_toolbar-function.                     "#EC NOTEXT
  MOVE icon_delete TO ts_toolbar-icon.
  MOVE 'Delete' TO ts_toolbar-text.
  MOVE 'Delete' TO ts_toolbar-quickinfo.                    "#EC NOTEXT
  APPEND ts_toolbar TO p_e_object->mt_toolbar.

*  IF it_eban_prev <> it_eban.
  CLEAR ts_toolbar.
  MOVE 'FC_SAVE' TO ts_toolbar-function.                    "#EC NOTEXT
  MOVE icon_system_save TO ts_toolbar-icon.
  MOVE 'Save' TO ts_toolbar-text.
  MOVE 'Save' TO ts_toolbar-quickinfo.                      "#EC NOTEXT
  APPEND ts_toolbar TO p_e_object->mt_toolbar.
*  ENDIF.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : HANDLE_USER_COMMAND                            *
*
*&**********************************************************************
*& Form Definition    : Handle custom buttons user command (DE1K905556)*
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM handle_user_command  USING    p_e_ucomm TYPE syucomm.
  CASE  p_e_ucomm.
*    WHEN 'FC_SAVE'.
*      PERFORM f_save_pr.
**    WHEN 'FC_CRT'.
**      PERFORM f_create_po.
*    WHEN 'FC_STK'.
*      PERFORM f_display_stock.
    WHEN 'FC_REFRESH'.
      CLEAR: it_eban.
      PERFORM f_get_prl_data.
      PERFORM f_field_editable.
      PERFORM f_set_field_edit USING ''.
      CLEAR: gv_edit.

      it_eban_prev = it_eban.
      CALL METHOD gr_prl_grid->set_table_for_first_display
        EXPORTING
          is_variant                    = ts_prl_variant    " Layout
          i_save                        = 'A'    " Save Layout
          is_layout                     = ts_prl_layo    " Layout
          it_toolbar_excluding          = it_exclude    " Excluded Toolbar Standard Functions
          it_alv_graphics               = it_prl_graphics
        CHANGING
          it_outtab                     = it_eban   " Output Table
          it_fieldcatalog               = it_fcat    " Field Catalog
          it_sort                       = it_sort    " Sort Criteria
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4.
      IF sy-subrc <> 0.
*   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    WHEN 'FC_CHG_PR'.
      PERFORM f_change_pr.
    WHEN 'FC_DISP_PR'.
      PERFORM f_display_pr.
    WHEN 'FC_DEL'.
      PERFORM f_delete_pr.
    WHEN 'FC_SAVE'.
      PERFORM f_save_pr.
*    WHEN 'FC_DETAIL'.
*      PERFORM f_detail.
  ENDCASE.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_REGISTER_EVENT                               *
*
*&**********************************************************************
*& Form Definition    : Register required events (DE1K905556)          *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_register_event .
  CALL METHOD gr_prl_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  CALL METHOD gr_prl_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  CREATE OBJECT gr_alv_event.
  SET HANDLER gr_alv_event->handle_toolbar FOR gr_prl_grid.
  SET HANDLER gr_alv_event->handle_user_command FOR gr_prl_grid.
*  SET HANDLER gr_alv_event->handle_changed_data FOR gr_prl_grid.
  SET HANDLER gr_alv_event->handle_hotspot_click FOR gr_prl_grid.
  SET HANDLER gr_alv_event->handle_double_click FOR gr_prl_grid.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_SAVE_PR                               *
*
*&**********************************************************************
*& Form Definition    : Save purchase requisitions (DE1K905556)        *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
*FORM f_save_pr .
**  DATA it_roid   TYPE lvc_t_roid.
**  gr_prl_grid->get_selected_rows(
**   IMPORTING
**     et_row_no     =  it_roid   " Numeric IDs of Selected Rows
**  ).
*  FIELD-SYMBOLS:<fs_cat>  LIKE LINE OF it_fcat_l.
*  DATA:ts_mod_cell TYPE lvc_s_modi,
*       it_pr_save  TYPE ydbm_pr_update_tt,
*       ts_pr_save  LIKE LINE OF  it_pr_save,
*       ts_eban     LIKE LINE OF it_eban,
*       ts_log      LIKE LINE OF it_log,
*       lv_error    TYPE boolean,
*       it_log_bapi TYPE bapiret2_t,
*       ts_log_bapi LIKE LINE OF it_log_bapi,
*       it_log_c    LIKE it_log.
*
*  it_log_c = it_log.
*  CLEAR:it_log,it_row.
*  LOOP AT it_alv_mod_cell INTO ts_mod_cell.
**    IF ( ts_mod_cell-fieldname = 'MENGE' OR ts_mod_cell-fieldname = 'LIFNR' OR ts_mod_cell-fieldname = 'RESWK')
**        AND ts_mod_cell-value IS NOT INITIAL AND ts_mod_cell-value NE 0.
*    CLEAR ts_eban.
*    READ TABLE it_eban INTO ts_eban INDEX ts_mod_cell-row_id.
*    IF sy-subrc = 0.
*      CLEAR ts_pr_save.
*      ts_pr_save-pr_type    = ts_eban-bsart.
*      ts_pr_save-preq_no    = ts_eban-banfn.
*      ts_pr_save-preq_item  = ts_eban-bnfpo.
*      ts_pr_save-quantity   = ts_eban-menge.
*      ts_pr_save-vendor     = ts_eban-lifnr.
*      ts_pr_save-suppl_plnt = ts_eban-reswk.
*      ts_pr_save-tracking_no = ts_eban-bednr.
*      ts_pr_save-ekorg = ts_eban-ekorg.
*      ts_pr_save-ekgrp = ts_eban-ekgrp.
*      ts_pr_save-store_loc = ts_eban-lgort.
*      ts_pr_save-plant = ts_eban-werks.
*      ts_pr_save-deliv_date = ts_eban-lfdat.
*      APPEND ts_pr_save TO it_pr_save.
*    ENDIF.
**    ELSE.
**      CLEAR ts_log.
**      ts_log-type = 'E'.
**      ts_log-message = 'Mandatory fields are not entered'.
**      APPEND ts_log TO it_log.
**    ENDIF.
*  ENDLOOP.
*  CLEAR it_alv_mod_cell.
*  IF it_log IS INITIAL AND it_pr_save IS NOT INITIAL.
*    SORT it_pr_save BY preq_no preq_item.
*    DELETE ADJACENT DUPLICATES FROM it_pr_save COMPARING preq_no preq_item.
*    CALL FUNCTION 'YDBM_UPDATE_PR_FM'
*      EXPORTING
*        it_pr_items = it_pr_save
*      IMPORTING
*        et_message  = it_log_bapi.
*    PERFORM f_prepare_log USING it_log_bapi.
*  ELSEIF it_log IS INITIAL.
*    it_log = it_log_c.
*    MESSAGE s142(ymsg_jet_dbm).
*    RETURN.
*  ENDIF.
*  PERFORM show_hide_fcat.
**  LOOP AT it_log TRANSPORTING NO FIELDS WHERE type = 'E' OR type = 'A'.
**    lv_error = abap_true.
**    EXIT.
**  ENDLOOP.
**  IF lv_error EQ abap_true AND gr_stk_grid IS BOUND.
**    "create field catalog and display in ALV
**    IF lv_first_time = abap_false.
**      lv_first_time = abap_true. "clear in stock event and back event
**      it_fcat_l = it_fcat_l_c.
**      LOOP AT it_fcat_l ASSIGNING <fs_cat>.
**        <fs_cat>-no_out = abap_false.
**        IF  <fs_cat>-fieldname = 'G_TYPE' OR <fs_cat>-fieldname = 'TYPE'.
**          <fs_cat>-no_out = abap_true.
**        ENDIF.
**      ENDLOOP.
**      PERFORM f_fill_led.
**      gr_stk_grid->set_frontend_fieldcatalog( it_fieldcatalog = it_fcat_l ).
**      gr_stk_grid->refresh_table_display( ).
**    ENDIF.
**  ELSE.
**    MESSAGE s094(ymsg_jet_dbm).
**  ENDIF.
*  gr_prl_grid->refresh_table_display( ).
*ENDFORM.

FORM f_save_pr .
  DATA: lt_row_no    TYPE lvc_t_roid,
        lw_row_no    TYPE lvc_s_roid,
        it_pr_save   TYPE zvss_pr_update_tt,
        ts_pr_save   LIKE LINE OF  it_pr_save,
        ls_eban      TYPE ty_eban,
        ls_eban_prev TYPE ty_eban,
        it_log_bapi  TYPE bapiret2_t,
        ts_log_bapi  LIKE LINE OF it_log_bapi.

  CALL METHOD gr_prl_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row_no.    " Numeric IDs of Selected Rows

*  LOOP AT lt_row_no INTO lw_row_no.
  CLEAR ls_eban.
  LOOP AT it_eban INTO ls_eban. "INDEX lw_row_no-row_id.
*    IF sy-subrc = 0.
    READ TABLE it_eban_prev INTO ls_eban_prev
      WITH KEY banfn = ls_eban-banfn bnfpo = ls_eban-bnfpo.
    IF sy-subrc = 0.
      IF ls_eban_prev-menge <> ls_eban-menge.

        CLEAR ts_pr_save.
        ts_pr_save-pr_type    = ls_eban-bsart.
        ts_pr_save-preq_no    = ls_eban-banfn.
        ts_pr_save-preq_item  = ls_eban-bnfpo.
        ts_pr_save-quantity   = ls_eban-menge.
        ts_pr_save-vendor     = ls_eban-lifnr.
        ts_pr_save-suppl_plnt = ls_eban-reswk.
        ts_pr_save-tracking_no = ls_eban-bednr.
        ts_pr_save-ekorg = ls_eban-ekorg.
        ts_pr_save-ekgrp = ls_eban-ekgrp.
        ts_pr_save-store_loc = ls_eban-lgort.
        ts_pr_save-plant = ls_eban-werks.
        ts_pr_save-deliv_date = ls_eban-lfdat.
        APPEND ts_pr_save TO it_pr_save.
      ENDIF.
    ENDIF.
*    ENDIF.
  ENDLOOP.

  IF it_pr_save IS NOT INITIAL.
    SORT it_pr_save BY preq_no preq_item.
    DELETE ADJACENT DUPLICATES FROM it_pr_save COMPARING preq_no preq_item.
    CALL FUNCTION 'YDBM_UPDATE_PR_FM'
      EXPORTING
        it_pr_items = it_pr_save
      IMPORTING
        et_message  = it_log_bapi.
    READ TABLE it_log_bapi INTO ts_log_bapi
      WITH KEY type = 'E'.
    IF sy-subrc = 0.
      MESSAGE ID ts_log_bapi-id TYPE ts_log_bapi-type
        NUMBER ts_log_bapi-number
        WITH ts_log_bapi-message_v1 ts_log_bapi-message_v2 ts_log_bapi-message_v3 ts_log_bapi-message_v4.
    ELSE.
      MESSAGE TEXT-002 TYPE 'S'.
    ENDIF.
  ELSE.
    MESSAGE TEXT-003 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

  it_eban_prev = it_eban.
  PERFORM f_display_pr .
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : HANDLE_DATA_CHANGED                            *
*
*&**********************************************************************
*& Form Definition    : Capture changed data from Pool List ALV        *
*&(DE1K905556)
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM handle_changed_data  USING    p_er_data_changed TYPE REF TO cl_alv_changed_data_protocol.
*  DATA: ts_mod_cell  LIKE LINE OF it_alv_mod_cell.
*  DATA: ts_eban      LIKE LINE OF it_eban.
*  LOOP AT p_er_data_changed->mt_mod_cells INTO ts_mod_cell.
*    APPEND ts_mod_cell TO it_alv_mod_cell.
*    IF ts_mod_cell-fieldname = 'PO_DOC'.
*      ts_eban-po_doc = ts_mod_cell-value.
*      MODIFY it_eban INDEX ts_mod_cell-row_id FROM ts_eban TRANSPORTING po_doc.
*    ENDIF.
*    IF ts_mod_cell-fieldname = 'LIFNR'.
*      ts_eban-lifnr = ts_mod_cell-value.
**      ts_eban-vendor = ts_mod_cell-value.
*      MODIFY it_eban INDEX ts_mod_cell-row_id FROM ts_eban TRANSPORTING lifnr.
*    ENDIF.
*  ENDLOOP.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_SET_FIELD_EDIT                               *
*
*&**********************************************************************
*& Form Definition    : Edit field using fieldcatalog (DE1K905556)     *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_set_field_edit USING iv_switch TYPE crmt_boolean.
  FIELD-SYMBOLS:<fs_edit>  LIKE LINE OF it_fcat.
  LOOP AT it_fcat ASSIGNING <fs_edit> WHERE fieldname = 'MENGE'
*                                         OR fieldname = 'LIFNR'
*                                         OR fieldname = 'RESWK'
*                                         OR fieldname = 'PO_DOC'
*                                         OR fieldname = 'LFDAT'
*                                         OR fieldname = 'WERKS'
*                                         OR fieldname = 'LGORT'
*                                         OR fieldname = 'EKGRP'
*                                         OR fieldname = 'BEDNR'
*                                         OR fieldname = 'EKORG'
                                                 .
    <fs_edit>-edit = iv_switch.
  ENDLOOP.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_DISABLE_ALV_TOOLBAR                          *
*
*&**********************************************************************
*& Form Definition    : Disable ALV toolbar (DE1K905556)               *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_disable_alv_toolbar.
  DATA ts_exclude  LIKE LINE OF it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row .
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_copy .
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row .
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_print.
  APPEND ts_exclude TO it_exclude.
*  ts_exclude = cl_gui_alv_grid=>mc_fc_refresh.
*  APPEND ts_exclude TO it_exclude.
*  ts_exclude = cl_gui_alv_grid=>mc_fc_sort.
*  append ts_exclude to it_exclude.
*  ts_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
*  append ts_exclude to it_exclude.
*  ts_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
*  append ts_exclude to it_exclude.
*  ts_exclude = cl_gui_alv_grid=>mc_fc_find.
*  APPEND ts_exclude TO it_exclude.
*  ts_exclude = cl_gui_alv_grid=>mc_fc_filter.
*  APPEND ts_exclude TO it_exclude.
*  ts_exclude = cl_gui_alv_grid=>mc_fc_graph.
*  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ts_exclude TO it_exclude.
*  ts_exclude = cl_gui_alv_grid=>mc_mb_export.
*  append ts_exclude to it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_load_variant." for layout
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_mb_sum.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_current_variant.
  APPEND ts_exclude TO it_exclude.
  ts_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ts_exclude TO it_exclude.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_PREPARE_LOG                          *
*
*&**********************************************************************
*& Form Definition    : Prepare log messages (DE1K905556)              *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_prepare_log  USING    p_it_log_bapi TYPE bapiret2_t.
  DATA ts_bapi_log  TYPE bapiret2.
  DATA ts_log  LIKE LINE OF it_log.
  LOOP AT p_it_log_bapi INTO ts_bapi_log.
    ts_log-type    = ts_bapi_log-type.
    ts_log-message = ts_bapi_log-message.
    APPEND ts_log TO it_log.
  ENDLOOP.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_FILL_LED                                     *
*
*&**********************************************************************
*& Form Definition    : Prepare traffic lights for log messages        *
*&(DE1K905556)
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_fill_led .
  FIELD-SYMBOLS:<fs_log>  LIKE LINE OF it_log.
  LOOP AT it_log ASSIGNING <fs_log>.
    IF <fs_log>-type = 'E' OR <fs_log>-type = 'A'.
      WRITE  icon_red_light  AS ICON TO <fs_log>-message_type.
    ELSEIF <fs_log>-type = 'S'.
      WRITE icon_green_light AS ICON TO <fs_log>-message_type.
    ELSEIF <fs_log>-type = 'W'.
      WRITE icon_yellow_light AS ICON TO <fs_log>-message_type.
    ENDIF.
  ENDLOOP.
*  ts_stk_layout-no_toolbar = abap_true.
*  ts_stk_layout-excp_fname = 'LIGHTS'.
*  gr_prl_grid->set_frontend_layout( is_layout = ts_stk_layout ).
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_CREATE_PO                                    *
*
*&**********************************************************************
*& Form Definition    : Create PO for selected PR's (DE1K905556)       *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_create_po .
  DATA: it_selected_r  TYPE lvc_t_roid,
        it_pr_item     TYPE zvss_pr_update_tt,
        ts_pr_item     LIKE LINE OF it_pr_item,
        ts_eban        LIKE LINE OF it_eban,
        ts_selected_r  LIKE LINE OF it_selected_r,
        it_return      TYPE bapiret2_t,
        ts_return      TYPE bapiret2,
        ts_log         LIKE LINE OF it_log,
        lv_po          TYPE ebeln,
        lv_po_doct     TYPE bsart,
        lv_first       TYPE boolean,
        lv_check       TYPE boolean,
        lv_po_exist    TYPE boolean,
        lt_add_row     TYPE lvc_t_roid,
        lw_add_row     TYPE lvc_s_roid,
        lv_header      TYPE int4,
        lt_header_eban TYPE TABLE OF ty_eban,
        ls_header_eban TYPE ty_eban,
        lt_row_no      TYPE lvc_t_roid,
        lw_row_no      TYPE lvc_s_roid,
        ls_msg         TYPE esp1_message_wa_type,
        lt_msg         TYPE esp1_message_tab_type,
        lv_tracking_no TYPE bednr,
        lv_tabix       TYPE sy-tabix.

  FIELD-SYMBOLS: <fs_eban>  LIKE LINE OF it_eban.

*  CHECK gs_po-selected_row IS NOT INITIAL.
  IF gr_prl_grid IS BOUND.
    gr_prl_grid->get_selected_rows(
      IMPORTING
        et_row_no     =  it_selected_r ).  " Numeric IDs of Selected Rows

    it_row = it_selected_r.

    lt_header_eban = it_eban.
    DELETE ADJACENT DUPLICATES FROM lt_header_eban COMPARING matnr_ext.
    CLEAR: lt_add_row.

    LOOP AT lt_row_no INTO lw_row_no WHERE row_id LT 0.

      lv_header = abs( lw_row_no-row_id ).
      READ TABLE lt_header_eban INTO ls_header_eban INDEX lv_header.
      IF sy-subrc = 0.
        LOOP AT it_eban TRANSPORTING NO FIELDS
            WHERE matnr = ls_header_eban-matnr.
          lw_add_row-row_id = sy-tabix.
          APPEND lw_add_row TO lt_add_row.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    DELETE lt_row_no WHERE row_id LT 0.

    IF lt_add_row IS NOT INITIAL.
      APPEND LINES OF lt_add_row TO it_selected_r.
    ENDIF.

    CLEAR: lv_tracking_no.
    SORT it_selected_r BY row_id.
    LOOP AT it_selected_r INTO ts_selected_r.
      lv_tabix = sy-tabix.
      CLEAR ts_eban.
      READ TABLE it_eban INTO ts_eban INDEX ts_selected_r-row_id.
      IF sy-subrc = 0.
        CLEAR ts_pr_item.
        IF lv_tabix = 1.
          lv_tracking_no = ts_eban-bednr.
        ENDIF.
        IF lv_tracking_no <> ts_eban-bednr.
          CLEAR: lv_tracking_no.
        ENDIF.
        ts_pr_item-preq_no = ts_eban-banfn.
        ts_pr_item-preq_item = ts_eban-bnfpo.
        ts_pr_item-pr_type = ts_eban-bsart.
        ts_pr_item-quantity = ts_eban-menge.
        ts_pr_item-vendor = gs_po-lifnr.
        ts_pr_item-suppl_plnt = gs_po-reswk.
        ts_pr_item-ekorg = ts_eban-ekorg.
        IF ts_pr_item-ekorg IS INITIAL.
          IF ts_eban-werks(2) = '22'.
            ts_pr_item-ekorg = '2201'.
          ELSEIF ts_eban-werks(2) = '21'.
            ts_pr_item-ekorg = '2101'.
          ENDIF.
        ENDIF.
        ts_pr_item-ekgrp = ts_eban-ekgrp.
        IF ts_pr_item-ekgrp IS INITIAL.
          IF ts_eban-werks(2) = '22'.
            ts_pr_item-ekgrp = '225'.
          ELSEIF ts_eban-werks(2) = '21'.
            ts_pr_item-ekgrp = '215'.
          ENDIF.
        ENDIF.
        ts_pr_item-plant = ts_eban-werks.
        ts_pr_item-store_loc = ts_eban-lgort.
        IF ts_eban-ebeln IS NOT INITIAL.
          MESSAGE e278(ymsg_jet_dbm).
          lv_po_exist = abap_true.
          EXIT.
        ENDIF.
        APPEND ts_pr_item TO it_pr_item.
      ENDIF.

      lv_po_doct = gs_po-po_order_type.
      IF lv_po_doct IS INITIAL.
        MESSAGE e279(ymsg_jet_dbm).
        EXIT.
      ENDIF.
    ENDLOOP.

    IF it_pr_item IS NOT INITIAL.
*      PERFORM f_check_pr_is_saved USING it_pr_item
*                                  CHANGING lv_check
*                                           it_log.
      IF
        "lv_check EQ abap_true AND
        lv_po_exist = abap_false.
        CALL FUNCTION 'YDBM_CREATE_PO_FROM_PR_FM'
          EXPORTING
            it_pr_items   = it_pr_item
            iv_doc_type   = lv_po_doct
            iv_trackingno = lv_tracking_no
          IMPORTING
            ev_po_number  = lv_po
            et_return     = it_return.
        CLEAR it_log.
        READ TABLE it_return INTO ts_return WITH KEY type = 'E'.
        IF sy-subrc = 0.

          LOOP AT it_return INTO ts_return WHERE type = 'E'.
            ls_msg-lineno = sy-index.
            ls_msg-msgid = ts_return-id.
            ls_msg-msgno = ts_return-number.
            ls_msg-msgty = ts_return-type.
            ls_msg-msgv1 = ts_return-message_v1.
            ls_msg-msgv2 = ts_return-message_v2.
            ls_msg-msgv3 = ts_return-message_v3.
            ls_msg-msgv4 = ts_return-message_v4.
            APPEND ls_msg TO lt_msg.
          ENDLOOP.
          CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
            TABLES
              i_message_tab = lt_msg.
*          MESSAGE ID ts_return-id TYPE 'S' NUMBER ts_return-number
*            WITH ts_return-message_v1
*                 ts_return-message_v2
*                 ts_return-message_v3
*                 ts_return-message_v4 DISPLAY LIKE 'E'.
        ENDIF.
        IF lv_po IS NOT INITIAL.
          LOOP AT it_pr_item INTO ts_pr_item.
            READ TABLE it_eban ASSIGNING <fs_eban>
              WITH KEY banfn = ts_pr_item-preq_no
                       bnfpo = ts_pr_item-preq_item..
            IF sy-subrc = 0.
              <fs_eban>-ebeln = lv_po.
              gs_po-ebeln = lv_po.
            ENDIF.
            IF <fs_eban> IS ASSIGNED.
              UNASSIGN <fs_eban>.
            ENDIF.
          ENDLOOP.
          MESSAGE s276(ymsg_jet_dbm) WITH lv_po.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE s144(ymsg_jet_dbm) DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ELSE."raise message
    MESSAGE s140(ymsg_jet_dbm) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
*  PERFORM show_hide_fcat.
*  gr_prl_grid->refresh_table_display( ).
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : SHOW_HIDE_FCAT                                 *
*
*&**********************************************************************
*& Form Definition    : Display or hide the from screen layout         *
*&(DE1K905556)
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM show_hide_fcat .
  FIELD-SYMBOLS:<fs_cat>  LIKE LINE OF it_fcat_l.
*  DATA lv_error    TYPE boolean.
*  LOOP AT it_log TRANSPORTING NO FIELDS WHERE type = 'E' OR type = 'A'.
*    lv_error = abap_true.
*    EXIT.
*  ENDLOOP.
  IF it_log IS NOT INITIAL AND gr_stk_grid IS BOUND.
    "create field catalog and display in ALV
    IF lv_first_time = abap_false.
      lv_first_time = abap_true. "clear in stock event and back event
      it_fcat_l = it_fcat_l_c.
      LOOP AT it_fcat_l ASSIGNING <fs_cat>.
        <fs_cat>-no_out = abap_false.
        IF  <fs_cat>-fieldname = 'MESSAGE_TYPE' OR <fs_cat>-fieldname = 'MESSAGE'.
*          OR <fs_cat>-fieldname = 'WERKS'
*        OR  <fs_cat>-fieldname = 'LGORT' OR <fs_cat>-fieldname = 'LABST' OR <fs_cat>-fieldname = 'EINME'
*        OR <fs_cat>-fieldname = 'MATNR' OR <fs_cat>-fieldname = 'MAKTX'.
          <fs_cat>-no_out = abap_false.
        ELSE.
          <fs_cat>-no_out = abap_true.
        ENDIF.
        IF <fs_cat>-fieldname = 'MESSAGE_TYPE'.
          <fs_cat>-scrtext_l = 'Exception'.
          <fs_cat>-scrtext_m = 'Exception'.
          <fs_cat>-scrtext_s = 'Exception'.
        ENDIF.
      ENDLOOP.
*      gr_stk_grid->refresh_table_display( ).
    ENDIF.
    PERFORM f_fill_led.
    gr_stk_grid->set_frontend_fieldcatalog( it_fieldcatalog = it_fcat_l ).
    gr_stk_grid->set_gridtitle( i_gridtitle = 'Messages Log' ).
  ELSEIF it_log IS INITIAL AND gr_stk_grid IS BOUND.
    MESSAGE s094(ymsg_jet_dbm).
  ENDIF.
  gr_stk_grid->refresh_table_display( ).
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : f_required_fields_PR                           *
*
*&**********************************************************************
*& Form Definition    : Fields to display in ALV grid (DE1K905556)     *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_required_fields_pr USING p_fields  TYPE string.
  DATA: lt_fields_r   TYPE TABLE OF string.
  SPLIT p_fields AT ',' INTO TABLE lt_fields_r.
  FIELD-SYMBOLS:<fs_cat>  LIKE LINE OF it_fcat.
  LOOP AT it_fcat ASSIGNING <fs_cat>.
    READ TABLE lt_fields_r WITH KEY table_line = <fs_cat>-fieldname TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      <fs_cat>-col_pos = sy-tabix.
      IF  <fs_cat>-fieldname = 'MATNR'.
        <fs_cat>-outputlen = 20.
        <fs_cat>-hotspot = abap_true.
      ENDIF.
      IF  <fs_cat>-fieldname = 'BANFN'.
        <fs_cat>-hotspot = abap_true.
      ENDIF.
      IF  <fs_cat>-fieldname = 'EBELN'.
        <fs_cat>-hotspot = abap_true.
      ENDIF.
      IF <fs_cat>-fieldname = 'TXZ01'.
        <fs_cat>-outputlen = 20.
      ENDIF.
      IF <fs_cat>-fieldname = 'LOEKZ'.
        <fs_cat>-checkbox = abap_true.
      ENDIF.
*      IF <fs_cat>-fieldname = 'BSART'.
*        <fs_cat>-outputlen = 16.
*        <fs_cat>-scrtext_l = 'PR Doc. Type'.
*        <fs_cat>-scrtext_m = 'PR Doc. Type'.
*        <fs_cat>-scrtext_s = 'PR Doc. Type'.
*        <fs_cat>-reptext = 'PR Doc. Type'.
*      ENDIF.
    ELSE.
      <fs_cat>-mark = abap_true.
    ENDIF.
  ENDLOOP.
  DELETE it_fcat WHERE mark EQ abap_true.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_DISPLAY_STOCK                                *
*
*&**********************************************************************
*& Form Definition    : display stock details in ALV grid (DE1K905556) *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
*FORM f_display_stock.
*  TYPES: BEGIN OF ty_tab, "
*           werks LIKE ekpo-werks,
*           lgort LIKE ekpo-lgort,
*           matnr LIKE ekpo-matnr,
*           menge LIKE ekpo-menge,
*           mengk LIKE ekpo-menge,
*         END OF ty_tab.
*  DATA:it_stock TYPE ydbm_jet_errstk_tt,
*       it_rows  TYPE lvc_t_roid,
*       ts_rows  LIKE LINE OF it_rows,
*       ts_eban  LIKE LINE OF it_eban,
*       it_matnr TYPE /isdfps/matnr_range_tt,
*       ts_matnr LIKE LINE OF it_matnr,
*       it_plant TYPE isi_plant_ra,
*       ts_plant LIKE LINE OF it_plant,
*       lv_size  TYPE i,
*       ts_log   TYPE ydbm_jet_errstk_st,
*       it_tab   TYPE TABLE OF ty_tab,
*       ts_tab   TYPE ty_tab.
*  DATA lv_elikz TYPE ekpo-elikz.
*  DATA lv_loekz TYPE ekpo-loekz.
*  RANGES: l_werks FOR mard-werks.
*  .
*
*  FIELD-SYMBOLS:<fs_fcat_l> LIKE LINE OF it_fcat_l,
*                <fs_log>    LIKE LINE OF it_log.
*  IF gr_prl_grid IS BOUND.
*    IF gr_stk_grid IS BOUND.
*      lv_first_time = abap_false.
*      LOOP AT it_fcat_l ASSIGNING <fs_fcat_l>.
*        IF <fs_fcat_l>-fieldname = 'G_TYPE' OR <fs_fcat_l>-fieldname = 'TYPE'
*        OR <fs_fcat_l>-fieldname = 'MESSAGE_TYPE' OR <fs_fcat_l>-fieldname = 'MESSAGE' OR <fs_fcat_l>-fieldname = 'MANDT'
*        OR <fs_fcat_l>-fieldname = 'BERID'   OR <fs_fcat_l>-fieldname = 'BERID' OR <fs_fcat_l>-fieldname = 'BERTX'
*        OR <fs_fcat_l>-fieldname = 'LGPBE' OR <fs_fcat_l>-fieldname = 'SBTXT' OR <fs_fcat_l>-fieldname = 'BSABR'
*        OR <fs_fcat_l>-fieldname = 'FAMNG' OR <fs_fcat_l>-fieldname = 'GLGMG' OR <fs_fcat_l>-fieldname = 'LBKUM'
*        OR <fs_fcat_l>-fieldname = 'TRAME' OR <fs_fcat_l>-fieldname = 'VBMNA'
*        OR <fs_fcat_l>-fieldname = 'VBMNB' OR <fs_fcat_l>-fieldname = 'TRASF'
*        OR <fs_fcat_l>-fieldname = 'VBMNC' OR <fs_fcat_l>-fieldname = 'VBMNE'
*        OR <fs_fcat_l>-fieldname = 'VBMNG' OR <fs_fcat_l>-fieldname = 'VBMNI'
*        OR <fs_fcat_l>-fieldname = 'SOBKZ' OR <fs_fcat_l>-fieldname = 'ZEILENKZ'
*        OR <fs_fcat_l>-fieldname = 'SOBKZ2' OR <fs_fcat_l>-fieldname = 'LVORM'
*        OR <fs_fcat_l>-fieldname = 'KASIT' OR <fs_fcat_l>-fieldname = 'WESBB'
*        OR <fs_fcat_l>-fieldname = 'SSTRA' OR <fs_fcat_l>-fieldname = 'BUKRS' OR <fs_fcat_l>-fieldname = 'BUTXT'
*        OR <fs_fcat_l>-fieldname = 'NAME1' OR <fs_fcat_l>-fieldname = 'LGOBE'
*        OR <fs_fcat_l>-fieldname = 'CHARG'.
*          <fs_fcat_l>-no_out = abap_true.
*        ELSE.
*          <fs_fcat_l>-no_out = abap_false.
*        ENDIF.
*      ENDLOOP.
*      gr_stk_grid->set_frontend_fieldcatalog( it_fieldcatalog = it_fcat_l ).
*      gr_stk_grid->refresh_table_display( ).
*    ENDIF.
*    gr_prl_grid->get_selected_rows(
*     IMPORTING
*       et_row_no  = it_rows    " Numeric IDs of Selected Rows
*    ).
*    it_row = it_rows.
*    IF it_rows IS NOT INITIAL.
*      DESCRIBE TABLE it_rows LINES lv_size.
*      IF lv_size GT 1.
*        MESSAGE e145(ymsg_jet_dbm).
*        RETURN.
*      ENDIF.
*      ts_matnr-sign = 'I'.
*      ts_matnr-option = 'EQ'.
*      ts_plant-sign = 'I'.
*      ts_plant-option = 'EQ'.
*      LOOP AT it_rows INTO ts_rows.
*        CLEAR ts_eban.
*        READ TABLE it_eban INTO ts_eban INDEX ts_rows-row_id.
*        IF sy-subrc = 0.
*          CLEAR:ts_matnr-low,ts_plant-low.
*          ts_matnr-low = ts_eban-matnr.
*          APPEND ts_matnr TO it_matnr.
*          ts_plant-low = ts_eban-werks.
*          APPEND ts_plant TO it_plant.
*        ENDIF.
*      ENDLOOP.
*      CALL FUNCTION 'YDBM_JET_GET_STOCK'
*        EXPORTING
*          it_matnr_range = it_matnr
**         it_werks_range = it_plant
*        IMPORTING
*          et_stock       = it_log.
*
*      LOOP AT it_log ASSIGNING <fs_log>.
*        CLEAR  : l_werks, l_werks[],it_tab.
*        l_werks-low = <fs_log>-werks.
*        l_werks-option = 'EQ'.
*        l_werks-sign = 'I'.
*        APPEND l_werks.
*
*        CALL FUNCTION 'MB_ADD_PURCHASE_ORDER_QUANTITY'
*          EXPORTING
*            x_elikz = lv_elikz
*            x_loekz = lv_loekz
*            x_matnr = <fs_log>-matnr
*            x_meins = 'EA'
*          TABLES
*            xtab    = it_tab
*            xwerks  = l_werks.
*        READ TABLE it_tab INTO ts_tab WITH KEY matnr = <fs_log>-matnr lgort = <fs_log>-lgort werks = <fs_log>-werks.
*        IF sy-subrc = 0.
*          <fs_log>-menge = ts_tab-menge.
*          <fs_log>-mengk = ts_tab-mengk.
*        ENDIF.
*
*      ENDLOOP.
*      IF gr_stk_grid IS BOUND.
*        gr_stk_grid->set_gridtitle( i_gridtitle = 'Stock Details' ).
*        gr_stk_grid->refresh_table_display( ).
*      ENDIF.
*    ELSE.
*      MESSAGE e144(ymsg_jet_dbm).
*    ENDIF.
*  ENDIF.
*ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_SET_SELECTED_ROW                             *
*
*&**********************************************************************
*& Form Definition    : set selected row (DE1K905556)                  *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_set_selected_row .
  gr_prl_grid->set_selected_rows(
    EXPORTING
      it_row_no  = it_row    " Numeric Row IDs
  ).
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_CLEAR_GLOBAL_VARIABLES                       *
*
*&**********************************************************************
*& Form Definition    : clear global variables (DE1K905556)            *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_clear_global_variables .
  CLEAR:it_alv_mod_cell,it_eban,it_log,it_row,lv_first_time.
ENDFORM.
*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Form Name        : F_CLEAR_GLOBAL_VARIABLES                       *
*
*&**********************************************************************
*& Form Definition    : clear global variables (DE1K905556)            *
*&
*&**********************************************************************
*& FORM CHANGES / Modification Logs :                                  *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
FORM f_add_field_fcat  USING    p_field  TYPE name_komp
                                p_tname  TYPE lvc_tname
                                p_rtname TYPE lvc_rtname
                                p_scrtxt TYPE scrtext_l
                                p_reffld TYPE scrtext_l
                                p_f4     TYPE boolean
                       CHANGING p_it_fcat LIKE it_fcat.
  DATA:ts_fcat LIKE LINE OF it_fcat,
       lv_pos  TYPE i.
  DESCRIBE TABLE p_it_fcat LINES lv_pos.
  ts_fcat-scrtext_l = p_scrtxt.
  ts_fcat-scrtext_m = p_scrtxt.
  ts_fcat-scrtext_s = p_scrtxt.
  ts_fcat-outputlen = 10.
  ts_fcat-fieldname = p_field.
  ts_fcat-tabname = p_tname.
  ts_fcat-ref_table = p_rtname.
  ts_fcat-ref_field = p_reffld.
  ts_fcat-f4availabl = p_f4.
  ts_fcat-col_pos = lv_pos + 1.
  APPEND ts_fcat TO it_fcat.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PR_IS_SAVED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_PR_ITEM  text
*      <--P_LV_CHECK  text
*      <--P_IT_LOG  text
*----------------------------------------------------------------------*
*FORM f_check_pr_is_saved  USING    p_it_pr_item TYPE ydbm_pr_update_tt
*                          CHANGING p_lv_check TYPE boolean
*                                   p_it_log LIKE it_log.
*  DATA:it_eban_db TYPE ydbm_pr_update_tt,
*       ts_pr_item LIKE LINE OF p_it_pr_item,
*       ts_eban_db LIKE LINE OF it_eban_db,
*       ts_it_log  LIKE LINE OF p_it_log.
*  p_lv_check = abap_true.
*  SELECT banfn AS preq_no bnfpo AS preq_item menge AS quantity lifnr AS vendor reswk AS suppl_plnt FROM eban
*    INTO CORRESPONDING FIELDS OF TABLE it_eban_db FOR ALL ENTRIES IN p_it_pr_item
*    WHERE banfn = p_it_pr_item-preq_no AND bnfpo = p_it_pr_item-preq_item.
*  IF sy-subrc <> 0.
*    CLEAR ts_it_log.
*    ts_it_log-type = TEXT-me0.
*    MESSAGE s168(ymsg_jet_dbm) INTO ts_it_log-message.
*    APPEND ts_it_log TO p_it_log.
*    p_lv_check = abap_false.
*    RETURN.
*  ENDIF.
*  LOOP AT p_it_pr_item INTO ts_pr_item.
*    CLEAR ts_eban_db.
*    READ TABLE it_eban_db INTO ts_eban_db WITH KEY preq_no = ts_pr_item-preq_no
*                                                   preq_item = ts_pr_item-preq_item.
*    IF sy-subrc <> 0.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s168(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-quantity <> ts_eban_db-quantity.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-vendor <> ts_eban_db-vendor.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-suppl_plnt <> ts_eban_db-suppl_plnt.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-deliv_date <> ts_eban_db-deliv_date.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-plant <> ts_eban_db-plant.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-store_loc <> ts_eban_db-store_loc.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-ekgrp <> ts_eban_db-ekgrp.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-ekgrp <> ts_eban_db-ekgrp.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-tracking_no <> ts_eban_db-tracking_no.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-tracking_no <> ts_eban_db-tracking_no.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*    IF ts_pr_item-ekorg <> ts_eban_db-ekorg.
*      CLEAR ts_it_log.
*      ts_it_log-type = TEXT-me0.
*      MESSAGE s169(ymsg_jet_dbm) INTO ts_it_log-message.
*      APPEND ts_it_log TO p_it_log.
*      p_lv_check = abap_false.
*      RETURN.
*    ENDIF.
*
*  ENDLOOP.
*ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_COLUMN_ID  text
*      -->P_E_ROW_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM handle_hotspot_click  USING    p_e_column_id TYPE lvc_s_col
                                    p_e_row_id TYPE lvc_s_row
                                    p_es_row_no TYPE lvc_s_roid.

  DATA: ts_eban  LIKE LINE OF it_eban.

  READ TABLE it_eban INTO ts_eban INDEX p_es_row_no-row_id.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  CASE p_e_column_id.
    WHEN 'MATNR'.
      SET PARAMETER ID 'MAT' FIELD ts_eban-matnr.
      SET PARAMETER ID 'MXX' FIELD 'K' .
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN .
    WHEN 'BANFN'.
      SET PARAMETER ID 'BAN' FIELD ts_eban-banfn.
      CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
    WHEN 'EBELN'.
      IF ts_eban-ebeln IS NOT INITIAL.
        SET PARAMETER ID 'BES' FIELD ts_eban-ebeln.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_REARRANGE_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_IT_FCAT  text
*----------------------------------------------------------------------*
FORM f_rearrange_fields  USING pv_fields TYPE string
                      CHANGING pt_fcat TYPE lvc_t_fcat.
  FIELD-SYMBOLS: <fs_fcat> TYPE lvc_s_fcat.
  DATA: lt_fields TYPE TABLE OF string,
        lv_fields TYPE string,
        lv_tabix  TYPE sy-tabix.

  SPLIT pv_fields AT ',' INTO TABLE lt_fields.

  LOOP AT lt_fields INTO lv_fields.
    lv_tabix = sy-tabix.
    READ TABLE pt_fcat ASSIGNING <fs_fcat>
      WITH KEY fieldname = lv_fields.
    IF sy-subrc = 0.
      <fs_fcat>-col_pos = lv_tabix.
      <fs_fcat>-decimals_o = 0.
      IF <fs_fcat>-fieldname = 'REGION'
        OR <fs_fcat>-fieldname = 'WERKS'
        OR <fs_fcat>-fieldname = 'MATNR'.
        <fs_fcat>-key = 'X'.
        <fs_fcat>-fix_column = 'X'.
      ELSE.
        CLEAR <fs_fcat>-key.
      ENDIF.
      IF <fs_fcat>-fieldname = 'MENGE'.
        <fs_fcat>-outputlen = 11.
        <fs_fcat>-scrtext_l = 'Qty Requested'.
        <fs_fcat>-scrtext_m = 'Qty Requested'.
        <fs_fcat>-scrtext_s = 'Qty Requested'.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_IT_SORT  text
*----------------------------------------------------------------------*
FORM f_prepare_sort  CHANGING pt_sort TYPE lvc_t_sort.

  DATA: ls_sort TYPE lvc_s_sort.

  CLEAR:ls_sort.
  ls_sort-fieldname = 'MATNR'.
  ls_sort-spos = 1.            " Second sort by this field.
  ls_sort-up = 'X'.            " Ascending
  APPEND ls_sort TO pt_sort.

  ls_sort-fieldname = 'REGION'.
  ls_sort-spos = 2.            " Second sort by this field.
  ls_sort-up = 'X'.            " Ascending
  APPEND ls_sort TO pt_sort.

  CLEAR:ls_sort.
  ls_sort-fieldname = 'WERKS'.
  ls_sort-spos = 3.            " Second sort by this field.
  ls_sort-up = 'X'.            " Ascending
  APPEND ls_sort TO pt_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_COLUMN_ID  text
*      -->P_E_ROW_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM handle_double_click  USING is_row_no TYPE lvc_s_roid.

  DATA: ts_eban  LIKE LINE OF it_eban.

  CLEAR: gs_po.
  READ TABLE it_eban INTO ts_eban INDEX is_row_no-row_id.
  IF sy-subrc = 0.
    gv_stock_matnr = ts_eban-matnr.
  ENDIF.

*  gs_po-selected_row = is_row_no-row_id.
*  gs_po-ebeln = ts_eban-ebeln.
*  gs_po-po_order_type = ts_eban-po_doc.
*  gs_po-reswk = ts_eban-reswk.
*  gs_po-werks = ts_eban-werks.
*  gs_po-menge = ts_eban-menge.
*  gs_po-matnr = ts_eban-matnr.
*  gs_po-txz01 = ts_eban-txz01.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cancel_pr .
  DATA: ls_eban    TYPE ty_eban,
        lv_success TYPE crmt_boolean.

  IF gs_po-selected_row IS INITIAL.
    MESSAGE e280(ymsg_jet_dbm).
  ELSE.
    READ TABLE it_eban INTO ls_eban INDEX gs_po-selected_row.
    IF sy-subrc = 0.
      CALL FUNCTION 'YMM_PR_CLOSE'
        EXPORTING
          iv_pr_no   = ls_eban-banfn    " Purchase requisition number
        IMPORTING
          ev_success = lv_success.    " Logical Variable
      IF lv_success = abap_true.
        MESSAGE s281(ymsg_jet_dbm).
      ELSE.
        MESSAGE e282(ymsg_jet_dbm).
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_change_pr .
  DATA: lt_row_ids TYPE lvc_t_roid,
        lw_row_id  TYPE lvc_s_roid.

  FIELD-SYMBOLS: <fs_eban>  TYPE ty_eban,
                 <fs_style> TYPE lvc_s_styl.

  CALL METHOD gr_prl_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row_ids.

  IF lt_row_ids IS INITIAL.
    MESSAGE TEXT-001 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM f_set_field_edit USING abap_true.
  CALL METHOD gr_prl_grid->set_frontend_fieldcatalog
    EXPORTING
      it_fieldcatalog = it_fcat.    " Field Catalog

*  CALL METHOD gr_prl_grid->get_selected_rows
*    IMPORTING
*      et_row_no = lt_row_ids.
  LOOP AT lt_row_ids INTO lw_row_id.
    READ TABLE it_eban ASSIGNING <fs_eban>
      INDEX lw_row_id-row_id.
    IF sy-subrc = 0.
      READ TABLE <fs_eban>-it_cell_tab ASSIGNING <fs_style>
        WITH KEY fieldname = 'MENGE'.
      IF sy-subrc = 0.
        <fs_style>-style = cl_gui_alv_grid=>mc_style_enabled.
      ENDIF.
    ENDIF.
  ENDLOOP.

  gv_edit = 'X'.

  CALL METHOD gr_prl_grid->set_toolbar_interactive.
  CALL METHOD gr_prl_grid->refresh_table_display.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_pr .
  FIELD-SYMBOLS: <fs_eban>  TYPE ty_eban,
                 <fs_style> TYPE lvc_s_styl.

  LOOP AT it_eban ASSIGNING <fs_eban>.
    READ TABLE <fs_eban>-it_cell_tab ASSIGNING <fs_style>
      WITH KEY fieldname = 'MENGE'.
    IF sy-subrc = 0.
      <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
    ENDIF.
  ENDLOOP.

  PERFORM f_set_field_edit USING ''.
  CLEAR: gv_edit.

  CALL METHOD gr_prl_grid->set_table_for_first_display
    EXPORTING
      is_variant                    = ts_prl_variant    " Layout
      i_save                        = 'A'    " Save Layout
      is_layout                     = ts_prl_layo    " Layout
      it_toolbar_excluding          = it_exclude    " Excluded Toolbar Standard Functions
      it_alv_graphics               = it_prl_graphics
    CHANGING
      it_outtab                     = it_eban   " Output Table
      it_fieldcatalog               = it_fcat    " Field Catalog
      it_sort                       = it_sort    " Sort Criteria
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
*   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_detail .

  DATA: ts_eban   LIKE LINE OF it_eban,
        lt_row_no TYPE lvc_t_roid,
        lw_row_no TYPE lvc_s_roid.

  CLEAR: gs_po.
  CALL METHOD gr_prl_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row_no.   " Numeric IDs of Selected Rows
  IF lt_row_no IS NOT INITIAL.
    LOOP AT lt_row_no INTO lw_row_no.
      READ TABLE it_eban INTO ts_eban INDEX lw_row_no-row_id.
      IF sy-subrc = 0.
        gs_po-ebeln = ts_eban-ebeln.
        gs_po-po_order_type = ts_eban-po_doc.
        gs_po-reswk = ts_eban-reswk.
*        gs_po-werks = ts_eban-werks.
        gs_po-menge = gs_po-menge + ts_eban-menge.
        gs_po-matnr = ts_eban-matnr.
        gs_po-txz01 = ts_eban-txz01.
      ENDIF.
    ENDLOOP.

  ELSE.
    MESSAGE TEXT-004 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PO_CREATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_po_creation .

  DATA: lt_row_no      TYPE lvc_t_roid,
        lt_add_row     TYPE lvc_t_roid,
        lw_row_no      TYPE lvc_s_roid,
        lw_add_row     TYPE lvc_s_roid,
        ls_eban        TYPE ty_eban,
        lv_tabix       TYPE sytabix,
        lv_header      TYPE int4,
        lt_header_eban TYPE TABLE OF ty_eban,
        ls_header_eban TYPE ty_eban,
        lt_cell        TYPE lvc_t_cell.

  CALL METHOD gr_prl_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row_no.    " Numeric IDs of Selected Rows

  CLEAR: gs_po.

  lt_header_eban = it_eban.
  DELETE ADJACENT DUPLICATES FROM lt_header_eban COMPARING matnr_ext.
  CLEAR: lt_add_row.

  LOOP AT lt_row_no INTO lw_row_no WHERE row_id LT 0.

    lv_header = abs( lw_row_no-row_id ).
    READ TABLE lt_header_eban INTO ls_header_eban INDEX lv_header.
    IF sy-subrc = 0.
      LOOP AT it_eban TRANSPORTING NO FIELDS
          WHERE matnr = ls_header_eban-matnr.
        lw_add_row-row_id = sy-tabix.
        APPEND lw_add_row TO lt_add_row.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  DELETE lt_row_no WHERE row_id LT 0.

  IF lt_add_row IS NOT INITIAL.
    APPEND LINES OF lt_add_row TO lt_row_no.
  ENDIF.
  SORT lt_row_no BY row_id.
  DELETE ADJACENT DUPLICATES FROM lt_row_no COMPARING row_id.

  CLEAR: gv_cn_lifnr , gv_cn_reswk.
  LOOP AT lt_row_no INTO lw_row_no.
    lv_tabix = sy-tabix.
    READ TABLE it_eban INTO ls_eban
      INDEX lw_row_no-row_id.
    IF sy-subrc = 0.
      IF ls_eban-ebeln IS NOT INITIAL.
        MESSAGE s295(ymsg_jet_dbm) DISPLAY LIKE 'E' WITH ls_eban-banfn ls_eban-bnfpo.
        RETURN.
      ENDIF.
      IF lv_tabix EQ 1.
        gs_po-ebeln = ls_eban-ebeln.
        gs_po-po_order_type = ls_eban-po_doc.
        gs_po-reswk = ls_eban-reswk.
        gs_po-werks = ls_eban-werks.
        gs_po-menge = ls_eban-menge.
        gs_po-matnr = ls_eban-matnr.
        gs_po-txz01 = ls_eban-txz01.
        gv_cn_lifnr = ls_eban-lifnr.
        gv_cn_reswk = ls_eban-reswk.
      ELSE.
        IF gv_cn_reswk <> ls_eban-reswk.
          CLEAR: gv_cn_reswk.
        ENDIF.
        IF gv_cn_lifnr <> ls_eban-lifnr.
          CLEAR: gv_cn_lifnr.
        ENDIF.
        gs_po-menge = gs_po-menge + ls_eban-menge.
        IF gs_po-werks <> ls_eban-werks.
          MESSAGE s296(ymsg_jet_dbm) DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gs_po-menge GT 0.
    CALL SCREEN 1003 STARTING AT 20 10.
  ELSE.
    MESSAGE s300(ymsg_jet_dbm) DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MMBE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_mmbe_data .
  CLEAR: it_pre_out[], it_mara[], it_werks_info[], it_mard[].
*... §2.2 select the data from the data table into a local internal table
*get JAHACO plants

  TYPES : BEGIN OF ty_ekbe,
            ebeln TYPE ekbe-ebeln,
            ebelp TYPE ekbe-ebelp,
            bwart TYPE ekbe-bwart,
            menge TYPE ekbe-menge,
            shkzg TYPE ekbe-shkzg,
          END OF ty_ekbe.
  TYPES : BEGIN OF ty_ekpo,
            ebeln TYPE ekpo-ebeln,
            ebelp TYPE ekpo-ebelp,
            matnr TYPE ekpo-matnr,
            menge TYPE ekpo-menge,
            werks TYPE ekpo-werks,
            lgort TYPE ekpo-lgort,
            banfn TYPE banfn,
            bnfpo TYPE bnfpo,
          END OF ty_ekpo.
  DATA: lt_ekpo TYPE STANDARD TABLE OF ty_ekpo.
  DATA: wg_error,
        ts_eban_qty  TYPE ty_eban_qty,
        ts_eban_temp TYPE ty_eban_qty,
        it_eban_temp TYPE TABLE OF ty_eban_qty,
        it_eban_ord  TYPE TABLE OF ty_eban_qty.
  DATA :
         ls_ekpo TYPE ty_ekpo.

  DATA : lt_ekbe TYPE STANDARD TABLE OF ty_ekbe,
         ls_ekbe TYPE ty_ekbe.

  DATA: lt_eban_c LIKE it_eban_c.

  FIELD-SYMBOLS: <fs_eban> LIKE LINE OF it_eban_qty.

*    CHECK IF PLANT IS IN JAHACO
*  BREAK tech1.

  "*****************************************************
  "*  get plant information
  "*****************************************************
  IF NOT wg_error = 'X'.

    lt_eban_c = it_eban_c.

    DELETE lt_eban_c WHERE matnr IS INITIAL.
    SORT lt_eban_c BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_eban_c COMPARING matnr.
    IF lt_eban_c IS NOT INITIAL.
      SELECT a~matnr a~mtart a~extwg a~matkl a~meins b~werks b~maabc
        b~minbe AS reorder_point b~eisbe AS safe_stk c~maktx
        FROM mara AS a
      INNER JOIN marc AS b ON b~matnr = a~matnr
      INNER JOIN makt AS c ON c~matnr = a~matnr
      INTO CORRESPONDING FIELDS OF TABLE it_mara
      FOR ALL ENTRIES IN it_eban_c
      WHERE a~matnr = it_eban_c-matnr
*    AND a~matkl = it_eban_c-matkl
      AND b~werks IN s_werks
      AND c~spras = sy-langu.

      IF NOT it_mara IS INITIAL.

        SORT it_mara BY matnr werks.

        SELECT matnr werks lgort labst klabs FROM mard
        INTO  TABLE it_mard
        FOR ALL ENTRIES IN it_mara
        WHERE matnr = it_mara-matnr
          AND werks = it_mara-werks
          AND lgort = 'P001'.

*      it_mard_blank[] = it_mard[].


*      SORT it_mard_blank ASCENDING BY matnr werks.
*      DELETE ADJACENT DUPLICATES FROM it_mard_blank COMPARING matnr werks
        IF it_mard IS NOT INITIAL.  "added by ismail
          SELECT
            ekpo~matnr
            ekpo~werks
            ekpo~lgort
            ekpo~menge
            INTO TABLE it_eban_qty
            FROM eban
            INNER JOIN
            ekpo
            ON eban~banfn = ekpo~banfn
            FOR ALL ENTRIES IN it_mard
            WHERE ekpo~loekz = ''
            AND ekpo~matnr = it_mard-matnr
            AND ekpo~werks = it_mard-werks
*        AND ekpo~lgort = it_mard-lgort
            AND eban~bsart = 'YMRP'.

          IF sy-subrc = 0.
            LOOP AT it_eban_qty INTO ts_eban_qty.
              READ TABLE it_eban_temp ASSIGNING <fs_eban>
              WITH KEY matnr = ts_eban_qty-matnr
              werks = ts_eban_qty-werks.
*          lgort = ts_eban_qty-lgort.
              IF <fs_eban> IS ASSIGNED.
                <fs_eban>-menge =   <fs_eban>-menge + ts_eban_qty-menge.
              ELSE.
                APPEND ts_eban_qty TO it_eban_temp.
              ENDIF.
              UNASSIGN <fs_eban>.
            ENDLOOP.
          ENDIF.


          SELECT ebeln
           ebelp
           matnr
           menge
           werks
           lgort FROM ekpo
                 INTO TABLE lt_ekpo
                  FOR ALL ENTRIES IN it_mard
                  WHERE loekz EQ '' AND
                        matnr EQ it_mard-matnr AND
*                    lgort EQ it_mard-lgort AND
                        werks IN s_werks AND
                        elikz NE 'X'.
        ENDIF.
        IF lt_ekpo[] IS NOT INITIAL.

          SELECT ebeln
                 ebelp
                 bwart
                 menge
                 shkzg FROM ekbe
                      INTO TABLE lt_ekbe
                      FOR ALL ENTRIES IN lt_ekpo
                      WHERE ebeln EQ lt_ekpo-ebeln AND
                            ebelp EQ lt_ekpo-ebelp AND
                            bewtp EQ 'E'.

        ENDIF.

*      SELECT
*      ekpo~matnr
*      ekpo~werks
*      ekpo~lgort
*      ekpo~menge
*      INTO TABLE it_eban_qty
*      FROM /dbm/vbak_db
*      INNER JOIN
*      ekpo
*      ON /dbm/vbak_db~vbeln = ekpo~bednr
*      FOR ALL ENTRIES IN it_mard
*      WHERE
*      ekpo~matnr = it_mard-matnr
*      AND ekpo~werks = it_mard-werks.
**      AND ekpo~lgort = it_mard-lgort.
*
*      IF sy-subrc = 0.
*        LOOP AT it_eban_qty INTO ts_eban_qty.
*          READ TABLE it_eban_ord ASSIGNING <fs_eban>
*          WITH KEY matnr = ts_eban_qty-matnr
*          werks = ts_eban_qty-werks.
**          lgort = ts_eban_qty-lgort.
*          IF <fs_eban> IS ASSIGNED.
*            <fs_eban>-menge =   <fs_eban>-menge + ts_eban_qty-menge.
*          ELSE.
*            APPEND ts_eban_qty TO it_eban_ord.
*          ENDIF.
*          UNASSIGN <fs_eban>.
*        ENDLOOP.
*      ENDIF.

*      LOOP AT it_mard_blank INTO ls_mard_blank.
*        CLEAR : ls_mard_blank-lgort,
*                ls_mard_blank-labst,
*                ls_mard_blank-klabs.
*        APPEND ls_mard_blank TO it_mard.
*      ENDLOOP.

*    it_pre_out[] = it_mara[].
        DATA: fs_pre_out LIKE LINE OF it_pre_out.
        LOOP AT it_mard ASSIGNING FIELD-SYMBOL(<fs_mard>).
*        READ TABLE it_jah_plants INTO ls_jah_plants WITH KEY bwkey = <fs_mard>-werks.
*        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING <fs_mard> TO fs_pre_out.
*        COLLECT fs_pre_out INTO it_pre_out.
          APPEND fs_pre_out TO it_pre_out.
*        ENDIF.
        ENDLOOP.

*      PERFORM f_fill_histdata CHANGING it_pre_out.

        IF it_mard IS NOT INITIAL.

          SELECT rsnum
                 rspos
                 matnr
                 werks
                 lgort
                 bdmng
                 shkzg
                 FROM resb INTO TABLE lt_resb
                                 FOR ALL ENTRIES IN it_mard
                                 WHERE matnr EQ it_mard-matnr AND
                                       werks EQ it_mard-werks AND
*                                     lgort EQ it_mard-lgort AND
                                       kzear NE 'X'.

          IF lt_resb IS NOT INITIAL.

            LOOP AT lt_resb  INTO ls_resb .
              MOVE-CORRESPONDING ls_resb TO ls_resb_f.
              COLLECT ls_resb_f INTO lt_resb_f.
            ENDLOOP.

            LOOP AT lt_resb INTO ls_resb.
              READ TABLE lt_resb_r ASSIGNING <fs_resb_r>
                WITH KEY matnr = ls_resb-matnr
                         werks = ls_resb-werks.
*                       lgort = ls_resb-lgort.
              IF sy-subrc <> 0.
                APPEND INITIAL LINE TO lt_resb_r ASSIGNING <fs_resb_r>.
                MOVE-CORRESPONDING ls_resb TO <fs_resb_r>.
              ENDIF.
              IF ls_resb-shkzg = 'S'.
                <fs_resb_r>-rct_rsvd = <fs_resb_r>-rct_rsvd + ls_resb-bdmng.
              ELSE.
                <fs_resb_r>-resvd = <fs_resb_r>-resvd + ls_resb-bdmng.
              ENDIF.
            ENDLOOP.

          ENDIF.

        ENDIF.

        LOOP AT it_pre_out ASSIGNING FIELD-SYMBOL(<fs_pre_out>).

          READ TABLE it_mara INTO DATA(fs_mara) WITH KEY matnr = <fs_pre_out>-matnr
                                                         werks = <fs_pre_out>-werks.
          IF sy-subrc = 0.
*        MOVE-CORRESPONDING FS_MARA TO <FS_PRE_OUT>.
            <fs_pre_out>-umlmc = fs_mara-umlmc.
            <fs_pre_out>-mtart = fs_mara-mtart.
            <fs_pre_out>-maktx = fs_mara-maktx.
            <fs_pre_out>-matkl = fs_mara-matkl.
            <fs_pre_out>-maabc = fs_mara-maabc.
            <fs_pre_out>-safe_stk = fs_mara-safe_stk.
            <fs_pre_out>-reorder_point = fs_mara-reorder_point.
          ENDIF.
          <fs_pre_out>-meins = fs_mara-meins.
*        ls_lgort-lgort = <fs_pre_out>-lgort.

          LOOP AT lt_ekpo INTO ls_ekpo WHERE matnr = <fs_pre_out>-matnr AND
                                     werks = <fs_pre_out>-werks .
*                              AND lgort = <fs_pre_out>-lgort.
            <fs_pre_out>-open_po = <fs_pre_out>-open_po + ls_ekpo-menge.
            LOOP AT lt_ekbe INTO ls_ekbe WHERE ebeln EQ ls_ekpo-ebeln AND
                                               ebelp EQ ls_ekpo-ebelp.
              IF ls_ekbe-shkzg EQ 'S'.
                <fs_pre_out>-open_po = <fs_pre_out>-open_po - ls_ekbe-menge.
              ELSE.
                <fs_pre_out>-open_po = <fs_pre_out>-open_po + ls_ekbe-menge.
              ENDIF.

            ENDLOOP.


          ENDLOOP.

          READ TABLE it_eban_temp
                  INTO ts_eban_qty
                  WITH KEY matnr = <fs_pre_out>-matnr
                    werks = <fs_pre_out>-werks.
*                  lgort = <fs_pre_out>-lgort.
          IF sy-subrc = 0.
            <fs_pre_out>-mrp_qty = ts_eban_qty-menge.
          ENDIF.

*        READ TABLE it_eban_ord
*        INTO ts_eban_qty
*        WITH KEY matnr = <fs_pre_out>-matnr
*          werks = <fs_pre_out>-werks.
**          lgort = <fs_pre_out>-lgort.
*        IF sy-subrc = 0.
*          <fs_pre_out>-b_ord_qty = ts_eban_qty-menge.
*        ENDIF.


*        CALL FUNCTION '/DBM/P_MAT_AVAILABILITY'
*          EXPORTING
*            i_matnr = <fs_pre_out>-matnr
*            i_werks = <fs_pre_out>-werks
*            i_meins = fs_mara-meins
*            i_lgort = ls_lgort
**           I_REQ_DATE         =
**           I_CHECK_RULE       =
**           I_ATP_LOCK         =
*          IMPORTING
*            e_vrfmg = <fs_pre_out>-vrfmg
**         EXCEPTIONS
**           NOT_FOUND          = 1
**           OTHERS  = 2
*          .
*        IF sy-subrc <> 0.
** Implement suitable error handling here
*        ENDIF.

          READ TABLE lt_resb_f INTO ls_resb_f WITH KEY matnr = <fs_pre_out>-matnr werks = <fs_pre_out>-werks." lgort = <fs_pre_out>-lgort.
          IF sy-subrc EQ 0." AND ls_resb_f-lgort IS NOT INITIAL.
            <fs_pre_out>-vrfmg   =    <fs_pre_out>-labst - ls_resb_f-bdmng.
*        ELSEIF sy-subrc EQ 0 AND ls_resb_f-lgort IS INITIAL.
*          <fs_pre_out>-labst = ls_resb_f-bdmng.
          ELSEIF sy-subrc NE 0.
            <fs_pre_out>-vrfmg = <fs_pre_out>-labst.
          ENDIF.
          IF <fs_pre_out>-vrfmg LT 0.
            <fs_pre_out>-vrfmg = 0.
          ENDIF.

          READ TABLE lt_resb_r ASSIGNING <fs_resb_r>
            WITH KEY matnr = <fs_pre_out>-matnr
                     werks = <fs_pre_out>-werks.
*                   lgort = <fs_pre_out>-lgort.
          IF sy-subrc = 0.
            <fs_pre_out>-resvd = <fs_resb_r>-resvd.
            <fs_pre_out>-rct_rsvd = <fs_resb_r>-rct_rsvd.
          ENDIF.

*        READ TABLE it_jah_plants INTO ls_jah_plants WITH KEY bwkey = <fs_pre_out>-werks.
*        IF sy-subrc EQ 0.
*          <fs_pre_out>-bukrs = ls_jah_plants-bukrs.
*        ENDIF.
*
*        READ TABLE it_werks_info INTO DATA(fs_werks) WITH KEY werks = <fs_pre_out>-werks.
*        IF sy-subrc = 0.
*          <fs_pre_out>-bezei = fs_werks-bezei.
*        ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_MATN2_OUTPUT'
            EXPORTING
              input  = <fs_pre_out>-matnr
            IMPORTING
              output = <fs_pre_out>-matnr.


*          IF <fs_pre_out>-vrfmg IS INITIAL AND <fs_pre_out>-labst IS INITIAL AND <fs_pre_out>-open_po IS   INITIAL AND <fs_pre_out>-umlmc IS   INITIAL
*            AND <fs_pre_out>-safe_stk IS INITIAL AND <fs_pre_out>-curr_mnt IS INITIAL AND <fs_pre_out>-three_mnt IS INITIAL
*            AND <fs_pre_out>-twelve_mnt IS INITIAL AND <fs_pre_out>-rct_rsvd IS INITIAL AND <fs_pre_out>-resvd IS INITIAL .
*            CLEAR <fs_pre_out>.
*          ENDIF.

        ENDLOOP.

        DELETE it_pre_out WHERE matnr IS INITIAL.

*      SORT it_pre_out BY matnr bukrs bezei AS TEXT werks." lgort.
*      IF  it_pre_out IS INITIAL.
*        MESSAGE s899(m3) WITH 'No data found' DISPLAY LIKE 'E'.
*      ELSE.
*        PERFORM supply_data USING it_pre_out.
*      ENDIF.
*    ELSE.
*      MESSAGE s899(m3) WITH 'No data found' DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

*ELSE.

*    MESSAGE 'Selected Plant(s) not in JAHACO'  TYPE 'E'.
*ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_STOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_material_stock .

  IF gv_stock_matnr IS NOT INITIAL.
    IF gr_mmbe IS NOT BOUND.
      CREATE OBJECT gr_mmbe
        EXPORTING
          container_name              = 'GC_MMBE'   " Name of the Screen CustCtrl Name to Link Container To
          lifetime                    = 1
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          OTHERS                      = 6.
    ENDIF.

    IF gr_tree IS NOT BOUND.
      TRY.
          cl_salv_tree=>factory(
            EXPORTING
              r_container = gr_mmbe
            IMPORTING
              r_salv_tree = gr_tree
            CHANGING
              t_table      = it_mat_stock ).
        CATCH cx_salv_no_new_data_allowed cx_salv_error.
          EXIT.
      ENDTRY.

      DATA: settings TYPE REF TO cl_salv_tree_settings.

      settings = gr_tree->get_tree_settings( ).
      settings->set_hierarchy_header( TEXT-hd1 ).
      settings->set_hierarchy_tooltip( TEXT-ht1 ).
      settings->set_hierarchy_size( 30 ).

      DATA: title TYPE salv_de_tree_text.
      title = TEXT-005.
      settings->set_header( title ).
    ENDIF.

    PERFORM f_get_mat_stock.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_MAT_STOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_mat_stock .
  TYPES: BEGIN OF ty_eban,
           matnr TYPE eban-matnr,
           werks TYPE eban-werks,
           lgort TYPE eban-lgort,
           menge TYPE eban-menge,
         END OF ty_eban.
  TYPES : BEGIN OF ty_ekpo,
            ebeln TYPE ekpo-ebeln,
            ebelp TYPE ekpo-ebelp,
            matnr TYPE ekpo-matnr,
            menge TYPE ekpo-menge,
            werks TYPE ekpo-werks,
            lgort TYPE ekpo-lgort,
          END OF ty_ekpo.
  TYPES : BEGIN OF ty_ekbe,
            ebeln TYPE ekbe-ebeln,
            ebelp TYPE ekbe-ebelp,
            bwart TYPE ekbe-bwart,
            menge TYPE ekbe-menge,
            shkzg TYPE ekbe-shkzg,
          END OF ty_ekbe.

  TYPES: BEGIN OF ty_safety,
           matnr TYPE matnr,
           werks TYPE werks_d,
           eisbe TYPE eisbe,
         END OF ty_safety.

  DATA: lt_3mons_hist  TYPE zcl_parts_util=>tt_sales_hist_mseg,
        lt_currm_hist  TYPE  zcl_parts_util=>tt_sales_hist_mseg,
        lt_12mons_hist TYPE zcl_parts_util=>tt_sales_hist_mseg,
        lt_6mons_hist  TYPE zcl_parts_util=>tt_sales_hist_mseg,
        lt_safety      TYPE TABLE OF ty_safety.

  DATA: lt_mara       TYPE TABLE OF ty_mat_stock,
        lt_pre_out    TYPE TABLE OF ty_mat_stock,
        lt_eban       TYPE STANDARD TABLE OF ty_eban,
        lt_eban_temp  TYPE STANDARD TABLE OF ty_eban,
        lt_ekpo       TYPE STANDARD TABLE OF ty_ekpo,
        lt_eban_ekpo  TYPE STANDARD TABLE OF ty_eban,
        lt_eban_ord   TYPE TABLE OF ty_eban,
        lt_ekbe       TYPE STANDARD TABLE OF ty_ekbe,
        lt_material   TYPE TABLE OF matnr,
        lt_resb_mat   TYPE STANDARD TABLE OF ty_resb,
        lt_resb_mat_f TYPE HASHED TABLE OF ty_resb_f WITH UNIQUE KEY matnr werks, "lgort,
        lt_resb_mat_r TYPE TABLE OF ty_resb_r,
        ls_resb_mat_f TYPE ty_resb_f.

  SELECT werks, vkorg FROM t001w INTO TABLE @DATA(lt_vkorg)
    WHERE werks IN @s_werks[].
  IF sy-subrc = 0.
    DATA(lt_vkorg_read) = lt_vkorg.
    SORT lt_vkorg BY vkorg.
    DELETE ADJACENT DUPLICATES FROM lt_vkorg COMPARING vkorg.
    DELETE lt_vkorg WHERE vkorg IS INITIAL.
    IF lt_vkorg IS NOT INITIAL.
      SELECT
        a~werks ,
        a~name1 ,
        a~land1 ,
        a~regio ,
        b~bezei
      INTO TABLE @DATA(lt_werks_info)
      FROM t001w AS a
      INNER JOIN t005u AS b ON b~land1 = a~land1 AND b~bland = a~regio "#EC CI_BUFFJOIN
      FOR ALL ENTRIES IN @lt_vkorg
      WHERE a~vkorg = @lt_vkorg-vkorg
        AND b~spras = @sy-langu.
      IF lt_werks_info IS NOT INITIAL.
        SELECT a~matnr a~mtart a~extwg a~matkl a~meins b~werks b~maabc c~maktx
          FROM mara AS a
          INNER JOIN marc AS b ON b~matnr = a~matnr
          INNER JOIN makt AS c ON c~matnr = a~matnr
          INTO CORRESPONDING FIELDS OF TABLE lt_mara
          FOR ALL ENTRIES IN lt_werks_info
          WHERE a~matnr = gv_stock_matnr
          AND b~werks   =  lt_werks_info-werks
          AND c~spras   =  sy-langu.
        IF lt_mara IS NOT INITIAL.
          SORT lt_mara BY matnr werks.

          SELECT matnr werks lgort labst klabs FROM mard
            INTO CORRESPONDING FIELDS OF TABLE lt_pre_out
             FOR ALL ENTRIES IN lt_werks_info
              WHERE matnr = gv_stock_matnr
              AND werks =  lt_werks_info-werks.

          SELECT ekpo~matnr ekpo~werks ekpo~lgort ekpo~menge
            INTO TABLE lt_eban FROM eban
            INNER JOIN
            ekpo
            ON eban~banfn = ekpo~banfn
            FOR ALL ENTRIES IN lt_werks_info
            WHERE ekpo~loekz = ''
            AND ekpo~matnr = gv_stock_matnr
            AND ekpo~werks = lt_werks_info-werks
            AND eban~bsart = 'YMRP'.

          IF sy-subrc = 0.
            LOOP AT lt_eban INTO DATA(ts_eban).
              READ TABLE lt_eban_temp ASSIGNING FIELD-SYMBOL(<fs_eban>)
              WITH KEY matnr = ts_eban-matnr
              werks = ts_eban-werks
              lgort = ts_eban-lgort.
              IF <fs_eban> IS ASSIGNED.
                <fs_eban>-menge =   <fs_eban>-menge + ts_eban-menge.
              ELSE.
                APPEND ts_eban TO lt_eban_temp.
              ENDIF.
              UNASSIGN <fs_eban>.
            ENDLOOP.
          ENDIF.

          SELECT ebeln ebelp matnr menge werks lgort FROM ekpo
            INTO TABLE lt_ekpo
            FOR ALL ENTRIES IN lt_werks_info
            WHERE loekz EQ '' AND
                  matnr EQ gv_stock_matnr AND
                  werks =  lt_werks_info-werks AND
                  elikz NE 'X'.

          SELECT  ekpo~matnr ekpo~werks ekpo~lgort ekpo~menge
            INTO TABLE lt_eban_ekpo" internal table name changed as the same is used above
            FROM /dbe/vbak_db
            INNER JOIN ekpo
            ON /dbe/vbak_db~vbeln = ekpo~bednr
            FOR ALL ENTRIES IN lt_werks_info
            WHERE ekpo~loekz = ''
            AND ekpo~matnr = gv_stock_matnr
            AND ekpo~werks = lt_werks_info-werks.

          IF sy-subrc = 0.
            LOOP AT lt_eban_ekpo INTO ts_eban." changed it_eban to it_eban_ekpo
              READ TABLE lt_eban_ord ASSIGNING <fs_eban>
                WITH KEY matnr = ts_eban-matnr
                         werks = ts_eban-werks
                         lgort = ts_eban-lgort.
              IF <fs_eban> IS ASSIGNED.
                <fs_eban>-menge =   <fs_eban>-menge + ts_eban-menge.
              ELSE.
                APPEND ts_eban TO lt_eban_ord.
              ENDIF.
              UNASSIGN <fs_eban>.
            ENDLOOP.
          ENDIF.
          SELECT rsnum rspos matnr werks lgort bdmng shkzg
           FROM resb INTO TABLE lt_resb_mat
*                           FOR ALL ENTRIES IN it_pre_out
                           WHERE matnr EQ gv_stock_matnr AND
*                                 werks EQ it_pre_out-werks AND
*                                 lgort EQ it_pre_out-lgort AND
                                 kzear NE 'X'.

          IF lt_resb_mat IS NOT INITIAL.
            LOOP AT lt_resb_mat  INTO DATA(ls_resb_mat) .
              MOVE-CORRESPONDING ls_resb_mat TO ls_resb_mat_f.
              COLLECT ls_resb_mat_f INTO lt_resb_mat_f.
            ENDLOOP.

            LOOP AT lt_resb_mat INTO ls_resb_mat.
              READ TABLE lt_resb_mat_r ASSIGNING FIELD-SYMBOL(<fs_resb_mat_r>)
                WITH KEY matnr = ls_resb_mat-matnr
                         werks = ls_resb_mat-werks
                         lgort = ls_resb_mat-lgort.
              IF sy-subrc <> 0.
                APPEND INITIAL LINE TO lt_resb_mat_r ASSIGNING <fs_resb_mat_r>.
                MOVE-CORRESPONDING ls_resb_mat TO <fs_resb_mat_r>.
              ENDIF.
              IF ls_resb-shkzg = 'S'.
                <fs_resb_mat_r>-rct_rsvd = <fs_resb_mat_r>-rct_rsvd + ls_resb_mat-bdmng.
              ELSE.
                <fs_resb_mat_r>-resvd = <fs_resb_mat_r>-resvd + ls_resb_mat-bdmng.
              ENDIF.
            ENDLOOP.
          ENDIF.
          IF lt_ekpo[] IS NOT INITIAL.
            SELECT ebeln ebelp bwart menge shkzg FROM ekbe
                        INTO TABLE lt_ekbe
                        FOR ALL ENTRIES IN lt_ekpo
                        WHERE ebeln EQ lt_ekpo-ebeln AND
                              ebelp EQ lt_ekpo-ebelp AND
                              bewtp EQ 'E'.
          ENDIF.

          SORT lt_pre_out BY matnr werks lgort.
          APPEND LINES OF lt_pre_out TO lt_material.

          SORT lt_material .
          DELETE ADJACENT DUPLICATES FROM lt_material COMPARING ALL FIELDS.
          DELETE lt_material WHERE table_line IS INITIAL.
          IF lt_material IS NOT INITIAL.
            CALL METHOD zcl_parts_util=>get_sales_hist_mseg
              EXPORTING
                it_material   = lt_material
              IMPORTING
                et_sales_curr = lt_currm_hist
                et_sales_3    = lt_3mons_hist
                et_sales_6    = lt_6mons_hist
                et_sales_12   = lt_12mons_hist.
*..<< Reading safety stock >>
            SELECT matnr werks eisbe FROM marc
              INTO TABLE lt_safety
              WHERE matnr = gv_stock_matnr.

          ENDIF.

          LOOP AT lt_pre_out ASSIGNING FIELD-SYMBOL(<fs_output>).

            IF <fs_output>-lgort = 'P001'.
              READ TABLE lt_safety ASSIGNING FIELD-SYMBOL(<fs_safety>)
                WITH KEY matnr = <fs_output>-matnr werks = <fs_output>-werks.
              IF sy-subrc = 0.
                <fs_output>-safe_stk = <fs_safety>-eisbe.
              ENDIF.

              READ TABLE lt_currm_hist ASSIGNING FIELD-SYMBOL(<fs_hist>)
                WITH KEY matnr = <fs_output>-matnr werks = <fs_output>-werks.
              IF sy-subrc = 0.
                <fs_output>-curr_mnt = <fs_hist>-fkimg.
              ENDIF.

              READ TABLE lt_3mons_hist ASSIGNING <fs_hist>
                WITH KEY matnr = <fs_output>-matnr werks = <fs_output>-werks.
              IF sy-subrc = 0.
                <fs_output>-three_mnt = <fs_hist>-fkimg.
              ENDIF.

              READ TABLE lt_12mons_hist ASSIGNING <fs_hist>
                WITH KEY matnr = <fs_output>-matnr werks = <fs_output>-werks.
              IF sy-subrc = 0.
                <fs_output>-twelve_mnt = <fs_hist>-fkimg.
              ENDIF.
*** following lines pasted from a loop outside for combining 2 loops on the same internal table
            ENDIF.

            READ TABLE lt_mara INTO DATA(fs_mara) WITH KEY matnr = <fs_output>-matnr
                                                           werks = <fs_output>-werks.
            IF sy-subrc = 0.
*        MOVE-CORRESPONDING FS_MARA TO <fs_output>.
              <fs_output>-umlmc = fs_mara-umlmc.
              <fs_output>-mtart = fs_mara-mtart.
              <fs_output>-maktx = fs_mara-maktx.
              <fs_output>-matkl = fs_mara-matkl.
              <fs_output>-maabc = fs_mara-maabc.
              <fs_output>-meins = fs_mara-meins.
            ENDIF.

*            ls_lgort-lgort = <fs_output>-lgort.


            LOOP AT lt_ekpo INTO DATA(ls_ekpo) WHERE matnr = <fs_output>-matnr AND
                                               werks = <fs_output>-werks AND
                                                lgort = <fs_output>-lgort.
              <fs_output>-open_po = <fs_output>-open_po + ls_ekpo-menge.

              LOOP AT lt_ekbe INTO DATA(ls_ekbe) WHERE ebeln EQ ls_ekpo-ebeln AND
                                                 ebelp EQ ls_ekpo-ebelp.
                IF ls_ekbe-shkzg EQ 'S'.
                  <fs_output>-open_po = <fs_output>-open_po - ls_ekbe-menge.
                ELSE.
                  <fs_output>-open_po = <fs_output>-open_po + ls_ekbe-menge.
                ENDIF.

              ENDLOOP.


            ENDLOOP.

            READ TABLE lt_eban_temp
              INTO ts_eban
              WITH KEY  matnr = <fs_output>-matnr
                        werks = <fs_output>-werks
                        lgort = <fs_output>-lgort.
            IF sy-subrc = 0.
              <fs_output>-mrp_qty = ts_eban-menge.
            ENDIF.

            READ TABLE lt_eban_ord
            INTO ts_eban
            WITH KEY matnr = <fs_output>-matnr
              werks = <fs_output>-werks
              lgort = <fs_output>-lgort.
            IF sy-subrc = 0.
              <fs_output>-b_ord_qty = ts_eban-menge.
            ENDIF.

            READ TABLE lt_resb_mat_f INTO ls_resb_mat_f
              WITH KEY matnr = <fs_output>-matnr
                       werks = <fs_output>-werks.
*                       lgort = <fs_output>-lgort.
            IF sy-subrc EQ 0." AND ls_resb_f-lgort IS NOT INITIAL.
              <fs_output>-vrfmg = <fs_output>-labst - ls_resb_mat_f-bdmng.
*        ELSEIF sy-subrc EQ 0 AND ls_resb_f-lgort IS INITIAL.
*          <fs_output>-labst = ls_resb_f-bdmng.
            ELSEIF sy-subrc NE 0.
              <fs_output>-vrfmg = <fs_output>-labst.
            ENDIF.
            IF <fs_output>-vrfmg LT 0.
              <fs_output>-vrfmg = 0.
            ENDIF.

            READ TABLE lt_resb_mat_r ASSIGNING <fs_resb_mat_r>
              WITH KEY matnr = <fs_output>-matnr
                       werks = <fs_output>-werks
                       lgort = <fs_output>-lgort.
            IF sy-subrc = 0.
              <fs_output>-resvd = <fs_resb_mat_r>-resvd.
              <fs_output>-rct_rsvd = <fs_resb_mat_r>-rct_rsvd.
            ENDIF.

            READ TABLE lt_vkorg_read INTO DATA(ls_vkorg)
               WITH KEY werks = <fs_output>-werks.
            IF sy-subrc EQ 0.
              <fs_output>-bukrs = ls_vkorg-vkorg.
            ENDIF.

            READ TABLE lt_werks_info INTO DATA(fs_werks) WITH KEY werks = <fs_output>-werks.
            IF sy-subrc = 0.
              <fs_output>-bezei = fs_werks-bezei.
            ENDIF.

            CALL FUNCTION 'CONVERSION_EXIT_MATN2_OUTPUT'
              EXPORTING
                input  = <fs_output>-matnr
              IMPORTING
                output = <fs_output>-matnr.

            IF <fs_output>-vrfmg IS INITIAL AND <fs_output>-labst IS INITIAL AND <fs_output>-open_po IS   INITIAL AND <fs_output>-umlmc IS   INITIAL
              AND <fs_output>-safe_stk IS INITIAL AND <fs_output>-curr_mnt IS INITIAL AND <fs_output>-three_mnt IS INITIAL
              AND <fs_output>-twelve_mnt IS INITIAL AND <fs_output>-rct_rsvd IS INITIAL AND <fs_output>-resvd IS INITIAL .
              CLEAR <fs_output>.
            ENDIF.
          ENDLOOP.

          DELETE lt_pre_out WHERE matnr IS INITIAL.
          SORT lt_pre_out BY matnr bezei werks.
          IF lt_pre_out IS NOT INITIAL.
            DATA: nodes TYPE REF TO cl_salv_nodes.

*... §0 working with nodes
            nodes = gr_tree->get_nodes( ).
            nodes->delete_all( ).

            PERFORM supply_data USING lt_pre_out.

*            gr_tree->set_screen_status(
*              pfstatus      =  'YSALV_STANDARD'
*              report        =  sy-repid
*              set_functions =  gr_tree->c_functions_all ).

            DATA: lr_functions TYPE REF TO cl_salv_functions_tree.
            lr_functions = gr_tree->get_functions( ).
*  lr_functions->set_group_print( abap_false ).
            lr_functions->set_help( abap_false ).

*... set the columns technical
            DATA: lr_columns TYPE REF TO cl_salv_columns_tree.

            lr_columns = gr_tree->get_columns( ).
            lr_columns->set_optimize( gc_true ).

            PERFORM set_columns_technical USING lr_columns.
* aggregations
            PERFORM set_aggregations.

            PERFORM register_events.

            gr_tree->display( ).

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SUPPLY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_PRE_OUT  text
*----------------------------------------------------------------------*
FORM supply_data  USING lt_outtab TYPE STANDARD TABLE.
*... §2.3 supply the data to ALV, building the hierarchy

  DATA: ls_data TYPE ty_mat_stock.
  DATA: l_matnr_key   TYPE lvc_nkey,
        l_company_key TYPE lvc_nkey,
        l_regio_key   TYPE lvc_nkey,
        l_plant_key   TYPE lvc_nkey,
        l_stor_key    TYPE lvc_nkey.

  LOOP AT lt_outtab INTO ls_data.

    ON CHANGE OF ls_data-matnr.
      PERFORM add_matnr_line USING    ls_data
                                       ''
                              CHANGING l_matnr_key.
    ENDON.
*    ON CHANGE OF ls_data-bukrs.
*      PERFORM add_company_line USING    ls_data
*                                       l_matnr_key
*                              CHANGING l_company_key.
*    ENDON.

    ON CHANGE OF ls_data-bezei OR ls_data-matnr.
      PERFORM add_region_line USING    ls_data
                                       l_matnr_key
                              CHANGING l_regio_key.
    ENDON.

    ON CHANGE OF ls_data-werks OR ls_data-bezei OR ls_data-matnr..
      PERFORM add_plant_line USING    ls_data
                                       l_regio_key
                              CHANGING l_plant_key.
    ENDON.

    PERFORM add_complete_line USING  ls_data
                                     l_plant_key
                            CHANGING l_stor_key.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_MATNR_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_DATA  text
*      -->P_7137   text
*      <--P_L_MATNR_KEY  text
*----------------------------------------------------------------------*
FORM add_matnr_line  USING    p_ls_data TYPE ty_mat_stock
                               p_key
                      CHANGING p_matnr_key.

  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node,
        item  TYPE REF TO cl_salv_item,
        text  TYPE lvc_value.

*... §0 working with nodes
  nodes = gr_tree->get_nodes( ).

  TRY.
*  ... §0.1 add a new node
*  ... §0.3 set the data for the nes node
      node = nodes->add_node( related_node = p_key
                              data_row     = p_ls_data
                              relationship = cl_gui_column_tree=>relat_last_child ).
*   set text for this node
      text = p_ls_data-matnr.
      node->set_text( text ).
      node->set_collapsed_icon( '@A6@' ).
      node->set_expanded_icon( '@A6@' ).
      node->set_data_row( p_ls_data ).
      p_matnr_key = node->get_key( ).
    CATCH cx_salv_msg.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_REGION_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_DATA  text
*      -->P_L_MATNR_KEY  text
*      <--P_L_REGIO_KEY  text
*----------------------------------------------------------------------*
FORM add_region_line  USING    p_ls_data TYPE ty_mat_stock
                               p_company_key
                      CHANGING p_regio_key.

  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node,
        text  TYPE lvc_value.

  nodes = gr_tree->get_nodes( ).

  TRY.
      node = nodes->add_node( related_node = p_company_key
                              data_row     = p_ls_data
                              relationship = cl_gui_column_tree=>relat_last_child ).
*   set  text for this node
      text = p_ls_data-bezei.
      node->set_text( text ).
      node->set_collapsed_icon( '@PN@' ).
      node->set_expanded_icon( '@PN@' ).
      node->set_data_row( p_ls_data ).
      p_regio_key = node->get_key( ).
    CATCH cx_salv_msg.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_PLANT_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_DATA  text
*      -->P_L_REGIO_KEY  text
*      <--P_L_PLANT_KEY  text
*----------------------------------------------------------------------*
FORM add_plant_line  USING    p_ls_data TYPE ty_mat_stock
                               p_regio_key
                      CHANGING p_plant_key.

  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node,
        text  TYPE lvc_value.

  nodes = gr_tree->get_nodes( ).

  TRY.
      node = nodes->add_node( related_node = p_regio_key
                              data_row     = p_ls_data
                              relationship = cl_gui_column_tree=>relat_last_child ).
*   set text for this node
      text = p_ls_data-werks.
      node->set_text( text ).
      node->set_collapsed_icon( '@PN@' ).
      node->set_expanded_icon( '@PN@' ).
      node->set_data_row( p_ls_data ).
      p_plant_key = node->get_key( ).
    CATCH cx_salv_msg.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_COMPLETE_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_DATA  text
*      -->P_L_PLANT_KEY  text
*      <--P_L_STOR_KEY  text
*----------------------------------------------------------------------*
FORM add_complete_line  USING    p_ls_data TYPE ty_mat_stock
                                 p_plant_key
                        CHANGING p_l_last_key.

  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node,
        text  TYPE lvc_value.
  nodes = gr_tree->get_nodes( ).

  TRY.
      node = nodes->add_node( related_node = p_plant_key
                      data_row     = p_ls_data
                      relationship = cl_gui_column_tree=>relat_last_child ).
*   set text for this node
      text = p_ls_data-lgort.
      node->set_text( text ).
      node->set_collapsed_icon( '@AC@' ).
      node->set_expanded_icon( '@AC@' ).
      node->set_data_row( p_ls_data ).
      p_l_last_key = node->get_key( ).
    CATCH cx_salv_msg.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_COLUMNS_TECHNICAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LR_COLUMNS  text
*----------------------------------------------------------------------*
FORM set_columns_technical  USING ir_columns TYPE REF TO cl_salv_columns_tree.

* those columns which should not be seen by the user at all are set technical
  DATA: lr_column TYPE REF TO cl_salv_column.

  TRY.
      lr_column = ir_columns->get_column( 'MANDT' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'MATNR' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'WERKS' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'BUKRS' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'LGORT' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'BEZEI' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.


*SET TEXTS
  TRY.
      lr_column = ir_columns->get_column( 'VRFMG' ).
      lr_column->set_tooltip('Available Quantity').
      lr_column->set_long_text('Available Quantity').
      lr_column->set_medium_text('Available Quantity').
      lr_column->set_short_text('Avail Qty').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.


*SET TEXTS
  TRY.
      lr_column = ir_columns->get_column( 'LABST' ).
      lr_column->set_tooltip('On Hand Stock').
      lr_column->set_long_text('On Hand Stock').
      lr_column->set_medium_text('On Hand Stock').
      lr_column->set_short_text('On Hand').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.


  TRY.
      lr_column = ir_columns->get_column( 'RESVD' ).
      lr_column->set_tooltip('Open Orders').
      lr_column->set_long_text('Open Orders').
      lr_column->set_medium_text('Open Orders').
      lr_column->set_short_text('Open Ord').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'RCT_RSVD' ).
      lr_column->set_tooltip('Returns').
      lr_column->set_long_text('Returns').
      lr_column->set_medium_text('Rcturns').
      lr_column->set_short_text('Returns.').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'OPEN_PO' ).
      lr_column->set_tooltip('On Order Stock').
      lr_column->set_long_text('On Order Stock').
      lr_column->set_medium_text('On Order Stock').
      lr_column->set_short_text('OnOrdrStck').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.


  TRY.
      lr_column = ir_columns->get_column( 'KLABS' ).
      lr_column->set_tooltip('Consignment Order').
      lr_column->set_long_text('Consignment Order').
      lr_column->set_medium_text('Consignment Order').
      lr_column->set_short_text('Cons.Ordr').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.


  TRY.
      lr_column = ir_columns->get_column( 'UMLMC' ).
      lr_column->set_tooltip('Stock transfer (Plant)').
      lr_column->set_long_text('Stock transfer (Plant)').
      lr_column->set_medium_text('Stck trnsfr(Plant)').
      lr_column->set_short_text('StckTrnsfr').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'SAFE_STK' ).
      lr_column->set_tooltip('Safety Stock').
      lr_column->set_long_text('Safety Stock').
      lr_column->set_medium_text('Safety Stock').
      lr_column->set_short_text('Sfty stk').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'CURR_MNT' ).
      lr_column->set_tooltip('Sold this month').
      lr_column->set_long_text('Sold this month').
      lr_column->set_medium_text('Sold(curr)').
      lr_column->set_short_text('Sold(curr)').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'THREE_MNT' ).
      lr_column->set_tooltip('Sold(3 mon)').
      lr_column->set_long_text('Sold(3 mon)').
      lr_column->set_medium_text('Sold(3 mon)').
      lr_column->set_short_text('Sold(3)').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'TWELVE_MNT' ).
      lr_column->set_tooltip('Sold(12 mon)').
      lr_column->set_long_text('Sold(12 mon)').
      lr_column->set_medium_text('Sold(12 mon)').
      lr_column->set_short_text('Sold(12)').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'MRP_QTY' ).
      lr_column->set_tooltip('MRP Qty').
      lr_column->set_long_text('MRP Qty').
      lr_column->set_medium_text('MRP Qty').
      lr_column->set_short_text('MRP Qty').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'B_ORD_QTY' ).
      lr_column->set_tooltip('Cust Back Ord').
      lr_column->set_long_text('Back Ord').
      lr_column->set_medium_text('Back Ord').
      lr_column->set_short_text('Back Ord').
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_AGGREGATIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_aggregations .

*... §4.3 Set some aggregations
  DATA:
  lr_aggregations TYPE REF TO cl_salv_aggregations.

  lr_aggregations = gr_tree->get_aggregations( ).

  lr_aggregations->clear( ).

  TRY.

      lr_aggregations->add_aggregation( columnname  = 'VRFMG' ).  "Defaultaggregation ist Summe
      lr_aggregations->add_aggregation( columnname  = 'LABST' ).  "Defaultaggregation ist Summe
      lr_aggregations->add_aggregation( columnname  = 'RESVD' ).  "Defaultaggregation ist Summe
      lr_aggregations->add_aggregation( columnname  = 'RCT_RSVD' ).  "Defaultaggregation ist Summe
      lr_aggregations->add_aggregation( columnname  = 'OPEN_PO' ).  "Defaultaggregation ist Summe
*      lr_aggregations->add_aggregation( columnname  = 'KLABS' ).  "Defaultaggregation ist Summe
      lr_aggregations->add_aggregation( columnname  = 'UMLMC' ).  "Defaultaggregation ist Summe
      lr_aggregations->add_aggregation( columnname  = 'SAFE_STK' ).  "Safety Stock
      lr_aggregations->add_aggregation( columnname  = 'CURR_MNT' ).  "Current month
      lr_aggregations->add_aggregation( columnname  = 'THREE_MNT' ).  "Three month
      lr_aggregations->add_aggregation( columnname  = 'TWELVE_MNT' ).  "Twelve month
      lr_aggregations->add_aggregation( columnname  = 'MRP_QTY' ).  "MRP Quantity
      lr_aggregations->add_aggregation( columnname  = 'B_ORD_QTY' ).  "Back Order
*      lr_aggregations->add_aggregation( columnname  = 'PRICE'
*                                        aggregation = if_salv_c_aggregation=>maximum ).
    CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing. "#EC NO_HANDLER
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REGISTER_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM register_events .
*... §4 register to the events of cl_salv_table
  DATA: lr_events TYPE REF TO cl_salv_events_tree.

  lr_events = gr_tree->get_event( ).

  CREATE OBJECT gr_events.

*... §4.1 register to the event USER_COMMAND
  SET HANDLER gr_events->on_user_command FOR lr_events.

  SET HANDLER gr_events->on_before_user_command FOR lr_events.

  SET HANDLER gr_events->on_after_user_command FOR lr_events.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_TO_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_to_excel.
  CONSTANTS:lc_xlspace     TYPE c VALUE ''. "hexa value for this field should be 0030

  DATA: lv_level TYPE i,

        lv_xlsx  TYPE xstring,

        lt_table TYPE REF TO data,
        lr_table TYPE REF TO cl_salv_table,
        lr_data  TYPE REF TO data.

  FIELD-SYMBOLS: <data>  TYPE any,

                 <table> TYPE STANDARD TABLE,

                 <str>   TYPE any.
  DATA:lt_nodes TYPE salv_t_nodes,
       lr_node  TYPE REF TO cl_salv_node,
       ls_node  LIKE LINE OF lt_nodes.

  TRY." added |07.03.2019
      lt_nodes = gr_tree->get_nodes( )->get_all_nodes( ).

    CATCH cx_salv_msg." added
  ENDTRY." added
  LOOP AT lt_nodes INTO ls_node.
    lr_node = ls_node-node.
    CLEAR lv_level.
    DO.
      TRY.
          lr_node = lr_node->get_parent( ).
          ADD 1 TO lv_level.
        CATCH cx_salv_msg.
          EXIT.
      ENDTRY.

    ENDDO.

    lr_data = ls_node-node->get_data_row( ).

    ASSIGN lr_data->* TO <data>.

    IF <table> IS NOT ASSIGNED.

      CREATE DATA lt_table LIKE STANDARD TABLE OF <data>.

      ASSIGN lt_table->* TO <table>.

    ENDIF.

    ASSIGN COMPONENT 1 OF STRUCTURE <data> TO <str>.

    SUBTRACT 1 FROM lv_level.

    DO lv_level TIMES.

      CONCATENATE lc_xlspace <str> INTO <str>.

    ENDDO.

    APPEND <data> TO <table>.

  ENDLOOP.


  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lr_table
        CHANGING
          t_table = <table> ).
    CATCH cx_salv_msg." added| taha|07.03.2019
  ENDTRY.
*
*  lr_table->display( ).

  lv_xlsx = lr_table->to_xml( if_salv_bs_xml=>c_type_xlsx ).



  DATA: lr_zip         TYPE REF TO cl_abap_zip,
        lr_xlnode      TYPE REF TO if_ixml_node,
        lr_xldimension TYPE REF TO if_ixml_node,
        lr_xlsheetpr   TYPE REF TO if_ixml_element,
        lr_xloutlinepr TYPE REF TO if_ixml_element,
        lv_file        TYPE xstring,
        lr_file        TYPE REF TO cl_xml_document,
        lr_xlrows      TYPE REF TO if_ixml_node_list,
        lr_xlrow       TYPE REF TO if_ixml_element,
        lr_xlformat    TYPE REF TO if_ixml_element,
        lr_xlworksheet TYPE REF TO if_ixml_element,
        lv_tabix       TYPE i,
        lv_maxlevel    TYPE i,
        lv_levels      TYPE string.
  CREATE OBJECT lr_zip.
  lr_zip->load( lv_xlsx ).
*Get Worksheet XML file
  lr_zip->get( EXPORTING name = 'xl/worksheets/sheet1.xml'
               IMPORTING content = lv_file ).
  CREATE OBJECT lr_file.
  lr_file->parse_xstring( lv_file ).
*Row elements are under SheetData
  lr_xlnode = lr_file->find_node( 'sheetData' ).
  lr_xlrows = lr_xlnode->get_children( ).
  DO lr_xlrows->get_length( ) TIMES.
    lv_tabix = sy-index - 1.
    lr_xlrow ?= lr_xlrows->get_item( lv_tabix ).
*Find the same node in the SALV Tree object
    READ TABLE lt_nodes INTO ls_node INDEX lv_tabix.
    IF sy-subrc EQ 0.
      lr_node = ls_node-node.
*Find the level of the node
      CLEAR lv_level.
      DO.
        TRY.
            lr_node = lr_node->get_parent( ).
            ADD 1 TO lv_level.
          CATCH cx_salv_msg.
            EXIT.
        ENDTRY.
      ENDDO.
      SUBTRACT 1 FROM lv_level.
      IF lv_level NE 0.
        lv_levels = lv_level.
        IF lv_level > lv_maxlevel.
          lv_maxlevel = lv_level.
        ENDIF.
        CONDENSE lv_levels.
*Assign the level to row
        lr_xlrow->set_attribute( name = 'outlinelevel' value = lv_levels ).
        lr_xlrow->set_attribute( name = 'hidden' value = 'true' ).
      ENDIF.
    ENDIF.
  ENDDO.
*Set maximum levels used in the sheet
  lv_levels = lv_maxlevel.
  CONDENSE lv_levels.
  lr_xlformat ?= lr_file->find_node( 'sheetFormatPr' ).
  lr_xlformat->set_attribute( name = 'outlineLevelRow' value = lv_levels ).
*Create new element in the XML file
  lr_xlworksheet ?= lr_file->find_node( 'worksheet' ).
  lr_xldimension ?= lr_file->find_node( 'dimension' ).
  lr_xlsheetpr = cl_ixml=>create( )->create_document( )->create_element( name = 'sheetPr' ).
  lr_xloutlinepr = cl_ixml=>create( )->create_document( )->create_element( name = 'outlinePr' ).
  lr_xlsheetpr->if_ixml_node~append_child( lr_xloutlinepr ).
  lr_xloutlinepr->set_attribute( name = 'summaryBelow' value = 'false' ).
  lr_xlworksheet->if_ixml_node~insert_child( new_child = lr_xlsheetpr ref_child = lr_xldimension ).
*Create Xstring file for the XML, and add it to Excel Zip file
  lr_file->render_2_xstring( IMPORTING stream = lv_file ).
  lr_zip->delete( EXPORTING name = 'xl/worksheets/sheet1.xml' ).
  lr_zip->add( EXPORTING name = 'xl/worksheets/sheet1.xml'
  content = lv_file ).
  lv_xlsx = lr_zip->save( ).

  PERFORM download_file
              USING
                 lv_xlsx.
*                 'C:\Users\E002640\Desktop\excelfile'.

ENDFORM.

FORM download_file USING pv_xlsx TYPE xstring.

  DATA lv_size              TYPE i.
  DATA lt_bintab            TYPE solix_tab.

* Convert to binary
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = pv_xlsx
    IMPORTING
      output_length = lv_size
    TABLES
      binary_tab    = lt_bintab.

* Save file
  IF lt_bintab IS INITIAL.
    EXIT.
  ENDIF.
  DATA: filename TYPE string,
        path     TYPE string,
        fullpath TYPE string.
  cl_gui_frontend_services=>file_save_dialog(
*    EXPORTING
*      window_title              = window_title    " Window Title
*      default_extension         = cl_gui_frontend_services-filetype_excel
*      default_file_name         = default_file_name    " Default File Name
*      with_encoding             = with_encoding
*      file_filter               = file_filter    " File Type Filter Table
*      initial_directory         = initial_directory    " Initial Directory
*      prompt_on_overwrite       = prompt_on_overwrite
    CHANGING
      filename                  = filename    " File Name to Save
      path                      = path    " Path to File
      fullpath                  = fullpath    " Path + File Name
*      user_action               = user_action    " User Action (C Class Const ACTION_OK, ACTION_OVERWRITE etc)
*      file_encoding             = file_encoding
*    EXCEPTIONS
*      cntl_error                = 1
*      error_no_gui              = 2
*      not_supported_by_gui      = 3
*      invalid_default_file_name = 4
  ).
  IF sy-subrc <> 0.
*   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  cl_gui_frontend_services=>gui_download(
  EXPORTING
  bin_filesize              = lv_size
  filename                  = fullpath
  filetype                  = 'BIN'
  CHANGING
  data_tab                  = lt_bintab
  EXCEPTIONS
  file_write_error          = 1
  no_batch                  = 2
  gui_refuse_filetransfer   = 3
  invalid_type              = 4
  no_authority              = 5
  unknown_error             = 6
  header_not_allowed        = 7
  separator_not_allowed     = 8
  filesize_not_allowed      = 9
  header_too_long           = 10
  dp_error_create           = 11
  dp_error_send             = 12
  dp_error_write            = 13
  unknown_dp_error          = 14
  access_denied             = 15
  dp_out_of_memory          = 16
  disk_full                 = 17
  dp_timeout                = 18
  file_not_found            = 19
  dataprovider_exception    = 20
  control_flush_error       = 21
  not_supported_by_gui      = 22
  error_no_gui              = 23
  OTHERS                    = 24
  ).

  IF sy-subrc <> 0.
*    MESSAGE ID sy–msgid TYPE sy–msgty NUMBER sy–msgno
*    WITH sy–msgv1 sy–msgv2 sy–msgv3 sy–msgv4 .
  ENDIF.

ENDFORM.

FORM show_function_info USING i_function TYPE salv_de_function
  i_text     TYPE string.

  DATA: l_string TYPE string.

  CONCATENATE i_text i_function INTO l_string SEPARATED BY space.

  MESSAGE i000(0k) WITH l_string.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DELETE_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_delete_pr .
  DATA: lt_row_ids    TYPE lvc_t_roid,
        lw_row_id     TYPE lvc_s_roid,
        lv_requistion TYPE bapieban-preq_no,
        lt_pr_item    TYPE TABLE OF bapieband,
        ls_pr_item    TYPE bapieband,
        ls_return     TYPE bapireturn,
        lt_return     TYPE TABLE OF bapireturn,
        lt_all        TYPE TABLE OF bapireturn.

  FIELD-SYMBOLS: <fs_eban>  TYPE ty_eban,
                 <fs_style> TYPE lvc_s_styl.

  CALL METHOD gr_prl_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row_ids.

  IF lt_row_ids IS INITIAL.
    MESSAGE TEXT-006 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT lt_row_ids INTO lw_row_id.
    READ TABLE it_eban ASSIGNING <fs_eban>
      INDEX lw_row_id-row_id.
    IF sy-subrc = 0.
      CLEAR: lt_pr_item, lt_return.
      lv_requistion = <fs_eban>-banfn.
      ls_pr_item-preq_item = <fs_eban>-bnfpo.
      ls_pr_item-delete_ind = 'X'.
      APPEND ls_pr_item TO lt_pr_item.
      CALL FUNCTION 'BAPI_REQUISITION_DELETE'
        EXPORTING
          number                      = lv_requistion    " Purchase Requisition Number
        TABLES
          requisition_items_to_delete = lt_pr_item    " Items to be Deleted/Closed
          return                      = lt_return.    " Return Messages
      LOOP AT lt_return INTO ls_return WHERE type = 'E' OR type = 'A'.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        APPEND LINES OF lt_return TO lt_all.
      ELSE.
        ls_return-type = 'S'.
        CONCATENATE
        'PR' <fs_eban>-banfn 'Item' <fs_eban>-bnfpo 'is deleted'
        INTO ls_return-message SEPARATED BY space.
        APPEND ls_return TO lt_all.
        CLEAR: <fs_eban>.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF lt_all IS NOT INITIAL.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_structure_name      = 'BAPIRETURN'
        i_grid_title          = 'Messages'
        i_screen_start_column = 50
        i_screen_start_line   = 15
        i_screen_end_column   = 150
        i_screen_end_line     = 40
*       ES_EXIT_CAUSED_BY_USER            =
      TABLES
        t_outtab              = lt_all.
  ENDIF.

  DELETE it_eban WHERE bnfpo IS INITIAL.

  it_eban_prev = it_eban.
  PERFORM f_display_pr .
ENDFORM.

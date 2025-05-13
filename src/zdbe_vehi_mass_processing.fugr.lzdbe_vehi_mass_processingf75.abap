*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF75 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREPARE_ALV_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_alv_data .

  CONSTANTS:
    lc_po_status_success  TYPE c VALUE 'S',
    lc_gr_status_success  TYPE c VALUE 'S',
    lc_gr_status_pending  TYPE c VALUE 'P',
    lc_gr_status_cancled  TYPE c VALUE 'C',
    lc_inv_status_initial TYPE c VALUE 'N',
    lc_inv_status_pending TYPE c VALUE 'P',
    lc_inv_status_cancled TYPE c VALUE 'C'.

  DATA:
    ls_gr_create         LIKE LINE OF gt_gr_create,
    ls_gr_cancel         LIKE LINE OF gt_gr_cancel,
    ls_inv_cancel        LIKE LINE OF gt_inv_cancel,
    ls_ac_post           LIKE LINE OF gt_ac_post,
    ls_ac_cancel         TYPE ty_addcost_cancel,
    ls_vlcactdata_head   TYPE vlcactdata_head_s,
    ls_vlcactdata_item   TYPE vlcactdata_item_s,
    porders_lt           LIKE vlcporder OCCURS 0,
    porders_ls           LIKE vlcporder,
    lt_apo_po            TYPE /dbe/vlc_ac_po_t,
    ls_apo_po            TYPE /dbe/vlc_ac_po,
    vguids_lt            TYPE TABLE OF vlcguid,
    lt_vguids            TYPE TABLE OF vlcguid WITH HEADER LINE,
    lt_adc_status        TYPE /dbe/vlc_adc_status_t,
    ls_adc_status        TYPE /dbe/vlc_adc_status_s,
    lo_buf               TYPE REF TO /dbe/cl_veh_buf,
    lt_bob               TYPE /dbe/t_veh_bob,
    ls_bob               LIKE LINE OF lt_bob,
    lo_veh               TYPE REF TO /dbe/cl_veh_dbmvehicle,
    lr_vlcactdata_head_s TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_head   TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item   TYPE REF TO vlcactdata_item_s,
    lr_vlcdiavehi        TYPE REF TO vlcdiavehi.

  IF sy-ucomm NE 'CG_ALL'.

    lo_buf = /dbe/cl_veh_buf=>get_instance( ).
    lt_bob = lo_buf->get_all( ).

    REFRESH: gt_gr_create, gt_gr_cancel ,gt_inv_cancel, gt_ac_post.

    IF gv_ok_code NE  gc_enter_fcode.
      REFRESH gt_ac_cancel.
    ENDIF.

    IF go_ac_create IS NOT INITIAL.
      CALL METHOD go_ac_create->refresh_table_display( ).
    ENDIF.

    IF go_ac_cancel IS NOT INITIAL.
      CALL METHOD go_ac_cancel->refresh_table_display( ).
    ENDIF.

    IF gv_action NE /dbe/if_vms_constants=>c_qapc AND gv_action NE /dbe/if_vms_constants=>c_qacc
       AND gv_action NE /dbe/if_vms_constants=>c_qagc
       AND gv_action NE /dbe/if_vms_constants=>c_qaic.
      LOOP AT lt_bob INTO ls_bob.                           "2066130
        lo_veh ?= ls_bob-bobref.
        TRY.
            lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.

        TRY.
            lr_vlcactdata_item ?=  lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.

        IF gv_action = /dbe/if_vms_constants=>c_qgrb.

          MOVE-CORRESPONDING lr_vlcactdata_head->* TO ls_gr_create.
          MOVE lr_vlcactdata_item->*-vguid TO ls_gr_create-vguid.
          MOVE lr_vlcactdata_item->*-vhcle TO ls_gr_create-vhcle.
          MOVE lr_vlcactdata_item->*-werks TO ls_gr_create-werks.
          MOVE lr_vlcactdata_head->*-lgort TO ls_gr_create-lgort.
          MOVE lr_vlcactdata_head->*-lfsnr TO ls_gr_create-lfsnr.
          MOVE lr_vlcactdata_head->*-frbnr TO ls_gr_create-frbnr.
          MOVE lr_vlcactdata_head->*-ebeln TO ls_gr_create-po_number.
          MOVE lr_vlcactdata_item->*-po_number TO ls_gr_create-po_number.
          MOVE lr_vlcactdata_item->*-po_item TO ls_gr_create-po_item.

          APPEND ls_gr_create-vguid TO vguids_lt.
          CALL FUNCTION 'VELO14_READ_PORDERS_WITH_VGUID'
            EXPORTING
              no_xgore         = 'X'
              latest_iv        = 'X'
            TABLES
              vlcguid_it       = vguids_lt
*             vlcactdoctype_it = actdoctype_lt
              vlcporder_et     = porders_lt
            EXCEPTIONS
              no_data_received = 1
              nothing_found    = 2
              OTHERS           = 3.
          LOOP AT porders_lt INTO porders_ls.
            ls_gr_create-po_number = porders_ls-ebeln.
            ls_gr_create-po_item = porders_ls-ebelp.
          ENDLOOP.
          APPEND ls_gr_create TO gt_gr_create.

        ENDIF.

        IF gv_action = /dbe/if_vms_constants=>c_qgcb.

          MOVE-CORRESPONDING lr_vlcactdata_head->* TO ls_gr_cancel.
          MOVE lr_vlcactdata_item->*-vguid TO ls_gr_cancel-vguid.
          MOVE lr_vlcactdata_item->*-vhcle TO ls_gr_cancel-vhcle.
          MOVE lr_vlcactdata_item->*-werks TO ls_gr_cancel-werks.
          MOVE lr_vlcactdata_item->*-ref_doc_it TO ls_gr_cancel-ref_doc_it.
          APPEND ls_gr_cancel TO gt_gr_cancel.

        ENDIF.

        IF gv_action = /dbe/if_vms_constants=>c_qadc OR
          gv_action = /dbe/if_vms_constants=>c_qapo OR
          gv_action = /dbe/if_vms_constants=>c_qagr OR
          gv_action = /dbe/if_vms_constants=>c_qain .

          MOVE-CORRESPONDING lr_vlcactdata_head->* TO ls_ac_post.
          MOVE lr_vlcactdata_item->*-vguid TO ls_ac_post-vguid.
          MOVE lr_vlcactdata_item->*-vhcle TO ls_ac_post-vhcle.
          MOVE lr_vlcactdata_head->*-lifnr TO ls_ac_post-lifnr.
*            MOVE lr_vlcactdata_head->*-/DBE/srvc_vendor TO ls_ac_post-lifnr.
          MOVE lr_vlcactdata_item->*-/dbe/ext_service_lifnr TO ls_ac_post-ext_service_lifnr. "
          MOVE lr_vlcactdata_item->*-/dbe/coaufnr TO ls_ac_post-/dbe/coaufnr.
          MOVE lr_vlcactdata_head->*-/dbe/ext_service_type TO ls_ac_post-ext_service_type.
          MOVE lr_vlcactdata_head->*-tax_code TO ls_ac_post-serv_tax_code.
          MOVE lr_vlcactdata_head->*-bldat TO ls_ac_post-serv_bldat.
          MOVE lr_vlcactdata_head->*-budat TO ls_ac_post-serv_budat.
          MOVE lr_vlcactdata_head->*-doc_date TO ls_ac_post-serv_bldat.
          MOVE lr_vlcactdata_head->*-pstng_date TO ls_ac_post-serv_budat.
          MOVE lr_vlcactdata_head->*-/dbe/ext_srv_netamt TO ls_ac_post-serv_netamt.
          IF  gv_action = /dbe/if_vms_constants=>c_qagr OR   gv_action = /dbe/if_vms_constants=>c_qain.
            MOVE lr_vlcactdata_item->*-/dbe/cost TO ls_ac_post-cost.
            MOVE lr_vlcactdata_item->*-item_currency TO ls_ac_post-currency.
          ENDIF.
          MOVE lr_vlcactdata_item->*-po_number TO ls_ac_post-po_number.
          MOVE lr_vlcactdata_item->*-po_item TO ls_ac_post-po_item.
          MOVE lr_vlcactdata_item->*-ref_doc TO ls_ac_post-ref_doc.
          MOVE lr_vlcactdata_item->*-ref_doc_year TO ls_ac_post-ref_doc_year.
          MOVE lr_vlcactdata_item->*-/dbe/serv_tax_code TO ls_ac_post-serv_tax_code.
          MOVE lr_vlcactdata_item->*-/dbe/serv_netamt TO ls_ac_post-serv_netamt.
          MOVE lr_vlcactdata_item->*-/dbe/fi_belnr TO ls_ac_post-inv_number.
          MOVE lr_vlcactdata_item->*-/dbe/fi_gjahr TO ls_ac_post-inv_year.

          IF gt_vsresult IS INITIAL.
            TRY.
                lr_vlcdiavehi ?=  lo_veh->get_data_com( lo_veh->gc_vlcdiavehi ).
                MOVE lr_vlcdiavehi->*-matnrtxt TO ls_ac_post-matnrtxt.
              CATCH cx_root.
                CLEAR ls_ac_post-matnrtxt.
            ENDTRY.
          ELSE.
            LOOP AT gt_vsresult INTO gs_vsresult WHERE vguid = ls_ac_post-vguid.
              ls_ac_post-matnrtxt = gs_vsresult-matnrtxt.
            ENDLOOP.
          ENDIF.
          APPEND ls_ac_post-vguid TO lt_vguids.
        ENDIF.

        CLEAR lt_apo_po.
        IF gv_action = /dbe/if_vms_constants=>c_qain.
          CLEAR lt_adc_status.
          ls_adc_status-po_status = lc_po_status_success.
          ls_adc_status-gr_status = lc_gr_status_success.
          ls_adc_status-inv_status = lc_inv_status_pending.
          APPEND ls_adc_status TO lt_adc_status.

          ls_adc_status-po_status = lc_po_status_success.
          ls_adc_status-gr_status = lc_gr_status_success.
          ls_adc_status-inv_status = lc_inv_status_cancled.
          APPEND ls_adc_status TO lt_adc_status.

          CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
            EXPORTING
              it_adc_status   = lt_adc_status
            TABLES
              vlcguid_it      = lt_vguids
              vlcapo_et       = lt_apo_po
            EXCEPTIONS
              no_record_found = 1
              OTHERS          = 2.
          IF sy-subrc NE 0.
* Implement suitable error handling here
          ENDIF.

        ELSEIF gv_action = /dbe/if_vms_constants=>c_qagr.
          CLEAR lt_adc_status.
          ls_adc_status-po_status = lc_po_status_success.
          ls_adc_status-gr_status = lc_gr_status_pending.
          ls_adc_status-inv_status = lc_inv_status_initial.
          APPEND ls_adc_status TO lt_adc_status.

          ls_adc_status-po_status = lc_po_status_success.
          ls_adc_status-gr_status = lc_gr_status_cancled.
          ls_adc_status-inv_status = lc_inv_status_cancled.
          APPEND ls_adc_status TO lt_adc_status.

          ls_adc_status-po_status = lc_po_status_success.
          ls_adc_status-gr_status = lc_gr_status_cancled.
          ls_adc_status-inv_status = lc_inv_status_pending.
          APPEND ls_adc_status TO lt_adc_status.

          CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
            EXPORTING
              it_adc_status   = lt_adc_status
            TABLES
              vlcguid_it      = lt_vguids
              vlcapo_et       = lt_apo_po
            EXCEPTIONS
              no_record_found = 1
              OTHERS          = 2.
          IF sy-subrc NE 0.
* Implement suitable error handling here
          ENDIF.
        ELSEIF
          gv_action = /dbe/if_vms_constants=>c_qagc.
          CALL FUNCTION '/DBE/VMASS_GET_ADC_ITEMS'
            EXPORTING
              iv_document_type = 3                  "N:2348422
            TABLES
              it_vlcguid       = lt_vguids
              et_vlcapo        = lt_apo_po
            EXCEPTIONS
              no_record_found  = 1
              OTHERS           = 2.
          IF sy-subrc NE 0.
* Implement suitable error handling here
          ENDIF.
        ENDIF.
        IF gv_action EQ /dbe/if_vms_constants=>c_qadc OR gv_action EQ /dbe/if_vms_constants=>c_qapo
          OR gv_action EQ /dbe/if_vms_constants=>c_qagr OR gv_action EQ /dbe/if_vms_constants=>c_qain.
          APPEND ls_ac_post TO gt_ac_post.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
  IF gv_action = /dbe/if_vms_constants=>c_qirb.

    CLEAR gs_selection.
    LOOP AT lt_bob INTO ls_bob.
*      READ TABLE gt_vresult_selection INTO gs_selection WITH KEY guid = ls_bob-vguid.
*      IF sy-subrc = 0.
      lo_veh ?= ls_bob-bobref.
*      IF lo_veh->mv_action  = gv_action.
      TRY.
          lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
        CATCH /dbe/cx_veh_layer_not_found .
      ENDTRY.

      TRY.
          lr_vlcactdata_item ?=  lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
        CATCH /dbe/cx_veh_layer_not_found .
      ENDTRY.
      MOVE-CORRESPONDING lr_vlcactdata_head->* TO ls_inv_cancel.
      MOVE lr_vlcactdata_item->*-vguid TO ls_inv_cancel-vguid.
      MOVE lr_vlcactdata_item->*-vhcle TO ls_inv_cancel-vhcle.
      MOVE lr_vlcactdata_item->*-werks TO ls_inv_cancel-werks.
      APPEND ls_inv_cancel TO gt_inv_cancel.
*      ENDIF.
    ENDLOOP.
  ENDIF.

  IF gv_action = /dbe/if_vms_constants=>c_qapc OR gv_action EQ /dbe/if_vms_constants=>c_qaic
    OR gv_action EQ /dbe/if_vms_constants=>c_qagc OR gv_action EQ /dbe/if_vms_constants=>c_qacc.
    IF gv_ok_code NE  gc_enter_fcode.
      REFRESH gt_ac_cancel.

*    CLEAR gs_selection.
      LOOP AT lt_bob INTO ls_bob.
        lo_veh ?= ls_bob-bobref.
        TRY.
            lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.

        TRY.
            lr_vlcactdata_item ?=  lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.

        MOVE-CORRESPONDING lr_vlcactdata_head->* TO ls_ac_cancel.
        MOVE lr_vlcactdata_item->*-vguid TO ls_ac_cancel-vguid.
        MOVE lr_vlcactdata_item->*-vhcle TO ls_ac_cancel-vhcle.
        MOVE lr_vlcactdata_head->*-lifnr TO ls_ac_cancel-lifnr.
        MOVE lr_vlcactdata_item->*-/dbe/ext_service_lifnr TO ls_ac_cancel-ext_service_lifnr.
        MOVE lr_vlcactdata_item->*-/dbe/coaufnr TO ls_ac_cancel-/dbe/coaufnr.
        MOVE lr_vlcactdata_item->*-matnr TO ls_ac_cancel-matnrtxt.
        MOVE lr_vlcactdata_head->*-currency TO ls_ac_cancel-currency.
        MOVE lr_vlcactdata_head->*-/dbe/ext_service_type TO ls_ac_cancel-ext_service_type.
        MOVE lr_vlcactdata_head->*-tax_code TO ls_ac_cancel-serv_tax_code.
        MOVE lr_vlcactdata_head->*-/dbe/ext_srv_netamt TO ls_ac_cancel-serv_netamt.
        MOVE lr_vlcactdata_item->*-/dbe/cost TO ls_ac_cancel-cost.
        MOVE lr_vlcactdata_head->*-ebeln TO ls_ac_cancel-po_number.
        MOVE lr_vlcactdata_item->*-po_number TO ls_ac_cancel-po_number.
        MOVE lr_vlcactdata_item->*-po_item TO ls_ac_cancel-po_item.
        MOVE lr_vlcactdata_item->*-ref_doc TO ls_ac_cancel-ref_doc.
        MOVE lr_vlcactdata_item->*-ref_doc_year TO ls_ac_cancel-ref_doc_year.
        MOVE lr_vlcactdata_item->*-/dbe/serv_tax_code TO ls_ac_cancel-serv_tax_code.
        MOVE lr_vlcactdata_item->*-/dbe/serv_netamt TO ls_ac_cancel-serv_netamt.
        MOVE lr_vlcactdata_item->*-/dbe/fi_belnr TO ls_ac_cancel-inv_number.
        MOVE lr_vlcactdata_item->*-/dbe/fi_gjahr TO ls_ac_cancel-inv_year.

        LOOP AT gt_apo_po INTO ls_apo_po WHERE vguid = ls_ac_cancel-vguid.

          ls_ac_cancel-ext_service_lifnr = ls_apo_po-vendor.
          ls_ac_cancel-po_number = ls_apo_po-po_number.
          ls_ac_cancel-po_item = ls_apo_po-po_item.
          ls_ac_cancel-po_status = ls_apo_po-po_status.
          ls_ac_cancel-ref_doc = ls_apo_po-gr_number.
          ls_ac_cancel-ref_doc_year = ls_apo_po-gr_year.
          ls_ac_cancel-gr_status = ls_apo_po-gr_status.
          ls_ac_cancel-inv_number = ls_apo_po-inv_number.
          ls_ac_cancel-inv_year = ls_apo_po-inv_year.
          ls_ac_cancel-inv_status = ls_apo_po-inv_status.
          ls_ac_cancel-currency = ls_apo_po-currency.
          ls_ac_cancel-cost = ls_apo_po-cost.

          APPEND ls_ac_cancel TO gt_ac_cancel.
        ENDLOOP.
      ENDLOOP.

      CASE gv_action.
        WHEN /dbe/if_vms_constants=>c_qacc OR /dbe/if_vms_constants=>c_qapc.
          DELETE gt_ac_cancel WHERE po_number IS INITIAL.
        WHEN /dbe/if_vms_constants=>c_qagc.
          DELETE gt_ac_cancel WHERE ref_doc IS INITIAL.
        WHEN /dbe/if_vms_constants=>c_qaic.
          DELETE gt_ac_cancel WHERE inv_number IS INITIAL.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
  ENDIF.


ENDFORM.                    " PREPARE_ALV_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_RELATED_VEHICLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_related_vehicles TABLES it_guids USING iv_document_type. "N:2348422

  CONSTANTS:
    lc_status_success TYPE c VALUE 'S'.

  DATA:
    lo_vehicle              TYPE REF TO /dbe/cl_veh_dbmvehicle,
    ls_req_data             TYPE /dbe/req_vehicle_data,
    ls_bobget               TYPE /dbe/s_veh_bobget,
    lt_bobget               TYPE /dbe/t_veh_bobget,
    ls_apo_po               TYPE /dbe/vlc_ac_po,
    lr_iobj_single          TYPE REF TO /dbe/iobj_data_single_com_s,
    lr_iobj_multi           TYPE REF TO /dbe/iobj_data_multi_com_s,
    lt_vlcdiavehi           TYPE vlcdiavehi_t,
    lt_iobj_data_single_com TYPE /dbe/iobj_data_single_com_t,
    lt_iobj_data_multi_com  TYPE /dbe/iobj_data_multi_com_t,
    lt_vlcactdata_head      TYPE TABLE OF vlcactdata_head_s,
    lt_vlcactdata_item      TYPE TABLE OF vlcactdata_item_s,
    lv_where                TYPE string,
    lt_invalid_bob          TYPE /dbe/t_veh_bob,
    ls_vlcdiavehi_ext       TYPE  /dbe/vsresult,
    lt_bob_details          TYPE /dbe/t_veh_bob,
    ls_bob_details          LIKE LINE OF lt_bob_details,
    lo_buf                  TYPE REF TO /dbe/cl_veh_buf,
    lt_bob                  TYPE  /dbe/t_veh_bob,
    ls_bob                  LIKE LINE OF lt_bob,
    lr_vlcactdata_head      TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item      TYPE REF TO vlcactdata_item_s,
    lr_vlcdiavehi           TYPE REF TO vlcdiavehi.

  REFRESH gt_apo_po.

* perform get_adc_items using it_guids.
* Retrieve all the Purchase orders
  CALL FUNCTION '/DBE/VMASS_GET_ADC_ITEMS'
    EXPORTING
      iv_document_type = iv_document_type       "N:2348422
    TABLES
      it_vlcguid       = it_guids
      et_vlcapo        = gt_apo_po
    EXCEPTIONS
      no_record_found  = 1
      OTHERS           = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Get the vehicle instance
  lo_buf = /dbe/cl_veh_buf=>get_instance( ).
  lt_bob = lo_buf->get_all( ).

* Loop at the vehicle data
  LOOP AT lt_bob INTO ls_bob.
    READ TABLE gt_apo_po INTO ls_apo_po WITH KEY vguid = ls_bob-guid.

    IF sy-subrc NE 0.
      APPEND ls_bob TO lt_invalid_bob.

      READ TABLE gt_vsresult_selection INTO gs_selection WITH KEY vguid = ls_bob-guid.
      IF sy-subrc EQ 0.
        DELETE gt_vsresult_selection INDEX sy-index.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Remove the vehicle for which no additional cost is posted
  CALL METHOD lo_buf->rem_bob
    EXPORTING
      it_bob = lt_invalid_bob.

* After deleting all the invalid bob retrive the valid bob's again.
  CALL METHOD lo_buf->get_all
    RECEIVING
      rt_bob = lt_bob.

  IF lt_bob IS NOT INITIAL.
*   Loop at the each purchase order
    LOOP AT gt_apo_po INTO ls_apo_po .

      READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_apo_po-vguid.
      IF sy-subrc NE 0.

*       Get the vehicle details Via VM01
        CALL FUNCTION '/DBE/VM01_VEHICLE_GET'
          EXPORTING
            iv_vguid                = ls_apo_po-vguid
            is_req_data             = ls_req_data
            iv_refresh_buffer       = abap_false        "N:2348422
          IMPORTING
            es_vlcdiavehi           = gs_vlcdiavehi
            es_vlcactdata_head      = gs_vlcactdata_head
            es_vlcactdata_item      = gs_vlcactdata_item
            et_vlcadddata           = gt_vlcadddata
            ev_category_id          = gv_iobj_catid
            es_iobj_data_single_com = gs_iobj_single
            es_iobj_data_multi_com  = gs_iobj_multi
            et_bapireturn           = gt_bapireturn
          EXCEPTIONS
            error_vms_get           = 1
            error_iobj_get          = 2
            error_badi              = 3
            OTHERS                  = 4.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

*       Collect data
        APPEND gs_vlcdiavehi TO lt_vlcdiavehi.
        APPEND gs_vlcactdata_head TO lt_vlcactdata_head.
        APPEND gs_vlcactdata_item TO lt_vlcactdata_item.
        APPEND gs_iobj_single TO lt_iobj_data_single_com.
        APPEND gs_iobj_multi TO lt_iobj_data_multi_com.

        ls_req_data-vms_text = abap_true.
        ls_req_data-iobj_gentext = abap_true.

        CLEAR: ls_bobget, lt_bobget.
        ls_bobget-guid     = ls_apo_po-vguid.
        ls_bobget-bobtype  = '/DBE/CL_VEH_DBMVEHICLE'.
        ls_bobget-set_lock = abap_true.
        APPEND ls_bobget TO lt_bobget.

*       Create new buffer objects and return the reference
        TRY.
            CALL METHOD /dbe/cl_veh_dbmvehicle=>get_dbmvehicle
              EXPORTING
                it_bobget   = lt_bobget
                is_req_data = ls_req_data
                iv_iobj_req = abap_true
              IMPORTING
                et_bob      = lt_bob_details.

          CATCH /dbe/cx_veh_error_occured .
          CATCH cx_dynamic_check .
        ENDTRY.

        LOOP AT lt_bob_details INTO ls_bob_details.
          lo_vehicle ?= ls_bob_details-bobref.

*         set action for additional vehicles which were not seleted
          TRY.
              CALL METHOD lo_vehicle->set_action
                EXPORTING
                  iv_action     = gv_action
                  iv_wo_prepare = abap_true.
            CATCH /dbe/cx_veh_action_not_defined .
            CATCH /dbe/cx_veh_static_check .
          ENDTRY.
*         Get header data
          TRY.
              lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.

*         Set Vlcdaivehi in buffer
          TRY.
              lr_vlcdiavehi ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcdiavehi ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.

          "append those entries selection table so that statuc change takes place for all selected vehicle
          MOVE-CORRESPONDING lr_vlcdiavehi->* TO ls_vlcdiavehi_ext.
          APPEND ls_vlcdiavehi_ext TO gt_vsresult_selection  .

          READ TABLE lt_vlcdiavehi INTO gs_vlcdiavehi WITH KEY vguid = ls_bob_details-guid.

          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING gs_vlcdiavehi TO  lr_vlcdiavehi->*.
*           Set header in buffer
            READ TABLE lt_vlcactdata_head INTO gs_vlcactdata_head WITH KEY /dbe/iobjguid = gs_vlcdiavehi-/dbe/iobjguid.
            IF sy-subrc EQ 0.
              MOVE-CORRESPONDING gs_vlcactdata_head TO  lr_vlcactdata_head->*.
            ENDIF.
          ENDIF.

*         Set item data
          TRY.
              lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.

          READ TABLE lt_vlcactdata_item INTO gs_vlcactdata_item WITH KEY vguid = ls_bob_details-guid.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING gs_vlcactdata_item TO  lr_vlcactdata_item->*.
          ENDIF.
*         Set Single Iobject data
          TRY.
              lr_iobj_single ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.

          READ TABLE lt_iobj_data_single_com INTO gs_iobj_single WITH KEY /dbe/v_vehicle-vguid = ls_bob_details-guid.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING gs_iobj_single TO  lr_iobj_single->*.
          ENDIF.
*         Set Multi Iobject data
          TRY.
              lr_iobj_multi ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_multi_com_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.

          READ TABLE lt_iobj_data_multi_com INTO gs_iobj_multi WITH KEY /dbe/v_vehicle-vguid = ls_bob_details-guid.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING gs_iobj_multi TO  lr_iobj_multi->*.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " GET_RELATED_VEHICLES
*&---------------------------------------------------------------------*
*&      Form  PREPARE_ALV_DATA_601
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_alv_data_601 .

  CONSTANTS:
    lc_po_status_success  TYPE c VALUE 'S',
    lc_gr_status_success  TYPE c VALUE 'S',
    lc_gr_status_pending  TYPE c VALUE 'P',
    lc_gr_status_cancled  TYPE c VALUE 'C',
    lc_inv_status_initial TYPE c VALUE 'N',
    lc_inv_status_pending TYPE c VALUE 'P',
    lc_inv_status_cancled TYPE c VALUE 'C'.

  DATA:
    ls_gr_create       LIKE LINE OF gt_gr_create,
    ls_gr_cancel       LIKE LINE OF gt_gr_cancel,
    ls_inv_cancel      LIKE LINE OF gt_inv_cancel,
    ls_ac_post         LIKE LINE OF gt_ac_post,
    ls_ac_cancel       TYPE ty_addcost_cancel,
    ls_vlcactdata_head TYPE vlcactdata_head_s,
    ls_vlcactdata_item TYPE vlcactdata_item_s,
    porders_lt         LIKE vlcporder OCCURS 0,
    porders_ls         LIKE vlcporder,
    lt_apo_po          TYPE /dbe/vlc_ac_po_t,
    ls_apo_po          TYPE /dbe/vlc_ac_po,
    vguids_lt          TYPE TABLE OF vlcguid,
    lt_vguids          TYPE TABLE OF vlcguid WITH HEADER LINE,
    lt_adc_status      TYPE /dbe/vlc_adc_status_t,
    ls_adc_status      TYPE /dbe/vlc_adc_status_s,
    lo_buf             TYPE REF TO /dbe/cl_veh_buf,
    lt_bob             TYPE /dbe/t_veh_bob,
    ls_bob             LIKE LINE OF lt_bob,
    lo_veh             TYPE REF TO /dbe/cl_veh_dbmvehicle,
    lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s.

  IF sy-ucomm NE 'CG_ALL'.

    lo_buf = /dbe/cl_veh_buf=>get_instance( ).
    lt_bob = lo_buf->get_all( ).

    REFRESH: gt_gr_create, gt_gr_cancel ,gt_inv_cancel, gt_ac_post.

    IF gv_ok_code NE  gc_enter_fcode.
      REFRESH gt_ac_cancel.
    ENDIF.

    IF go_ac_create IS NOT INITIAL.
      CALL METHOD go_ac_create->refresh_table_display( ).
    ENDIF.

    IF go_ac_cancel IS NOT INITIAL.
      CALL METHOD go_ac_cancel->refresh_table_display( ).
    ENDIF.

    LOOP AT lt_bob INTO ls_bob.
      DATA lv_guid TYPE vlcguid.
      lo_veh ?= ls_bob-bobref.
      lv_guid = lo_veh->get_guid( ).
      APPEND lv_guid TO lt_vguids.
    ENDLOOP.

    LOOP AT lt_bob INTO ls_bob.
      lo_veh ?= ls_bob-bobref.
      TRY.
          lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
        CATCH /dbe/cx_veh_layer_not_found .
      ENDTRY.

      TRY.
          lr_vlcactdata_item ?=  lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
        CATCH /dbe/cx_veh_layer_not_found .
      ENDTRY.
      CLEAR lt_apo_po.


      IF gv_action = /dbe/if_vms_constants=>c_qagc.
        CALL FUNCTION '/DBE/VMASS_GET_ADC_ITEMS'
          EXPORTING
            iv_document_type = 3                 "N:2348422
          TABLES
            it_vlcguid       = lt_vguids
            et_vlcapo        = lt_apo_po
          EXCEPTIONS
            no_record_found  = 1
            OTHERS           = 2.
        IF sy-subrc NE 0.
* Implement suitable error handling here
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF gv_ok_code NE  gc_enter_fcode.
      REFRESH gt_ac_cancel.

*    CLEAR gs_selection.
      LOOP AT lt_bob INTO ls_bob.
        lo_veh ?= ls_bob-bobref.
        TRY.
            lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.

        TRY.
            lr_vlcactdata_item ?=  lo_veh->get_data_com( lo_veh->gc_vlcactdata_item_s ).
          CATCH /dbe/cx_veh_layer_not_found .
        ENDTRY.

        MOVE-CORRESPONDING lr_vlcactdata_head->* TO ls_ac_cancel.
        MOVE lr_vlcactdata_head->*-currency TO ls_ac_cancel-currency.
        MOVE lr_vlcactdata_head->*-/dbe/ext_service_type TO ls_ac_cancel-ext_service_type.
        MOVE lr_vlcactdata_head->*-tax_code TO ls_ac_cancel-serv_tax_code.
        MOVE lr_vlcactdata_head->*-/dbe/ext_srv_netamt TO ls_ac_cancel-serv_netamt.
        MOVE lr_vlcactdata_head->*-lifnr TO ls_ac_cancel-lifnr.
        MOVE lr_vlcactdata_head->*-ebeln TO ls_ac_cancel-po_number.

        MOVE lr_vlcactdata_item->*-vguid TO ls_ac_cancel-vguid.
        MOVE lr_vlcactdata_item->*-vhcle TO ls_ac_cancel-vhcle.
        MOVE lr_vlcactdata_item->*-/dbe/ext_service_lifnr TO ls_ac_cancel-ext_service_lifnr.
        MOVE lr_vlcactdata_item->*-/dbe/coaufnr TO ls_ac_cancel-/dbe/coaufnr.
        MOVE lr_vlcactdata_item->*-matnr TO ls_ac_cancel-matnrtxt.
        MOVE lr_vlcactdata_item->*-/dbe/cost TO ls_ac_cancel-cost.
        MOVE lr_vlcactdata_item->*-po_number TO ls_ac_cancel-po_number.
        MOVE lr_vlcactdata_item->*-po_item TO ls_ac_cancel-po_item.
        MOVE lr_vlcactdata_item->*-ref_doc TO ls_ac_cancel-ref_doc.
        MOVE lr_vlcactdata_item->*-ref_doc_year TO ls_ac_cancel-ref_doc_year.
        MOVE lr_vlcactdata_item->*-/dbe/serv_tax_code TO ls_ac_cancel-serv_tax_code.
        MOVE lr_vlcactdata_item->*-/dbe/serv_netamt TO ls_ac_cancel-serv_netamt.
        MOVE lr_vlcactdata_item->*-/dbe/fi_belnr TO ls_ac_cancel-inv_number.
        MOVE lr_vlcactdata_item->*-/dbe/fi_gjahr TO ls_ac_cancel-inv_year.

        LOOP AT gt_apo_po INTO ls_apo_po WHERE vguid = ls_ac_cancel-vguid.

          ls_ac_cancel-ext_service_lifnr = ls_apo_po-vendor.
          ls_ac_cancel-po_number = ls_apo_po-po_number.
          ls_ac_cancel-po_item = ls_apo_po-po_item.
          ls_ac_cancel-po_status = ls_apo_po-po_status.
          ls_ac_cancel-ref_doc = ls_apo_po-gr_number.
          ls_ac_cancel-ref_doc_year = ls_apo_po-gr_year.
          ls_ac_cancel-gr_status = ls_apo_po-gr_status.
          ls_ac_cancel-inv_number = ls_apo_po-inv_number.
          ls_ac_cancel-inv_year = ls_apo_po-inv_year.
          ls_ac_cancel-inv_status = ls_apo_po-inv_status.
          ls_ac_cancel-currency = ls_apo_po-currency.
          ls_ac_cancel-cost = ls_apo_po-cost.

          APPEND ls_ac_cancel TO gt_ac_cancel.
        ENDLOOP.
      ENDLOOP.

      PERFORM check_adc_cancel_status.                      "N:2348422
    ENDIF.
  ENDIF.

ENDFORM.                    " PREPARE_ALV_DATA_601

*&---------------------------------------------------------------------*
*&      Form  GET_ADC_ITEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_GUIDS  text
*----------------------------------------------------------------------*
FORM get_adc_items  USING  it_guids .
*  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
*   EXPORTING
**     IT_ADC_STATUS                     =
**     IV_INCLUDE_ALL                    =
**     IV_PO_NUMBER                      =
**     IV_ADDDTIONAL_COST_OVERVIEW       =
*    TABLES
*      vlcguid_it                        = it_guids
*      vlcapo_et                         =
**   EXCEPTIONS
**     NO_RECORD_FOUND                   = 1
**     OTHERS                            = 2
*            .
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.


ENDFORM.                    " GET_ADC_ITEMS
*&---------------------------------------------------------------------*
*&      Form  check_adc_cancel_status                         N:2348422
*&---------------------------------------------------------------------*
FORM check_adc_cancel_status.

  CASE gv_action.
    WHEN /dbe/if_vms_constants=>c_qacc.
      PERFORM  check_qacc_cancel_status.

    WHEN /dbe/if_vms_constants=>c_qapc.
      PERFORM  check_adc_po_cancel_status.

    WHEN /dbe/if_vms_constants=>c_qagc.
      PERFORM  check_adc_gr_cancel_status.

    WHEN /dbe/if_vms_constants=>c_qaic.
      PERFORM  check_adc_iv_cancel_status.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  check_adc_po_cancel_status                      N:2348422
*&---------------------------------------------------------------------*
FORM check_adc_po_cancel_status.
  DATA: lv_cannot_cancel  TYPE char1,
        lv_po_number_prev TYPE bstnr.

  FIELD-SYMBOLS <ac_cancel> LIKE LINE OF gt_ac_cancel.

  SORT gt_ac_cancel BY po_number vhcle.

  LOOP AT gt_ac_cancel ASSIGNING <ac_cancel>.
*   check grouping by po_number
    IF sy-tabix > 1 AND lv_po_number_prev <> <ac_cancel>-po_number.
*     for previous group of PO number set icon based on lv_cannot_cancel
      PERFORM set_adc_po_cancel_icon
        USING lv_po_number_prev
              lv_cannot_cancel.
      CLEAR lv_cannot_cancel.
    ENDIF.

    IF lv_cannot_cancel IS INITIAL.
*     when material document exists or invoice exists we cannot cancel PO
      IF <ac_cancel>-gr_status = 'S'.
        lv_cannot_cancel = 'M'.
      ELSEIF <ac_cancel>-inv_status = 'S'.
        lv_cannot_cancel = 'I'.
      ELSE.
*       check if action can be executed
        PERFORM check_adc_vehicle_action
          USING    <ac_cancel>-vguid
                   gv_action
          CHANGING lv_cannot_cancel.
      ENDIF.
    ENDIF.
    lv_po_number_prev = <ac_cancel>-po_number.
  ENDLOOP.

  IF sy-subrc = 0.
    PERFORM set_adc_po_cancel_icon
      USING lv_po_number_prev
            lv_cannot_cancel.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  set_adc_po_cancel_icon                          N:2348422
*&---------------------------------------------------------------------*
FORM set_adc_po_cancel_icon
  USING iv_po_number     TYPE bstnr
        iv_cannot_cancel TYPE char1.

  DATA: ls_ac_cancel LIKE LINE OF gt_ac_cancel.

  PERFORM get_adc_status_icon
    USING    iv_cannot_cancel
    CHANGING ls_ac_cancel-icon.

  ls_ac_cancel-cannot_cancel = iv_cannot_cancel.
  MODIFY gt_ac_cancel FROM ls_ac_cancel TRANSPORTING icon cannot_cancel WHERE po_number = iv_po_number.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form check_adc_gr_cancel_status                       N:2348422
*&---------------------------------------------------------------------*
FORM check_adc_gr_cancel_status.

  DATA: lv_cannot_cancel     TYPE char1,
        lv_ref_doc_prev      TYPE mblnr,
        lv_ref_doc_year_prev TYPE mjahr.

  FIELD-SYMBOLS <ac_cancel> LIKE LINE OF gt_ac_cancel.

  SORT gt_ac_cancel BY ref_doc ref_doc_year vhcle.

  LOOP AT gt_ac_cancel ASSIGNING <ac_cancel>.
*   check grouping by GR number and year
    IF sy-tabix > 1 AND ( lv_ref_doc_prev <> <ac_cancel>-ref_doc OR lv_ref_doc_year_prev <> <ac_cancel>-ref_doc_year ).
*     for previous group of GR number and year set icon based on lv_cannot_cancel
      PERFORM set_adc_gr_cancel_icon
        USING lv_ref_doc_prev
              lv_ref_doc_year_prev
              lv_cannot_cancel.
      CLEAR lv_cannot_cancel.
    ENDIF.

    IF lv_cannot_cancel IS INITIAL.
*     when invoice exists we cannot cancel GR
      IF <ac_cancel>-inv_status = 'S'.
        lv_cannot_cancel = 'I'.
      ELSE.
*       check if action can be executed
        PERFORM check_adc_vehicle_action
          USING    <ac_cancel>-vguid
                   gv_action
          CHANGING lv_cannot_cancel.
      ENDIF.
    ENDIF.
    lv_ref_doc_prev = <ac_cancel>-ref_doc.
    lv_ref_doc_year_prev = <ac_cancel>-ref_doc_year.
  ENDLOOP.

  IF sy-subrc = 0.
    PERFORM set_adc_gr_cancel_icon
      USING lv_ref_doc_prev
            lv_ref_doc_year_prev
            lv_cannot_cancel.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  set_adc_gr_cancel_icon                          N:2348422
*&---------------------------------------------------------------------*
FORM set_adc_gr_cancel_icon
  USING iv_ref_doc       TYPE mblnr
        iv_ref_doc_year  TYPE mjahr
        iv_cannot_cancel TYPE char1.

  DATA: ls_ac_cancel LIKE LINE OF gt_ac_cancel.

  PERFORM get_adc_status_icon
    USING    iv_cannot_cancel
    CHANGING ls_ac_cancel-icon.

  ls_ac_cancel-cannot_cancel = iv_cannot_cancel.
  MODIFY gt_ac_cancel FROM ls_ac_cancel TRANSPORTING icon cannot_cancel WHERE ref_doc = iv_ref_doc AND ref_doc_year = iv_ref_doc_year.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form check_adc_iv_cancel_status                       N:2348422
*&---------------------------------------------------------------------*
FORM check_adc_iv_cancel_status.
  DATA: lv_cannot_cancel   TYPE char1,
        lv_inv_number_prev TYPE re_belnr,
        lv_inv_year_prev   TYPE gjahr.

  FIELD-SYMBOLS <ac_cancel> LIKE LINE OF gt_ac_cancel.

  SORT gt_ac_cancel BY inv_number inv_year vhcle.

  LOOP AT gt_ac_cancel ASSIGNING <ac_cancel>.
*   check grouping by INV number and year
    IF sy-tabix > 1 AND ( lv_inv_number_prev <> <ac_cancel>-inv_number OR lv_inv_year_prev <> <ac_cancel>-inv_year ).
*     for previous group of INV number and year set icon based on lv_cannot_cancel
      PERFORM set_adc_iv_cancel_icon
        USING lv_inv_number_prev
              lv_inv_year_prev
              lv_cannot_cancel.
      CLEAR lv_cannot_cancel.
    ENDIF.

    IF lv_cannot_cancel IS INITIAL.
*     check if action can be executed
      PERFORM check_adc_vehicle_action
        USING    <ac_cancel>-vguid
                 gv_action
        CHANGING lv_cannot_cancel.
    ENDIF.
    lv_inv_number_prev = <ac_cancel>-inv_number.
    lv_inv_year_prev = <ac_cancel>-inv_year.
  ENDLOOP.

  IF sy-subrc = 0.
    PERFORM set_adc_iv_cancel_icon
      USING lv_inv_number_prev
            lv_inv_year_prev
            lv_cannot_cancel.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  set_adc_iv_cancel_icon                          N:2348422
*&---------------------------------------------------------------------*
FORM set_adc_iv_cancel_icon
  USING iv_inv_number    TYPE re_belnr
        iv_inv_year      TYPE gjahr
        iv_cannot_cancel TYPE char1.

  DATA: ls_ac_cancel LIKE LINE OF gt_ac_cancel.

  PERFORM get_adc_status_icon
    USING    iv_cannot_cancel
    CHANGING ls_ac_cancel-icon.

  ls_ac_cancel-cannot_cancel = iv_cannot_cancel.
  MODIFY gt_ac_cancel FROM ls_ac_cancel TRANSPORTING icon cannot_cancel WHERE inv_number = iv_inv_number AND inv_year = iv_inv_year.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form check_qacc_cancel_status                         N:2348422
*&---------------------------------------------------------------------*
FORM  check_qacc_cancel_status.

  DATA: lv_cannot_cancel   TYPE char1,
        ls_ac_cancel_prev  LIKE LINE OF gt_ac_cancel,
        lv_inv_number_prev TYPE re_belnr,
        lv_inv_year_prev   TYPE gjahr.

  FIELD-SYMBOLS <ac_cancel> LIKE LINE OF gt_ac_cancel.

  SORT gt_ac_cancel BY inv_number inv_year vhcle.

  LOOP AT gt_ac_cancel ASSIGNING <ac_cancel>.
    IF sy-tabix = 1.
      ls_ac_cancel_prev = <ac_cancel>.
    ENDIF.
*   check grouping by INV number and year
    IF sy-tabix > 1 AND ( lv_inv_number_prev <> <ac_cancel>-inv_number OR lv_inv_year_prev <> <ac_cancel>-inv_year ).
*     for new group of INV number and year set icon based on lv_cannot_cancel
      PERFORM set_adc_iv_cancel_icon
        USING lv_inv_number_prev
              lv_inv_year_prev
              lv_cannot_cancel.
      CLEAR lv_cannot_cancel.
      ls_ac_cancel_prev = <ac_cancel>.
    ENDIF.

    IF lv_cannot_cancel IS INITIAL.
*     check if different material documents are used
      IF <ac_cancel>-ref_doc <> ls_ac_cancel_prev-ref_doc OR <ac_cancel>-ref_doc_year <> ls_ac_cancel_prev-ref_doc_year.
        lv_cannot_cancel = 'm'.
*     check if different PO are used
      ELSEIF <ac_cancel>-po_number <> ls_ac_cancel_prev-po_number.
        lv_cannot_cancel = 'p'.
      ENDIF.
    ENDIF.

    IF lv_cannot_cancel IS INITIAL.
*     check if exists the same gr number and year for different invoice -> cannot cancel additional costs
      LOOP AT gt_ac_cancel TRANSPORTING NO FIELDS WHERE ref_doc = <ac_cancel>-ref_doc AND ref_doc_year = <ac_cancel>-ref_doc_year AND ( inv_number <> <ac_cancel>-inv_number OR inv_year <> <ac_cancel>-inv_year ).
        lv_cannot_cancel = 'n'.
        EXIT.
      ENDLOOP.
    ENDIF.

    IF lv_cannot_cancel IS INITIAL.
*     check if exists the same po number for different invoice -> cannot cancel additional costs
      LOOP AT gt_ac_cancel TRANSPORTING NO FIELDS WHERE po_number = <ac_cancel>-po_number AND ( inv_number <> <ac_cancel>-inv_number OR inv_year <> <ac_cancel>-inv_year ).
        lv_cannot_cancel = 'q'.
        EXIT.
      ENDLOOP.
    ENDIF.

    IF lv_cannot_cancel IS INITIAL.
*     check if action can be executed
      PERFORM check_adc_vehicle_action
        USING    <ac_cancel>-vguid
                 gv_action
        CHANGING lv_cannot_cancel.
    ENDIF.
    lv_inv_number_prev = <ac_cancel>-inv_number.
    lv_inv_year_prev = <ac_cancel>-inv_year.
    ls_ac_cancel_prev = <ac_cancel>.
  ENDLOOP.

  IF sy-subrc = 0.
    PERFORM set_adc_iv_cancel_icon
      USING lv_inv_number_prev
            lv_inv_year_prev
            lv_cannot_cancel.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_adc_status_icon                              N:2348422
*&---------------------------------------------------------------------*
FORM get_adc_status_icon
  USING    iv_cannot_cancel TYPE char1
  CHANGING cv_icon          TYPE icon_text.

  DATA: lv_tooltip   TYPE icon_text.

  IF iv_cannot_cancel IS NOT INITIAL.
    CASE iv_cannot_cancel.
      WHEN 'M'.
        MESSAGE e120(/dbe/vehicle_master) INTO lv_tooltip.
      WHEN 'I'.
        MESSAGE e121(/dbe/vehicle_master) INTO lv_tooltip.
      WHEN 'A'.
        MESSAGE e123(/dbe/vehicle_master) INTO lv_tooltip.
      WHEN 'p'.
        MESSAGE e124(/dbe/vehicle_master) INTO lv_tooltip.
      WHEN 'm'.
        MESSAGE e125(/dbe/vehicle_master) INTO lv_tooltip.
      WHEN 'q'.
        MESSAGE e127(/dbe/vehicle_master) INTO lv_tooltip.
      WHEN 'n'.
        MESSAGE e126(/dbe/vehicle_master) INTO lv_tooltip.
      WHEN OTHERS.
        MESSAGE e130(/dbe/vehicle_master) INTO lv_tooltip.
    ENDCASE.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name   = icon_led_red
        info   = lv_tooltip
      IMPORTING
        result = cv_icon.
  ELSE.
    cv_icon = icon_led_green.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  check_adc_vehicle_action                        N:2348422
*&---------------------------------------------------------------------*
FORM check_adc_vehicle_action
  USING    iv_vguid  TYPE vlc_guid
           iv_action TYPE cvlc03-aktion
  CHANGING cv_cannot_cancel TYPE char1.

  DATA: lo_veh_buf       TYPE REF TO /dbe/cl_veh_buf,
        lo_vehicle       TYPE REF TO /dbe/cl_veh_dbmvehicle,
        lt_bob           TYPE /dbe/t_veh_bob,
        ls_bob           TYPE /dbe/s_veh_bob,
        lt_actions       TYPE /dbe/vms_actions,
        cur_txn_name(20) TYPE c.

  lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
  lt_bob = lo_veh_buf->get_all( ).

  cur_txn_name  = '/DBE/MASSACTIONS'.
  EXPORT cur_txn_name FROM cur_txn_name TO  MEMORY ID 'TXN_NAME'.

* check if action can be executed
  READ TABLE lt_bob INTO ls_bob WITH KEY guid = iv_vguid.
  IF sy-subrc = 0.
    lo_vehicle ?= ls_bob-bobref.
    lo_vehicle->vms_actions_get( EXPORTING iv_no_internal_actions = abap_false
                                 IMPORTING et_actions = lt_actions ).
    READ TABLE lt_actions WITH KEY aktion = gv_action TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      cv_cannot_cancel = 'A'.
    ENDIF.
  ELSE.
    cv_cannot_cancel = 'U'.
  ENDIF.
ENDFORM.

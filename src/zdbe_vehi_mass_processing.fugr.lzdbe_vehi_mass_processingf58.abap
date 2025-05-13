*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF58 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ENTRY_LIFNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_entry_lifnr .

  DATA: ls_xlfa1 LIKE lfa1.

  IF gv_action = /DBE/if_vms_constants=>c_qadc OR
            gv_action = /DBE/if_vms_constants=>c_qapo OR
            gv_action = /DBE/if_vms_constants=>c_qagr OR
            gv_action = /DBE/if_vms_constants=>c_qain .

    CALL FUNCTION 'READ_LFA1'
      EXPORTING
        xlifnr         = vlcactdata_head_s-/DBE/srvc_vendor
      IMPORTING
        xlfa1          = ls_xlfa1
      EXCEPTIONS
*       KEY_INCOMPLETE = 1
        not_authorized = 2
        not_found      = 3
*       OTHERS         =          4.
      .
  ELSE.
    CALL FUNCTION 'READ_LFA1'
      EXPORTING
        xlifnr         = vlcactdata_head_s-lifnr
      IMPORTING
        xlfa1          = ls_xlfa1
      EXCEPTIONS
*       KEY_INCOMPLETE = 1
        not_authorized = 2
        not_found      = 3
*       OTHERS         =          4.
      .
  ENDIF.

  IF sy-subrc <> 0.
    IF gv_action = /DBE/if_vms_constants=>c_qadc OR
            gv_action = /DBE/if_vms_constants=>c_qapo OR
            gv_action = /DBE/if_vms_constants=>c_qagr OR
            gv_action = /DBE/if_vms_constants=>c_qain .
      MESSAGE e058(00) WITH vlcactdata_head_s-/DBE/srvc_vendor '' '' 'LFA1'.
    ELSE.
      MESSAGE e058(00) WITH vlcactdata_head_s-lifnr '' '' 'LFA1'. "vlcactdata_head_s-/DBE/srvc_vendor '' '' 'LFA1'. "
    ENDIF.
  ELSE.
    lfa1-name1 = ls_xlfa1-name1.
  ENDIF.

ENDFORM.                    " F_CHECK_ENTRY_LIFNR
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ENTRY_NETAMT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_entry_netamt .
  IF gv_adc_flag IS NOT INITIAL.
    MESSAGE e442(/DBE/vehicle_master).
  ENDIF.
ENDFORM.                    " F_CHECK_ENTRY_NETAMT
*&---------------------------------------------------------------------*
*&      Form  HANDLE_CHARACTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM handle_character .
  IF sy-ucomm = gc_error.
    TRY.
        CALL METHOD go_ac_create->refresh_table_display.
      CATCH cx_root.
    ENDTRY.
  ENDIF.

  IF sy-ucomm = gc_netamt AND gv_netamt EQ 0.
    MESSAGE i426(/DBE/vehicle_master).
  ENDIF.

ENDFORM.                    " HANDLE_CHARACTER
*&---------------------------------------------------------------------*
*&      Form  TRANSFER_ADC_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM transfer_adc_info .

  DATA:
          ls_adc_info         LIKE LINE OF gt_ac_post,
          lv_valid            TYPE boole_d,
          lo_vehicle          TYPE REF TO /DBE/cl_veh_dbmvehicle,
          lr_item_data        TYPE REF TO data ,
          lv_tax_amount       TYPE /DBE/wmwst ,
          lr_data             TYPE REF TO data,
          lo_veh_buf          TYPE REF TO /DBE/cl_veh_buf,
          lt_bob              TYPE /DBE/t_veh_bob,
          ls_bob              LIKE LINE OF lt_bob,
          lr_vlcactdata_head  TYPE REF TO vlcactdata_head_s,
          lr_vlcactdata_item  TYPE REF TO vlcactdata_item_s.

  IF gv_ok_code EQ gc_error.
    RETURN.

  ELSE.
    IF go_ac_create IS BOUND.
      CALL METHOD go_ac_create->check_changed_data
        IMPORTING
          e_valid = lv_valid.
    ENDIF.

    CALL METHOD /DBE/cl_veh_buf=>get_instance
      RECEIVING
        ro_instance = lo_veh_buf.

    TRY.
      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob.
    ENDTRY.

    LOOP AT gt_ac_post INTO ls_adc_info .
      READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_adc_info-vguid.
      IF sy-subrc EQ 0.
        lo_vehicle ?= ls_bob-bobref.
      ENDIF.
      TRY.
          IF lo_vehicle IS BOUND.
            lr_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
          ENDIF.
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
      IF lr_data IS BOUND.
        lr_vlcactdata_head ?= lr_data.
        MOVE vlcactdata_head_s-bsart TO lr_vlcactdata_head->*-bsart.
        MOVE vlcactdata_head_s-bldat TO lr_vlcactdata_head->*-bldat.
        MOVE vlcactdata_head_s-budat TO lr_vlcactdata_head->*-budat.
        MOVE vlcactdata_head_s-ref_doc_no TO lr_vlcactdata_head->*-ref_doc_no.
        MOVE vlcactdata_head_s-/DBE/ext_service_type TO lr_vlcactdata_head->*-/DBE/ext_service_type.
        MOVE vlcactdata_head_s-/DBE/ext_srv_netamt TO lr_vlcactdata_head->*-/DBE/ext_srv_netamt.

        "in case of these two action, no need to get vendor from screen field
        IF gv_action NE /DBE/if_vms_constants=>c_qagr AND gv_action NE /DBE/if_vms_constants=>c_qain.
*          MOVE vlcactdata_head_s-lifnr TO lr_vlcactdata_head->*-lifnr.
          MOVE vlcactdata_head_s-/DBE/srvc_vendor TO lr_vlcactdata_head->*-/DBE/srvc_vendor.
        ENDIF.
        MOVE vlcactdata_head_s-tax_code TO lr_vlcactdata_head->*-tax_code.
        MOVE vlcactdata_head_s-currency TO lr_vlcactdata_head->*-currency.
        MOVE vlcactdata_head_s-/DBE/ext_srv_netamt TO lr_vlcactdata_head->*-netpr.
        MOVE vlcactdata_head_s-gross_amount TO lr_vlcactdata_head->*-gross_amount .
        MOVE vlcactdata_head_s-tax_amount TO lr_vlcactdata_head->*-tax_amount.
        gs_vlcactdata_head = vlcactdata_head_s.
      ENDIF.

      TRY.
          lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
      IF lr_item_data IS BOUND.
        lr_vlcactdata_item ?= lr_item_data.
      ENDIF.
* for cost
      IF  lr_vlcactdata_item->*-vguid   = ls_bob-guid.
        lr_vlcactdata_item->*-/dbe/cost = ls_adc_info-cost.
      ENDIF.
    ENDLOOP.

    TRY.
        CALL METHOD lo_veh_buf->set_all .
      CATCH /DBE/cx_veh_error_occured .
      CATCH cx_static_check .
    ENDTRY.
  ENDIF.
ENDFORM.                    " TRANSFER_ADC_INFO

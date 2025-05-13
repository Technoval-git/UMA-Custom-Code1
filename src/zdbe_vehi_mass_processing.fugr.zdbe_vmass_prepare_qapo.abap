FUNCTION ZDBE_VMASS_PREPARE_QAPO.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(ACTION_TO_BE_PERFORMED_IV) TYPE  VLC_ACTION OPTIONAL
*"     REFERENCE(LIST_OF_VEHICLES_IT) TYPE  VLCDIAVEHI_T OPTIONAL
*"     REFERENCE(IV_CALLED_IN_EXE) TYPE  BOOLEAN
*"  TABLES
*"      VLCAPO_ET TYPE  /DBE/VLC_AC_PO_T OPTIONAL
*"  CHANGING
*"     REFERENCE(VLCACTDATA_CS) TYPE  VLCACTDATA
*"     REFERENCE(VLCDIAVEHI_CT) TYPE  VLCDIAVEHI_T OPTIONAL
*"  EXCEPTIONS
*"      PREPARE_FAILED
*"--------------------------------------------------------------------

  DATA: ls_poheader TYPE bapimepoheader,
        lt_return   TYPE TABLE OF bapiret2.


  DATA: lt_vlcguid   TYPE TABLE OF vlcguid,
        ls_vlcguid   TYPE vlcguid,                          "N:2711659
        lt_vlcporder TYPE TABLE OF vlcporder,
        ls_vlcporder TYPE vlcporder,                        "N:2711659
        ls_vlcapo    TYPE /dbe/vlc_ac_po,
        lt_vlcapo    TYPE STANDARD TABLE OF /dbe/vlc_ac_po.


  DATA: ls_lfm1  TYPE lfm1,
        lv_bukrs TYPE bkpf-bukrs,
        lv_werks TYPE werks.

  DATA: lv_pricingtype          TYPE /dbe/veh_pricingtype.  "N:2711659
  DATA: ls_iobj_data_single     TYPE /dbe/iobj_data_single_txt_s.
  DATA: lv_scenario             TYPE char1.                                    "1 - PO exists for all vehicles, 2 - PO does not exists for any vehicle,  3 - combined scenarion (not supported)

  FIELD-SYMBOLS: "<fs_vlcactdata_actcs> TYPE vlcactdata_item_s,
    <fs_actdata_item> TYPE vlcactdata_item_s,
    <fs_vlcporder>    TYPE vlcporder,
    <fs_vlcdiavehi>   TYPE  vlcdiavehi,
    <fs_vlcapo>       TYPE /dbe/vlc_ac_po.

  CONSTANTS: lc_vlc_qord         TYPE vlc_actdoctype VALUE 'QORD',
             lc_bapi_mtype_error TYPE bapi_mtype VALUE 'E'.

* Prepare data for creating purchase order

  IF iv_called_in_exe EQ abap_true.
    LOOP AT vlcdiavehi_ct ASSIGNING <fs_vlcdiavehi>.
      APPEND <fs_vlcdiavehi>-vguid TO lt_vlcguid.
      <fs_vlcdiavehi>-actdoctype = action_to_be_performed_iv.
      <fs_vlcdiavehi>-cuaba = action_to_be_performed_iv.  " no required
    ENDLOOP.
  ELSE.
    LOOP  AT list_of_vehicles_it ASSIGNING <fs_vlcdiavehi>.
      APPEND <fs_vlcdiavehi>-vguid TO lt_vlcguid.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'VELO14_READ_PORDERS_WITH_VGUID'
    EXPORTING
      latest_iv        = abap_true
      actdoctype_iv    = lc_vlc_qord
    TABLES
      vlcguid_it       = lt_vlcguid
      vlcporder_et     = lt_vlcporder
    EXCEPTIONS
      no_data_received = 1
      nothing_found    = 2
      OTHERS           = 3.

* check scenario                                                                >>>N:2711659
  IF lt_vlcporder IS INITIAL.
    lv_scenario = '2'.            "No po exists for any vehicle
  ELSE.
    lv_scenario = '1'.            "PO exists but for all vehicles???
  ENDIF.

  gv_ekorg_0600_visible = abap_false.
  gv_ekgrp_0600_visible = abap_false.

* in case of not found vehicle PO add dummy record
  LOOP AT lt_vlcguid INTO ls_vlcguid.
    READ TABLE lt_vlcporder WITH KEY vguid = ls_vlcguid-vguid TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      IF lv_scenario = '1'.
        lv_scenario = '3'.        "combined scenario, some vehicles have PO some have not - not suported
      ENDIF.
      CLEAR ls_vlcporder.
      ls_vlcporder-vguid = ls_vlcguid-vguid.
      APPEND ls_vlcporder TO lt_vlcporder.
    ENDIF.
  ENDLOOP.

  IF lv_scenario = '3'.
    DATA lo_veh_buf TYPE REF TO /dbe/cl_veh_buf.
    DATA ls_bob	TYPE /dbe/s_veh_bob.
    DATA lv_dummy TYPE c.
    DATA lo_vehicle TYPE REF TO /dbe/cl_veh_dbmvehicle.
    DATA lr_vlcdiavehi  TYPE REF TO vlcdiavehi.
    DATA lv_vhcle  TYPE vlcdiavehi-vhcle.

    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).

    ls_bob-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.

    LOOP AT lt_vlcporder INTO ls_vlcporder.
      ls_bob-guid = ls_vlcporder-vguid.

      lo_vehicle ?= lo_veh_buf->is_in_buffer( ls_bob ).
      IF lo_vehicle IS BOUND.

        TRY.
            lr_vlcdiavehi ?= lo_vehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
            lv_vhcle = lr_vlcdiavehi->vhcle.
          CATCH /dbe/cx_veh_layer_not_found.
          CATCH cx_sy_move_cast_error.
            CLEAR lv_vhcle.
        ENDTRY.

        IF ls_vlcporder-ebeln IS INITIAL.
          MESSAGE w142(/dbe/vehicle_master) WITH lv_vhcle INTO lv_dummy.
        ELSE.
          MESSAGE w141(/dbe/vehicle_master) WITH lv_vhcle ls_vlcporder-ebeln INTO lv_dummy.
        ENDIF.
        lo_vehicle->bal_add_symessage( ).
      ENDIF.
    ENDLOOP.
    MESSAGE e140(/dbe/vehicle_master) RAISING prepare_failed.
  ENDIF.                                                                        "<<<N:2711659

  LOOP AT lt_vlcporder ASSIGNING <fs_vlcporder>.

    IF <fs_vlcporder>-ebeln IS NOT INITIAL.                 "N:2711659
      CALL FUNCTION 'BAPI_PO_GETDETAIL1' "#EC CI_USAGE_OK[2438131]
        EXPORTING
          purchaseorder = <fs_vlcporder>-ebeln
        IMPORTING
          poheader      = ls_poheader
        TABLES
          return        = lt_return.

      LOOP AT lt_return TRANSPORTING NO FIELDS WHERE type = lc_bapi_mtype_error .
        IF iv_called_in_exe EQ abap_true.
          RAISE prepare_failed.
        ENDIF.
      ENDLOOP.
    ENDIF.

    READ TABLE vlcactdata_cs-actdata_item ASSIGNING <fs_actdata_item> WITH KEY vguid = <fs_vlcporder>-vguid.
    IF sy-subrc <> 0.
    ENDIF.
    IF iv_called_in_exe EQ abap_true.
      READ TABLE vlcdiavehi_ct ASSIGNING <fs_vlcdiavehi> WITH KEY vguid = <fs_vlcporder>-vguid.
      IF sy-subrc <> 0.
      ENDIF.
    ELSE.
      READ TABLE list_of_vehicles_it ASSIGNING <fs_vlcdiavehi> WITH KEY vguid = <fs_vlcporder>-vguid.
    ENDIF.

*    CALL METHOD /DBE/cl_vehi_acd_utl=>get_service_material
*      EXPORTING
*        service_type = vlcactdata_cs-/DBE/ext_service_type
*        plant        = <fs_vlcdiavehi>-werks
*      IMPORTING
*        service_mat  = ls_vlcapo-service_mat
*      EXCEPTIONS
*        no_ser_mat   = 1
*        OTHERS       = 2.
*    IF sy-subrc <> 0.
*      IF iv_called_in_exe EQ abap_true.
*        RAISE prepare_failed.
*      ENDIF.
*    ENDIF.

    CALL FUNCTION '/DBE/VMASS_ADC_READ_SER_MAT_DB'
      EXPORTING
        iv_service_type = vlcactdata_cs-/dbe/ext_service_type
        iv_plant        = <fs_vlcdiavehi>-werks
      IMPORTING
        ev_service_mat  = ls_vlcapo-service_mat
      EXCEPTIONS
        no_record_found = 1
        data_incos      = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      IF iv_called_in_exe EQ abap_true.
        RAISE prepare_failed.
      ENDIF.
    ENDIF.
    TRY.
        ls_vlcapo-guid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.                                      " catch error
        RAISE prepare_failed.
    ENDTRY.
    ls_vlcapo-vguid = <fs_vlcporder>-vguid.
    ls_vlcapo-int_ord =  <fs_vlcdiavehi>-/dbe/coaufnr.
    ls_vlcapo-plant = <fs_vlcdiavehi>-werks.
    ls_vlcapo-purch_org = ls_poheader-purch_org.
    ls_vlcapo-pur_group = ls_poheader-pur_group.
    ls_vlcapo-comp_code = vlcactdata_cs-comp_code.
*    ls_vlcapo-vendor = vlcactdata_cs-lifnr.
    ls_vlcapo-vendor = vlcactdata_cs-/dbe/srvc_vendor.
    ls_vlcapo-service_type = vlcactdata_cs-/dbe/ext_service_type.
    IF <fs_actdata_item> IS ASSIGNED.                       "N:2266214
      ls_vlcapo-cost = <fs_actdata_item>-/dbe/cost.
    ENDIF.
    IF vlcactdata_cs-currency IS INITIAL.
      ls_vlcapo-currency = vlcactdata_cs-currency = ls_poheader-currency.
    ELSE.
      ls_vlcapo-currency = vlcactdata_cs-currency.
    ENDIF.
    ls_vlcapo-tax_code = vlcactdata_cs-tax_code.
    ls_vlcapo-ref_doc_no = vlcactdata_cs-ref_doc_no.
    APPEND ls_vlcapo TO vlcapo_et.

  ENDLOOP.

* we have no currency from PO so determine it from vehicle                     ">>>N:2711659
  IF vlcactdata_cs-currency IS INITIAL.
*   take currency from last vehicle like purch. org. and group
    IF iv_called_in_exe EQ abap_true.
      READ TABLE vlcdiavehi_ct ASSIGNING <fs_vlcdiavehi> WITH KEY vguid = ls_vlcapo-vguid.
    ELSE.
      READ TABLE list_of_vehicles_it ASSIGNING <fs_vlcdiavehi> WITH KEY vguid = ls_vlcapo-vguid.
    ENDIF.
    IF sy-subrc = 0.
*     Find out if new vehicle pricing or used vehicle pricing is to be used
      CALL FUNCTION '/DBE/VM08_FIND_PRICING_TYPE'
        EXPORTING
          is_vlcdiavehi        = <fs_vlcdiavehi>
        IMPORTING
          ev_pricingtype       = lv_pricingtype
        EXCEPTIONS
          determination_failed = 1
          OTHERS               = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING action_prepare_not_performed.
      ENDIF.

      CALL FUNCTION '/DBE/VM02_IOBJ_GET'
        EXPORTING
          iv_iobj_guid        = <fs_vlcdiavehi>-/dbe/iobjguid
        IMPORTING
          es_iobj_data_single = ls_iobj_data_single
        EXCEPTIONS
          error_convert       = 1
          error_iobjapi       = 2.
      IF sy-subrc <> 0.
        RAISE prepare_failed.
      ENDIF.
      IF lv_pricingtype = /dbe/cl_im_prepare_action=>gc_vehipricing_new.
        vlcactdata_cs-currency = ls_iobj_data_single-/dbe/v_imodel-purcprice_c.
      ELSEIF lv_pricingtype = /dbe/cl_im_prepare_action=>gc_vehipricing_used.
        vlcactdata_cs-currency = ls_iobj_data_single-/dbe/v_iprices-estpurpri_c.
      ENDIF.

    ENDIF.
  ENDIF.                                                                       "<<<N:2711659

  rbkp-waers = pnwtyh-/dbe/invoice_cu = vlcactdata_cs-currency.                                  "set reference currency for UI N:2304203

  IF lv_scenario = '2'.                                                        "PO does not exists for any vehicle N:2711659
    gv_ekorg_0600_visible = abap_true.
    gv_ekgrp_0600_visible = abap_true.
    IF iv_called_in_exe = abap_true.
*     set purchase org and purchase group from screen
      LOOP AT vlcapo_et ASSIGNING <fs_vlcapo>.
        <fs_vlcapo>-purch_org = vlcactdata_cs-ekorg.
        <fs_vlcapo>-pur_group = vlcactdata_cs-ekgrp.
      ENDLOOP.
    ENDIF.
  ENDIF.

********* Start : Get Payment terms, company code and TAX Procedure************
  IF iv_called_in_exe = abap_true.                          "N:2711659
    LOOP AT vlcapo_et ASSIGNING <fs_vlcapo>.
      CALL FUNCTION 'LFM1_SINGLE_READ'
        EXPORTING
          i_lifnr   = vlcactdata_cs-/dbe/srvc_vendor                           "N:2711659
          i_ekorg   = <fs_vlcapo>-purch_org                                    "N:2711659
        IMPORTING
          o_lfm1    = ls_lfm1
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc EQ 0.
        <fs_vlcapo>-pmnttrms = ls_lfm1-zterm.               "N:2711659
      ELSE.
        RAISE prepare_failed.                               "N:2711659
      ENDIF.
    ENDLOOP.
  ENDIF.

* Determine the company code which the plant is assigned to
  lv_werks = vlcactdata_cs-werks.
  CALL FUNCTION 'VELO25_DETERM_BUKRS_FROM_WERKS'
    EXPORTING
      werks_iv  = lv_werks
    IMPORTING
      bukrs_ev  = lv_bukrs
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  IF sy-subrc <> 0.
    RAISE prepare_failed.                                   "N:2711659
  ELSE.
    vlcactdata_cs-comp_code = lv_bukrs.
  ENDIF.

  IF lv_bukrs IS NOT INITIAL.
*  * Find the tax spreadsheet assigned to the company code
    CALL FUNCTION 'FIND_TAX_SPREADSHEET'
      EXPORTING
        buchungskreis = lv_bukrs
      IMPORTING
        schema        = vlcactdata_cs-kalsm
      EXCEPTIONS
        not_found     = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.
      RAISE prepare_failed.                                 "N:2711659
    ENDIF.
  ENDIF.
********* End : Get Payment terms, company code and TAX Procedure************

  LOOP AT vlcapo_et ASSIGNING <fs_vlcapo>.
    <fs_vlcapo>-comp_code = vlcactdata_cs-comp_code.
    <fs_vlcapo>-kalsm = vlcactdata_cs-kalsm.
  ENDLOOP.


  IF vlcactdata_cs-budat IS INITIAL.
    vlcactdata_cs-budat = sy-datum.
  ENDIF.

  IF vlcactdata_cs-bldat IS INITIAL.
    vlcactdata_cs-bldat = sy-datum.
  ENDIF.

ENDFUNCTION.

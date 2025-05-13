*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF43 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREPARE_INVOICE_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ININVOIE_INFO  text
*----------------------------------------------------------------------*
FORM prepare_invoice_info  .

  DATA : lt_bob           TYPE /DBE/t_veh_bobget ,
         ls_bob           TYPE /DBE/s_veh_bobget ,
         lt_bob_all       TYPE /DBE/t_veh_bob,
         ls_bob_all       TYPE /DBE/s_veh_bob,
         lt_bob_details   TYPE /DBE/t_veh_bob,
         ls_bob_details   TYPE /DBE/s_veh_bob,
         lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
         lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
         lo_veh_buf         TYPE REF TO /DBE/cl_veh_buf,
         lo_vehicle           TYPE REF TO /DBE/cl_veh_dbmvehicle,
         ls_vlcactdata_head   TYPE  vlcactdata_head_s,
         ls_vlcactdata_item   TYPE  vlcactdata_item_s,
         lt_ininvoice_info    TYPE TABLE OF tty_invoice_info,
         lr_iobj_single       TYPE REF TO /DBE/iobj_data_single_com_s,
         ls_iobj_single       TYPE  /DBE/iobj_data_single_com_s,
         lv_pricingtype       TYPE /DBE/veh_pricingtype,
         lv_tax_code          TYPE mwskz,                                                                     "N:2972000
         lv_different_tax_codes TYPE abap_bool,                                                               "N:2972000
         lv_first_vehicle       TYPE abap_bool VALUE abap_true.                                               "N:2972000


*  LOOP AT gt_vsresult_selection INTO gs_selection.
*    ls_bob-guid = gs_selection-vguid .
*    ls_bob-bobtype = '/DBE/CL_VEH_DBMVEHICLE'.
*    ls_bob-set_lock = abap_true .
*    APPEND ls_bob TO lt_bob.
*  ENDLOOP.
*  TRY.
*      CALL METHOD lo_veh_buf->get_bob
*        EXPORTING
*          it_bobget = lt_bob
*        IMPORTING
*          et_bob    = lt_bob_details.
*    CATCH /DBE/cx_veh_error_occured .
*  ENDTRY.
  IF gv_tax_calculated EQ abap_true.
**    gv_tax_calculated = abap_false.
    RETURN.
  ENDIF.

  lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).
  TRY.
    CALL METHOD lo_veh_buf->get_all
      RECEIVING
        rt_bob = lt_bob_details.
  ENDTRY.
  CLEAR: vlcactdata_head_s-netpr, vlcactdata_head_s-tax_code, vlcactdata_head_s-tax_amount, vlcactdata_head_s-gross_amount.  "N:2972000
  CLEAR: gt_ininvoice_info.
  LOOP AT gt_vsresult_selection INTO gs_selection.
    READ TABLE lt_bob_details INTO ls_bob_details WITH KEY guid = gs_selection-vguid.
    IF sy-subrc = 0 .
      lo_vehicle ?= ls_bob_details-bobref.
      TRY.
          lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.

      ls_vlcactdata_head = lr_vlcactdata_head->*.
*    CLEAR : lr_vlcactdata_head->*-gross_amount,lr_vlcactdata_head->*-tax_amount.
      MOVE-CORRESPONDING ls_vlcactdata_head TO ls_invoice_info.


      TRY.
          lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
      ls_vlcactdata_item = lr_vlcactdata_item->*.

*Fetch IObject Data

      TRY.
          lr_iobj_single ?=  lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
      IF lr_iobj_single IS BOUND.
        MOVE-CORRESPONDING  lr_iobj_single->* TO ls_iobj_single.
      ENDIF.

      MOVE ls_vlcactdata_item-vhcle TO ls_invoice_info-vhcle.

      CALL FUNCTION '/DBE/VM08_FIND_PRICING_TYPE' "NOTE: 2093139
        EXPORTING
          is_vlcactdata_item   = vlcactdata_item_s
          is_vlcactdata_head   = vlcactdata_head_s
          iv_use_last_po_info  = abap_true                        "N:2784633
        IMPORTING
          ev_pricingtype       = lv_pricingtype
        EXCEPTIONS
          determination_failed = 0
          OTHERS               = 0.
*for Used Vehicle, aimed purchase price will be net price, othewise it will be model purchase price.
      IF lv_pricingtype = gc_vehipricing_used.                    "N:2784633
        MOVE ls_iobj_single-/DBE/V_IPRICES-aimpurpri TO ls_invoice_info-/DBE/AIMED_PURCPRICE.
      ENDIF.

*     net price is taken by action prepare from PO                 N:2784633
      vlcactdata_head_s-netpr  =  ls_vlcactdata_item-netpr + vlcactdata_head_s-netpr.
      vlcactdata_head_s-tax_code = ls_vlcactdata_head-tax_code.                                             "N:2972000
      vlcactdata_head_s-tax_amount = vlcactdata_head_s-tax_amount + ls_vlcactdata_head-tax_amount.          "N:2972000
      vlcactdata_head_s-gross_amount = vlcactdata_head_s-gross_amount + ls_vlcactdata_head-gross_amount.    "N:2972000
      ls_invoice_info-netpr    = ls_vlcactdata_item-netpr.
      ls_invoice_info-currency = ls_vlcactdata_item-value_waers.
      ls_invoice_info-vhcle  = gs_selection-vhcle.
      APPEND ls_invoice_info TO gt_ininvoice_info.


*     check if different tax codes are used, then do not set tax code on UI                                  N:2972000
      IF lv_first_vehicle = abap_true.
        lv_tax_code = ls_vlcactdata_head-tax_code.
      ELSEIF lv_tax_code <> ls_vlcactdata_head-tax_code.
        lv_different_tax_codes = abap_true.
        CLEAR lv_tax_code.
      ENDIF.

      lv_first_vehicle = abap_false.                                                                        "N:2972000
    ENDIF.
  ENDLOOP.

  IF lv_different_tax_codes = abap_true.                                                                    "N:2972000
    CLEAR: vlcactdata_head_s-tax_code, vlcactdata_head_s-tax_amount, vlcactdata_head_s-gross_amount.
  ENDIF.
ENDFORM.                    " PREPARE_INVOICE_INFO

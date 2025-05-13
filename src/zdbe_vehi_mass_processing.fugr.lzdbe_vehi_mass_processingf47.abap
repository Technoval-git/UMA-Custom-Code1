*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF47 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREPARE_PO_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_po_info .
  DATA : lt_bob            TYPE /DBE/t_veh_bobget ,
           ls_bob          TYPE /DBE/s_veh_bobget ,
           lt_bob_all      TYPE /DBE/t_veh_bob,"/DBE/t_veh_bobget,
           ls_bob_all      TYPE /DBE/s_veh_bob,
           lt_bob_details  TYPE /DBE/t_veh_bob,
           ls_bob_details     TYPE /DBE/s_veh_bob,
           lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
           lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
           lo_veh_buf         TYPE REF TO /DBE/cl_veh_buf,
           lo_vehicle         TYPE REF TO /DBE/cl_veh_dbmvehicle,
           ls_vlcactdata_head   TYPE  vlcactdata_head_s,
           ls_vlcactdata_item   TYPE  vlcactdata_item_s,
           ls_po_upd_info       TYPE  tty_po_info,
           ls_po_item_diff_delv TYPE ty_po_cre_diff_delvdate,
           lr_iobj_single       TYPE REF TO /DBE/iobj_data_single_com_s,
           ls_iobj_single       TYPE  /DBE/iobj_data_single_com_s,
           lr_iobj_multi        TYPE REF TO /dbe/iobj_data_multi_com_s,
           ls_iobj_multi        TYPE  /dbe/iobj_data_multi_com_s,
           lv_pricingtype    TYPE /DBE/veh_pricingtype.

  IF gv_ok_code NE 'DD_ALL'.
    lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).

      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob_details.

    CLEAR : gt_po_upd_info ,gt_po_item_diff_delv .

    LOOP AT gt_vsresult_selection INTO gs_selection.
      READ TABLE lt_bob_details INTO ls_bob_details WITH KEY guid = gs_selection-vguid.
      IF sy-subrc = 0 .
        lo_vehicle ?= ls_bob_details-bobref.
        TRY.
            lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
          CATCH /DBE/cx_veh_layer_not_found .
        ENDTRY.
** Prepare table for PO updation
        ls_vlcactdata_head = lr_vlcactdata_head->*.

        TRY.
            lr_iobj_single ?=  lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
          CATCH /DBE/cx_veh_layer_not_found .
        ENDTRY.

        IF lr_iobj_single IS BOUND.
          MOVE-CORRESPONDING  lr_iobj_single->* TO ls_iobj_single.
        ENDIF.

        TRY.
            lr_iobj_multi ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_multi_com_s ).
            MOVE-CORRESPONDING lr_iobj_multi->* TO ls_iobj_multi.
          CATCH /dbe/cx_veh_layer_not_found .
            CLEAR ls_iobj_multi.
        ENDTRY.

        MOVE-CORRESPONDING ls_vlcactdata_head TO ls_po_upd_info.
        ls_po_upd_info-po_number = ls_vlcactdata_head-ebeln .
        ls_po_upd_info-eindt_changed = ls_vlcactdata_head-eindt .
        ls_po_upd_info-ekorg = ls_vlcactdata_head-ekorg .
        ls_po_upd_info-ekgrp = ls_vlcactdata_head-ekgrp .

        TRY.
            lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
          CATCH /DBE/cx_veh_layer_not_found .
        ENDTRY.
        ls_vlcactdata_item = lr_vlcactdata_item->*.
        MOVE ls_vlcactdata_item-vguid TO ls_po_upd_info-vguid.
        MOVE ls_vlcactdata_item-vhcle TO ls_po_upd_info-vhcle.
        MOVE ls_iobj_single-/DBE/V_IMODEL-mcodesd TO ls_po_upd_info-mcodesd.
        MOVE ls_vlcactdata_item-netpr TO ls_po_upd_info-netpr.
        MOVE ls_vlcactdata_item-po_item TO ls_po_upd_info-po_item.
        IF ls_vlcactdata_item-eindt_changed IS NOT INITIAL.
          MOVE ls_vlcactdata_item-eindt_changed TO ls_po_upd_info-eindt_changed.
        ENDIF.
        IF ls_vlcactdata_item-po_number IS NOT INITIAL.
          MOVE ls_vlcactdata_item-po_number TO ls_po_upd_info-po_number.
        ENDIF.
        ls_po_upd_info-vhcle  = gs_selection-vhcle.

        PERFORM calculate_option_price USING    ls_iobj_multi
                                                ls_po_upd_info-currency
                                       CHANGING ls_po_upd_info-optpr.

        APPEND ls_po_upd_info TO gt_po_upd_info.

** Prepare the table for PO creation with Different delivery date
        MOVE ls_vlcactdata_item-vguid TO ls_po_item_diff_delv-vguid.
        MOVE ls_vlcactdata_item-vhcle TO ls_po_item_diff_delv-vhcle.
        MOVE ls_vlcactdata_item-netpr TO ls_po_item_diff_delv-netpr.
*        MOVE ls_vlcactdata_item-po_item TO ls_po_item_diff_delv-po_item.


        MOVE ls_iobj_single-/DBE/V_IMODEL-mcodesd TO ls_po_item_diff_delv-mcodesd.
        MOVE ls_vlcactdata_head-currency TO ls_po_item_diff_delv-currency.
        MOVE ls_vlcactdata_head-ekorg TO ls_po_item_diff_delv-ekorg.
        MOVE ls_vlcactdata_head-ekgrp TO ls_po_item_diff_delv-ekgrp.
        MOVE ls_vlcactdata_head-currency TO ls_po_item_diff_delv-currency.
        MOVE gs_selection-vhcle TO ls_po_item_diff_delv-vhcle.

        CALL FUNCTION '/DBE/VM08_FIND_PRICING_TYPE'  "NOTE: 2093139
          EXPORTING
            is_vlcactdata_item   = ls_vlcactdata_item    "N:2784633
            is_vlcactdata_head   = ls_vlcactdata_head    "N:2784633
          IMPORTING
            ev_pricingtype       = lv_pricingtype
          EXCEPTIONS
            determination_failed = 0
            OTHERS               = 0.

        IF lv_pricingtype = gc_vehipricing_used.         "N:2784633
          MOVE ls_iobj_single-/DBE/V_IPRICES-aimpurpri TO ls_po_item_diff_delv-/DBE/AIMED_PURCPRICE.
          MOVE ls_iobj_single-/DBE/V_IPRICES-estpurpri TO ls_po_item_diff_delv-/DBE/EST_PURCPRICE.
        ENDIF.
        IF ls_vlcactdata_head-eindt IS NOT INITIAL.                            "N:2773495
          MOVE ls_vlcactdata_head-eindt TO ls_po_item_diff_delv-eindt.
        ENDIF.
        IF ls_vlcactdata_item-eindt_changed IS NOT INITIAL.                    "N:2773495
          MOVE ls_vlcactdata_item-eindt_changed TO ls_po_item_diff_delv-eindt.
        ENDIF.

        PERFORM calculate_option_price USING    ls_iobj_multi
                                                ls_po_item_diff_delv-currency
                                       CHANGING ls_po_item_diff_delv-optpr.

        APPEND ls_po_item_diff_delv TO gt_po_item_diff_delv.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " PREPARE_PO_INFO

*&---------------------------------------------------------------------*
*&      Form  CHECK_USED_VEHICLE                              N:2784633
*&---------------------------------------------------------------------*
FORM check_used_vehicle USING    iv_use_last_po_info TYPE abap_bool
                        CHANGING cv_used_vehicle     TYPE abap_bool.

  DATA:
           lt_bob_details     TYPE /DBE/t_veh_bob,
           ls_bob_details     TYPE /DBE/s_veh_bob,
           lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
           lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
           lo_veh_buf         TYPE REF TO /DBE/cl_veh_buf,
           lo_vehicle         TYPE REF TO /DBE/cl_veh_dbmvehicle,
           lv_pricingtype     TYPE /DBE/veh_pricingtype.

  lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).

    CALL METHOD lo_veh_buf->get_all
      RECEIVING
        rt_bob = lt_bob_details.

  cv_used_vehicle = abap_false.

  LOOP AT gt_vsresult_selection INTO gs_selection.
    READ TABLE lt_bob_details INTO ls_bob_details WITH KEY guid = gs_selection-vguid.
    IF sy-subrc = 0 .
      lo_vehicle ?= ls_bob_details-bobref.
      TRY.
          lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.

      TRY.
          lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.


      CALL FUNCTION '/DBE/VM08_FIND_PRICING_TYPE'
        EXPORTING
          is_vlcactdata_item   = lr_vlcactdata_item->*
          is_vlcactdata_head   = lr_vlcactdata_head->*
        IMPORTING
          ev_pricingtype       = lv_pricingtype
        EXCEPTIONS
          determination_failed = 0
          OTHERS               = 0.

      IF lv_pricingtype <> gc_vehipricing_new.
        cv_used_vehicle = abap_true.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form calculate_option_price
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM calculate_option_price  USING    is_iobj_multi TYPE /dbe/iobj_data_multi_com_s
                                      iv_currency
                             CHANGING cv_price.

  CLEAR cv_price.

  LOOP AT is_iobj_multi-/dbe/v_ioption ASSIGNING FIELD-SYMBOL(<ls_ioption>) WHERE mmnoord IS INITIAL.
    IF <ls_ioption>-puprc_c = iv_currency.
      DATA(lv_puprc) = <ls_ioption>-puprc.
    ELSE.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          date             = sy-datum
          foreign_amount   = <ls_ioption>-puprc
          foreign_currency = <ls_ioption>-puprc_c
          local_currency   = iv_currency
        IMPORTING
          local_amount     = lv_puprc
        EXCEPTIONS
          no_rate_found    = 1
          overflow         = 2
          no_factors_found = 3
          no_spread_found  = 4
          derived_2_times  = 5
          OTHERS           = 6.
      IF sy-subrc <> 0.
        lv_puprc = <ls_ioption>-puprc.
      ENDIF.
    ENDIF.

    ADD lv_puprc TO cv_price.
  ENDLOOP.

ENDFORM.

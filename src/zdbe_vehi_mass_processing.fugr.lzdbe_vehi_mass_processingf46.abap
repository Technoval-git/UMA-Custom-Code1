*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF46 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREPARE_INVOICE_CANCEL_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_invoice_cancel_info .
  DATA : lt_bob TYPE /DBE/t_veh_bobget ,
         ls_bob TYPE /DBE/s_veh_bobget ,
         lt_bob_all TYPE /DBE/t_veh_bob,"/DBE/t_veh_bobget,
         ls_bob_all TYPE /DBE/s_veh_bob,
         lt_bob_details TYPE /DBE/t_veh_bob,
         ls_bob_details TYPE /DBE/s_veh_bob,
         lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
         lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
         lo_veh_buf TYPE REF TO /DBE/cl_veh_buf,
         lo_vehicle TYPE REF TO /DBE/cl_veh_dbmvehicle,
         ls_vlcactdata_head  TYPE  vlcactdata_head_s,
         ls_vlcactdata_item  TYPE  vlcactdata_item_s,
         lt_ininvoice_info TYPE TABLE OF tty_invoice_info.


  lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).
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
  TRY.
    CALL METHOD lo_veh_buf->get_all
      RECEIVING
        rt_bob = lt_bob_details.
  ENDTRY.



  LOOP AT gt_vsresult_selection INTO gs_selection.
    READ TABLE lt_bob_details INTO ls_bob_details WITH KEY guid = gs_selection-vguid.
    IF sy-subrc = 0 .
      lo_vehicle ?= ls_bob_details-bobref.
      TRY.
          lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.

      ls_vlcactdata_head = lr_vlcactdata_head->*.
*      MOVE ls_vlcactdata_head-tax_code TO ls_invoice_info-tax_code.
      MOVE-CORRESPONDING ls_vlcactdata_head TO ls_invoice_info.


      TRY.
          lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
      ls_vlcactdata_item = lr_vlcactdata_item->*.

      MOVE ls_vlcactdata_item-vhcle TO ls_invoice_info-vhcle.
      MOVE ls_vlcactdata_item-netpr TO ls_invoice_info-netpr.
*    MOVE ls_vlcactdata_item-currency to ls_invoice_info-currency.
      ls_invoice_info-vhcle  = gs_selection-vhcle.
      APPEND ls_invoice_info TO gt_ininvoice_info.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " PREPARE_INVOICE_CANCEL_INFO

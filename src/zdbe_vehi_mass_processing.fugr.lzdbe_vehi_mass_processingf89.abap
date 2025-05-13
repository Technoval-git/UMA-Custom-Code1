*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF89 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_ACTION_CANCEL_INVOICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_GUIDS  text
*----------------------------------------------------------------------*
FORM set_action_cancel_invoice  TABLES  lt_guids.

  DATA : lt_all_guids        TYPE TABLE OF vlcguid.
  DATA : lt_invoice_guids    TYPE TABLE OF vlcguid.
  DATA : ls_invoice_guids    TYPE vlcguid.
  DATA : lt_invoice          TYPE TABLE OF vlcincinvoice.
  DATA : ls_inc_invoice      TYPE vlcincinvoice.
  DATA : ls_bobget           TYPE /DBE/s_veh_bobget.
  DATA : lt_bobget           TYPE /DBE/t_veh_bobget.
  DATA : lv_fiscalyear       TYPE vlcincinvoice-gjahr.
  DATA : lv_invoicedocnumber TYPE vlcincinvoice-belnr.
  DATA : lv_ref_doc_no       TYPE vlcincinvoice-xblnr.
  DATA : ls_req_data         TYPE /DBE/req_vehicle_data.
  DATA : lt_bob_details      TYPE /DBE/t_veh_bob.
  DATA : lr_vlcdiavehi       TYPE REF TO vlcdiavehi.
  DATA : ls_selection        TYPE /DBE/vsresult.
  DATA : lo_buf              TYPE REF TO /DBE/cl_veh_buf.         "N:2304203
  DATA : lt_bob              TYPE /DBE/t_veh_bob.
  DATA : ls_bob              TYPE /DBE/s_veh_bob.
  DATA : ls_guid             TYPE vlcguid.
  DATA : lo_veh              TYPE REF TO /DBE/cl_veh_dbmvehicle.
  DATA : lr_vlcactdata_head  TYPE REF TO vlcactdata_head_s.

  CLEAR lt_invoice.
*Read Invoice details
  CALL FUNCTION 'VELO14_READ_INCINVOICES'
    EXPORTING
      actdoctype_iv    = 'QINV'
      reversalflag_iv  = ''
      latest_iv        = 'X'  " flag added for CRT4
    TABLES
      vguids_it        = lt_guids
      incinvs_et       = lt_invoice
    EXCEPTIONS
      no_entries_found = 1
      no_data_received = 2
      OTHERS           = 3.
  IF sy-subrc = 0.
    SORT lt_invoice BY belnr gjahr DESCENDING.
    CLEAR lt_invoice_guids.
    LOOP AT lt_invoice INTO ls_inc_invoice .

      lv_invoicedocnumber = ls_inc_invoice-belnr.
      lv_fiscalyear = ls_inc_invoice-gjahr.
      lv_ref_doc_no = ls_inc_invoice-xblnr.

      CLEAR lt_all_guids.
      "For all distinct invoice numbers , read the vehicles belonging to the invoice
      AT NEW belnr.
        CALL FUNCTION 'VELO14_READ_GUIDS_INCINVOICE'
          EXPORTING
            actdoctype_iv   = 'QINV'
            reversalflag_iv = ' '
            belnr_iv        = lv_invoicedocnumber
            gjahr_iv        = lv_fiscalyear
          TABLES
            vguids_et       = lt_all_guids
          EXCEPTIONS
            no_record_found = 1
            OTHERS          = 2.
      ENDAT.
    ENDLOOP.

    CLEAR : lt_bobget , ls_bobget ,gs_selection.
    SORT lt_all_guids BY vguid.
    IF lo_buf IS NOT BOUND.
      CALL METHOD /DBE/cl_veh_buf=>get_instance
        RECEIVING
          ro_instance = lo_buf.
    ENDIF.
    IF lo_buf IS BOUND.
      TRY.
          CALL METHOD lo_buf->get_all
            RECEIVING
              rt_bob = lt_bob.
      ENDTRY.
    ENDIF.

    LOOP AT lt_all_guids INTO ls_invoice_guids.
      READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_invoice_guids-vguid.
      IF sy-subrc = 0. " guid is included in selection and buffer
      ELSE. " collect all guids of invoice if they are not selected
        ls_bobget-guid     = ls_invoice_guids-vguid.
        ls_bobget-bobtype  = '/DBE/CL_VEH_DBMVEHICLE'.
        ls_bobget-set_lock = 'X'.
        APPEND ls_bobget TO lt_bobget.
      ENDIF.
    ENDLOOP.
* read the vehicle details which are not selected
    ls_req_data-vms_text = abap_true.
    ls_req_data-iobj_gentext = abap_true.
    TRY.
        CALL METHOD /DBE/cl_veh_dbmvehicle=>get_dbmvehicle
          EXPORTING
            it_bobget          = lt_bobget
            is_req_data        = ls_req_data
            iv_iobj_req        = abap_true
*           iv_no_archive      =
            iv_mode_vlcvehicle = 'E'
            iv_scope           = '1'
            iv_wait            = space
            iv_collect         = space
          IMPORTING
            et_bob             = lt_bob_details.
      CATCH /DBE/cx_veh_error_occured .
      CATCH cx_dynamic_check .
    ENDTRY.
    CLEAR ls_guid.
    LOOP AT lt_all_guids INTO ls_guid.  "guids in current invoice
      CLEAR ls_bob.
      " Apply the invoice details for the selected vehicles
      READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_guid-vguid.
      IF sy-subrc = 0 .
        lo_veh ?= ls_bob-bobref.
        TRY.
            lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
          CATCH /DBE/cx_veh_layer_not_found .
        ENDTRY.
        lr_vlcactdata_head->*-invoicedocnumber  = lv_invoicedocnumber .
        lr_vlcactdata_head->*-fiscalyear = lv_fiscalyear.
        lr_vlcactdata_head->*-ref_doc_no = lv_ref_doc_no.
        " set data in the COM layer
        TRY.
            CALL METHOD lo_veh->/DBE/if_veh_bob~set_bob .
          CATCH /DBE/cx_veh_static_check .
        ENDTRY.

      ENDIF.
      CLEAR ls_bob.
* Apply the invoice details for newly found vehicles
      READ TABLE lt_bob_details INTO ls_bob WITH KEY guid = ls_guid-vguid.
      IF sy-subrc = 0 .
        lo_veh ?= ls_bob-bobref.
        TRY.
            lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
          CATCH /DBE/cx_veh_layer_not_found .
        ENDTRY.
        lr_vlcactdata_head->*-invoicedocnumber  = lv_invoicedocnumber .
        lr_vlcactdata_head->*-fiscalyear = lv_fiscalyear.
        lr_vlcactdata_head->*-ref_doc_no = lv_ref_doc_no.
        " set action
        TRY.
            CALL METHOD lo_veh->set_action
              EXPORTING
                iv_action     = gv_action
                iv_wo_prepare = abap_true.
          CATCH /DBE/cx_veh_action_not_defined .
          CATCH /DBE/cx_veh_static_check .
        ENDTRY.
        TRY.
            lr_vlcdiavehi ?= lo_veh->get_data_com( lo_veh->gc_vlcdiavehi ).
            MOVE-CORRESPONDING lr_vlcdiavehi->* TO ls_selection.
            APPEND ls_selection TO gt_vsresult_selection.
          CATCH /DBE/cx_veh_layer_not_found .
        ENDTRY.

      ENDIF.

    ENDLOOP.
*
*    ENDLOOP.
  ENDIF.
  IF lo_buf IS NOT BOUND.                                   "2223599

    CALL METHOD /DBE/cl_veh_buf=>get_instance
      RECEIVING
        ro_instance = lo_buf.

  ENDIF.
  IF lo_buf IS BOUND.
    TRY.

        CALL METHOD lo_buf->set_all .
      CATCH /DBE/cx_veh_error_occured .
      CATCH cx_static_check .
    ENDTRY.
  ENDIF.

ENDFORM.                    " SET_ACTION_CANCEL_INVOICE

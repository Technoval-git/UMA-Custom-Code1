FUNCTION ZDBE_VEH_PO_MODIF_NEW.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(VLCDIAVEHI_IT) TYPE  VLCDIAVEHI_T
*"     REFERENCE(VLCACTDATA_IS) TYPE  VLCACTDATA
*"     REFERENCE(IV_MODE) TYPE  CHAR6
*"  EXPORTING
*"     REFERENCE(VLCH_MSSG_CT) TYPE  VLCH_MSSG_PT
*"  CHANGING
*"     REFERENCE(PURCHASEORDER_CV) TYPE  BAPIMEPOHEADER-PO_NUMBER
*"         OPTIONAL
*"     REFERENCE(POHEADER_CS) TYPE  BAPIMEPOHEADER OPTIONAL
*"     REFERENCE(POHEADERX_CS) TYPE  BAPIMEPOHEADERX OPTIONAL
*"     REFERENCE(POADDRVENDOR_CS) TYPE  BAPIMEPOADDRVENDOR OPTIONAL
*"     REFERENCE(TESTRUN_CV) TYPE  BAPIFLAG-BAPIFLAG OPTIONAL
*"     REFERENCE(MEMORY_UNCOMPLETE_CV) TYPE  BAPIFLAG-BAPIFLAG
*"         OPTIONAL
*"     REFERENCE(MEMORY_COMPLETE_CV) TYPE  BAPIFLAG-BAPIFLAG OPTIONAL
*"     REFERENCE(POEXPIMPHEADER_CS) TYPE  BAPIEIKP OPTIONAL
*"     REFERENCE(POEXPIMPHEADERX_CS) TYPE  BAPIEIKPX OPTIONAL
*"     REFERENCE(VERSIONS_CS) TYPE  BAPIMEDCM OPTIONAL
*"     REFERENCE(POITEM_CT) TYPE  MDS_BAPI_PO_ITEM_TAB OPTIONAL
*"     REFERENCE(POITEMX_CT) TYPE  MDS_BAPI_PO_ITEMX_TAB OPTIONAL
*"     REFERENCE(POADDRDELIVERY_CT) TYPE  VLC_BAPIMEPOADDRDELIVERY_T
*"         OPTIONAL
*"     REFERENCE(POSCHEDULE_CT) TYPE  MDS_BAPI_PO_SCHEDULE_TAB
*"         OPTIONAL
*"     REFERENCE(POSCHEDULEX_CT) TYPE  MDS_BAPI_PO_SCHEDULEX_TAB
*"         OPTIONAL
*"     REFERENCE(POACCOUNT_CT) TYPE  VLC_BAPIMEPOACCOUNT_T OPTIONAL
*"     REFERENCE(POACCOUNTPROFITSEGMENT_CT) TYPE
*"                             VLC_BAPIMEPOACCNTPRFTSEGMENT_T
*"         OPTIONAL
*"     REFERENCE(POACCOUNTX_CT) TYPE  VLC_BAPIMEPOACCOUNTX_T OPTIONAL
*"     REFERENCE(POCONDHEADER_CT) TYPE  VLC_BAPIMEPOCONDHEADER_T
*"         OPTIONAL
*"     REFERENCE(POCONDHEADERX_CT) TYPE  VLC_BAPIMEPOCONDHEADERX_T
*"         OPTIONAL
*"     REFERENCE(POCOND_CT) TYPE  VLC_BAPIMEPOCOND_T OPTIONAL
*"     REFERENCE(POCONDX_CT) TYPE  VLC_BAPIMEPOCONDX_T OPTIONAL
*"     REFERENCE(POLIMITS_CT) TYPE  VLC_BAPIESUHC_T OPTIONAL
*"     REFERENCE(POCONTRACTLIMITS_CT) TYPE  VLC_BAPIESUCC_T OPTIONAL
*"     REFERENCE(POSERVICES_CT) TYPE  VLC_BAPIESLLC_T OPTIONAL
*"     REFERENCE(POSRVACCESSVALUES_CT) TYPE  VLC_BAPIESKLC_T OPTIONAL
*"     REFERENCE(POSERVICESTEXT_CT) TYPE  VLC_BAPIESLLTX_T OPTIONAL
*"     REFERENCE(EXTENSIONIN_CT) TYPE  VLC_BAPIPAREX_T OPTIONAL
*"     REFERENCE(EXTENSIONOUT_CT) TYPE  VLC_BAPIPAREX_T OPTIONAL
*"     REFERENCE(POEXPIMPITEM_CT) TYPE  VLC_BAPIEIPO_T OPTIONAL
*"     REFERENCE(POEXPIMPITEMX_CT) TYPE  VLC_BAPIEIPOX_T OPTIONAL
*"     REFERENCE(POPARTNER_CT) TYPE  VLC_BAPIEKKOP_T OPTIONAL
*"     REFERENCE(ALLVERSIONS_CT) TYPE  VLC_BAPIMEDCM_ALLVERSIONS_T
*"     REFERENCE(POTEXTITEM_CT) TYPE  VLC_BAPIMEPOTEXT_T
*"     REFERENCE(POTEXTHEADER_CT) TYPE  VLC_BAPIMEPOTEXTHEADER_T
*"  EXCEPTIONS
*"      PROCESSING_IMPOSSIBLE
*"--------------------------------------------------------------------

* ------------------------------------------------------------------------
* ---Data Declaration
* ------------------------------------------------------------------------
*--> local data for data preparation step 1.)
*--> structure and table for IV_IOBJ_GUID
  DATA: ls_vlcdiavehi             TYPE vlcdiavehi.
  DATA: lt_vlcguid                TYPE vlcguid_t.
  DATA: ls_vlcguid                LIKE LINE  OF lt_vlcguid.
  DATA: lv_iobjguid               TYPE /dbe/exts_ouid.
  DATA: lv_dbe_coaufnr            TYPE vlcvehicle-/dbe/coaufnr.
  DATA: lv_category_id            TYPE /dbe/exts_category_id.
  DATA: ls_iobj_data_single       TYPE /dbe/iobj_data_single_txt_s.
  DATA: ls_iobj_data_multi        TYPE /dbe/iobj_data_multi_txt_s.
  DATA: lt_return                 TYPE TABLE OF bapiret2.
*--> error message handling
  DATA: ls_vlch_mssg              TYPE vlch_mssg_ps.
*--> local data for INI-file values
  DATA: lv_bustype_uc             TYPE /dbe/ctrl_value.
  DATA: lv_bustype_nc             TYPE /dbe/ctrl_value.
  DATA: lv_qopt                   TYPE /dbe/ctrl_value.                       "condition type for options
  DATA: lv_qdam                   TYPE /dbe/ctrl_value.                        "condition type for damages
  DATA: lv_cnpr                   TYPE /dbe/ctrl_value.                        "changed net-price
  DATA: lt_bapi_po_schedules      TYPE TABLE OF bapimeposchedule.
  DATA: lv_index                  TYPE sy-tabix.
*--> local data for create/ update/ delete items for missing handover articles step 3.)
  DATA: ls_v_ioption              TYPE LINE OF /dbe/v_ioption_dynp_t.
  DATA: lt_v_ioption              TYPE /dbe/v_ioption_dynp_t.
  DATA: ls_purch_order_item       TYPE bapimepoitem.
  DATA: ls_purch_order_itemx      TYPE bapimepoitemx.
*--> local data for conditions for new vehicles options
  DATA: lt_bapi_po_cond_qopt      TYPE TABLE OF bapimepocond.
  DATA: lt_porders                TYPE TABLE OF vlcporder.
  DATA: lv_po_number              TYPE bapiekko-po_number.
  DATA: lt_bapi_return            TYPE TABLE OF bapiret2.
  DATA: ls_bapi_po_header         TYPE bapimepoheader.
  DATA: ls_bapi_po_items_all      TYPE bapimepoitem.
  DATA: lt_bapi_po_items_all      TYPE TABLE OF bapimepoitem.
  DATA: lt_bapi_po_items          TYPE TABLE OF bapimepoitem.
  DATA: lt_bapi_po_account        TYPE TABLE OF bapimepoaccount.
  DATA: ls_bapi_po_cond           TYPE bapimepocond.
  DATA: lt_bapi_po_cond           TYPE TABLE OF bapimepocond.
  DATA: lt_extensionout           TYPE bapiparex_tp.
  DATA: ls_extensionout           TYPE bapiparex.
  DATA: lv_tabix_old              TYPE sy-tabix.
  DATA: lv_ebelp_last             TYPE ebelp.
  DATA: ls_pocond_ct              TYPE bapimepocond.
  DATA: ls_pocondx_ct             TYPE bapimepocondx.
  DATA: ls_potextitem             TYPE bapimepotext.
  DATA: lv_lflag                  TYPE c VALUE 'L'.                 "deletion flag for PO item
  DATA: poschedule_lt             TYPE TABLE OF bapimeposchedule.
  DATA: poschedulex_lt            TYPE TABLE OF bapimeposchedulx.
  DATA: lt_iobj_data_single_com   TYPE /dbe/iobj_data_single_com_t.
  DATA: lt_iobj_data_multi_com    TYPE /dbe/iobj_data_multi_com_t.
  DATA: ls_iobj_data_single_com   TYPE /dbe/iobj_data_single_com_s.
  DATA: ls_iobj_data_multi_com    TYPE /dbe/iobj_data_multi_com_s.
  DATA: ls_iobj_data_single_txt   TYPE /dbe/iobj_data_single_txt_s.
  DATA: ls_iobj_data_multi_txt    TYPE /dbe/iobj_data_multi_txt_s.

  DATA: ls_actdata_item           TYPE vlcactdata_item_s.
  DATA: lo_veh_buf                TYPE REF TO /dbe/cl_veh_buf.
  DATA: lo_vehicle                TYPE REF TO /dbe/cl_veh_dbmvehicle.
  DATA: lt_vehicles               TYPE /dbe/t_veh_bob.
  DATA: ls_vehicle                TYPE /dbe/s_veh_bob.
  DATA: lo_object                 TYPE REF TO /dbe/cl_veh_iobject_vehicle.
  DATA: lv_tabix                  TYPE sy-tabix.
  DATA: lt_iobj_data_single       TYPE /dbe/iobj_data_single_com_t.
  DATA: lt_iobj_data_multi        TYPE /dbe/iobj_data_multi_com_t.
  DATA: lr_iobj_single            TYPE REF TO /dbe/iobj_data_single_com_s.
  DATA: lr_iobj_multi             TYPE REF TO /dbe/iobj_data_multi_com_s.
  DATA: purch_order_schedule_cs   TYPE bapimeposchedule.
  DATA: purch_order_schedulex_cs  TYPE bapimeposchedulx.
  DATA: lv_iobj_exist             TYPE boole_d .
  DATA: lv_pricing_type           TYPE /dbe/veh_pricingtype.

*--> Get IOBJGUID and VlCGUID
  LOOP AT vlcdiavehi_it INTO ls_vlcdiavehi.
*   Only for DBM vehicles
    IF ls_vlcdiavehi-/dbe/iobjguid IS INITIAL.
      RETURN.
    ENDIF.
    ls_vlcguid = ls_vlcdiavehi-vguid.                                  "vguid
    lv_iobjguid = ls_vlcdiavehi-/dbe/iobjguid.                              "iobjguid
    APPEND ls_vlcguid TO lt_vlcguid.
  ENDLOOP.

  lo_veh_buf  = /dbe/cl_veh_buf=>get_instance( ) .
  IF lo_veh_buf  IS BOUND .
* Case 1    => Mass processing in DBM 6.0
* Case 2    => single vehicle processing
*--> Get IOBJECT Data from buffer
    lt_vehicles = lo_veh_buf->get_all( ). "get vehicles from vehicle buffer
    LOOP AT lt_vehicles INTO ls_vehicle .
      READ TABLE lt_vlcguid INTO ls_vlcguid WITH KEY vguid = ls_vehicle-guid.
      IF sy-subrc = 0 .
        lo_vehicle ?= ls_vehicle-bobref.  "get vehicle object
        lo_object ?= lo_vehicle->iobject_get( ).  "get vehicle iobject
        TRY.
            lr_iobj_single ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
            ls_iobj_data_single_com = lr_iobj_single->*.
            IF ls_iobj_data_single_com-/dbe/v_vehicle-vguid IS INITIAL. "2303703
              MOVE  ls_vehicle-guid TO ls_iobj_data_single_com-/dbe/v_vehicle-vguid.
            ENDIF.
            APPEND ls_iobj_data_single_com TO lt_iobj_data_single_com.
          CATCH  /dbe/cx_veh_layer_not_found.
        ENDTRY.
        TRY.
            lr_iobj_multi ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_multi_com_s ).
            ls_iobj_data_multi_com = lr_iobj_multi->*.
            APPEND ls_iobj_data_multi_com TO lt_iobj_data_multi_com.
          CATCH  /dbe/cx_veh_layer_not_found.
        ENDTRY.
      ENDIF.
    ENDLOOP.

    IF lt_iobj_data_single_com IS  INITIAL AND lt_iobj_data_multi_com IS INITIAL.
      lv_iobj_exist   = abap_false.
      "while processing single vehicle via transaction, iobject details are not filled
    ELSE.
      lv_iobj_exist   = abap_true. "Mass processing
    ENDIF.
  ELSE.
    lv_iobj_exist   = abap_false.   "Single vehicle processing in DBM 6.0
  ENDIF.

  IF lv_iobj_exist  = abap_false.   "Single vehicle processing
    LOOP AT lt_vlcguid INTO ls_vlcdiavehi-vguid .
      lv_iobjguid = ls_vlcdiavehi-/dbe/iobjguid.
*--> Get IOBJECT Data from DB
      CALL FUNCTION '/DBE/VM02_IOBJ_GET'
        EXPORTING
          iv_iobj_guid        = lv_iobjguid
        IMPORTING
          ev_category_id      = lv_category_id
          es_iobj_data_single = ls_iobj_data_single_txt
          es_iobj_data_multi  = ls_iobj_data_multi_txt
          et_bapireturn       = lt_return
        EXCEPTIONS
          error_convert       = 1
          error_iobjapi       = 2
          OTHERS              = 3.
*--> Error Handling
      IF sy-subrc <> 0.
        ls_vlch_mssg-vguid     = ls_vlcguid.
        ls_vlch_mssg-msgid     = sy-msgid.
        ls_vlch_mssg-msgty     = sy-msgty.
        ls_vlch_mssg-msgno     = sy-msgno.
        ls_vlch_mssg-msgv1     = sy-msgv1.
        ls_vlch_mssg-msgv2     = sy-msgv2.
        ls_vlch_mssg-msgv3     = sy-msgv3.
        ls_vlch_mssg-msgv4     = sy-msgv4.
        APPEND ls_vlch_mssg TO vlch_mssg_ct.
        RAISE processing_impossible.
      ENDIF.
* Transfer data from work layer to COM layer
      MOVE-CORRESPONDING ls_iobj_data_single_txt-/dbe/v_imodel TO ls_iobj_data_single_com-/dbe/v_imodel.
      MOVE-CORRESPONDING ls_iobj_data_single_txt-/dbe/v_iprices TO ls_iobj_data_single_com-/dbe/v_iprices.
      MOVE-CORRESPONDING ls_iobj_data_single_txt-/dbe/v_vehicle TO ls_iobj_data_single_com-/dbe/v_vehicle.
      MOVE ls_vlcdiavehi-/dbe/iobjguid TO ls_iobj_data_single_com-/dbe/v_vehicle-/dbe/iobjguid.
      MOVE ls_vlcdiavehi-vguid TO ls_iobj_data_single_com-/dbe/v_vehicle-vguid.
      APPEND ls_iobj_data_single_com TO lt_iobj_data_single_com.

      ls_iobj_data_multi_com-/dbe/v_ioptiont = ls_iobj_data_multi_txt-/dbe/v_ioptiont .
      ls_iobj_data_multi_com-/dbe/v_ioption = ls_iobj_data_multi_txt-/dbe/v_ioption .
      ls_iobj_data_multi_com-/dbe/v_vehicle = ls_iobj_data_multi_txt-/dbe/v_vehicle .
      MOVE ls_vlcdiavehi-/dbe/iobjguid TO ls_iobj_data_multi_com-/dbe/v_vehicle-/dbe/iobjguid.
      MOVE ls_vlcdiavehi-vguid TO ls_iobj_data_multi_com-/dbe/v_vehicle-vguid.
      APPEND ls_iobj_data_multi_com TO lt_iobj_data_multi_com.
    ENDLOOP.
  ENDIF.
*--> Get business transaction type for new vehicle


  CALL FUNCTION '/DBE/VM08_FIND_PRICING_TYPE'          " INI  FM's for bt types are obsolete
    EXPORTING
      is_vlcdiavehi        = ls_vlcdiavehi
    IMPORTING
      ev_pricingtype       = lv_pricing_type
    EXCEPTIONS
      determination_failed = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    RAISE processing_impossible.
    EXIT.
  ENDIF.
*--> Get customized condition type for the changed net price
  CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
    EXPORTING
      object               = gc_cond_netprice
    IMPORTING
      value                = lv_cnpr                            "changed net price condition
    EXCEPTIONS
      object_not_defined   = 0
      value_not_maintained = 0
      OTHERS               = 0.

*--> Get customized condition type for the options
  CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
    EXPORTING
      object               = gc_cond_optnew
    IMPORTING
      value                = lv_qopt                           "new vehicle options
    EXCEPTIONS
      object_not_defined   = 0
      value_not_maintained = 0
      OTHERS               = 0.

  IF iv_mode = mode_change_gc..
*--> Read PO data of the vehicle from the DB.
*    (VELO10_MORD_EXECUTE provides only changes on vehicle items
*    and not all items like missing handover articles)
********************************************************************
*--> Determine the PO data from DB
    lv_po_number = purchaseorder_cv.
    CALL FUNCTION 'BAPI_PO_GETDETAIL1' "#EC CI_USAGE_OK[2438131]
      EXPORTING
        purchaseorder      = lv_po_number
        account_assignment = gc_xflag
      IMPORTING
        poheader           = ls_bapi_po_header
      TABLES
        return             = lt_bapi_return
        poitem             = lt_bapi_po_items_all
        poschedule         = lt_bapi_po_schedules
        poaccount          = lt_bapi_po_account
        pocond             = lt_bapi_po_cond
        extensionout       = lt_extensionout.
*--> Error handling

*--> determine the latest item number in PO
    CLEAR: lv_tabix_old, lv_ebelp_last.
    DESCRIBE TABLE lt_bapi_po_items_all LINES lv_tabix_old.
    READ TABLE lt_bapi_po_items_all INDEX lv_tabix_old INTO ls_bapi_po_items_all.
    IF sy-subrc = 0.
      lv_ebelp_last = ls_bapi_po_items_all-po_item.
    ENDIF.

*--> WORK-AROUND: update the Net-price and PBXX for PO Change
    LOOP AT lt_bapi_po_items_all INTO ls_purch_order_item.
*      lv_tabix  = sy-tabix .
      READ TABLE vlcactdata_is-actdata_item INTO ls_actdata_item WITH KEY po_item = ls_purch_order_item-po_item TRANSPORTING vguid .
      IF sy-subrc = 0.
        READ TABLE lt_iobj_data_single_com INTO ls_iobj_data_single_com WITH KEY /dbe/v_vehicle-vguid = ls_actdata_item-vguid. "2303703
*   Change the net price
        IF sy-subrc = 0 .
          CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
            EXPORTING
              currency        = vlcactdata_is-currency
              amount_internal = ls_iobj_data_single_com-/dbe/v_imodel-purcprice
            IMPORTING
              amount_external = ls_purch_order_item-net_price.

          CLEAR ls_purch_order_item-calctype.
          MODIFY poitem_ct FROM ls_purch_order_item TRANSPORTING net_price calctype WHERE po_item = ls_purch_order_item-po_item .
        ENDIF.

*   corresponding poitemx table                                                              " new vehicle
        READ TABLE poitemx_ct INTO ls_purch_order_itemx WITH KEY po_item = ls_purch_order_item-po_item.
        IF sy-subrc = 0 .
          ls_purch_order_itemx-net_price = gc_xflag.
          CLEAR ls_purch_order_itemx-calctype.
          MODIFY poitemx_ct FROM ls_purch_order_itemx TRANSPORTING net_price calctype WHERE po_item = ls_purch_order_item-po_item .
        ENDIF.


*     overwrite the condition PBXX (or what is customized)
*      ls_pocond_ct-cond_value = ls_iobj_data_single-/DBE/V_IMODEL-purcprice.
        ls_pocond_ct-currency = ls_iobj_data_single_com-/dbe/v_imodel-purcprice_c.
        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
          EXPORTING
            currency        = vlcactdata_is-currency
            amount_internal = ls_iobj_data_single_com-/dbe/v_imodel-purcprice
          IMPORTING
            amount_external = ls_pocond_ct-cond_value.

        ls_pocond_ct-itm_number  = ls_purch_order_item-po_item.
        ls_pocond_ct-cond_type   = lv_cnpr.
        ls_pocond_ct-change_id   = gc_u.
*--> Mark all fields which can be changed
        ls_pocondx_ct-itm_number = ls_purch_order_item-po_item. "2303703
        ls_pocondx_ct-cond_value = gc_xflag.
        ls_pocondx_ct-currency   = gc_xflag.
        ls_pocondx_ct-cond_type  = gc_xflag.
        ls_pocondx_ct-change_id  = gc_xflag.
        APPEND ls_pocond_ct TO pocond_ct.
        APPEND ls_pocondx_ct TO pocondx_ct.
      ENDIF.
* ---  Create/ Update/ Delete options for new vehicles

*--> Check if options exist for the new vehicle which needs to get set up
*    as a condition type for the new vehicle
      READ TABLE lt_iobj_data_multi_com INTO ls_iobj_data_multi_com WITH KEY /dbe/v_vehicle-vguid = ls_vlcdiavehi-vguid.
      IF sy-subrc = 0 .
        LOOP AT ls_iobj_data_multi_com-/dbe/v_ioption INTO ls_v_ioption
                WHERE opmatnr IS NOT INITIAL AND
                      mmnoord <> gc_xflag.
          APPEND ls_v_ioption TO lt_v_ioption.
        ENDLOOP.
      ENDIF.
*--> check if old condition exist on DB and should get deleted
*    determine the existing Condition for the item (from BAPI PO DB)

      LOOP AT lt_bapi_po_cond INTO ls_bapi_po_cond
                               WHERE itm_number =  ls_purch_order_item-po_item
                               AND cond_type = lv_qopt.
        APPEND ls_bapi_po_cond TO lt_bapi_po_cond_qopt.              "existing conditions with QOPT
      ENDLOOP.

*--> Creating/Updating new conditions for the new vehicles option
**************************************************************************
*    Update of multiple QOPT conditions not possible via BADI_PO_CHANGE
*    therefore first deleting all existing and second insert all new conditions
      IF lv_index IS INITIAL.                               "2303703
        lv_index = gc_1.
      ENDIF.
      PERFORM fill_cond_nec_option IN PROGRAM /dbe/saplvm13
                  USING    ls_iobj_data_multi_com-/dbe/v_ioptiont
                           lt_bapi_po_cond_qopt
                           lt_v_ioption
                           ls_purch_order_item-po_item
                           iv_mode
                           lv_qopt
                  CHANGING pocond_ct
                           pocondx_ct
                           potextitem_ct
                           lv_index.

      " if there is not PO item text then is necessary .add this line to potextitem_ct to remove item text
      " otherwise no changes of item text will be performed and old value will be still there

      IF potextitem_ct IS INITIAL.
        CLEAR ls_potextitem.
        ls_potextitem-po_item = ls_purch_order_item-po_item.
        ls_potextitem-text_id = 'F01'.
        ls_potextitem-text_form = '*'.
        APPEND ls_potextitem TO potextitem_ct.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.

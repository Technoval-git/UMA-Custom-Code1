FUNCTION ZDBE_VEH_PO_CREATE_USED.
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
*"         OPTIONAL
*"  EXCEPTIONS
*"      PROCESSING_IMPOSSIBLE
*"--------------------------------------------------------------------
* ---Data Declaration
  DATA: ls_vlcdiavehi             TYPE vlcdiavehi.
  DATA: lt_vlcguid                TYPE vlcguid_t.
  DATA: ls_vlcguid                LIKE LINE  OF lt_vlcguid.
  DATA: lv_iobjguid               TYPE /dbe/exts_ouid.
  DATA: lv_dbe_coaufnr            TYPE vlcvehicle-/dbe/coaufnr.
  DATA: lv_category_id            TYPE /dbe/exts_category_id.
  DATA: ls_iobj_data_single       TYPE /dbe/iobj_data_single_txt_s.
  DATA: ls_iobj_data_multi        TYPE /dbe/iobj_data_multi_txt_s.
  DATA: lt_return                 TYPE TABLE OF bapiret2.
  DATA: ls_vlch_mssg              TYPE vlch_mssg_ps.
*--> local data for INI-file values
  DATA: lv_bustype_uc             TYPE /dbe/ctrl_value.
  DATA: lv_bustype_nc             TYPE /dbe/ctrl_value.
  DATA: lv_qopt                   TYPE /dbe/ctrl_value.                       "condition type for options
  DATA: lv_qdam                   TYPE /dbe/ctrl_value.                        "condition type for damages
  DATA: lv_cnpr                   TYPE /dbe/ctrl_value.                        "changed net-price
  DATA: lv_matkl_feature          TYPE /dbe/ctrl_value.                        "material group missing features
  DATA: lv_matkl_dealcos          TYPE /dbe/ctrl_value.                        "material group dealer cost
*--> structure and table for purchase order from DB
  DATA: ls_bapi_po_items_all      TYPE bapimepoitem.
  DATA: lt_bapi_po_items_all      TYPE TABLE OF bapimepoitem.
  DATA: lt_bapi_po_schedules      TYPE TABLE OF bapimeposchedule.
  DATA: lt_bapi_po_account        TYPE TABLE OF bapimepoaccount.
  DATA: lt_extensionout           TYPE bapiparex_tp.
*--> local data for create/update damage conditions step 2.)
  DATA: lt_bapi_po_cond_qdam      TYPE TABLE OF bapimepocond.
  DATA: lt_qmfe_db                TYPE /dbe/qmfe_t.
  DATA: lv_index                  TYPE sy-tabix.
  DATA: lv_ebelp_last             TYPE ebelp.
  DATA: lv_ebelp_new              TYPE ebelp.
*--> local data for create/ update/ delete items for missing handover articles step 3.)
  DATA: ls_v_ioption              TYPE LINE OF /dbe/v_ioption_dynp_t.
  DATA: lt_v_ioption              TYPE /dbe/v_ioption_dynp_t.
  DATA: ls_purch_order_item       TYPE bapimepoitem.
  DATA: ls_purch_order_itemx      TYPE bapimepoitemx.
  DATA: potextitem_lt             TYPE TABLE OF bapimepotext.
*--> local data for conditions for new vehicles options
  DATA: lt_bapi_po_cond_qopt      TYPE TABLE OF bapimepocond.
  DATA: lv_lflag                  TYPE c VALUE 'L'.                 "deletion flag for PO item
*--> local data for dealer cost item step 4.)
  DATA: lv_dealer_cost            TYPE bapicurext.                  "dealer cost net price
  DATA: lv_netpr                  TYPE bapicurext.                  "net price (estimated PO-price - damages)
  DATA: lv_aimpurpri              TYPE bapicurext.                  "aimed PO price
  DATA: lv_estpurpri              TYPE bapicurext.                  "estimated PO-price
  DATA: lv_mhipri                 TYPE bapicurext.                  "sum of all net-prices from missing items
  DATA: lv_testrun                TYPE bapiflag-bapiflag VALUE 'X'.
  DATA  poitem_ls TYPE bapimepoitem.                 "dealer cost calculation
*--> local structures for the testrun PO-BAPI (mandotary)
  DATA: poheader_ls               TYPE bapimepoheader.
  DATA: poheaderx_ls              TYPE bapimepoheaderx.
  DATA: poaddrvendor_ls           TYPE bapimepoaddrvendor.
  DATA: testrun_lv                TYPE bapiflag-bapiflag.
  DATA: memory_uncomplete_lv      TYPE bapiflag-bapiflag.
  DATA: memory_complete_lv        TYPE bapiflag-bapiflag.
  DATA: poexpimpheader_ls         TYPE bapieikp.
  DATA: poexpimpheaderx_ls        TYPE bapieikpx.
  DATA: versions_ls               TYPE bapimedcm.
  DATA: exppurchaseorder_lv       TYPE bapimepoheader-po_number.
  DATA: expheader_ls              TYPE bapimepoheader.
  DATA: exppoexpimpheader_ls      TYPE bapieikp.
  DATA: return_lt                 TYPE TABLE OF bapiret2.
  DATA: poitem_lt                 TYPE TABLE OF bapimepoitem.
  DATA: poitemx_lt                TYPE TABLE OF bapimepoitemx.
  DATA: poaddrdelivery_lt         TYPE TABLE OF bapimepoaddrdelivery.
  DATA: poschedule_lt             TYPE TABLE OF bapimeposchedule.
  DATA: poschedulex_lt            TYPE TABLE OF bapimeposchedulx.
  DATA: poaccount_lt              TYPE TABLE OF bapimepoaccount.
  DATA: poaccountprofitsegment_lt TYPE TABLE OF bapimepoaccountprofitsegment.
  DATA: poaccountx_lt             TYPE TABLE OF bapimepoaccountx.
  DATA: pocondheader_lt           TYPE TABLE OF bapimepocondheader.
  DATA: pocondheaderx_lt          TYPE TABLE OF bapimepocondheaderx.
  DATA: pocond_lt                 TYPE TABLE OF bapimepocond.
  DATA: pocondx_lt                TYPE TABLE OF bapimepocondx.
  DATA: polimits_lt               TYPE TABLE OF bapiesuhc.
  DATA: pocontractlimits_lt       TYPE TABLE OF bapiesucc.
  DATA: poservices_lt             TYPE TABLE OF bapiesllc.
  DATA: posrvaccessvalues_lt      TYPE TABLE OF bapiesklc.
  DATA: poservicestext_lt         TYPE TABLE OF bapieslltx.
  DATA: extensionin_lt            TYPE TABLE OF bapiparex.
  DATA: extensionout_lt           TYPE TABLE OF bapiparex.
  DATA: poexpimpitem_lt           TYPE TABLE OF bapieipo.
  DATA: poexpimpitemx_lt          TYPE TABLE OF bapieipox.
  DATA: potextheader_lt           TYPE TABLE OF bapimepotextheader.
  DATA: ls_potextitem             TYPE bapimepotext.
  DATA: allversions_lt            TYPE TABLE OF bapimedcm_allversions.
  DATA: popartner_lt              TYPE TABLE OF bapiekkop.
  DATA: lt_iobj_data_single_com   TYPE /dbe/iobj_data_single_com_t.
  DATA: lt_iobj_data_multi_com    TYPE /dbe/iobj_data_multi_com_t.
  DATA: ls_iobj_data_single_com   TYPE /dbe/iobj_data_single_com_s.
  DATA: ls_iobj_data_multi_com    TYPE /dbe/iobj_data_multi_com_s.
  DATA: ls_iobj_data_single_txt   TYPE /dbe/iobj_data_single_txt_s.
  DATA: ls_iobj_data_multi_txt    TYPE /dbe/iobj_data_multi_txt_s.
  DATA: ls_actdata_item           TYPE vlcactdata_item_s.
  DATA  lv_lines                  TYPE i.
  DATA  lo_veh_buf                TYPE REF TO /dbe/cl_veh_buf.
  DATA  lo_vehicle                TYPE REF TO /dbe/cl_veh_dbmvehicle.
  DATA  lt_vehicles               TYPE /dbe/t_veh_bob.
  DATA  ls_vehicle                TYPE /dbe/s_veh_bob.
  DATA  lo_object                 TYPE REF TO /dbe/cl_veh_iobject_vehicle.
  DATA  lv_tabix                  TYPE sy-tabix.
  DATA  lt_iobj_data_single       TYPE /dbe/iobj_data_single_com_t.
  DATA  lt_iobj_data_multi        TYPE /dbe/iobj_data_multi_com_t.
  DATA  lr_iobj_single            TYPE REF TO /dbe/iobj_data_single_com_s.
  DATA  lr_iobj_multi             TYPE REF TO /dbe/iobj_data_multi_com_s.
  DATA  purch_order_schedule_cs   TYPE bapimeposchedule.
  DATA  purch_order_schedulex_cs  TYPE bapimeposchedulx.
  DATA  lv_iobj_exist             TYPE boole_d .
  DATA  lv_ebelp_uc               TYPE ebelp.
  DATA  lv_ebelp_next             TYPE ebelp.
  DATA  gv_ebelp                  TYPE ebelp.
  DATA  lv_tax_code               TYPE mwskz.
  DATA lv_pricing_type            TYPE /dbe/veh_pricingtype.

*--> Get IOBJGUID and VlCGUID

  LOOP AT vlcdiavehi_it INTO ls_vlcdiavehi.
*   Only for DBM vehicles
    IF ls_vlcdiavehi-/dbe/iobjguid IS INITIAL.
      RETURN.
    ENDIF.
    ls_vlcguid = ls_vlcdiavehi-vguid.                                  "vguid
    lv_iobjguid = ls_vlcdiavehi-/dbe/iobjguid.                              "iobjguid
    lv_dbe_coaufnr = ls_vlcdiavehi-/dbe/coaufnr.                         " dbm-co-aufnr
    APPEND ls_vlcguid TO lt_vlcguid.
  ENDLOOP.

* Possible use-cases :
* Case 1    => Mass processing in DBM 8.0 - NOT FEASIBLE!! - techinically it is not feasible to link the vehicle item and it's corresponding dealer cost etc in Purchase Order.
* Case 2    => single vehicle processing  in DBM 6.0 ( No vehicle buffer concept)
* Cas3 3    => Single vehicle processing in DBM 7.0 and higher  ( with vehicle buffer usage )
  lo_veh_buf  = /dbe/cl_veh_buf=>get_instance( ) .

  IF lo_veh_buf  IS BOUND .  " Case 1 and 3
*--> Get IOBJECT Data from buffer
    lt_vehicles = lo_veh_buf->get_all( ). "get vehicles from vehicle buffer
    READ TABLE lt_vlcguid INTO ls_vlcguid INDEX 1.
    IF sy-subrc = 0.
      READ TABLE lt_vehicles INTO ls_vehicle WITH KEY guid = ls_vlcguid-vguid.
      IF sy-subrc = 0 .
        lo_vehicle ?= ls_vehicle-bobref.  "get vehicle object
        lo_object ?= lo_vehicle->iobject_get( ).  "get vehicle iobject
        TRY.
            lr_iobj_single ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
            ls_iobj_data_single_com = lr_iobj_single->*.
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
    ENDIF.

    IF lt_iobj_data_single_com IS  INITIAL AND lt_iobj_data_multi_com IS INITIAL.
      lv_iobj_exist = abap_false.
      "while processing single vehicle via transaction, iobject details are not filled
    ELSE.
      lv_iobj_exist = abap_true.
    ENDIF.
  ELSE.
    lv_iobj_exist = abap_false.   "Single vehicle processing (Case 2)
  ENDIF.

  IF lv_iobj_exist = abap_false.   "Single vehicle processing for DBM 6.0
    LOOP AT vlcdiavehi_it INTO ls_vlcdiavehi.

*--> Get IOBJECT Data from DB
      lv_iobjguid = ls_vlcdiavehi-/dbe/iobjguid.
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

      MOVE-CORRESPONDING ls_iobj_data_single_txt-/dbe/v_imodel  TO ls_iobj_data_single_com-/dbe/v_imodel.
      MOVE-CORRESPONDING ls_iobj_data_single_txt-/dbe/v_iprices TO ls_iobj_data_single_com-/dbe/v_iprices.
      MOVE-CORRESPONDING ls_iobj_data_single_txt-/dbe/v_vehicle TO ls_iobj_data_single_com-/dbe/v_vehicle.
      MOVE ls_vlcdiavehi-/dbe/iobjguid TO ls_iobj_data_single_com-/dbe/v_vehicle-/dbe/iobjguid.
      MOVE ls_vlcdiavehi-vguid TO ls_iobj_data_single_com-/dbe/v_vehicle-vguid.
      APPEND ls_iobj_data_single_com TO lt_iobj_data_single_com.

      ls_iobj_data_multi_com-/dbe/v_ioptiont = ls_iobj_data_multi_txt-/dbe/v_ioptiont .
      ls_iobj_data_multi_com-/dbe/v_ioption  = ls_iobj_data_multi_txt-/dbe/v_ioption .
      MOVE-CORRESPONDING ls_iobj_data_single_txt-/dbe/v_vehicle TO ls_iobj_data_single_com-/dbe/v_vehicle.
      MOVE ls_vlcdiavehi-/dbe/iobjguid TO ls_iobj_data_multi_com-/dbe/v_vehicle-/dbe/iobjguid.
      MOVE ls_vlcdiavehi-vguid TO ls_iobj_data_multi_com-/dbe/v_vehicle-vguid.
      APPEND ls_iobj_data_multi_com TO lt_iobj_data_multi_com.

    ENDLOOP.
  ENDIF.

*--> Get customized condition type for the damages
  CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
    EXPORTING
      object               = gc_cond_damage
    IMPORTING
      value                = lv_qdam                            "used vehicle damages
    EXCEPTIONS
      object_not_defined   = 0
      value_not_maintained = 0
      OTHERS               = 0.
*--> Get customized material group for missing handover items
  CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
    EXPORTING
      object               = gc_matkl_feature
    IMPORTING
      value                = lv_matkl_feature                   "material group missing features
    EXCEPTIONS
      object_not_defined   = 0
      value_not_maintained = 0
      OTHERS               = 0.
*--> Get customized material group for dealer cost item
  CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
    EXPORTING
      object               = gc_matkl_dealcos
    IMPORTING
      value                = lv_matkl_dealcos                   "material group dealer cost
    EXCEPTIONS
      object_not_defined   = 0
      value_not_maintained = 0
      OTHERS               = 0.

  IF iv_mode = mode_create_gc.
*--> determine the po item price
    READ TABLE poitem_ct INTO ls_purch_order_item INDEX 1.
    lv_ebelp_uc  = ls_purch_order_item-po_item.
    lv_ebelp_new = ls_purch_order_item-po_item.
*   Preparing the netprice for used and new vehicle
    READ TABLE vlcdiavehi_it INTO ls_vlcdiavehi WITH KEY charg = ls_purch_order_item-batch
                       TRANSPORTING vguid .
    IF sy-subrc = 0.
*     Ensure that net_price is converted to the form of bapicurext.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
        EXPORTING
          currency        = vlcactdata_is-currency
          amount_internal = ls_iobj_data_single_com-/dbe/v_iprices-estpurpri
        IMPORTING
          amount_external = ls_purch_order_item-net_price.
      MODIFY poitem_ct FROM ls_purch_order_item  TRANSPORTING net_price  WHERE po_item = lv_ebelp_uc.

    ENDIF.

*--> determine the notification items
    PERFORM get_data_notification IN PROGRAM /dbe/saplvm13
                USING    lt_vlcguid
                CHANGING lt_qmfe_db.

*--> Creating/Updating condition entries for Used Vehicle damages
**************************************************************************
*    Update of multiple QDAM conditions not possible via BADI_PO_CHANGE
*    therefore first deleting all existing and second insert all new conditions

    lv_index = gc_1.
    PERFORM fill_cond_damages IN PROGRAM /dbe/saplvm13
                   USING    lt_bapi_po_cond_qdam
                            lt_qmfe_db
                            lv_ebelp_uc
                            iv_mode
                            lv_qdam
                   CHANGING pocond_ct
                            pocondx_ct
                            potextitem_ct
                            lv_index.
* ------------------------------------------------------------------------
* --- 3.) Create/ Update/ Delete items for missing handover articles
*         for used vehicles
* ------------------------------------------------------------------------
    "only for used vehicles
    LOOP AT ls_iobj_data_multi_com-/dbe/v_ioption INTO ls_v_ioption
            WHERE opclass = gc_u AND
                  mmnoord <> gc_xflag. "no PO-relevant
      APPEND ls_v_ioption TO lt_v_ioption.             "relevant missing handover items
    ENDLOOP.

*--> Create/ Update/ Delete items for missing handover articles from features
    PERFORM fill_item_usc_data_ord1 IN PROGRAM /dbe/saplvm13
                     USING    ls_iobj_data_multi_com-/dbe/v_ioptiont
                              lt_v_ioption
                              lt_bapi_po_items_all
                              lt_bapi_po_account
                              lt_extensionout
                              vlcdiavehi_it
                              vlcactdata_is
                              iv_mode
                              lv_matkl_feature
                     CHANGING poitem_ct
                              poitemx_ct
                              poschedule_ct
                              poschedulex_ct
                              poaccount_ct
                              poaccountx_ct
                              extensionin_ct
                              lv_ebelp_new
                              lv_ebelp_last
                              lv_mhipri
                              vlch_mssg_ct.
    LOOP AT vlch_mssg_ct INTO ls_vlch_mssg WHERE msgty = 'E' OR msgty = 'A'.
      RAISE processing_impossible.
    ENDLOOP.
    " if there is not PO item text then is necessary add this line to potextitem_ct to remove item text
    " otherwise no changes of item text will be performed and old value will be still there

    IF potextitem_ct IS INITIAL.
      CLEAR ls_potextitem.
      ls_potextitem-po_item = lv_ebelp_uc.
      ls_potextitem-text_id = 'F01'.
      "    ls_potextitem-text_line = ''.
      ls_potextitem-text_form = '*'.
      APPEND ls_potextitem TO potextitem_ct.
    ENDIF.

* --- 5.) Create/ Update item for Dealer Cost for used vehicle PO
*
* ------------------------------------------------------------------------
    "only for used vehicles
*--> set the currency in the purchase order header
    poheader_cs-currency       = vlcactdata_is-currency.
    poheaderx_cs-currency      = 'X'.
*--> move changes to internal-tables for testrun
    poheader_ls                = poheader_cs.
    poheaderx_ls               = poheaderx_cs.
    poaddrvendor_ls            = poaddrvendor_cs.
    memory_complete_lv         = memory_complete_cv.
    poexpimpheader_ls          = poexpimpheader_cs.
    poexpimpheaderx_ls         = poexpimpheaderx_cs.
    versions_ls                = versions_cs.
    exppurchaseorder_lv        = purchaseorder_cv.
    poexpimpheader_ls          = poexpimpheader_cs.
    poexpimpheaderx_ls         = poexpimpheaderx_cs.
    return_lt                  = lt_return.
    poitem_lt[]                = poitem_ct[].
    poitemx_lt[]               = poitemx_ct[].
    poaddrdelivery_lt          = poaddrdelivery_ct.
    poschedule_lt              = poschedule_ct.
    poschedulex_lt             = poschedulex_ct.
    poaccount_lt[]             = poaccount_ct[].
    poaccountprofitsegment_lt  = poaccountprofitsegment_ct.
    poaccountx_lt[]            = poaccountx_ct[].
    pocondheader_lt            = pocondheader_ct.
    pocondheaderx_lt           = pocondheaderx_ct.
    pocond_lt[]                = pocond_ct[].
    pocondx_lt[]               = pocondx_ct[].
    polimits_lt                = polimits_ct.
    pocontractlimits_lt        = pocontractlimits_ct.
    poservices_lt              = poservices_ct.
    posrvaccessvalues_lt       = posrvaccessvalues_ct.
    poservicestext_lt          = poservicestext_ct.
    extensionin_lt             = extensionin_ct.
    extensionout_lt            = extensionout_ct.
    poexpimpitem_lt            = poexpimpitem_ct.
    poexpimpitemx_lt           = poexpimpitemx_ct.
    potextheader_lt            = potextheader_ct.
    potextitem_lt              = potextitem_ct.
    allversions_lt             = allversions_ct.
    popartner_lt               = popartner_ct.

*--> Testrun BAPI to get the price information
**************************************************************************
    IF iv_mode = mode_create_gc.
      CALL FUNCTION 'BAPI_PO_CREATE1' "#EC CI_USAGE_OK[2438131]
        EXPORTING
          poheader               = poheader_ls
          poheaderx              = poheaderx_ls
          poaddrvendor           = poaddrvendor_ls
          testrun                = lv_testrun
          poexpimpheader         = poexpimpheader_ls
          poexpimpheaderx        = poexpimpheaderx_ls
          no_price_from_po       = lv_testrun
        IMPORTING
          exppurchaseorder       = exppurchaseorder_lv
          expheader              = expheader_ls
          exppoexpimpheader      = exppoexpimpheader_ls
        TABLES
          return                 = return_lt
          poitem                 = poitem_lt
          poitemx                = poitemx_lt
          poaddrdelivery         = poaddrdelivery_lt
          poschedule             = poschedule_lt
          poschedulex            = poschedulex_lt
          poaccount              = poaccount_lt
          poaccountprofitsegment = poaccountprofitsegment_lt
          poaccountx             = poaccountx_lt
          pocondheader           = pocondheader_lt
          pocondheaderx          = pocondheaderx_lt
          pocond                 = pocond_lt
          pocondx                = pocondx_lt
          polimits               = polimits_lt
          pocontractlimits       = pocontractlimits_lt
          poservices             = poservices_lt
          posrvaccessvalues      = posrvaccessvalues_lt
          poservicestext         = poservicestext_lt
          extensionin            = extensionin_lt
          extensionout           = extensionout_lt
          poexpimpitem           = poexpimpitem_lt
          poexpimpitemx          = poexpimpitemx_lt
          potextheader           = potextheader_lt
          potextitem             = potextitem_lt
          allversions            = allversions_lt
          popartner              = popartner_lt.
    ENDIF.

*--> Calculate the Dealer Cost
**************************************************************************

    LOOP AT poitem_lt INTO poitem_ls WHERE po_item = lv_ebelp_uc.
      lv_tax_code = poitem_ls-tax_code.

*-->   Estimated Purchase price
*      - Damages
*      = item net price from used vehicle (from testrun BAPI)
*      - Missing articles
*      + Dealer Cost
*      ------------------------
*      = Aimed Purchase Price

      lv_netpr = poitem_ls-net_price.
*      lv_aimpurpri = ls_iobj_data_single-/DBE/V_IPRICES-aimpurpri.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
        EXPORTING
          currency        = vlcactdata_is-currency
          amount_internal = ls_iobj_data_single_com-/dbe/v_iprices-aimpurpri
        IMPORTING
          amount_external = lv_aimpurpri.

*      lv_estpurpri = ls_iobj_data_single-/DBE/V_IPRICES-estpurpri.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
        EXPORTING
          currency        = vlcactdata_is-currency
          amount_internal = ls_iobj_data_single_com-/dbe/v_iprices-estpurpri
        IMPORTING
          amount_external = lv_estpurpri.

* calculate the aimed purchase price as net price for the dealer cost
      lv_dealer_cost = lv_aimpurpri - ( lv_netpr - lv_mhipri ).

*--> Create/Update the Dealer Cost Item
**************************************************************************
      IF lv_dealer_cost NE 0.
        DESCRIBE TABLE  poitem_lt LINES lv_lines .
        "create/update dealer cost item
        gv_ebelp = ( lv_lines + 1 ) * fact_ten_gc.
        IF lv_ebelp_new  >= gv_ebelp.
          lv_ebelp_new = lv_ebelp_new + fact_ten_gc.
        ELSE.
          lv_ebelp_new = gv_ebelp.
        ENDIF.
        PERFORM fill_dealer_cost_ord1 IN PROGRAM /dbe/saplvm13
               USING    vlcdiavehi_it
                        vlcactdata_is
                        lt_bapi_po_items_all
                        lt_bapi_po_account
                        lv_ebelp_new
                        lv_dealer_cost
                        lv_dbe_coaufnr
                        iv_mode
                        lv_matkl_dealcos
                        lv_tax_code                         "1766084
               CHANGING poitem_ct
                        poitemx_ct
                        poschedule_ct
                        poschedulex_ct
                        poaccount_ct
                        poaccountx_ct
                        vlch_mssg_ct.
        LOOP AT vlch_mssg_ct INTO ls_vlch_mssg WHERE msgty = 'E' OR msgty = 'A'.
          RAISE processing_impossible.
        ENDLOOP.

      ELSE.
        LOOP AT lt_bapi_po_items_all INTO ls_bapi_po_items_all       "delete existing dealer cost item?
                                   WHERE delete_ind NE gc_xflag
                                   AND short_text = TEXT-002.
          lv_ebelp_new = ls_bapi_po_items_all-po_item.

          PERFORM fill_dealer_cost_dele IN PROGRAM /dbe/saplvm13
                          USING    lt_bapi_po_items_all
                          CHANGING poitem_ct
                                   poitemx_ct
                                   poaccount_ct
                                   poaccountx_ct
                                   lv_ebelp_new.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.

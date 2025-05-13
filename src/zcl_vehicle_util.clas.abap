class ZCL_VEHICLE_UTIL definition
  public
  final
  create public .

public section.

  types:
*  types:
*    tt_ydbmc_jet_vehi TYPE TABLE OF ydbmc_jet_vehi .
    BEGIN OF  ty_vhcle_vin ,
        vhcle TYPE vlc_vhcle,
        vhvin TYPE vlc_vhvin,
        matnr TYPE vlc_matnr,
      END OF  ty_vhcle_vin .
  types:
    BEGIN OF ty_mcodesd,
        mcodesd TYPE /dbe/v_model-mcodesd,
      END OF ty_mcodesd .
  types:
    BEGIN OF ty_vguid,
        vguid TYPE vlcvehicle-vguid,
      END OF ty_vguid .
  types:
    BEGIN OF ty_status,
        vguid TYPE vlcvehicle-vguid,
        mmsta TYPE vlcvehicle-mmsta,
      END OF ty_status .
  types:
    BEGIN OF ty_bpext,
        bpext TYPE bu_bpext,
      END OF ty_bpext .
  types:
    BEGIN OF ty_partnerdetails,
        partner  TYPE bu_partner,
        bu_sort2 TYPE bu_sort2,
      END OF ty_partnerdetails .
  types:
    tt_partnerdetails_tab TYPE TABLE OF ty_partnerdetails .
  types:
    tt_vguid TYPE TABLE OF ty_vguid .
  types:
    tt_status TYPE TABLE OF ty_status .
  types:
    tt_vhcle_vin TYPE TABLE OF ty_vhcle_vin .
  types:
    tt_bu_sort2_tab TYPE TABLE OF bu_sort2 .
  types:
    BEGIN OF ty_material,
        old_material TYPE bismt,
        sap_material TYPE matnr,
      END OF ty_material .
  types:
    tt_material_tab TYPE TABLE OF ty_material .
  types:
    tt_matnr_tab TYPE TABLE OF matnr .
  types:
    BEGIN OF ty_bob_structures ,
        ts_vlcactdata_head      TYPE vlcactdata_head_s,
        vguid                   TYPE vlc_guid,
        ts_vlcactdata_item      TYPE vlcactdata_item_s,
        ts_iobj_data_single_com TYPE /dbe/iobj_data_single_com_s,
        ts_iobj_data_multi_com  TYPE /dbe/iobj_data_multi_com_s,
        it_vlcadddata           TYPE vlcadddata_item_t,
        ts_vlcadddata           TYPE vlcadddata_item_s,
        ts_vlcdiavehi           TYPE vlcdiavehi,
      END OF ty_bob_structures .
  types TY_REF_OF_DBMVEHICLE_BOB_TYPE type ref to /DBE/CL_VEH_DBMVEHICLE .
  types:
    BEGIN OF ty_bob_ref,
        vguid  TYPE vlc_guid,
        bobref TYPE ty_ref_of_dbmvehicle_bob_type,
      END OF ty_bob_ref .
  types:
    tt_bob_ref TYPE TABLE OF ty_bob_ref .
  types:
    tt_ref_of_dbmvehicle_bob_type TYPE TABLE OF ty_ref_of_dbmvehicle_bob_type .
  types:
    tt_bob_structures TYPE TABLE OF ty_bob_structures .
  types:
    ty_vlcvehicle TYPE TABLE OF vlcvehicle .

  class-data GC_CUSTOMER type CHAR1 value 'C' ##NO_TEXT.
  class-data GC_VENDOR type CHAR1 value 'V' ##NO_TEXT.
  class-data GT_VHCLE_VIN type TT_VHCLE_VIN .
*  class-data GT_YDBMC_JET_VEHI type TT_YDBMC_JET_VEHI .
  class-data GV_LOG_HANDLE type BALLOGHNDL .
  class-data GV_GWT type VLC_ADQUAL value 'Y024' ##NO_TEXT.
  class-data GV_NWT type VLC_ADQUAL value 'Y025' ##NO_TEXT.
  class-data GV_ENGNO type VLC_ADQUAL value 'Y008' ##NO_TEXT.
  class-data GV_ETA type VLC_ADQUAL value 'Y026' ##NO_TEXT.
  class-data GV_MODYEAR type VLC_ADQUAL value 'Y027' ##NO_TEXT.
  class-data GV_CYL type VLC_ADQUAL value 'Y028' ##NO_TEXT.
  class-data GV_HP type VLC_ADQUAL value 'Y029' ##NO_TEXT.
  class-data GV_CHCLR type VLC_ADQUAL value 'Y030' ##NO_TEXT.

  class-methods CREATE_VEHICLE
    importing
      !IS_VLCACTDATA_HEAD type VLCACTDATA_HEAD_S optional
      !IS_VLCACTDATA_ITEM type VLCACTDATA_ITEM_S optional
      !IS_IOBJ_DATA_SINGLE_COM type /DBE/IOBJ_DATA_SINGLE_COM_S optional
      !IS_IOBJ_DATA_MULTI_COM type /DBE/IOBJ_DATA_MULTI_COM_S optional
      !IT_VLCADDDATA type VLCADDDATA_ITEM_T optional
      !IS_VLCDIAVEHI type VLCDIAVEHI optional
      !IV_COMMIT type BOOLEAN default ABAP_TRUE
      !LV_CLEARBUFF type BOOLEAN default ABAP_FALSE
    exporting
      !ET_BAPIRETURN type BAPIRET2_TAB
      !EV_VECHILEGUID type VLC_GUID .
  class-methods UPDATE_VEHICLE_BOB
    importing
      !IV_VID type VLC_VHCLE optional
      !IV_VGUID type VLC_GUID optional
      !IS_VLCACTDATA_HEAD type VLCACTDATA_HEAD_S optional
      !IS_VLCACTDATA_ITEM type VLCACTDATA_ITEM_S optional
      !IS_IOBJ_DATA_SINGLE_COM type /DBE/IOBJ_DATA_SINGLE_COM_S optional
      !IS_IOBJ_DATA_MULTI_COM type /DBE/IOBJ_DATA_MULTI_COM_S optional
      !IT_VLCADDDATA type VLCADDDATA_ITEM_T optional
      !IS_VLCDIAVEHI type VLCDIAVEHI optional
      !IV_SAVE_NEEDED type ABAP_BOOL default ABAP_TRUE
      !IS_VLCADDDATA type VLCADDDATA_ITEM_T optional
    exporting
      !CT_BAPIRETURN type BAPIRET2_TAB .
  class-methods GET_VEHICLE_DB
    importing
      !IT_KEY_VAL type ECM_T_KEY_VALUE_PAIR
    exporting
      !ET_VLEVEHICLE type TY_VLCVEHICLE .
  class-methods GET_VEHICLE_FROM_BUFFER
    importing
      !IV_VEH_GUID type VLC_GUID
    exporting
      !EO_VEH_DBMVEHICLE type ref to /DBE/CL_VEH_DBMVEHICLE
      !ET_BAPIRET2 type BAPIRET2_T .
  class-methods GET_VEHICLE_BOB_DB
    importing
      !IT_VGUID type /DBE/VLC_GUID_T
    exporting
      !ET_BAPIRET2 type BAPIRET2_T
      !ET_BOB_STRUCTURES type TT_BOB_STRUCTURES .
  class-methods GET_VEHICLE_BOB
    importing
      !IT_VGUID type /DBE/VLC_GUID_T
    exporting
      !ET_BAPIRET2 type BAPIRET2_T
      !ET_BOBREF type TT_BOB_REF .
*  class-methods GET_SAPPARTNER_FOR_LEGACY
*    importing
*      !IT_BU_SORT2 type TT_BU_SORT2_TAB
*      !IV_CUST_VENDOR type YSAPPARNTYP_DE
*    exporting
*      !ET_RETURN type BAPIRET2_T
*      !ET_PARTNERINFO type TT_PARTNERDETAILS_TAB .
  class-methods GET_SAPMATERIAL
    importing
      !IT_MATNR type TT_MATNR_TAB
    exporting
      !ET_MATERIALINFO type TT_MATERIAL_TAB .
  class-methods CREATE_VELO_VEHICLE
    importing
      !IS_VLCACTDATA_HEAD type VLCACTDATA_HEAD_S optional
      !IS_VLCACTDATA_ITEM type VLCACTDATA_ITEM_S optional
      !IS_IOBJ_DATA_SINGLE_COM type /DBE/IOBJ_DATA_SINGLE_COM_S optional
      !IS_IOBJ_DATA_MULTI_COM type /DBE/IOBJ_DATA_MULTI_COM_S optional
      !IT_VLCADDDATA type VLCADDDATA_ITEM_T optional
      !IS_VLCDIAVEHI type VLCDIAVEHI optional
      !IV_COMMIT type BOOLEAN default ABAP_TRUE
      !LV_CLEARBUFF type BOOLEAN default ABAP_FALSE
    exporting
      !ET_BAPIRETURN type BAPIRET2_TAB
      !EV_VECHILEGUID type VLC_GUID .
  class-methods REFRESH_BOB_BUFFER .
*  class-methods GET_CONFIG_DATA_SINGLE
*    importing
*      !IV_NAME type NAME_KOMP
*      !IV_SPART type SPART optional
*    exporting
*      !EV_VALUE type YDBM_VEHICLE_CONFIG_VALUE_DE .
  class-methods ADD_SLG_LOG
    importing
      !IT_MSG type BAL_T_MSG .
  class-methods AUTH_CHECK
    importing
      !IV_OBJECT type UST12-OBJCT default '/dbe/ORDER'
      !IV_FIELD type UST12-FIELD
    changing
      !IT_DATA type ANY TABLE .
  class-methods GET_CONFIG_DATA_SINGLE
    importing
      !IV_NAME type NAME_KOMP
      !IV_SPART type SPART
    exporting
      !EV_VALUE type STRING .
  class-methods GET_SAPPARTNER_FOR_LEGACY
    importing
      !IT_BU_SORT2 type TT_BU_SORT2_TAB
      !IV_CUST_VENDOR type STRING
    exporting
      !ET_RETURN type BAPIRET2_T
      !ET_PARTNERINFO type TT_PARTNERDETAILS_TAB .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VEHICLE_UTIL IMPLEMENTATION.


  METHOD add_slg_log.


*----------------- Local Internal Table declarations ------------------*
    DATA : lt_log_handle     TYPE bal_t_logh,
           lt_new_lognumbers TYPE bal_t_lgnm.

*----------------- Local Structure declarations -----------------------*
    DATA: ls_log        TYPE bal_s_log,
          ls_log_handle TYPE balloghndl,
          ls_msg        TYPE bal_s_msg.

**********************************************************************
*                     Mapping Log values                             *
**********************************************************************
    CLEAR: ls_log, ls_log_handle.
    ls_log-aluser     = sy-uname.
    ls_log-object     = 'ZDATA_CONV'.
    ls_log-altcode    = sy-tcode.
    ls_log-subobject  = 'ZOB29'.
    ls_log-extnumber  = 100.      "<<<<<<<<--any external number for reference.
    ls_log-aldate     = sy-datum.
    ls_log-altime     = sy-uzeit.

**********************************************************************
*                    Create SLG Log Handle                           *
**********************************************************************
    IF  zcl_vehicle_util=>gv_log_handle IS INITIAL.
      CALL FUNCTION 'BAL_LOG_CREATE'
        EXPORTING
          i_s_log                 = ls_log
        IMPORTING
          e_log_handle            = zcl_vehicle_util=>gv_log_handle
        EXCEPTIONS
          log_header_inconsistent = 1
          OTHERS                  = 2.
    ENDIF.

    ls_log_handle = zcl_vehicle_util=>gv_log_handle.

**********************************************************************
*                    Add Msg to SLG Log Handle                       *
**********************************************************************
    LOOP AT it_msg INTO ls_msg.
      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle     = ls_log_handle
          i_s_msg          = ls_msg
        EXCEPTIONS
          log_not_found    = 1
          msg_inconsistent = 2
          log_is_full      = 3
          OTHERS           = 4.
    ENDLOOP.
    APPEND ls_log_handle TO lt_log_handle.

**********************************************************************
*                    Save SLG Log via Handle                         *
**********************************************************************
    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_log_handle
      IMPORTING
        e_new_lognumbers = lt_new_lognumbers
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.

  ENDMETHOD.


  METHOD auth_check.
    CONSTANTS : lc_werks TYPE ust12-von VALUE 'WERKS',
                lc_vkorg TYPE ust12-von VALUE 'VKORG',
                lc_vtewg TYPE ust12-von VALUE 'VTWEG',
                lc_aart  TYPE ust12-von VALUE '/dbe/AART',
                lc_spart TYPE ust12-von VALUE 'SPART',
                lc_actvt TYPE ust12-von VALUE 'ACTVT',
                lc_ordac TYPE ust12-von VALUE '/dbe/ORDAC'.
*    DATA : lv_value TYPE ust12-von.
    DATA : ls_value TYPE selopt.
    DATA : lt_data TYPE TABLE OF selopt.

    LOOP AT it_data  ASSIGNING  FIELD-SYMBOL(<fs_any>) .
      ls_value = <fs_any>.
      CASE iv_field.
        WHEN lc_werks.
          AUTHORITY-CHECK OBJECT iv_object FOR USER sy-uname
              ID iv_field FIELD ls_value-low
              ID lc_actvt FIELD '03'
              ID lc_vkorg  DUMMY
              ID lc_vtewg DUMMY
              ID lc_aart DUMMY
              ID lc_ordac DUMMY
              ID lc_spart DUMMY .
          IF sy-subrc = 0.
            APPEND ls_value TO lt_data.
          ENDIF.
        WHEN lc_vkorg.
          AUTHORITY-CHECK OBJECT iv_object FOR USER sy-uname
           ID iv_field FIELD ls_value-low
           ID lc_actvt FIELD '03'
           ID lc_werks DUMMY
           ID lc_vtewg DUMMY
           ID lc_aart DUMMY
           ID lc_ordac DUMMY
           ID lc_spart DUMMY .
          IF sy-subrc = 0.
            APPEND ls_value TO lt_data.
          ENDIF.
        WHEN lc_vtewg.
          AUTHORITY-CHECK OBJECT iv_object FOR USER sy-uname
           ID iv_field FIELD ls_value-low
           ID lc_actvt FIELD '03'
           ID lc_werks DUMMY
           ID lc_vkorg DUMMY
           ID lc_aart DUMMY
           ID lc_ordac DUMMY
           ID lc_spart DUMMY .
          IF sy-subrc = 0.
            APPEND ls_value TO lt_data.
          ENDIF.
        WHEN lc_aart.
          AUTHORITY-CHECK OBJECT iv_object FOR USER sy-uname
           ID iv_field FIELD ls_value-low
           ID lc_actvt FIELD '03'
           ID lc_werks DUMMY
           ID lc_vkorg DUMMY
           ID lc_vtewg DUMMY
           ID lc_ordac DUMMY
           ID lc_spart DUMMY .
          IF sy-subrc = 0.
            APPEND ls_value TO lt_data.
          ENDIF.
        WHEN lc_spart.
          AUTHORITY-CHECK OBJECT iv_object FOR USER sy-uname
           ID iv_field FIELD ls_value-low
           ID lc_actvt FIELD '03'
           ID lc_werks DUMMY
           ID lc_vkorg DUMMY
           ID lc_vtewg DUMMY
           ID lc_ordac DUMMY
           ID lc_aart DUMMY .
          IF sy-subrc = 0.
            APPEND ls_value TO lt_data.
          ENDIF.
      ENDCASE.
    ENDLOOP.
    it_data[] = lt_data[].
  ENDMETHOD.


  METHOD create_vehicle.
*&**********************************************************************
*&   Author           : Amit Thapa                                     *
*&   Date             : 10-04-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Method Name     : CREATE_VEHICLE                                  *
*
*&**********************************************************************
*& Method Definition : Method to create new vehicle (DE1K903481)       *
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 10.04.17 | DE1K903481 | Amit Thapa   |       New                    *
*&+-------------------------------------------------------------------+*
    DATA: it_veh_bob         TYPE /dbe/t_veh_bob,
          ts_veh_bob         LIKE LINE OF it_veh_bob,
          it_bapiret2        TYPE TABLE OF bapiret2,
          lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
          lo_veh_dbmvehicle  TYPE REF TO /dbe/cl_veh_dbmvehicle,
          lt_veh_dbmvehicle  TYPE TABLE OF /dbe/s_veh_bob,
          lt_vlcactdata_item TYPE vlcactdata_item_t,
          lo_iobject         TYPE REF TO /dbe/cl_veh_iobject_vehicle,
          lo_cx_root         TYPE REF TO cx_root,
          ls_vlcactdata      TYPE vlcactdata,
          lt_vlcdiavehi      TYPE vlcdiavehi_t.
    DATA:
      rs_vlcdiavehi           TYPE REF TO vlcdiavehi,
      rs_vlcactdata_head      TYPE REF TO vlcactdata_head_s,
      rs_vlcactdata_item      TYPE REF TO vlcactdata_item_s,
      rt_vlcadddata_item      TYPE REF TO vlcadddata_item_t,
      ls_vlcactdata_head      TYPE vlcactdata_head_s,
      rs_iobj_data_single_com TYPE REF TO /dbe/iobj_data_single_com_s,
      rs_iobj_data_multi_com  TYPE REF TO /dbe/iobj_data_multi_com_s.
    DATA: lv_dummy_guid TYPE /dbe/veh_guid VALUE 1,
          it_veh_bobnew TYPE /dbe/t_veh_bobnew,
          ts_veh_bobnew TYPE /dbe/s_veh_bobnew.
    FIELD-SYMBOLS <fs_veh_bob>         LIKE LINE OF it_veh_bob.
    "Get the reference to the buffer
    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    TRY .
        READ TABLE it_veh_bob INTO ts_veh_bob  WITH KEY guid = lv_dummy_guid.
        IF sy-subrc <> 0.
          "Provide Dummy guid
          ts_veh_bobnew-guid    = lv_dummy_guid.
          ts_veh_bobnew-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
          INSERT ts_veh_bobnew INTO TABLE it_veh_bobnew.
          CALL METHOD lo_veh_buf->new_bob
            EXPORTING
              it_bobnew = it_veh_bobnew
            IMPORTING
              et_bob    = it_veh_bob.
          READ TABLE it_veh_bob INTO ts_veh_bob INDEX 1.
*          READ TABLE it_veh_bob ASSIGNING <fs_veh_bob> INDEX 1.
        ENDIF.

        IF sy-subrc EQ 0.
* We know that the interface reference returned in ts_veh_bob is a DBMVEHICLE
* Need to cast to DBMVEHICLE, to get access to the COM layer
*          lo_veh_dbmvehicle ?= <fs_veh_bob>-bobref.
          lo_veh_dbmvehicle ?= ts_veh_bob-bobref.
          lo_iobject ?= lo_veh_dbmvehicle->iobject_get( ).
*Indicate that the guid is a DUMMY guid yet.
          lo_veh_dbmvehicle->set_dummy_guid( lv_dummy_guid ).

* Move the data from the interface to the COM layer
          IF is_vlcactdata_head IS SUPPLIED.
            rs_vlcactdata_head ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_head_s ).
            rs_vlcactdata_head->* = is_vlcactdata_head.
          ENDIF.
          IF is_vlcactdata_item IS SUPPLIED.
            rs_vlcactdata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_item_s ).
            rs_vlcactdata_item->* = is_vlcactdata_item.
          ENDIF.
          IF it_vlcadddata IS SUPPLIED.
            rt_vlcadddata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcadddata_item_t ).
            rt_vlcadddata_item->*[] = it_vlcadddata[].
          ENDIF.
          IF is_iobj_data_single_com IS SUPPLIED.
            rs_iobj_data_single_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_single_com_s ).
            rs_iobj_data_single_com->* = is_iobj_data_single_com.
          ENDIF.
          IF is_iobj_data_multi_com IS SUPPLIED.
            rs_iobj_data_multi_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_multi_com_s ).
            rs_iobj_data_multi_com->* = is_iobj_data_multi_com.
          ENDIF.
          IF is_vlcdiavehi IS SUPPLIED.
            rs_vlcdiavehi ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
            rs_vlcdiavehi->* = is_vlcdiavehi.
          ENDIF.

          "setting the action
          lo_veh_dbmvehicle->set_action( iv_action = 'QCRV'   "yif_dbm_jet_constants=>gc_dbm_veh_qcrv
           iv_wo_prepare = abap_true ).

          "setting the action
          " Call the SET_BOB method to set the data from the COM to WORK layer
          lo_veh_dbmvehicle->/dbe/if_veh_bob~set_bob( ).

          "data can be changed also by badi_vehicle_api->before_vehicle_set e.g. generic options
          "so move changes back to COM to prevent lost of these changes N:1806382
          lo_veh_dbmvehicle->/dbe/if_veh_bob~fill_com( ).

**************************************************************************

* Move the data from the interface to the COM layer
          IF is_vlcdiavehi IS SUPPLIED.
            rs_vlcdiavehi ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
            rs_vlcdiavehi->vkorg = is_vlcdiavehi-/dbe/vkorg.
            rs_vlcdiavehi->vtweg = is_vlcdiavehi-/dbe/vtweg.
            rs_vlcdiavehi->/dbe/vkorg = is_vlcdiavehi-/dbe/vkorg.
            rs_vlcdiavehi->/dbe/vtweg = is_vlcdiavehi-/dbe/vtweg.
          ENDIF.
          IF is_vlcactdata_head IS SUPPLIED. "not overwritting
            rs_vlcactdata_head ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_head_s ).
            rs_vlcactdata_head->vkorg = is_vlcactdata_head-vkorg.
            rs_vlcactdata_head->vtweg = is_vlcactdata_head-vtweg.

            rs_vlcactdata_head->/dbe/vkorg = is_vlcactdata_head-/dbe/vkorg.
            rs_vlcactdata_head->/dbe/vtweg = is_vlcactdata_head-/dbe/vtweg.
          ENDIF.
          IF is_vlcactdata_item IS SUPPLIED.
            rs_vlcactdata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_item_s ).
*            rs_vlcactdata_item->zveh_fin_no = is_vlcactdata_item-zveh_fin_no.
          ENDIF.
          IF is_iobj_data_single_com IS SUPPLIED.
            rs_iobj_data_single_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_single_com_s ).
            rs_iobj_data_single_com->/dbe/v_imodel-modyear = is_iobj_data_single_com-/dbe/v_imodel-modyear.
            rs_iobj_data_single_com->/dbe/v_ivehicle-labval_ty = is_iobj_data_single_com-/dbe/v_ivehicle-labval_ty.
          ENDIF.
          IF is_vlcdiavehi IS SUPPLIED.
            rs_vlcdiavehi ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
            rs_vlcdiavehi->pddatu = is_vlcdiavehi-pddatu.
          ENDIF.

          lo_veh_dbmvehicle->/dbe/if_veh_bob~set_bob( ).

          "data can be changed also by badi_vehicle_api->before_vehicle_set e.g. generic options
          "so move changes back to COM to prevent lost of these changes N:1806382
          lo_veh_dbmvehicle->/dbe/if_veh_bob~fill_com( ).



          lo_veh_dbmvehicle->set_action( iv_action = 'QCRE'
         iv_wo_prepare = abap_true ).
*          lo_veh_dbmvehicle->perform_save( ).
          lo_veh_dbmvehicle->/dbe/if_veh_bob~save( ).
**************************************************************************

          READ TABLE lo_veh_dbmvehicle->mt_bapireturn TRANSPORTING NO FIELDS WITH KEY type = 'E'.
          IF sy-subrc <> 0.
            "commiting the creation of vehicle
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.
            WAIT UP TO 20 SECONDS.
            "setting for the internal dbm
            lo_veh_dbmvehicle->set_action( iv_action = 'QIOG'
              iv_wo_prepare = abap_true ).
*            lo_veh_dbmvehicle->/dbe/if_veh_bob~save( ).
            lo_veh_dbmvehicle->perform_save( ).
*            APPEND LINES OF lo_veh_dbmvehicle->mt_bapireturn TO et_bapireturn.
            "commiting the creation of vehicle
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.


          ENDIF.
        ENDIF.

        APPEND LINES OF lo_veh_dbmvehicle->mt_bapireturn TO et_bapireturn.
        READ TABLE lo_veh_dbmvehicle->mt_bapireturn TRANSPORTING NO FIELDS WITH KEY type = 'E'.
        IF sy-subrc <> 0.
          ev_vechileguid = lo_veh_dbmvehicle->get_guid( ).
        ENDIF.
        IF iv_commit = abap_true.
          "Committing the vehicle
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        ENDIF.
      CATCH cx_root INTO lo_cx_root.
        CALL METHOD lo_veh_buf->get_messages
          EXPORTING
            io_cx_root    = lo_cx_root
          IMPORTING
            et_bapireturn = it_bapiret2.
        CLEAR ev_vechileguid.
        APPEND LINES OF it_bapiret2 TO et_bapireturn.
*        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        IF lv_clearbuff = abap_true.
          lo_veh_buf->unlock(
            EXPORTING
              it_bob                    =  it_veh_bob    " Table type for /dbe/S_VEH_BOB
           ).

          lo_veh_buf->del_buf(
              it_bob = it_veh_bob
          ).
        ENDIF.

    ENDTRY.

  ENDMETHOD.


  METHOD create_velo_vehicle.
*&**********************************************************************
*&   Author           : Anish                                     *
*&   Date             : 21-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Program Name     : CREATE_VELO_VEHICLE                    *
*
*&**********************************************************************
*& Program Definition : Vehicle  master upload (NAI) (DE1K906120)       *
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 21-07-2017  | DE1K904102 | Anish     |       New         *
*&+-------------------------------------------------------------------+*
    DATA: it_veh_bob         TYPE /dbe/t_veh_bob,
          ts_veh_bob         LIKE LINE OF it_veh_bob,
          it_bapiret2        TYPE TABLE OF bapiret2,
          lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
          lo_veh_dbmvehicle  TYPE REF TO /dbe/cl_veh_dbmvehicle,
          lt_veh_dbmvehicle  TYPE TABLE OF /dbe/s_veh_bob,
          lt_vlcactdata_item TYPE vlcactdata_item_t,
          lo_iobject         TYPE REF TO /dbe/cl_veh_iobject_vehicle,
          lo_cx_root         TYPE REF TO cx_root,
          ls_vlcactdata      TYPE vlcactdata,
          ls_vlcdiavehi      TYPE vlcdiavehi,
          lt_vlcdiavehi      TYPE vlcdiavehi_t.
    DATA:
      rs_vlcdiavehi           TYPE REF TO vlcdiavehi,
      rs_vlcactdata_head      TYPE REF TO vlcactdata_head_s,
      rs_vlcactdata_item      TYPE REF TO vlcactdata_item_s,
      rt_vlcadddata_item      TYPE REF TO vlcadddata_item_t,
      ls_vlcactdata_head      TYPE vlcactdata_head_s,
      rs_iobj_data_single_com TYPE REF TO /dbe/iobj_data_single_com_s,
      rs_iobj_data_multi_com  TYPE REF TO /dbe/iobj_data_multi_com_s.
    DATA: lv_dummy_guid TYPE /dbe/veh_guid VALUE 1,
          it_veh_bobnew TYPE /dbe/t_veh_bobnew,
          ts_veh_bobnew TYPE /dbe/s_veh_bobnew,
          ts_vlcdiavehi TYPE vlcdiavehi.
    FIELD-SYMBOLS <fs_veh_bob>         LIKE LINE OF it_veh_bob.
    "Get the reference to the buffer
    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    TRY .
        READ TABLE it_veh_bob INTO ts_veh_bob  WITH KEY guid = lv_dummy_guid.
        IF sy-subrc <> 0.
          "Provide Dummy guid
          ts_veh_bobnew-guid    = lv_dummy_guid.
          ts_veh_bobnew-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
          INSERT ts_veh_bobnew INTO TABLE it_veh_bobnew.
          CALL METHOD lo_veh_buf->new_bob
            EXPORTING
              it_bobnew = it_veh_bobnew
            IMPORTING
              et_bob    = it_veh_bob.
          READ TABLE it_veh_bob INTO ts_veh_bob INDEX 1.
*          READ TABLE it_veh_bob ASSIGNING <fs_veh_bob> INDEX 1.
        ENDIF.

        IF sy-subrc EQ 0.
* We know that the interface reference returned in ts_veh_bob is a DBMVEHICLE
* Need to cast to DBMVEHICLE, to get access to the COM layer
*          lo_veh_dbmvehicle ?= <fs_veh_bob>-bobref.
          lo_veh_dbmvehicle ?= ts_veh_bob-bobref.
          lo_iobject ?= lo_veh_dbmvehicle->iobject_get( ).
*Indicate that the guid is a DUMMY guid yet.
          lo_veh_dbmvehicle->set_dummy_guid( lv_dummy_guid ).

* Move the data from the interface to the COM layer
          IF is_vlcactdata_head IS SUPPLIED.
            rs_vlcactdata_head ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_head_s ).
            rs_vlcactdata_head->* = is_vlcactdata_head.
          ENDIF.
          IF is_vlcactdata_item IS SUPPLIED.
            rs_vlcactdata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_item_s ).
            rs_vlcactdata_item->* = is_vlcactdata_item.
          ENDIF.
          IF it_vlcadddata IS SUPPLIED.
            rt_vlcadddata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcadddata_item_t ).
            rt_vlcadddata_item->*[] = it_vlcadddata[].
          ENDIF.
          IF is_iobj_data_single_com IS SUPPLIED.
            rs_iobj_data_single_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_single_com_s ).
            rs_iobj_data_single_com->* = is_iobj_data_single_com.
          ENDIF.
          IF is_vlcdiavehi IS SUPPLIED.
            rs_vlcdiavehi ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
            rs_vlcdiavehi->* = is_vlcdiavehi.
          ENDIF.

          "setting the action
          lo_veh_dbmvehicle->set_action( iv_action = 'CREA'
           iv_wo_prepare = abap_true ).



          "setting the action
          " Call the SET_BOB method to set the data from the COM to WORK layer
          lo_veh_dbmvehicle->/dbe/if_veh_bob~set_bob( ).

          "data can be changed also by badi_vehicle_api->before_vehicle_set e.g. generic options
          "so move changes back to COM to prevent lost of these changes N:1806382
          lo_veh_dbmvehicle->/dbe/if_veh_bob~fill_com( ).

*************************onfiguration
*
*          DATA : guid_ls TYPE vlcguidcuobj.
*          DATA : vlcbapicu_ct TYPE vlcbapicu_t.
*          DATA : values TYPE vlcbapicuval_t.
*          DATA : ts_values TYPE bapicuval.
*          DATA : ts_cuins TYPE bapicuins.
*          DATA : ts_bapicucfg TYPE bapicucfg.
*          DATA : bapicuins_it TYPE TABLE OF bapicuins,
*                 bapicuprt_it TYPE TABLE OF bapicuprt,
*                 bapicuval_it TYPE TABLE OF bapicuval.
*          FIELD-SYMBOLS : <vlcbapicu_cs>     TYPE vlcbapicu.
*
*          guid_ls-vguid = 'VLC_DUMMYGUID'.
*
*          CALL FUNCTION 'VELO03_GET_CONFIG_FOR_VEHICLE'
*            EXPORTING
*              guid_cuobj_mapping_is = guid_ls
*            IMPORTING
*              bapicucfg_es          = ts_bapicucfg
**             CUOBJ_EV              =
*            TABLES
**             BAPICUINS_ET          = bapicuins_it
**             BAPICUPRT_ET          = bapicuprt_it
**             BAPICUVAL_ET          = bapicuval_it
**             BAPICUVK_ET           =
*              vlcbapicu_ct          = vlcbapicu_ct
** EXCEPTIONS
**             CONFIG_NOT_FOUND      = 1
**             OTHERS                = 2
*            .
*          IF sy-subrc <> 0.
** Implement suitable error handling here
*          ENDIF.
*          READ TABLE vlcbapicu_ct ASSIGNING <vlcbapicu_cs> INDEX 1.
*          IF sy-subrc = 0.
*            ts_values-config_id = '000001'.
*            ts_values-inst_id = '00000001'.
*            ts_values-valcode = '1'.
*
*            ts_values-charc = 'CLR'.
*            ts_values-value = 'BLUE'.
*            ts_values-value_txt = 'BLUE'.
*            APPEND ts_values TO values.
*
**            ts_values-charc = 'Z_RIM'.
**            ts_values-value = 'R28'.
**            ts_values-value_txt = 'R28'.
**            APPEND ts_values TO values.
**
**            ts_values-charc = 'Z_BM'.
**            ts_values-value = '934013'.
**            ts_values-value_txt = '934013'.
**            APPEND ts_values TO values.
**
**            ts_values-charc = 'Z_OPN'.
**            ts_values-value = 'NA'.
**            ts_values-value_txt = 'NA'.
**            APPEND ts_values TO values.
**
**            ts_values-charc = 'Z_CLR'.
**            ts_values-value = 'WHITE'.
**            ts_values-value_txt = 'WHITE'.
**            APPEND ts_values TO values.
*
*            <vlcbapicu_cs>-vcuval = values.
*            ts_cuins-config_id = 1.
*            ts_cuins-inst_id = 1.
*            ts_cuins-obj_type = 'MARA'.
*            ts_cuins-class_type = '300'.
*            ts_cuins-obj_key = '000000000070000061'.
*            ts_cuins-quantity = '1'.
*            ts_cuins-quantity_unit = 'ST'.
*            APPEND ts_cuins TO <vlcbapicu_cs>-vcuins.
*
*            <vlcbapicu_cs>-vcucfg-config_id = 1.
*            <vlcbapicu_cs>-vcucfg-root_id = 1.
*            <vlcbapicu_cs>-vcucfg-sce = 1.
*
*            DATA : lt_vlcdiavehi_fm   TYPE vlcdiavehi_t,
*                   it_fm_message      TYPE vlch_mssg_pt,
*                   ts_vlcactdata      TYPE vlcactdata,
*                   lt_actdata_item_fm TYPE vlcactdata_item_t.
*
*            APPEND is_vlcdiavehi TO lt_vlcdiavehi_fm.
*
*            CLEAR lt_actdata_item_fm.
*            APPEND is_vlcactdata_item TO lt_actdata_item_fm.
*            MOVE-CORRESPONDING is_vlcdiavehi TO ts_vlcactdata.
*
*            ts_vlcactdata-actdata_item = lt_actdata_item_fm.
*
*            CALL FUNCTION 'VELO09_SET_SELECTED_ACTION'
*              EXPORTING
*                selected_action_iv = 'CREA'.
*
*            "Call Action
*            CALL FUNCTION 'VELO09_SET_ACTION'
*              EXPORTING
*                incoming_action_iv         = 'CREA'
*                commit_iv                  = 'S'
*                dialogue_allowed_iv        = abap_false
**               RESTRICTED_MODE_IV         =
**               ROLLBACK_IV                = 'A'
*              TABLES
*                vlcdiavehi_ct              = lt_vlcdiavehi_fm
*                vlch_mssg_et               = it_fm_message
*                vlcbapicu_it               = vlcbapicu_ct
*              CHANGING
*                vlcactdata_cs              = ts_vlcactdata
*              EXCEPTIONS
*                action_not_defined         = 1
*                no_authority               = 2
*                interlinked_action_error   = 3
*                crea_prepare_failed        = 4
*                action_not_performed       = 5
*                action_not_compl_performed = 6
*                OTHERS                     = 7.
**
*          ENDIF.
*          CALL FUNCTION 'VELO03_SET_CONFIG_FOR_VEHICLE'
*            EXPORTING
**             VLCDISPLALV_ACTION_IS       =
**             CUOBJ_IV     =
*              bapicucfg_is = ts_bapicucfg
*            TABLES
*              bapicuins_it = bapicuins_it
*              bapicuprt_it = bapicuprt_it
*              bapicuval_it = bapicuval_it
**             BAPICUVK_IT  =
*              vlcbapicu_ct = vlcbapicu_ct.


*          ENDIF.
*          DATA : lv_ib_inst TYPE ib_instance.
*          DATA : lt_config TYPE ibco2_instance_tab2.
*          DATA : ts_config TYPE ibco2_instance_rec2.
*          DATA : it_values TYPE ibco2_value_tab.
*          DATA : ts_values TYPE ibco2_value_rec.
*            ts_config-instance = '999900000000000001'.
*            ts_config-conf-cstatus = '1'.
*            ts_config-conf-cstatus = 'CUCOCNT'.
*            ts_config-conf-klart = '300'.
*            ts_config-type_of-object_type = 'MARA'.
*            ts_config-type_of-object_key = is_vlcdiavehi-matnr.
*
*
*            ts_values-atinn = '0000000064'.
*            ts_values-atwrt = 'KD1'.
*            APPEND ts_values TO it_values.
*
*            ts_values-atinn = '0000000066'.
*            ts_values-atwrt = 'KD1'.
*            APPEND ts_values TO it_values.
*
*            ts_values-atinn = '0000000067'.
*            ts_values-atwrt = 'WHITE'.
*            APPEND ts_values TO it_values.
*
*            ts_values-atinn = '0000000091'.
*            ts_values-atwrt = '934013'.
*            APPEND ts_values TO it_values.
*
*            ts_values-atinn = '0000000092'.
*            ts_values-atwrt = 'NA'.
*            APPEND ts_values TO it_values.
*
*            ts_config-values = it_values.
*
*          APPEND ts_config TO lt_config.
*
*
*          lv_ib_inst = '999900000000000001'.
*          CALL FUNCTION 'CUCB_SET_CONFIGURATION'
*            EXPORTING
*              root_instance = lv_ib_inst
**             IS_CBASE_HEADER                    =
*            CHANGING
*              configuration = lt_config
**           EXCEPTIONS
**             INVALID_INPUT = 1
**             INVALID_INSTANCE                   = 2
**             INSTANCE_IS_A_CLASSIFICATION       = 3
**             OTHERS        = 4
*            .
*          IF sy-subrc <> 0.
** Implement suitable error handling here
*          ENDIF.




          lo_veh_dbmvehicle->/dbe/if_veh_bob~save( ).
          READ TABLE lo_veh_dbmvehicle->mt_bapireturn
            TRANSPORTING NO FIELDS WITH KEY type = 'E'.
          IF sy-subrc <> 0.

            "commiting the creation of vehicle
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.

**************************************************************************

** Move the data from the interface to the COM layer
*            IF is_vlcdiavehi IS SUPPLIED.
*              rs_vlcdiavehi ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
*              IF is_vlcdiavehi IS SUPPLIED.
*                rs_vlcdiavehi->pddatu = is_vlcdiavehi-pddatu.
*              ENDIF.
*              rs_vlcdiavehi->vkorg = is_vlcdiavehi-dbm_vkorg.
*              rs_vlcdiavehi->vtweg = is_vlcdiavehi-dbm_vtweg.
*              rs_vlcdiavehi->dbm_vkorg = is_vlcdiavehi-dbm_vkorg.
*              rs_vlcdiavehi->dbm_vtweg = is_vlcdiavehi-dbm_vtweg.
*              ts_vlcdiavehi = rs_vlcdiavehi->*.
*            ENDIF.
*            IF is_vlcactdata_head IS SUPPLIED. "not overwritting
*              rs_vlcactdata_head ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_head_s ).
*              IF ts_vlcdiavehi IS NOT INITIAL.
*                MOVE-CORRESPONDING ts_vlcdiavehi TO rs_vlcactdata_head->*.
*              ENDIF.
*              rs_vlcactdata_head->vkorg = is_vlcactdata_head-vkorg.
*              rs_vlcactdata_head->vtweg = is_vlcactdata_head-vtweg.
*              rs_vlcactdata_head->dbm_vkorg = is_vlcactdata_head-dbm_vkorg.
*              rs_vlcactdata_head->dbm_vtweg = is_vlcactdata_head-dbm_vtweg.
*
*            ENDIF.
*            IF is_vlcactdata_item IS SUPPLIED.
*              rs_vlcactdata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_item_s ).
*              IF ts_vlcdiavehi IS NOT INITIAL.
*                MOVE-CORRESPONDING ts_vlcdiavehi TO rs_vlcactdata_item->*.
*              ENDIF.
*              rs_vlcactdata_item->zveh_fin_no = is_vlcactdata_item-zveh_fin_no.
*            ENDIF.
*            IF is_iobj_data_single_com IS SUPPLIED.
*              rs_iobj_data_single_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_single_com_s ).
*              rs_iobj_data_single_com->dbm_v_imodel-modyear = is_iobj_data_single_com-dbm_v_imodel-modyear.
*              rs_iobj_data_single_com->dbm_v_ivehicle-labval_ty = is_iobj_data_single_com-dbm_v_ivehicle-labval_ty.
*            ENDIF.
*
*
*            lo_veh_dbmvehicle->/dbe/if_veh_bob~set_bob( ).
*
*            "data can be changed also by badi_vehicle_api->before_vehicle_set e.g. generic options
*            "so move changes back to COM to prevent lost of these changes N:1806382
*            lo_veh_dbmvehicle->/dbe/if_veh_bob~fill_com( ).



            lo_veh_dbmvehicle->set_action( iv_action = 'QDBM'
            iv_wo_prepare = abap_true ).
            lo_veh_dbmvehicle->/dbe/if_veh_bob~save( ).
**************************************************************************


***********************          configuratiosn
*            DATA lt_config TYPE ibco2_instance_tab2.
*
*            FIELD-SYMBOLS <ft_values> TYPE ibco2_value_tab.
*            FIELD-SYMBOLS <fs_config> LIKE LINE OF lt_config.
*            FIELD-SYMBOLS <fs_values> TYPE ibvalue0.
*            DATA ts_config TYPE ibvalue0..
*            ts_vlcdiavehi =  rs_vlcdiavehi->*.
*            CALL FUNCTION 'CUCB_GET_CONFIGURATION'
*              EXPORTING
*                instance      = ts_vlcdiavehi-cuobj
**               IS_BUSINESS_OBJECT                 =
**               IV_MOMENT     =
**               IV_WITH_DB_INSTANCE                =
*              IMPORTING
**               IBASE         =
*                configuration = lt_config
**               EO_CBASE_REF  =
** EXCEPTIONS
**               INVALID_INPUT = 1
**               INVALID_INSTANCE                   = 2
**               INSTANCE_IS_A_CLASSIFICATION       = 3
**               OTHERS        = 4
*              .
*            IF sy-subrc <> 0.
** Implement suitable error handling here
*            ENDIF.
*
*            IF lt_config IS NOT INITIAL.
*              READ TABLE lt_config ASSIGNING <fs_config> INDEX 1.
*              ASSIGN <fs_config>-values TO <ft_values>.
*              SORT <ft_values> BY  atwrt. "Sorting for binary search
*              ts_config-atinn = '0000000111'.
*              ts_config-atcod = '1'.
*              ts_config-atwrt = '11B'.
*              APPEND ts_config TO <ft_values>.
*
*              CALL FUNCTION 'CUCB_SET_CONFIGURATION'
*                EXPORTING
*                  root_instance                = ts_vlcdiavehi-cuobj
*                CHANGING
*                  configuration                = lt_config
*                EXCEPTIONS
*                  invalid_input                = 1
*                  invalid_instance             = 2
*                  instance_is_a_classification = 3
*                  OTHERS                       = 4.
*
*            ENDIF.
*            lo_veh_dbmvehicle->set_action( iv_action = 'QMOD'"yif_dbm_jet_constants=>gc_dbm_veh_po_createv_action
*           iv_wo_prepare = abap_true ).
*            lo_veh_dbmvehicle->/dbe/if_veh_bob~save( ).
*          ***********Configuration

            READ TABLE lo_veh_dbmvehicle->mt_bapireturn
              TRANSPORTING NO FIELDS WITH KEY type = 'E'.
            IF sy-subrc <> 0.
              "commiting the creation of vehicle
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true.
              DATA : it_vguid  TYPE /dbe/vlc_guid_t.
              DATA : it_vbobref TYPE Zcl_vehicle_util=>tt_bob_ref.
              DATA : ts_vbobref TYPE Zcl_vehicle_util=>ty_bob_ref.
              DATA : lv_vguid TYPE vlcvehicle-vguid.
              DATA : lv_iobjguid TYPE vlcvehicle-/dbe/iobjguid.
              lv_vguid = rs_vlcdiavehi->vguid.
              lv_iobjguid = rs_vlcdiavehi->/dbe/iobjguid.
              APPEND rs_vlcdiavehi->vguid TO it_vguid.
              "Get Vehicle again as QDBM is refreshing buffer
              Zcl_vehicle_util=>get_vehicle_bob(
                EXPORTING
                  it_vguid    = it_vguid    " Vehicle GUID (Globally Unique IDentifier)
                IMPORTING
*                  et_bapiret2 =     " Proxy Table Type (generated)
                  et_bobref   = it_vbobref
              ).
              "Values in rs_vlcdiavehi, is_vlcactdata_item and is_iobj_data_multi_com are refreshed so update it and set guid
              READ TABLE it_vbobref INTO ts_vbobref WITH KEY vguid = rs_vlcdiavehi->vguid.
              lo_veh_dbmvehicle ?= ts_vbobref-bobref.
              lo_iobject ?= lo_veh_dbmvehicle->iobject_get( ).
              IF is_vlcdiavehi IS SUPPLIED.
                rs_vlcdiavehi ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
                ls_vlcdiavehi = rs_vlcdiavehi->*.
                lv_iobjguid = rs_vlcdiavehi->/dbe/iobjguid.
                rs_vlcdiavehi->* = is_vlcdiavehi.
                rs_vlcdiavehi->vguid = lv_vguid.
                rs_vlcdiavehi->/dbe/iobjguid = lv_iobjguid.
                rs_vlcdiavehi->vhcle = ls_vlcdiavehi-vhcle.
              ENDIF.
              IF is_vlcactdata_item IS SUPPLIED.
                rs_vlcactdata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_item_s ).
                rs_vlcactdata_item->* = is_vlcactdata_item.
                rs_vlcactdata_item->vguid = lv_vguid.
                rs_vlcactdata_item->/dbe/iobjguid = lv_vguid.
              ENDIF.
              IF is_iobj_data_multi_com IS SUPPLIED.
                rs_iobj_data_multi_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_multi_com_s ).
                rs_iobj_data_multi_com->/dbe/v_ioption = is_iobj_data_multi_com-/dbe/v_ioption.
                rs_iobj_data_multi_com->/dbe/v_ioptiont = is_iobj_data_multi_com-/dbe/v_ioptiont.
                rs_iobj_data_multi_com->/dbe/v_ireghist = is_iobj_data_multi_com-/dbe/v_ireghist.
              ENDIF.
              lo_iobject->validate_com( ).
              lo_iobject->com2work( ).
              "setting the action
              "setting for the Changing values like vin Vhcex
              lo_veh_dbmvehicle->set_action( iv_action = 'QMOD'
                iv_wo_prepare = abap_true ).

              " Call the SET_BOB method to set the data from the COM to WORK layer
              lo_veh_dbmvehicle->/dbe/if_veh_bob~set_bob( ).
              "data can be changed also by badi_vehicle_api->before_vehicle_set e.g. generic options
              "so move changes back to COM to prevent lost of these changes N:1806382
              lo_veh_dbmvehicle->/dbe/if_veh_bob~fill_com( ).
*              lo_veh_dbmvehicle->/dbe/if_veh_bob~save( ).
              lo_veh_dbmvehicle->perform_save( ).
              APPEND LINES OF lo_veh_dbmvehicle->mt_bapireturn TO et_bapireturn.
              "commiting the QMOD of vehicle
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true.
            ENDIF.
          ENDIF.
          APPEND LINES OF lo_veh_dbmvehicle->mt_bapireturn TO et_bapireturn.
          READ TABLE lo_veh_dbmvehicle->mt_bapireturn TRANSPORTING NO FIELDS WITH KEY type =  'E'.
          IF sy-subrc <> 0.
*            lo_veh_dbmvehicle->perform_save( ).
            ev_vechileguid = lo_veh_dbmvehicle->get_guid( ).
          ENDIF.
          IF iv_commit = abap_true.
            "Committing the vehicle
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          ENDIF.
        ENDIF.



      CATCH cx_root INTO lo_cx_root.
        CALL METHOD lo_veh_buf->get_messages
          EXPORTING
            io_cx_root    = lo_cx_root
          IMPORTING
            et_bapireturn = it_bapiret2.
        CLEAR ev_vechileguid.
        APPEND LINES OF it_bapiret2 TO et_bapireturn.
*        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        IF lv_clearbuff = abap_true.
          lo_veh_buf->unlock(
            EXPORTING
              it_bob                    =  it_veh_bob    " Table type for /dbe/S_VEH_BOB
           ).

          lo_veh_buf->del_buf(
              it_bob = it_veh_bob
          ).
        ENDIF.

    ENDTRY.

  ENDMETHOD.


  METHOD get_config_data_single.
*    DATA : ts_ydbmc_jet_vehi TYPE dbmc_jet_vehi.
*
*    IF gt_ydbmc_jet_vehi IS INITIAL.
*      SELECT * FROM  ydbmc_jet_vehi INTO TABLE gt_ydbmc_jet_vehi.
*    ENDIF.
*
*    READ TABLE gt_ydbmc_jet_vehi
*      INTO ts_ydbmc_jet_vehi
*      WITH KEY name = iv_name
*      division  = iv_spart.
*    IF sy-subrc = 0.
*      ev_value = ts_ydbmc_jet_vehi-value.
*    ENDIF.

  ENDMETHOD.


  METHOD get_sapmaterial.
*    IF it_matnr IS NOT INITIAL.
*      SELECT old_material sap_material
*        FROM ymat_bismt_model
*        INTO TABLE et_materialinfo
*        FOR ALL ENTRIES IN it_matnr
*        WHERE old_material = it_matnr-table_line.
*    ENDIF.
  ENDMETHOD.


  METHOD get_sappartner_for_legacy.
    DATA: it_partner TYPE TABLE OF bu_partner,
          ts_partner LIKE LINE OF et_partnerinfo,
          lv_type    TYPE char6,
          ts_bapiret LIKE LINE OF et_return.
*
*    IF iv_cust_vendor = ycl_vehicle_util=>gc_vendor. "if vendor
*      lv_type = yif_dbm_jet_constants=>gc_sapvendor_type. "'FLVN01'
*    ELSEIF iv_cust_vendor =  ycl_vehicle_util=>gc_customer. "if customer
*      lv_type = yif_dbm_jet_constants=>gc_sapcustomer_type. "'FLCU01'
*    ELSE.
*      ts_bapiret-type = yif_dbm_jet_constants=>gc_value_e.
*      ts_bapiret-id = yif_dbm_jet_constants=>gc_msg_class_id.
*      ts_bapiret-number = 103.
*      MESSAGE s103(ymsg_jet_dbm) INTO ts_bapiret-message.
*      APPEND ts_bapiret TO et_return.
*      RETURN.
*    ENDIF.

    IF it_bu_sort2 IS NOT INITIAL.
      SELECT but000~partner but000~bu_sort1
        FROM but000
        INNER JOIN but100
        ON but000~partner = but100~partner
        INTO TABLE et_partnerinfo
        FOR ALL ENTRIES IN it_bu_sort2
        WHERE bu_sort1 = it_bu_sort2-table_line
        AND rltyp = lv_type.
    ENDIF.

    SORT et_partnerinfo BY bu_sort2.
    DELETE ADJACENT DUPLICATES FROM et_partnerinfo COMPARING bu_sort2.

  ENDMETHOD.


  METHOD get_vehicle_bob.
*&**********************************************************************
*&   Author           : Clinton k fernandes                            *
*&   Date             : 10-04-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Method Name      : GET_VEHICLE_BOB                                *
*
*&**********************************************************************
*& Method Definition : method returns the BOB structures               *
*                      for given VGUIDs (DE1K903481)                   *
*&
*&**********************************************************************
*& METHOD CHANGES / Modification Logs :                                *
*&**********************************************************************
*&   Date   | Request    | Programmer     |     Changes                *
*&+-------------------------------------------------------------------+*
*& 10.04.17 | DE1K903481 | Clinton K fdes |       New                  *
*&+-------------------------------------------------------------------+*



    DATA :lo_veh_buf        TYPE REF TO /dbe/cl_veh_buf,
          lt_veh_bob        TYPE /dbe/t_veh_bob,
          ls_veh_bob        LIKE LINE OF lt_veh_bob,
          lo_cx_root        TYPE REF TO cx_root,
          lt_veh_bobget     TYPE /dbe/t_veh_bobget,
          ls_veh_bobget     LIKE LINE OF lt_veh_bobget,
          lv_vguid          TYPE vlc_guid,
          lo_veh_dbmvehicle TYPE REF TO /dbe/cl_veh_dbmvehicle,
          ts_bob_ref        TYPE  ty_bob_ref,
          ts_bob_structures TYPE ty_bob_structures.

    "get the reference to the buffer
    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    lt_veh_bob = lo_veh_buf->get_all( ).
    "loop at each VGUID and process
    LOOP AT it_vguid INTO lv_vguid.

      TRY.
          CLEAR : ls_veh_bob,
                  lt_veh_bobget,
                  ls_veh_bob.
          READ TABLE lt_veh_bob INTO ls_veh_bob WITH KEY guid = lv_vguid.
          IF sy-subrc <> 0.

            ls_veh_bobget-guid    = lv_vguid.
            ls_veh_bobget-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
            INSERT ls_veh_bobget INTO TABLE lt_veh_bobget.

            CALL METHOD /dbe/cl_veh_dbmvehicle=>get_dbmvehicle
              EXPORTING
                it_bobget   = lt_veh_bobget
*               is_req_data = is_req_data
                iv_iobj_req = abap_true
              IMPORTING
                et_bob      = lt_veh_bob.
          ENDIF.

          READ TABLE lt_veh_bob INTO ls_veh_bob WITH KEY guid = lv_vguid.
          IF sy-subrc EQ 0.
            "cast bob reference
            lo_veh_dbmvehicle ?= ls_veh_bob-bobref.
            ts_bob_ref-vguid = lv_vguid.
            ts_bob_ref-bobref = lo_veh_dbmvehicle.
            "append to table with corresponding VGUID.
            APPEND ts_bob_ref TO et_bobref.

          ENDIF.
        CATCH  cx_root INTO lo_cx_root.

          CALL METHOD lo_veh_buf->get_messages
            EXPORTING
              io_cx_root    = lo_cx_root
            IMPORTING
              et_bapireturn = et_bapiret2.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_vehicle_bob_db.
*&**********************************************************************
*&   Author           : Clinton k fernandes                            *
*&   Date             : 10-04-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Method Name      : GET_VEHICLE_BOB_DB                             *
*
*&**********************************************************************
*& Method Definition : method returns the BOB structures               *
*                      for given VGUIDs (DE1K903481)                   *
*&
*&**********************************************************************
*& METHOD CHANGES / Modification Logs :                                *
*&**********************************************************************
*&   Date   | Request    | Programmer     |     Changes                *
*&+-------------------------------------------------------------------+*
*& 10.04.17 | DE1K903481 | Clinton K fdes |       New                  *
*&+-------------------------------------------------------------------+*
    DATA: lo_veh_buf              TYPE REF TO /dbe/cl_veh_buf,
          lt_veh_bob              TYPE /dbe/t_veh_bob,
          ls_veh_bob              LIKE LINE OF lt_veh_bob,
          lo_cx_root              TYPE REF TO cx_root,
          lt_veh_bobget           TYPE /dbe/t_veh_bobget,
          ls_veh_bobget           LIKE LINE OF lt_veh_bobget,
          lv_vguid                TYPE vlc_guid,
          lo_veh_dbmvehicle       TYPE REF TO /dbe/cl_veh_dbmvehicle,
          ts_vlcactdata_head      TYPE vlcactdata_head_s,
          ts_vlcactdata_item      TYPE vlcactdata_item_s,
          ts_iobj_data_single_com TYPE /dbe/iobj_data_single_com_s,
          ts_vlcdiavehi           TYPE vlcdiavehi,
          ts_iobj_data_multi_com  TYPE /dbe/iobj_data_multi_com_s,
          it_vlcadddata           TYPE vlcadddata_item_t,
          rt_data                 TYPE REF TO data,
          rs_vlcdiavehi           TYPE REF TO vlcdiavehi,
          rs_vlcactdata_head      TYPE REF TO vlcactdata_head_s,
          rs_vlcactdata_item      TYPE REF TO vlcactdata_item_s,
          rt_vlcadddata_item      TYPE REF TO vlcadddata_item_t,
          rs_iobj_data_single_com TYPE REF TO /dbe/iobj_data_single_com_s,
          rs_iobj_data_multi_com  TYPE REF TO /dbe/iobj_data_multi_com_s,
          ts_bob_structures       TYPE ty_bob_structures.
    "get the reference to the buffer
    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    lt_veh_bob = lo_veh_buf->get_all( ).

    LOOP AT it_vguid INTO lv_vguid.

      TRY.
          CLEAR : ls_veh_bob,
                  lt_veh_bobget,
                  ts_bob_structures.

          READ TABLE lt_veh_bob INTO ls_veh_bob WITH KEY guid = lv_vguid.
          IF sy-subrc <> 0.

            ls_veh_bobget-guid    = lv_vguid.
            ls_veh_bobget-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
* No locking request is possible through the interface of this function module
            INSERT ls_veh_bobget INTO TABLE lt_veh_bobget.

            CALL METHOD /dbe/cl_veh_dbmvehicle=>get_dbmvehicle
              EXPORTING
                it_bobget   = lt_veh_bobget
                iv_iobj_req = abap_true
              IMPORTING
                et_bob      = lt_veh_bob.
          ENDIF.
          "get reference to the structures
          "Dereference the structure into the local structure
          "append to the table with the corresponding VGUID.
          READ TABLE lt_veh_bob INTO ls_veh_bob WITH KEY guid = lv_vguid.
          IF sy-subrc EQ 0.

            lo_veh_dbmvehicle ?= ls_veh_bob-bobref.
            rs_vlcactdata_head ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_head_s ).
            ts_vlcactdata_head =  rs_vlcactdata_head->*.

            rs_vlcactdata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_item_s ).
            ts_vlcactdata_item = rs_vlcactdata_item->*.

            rt_vlcadddata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcadddata_item_t ).
            it_vlcadddata[] = rt_vlcadddata_item->*[] .

            rs_iobj_data_single_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_single_com_s ).
            ts_iobj_data_single_com = rs_iobj_data_single_com->* .

            rs_iobj_data_multi_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_multi_com_s ).
            ts_iobj_data_multi_com = rs_iobj_data_multi_com->*.

            rs_vlcdiavehi ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
            ts_vlcdiavehi = rs_vlcdiavehi->*.
            "assign to exporting table
            ts_bob_structures-vguid = lv_vguid.
            ts_bob_structures-ts_vlcactdata_head = ts_vlcactdata_head.
            ts_bob_structures-ts_vlcactdata_item = ts_vlcactdata_item.
            ts_bob_structures-it_vlcadddata = it_vlcadddata.
            ts_bob_structures-ts_iobj_data_single_com = ts_iobj_data_single_com.
            ts_bob_structures-ts_iobj_data_multi_com = ts_iobj_data_multi_com.
            ts_bob_structures-ts_vlcdiavehi = ts_vlcdiavehi.
            APPEND ts_bob_structures TO et_bob_structures.
          ENDIF.
        CATCH  cx_root INTO lo_cx_root.

          CALL METHOD lo_veh_buf->get_messages
            EXPORTING
              io_cx_root    = lo_cx_root
            IMPORTING
              et_bapireturn = et_bapiret2.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_vehicle_db.
*&**********************************************************************
*&   Author           : Clinton k fernandes                            *
*&   Date             : 10-04-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Method Name      : GET_VEHICLE                                    *
*
*&**********************************************************************
*& Method Definition : retrieve vehicle details (DE1K903481)           *
*&
*&**********************************************************************
*& METHOD CHANGES / Modification Logs :                                *
*&**********************************************************************
*&   Date   | Request    | Programmer     |     Changes                *
*&+-------------------------------------------------------------------+*
*& 10.04.17 | DE1K903481 | Clinton K fdes |       New                  *
*&+-------------------------------------------------------------------+*


    FIELD-SYMBOLS : <fs_key_val> TYPE ecm_s_key_value_pair.
    DATA:
      it_vlch_searchrange_gt TYPE TABLE OF vlch_searchrange_ps,
      it_vlch_conditions_gt  TYPE TABLE OF vlch_condition_ps,
      it_vlcvehicle_gt       TYPE TABLE OF vlcvehicle,
      ts_value               LIKE LINE OF it_key_val,
      ts_key_val             LIKE LINE OF it_key_val,
      ts_vlch_searchrange_gs TYPE vlch_searchrange_ps.

    ts_vlch_searchrange_gs-sign = 'I'..
    ts_vlch_searchrange_gs-option = 'EQ'.
**********************************************************************
*    get each key value -> (column -> Value) and create a range table*
**********************************************************************
    LOOP AT it_key_val INTO ts_key_val.

      ts_vlch_searchrange_gs-low = ts_key_val-value.

      ts_vlch_searchrange_gs-qual = ts_key_val-key .
      APPEND ts_vlch_searchrange_gs TO it_vlch_searchrange_gt.

    ENDLOOP.
**********************************************************************
*    generate conditions                                             *
**********************************************************************
    CALL FUNCTION 'VELO13_PREPARE_CONDITION_TAB'
      TABLES
        p_vlcvehicrit_it      = it_vlch_searchrange_gt
        p_conditions_et       = it_vlch_conditions_gt
      EXCEPTIONS
        invalid_select_option = 1
        invalid_select_sign   = 2
        no_criterions         = 3
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
**********************************************************************
*    get vehicle data as per the conditions generated                *
**********************************************************************
      CALL FUNCTION 'VELO14_VEHI_SELECT'
        TABLES
          vlcvehicle_et      = it_vlcvehicle_gt
          conditions_it      = it_vlch_conditions_gt
        EXCEPTIONS
          no_vehicle_found   = 1
          select_error       = 2
          no_criteria_passed = 3
          result_overflow    = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        et_vlevehicle = it_vlcvehicle_gt.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD get_vehicle_from_buffer.
    DATA lo_veh_buf                   TYPE REF TO /dbe/cl_veh_buf.
    DATA lt_veh_bob                   TYPE /dbe/t_veh_bob.
    DATA ls_veh_bob                   LIKE LINE OF lt_veh_bob.
    DATA lv_vguid_s                   TYPE string.
    DATA lv_dummy_guid                TYPE /dbe/veh_guid VALUE 1.
    DATA lv_vguid_len                 TYPE i.
    DATA lt_veh_bobnew                TYPE /dbe/t_veh_bobnew.
    DATA ls_veh_bobnew                TYPE /dbe/s_veh_bobnew.
    DATA lo_cx_root                   TYPE REF TO cx_root.
    DATA lt_veh_bobget             TYPE /dbe/t_veh_bobget.
    DATA ls_veh_bobget             LIKE LINE OF lt_veh_bobget.

    "get the reference to the buffer
    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).

    TRY.

        lt_veh_bob = lo_veh_buf->get_all( ).
        READ TABLE lt_veh_bob INTO ls_veh_bob WITH KEY guid = iv_veh_guid.
        IF sy-subrc <> 0.
**         check dummy guid - length < 22 characters    N:2263179
*          lv_vguid_s = iv_veh_guid.
*          CONDENSE lv_vguid_s NO-GAPS.
*          lv_vguid_len = strlen( lv_vguid_s ).
*          IF lv_vguid_len < 22.
*            lv_dummy_guid = iv_veh_guid.
*          ENDIF.
*          "The buffer is empty, create new DBM vehicle in the buffer
*
**Provide Dummy guid
*          ls_veh_bobnew-guid    = lv_dummy_guid.
*          ls_veh_bobnew-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
*
*          INSERT ls_veh_bobnew INTO TABLE lt_veh_bobnew.
*
*          CALL METHOD lo_veh_buf->new_bob
*            EXPORTING
*              it_bobnew = lt_veh_bobnew
*            IMPORTING
*              et_bob    = lt_veh_bob.

          ls_veh_bobget-guid    = iv_veh_guid.
          ls_veh_bobget-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
* No locking request is possible through the interface of this function module
          INSERT ls_veh_bobget INTO TABLE lt_veh_bobget.

          CALL METHOD /dbe/cl_veh_dbmvehicle=>get_dbmvehicle
            EXPORTING
              it_bobget   = lt_veh_bobget
*             is_req_data = is_req_data
              iv_iobj_req = abap_true
            IMPORTING
              et_bob      = lt_veh_bob.
        ENDIF.

        READ TABLE lt_veh_bob INTO ls_veh_bob WITH KEY guid = iv_veh_guid.
        IF sy-subrc EQ 0.
          " We know that the interface reference returned in ls_veh_bob is a DBMVEHICLE
          " Need to cast to DBMVEHICLE, to get access to the COM layer
          eo_veh_dbmvehicle ?= ls_veh_bob-bobref.

          "indicate that the guid is a DUMMY guid yet.
*          eo_veh_dbmvehicle->set_dummy_guid( lv_dummy_guid ).
        ENDIF.
      CATCH  cx_root INTO lo_cx_root.

        CALL METHOD lo_veh_buf->get_messages
          EXPORTING
            io_cx_root    = lo_cx_root
          IMPORTING
            et_bapireturn = et_bapiret2.
    ENDTRY.
  ENDMETHOD.


  METHOD refresh_bob_buffer.
    DATA : lo_veh_buf TYPE REF TO /dbe/cl_veh_buf,
           it_veh_bob TYPE /dbe/t_veh_bob.

    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    IF lo_veh_buf IS BOUND.
      it_veh_bob =  lo_veh_buf->get_all( ).
      lo_veh_buf->unlock(
        EXPORTING
          it_bob                    =  it_veh_bob    " Table type for /dbe/S_VEH_BOB
       ).

      lo_veh_buf->del_buf(
          it_bob = it_veh_bob
      ).
    ENDIF.
  ENDMETHOD.


  METHOD update_vehicle_bob.
*&**********************************************************************
*&   Author           : Amit Thapa                                     *
*&   Date             : 10-04-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Method Name     : UPDATE_VEHICLE_BOB                              *
*
*&**********************************************************************
*& Method Definition : Method to update existing vehicle (DE1K903481)  *
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 10.04.17 | DE1K903481 | Amit Thapa   |       New                    *
*&+-------------------------------------------------------------------+*
    DATA: it_veh_bob              TYPE /dbe/t_veh_bob,
          ts_veh_bob              LIKE LINE OF it_veh_bob,
          it_bapiret2             TYPE TABLE OF bapiret2,
          ls_bapiret2             TYPE          bapiret2,
          lo_veh_buf              TYPE REF TO /dbe/cl_veh_buf,
          lo_veh_dbmvehicle       TYPE REF TO /dbe/cl_veh_dbmvehicle,
          lo_iobject              TYPE REF TO /dbe/cl_veh_iobject_vehicle,
          lo_cx_root              TYPE REF TO cx_root,
          rs_vlcdiavehi           TYPE REF TO vlcdiavehi,
          rs_vlcactdata_head      TYPE REF TO vlcactdata_head_s,
          rs_vlcactdata_item      TYPE REF TO vlcactdata_item_s,
          rt_vlcadddata_item      TYPE REF TO vlcadddata_item_t,
          rs_vlcadddata_item      TYPE REF TO vlcadddata_item_t,
          ls_vlcactdata_head      TYPE vlcactdata_head_s,
          rs_iobj_data_single_com TYPE REF TO /dbe/iobj_data_single_com_s,
          rs_iobj_data_multi_com  TYPE REF TO /dbe/iobj_data_multi_com_s,
          lt_vlcactdata_item      TYPE vlcactdata_item_t,
          it_veh_bobget           TYPE /dbe/t_veh_bobget,
          ts_veh_bobget           LIKE LINE OF it_veh_bobget.

    DATA: lv_vguid                TYPE vlc_guid.
    FIELD-SYMBOLS: <fs_veh_bob>   LIKE LINE OF it_veh_bob.
    "Read Vehicle GUID from DB if Vehicle No. Provided.
    lv_vguid = iv_vguid.
    IF lv_vguid IS INITIAL AND iv_vid IS NOT INITIAL.
      SELECT SINGLE vguid FROM vlcvehicle
        INTO lv_vguid
        WHERE vhcle = iv_vid.
      IF sy-subrc <> 0.
        MESSAGE e089(velo) INTO ls_bapiret2-message.
        ls_bapiret2-type = 'E'.
*        ls_bapiret2-id =
*ls_bapiret2-id VELO089
*      ENDIF.
      ENDIF.
    ENDIF.

*Get the reference to the buffer
    lo_veh_buf              = /dbe/cl_veh_buf=>get_instance( ).

    TRY .
        it_veh_bob = lo_veh_buf->get_all( ).
*        READ TABLE it_veh_bob INTO ts_veh_bob WITH KEY guid = lv_vguid.
        READ TABLE it_veh_bob ASSIGNING <fs_veh_bob> WITH KEY guid = lv_vguid.
        IF sy-subrc <> 0.
          ts_veh_bobget-guid    = lv_vguid.
          ts_veh_bobget-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
* No locking request is possible through the interface of this function module
          INSERT ts_veh_bobget INTO TABLE it_veh_bobget.

          CALL METHOD /dbe/cl_veh_dbmvehicle=>get_dbmvehicle
            EXPORTING
              it_bobget   = it_veh_bobget
*             is_req_data = is_req_data
              iv_iobj_req = abap_true
            IMPORTING
              et_bob      = it_veh_bob.
        ENDIF.


*        READ TABLE it_veh_bob INTO ts_veh_bob WITH KEY guid = lv_vguid.
        READ TABLE it_veh_bob ASSIGNING <fs_veh_bob> WITH KEY guid = lv_vguid.

        IF sy-subrc EQ 0.
* We know that the interface reference returned in ts_veh_bob is a DBMVEHICLE
* Need to cast to DBMVEHICLE, to get access to the COM layer
          lo_veh_dbmvehicle ?= <fs_veh_bob>-bobref.


* Move the data from the interface to the COM layer
          IF is_vlcactdata_head IS SUPPLIED.
            rs_vlcactdata_head ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_head_s ).
            rs_vlcactdata_head->* = is_vlcactdata_head.
          ENDIF.
          IF is_vlcactdata_item IS SUPPLIED.
            rs_vlcactdata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcactdata_item_s ).
            rs_vlcactdata_item->* = is_vlcactdata_item.
          ENDIF.
          IF it_vlcadddata IS SUPPLIED.
            rt_vlcadddata_item ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcadddata_item_t ).
            rt_vlcadddata_item->*[] = it_vlcadddata[].
          ENDIF.
          IF is_iobj_data_single_com IS SUPPLIED.
            rs_iobj_data_single_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_single_com_s ).
            rs_iobj_data_single_com->* = is_iobj_data_single_com.
          ENDIF.
          IF is_iobj_data_multi_com IS SUPPLIED.
            rs_iobj_data_multi_com ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_iobj_data_multi_com_s ).
            rs_iobj_data_multi_com->* = is_iobj_data_multi_com.
          ENDIF.
          IF is_vlcdiavehi IS SUPPLIED.
            rs_vlcdiavehi ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
            rs_vlcdiavehi->* = is_vlcdiavehi.
          ENDIF.
* Call the SET_BOB method to set the data from the COM to WORK layer
          "setting the action
          lo_veh_dbmvehicle->set_action( iv_action = 'QMOD'
           iv_wo_prepare = abap_true ).

* Call the SET_BOB method to set the data from the COM to WORK layer
          lo_veh_dbmvehicle->/dbe/if_veh_bob~set_bob( ).
*         data can be changed also by badi_vehicle_api->before_vehicle_set e.g. generic options
*         so move changes back to COM to prevent lost of these changes N:1806382
          lo_veh_dbmvehicle->/dbe/if_veh_bob~fill_com( ).

          IF is_vlcdiavehi IS SUPPLIED.
            rs_vlcdiavehi ?= lo_veh_dbmvehicle->get_data_com( /dbe/cl_veh_dbmvehicle=>gc_vlcdiavehi ).
            rs_vlcdiavehi->* = is_vlcdiavehi.
          ENDIF.


* Call the SET_BOB method to set the data from the COM to WORK layer
          lo_veh_dbmvehicle->/dbe/if_veh_bob~set_bob( ).


        ENDIF.

        APPEND LINES OF lo_veh_dbmvehicle->mt_bapireturn TO ct_bapireturn.

        "Saving the data
        IF iv_save_needed = abap_true.
          lo_veh_dbmvehicle->perform_save( ).
          "Committing the vehicle
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ENDIF.

      CATCH cx_root INTO lo_cx_root.
        CALL METHOD lo_veh_buf->get_messages
          EXPORTING
            io_cx_root    = lo_cx_root
          IMPORTING
            et_bapireturn = it_bapiret2.
        APPEND LINES OF it_bapiret2 TO ct_bapireturn.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.

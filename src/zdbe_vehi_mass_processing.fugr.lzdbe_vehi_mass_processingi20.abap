*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI20 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  TRANSFER_DATA_TO_BUFFER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE transfer_data_to_buffer INPUT."#EC CALLED
**  DATA: lv_value                     TYPE /DBE/ctrl_value,
**          lt_bapiret                   TYPE bapiret2_t,
**          lt_bapiret2                  TYPE bapiret2_t,
**          ls_bapiret2                  TYPE bapiret2,
**          ls_bapiret                   TYPE bapiret2,
**          ls_return                    TYPE /DBE/s_rfc_veh_bapiret,
**          ls_bapireturn                TYPE /DBE/s_rfc_veh_bapiret,
**          lt_vlcactdata_item_rfc       TYPE /DBE/t_rfc_veh_vlcactdata_item,
**          ls_vlcactdata_item_rfc       TYPE /DBE/vlcactdata_item_rfc,
**          ls_vlcactdata_item           TYPE vlcactdata_item_s,
**          ls_vlcactdata_head           TYPE vlcactdata_head_s,
**          lv_action                    TYPE vlc_action,
**
**          ls_new_vehicle               TYPE /DBE/s_veh_bobnew,
**          lt_new_vehicles              TYPE /DBE/t_veh_bobnew,
**          lt_vehicles                  TYPE /DBE/t_veh_bob,
**          lt_vehicles2                 TYPE /DBE/t_veh_bob,
**          ls_vehicles                  TYPE /DBE/s_veh_bob,
**          ls_vehicles2                 TYPE /DBE/s_veh_bob,
**          lo_vehbuf                    TYPE REF TO /DBE/cl_veh_buf,
**          lr_vehicle                   TYPE REF TO /DBE/cl_veh_dbmvehicle, "#EC NEEDED
**          lr_vehicle2                  TYPE REF TO /DBE/cl_veh_dbmvehicle, "#EC NEEDED
**
**          ls_bob                       TYPE /DBE/s_veh_bob,
**
**          lo_cx_root                   TYPE REF TO cx_root,
**
**          ls_vguid_extension_in        TYPE /DBE/s_rfc_veh_extension_in,
**          ls_extension_in              TYPE bapiparex,
**          lt_extension_in              TYPE TABLE OF bapiparex,
**          ls_iobj_data_single_com_rfc  TYPE /DBE/s_rfc_veh_iobj_single_com,
**          ls_iobj_data_single_com      TYPE /DBE/iobj_data_single_com_s,
**          lt_ltext                     TYPE TABLE OF /DBE/lt_ltext_rfc,
**          ls_ltext                     TYPE /DBE/lt_ltext_rfc,
**          ls_guid_ltext                TYPE /DBE/s_rfc_veh_ltext,
**          ls_guid_vlcaddata            TYPE /DBE/vlcadddata_item_rfc,
**          ls_vlcadddata                TYPE vlcadddata_item_s,
**          lt_vlcadddata                TYPE vlcadddata_item_t,
**          ls_guid_ioptiont             TYPE /DBE/s_rfc_veh_ioptiont,
**          ls_ioptiont                  TYPE /DBE/V_IOPTIONT_DYNP_SV,
**          ls_iobj_data_multi_com       TYPE /DBE/iobj_data_multi_com_s,
**          ls_guid_ioption              TYPE /DBE/s_rfc_veh_ioption,
**          ls_ioption                   TYPE /DBE/V_IOPTION_DYNP_SV,
**          ls_guid_ipartner             TYPE /DBE/s_rfc_veh_ipartner,
**          ls_ipartner                  TYPE /DBE/V_IPARTNER_DYNP_SV,
**          ls_guid_ireghist             TYPE /DBE/s_rfc_veh_ireghist,
**          ls_ireghist                  TYPE LINE OF /DBE/iobj_data_multi_com_s-/DBE/V_IREGHIST,
**          ls_guid_isint                TYPE /DBE/s_rfc_veh_isint,
**          ls_isint                     TYPE /DBE/V_ISINT_DYNP_SV,
**          ls_guid_iwty                 TYPE /DBE/s_rfc_veh_iwty,
**          ls_iwty                      TYPE /DBE/V_IWTY_DYNP_SV,
**          ls_guid_ikeys                TYPE /DBE/s_rfc_veh_ikeys,
**          ls_ikeys                     TYPE /DBE/V_IKEYS_DYNP_SV,
**          ls_guid_imodelt              TYPE /DBE/s_rfc_veh_imodelt,
**          ls_imodelt                   TYPE /DBE/V_IMODELT_DYNP_SV,
**          ls_guid_ircl                 TYPE /DBE/s_rfc_veh_ircl,
**          ls_ircl                      TYPE /DBE/V_IRCL_DYNP_SV_EXT,
**          ls_guid_ltext_opt            TYPE /DBE/s_rfc_veh_ltext,
**          ls_ltext_opt                 TYPE /DBE/lt_ltext_rfc,
**          lt_ltext_opt                 TYPE /DBE/lt_ltext_rfc_tt,
**          lv_item_lines_all            TYPE i,
**          lv_item_lines_vguid          TYPE i,
**          lv_item_lines_novguid        TYPE i,
**          lv_continue                  TYPE abap_bool,
**          lr_iobj_single_com           TYPE REF TO /DBE/iobj_data_single_com_s,
**          lr_iobj_multi_com            TYPE REF TO /DBE/iobj_data_multi_com_s,
**          rs_vlcactdata_head           TYPE REF TO vlcactdata_head_s,
**          rs_vlcactdata_item           TYPE REF TO vlcactdata_item_s,
**          rt_vlcadddata_item           TYPE REF TO vlcadddata_item_t,
**
**          lv_dummy_guid                TYPE /DBE/veh_guid,
**          es_vguid                     TYPE /DBE/s_rfc_veh_vguid_created.
**
**  DATA:
**    gv_bob_type TYPE /DBE/veh_bobtype.
**  DATA lt_veh_bobget             TYPE /DBE/t_veh_bobget.
**  DATA ls_veh_bobget             LIKE LINE OF lt_veh_bobget.
**  DATA lt_bob                    TYPE /DBE/t_veh_bob.
**  DATA lo_veh_dbmvehicle         TYPE REF TO /DBE/cl_veh_dbmvehicle.
**
**  DATA lv_category_id TYPE comt_category_id.
***  DATA ls_category_id LIKE LINE OF it_category_id.
**  DATA lo_iobject TYPE REF TO /DBE/cl_veh_iobject_vehicle.
**  DATA : lv_no_in_char               TYPE c,
**
**           lt_iobj_data_single_com_rfc TYPE /DBE/t_rfc_veh_iobj_single_com,
**          gt_iobj_single TYPE TABLE OF gs_iobj_data_single_com,
**           lv_number                   TYPE i VALUE 1.
*** Create an instance of the buffer...
**  lo_vehbuf = /DBE/cl_veh_buf=>get_instance( ).
**
**  IF gv_bob_type IS INITIAL.
**    gv_bob_type = /DBE/cl_veh_dbmvehicle=>gc_bobtype.
**  ENDIF.
*** Header data
**  MOVE-CORRESPONDING vlcactdata_head_s TO ls_vlcactdata_head.
**  MOVE-CORRESPONDING vlcactdata_head_s TO gs_vlcactdata_head.
*** Item data
**  MOVE-CORRESPONDING vlcactdata_item_s TO ls_vlcactdata_item.
**
***  gs_iobj_single-category_id  = 'DBM_PASSENGERCAR' .
**
**  DO ls_vlcactdata_head-numofvehi TIMES.
**    lv_no_in_char = lv_number.
**    CONCATENATE  'DUMMY' lv_no_in_char INTO lv_dummy_guid.
***    gs_iobj_single-guid   = lv_dummy_guid.
**    INSERT gs_iobj_single INTO TABLE gt_iobj_single.
**
**    ls_vlcactdata_item-vguid           = lv_dummy_guid.
**    INSERT ls_vlcactdata_item         INTO TABLE gt_vlcactdata_item.
**
**    ls_category_id-guid                 = lv_dummy_guid.
**    ls_category_id-category_id          = gs_iobj_single-category_id  ."gv_iobj_catid .
**    INSERT ls_category_id              INTO TABLE lt_category_id.
**
**    ls_new_vehicle-guid    = ls_vlcactdata_item-vguid.
**    ls_new_vehicle-bobtype = gv_bob_type.
**    INSERT ls_new_vehicle INTO TABLE lt_new_vehicles.
**
**    lv_number = lv_number + 1.
**  ENDDO.
**
***  CLEAR gs_vlcactdata_head.
**
**  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**    EXPORTING
**      input  = gs_vlcactdata_head-matnr
**    IMPORTING
**      output = gs_vlcactdata_head-matnr.
**  TRY.
**
**      CALL METHOD lo_vehbuf->new_bob
**        EXPORTING
**          it_bobnew = lt_new_vehicles
**        IMPORTING
**          et_bob    = lt_vehicles.
**    CATCH /DBE/cx_veh_error_occured INTO lo_cx_root.
**
**      CALL METHOD lo_vehbuf->get_messages
**        EXPORTING
**          io_cx_root        = lo_cx_root
**        IMPORTING
**          et_bapireturn_rfc = et_return.
**  ENDTRY.
**  LOOP AT lt_vehicles INTO ls_vehicles.
**    TRY.
**        lr_vehicle ?= ls_vehicles-bobref.
**
*** Indicate that the guid is a DUMMY guid yet.
**        lr_vehicle->set_dummy_guid( ls_vehicles-guid ).
**        lr_vehicle->clear_dialogue_allowed( ).
**
***        es_vguid-dummyguid = ls_vehicles-guid.
***        APPEND es_vguid TO et_vguid.
**
**        lr_iobj_single_com ?= lr_vehicle->get_data_com(
**                 lr_vehicle->gc_iobj_data_single_com_s ).
**
**        MOVE-CORRESPONDING ls_iobj_data_single_com TO lr_iobj_single_com->*.
***       multi com
**        lr_iobj_multi_com ?= lr_vehicle->get_data_com(
**                 lr_vehicle->gc_iobj_data_multi_com_s ).
**
**        MOVE-CORRESPONDING ls_iobj_data_multi_com TO lr_iobj_multi_com->*.
**
***       vlcactdata head
**        rs_vlcactdata_head ?= lr_vehicle->get_data_com(
**                /DBE/cl_veh_dbmvehicle=>gc_vlcactdata_head_s ).
**
**        MOVE ls_vlcactdata_head TO rs_vlcactdata_head->*.
**
***       vlcactdata item structure
**        rs_vlcactdata_item ?= lr_vehicle->get_data_com(
**                /DBE/cl_veh_dbmvehicle=>gc_vlcactdata_item_s ).
**
**        MOVE ls_vlcactdata_item TO rs_vlcactdata_item->*.
*** Catid
**        lo_iobject ?= lr_vehicle->iobject_get( ).
**        lo_iobject->set_category_data( lv_category_id ).
**
**        lr_vehicle->set_action( iv_action = lv_action iv_wo_prepare = abap_true ).
**
***       vlcaDDdata item table
**        rt_vlcadddata_item ?= lr_vehicle->get_data_com(
**               /DBE/cl_veh_dbmvehicle=>gc_vlcadddata_item_t ).
**
**        INSERT LINES OF lt_vlcadddata INTO TABLE rt_vlcadddata_item->*.
**      CATCH cx_static_check
**            cx_root INTO lo_cx_root.
**
**        CALL METHOD lo_vehbuf->get_messages
**          EXPORTING
**            io_cx_root        = lo_cx_root
**          IMPORTING
**            et_bapireturn_rfc = et_return.
**    ENDTRY.
**
**  ENDLOOP.
**
*** Dependency Check
**  TRY.
**      lo_vehbuf->dependency_check( lt_vehicles ).
**    CATCH /DBE/cx_veh_error_occured INTO lo_cx_root.
**
**      CALL METHOD lo_vehbuf->get_messages
**        EXPORTING
**          io_cx_root        = lo_cx_root
**        IMPORTING
**          et_bapireturn_rfc = et_return.
*** Exit processing, dependency error
**      RETURN.
**    CATCH cx_static_check INTO lo_cx_root.
**
**      CALL METHOD lo_vehbuf->get_messages
**        EXPORTING
**          io_cx_root        = lo_cx_root
**        IMPORTING
**          et_bapireturn_rfc = et_return.
*** Exit processing, dependency error
**      RETURN.
**  ENDTRY.
**
*** ------------------------------------------------------------------------------
*** 4.) SET_BOB
*** ------------------------------------------------------------------------------
**
**  LOOP AT lt_vehicles INTO ls_vehicles.
**    TRY.
**        lr_vehicle ?= ls_vehicles-bobref.
*** A new vehicle is SET, clear the MEMORY ID (see /DBE/VM10_SET_MODEL_MESTER)
**        CONCATENATE sy-uname sy-datum INTO lv_id.
**        DATA lv_model_guid TYPE /DBE/MODEL_GUID.
**        CLEAR lv_model_guid.
**        EXPORT model_guid FROM lv_model_guid TO MEMORY ID lv_id.
**
**        lr_vehicle->/DBE/if_veh_bob~set_bob( ).
**      CATCH cx_static_check
**            cx_root INTO lo_cx_root.
**
**        CALL METHOD lo_vehbuf->get_messages
**          EXPORTING
**            io_cx_root        = lo_cx_root
**          IMPORTING
**            et_bapireturn_rfc = et_return.
**    ENDTRY.
**  ENDLOOP.

ENDMODULE.                 " TRANSFER_DATA_TO_BUFFER  INPUT

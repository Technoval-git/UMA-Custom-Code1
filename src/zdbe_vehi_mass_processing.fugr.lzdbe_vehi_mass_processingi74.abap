*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI74.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0551  INPUT                      N:2426282
*&---------------------------------------------------------------------*
MODULE user_command_0551 INPUT.

  PERFORM f_user_command_0551.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      FORM f_user_command_0551                             "N:2426282
*&---------------------------------------------------------------------*
FORM f_user_command_0551.
  DATA: lt_bob              TYPE /dbe/t_veh_bob,
        ls_bob              TYPE /dbe/s_veh_bob,
        lo_vehicle          TYPE REF TO /dbe/cl_veh_dbmvehicle,
        lo_wrapper          TYPE REF TO /dbe/cl_oe_wrapper,
        lo_veh_buf          TYPE REF TO /dbe/cl_veh_buf,
        lo_static_check_exc TYPE REF TO /dbe/cx_veh_static_check,
        lr_vlcactdata_h     TYPE REF TO vlcactdata_head_s,
        lr_vlcdiavehi       TYPE REF TO vlcdiavehi,
        lt_objects          TYPE /dbe/cl_oe_wrapper=>ty_oe_objref_t,
        ls_objects          TYPE /dbe/cl_oe_wrapper=>ty_oe_objref,
        ls_context          TYPE vlcmsgcontxt,
        ls_context_bal      TYPE bal_s_cont,
        lt_bapireturn       TYPE bapiret2_t,
        lv_failed_count     TYPE i,
        lv_success_count    TYPE i.

  CONSTANTS cv_real_action      TYPE vlc_action VALUE 'QVTP'.

  IF gv_ok_code EQ gc_exec_fc.    " Execution

    "Fetch selected vehicles from vehicle buffer object
    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).

    IF lo_veh_buf IS BOUND.
      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob.
    ENDIF.


    LOOP AT lt_bob INTO ls_bob.
      "Current vehicle
      lo_vehicle ?= ls_bob-bobref.

      REFRESH lt_objects.
      ls_objects-objref = lo_vehicle.
      APPEND ls_objects TO lt_objects.
      lo_wrapper = /dbe/cl_oe_wrapper=>get_wrapper( lt_objects ).

      lo_wrapper->register_object( lo_vehicle ).

      TRY.
          lr_vlcdiavehi   ?=  lo_vehicle->get_data_com( lo_vehicle->gc_vlcdiavehi ).
        CATCH /dbe/cx_veh_layer_not_found INTO lo_static_check_exc.
          lo_veh_buf->get_messages( EXPORTING io_cx_root    = lo_static_check_exc
                                    IMPORTING et_bapireturn = lt_bapireturn ).
          ADD 1 TO lv_failed_count.
          EXIT.
      ENDTRY.

      TRY.
          lo_vehicle->set_action( cv_real_action ).
          lo_vehicle->mo_wrapper = lo_wrapper.
          lo_vehicle->request_change_signal( ).

          lo_wrapper->ms_oe_control-actvt = /dbe/cl_object_engine=>c_actvt_change.
          lo_wrapper->execute_event( 'SAVE' ).
          IF lo_vehicle->mo_bal IS BOUND.
            lt_bapireturn = lo_vehicle->mo_bal->export( ).
            lo_vehicle->mo_bal->tmp_refresh( ).

            "Log message
            PERFORM f_add_bapiret2_with_context USING lo_vehicle
                                                      lt_bapireturn
                                                      lr_vlcdiavehi->*
                                                      cv_real_action.

          ENDIF.
          ADD 1 TO lv_success_count.
          lo_vehicle->fill_com( ).

        CATCH /dbe/cx_veh_static_check INTO lo_static_check_exc.
          ADD 1 TO lv_failed_count.
*       Log message
          lt_bapireturn = lo_vehicle->mo_bal->export( ).
          lo_vehicle->mo_bal->tmp_refresh( ).
          PERFORM f_add_bapiret2_with_context USING lo_vehicle
                                                    lt_bapireturn
                                                    lr_vlcdiavehi->*
                                                    cv_real_action.
          EXIT.

        CATCH /dbe/cx_oe_nothing_selected
              /dbe/cx_oe_user_abort
              /dbe/cx_oe_event_denied
              /dbe/cx_oe_action_error
              /dbe/cx_oe_internal_error.
          ADD 1 TO lv_failed_count.
          IF lo_vehicle->mo_bal IS BOUND.
            lt_bapireturn = lo_vehicle->mo_bal->export( ).
            lo_vehicle->mo_bal->tmp_refresh( ).

            PERFORM f_add_bapiret2_with_context USING lo_vehicle
                                                      lt_bapireturn
                                                      lr_vlcdiavehi->*
                                                      cv_real_action.
          ENDIF.
          EXIT.
        CATCH cx_root.
          EXIT.       "Stop execution, errors will be in log
      ENDTRY.
    ENDLOOP.

    IF lv_failed_count IS INITIAL.
      MESSAGE s480(/dbe/vehicle_master) WITH gv_action_text.
    ELSEIF lv_success_count IS INITIAL.
      MESSAGE s479(/dbe/vehicle_master) WITH gv_action_text DISPLAY LIKE 'E'.
    ELSE.
      MESSAGE s478(/dbe/vehicle_master) WITH gv_action_text DISPLAY LIKE 'W'.
    ENDIF.

  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_add_bapiret2_with_context                     N:2426282
*&---------------------------------------------------------------------*
FORM f_add_bapiret2_with_context USING io_vehicle     TYPE REF TO /dbe/cl_veh_dbmvehicle
                                       it_bapiret2_t  TYPE bapiret2_t
                                       is_vlcdiavehi  TYPE vlcdiavehi
                                       iv_action      TYPE vlc_action.

  DATA: ls_context     TYPE vlcmsgcontxt,
        ls_context_bal TYPE bal_s_cont.

  ls_context-vhcle    = is_vlcdiavehi-vhcle.
  ls_context-vhcex    = is_vlcdiavehi-vhcex.
  ls_context-vhvin    = is_vlcdiavehi-vhvin.
  ls_context-actiont  = iv_action.
  "Set context to be logged in BAL
  ls_context_bal-value    = ls_context.
  ls_context_bal-tabname  = 'VLCMSGCONTXT'  .
  "Log message
  io_vehicle->add_bapiret2_bal( EXPORTING it_bapiret2 = it_bapiret2_t is_context = ls_context_bal ).

ENDFORM.


*&---------------------------------------------------------------------*
*&      Module m_prepare_data_0551 OUTPUT                     N:2426282
*&---------------------------------------------------------------------*
MODULE m_prepare_data_0551 OUTPUT.

  PERFORM f_prepare_data_0551.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  f_prepare_data_0551                             N:2426282
*&---------------------------------------------------------------------*
FORM f_prepare_data_0551.

  PERFORM f_prepare_action_qvtb_data USING ok_code gv_action.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  f_prepare_action_qvtb_data                      N:2426282
*&---------------------------------------------------------------------*
FORM f_prepare_action_qvtb_data  USING p_ok_code
                                       p_gv_action.

  DATA : lo_buf             TYPE REF TO /dbe/cl_veh_buf,
         lo_veh             TYPE REF TO /dbe/cl_veh_dbmvehicle,
         lt_bob             TYPE /dbe/t_veh_bob,
         lt_veh_bob         TYPE /dbe/t_veh_bob,
         lt_bob_all         TYPE /dbe/t_veh_bob,
         ls_bob             TYPE /dbe/s_veh_bob,
         lr_data            TYPE REF TO data,
         lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
         lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
         lr_vlcdiavehi      TYPE REF TO vlcdiavehi,
         lt_guids           TYPE TABLE OF vlcguid,
         ls_guid            TYPE vlcguid,
         lv_werks           TYPE werks,
         lv_diff_werks      TYPE abap_bool,
         lv_lgort           TYPE lgort_d,
         lv_diff_lgort      TYPE abap_bool.

* get instance of the buffer...
  lo_buf = /dbe/cl_veh_buf=>get_instance( ).
* Read the buffer data
  CALL METHOD lo_buf->get_all
    RECEIVING
      rt_bob = lt_bob.


  LOOP AT lt_bob INTO ls_bob.

    lo_veh ?= ls_bob-bobref.

    TRY.
        CALL METHOD lo_veh->set_action
          EXPORTING
            iv_action = gv_action.
      CATCH /dbe/cx_veh_action_not_defined .
      CATCH /dbe/cx_veh_static_check .
    ENDTRY.

    TRY.                                                    "N:2744222
        lr_vlcactdata_head ?= lo_veh->get_data_com( lo_veh->gc_vlcactdata_head_s ).
      CATCH /dbe/cx_veh_layer_not_found.
      CATCH cx_sy_move_cast_error.
    ENDTRY.

*   check different plants
    IF lv_werks IS INITIAL.
      lv_werks = lr_vlcactdata_head->werks.
    ELSEIF lv_werks <> lr_vlcactdata_head->werks.
      lv_diff_werks = abap_true.
    ENDIF.

*   chekl different storage locations
    IF lv_lgort IS INITIAL.
      lv_lgort = lr_vlcactdata_head->lgort.
    ELSEIF lv_lgort <> lr_vlcactdata_head->lgort.
      lv_diff_lgort = abap_true.
    ENDIF.

    MOVE-CORRESPONDING lr_vlcactdata_head->* TO vlcactdata_head_s.

    ls_guid-vguid = ls_bob-guid.
    APPEND ls_guid TO lt_guids.
  ENDLOOP.

  IF lv_diff_werks = abap_true.
    CLEAR: vlcactdata_head_s-werks, vlcactdata_head_s-lgort.
  ELSEIF lv_diff_lgort = abap_true.
    CLEAR vlcactdata_head_s-lgort.
  ENDIF.

* Set data in Vehicle buffer
  IF lo_buf IS BOUND.
    TRY.
        CALL METHOD lo_buf->set_all.
      CATCH /dbe/cx_veh_error_occured .
      CATCH cx_static_check.
    ENDTRY.
  ENDIF.
ENDFORM.                    " F_PREPARE_ACTION_DATA


*&---------------------------------------------------------------------*
*&      Module  M_FILL_SHORT_TEXT_0551  OUTPUT                N:2426282
*&---------------------------------------------------------------------*
MODULE m_fill_short_text_0551 OUTPUT.

  PERFORM fill_short_text_0551.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      FORM fill_short_text_0551                             N:2426282
*&---------------------------------------------------------------------*
FORM fill_short_text_0551.
* fill out the short texts
  DATA lr_exroot TYPE REF TO cx_root.
  DATA lo_factory TYPE REF TO /dbe/cl_veh_md_reader_factory.
  DATA lo_reader TYPE REF TO /dbe/if_veh_md_reader.
  DATA lo_buskey TYPE REF TO /dbe/cl_veh_md_key_bustype.
  DATA lo_result TYPE REF TO /dbe/if_veh_md_result.
  DATA lo_txt TYPE string.
  DATA lo_plant TYPE REF TO /dbe/cl_veh_md_key_plant.
  DATA lo_storeloc TYPE REF TO /dbe/cl_veh_md_key_storeloc.
  DATA lv_error_message TYPE string.

  TRY.
      lo_factory = /dbe/cl_veh_md_reader_factory=>get_instance( ).

*     read plants
      lo_reader = lo_factory->create_reader( 'PLANT' ).
      lo_plant ?= lo_reader->createkey( ).
      TRY.
          lo_plant->set_plant( vlcactdata_head_s-werks ).
          lo_result = lo_reader->read( lo_plant ).
          /dbe/s_veh_shorttext_plant2-descr = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          /dbe/s_veh_shorttext_plant2-descr = ''.
      ENDTRY.
      TRY.
          lo_plant->set_plant( vlcactdata_head_s-umwerks ).
          lo_result = lo_reader->read( lo_plant ).
          /dbe/s_veh_shorttext_plant1-descr = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          /dbe/s_veh_shorttext_plant1-descr = ''.
      ENDTRY.

*     read storage locations
      lo_reader = lo_factory->create_reader( 'STORELOC' ).
      lo_storeloc ?= lo_reader->createkey( ).
      TRY.
          lo_storeloc->set_storeloc( vlcactdata_head_s-lgort ).
          lo_storeloc->set_plant( vlcactdata_head_s-werks ).
          lo_result = lo_reader->read( lo_storeloc ).
          /dbe/s_veh_shorttext_strloc2-lgobe = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          /dbe/s_veh_shorttext_strloc2-lgobe = ''.
      ENDTRY.
      TRY.
          lo_storeloc->set_storeloc( vlcactdata_head_s-umlgo ).
          lo_storeloc->set_plant( vlcactdata_head_s-umwerks ).
          lo_result = lo_reader->read( lo_storeloc ).
          /dbe/s_veh_shorttext_strloc1-lgobe = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          /dbe/s_veh_shorttext_strloc1-lgobe = ''.
      ENDTRY.
    CATCH cx_root INTO lr_exroot .
      lv_error_message = lr_exroot->if_message~get_longtext( ).
*     if something went wrong during reading short text, the shost text will be empty and error silently
*     dropped becasue it not effecting.
  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Module  m_transfer_data_0551  INPUT                   N:2426282
*&---------------------------------------------------------------------*
MODULE m_transfer_data_0551 INPUT.
  PERFORM f_transfer_data_0551.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      FORM f_transfer_data_0551                             N:2426282
*&---------------------------------------------------------------------*
FORM f_transfer_data_0551.
  DATA: lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
        lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
        lt_bob             TYPE /dbe/t_veh_bob,
        ls_bob             TYPE /dbe/s_veh_bob,
        lr_data            TYPE REF TO data,
        lr_item_data       TYPE REF TO data,
        ls_ac_post         TYPE /dbe/vmass_adc,
        lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
        lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
        ls_invoice_info    TYPE tty_invoice_info.

* Header data
  MOVE-CORRESPONDING vlcactdata_head_s TO gs_vlcactdata_head.
* Item data
  MOVE-CORRESPONDING vlcactdata_item_s TO gs_vlcactdata_item.

* Get Buffer instance
  lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
  TRY.
      CALL METHOD lo_veh_buf->get_all
        RECEIVING
          rt_bob = lt_bob.
  ENDTRY.

  LOOP AT lt_bob INTO ls_bob .
    lo_vehicle ?= ls_bob-bobref.
    TRY.
        lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
      CATCH /dbe/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_data IS BOUND.
      lr_vlcactdata_head ?= lr_data.

      lr_vlcactdata_head->umwerks = vlcactdata_head_s-umwerks.
      lr_vlcactdata_head->umlgo = vlcactdata_head_s-umlgo.

      lr_vlcactdata_head->bldat = vlcactdata_head_s-bldat.
      lr_vlcactdata_head->bldat = vlcactdata_head_s-budat.
    ENDIF.
  ENDLOOP.

* Set data in Vehicle buffer
  TRY.
      CALL METHOD lo_veh_buf->set_all.
    CATCH /dbe/cx_veh_error_occured .
    CATCH cx_static_check.
  ENDTRY.

ENDFORM.

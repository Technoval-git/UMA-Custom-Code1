*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF40 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  RETRIEVE_VEHICLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM retrieve_vehicles .

  DATA : lt_bob                  TYPE /dbe/t_veh_bobget,
         ls_bob                  TYPE /dbe/s_veh_bobget,
         lt_bob_all              TYPE /dbe/t_veh_bob, "/DBE/t_veh_bobget,
         ls_bob_all              TYPE /dbe/s_veh_bob,
         lt_bob_lock             TYPE /dbe/t_veh_bob,
         lt_bob_details          TYPE /dbe/t_veh_bob,
         ls_bob_details          TYPE /dbe/s_veh_bob,
         lr_vlcdiavehi           TYPE REF TO vlcdiavehi,
         lr_iobj_single          TYPE REF TO /dbe/iobj_data_single_com_s,
         lr_iobj_multi           TYPE REF TO /dbe/iobj_data_multi_com_s,
         lr_vlcactdata_head      TYPE REF TO vlcactdata_head_s,
         lo_veh_buf              TYPE REF TO /dbe/cl_veh_buf,
         lo_vehicle              TYPE REF TO /dbe/cl_veh_dbmvehicle,
         ls_req_data             TYPE /dbe/req_vehicle_data,
         lt_guid                 TYPE /dbe/vlc_guid_t,
         ls_guid                 LIKE LINE OF lt_guid,
         gt_vlcdiavehi           TYPE vlcdiavehi_t,
         gt_vlcadddata           TYPE vlcadddata_item_t,
         gt_iobj_data_single_com TYPE /dbe/iobj_data_single_com_t,
         gt_iobj_data_multi_com  TYPE /dbe/iobj_data_multi_com_t,
         lt_bapireturn           TYPE bapiret2_tab,
         gt_vlcactdata_head      TYPE TABLE OF vlcactdata_head_s,
         gt_vlcactdata_item      TYPE TABLE OF vlcactdata_item_s,
         lr_vlcactdata_item      TYPE REF TO vlcactdata_item_s,
         lv_vguid                TYPE vlc_guid.

  FIELD-SYMBOLS <ls_bob_all>      TYPE /dbe/s_veh_bob.

  IF gs_bulk_actions-creaact  <> 'X'.
    IF  gt_vsresult_selection IS INITIAL .
** get instance of the buffer...
*      lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).
*          CALL METHOD lo_veh_buf->rem_bob.

* raise error
    ELSE.
* get instance of the buffer...
      lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
      CALL METHOD lo_veh_buf->rem_bob.
      lt_bob_all = lo_veh_buf->get_all( ).

      SORT gt_vsresult_selection BY vguid.
      LOOP AT gt_vsresult_selection INTO gs_selection.
        READ TABLE lt_bob_all INTO ls_bob_all WITH KEY guid = gs_selection-vguid.
        IF sy-subrc <> 0.  " Add to buffer
          lv_vguid        = gs_selection-vguid.
          ls_bob-guid     = gs_selection-vguid.
          ls_bob-bobtype  = '/DBE/CL_VEH_DBMVEHICLE'.
          ls_bob-set_lock = 'X'.
          APPEND ls_bob TO lt_bob.
        ELSE. " modify with lock
          APPEND ls_bob_all TO lt_bob_lock.
          CONTINUE.
        ENDIF.

*       Get the vehicle details Via VM01
        CALL FUNCTION '/DBE/VM01_VEHICLE_GET'
          EXPORTING
            iv_vguid                = lv_vguid
            is_req_data             = ls_req_data
            iv_refresh_buffer       = abap_false        "N:2348422
          IMPORTING
            es_vlcdiavehi           = gs_vlcdiavehi
            es_vlcactdata_head      = gs_vlcactdata_head
            es_vlcactdata_item      = gs_vlcactdata_item
            et_vlcadddata           = gt_vlcadddata
            ev_category_id          = gv_iobj_catid
            es_iobj_data_single_com = gs_iobj_single
            es_iobj_data_multi_com  = gs_iobj_multi
            et_bapireturn           = gt_bapireturn
          EXCEPTIONS
            error_vms_get           = 1
            error_iobj_get          = 2
            error_badi              = 3
            OTHERS                  = 4.
        IF sy-subrc <> 0.
*         Implement suitable error handling here
        ENDIF.

*       Collect data
        APPEND gs_vlcdiavehi TO gt_vlcdiavehi.
        APPEND gs_vlcactdata_head TO gt_vlcactdata_head.
        APPEND gs_vlcactdata_item TO gt_vlcactdata_item.
        APPEND gs_iobj_single TO gt_iobj_data_single_com.
        APPEND gs_iobj_multi TO gt_iobj_data_multi_com.
      ENDLOOP.

      IF lt_bob_lock IS NOT INITIAL.
        DATA lt_cx_root   TYPE sibfexctab.
        DATA lo_cx_root  TYPE REF TO cx_root.
        TRY.
            CALL METHOD lo_veh_buf->lock
              EXPORTING
                it_bob             = lt_bob_lock
                iv_mode_vlcvehicle = 'E'.
          CATCH /dbe/cx_veh_error_occured.
          CATCH cx_dynamic_check.
        ENDTRY.
      ENDIF.

      IF lt_bob IS NOT INITIAL.
        ls_req_data-vms_text = abap_true.
        ls_req_data-iobj_gentext = abap_true.

*       Create new buffer objects and return the reference
        TRY.
            CALL METHOD /dbe/cl_veh_dbmvehicle=>get_dbmvehicle
              EXPORTING
                it_bobget          = lt_bob
                is_req_data        = ls_req_data
                iv_iobj_req        = abap_true
                iv_mode_vlcvehicle = 'E'
                iv_scope           = '1'
                iv_wait            = space
                iv_collect         = space
              IMPORTING
                et_bob             = lt_bob_details.
          CATCH /dbe/cx_veh_error_occured .
          CATCH cx_dynamic_check .
        ENDTRY.

        LOOP AT lt_bob_details INTO ls_bob_details.
          lo_vehicle ?= ls_bob_details-bobref.

*         Get header data
          TRY.
              lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.

*         Set Vlcdaivehi in buffer
          TRY.
              lr_vlcdiavehi ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcdiavehi ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.
          READ TABLE gt_vlcdiavehi INTO gs_vlcdiavehi WITH KEY vguid = ls_bob_details-guid.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING gs_vlcdiavehi TO  lr_vlcdiavehi->*.
*           Set header in buffer
            READ TABLE gt_vlcactdata_head INTO gs_vlcactdata_head WITH KEY /dbe/iobjguid = gs_vlcdiavehi-/dbe/iobjguid.
            IF sy-subrc = 0.
              MOVE-CORRESPONDING gs_vlcactdata_head TO  lr_vlcactdata_head->*.
            ENDIF.
          ENDIF.

*         Set item data
          TRY.
              lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.
          READ TABLE gt_vlcactdata_item INTO gs_vlcactdata_item WITH KEY vguid = ls_bob_details-guid.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING gs_vlcactdata_item TO  lr_vlcactdata_item->*.
          ENDIF.
*         Set Single Iobject data
          TRY.
              lr_iobj_single ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.
          READ TABLE gt_iobj_data_single_com INTO gs_iobj_single WITH KEY /dbe/v_vehicle-vguid = ls_bob_details-guid.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING gs_iobj_single TO  lr_iobj_single->*.
          ENDIF.
*         Set Multi Iobject data
          TRY.
              lr_iobj_multi ?= lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_multi_com_s ).
            CATCH /dbe/cx_veh_layer_not_found .
          ENDTRY.
          READ TABLE gt_iobj_data_multi_com INTO gs_iobj_multi WITH KEY /dbe/v_vehicle-vguid = ls_bob_details-guid.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING gs_iobj_multi TO  lr_iobj_multi->*.
          ENDIF.
        ENDLOOP.
      ENDIF.
      CALL METHOD lo_veh_buf->get_cx_root
        RECEIVING
          rt_cx_root = lt_cx_root.

      LOOP AT lt_cx_root INTO lo_cx_root.
        CALL METHOD lo_veh_buf->get_messages
          EXPORTING
            io_cx_root    = lo_cx_root
          IMPORTING
            et_bapireturn = gt_bapireturn.
      ENDLOOP.

      READ TABLE gt_bapireturn TRANSPORTING NO FIELDS WITH KEY id = '/DBE/COMMON' number = '101'.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
*     Set all data in Buffer
      TRY.
          CALL METHOD lo_veh_buf->set_all .
        CATCH /dbe/cx_veh_error_occured .
        CATCH cx_static_check .
      ENDTRY.
    ENDIF.
  ENDIF.

ENDFORM.                    " RETRIEVE_VEHICLES
*&---------------------------------------------------------------------*
*&      Form  GET_SCREEN_COORDINATES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ACTION  text
*      <--P_LV_DEF_COL_1  text
*      <--P_LV_DEF_COL_2  text
*----------------------------------------------------------------------*
FORM get_screen_coordinates  USING    p_gv_action
                             CHANGING p_lv_def_col_1
                                      p_lv_def_col_2.
  CASE p_gv_action.
    WHEN /dbe/if_vms_constants=>c_qcrb .
      p_lv_def_col_1  = '200'.
      p_lv_def_col_2  = '27'.

    WHEN /dbe/if_vms_constants=>c_qirb.
      p_lv_def_col_1  = '113'.
      p_lv_def_col_2  = '25'.
    WHEN /dbe/if_vms_constants=>c_qgrb.
      p_lv_def_col_1  = '112'.
      p_lv_def_col_2  = '27'.
    WHEN /dbe/if_vms_constants=>c_qorb  .
      p_lv_def_col_1  = '95'.
      p_lv_def_col_2  = '30'.
    WHEN /dbe/if_vms_constants=>c_qdob.
      p_lv_def_col_1  = '125'.
      p_lv_def_col_2  = '30'.
    WHEN /dbe/if_vms_constants=>c_qinb.
      p_lv_def_col_1  = '106'.
      p_lv_def_col_2  = '30'.
    WHEN  /dbe/if_vms_constants=>c_qgcb.
      p_lv_def_col_1  = '113'.
      p_lv_def_col_2  = '26'.
    WHEN /dbe/if_vms_constants=>c_qmob.
      p_lv_def_col_1  = '122'.
      p_lv_def_col_2  = '25'.
    WHEN /dbe/if_vms_constants=>c_qadc.
      p_lv_def_col_1  = '130'.
      p_lv_def_col_2  = '27'.
    WHEN /dbe/if_vms_constants=>c_qapo.
      p_lv_def_col_1  = '130'.
      p_lv_def_col_2  = '27'.
    WHEN /dbe/if_vms_constants=>c_qagr.
      p_lv_def_col_1  = '130'.
      p_lv_def_col_2  = '27'.
    WHEN /dbe/if_vms_constants=>c_qain.
      p_lv_def_col_1  = '130'.
      p_lv_def_col_2  = '27'.

    WHEN /dbe/if_vms_constants=>c_qapc .
      p_lv_def_col_1  = '133'.
      p_lv_def_col_2  = '27'.

    WHEN /dbe/if_vms_constants=>c_qaic.
      p_lv_def_col_1  = '133'.
      p_lv_def_col_2  = '27'.

    WHEN /dbe/if_vms_constants=>c_qagc  .
      p_lv_def_col_1  = '135'.
      p_lv_def_col_2  = '27'.

    WHEN /dbe/if_vms_constants=>c_qpdi.
      p_lv_def_col_1  = '122'.
      p_lv_def_col_2  = '27'.

    WHEN /dbe/if_vms_constants=>c_qacc.
      p_lv_def_col_1  = '133'.
      p_lv_def_col_2  = '27'.

    WHEN 'QRSB'.
      p_lv_def_col_1  = '100'.
      p_lv_def_col_2  = '25'.

*Check weather popup to be called or not.

    WHEN OTHERS.
*Badi needed?
      p_lv_def_col_1  = '80'.
      p_lv_def_col_2  = '30'.
  ENDCASE.

ENDFORM.                    " GET_SCREEN_COORDINATES
*&---------------------------------------------------------------------*
*&      Form  SET_OK_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_OK_CODE  text
*----------------------------------------------------------------------*
FORM set_ok_code  USING    p_gv_ok_code.

  CALL FUNCTION '/DBE/VMASS_SET_OK_CODE'
    EXPORTING
      iv_ok_code = p_gv_ok_code.

ENDFORM.                    " SET_OK_CODE
*&---------------------------------------------------------------------*
*&      Form  SET_ACTION_FOR_VEHICLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_action_for_vehicles .

  DATA lo_veh_buf TYPE REF TO /dbe/cl_veh_buf.
  DATA lo_veh     TYPE REF TO /dbe/cl_veh_dbmvehicle.
  DATA lt_bob     TYPE /dbe/t_veh_bob.
  DATA ls_bob     TYPE /dbe/s_veh_bob.
  DATA lv_wo_prepare        TYPE boole_d.
  DATA lx_root    TYPE REF TO cx_root.

  lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).

* call VMS action prepare for all vehicles at once >>>N:2260461
  lo_veh_buf->prepare_action_all( EXPORTING iv_action     = gv_action
                                  IMPORTING et_bapireturn = gt_bapireturn ).
  LOOP AT gt_bapireturn TRANSPORTING NO FIELDS
    WHERE type CA 'EA'.
    RETURN.
  ENDLOOP.

  TRY.
      CALL METHOD lo_veh_buf->set_all. "2234293

    CATCH /dbe/cx_veh_error_occured INTO lx_root.
      lo_veh_buf->get_messages( EXPORTING io_cx_root = lx_root
                               IMPORTING et_bapireturn = gt_bapireturn ).

      gt_bapireturn  = lo_veh->mo_bal->export( ).
      RETURN.
    CATCH cx_static_check .
      lo_veh_buf->get_messages( EXPORTING io_cx_root = lx_root
                               IMPORTING et_bapireturn = gt_bapireturn ).

      gt_bapireturn  = lo_veh->mo_bal->export( ).
      RETURN.
  ENDTRY.                                         "<<<N:2260461

ENDFORM.                    " SET_ACTION_FOR_VEHICLES

*&---------------------------------------------------------------------*
*&  Include          /DBE/LVEHI_MASS_PROCESSINGF90
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class LCL_ALVGRID_EVENT_HANDLER
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
* call vehicle master for selected vehicle
FORM call_vehicle_masters USING p_row_id
                               p_col_id.
  DATA : lv_row         TYPE sy-tabix.
  DATA : lv_column      TYPE c LENGTH 10.
  DATA : ls_vlcdisplalv TYPE /DBE/vsresult.
  DATA : lt_bobget      TYPE /DBE/t_veh_bobget.
  DATA : ls_bobget          LIKE LINE OF lt_bobget.
  DATA : lx_layer_not_found TYPE REF TO /DBE/cx_veh_layer_not_found.
  DATA : lr_vlcdiavehi      TYPE REF TO vlcdiavehi.
  DATA : lr_iobj_single     TYPE REF TO /DBE/iobj_data_single_com_s.
  DATA : lr_iobj_multi      TYPE REF TO /DBE/iobj_data_multi_com_s.
  DATA : lo_veh_buf         TYPE REF TO /DBE/cl_veh_buf.
  DATA : lo_veh             TYPE REF TO /DBE/cl_veh_dbmvehicle.          "N:2304203
  DATA : ls_req_data        TYPE /DBE/req_vehicle_data .
  DATA : lt_bob_all         TYPE /DBE/t_veh_bob.
  DATA : ls_bob_all         LIKE LINE OF lt_bob_all.
  DATA : lt_bob             TYPE /DBE/t_veh_bob.                         "N:2304203
  DATA : ls_bob             TYPE /DBE/s_veh_bob.
  DATA:  lv_object_id  LIKE  cdhdr-objectid,
         lv_timlo      TYPE sy-timlo,
         lv_datlo      TYPE sy-datlo,
         ls_cdred      TYPE cdred,
         lt_cdred      TYPE STANDARD TABLE OF cdred,
         ls_iobj_multi TYPE /DBE/iobj_data_multi_txt_s,
         ls_iobj_sngl  TYPE /DBE/iobj_data_single_txt_s,
         ls_vehicles   TYPE vlcdiavehi,
         lt_ordtyp     TYPE /DBE/c_tt_ordertp,
         lt_vbak_com   TYPE /DBE/vbak_com_tt.
  CONSTANTS:
         lc_object_class LIKE  cdhdr-objectclas VALUE 'VEHICLE'.

  FIELD-SYMBOLS <gs_vsresult> TYPE /DBE/vsresult.

  "Record time of navigation.
  gv_navigation_time = sy-timlo.

  lv_row    = p_row_id.
  lv_column = p_col_id.

  READ TABLE gt_vsresult INTO ls_vlcdisplalv
        INDEX lv_row..
  IF sy-subrc = 0.
* set the selected guid in VM08
    CALL FUNCTION '/DBE/VM08_VEHICLE_VGUID_SET'
      EXPORTING
        iv_vguid = ls_vlcdisplalv-vguid.

*    lv_object = gc_actn_chg.
*    CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
*      EXPORTING
*        object               = lv_object
*      IMPORTING
*        value                = lv_value
*      EXCEPTIONS
*        object_not_defined   = 1
*        value_not_maintained = 2
*        OTHERS               = 3.
*    IF sy-subrc <> 0.
*    ENDIF.
*
*    SET PARAMETER ID 'VGUID' FIELD ls_vlcdisplalv-vguid.    "#EC EXISTS
**    SET PARAMETER ID 'VHCLE' FIELD ls_vlcdisplalv-vhcle.
*    SET PARAMETER ID 'ACTION' FIELD lv_value.               "#EC EXISTS

    EXPORT space TO MEMORY ID 'TXN_NAME'.
    SET PARAMETER ID 'VHCLE' FIELD ls_vlcdisplalv-vhcle.


    AUTHORITY-CHECK OBJECT 'S_TCODE'
             ID 'TCD' FIELD '/DBE/VM'.
    IF sy-subrc <> 0.
      MESSAGE s321(/DBE/service) WITH '/DBE/VM'. "#NOTEXT.
* No Authority for Transaction &1
      EXIT.
    ENDIF.

    CALL TRANSACTION '/DBE/VM'.

**  If the navigation to VM has taken place ,possible to have changes
**  in vehicle master record -Update the changes to result table in that case

    CALL METHOD /DBE/cl_veh_buf=>get_instance
      RECEIVING
        ro_instance = lo_veh_buf.
    TRY.
        CALL METHOD lo_veh_buf->get_all
          RECEIVING
            rt_bob = lt_bob_all.
    ENDTRY.
    READ  TABLE lt_bob_all INTO ls_bob_all WITH KEY guid = ls_vlcdisplalv-vguid.
    IF sy-subrc <> 0.
      ls_bobget-guid = ls_vlcdisplalv-vguid.
      ls_bobget-bobtype = '/DBE/CL_VEH_DBMVEHICLE'.
      ls_bobget-set_lock = abap_false.
      APPEND ls_bobget TO lt_bobget.
    ELSE. "if vehicle already exists in buffer ,request for a reload from DB
      lo_veh ?= ls_bob_all-bobref.
      CALL METHOD lo_veh->request_reload.
      ls_bobget-guid = ls_vlcdisplalv-vguid.
      ls_bobget-bobtype = ls_bob_all-bobtype.
      APPEND ls_bobget TO lt_bobget.
    ENDIF.
    ls_req_data-vms_text = 'X'.
    ls_req_data-iobj_gentext = 'X'.
    TRY.
        CALL METHOD /DBE/cl_veh_dbmvehicle=>get_dbmvehicle
          EXPORTING
            it_bobget   = lt_bobget
            is_req_data = ls_req_data
            iv_iobj_req = abap_true
*           iv_no_archive      =
*           iv_mode_vlcvehicle = 'E'
*           iv_scope    = '1'
*           iv_wait     = SPACE
*           iv_collect  = SPACE
          IMPORTING
            et_bob      = lt_bob.
      CATCH /DBE/cx_veh_error_occured .
      CATCH cx_dynamic_check .
    ENDTRY.
    READ TABLE lt_bob INTO ls_bob WITH KEY guid = ls_vlcdisplalv-vguid.  .
    IF sy-subrc = 0.
      lo_veh ?= ls_bob-bobref.
      "Fetch Vehicle history
      lv_object_id = ls_vlcdisplalv-vguid.
      CALL FUNCTION 'CHANGEDOCUMENT_READ'
        EXPORTING
          objectclass                = lc_object_class
          objectid                   = lv_object_id
          local_time                 = abap_true
        TABLES
          editpos                    = lt_cdred
        EXCEPTIONS
          no_position_found          = 1
          wrong_access_to_archive    = 2
          time_zone_conversion_error = 3
          OTHERS                     = 4.
      "Check last entry of history table whether it is modified after the navigation.
      READ TABLE lt_cdred INTO ls_cdred INDEX lines( lt_cdred ).
      IF sy-subrc EQ 0.
        IF ls_cdred-udate = sy-datlo AND ls_cdred-utime >= gv_navigation_time.
          "modified, fetch latest details of vehicle
          READ TABLE gt_vsresult ASSIGNING <gs_vsresult> WITH KEY vguid  = ls_vlcdisplalv-vguid.
          TRY.
              lr_vlcdiavehi ?= lo_veh->get_data_com( lo_veh->gc_vlcdiavehi ).
              MOVE-CORRESPONDING lr_vlcdiavehi->* TO <gs_vsresult>.
              lr_iobj_single ?= lo_veh->get_data_com( lo_veh->gc_iobj_data_single_com_s ).
              MOVE-CORRESPONDING lr_iobj_single->*-/DBE/V_IVEHICLE TO <gs_vsresult>.
              MOVE-CORRESPONDING lr_iobj_single->*-/DBE/V_IMODEL TO <gs_vsresult>.
              MOVE-CORRESPONDING lr_iobj_single->*-/DBE/V_IPRICES TO <gs_vsresult>.
              MOVE-CORRESPONDING lr_iobj_single->*-/DBE/V_ILEASING TO <gs_vsresult>.
              MOVE-CORRESPONDING lr_iobj_single->*-/DBE/V_ICOND TO <gs_vsresult>.
              MOVE-CORRESPONDING lr_iobj_single->*-/DBE/V_IFINANC TO <gs_vsresult>.

              "Get Actual Next Sevice Date
              PERFORM calculate_next_service_date USING ls_vlcdisplalv-vguid CHANGING <gs_vsresult>.

* Get order type customizing to determine service orders
              CALL FUNCTION '/DBE/CU06_READ_ORDTYP_ENG'
                IMPORTING
                  et_c_ordertp = lt_ordtyp
                EXCEPTIONS
*                 not_found    = 1
                  OTHERS       = 0. "No error

              SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbak_com
       FROM /DBE/vbak_db AS vbak
       INNER JOIN /DBE/splhdr_db AS splhdr
       ON splhdr~vbeln = vbak~vbeln
       AND splhdr~splnr = 1
       WHERE       engine  = 'CS'
                   AND   vguid = ls_vlcdisplalv-vguid
         ORDER BY audat DESCENDING.

              "Get changed Last Service Date
              PERFORM calculate_last_service_date USING ls_vlcdisplalv-vguid lt_ordtyp lt_vbak_com
                    CHANGING <gs_vsresult>.

              "Get Recall Status
              lr_iobj_multi ?= lo_veh->get_data_com( lo_veh->gc_iobj_data_multi_com_s ).
              IF <gs_vsresult> IS ASSIGNED.
                MOVE-CORRESPONDING <gs_vsresult> TO ls_vehicles.
              ENDIF.
              MOVE-CORRESPONDING lr_iobj_single->* TO ls_iobj_sngl.
              MOVE-CORRESPONDING lr_iobj_multi->* TO ls_iobj_multi.

              PERFORM calculate_recall_status USING ls_vehicles ls_iobj_sngl ls_iobj_multi
                     CHANGING <gs_vsresult>.

            CATCH /DBE/cx_veh_layer_not_found INTO lx_layer_not_found.

          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.

* Remove the entries from buffer
    IF lt_bob_all IS INITIAL.
      CALL METHOD lo_veh_buf->rem_bob
        EXPORTING
          it_bob = lt_bob.
    ENDIF.
  ENDIF.

ENDFORM.                    "call_vehicle_masters
*&---------------------------------------------------------------------*
*&      Form  call_callback
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW_ID   text
*----------------------------------------------------------------------*
FORM call_callback USING pt_params
                        p_col_id.
  DATA : lv_row TYPE STANDARD TABLE OF /DBE/vsresult .
  DATA : lt_params TYPE TABLE OF spar.
  DATA : ls_params TYPE  spar.
  DATA : lv_column TYPE c LENGTH 10.
  DATA : ls_vlcdisplalv TYPE /DBE/vsresult.
  DATA : lv_object TYPE /DBE/ctrl_object.
  DATA : lv_value TYPE /DBE/ctrl_value.
  DATA : lv_vm_no_tabs.

  lt_params  = pt_params.
  READ TABLE lt_params INTO ls_params WITH KEY param = 'VHCLE'.
  IF ls_params-value IS NOT INITIAL.
    READ TABLE gt_vsresult INTO ls_vlcdisplalv
            WITH KEY vhcle = ls_params-value.
    IF sy-subrc = 0.
* call vehicle master transaction for displaing vehicle data
* (in change action)
      CALL FUNCTION '/DBE/VM08_VEHICLE_VGUID_SET'
        EXPORTING
          iv_vguid = ls_vlcdisplalv-vguid.

      lv_object = gc_actn_chg.
      IF sy-subrc <> 0.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'S_TCODE'
               ID 'TCD' FIELD '/DBE/VM'.
      IF sy-subrc <> 0.
        MESSAGE s321(/DBE/service) WITH '/DBE/VM'. "#NOTEXT.
* No Authority for Transaction &1
        EXIT.
      ENDIF.

      CALL TRANSACTION '/DBE/VM'.
    ENDIF.
  ENDIF.

ENDFORM.                    "call_callback

*&---------------------------------------------------------------------*
*&      Form  call_callback2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->C_S_STATE  text
*----------------------------------------------------------------------*
FORM log_callback_order CHANGING c_s_state       TYPE bal_s_cbuc.
  DATA : ls_vlcdisplalv TYPE /DBE/vsresult,
         lv_vbeln       TYPE /DBE/vbeln_va.

  IF c_s_state-list_field = 'VBELN' AND c_s_state-list_value IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = c_s_state-list_value
      IMPORTING
        output = lv_vbeln.
    CALL FUNCTION '/DBE/ORD_UI_ORDER_TA_CALL'
      EXPORTING
        iv_activity     = '03'
        iv_vbeln        = lv_vbeln
      EXCEPTIONS
        wrong_parameter = 1
        ord_get_error   = 2
        ord_new_error   = 3
        ord_del_error   = 4
        ord_copy_error  = 5
        OTHERS          = 6.
  ELSEIF c_s_state-list_field = 'VHCLE' AND c_s_state-list_value IS NOT INITIAL.
    READ TABLE gt_vsresult INTO ls_vlcdisplalv
        WITH KEY vhcle = c_s_state-list_value.
    IF sy-subrc = 0.
* call vehicle master transaction for displaing vehicle data
      CALL FUNCTION '/DBE/VM08_VEHICLE_VGUID_SET'
        EXPORTING
          iv_vguid = ls_vlcdisplalv-vguid.
      IF sy-subrc <> 0.
      ENDIF.
      AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD '/DBE/VM'.
      IF sy-subrc <> 0.
        MESSAGE s321(/DBE/service) WITH '/DBE/VM'. "#NOTEXT.
        EXIT.
      ENDIF.
      CALL TRANSACTION '/DBE/VM'.
    ENDIF.
  ENDIF.
ENDFORM.                    "call_callback

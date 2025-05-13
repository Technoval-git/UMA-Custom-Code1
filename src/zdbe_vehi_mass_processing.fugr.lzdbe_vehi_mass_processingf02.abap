*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  EXECUTE_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM execute_search .
  DATA:
    vlcextcrit_lt         TYPE vlch_searchcrit_pt,
    vlcextcrit_ls         TYPE vlch_searchcrit_ps,
    lt_search_crit_2      TYPE /dbe/veh_searchcrit_t,
    lt_vlcdiavehi_2       TYPE vlcdiavehi_t,
    lv_is_bupa,
    lt_busobj_cust        TYPE com_search_tt_object_type_cust,
    ls_busobj_cust        TYPE com_search_ts_object_type_cust,
    lv_tabix              TYPE i,
    lo_trex_wrapper       TYPE REF TO if_com_se_trex,
    lt_indexes            TYPE trext_index_ids,
    ls_index              TYPE trexs_index_id,
    lt_index_info         TYPE trext_index_exist,
    ls_index_info         TYPE trexs_index_exist,
    lv_return_code        TYPE trex_rfc-return_code,
    lv_return_text        TYPE trex_rfc-return_text,
    lv_no_trex            TYPE boole_d,
    lt_mass_search_crit_i TYPE /dbe/veh_searchcrit_t,
    lt_mass_search_crit_e TYPE /dbe/veh_searchcrit_t,
    db_badi               TYPE REF TO /dbe/badi_es_hana,
    ls_bapireturn         TYPE bapiret2.

  DATA:
    ls_req_data TYPE  /dbe/req_vehicle_list_data,
    ls_settype  TYPE  comt_frgtype_id.
  FIELD-SYMBOLS:
    <ls_vlcdiavehi_2>     TYPE vlcdiavehi,
    <ls_mass_search_crit> TYPE /dbe/veh_searchcrit.

  CLEAR: gv_error_search.

  TRY.
      GET BADI db_badi
        FILTERS
          dbsys = cl_db_sys=>dbsys_type.
    CATCH cx_badi_not_implemented     ##no_handler.
  ENDTRY.

* in case of external call - go directly to search execution
  IF gv_external_mode IS INITIAL.
    CLEAR: gv_searchmode.

*Get the selection criteria from customer screen
    IF gv_subscreen_program NE gc_mass_main_program.
      CALL FUNCTION '/DBE/VMASS_SEARCHVIEWS_GETDATA'
        TABLES
          et_vlcextcrit = vlcextcrit_lt
          et_contrerror = controlerr_lt
        EXCEPTIONS
          controlerror  = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
* get search criteria from the screen
      CALL FUNCTION '/DBE/MASS_VSEARCH_DATA_GET'
        TABLES
          vlcvehicrit_et = vlcsearchcrit_lt
          contrerror_et  = controlerr_lt
        EXCEPTIONS
          controlerror   = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    APPEND LINES OF vlcsearchcrit_lt TO gt_mass_search_crit.
    APPEND LINES OF vlcextcrit_lt TO gt_mass_search_crit.
    gv_searchmode = 'E'. " Default mode is Exact

  ENDIF.

  REFRESH gt_vehicles.

  IF gv_searchmode IS INITIAL.
    gv_searchmode = 'E'.
  ENDIF.

  CLEAR: lt_search_crit_2, lt_vlcdiavehi_2, lv_is_bupa.

* execute search (trex + vms)
  CLEAR: gt_bapireturn[].

* Check if TREX is available at all. This is done here as the error_message exception
* supresses all message of type S/I/W. This is necessary so that the success message
* issued wihtin the VMS fm does not appear whenever the VM01_vehicle_search is called.
* However, with that solution the information message i027 about the TREX being down
* got suppressed as well, so it's checked here before calling anything.

  IF db_badi IS NOT BOUND.
    cl_com_se_custom_read=>get_customizing_for_busobj( EXPORTING iv_busobj = /dbe/cl_se_vehicle=>gc_dbm_busobj
                                                       IMPORTING et_object_type_cust = lt_busobj_cust ).
    READ TABLE lt_busobj_cust INTO ls_busobj_cust
      WITH KEY mandt = sy-mandt busobj = /dbe/cl_se_vehicle=>gc_dbm_busobj index_active = abap_true.
    IF sy-subrc NE 0.
      lv_no_trex = abap_true.
    ELSE.
      lo_trex_wrapper = cl_com_se_trex=>if_com_se_trex~get_instance( ).
      ls_index-index_id = ls_busobj_cust-index_id.
      APPEND ls_index TO lt_indexes.
      lo_trex_wrapper->index_exists( EXPORTING  it_indexes = lt_indexes
                                                iv_rfc_destination = ls_busobj_cust-rfc_destination
                                     IMPORTING  et_index_info = lt_index_info
                                                ev_return_code = lv_return_code
                                                ev_return_text = lv_return_text
                                     EXCEPTIONS conversion_error = 1
                                                error = 2
                                                OTHERS = 3 ).
      IF sy-subrc NE 0.
        lv_no_trex = abap_true.
      ELSE.
        READ TABLE lt_index_info INTO ls_index_info WITH KEY index_id = ls_busobj_cust-index_id.
        IF sy-subrc NE 0 OR ls_index_info-return_code NE 0.
          lv_no_trex = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_no_trex = abap_true.
      MESSAGE i027(/dbe/vehicle_master).
      CLEAR gv_searchstring.
      DELETE gt_mass_search_crit WHERE tab NE 'VLCVEHICLE'.
      DELETE lt_search_crit_2 WHERE tab NE 'VLCVEHICLE'.
    ENDIF.
  ENDIF.

  DATA:
    lv_category_id    TYPE /dbe/exts_category_id VALUE 'DBM_PASSENGERCAR',
    lt_extmeta_single TYPE /dbe/iobj_extmeta_t,
    lt_extmeta_multi  TYPE /dbe/iobj_extmeta_t.

* Only fetch required settype instead of all: add all settypes which data are to be dispayed on UI
  ls_settype = '/DBE/V_IMODEL'.
  APPEND ls_settype TO ls_req_data-iobj_settype.
  ls_settype = '/DBE/V_ICOND'.
  APPEND ls_settype TO ls_req_data-iobj_settype.
  ls_settype = '/DBE/V_ILEASING'.
  APPEND ls_settype TO ls_req_data-iobj_settype.
  ls_settype = '/DBE/V_IPRICES'.
  APPEND ls_settype TO ls_req_data-iobj_settype.
  ls_settype = '/DBE/V_IFINANC'.
  APPEND ls_settype TO ls_req_data-iobj_settype.
  ls_settype = '/DBE/V_ISINT'.
  APPEND ls_settype TO ls_req_data-iobj_settype.
  ls_settype = '/DBE/V_IVEHICLE'.
  APPEND ls_settype TO ls_req_data-iobj_settype.
  ls_settype = '/DBE/V_IRCL'.
  APPEND ls_settype TO ls_req_data-iobj_settype.

  CLEAR: gt_iobj_single, gt_iobj_multi,gt_bapireturn,gt_vehicles.


  IF badi_search_ui IS BOUND.
    lt_mass_search_crit_i = gt_mass_search_crit.

    CALL BADI badi_search_ui->get_search_criteria
      EXPORTING
        it_search_criteria = lt_mass_search_crit_i
      IMPORTING
        et_search_criteria = lt_mass_search_crit_e.

    IF lt_mass_search_crit_e IS INITIAL. "If BAdI method is not implemented then assign same criteria what is exported
      lt_mass_search_crit_e = lt_mass_search_crit_i.
    ENDIF.

    gt_mass_search_crit =  lt_mass_search_crit_e.
    CLEAR : lt_mass_search_crit_e, lt_mass_search_crit_i.
  ENDIF.

*Change the requested vehicle data
  IF badi_result_alv IS BOUND.
    CALL BADI badi_result_alv->vehicle_overview_req_data
      CHANGING
        cs_req_data = ls_req_data.
  ENDIF.

  IF db_badi IS BOUND.
    LOOP AT gt_mass_search_crit ASSIGNING <ls_mass_search_crit>.
      IF <ls_mass_search_crit>-tab = 'VLCGRECEIPT' AND <ls_mass_search_crit>-qual = 'ERNAM'.
        <ls_mass_search_crit>-qual = 'ERNAM_GR'.
      ELSEIF <ls_mass_search_crit>-tab = 'VLCPORDER' AND <ls_mass_search_crit>-qual = 'ERNAM'.
        <ls_mass_search_crit>-qual = 'ERNAM_PO'.
      ELSEIF <ls_mass_search_crit>-tab = 'VLCINCINVOICE' AND <ls_mass_search_crit>-qual = 'ERNAM'.
        <ls_mass_search_crit>-qual = 'ERNAM_INV'.
      ELSEIF <ls_mass_search_crit>-tab = '/DBE/VBAK_COM' AND <ls_mass_search_crit>-qual = 'AUDAT'.
        <ls_mass_search_crit>-qual = 'L_AUDAT'.
      ENDIF.
    ENDLOOP.
  ENDIF.

  PERFORM f_get_veh_parameters.

** Perform the search
  CALL FUNCTION '/DBE/VM01_VEHICLE_SEARCH'
    EXPORTING
      iv_searchstring         = gv_searchstring
      iv_searchmode           = gv_searchmode
      iv_max_sel              = gv_maxsel
      it_searchcrit           = gt_mass_search_crit
      is_req_data             = ls_req_data
    IMPORTING
      et_vlcdiavehi           = gt_vehicles
      et_iobj_data_single_com = gt_iobj_single
      et_iobj_data_multi_com  = gt_iobj_multi
      et_bapireturn           = gt_bapireturn
    EXCEPTIONS
      error_search            = 1
      no_vehicle_found        = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    IF ( lv_is_bupa = abap_false ) OR ( lv_is_bupa = abap_true AND sy-subrc <> 2 ) .
*   BuPa field was empty, there is only one search.
*   Set the error flag
      gv_error_search = 'X'.
*   Delete the old search criteria
      REFRESH gt_mass_search_crit.
      CLEAR : gv_searchstring.
*     Show the error message
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            DISPLAY LIKE sy-msgty.
      IF sy-msgty CA 'EAX'.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.
* report warning from search execution              N:2317367
  LOOP AT gt_bapireturn INTO ls_bapireturn WHERE type = 'W'.
    IF lines( gt_vehicles ) > 0.
      MESSAGE ID ls_bapireturn-id TYPE 'S' NUMBER ls_bapireturn-number
            WITH ls_bapireturn-message_v1 ls_bapireturn-message_v2 ls_bapireturn-message_v3 ls_bapireturn-message_v4
            DISPLAY LIKE ls_bapireturn-type.
      EXIT.
    ELSE.
      MESSAGE ID ls_bapireturn-id TYPE 'I' NUMBER ls_bapireturn-number
            WITH ls_bapireturn-message_v1 ls_bapireturn-message_v2 ls_bapireturn-message_v3 ls_bapireturn-message_v4
            DISPLAY LIKE ls_bapireturn-type.
      gv_skip_novehicle_info = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.

* In case of normal mode, delete the old search criteria
  IF gv_external_mode IS INITIAL.
    REFRESH gt_mass_search_crit.
    CLEAR gv_searchstring.
  ENDIF.
ENDFORM.                    " EXECUTE_SEARCH

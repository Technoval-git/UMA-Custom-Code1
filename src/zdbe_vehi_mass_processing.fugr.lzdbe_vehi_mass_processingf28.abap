*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF28 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PAI_USER_COMMAND_1200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_result USING lt_ordtyp   TYPE /dbe/c_tt_ordertp
                           lt_vbak_com TYPE /dbe/vbak_com_tt.
  DATA:
    ls_iobj_single TYPE /dbe/iobj_data_single_com_s,
    ls_v_imodel    TYPE /dbe/v_imodel_dynp,
    ls_v_ivehicle  TYPE /dbe/v_vehicle_data,
    ls_v_icond     TYPE /dbe/v_icond_dynp,
    ls_v_ileasing  TYPE /dbe/v_ileasing_dynp,
    ls_v_ifinanc   TYPE /dbe/v_ifinanc_dynp,
    ls_v_isint     TYPE /dbe/v_isint_dynp_ext,
    ls_v_iprices   TYPE /dbe/v_iprices_dynp,
    ls_iobj_multi  TYPE /dbe/iobj_data_multi_txt_s,
    ls_iobj_sngl   TYPE /dbe/iobj_data_single_txt_s.
*
  FIELD-SYMBOLS:
    <f_iobj_multi>  TYPE /dbe/iobj_data_multi_com_s,
    <f_iobj_single> TYPE /dbe/iobj_data_single_com_s.

  READ TABLE gt_iobj_single ASSIGNING <f_iobj_single>
        WITH KEY /dbe/v_vehicle-vguid = gs_vehicles-vguid
        BINARY SEARCH.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING gs_vehicles TO gs_vsresult.
    ls_v_ivehicle = <f_iobj_single>-/dbe/v_vehicle.
    ls_v_imodel = <f_iobj_single>-/dbe/v_imodel.
    MOVE-CORRESPONDING ls_v_imodel TO gs_vsresult.
    ls_v_icond = <f_iobj_single>-/dbe/v_icond.
    MOVE-CORRESPONDING ls_v_icond TO gs_vsresult.
    ls_v_ileasing = <f_iobj_single>-/dbe/v_ileasing.
    MOVE-CORRESPONDING ls_v_ileasing TO gs_vsresult.
    ls_v_iprices = <f_iobj_single>-/dbe/v_iprices.
    MOVE-CORRESPONDING ls_v_iprices TO gs_vsresult.
    ls_v_ifinanc = <f_iobj_single>-/dbe/v_ifinanc.
    MOVE-CORRESPONDING ls_v_ifinanc TO gs_vsresult.
  ENDIF.

  PERFORM calculate_next_service_date USING    gs_vehicles-vguid
                                      CHANGING gs_vsresult.
  PERFORM calculate_last_service_date USING    gs_vehicles-vguid
                                               lt_ordtyp
                                               lt_vbak_com
                                      CHANGING gs_vsresult.

  READ TABLE gt_iobj_multi ASSIGNING <f_iobj_multi>
        WITH KEY /dbe/v_vehicle-vguid = gs_vehicles-vguid
        BINARY SEARCH.
  IF sy-subrc EQ 0.
  ENDIF.

  IF <f_iobj_single> IS ASSIGNED OR <f_iobj_multi> IS ASSIGNED.
    MOVE-CORRESPONDING <f_iobj_single> TO ls_iobj_sngl.
    MOVE-CORRESPONDING <f_iobj_multi> TO ls_iobj_multi.
  ENDIF.

  PERFORM calculate_recall_status USING    gs_vehicles
                                           ls_iobj_sngl
                                           ls_iobj_multi
                                  CHANGING gs_vsresult.

  APPEND gs_vsresult TO gt_vsresult.
ENDFORM.                    "populate_result
*&---------------------------------------------------------------------*
*&      Form  pai_user_command_1200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM pai_user_command_1200 .

  DATA: lv_svariant        TYPE /dbe/svariant,
        lt_search_crit     TYPE /dbe/veh_searchcrit_t,
        lt_search_crit_tmp TYPE /dbe/veh_searchcrit_t,
        lt_search_crit_buf TYPE /dbe/veh_searchcrit_t,
        lt_search_crit_2   TYPE /dbe/veh_searchcrit_t,
        lv_status          TYPE /dbe/status_vb,
        lt_vbak_com        TYPE /dbe/vbak_com_tt,
        ls_vbak_com        TYPE /dbe/vbak_com,
        lt_ordtyp          TYPE /dbe/c_tt_ordertp,
        ls_ordtyp          TYPE /dbe/c_ordertp,
        lv_order           TYPE boolean,
        ls_req_data        TYPE /dbe/req_vehicle_list_data.

  FIELD-SYMBOLS: <fs_search_crit> TYPE /dbe/veh_searchcrit.

  gv_main_ok_code = ok_code.

  CASE gv_main_ok_code.
    WHEN gc_svar_fc.
      CALL SCREEN 1210 STARTING AT 25 6.

    WHEN gc_listbox_fc.
      PERFORM f_clear_fields.
      CLEAR: gv_mass_search_filled,
             gv_extsearch_filled,
             gt_search_crit_ext[],
             gt_mass_search_crit_buf.
      lv_svariant = <gf_varlistitem_shown>.
      PERFORM f_load_variant USING lv_svariant.
      PERFORM f_find_tab_text_set .
      gv_read_oem_opt_texts = abap_true.
      PERFORM f_search_data_get CHANGING gt_mass_search_crit_buf.

    WHEN gc_clear_fc.
      PERFORM f_clear_fields.
      CLEAR: gv_mass_search_filled,
             gv_extsearch_filled,
             gt_search_crit_ext[],
             gt_mass_search_crit_buf.
      PERFORM f_find_tab_text_set .
      CLEAR <gf_varlistitem_shown>.

    WHEN gc_execute_fc.
      IF lt_search_crit IS INITIAL OR gt_mass_search_crit NE lt_search_crit.
        IF gt_mass_search_crit_buf NE lt_search_crit.
          CLEAR: <gf_varlistitem_shown>, gt_mass_search_crit_buf.
        ENDIF.
      ENDIF.

      PERFORM execute_search.
      PERFORM authchk_populate_result.

    WHEN OTHERS.
*     check whether the criteria are the same as before user activity
*     (e.g. multiple selection popup, tabstrip change, etc.)
      lt_search_crit_tmp = gt_mass_search_crit.
      lt_search_crit_buf = gt_mass_search_crit_buf.
      PERFORM f_search_data_get CHANGING lt_search_crit.
      lt_search_crit_2 = lt_search_crit.
      LOOP AT lt_search_crit ASSIGNING <fs_search_crit> WHERE sign CA 'AB'.
        IF <fs_search_crit>-sign = 'A'.
          <fs_search_crit>-sign = 'I'.
        ELSE.
          <fs_search_crit>-sign = 'E'.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_search_crit_buf ASSIGNING <fs_search_crit> WHERE sign CA 'AB'.
        IF <fs_search_crit>-sign = 'A'.
          <fs_search_crit>-sign = 'I'.
        ELSE.
          <fs_search_crit>-sign = 'E'.
        ENDIF.
      ENDLOOP.
      SORT lt_search_crit     BY tab  ASCENDING qual   ASCENDING
                                 sign ASCENDING option ASCENDING
                                 low  ASCENDING high   ASCENDING.
      SORT lt_search_crit_tmp BY tab  ASCENDING qual   ASCENDING
                                 sign ASCENDING option ASCENDING
                                 low  ASCENDING high   ASCENDING.
      SORT lt_search_crit_buf BY tab  ASCENDING qual   ASCENDING
                                 sign ASCENDING option ASCENDING
                                 low  ASCENDING high   ASCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_search_crit     COMPARING ALL FIELDS.
      DELETE ADJACENT DUPLICATES FROM lt_search_crit_tmp COMPARING ALL FIELDS.
      DELETE ADJACENT DUPLICATES FROM lt_search_crit_buf COMPARING ALL FIELDS.

      IF ( lt_search_crit IS INITIAL OR lt_search_crit_tmp NE lt_search_crit AND lt_search_crit_tmp IS NOT INITIAL )
        OR ( lt_search_crit_buf IS NOT INITIAL AND lt_search_crit_buf NE lt_search_crit ).
        CLEAR: <gf_varlistitem_shown>, gt_mass_search_crit_buf.
      ENDIF.

**     Search criteria buffer table is used to store the search criteria data
**     which was loaded with variant. If any changes were made on the sreen
**     fields then the selected load variant will be unselected from the variant dropdown.
      IF     <gf_varlistitem_shown> IS     ASSIGNED
         AND <gf_varlistitem_shown> IS NOT INITIAL.
        gt_mass_search_crit_buf = lt_search_crit_2.
      ENDIF.

  ENDCASE.

  gv_subscreen_dynpro = gc_variant_subscreen..

ENDFORM.                    " PAI_USER_COMMAND_1200
*&---------------------------------------------------------------------*
*&      Form  AUTHCHK_POPULATE_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM authchk_populate_result .

  DATA: no_of_lines TYPE i,
        lv_mcatalog TYPE /dbe/mcatalog,
        lt_ordtyp   TYPE /dbe/c_tt_ordertp,
        lt_vguid    TYPE TABLE OF vlc_guid,
        lt_vbak_com TYPE /dbe/vbak_com_tt.

  DATA: db_badi        TYPE REF TO /dbe/badi_es_hana.


  CALL METHOD /dbe/cl_es_hana_util=>get_hana_search
    RECEIVING
      ro_badi = db_badi.

*     Check for vehicle searched
  DESCRIBE TABLE gt_vehicles LINES no_of_lines.
  IF gv_skip_novehicle_info IS INITIAL.                     "N:2317367
    IF no_of_lines = 0.
      MESSAGE i078(/dbe/vehicle_master).
      ok_code = gc_find-gc_tab1.
      CLEAR gt_bapireturn.
    ENDIF.
  ENDIF.

  REFRESH gt_vsresult.

  SORT gt_vsresult BY vguid ASCENDING.
  SORT gt_iobj_single BY /dbe/v_vehicle-vguid.
  SORT gt_iobj_multi BY /dbe/v_vehicle-vguid.

  IF gt_vehicles IS NOT INITIAL.
*  * Get order type customizing to determine service orders
    CALL FUNCTION '/DBE/CU06_READ_ORDTYP_ENG'
      IMPORTING
        et_c_ordertp = lt_ordtyp
      EXCEPTIONS
*       not_found    = 1
        OTHERS       = 0. "No error

    LOOP AT gt_vehicles INTO gs_vehicles.
      APPEND gs_vehicles-vguid TO lt_vguid.
    ENDLOOP.

*  *  * Select all service orders / quotations for the vehicle
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbak_com
       FROM /dbe/vbak_db AS vbak
          INNER JOIN /dbe/splhdr_db AS splhdr
          ON splhdr~vbeln = vbak~vbeln
          AND splhdr~splnr = 1
         FOR ALL ENTRIES IN  lt_vguid
          WHERE  engine  = 'CS' AND vguid = lt_vguid-table_line.

    SORT lt_vbak_com DESCENDING BY audat vguid.

  ENDIF.

**************************************************************************************
*Authorization check : Remove the vehicles, user is not authrized to their model catalog
**************************************************************************************
  LOOP AT gt_vehicles INTO gs_vehicles.
    IF db_badi IS NOT BOUND. "IF Embedded Search on HANA is not enabled
*find out the model catalog of current vehicle
      SELECT SINGLE mcatalog FROM /dbe/v_model INTO lv_mcatalog WHERE matnr = gs_vehicles-matnr.

*Check the authorization for this model catalog
      IF NOT  lv_mcatalog IS INITIAL .

*          PERFORM check_model_catalog_authority USING lv_mcatalog.
        CALL FUNCTION '/DBE/CHECK_MODELCATALOG_AUTH'
          EXPORTING
            iv_model_cat = lv_mcatalog
          EXCEPTIONS
            no_authority = 1
            OTHERS       = 2.

        IF sy-subrc = 1.
*If user is not authorized than delete all vehicle corresponds to this material
          DELETE gt_vehicles WHERE matnr = gs_vehicles-matnr.
          DESCRIBE TABLE gt_vehicles LINES no_of_lines.
          IF no_of_lines = 0.
            MESSAGE i078(/dbe/vehicle_master).
            ok_code = gc_find-gc_tab1.
            CLEAR gt_bapireturn.
          ENDIF.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF sy-subrc <> 0 .
        DELETE gt_vehicles WHERE /dbe/iobjguid = gs_vehicles-/dbe/iobjguid.
        DESCRIBE TABLE gt_vehicles LINES no_of_lines.
        IF no_of_lines = 0.
          MESSAGE i078(/dbe/vehicle_master).
          ok_code = gc_find-gc_tab1.
          CLEAR gt_bapireturn.
        ENDIF.
        CONTINUE.
      ENDIF.

    ENDIF.
    MOVE-CORRESPONDING gs_vehicles TO gs_vsresult.

*Get iobject deatils for current vehicle
    PERFORM populate_result USING lt_ordtyp lt_vbak_com.
  ENDLOOP.

ENDFORM.                    " AUTHCHK_POPULATE_RESULT

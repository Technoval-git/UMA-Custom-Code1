**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGP02 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&       Class (Implementation)  lcl_optionsearchalv_event_rec
**&---------------------------------------------------------------------*
**        Text
**----------------------------------------------------------------------*
*class lcl_optionsearchalv_event_rec implementation.
*
*  METHOD handle_f4.
*
*    CONSTANTS: lc_tabname_moptions TYPE tabname VALUE '/DBE/V_MOPTIONS',
*               lc_option_class(7)  TYPE c VALUE 'OPCLASS',
*               lc_option_type(5)   TYPE c VALUE 'OPTYP',
*               lc_option_keyf4help TYPE fieldname VALUE '/DBE/OPKEY',
*               lc_option_key       TYPE fieldname VALUE 'OPKEY',
*               lc_option_mcodesd   TYPE fieldname VALUE 'MCODESD',
*               lc_sign_mcode_star  TYPE /DBE/MODCODE_SALE VALUE '*',
*               lc_sign_mcat_star   TYPE /DBE/mcatalog    VALUE '*'.
*
*    DATA : ls_fields TYPE  dfies.
*    DATA : lt_return TYPE STANDARD TABLE OF ddshretval.
*    DATA : ls_return TYPE ddshretval.
*    DATA : lv_value TYPE help_info-fldvalue.
*    DATA : lv_optyp TYPE /DBE/VD_OPTYP.
*    DATA : ls_optionalv TYPE /DBE/s_veh_alv_option_search.
*    DATA : lv_rowno TYPE sy-tabix.
*    DATA: lv_modguid TYPE /DBE/MODEL_GUID.
*    DATA : ls_modi           TYPE lvc_s_modi.
*    DATA: ls_model TYPE /DBE/v_model.
*
*    FIELD-SYMBOLS <itab> TYPE lvc_t_modi.
*
*    IF e_fieldname EQ gc_optyp. " Field: OPTYP - Features Category
*
*      SET PARAMETER ID gc_opclass FIELD opclass.            "#EC EXISTS
**     Reset the field Features Key
*      ASSIGN er_event_data->m_data->* TO <itab>.
*      IF sy-subrc EQ 0.
*        ls_modi-row_id    = es_row_no-row_id.
*        ls_modi-fieldname = gc_opkey.
*        CLEAR: ls_modi-value.
*        APPEND ls_modi TO <itab>.
*      ENDIF.
*
*    ELSEIF e_fieldname EQ gc_opkey. " Field: OPKEY - Features Key
*
*      ls_fields-tabname = lc_tabname_moptions. " '/DBE/V_MOPTIONS'.
*
**     read corresponding optype
*      lv_rowno = es_row_no-row_id.
*      READ TABLE gt_optionsearchalv INTO ls_optionalv INDEX lv_rowno.
*      IF sy-subrc EQ 0.
*        lv_optyp = ls_optionalv-optyp.
*      ENDIF.
*
*      SELECT SINGLE model_guid INTO  lv_modguid FROM /DBE/v_model
*                               WHERE mcodesd = ls_optionalv-mcodesd. "#EC *
*      IF sy-subrc <> 0.
*        CLEAR: lv_modguid.
*      ENDIF.
*      IF lv_modguid IS INITIAL.
*        MESSAGE i050(/DBE/vehicle_master).
**       Set flag finished to avoid the standard search help
*        er_event_data->m_event_handled = abap_true.
*      ELSE.
**       Set parameters relevant for search help
**       SET PARAMETER ID gc_model_guid
**                  FIELD gs_iobj_single-/DBE/V_IMODEL-modguid.
*        SET PARAMETER ID gc_model_guid   FIELD lv_modguid.  "#EC EXISTS
*        SET PARAMETER ID lc_option_class FIELD opclass.     "#EC EXISTS
*        SET PARAMETER ID lc_option_type  FIELD lv_optyp.    "#EC EXISTS
*
**       Call F4 for option key
*        CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
*          EXPORTING
*            tabname           = ls_fields-tabname
*            fieldname         = ls_fields-fieldname
*            searchhelp        = lc_option_keyf4help
*            shlpparam         = lc_option_key
*            value             = lv_value
*          TABLES
*            return_tab        = lt_return
*          EXCEPTIONS
*            field_not_found   = 1
*            no_help_for_field = 2
*            inconsistent_help = 3
*            no_values_found   = 4
*            OTHERS            = 5.
*        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDIF.
*
**       F4 retruns only opkey - read other model data
*        READ TABLE lt_return INTO ls_return INDEX 1.
*        IF sy-subrc EQ 0.
*          e_fieldvalue = ls_return-fieldval.
**         update grid field
*          ASSIGN er_event_data->m_data->* TO <itab>.
*          IF sy-subrc EQ 0.
*            ls_modi-row_id    = es_row_no-row_id.
*            ls_modi-fieldname = e_fieldname.
*            ls_modi-value     = ls_return-fieldval.
*            APPEND ls_modi TO <itab>.
**           Update Features Category key
*            SELECT SINGLE optyp INTO lv_optyp FROM  /DBE/v_moptions
*                                              WHERE model_guid = lv_modguid
*                                              AND   opkey      = ls_modi-value. "#EC *
*            IF sy-subrc = 0.
**             Put Features Category key to the ALV field
*              ls_modi-row_id = es_row_no-row_id.
*              ls_modi-fieldname = gc_optyp.
*              ls_modi-value = lv_optyp.
*              APPEND ls_modi TO <itab>.
*            ENDIF.
*
*          ENDIF.
*
*        ENDIF.
**       Set flag finished to avoid the standard search help
*        er_event_data->m_event_handled = abap_true.
*      ENDIF.
*
*    ELSEIF e_fieldname EQ lc_option_mcodesd.   " Field: MCODESD - Model Sales Code
*
*      CALL FUNCTION '/DBE/VM16_MODEL_SEARCH_HELP2'
*        EXPORTING
*          iv_vk_code  = lc_sign_mcode_star
*          iv_mcatalog = lc_sign_mcat_star
*          iv_nopopup  = space
*        IMPORTING
*          es_model    = ls_model.
*      READ TABLE gt_optionsearchalv INDEX es_row_no-row_id INTO ls_optionalv.
*      ls_optionalv-mcodesd = ls_model-mcodesd.
*      MODIFY gt_optionsearchalv INDEX es_row_no-row_id FROM ls_optionalv.
*      IF sy-subrc NE 0.
*        APPEND ls_optionalv TO gt_optionsearchalv.
*      ENDIF.
*
*      CALL METHOD go_option_search_alv->refresh_table_display.
*
**     Set flag finished to avoid the standard search help
*      er_event_data->m_event_handled = abap_true.
*    ENDIF.
*  ENDMETHOD.                                                "HANDLE_F4
*
*  METHOD is_data_changed.
*    ev_changed = mv_changed.
*    mv_changed = abap_undefined.
*  ENDMETHOD.                    "is_data_changed
*
*  METHOD set_data_changed.
*    mv_changed = abap_true.
*  ENDMETHOD.                    "set_data_changed
*
*  METHOD data_changed.
*    IF e_onf4 IS INITIAL.
*      PERFORM f_put_tree_to_searchcrit.
*      go_option_search_alv->raise_event( EXPORTING i_ucomm = 'ENTE' ).
*    ELSEIF e_onf4_after IS NOT INITIAL.
*      PERFORM f_put_tree_to_searchcrit.
*    ENDIF.
*  ENDMETHOD.                    "data_changed
*
*  METHOD data_changed_finished.
*    DATA: ls_optionalv   TYPE /DBE/s_veh_alv_option_search.
*    DATA: lv_modguid     TYPE /DBE/MODEL_GUID,
*          lv_option_guid TYPE /DBE/OPTION_GUID.
*    DATA: lv_modified    TYPE char01,
*          lv_empty_count TYPE i.
*
*    FIELD-SYMBOLS: <fs_good_cells> TYPE lvc_s_modi.
*    FIELD-SYMBOLS: <fs_optionalv>  TYPE /DBE/s_veh_alv_option_search.
*
*    lv_modified   = e_modified.
*
*    IF lv_modified IS NOT INITIAL AND LINES( et_good_cells ) > 1.
**     Override modified flag if no real change has been made. This is necessary
**     because Insert row and Append row buttons set this flag in (but needlessly).
*      CLEAR lv_empty_count.
*      LOOP AT et_good_cells ASSIGNING <fs_good_cells> WHERE value = ''.
*        ADD 1 TO lv_empty_count.
*      ENDLOOP.
*      IF lv_empty_count = LINES( et_good_cells ).
*        CLEAR lv_modified.
*      ENDIF.
*    ENDIF.
*
**   Get description and text for fields Features Category and Features Key
*    IF lv_modified IS NOT INITIAL.
*      LOOP AT et_good_cells ASSIGNING <fs_good_cells>.
*        READ TABLE gt_optionsearchalv INTO ls_optionalv INDEX <fs_good_cells>-row_id.
*        IF sy-subrc NE 0.
*          CONTINUE.
*        ELSE.
**         We should check that the selected features key was not
**         defined previously
*          LOOP AT gt_optionsearchalv ASSIGNING <fs_optionalv>
*                                     WHERE     mcodesd = ls_optionalv-mcodesd
*                                     AND       optyp   = ls_optionalv-optyp
*                                     AND       opkey   = ls_optionalv-opkey.
*            IF sy-tabix NE <fs_good_cells>-row_id.
*              CLEAR: ls_optionalv-opkey.
*              MESSAGE i291(/DBE/vehicle_master) WITH <fs_optionalv>-opkey ls_optionalv-optyp.
*              EXIT.
*            ENDIF.
*          ENDLOOP.
*        ENDIF.
*
*        IF <fs_good_cells>-fieldname EQ gc_optyp.
*          SELECT SINGLE descr FROM  /DBE/v_optypet INTO ls_optionalv-descr
*                              WHERE optyp = ls_optionalv-optyp
*                              AND   spras = sy-langu.
*          IF sy-subrc NE 0.
*            CLEAR: ls_optionalv-descr.
*          ENDIF.
*        ELSEIF <fs_good_cells>-fieldname EQ gc_opkey.
*          SELECT SINGLE model_guid INTO  lv_modguid
*                                   FROM  /DBE/v_model
*                                   WHERE mcodesd = ls_optionalv-mcodesd. "#EC *
*          IF sy-subrc <> 0.
*            CLEAR: lv_modguid.
*          ENDIF.
*          IF   lv_modguid IS INITIAL AND
*             ( ls_optionalv-optyp IS NOT INITIAL OR
*               ls_optionalv-opkey IS NOT INITIAL ).
*            CLEAR: ls_optionalv-optext1.
*            MESSAGE i050(/DBE/vehicle_master).
*          ELSE.
*            CLEAR: ls_optionalv-optext1.
*            SELECT SINGLE option_guid INTO  lv_option_guid
*                            FROM  /DBE/v_moptions
*                            WHERE model_guid = lv_modguid
*                            AND   optyp      = ls_optionalv-optyp
*                            AND   opkey      = ls_optionalv-opkey. "#EC *
*            IF sy-subrc = 0.
*              SELECT SINGLE optext1 INTO  ls_optionalv-optext1
*                                    FROM  /DBE/v_moptionst
*                                    WHERE option_guid = lv_option_guid
*                                    AND   spras       = sy-langu.
*            ENDIF.
*          ENDIF.
*        ELSEIF <fs_good_cells>-fieldname EQ gc_mcodesd.
*          SELECT SINGLE model_guid INTO  lv_modguid
*                                   FROM  /DBE/v_model
*                                   WHERE mcodesd = ls_optionalv-mcodesd. "#EC *
*          IF sy-subrc <> 0.
*            MESSAGE i290(/DBE/vehicle_master) WITH ls_optionalv-mcodesd.
*            CLEAR: ls_optionalv.
*          ENDIF.
*        ENDIF.
*        MODIFY gt_optionsearchalv FROM ls_optionalv INDEX <fs_good_cells>-row_id.
*      ENDLOOP.
*      CALL METHOD go_option_search_alv->refresh_table_display.
*      set_data_changed( ).
**   Apply changes to search criteria table as well
*      PERFORM f_put_tree_to_searchcrit.
*    ENDIF.
*  ENDMETHOD.                    "data_changed_finished
*
*  METHOD handle_user_command.
*    CASE e_ucomm.
*      WHEN 'EXECUTE'.
*        go_option_search_alv->check_changed_data( ).
*      WHEN 'ENTE'.
*        PERFORM f_put_tree_to_searchcrit.
*    ENDCASE.
*  ENDMETHOD.                    "handle_user_command
*
*endclass.               "lcl_optionsearchalv_event_rec

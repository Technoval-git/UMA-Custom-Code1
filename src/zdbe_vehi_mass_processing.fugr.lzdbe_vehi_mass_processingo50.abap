*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO50 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GENERATE_VACO_ALV_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE generate_vaco_alv_grid OUTPUT.
  DATA: lo_alv_grid           TYPE REF TO cl_gui_alv_grid,
        lo_cust_container     TYPE REF TO cl_gui_custom_container,
        lv_tabname            TYPE tabname VALUE '/DBE/VLC_ADC_HISTORY',
        lc_vaco_name          TYPE scrfname VALUE 'CC_VACO'.


  DATA: lt_vlcguid            TYPE TABLE OF vlcguid,
        ls_vlcguid            TYPE vlcguid,
        lv_vlcguid            TYPE vlc_guid,
        lt_vlcapo             TYPE TABLE OF /DBE/vlc_ac_po,
        ls_vlcapo             TYPE /DBE/vlc_ac_po,
        lt_vlc_adc_history    TYPE TABLE OF /DBE/vlc_adc_history,
        ls_vlc_adc_history    TYPE /DBE/vlc_adc_history,
        lt_servtypetxt        TYPE TABLE OF /DBE/servtype_t,
        ls_servtypetxt        TYPE /DBE/servtype_t,
        lv_succes             TYPE c VALUE 'S',
        ls_exclud             TYPE ui_func,
        lt_exclud             TYPE ui_functions.


  DATA: ls_variant            TYPE disvariant,
        lv_save_variant       TYPE char1 VALUE 'A',
        ls_fieldcatalog       TYPE lvc_s_fcat,
        lt_fieldcatalog       TYPE lvc_t_fcat,
        lt_sort               TYPE lvc_t_sort,
        ls_sort               TYPE lvc_s_sort.

  FIELD-SYMBOLS: <fs_fieldcatalog>       TYPE lvc_s_fcat.

  CLEAR: gs_layout , gs_fieldcat , gt_fieldcatalog, lt_exclud.

* CREATE A CUSTOM CONTAINER CONTROL FOR OUR ALV CONTROL
  IF lo_cust_container IS NOT BOUND.
    CREATE OBJECT lo_cust_container
      EXPORTING
        container_name              = lc_vaco_name
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc NE 0.
* ADD YOUR HANDLING, FOR EXAMPLE
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = sy-repid
          txt2  = sy-subrc
          txt1  = 'THE CONTROL COULD NOT BE CREATED'(510).
    ENDIF.

    CREATE OBJECT lo_alv_grid
      EXPORTING
        i_parent = lo_cust_container.

  ENDIF.

  CLEAR: lt_vlcguid , lt_vlcapo , lt_vlc_adc_history, gt_fieldcatalog, lt_sort .

* Create the fieldcatalogue
  CALL FUNCTION 'VELO03_FIELDCATALOG_MERGE'
    EXPORTING
      structure_name_iv       = lv_tabname
      client_never_display_iv = 'X'
    CHANGING
      fieldcat_ct             = gt_fieldcatalog
    EXCEPTIONS
      error_occured           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  READ TABLE gt_fieldcatalog ASSIGNING <fs_fieldcatalog> WITH KEY fieldname = 'COST'.
  IF sy-subrc <> 0.
  ELSE.
    <fs_fieldcatalog>-do_sum = abap_true.
  ENDIF.

  READ TABLE gt_fieldcatalog ASSIGNING <fs_fieldcatalog> WITH KEY fieldname = 'POSTING_DATE'.
  IF sy-subrc <> 0.
  ELSE.
    <fs_fieldcatalog>-coltext = 'Date'(701).
  ENDIF.
  READ TABLE gt_fieldcatalog ASSIGNING <fs_fieldcatalog> WITH KEY fieldname = 'POSTING_TIME'.
  IF sy-subrc <> 0.
  ELSE.
    <fs_fieldcatalog>-coltext = 'Time'(702).
  ENDIF.


  ls_sort-fieldname = 'POSTING_DATE'.
  ls_sort-up = 'X'.
  ls_sort-spos = '01'.
  APPEND ls_sort TO lt_sort.

  ls_sort-fieldname = 'POSTING_TIME'.
  ls_sort-up = 'X'.
  ls_sort-spos = '02'.
  APPEND ls_sort TO lt_sort.


* prepare data
*Get selected vehicle - in case of existing vehicle
  CALL FUNCTION '/DBE/VM08_VEHICLE_VGUID_GET'
    IMPORTING
      ev_vguid = lv_vlcguid.


  ls_vlcguid-vguid = lv_vlcguid.
  APPEND ls_vlcguid TO lt_vlcguid.

  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      iv_adddtional_cost_overview = abap_true
    TABLES
      vlcguid_it                  = lt_vlcguid
      vlcapo_et                   = lt_vlcapo
    EXCEPTIONS
      no_record_found             = 1
      OTHERS                      = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT lt_vlcapo INTO ls_vlcapo.
    ls_servtypetxt-service_type = ls_vlcapo-service_type.
    APPEND ls_servtypetxt TO lt_servtypetxt.
  ENDLOOP.

  CALL FUNCTION '/DBE/VMASS_READ_SERVTYPE_TEXT'
    EXPORTING
      iv_langu      = sy-langu
    TABLES
      servtypetxt_t = lt_servtypetxt.

  LOOP AT lt_vlcapo INTO ls_vlcapo.
    ls_vlc_adc_history-service_type = ls_vlcapo-service_type.
    READ TABLE lt_servtypetxt INTO ls_servtypetxt WITH KEY service_type = ls_vlc_adc_history-service_type.

    IF sy-subrc <> 0.
    ENDIF.
    ls_vlc_adc_history-text = ls_servtypetxt-text.
    ls_vlc_adc_history-vendor = ls_vlcapo-vendor.
    ls_vlc_adc_history-cost = ls_vlcapo-cost.
    ls_vlc_adc_history-currency = ls_vlcapo-currency.
    ls_vlc_adc_history-po_number = ls_vlcapo-po_number.
    ls_vlc_adc_history-gr_number = ls_vlcapo-gr_number.
    ls_vlc_adc_history-gr_year = ls_vlcapo-gr_year.
    ls_vlc_adc_history-inv_number = ls_vlcapo-inv_number.
    ls_vlc_adc_history-inv_year = ls_vlcapo-inv_year.

    CALL FUNCTION '/DBE/C_CONVERT_FROM_TIMESTAMP'
      EXPORTING
        iv_long_timestamp = ls_vlcapo-inv_tstmp
      IMPORTING
        ev_datlo          = ls_vlc_adc_history-posting_date
        ev_timlo          = ls_vlc_adc_history-posting_time
      EXCEPTIONS
        data_missing      = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    APPEND ls_vlc_adc_history TO lt_vlc_adc_history.
  ENDLOOP.

*Prepare table with button which are not required in toolbar(Exclude them):
  PERFORM exclude_tb_functionss CHANGING lt_exclud.

  ls_exclud = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_exclud TO lt_exclud.

  ls_exclud = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_exclud TO lt_exclud.

  ls_exclud = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclud TO lt_exclud.

  ls_exclud = cl_gui_alv_grid=>mc_fc_average.
  APPEND ls_exclud TO lt_exclud.

  ls_exclud = cl_gui_alv_grid=>mc_fc_maximum.
  APPEND ls_exclud TO lt_exclud.

  ls_exclud = cl_gui_alv_grid=>mc_fc_minimum.
  APPEND ls_exclud TO lt_exclud.

*Re-include filter in toolbar:
  DELETE lt_exclud WHERE table_line = cl_gui_alv_grid=>mc_mb_filter.

*  gs_layout-sel_mode = 'A'.
*  gs_layout-zebra = 'X'.
*  gs_layout-edit  = ''.
  gs_layout-cwidth_opt = 'X'.


  ls_variant-report = sy-cprog.
  ls_variant-handle = sy-dynnr.


  IF lo_alv_grid IS BOUND.
    CLEAR gs_layout.

    CALL METHOD lo_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = ls_variant
        i_save                        = lv_save_variant
        i_default                     = 'X'
        is_layout                     = gs_layout
        it_toolbar_excluding          = lt_exclud
      CHANGING
        it_sort                       = lt_sort
        it_outtab                     = lt_vlc_adc_history
        it_fieldcatalog               = gt_fieldcatalog
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDMODULE.                 " GENERATE_VACO_ALV_GRID  OUTPUT

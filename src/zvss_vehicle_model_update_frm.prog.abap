*&---------------------------------------------------------------------*
*& Include          ZVSS_VEHICLE_MODEL_UPDATE_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form form_get_data_pc_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM form_get_data_pc_file .

  PERFORM form_upload_file_pc USING gc_csv_sep.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form form_upload_file_pc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_CSV_SEP
*&---------------------------------------------------------------------*
FORM form_upload_file_pc  USING p_file_sep.


* Variable for passing the input file name
  DATA: lv_file_name          TYPE string,
* Variable for passing the virus scan profile
        lv_virus_sacn_profile TYPE vscan_profile,
* Internal table to which data in the input file will be uploaded
        it_data_tab           TYPE stringtab,
* Work area for the above internal table
        ts_data_tab           TYPE string.
  lv_file_name = pv_file.

* Method to upload the text file specified as input into internal table
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_file_name
      virus_scan_profile      = lv_virus_sacn_profile
    CHANGING
      data_tab                = it_data_tab
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  CLEAR gt_source.

  LOOP AT it_data_tab INTO ts_data_tab FROM 2.
* Map the data to structure
    PERFORM form_map_to_structure USING p_file_sep
                                        ts_data_tab.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form form_map_to_structure
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_FILE_SEP
*&      --> TS_DATA_TAB
*&---------------------------------------------------------------------*
FORM form_map_to_structure  USING    p_p_file_sep
                                     p_ts_data_tab.


*  DATA: gw_source   TYPE ty_source_fields.
  SPLIT p_ts_data_tab AT p_p_file_sep
  INTO gw_source-vhvin
  gw_source-matnr.

  APPEND gw_source TO gt_source.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_vehicle
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_vehicle .

  IF gt_source IS NOT INITIAL.
    SELECT * FROM vlcvehicle INTO TABLE @DATA(lt_vlcvehicle) FOR ALL ENTRIES IN
      @gt_source WHERE vhvin EQ @gt_source-vhvin.

    IF lt_vlcvehicle IS NOT INITIAL.

      SELECT * FROM /dbe/v_imodel INTO TABLE @DATA(lt_imodel) FOR ALL ENTRIES IN
         @lt_vlcvehicle WHERE product_guid EQ @lt_vlcvehicle-/dbe/iobjguid.

      SELECT * FROM /dbe/v_imodelt INTO TABLE @DATA(lt_imodelt) FOR ALL ENTRIES IN
         @lt_vlcvehicle WHERE product_guid EQ @lt_vlcvehicle-/dbe/iobjguid.

*      SELECT * FROM /dbe/v_ioption INTO TABLE @DATA(lt_ioption) FOR ALL ENTRIES IN
*         @lt_vlcvehicle WHERE product_guid EQ @lt_vlcvehicle-/dbe/iobjguid.

      SELECT * FROM /dbe/v_model INTO TABLE @DATA(lt_model) FOR ALL ENTRIES IN
         @gt_source WHERE matnr EQ @gt_source-matnr.

      IF lt_model IS NOT INITIAL.
        SELECT * FROM /dbe/v_modelt INTO TABLE @DATA(lt_modelt) FOR ALL ENTRIES IN
          @lt_model WHERE model_guid EQ @lt_model-model_guid.

*        SELECT * FROM /dbe/v_moptions INTO TABLE @DATA(lt_moptions) FOR ALL ENTRIES IN
*          @lt_model WHERE model_guid EQ @lt_model-model_guid AND copyrel EQ 'X'.
*
*        IF lt_moptions IS NOT INITIAL.
*          SELECT * FROM /dbe/v_moptionst INTO TABLE @DATA(lt_moptionst) FOR ALL ENTRIES IN
*            @lt_moptions WHERE option_guid EQ @lt_moptions-option_guid.
*        ENDIF.
      ENDIF.

      LOOP AT gt_source INTO gw_source.
        READ TABLE lt_model INTO DATA(ls_model) WITH KEY matnr = gw_source-matnr.
        IF sy-subrc EQ 0.
          READ TABLE lt_vlcvehicle INTO DATA(ls_vlcvehicle) WITH KEY vhvin = gw_source-vhvin.
          IF sy-subrc EQ 0.
            READ TABLE lt_imodel INTO DATA(ls_imodel) WITH KEY product_guid = ls_vlcvehicle-/dbe/iobjguid.
            IF sy-subrc EQ 0.
              MOVE-CORRESPONDING ls_model TO ls_imodel.
              ls_imodel-modguid = ls_model-model_guid.
              MODIFY /dbe/v_imodel FROM ls_imodel.
              READ TABLE lt_imodelt INTO DATA(ls_imodelt) WITH KEY product_guid = ls_vlcvehicle-/dbe/iobjguid.
              IF sy-subrc EQ 0.
                READ TABLE lt_modelt INTO DATA(ls_modelt) WITH KEY model_guid = ls_model-model_guid.
                MOVE-CORRESPONDING ls_modelt TO ls_imodelt.
                ls_imodelt-text1 = ls_modelt-motext1.
                ls_imodelt-text2 = ls_modelt-motext2.
                ls_imodelt-text3 = ls_modelt-motext3.
                ls_imodelt-text4 = ls_modelt-motext4.
                MODIFY /dbe/v_imodelt FROM ls_imodelt.
              ENDIF.
            ENDIF.
            ls_vlcvehicle-matnr = ls_model-matnr.
            MODIFY vlcvehicle FROM ls_vlcvehicle.
            UPDATE /dbe/v_ivehicle SET labval_ty = ls_model-labval_ty WHERE product_guid = ls_vlcvehicle-/dbe/iobjguid.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDIF.


  ENDIF.

ENDFORM.

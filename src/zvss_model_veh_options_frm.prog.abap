*&---------------------------------------------------------------------*
*& Include          ZVSS_MODEL_VEH_OPTIONS_FRM
*&---------------------------------------------------------------------*
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
  INTO gw_source-mcatalog
gw_source-opclass
gw_source-opkey
gw_source-optyp
gw_source-matnr
gw_source-puprc
gw_source-pkonwa
gw_source-saprc
gw_source-skonwa
gw_source-spras
gw_source-optext1
gw_source-optext2
gw_source-optext3
gw_source-optext4.

  APPEND gw_source TO gt_source.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_model_options
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_model_options .

  DATA : ls_options  TYPE /dbe/vm_options,
         ls_optionst TYPE /dbe/vm_optionst.

  LOOP AT gt_source INTO gw_source.
    MOVE-CORRESPONDING gw_source TO ls_options.
    MOVE-CORRESPONDING gw_source TO ls_optionst.
    MODIFY /dbe/vm_options FROM ls_options.
    MODIFY /dbe/vm_optionst FROM ls_optionst.
  ENDLOOP.

ENDFORM.

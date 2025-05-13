*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEH_MAT_UPLOAD_N_FORM
*&---------------------------------------------------------------------*
FORM form_on_val_req_file .
  DATA: lv_window_title      TYPE string,
        lv_rc                TYPE sysubrc,
        lv_default_file_name TYPE string,
        lt_file_table        TYPE filetable.

  CONSTANTS : lc_err TYPE i VALUE -1,
              lc_suc TYPE i VALUE 1.

  lv_window_title = TEXT-003.
  lv_default_file_name = TEXT-004.

* Method to provide value help for input file name
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_window_title
      default_filename        = lv_default_file_name
    CHANGING
      file_table              = lt_file_table
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  IF lv_rc EQ lc_err.
    MESSAGE ID sy-msgid
          TYPE sy-msgty
        NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSEIF lv_rc EQ lc_suc.
    READ TABLE lt_file_table INDEX 1 INTO p_file.
    IF sy-subrc <> 0.
      CLEAR p_file.
    ENDIF.
  ENDIF.
  CLEAR lt_file_table.
ENDFORM.
FORM form_on_val_req_pi  USING p_p_file TYPE localfile.
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = p_p_file
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_HIDE_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_LOG  text
*----------------------------------------------------------------------*
FORM form_hide_field  USING    p_lc_log.
  LOOP AT SCREEN.
    IF screen-group1 = p_lc_log.
      screen-input = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_UNHIDE_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_LOG  text
*----------------------------------------------------------------------*
FORM form_unhide_field  USING    p_lc_log.
  LOOP AT SCREEN.
    IF screen-group1 = p_lc_log.
      screen-input = 1.
      screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_FILE_EXTENSION_ALLOWED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_file_extension_allowed .

* FM to determine the extension of the specified input file
  IF sy-ucomm = 'ONLI'.
    IF p_file IS NOT INITIAL.
      CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
        EXPORTING
          filename  = p_file
        IMPORTING
          extension = lv_extension.

* Throw an error message
* if the extension of the input file is not equal
* the pre-determined extension
      TRANSLATE lv_extension TO UPPER CASE.

      IF ( ( lv_extension NS gc_ext1 ) AND
         ( lv_extension NE gc_ext2 ) ).
        MESSAGE TEXT-004 TYPE gc_err.
      ENDIF.
    ENDIF.


* Throw an error message
* if entered value in both File Path and Logical File Name
    IF p_file IS NOT INITIAL AND p_logicl IS NOT INITIAL.
      MESSAGE TEXT-007 TYPE gc_err.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_FETCH_FILEPATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_SLOGIC  text
*      <--P_P_SUCC  text
*----------------------------------------------------------------------*
FORM form_fetch_filepath  USING    p_logical
                          CHANGING p_cv_file TYPE localfile.
  IF p_logical IS NOT INITIAL.
    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
*       CLIENT           = SY-MANDT
        logical_filename = p_logical
      IMPORTING
        file_name        = p_cv_file
      EXCEPTIONS
        file_not_found   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
      EXIT.
    ENDIF.
  ENDIF.

  IF p_logical IS NOT INITIAL.
    CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
      EXPORTING
        filename  = p_cv_file
      IMPORTING
        extension = lv_extension.

* Throw an error message
* if the extension of the input file is not equal
* the pre-determined extension
    TRANSLATE lv_extension TO UPPER CASE.

    IF ( ( lv_extension NS gc_ext1 ) AND
       ( lv_extension NE gc_ext2 ) ).
      MESSAGE TEXT-004 TYPE gc_err.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_READ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PR_PI  text
*----------------------------------------------------------------------*
FORM form_read_file  USING p_pr_pi TYPE char1.
* To call the appropriate sub-routine to upload
* the respective input file based on the server
  IF p_pr_pi IS INITIAL.
* Extracting Data from Presentation Server File
    PERFORM form_get_data_pc_file.
  ELSE.
* Extracting Data from Application Server File
    PERFORM form_get_data_pi_file.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_GET_DATA_PC_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_get_data_pc_file .
* To call the appropriate sub-routine to upload the respective
* input file based on the file type
  IF lv_extension CS gc_ext1.
* Sub-routine to upload an excel file
    PERFORM form_upload_file_pc USING gc_csv_sep.
  ELSEIF lv_extension EQ gc_ext2.
* Sub-routine to upload a text file
    PERFORM form_upload_file_pc USING gc_txt_sep.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_GET_DATA_PI_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_get_data_pi_file .
* To call the appropriate sub-routine to upload the respective
* input file based on the file type
  IF lv_extension CS gc_ext1.
* Sub-routine to upload an excel file
    PERFORM form_upload_pi USING gc_csv_sep.
  ELSEIF lv_extension EQ gc_ext2.
* Sub-routine to upload a text file
    PERFORM form_upload_pi USING gc_txt_sep.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_UPLOAD_FILE_PC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CN_CSV_SEP  text
*----------------------------------------------------------------------*
FORM form_upload_file_pc  USING p_file_sep.

* Variable for passing the input file name
  DATA: lv_file_name          TYPE string,
* Variable for passing the virus scan profile
        lv_virus_sacn_profile TYPE vscan_profile,
* Internal table to which data in the input file will be uploaded
        it_data_tab           TYPE stringtab,
* Work area for the above internal table
        ts_data_tab           TYPE string.
  lv_file_name = p_file.

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
  CLEAR it_source.
  LOOP AT it_data_tab INTO ts_data_tab FROM 2.
* Map the data to structure
    PERFORM form_map_to_structure USING p_file_sep
                                        ts_data_tab.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_UPLOAD_PI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_CSV_SEP  text
*----------------------------------------------------------------------*
FORM form_upload_pi  USING    p_lc_sep.
  DATA : ts_row      TYPE string.
  CLEAR it_source.
  OPEN DATASET p_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
    DO.
      READ DATASET p_file INTO ts_row.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        IF sy-index GT 1.
* Map the data to structure
          PERFORM form_map_to_structure USING p_lc_sep
                                              ts_row.
        ENDIF.
      ENDIF.
    ENDDO.
    CLOSE DATASET p_file.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_MAP_TO_STRUCTURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FILE_SEP  text
*      -->P_TS_DATA_TAB  text
*      -->P_ENDLOOP  text
*----------------------------------------------------------------------*
FORM form_map_to_structure  USING    p_p_file_sep
                                     p_ts_data_tab.
  DATA: ts_source   TYPE ty_source_fields.
  SPLIT p_ts_data_tab AT p_p_file_sep
  INTO ts_source-matnr
ts_source-mbrsh
ts_source-mtart
ts_source-bukrs
*ts_source-werks
*ts_source-lgort
ts_source-vkorg
ts_source-vtweg
ts_source-maktx
ts_source-maktx_a
ts_source-meins
ts_source-matkl
ts_source-mtpos
ts_source-bismt
ts_source-class
ts_source-bstme
ts_source-spart
ts_source-taxm1
ts_source-kondm
ts_source-ktgrm
ts_source-mtpos_d
ts_source-mtvfp
ts_source-tragr
ts_source-ladgr
ts_source-xchpf
ts_source-bwtty
ts_source-ekgrp
ts_source-prctr
ts_source-dismm
ts_source-bklas
ts_source-vprsv
ts_source-verpr
ts_source-peinh.

  "Set default values
*  PERFORM f_default_values.
*  "Check Mandatory fields
*  PERFORM check_mandat CHANGING lv_success.

*  IF lv_success = abap_true.
*           ts_source-bwtty = lv_split1.

  "Conversion routine
*  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
*    EXPORTING
*      input  = ts_source-bstme
*    IMPORTING
*      output = ts_source-bstme.
*  "Conversion routine
*  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
*    EXPORTING
*      input  = ts_source-meins
*    IMPORTING
*      output = ts_source-meins.
*
*
*  IF  ts_source-bstme IS NOT INITIAL.
*    READ TABLE  it_unit_list TRANSPORTING NO FIELDS WITH KEY table_line =  ts_source-bstme.
*    IF sy-subrc <> 0.
*      APPEND  ts_source-bstme TO it_unit_list.
*    ENDIF.
*  ENDIF.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = ts_source-tragr
*    IMPORTING
*      output = ts_source-tragr.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = ts_source-ladgr
*    IMPORTING
*      output = ts_source-ladgr.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = ts_source-kondm
*    IMPORTING
*      output = ts_source-kondm.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = ts_source-ktgrm
*    IMPORTING
*      output = ts_source-ktgrm.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = ts_source-prctr
*    IMPORTING
*      output = ts_source-prctr.

  IF ts_source IS NOT INITIAL.
    APPEND ts_source TO it_source.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_VALIDATE_INBDEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM  form_process_material.
  lt_main[] = it_source[].

  DATA : lv_string              TYPE string,
         lv_unwanted_char       TYPE xstring VALUE '0D',
         lv_xstring             TYPE xstring,
         lv_empty               TYPE xstring,
         lv_msg1                TYPE symsgv,
         lo_root                TYPE REF TO cx_root,
         lv_message             TYPE string,
         lv_success             TYPE boolean,
         it_class_aloc_list     TYPE TABLE OF bapi1003_alloc_list,
         it_class_aloc_bapiret2 TYPE bapiret2_t.

  CONSTANTS :  lc_profile    TYPE cuprfid VALUE 'VEHICLE PROFILE'.

  IF r_woplan EQ 'X'.
    SELECT * FROM t001k INTO TABLE @DATA(lt_werks) FOR ALL ENTRIES IN
          @lt_main WHERE bukrs EQ @lt_main-bukrs+0(4).

    SELECT * FROM t001l INTO TABLE @DATA(lt_t001l) FOR ALL ENTRIES IN
             @lt_werks WHERE werks EQ @lt_werks-bwkey AND
                             lgort LIKE 'V%'.
  ELSE.
    SELECT * FROM t001w INTO TABLE @DATA(lt_werks1) WHERE werks IN @s_werks.

    SELECT * FROM t001l INTO TABLE @lt_t001l FOR ALL ENTRIES IN
       @lt_werks1 WHERE werks EQ @lt_werks1-bwkey AND
                       lgort LIKE 'V%'.
  ENDIF.






  LOOP AT lt_main INTO lwa_main.
    LOOP AT lt_t001l INTO DATA(lwa_t0011).
      TRY.

*        "Generate Material no if not specified in File data
*        IF lwa_main-mtart EQ 'VEHI' AND lwa_main-matnr IS INITIAL.
*          READ TABLE it_mat_bismat_map INTO ts_mat_bismat_map WITH KEY old_material = lwa_main-bismt. "Changed by DE1K905848
*          IF sy-subrc = 0.
*            lwa_main-matnr = ts_mat_bismat_map-sap_material.
*          ELSE.
*            CALL FUNCTION 'BAPI_MATERIAL_GETINTNUMBER'
*              EXPORTING
*                material_type    = lwa_main-mtart
*                required_numbers = 1
*              TABLES
*                material_number  = lt_material.
*
*            READ TABLE lt_material INTO ls_material INDEX 1.
*            IF sy-subrc EQ 0.
*              lwa_main-matnr = ls_material-material.
*              CLEAR: lt_material, ls_material.
*            ENDIF.
*          ENDIF.
**
**      ENDIF.
**
*        ENDIF.

********************************* Fill Header Level Details *********************************

          lwa_header-material      = lwa_main-matnr.
          lwa_header-ind_sector    = lwa_main-mbrsh.
          lwa_header-matl_type     = lwa_main-mtart.
          lwa_header-basic_view    = 'X'.
          lwa_header-purchase_view = 'X'.
          lwa_header-sales_view    = 'X'.
          lwa_header-account_view  = 'X'.
          lwa_header-storage_view  = 'X'.
*        lwa_header-mrp_view      = 'X'.


********************************* Material Description - Short Text **********************************
          REFRESH it_makt.
          IF lwa_main-maktx IS NOT INITIAL.
            lwa_makt-langu = sy-langu.
            lwa_makt-matl_desc = lwa_main-maktx.
            APPEND lwa_makt TO it_makt.
          ENDIF.

          IF lwa_main-maktx_a IS NOT INITIAL.
            lwa_makt-langu = 'AR'.
            lwa_makt-matl_desc = lwa_main-maktx_a.
            APPEND lwa_makt TO it_makt.
          ENDIF.


********************************** Basic Data **********************************
          lwa_client-matl_group     = lwa_main-matkl.
          lwa_client-base_uom       = lwa_main-meins.
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input  = lwa_client-base_uom
            IMPORTING
              output = lwa_client-base_uom.
          lwa_client-division       = lwa_main-spart.
          lwa_client-item_cat       = lwa_main-mtpos.
          lwa_client-trans_grp      = lwa_main-tragr.
*        lwa_client-net_weight = 1.
*        lwa_client-unit_of_wt = 'KG'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lwa_client-trans_grp
            IMPORTING
              output = lwa_client-trans_grp.
          lwa_client-old_mat_no     = lwa_main-bismt.
          lwa_client-po_unit        = lwa_main-bstme.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input  = lwa_client-po_unit
            IMPORTING
              output = lwa_client-po_unit.

          IF lwa_client-po_unit IS NOT INITIAL.
            READ TABLE  it_unit_list TRANSPORTING NO FIELDS WITH KEY table_line = lwa_client-po_unit.
            IF sy-subrc <> 0.
              APPEND lwa_client-po_unit TO it_unit_list.
            ENDIF.
          ENDIF.

          lwa_clientx-matl_group = 'X'.
          lwa_clientx-base_uom   = 'X'.
          lwa_clientx-division   = 'X'.
          lwa_clientx-item_cat   = 'X'.
          lwa_clientx-pur_valkey = 'X'.
          lwa_clientx-trans_grp  = 'X'.
          lwa_clientx-old_mat_no     = 'X'.
          lwa_clientx-po_unit        = 'X'.

********************************** Purchasing **********************************

          lwa_plant-plant      = lwa_t0011-werks. "lwa_main-werks.

          lwa_plant-pur_group  = lwa_main-ekgrp.
          lwa_plant-profit_ctr = lwa_main-prctr.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lwa_plant-profit_ctr
            IMPORTING
              output = lwa_plant-profit_ctr.
          lwa_plant-availcheck  = lwa_main-mtvfp.
          lwa_plant-loadinggrp  = lwa_main-ladgr.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lwa_plant-loadinggrp
            IMPORTING
              output = lwa_plant-loadinggrp.
*        lwa_plant-mrp_type    = lwa_main-dismm.
*        lwa_plant-batch_mgmt = lwa_main-xchpf.

          lwa_plantx-plant       = lwa_t0011-werks. "lwa_main-werks.
          lwa_plantx-pur_group   = 'X'.
*        lwa_plantx-batch_mgmt  = 'X'.
          lwa_plantx-profit_ctr  = 'X'.
          lwa_plantx-availcheck  = 'X'.
          lwa_plantx-loadinggrp  = 'X'.
*        lwa_plantx-mrp_type    = 'X'.



********************************** Sales **********************************

          lwa_sale-sales_org   = lwa_main-vkorg.
          lwa_sale-distr_chan  = '00'. "lwa_main-vtweg.
          lwa_sale-item_cat    = lwa_main-mtpos.
          lwa_sale-mat_pr_grp  = lwa_main-kondm.
          lwa_sale-acct_assgt  = lwa_main-ktgrm.

          lwa_salex-sales_org   = lwa_main-vkorg.
          lwa_salex-distr_chan  = '00'. "lwa_main-vtweg.
          lwa_salex-item_cat    = 'X'.
          lwa_salex-mat_pr_grp  = 'X'.
          lwa_salex-acct_assgt  = 'X'.

          lwa_salex-comm_group  = 'X'.
          lwa_salex-min_order   = 'X'.

          CLEAR : lwa_tax-depcountry, lwa_tax-tax_type_1.
          SELECT SINGLE land1 INTO lwa_tax-depcountry FROM t001w WHERE werks = lwa_t0011-werks. "lwa_main-werks.
          IF sy-subrc = 0.
            SELECT SINGLE tatyp INTO  lwa_tax-tax_type_1 FROM tstl WHERE talnd = lwa_tax-depcountry.
          ENDIF.

*        lwa_tax-depcountry = 'SA'.
*        lwa_tax-tax_type_1 = 'MWST'.
          lwa_tax-taxclass_1 = lwa_main-taxm1.
          lwa_tax-tax_ind = lwa_main-taxm1.
          REFRESH it_tax.
          APPEND lwa_tax TO it_tax.

********************************** Accounting **********************************

          lwa_acc-val_area   = lwa_t0011-werks.  "lwa_main-werks.
          lwa_acc-val_class  = lwa_main-bklas.
          lwa_acc-val_cat    = lwa_main-bwtty.
          lwa_acc-price_ctrl = lwa_main-vprsv.
          lwa_acc-moving_pr  = lwa_main-verpr.
          lwa_acc-price_unit = 1.

          lwa_accx-val_area   = lwa_t0011-werks. "lwa_main-werks.
          lwa_accx-val_class  = 'X'.
          lwa_accx-price_ctrl = 'X'.
          lwa_accx-moving_pr  = 'X'.
          lwa_accx-val_cat = 'X'.
          lwa_accx-price_unit = 'X'.

********************************** Storage location**********************************Added by DE1K904423

          lwa_store-plant = lwa_t0011-werks. "lwa_main-werks.
          lwa_store-stge_loc = lwa_t0011-lgort.  "lwa_main-lgort.

          lwa_storex-plant = lwa_t0011-werks.  "lwa_main-werks.
          lwa_storex-stge_loc = lwa_t0011-lgort. "lwa_main-lgort.

          SORT it_unit_list.
          IF it_unit_list IS NOT INITIAL.
            SELECT msehi zaehl nennr
              INTO TABLE it_unit_details
              FROM t006 FOR ALL ENTRIES IN it_unit_list
              WHERE msehi = it_unit_list-table_line.
            SORT it_unit_details BY unit.
          ENDIF.

********************************** Units of measure **********************************Added by DE1K904423
          READ TABLE it_unit_details INTO ts_unit_details WITH KEY unit = lwa_client-po_unit BINARY SEARCH.
          IF sy-subrc = 0.
            ts_uom-alt_unit = lwa_client-po_unit.
            ts_uom-denominatr = ts_unit_details-denom.
            ts_uom-numerator = ts_unit_details-numer.
            REFRESH it_uom.
            APPEND ts_uom TO it_uom.
            ts_uom_x-alt_unit = lwa_client-po_unit.
            ts_uom_x-denominatr = 'X'.
            ts_uom_x-numerator = 'X'.
            REFRESH it_uom_x.
            APPEND ts_uom_x TO it_uom_x.
          ENDIF.



          CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
            EXPORTING
              headdata             = lwa_header
              clientdata           = lwa_client
              clientdatax          = lwa_clientx
              plantdata            = lwa_plant
              plantdatax           = lwa_plantx
              forecastparameters   = lwa_forecast
              forecastparametersx  = lwa_forecastx
              storagelocationdata  = lwa_store
              storagelocationdatax = lwa_storex
              valuationdata        = lwa_acc
              valuationdatax       = lwa_accx
              salesdata            = lwa_sale
              salesdatax           = lwa_salex
            IMPORTING
              return               = lwa_return
            TABLES
              materialdescription  = it_makt
              unitsofmeasure       = it_uom "it_unit    "Added by DE1K904423
              unitsofmeasurex      = it_uom_x "it_unitx "Added by DE1K904423
              taxclassifications   = it_tax.

          "Check for success
          IF lwa_return-type EQ 'S'.
*          IF lwa_main-class-class IS NOT INITIAL.  "commented
            IF lwa_main-class IS NOT INITIAL.
              lwa_objkey-object = lwa_main-matnr.
              lwa_objkey-objecttable = 'MARA'.
              lwa_objkey-classtype = '300'.
              lwa_objkey-classnum = lwa_main-class.

              CALL FUNCTION 'BAPI_OBJCL_GETCLASSES' "Added by DE1K905848
                EXPORTING
                  objectkey_imp   = lwa_objkey-object
                  objecttable_imp = lwa_objkey-objecttable
                  classtype_imp   = lwa_objkey-classtype
                TABLES
                  alloclist       = it_class_aloc_list
                  return          = it_class_aloc_bapiret2.

              READ TABLE it_class_aloc_list
                TRANSPORTING NO FIELDS
                WITH KEY classnum = lwa_objkey-classnum.
              IF sy-subrc <> 0.
                "Assign Class for material
                CALL FUNCTION 'BAPI_OBJCL_CREATE'
                  EXPORTING
                    objectkeynew    = lwa_objkey-object
                    objecttablenew  = lwa_objkey-objecttable
                    classnumnew     = lwa_objkey-classnum
                    classtypenew    = lwa_objkey-classtype
                  TABLES
                    allocvaluesnum  = it_num
                    allocvalueschar = it_cha
                    allocvaluescurr = it_cur
                    return          = it_ret.
              ENDIF.

              READ TABLE it_ret
              TRANSPORTING NO FIELDS
              WITH KEY type = 'E'.
              IF sy-subrc = 0.
                MESSAGE ID 'ZMSG_VSS01'
                  TYPE 'E'
                  NUMBER '021'
                  INTO lv_message
                  WITH TEXT-cls.
                ls_log-old_matnr = lwa_main-bismt.
                ls_log-plant = lwa_t0011-werks.  "lwa_main-werks.
                ls_log-type = 'E'.
                ls_log-message = lv_message.
                APPEND ls_log TO lt_log.
                CLEAR ls_log.

                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*             IMPORTING
*               RETURN        =
                  .
              ELSE.

                wg_obj_key-key_feld = 'MATNR'.
                wg_obj_key-kpara_valu = lwa_objkey-object.

                REFRESH it_obj_key.
                APPEND wg_obj_key TO it_obj_key.

                wg_attrib-c_profile = lc_profile."'ZV_JUFFALI_01'.
                wg_attrib-classtype = lwa_objkey-classtype.

                REFRESH it_attrib.
                APPEND wg_attrib TO it_attrib.

                CALL FUNCTION 'CAMA_CON_PROFILE_MAINTAIN'
                  EXPORTING
                    object_type        = 'MARA'
                  TABLES
                    con_object_key     = it_obj_key
                    con_pro_attributes = it_attrib
                  EXCEPTIONS
                    error              = 1
                    OTHERS             = 2.
                IF sy-subrc = 0.
                  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                    EXPORTING
                      wait = 'X'.
*                "Create entry in Old mat to sap mat table
*                CLEAR ts_mat_bismat_map.
*                ts_mat_bismat_map-old_material = lwa_main-bismt.
*                ts_mat_bismat_map-sap_material = lwa_main-matnr.
*                ts_mat_bismat_map-material_desc = lwa_main-maktx.
*                APPEND ts_mat_bismat_map TO it_mat_bismat_map.

                  "Display message
                  ls_log-material = lwa_main-matnr.
                  ls_log-old_matnr = lwa_main-bismt.
                  ls_log-plant = lwa_t0011-werks. "lwa_main-werks.
                  ls_log-type = lwa_return-type.
                  ls_log-message = lwa_return-message.
                  APPEND ls_log TO lt_log.
                  CLEAR ls_log.
                ELSE.
                  MESSAGE ID 'ZMSG_VSS01'
                    TYPE 'E'
                    NUMBER '109'
                    INTO lv_message
                    WITH TEXT-prf.
*                ls_log-old_matnr = lwa_main-bismt.
                  ls_log-plant = lwa_t0011-werks.  "lwa_main-werks.
                  ls_log-type = 'E'.
                  ls_log-message = lv_message.
                  APPEND ls_log TO lt_log.
                  CLEAR ls_log.

                  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                ENDIF.
              ENDIF.
            ELSE.  "added CD 8956
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = 'X'.
*            "Create entry in Old mat to sap mat table
*            CLEAR ts_mat_bismat_map.
*            ts_mat_bismat_map-old_material = lwa_main-bismt.
*            ts_mat_bismat_map-sap_material = lwa_main-matnr.
*            ts_mat_bismat_map-material_desc = lwa_main-maktx.
*            APPEND ts_mat_bismat_map TO it_mat_bismat_map.

              "Display message
              ls_log-material = lwa_main-matnr.
              ls_log-old_matnr = lwa_main-bismt.
*            ls_log-plant = lwa_t0011-werks.  "lwa_main-werks.
              ls_log-type = lwa_return-type.
              ls_log-message = lwa_return-message.
              APPEND ls_log TO lt_log.
              CLEAR ls_log.

            ENDIF.
          ELSE.
            "Display message
            ls_log-material = lwa_main-matnr.
            ls_log-old_matnr = lwa_main-bismt.
            ls_log-plant = lwa_t0011-werks.  "lwa_main-werks.
            ls_log-type = lwa_return-type.
            ls_log-message = lwa_return-message.
            APPEND ls_log TO lt_log.
            CLEAR ls_log.
          ENDIF.

        CATCH cx_root INTO lo_root.
          lv_message = lo_root->get_text( ).
          ls_log-old_matnr = lwa_main-bismt.
          ls_log-material = lwa_main-matnr.
          ls_log-plant = lwa_t0011-werks. "lwa_main-werks.
          ls_log-type = 'E'.
          ls_log-message = lv_message.
          APPEND ls_log TO lt_log.
          CLEAR ls_log.
      ENDTRY.
      "Clear data
      CLEAR : lwa_header,lwa_client, lwa_clientx, lwa_plant,lwa_plantx,lwa_forecast,lwa_forecastx,lwa_store,lwa_storex,  "Added by DE1K904423
              lwa_acc,lwa_accx,lwa_sale,lwa_salex,lwa_return,it_makt,it_uom,it_uom_x,it_tax,it_class_aloc_list,it_class_aloc_bapiret2,
              it_ret.

    ENDLOOP.
  ENDLOOP.

*  IF it_mat_bismat_map IS NOT INITIAL.
*    MODIFY ymat_bismt_model FROM TABLE it_mat_bismat_map.
*    IF sy-subrc = 0.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          wait = 'X'.
*    ENDIF.
*  ENDIF.

  PERFORM f_upload_log_to_server.
  "Display in ALV
  IF lt_log[] IS NOT INITIAL.
    PERFORM f_display_alv.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_ALPHA_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TS_WUEB_EBELN  text
*      <--P_TS_SOURCE_COPY_EBELN  text
*----------------------------------------------------------------------*
FORM form_alpha_input  USING    p_input
                       CHANGING p_output.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_input
    IMPORTING
      output = p_output.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FORM_SERVR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_servr_log USING p_mtype TYPE char07.
  CONSTANTS: lc_dot           TYPE char01 VALUE '.',
             lc_underscore    TYPE char01 VALUE '_',
             lc_pattern       TYPE string VALUE '(.*)(\.{1}(?:csv|txt){1})$', " end with extension
             lc_last_f_sls    TYPE string VALUE '.*/$', "end with /
             lc_not_full_path TYPE string VALUE '(\.\w+)?$'.
  DATA : ts_data                TYPE  string,
         lv_path                TYPE  rcgfiletr-ftappl,
         ts_log                 TYPE  ty_log,
         lv_extension           TYPE  char5,
         ts_result              TYPE  match_result,
         lv_offset              TYPE  i,
         lv_file                TYPE localfile,
         lv_sub_path_file       TYPE string,
         lv_sub_path_extension  TYPE string,
         lv_user_path           TYPE string,
         lt_result_tab          TYPE match_result_tab,
         ts_submatch_result_tab TYPE match_result,
         lv_ext_tmp             TYPE string,
         lv_file_1              TYPE string.

  CLEAR: lv_path, ts_result, lv_offset, lv_extension,lv_user_path.
  lv_file = COND #( WHEN p_mtype EQ gc_error THEN p_error ELSE p_succ ).

  "copy path to local variable type string to omit succedding string space.
  lv_user_path = lv_file.
  CHECK lv_file IS NOT INITIAL.
  CALL METHOD zcl_common_util=>get_path_params
    EXPORTING
      iv_path      = lv_file
    IMPORTING
      ev_directory = lv_sub_path_file
      ev_file_name = lv_file_1
      ev_extension = lv_sub_path_extension.

  CONCATENATE lv_sub_path_file lv_file_1 TEXT-001 lc_underscore
              sy-datum sy-uzeit lv_sub_path_extension INTO lv_path.
  OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc IS INITIAL.
    CONCATENATE gc_message TEXT-017 TEXT-011 TEXT-010 INTO ts_data.
    TRANSFER ts_data TO lv_path.
    LOOP AT it_log INTO ts_log WHERE message EQ p_mtype.
      ts_data = ts_log.
      TRANSFER ts_data TO lv_path.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDLOOP.
    CLOSE DATASET lv_path.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_log.
*write error log
  PERFORM form_servr_log USING gc_error.
*write success log
  PERFORM form_servr_log USING gc_success.
*ALV
  PERFORM form_display_alv.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_display_alv .
  " LOCAL TABLES Declaration
  DATA  it_fcat    TYPE TABLE OF  slis_fieldcat_alv.
  " LOCAL WORK AREAS Declaration
  DATA: ts_fcat   TYPE        slis_fieldcat_alv,
        ts_layout TYPE        slis_layout_alv.
  DATA : lv_top TYPE slis_formname VALUE 'F_ALV_HEADER'.

**Field Catalog
*  CLEAR ts_fcat.
*  ts_fcat-fieldname = gc_message.
*  ts_fcat-tabname   = gc_it_source.
*  ts_fcat-outputlen   = 07.
*  ts_fcat-seltext_l   = TEXT-009.
*  APPEND ts_fcat TO it_fcat.
*
**  CLEAR ts_fcat.
**  ts_fcat-fieldname = gc_verur.
**  ts_fcat-tabname   = gc_it_source.
**  ts_fcat-outputlen   = 015.
**  ts_fcat-seltext_l   = TEXT-017.
**  APPEND ts_fcat TO it_fcat.
*
*
*  CLEAR ts_fcat.
*  ts_fcat-fieldname = gc_vhcex.
*  ts_fcat-tabname   = gc_it_source.
*  ts_fcat-outputlen   = 10.
*  ts_fcat-seltext_l   = TEXT-011.
*  APPEND ts_fcat TO it_fcat.
*
*
*  CLEAR ts_fcat.
*  ts_fcat-fieldname = gc_po.
*  ts_fcat-tabname   = gc_it_source.
*  ts_fcat-outputlen   = 10.
*  ts_fcat-seltext_l   = TEXT-024.
*  APPEND ts_fcat TO it_fcat.
*
*
*  CLEAR ts_fcat.
*  ts_fcat-fieldname = gc_po_item.
*  ts_fcat-tabname   = gc_it_source.
*  ts_fcat-outputlen   = 10.
*  ts_fcat-seltext_l   = TEXT-025.
*  APPEND ts_fcat TO it_fcat.
*
*  CLEAR ts_fcat.
*  ts_fcat-fieldname = gc_long_text.
*  ts_fcat-tabname   = gc_it_source.
*  ts_fcat-outputlen   = 60.
*  ts_fcat-seltext_l   = TEXT-010.
*  APPEND ts_fcat TO it_fcat.
  " Setting Layout for the Alv.
  ts_layout-zebra             = abap_true.
  ts_layout-colwidth_optimize = abap_true.

  IF it_log IS NOT INITIAL.
*    SORT it_log BY identifiers.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program     = sy-cprog
        i_callback_top_of_page = lv_top
        is_layout              = ts_layout
        it_fieldcat            = it_fcat
      TABLES
        t_outtab               = it_log
      EXCEPTIONS
        program_error          = 1
        OTHERS                 = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_ALV_HEADER
*&---------------------------------------------------------------------*
* To Display Success and error records (top_of_page)
*----------------------------------------------------------------------*
FORM f_alv_header ##called.

  " LOCAL TABLES Declaration
  DATA  lt_head      TYPE STANDARD TABLE OF slis_listheader.
  " LOCAL WORK AREAS Declaration
  DATA  lw_head      TYPE slis_listheader.

  CONSTANTS: lc_head TYPE c VALUE  'H',
             lc_sel  TYPE c VALUE  'S'.

  lw_head-typ  = lc_head.
  lw_head-info = TEXT-019.
  APPEND lw_head TO  lt_head.
  CLEAR lw_head.

  " Record count for ALV header display
  lw_head-typ  = lc_sel.
  CONCATENATE TEXT-020
              va_total_records      INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR lw_head.

  lw_head-typ  = lc_sel.
  CONCATENATE TEXT-021
              va_succ_records    INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR lw_head.

  lw_head-typ  = lc_sel.
  CONCATENATE TEXT-022
              va_fail_records     INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR lw_head.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_head.
ENDFORM           ##called.                    " F_ALV_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_LOG_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_log_path .
  DATA : lv_succ_directory  TYPE string,
         lv_error_directory TYPE string.
  IF p_succ IS NOT INITIAL.
    CALL METHOD zcl_common_util=>get_path_params
      EXPORTING
        iv_path      = p_succ
      IMPORTING
        ev_directory = lv_succ_directory.
    OPEN DATASET lv_succ_directory FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc  <> 0.
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  027
*              WITH    TEXT-l10.
    ENDIF.
    CLOSE DATASET lv_succ_directory.
  ENDIF.
  IF p_error IS NOT INITIAL.
    CALL METHOD zcl_common_util=>get_path_params
      EXPORTING
        iv_path      = p_error
      IMPORTING
        ev_directory = lv_error_directory.

    OPEN DATASET lv_error_directory FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc  <> 0.
*      MESSAGE ID      yif_dbm_jet_constants=>gc_msg_class_id
*              TYPE    yif_dbm_jet_constants=>gc_value_e
*              NUMBER  027
*              WITH    TEXT-l11.
    ENDIF.
    CLOSE DATASET lv_error_directory.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_REPLACE_JUNK_FROM_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TS_SOURCE  text
*----------------------------------------------------------------------*
FORM f_replace_junk_from_no  CHANGING cv_number.

  REPLACE ALL OCCURRENCES OF ',' IN cv_number WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN cv_number WITH ''.
  CONDENSE cv_number NO-GAPS.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_alv .
  DATA : it_events2 TYPE slis_t_event,
         ts_events2 TYPE slis_alv_event.

  PERFORM f_fill_field_catalog CHANGING it_fieldcat.

  wa_layout-zebra             = abap_true.
  wa_layout-colwidth_optimize = abap_true.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    IMPORTING
      et_events = it_events2.

* To set header
  READ TABLE it_events2 INTO ts_events2
     WITH KEY name = slis_ev_top_of_page .
  ts_events2-form = slis_ev_top_of_page .
  MODIFY it_events2 FROM ts_events2 INDEX sy-tabix .


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
*     i_callback_top_of_page = va_top
      i_grid_title       = TEXT-n04
      is_layout          = wa_layout
      it_fieldcat        = it_fieldcat
*     is_print           = ls_print
      it_events          = it_events2
    TABLES
      t_outtab           = lt_log
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       Fill field catalog for ALV
*----------------------------------------------------------------------*
*      <--P_IT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM f_fill_field_catalog  CHANGING ct_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: lw_fcat TYPE slis_fieldcat_alv.

  DEFINE m_cat ##NEEDED.
    lw_fcat-fieldname   = &1.
    lw_fcat-tabname     = &2.
    lw_fcat-seltext_l   = &3.
    lw_fcat-outputlen   = &4.
    APPEND lw_fcat TO ct_fieldcat.
  END-OF-DEFINITION.

  m_cat 'TYPE'           'LT_LOG' TEXT-n00 TEXT-026.
  m_cat 'OLD_MATNR'         'LT_LOG' TEXT-035 TEXT-026.
  m_cat 'MATERIAL'         'LT_LOG' TEXT-n01 TEXT-026.
  m_cat 'PLANT'         'LT_LOG' TEXT-n02 TEXT-026.
  m_cat 'MESSAGE'        'LT_LOG' TEXT-n03 TEXT-026.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_LOG_TO_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_upload_log_to_server .
*  data delclarations
  DATA : lv_path       TYPE rcgfiletr-ftappl,
         l_temp_string TYPE char260,
         lv_extension  TYPE string,
         ls_result     TYPE match_result,
         lv_offset     TYPE i,

         old_matnr     TYPE bismt,
         material      TYPE matnr,
         plant         TYPE werks_d,
         type          TYPE bapi_mtype,
         message       TYPE bapi_msg,
         lv_strlen     TYPE int4,
         lv_dir        TYPE string,
         lv_filename   TYPE string.
* constants for headings
  CONSTANTS: lc_old_matnr TYPE char50 VALUE 'OLD_MATNR',
             lc_material  TYPE char50 VALUE 'MATERIAL',
             lc_plant     TYPE char50 VALUE 'PLANT',
             lc_type      TYPE char50 VALUE 'TYPE',
             lc_message   TYPE char50 VALUE 'MESSAGE'.

*** Success Log
  CLEAR: lv_path, ls_result, lv_offset, lv_extension,lv_dir,lv_filename.

  CHECK p_log IS NOT INITIAL. "CR 8100002945
  zcl_common_util=>get_path_params(
     EXPORTING
       iv_path      = p_log    " success file path
*      iv_prefix    =          " prefix
     IMPORTING
       ev_directory = lv_dir        " created path
       ev_file_name = lv_filename   " FILE NAME
       ev_extension = lv_extension  " file extension
   ).

  CONCATENATE lv_dir lv_filename  TEXT-034
              sy-datum sy-uzeit  lv_extension INTO lv_path.


*  create and open file for write
  OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc <> 0.
    CONCATENATE TEXT-034
            sy-datum sy-uzeit  lv_extension INTO lv_path.
    OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  ENDIF.
  IF sy-subrc IS INITIAL.

*transfer heading
    CONCATENATE lc_old_matnr lc_material
          lc_plant  lc_type lc_message INTO l_temp_string SEPARATED BY space.
    TRANSFER  l_temp_string TO lv_path.

**transfer data
    LOOP AT lt_log INTO ls_log.
*      TRANSFER  Log TO lv_path.
      CONCATENATE ls_log-old_matnr ls_log-material
            ls_log-plant      ls_log-type ls_log-message INTO l_temp_string SEPARATED BY space.
      TRANSFER l_temp_string TO lv_path.
      CLEAR:l_temp_string.
      IF sy-subrc IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
    CLOSE DATASET lv_path.
  ENDIF.

*** Error Log
  CLEAR: lv_path, ls_result, lv_offset, lv_extension.
ENDFORM.

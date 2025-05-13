*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEH_MAT_UPLOAD_SUB
*&---------------------------------------------------------------------*

FORM f_file_value .

  DATA: l_rc         TYPE i,                                                      "RC Value
        l_select     TYPE string,                                                 "Select File
        lt_file_name TYPE STANDARD TABLE OF file_table.
  l_select = TEXT-002.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog                         "Selection screen file value help
    EXPORTING
      window_title            = l_select
*     default_filename        = ca_txt
      multiselection          = abap_true
    CHANGING
      file_table              = lt_file_name
      rc                      = l_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> ca_check.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  IF lt_file_name IS NOT INITIAL.
*Assign file names to selection screen field
    LOOP AT lt_file_name INTO wa_file_name.
      p_fname = wa_file_name-filename.
      CLEAR wa_file_name.
    ENDLOOP.
  ENDIF.

ENDFORM.

FORM f_at_sel_scr_on_val_req_pi  USING p_fname TYPE rlgrap-filename.

  DATA : l_fname TYPE localfile.

  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = l_fname
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  p_fname =  l_fname.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_LOADDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_loaddata .

  IF rb_pi IS INITIAL.
    "Read file from presentation server
    PERFORM f_read_file.
  ELSE.
    "read file from Application server
    PERFORM f_extract_data_pi.
*    ls_print-print = 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_READ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_read_file .

  DATA: l_filename TYPE string.                                               "File Name
  l_filename = p_fname.
  CONSTANTS: lc_err_msg TYPE c VALUE 'E'.

  CALL METHOD cl_gui_frontend_services=>gui_upload                            "Read file data into SAP.
    EXPORTING
      filename                = l_filename
      filetype                = ca_ftype
    CHANGING
      data_tab                = i_file_data
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


  IF i_file_data IS INITIAL.
    MESSAGE TEXT-036 TYPE  lc_err_msg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_EXTRACT_DATA_PI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_extract_data_pi .

  DATA : lw_row      TYPE string.

*  OPEN DATASET p_fname FOR INPUT IN TEXT MODE ENCODING UTF-8.
  OPEN DATASET p_fname FOR INPUT IN TEXT MODE ENCODING NON-UNICODE.
  IF sy-subrc IS INITIAL.
    DO.
      READ DATASET p_fname INTO lw_row.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        wa_file_data = lw_row.
        APPEND wa_file_data TO i_file_data.
        CLEAR wa_file_data.
      ENDIF.
    ENDDO.
    CLOSE DATASET p_fname.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
"Changes
"1. assiging taxclass_1  with taxm1 in it_tax
"2. creating entry in unitsofmeasure and unitsofmeasurex for bstme(Order Unit)
*----------------------------------------------------------------------*
FORM f_prepare_data .
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


  SELECT * FROM t001k INTO TABLE @DATA(lt_werks) FOR ALL ENTRIES IN
             @lt_main WHERE bukrs EQ @lt_main-bukrs.

  SELECT * FROM t001l INTO TABLE @DATA(lt_t001l) FOR ALL ENTRIES IN
               @lt_werks WHERE werks EQ @lt_werks-bwkey AND
                               lgort LIKE 'V%'.

  LOOP AT lt_main INTO lwa_main.
    LOOP AT lt_werks INTO DATA(ls_werks) WHERE bukrs = lwa_main-bukrs.
      LOOP AT lt_t001l INTO DATA(ls_t001l) WHERE werks EQ ls_werks-bwkey.
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
            lwa_header-mrp_view      = 'X'.


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
            lwa_client-division       = lwa_main-spart.
            lwa_client-item_cat       = lwa_main-mtpos.
            lwa_client-trans_grp      = lwa_main-tragr.
            lwa_client-old_mat_no     = lwa_main-bismt.
            lwa_client-po_unit        = lwa_main-bstme.


            lwa_clientx-matl_group = 'X'.
            lwa_clientx-base_uom   = 'X'.
            lwa_clientx-division   = 'X'.
            lwa_clientx-item_cat   = 'X'.
            lwa_clientx-pur_valkey = 'X'.
            lwa_clientx-trans_grp  = 'X'.
            lwa_clientx-old_mat_no     = 'X'.
            lwa_clientx-po_unit        = 'X'.

********************************** Purchasing **********************************

            lwa_plant-plant      = ls_t001l-werks."  lwa_main-werks.
            lwa_plant-pur_group  = lwa_main-bukrs.  "lwa_main-ekgrp.
            lwa_plant-profit_ctr = lwa_main-prctr.
            lwa_plant-availcheck  = lwa_main-mtvfp.
            lwa_plant-loadinggrp  = lwa_main-ladgr.
            lwa_plant-mrp_type    = lwa_main-dismm.
*        lwa_plant-batch_mgmt = lwa_main-xchpf.

            lwa_plantx-plant       = ls_t001l-werks.  "lwa_main-werks.
            lwa_plantx-pur_group   = 'X'.
*        lwa_plantx-batch_mgmt  = 'X'.
            lwa_plantx-profit_ctr  = 'X'.
            lwa_plantx-availcheck  = 'X'.
            lwa_plantx-loadinggrp  = 'X'.
            lwa_plantx-mrp_type    = 'X'.



********************************** Sales **********************************

            lwa_sale-sales_org   = lwa_main-bukrs.  "lwa_main-vkorg.
            lwa_sale-distr_chan  = lwa_main-vtweg.
            lwa_sale-item_cat    = lwa_main-mtpos.
            lwa_sale-mat_pr_grp  = lwa_main-kondm.
            lwa_sale-acct_assgt  = lwa_main-ktgrm.

            lwa_salex-sales_org   = lwa_main-bukrs.  "lwa_main-vkorg.
            lwa_salex-distr_chan  = lwa_main-vtweg.
            lwa_salex-item_cat    = 'X'.
            lwa_salex-mat_pr_grp  = 'X'.
            lwa_salex-acct_assgt  = 'X'.

            lwa_salex-comm_group  = 'X'.
            lwa_salex-min_order   = 'X'.

            CLEAR : lwa_tax-depcountry, lwa_tax-tax_type_1.
            SELECT SINGLE land1 INTO lwa_tax-depcountry FROM t001w WHERE werks = ls_t001l-werks. "lwa_main-werks.
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

            lwa_acc-val_area   = ls_t001l-werks. "lwa_main-werks.
            lwa_acc-val_class  = lwa_main-bklas.
            lwa_acc-val_cat    = lwa_main-bwtty.
            lwa_acc-price_ctrl = lwa_main-vprsv.
            lwa_acc-moving_pr  = lwa_main-verpr.
            lwa_acc-price_unit = 1.

            lwa_accx-val_area   = ls_t001l-werks.  "lwa_main-werks.
            lwa_accx-val_class  = 'X'.
            lwa_accx-price_ctrl = 'X'.
            lwa_accx-moving_pr  = 'X'.
            lwa_accx-val_cat = 'X'.
            lwa_accx-price_unit = 'X'.

********************************** Storage location**********************************Added by DE1K904423

            lwa_store-plant = ls_t001l-werks.  "lwa_main-werks.
            lwa_store-stge_loc = ls_t001l-lgort.   "lwa_main-lgort.

            lwa_storex-plant = ls_t001l-werks.   "lwa_main-werks.
            lwa_storex-stge_loc = ls_t001l-lgort.   "lwa_main-lgort.

********************************** Units of measure **********************************Added by DE1K904423
            READ TABLE it_unit_details INTO ts_unit_details WITH KEY unit = lwa_main-bstme BINARY SEARCH.
            IF sy-subrc = 0.
              ts_uom-alt_unit = lwa_main-bstme.
              ts_uom-denominatr = ts_unit_details-denom.
              ts_uom-numerator = ts_unit_details-numer.
              REFRESH it_uom.
              APPEND ts_uom TO it_uom.
              ts_uom_x-alt_unit = lwa_main-bstme.
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
                  ls_log-plant = lwa_main-werks.
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
                    ls_log-plant = lwa_main-werks.
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
                    ls_log-plant = lwa_main-werks.
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
                ls_log-plant = lwa_main-werks.
                ls_log-type = lwa_return-type.
                ls_log-message = lwa_return-message.
                APPEND ls_log TO lt_log.
                CLEAR ls_log.

              ENDIF.
            ELSE.
              "Display message
              ls_log-material = lwa_main-matnr.
              ls_log-old_matnr = lwa_main-bismt.
              ls_log-plant = lwa_main-werks.
              ls_log-type = lwa_return-type.
              ls_log-message = lwa_return-message.
              APPEND ls_log TO lt_log.
              CLEAR ls_log.
            ENDIF.

          CATCH cx_root INTO lo_root.
            lv_message = lo_root->get_text( ).
            ls_log-old_matnr = lwa_main-bismt.
            ls_log-material = lwa_main-matnr.
            ls_log-plant = lwa_main-werks.
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

  m_cat 'TYPE'           'LT_LOG' TEXT-004 TEXT-008.
  m_cat 'OLD_MATNR'         'LT_LOG' TEXT-035 TEXT-008.
  m_cat 'MATERIAL'         'LT_LOG' TEXT-005 TEXT-008.
  m_cat 'PLANT'         'LT_LOG' TEXT-006 TEXT-008.
  m_cat 'MESSAGE'        'LT_LOG' TEXT-007 TEXT-009.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_MANDAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_SUCCESS  text
*----------------------------------------------------------------------*
FORM check_mandat  CHANGING p_lv_success.

  DATA : lv_mandat_fields TYPE string,
         lv_message       TYPE string,
         lv_message2      TYPE string,
         lv_unit_same     TYPE boolean.

  ls_log-old_matnr = lwa_main-bismt.
  ls_log-material = lwa_main-matnr.
  ls_log-plant = lwa_main-werks.
  ls_log-type = 'E'.


  IF lwa_main-mtart IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-011.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.
  ENDIF.

*  IF lwa_main-lgort IS INITIAL.
*    "Mandatory field missing
*    MESSAGE ID 'ZMSG_VSS01'
*      TYPE 'E'
*      NUMBER '022'
*      INTO lv_message
*      WITH TEXT-033 TEXT-012.
*    ls_log-message = lv_message.
*    APPEND ls_log TO lt_log.
*  ENDIF.
*  IF lwa_main-vkorg IS INITIAL.
*    "Mandatory field missing
*    MESSAGE ID 'ZMSG_VSS01'
*      TYPE 'E'
*      NUMBER '022'
*      INTO lv_message
*      WITH TEXT-033 TEXT-013.
*    ls_log-message = lv_message.
*    APPEND ls_log TO lt_log.
*  ENDIF.
  IF lwa_main-vtweg IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-014.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-maktx IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-015.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-matkl IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-017.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-mtpos IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-018.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
*  IF lwa_main-bismt IS INITIAL.
*    "Mandatory field missing
*    MESSAGE ID 'ZMSG_VSS01'
*      TYPE 'E'
*      NUMBER '022'
*      INTO lv_message
*      WITH TEXT-033 TEXT-019.
*    ls_log-message = lv_message.
*    APPEND ls_log TO lt_log.
*
*  ENDIF.
*  IF lwa_main-class IS INITIAL AND lwa_main-mtpos NE 'LEIS'.
  IF lwa_main-class IS INITIAL AND lwa_main-mtart = 'VEHI'.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-020.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-spart IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-021.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-mtpos IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-025.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-mtvfp IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-026.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-ladgr IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-028.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-dismm IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-029.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-bklas IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-030.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
  IF lwa_main-verpr IS INITIAL.
    "Mandatory field missing
    MESSAGE ID 'ZMSG_VSS01'
      TYPE 'E'
      NUMBER '022'
      INTO lv_message
      WITH TEXT-033 TEXT-031.
    ls_log-message = lv_message.
    APPEND ls_log TO lt_log.

  ENDIF.
*  IF lwa_main-bstme = lwa_main-meins.
*    "Mandatory field missing
*    MESSAGE ID 'ZMSG_VSS01'
*      TYPE 'E'
*      NUMBER '023'
*      INTO lv_message.
*    ls_log-message = lv_message.
*    APPEND ls_log TO lt_log.
*
*
*  ENDIF.


  IF lt_log IS NOT INITIAL.
    p_lv_success = abap_false.
  ELSE.
    p_lv_success = abap_true.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DEFAULT_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_default_values .

  CONSTANTS : lc_dflt_vprsv TYPE mbew-vprsv VALUE 'V',
              lc_dflt_mbrsh TYPE mbrsh VALUE 'M',
              lc_dflt_meins TYPE meins VALUE 'EA',
              lc_dflt_taxm1 TYPE taxm1 VALUE '0',
              lc_dflt_kondm TYPE kondm VALUE '1',
              lc_dflt_xchpf TYPE xchpf VALUE 'X',
              lc_dflt_bwtty TYPE bwtty VALUE 'X',
              lc_dflt_tragr TYPE tragr VALUE '1'.





  "Defaulting Values
  IF lwa_main_char-vprsv IS INITIAL.
    lwa_main_char-vprsv = lc_dflt_vprsv. "V
  ENDIF.

  "Defaulting Values
  IF lwa_main_char-mbrsh IS INITIAL.
    lwa_main_char-mbrsh = lc_dflt_mbrsh.
  ENDIF.

  "Defaulting Values
  IF lwa_main_char-meins IS INITIAL.
    lwa_main_char-meins = lc_dflt_meins.
  ENDIF.

  "Defaulting Values
  IF lwa_main_char-taxm1 IS INITIAL.
    lwa_main_char-taxm1 = lc_dflt_taxm1.
  ENDIF.

  "Defaulting Values
  IF lwa_main_char-kondm IS INITIAL.
    lwa_main_char-kondm = lc_dflt_kondm.
  ENDIF.

  "Defaulting Values
  IF lwa_main_char-xchpf IS INITIAL.
    lwa_main_char-xchpf = lc_dflt_xchpf.
  ENDIF.

  "Defaulting Values
  IF lwa_main_char-bwtty IS INITIAL.
    lwa_main_char-bwtty = lc_dflt_bwtty.
  ENDIF.

  "Defaulting Values
  IF lwa_main_char-tragr IS INITIAL.
    lwa_main_char-tragr = lc_dflt_tragr.
  ENDIF.
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
      i_grid_title       = TEXT-003
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


FORM top_of_page .

  DATA: lv_lines   TYPE int4,
        lv_date_15 TYPE char15,
        lv_heading TYPE string,
        it_head    TYPE STANDARD TABLE OF slis_listheader,
        ts_head    TYPE slis_listheader.
*

*  IF p_radd = abap_true.
  ts_head-typ  = 'H'.
  ts_head-info  = TEXT-003.

  APPEND ts_head TO  it_head.
  CLEAR ts_head.

  "No of records
  DESCRIBE TABLE lt_log LINES lv_lines.
  ts_head-typ  = 'S'.
  ts_head-key  = TEXT-036.
  ts_head-info = lv_lines.
  APPEND ts_head TO  it_head.
  CLEAR ts_head.

  "No of error records
  DELETE lt_log WHERE type <> 'E'.
  DESCRIBE TABLE lt_log LINES lv_lines.
  ts_head-typ  = 'S'.
  ts_head-key  = TEXT-039.
  ts_head-info = lv_lines.
  APPEND ts_head TO  it_head.
  CLEAR ts_head.


  " Date
  WRITE sy-datum TO lv_date_15 DD/MM/YYYY.
  ts_head-typ  = 'S'.
  ts_head-key  = TEXT-037.
  ts_head-info = lv_date_15.
  APPEND ts_head TO it_head.
  CLEAR ts_head.

  "User name
  ts_head-typ  = 'S'.
  ts_head-key  = TEXT-038.
  ts_head-info = sy-uname.
  APPEND ts_head TO  it_head.
  CLEAR ts_head.
*


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_head.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_AND_CHECK_MANDAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_split_and_check_mandat .

  DATA : lv_string        TYPE string,
         lv_unwanted_char TYPE xstring VALUE '0D',
         lv_xstring       TYPE xstring,
         lv_empty         TYPE xstring,
         lo_root          TYPE REF TO cx_root,
         lv_message       TYPE string,
         lv_success       TYPE boolean.

  LOOP             AT i_file_data INTO wa_file_data.
    TRY.
        "Skip Heading row
        IF sy-tabix = 1.
          CONTINUE.
        ENDIF.
        "Split into structure
        SPLIT wa_file_data AT lv_tab INTO lwa_main_char-matnr
                                          lwa_main_char-mbrsh
                                          lwa_main_char-mtart
*                                          lwa_main_char-werks
*                                          lwa_main_char-lgort
*                                          lwa_main_char-vkorg
                                          lwa_main_char-bukrs
                                          lwa_main_char-vtweg
                                          lwa_main_char-maktx
                                          lwa_main_char-maktx_a
                                          lwa_main_char-meins
                                          lwa_main_char-matkl
                                          lwa_main_char-mtpos
                                          lwa_main_char-bismt
                                          lwa_main_char-class
                                          lwa_main_char-bstme
                                          lwa_main_char-spart
                                          lwa_main_char-taxm1
                                          lwa_main_char-kondm
                                          lwa_main_char-ktgrm
                                          lwa_main_char-mtpos_d
                                          lwa_main_char-mtvfp
                                          lwa_main_char-tragr
                                          lwa_main_char-ladgr
                                          lwa_main_char-xchpf
                                          lwa_main_char-bwtty" lv_split1        "
                                          lwa_main_char-ekgrp
                                          lwa_main_char-prctr
                                          lwa_main_char-dismm
                                          lwa_main_char-bklas
                                          lwa_main_char-vprsv
                                          lwa_main_char-verpr"."lv_split2. ".
                                          lwa_main_char-peinh.

        IF rb_pi = abap_true.
          "Avoid #
          lv_string = lwa_main_char-verpr.
          CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
            EXPORTING
              text   = lv_string
            IMPORTING
              buffer = lv_xstring.

          REPLACE ALL OCCURRENCES OF lv_unwanted_char
            IN lv_xstring WITH lv_empty IN BYTE MODE.
          CLEAR lv_string.
          CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
            EXPORTING
              im_xstring = lv_xstring
            IMPORTING
              ex_string  = lv_string.
          "Avoid #
          lwa_main_char-verpr = lv_string.
        ENDIF.

        "Set default values
        PERFORM f_default_values.
        CLEAR lwa_main.
        MOVE-CORRESPONDING lwa_main_char TO lwa_main.
        "Check Mandatory fields
        PERFORM check_mandat CHANGING lv_success.

        IF lv_success = abap_true.
*          lwa_main-bwtty = lv_split1.

          "Conversion routine
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input  = lwa_main-bstme
            IMPORTING
              output = lwa_main-bstme.
          "Conversion routine
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input  = lwa_main-meins
            IMPORTING
              output = lwa_main-meins.

          "Listing unit to get numerator and denominator of unit   "DE1K904423
          IF lwa_main-bstme IS NOT INITIAL.
            READ TABLE  it_unit_list TRANSPORTING NO FIELDS WITH KEY table_line = lwa_main-bstme.
            IF sy-subrc <> 0.
              APPEND lwa_main-bstme TO it_unit_list.
            ENDIF.
          ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lwa_main-tragr
            IMPORTING
              output = lwa_main-tragr.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lwa_main-ladgr
            IMPORTING
              output = lwa_main-ladgr.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lwa_main-kondm
            IMPORTING
              output = lwa_main-kondm.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lwa_main-ktgrm
            IMPORTING
              output = lwa_main-ktgrm.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lwa_main-prctr
            IMPORTING
              output = lwa_main-prctr.


          "Create table of splitted entries
          APPEND lwa_main TO lt_main.
          CLEAR lwa_main.
        ENDIF.
      CATCH cx_root INTO lo_root.
        lv_message = lo_root->get_text( ).
        ls_log-old_matnr = lwa_main-bismt.
        ls_log-material = lwa_main-matnr.
        ls_log-plant = lwa_main-werks.
        ls_log-type = 'E'.
        ls_log-message = lv_message.
        APPEND ls_log TO lt_log.
        CLEAR ls_log.
    ENDTRY.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_VALUES_FROM_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_values_from_db .
  "Get Denominator and Numerator of units from DB for Units DE1K904423
  SORT it_unit_list.
  IF it_unit_list IS NOT INITIAL.
    SELECT msehi zaehl nennr
      INTO TABLE it_unit_details
      FROM t006 FOR ALL ENTRIES IN it_unit_list
      WHERE msehi = it_unit_list-table_line.
    SORT it_unit_details BY unit.
  ENDIF.

  IF lt_main IS NOT INITIAL.
    "Get Old Material from table
*    SELECT old_material sap_material  INTO TABLE lt_bismt_db
*      FROM ymat_bismt_model FOR ALL ENTRIES IN lt_main
*      WHERE old_material = lt_main-bismt.
*    IF lt_bismt_db IS NOT INITIAL.
*      SORT lt_bismt_db .
*      DELETE ADJACENT DUPLICATES FROM lt_bismt_db.
*      SELECT matnr  werks FROM marc
*        INTO TABLE lt_matnr_plant
*        FOR ALL ENTRIES IN lt_bismt_db
*        WHERE matnr = lt_bismt_db-sap_material.
*      SORT lt_matnr_plant.
*      DELETE ADJACENT DUPLICATES FROM lt_matnr_plant.
*    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data .
  DATA lv_msg1 TYPE msgv1.
  DATA lv_msg2 TYPE msgv1.
  FIELD-SYMBOLS :  <fs_main> TYPE ty_main.
  LOOP AT lt_main ASSIGNING <fs_main>.
    " if old number is present in db, donot save that material
    READ TABLE lt_bismt_db INTO ts_bismt_db
      WITH KEY old_material = <fs_main>-bismt.
    IF sy-subrc = 0.
      <fs_main>-matnr = ts_bismt_db-sap_material.
      CONTINUE.     "=============>>>
    ENDIF.
  ENDLOOP.
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
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_LOG_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_log_path .

  IF p_log IS NOT INITIAL.
* Check if success log path is valid
    OPEN DATASET p_log FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc  <> 0.
      MESSAGE TEXT-l14 TYPE 'E'.
    ENDIF.
    CLOSE DATASET p_log.
  ENDIF.
ENDFORM.



*&---------------------------------------------------------------------*
*&  Include           ZBP_UPLOAD_PRG_FORMS
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialization .

  sscrfields-functxt_01 = TEXT-fc1.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FUNCTION_KEY_HANDLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_function_key_handler .


  CASE sy-ucomm.
    WHEN 'FC01'.
      PERFORM f_download_template.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_template .

  TYPES: BEGIN OF lty_excel_record,
*-------general data
           partner_cat     TYPE char30,    " Partner_Category
           vend_role       TYPE char30,    " Create_Vendor_Role
           fi_ven_role     TYPE char30,    " Create_FI_Vendor Role
           cust_role       TYPE char30,    " Create Customer Role
           fi_cust_role    TYPE char30,     " Create FI Customer Role
           title           TYPE char15,     " Title
           tatyp           TYPE char20,     " Account Grp
           bp_name_1       TYPE char20,    " BP Name 1
           bp_name_2       TYPE char20,    " BP Name 2
           langu           TYPE char30,     "Correspondence lang
           searchterm1     TYPE char20,   "Search Term 1
           searchterm2     TYPE char20,   "Search Term 2
           street4         TYPE char20, "Street 4
           street3         TYPE char20, "Street 3
           street5         TYPE char20, "Street 5
           street2         TYPE char20, "Street 2
           streethno       TYPE char30, "street /House number
           postalpo        TYPE char30, "Postal Code - PO Box
           zipcode         TYPE char20, " ZIP Code
           city            TYPE char20, "City
           region          TYPE char20, "Region
           countrycode     TYPE char20, "COUNTRY code
           telephone       TYPE char20,  "Telephone
           extension       TYPE char20,  "Extension
           mobilephone     TYPE char30, "MobilePhone "MobilePhone
           faxnumber       TYPE char30, "Faxnumber
           email           TYPE char30, "E-Mail Address
           vat_cat         TYPE char20, "   VAT Catergory
           vat_number      TYPE char20, "VAT Number
           title_ar        TYPE char20,     " Title
           bp_name_1_ar    TYPE char20,    " BP Name 1
           bp_name_2_ar    TYPE char20,    " BP Name 2
           searchterm1_ar  TYPE char20,   "Search Term 1
           street4_ar      TYPE char20, "Street 4
           street3_ar      TYPE char20, "Street 3
           street5_ar      TYPE char20, "Street 5
           street2_ar      TYPE char20, "Street 2
           streethno_ar    TYPE char30, "street /House number
           city_ar         TYPE char20, "City
*--------FI data
           cust_acc_grp_fi TYPE char20, "Account Group
           comp_code_fi    TYPE char20, "Company Code
           rec_acc_fi      TYPE char20,  "Recon Account
           sort_key_fi     TYPE char20,  "Sort key
           term_pay_fi     TYPE char20, "Terms of Payment
           trade_part_fi   TYPE char20, " Trading Partner
*------customer data
           sales_org_cus   TYPE char30, " Sales Organization
           dist_cha_cus    TYPE char30, "Distribution Channel
           division_cus    TYPE char20, "Division
           cont_pname_cus  TYPE char30, "Contact Person Name
           cont_pdept_cus  TYPE char30, "Contact Person Dept.
           cont_pfunc_cus  TYPE char30, "Contact Person Function
           sales_dist_cus  TYPE char20, "Sales District
           sales_off_cus   TYPE char20, "Sales Office
           sales_grp_cus   TYPE char20, "Sales Group
           cust_grp_cus    TYPE char20, "Customer Group
           funt_part_cus   TYPE char20, "Function Partner
           sal_repco_cus   TYPE char20, "SalesRep Code
           curr_cus        TYPE char20, "Currency
           price_grp_cus   TYPE char20, "Price Group
           rebate_cus      TYPE char20, "Rebate
           price_li_cus    TYPE char30, "Customer Price List
           price_pro_cus   TYPE char30, "Customer Pricing procedure
           stat_grp_cus    TYPE char30, "Customer Statistics Group
           del_plant_cus   TYPE char30, "Delivery Plant
           ship_cond_cus   TYPE char30, "Shipping Condition
           incoterm1_cus   TYPE char30, "Inco terms1
           incoterm2_cus   TYPE char30, "Inco terms2
           term_pay_cus    TYPE char30, "Terms of Payment
           acc_asigrp_cus  TYPE char30, "Account assignment Group
           out_tax_cus     TYPE char30, "Output Tax
*--------FI vendor data.........
           accgrp_ven      TYPE char20,  "VENDOR ACCOUNT GROUP
           comp_code_ven   TYPE char20,  "COMPANY CODE
           term_pay_ven    TYPE char20,   " Terms of Payment Key
           pay_method_ven  TYPE char30, "Payment Methods
           rec_acc_ven     TYPE char30, "  RECONCILATION ACCOUNT
           sort_key_ven    TYPE char20, "Sort key
           bank_coun_ven   TYPE char30, "VENDOR BANK COUNTRY
           bank_key_ven    TYPE char20, "BANK KEY
           bank_acc_ven    TYPE char30, "BANK ACCOUNT NUMBER
           acc_holname_ven TYPE char20, "Account Holder Name
           iban_ven        TYPE char20, "IBAN Number
           bank_ven        TYPE char20, "VENDOR BANK

*  *-----Vendor data
           pur_org_vend    TYPE char30, "PURCHASING ORGANIZATION
           po_curr_vend    TYPE char20, "PO CURRENCY
           tax_per_vend    TYPE char20, "Tax Percentage
           pay_term_vend   TYPE char20,  "Payment Terms
           schema_gp       TYPE char20, "Group for Calculation Schema (Supplier)
           bp_ext          TYPE char20,  "External BP
         END OF lty_excel_record.


*-----------------------------------------------------------------------
  DATA lwf_filename            TYPE string.
  DATA lwf_path                TYPE string.
  DATA lwf_fullpath            TYPE string.
  DATA lwf_user_action         TYPE i.
  DATA lint_data_tab           TYPE TABLE OF lty_excel_record.
  DATA lfs_data_tab            LIKE LINE OF lint_data_tab.


  lfs_data_tab-partner_cat    =  'Partner_Category'.
  lfs_data_tab-vend_role       = 'Create_Vendor_Role'.
  lfs_data_tab-fi_ven_role     =  'Create_FI_Vendor Role'.
  lfs_data_tab-cust_role       =   'Create Customer Role'.
  lfs_data_tab-fi_cust_role    =  'Create FI Customer Role'.
  lfs_data_tab-title           = 'Title'.
  lfs_data_tab-tatyp           = 'Account Grp'.
  lfs_data_tab-bp_name_1       = 'BP Name 1'.
  lfs_data_tab-bp_name_2       =   'BP Name 2'.
  lfs_data_tab-langu           =   'Correspondence lang'.
  lfs_data_tab-searchterm1     =  'Search Term 1'.
  lfs_data_tab-searchterm2     = 'Search Term 2'.
  lfs_data_tab-street4         = 'Street 4'.
  lfs_data_tab-street3         =  'Street 3'.
  lfs_data_tab-street5         = 'Street 5'.
  lfs_data_tab-street2         = 'Street 2'.
  lfs_data_tab-streethno       = 'Street /House number'.
  lfs_data_tab-postalpo        = 'Postal Code - PO Box'.
  lfs_data_tab-zipcode         = 'ZIP Code'.
  lfs_data_tab-city            = 'City'.
  lfs_data_tab-region          = 'Region'.
  lfs_data_tab-countrycode     = 'COUNTRY code'.
  lfs_data_tab-telephone       = 'Telephone'.
  lfs_data_tab-extension       = 'Extension'.
  lfs_data_tab-mobilephone    = 'MobilePhone'. "MobilePhone
  lfs_data_tab-faxnumber       = 'Faxnumber'.
  lfs_data_tab-email           = 'E-Mail'.
  lfs_data_tab-vat_cat         =  'VAT Catergory'.
  lfs_data_tab-vat_number      = 'VAT Number'.
  lfs_data_tab-title_ar        =    'Title AR'.
  lfs_data_tab-bp_name_1_ar    =    'BP Name 1 AR'.
  lfs_data_tab-bp_name_2_ar    =    'BP Name 2 AR'.
  lfs_data_tab-searchterm1_ar  =   'Search Term 1 AR'.
  lfs_data_tab-street4_ar      = 'Street 4 AR'.
  lfs_data_tab-street3_ar      = 'Street 3 AR'.
  lfs_data_tab-street5_ar      = 'Street 5 AR'.
  lfs_data_tab-street2_ar      = 'Street 2 AR'.
  lfs_data_tab-streethno_ar    = 'street /House number AR'.
  lfs_data_tab-city_ar         = 'City AR'.
*--------FI data
  lfs_data_tab-cust_acc_grp_fi = 'FI Account Group'.
  lfs_data_tab-comp_code_fi    = 'FI Company Code'.
  lfs_data_tab-rec_acc_fi      =  'FI Recon Account'.
  lfs_data_tab-sort_key_fi     =  'FI Sort key'.
  lfs_data_tab-term_pay_fi     = 'FI Terms of Payment'.
  lfs_data_tab-trade_part_fi   = 'FI Trading Partner'.
*------customer data
  lfs_data_tab-sales_org_cus   = 'Cust Sales Org.'.
  lfs_data_tab-dist_cha_cus    = 'Cust Dist. Channel'.
  lfs_data_tab-division_cus    = 'Cust Division'.
  lfs_data_tab-cont_pname_cus  = 'Cust Cont. Person Name'.
  lfs_data_tab-cont_pdept_cus  = 'Cust Cont. Per. Dept'.
  lfs_data_tab-cont_pfunc_cus  = 'Cust Cont. Per. Funct.'.
  lfs_data_tab-sales_dist_cus  = 'Cust Sales District'.
  lfs_data_tab-sales_off_cus   = 'Cust Sales Office'.
  lfs_data_tab-sales_grp_cus   = 'Cust Sales Group'.
  lfs_data_tab-cust_grp_cus    = 'Customer Group'.
  lfs_data_tab-funt_part_cus   = 'Cust Function Partner'.
  lfs_data_tab-sal_repco_cus   = 'Cust SalesRep Code'.
  lfs_data_tab-curr_cus       = 'Cust Currency'.
  lfs_data_tab-price_grp_cus   = 'Cust Price Group'.
  lfs_data_tab-rebate_cus      =  'Cust Rebate'.
  lfs_data_tab-price_li_cus    = 'Customer Price List'.
  lfs_data_tab-price_pro_cus   = 'Customer Pricing procedure'.
  lfs_data_tab-stat_grp_cus    = 'Customer Statistics Group'.
  lfs_data_tab-del_plant_cus   = 'Cust Delivery Plant'.
  lfs_data_tab-ship_cond_cus   = 'Cust Shipping Condition'.
  lfs_data_tab-incoterm1_cus   = 'Cust Inco terms1'.
  lfs_data_tab-incoterm2_cus   = 'Cust Inco terms2'.
  lfs_data_tab-term_pay_cus    = 'Cust Terms of Payment'.
  lfs_data_tab-acc_asigrp_cus  = 'Cust Account assig. Group'.
  lfs_data_tab-out_tax_cus     = 'Cust Output Tax'.
*--------FI vendor data.........
  lfs_data_tab-accgrp_ven      =  'VENDOR ACCOUNT GROUP'.
  lfs_data_tab-comp_code_ven   =  'Vendor COMPANY CODE'.
  lfs_data_tab-term_pay_ven    = 'Terms of Payment Key'.
  lfs_data_tab-pay_method_ven  = 'Vendor Payment Methods'.
  lfs_data_tab-rec_acc_ven     =  'Vendor RECONCILATION ACCOUNT'.
  lfs_data_tab-sort_key_ven    = 'Vendor Sort key'.
  lfs_data_tab-bank_coun_ven   =  'VENDOR BANK COUNTRY'.
  lfs_data_tab-bank_key_ven    = 'Vendor BANK KEY'.
  lfs_data_tab-bank_acc_ven    =  'Vendor BANK ACCOUNT NUMBER'.
  lfs_data_tab-acc_holname_ven = 'Account Holder Name'.
  lfs_data_tab-iban_ven        = 'Vendor IBAN Number'.
  lfs_data_tab-bank_ven        =  'VENDOR BANK'.

*  *-----Vendor data
  lfs_data_tab-pur_org_vend    =  'Vendor Purchase Organization'.
  lfs_data_tab-po_curr_vend    =  'VendorPO CURRENCY'.
  lfs_data_tab-tax_per_vend    =  'VendorTax Percentage'.
  lfs_data_tab-pay_term_vend   =  'VendorPayment Terms'.
  lfs_data_tab-schema_gp       = 'Schema Group(Supplier)'.
  lfs_data_tab-bp_ext          = 'External BP'.
  APPEND lfs_data_tab TO lint_data_tab.


  "***************************************
  "* get save file name and location
  "***************************************
  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      file_filter               = cl_gui_frontend_services=>filetype_excel
    CHANGING
      filename                  = lwf_filename
      path                      = lwf_path
      fullpath                  = lwf_fullpath
      user_action               = lwf_user_action
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
         ).
  IF sy-subrc <> 0 AND lwf_user_action <> 0.
    RETURN.
  ENDIF.



  "*******************************************
  "*
  "*******************************************
  cl_gui_frontend_services=>gui_download(
    EXPORTING
      filename                  = lwf_filename
      filetype                  = 'DAT'
    CHANGING
      data_tab                  = lint_data_tab
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
         ).
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_F4_FILE_BROWSER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_f4_file_browser .


************************************************************************
*                        BEGION
************************************************************************
  DATA file_table        TYPE filetable.
  DATA rc                TYPE i.
************************************************************************


  cl_gui_frontend_services=>file_open_dialog(
    CHANGING
      file_table              = file_table
      rc                      = rc
         ).
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF rc = 1.

    READ TABLE file_table ASSIGNING FIELD-SYMBOL(<fs_filename>) INDEX 1.
    IF sy-subrc = 0.
      p_file = <fs_filename>-filename.
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_BAL_CREATE_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bal_create_log .

************************************************************************
*                  BEGIN OF DECLARING LOCAL DATA
************************************************************************
*  DATA:
************************************************************************
* define some header data of this log
  fs_bal_log-extnumber  = sy-title.
  fs_bal_log-aldate     = sy-datum.
  fs_bal_log-altime     = sy-uzeit.
  fs_bal_log-aluser     = sy-uname.
  fs_bal_log-alprog     = sy-repid.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = fs_bal_log
    IMPORTING
      e_log_handle            = wf_bal_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
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

************************************************************************
*                        BEGION
************************************************************************
  DATA lwf_filename LIKE  rlgrap-filename.
  DATA intern      TYPE STANDARD TABLE OF alsmex_tabline.
  DATA: wf_row_number TYPE i,
        fs_record     LIKE LINE OF int_excel_data.
************************************************************************

  lwf_filename = p_file.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lwf_filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 88
      i_end_row               = 100000
    TABLES
      intern                  = intern
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2.

  IF sy-subrc = 0.


    LOOP AT intern ASSIGNING FIELD-SYMBOL(<fs_cell>).

      IF wf_row_number IS INITIAL.
        wf_row_number = <fs_cell>-row.
        CLEAR fs_record.
      ELSEIF <fs_cell>-row <> wf_row_number.
        APPEND fs_record TO int_excel_data.
        wf_row_number = <fs_cell>-row.
        CLEAR fs_record.
      ENDIF.

      CASE <fs_cell>-col.
        WHEN 1.
          fs_record-partner_cat = <fs_cell>-value.     "" Partner_Category
        WHEN 2.
          fs_record-vend_role = <fs_cell>-value.       " Create_Vendor_Role
        WHEN 3.
          fs_record-fi_ven_role = <fs_cell>-value.     "" Create_FI_Vendor Role
        WHEN 4.
          fs_record-cust_role = <fs_cell>-value.       " Create_cust Role
        WHEN 5.
          fs_record-fi_cust_role = <fs_cell>-value.     " Create_FI_cust Role
        WHEN 6.
          fs_record-title = <fs_cell>-value.    "title
        WHEN 7.
          fs_record-tatyp = <fs_cell>-value.     "Account Grp
        WHEN 8.
          fs_record-bp_name_1 = <fs_cell>-value.  ""BP Name 1
        WHEN 9.
          fs_record-bp_name_2 = <fs_cell>-value.  "BP Name 2
        WHEN 10.
          fs_record-langu = <fs_cell>-value.   "Correspondence lang
        WHEN 11.
          fs_record-searchterm1 = <fs_cell>-value. "Search Term 1
        WHEN 12.

          fs_record-searchterm2 = <fs_cell>-value.   "Search Term 2
        WHEN 13.
          fs_record-street4  = <fs_cell>-value.      "street4
        WHEN 14.
          fs_record-street3 = <fs_cell>-value.       "street3
        WHEN 15.
          fs_record-street5 = <fs_cell>-value.     "street5
        WHEN 16.
          fs_record-street2 = <fs_cell>-value.     "street2
        WHEN 17.
          fs_record-streethno = <fs_cell>-value.   "streethno

        WHEN 18.
          fs_record-postalpo = <fs_cell>-value.      "Postal Code - PO Box

        WHEN 19.
          fs_record-zipcode = <fs_cell>-value.        "zipcode
        WHEN 20.
          fs_record-city = <fs_cell>-value.           "city
        WHEN 21.
          fs_record-region = <fs_cell>-value.    "region
        WHEN 22.
          fs_record-countrycode = <fs_cell>-value.    "countrycode
        WHEN 23.
          fs_record-telephone = <fs_cell>-value.      "telephone
        WHEN 24.
          fs_record-extension = <fs_cell>-value.      "extension
        WHEN 25.
          fs_record-mobilephone = <fs_cell>-value.   "mobilephone
        WHEN 26.
          fs_record-faxnumber = <fs_cell>-value.     "faxnumber
        WHEN 27.
          fs_record-email = <fs_cell>-value.         "email
        WHEN 28.
          fs_record-vat_cat = <fs_cell>-value.       "vat_cat
        WHEN 29.
          fs_record-vat_number = <fs_cell>-value.   "vat_number
        WHEN 30.
          fs_record-title_ar = <fs_cell>-value.
        WHEN 31.
          fs_record-bp_name_1_ar = <fs_cell>-value.
        WHEN 32.
          fs_record-bp_name_2_ar = <fs_cell>-value.
        WHEN 33.
          fs_record-searchterm1_ar  = <fs_cell>-value.
        WHEN 34.
          fs_record-street4_ar = <fs_cell>-value.
        WHEN 35.
          fs_record-street3_ar = <fs_cell>-value.

        WHEN 36.
          fs_record-street5_ar = <fs_cell>-value.
        WHEN 37.
          fs_record-street2_ar = <fs_cell>-value.
        WHEN 38.
          fs_record-streethno_ar = <fs_cell>-value.
        WHEN 39.
          fs_record-city_ar = <fs_cell>-value.
        WHEN 40.
          fs_record-cust_acc_grp_fi = <fs_cell>-value.

        WHEN 41.
          fs_record-comp_code_fi = <fs_cell>-value.
        WHEN 42.
          fs_record-rec_acc_fi = <fs_cell>-value.
        WHEN 43.
          fs_record-sort_key_fi = <fs_cell>-value.
        WHEN 44.
          fs_record-term_pay_fi = <fs_cell>-value.
        WHEN 45.
          fs_record-trade_part_fi = <fs_cell>-value.
        WHEN 46.
          fs_record-sales_org_cus = <fs_cell>-value.
        WHEN 47.
          fs_record-dist_cha_cus = <fs_cell>-value.
        WHEN 48.
          fs_record-division_cus = <fs_cell>-value.
        WHEN 49.
          fs_record-cont_pname_cus = <fs_cell>-value.
        WHEN 50.
          fs_record-cont_pdept_cus = <fs_cell>-value.
        WHEN 51.
          fs_record-cont_pfunc_cus = <fs_cell>-value.
        WHEN 52.
          fs_record-sales_dist_cus = <fs_cell>-value.
        WHEN 53.
          fs_record-sales_off_cus = <fs_cell>-value.
        WHEN 54.
          fs_record-sales_grp_cus = <fs_cell>-value.
        WHEN 55.
          fs_record-cust_grp_cus = <fs_cell>-value.
        WHEN 56.
          fs_record-funt_part_cus = <fs_cell>-value.
        WHEN 57.
          fs_record-sal_repco_cus = <fs_cell>-value.
        WHEN 58.
          fs_record-curr_cus = <fs_cell>-value.
        WHEN 59.
          fs_record-price_grp_cus = <fs_cell>-value.
        WHEN 60.
          fs_record-rebate_cus  = <fs_cell>-value.
        WHEN 61.
          fs_record-price_li_cus = <fs_cell>-value.
        WHEN 62.
          fs_record-price_pro_cus = <fs_cell>-value.
        WHEN 63.
          fs_record-stat_grp_cus = <fs_cell>-value.
        WHEN 64.
          fs_record-del_plant_cus = <fs_cell>-value.
        WHEN 65.
          fs_record-ship_cond_cus = <fs_cell>-value.
        WHEN 66.
          fs_record-incoterm1_cus = <fs_cell>-value.
        WHEN 67.
          fs_record-incoterm2_cus = <fs_cell>-value.
        WHEN 68.
          fs_record-term_pay_cus = <fs_cell>-value.
        WHEN 69.
          fs_record-acc_asigrp_cus = <fs_cell>-value.
        WHEN 70.
          fs_record-out_tax_cus = <fs_cell>-value.
        WHEN 71.
          fs_record-accgrp_ven = <fs_cell>-value.
        WHEN 72.
          fs_record-comp_code_ven = <fs_cell>-value.
        WHEN 73.
          fs_record-term_pay_ven = <fs_cell>-value.
        WHEN 74.
          fs_record-pay_method_ven = <fs_cell>-value.
        WHEN 75.
          fs_record-rec_acc_ven = <fs_cell>-value.

        WHEN 76.
          fs_record-sort_key_ven = <fs_cell>-value.
        WHEN 77.
          fs_record-bank_coun_ven = <fs_cell>-value.
        WHEN 78.
          fs_record-bank_key_ven  = <fs_cell>-value.
        WHEN 79.
          fs_record-bank_acc_ven  = <fs_cell>-value.
        WHEN 80.
          fs_record-acc_holname_ven = <fs_cell>-value.
        WHEN 81.
          fs_record-iban_ven = <fs_cell>-value.

        WHEN 82.
          fs_record-bank_ven = <fs_cell>-value.
        WHEN 83.
          fs_record-pur_org_vend = <fs_cell>-value.
        WHEN 84.
          fs_record-po_curr_vend = <fs_cell>-value.
        WHEN 85.
          fs_record-tax_per_vend = <fs_cell>-value.
        WHEN 86.
          fs_record-pay_term_vend = <fs_cell>-value.
        WHEN 87.
          fs_record-schema_gp     = <fs_cell>-value.

        WHEN 88.
          fs_record-bp_ext    = <fs_cell>-value.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

    IF fs_record IS NOT INITIAL.
      APPEND fs_record TO int_excel_data.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BAL_ADD_MESSAGE_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BAPIRETURN  text
*----------------------------------------------------------------------*
FORM f_bal_add_message_log  USING p_msg TYPE bal_s_msg.
  "***********************************************************
  "*            BEGIN OF DECLARING LOCAL DATA
  "***********************************************************
  "CONSTANTS:
  "***********************************************************
  "DATA:
  "      lfs_message       TYPE bal_s_msg.
  "***********************************************************
  "FIELD-SYMBOLS:
  "************ END OF DECLARING LOCAL DATA ******************

*----------------- Local Internal Table declarations ------------------*
  DATA : lt_log_handle     TYPE bal_t_logh,
         lt_new_lognumbers TYPE bal_t_lgnm.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_s_msg       = p_msg
      i_log_handle  = wf_bal_log_handle
    EXCEPTIONS
      log_not_found = 0
      OTHERS        = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



**********************************************************************
*                    Save SLG Log via Handle                         *
**********************************************************************

  APPEND wf_bal_log_handle TO lt_log_handle.
  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_t_log_handle   = lt_log_handle
    IMPORTING
      e_new_lognumbers = lt_new_lognumbers
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BAL_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bal_display_log.
************************************************************************
*                  BEGIN OF DECLARING LOCAL DATA
************************************************************************
  DATA:
        lfs_s_display_profile TYPE bal_s_prof.
************************************************************************

  CALL FUNCTION 'BAL_DSP_PROFILE_DETLEVEL_GET'
    IMPORTING
      e_s_display_profile = lfs_s_display_profile.

  "* set report to allow saving of variants
  lfs_s_display_profile-disvariant-report = sy-repid.
  lfs_s_display_profile-tree_ontop = abap_false.
  lfs_s_display_profile-tree_adjst = abap_true.
  lfs_s_display_profile-root_text = 'File Data'.


  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_s_display_profile = lfs_s_display_profile
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_bp .


  "***********************************************************
  DATA:
        lfs_message       TYPE bal_s_msg.

  DATA: l_eflag.

  CLEAR: l_eflag.
  LOOP AT int_excel_data INTO fs_exce_row .

    CLEAR: gv_bpartner.

    IF fs_exce_row-cust_role IS NOT INITIAL AND fs_exce_row-fi_cust_role IS INITIAL.

      lfs_message-msgty = 'E'.
      lfs_message-msgid = '00'.
      lfs_message-msgno = '001'.
      lfs_message-msgv1 = 'Customer role flag passed without FI Customer flag' .
      lfs_message-msgv2 =  'please correct the record '.
      lfs_message-msgv3 = fs_exce_row-searchterm2.
      lfs_message-detlevel  = 2.
      PERFORM f_bal_add_message_log USING lfs_message.
      l_eflag = 'X'.
      CONTINUE.
    ENDIF.

    IF fs_exce_row-vend_role IS NOT INITIAL AND fs_exce_row-fi_ven_role IS INITIAL.

      lfs_message-msgty = 'E'.
      lfs_message-msgid = '00'.
      lfs_message-msgno = '001'.
      lfs_message-msgv1 = 'Vendor role flag passed with out FI Vendor flag' . .
      lfs_message-msgv2 = 'please correct the record '.
      lfs_message-msgv3 = fs_exce_row-searchterm2.
      lfs_message-detlevel  = 2.
      PERFORM f_bal_add_message_log USING lfs_message.
      l_eflag = 'X'.
      CONTINUE.

    ENDIF.

*--------check the BP exist or not...ll
    IF   l_eflag IS INITIAL.
      CLEAR: gv_bp_flag.
      PERFORM check_bp_exist USING fs_exce_row-searchterm2.

      IF gv_bp_flag  IS INITIAL.

        PERFORM create_bp_using_gen_data USING fs_exce_row.    "create BP with generadata

      ENDIF.
*-----to unlock BP
      IF gv_bpartner IS NOT INITIAL.
        DATA lwf_iv_partner          TYPE bu_partner.
        DATA lit_et_return           TYPE STANDARD TABLE OF bapiret2.

        lwf_iv_partner  = gv_bpartner.

        CALL FUNCTION 'BUPA_DEQUEUE'
          EXPORTING
            iv_partner = lwf_iv_partner
          TABLES
            et_return  = lit_et_return.

        IF sy-subrc <> 0.

        ENDIF.
      ENDIF.

      IF gv_bpartner IS NOT INITIAL.  "BP created...or exists

*----create customer ......
        IF fs_exce_row-cust_role IS NOT INITIAL OR fs_exce_row-fi_cust_role  IS NOT INITIAL.  "customer role and FI role
*
          PERFORM create_customer_and_roles USING fs_exce_row.

        ENDIF.

*---create vendor.....
        IF fs_exce_row-vend_role IS NOT INITIAL OR fs_exce_row-fi_ven_role  IS NOT INITIAL.  "vendor role and FI role

          PERFORM create_vend_and_roles USING fs_exce_row.

        ENDIF.


      ENDIF.


    ENDIF.
    CLEAR fs_exce_row.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_BP_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FS_EXCE_ROW_SEARCHTERM2  text
*----------------------------------------------------------------------*
FORM check_bp_exist  USING    p_searchterm2 TYPE  bu_sort2.

*-- FM to check BP exist or not
  CALL FUNCTION 'ZBP_CHECK'
    EXPORTING
      bu_sort2 = p_searchterm2
    IMPORTING
      flag     = gv_bp_flag
      bpartner = gv_bpartner.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_BP_USING_GEN_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FS_EXCE_ROW  text
*----------------------------------------------------------------------*
FORM create_bp_using_gen_data  USING    p_fs_exce_row LIKE LINE OF int_excel_data.

  DATA:  gs_return             TYPE bapiret2.
  DATA: ls_head      TYPE bapibus1006_head,
        ls_central   TYPE bapibus1006_central,
        ls_person    TYPE bapibus1006_central_person,
        ls_organ     TYPE bapibus1006_central_organ,
        ls_group     TYPE bapibus1006_central_group,
        ls_address   TYPE bapibus1006_address,
        lt_tel       TYPE STANDARD TABLE OF bapiadtel,
        ls_tel       LIKE LINE OF lt_tel,
        lt_fax       TYPE STANDARD TABLE OF bapiadfax,
        ls_fax       LIKE LINE OF lt_fax,
        lt_email     TYPE STANDARD TABLE OF bapiadsmtp,
        ls_email     LIKE LINE OF lt_email,

        ls_central_x TYPE bapibus1006_central_x,
        ls_person_x  TYPE bapibus1006_central_person_x,
        ls_organ_x   TYPE bapibus1006_central_organ_x.
  DATA: gt_return     TYPE STANDARD TABLE OF bapiret2,
        lint_messages TYPE bapiret2_t.



  CLEAR: ls_head , ls_head , ls_person , ls_organ,ls_group, ls_address,ls_tel,lt_tel ,lt_fax,ls_fax,lt_email,ls_email,ls_msg,ls_central_x,
         ls_person_x,ls_organ_x,gt_return, lint_messages .



  CLEAR: gv_bpartner.

  MOVE-CORRESPONDING p_fs_exce_row TO ls_bpdetails.

*----call custom function module to create BP and its address and tax codes
  CALL FUNCTION 'ZBP_CREATE'
    EXPORTING
      bpdetails = ls_bpdetails
    IMPORTING
      bpartner  = gv_bpartner
    TABLES
      return    = gt_return.

  LOOP AT gt_return
    INTO gs_return.
    CLEAR ls_msg.
    ls_msg-msgty = gs_return-type.
    ls_msg-msgid = gs_return-id.
    ls_msg-msgno = gs_return-number.
    ls_msg-msgv1 = gs_return-message_v1.
    ls_msg-msgv2 = gv_bpartner.
    ls_msg-msgv3 = gs_err-msg.
    ls_msg-detlevel = 2.
    PERFORM f_bal_add_message_log USING ls_msg.
  ENDLOOP.

*read table gt_return
  IF gt_return IS INITIAL AND gv_bpartner IS INITIAL.
    CLEAR ls_msg.
    ls_msg-msgty = 'E'.
    ls_msg-msgid = '00'.
    ls_msg-msgno = '398'.
    ls_msg-msgv1 = 'Error in BP creation'.
    ls_msg-msgv2 = ls_bpdetails-searchterm2.
    ls_msg-detlevel = 2.
    PERFORM f_bal_add_message_log USING ls_msg.
    CLEAR gs_return.
  ENDIF.


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_BAL_ADD_MESSAGE_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BAPIRETURN  text
*----------------------------------------------------------------------*
FORM f_bal_add_message_log_t  USING p_msg TYPE bapiret2_t
                                    p_msg_level TYPE i.
  "***********************************************************
  "*            BEGIN OF DECLARING LOCAL DATA
  "***********************************************************
  "CONSTANTS:
  "***********************************************************
  DATA:
        lfs_message       TYPE bal_s_msg.
  "***********************************************************
  "FIELD-SYMBOLS:
  "************ END OF DECLARING LOCAL DATA ******************


  LOOP AT p_msg ASSIGNING FIELD-SYMBOL(<fs_msg>) .

    lfs_message-msgty = <fs_msg>-type.
    lfs_message-msgid = <fs_msg>-id.
    lfs_message-msgno = <fs_msg>-number.
    lfs_message-msgv1 = <fs_msg>-message_v1.
    lfs_message-msgv2 = <fs_msg>-message_v2.
    lfs_message-msgv3 = <fs_msg>-message_v3.
    lfs_message-msgv4 = <fs_msg>-message_v4.
    lfs_message-detlevel = p_msg_level.

    PERFORM f_bal_add_message_log USING lfs_message.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_BAPI_ADD_ARABIC_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_BPARTNER  text
*----------------------------------------------------------------------*
FORM f_bapi_add_arabic_address  USING    p_gv_bpartner LIKE gv_bpartner .




ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DATAX_FLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FS_VENDOR_CENTRAL_DATA_ADDRE  text
*      <--P_P_FS_VENDOR_CENTRAL_DATA_ADDRE  text
*----------------------------------------------------------------------*
FORM f_update_datax_flag  USING    p_data
                          CHANGING p_datax.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_CUSTOMER_AND_ROLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FS_EXCE_ROW  text
*----------------------------------------------------------------------*
FORM create_customer_and_roles  USING    p_fs_exce_row LIKE LINE OF int_excel_data..

  DATA: ls_custdata TYPE zcust_create_struct,
        lt_return   TYPE STANDARD TABLE OF bapiret2,
        lw_return   LIKE LINE OF lt_return.


  MOVE-CORRESPONDING  p_fs_exce_row TO ls_custdata.



  CALL FUNCTION 'ZCUST_CREATE'
    EXPORTING
      cust_details = ls_custdata
      bpartner     = gv_bpartner
    TABLES
      return       = lt_return.


  LOOP AT lt_return INTO lw_return.
    CLEAR ls_msg.
    ls_msg-msgty = lw_return-type.
    ls_msg-msgid = lw_return-id.
    ls_msg-msgno = lw_return-number.
    ls_msg-msgv1 = lw_return-message_v1.
    ls_msg-msgv2 = lw_return-message_v2.
    ls_msg-msgv3 = lw_return-message_v3.
    ls_msg-detlevel = 2.
    PERFORM f_bal_add_message_log USING ls_msg.

  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_VEND_AND_ROLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FS_EXCE_ROW  text
*----------------------------------------------------------------------*
FORM create_vend_and_roles  USING    p_fs_exce_row.

  DATA: ls_venddata TYPE zbp_vendor_struct,
        lt_return   TYPE STANDARD TABLE OF bapiret2,
        lw_return   LIKE LINE OF lt_return.


  MOVE-CORRESPONDING  p_fs_exce_row TO ls_venddata.



  CALL FUNCTION 'ZVEND_CREATE'
    EXPORTING
      vend_details = ls_venddata
      bpartner     = gv_bpartner
    TABLES
      return       = lt_return.


  LOOP AT lt_return INTO lw_return.
    CLEAR ls_msg.
    ls_msg-msgty = lw_return-type.
    ls_msg-msgid = lw_return-id.
    ls_msg-msgno = lw_return-number.
    ls_msg-msgv1 = lw_return-message_v1.
    ls_msg-msgv2 = lw_return-message_v2.
    ls_msg-msgv3 = lw_return-message_v3.
    ls_msg-detlevel = 2.
    PERFORM f_bal_add_message_log USING ls_msg.

  ENDLOOP.



ENDFORM.


*&---------------------------------------------------------------------*
*&  Include           ZBP_UPLOAD_PRG_DEC
*&---------------------------------------------------------------------*

TABLES: sscrfields.
TYPES: BEGIN OF ty_excel_record,
*-------general data
         partner_cat     TYPE char1,    " Partner_Category
         vend_role       TYPE char1,    " Create_Vendor_Role
         fi_ven_role     TYPE char1,    " Create_FI_Vendor Role
         cust_role       TYPE char1,    " Create Customer Role
         fi_cust_role    TYPE char1,     " Create FI Customer Role
         title           TYPE char15,     " Title
         tatyp           TYPE char4,     " Account Grp
         bp_name_1       TYPE char50,    " BP Name 1
         bp_name_2       TYPE char50,    " BP Name 2
         langu           TYPE char2,     "Correspondence lang
         searchterm1     TYPE char50,   "Search Term 1
         searchterm2     TYPE char20,   "Search Term 2
         street4         TYPE char50, "Street 4
         street3         TYPE char50, "Street 3
         street5         TYPE char50, "Street 5
         street2         TYPE char50, "Street 2
         streethno       TYPE char50, "street /House number
         postalpo        TYPE char20, "Postal Code - PO Box
         zipcode         TYPE char10, " ZIP Code
         city            TYPE char20, "City
         region          TYPE char20, "Region
         countrycode     TYPE char20, "COUNTRY code
         telephone       TYPE char20,  "Telephone
         extension       TYPE char20,  "Extension
         mobilephone     TYPE char30, "MobilePhone "MobilePhone
         faxnumber       TYPE char30, "Faxnumber
         email           TYPE char50, "E-Mail Address
         vat_cat         TYPE char20, "   VAT Catergory
         vat_number      TYPE char30, "VAT Number
         title_ar        TYPE char15,     " Title
         bp_name_1_ar    TYPE char50,    " BP Name 1
         bp_name_2_ar    TYPE char50,    " BP Name 2
         searchterm1_ar  TYPE char50,   "Search Term 1
         street4_ar      TYPE char50, "Street 4
         street3_ar      TYPE char50, "Street 3
         street5_ar      TYPE char50, "Street 5
         street2_ar      TYPE char50, "Street 2
         streethno_ar    TYPE char50, "street /House number
         city_ar         TYPE char20, "City
*--------FI data
         cust_acc_grp_fi TYPE char10, "Account Group
         comp_code_fi    TYPE char10, "Company Code
         rec_acc_fi      TYPE char10,  "Recon Account
         sort_key_fi     TYPE char10,  "Sort key
         term_pay_fi     TYPE char10, "Terms of Payment
         trade_part_fi   TYPE char10, " Trading Partner
*------customer data
         sales_org_cus   TYPE char10, " Sales Organization
         dist_cha_cus    TYPE char10, "Distribution Channel
         division_cus    TYPE char10, "Division
         cont_pname_cus  TYPE char50, "Contact Person Name
         cont_pdept_cus  TYPE char50, "Contact Person Dept.
         cont_pfunc_cus  TYPE char50, "Contact Person Function
         sales_dist_cus  TYPE char20, "Sales District
         sales_off_cus   TYPE char10, "Sales Office
         sales_grp_cus   TYPE char10, "Sales Group
         cust_grp_cus    TYPE char10, "Customer Group
         funt_part_cus   TYPE char30, "Function Partner
         sal_repco_cus   TYPE char20, "SalesRep Code
         curr_cus        TYPE char10, "Currency
         price_grp_cus   TYPE char10, "Price Group
         rebate_cus      TYPE char20, "Rebate
         price_li_cus    TYPE char20, "Customer Price List
         price_pro_cus   TYPE char10, "Customer Pricing procedure
         stat_grp_cus    TYPE char10, "Customer Statistics Group
         del_plant_cus   TYPE char10, "Delivery Plant
         ship_cond_cus   TYPE char10, "Shipping Condition
         incoterm1_cus   TYPE char10, "Inco terms1
         incoterm2_cus   TYPE char10, "Inco terms2
         term_pay_cus    TYPE char10, "Terms of Payment
         acc_asigrp_cus  TYPE char10, "Account assignment Group
         out_tax_cus     TYPE char10, "Output Tax
*--------FI vendor data.........
         accgrp_ven      TYPE char10,  "VENDOR ACCOUNT GROUP
         comp_code_ven   TYPE char10,  "COMPANY CODE
         term_pay_ven    TYPE char10,   " Terms of Payment Key
         pay_method_ven  TYPE char10, "Payment Methods
         rec_acc_ven     TYPE char20, "  RECONCILATION ACCOUNT
         sort_key_ven    TYPE char10, "Sort key
         bank_coun_ven   TYPE char30, "VENDOR BANK COUNTRY
         bank_key_ven    TYPE char20, "BANK KEY
         bank_acc_ven    TYPE char30, "BANK ACCOUNT NUMBER
         acc_holname_ven TYPE char50, "Account Holder Name
         iban_ven        TYPE char50, "IBAN Number
         bank_ven        TYPE char50, "VENDOR BANK

*  *-----Vendor data
         pur_org_vend    TYPE char10, "PURCHASING ORGANIZATION
         po_curr_vend    TYPE char10, "PO CURRENCY
         tax_per_vend    TYPE char10, "Tax Percentage
         pay_term_vend   TYPE char10,  "Payment Terms
         schema_gp       type char2,   "schema group ( supplier)
         BP_EXT          type char20,  " External BP

       END OF ty_excel_record.

*----------------------------------------------------------------------*
*      I N T E R N A L   T A B L E    D E C L A R A T I O N            *
*----------------------------------------------------------------------*
DATA:
     int_excel_data  TYPE TABLE OF ty_excel_record.
 data:       ls_msg       TYPE bal_s_msg.
DATA: lv_error.
TYPES: BEGIN OF gty_err.
    INCLUDE TYPE ty_excel_record.

TYPES: msg TYPE string,
       END OF gty_err.

DATA:      gs_err                TYPE gty_err.
*----------------------------------------------------------------------*
*      W O R K   A R E A    D E C L A R A T I O N
*----------------------------------------------------------------------*
DATA:
  fs_exce_row       LIKE LINE OF int_excel_data,
  fs_return         TYPE bapiret2,
  "--------------------------
*  fs_material_master_data TYPE ty_material_master_data,
  "--------------------------
  wf_bal_log_handle TYPE balloghndl,   "Application Log: Log Handle
  fs_bal_log        TYPE bal_s_log.    "Log header data .

DATA: gv_bp_flag.

DATA: gv_bpartner TYPE bapibus1006_head-bpartner.
data: ls_BPDETAILS type ZBP_CREATE_STRUCT.
*----------------------------------------------------------------------*
*                       C O N S T A N T S                              *
*----------------------------------------------------------------------*
FIELD-SYMBOLS:
 <fs_excel_row>     LIKE LINE OF int_excel_data.
*----------------------------------------------------------------------*
*                       D E F I N E                                    *
*----------------------------------------------------------------------*
DEFINE conversion_alpha_input.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = &1
            IMPORTING
              output = &2.

END-OF-DEFINITION.

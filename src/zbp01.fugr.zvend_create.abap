FUNCTION zvend_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VEND_DETAILS) TYPE  ZBP_VENDOR_STRUCT
*"     VALUE(BPARTNER) TYPE  BU_PARTNER
*"  TABLES
*"      RETURN TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  "***********************************************************
  "*            BEGIN OF DECLARING LOCAL DATA
  "***********************************************************
  CONSTANTS:
     lc_create_update      TYPE cmd_ei_object_task VALUE 'M'.

  DATA:
    lint_messages TYPE bapiret2_t,
    lfs_message   LIKE LINE OF lint_messages.
  DATA:
    lfs_master_data       TYPE vmds_ei_main,
    lint_vendors          LIKE lfs_master_data-vendors,
    lfs_vendor            LIKE LINE OF lint_vendors,
    lfs_message_correct   TYPE cvis_message,
    lfs_message_defective TYPE cvis_message,
    ls_msg                TYPE bal_s_msg.
  "***********************************************************
  FIELD-SYMBOLS:
    <lfs_message>         LIKE LINE OF  lfs_message_correct-messages.
  DATA: l_fs_vendor  TYPE vmds_ei_extern.

  DATA:
    lfs_company_data       LIKE LINE OF l_fs_vendor-company_data-company,
    lfs_purchasing         LIKE LINE OF l_fs_vendor-purchasing_data-purchasing,
    lfs_function           LIKE LINE OF lfs_purchasing-functions-functions,
    lfs_bankdetail         LIKE LINE OF l_fs_vendor-central_data-bankdetail-bankdetails,
    lwg_update_center_data TYPE abap_bool , "ALUE abap_true,
    lwf_lifnr              TYPE lifnr.

  macro_alpha_input bpartner bpartner.

  SELECT SINGLE lifnr INTO lwf_lifnr FROM lfa1 WHERE lifnr = bpartner.
  IF sy-subrc <> 0.
    lwg_update_center_data = abap_true.
  ENDIF.

  "*************************************
  "*set header info
  "*************************************
  l_fs_vendor-header-object_instance-lifnr = bpartner.
  l_fs_vendor-header-object_task = lc_create_update.


  "*************************************
  "set Ext. Interface: Company Code Data
  "*************************************
  CLEAR lfs_company_data.

  "set company code
  lfs_company_data-task = lc_create_update.
  lfs_company_data-data_key-bukrs = vend_details-comp_code_ven.



  lfs_company_data-data-akont = vend_details-rec_acc_ven.   "RECONCILATION ACCOUNT
  lfs_company_data-data-zwels = vend_details-pay_method_ven.   "Payment Methods
  lfs_company_data-data-zterm = vend_details-term_pay_ven.   "Payment Methods

*  lfs_company_data-data-sperr           = VEND_DETAILS-.  "Posting block for company code
*  lfs_company_data-data-loevm           = VEND_DETAILS-.  "Deletion Flag for Master Record (Company Code Level)
  lfs_company_data-data-zuawa           = vend_details-sort_key_ven.  "Key for sorting according to assignment numbers
  lfs_company_data-data-akont           = vend_details-rec_acc_ven.  "Reconciliation Account in General Ledger
*  lfs_company_data-data-begru           = VEND_DETAILS-.  "Authorization Group
*  lfs_company_data-data-vzskz           = VEND_DETAILS-.  "Interest calculation indicator
  lfs_company_data-data-zwels           = vend_details-pay_method_ven.  "List of Respected Payment Methods
*  lfs_company_data-data-xverr           = VEND_DETAILS-.  "Indicator: Clearing between customer and vendor?
*  lfs_company_data-data-zahls           = VEND_DETAILS-.  "Block Key for Payment
  lfs_company_data-data-zterm           = vend_details-term_pay_ven.  "Terms of Payment Key
*  lfs_company_data-data-eikto           = VEND_DETAILS-.  "Our account number with the vendor
*  lfs_company_data-data-zsabe           = VEND_DETAILS-.  "Clerk at vendor
*  lfs_company_data-data-kverm           = VEND_DETAILS-.  "Memo
*  lfs_company_data-data-fdgrv           = VEND_DETAILS-.  "Planning group
*  lfs_company_data-data-busab           = VEND_DETAILS-.  "Accounting clerk
*  lfs_company_data-data-lnrze           = VEND_DETAILS-.  "Head office account number
*  lfs_company_data-data-lnrzb           = VEND_DETAILS-.  "Account number of the alternative payee
*  lfs_company_data-data-zindt           = VEND_DETAILS-.  "Key Date of Last Interest Calculation
*  lfs_company_data-data-zinrt           = VEND_DETAILS-.  "Interest Calculation Frequency in Months
*  lfs_company_data-data-datlz           = VEND_DETAILS-.  "Date of the last interest calculation run
*  lfs_company_data-data-xdezv           = VEND_DETAILS-.  "Indicator: Local processing?
*  lfs_company_data-data-webtr           = VEND_DETAILS-.  "Bill of exchange limit (in local currency)
*  lfs_company_data-data-kultg           = VEND_DETAILS-.  "Probable time until check is paid
*  lfs_company_data-data-reprf           = VEND_DETAILS-.  "Check Flag for Double Invoices or Credit Memos
*  lfs_company_data-data-togru           = VEND_DETAILS-.  "Tolerance group for the business partner/G/L account
*  lfs_company_data-data-hbkid           = VEND_DETAILS-.  "Short key for a house bank
*  lfs_company_data-data-xpore           = VEND_DETAILS-.  "Indicator: Pay all items separately ?
*  lfs_company_data-data-qsznr           = VEND_DETAILS-.  "Certificate Number of the Withholding Tax Exemption
*  lfs_company_data-data-qszdt           = VEND_DETAILS-.  "Validity Date for Withholding Tax Exemption Certificate
*  lfs_company_data-data-qsskz           = VEND_DETAILS-.  "Withholding Tax Code
*  lfs_company_data-data-blnkz           = VEND_DETAILS-.  "Subsidy Indicator for Determining the Reduction Rates
*  lfs_company_data-data-mindk           = VEND_DETAILS-.  "Minority Indicators
*  lfs_company_data-data-altkn           = VEND_DETAILS-.  "Previous Master Record Number
*  lfs_company_data-data-zgrup           = VEND_DETAILS-.  "Key for Payment Grouping
*  lfs_company_data-data-mgrup           = VEND_DETAILS-.  "Key for dunning notice grouping
*  lfs_company_data-data-uzawe           = VEND_DETAILS-.  "Payment method supplement
*  lfs_company_data-data-qsrec           = VEND_DETAILS-.  "Vendor Recipient Type
*  lfs_company_data-data-qsbgr           = VEND_DETAILS-.  "Authority for Exemption from Withholding Tax
*  lfs_company_data-data-qland           = VEND_DETAILS-.  "Withholding Tax Country Key
*  lfs_company_data-data-xedip           = VEND_DETAILS-.  "Indicator: Send Payment Advices by EDI
*  lfs_company_data-data-frgrp           = VEND_DETAILS-.  "Release Approval Group
*  lfs_company_data-data-tlfxs           = VEND_DETAILS-.  "Accounting clerk's fax number at the customer/vendor
*  lfs_company_data-data-intad           = VEND_DETAILS-.  "Internet address of partner company clerk
*  lfs_company_data-data-guzte           = VEND_DETAILS-.  "Payment Terms Key for Credit Memos
*  lfs_company_data-data-gricd           = VEND_DETAILS-.  "Activity Code for Gross Income Tax
*  lfs_company_data-data-gridt           = VEND_DETAILS-.  "Distribution Type for Employment Tax
*  lfs_company_data-data-xausz           = VEND_DETAILS-.  "Indicator for periodic account statements
*  lfs_company_data-data-cerdt           = VEND_DETAILS-.  "Certification date
*  lfs_company_data-data-togrr           = VEND_DETAILS-.  "Tolerance group; Invoice Verification
*  lfs_company_data-data-pernr           = VEND_DETAILS-.  "Personnel Number
*  lfs_company_data-data-nodel           = VEND_DETAILS-.  "Deletion bock for master record (company code level)
*  lfs_company_data-data-tlfns           = VEND_DETAILS-.  "Accounting clerk's telephone number at business partner
*  lfs_company_data-data-prepay_relevant  = VEND_DETAILS-.  "Prepayment Relevance (Vendor Master)
*  lfs_company_data-data-assign_test      = VEND_DETAILS-.  "Assignment Test Group
*  lfs_company_data-data-cvp_xblck_b      = VEND_DETAILS-.  "Business Purpose Completed Flag
*  lfs_company_data-data-ciiucode        = VEND_DETAILS-.  "Main economic activity

  macro_alpha_input: lfs_company_data-data-akont lfs_company_data-data-akont,
       lfs_company_data-data-zuawa lfs_company_data-data-zuawa,
                     lfs_company_data-data-zterm lfs_company_data-data-zterm.

  PERFORM f_update_datax_flag USING    lfs_company_data-data
                              CHANGING lfs_company_data-datax.


  l_fs_vendor-company_data-current_state = abap_true.
  APPEND lfs_company_data TO l_fs_vendor-company_data-company.


  IF lwg_update_center_data = abap_true.


    "*************************************
    "set External Interface: Central Data
    "*************************************
    "Ext. Interface: Central Vendor Data
*  p_fs_vendor-central_data-central-data-bahns     = VEND_DETAILS- .    "Train station
*  p_fs_vendor-central_data-central-data-bbbnr     = VEND_DETAILS- .    "International location number  (part 1)
*  p_fs_vendor-central_data-central-data-bbsnr     = VEND_DETAILS- .    "International location number (Part 2)
*  p_fs_vendor-central_data-central-data-begru     = VEND_DETAILS- .    "Authorization Group
*  p_fs_vendor-central_data-central-data-brsch     = VEND_DETAILS- .    "Industry key
*  p_fs_vendor-central_data-central-data-bubkz     = VEND_DETAILS- .    "Check digit for the international location number
*  p_fs_vendor-central_data-central-data-dtams     = VEND_DETAILS- .    "Report key for data medium exchange
*  p_fs_vendor-central_data-central-data-dtaws     = VEND_DETAILS- .    "Instruction key for data medium exchange
*  p_fs_vendor-central_data-central-data-esrnr     = VEND_DETAILS- .    "POR subscriber number
*  p_fs_vendor-central_data-central-data-konzs     = VEND_DETAILS- .    "Group key
    l_fs_vendor-central_data-central-data-ktokk     = vend_details-accgrp_ven ."lf_ktokk .    "Vendor account group
*  p_fs_vendor-central_data-central-data-kunnr     = VEND_DETAILS- .    "Customer Number
*  p_fs_vendor-central_data-central-data-lnrza     = VEND_DETAILS- .    "Account Number of the Alternative Payee
*  p_fs_vendor-central_data-central-data-loevm     = VEND_DETAILS- .    "Central Deletion Flag for Master Record
*  p_fs_vendor-central_data-central-data-sperr     = VEND_DETAILS- .    "Central posting block
*  p_fs_vendor-central_data-central-data-sperm     = VEND_DETAILS- .    "Centrally imposed purchasing block
*  p_fs_vendor-central_data-central-data-stcd1     = VEND_DETAILS- .    "Tax Number 1
*  p_fs_vendor-central_data-central-data-stcd2     = VEND_DETAILS- .    "Tax Number 2
*  p_fs_vendor-central_data-central-data-stkza     = VEND_DETAILS- .    "Indicator: Business Partner Subject to Equalization Tax?
*  p_fs_vendor-central_data-central-data-stkzu     = VEND_DETAILS- .    "Liable for VAT
*  p_fs_vendor-central_data-central-data-xzemp     = VEND_DETAILS- .    "Indicator: Alternative payee in document allowed ?
*  p_fs_vendor-central_data-central-data-vbund     = VEND_DETAILS- .    "Company ID of trading partner
*  p_fs_vendor-central_data-central-data-fiskn     = VEND_DETAILS- .    "Account number of the master record with fiscal address
    l_fs_vendor-central_data-central-data-stceg     = vend_details-vat_number.    "VAT Registration Number
*  p_fs_vendor-central_data-central-data-stkzn     = VEND_DETAILS- .    "Natural Person
*  p_fs_vendor-central_data-central-data-sperq     = VEND_DETAILS- .    "Function That Will Be Blocked
*  p_fs_vendor-central_data-central-data-adrnr     = VEND_DETAILS- .    "Address
*  p_fs_vendor-central_data-central-data-gbort     = VEND_DETAILS- .    "Place of birth of the person subject to withholding tax
*  p_fs_vendor-central_data-central-data-gbdat     = VEND_DETAILS- .    "Date of Birth
*  p_fs_vendor-central_data-central-data-sexkz     = VEND_DETAILS- .    "Key for the Sex of the Person Subject to Withholding Tax
*  p_fs_vendor-central_data-central-data-kraus     = VEND_DETAILS- .    "Credit information number
*  p_fs_vendor-central_data-central-data-revdb     = VEND_DETAILS- .    "Last review (external)
*  p_fs_vendor-central_data-central-data-qssys     = VEND_DETAILS- .    "Vendor's QM system
*  p_fs_vendor-central_data-central-data-ktock     = VEND_DETAILS- .    "Reference Account Group for One-Time Account (Vendor)
*  p_fs_vendor-central_data-central-data-werks     = VEND_DETAILS- .    "Plant
*  p_fs_vendor-central_data-central-data-ltsna     = VEND_DETAILS- .    "Indicator: vendor sub-range relevant
*  p_fs_vendor-central_data-central-data-werkr     = VEND_DETAILS- .    "Indicator: plant level relevant
*  p_fs_vendor-central_data-central-data-plkal     = VEND_DETAILS- .    "Factory calendar key
*  p_fs_vendor-central_data-central-data-scacd     = VEND_DETAILS- .    "Standard carrier access code
*  p_fs_vendor-central_data-central-data-sfrgr     = VEND_DETAILS- .    "Forwarding agent freight group
*  p_fs_vendor-central_data-central-data-dlgrp     = VEND_DETAILS- .    "Service agent procedure group
*  p_fs_vendor-central_data-central-data-fityp     = VEND_DETAILS- .    "Tax type
*  p_fs_vendor-central_data-central-data-stcdt     = VEND_DETAILS- .    "Tax Number Type
*  p_fs_vendor-central_data-central-data-regss     = VEND_DETAILS- .    "Registered for Social Insurance
*  p_fs_vendor-central_data-central-data-actss     = VEND_DETAILS- .    "Activity Code for Social Insurance
*  p_fs_vendor-central_data-central-data-stcd3     = VEND_DETAILS- .    "Tax Number 3
*  p_fs_vendor-central_data-central-data-stcd4     = VEND_DETAILS- .    "Tax Number 4
*  p_fs_vendor-central_data-central-data-ipisp     = VEND_DETAILS- .    "Tax Split
*  p_fs_vendor-central_data-central-data-taxbs     = VEND_DETAILS- .    "Tax Base in Percentage
*  p_fs_vendor-central_data-central-data-profs     = VEND_DETAILS- .    "Profession
    l_fs_vendor-central_data-central-data-stgdl     = vend_details-tax_per_vend .    "Shipment: statistics group, transportation service agent
*  p_fs_vendor-central_data-central-data-emnfr     = VEND_DETAILS- .    "External manufacturer code name or number
*  p_fs_vendor-central_data-central-data-nodel     = VEND_DETAILS- .    "Central deletion block for master record
*  p_fs_vendor-central_data-central-data-j_1kfrepre  = VEND_DETAILS- .    "Name of Representative
*  p_fs_vendor-central_data-central-data-j_1kftbus   = VEND_DETAILS- .    "Type of Business
*  p_fs_vendor-central_data-central-data-j_1kftind   = VEND_DETAILS- .    "Type of Industry
*  p_fs_vendor-central_data-central-data-qssysdat    = VEND_DETAILS- .    "Validity date of certification
*  p_fs_vendor-central_data-central-data-podkzb    = VEND_DETAILS- .    "Vendor indicator relevant for proof of delivery
*  p_fs_vendor-central_data-central-data-fisku     = VEND_DETAILS- .    "Account Number of Master Record of Tax Office Responsible
*  p_fs_vendor-central_data-central-data-stenr     = VEND_DETAILS- .    "Tax Number at Responsible Tax Authority
*  p_fs_vendor-central_data-central-data-stcd5     = VEND_DETAILS- .    "Tax Number 5
*  p_fs_vendor-central_data-central-data-cvp_xblck   = VEND_DETAILS- .    "Business Purpose Completed Flag
*  p_fs_vendor-central_data-central-data-rg      = VEND_DETAILS- .    "RG Number
*  p_fs_vendor-central_data-central-data-exp     = VEND_DETAILS- .    "Issued by
*  p_fs_vendor-central_data-central-data-uf      = VEND_DETAILS- .    "State
*  p_fs_vendor-central_data-central-data-rgdate    = VEND_DETAILS- .    "RG Issuing Date
*  p_fs_vendor-central_data-central-data-ric     = VEND_DETAILS- .    "RIC Number
*  p_fs_vendor-central_data-central-data-rne     = VEND_DETAILS- .    "Foreign National Registration
*  p_fs_vendor-central_data-central-data-rnedate   = VEND_DETAILS- .    "RNE Issuing Date
*  p_fs_vendor-central_data-central-data-cnae      = VEND_DETAILS- .    "CNAE
*  p_fs_vendor-central_data-central-data-legalnat    = VEND_DETAILS- .    "Legal Nature
*  p_fs_vendor-central_data-central-data-crtn      = VEND_DETAILS- .    "CRT Number
*  p_fs_vendor-central_data-central-data-icmstaxpay  = VEND_DETAILS- .    "ICMS Taxpayer
*  p_fs_vendor-central_data-central-data-indtyp    = VEND_DETAILS- .    "Industry Main Type
*  p_fs_vendor-central_data-central-data-tdt     = VEND_DETAILS- .    "Tax Declaration Type
*  p_fs_vendor-central_data-central-data-comsize   = VEND_DETAILS- .    "Company Size
*  p_fs_vendor-central_data-central-data-decregpc    = VEND_DETAILS- .    "Declaration Regimen for PIS/COFINS

    PERFORM f_update_datax_flag USING    l_fs_vendor-central_data-central-data
                                CHANGING l_fs_vendor-central_data-central-datax.

    "Ext. Interface: Address of Organization
    l_fs_vendor-central_data-address-task = lc_create_update.
    "----
**  p_fs_vendor-central_data-address-postal-data-addr_vers      = VEND_DETAILS-    .   "Version ID for International Addresses
**  p_fs_vendor-central_data-address-postal-data-from_date      = VEND_DETAILS-    .   "Valid-from date - in current Release only 00010101 possible
**  p_fs_vendor-central_data-address-postal-data-to_date        = VEND_DETAILS-    .   "Valid-to date in current Release only 99991231 possible
*  p_fs_vendor-central_data-address-postal-data-title           = VEND_DETAILS-bp_title    .   "Form-of-Address Key
*  p_fs_vendor-central_data-address-postal-data-name            = VEND_DETAILS-ad_street1    .   "Name 1
*  p_fs_vendor-central_data-address-postal-data-name_2          = VEND_DETAILS-ad_street2    .   "Name 2
*  p_fs_vendor-central_data-address-postal-data-name_3          = VEND_DETAILS-ad_street3    .   "Name 3
*  p_fs_vendor-central_data-address-postal-data-name_4          = VEND_DETAILS-ad_street4    .   "Name 4
**  p_fs_vendor-central_data-address-postal-data-conv_name       = VEND_DETAILS-    .   "Converted name field (with form of address)
**  p_fs_vendor-central_data-address-postal-data-c_o_name        = VEND_DETAILS-    .   "c/o name
*  p_fs_vendor-central_data-address-postal-data-city            = VEND_DETAILS-lf_ort01    .   "City
**  p_fs_vendor-central_data-address-postal-data-district        = VEND_DETAILS-    .   "District
*  p_fs_vendor-central_data-address-postal-data-city_no        = VEND_DETAILS-lf_pstlz    .   "City code for city/street file
**  p_fs_vendor-central_data-address-postal-data-distrct_no     = VEND_DETAILS-    .   "District code for City and Street file
**  p_fs_vendor-central_data-address-postal-data-chckstatus     = VEND_DETAILS-    .   "City file test status
*  p_fs_vendor-central_data-address-postal-data-regiogroup     = VEND_DETAILS-ad_po_box_reg    .   "Regional structure grouping
*  p_fs_vendor-central_data-address-postal-data-postl_cod1     = VEND_DETAILS-ad_post_code2    .   "City postal code
*  p_fs_vendor-central_data-address-postal-data-postl_cod2     = VEND_DETAILS-ad_post_code1    .   "PO Box Postal Code
**  p_fs_vendor-central_data-address-postal-data-postl_cod3     = VEND_DETAILS-    .   "Company Postal Code (for Large Customers)
**  p_fs_vendor-central_data-address-postal-data-pcode1_ext     = VEND_DETAILS-    .   "(Not Supported)City Postal Code Extension, e.g. ZIP+4+2 Code
**  p_fs_vendor-central_data-address-postal-data-pcode2_ext     = VEND_DETAILS-    .   "(Not Supported) PO Box Postal Code Extension
**  p_fs_vendor-central_data-address-postal-data-pcode3_ext     = VEND_DETAILS-    .   "(Not Supported) Major Customer Postal Code Extension
**  p_fs_vendor-central_data-address-postal-data-po_box         = VEND_DETAILS-    .   "PO Box
**  p_fs_vendor-central_data-address-postal-data-po_w_o_no      = VEND_DETAILS-    .   "Flag: PO Box Without Number
**  p_fs_vendor-central_data-address-postal-data-po_box_cit     = VEND_DETAILS-    .   "PO Box city
*  p_fs_vendor-central_data-address-postal-data-pboxcit_no     = VEND_DETAILS-ad_city_code2    .   "City PO box code (City file)
*  p_fs_vendor-central_data-address-postal-data-po_box_reg     = VEND_DETAILS-ad_po_box_reg    .   "Region for PO Box (Country, State, Province, ...)
*  p_fs_vendor-central_data-address-postal-data-pobox_ctry     = VEND_DETAILS-ad_country    .   "PO box country
*  p_fs_vendor-central_data-address-postal-data-po_ctryiso     = VEND_DETAILS-ad_country    .   "Country ISO code
**  p_fs_vendor-central_data-address-postal-data-deliv_dis      = VEND_DETAILS-    .   "(Not Supported) Post Delivery District
**  p_fs_vendor-central_data-address-postal-data-transpzone     = VEND_DETAILS-    .   "Transportation zone to or from which the goods are delivered
*  p_fs_vendor-central_data-address-postal-data-street       = VEND_DETAILS-ad_street1    .   "Street
**  p_fs_vendor-central_data-address-postal-data-street_no      = VEND_DETAILS-    .   "Street Number for City/Street File
**  p_fs_vendor-central_data-address-postal-data-str_abbr     = VEND_DETAILS-    .   "(Not Supported) Abbreviation of Street Name
**  p_fs_vendor-central_data-address-postal-data-house_no     = VEND_DETAILS-    .   "House Number
**  p_fs_vendor-central_data-address-postal-data-house_no2      = VEND_DETAILS-    .   "House number supplement
**  p_fs_vendor-central_data-address-postal-data-house_no3      = VEND_DETAILS-    .   "(Not supported) House Number Range
*  p_fs_vendor-central_data-address-postal-data-str_suppl1     = VEND_DETAILS-ad_street2    .   "Street 2
*  p_fs_vendor-central_data-address-postal-data-str_suppl2     = VEND_DETAILS-ad_street3    .   "Street 3
*  p_fs_vendor-central_data-address-postal-data-str_suppl3     = VEND_DETAILS-ad_street4    .   "Street 4
*  p_fs_vendor-central_data-address-postal-data-location     = VEND_DETAILS-ad_street5    .   "Street 5
**  p_fs_vendor-central_data-address-postal-data-building     = VEND_DETAILS-    .   "Building (Number or Code)
**  p_fs_vendor-central_data-address-postal-data-floor        = VEND_DETAILS-    .   "Floor in building
**  p_fs_vendor-central_data-address-postal-data-room_no        = VEND_DETAILS-    .   "Room or Appartment Number
    l_fs_vendor-central_data-address-postal-data-country        =  'SA' ."VEND_DETAILS-    .   "Country Key
    l_fs_vendor-central_data-address-postal-data-countryiso     =  'SA'. "VEND_DETAILS-ad_country    .   "Country ISO code
**  p_fs_vendor-central_data-address-postal-data-langu        = VEND_DETAILS-    .   "Language Key
**  p_fs_vendor-central_data-address-postal-data-langu_iso      = VEND_DETAILS-    .   "2-Character SAP Language Code
**  p_fs_vendor-central_data-address-postal-data-region       = VEND_DETAILS-    .   "Region (State, Province, County)
*  p_fs_vendor-central_data-address-postal-data-sort1        = VEND_DETAILS-bp_sterm1    .   "Search Term 1
*  p_fs_vendor-central_data-address-postal-data-sort2        = VEND_DETAILS-bp_sterm2    .   "Search Term 2
**  p_fs_vendor-central_data-address-postal-data-extens_1     = VEND_DETAILS-    .   "Extension (only for data conversion) (e.g. data line)
**  p_fs_vendor-central_data-address-postal-data-extens_2     = VEND_DETAILS-    .   "Extension (only for data conversion) (e.g. telebox)
**  p_fs_vendor-central_data-address-postal-data-time_zone      = VEND_DETAILS-    .   "Address time zone
**  p_fs_vendor-central_data-address-postal-data-taxjurcode     = VEND_DETAILS-    .   "Tax Jurisdiction
**  p_fs_vendor-central_data-address-postal-data-address_id     = VEND_DETAILS-    .   "(Not supported) Physical address ID
**  p_fs_vendor-central_data-address-postal-data-langu_cr     = VEND_DETAILS-    .   "Address record creation original language
**  p_fs_vendor-central_data-address-postal-data-langucriso     = VEND_DETAILS-    .   "2-Character SAP Language Code
**  p_fs_vendor-central_data-address-postal-data-comm_type      = VEND_DETAILS-    .   "Communication Method (Key) (Business Address Services)
**  p_fs_vendor-central_data-address-postal-data-addr_group     = VEND_DETAILS-    .   "Address Group (Key) (Business Address Services)
**  p_fs_vendor-central_data-address-postal-data-home_city      = VEND_DETAILS-    .   "City (different from postal city)
**  p_fs_vendor-central_data-address-postal-data-homecityno     = VEND_DETAILS-    .   "Different city for city/street file
**  p_fs_vendor-central_data-address-postal-data-dont_use_s     = VEND_DETAILS-    .   "Street Address Undeliverable Flag
**  p_fs_vendor-central_data-address-postal-data-dont_use_p     = VEND_DETAILS-    .   "PO Box Address Undeliverable Flag
**  p_fs_vendor-central_data-address-postal-data-po_box_lobby   = VEND_DETAILS-    .   "PO Box Lobby
**  p_fs_vendor-central_data-address-postal-data-deli_serv_type   = VEND_DETAILS-    .   "Type of Delivery Service
**  p_fs_vendor-central_data-address-postal-data-deli_serv_number	= VEND_DETAILS-    .   "Number of Delivery Service
    l_fs_vendor-central_data-address-postal-data-county_code      = 'SA'. "VEND_DETAILS-    .   "County code for county
    l_fs_vendor-central_data-address-postal-data-county       = 'SA'. "VEND_DETAILS-    .   "County
**  p_fs_vendor-central_data-address-postal-data-township_code    = VEND_DETAILS-    .   "Township code for Township
**  p_fs_vendor-central_data-address-postal-data-township     = VEND_DETAILS-    .   "Township
*
    PERFORM f_update_datax_flag USING    l_fs_vendor-central_data-address-postal-data
                                CHANGING l_fs_vendor-central_data-address-postal-datax.


    "Ext. Interface: Text Main Structure
    "p_fs_vendor-CENTRAL_DATA-TEXT

    "Ext. Interface: EU Tax Numbers
    "p_fs_vendor-CENTRAL_DATA-VAT_NUMBER

    "Ext. Interface: Tax Groupings
    "p_fs_vendor-CENTRAL_DATA-TAX_GROUPING
    "***********************************
    "* External Interface: Bank Details
    "***********************************
    IF  vend_details-bank_coun_ven IS NOT INITIAL
     AND vend_details-bank_ven IS NOT INITIAL
     AND vend_details-bank_acc_ven IS NOT INITIAL.

      lfs_bankdetail-data_key-banks = vend_details-bank_coun_ven. "Bank country key
      lfs_bankdetail-data_key-bankl = vend_details-bank_ven. "Bank number
      lfs_bankdetail-data_key-bankn = vend_details-bank_acc_ven. "Bank account number

      lfs_bankdetail-data-bkont           = vend_details-bank_key_ven ."Bank Control Key
*  lfs_bankdetail-data-bvtyp           = VEND_DETAILS- ."Partner bank type
*  lfs_bankdetail-data-xezer           = VEND_DETAILS- ."Indicator: Is there collection authorization ?
*  lfs_bankdetail-data-bkref           = VEND_DETAILS- ."Reference specifications for bank details
      lfs_bankdetail-data-koinh           = vend_details-acc_holname_ven ."Account Holder Name
      lfs_bankdetail-data-iban            = vend_details-iban_ven ."IBAN (International Bank Account Number)
      lfs_bankdetail-data-iban_from_date  = sy-datum ."Validity start of IBAN



      lfs_bankdetail-task = lc_create_update.

      PERFORM f_update_datax_flag USING    lfs_bankdetail-data
                                  CHANGING  lfs_bankdetail-datax.

      l_fs_vendor-central_data-bankdetail-current_state = abap_true.

      APPEND lfs_bankdetail TO l_fs_vendor-central_data-bankdetail-bankdetails.

    ENDIF.

  ENDIF.




  "Ext. Interface: Contact Person
  "p_fs_vendor-CENTRAL_DATA-CONTACT

  "External Interface: Vendor Subrange
  "p_fs_vendor-CENTRAL_DATA-SUBRANGE

  "*************************************
  "*set Ext. Interface: Purchasing Data
  "*************************************
  CLEAR: lfs_purchasing,lfs_function.

  IF vend_details-pur_org_vend IS NOT INITIAL .

    lfs_purchasing-task = lc_create_update.
    lfs_purchasing-data_key-ekorg = vend_details-pur_org_vend.
    "DATA
*  lfs_purchasing-data-sperm  = p_gs_data-   .  "Purchasing block at purchasing organization level
*  lfs_purchasing-data-loevm  = p_gs_data-   .  "Delete flag for vendor at purchasing level
*  lfs_purchasing-data-lfabc  = p_gs_data-   .  "ABC indicator
    lfs_purchasing-data-waers  = vend_details-po_curr_vend   .  "Purchase order currency
*  lfs_purchasing-data-verkf  = p_gs_data-   .  "Responsible Salesperson at Vendor's Office
*  lfs_purchasing-data-telf1  = p_gs_data-   .  "Vendor's telephone number
*  lfs_purchasing-data-minbw  = p_gs_data-   .  "Minimum order value
    lfs_purchasing-data-zterm	= vend_details-pay_term_vend   .  "Terms of Payment Key
*  lfs_purchasing-data-inco1  = p_gs_data-   .  "Incoterms (Part 1)
*  lfs_purchasing-data-inco2  = p_gs_data-   .  "Incoterms (Part 2)
*  lfs_purchasing-data-webre  = p_gs_data-   .  "Indicator: GR-Based Invoice Verification
*  lfs_purchasing-data-kzabs  = p_gs_data-   .  "Order Acknowledgment Requirement
    lfs_purchasing-data-kalsk  = vend_details-schema_gp."  "Group for Calculation Schema (Vendor)
*  lfs_purchasing-data-kzaut  = p_gs_data-   .  "Automatic Generation of Purchase Order Allowed
*  lfs_purchasing-data-expvz  = p_gs_data-   .  "Mode of Transport for Foreign Trade
*  lfs_purchasing-data-zolla  = p_gs_data-   .  "Customs Office: Office of Exit/Entry for Foreign Trade
*  lfs_purchasing-data-meprf  = p_gs_data-   .  "Price Determination (Pricing) Date Control
*  lfs_purchasing-data-ekgrp  = p_gs_data-   .  "Purchasing group
*  lfs_purchasing-data-bolre  = p_gs_data-   .  "Indicator: vendor subject to subseq. settlement accounting
*  lfs_purchasing-data-umsae  = p_gs_data-   .  "Comparison/agreement of business volumes necessary
*  lfs_purchasing-data-xersy  = p_gs_data-   .  "Evaluated Receipt Settlement (ERS)
*  lfs_purchasing-data-plifz  = p_gs_data-   .  "Planned delivery time in days
*  lfs_purchasing-data-mrppp  = p_gs_data-   .  "Planning calendar
*  lfs_purchasing-data-lfrhy  = p_gs_data-   .  "Planning cycle
*  lfs_purchasing-data-libes  = p_gs_data-   .  "Order entry by vendor
*  lfs_purchasing-data-lipre  = p_gs_data-   .  "Price marking, vendor
*  lfs_purchasing-data-liser  = p_gs_data-   .  "Rack-jobbing: vendor
*  lfs_purchasing-data-boind  = p_gs_data-   .  "Indicator: index compilation for subseq. settlement active
*  lfs_purchasing-data-prfre  = p_gs_data-   .  "Indicator: "relev. to price determination (vend. hierarchy)
*  lfs_purchasing-data-nrgew  = p_gs_data-   .  "Indicator whether discount in kind granted
*  lfs_purchasing-data-blind  = p_gs_data-   .  "Indicator: Doc. index compilation active for purchase orders
*  lfs_purchasing-data-skrit  = p_gs_data-   .  "Vendor sort criterion for materials
*  lfs_purchasing-data-bstae  = p_gs_data-   .  "Confirmation Control Key
*  lfs_purchasing-data-rdprf  = p_gs_data-   .  "Rounding Profile
*  lfs_purchasing-data-megru  = p_gs_data-   .  "Unit of Measure Group
*  lfs_purchasing-data-vensl  = p_gs_data-   .  "Vendor service level
*  lfs_purchasing-data-bopnr  = p_gs_data-   .  "Restriction Profile for PO-Based Load Building
*  lfs_purchasing-data-xersr  = p_gs_data-   .  "Automatic evaluated receipt settlement for return items
*  lfs_purchasing-data-eikto  = p_gs_data-   .  "Our account number with the vendor
*  lfs_purchasing-data-paprf  = p_gs_data-   .  "Profile for transferring material data via IDoc PROACT
*  lfs_purchasing-data-agrel  = p_gs_data-   .  "Indicator: Relevant for agency business
*  lfs_purchasing-data-xnbwy  = p_gs_data-   .  "Revaluation allowed
*  lfs_purchasing-data-vsbed  = p_gs_data-   .  "Shipping Conditions
*  lfs_purchasing-data-lebre  = p_gs_data-   .  "Indicator for Service-Based Invoice Verification


    PERFORM f_update_datax_flag USING    lfs_purchasing-data
                               CHANGING  lfs_purchasing-datax.


    "Ext. Interface: Partner Roles
    "lfs_function-task = lc_create_update.
    "lfs_function-data_key-

    "Ext. Interface: Text Main Structure

    "External Interface: Purchasing2 (LFM2)

    l_fs_vendor-purchasing_data-current_state = abap_true.
    APPEND lfs_purchasing TO l_fs_vendor-purchasing_data-purchasing.
  ENDIF.

  APPEND l_fs_vendor TO lfs_master_data-vendors.

  TRY .

      vmd_ei_api=>initialize( ).

      vmd_ei_api=>maintain_bapi(
        EXPORTING
*        iv_test_run              = iv_test_run    " Checkbox Test Run ('X' = Yes)
        iv_collect_messages      =  abap_true    " Checkbox Collect Messages ('X' = Yes)
          is_master_data           = lfs_master_data    " Vendor Total Data
      IMPORTING
*        es_master_data_correct   = es_master_data_correct    " Vendor Total Data Without Errors
        es_message_correct       = lfs_message_correct    " Error Indicator and System Messages for Data Without Errors
*        es_master_data_defective = es_master_data_defective    " Vendor Total Data with Errors
        es_message_defective     = lfs_message_defective    " Error Indicator and System Messages for Incorrect Data
      ).

      IF  lfs_message_correct-is_error IS INITIAL AND lfs_message_defective-is_error IS INITIAL.
        CLEAR : lfs_message.
        lfs_message-type = 'S'.
        lfs_message-id = '00'.
        lfs_message-number = '398'.
        lfs_message-message_v1 = 'Creation/Updating Vendor done' .
        lfs_message-message_v3 = bpartner.
        APPEND lfs_message TO return.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
*--linking cutomer to BP....

*--customer role
        IF  vend_details-vend_role IS NOT INITIAL.
          PERFORM bp_vend_link USING bpartner vend_details-vend_role '' CHANGING  lint_messages .
          LOOP AT lint_messages INTO lfs_message.
            APPEND lfs_message TO return.
          ENDLOOP.
        ENDIF.
*--*--FI customer role
        IF  vend_details-fi_ven_role IS NOT INITIAL.
          PERFORM bp_vend_link USING bpartner '' vend_details-fi_ven_role  CHANGING  lint_messages .
          LOOP AT lint_messages INTO lfs_message.
            APPEND lfs_message TO return.
          ENDLOOP.
        ENDIF.
        "added
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ELSE.
        LOOP AT lfs_message_defective-messages INTO DATA(return1).
          MOVE-CORRESPONDING  return1 TO  lfs_message.
          APPEND lfs_message TO return.
        ENDLOOP.

        LOOP AT lfs_message_correct-messages INTO DATA(return2).
          MOVE-CORRESPONDING  return2 TO  lfs_message.
          APPEND lfs_message TO return.
        ENDLOOP.

        lfs_message-type = 'E'.
        lfs_message-id = '00'.
        lfs_message-number = '001'.
        lfs_message-message_v1 = 'Error While updating Vendor' .
        lfs_message-message_v2 =  'please correct the record '.
        lfs_message-message_v3 = bpartner.
        APPEND lfs_message TO return.
      ENDIF.


    CATCH cx_root.

  ENDTRY.




ENDFUNCTION.

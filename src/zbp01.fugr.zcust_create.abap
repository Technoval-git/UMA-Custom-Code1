FUNCTION ZCUST_CREATE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CUST_DETAILS) TYPE  ZCUST_CREATE_STRUCT
*"     VALUE(BPARTNER) TYPE  BU_PARTNER
*"  TABLES
*"      RETURN TYPE  BAPIRET2_T OPTIONAL
*"----------------------------------------------------------------------



  "***********************************************************
  "*            BEGIN OF DECLARING LOCAL DATA
  "***********************************************************
  DATA:
    lfs_master_data       TYPE cmds_ei_main,
    lint_customer         LIKE lfs_master_data-customers,
    lfs_customer          LIKE LINE OF lint_customer,
    lfs_message_correct   TYPE cvis_message,
    lfs_message_defective TYPE cvis_message,
    ls_msg                TYPE bal_s_msg.
  DATA: return5 TYPE bapiret2.
  "***********************************************************
  FIELD-SYMBOLS:
    <lfs_message>         LIKE LINE OF  lfs_message_correct-messages.



  "***********************************************************
  DATA:
    lint_messages TYPE bapiret2_t,
    lfs_message   LIKE LINE OF lint_messages,
    lv_commit     .
  "***********************************************************

  CLEAR lv_commit.

  "***********************************************************
  "*            BEGIN OF DECLARING LOCAL DATA
  "***********************************************************
  CONSTANTS:
     lc_create_update      TYPE cmd_ei_object_task VALUE 'M'.
  "***********************************************************
  DATA:
    lfs_company_data       LIKE LINE OF lfs_customer-company_data-company,
    lfs_header             LIKE lfs_customer-header,
    lfs_central_data       LIKE lfs_customer-central_data,
    lfs_address            LIKE LINE OF lfs_customer-central_data-address-version-versions,
    lfs_contact            LIKE LINE OF lfs_customer-central_data-contact-contacts,
    lfs_sales_data         LIKE LINE OF lfs_customer-sales_data-sales,
    lwg_update_center_data TYPE abap_bool VALUE abap_true,
    lwf_kunner             TYPE kunnr.

  DATA: lw_but00 TYPE but100.
  DATA: lv_cusflag,
        lv_fiflag.

  CLEAR: lv_cusflag,lv_fiflag,lwf_kunner,lwg_update_center_data,lfs_sales_data,lfs_address,lfs_central_data,lfs_header, lfs_company_data,
   lint_messages,lfs_message,  lfs_master_data,lfs_customer,lint_customer,lfs_message_correct,lfs_message_defective, ls_msg.
  "***********************************************************
  "FIELD-SYMBOLS:
  "************ END OF DECLARING LOCAL DATA ******************

  "********************************
  "*check if the center data exist
  "********************************
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = bpartner
    IMPORTING
      output = bpartner.

  SELECT SINGLE kunnr INTO lwf_kunner FROM kna1 WHERE kunnr = bpartner.
  IF sy-subrc <> 0.
    lwg_update_center_data = abap_true.
  ENDIF.
*-----some validation and roles creation.....

  IF cust_details-cust_role IS NOT INITIAL AND cust_details-fi_cust_role IS INITIAL.
    lfs_message-type = 'E'.
    lfs_message-id = '00'.
    lfs_message-number = '001'.
    lfs_message-message_v1 = 'Customer role flag passed without FI Customer flag' .
    lfs_message-message_v2 =  'please correct the record '.
    lfs_message-message_v3 = bpartner.
    APPEND lfs_message TO return.
    EXIT.
  ENDIF.
  "*************************************
  "*set header info
  "*************************************
  lfs_customer-header-object_instance-kunnr = bpartner.
  lfs_customer-header-object_task = lc_create_update.

  "*************************************
  "set Ext. Interface: Company Code Data
  "*************************************
  CLEAR lfs_company_data.

  "set company code
  lfs_company_data-task = lc_create_update.
  lfs_company_data-data_key-bukrs = cust_details-comp_code_fi.
  lfs_company_data-data-akont = cust_details-rec_acc_fi.   "RECONCILATION ACCOUNT
  lfs_company_data-data-zuawa = cust_details-sort_key_fi.  "Sortkey
  lfs_company_data-data-zterm = cust_details-term_pay_fi. "Payment Methods

**  lfs_company_data-data-sperr           = p_CUST_DETAILS-.  "Posting block for company code
**  lfs_company_data-data-loevm           = p_CUST_DETAILS-.  "Deletion Flag for Master Record (Company Code Level)
**  lfs_company_data-data-zuawa           = p_CUST_DETAILS-.  "Key for sorting according to assignment numbers
*  lfs_company_data-data-akont           = p_CUST_DETAILS-lb_akont.  "Reconciliation Account in General Ledger
**  lfs_company_data-data-begru           = p_CUST_DETAILS-.  "Authorization Group
**  lfs_company_data-data-vzskz           = p_CUST_DETAILS-.  "Interest calculation indicator
*  lfs_company_data-data-zwels           = p_CUST_DETAILS-lb_zwels.  "List of Respected Payment Methods
**  lfs_company_data-data-xverr           = p_CUST_DETAILS-.  "Indicator: Clearing between customer and vendor?
**  lfs_company_data-data-zahls           = p_CUST_DETAILS-.  "Block Key for Payment
*  lfs_company_data-data-zterm           = p_CUST_DETAILS-lb_zterm.  "Terms of Payment Key
**  lfs_company_data-data-eikto           = p_CUST_DETAILS-.  "Our account number with the vendor
**  lfs_company_data-data-zsabe           = p_CUST_DETAILS-.  "Clerk at vendor
**  lfs_company_data-data-kverm           = p_CUST_DETAILS-.  "Memo
**  lfs_company_data-data-fdgrv           = p_CUST_DETAILS-.  "Planning group
**  lfs_company_data-data-busab           = p_CUST_DETAILS-.  "Accounting clerk
**  lfs_company_data-data-lnrze           = p_CUST_DETAILS-.  "Head office account number
**  lfs_company_data-data-lnrzb           = p_CUST_DETAILS-.  "Account number of the alternative payee
**  lfs_company_data-data-zindt           = p_CUST_DETAILS-.  "Key Date of Last Interest Calculation
**  lfs_company_data-data-zinrt           = p_CUST_DETAILS-.  "Interest Calculation Frequency in Months
**  lfs_company_data-data-datlz           = p_CUST_DETAILS-.  "Date of the last interest calculation run
**  lfs_company_data-data-xdezv           = p_CUST_DETAILS-.  "Indicator: Local processing?
**  lfs_company_data-data-webtr           = p_CUST_DETAILS-.  "Bill of exchange limit (in local currency)
**  lfs_company_data-data-kultg           = p_CUST_DETAILS-.  "Probable time until check is paid
**  lfs_company_data-data-reprf           = p_CUST_DETAILS-.  "Check Flag for Double Invoices or Credit Memos
**  lfs_company_data-data-togru           = p_CUST_DETAILS-.  "Tolerance group for the business partner/G/L account
**  lfs_company_data-data-hbkid           = p_CUST_DETAILS-.  "Short key for a house bank
**  lfs_company_data-data-xpore           = p_CUST_DETAILS-.  "Indicator: Pay all items separately ?
**  lfs_company_data-data-qsznr           = p_CUST_DETAILS-.  "Certificate Number of the Withholding Tax Exemption
**  lfs_company_data-data-qszdt           = p_CUST_DETAILS-.  "Validity Date for Withholding Tax Exemption Certificate
**  lfs_company_data-data-qsskz           = p_CUST_DETAILS-.  "Withholding Tax Code
**  lfs_company_data-data-blnkz           = p_CUST_DETAILS-.  "Subsidy Indicator for Determining the Reduction Rates
**  lfs_company_data-data-mindk           = p_CUST_DETAILS-.  "Minority Indicators
**  lfs_company_data-data-altkn           = p_CUST_DETAILS-.  "Previous Master Record Number
**  lfs_company_data-data-zgrup           = p_CUST_DETAILS-.  "Key for Payment Grouping
**  lfs_company_data-data-mgrup           = p_CUST_DETAILS-.  "Key for dunning notice grouping
**  lfs_company_data-data-uzawe           = p_CUST_DETAILS-.  "Payment method supplement
**  lfs_company_data-data-qsrec           = p_CUST_DETAILS-.  "Vendor Recipient Type
**  lfs_company_data-data-qsbgr           = p_CUST_DETAILS-.  "Authority for Exemption from Withholding Tax
**  lfs_company_data-data-qland           = p_CUST_DETAILS-.  "Withholding Tax Country Key
**  lfs_company_data-data-xedip           = p_CUST_DETAILS-.  "Indicator: Send Payment Advices by EDI
**  lfs_company_data-data-frgrp           = p_CUST_DETAILS-.  "Release Approval Group
**  lfs_company_data-data-tlfxs           = p_CUST_DETAILS-.  "Accounting clerk's fax number at the customer/vendor
**  lfs_company_data-data-intad           = p_CUST_DETAILS-.  "Internet address of partner company clerk
**  lfs_company_data-data-guzte           = p_CUST_DETAILS-.  "Payment Terms Key for Credit Memos
**  lfs_company_data-data-gricd           = p_CUST_DETAILS-.  "Activity Code for Gross Income Tax
**  lfs_company_data-data-gridt           = p_CUST_DETAILS-.  "Distribution Type for Employment Tax
**  lfs_company_data-data-xausz           = p_CUST_DETAILS-.  "Indicator for periodic account statements
**  lfs_company_data-data-cerdt           = p_CUST_DETAILS-.  "Certification date
**  lfs_company_data-data-togrr           = p_CUST_DETAILS-.  "Tolerance group; Invoice Verification
**  lfs_company_data-data-pernr           = p_CUST_DETAILS-.  "Personnel Number
**  lfs_company_data-data-nodel           = p_CUST_DETAILS-.  "Deletion bock for master record (company code level)
**  lfs_company_data-data-tlfns           = p_CUST_DETAILS-.  "Accounting clerk's telephone number at business partner
**  lfs_company_data-data-prepay_relevant  = p_CUST_DETAILS-.  "Prepayment Relevance (Vendor Master)
**  lfs_company_data-data-assign_test      = p_CUST_DETAILS-.  "Assignment Test Group
**  lfs_company_data-data-cvp_xblck_b      = p_CUST_DETAILS-.  "Business Purpose Completed Flag
**  lfs_company_data-data-ciiucode        = p_CUST_DETAILS-.
*
  macro_alpha_input: lfs_company_data-data-akont lfs_company_data-data-akont,  "RECONCILATION ACCOUNT
                     lfs_company_data-data-zuawa lfs_company_data-data-zuawa, "Sortkey
                     lfs_company_data-data-zterm  lfs_company_data-data-zterm. "Payment Methods


  PERFORM f_update_datax_flag USING    lfs_company_data-data
                              CHANGING lfs_company_data-datax.

  lfs_customer-company_data-current_state = abap_true.
  APPEND lfs_company_data TO lfs_customer-company_data-company.


  IF cust_details-cust_role IS NOT INITIAL.
    CLEAR lfs_sales_data.
    lfs_sales_data-task = lc_create_update.


    CLEAR lfs_sales_data.
    lfs_sales_data-task = lc_create_update.
*----key data
    lfs_sales_data-data_key-vkorg = cust_details-sales_org_cus.
*    lfs_sales_data-data_key-vtweg = cust_details-sales_dist_cus.
    lfs_sales_data-data_key-vtweg = cust_details-dist_cha_cus.
    lfs_sales_data-data_key-spart = cust_details-division_cus .

*---other data
    lfs_sales_data-data-bzirk = cust_details-sales_dist_cus.
    lfs_sales_data-data-vkbur = cust_details-sales_off_cus.
    lfs_sales_data-data-vkgrp = cust_details-sales_grp_cus.
    lfs_sales_data-data-kdgrp = cust_details-cust_grp_cus.
    lfs_sales_data-data-waers = cust_details-curr_cus.
    lfs_sales_data-data-konda = cust_details-price_grp_cus.
    lfs_sales_data-data-pltyp = cust_details-price_li_cus.
    lfs_sales_data-data-kalks = cust_details-price_pro_cus.
    lfs_sales_data-data-vsbed = cust_details-ship_cond_cus.
    lfs_sales_data-data-inco1 = cust_details-incoterm1_cus.
    lfs_sales_data-data-inco2 = cust_details-incoterm2_cus.
    lfs_sales_data-data-zterm = cust_details-term_pay_cus.
    lfs_sales_data-data-ktgrd = cust_details-acc_asigrp_cus.
    lfs_sales_data-data-versg = cust_details-stat_grp_cus.
    lfs_sales_data-data-vwerk = cust_details-del_plant_cus.

    macro_alpha_input:
                       lfs_sales_data-data-kdgrp lfs_sales_data-data-kdgrp,
                       lfs_sales_data-data-ktgrd lfs_sales_data-data-ktgrd,
                       lfs_sales_data-data-vkbur lfs_sales_data-data-vkbur,
                       lfs_sales_data-data-vkgrp lfs_sales_data-data-vkgrp.


    PERFORM f_update_datax_flag USING    lfs_sales_data-data
                                CHANGING lfs_sales_data-datax.



    lfs_sales_data-functions-current_state = abap_true.
    DATA: ls_functions LIKE LINE OF lfs_sales_data-functions-functions,
          lt_func      TYPE TABLE OF e1knvpm,
          ls_func      LIKE LINE OF lt_func.
*  BREAK tech2.
    CALL FUNCTION 'CUSTOMER_PARTNERFS_GET'
      EXPORTING
        iv_kunnr   = lfs_customer-header-object_instance-kunnr
        iv_vkorg   = cust_details-sales_org_cus
        iv_vtweg   = cust_details-dist_cha_cus
        iv_spart   = cust_details-division_cus
      TABLES
        et_e1knvpm = lt_func.


    LOOP AT lt_func
      INTO ls_func.
      ls_functions-task = lc_create_update.
      ls_functions-data_key-parvw = ls_func-parvw.
      ls_functions-data_key-parza = ls_func-parza.
      ls_functions-data-defpa = ls_func-defpa.
      ls_functions-datax-defpa = abap_true.
      ls_functions-data-knref = cust_details-bp_name_1."ls_func-knref.
      ls_functions-datax-knref = abap_true.
      ls_functions-data-partner = ls_func-kunn2.
      ls_functions-datax-partner = abap_true.
      APPEND ls_functions TO lfs_sales_data-functions-functions.
    ENDLOOP.


    "***************************************************
    "*    add customer partners functions
    "*      some time there is issue with partner function
    "***************************************************
    IF lt_func IS INITIAL.

      DATA lit_data TYPE STANDARD TABLE OF parvw.

      APPEND 'AG' TO lit_data.
      APPEND 'RE' TO lit_data.
      APPEND 'RG' TO lit_data.
      APPEND 'WE' TO lit_data.

      LOOP AT lit_data ASSIGNING FIELD-SYMBOL(<lfs_partner_function>).

        ls_functions-task = lc_create_update.
        ls_functions-data_key-parvw = <lfs_partner_function>.
        ls_functions-data_key-parza = '000'.
        ls_functions-data-defpa = ''.
        ls_functions-datax-defpa = abap_true.
        ls_functions-data-knref = cust_details-bp_name_1."ls_func-knref.
        ls_functions-datax-knref = abap_true.
        ls_functions-data-partner = bpartner.
        ls_functions-datax-partner = abap_true.
        APPEND ls_functions TO lfs_sales_data-functions-functions.

      ENDLOOP.

    ENDIF.


******************commentin by ismail
    "set SalesRep Code in Functions
    IF cust_details-sal_repco_cus IS NOT INITIAL.
      CLEAR ls_functions.

      ls_functions-task = lc_create_update.
      ls_functions-data_key-parvw = 'VE'.
      ls_functions-data_key-parza = '000'.
      ls_functions-data-partner = cust_details-sal_repco_cus.

      PERFORM f_update_datax_flag
        USING ls_functions-data
        CHANGING ls_functions-datax.

      APPEND ls_functions TO lfs_sales_data-functions-functions.

    ENDIF.
    MODIFY TABLE lfs_sales_data-functions-functions FROM ls_functions.


    lfs_customer-sales_data-current_state = abap_true.
    APPEND lfs_sales_data TO lfs_customer-sales_data-sales.
  ENDIF.
*-----account group
  lfs_customer-central_data-central-data-ktokd = cust_details-cust_acc_grp_fi.
*  lfs_customer-central_data-central-datax-ktokd = abap_true.
*  lfs_customer-central_data-central-data-vbund = gs_data-kn_vbund.   "need to fill

*---contact person details...
*  lfs_contact-task = 'M'.
*
*
*  lfs_contact-data_key-parnr = cust_details-sal_repco_cus.
*  lfs_contact-data-abtnr =  cust_details-cont_pdept_cus.
*  lfs_contact-data-pafkt = cust_details-cont_pfunc_cus.
*  lfs_contact-data-PARAU = cust_details-bp_name_1.
*  macro_alpha_input lfs_contact-data_key-parnr  lfs_contact-data_key-parnr.
*
*  PERFORM f_update_datax_flag USING    lfs_contact-data
*                              CHANGING lfs_contact-datax.
*  lfs_customer-sales_data-current_state = abap_true.
*  APPEND lfs_contact TO lfs_customer-central_data-contact-contacts.

*----other details....
*
**************************************************commenting
  IF lwg_update_center_data = abap_true.
    lfs_customer-central_data-address-version-current_state = abap_true.
    lfs_address-task              = 'I'.  " lc_create_update.
    lfs_address-data-addr_vers    = 'A'.
    macro_alpha_input cust_details-title lfs_address-data-title.
    lfs_address-data-name         = cust_details-bp_name_1_ar.
    lfs_address-data-name_2       = cust_details-bp_name_2_ar .
    lfs_address-data-sort1        = cust_details-searchterm1_ar.  " Arabic Search Term 1
    lfs_address-data-sort2        = cust_details-searchterm2_ar.  " Arabic Search Term 1
    lfs_address-data-str_suppl3   = cust_details-street4_ar. " Arabic Street 4
    lfs_address-data-str_suppl2   = cust_details-street3_ar. " Arabic Street 3
    lfs_address-data-location     = cust_details-street5_ar. " Arabic Street 5 LOCATION
    lfs_address-data-str_suppl1   = cust_details-street2_ar. " Arabic Street 2
    lfs_address-data-street       = cust_details-streethno_ar. " Arabic street /---House number
    lfs_address-data-city         = cust_details-city_ar.   " Arabic City
    lfs_address-data-county       = cust_details-countrycode.   " Arabic City
    PERFORM f_update_datax_flag
      USING lfs_address-data
      CHANGING lfs_address-datax.
*
    APPEND lfs_address TO lfs_customer-central_data-address-version-versions.
    DATA lfs_org_address TYPE cvis_ei_1vl.
    lfs_customer-central_data-address-task = 'M'.  " lc_create_update.
    macro_alpha_input cust_details-title lfs_org_address-data-title.
**    lfs_org_address-data-addr_vers    = 'A'.
    lfs_org_address-data-addr_vers    = 'I'.
    lfs_org_address-data-name         = cust_details-bp_name_1.
    lfs_org_address-data-name_2       = cust_details-bp_name_2.
    lfs_org_address-data-sort1        = cust_details-searchterm1.  " Arabic Search Term 1
    lfs_org_address-data-sort2        = cust_details-searchterm2.  " Arabic Search Term 1
    lfs_org_address-data-str_suppl3   = cust_details-street4. " Arabic Street 4
    lfs_org_address-data-str_suppl2   = cust_details-street3. " Arabic Street 3
    lfs_org_address-data-location     = cust_details-street5. " Arabic Street 5 LOCATION
    lfs_org_address-data-str_suppl1   = cust_details-street2. " Arabic Street 2
    lfs_org_address-data-street       = cust_details-streethno. " Arabic street /---House number
    lfs_org_address-data-city         = cust_details-city..   " Arabic City
    lfs_org_address-data-po_box       = cust_details-postalpo.   " Arabic City
    lfs_org_address-data-postl_cod1   = cust_details-postalpo.   " Arabic City
    lfs_org_address-data-region       = cust_details-region  .   " Arabic City
    lfs_org_address-data-country      = cust_details-countrycode.   " Arabic City
    lfs_org_address-data-county_code  = cust_details-countrycode.   " Arabic City
    lfs_org_address-data-county       = cust_details-countrycode.   " Arabic City
    lfs_org_address-data-langu  = 'E'.
    lfs_org_address-data-langu_iso = 'EN'.

    MOVE lfs_org_address TO lfs_customer-central_data-address-postal.

    PERFORM f_update_datax_flag
      USING lfs_customer-central_data-address-postal-data
      CHANGING lfs_customer-central_data-address-postal-datax.
  ENDIF.
**********************************************************************
  " Tax
**********************************************************************
  DATA: lfs_tax_ind LIKE LINE OF lfs_customer-central_data-tax_ind-tax_ind. "CMDS_EI_TAX_IND.


  IF cust_details-out_tax_cus IS NOT INITIAL.
    lfs_customer-central_data-tax_ind-current_state = abap_true.

    lfs_tax_ind-task = 'M'.

    lfs_tax_ind-data_key-aland = cust_details-countrycode.
    lfs_tax_ind-data_key-tatyp = 'MWST'.

    lfs_tax_ind-data-taxkd = cust_details-out_tax_cus.

    PERFORM f_update_datax_flag
      USING lfs_tax_ind-data
      CHANGING lfs_tax_ind-datax.

    APPEND lfs_tax_ind TO lfs_customer-central_data-tax_ind-tax_ind.
  ENDIF.

  PERFORM f_update_datax_flag
    USING lfs_customer-central_data-central-data
    CHANGING lfs_customer-central_data-central-datax.

  APPEND lfs_customer TO lfs_master_data-customers.



  TRY .

      cmd_ei_api=>initialize( ).

      cmd_ei_api=>maintain_bapi(
        EXPORTING
*        iv_test_run              = iv_test_run    " Checkbox Test Run ('X' = Yes)
          iv_collect_messages      =  abap_true    " Checkbox Collect Messages ('X' = Yes)
          is_master_data           = lfs_master_data    "  Total Data
      IMPORTING
        es_message_correct       = lfs_message_correct    " Error Indicator and System Messages for Data Without Errors
        es_message_defective     = lfs_message_defective    " Error Indicator and System Messages for Incorrect Data
      ).

      IF  lfs_message_correct-is_error IS INITIAL AND lfs_message_defective-is_error IS INITIAL.
        CLEAR : lfs_message.
        lfs_message-type = 'S'.
        lfs_message-id = '00'.
        lfs_message-number = '398'.
        lfs_message-message_v1 = 'Creation/Updating Customer succesfully' .
        lfs_message-message_v3 = bpartner.
        APPEND lfs_message TO return.


        DATA lwf_kunnr     TYPE kna1-kunnr.
        "******************************************************

        lwf_kunnr = lfs_customer-header-object_instance..

        CALL FUNCTION 'DEQUEUE_EXKNA1'
          EXPORTING
            kunnr = lwf_kunnr.


**0---link customer to BP....
        WAIT UP TO 2 SECONDS.
*--customer role
        IF  cust_details-cust_role IS NOT INITIAL.
          PERFORM bp_cust_link USING bpartner cust_details-cust_role '' CHANGING  lint_messages .
          LOOP AT lint_messages INTO lfs_message.
            APPEND lfs_message TO return.
          ENDLOOP.
        ENDIF.
*--*--FI customer role
        IF  cust_details-fi_cust_role IS NOT INITIAL.
          PERFORM bp_cust_link USING bpartner '' cust_details-fi_cust_role  CHANGING  lint_messages .
          LOOP AT lint_messages INTO lfs_message.
            APPEND lfs_message TO return.
          ENDLOOP.
        ENDIF.
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
        lfs_message-message_v1 = 'Error While updating customer' .
        lfs_message-message_v2 =  'please correct the record '.
        lfs_message-message_v3 = bpartner.
        APPEND lfs_message TO return.
      ENDIF.


    CATCH cx_root.


  ENDTRY.




ENDFUNCTION.

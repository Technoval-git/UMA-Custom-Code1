FUNCTION ZBP_CREATE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(BPDETAILS) LIKE  ZBP_CREATE_STRUCT STRUCTURE
*"        ZBP_CREATE_STRUCT OPTIONAL
*"  EXPORTING
*"     REFERENCE(BPARTNER) TYPE  BU_PARTNER
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------



  DATA:  gs_return             TYPE bapiret2.
  DATA: ls_head      TYPE bapibus1006_head,
        ls_central   TYPE bapibus1006_central,
        ls_person    TYPE bapibus1006_central_person,
        ls_organ     TYPE bapibus1006_central_organ,
        ls_group     TYPE bapibus1006_central_group,
        ls_address   TYPE bapibus1006_address,
        lt_tel       TYPE STANDARD TABLE OF bapiadtel,
        ls_tel       LIKE LINE OF lt_tel,
*     lt_teli      TYPE STANDARD TABLE OF bapiadtel,
        lt_fax       TYPE STANDARD TABLE OF bapiadfax,
        ls_fax       LIKE LINE OF lt_fax,
        lt_email     TYPE STANDARD TABLE OF bapiadsmtp,
        ls_email     LIKE LINE OF lt_email,
        ls_central_x TYPE bapibus1006_central_x,
        ls_person_x  TYPE bapibus1006_central_person_x,
        ls_organ_x   TYPE bapibus1006_central_organ_x.
  DATA: gt_return     TYPE STANDARD TABLE OF bapiret2,
        lint_messages TYPE bapiret2_t.
  "***********************************************************
  "*            BEGIN OF DECLARING LOCAL DATA
  "***********************************************************
  "CONSTANTS:
  "***********************************************************
  DATA:
    lobj_typedescr TYPE REF TO cl_abap_structdescr,
    lint_fields    TYPE ddfields.
  "***********************************************************
  FIELD-SYMBOLS:
<fs_field>  LIKE LINE OF lint_fields,
<wf_field>  TYPE any,
<wf_fieldx> TYPE any.
  CLEAR: ls_head , ls_head , ls_person , ls_organ,ls_group, ls_address,ls_tel,lt_tel ,lt_fax,ls_fax,lt_email,ls_email,
*        ls_msg,
        ls_central_x,
         ls_person_x,ls_organ_x,gt_return, lint_messages .
*------------------------head data
  ls_head-partn_cat      =    bpdetails-partner_cat.
  ls_head-partn_typ     =     bpdetails-tatyp.
  ls_head-partn_grp     =     bpdetails-tatyp.
  ls_head-EXTERN_NO     =     bpdetails-BP_EXT.
*-----------central data
  ls_central-searchterm1  = bpdetails-searchterm1.
  ls_central-searchterm2    = bpdetails-searchterm2.
ls_central-PARTNEREXTERNAL   =     bpdetails-BP_EXT.
*  IF bpdetails-partnerlanguage = 'EN'.
*    ls_central-partnerlanguage = 'E' .
*  ELSE.
*    ls_central-partnerlanguage = 'A' .
*  ENDIF.
  ls_central-partnerlanguage =  bpdetails-langu.
  ls_central-title_key  = bpdetails-title .
*--------------now peronnel data.
  IF bpdetails-partner_cat EQ '1'.  " Person
    ls_person-firstname             =  bpdetails-bp_name_1.
    ls_person-lastname              =  bpdetails-bp_name_2.
*  ls_person-birthname             = .
*  ls_person-middlename            = .
*  ls_person-secondname            = .
*  ls_person-title_aca1            = .
*  ls_person-title_aca2            = .
*  ls_person-title_sppl            = .
*  ls_person-prefix1               = .
*  ls_person-prefix2               = .
*  ls_person-nickname              = .
*  ls_person-initials              = .
*  ls_person-nameformat            = .
    ls_person-namcountry            = bpdetails-countrycode.
*    macro_alpha_input gs_data-ad_country ls_person-namcountry.
*  ls_person-namcountryiso         = gs_data-ad_country.
*    IF gs_data-bu_xsexm IS NOT INITIAL.
*      ls_person-sex = '2'.
*    ELSEIF gs_data-bu_xsexf IS NOT INITIAL.
*      ls_person-sex = '1'.
*    ENDIF.
*  ls_person-birthplace            = .
**    macro_alpha_input gs_data-bu_birthdt ls_person-birthdate.
*    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
*      EXPORTING
*        date_external            = gs_data-bu_birthdt
*      IMPORTING
*        date_internal            = ls_person-birthdate
*      EXCEPTIONS
*        date_external_is_invalid = 1
*        OTHERS                   = 2.
*    IF sy-subrc NE 0.
*    ENDIF.
*  ls_person-deathdate             = .
*    UNPACK gs_data-bu_marst TO ls_person-maritalstatus.
*    macro_alpha_input gs_data-bu_marst ls_person-maritalstatus.
*    ls_person-maritalstatus         = gs_data-bu_marst.
    ls_person-correspondlanguage    = bpdetails-langu.
*    ls_person-correspondlanguageiso = gs_data-bp_lang.
    ls_person-fullname              = bpdetails-bp_name_1.
*    ls_person-employer              = gs_data-bu_emplo.
*    macro_alpha_input gs_data-bu_emplo ls_person-employer.
*    ls_person-occupation            = gs_data-bu_jobgr.
*    UNPACK gs_data-bu_jobgr TO ls_person-occupation.
*    macro_alpha_input gs_data-bu_jobgr ls_person-occupation.
*    ls_person-nationality           = gs_data-bu_natio.
*  ls_person-nationalityiso        = gs_data-.
*  ls_person-countryorigin         = gs_data-.
  ELSEIF bpdetails-partner_cat EQ '2'.  " Organization
    ls_organ-name1            = bpdetails-bp_name_1.
    ls_organ-name2            = bpdetails-bp_name_2.
*  ls_organ-NAME3            = gs_data-.
*  ls_organ-NAME4            = gs_data-.
*  ls_organ-LEGALFORM        = gs_data-.
*  ls_organ-INDUSTRYSECTOR   = gs_data-.
*  ls_organ-FOUNDATIONDATE   = gs_data-.
*  ls_organ-LIQUIDATIONDATE  = gs_data-.
*  ls_organ-LOC_NO_1         = gs_data-.
*  ls_organ-LOC_NO_2         = gs_data-.
*  ls_organ-CHK_DIGIT        = gs_data-.
*  ls_organ-LEGALORG         = gs_data-.
  ELSEIF bpdetails-partner_cat EQ '3'.  " Group
    ls_group-namegroup1   = bpdetails-bp_name_1.
    ls_group-namegroup2   = bpdetails-bp_name_2.
*  ls_group-grouptype    = .
  ENDIF.
**************address.....................
  ls_address-standardaddress    = 'X'.
*  ls_address-c_o_name           = .
  ls_address-city               = bpdetails-city.
*  ls_address-district           = .
*  ls_address-regiogroup         = .
*  ls_address-postl_cod1         = gs_data-ad_post_code1.
  ls_address-postl_cod1 =        bpdetails-postalpo.
*  ls_address-postl_cod2         = .
*  ls_address-postl_cod3         = .
  ls_address-pcode1_ext         =  bpdetails-zipcode .
*  ls_address-pcode2_ext         = .
*  ls_address-pcode3_ext         = .
  ls_address-po_box             = bpdetails-postalpo.
*  ls_address-po_w_o_no          = .
*  ls_address-po_box_cit         = gs_data-ad_city_code2.
*  ls_address-po_box_reg         = gs_data-ad_po_box_reg.
*  ls_address-pobox_ctry         = gs_data-ad_country.
*  ls_address-po_ctryiso         = .
  ls_address-street             = bpdetails-streethno.
*  ls_address-str_abbr           = .
*  ls_address-house_no           = .
*  ls_address-house_no2          = .
*  ls_address-house_no3          = .
  ls_address-str_suppl1         = bpdetails-street2.
  ls_address-str_suppl2         = bpdetails-street3.
  ls_address-str_suppl3         = bpdetails-street4.
  ls_address-location           = bpdetails-street5.
*  ls_address-building           = .
*  ls_address-floor              = .
*  ls_address-room_no            = .
  ls_address-country            = bpdetails-countrycode.
*  ls_address-countryiso         = .
*  ls_address-region             = gs_data-ad_po_box_reg.
*  WRITE gs_data-ad_po_box_reg TO ls_address-region.
*  MOVE gs_data-ad_po_box_reg TO ls_address-region.
*  UNPACK gs_data-ad_po_box_reg TO ls_address-region.
  ls_address-region         = bpdetails-region.
*  ls_address-time_zone          = .
*  ls_address-taxjurcode         = .
*  ls_address-home_city          = .
*  ls_address-transpzone         = .
  ls_address-langu              = bpdetails-langu.
*  ls_address-languiso           = .
*  ls_address-comm_type          = .
*  ls_address-extaddressnumber   = .
*  ls_address-dont_use_p         = .
*  ls_address-dont_use_s         = .
*  ls_address-move_date          = .
*  ls_address-move_address       = .
*  ls_address-validfromdate      = .
*  ls_address-validtodate        = .
*  ls_address-move_addr_guid     = .
*  ls_address-city_no            = .
*  ls_address-distrct_no         = .
*  ls_address-chckstatus         = .
*  ls_address-pboxcit_no         = .
*  ls_address-street_no          = .
*  ls_address-homecityno         =   .
*  ls_address-po_box_lobby       = .
*  ls_address-deli_serv_type     = .
*  ls_address-deli_serv_number   = .
*  ls_address-county             = gs_data-.
*  ls_address-county_no          = .
*  ls_address-township           = .
*  ls_address-township_no        = .

  CLEAR ls_tel.
  ls_tel-country      = bpdetails-countrycode.
*  ls_tel-countryiso   = gs_data-ad_country.
  ls_tel-std_no       = 'X'.
  ls_tel-telephone    = bpdetails-telephone.
  ls_tel-extension    = bpdetails-extension.
*  ls_tel-tel_no       = gs_data-.
*  ls_tel-caller_no    = gs_data-.
*  ls_tel-std_recip    = gs_data-.
*  ls_tel-r_3_user     = gs_data-.
*  ls_tel-home_flag    = gs_data-.
*  ls_tel-consnumber   = gs_data-.
*  ls_tel-errorflag    = gs_data-.
*  ls_tel-flg_nouse    = gs_data-.
*  ls_tel-valid_from   = ''.
*  ls_tel-valid_to     = gs_data-.
  APPEND ls_tel TO lt_tel.
  IF bpdetails-mobilephone IS NOT INITIAL.
    CLEAR ls_tel.
    ls_tel-country      = bpdetails-countrycode.
    ls_tel-telephone    = bpdetails-mobilephone.
    ls_tel-std_recip    = 'X'.
    ls_tel-r_3_user     = '3'.
    APPEND ls_tel TO lt_tel.
  ENDIF.
*  IF gs_data-a2_mob2 IS NOT INITIAL.
*    CLEAR ls_tel.
*    ls_tel-country      = BPDETAILS-ad_country(3).
*    ls_tel-telephone    = BPDETAILS-a2_mob2.
*    ls_tel-std_recip    = gc_x.
*    ls_tel-r_3_user     = '2'.
*    APPEND ls_tel TO lt_tel.
*  ENDIF.
  IF bpdetails-faxnumber IS NOT INITIAL.
    CLEAR ls_fax.
    ls_fax-country     = bpdetails-countrycode.
*  ls_fax-countryiso = gs_data-ad_country.
    ls_fax-std_no      = 'X'.
    ls_fax-fax         = bpdetails-faxnumber.
*  ls_fax-EXTENSION  = gs_data-.
    ls_fax-fax_no      = bpdetails-faxnumber.
*  ls_fax-sender_no  = gs_data-.
*  ls_fax-fax_group  = gs_data-.
*  ls_fax-std_recip  = gs_data-.
*  ls_fax-r_3_user   = gs_data-.
*  ls_fax-home_flag  = gs_data-.
*  ls_fax-consnumber = gs_data-.
*  ls_fax-errorflag  = gs_data-.
*  ls_fax-flg_nouse  = gs_data-.
*  ls_fax-valid_from = gs_data-.
*  ls_fax-valid_to   = gs_data-.
    APPEND ls_fax TO lt_fax.
  ENDIF.
  IF bpdetails-email IS NOT INITIAL.
    CLEAR ls_email.
    ls_email-std_no     = 'X'.
    ls_email-e_mail     = bpdetails-email.
*  ls_email-EMAIL_SRCH = gs_data-.
*  ls_email-STD_RECIP  = gs_data-.
*  ls_email-R_3_USER   = gs_data-.
    ls_email-encode     = '2'.
*  ls_email-TNEF       = gs_data-.
*  ls_email-HOME_FLAG  = gs_data-.
*  ls_email-CONSNUMBER = gs_data-.
*  ls_email-ERRORFLAG  = gs_data-.
*  ls_email-FLG_NOUSE  = gs_data-.
*  ls_email-VALID_FROM = gs_data-.
*  ls_email-VALID_TO   = gs_data-.
    APPEND ls_email TO lt_email.
  ENDIF.

  REFRESH gt_return.
*    CLEAR gs_return.
  CLEAR bpartner.
  CALL FUNCTION 'BAPI_BUPA_CREATE_FROM_DATA'
    EXPORTING
*     BUSINESSPARTNEREXTERN   =
      partnercategory         = ls_head-partn_cat
      partnergroup            = ls_head-partn_typ
      centraldata             = ls_central
      centraldataperson       = ls_person
      centraldataorganization = ls_organ
      centraldatagroup        = ls_group
      addressdata             = ls_address
    IMPORTING
      businesspartner         = bpartner
    TABLES
      telefondata             = lt_tel
      faxdata                 = lt_fax
*     TELETEXDATA             =
*     TELEXDATA               =
      e_maildata              = lt_email
*     RMLADDRESSDATA          =
*     X400ADDRESSDATA         =
*     RFCADDRESSDATA          =
*     PRTADDRESSDATA          =
*     SSFADDRESSDATA          =
*     URIADDRESSDATA          =
*     PAGADDRESSDATA          =
*     ADDRESSNOTES            =
*     COMMUNICATIONNOTES      =
*     COMMUNICATIONUSAGE      =
      telefondatanonaddress   = lt_tel
      faxdatanonaddress       = lt_fax
*     TELETEXDATANONADDRESS   =
*     TELEXDATANONADDRESS     =
      e_maildatanonaddress    = lt_email
*     RMLADDRESSDATANONADDRESS           =
*     X400ADDRESSDATANONADDRESS          =
*     RFCADDRESSDATANONADDRESS           =
*     PRTADDRESSDATANONADDRESS           =
*     SSFADDRESSDATANONADDRESS           =
*     URIADDRESSDATANONADDRESS           =
*     PAGADDRESSDATANONADDRESS           =
*     COMMUNICATIONNOTESNONADDRESS       =
*     COMMUNICATIONUSAGENONADDRESS       =
      return                  = gt_return
*     ADDRESSDUPLICATES       =
    .
  CLEAR gs_return.
  LOOP AT gt_return
    INTO gs_return
    WHERE type CA 'EA'.
    EXIT.
  ENDLOOP.
  APPEND LINES OF   gt_return TO return.
  IF gs_return-type CN 'EA'.
    CLEAR gs_return.
    gs_return-type = 'S'.
    gs_return-id = '00'.
    gs_return-number = '398'.
    gs_return-message_v1 = 'BP'.
    gs_return-message_v2 = bpartner.
    gs_return-message_v3 = 'Created'.
    APPEND gs_return TO return.
    CLEAR gs_return.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = 'X'
      IMPORTING
        return = gs_return.

    "* Add VAT/TAX Registration number
    "*****************************************************

    "*********************************
    " unlock Business Partner
    "*********************************
    IF bpartner IS NOT INITIAL.
      DATA lwf_iv_partner          TYPE bu_partner.
      DATA lit_et_return           TYPE STANDARD TABLE OF bapiret2.
*
      lwf_iv_partner  = bpartner.
*
*      CALL FUNCTION 'BUPA_DEQUEUE'
*        EXPORTING
*          iv_partner = lwf_iv_partner
**         IV_PARTNER_GUID           = IV_PARTNER_GUID
**         IV_CHECK_NOT_NUMBER       = IV_CHECK_NOT_NUMBER
*        TABLES
*          et_return  = lit_et_return.
*
*      IF sy-subrc <> 0.
*
*      ENDIF.
    ENDIF.
    IF bpdetails-vat_cat  IS NOT INITIAL AND bpdetails-vat_number IS NOT INITIAL.

*DATA BUSINESSPARTNER TYPE BAPIBUS1006_HEAD-BPARTNER.
      DATA lwf_taxtype         TYPE bapibus1006tax-taxtype.
      DATA lwf_taxnumber       TYPE bapibus1006tax-taxnumber.
*DATA lint_RETURN          TYPE STANDARD TABLE OF BAPIRET2.

      lwf_taxnumber = bpdetails-vat_number.
      lwf_taxtype = bpdetails-vat_cat.
      CLEAR: gt_return.
      CALL FUNCTION 'BAPI_BUPA_TAX_ADD'
        EXPORTING
          businesspartner = bpartner
          taxtype         = lwf_taxtype
          taxnumber       = lwf_taxnumber
        TABLES
          return          = gt_return.

      APPEND LINES OF   gt_return TO return.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = gs_return.

        CLEAR gs_return.
        gs_return-type = 'S'.
        gs_return-id = '00'.
        gs_return-number = '398'.
        gs_return-message_v1 = 'BP'.
        gs_return-message_v2 = bpartner.
        gs_return-message_v3 = 'TAX codes added'.
        APPEND gs_return TO return.
      ENDIF.
*      PERFORM f_bal_add_message_log_t
*          USING gt_return 2.
*      CLEAR gs_return.
*      LOOP AT gt_return
*        INTO gs_return
*        WHERE type CA 'EA'.
*        " Add to error file
*        CONCATENATE 'ADD_VAT_License:' gs_return-message INTO gs_err-msg SEPARATED BY space.
**      lv_error = 'X'.
*
*        CLEAR ls_msg.
*        ls_msg-msgty = 'E'.
*        ls_msg-msgid = gs_return-id.
*        ls_msg-msgno = gs_return-number.
*        ls_msg-msgv1 = gs_return-message_v1.
*        ls_msg-msgv2 = gv_bpartner.
*        ls_msg-msgv3 = gs_err-msg.
*        ls_msg-detlevel = 2.
*        PERFORM f_bal_add_message_log USING ls_msg.
*        EXIT.
*      ENDLOOP.
    ENDIF.
    "*********************************
    " unlock Business Partner
    "*********************************
    IF bpartner IS NOT INITIAL.
*      DATA lwf_iv_partner          TYPE bu_partner.
*      DATA lit_et_return           TYPE STANDARD TABLE OF bapiret2.
*      lwf_iv_partner  = bpartner.
*
*      CALL FUNCTION 'BUPA_DEQUEUE'
*        EXPORTING
*          iv_partner = lwf_iv_partner
**         IV_PARTNER_GUID           = IV_PARTNER_GUID
**         IV_CHECK_NOT_NUMBER       = IV_CHECK_NOT_NUMBER
*        TABLES
*          et_return  = lit_et_return.
*
*      IF sy-subrc <> 0.
*
*      ENDIF.
    ENDIF.
*----Now add arabic address......
    IF bpdetails-bp_name_1_ar IS NOT INITIAL OR bpdetails-bp_name_2_ar IS NOT INITIAL.

      DATA lwf_businesspartner        TYPE bapibus1006_head-bpartner.
      DATA lit_bapiadversorg          TYPE STANDARD TABLE OF bapiad1vd.
      DATA lit_bapiadverspers         TYPE STANDARD TABLE OF bapiad2vd.
      DATA lit_bapiadversorg_x        TYPE STANDARD TABLE OF bapiad1vdx.
      DATA lit_bapiadverspers_x       TYPE STANDARD TABLE OF bapiad2vdx.
      DATA lit_return                 TYPE STANDARD TABLE OF bapiret2.
      DATA: ls_return LIKE LINE OF lit_return.
      DATA:
        lfs_bapiadversorg    LIKE LINE OF lit_bapiadversorg,
        lfs_bapiadverspers   LIKE LINE OF lit_bapiadverspers,
        lfs_bapiadversorg_x  LIKE LINE OF lit_bapiadversorg_x,
        lfs_bapiadverspers_x LIKE LINE OF lit_bapiadverspers_x.
      DATA lfs_msg TYPE bal_s_msg.
      CHECK bpartner IS NOT INITIAL.
*---now pass the required fields...
      "**********************
      " map fields
      "**********************
      lwf_businesspartner = bpartner.
      "check if bp is company
      IF bpdetails-title_ar = '0003'.
        lfs_bapiadversorg-addr_vers = 'A'.
        lfs_bapiadversorg-title =         bpdetails-title_ar.
        lfs_bapiadversorg-name         =  bpdetails-bp_name_1_ar.
        lfs_bapiadversorg-name_2       =  bpdetails-bp_name_2_ar.
        lfs_bapiadversorg-sort1        =  bpdetails-searchterm1_ar.  " Arabic Search Term 1
*    lfs_bapiadversorg-sort2        = BPDETAILS-bp_sterm2.  " Arabic Search Term 1
        lfs_bapiadversorg-str_suppl3   = bpdetails-street4_ar. " Arabic Street 4
        lfs_bapiadversorg-str_suppl2   = bpdetails-street3_ar. " Arabic Street 3
        lfs_bapiadversorg-location     = bpdetails-street5_ar. " Arabic Street 5 LOCATION
        lfs_bapiadversorg-str_suppl1   = bpdetails-street2_ar. " Arabic Street 2
        lfs_bapiadversorg-street       = bpdetails-streethno_ar. " Arabic street /---House number
        lfs_bapiadversorg-city         = bpdetails-city_ar.   " Arabic City
*    lfs_bapiadversorg-county       = gs_data-ad_country.   " Arabic City

        "************ END OF DECLARING LOCAL DATA ******************
        lobj_typedescr  ?= cl_abap_structdescr=>describe_by_data( lfs_bapiadverspers ).
        lint_fields = lobj_typedescr->get_ddic_field_list( ).
        LOOP AT lint_fields ASSIGNING <fs_field>.
          ASSIGN COMPONENT <fs_field>-fieldname OF STRUCTURE lfs_bapiadverspers TO <wf_field>.
          IF sy-subrc = 0.
            IF <wf_field> IS NOT INITIAL.
              ASSIGN COMPONENT <fs_field>-fieldname OF STRUCTURE lfs_bapiadverspers_x TO <wf_fieldx>.
              IF sy-subrc = 0.
<wf_fieldx> = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
        lfs_bapiadversorg_x-updateflag = 'I'.
        APPEND lfs_bapiadversorg TO lit_bapiadversorg.
        APPEND lfs_bapiadversorg_x TO lit_bapiadversorg_x.
      ELSE.
        lfs_bapiadverspers-addr_vers = 'A'.
        lfs_bapiadverspers-title_p =       bpdetails-title_ar.
        lfs_bapiadverspers-firstname         = bpdetails-bp_name_1_ar.
        lfs_bapiadverspers-lastname       = bpdetails-bp_name_2_ar.
        lfs_bapiadverspers-sort1_p        = bpdetails-searchterm1_ar.  " Arabic Search Term 1
*    lfs_bapiadverspers-sort2_p        = gs_data-bp_sterm2.  " Arabic Search Term 1
        lfs_bapiadverspers-str_suppl3   = bpdetails-street4_ar. " Arabic Street 4
        lfs_bapiadverspers-str_suppl2   = bpdetails-street3_ar. " Arabic Street 3
        lfs_bapiadverspers-location     = bpdetails-street5_ar." Arabic Street 5 LOCATION
        lfs_bapiadverspers-str_suppl1   = bpdetails-street2_ar. " Arabic Street 2
        lfs_bapiadverspers-street       = bpdetails-streethno_ar. " Arabic street /---House number
        lfs_bapiadverspers-city         = bpdetails-city_ar.   " Arabic City
*    lfs_bapiadverspers-county       = gs_data-ad_country.   " Arabic City
*    PERFORM f_update_datax_flag
*      USING lfs_bapiadverspers
*      CHANGING lfs_bapiadverspers_x.
        "************ END OF DECLARING LOCAL DATA ******************
        lobj_typedescr  ?= cl_abap_structdescr=>describe_by_data( lfs_bapiadverspers ).
        lint_fields = lobj_typedescr->get_ddic_field_list( ).
        LOOP AT lint_fields ASSIGNING <fs_field>.
          ASSIGN COMPONENT <fs_field>-fieldname OF STRUCTURE lfs_bapiadverspers TO <wf_field>.
          IF sy-subrc = 0.
            IF <wf_field> IS NOT INITIAL.
              ASSIGN COMPONENT <fs_field>-fieldname OF STRUCTURE lfs_bapiadverspers_x TO <wf_fieldx>.
              IF sy-subrc = 0.
<wf_fieldx> = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
        lfs_bapiadverspers_x-updateflag = 'I'.
        APPEND lfs_bapiadverspers TO lit_bapiadverspers.
        APPEND lfs_bapiadverspers_x TO lit_bapiadverspers_x.
      ENDIF.
*---
      CALL FUNCTION 'BAPI_BUPA_ADDRESS_CHANGE'
        EXPORTING
          businesspartner  = bpartner
*         ADDRESSGUID      = ADDRESSGUID
*         ADDRESSDATA      = ADDRESSDATA
*         ADDRESSDATA_X    = ADDRESSDATA_X
*         DUPLICATE_MESSAGE_TYPE       = DUPLICATE_MESSAGE_TYPE
*         ACCEPT_ERROR     = ' '
        TABLES
*         BAPIADTEL        = BAPIADTEL
*         BAPIADFAX        = BAPIADFAX
*         BAPIADTTX        = BAPIADTTX
*         BAPIADTLX        = BAPIADTLX
*         BAPIADSMTP       = BAPIADSMTP
*         BAPIADRML        = BAPIADRML
*         BAPIADX400       = BAPIADX400
*         BAPIADRFC        = BAPIADRFC
*         BAPIADPRT        = BAPIADPRT
*         BAPIADSSF        = BAPIADSSF
*         BAPIADURI        = BAPIADURI
*         BAPIADPAG        = BAPIADPAG
*         BAPIAD_REM       = BAPIAD_REM
*         BAPICOMREM       = BAPICOMREM
*         ADDRESSUSAGE     = ADDRESSUSAGE
          bapiadversorg    = lit_bapiadversorg
          bapiadverspers   = lit_bapiadverspers
*         BAPIADUSE        = BAPIADUSE
*         BAPIADTEL_X      = BAPIADTEL_X
*         BAPIADFAX_X      = BAPIADFAX_X
*         BAPIADTTX_X      = BAPIADTTX_X
*         BAPIADTLX_X      = BAPIADTLX_X
*         BAPIADSMT_X      = BAPIADSMT_X
*         BAPIADRML_X      = BAPIADRML_X
*         BAPIADX40_X      = BAPIADX40_X
*         BAPIADRFC_X      = BAPIADRFC_X
*         BAPIADPRT_X      = BAPIADPRT_X
*         BAPIADSSF_X      = BAPIADSSF_X
*         BAPIADURI_X      = BAPIADURI_X
*         BAPIADPAG_X      = BAPIADPAG_X
*         BAPIAD_RE_X      = BAPIAD_RE_X
*         BAPICOMRE_X      = BAPICOMRE_X
*         ADDRESSUSAGE_X   = ADDRESSUSAGE_X
          bapiadversorg_x  = lit_bapiadversorg_x
          bapiadverspers_x = lit_bapiadverspers_x
*         BAPIADUSE_X      = BAPIADUSE_X
          return           = lit_return
*         ADDRESSDUPLICATES            = ADDRESSDUPLICATES
        .
    ENDIF.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
        IMPORTING
          return = gs_return.
      CLEAR gs_return.
      gs_return-type = 'S'.
      gs_return-id = '00'.
      gs_return-number = '398'.
      gs_return-message_v1 = 'BP'.
      gs_return-message_v2 = bpartner.
      gs_return-message_v3 = 'Address Changed'.
      APPEND gs_return TO return.
    ENDIF.
    APPEND LINES OF   lit_return TO return.

    lwf_iv_partner  = bpartner.
    CALL FUNCTION 'BUPA_DEQUEUE'
      EXPORTING
        iv_partner = lwf_iv_partner
*       IV_PARTNER_GUID           = IV_PARTNER_GUID
*       IV_CHECK_NOT_NUMBER       = IV_CHECK_NOT_NUMBER
      TABLES
        et_return  = lit_et_return.
*
    IF sy-subrc <> 0.
    ENDIF.

  ELSE.
  ENDIF.



ENDFUNCTION.

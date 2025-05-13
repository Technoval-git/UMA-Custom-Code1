*&---------------------------------------------------------------------*
*& Report ZRVSS_SALES_SERVICE_INVOICE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrvss_sales_service_invoice.

* declaration of data
INCLUDE ydbe_serv_inv_drvr_top.

*Print forms
INCLUDE ydbe_serv_inv_drvr_frm.


*DBM Constants
*INCLUDE /dbm/constants.
INCLUDE /dbe/constants.
*---------------------------------------------------------------------*
*       FORM ENTRY
*---------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  DATA: lf_retcode TYPE sy-subrc.
  CLEAR retcode.
  xscreen = us_screen.
  PERFORM processing USING us_screen
                     CHANGING lf_retcode.
  IF lf_retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.

ENDFORM.                    "ENTRY
*---------------------------------------------------------------------*
*       FORM PROCESSING                                               *
*---------------------------------------------------------------------*
FORM processing USING proc_screen
                CHANGING cf_retcode.

  DATA: ls_print_data_to_read TYPE lbbil_print_data_to_read.
  DATA: ls_bil_invoice TYPE lbbil_invoice.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.
  DATA: ls_dlv-land           LIKE vbrk-land1.
  DATA: ls_job_info           TYPE ssfcrescl.
  DATA: lv_vbeln_no           TYPE vbeln_va.
  DATA: lv_arabic             TYPE crmt_boolean.
  DATA: lv_billing TYPE vbeln_vf,
        lv_string  TYPE string.

* SmartForm from customizing table TNAPR
  lf_formname = tnapr-sform.

* BEGIN: Country specific extension for Hungary
  DATA: lv_ccnum TYPE idhuccnum,
        lv_error TYPE c.

* If a valid entry exists for the form in customizing view
* IDHUBILLINGOUT then the localized output shall be used.
  SELECT SINGLE ccnum INTO lv_ccnum FROM idhubillingout WHERE
    kschl = nast-kschl.

  IF sy-subrc EQ 0.
    IF lv_ccnum IS INITIAL.
      lv_ccnum = 1.
    ENDIF.

    IF ( nast-delet IS INITIAL OR nast-dimme IS INITIAL ).

      nast-delet = 'X'.
      nast-dimme = 'X'.

      sy-msgid = 'IDFIHU'.
      sy-msgty = 'W'.
      sy-msgno = 201.
      sy-msgv1 = nast-objky.

      CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
        EXPORTING
          msg_arbgb = sy-msgid
          msg_nr    = sy-msgno
          msg_ty    = sy-msgty
          msg_v1    = sy-msgv1
          msg_v2    = ''
          msg_v3    = ''
          msg_v4    = ''
        EXCEPTIONS
          OTHERS    = 1.
    ENDIF.
  ELSE.
    CLEAR lv_ccnum.
  ENDIF.
* END: Country specific extension for Hungary

** determine print data
*  PERFORM set_print_data_to_read USING    lf_formname
*                                 CHANGING ls_print_data_to_read
*                                 cf_retcode.
*
*  IF cf_retcode = 0.
** select print data
*    PERFORM get_data USING    ls_print_data_to_read
*                     CHANGING ls_addr_key
*                              ls_dlv-land
*                              ls_bil_invoice
*                              cf_retcode.
*  ENDIF.
*
*  IF cf_retcode = 0.
*    PERFORM set_print_param USING    ls_addr_key
*                                     ls_dlv-land
*                            CHANGING ls_control_param
*                                     ls_composer_param
*                                     ls_recipient
*                                     ls_sender
*                                     cf_retcode.
*  ENDIF.
**
  lv_billing = nast-objky.

*  CONCATENATE 'DBM' lv_vbeln_no '%' INTO lv_string.
*
*  SELECT SINGLE vbeln FROM vbrk INTO ( lv_billing )
*      WHERE vbtyp = 'M'
*        AND zuonr LIKE lv_string
*        AND fksto = ''.

*get data to print the form
  DATA lv_all TYPE boolean.
  IF nast-kappl = 'V3'.
    lv_all = abap_false.
  ELSE.
    lv_all = abap_true.
  ENDIF.

*  IF nast-kschl = 'YS13'.
*    lv_arabic = abap_true.
*  ENDIF.
  CLEAR: gt_header           ,
         it_labor_details    ,
         it_parts_details    ,
         it_consumab_details ,
         it_addition_details ,
         lv_tax_perc.

  CALL FUNCTION 'YDBE_SERV_INV_DATA'
    EXPORTING
      iv_billing_doc      = lv_billing
      iv_sf_show          = abap_false
      iv_all              = lv_all
      iv_arabic           = lv_arabic
      iv_langu            = nast-spras
    IMPORTING
      et_header           = gt_header
      et_labor_details    = it_labor_details
      et_parts_details    = it_parts_details
      et_consumab_details = it_consumab_details
      et_addition_details = it_addition_details
      ev_tax_perc         = lv_tax_perc.

  CLEAR:  gs_company, gs_customer.
  CALL FUNCTION 'YDBE_INV_HEAD_PARTNR_ADRS'
    EXPORTING
      lv_invoice_no = lv_billing
    IMPORTING
      es_seller     = gs_company
      es_buyer      = gs_customer.

  IF lv_tax_perc IS INITIAL.
    lv_tax_perc = '0'.
  ENDIF.
  DATA: lv_tax_int TYPE int4.
  lv_tax_int = lv_tax_perc.
  lv_tax_perc = lv_tax_int.

  READ TABLE gt_header INTO gs_header INDEX 1.
  READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
  SELECT SINGLE spart FROM vbrp INTO gs_header-spart
  WHERE vbeln = lv_billing
    AND posnr = '000010'.
  IF sy-subrc = 0.
    cf_retcode = 0.
  ELSE.
    cf_retcode = 4.
  ENDIF.

  IF cf_retcode = 0.
* determine Adope Form function module for invoice
    CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
        i_name     = lf_formname
      IMPORTING
        e_funcname = lf_fm_name.
    IF sy-subrc <> 0.
*   error handling
      cf_retcode = sy-subrc.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

  IF cf_retcode = 0.
    PERFORM check_repeat.
    IF ls_composer_param-tdcopies EQ 0.
      nast_anzal = 1.
    ELSE.
      nast_anzal = ls_composer_param-tdcopies.
    ENDIF.
    ls_composer_param-tdcopies = 1.

    DO nast_anzal TIMES.
* In case of repetition only one time archiving
      IF sy-index > 1 AND nast-tdarmod = 3.
        nast_tdarmod = nast-tdarmod.
        nast-tdarmod = 1.
        ls_composer_param-tdarmod = 1.
      ENDIF.
      IF sy-index NE 1 AND repeat IS INITIAL.
        repeat = 'X'.
      ENDIF.
* BEGIN: Country specific extension for Hungary
      IF lv_ccnum IS NOT INITIAL.
        IF nast-repid IS INITIAL.
          nast-repid = 1.
        ELSE.
          nast-repid = nast-repid + 1.
        ENDIF.
        nast-pfld1 = lv_ccnum.
      ENDIF.

* Language and country setting
      fp_docparams-langu   = nast-spras.
*      fp_docparams-country = 'US'.
* Sets the output parameters and opens the spool job
      " tech1.
      fp_outputparams-nodialog = 'X'.
      fp_outputparams-preview = 'X'.
*      IF nast-spras = 'A'.
      fp_outputparams-reqnew = 'X'.
      fp_outputparams-reqimm = 'X'.
      fp_outputparams-reqdel = 'X'.
      fp_outputparams-device = 'PRINTER'.
      fp_outputparams-dest = 'PDF1'.
*      ENDIF.
      CALL FUNCTION 'FP_JOB_OPEN'
        CHANGING
          ie_outputparams = fp_outputparams
        EXCEPTIONS
          cancel          = 1
          usage_error     = 2
          system_error    = 3
          internal_error  = 4
          OTHERS          = 5.
*-- Adding code to check ZATCA accepted or not..
      DATA: lv_source_key TYPE edoc_source_key,
            lv_edoc_guid  TYPE edoc_guid,
            lv_approve,
            lv_title_en   TYPE char30,
            lv_title_ar   TYPE char30,
            lv_person,
            lv_cust_id    TYPE bu_partner.

      CLEAR: lv_source_key ,lv_edoc_guid, lv_approve,lv_title_en,lv_title_ar,lv_person,lv_cust_id.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gs_header-invoice_no                " C field
        IMPORTING
          output = gs_header-invoice_no.

      cl_edoc_source_sd_invoice=>pack_key(
        EXPORTING
          iv_vbeln = gs_header-invoice_no
        IMPORTING
          ev_key   = lv_source_key ).

      lv_cust_id = gs_header-cust_id.

      CALL FUNCTION 'YEDOC_INV_TITLE_STATUS'
        EXPORTING
          source_key = lv_source_key
          partner    = lv_cust_id
        IMPORTING
          approved   = lv_approve
          title_en   = lv_title_en
          title_ar   = lv_title_ar
          person     = lv_person.

*  CONCATENATE  lv_title_en lv_title_ar INTO  SEPARATED BY space.
      IF lv_title_ar IS INITIAL AND lv_title_en IS INITIAL.
        lv_title_en = 'Tax Invoice'.
        lv_title_ar = 'فاتورة ضريبية'.
      ENDIF.
*      IF lv_approve = 'X'. "added condition for E-invoice status

      " checking if the invoice has been printed|cd 9620
      DATA:
        repeat_text  TYPE string,
        ts_ydbm_invc TYPE ydbe_srvinv_prnt.
      ts_ydbm_invc-kschl = nast-kschl.
      ts_ydbm_invc-vbeln = gs_header-invoice_no.
      SELECT SINGLE * FROM ydbe_srvinv_prnt INTO ts_ydbm_invc WHERE kschl = nast-kschl AND vbeln = gs_header-invoice_no.
      IF sy-subrc <> 0.
        repeat = ''.
        ts_ydbm_invc-kschl = nast-kschl.
        ts_ydbm_invc-vbeln = gs_header-invoice_no.
        ts_ydbm_invc-usnam = sy-uname.
        ts_ydbm_invc-erdat = sy-datum.
        ts_ydbm_invc-erzet = sy-uzeit.
        MODIFY ydbe_srvinv_prnt FROM ts_ydbm_invc.
      ELSE.
        repeat = 'X'.
        repeat_text = 'Copy'.
      ENDIF.

      CALL FUNCTION lf_fm_name
        EXPORTING
          /1bcdwb/docparams = fp_docparams
          is_header         = gs_header
          it_item_labour    = it_labor_details
          it_item_parts     = it_parts_details
          it_item_consumab  = it_consumab_details
          it_item_addition  = it_addition_details
          iv_division       = gs_header-division
          iv_tax_perc       = lv_tax_perc
          is_customer       = gs_customer
          is_company        = gs_company
          iv_title_ar       = lv_title_ar
          iv_title_en       = lv_title_en
          repeat_text       = repeat_text
*         gv_comp           =
*       IMPORTING
*         /1BCDWB/FORMOUTPUT       = /1BCDWB/FORMOUTPUT
        EXCEPTIONS
          usage_error       = 1
          system_error      = 2
          internal_error    = 3.
      IF sy-subrc <> 0.
*        *   error handling
        cf_retcode = sy-subrc.
        PERFORM protocol_update.
      ENDIF.
*      ELSE.
**        MESSAGE 'Invoice cannot be printed as edocument not accepted by ZATCA ' TYPE 'E'.
*        MESSAGE e000(zedosa). "Invoice can't be printed until ZATCA approved. Please try later
*      ENDIF.

*&---- Close the spool job
      CALL FUNCTION 'FP_JOB_CLOSE'
*    IMPORTING
*     E_RESULT             =
        EXCEPTIONS
          usage_error    = 1
          system_error   = 2
          internal_error = 3
          OTHERS         = 4.
      IF sy-subrc <> 0.
*        *   error handling
        cf_retcode = sy-subrc.
        PERFORM protocol_update.
      ENDIF.
    ENDDO.

  ENDIF.

ENDFORM.                    "PROCESSING

*----------------------------------------------------------------------*
*   INCLUDE RLB_INVOICE_DATA_DECLARE                                   *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE RLB_INVOICE_DATA_DECLARE                                   *
*----------------------------------------------------------------------*

*INCLUDE rvadtabl.

*DATA:   retcode   LIKE sy-subrc.         "Returncode
*DATA:   xscreen(1) TYPE c.               "Output on printer or screen
*DATA:   repeat(1) TYPE c.
*DATA: nast_anzal LIKE nast-anzal.      "Number of outputs (Orig. + Cop.)
*DATA: nast_tdarmod LIKE nast-tdarmod.  "Archiving only one time

* current language for read buffered.
*DATA: gf_language LIKE sy-langu.

*DATA:
*      it_header           TYPE yprfinv_head_vss_tt,
*      gt_header           TYPE yprfinv_head_vss_tt,
*      gs_header           TYPE yprfinv_head_jet_st,
*      it_labor_details    TYPE yserv_inv_item_pdf_tt,
*      it_parts_details    TYPE yserv_inv_item_pdf_tt,
*      it_consumab_details TYPE yserv_inv_item_pdf_tt,
*      it_addition_details TYPE yserv_inv_item_pdf_tt,
*      lv_tax_perc         TYPE string,
*      ts_ctrlparms        TYPE ssfctrlop,
*      gs_customer         TYPE zsd_inv_head_mid,
*      gs_company          TYPE zsd_inv_head_mid.
*DATA:fp_docparams    TYPE sfpdocparams,    " Structure  SFPDOCPARAMS Short Description  Form Parameters for Form Processing
*     fp_outputparams TYPE sfpoutputparams.

*----------------------------------------------------------------------*
*   INCLUDE RLB_PRINT_FORMS                                            *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

*FORM protocol_update.
*
*  CHECK xscreen = space.
*  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
*    EXPORTING
*      msg_arbgb = syst-msgid
*      msg_nr    = syst-msgno
*      msg_ty    = syst-msgty
*      msg_v1    = syst-msgv1
*      msg_v2    = syst-msgv2
*      msg_v3    = syst-msgv3
*      msg_v4    = syst-msgv4
*    EXCEPTIONS
*      OTHERS    = 1.
*
*ENDFORM.                    "PROTOCOL_UPDATE

*&---------------------------------------------------------------------*
*&      Form  ADD_SMFRM_PROT
*&---------------------------------------------------------------------*
*FORM add_smfrm_prot.
*
*  DATA: lt_errortab             TYPE tsferror.
** DATA: LF_MSGNR                TYPE SY-MSGNO.
*  FIELD-SYMBOLS: <fs_errortab>  TYPE LINE OF tsferror.
*
** get smart form protocoll
*  CALL FUNCTION 'SSF_READ_ERRORS'
*    IMPORTING
*      errortab = lt_errortab.
*
** add smartform protocoll to nast protocoll
*  LOOP AT lt_errortab ASSIGNING <fs_errortab>.
**   CLEAR LF_MSGNR.
**   LF_MSGNR = <FS_ERRORTAB>-ERRNUMBER.
*    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
*      EXPORTING
*        msg_arbgb = <fs_errortab>-msgid
**       MSG_NR    = LF_MSGNR
*        msg_nr    = <fs_errortab>-msgno
*        msg_ty    = <fs_errortab>-msgty
*        msg_v1    = <fs_errortab>-msgv1
*        msg_v2    = <fs_errortab>-msgv2
*        msg_v3    = <fs_errortab>-msgv3
*        msg_v4    = <fs_errortab>-msgv4
*      EXCEPTIONS
*        OTHERS    = 1.
*  ENDLOOP.
*
*ENDFORM.                               " ADD_SMFRM_PROT

*&---------------------------------------------------------------------*
*&      Form  SET_PRINT_PARAM
*&---------------------------------------------------------------------*
*FORM set_print_param USING    is_addr_key LIKE addr_key
*                              is_dlv-land LIKE vbrk-land1
*                     CHANGING cs_control_param TYPE ssfctrlop
*                              cs_composer_param TYPE ssfcompop
*                              cs_recipient TYPE  swotobjid
*                              cs_sender TYPE  swotobjid
*                              cf_retcode TYPE sy-subrc.
*
*  DATA: ls_itcpo     TYPE itcpo.
*  DATA: lf_repid     TYPE sy-repid.
*  DATA: lf_device    TYPE tddevice.
*  DATA: ls_recipient TYPE swotobjid.
*  DATA: ls_sender    TYPE swotobjid.
*
*  lf_repid = sy-repid.
*
*  CALL FUNCTION 'WFMC_PREPARE_SMART_FORM'
*    EXPORTING
*      pi_nast       = nast
*      pi_country    = is_dlv-land
*      pi_addr_key   = is_addr_key
*      pi_repid      = lf_repid
*      pi_screen     = xscreen
*    IMPORTING
*      pe_returncode = cf_retcode
*      pe_itcpo      = ls_itcpo
*      pe_device     = lf_device
*      pe_recipient  = cs_recipient
*      pe_sender     = cs_sender.
*
*  IF cf_retcode = 0.
*    MOVE-CORRESPONDING ls_itcpo TO cs_composer_param.
**   CS_CONTROL_PARAM-NO_OPEN
**   CS_CONTROL_PARAM-NO_CLOSE
*    cs_control_param-device      = lf_device.
*    cs_control_param-no_dialog   = 'X'.
*    cs_control_param-preview     = xscreen.
*    cs_control_param-getotf      = ls_itcpo-tdgetotf.
*    cs_control_param-langu       = nast-spras.
**   CS_CONTROL_PARAM-REPLANGU1
**   CS_CONTROL_PARAM-REPLANGU2
**   CS_CONTROL_PARAM-REPLANGU3
**   CS_CONTROL_PARAM-STARTPAGE
*  ENDIF.
*ENDFORM.                               " SET_PRINT_PARAM
*&---------------------------------------------------------------------*
*&      Form  CHECK_REPEAT
*&---------------------------------------------------------------------*
*FORM check_repeat .
*
*  CLEAR repeat.
*  SELECT * INTO *nast FROM nast WHERE kappl = nast-kappl
*                                AND   objky = nast-objky
*                                AND   kschl = nast-kschl
*                                AND   parnr = nast-parnr
*                                AND   parvw = nast-parvw
*                                AND   nacha BETWEEN '1' AND '5'.
*    IF *nast-vstat = '1'.
*      repeat = 'X'.
*    ENDIF.
*  ENDSELECT.
*
*
*ENDFORM.                    " CHECK_REPEAT
*&---------------------------------------------------------------------*
*&      Form  protocol_update_spool
*&---------------------------------------------------------------------*
*       The messages are collected for the processing protocol
*----------------------------------------------------------------------*
*FORM protocol_update_spool  USING    syst_msgno
*                                     p_ls_spoolid
*                                     p_space1
*                                     p_space2
*                                     p_space3.
*  syst-msgid = 'VN'.
*  syst-msgno = syst_msgno.
*  syst-msgv1 = p_ls_spoolid.
*  CONDENSE syst-msgv1.
*  CHECK xscreen = space.
*  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
*    EXPORTING
*      msg_arbgb = syst-msgid
*      msg_nr    = syst-msgno
*      msg_ty    = syst-msgty
*      msg_v1    = syst-msgv1
*      msg_v2    = p_space1
*      msg_v3    = p_space2
*      msg_v4    = p_space3
*    EXCEPTIONS
*      OTHERS    = 1.
*
*
*ENDFORM.                    " protocol_update_spool


*&---------------------------------------------------------------------*
*---- Include Recall Constants
*INCLUDE /dbe/rcl_constants.                                "#EC INCL_OK

* --- Declaration of Constants
*CONSTANTS:
**--> function codes
*  gc_back_fc                 TYPE sy-ucomm         VALUE 'BACK',
*  gc_canc_fc                 TYPE sy-ucomm         VALUE 'CANCEL',
*  gc_exit_fc                 TYPE sy-ucomm         VALUE 'EXIT',
*  gc_bac1_fc                 TYPE sy-ucomm         VALUE 'BACK1',
*  gc_can1_fc                 TYPE sy-ucomm         VALUE 'CANCEL1',
*  gc_exi1_fc                 TYPE sy-ucomm         VALUE 'EXIT1',
*  gc_orga_fc                 TYPE sy-ucomm         VALUE 'ORG',
*  gc_orgd_fc                 TYPE sy-ucomm         VALUE 'ORG_DISPL',
*  gc_crea_fc                 TYPE sy-ucomm         VALUE 'NEW',
*  gc_wizard_fc               TYPE sy-ucomm         VALUE 'WIZARD',
*  gc_edit_fc                 TYPE sy-ucomm         VALUE 'CHANGE',
*  gc_show_fc                 TYPE sy-ucomm         VALUE 'SHOW',
*  gc_copy_fc                 TYPE sy-ucomm         VALUE 'COPY',
*  gc_dele_fc                 TYPE sy-ucomm         VALUE 'DELETE',
*  gc_crcu_fc                 TYPE sy-ucomm         VALUE 'NEW_CUSTOM',
*  gc_crvh_fc                 TYPE sy-ucomm         VALUE 'NEW_VEHICLE',
*  gc_srch_fc                 TYPE sy-ucomm         VALUE 'SEARCH',
*  gc_esrh_fc                 TYPE sy-ucomm         VALUE 'ESEARCH',
*  gc_csrh_fc                 TYPE sy-ucomm         VALUE 'CLEAR_SEAR',
*  gc_ente_fc                 TYPE sy-ucomm         VALUE 'ENTER',
*  gc_okay_fc                 TYPE sy-ucomm         VALUE 'OK',
*  gc_stov_fc                 TYPE sy-ucomm         VALUE 'STOCK_OVERVIEW',
*  gc_pinf_fc                 TYPE sy-ucomm         VALUE 'PART_INFO',
*  gc_omar_fc                 TYPE sy-ucomm         VALUE 'OMARA',
*  gc_mara_fc                 TYPE sy-ucomm         VALUE 'MAT_MASTER',
*  gc_rqit_fc                 TYPE sy-ucomm         VALUE 'EINTEILUNG',
*  gc_itcn_fc                 TYPE sy-ucomm         VALUE 'ITEM_CANCEL',
*  gc_aval_fc                 TYPE sy-ucomm         VALUE 'ITEM_AVAIL_CHECK',
*  gc_vhcl_fc                 TYPE sy-ucomm         VALUE 'VHMASTER',
*  gc_vshw_fc                 TYPE sy-ucomm         VALUE 'VH_SHOW',
*  gc_vshw_fo_fc              TYPE sy-ucomm         VALUE 'VH_SHOW_FO', "Fleet order vehicle on item level
*  gc_header_cntrct_fc        TYPE sy-ucomm         VALUE 'HEADER_CNTRCT_SHOW',
*  gc_splhdr_cntrct_fc        TYPE sy-ucomm         VALUE 'SPLHDR_CNTRCT_SHOW',
*  gc_job_cntrct_fc           TYPE sy-ucomm         VALUE 'JOB_CNTRCT_SHOW',
*  gc_vnew_fc                 TYPE sy-ucomm         VALUE 'VH_NEW',
*  gc_cust_fc                 TYPE sy-ucomm         VALUE 'CUST_MAST',
*  gc_bpar_fc                 TYPE sy-ucomm         VALUE 'BUPA_MAST',
*  gc_cnew_fc                 TYPE sy-ucomm         VALUE 'CUST_NEW',
*  gc_bpnw_fc                 TYPE sy-ucomm         VALUE 'BP_NEW',
*  gc_noti_fc                 TYPE sy-ucomm         VALUE 'NOTI',
*  gc_ccre_fc                 TYPE sy-ucomm         VALUE 'CUST_CRED',
*  gc_cost_fc                 TYPE sy-ucomm         VALUE 'COST',
*  gc_stat_fc                 TYPE sy-ucomm         VALUE 'STATUS',
*  gc_stsi_fc                 TYPE sy-ucomm         VALUE 'STSIMU',
*  gc_dflw_fc                 TYPE sy-ucomm         VALUE 'DOCFLOW',
*  gc_dfit_fc                 TYPE sy-ucomm         VALUE 'DOCFLOW_ITEM',
*  gc_dfsp_fc                 TYPE sy-ucomm         VALUE 'DOCFLOW_SPLIT',
*  gc_isel_fc                 TYPE sy-ucomm         VALUE 'ITEM_SEL',
*  gc_cats_fc                 TYPE sy-ucomm         VALUE 'CATS_DA',
*  gc_cpep_fc                 TYPE sy-ucomm         VALUE 'CPEP',
*  gc_itcd_fc                 TYPE sy-ucomm         VALUE 'ITEM_COND',
*  gc_itpc_fc                 TYPE sy-ucomm         VALUE 'ITEM_PICK',
*  gc_itch_fc                 TYPE sy-ucomm         VALUE 'ITEM_CHANGE',
*  gc_itcr_fc                 TYPE sy-ucomm         VALUE 'ITEM_CREATE',
*  gc_aplg_fc                 TYPE sy-ucomm         VALUE 'APPL_LOG',
*  gc_itdl_fc                 TYPE sy-ucomm         VALUE 'ITEM_DELETE',
*  gc_itrj_fc                 TYPE sy-ucomm         VALUE 'ITEM_REJECT',
*  gc_itur_fc                 TYPE sy-ucomm         VALUE 'ITEM_UNREJECT',
*  gc_evnt_fc                 TYPE sy-ucomm         VALUE 'OE_EVENT',
*  gc_vehi_fc                 TYPE sy-ucomm         VALUE 'VEHICLE',
*  gc_vhrf_fc                 TYPE sy-ucomm         VALUE 'VEHI_REFR',
*  gc_valid_salesarea_fc      TYPE sy-ucomm         VALUE 'VALID_SAREA',
*  gc_mrsv_fc                 TYPE sy-ucomm         VALUE 'MRS_VIEW',
*  gc_cuag_fc                 TYPE sy-ucomm         VALUE 'CUSTOMER',
*  gc_bupa_fc                 TYPE sy-ucomm         VALUE 'PARTNER',
*  gc_ordt_fc                 TYPE sy-ucomm         VALUE 'ORD_TYPE',
*  gc_ordl_fc                 TYPE sy-ucomm         VALUE 'ORDLIST',
*  gc_chdc_fc                 TYPE sy-ucomm         VALUE 'CHNG_DOC',
*  gc_refm_fc                 TYPE sy-ucomm         VALUE 'REF_MAT',
*  gc_fact_fc                 TYPE sy-ucomm         VALUE 'FACT_SHEET',
*  gc_memo_fc                 TYPE sy-ucomm         VALUE 'MEMO_PAD',
*  gc_ordwiz_fc               TYPE sy-ucomm         VALUE 'ORD_WIZ',
*  gc_qnav_fc                 TYPE sy-ucomm         VALUE 'QUICKNAV',
*  gc_noqnav_fc               TYPE sy-ucomm         VALUE 'NOQUICKNAV',
*  gc_save_fc                 TYPE sy-ucomm         VALUE 'SAVE',
*  gc_new_fc                  TYPE sy-ucomm         VALUE 'NEW',
*  gc_delete_fc               TYPE sy-ucomm         VALUE 'DELETE',
*  gc_sline_fc                TYPE sy-ucomm         VALUE 'SCHEDULE_LINE',
*  gc_ordsave_fc              TYPE sy-ucomm         VALUE 'ORD_SAVE',
*  gc_jobch_fc                TYPE sy-ucomm         VALUE 'JOB_CHANGE',
*  gc_splhdr_fc               TYPE sy-ucomm         VALUE 'SPLHDR_CHANGE',
*  gc_it_av_fc                TYPE sy-ucomm         VALUE 'ITEM_AVAIL_CHECK',
*  gc_wt_ord_fc               TYPE sy-ucomm         VALUE 'WTYD_ORDER_CHNG',
*  gc_it_wty_fc               TYPE sy-ucomm         VALUE 'ITEM_WTY_CHANGE',
*  gc_proc_fc                 TYPE sy-ucomm         VALUE 'PROCUREMENT',
*  gc_prnt_x_fc               TYPE sy-ucomm         VALUE 'ORD_PRNT_X',
*
*  gc_preq_fc                 TYPE sy-ucomm         VALUE 'PROCUREMENT',
*  gc_preq_can_fc             TYPE sy-ucomm         VALUE 'PROCUREMENT_CANC',
*  gc_upc_menu                TYPE sy-ucomm         VALUE 'ITEM_UPCR',
*  gc_upc_fc                  TYPE sy-ucomm         VALUE 'ITEM_UPCR_B',
*  gc_upc_fc_p                TYPE sy-ucomm         VALUE 'ITEM_UPCR_P',
*
**DBM812
*  gc_save_fcc(4)             TYPE c              VALUE 'SAVE',   "duplicate declaration in other include -> clash
*  gc_vehdetail_fc(9)         TYPE c              VALUE 'VEHDETAIL',
*  gc_actionvm_fc(8)          TYPE c              VALUE 'ACTIONVM',
*  gc_new_fcc(3)              TYPE c              VALUE 'NEW',     "duplicate declaration in other include -> clash
*
**--> order transactions; need for call transactions
*  gc_order_crea_ta           TYPE sy-ucomm         VALUE '/DBM/ORDER01',
*  gc_order_edit_ta           TYPE sy-ucomm         VALUE '/DBM/ORDER02',
*  gc_order_show_ta           TYPE sy-ucomm         VALUE '/DBM/ORDER03',
*  gc_order_copy_ta           TYPE sy-ucomm         VALUE '/DBM/ORDER05',
*  gc_order_ordl_ta           TYPE sy-ucomm         VALUE '/DBM/ORDER',
*
**--> programs
*
*  gc_prog_textpool           TYPE sy-cprog     VALUE '/DBM/MS_TEXT_TEXTPOOL',
*
**--> activities
*  gc_crea_activity           TYPE activ_auth       VALUE '01',
*  gc_edit_activity           TYPE activ_auth       VALUE '02',
*  gc_show_activity           TYPE activ_auth       VALUE '03',
*  gc_dele_activity           TYPE activ_auth       VALUE '06',
*  gc_copy_activity           TYPE activ_auth       VALUE 'D1',
*  gc_disp_order              TYPE activ_auth       VALUE '03',
*  gc_change_order            TYPE activ_auth       VALUE '02',
*
**--> engine codes
*  gc_service(2)              TYPE c                VALUE 'CS',
*  gc_vehicle(2)              TYPE c                VALUE 'SD',
*  gc_parts(2)                TYPE c                VALUE 'MM',
*  gc_package(2)              TYPE c                VALUE 'PC',
*  gc_fleet(2)                TYPE c                VALUE 'FO',
*  c_cs(2)                    TYPE c                VALUE 'CS',
*  c_sd(2)                    TYPE c                VALUE 'SD',
*  c_mm(2)                    TYPE c                VALUE 'MM',
*
**--> languages
*  gc_language_en(2)          TYPE c                VALUE 'EN',
*
** --> order class
*  gc_detail                  TYPE c                VALUE 'D',
*
**--> BOR objects
*  gc_dbmorder                TYPE swo_objtyp       VALUE 'BUS2400',
*  gc_dbmorderitem            TYPE swo_objtyp       VALUE 'BUS2401',
*
*
**--> item cancel flag
*  gc_itcanc                  TYPE c                VALUE 'X',
*
**--> increment of possiton number
*  gc_item_posnr_increment(2) TYPE c            VALUE '10',
*
**--> changing flags
*  gc_insert                  TYPE c                VALUE 'I',
*  gc_change                  TYPE c                VALUE 'C',
*  gc_delete                  TYPE c                VALUE 'D',
*  gc_update                  TYPE c                VALUE 'U',
*
**--> application log
*  gc_object_dbm              TYPE balobj_d         VALUE 'DBM',
*  gc_subobject_order         TYPE balsubobj        VALUE 'ORDER',
*  gc_subobject_service       TYPE balsubobj        VALUE 'SERVICE',
*
**--> authority objects
*  gc_authobj_order           TYPE tobj-objct   VALUE '/DBM/ORDER',
*  gc_authobj_package         TYPE tobj-objct   VALUE '/DBM/PCKG',
*
**--> text object/id's
*  gc_dbm_text_obj            TYPE tdobject         VALUE 'DBM_TEXT',
*  gc_dbm_id_lt               TYPE tdid             VALUE 'LT',
*  gc_dbm_id_cs               TYPE tdid             VALUE 'CS',
*  gc_dbm_id_mm               TYPE tdid             VALUE 'MM',
*  gc_dbm_id_sd               TYPE tdid             VALUE 'SD',
*
**--> ALV settings
*  gc_alv_var_save            TYPE c                VALUE 'A',
*  gc_zmeng_zero              TYPE /dbm/amount      VALUE '0',
*
**--> hart coded screens
*  gc_tabstrip_repid          TYPE syrepid          VALUE '/DBM/SAPLATAB',
*  gc_tabstrip_dynnr          TYPE sydynnr          VALUE '0100',
*  gc_emptyscr_dynnr          TYPE sydynnr          VALUE '2999',
*  gc_emptyscr_repid          TYPE syrepid         VALUE '/DBM/SAPLORDER_UI',
**gc_accounting_dynnr     TYPE sydynnr         VALUE '2204',
*
**--> 'Application' and 'Layout for service functions (package ATAB) used
**    for order tabstrip
*  gc_tab_appl                TYPE tab_appl         VALUE 'PN__DBM',
*  gc_default_layout          TYPE tab_layout       VALUE 'SAP',
*  gc_tab(3)                  TYPE c                VALUE 'TAB',
*  gc_tab_prev_fc             TYPE  sy-ucomm VALUE 'PREV_TAB',
*  gc_tab_next_fc             TYPE  sy-ucomm VALUE 'NEXT_TAB',
*
**--> lean condition technique
*  gc_ord_layout_lc           TYPE /dbm/lc_usage_d  VALUE '/DBM/ORD_LAYOUT',
*  gc_ord_screens_lc          TYPE /dbm/lc_usage_d  VALUE '/DBM/ORD_SCREENS',
*
**--> status of collapsion/expansion of screen areas
*  gc_scr_expanded            TYPE c                VALUE ' ',
*  gc_scr_collapsed           TYPE c                VALUE '1',
*  gc_scr_inactive            TYPE c                VALUE '2',
*  gc_scr_invisible           TYPE c                VALUE '3',
*  gc_scr_hidden              TYPE c                VALUE '4',
*
**--> Yes and No
*  gc_yes                     TYPE c                VALUE 'J',
*  gc_no                      TYPE c                VALUE 'N',
*
**--> xflag, space
*  gc_xflag                   TYPE c                VALUE 'X',
*  gc_space                   TYPE c                VALUE ' ',
*
**--> user actions
*  gc_action_b                TYPE c                VALUE 'B',
*  gc_action_c                TYPE c                VALUE 'C',
*  gc_action_e                TYPE c                VALUE 'E',
*
**--> old constants which doesn't fit with our naming convention
*  c_checkval                 TYPE c                VALUE 'X',
*  c_true                     TYPE c                VALUE 'X',
*  c_false                    TYPE c                VALUE space,
*  c_call_flag_new            TYPE t365-aktyp       VALUE 'H',
*  c_call_flag_change         TYPE t365-aktyp       VALUE 'V',
*  c_call_flag_view           TYPE t365-aktyp       VALUE 'A',
*  c_new_order(1)             TYPE c                VALUE 'N',
*  c_new                      TYPE c                VALUE 'N',
*  c_change_order(1)          TYPE c                VALUE 'C',
*  c_column1(12)              TYPE c                VALUE 'COLUMN1',
*  c_column2(12)              TYPE c                VALUE 'COLUMN2',
*  c_column3(12)              TYPE c                VALUE 'COLUMN3',
*  c_column4(12)              TYPE c                VALUE 'COLUMN4',
*  c_column5(12)              TYPE c                VALUE 'COLUMN5',
*
**--> call transaction parameter
*  gc_dismode_e_cta           TYPE ctu_mode         VALUE 'E',
*  gc_dismode_a_cta           TYPE ctu_mode         VALUE 'A',
*  gc_nobinpt_cta             TYPE ctu_nobim        VALUE 'X',
*
**--> columns of the column-tree on the part item subscreen
*  gc_column1(12)             TYPE c                VALUE 'COLUMN1',
*  gc_column2(12)             TYPE c                VALUE 'COLUMN2',
*  gc_column3(12)             TYPE c                VALUE 'COLUMN3',
*  gc_column4(12)             TYPE c                VALUE 'COLUMN4',
*  gc_column5(12)             TYPE c                VALUE 'COLUMN5',
*
**--> constants need for column-tree nodes
*  gc_job_node                TYPE c                VALUE 'J',
*  gc_vbap_node               TYPE c                VALUE 'P',
*  gc_vbep_node               TYPE c                VALUE 'E',
*  gc_nojob_node(7)           TYPE c                VALUE 'J000000',
*  gc_nopict(5)               TYPE c                VALUE 'BNONE',
*
**--> message types
*  gc_msg_error               TYPE c                VALUE 'E',
*  gc_msg_abort               TYPE c                VALUE 'A',
*  gc_error_msgtyp            TYPE c                VALUE '1',
*  gc_warning_msgtyp          TYPE c                VALUE '2',
*  gc_info_msgtyp             TYPE c                VALUE '3',
*
**--> split number 1
*  gc_splhdr_one              TYPE /dbm/splnr       VALUE '0001',
*  gc_job_zero                TYPE /dbm/jobnr       VALUE '000000',
*
**--> search modes on item screen
*  gc_smode_qm_fc             TYPE c                VALUE '?',
*  gc_smode_st_fc             TYPE c                VALUE '*',
*  gc_smode_pl_fc             TYPE c                VALUE '+',
*  gc_smode_mi_fc             TYPE c                VALUE '-',
*
**--> partner determination
*  gc_parvw_ag                TYPE parvw_4          VALUE 'AG', "sold-to prty
*  gc_parvw_we                TYPE parvw_4          VALUE 'WE', "ship-to party
*  gc_parvw_re                TYPE parvw_4          VALUE 'RE', "bill-to party
*  gc_split_first             TYPE /dbm/splnr       VALUE '0001',
**--> partner types:
*  gc_part_type_ku            TYPE nrart            VALUE 'KU', "Customer
*  gc_part_type_ap            TYPE nrart            VALUE 'AP', "Contact pers
*  gc_part_type_li            TYPE nrart            VALUE 'LI', "Supplier
*  gc_part_type_pe            TYPE nrart            VALUE 'PE', "Employee
*
**--> partner display constants
*  gc_partner_overview_repid  TYPE sy-repid      VALUE  'SAPLV09C',
*  gc_partner_overview_dynnr  TYPE sy-dynnr      VALUE  '1000',
*  gc_partner_repid           TYPE sy-repid      VALUE  '/DBM/SAPLCU05',
*  gc_partner_dynnr           TYPE sy-dynnr      VALUE  '0100',
*
**--> constants need for time conversions
*  gc_time_low                TYPE sy-timlo         VALUE '000000',
*  gc_time_high               TYPE sy-timlo         VALUE '235959',
*  gc_time_mid                TYPE sy-timlo         VALUE '120000',
*
**--> language
*  gc_language_english        TYPE sy-langu         VALUE 'E',
*
**--> sales document type
*  gc_c_vbtyp                 TYPE c                VALUE 'C',
*  gc_o_vbtyp                 TYPE c                VALUE 'O',
*  gc_b_vbtyp                 TYPE c                VALUE 'B',
*  gc_a_vbtyp                 TYPE c                VALUE 'A',
*
**--> text types
*  gc_header_texttype         TYPE /dbm/txt_type    VALUE 'H',
*  gc_footer_texttype         TYPE /dbm/txt_type    VALUE 'F',
*  gc_job_texttype            TYPE /dbm/txt_type    VALUE 'J',
*  gc_item_texttype           TYPE /dbm/txt_type    VALUE 'I',
*  gc_tdobject(8)             TYPE c                VALUE 'DBM_TEXT',
*
*  gc_charh                   TYPE c                VALUE 'H',
*  gc_charv                   TYPE c                VALUE 'V',
*  gc_posnr_low               TYPE vbap-posnr       VALUE '000000',
*
**--> job
*  gc_spchar(11)              TYPE c                VALUE '0123456789 ',
*
**--> task
*  gc_task_zero               TYPE /dbm/tasknr      VALUE '000000',
*
**---> parts super session
*  gc_pictyp_1                TYPE c               VALUE '1', "autom.1 to 1
*  gc_pictyp_1to1             TYPE c               VALUE '2', "screen 1 to 1
*  gc_pictyp_mto1             TYPE c               VALUE '3', "multi
*
**--> Memory IDs
*  gc_memory_id_vguid(55)     TYPE c               VALUE '/DBM/VLC_GUID',
*
**---> change document
*  gc_chng_doc_obj            TYPE cdobjectcl      VALUE '/DBM/ORDER',
*
** Default unit of measurement for odometer reading / distance
*  gc_uom_counter             TYPE /dbm/ctrl_object  VALUE '/DBM/V_UOM_DIST', "#EC *
*
*
**---> order search
*  gc_freetxt(11)             TYPE c               VALUE 'GV_FREETEXT',
*  gc_srchtype(13)            TYPE c               VALUE 'GV_SEARCHTYPE',
*  gc_tab01_os(6)             TYPE c               VALUE 'TAB_01',
*  gc_tab02_os(6)             TYPE c               VALUE 'TAB_02',
*  gc_tab03_os(6)             TYPE c               VALUE 'TAB_03',
*  gc_search_os(9)            TYPE c               VALUE 'OS_SEARCH',
*  gc_clear_os(8)             TYPE c               VALUE 'OS_CLEAR',
*  gc_maint_os(14)            TYPE c               VALUE 'OS_MAINTENANCE',
*  gc_varchg_os(7)            TYPE c               VALUE 'VAR_CHG',
*  gc_scrchg_os(7)            TYPE c               VALUE 'SCR_CHG',
*  gc_uspara_os(11)           TYPE c               VALUE 'USER_PARAM',
*  gc_planview_os(18)         TYPE c               VALUE '/DBM/ORD_PLAN_VIEW',
*  gc_prg_os(17)              TYPE c               VALUE '/DBM/SAPLORDER_UI',
*  gc_weg_os(19)              TYPE c               VALUE '/DBM/VBAK_COM-VTWEG',
*  gc_org_os(19)              TYPE c               VALUE '/DBM/VBAK_COM-VKORG',
*  gc_spa_os(19)              TYPE c               VALUE '/DBM/VBAK_COM-SPART',
*  gc_wer_os(19)              TYPE c               VALUE '/DBM/VBAK_COM-WERKS',
*  gc_aufart_os(22)           TYPE c             VALUE '/DBM/SPLHDR_COM-AUFART',
*  gc_osweg_os(10)            TYPE c               VALUE 'VTW', "/DBM/OSWEG
*  gc_osorg_os(10)            TYPE c               VALUE 'VKO', "/DBM/OSORG
*  gc_osspa_os(10)            TYPE c               VALUE 'SPA', "/DBM/OSSPA
*  gc_oswer_os(10)            TYPE c               VALUE 'WRK', "/DBM/OSWER
*  gc_stand_os(8)             TYPE c               VALUE 'STANDARD',
*  gc_views_os(8)             TYPE c               VALUE 'gv_views',
*  gc_variantn_os(11)         TYPE c               VALUE 'gv_variantn',
*  gc_var_os(10)              TYPE c               VALUE '/DBM/OSVAR',
*  gc_ini_os(10)              TYPE c               VALUE '/DBM/OSINI',
*  gc_ossd_os(9)              TYPE c               VALUE '/DBM/OSSD',
*  gc_osmm_os(9)              TYPE c               VALUE '/DBM/OSMM',
*  gc_oscs_os(9)              TYPE c               VALUE '/DBM/OSCS',
*  gc_rel_os(10)              TYPE c               VALUE '/DBM/OSREL',
*  gc_aua_os(10)              TYPE c               VALUE '/DBM/OSAUA',
*  gc_osweg(10)               TYPE c               VALUE '/DBM/OSWEG',
*  gc_colscr(6)               TYPE c               VALUE 'COLSCR',
*  gc_expscr(6)               TYPE c               VALUE 'EXPSCR',
*  gc_maxsel(15)              TYPE c               VALUE '/DBM/ORD_MAXSEL',
*  gc_prg_dbm_bp(16)          TYPE c               VALUE '/DBM/BP_MAINTAIN',
*  gc_prg_bp(20)              TYPE c               VALUE 'SAPLBUPA_DIALOG_JOEL'.
*
** Constants for the selection screen of Extended order search
*CONSTANTS:
*  gc_standard_selscreen  TYPE dynnr VALUE '1011',
*  gc_standard_selscreen2 TYPE dynnr VALUE '1012',
*  gc_header_selscreen1   TYPE dynnr VALUE '1013',
*  gc_header_selscreen2   TYPE dynnr VALUE '1113',
*  gc_split_selscreen     TYPE dynnr VALUE '1014',
*  gc_job_selscreen       TYPE dynnr VALUE '1015',
*  gc_item_selscreen      TYPE dynnr VALUE '1016',
*  gc_task_selscreen      TYPE dynnr VALUE '1017',
*  gc_job_selscreen2      TYPE dynnr VALUE '1018',
*  gc_sel_level           TYPE string VALUE 'SELECTION LEVEL',
*  gc_fertig_date(25)     TYPE c VALUE '/DBM/VBAK_COM-FERTIG_DAT',
*  gc_drop_date(32)       TYPE c VALUE '/DBM/VBAK_COM-VISIT_START_DATE',
*  gc_pick_date(32)       TYPE c VALUE '/DBM/VBAK_COM-VISIT_END_DATE',
*  gc_drop_time(32)       TYPE c VALUE '/DBM/VBAK_COM-VISIT_START_TIME',
*  gc_pick_time(32)       TYPE c VALUE '/DBM/VBAK_COM-VISIT_END_TIME',
*  gc_validto(30)         TYPE c VALUE '/DBM/VBAK_COM-VALID_TO_DATE',
*  gc_validfrom(30)       TYPE c VALUE '/DBM/VBAK_COM-VALID_FR_DATE',
*  gc_validto_timestp(30) TYPE c VALUE '/DBM/VBAK_COM-VALID_TO_TSTMP',
*  gc_validfr_timestp(30) TYPE c VALUE '/DBM/VBAK_COM-VALID_FR_TSTMP',
*  gc_fertig_time(25)     TYPE c VALUE '/DBM/VBAK_COM-FERTIG_TIME',
*  gc_fertig_timestp(30)  TYPE c VALUE '/DBM/VBAK_COM-FERT_DATE_TMSTP',
*  gc_drop_timestp(30)    TYPE c VALUE '/DBM/VBAK_COM-VISIT_START_TST',
*  gc_pick_timestp(30)    TYPE c VALUE '/DBM/VBAK_COM-VISIT_END_TST',
*  gc_selopt_kind         TYPE rsscr_kind VALUE 'S',
*  gc_param_kind          TYPE rsscr_kind VALUE 'P',
*  gc_date_kind           TYPE rsscr_kind VALUE 'D',
*  gc_time_kind           TYPE rsscr_kind VALUE 'T',
*  gc_sign_incl           TYPE tvarv_sign VALUE 'I',
*  gc_option_eq           TYPE tvarv_opti VALUE 'EQ',
*  gc_option_bt           TYPE tvarv_opti VALUE 'BT',
*  gc_scrinfo_type        TYPE rsscr_kind VALUE 'C',
*  gc_werks(8)            TYPE c VALUE 'GV_WERKS',
*  gc_vkorg(8)            TYPE c VALUE 'GV_VKORG',
*  gc_p_vhvin(7)          TYPE c VALUE 'P_VHVIN'.

*&---------------------------------------------------------------------*
*&  Include           /DBM/RCL_CONSTANTS
*&---------------------------------------------------------------------*

* --- Declaration of Constants
*CONSTANTS:
**--> recall status
*  gc_rcl_open_fc TYPE /dbe/wtyrclstat  VALUE '1',
*  gc_rcl_rese_fc TYPE dbm_wtyrclstat  VALUE '2',
*  gc_rcl_proc_fc TYPE dbm_wtyrclstat  VALUE '3',
*  gc_rcl_clos_fc TYPE dbm_wtyrclstat  VALUE '4',
*  gc_rcl_clex_fc TYPE dbm_wtyrclstat  VALUE '5'.

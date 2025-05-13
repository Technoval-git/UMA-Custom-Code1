*&---------------------------------------------------------------------*
*& Report ZRVSS_SALES_PARTS_INVOICE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrvss_sales_parts_invoice.

INCLUDE rvadtabl.

DATA:   retcode   LIKE sy-subrc.         "Returncode
DATA:   xscreen(1) TYPE c.               "Output on printer or screen
DATA:   repeat(1) TYPE c.
DATA: nast_anzal LIKE nast-anzal.      "Number of outputs (Orig. + Cop.)
DATA: nast_tdarmod LIKE nast-tdarmod.  "Archiving only one time
DATA: gv_qr            TYPE string.
DATA:
  lv_disc_flag TYPE c,
  is_seller    TYPE  zsd_inv_head_mid,
  ts_invc      TYPE  ydbe_invc,
  is_buyer     TYPE  zsd_inv_head_mid.
DATA:
*      gs_header TYPE yst_jipco_mm_inv_head,
*      gs_footer TYPE yst_jipco_mm_inv_footer,
*      gt_item   TYPE yst_jipco_mm_inv_item_tb,
  gs_header TYPE  ycl_dbe_prt_crdt_inv_frm_util=>ty_header,
  gt_body   TYPE  ycl_dbe_prt_crdt_inv_frm_util=>tt_body_str,
  gs_footer TYPE  ycl_dbe_prt_crdt_inv_frm_util=>ty_footer_str.

INCLUDE rlb_print_forms.

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

  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: lf_formname           TYPE tdsfname.
  DATA: lv_invoice_no         TYPE vbeln_vf.
  DATA:fp_docparams    TYPE sfpdocparams,    " Structure  SFPDOCPARAMS Short Description  Form Parameters for Form Processing
       fp_outputparams TYPE sfpoutputparams.
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

  lv_invoice_no = nast-objky.
*
*  PERFORM get_data USING lv_invoice_no
*                  CHANGING cf_retcode.

  CALL FUNCTION 'YDBE_VSS_PRT_CRDT_INVOICE'
    EXPORTING
      iv_invoice_no = lv_invoice_no
      iv_sf         = ''
      iv_langu      = nast-spras
    IMPORTING
      es_header     = gs_header
      et_body       = gt_body
      es_footer     = gs_footer.
  "**************begin*******************************************
  " Date: 29.09.2024 14:52:35" | CD: 8100009737, New Condition Type- ATC Delivery Charges| Desc:
  IF lv_invoice_no IS NOT INITIAL.
*    BREAK tech5.
    DATA l_total_del_charges TYPE kwert.

    SELECT SINGLE low FROM tvarvc CLIENT SPECIFIED
          INTO  @DATA(lv_mat)
          WHERE mandt = '000'
          AND name = 'YJACO_ATC_MAT_CHECK'.

    SELECT SINGLE spart FROM vbrp INTO gs_header-spart
WHERE vbeln = lv_invoice_no
  AND posnr = '000010'.

    READ TABLE gt_body INTO DATA(wa_dlv_charge) WITH KEY product_number = lv_mat.
    IF sy-subrc = 0.
      l_total_del_charges = wa_dlv_charge-taxable_amt.
    ENDIF.
    DELETE gt_body WHERE product_number = lv_mat.

**    SELECT low FROM tvarvc CLIENT SPECIFIED
**         INTO TABLE @DATA(lt_plants)
**         WHERE mandt = '000'
**         AND name  = 'YJACO_ATC_DEL_PLANT'.
***    SELECT SINGLE werks FROM /dbe/vbak_db INTO @DATA(l_werks) WHERE vbeln = @gs_header-order_no.
***    IF sy-subrc = 0.
***      READ TABLE lt_plants WITH KEY low = l_werks TRANSPORTING NO FIELDS.
***      IF sy-subrc = 0.
***        lv_disc_flag = 'X'.
***        SELECT SINGLE knumv FROM vbrk INTO @DATA(ls_knumv) WHERE vbeln = @lv_invoice_no.
***        IF sy-subrc = 0 AND ls_knumv IS NOT INITIAL.
***          SELECT SUM( kwert ) FROM konv INTO @DATA(l_total_del_charges) WHERE knumv = @ls_knumv AND kschl = 'YPDC' AND kinak = @space.
    IF l_total_del_charges IS INITIAL.
      SELECT SINGLE knumv FROM vbrk INTO @DATA(ls_knumv) WHERE vbeln = @lv_invoice_no.
      IF sy-subrc = 0.
        SELECT SUM( kwert ) FROM konv INTO l_total_del_charges WHERE knumv = ls_knumv AND kschl = 'YPDC' AND kinak = space.
      ENDIF.
    ENDIF.

    gs_footer-taxable_amt = gs_footer-taxable_amt +  l_total_del_charges.
    gs_footer-final_amt = gs_footer-final_amt + l_total_del_charges.
***        ENDIF.
***      ENDIF.
***    ENDIF.
  ENDIF.
  "**************end*******************************************
*--checking for return invoice..
  CLEAR: gs_header-origin_ord .
  IF gs_header-fkart  EQ 'G2'.

    DATA: lt_original_ord TYPE /dbe/docflow_documents_tt.
    CALL FUNCTION '/dbe/OE_MAIN_DOCFLOW_READ_ALL'
      EXPORTING
        iv_vbeln       = gs_header-order_no
        iv_borobj      = 'BUS2400'
*       iv_logsys      =
*       iv_posnr       =
*       iv_etenr       =
*       iv_splnr       =
*       iv_jobnr       =
*       iv_seqno       =                  " Sequence Number
*       io_order       =                  " DBM Order Instance
      IMPORTING
        et_documents   = lt_original_ord
      EXCEPTIONS
        internal_error = 1
        OTHERS         = 2.
    IF sy-subrc = 0.
      READ TABLE lt_original_ord INTO DATA(ls_org_ord) INDEX 1.
      IF sy-subrc = 0.
        gs_header-origin_ord = ls_org_ord-docnum.
      ENDIF.
    ENDIF.
  ENDIF.

*---call FM to get the address of seller and buyer..
  CLEAR:  is_seller, is_buyer.
*  CALL FUNCTION 'YDBE_INV_HEAD_PARTNR_ADRS2'
  CALL FUNCTION 'YDBE_INV_HEAD_PARTNR_ADRS'
    EXPORTING
      lv_invoice_no = lv_invoice_no
    IMPORTING
      es_seller     = is_seller
      es_buyer      = is_buyer.

  BREAK tech2.
  IF is_buyer-vat_no IS INITIAL.                      "Shahid changed 20.06.2023 8100008102
    IF is_buyer-cust_no = gs_header-ac_number.
      is_buyer-vat_no = gs_header-cus_vat.
    ELSE.
      SELECT SINGLE stceg INTO is_buyer-vat_no FROM kna1
         WHERE kunnr = is_buyer-cust_no.
    ENDIF.
  ENDIF.
*****************************************************Shahid changed 20.06.2023 8100008102
  DATA: l_amtwords    TYPE string,
        l_amtwords_ar TYPE string.
*--amount in workds
  CALL FUNCTION 'Z_AMT_IN_WORDS_INV'
    EXPORTING
      amount       = gs_footer-final_amt
      currency     = 'SAR'
      language     = sy-langu
    IMPORTING
      amt_in_words = l_amtwords.  "   wf_amt_in_words.

  REPLACE  ALL OCCURRENCES OF 'Amount includes VAT'  IN l_amtwords WITH 'Inclusive of VAT' .
* arabic
  CALL FUNCTION 'Z_AMT_IN_WORDS_INV'
    EXPORTING
      amount       = gs_footer-final_amt
      currency     = 'SAR'
      language     = 'A'
    IMPORTING
      amt_in_words = l_amtwords_ar.  "   wf_amt_in_words.


*QR Code
  CLEAR: gv_qr.
  CALL FUNCTION 'ZSD_GETINV_QRDATA'
    EXPORTING
      l_vbeln   = lv_invoice_no
*     l_vat_amt = ls_bil_invoice-hd_gen-bil_tax
      l_vat_amt = gs_footer-vat
*     l_total   = ls_bil_invoice-hd_gen-bil_netwr
      l_total   = gs_footer-final_amt
    IMPORTING
      ls_qr     = gv_qr.


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

*call smartform here
*-- Adding code to check ZATCA accepted or not..
  DATA: lv_source_key TYPE edoc_source_key,
        lv_edoc_guid  TYPE edoc_guid,
        lv_approve,
        lv_repeat(1)  TYPE c,  "added
        it_ydbm_invc  TYPE TABLE OF ydbe_invc,
        ts_ydbm_invc  LIKE LINE OF it_ydbm_invc,
        lv_title_en   TYPE char30,
        lv_title_ar   TYPE char30,
        lv_person,
        lv_cust_id    TYPE bu_partner.

  CLEAR: lv_source_key ,lv_edoc_guid, lv_approve,lv_title_en,lv_title_ar,lv_person,lv_cust_id.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gs_header-inv_number                 " C field
    IMPORTING
      output = gs_header-inv_number.

  cl_edoc_source_sd_invoice=>pack_key(
    EXPORTING
      iv_vbeln = gs_header-inv_number
    IMPORTING
      ev_key   = lv_source_key ).

  lv_cust_id = gs_header-ac_number.

  CALL FUNCTION 'YEDOC_INV_TITLE_STATUS'
    EXPORTING
      source_key = lv_source_key
      partner    = lv_cust_id
    IMPORTING
      approved   = lv_approve
      title_en   = lv_title_en
      title_ar   = lv_title_ar
      person     = lv_person.

  IF lv_title_en IS INITIAL.
    lv_title_en = 'Tax Invoice'.
  ENDIF.

  IF lv_title_ar IS INITIAL.
    lv_title_ar = 'فاتورة ضريبة'.
  ENDIF.
*  CONCATENATE  lv_title_en lv_title_ar INTO gs_header-title SEPARATED BY space.


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
*        repeat = 'X'.
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
*      fp_docparams-langu   = nast-spras.
*      fp_docparams-country = 'US'.
* Sets the output parameters and opens the spool job
      " tech1.
      fp_outputparams-nodialog = 'X'.
      fp_outputparams-device = 'PRINTER'.
*      fp_outputparams-dest = 'PDF1'.
      fp_outputparams-dest = nast-ldest.
      fp_outputparams-preview = 'X'.
*      IF nast-spras = 'A'.
*      fp_outputparams-reqnew = 'X'.
*      fp_outputparams-reqimm = 'X'.
*      fp_outputparams-reqdel = 'X'.
*      ENDIF.

      CLEAR repeat.
*      ts_ydbm_invc-kschl = nast-kschl.
*      ts_ydbm_invc-vbeln = gs_header-inv_number.
      SELECT SINGLE * FROM ydbe_invc INTO ts_ydbm_invc WHERE kschl = nast-kschl AND vbeln = gs_header-inv_number.
      IF sy-subrc <> 0.
        repeat = ''.
*        ts_ydbm_invc-kschl = nast-kschl.
*        ts_ydbm_invc-vbeln = gs_header-inv_number.
*        ts_ydbm_invc-usnam = sy-uname.
*        ts_ydbm_invc-erdat = sy-datum.
*        ts_ydbm_invc-erzet = sy-uzeit.
*        MODIFY ydbm_invc2 FROM ts_ydbm_invc.

        ts_invc-mandt = sy-mandt.
        ts_invc-kappl = 'PI'.
        ts_invc-bukrs = '2100'.
        ts_invc-vbeln = lv_invoice_no.
        ts_invc-gjahr = gs_header-inv_date(4).
        ts_invc-kschl = 'YPI7'.
        ts_invc-erdat = sy-datum.
        ts_invc-erzet = sy-uzeit.
        ts_invc-usnam = sy-uname.
        INSERT ydbe_invc CLIENT SPECIFIED FROM ts_invc.
        COMMIT WORK.
      ELSE.
        repeat = 'X'.
      ENDIF.

*      IF lv_approve = 'X' . "added condition for E-invoice status

      CALL FUNCTION 'FP_JOB_OPEN'
        CHANGING
          ie_outputparams = fp_outputparams
        EXCEPTIONS
          cancel          = 1
          usage_error     = 2
          system_error    = 3
          internal_error  = 4
          OTHERS          = 5.
*        SELECT SINGLE vbeln INTO @DATA(gv_vbeln) FROM ydbm_invc
*               WHERE vbeln = @lv_invoice_no
*               AND   gjahr = @gs_header-inv_date(4)
*               AND   kschl = 'YPI7'.
*        IF sy-subrc = 0.
*          repeat = 'X'.   "reprint
*        ELSE.
*          repeat = ''.   "original
*        ENDIF.

      CALL FUNCTION lf_fm_name
        EXPORTING
          /1bcdwb/docparams = fp_docparams
          is_head           = gs_header
          gv_qr             = gv_qr
          it_body           = gt_body
          is_footer         = gs_footer
          is_repeat         = repeat
          gs_seller         = is_seller
          gs_buyer          = is_buyer
          l_amtwords        = l_amtwords
          l_amtwords_ar     = l_amtwords_ar
          l_title_en        = lv_title_en
          l_title_ar        = lv_title_ar
          is_del_charges    = l_total_del_charges
          i_disc_flag       = lv_disc_flag
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
*        ELSE.  "commented by ismail
*          ts_invc-mandt = sy-mandt.
*          ts_invc-kappl = 'PI'.
*          ts_invc-bukrs = '2100'.
*          ts_invc-vbeln = lv_invoice_no.
*          ts_invc-gjahr = gs_header-inv_date(4).
*          ts_invc-kschl = 'YPI7'.
*          ts_invc-erdat = sy-datum.
*          ts_invc-erzet = sy-uzeit.
*          ts_invc-usnam = sy-uname.
*          INSERT ydbm_invc CLIENT SPECIFIED FROM ts_invc.
*          COMMIT WORK.

      ENDIF.

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
*      ELSE.
*        MESSAGE e000(zedosa).
*      ENDIF.
    ENDDO.

  ENDIF.

ENDFORM.                    "PROCESSING

**&---------------------------------------------------------------------*
**&      Form  GET_DATA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_LV_INVOICE_NO  text
**      <--P_CF_RETCODE  text
**----------------------------------------------------------------------*
*FORM get_data  USING    iv_invoice_no TYPE vbeln_vf
*               CHANGING cv_retcode TYPE sy-subrc.
*
*
*
*
*
*
*ENDFORM.


*----------------------------------------------------------------------*
*   INCLUDE RLB_PRINT_FORMS                                            *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

*FORM PROTOCOL_UPDATE.
*
*  CHECK XSCREEN = SPACE.
*  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
*    EXPORTING
*      MSG_ARBGB = SYST-MSGID
*      MSG_NR    = SYST-MSGNO
*      MSG_TY    = SYST-MSGTY
*      MSG_V1    = SYST-MSGV1
*      MSG_V2    = SYST-MSGV2
*      MSG_V3    = SYST-MSGV3
*      MSG_V4    = SYST-MSGV4
*    EXCEPTIONS
*      OTHERS    = 1.
*
*ENDFORM.                    "PROTOCOL_UPDATE

*&---------------------------------------------------------------------*
*&      Form  ADD_SMFRM_PROT
*&---------------------------------------------------------------------*
*FORM ADD_SMFRM_PROT.
*
*  DATA: LT_ERRORTAB             TYPE TSFERROR.
** DATA: LF_MSGNR                TYPE SY-MSGNO.
*  FIELD-SYMBOLS: <FS_ERRORTAB>  TYPE LINE OF TSFERROR.
*
** get smart form protocoll
*  CALL FUNCTION 'SSF_READ_ERRORS'
*    IMPORTING
*      ERRORTAB = LT_ERRORTAB.
*
** add smartform protocoll to nast protocoll
*  LOOP AT LT_ERRORTAB ASSIGNING <FS_ERRORTAB>.
**   CLEAR LF_MSGNR.
**   LF_MSGNR = <FS_ERRORTAB>-ERRNUMBER.
*    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
*         EXPORTING
*              MSG_ARBGB = <FS_ERRORTAB>-MSGID
**             MSG_NR    = LF_MSGNR
*              MSG_NR    = <FS_ERRORTAB>-MSGNO
*              MSG_TY    = <FS_ERRORTAB>-MSGTY
*              MSG_V1    = <FS_ERRORTAB>-MSGV1
*              MSG_V2    = <FS_ERRORTAB>-MSGV2
*              MSG_V3    = <FS_ERRORTAB>-MSGV3
*              MSG_V4    = <FS_ERRORTAB>-MSGV4
*         EXCEPTIONS
*              OTHERS    = 1.
*  ENDLOOP.
*
*ENDFORM.                               " ADD_SMFRM_PROT

*&---------------------------------------------------------------------*
*&      Form  SET_PRINT_PARAM
*&---------------------------------------------------------------------*
*FORM SET_PRINT_PARAM USING    IS_ADDR_KEY LIKE ADDR_KEY
*                              IS_DLV-LAND LIKE VBRK-LAND1
*                     CHANGING CS_CONTROL_PARAM TYPE SSFCTRLOP
*                              CS_COMPOSER_PARAM TYPE SSFCOMPOP
*                              CS_RECIPIENT TYPE  SWOTOBJID
*                              CS_SENDER TYPE  SWOTOBJID
*                              CF_RETCODE TYPE SY-SUBRC.
*
*  DATA: LS_ITCPO     TYPE ITCPO.
*  DATA: LF_REPID     TYPE SY-REPID.
*  DATA: LF_DEVICE    TYPE TDDEVICE.
*  DATA: LS_RECIPIENT TYPE SWOTOBJID.
*  DATA: LS_SENDER    TYPE SWOTOBJID.
*
*  LF_REPID = SY-REPID.
*
*  CALL FUNCTION 'WFMC_PREPARE_SMART_FORM'
*    EXPORTING
*      PI_NAST       = NAST
*      PI_COUNTRY    = IS_DLV-LAND
*      PI_ADDR_KEY   = IS_ADDR_KEY
*      PI_REPID      = LF_REPID
*      PI_SCREEN     = XSCREEN
*    IMPORTING
*      PE_RETURNCODE = CF_RETCODE
*      PE_ITCPO      = LS_ITCPO
*      PE_DEVICE     = LF_DEVICE
*      PE_RECIPIENT  = CS_RECIPIENT
*      PE_SENDER     = CS_SENDER.
*
*  IF CF_RETCODE = 0.
*    MOVE-CORRESPONDING LS_ITCPO TO CS_COMPOSER_PARAM.
**   CS_CONTROL_PARAM-NO_OPEN
**   CS_CONTROL_PARAM-NO_CLOSE
*    CS_CONTROL_PARAM-DEVICE      = LF_DEVICE.
*    CS_CONTROL_PARAM-NO_DIALOG   = 'X'.
*    CS_CONTROL_PARAM-PREVIEW     = XSCREEN.
*    CS_CONTROL_PARAM-GETOTF      = LS_ITCPO-TDGETOTF.
*    CS_CONTROL_PARAM-LANGU       = NAST-SPRAS.
**   CS_CONTROL_PARAM-REPLANGU1
**   CS_CONTROL_PARAM-REPLANGU2
**   CS_CONTROL_PARAM-REPLANGU3
**   CS_CONTROL_PARAM-STARTPAGE
*  ENDIF.
*ENDFORM.                               " SET_PRINT_PARAM
*&---------------------------------------------------------------------*
*&      Form  CHECK_REPEAT
*&---------------------------------------------------------------------*
*FORM CHECK_REPEAT .
*
*  CLEAR REPEAT.
*  SELECT * INTO *NAST FROM NAST WHERE KAPPL = NAST-KAPPL
*                                AND   OBJKY = NAST-OBJKY
*                                AND   KSCHL = NAST-KSCHL
*                                AND   PARNR = NAST-PARNR
*                                AND   PARVW = NAST-PARVW
*                                AND   NACHA BETWEEN '1' AND '5'.
*    IF *NAST-VSTAT = '1'.
*      REPEAT = 'X'.
*    ENDIF.
*  ENDSELECT.
*
*
*ENDFORM.                    " CHECK_REPEAT
*&---------------------------------------------------------------------*
*&      Form  protocol_update_spool
*&---------------------------------------------------------------------*
*       The messages are collected for the processing protocol
**----------------------------------------------------------------------*
*FORM protocol_update_spool  USING    SYST_MSGNO
*                                     P_LS_SPOOLID
*                                     P_SPACE1
*                                     P_SPACE2
*                                     P_SPACE3.
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

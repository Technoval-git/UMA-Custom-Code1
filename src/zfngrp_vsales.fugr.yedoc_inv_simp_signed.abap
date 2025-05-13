FUNCTION yedoc_inv_simp_signed .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(P_ACT) TYPE  CHAR20
*"     REFERENCE(P_PROC) TYPE  CHAR20
*"     REFERENCE(P_BUKRS) TYPE  VBRK-BUKRS OPTIONAL
*"     REFERENCE(P_CRE_DATE) TYPE  VBRK-ERDAT OPTIONAL
*"     REFERENCE(P_PRSTA) TYPE  CHAR20
*"     REFERENCE(P_CPU_PE) TYPE  INT4 OPTIONAL
*"     REFERENCE(P_THREAD) TYPE  INT4 OPTIONAL
*"     REFERENCE(P_BILLNO) TYPE  VBRK-VBELN
*"     REFERENCE(P_TOT_VAT) TYPE  NETPR OPTIONAL
*"     REFERENCE(P_TOT_INV_AMT) TYPE  NETPR OPTIONAL
*"  EXPORTING
*"     REFERENCE(LS_QR) TYPE  STRING
*"     REFERENCE(LS_RETURN) TYPE  INT1
*"----------------------------------------------------------------------

  DATA: mo_cockpit TYPE REF TO cl_edoc_cockpit.
  DATA: lv_source_key    TYPE edoc_source_key,
        lv_edoc_guid     TYPE edoc_guid,
        lv_qr_code_x     TYPE edoc_sa_xstring,
        lv_qr_code       TYPE string,
        lv_not_relevant  TYPE abap_bool,
        lv_action_type   TYPE edoc_action_type,
        lt_edoc_guid_msg TYPE edoc_guid_error_message_tab,
        lv_rc            TYPE n,
        p_iv_act         TYPE edoc_action,
        lx_error         TYPE REF TO cx_edocument,
        lt_edoc_selected TYPE edoc_reslist_field_tab.

  DEFINE lmac_alpha_input.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input         = &1
   IMPORTING
     output        = &1
            .

  END-OF-DEFINITION.


*  lmac_alpha_input = p_billno .



  "Get Data from eDocument Table for SD/FI Source Document
  "For SD Invoice, use the below code snippet for populating variable
  "lv_source_key
  "Fill this variable with relevant Billing Document Number
  "along with leading zeros
  cl_edoc_source_sd_invoice=>pack_key(
   EXPORTING
   iv_vbeln = p_billno
   IMPORTING
   ev_key = lv_source_key ).

  "Also eDocument should be in GeneratedAndStored or SentToCustomer Status
  SELECT * FROM edocument INTO CORRESPONDING FIELDS OF TABLE lt_edoc_selected
   WHERE source_key = lv_source_key.

  IF sy-subrc = 0.
    lv_edoc_guid = lt_edoc_selected[ 1 ]-edoc_guid.
  ENDIF.
*   AND proc_status = 'CREATED'.

  "Get QR Code Data from KSA Specific Database Table using eDocument GUID
********************************************************************************************

  TRY.
      CLEAR lv_rc.
      p_iv_act = p_act.
      CREATE OBJECT mo_cockpit.
      "The action is allowed for at least one of the selected eDocuments
      mo_cockpit->mo_action->run( EXPORTING iv_action       = p_iv_act
                                            it_edocument    = lt_edoc_selected
                                            iv_not_relevant = lv_not_relevant
                                  IMPORTING ev_action_type  = lv_action_type
                                            et_log          = lt_edoc_guid_msg ).

    CATCH cx_edocument INTO lx_error.
      lv_rc = 1.
  ENDTRY.
********************************************************************************************
  IF lv_rc = 0.

    SELECT SINGLE qr_code FROM edosainv INTO lv_qr_code_x
     WHERE edoc_guid = lv_edoc_guid.
    lv_qr_code = cl_http_utility=>if_http_utility~encode_x_base64(
     unencoded = lv_qr_code_x ).

    ls_qr = lv_qr_code .
  ELSE.
    CLEAR ls_qr.
  ENDIF.


  IF ls_qr IS INITIAL.
    ls_return = 1.
  ELSE.
    ls_return = 0.
  ENDIF.

ENDFUNCTION.

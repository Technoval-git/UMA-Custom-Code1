*&---------------------------------------------------------------------*
*& Report ZFI_CUST_ACT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_cust_act.



TABLES: bseg,bkpf.

DATA: ls_output  TYPE sfpoutputparams,
      wa_fmname  TYPE funcname,
      lv_comp    TYPE bapi3007_1-comp_code,
      lv_cus     TYPE bapi3007_1-customer,
      lv_dat     TYPE bapi3007-key_date,
      wa_ret     TYPE bapireturn,
      lv_line    TYPE i,
      wa_header  TYPE zfi_cust_act_hdr,
      wa_item    TYPE zfi_cust_act_itm,
      wa_item_dz TYPE zfi_cust_act_itm,
      it_item    TYPE TABLE OF zfi_cust_act_itm,
      it_bal     TYPE TABLE OF bapi3007_3.

DATA:

  w_otf TYPE fpformoutput,
  t_otf TYPE STANDARD TABLE OF fpformoutput.
TYPES: BEGIN OF ty_binary,
         line TYPE x LENGTH 255,         "Binary Data
       END OF ty_binary.
DATA :
  lv_sf_fm       TYPE rs38l_fnam,
  g_objcont      TYPE solix_tab, "  TYPE STANDARD TABLE OF ty_binary,
  w_bin_size     TYPE i,
  w_pdf_xstring  TYPE xstring,
  send_request   TYPE REF TO cl_bcs,
  document       TYPE REF TO cl_document_bcs,
  sender         TYPE REF TO if_sender_bcs,
  recipient      TYPE REF TO if_recipient_bcs,
  message_body   TYPE bcsy_text,
  gv_send        TYPE ad_smtpadr,
  gv_sent_to_all TYPE os_boolean,
  binary_content TYPE solix_tab,
  t_line         TYPE STANDARD TABLE OF tline,
  size           TYPE so_obj_len,
  w_subject(50)  TYPE c,
  w_xsf          TYPE ssfcrescl.

DATA: lv_sent_to_all  TYPE os_boolean.

" Selection Screen
SELECTION-SCREEN:BEGIN OF BLOCK a1 WITH FRAME.
  SELECT-OPTIONS: so_bukrs FOR bseg-bukrs NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID md1,
                  so_gjahr FOR bseg-gjahr NO-DISPLAY NO INTERVALS NO-EXTENSION MODIF ID md1 DEFAULT syst-datum(4),
                  so_kunnr FOR bseg-kunnr NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID md1,
                  so_rundt FOR bkpf-budat NO-EXTENSION OBLIGATORY DEFAULT sy-datum MODIF ID md1.
SELECTION-SCREEN: END OF BLOCK a1.

SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME.
  PARAMETERS: p_mail TYPE char1 AS CHECKBOX DEFAULT ''.
SELECTION-SCREEN: END OF BLOCK b1.

AT SELECTION-SCREEN ON so_bukrs.
  SELECT SINGLE bukrs
    FROM t001
    INTO @DATA(ls_bukrs)
    WHERE bukrs EQ @so_bukrs-low.
  IF sy-subrc NE 0.
    MESSAGE 'Invalid Company code' TYPE 'E'.
  ENDIF.

AT SELECTION-SCREEN ON so_kunnr.
  SELECT SINGLE kunnr,
                bukrs
    FROM knb1
    INTO @DATA(ls_knb1)
    WHERE kunnr EQ @so_kunnr-low
      AND bukrs EQ @so_bukrs-low.
  IF sy-subrc NE 0.
    MESSAGE 'Invalid Customer for Company Code' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.

  CLEAR : so_gjahr[].
  so_gjahr-sign = 'I'.
  IF so_rundt-high IS INITIAL.
    so_gjahr-option = 'EQ'.
  ELSE.
    so_gjahr-option = 'BT'.
  ENDIF.
  so_gjahr-low  = so_rundt-low+0(4).
  so_gjahr-high =   so_rundt-high+0(4).
  APPEND so_gjahr.

  SELECT SINGLE *
    FROM kna1
    INTO @DATA(wa_cus)
   WHERE kunnr IN @so_kunnr.
  IF sy-subrc EQ 0.
    lv_cus = wa_header-kunnr = wa_cus-kunnr.
    wa_header-name  = wa_cus-name1.
    wa_header-line1 = wa_cus-ort01.
    wa_header-line2 = wa_cus-regio.
    wa_header-line3 = wa_cus-pstlz.
  ENDIF.
  lv_comp = wa_header-bukrs     = so_bukrs-low.
  lv_dat  = wa_header-from_date = so_rundt-low.
  lv_dat  = lv_dat - 1.
  IF so_rundt-high IS NOT INITIAL.
    wa_header-till_date = so_rundt-high.
  ELSE.
    wa_header-till_date = so_rundt-low.
  ENDIF.
  wa_header-from_date = |{ wa_header-from_date+6(2) }/{ wa_header-from_date+4(2) }/{ wa_header-from_date+0(4) }|.
  wa_header-till_date = |{ wa_header-till_date+6(2) }/{ wa_header-till_date+4(2) }/{ wa_header-till_date+0(4) }|.
  CALL FUNCTION 'BAPI_AR_ACC_GETKEYDATEBALANCE'
    EXPORTING
      companycode = lv_comp
      customer    = lv_cus
      keydate     = lv_dat
    IMPORTING
      return      = wa_ret
    TABLES
      keybalance  = it_bal.
  IF it_bal IS NOT INITIAL.
    READ TABLE it_bal ASSIGNING FIELD-SYMBOL(<lfs_bal>) INDEX 1.
    IF sy-subrc EQ 0.
      wa_header-bal = <lfs_bal>-t_curr_bal.
    ENDIF.
  ENDIF.

  IF so_bukrs[] IS NOT INITIAL AND
     so_kunnr[] IS NOT INITIAL.
    SELECT *
      FROM bseg
      INTO TABLE @DATA(it_bseg2)
     WHERE bukrs   IN @so_bukrs[]
       AND gjahr   IN @so_gjahr[]
       AND kunnr   IN @so_kunnr[]
       AND h_budat IN @so_rundt[]
       AND koart   EQ 'D'
       " Special GL indicator Noted Item
       AND umskz   NE 'F'.
    IF it_bseg2 IS NOT INITIAL.
      SORT it_bseg2 BY bukrs ASCENDING belnr ASCENDING gjahr ASCENDING.
      SELECT *
        FROM bkpf
        INTO TABLE @DATA(it_bkpf2)
         FOR ALL ENTRIES IN @it_bseg2
       WHERE bukrs = @it_bseg2-bukrs
         AND gjahr = @it_bseg2-gjahr
         AND belnr = @it_bseg2-belnr
         AND budat IN @so_rundt.
      IF sy-subrc EQ 0.
        SORT it_bkpf2 BY blart ASCENDING awtyp ASCENDING.
*        DELETE it_bkpf2 WHERE blart EQ 'AB' AND awtyp EQ 'BKPF'.
        SORT it_bkpf2 BY bukrs ASCENDING belnr ASCENDING gjahr ASCENDING.
      ENDIF.
      SORT it_bseg2 BY h_budat.
      SELECT bschl,
             ltext
        FROM tbslt
        INTO TABLE @DATA(lt_bschl)
        FOR ALL ENTRIES IN @it_bseg2
       WHERE spras = @sy-langu
         AND bschl = @it_bseg2-bschl
         AND umskz = @it_bseg2-umskz.
      IF sy-subrc EQ 0.
        SORT lt_bschl BY bschl ASCENDING.
      ENDIF.
      DATA(lv_balance) = wa_header-bal.

      SORT it_bseg2 BY h_budat ASCENDING bukrs ASCENDING
                       belnr   ASCENDING gjahr ASCENDING
                       buzei   ASCENDING.

      LOOP AT it_bseg2 ASSIGNING FIELD-SYMBOL(<lfs_bseg2>).
        DATA(lv_tabix) = sy-tabix + 1.
        READ TABLE it_bkpf2 ASSIGNING FIELD-SYMBOL(<lfs_bkpf2>)
              WITH KEY bukrs = <lfs_bseg2>-bukrs
                       belnr = <lfs_bseg2>-belnr
                       gjahr = <lfs_bseg2>-gjahr.
        IF sy-subrc = 0.

          " Date
          wa_item-bldat1 = <lfs_bkpf2>-bldat.
          wa_item-bldat = |{ <lfs_bkpf2>-bldat+6(2) }/{ <lfs_bkpf2>-bldat+4(2) }/{ <lfs_bkpf2>-bldat+0(4) }|.

          " Reference
          wa_item-belnr = <lfs_bkpf2>-awkey.

          " PTerms
          wa_item-zbd1t = <lfs_bseg2>-zbd1t.

          " User Ref
          READ TABLE lt_bschl ASSIGNING FIELD-SYMBOL(<lfs_bschl>)

               WITH KEY bschl = <lfs_bseg2>-bschl BINARY SEARCH.
          IF sy-subrc EQ 0.
            wa_item-bschl = <lfs_bschl>-ltext.
            UNASSIGN: <lfs_bschl>.
          ENDIF.

          " Separator
*          wa_item-bktxt = |: { <lfs_bkpf2>-bktxt }|.
           wa_item-bktxt = |: { <lfs_bkpf2>-xblnr }|.
          " Debit, Credit and Balance values
          IF <lfs_bseg2>-shkzg = 'S'. " Debit
            wa_item-shkzg_s = <lfs_bseg2>-dmbtr.
            wa_item-dmbtr = lv_balance = lv_balance + wa_item-shkzg_s.
          ELSEIF <lfs_bseg2>-shkzg = 'H'."Credit
            wa_item-shkzg_h = <lfs_bseg2>-dmbtr.
            wa_item-dmbtr = lv_balance = lv_balance - wa_item-shkzg_h.
          ENDIF.

          " Due Date
          wa_item-due = <lfs_bseg2>-netdt.
          wa_item-due = |{ wa_item-due+6(2) }/{ wa_item-due+4(2) }/{ wa_item-due+0(4) }|.

          " Credit and Debit Totals
          wa_header-debit = wa_item-shkzg_s + wa_header-debit.
          wa_header-credit = wa_item-shkzg_h + wa_header-credit.

          APPEND wa_item TO it_item.
          CLEAR: wa_item.

        ENDIF.
      ENDLOOP.


      lv_line = lines( it_item ).
      READ TABLE it_item ASSIGNING FIELD-SYMBOL(<lfs_item>) INDEX lv_line.
      IF sy-subrc EQ 0.
        wa_header-final_bal = <lfs_item>-dmbtr.
      ENDIF.

    ENDIF.

    IF it_item IS INITIAL.
      wa_header-final_bal = wa_header-bal.
    ENDIF.


    CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
        i_name     = 'ZFI_F_CUST_ACT'
      IMPORTING
        e_funcname = wa_fmname.


    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = ls_output
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
      LEAVE LIST-PROCESSING.
    ENDIF.

  DATA: doc_param TYPE sfpdocparams.
  doc_param-langu = 'E'.
  doc_param-country = 'US'.

    CALL FUNCTION wa_fmname
      EXPORTING
        /1bcdwb/docparams  = doc_param
        ls_header          = wa_header
        it_item            = it_item
      IMPORTING
        /1bcdwb/formoutput = w_otf
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF p_mail = 'X'.
      PERFORM sendmail.
    ENDIF.
    CALL FUNCTION 'FP_JOB_CLOSE'.

  ENDIF.
FORM sendmail .


  DATA: lv_adrnr   TYPE kna1-adrnr,
        lv_name1   TYPE kna1-name1,
        l_sub      TYPE so_obj_des,
        l_invoice  TYPE vbeln_vf,
        p_receiver TYPE so_recname.


*    * Create recipient
  SELECT SINGLE addrnumber FROM but020 INTO lv_adrnr WHERE partner = so_kunnr-low.
  IF sy-subrc = 0 AND lv_adrnr IS NOT INITIAL.
    SELECT SINGLE smtp_addr INTO gv_send FROM adr6 WHERE addrnumber = lv_adrnr.
    IF gv_send IS NOT INITIAL AND sy-subrc = 0.

      CALL METHOD cl_document_bcs=>xstring_to_solix
        EXPORTING
          ip_xstring = w_otf-pdf
        RECEIVING
          rt_solix   = g_objcont.


      CLASS cl_bcs DEFINITION LOAD.
      send_request = cl_bcs=>create_persistent( ).
      CONCATENATE 'Dear Business Partner,' lv_name1  INTO lv_name1.
*    * Create message body and name of the attachment

      APPEND lv_name1 TO message_body.
      APPEND INITIAL LINE TO message_body.
      APPEND 'Please find attached account statement.' TO message_body.
      APPEND INITIAL LINE TO message_body.
      APPEND 'Best regards,' TO message_body.
      APPEND 'Altawkilat' TO message_body.
      CONCATENATE 'Customer Account Statement' ''  INTO l_sub.
*    * Email Body
      document = cl_document_bcs=>create_document(
                                    i_type = 'RAW'
                                    i_text = message_body
                                    i_subject = l_sub ).
      TRY.
          w_subject = 'Customer Account Statement'.
          CALL METHOD document->add_attachment
            EXPORTING
              i_attachment_type    = 'PDF'
              i_attachment_subject = w_subject
              i_att_content_hex    = g_objcont.
        CATCH cx_document_bcs .
      ENDTRY.
*    * Pass the document to send request

      CALL METHOD send_request->set_document( document ).


*  gv_send = 'abcd@gmail.com'.
      recipient = cl_cam_address_bcs=>create_internet_address( gv_send ).

*    *Set recipient

      CALL METHOD send_request->add_recipient
        EXPORTING
          i_recipient = recipient
          i_express   = 'X'.
      TRY.
          CALL METHOD send_request->set_send_immediately
            EXPORTING
              i_send_immediately = 'X'.
          .
        CATCH cx_send_req_bcs .
      ENDTRY.

      TRY.
          CALL METHOD send_request->send
            EXPORTING
              i_with_error_screen = 'X'
            RECEIVING
              result              = lv_sent_to_all.
        CATCH cx_send_req_bcs .
      ENDTRY.

      IF lv_sent_to_all = 'X'.
        MESSAGE 'Email sent succesfully'TYPE 'S'.
      ELSEIF lv_sent_to_all IS INITIAL.
        MESSAGE i000(8i) WITH 'Email not send'.
      ENDIF.
      COMMIT WORK.

    ELSE.
      MESSAGE i000(8i) WITH 'Please maintain email for Customer'.
    ENDIF.
  ENDIF.
ENDFORM.

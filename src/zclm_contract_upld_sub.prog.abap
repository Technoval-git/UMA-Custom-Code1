*&---------------------------------------------------------------------*
*& Include          ZCLM_CONTRACT_UPLD_SUB
*&---------------------------------------------------------------------*

FORM upload_excel .
  lv_filename = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_filelength
      header                  = lv_headerxstring
    TABLES
      data_tab                = lt_records
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
      OTHERS                  = 17.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_filelength
    IMPORTING
      buffer       = lv_headerxstring
    TABLES
      binary_tab   = lt_records
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    "Implement suitable error handling here
  ENDIF.
  DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet .

  TRY .
      lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                              document_name = lv_filename
                              xdocument     = lv_headerxstring ) .
    CATCH cx_fdt_excel_core.
      "Implement suitable error handling here
  ENDTRY .

  "Get List of Worksheets
  lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
    IMPORTING
      worksheet_names = DATA(lt_worksheets) ).

  IF NOT lt_worksheets IS INITIAL.
    LOOP AT lt_worksheets INTO DATA(lv_woksheetname).

      DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                               lv_woksheetname ).
      "now you have excel work sheet data in dyanmic internal table
      ASSIGN lo_data_ref->* TO <gt_data_h>.
*    *-- Excel work sheet data in dyanmic internal table
      ASSIGN lo_data_ref->* TO <gt_data_h>.

*-Checking table strcuture componet count value
      IF lv_woksheetname EQ 'Contract'.
        DATA(lr_descr) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( gw_contract ) ).
      ELSEIF lv_woksheetname EQ 'Conditions'.
        lr_descr = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( gw_conditions ) ).
      ENDIF.

      DATA(l_count) = lines( lr_descr->components ).
      DATA :dref TYPE REF TO data.
      CREATE DATA dref LIKE LINE OF <gt_data_h>.
      ASSIGN dref->* TO  <gs_table>.
*-Checking excel file from PWC strcuture componet count value
      DATA(lr_descr1) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( <gs_table> ) ).
      DATA(l_count1) = lines( lr_descr->components ).

*-Deleting Excel  header
      DELETE <gt_data_h> FROM 1 TO 11.
      DATA:lv_int TYPE i.
      LOOP AT <gt_data_h> ASSIGNING FIELD-SYMBOL(<ls_datah>).
        LOOP AT lr_descr1->components[] ASSIGNING FIELD-SYMBOL(<ls_compnt>) FROM 1 TO l_count.
          lv_int = sy-tabix.

          DATA(ls_compont) = lr_descr->components[ lv_int ].
          ASSIGN COMPONENT <ls_compnt>-name OF STRUCTURE <ls_datah> TO FIELD-SYMBOL(<ls_fld>).
          IF sy-subrc IS INITIAL.
            IF lv_woksheetname EQ 'Contract'.
              ASSIGN COMPONENT ls_compont-name OF STRUCTURE gw_contract TO FIELD-SYMBOL(<ls_file>).
            ELSEIF lv_woksheetname EQ 'Conditions'.
              ASSIGN COMPONENT ls_compont-name OF STRUCTURE gw_conditions TO <ls_file>.
            ENDIF.
            IF sy-subrc IS INITIAL.
              <ls_file> = <ls_fld>.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF gw_contract IS NOT INITIAL AND lv_woksheetname EQ 'Contract'.
          APPEND gw_contract TO gt_contract.
        ELSEIF gw_conditions IS NOT INITIAL AND  lv_woksheetname EQ 'Conditions'.
          APPEND gw_conditions TO gt_conditions.
        ENDIF.
        CLEAR :gw_contract,  gw_conditions.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  EXPORT gt_contract TO DATABASE indx(id) ID 'ZREFX_CONTRACT_TAB'.
  EXPORT gt_conditions TO DATABASE indx(id) ID 'ZREFX_CONDITIONS_TAB'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_bapi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_bapi .
  DATA: gv_comp_code_ext        TYPE bapi_re_bus_entity_key-comp_code,
        gv_contract_type        TYPE bapi_re_contract_key-contract_type,

*Contract
        gt_contract_bapi        TYPE TABLE OF bapi_re_contract_dat,
        gw_contract_bapi        TYPE bapi_re_contract_dat,
* Frequency
        gt_term_frequency       LIKE TABLE OF bapi_re_term_rh_dat,
        gw_term_frequency       LIKE bapi_re_term_rh_dat,
**Posting
        gt_term_payment         LIKE TABLE OF bapi_re_term_py_dat,
        gw_term_payment         LIKE bapi_re_term_py_dat,
*Objects
        gt_object_rel           LIKE TABLE OF bapi_re_object_rel_dat,
        gw_object_rel           LIKE bapi_re_object_rel_dat,
**Conditions
*        gt_condition            LIKE TABLE OF bapi_re_condition_dat,
*        gw_condition            LIKE bapi_re_condition_dat,
*Valuation Parameters
        gt_term_evaluation      LIKE TABLE OF bapi_re_term_ce_dat,
        gw_term_evaluation      LIKE bapi_re_term_ce_dat,

        gt_evaluation_condition LIKE TABLE OF bapi_re_term_cecond_dat,
        gw_evaluation_condition LIKE bapi_re_term_cecond_dat,
*Adjustment
        gt_term_adjustment      LIKE TABLE OF bapi_re_term_aj_dat,
        gw_term_adjustment      LIKE bapi_re_term_aj_dat,
*Resubmit
        gt_resubmit_rule        LIKE TABLE OF bapi_re_resubm_rule_dat,
        gw_resubmit_rule        LIKE bapi_re_resubm_rule_dat,
**Partner
        gt_partner              LIKE TABLE OF bapi_re_partner_dat,
        gw_partner              LIKE bapi_re_partner_dat,
**Organization assignment
        gt_term_org_assignment  LIKE TABLE OF      bapi_re_term_oa_dat,
        gw_term_org_assignment  LIKE bapi_re_term_oa_dat,
** Extension in - Custom fields
        gt_extensionin          LIKE TABLE OF bapiparex,
        gw_extensionin          LIKE bapiparex,
        gv_contractnumber       TYPE bapi_re_contract_key-contract_number.

  DATA: gwa_ci             TYPE recn_contract_ci.
  CLEAR gwa_ci.

  DATA : lv_frequency   TYPE string, "recdtermnorh,
         lv_paymentform TYPE string, "recdtermnorh,
         lv_multi       TYPE char1.

  DATA : gv_condtype TYPE recdcondtype,
         lv_condtype TYPE recdcondtype,
         lv_kostl    TYPE rebdbusobjidacct.

  DATA : lv_condfr TYPE char10,
         lv_condto TYPE char10.

*  SELECT * FROM zre_interest_upd INTO TABLE @DATA(gt_interest)
*             FOR ALL ENTRIES IN @gt_contract
*                  WHERE bukrs EQ @gt_contract-bukrs
*                    AND smvart EQ @gt_contract-recntype.
*  IF sy-subrc EQ 0.
*    SORT gt_interest BY bukrs quarter smvart fiscal_year DESCENDING creat_date.
*  ENDIF.

  SELECT * FROM tivcdcondtypet
            INTO TABLE gt_condtypes
              FOR ALL ENTRIES IN gt_conditions
              WHERE condtype = gt_conditions-condtype and spras = 'E'.
*  WHERE xcondtypel = gt_conditions-condtype.

*  SELECT * FROM zre_costcenters INTO TABLE @DATA(gt_costcenters)
*                FOR ALL ENTRIES IN @gt_contract
*                  WHERE bukrs = @gt_contract-bukrs
*                  AND prctr = @gt_contract-prctr
*                  AND cnsubjecttype = @gt_contract-objtype.
*
*  SELECT * FROM znss_wh_locat INTO TABLE @DATA(gt_wh_locat)
*                FOR ALL ENTRIES IN @gt_contract
*                  WHERE company EQ @gt_contract-bukrs
*                     AND prctr = @gt_contract-prctr.
**                     AND wh_location = @gt_contract-zzrecn_ext.
*  IF sy-subrc EQ 0.
*    SORT gt_wh_locat BY company prctr wh_location.
*  ENDIF.

  SELECT bukrs, recnbeg, recnendabs     ", zzstort, zzktext
               FROM vicncn INTO TABLE @DATA(gt_vicncn)
               FOR ALL ENTRIES IN @gt_contract
               WHERE bukrs EQ @gt_contract-bukrs.
*               AND zzktext EQ @gt_contract-zzframe_recn.
*
*     select stand, ktext FROM T499S INTO TABLE @DATA(gt_t499s)
*                    FOR ALL ENTRIES IN @gt_contract
*               WHERE stand = @gt_contract-zzrecn_ext
*               and  ktext = @gt_contract-zzframe_recn.

  SELECT addrnumber, name1 FROM adrc INTO TABLE @DATA(gt_adrc)
              FOR ALL ENTRIES IN @gt_contract
              WHERE name1 EQ @gt_contract-zzframe_recn.
  IF sy-subrc EQ 0.
    SORT gt_adrc BY addrnumber.
    SELECT * FROM t499s INTO TABLE @DATA(gt_t499s)
               FOR ALL ENTRIES IN @gt_adrc
          WHERE addrnum = @gt_adrc-addrnumber.
    IF sy-subrc EQ 0.
      SORT gt_t499s BY stand.
    ENDIF.
  ENDIF.

  SELECT bukrs FROM t001
               INTO TABLE @DATA(gt_t001)
              FOR ALL ENTRIES IN @gt_contract
               WHERE bukrs = @gt_contract-bukrs.
  IF sy-subrc EQ 0.
    SORT gt_t001 BY bukrs.
  ENDIF.
  IF r1_simu IS NOT INITIAL.
    DATA(lv_test_run) = abap_true.
  ELSE.
    lv_test_run = abap_false.
  ENDIF.
  SORT gt_contract BY bukrs recntype.
  DELETE ADJACENT DUPLICATES FROM gt_contract COMPARING bukrs recntype.
  DESCRIBE TABLE gt_contract LINES DATA(lv_lines).
  IF lv_lines GT 1.
    MESSAGE 'File cannot contain multiple company codes & contract types' TYPE gc_e.
  ENDIF.

  SORT gt_contract BY bukrs recnnr.
  SORT gt_conditions BY recnnr.

  LOOP AT gt_contract INTO gw_contract.
    PERFORM validate_date_format CHANGING gw_contract-start_date.
    PERFORM validate_date_format CHANGING gw_contract-end_date.
    PERFORM validate_date_format CHANGING gw_contract-consbeg.

    READ TABLE gt_t001 TRANSPORTING NO FIELDS WITH KEY bukrs = gw_contract-bukrs BINARY SEARCH.
    IF sy-subrc NE 0.
      gw_final-type = gc_e.
      gw_final-reccn = gw_contract-recnnr.
      PERFORM f_message_handling USING gc_e gw_final-reccn TEXT-016
                              CHANGING gw_final-message gw_final-tlights.
      APPEND gw_final TO gt_final.
      CLEAR gw_final.
      CONTINUE.
    ENDIF.

*****
*****    READ TABLE gt_t499s INTO DATA(gw_t499s) WITH KEY stand = gw_contract-zzrecn_ext BINARY SEARCH.
*****    IF sy-subrc EQ 0.
*****      READ TABLE gt_adrc INTO DATA(gw_adrc) WITH KEY addrnumber = gw_t499s-addrnum BINARY SEARCH.
*****      IF sy-subrc NE 0.
*****        gw_final-type = gc_e.
*****        gw_final-reccn = gw_contract-recnnr.
*****        PERFORM f_message_handling USING gc_e gw_final-reccn TEXT-012
*****                                CHANGING gw_final-message gw_final-tlights.
*****        APPEND gw_final TO gt_final.
*****        CLEAR gw_final.
*****        CONTINUE.
*****      ELSE.
******        IF  gw_adrc-name1 NE gw_contract-zzframe_recn.
******          gw_final-type = gc_e.
******          gw_final-reccn = gw_contract-recnnr.
******          PERFORM f_message_handling USING gc_e gw_final-reccn 'Vendor ID not matched with upload file for Location'
******                                                   CHANGING gw_final-message gw_final-tlights.
******          APPEND gw_final TO gt_final.
******          CLEAR gw_final.
******          CONTINUE.
******        ENDIF.
*****      ENDIF.
*****    ELSE.
*****      gw_final-type = gc_e.
*****      gw_final-reccn = gw_contract-recnnr.
*****      PERFORM f_message_handling USING gc_e gw_final-reccn TEXT-013
*****                              CHANGING gw_final-message gw_final-tlights.
*****      APPEND gw_final TO gt_final.
*****      CLEAR gw_final.
*****      CONTINUE.
*****    ENDIF.
*****************    SELECT SINGLE * FROM vicncn INTO @DATA(lw_vicncn)
*****************                           WHERE ( recnbeg  BETWEEN  @gw_contract-start_date AND @gw_contract-end_date )
*****************                            AND  ( recnendabs BETWEEN @gw_contract-start_date AND @gw_contract-end_date ).
******************                            AND   zzstort    = @gw_t499s-stand               "gw_contract-zzrecn_ext
******************                            AND   zzktext    = @gw_contract-zzframe_recn.
*****************    IF sy-subrc EQ 0.
*****************      gw_final-type = gc_e.
*****************      gw_final-reccn = gw_contract-recnnr.
*****************      PERFORM f_message_handling USING gc_e gw_final-reccn TEXT-011
*****************                                 CHANGING gw_final-message gw_final-tlights.
*****************      APPEND gw_final TO gt_final.
*****************      CLEAR gw_final.
*****************      CONTINUE.
*****************    ENDIF.

    gv_comp_code_ext = gw_contract-bukrs.
    gv_contract_type = gw_contract-recntype.

****** Contract
    gw_contract_bapi-main_contract_comp_code     = gw_contract-bukrs.
    gw_contract_bapi-contract_text               = gw_contract-contract_text.
    gw_contract_bapi-old_contract_number         = gw_contract-old_contract_no.
    gw_contract_bapi-contract_start_date         = gw_contract-start_date.
    gw_contract_bapi-first_end_date              = gw_contract-end_date.
    gw_contract_bapi-cash_flow_start_date        = gw_contract-start_date.
    gw_contract_bapi-valuation_relevance         = gw_contract-relevanteval.
*    gw_contract_bapi-tenancy_law = '6'.
    APPEND gw_contract_bapi TO gt_contract_bapi.

******* Partners
    gw_partner-partner  = gw_contract-partner.
    gw_partner-role_type  = 'FLCU01'."zcl_refx=>c_role_type.          " 'TR0602'.
    APPEND gw_partner TO gt_partner.
    CLEAR gw_partner.

      gw_partner-partner  = gw_contract-partner.
    gw_partner-role_type  = 'FLCU00'."zcl_refx=>c_role_type.          " 'TR0602'.
    APPEND gw_partner TO gt_partner.
    CLEAR gw_partner.

******* Organization Assignment
    gw_term_org_assignment-profit_ctr = gw_contract-prctr.
    gw_term_org_assignment-FUNC_AREA = gw_contract-FUNCTIONALAREA.
    APPEND gw_term_org_assignment     TO gt_term_org_assignment.
    CLEAR gw_term_org_assignment.

******  Posting
*    READ TABLE gt_costcenters INTO DATA(lw_costcenters)
*                                   WITH KEY bukrs = gw_contract-bukrs
*                                            prctr = gw_contract-prctr
*                                            cnsubjecttype = gw_contract-objtype
*                                            smvart   = gw_contract-recntype.
**    zcl_refx=>get_posting( EXPORTING im_contract_type  = gw_contract-recntype
**                                     im_partner        = gw_contract-partner
**                           IMPORTING ex_term_payment   = gw_term_payment ).
*    IF sy-subrc EQ 0.
*      gw_term_payment-acc_det_key = lw_costcenters-accdetkey.
*      gw_term_payment-partner = gw_contract-partner.
*      APPEND gw_term_payment TO gt_term_payment.
*      CLEAR gw_term_payment.
*    ENDIF.


    CLEAR: lv_frequency,lv_paymentform,lv_multi.

*    gw_conditions = gt_conditions[ recnnr = gw_contract-recnnr ].
    READ TABLE gt_conditions INTO gw_conditions WITH KEY recnnr = gw_contract-recnnr BINARY SEARCH.
    IF sy-subrc = 0.
      DATA(lv_index_cond) = sy-tabix.
      LOOP AT gt_conditions INTO gw_conditions FROM lv_index_cond.   "WHERE  recnnr = gw_contract-recnnr.
        IF  gw_conditions-recnnr <> gw_contract-recnnr.
          EXIT.
        ENDIF.
*        IF gw_conditions-frequency EQ lv_frequency AND gw_conditions-paymentform EQ lv_paymentform.
*          CONTINUE.
*        ENDIF.

******  Frequency
*        zcl_refx=>get_frequency( EXPORTING im_ternmnorh   = gw_conditions-frequency
*                                           im_paymentform = gw_conditions-paymentform
*                                 IMPORTING ex_frequency   = gw_term_frequency ).

    IF   gw_conditions-frequency    ='Monthly' .
      gw_term_frequency-frequency        = '0001'.
      gw_term_frequency-frequency_unit        = 0.
    ELSEIF  gw_conditions-frequency = 'Quaterly'.
      gw_term_frequency-frequency        = '0003'.
      gw_term_frequency-frequency_unit        = 0.
    ELSEIF gw_conditions-frequency  = 'Semi Annually'.
      gw_term_frequency-frequency        = '0006'.
      gw_term_frequency-frequency_unit        = 0.
    ELSEIF gw_conditions-frequency  = 'Annually' .
      gw_term_frequency-frequency        = '0001'.
      gw_term_frequency-frequency_unit        = 1.
    ELSEIF gw_conditions-frequency  = 'onetime' .
      gw_term_frequency-frequency        = '0001'.
     gw_term_frequency-frequency_unit        = 0.
    ENDIF.
    gw_term_frequency-due_date_move_begin = abap_true.
    gw_term_frequency-due_date_move_end   = abap_true.
    gw_term_frequency-starting_month              = 14.
    gw_term_frequency-condition_amount_ref        = 3.

*    gw_term_frequency-term_no    = c_termno_0001.
*    gw_term_frequency-term_text   gw_conditions-xterm.
    IF gw_conditions-paymentform   = 'Start'.
      gw_term_frequency-payment_form    = '0000'.
    ELSEIF gw_conditions-paymentform = 'Inmiddle'.
      gw_term_frequency-payment_form    = '0001'.
    ELSEIF gw_conditions-paymentform = 'End'.
      gw_term_frequency-payment_form    = '0002'.
    ENDIF.

*****
        IF gw_conditions-paymentform = 'End'.
*        IF lv_multi = abap_true.
          gw_term_frequency-term_no = '10'.
          DATA(lv_freq) = abap_true.
        ENDIF.
        APPEND gw_term_frequency TO gt_term_frequency.
        CLEAR gw_term_frequency.

******  Conditions
        READ TABLE gt_condtypes INTO DATA(gw_condtype1)
                              WITH KEY condtype = gw_conditions-condtype.
*         WITH KEY xcondtypel = gw_conditions-condtype.
        IF sy-subrc EQ 0.
          PERFORM validate_date_format CHANGING gw_conditions-cond_valid_from.
          PERFORM validate_date_format CHANGING gw_conditions-cond_valid_to.
*          zcl_refx=>get_conditions( EXPORTING im_condtype   = gw_condtype1-condtype
*                                              im_valid_from = gw_conditions-cond_valid_from
*                                              im_valid_to   = gw_conditions-cond_valid_to
*                                              im_unitprice  = gw_conditions-unitprice
*                                    IMPORTING ex_condtype   = gw_condition ).

    gw_condition-condition_type = gw_conditions-condtype.
    gw_condition-unit_price = gw_conditions-unitprice.
    gw_condition-calculation_object_id           = '0010' . "c_cal_obj_id.           "'0010'.
    gw_condition-calculation_object_type         = 'J4'  . "c_cal_obj_typ.          "'J4'.
    gw_condition-valid_from                      = gw_conditions-cond_valid_from.
    gw_condition-valid_to                        = gw_conditions-cond_valid_to ."im_valid_to. "20230331
    gw_condition-calc_rule                       = 'A'.
*    IF gw_condition-frequency ='onetime'.
*      gw_condition-external_purpose             = 'B'.
*    ELSE.
    gw_condition-external_purpose                = 'A'.
*    ENDIF.

        ENDIF.
        IF lv_freq = abap_true.
*        IF lv_multi = abap_true.
          gw_condition-term_no_rhythm = '10'.
        ENDIF.
        gw_condition-EXTERNAL_PURPOSE = 'A'.
        APPEND gw_condition TO gt_condition.
        IF gw_conditions-calcrule IS NOT INITIAL AND gw_conditions-distrule IS NOT INITIAL.
          PERFORM add_grading.
        ENDIF.

*   Evaluation Condition
        CLEAR lv_condtype.
        lv_condtype = gw_condition-condition_type.
*        zcl_refx=>get_term_evaluation_condition( EXPORTING im_condtype      = lv_condtype
*                                                           im_cerrule       = gw_contract-cerule
*                                                          im_cond_vali_from = gw_conditions-cond_valid_from
*                                                          im_cond_vali_to   = gw_conditions-cond_valid_to
*                                     IMPORTING et_evaluation_condition      = gt_evaluation_condition ).
*        lv_frequency = gw_conditions-frequency.
*        lv_paymentform = gw_conditions-paymentform.
*        lv_multi = abap_true.
        CLEAR lv_freq.
      ENDLOOP.
      CLEAR : lv_frequency, lv_paymentform, lv_multi.

      LOOP AT gt_condition  INTO DATA(lw_condition).
        READ TABLE gt_evaluation_condition INTO DATA(lw_evaluation_condition)
                                            WITH KEY condition_type       = lw_condition-condition_type.
*                                                   condition_valid_from = lw_condition-valid_from
*                                                   condition_valid_to   = lw_condition-valid_to.
        IF sy-subrc EQ 0.
          IF  lw_evaluation_condition-condition_valid_from EQ lw_condition-valid_from
          AND lw_evaluation_condition-condition_valid_to   EQ lw_condition-valid_to.
          ELSE.
            lw_evaluation_condition-condition_valid_from = lw_condition-valid_from.
            lw_evaluation_condition-condition_valid_to   = lw_condition-valid_to.
            APPEND lw_evaluation_condition TO gt_evaluation_condition.
            CLEAR lw_evaluation_condition.
          ENDIF.
        ENDIF.
      ENDLOOP.

*******  Objects
*****      READ TABLE gt_wh_locat INTO DATA(lw_prctr)
*****                               WITH KEY company = gw_contract-bukrs
*****                                        prctr = gw_contract-prctr
*****                                        wh_location = gw_contract-zzrecn_ext BINARY SEARCH.  "gw_t499s-stand.
*****      IF sy-subrc NE 0.
*****        gw_final-type = gc_e.
*****        gw_final-reccn = gw_contract-recnnr.
*****        PERFORM f_message_handling USING gc_e gw_final-reccn TEXT-014
*****                                    CHANGING gw_final-message gw_final-tlights.
*****        APPEND gw_final TO gt_final.
*****        CLEAR gw_final.
*****        CONTINUE.
*****      ENDIF.
****      zcl_refx=>get_objects_rel( EXPORTING im_objtype = gw_contract-objtype
****                                           im_contract_subtxt = gw_contract-zzrecn_ext    "gw_t499s-stand
****                                           im_start_date = gw_contract-start_date
****                                           im_end_date   = gw_contract-end_date
****                                IMPORTING ex_objects_rel = gw_object_rel ).
*    CONCATENATE 'VI01/' '10GUJG9801' INTO lv_kostl.
*      READ TABLE gt_costcenters INTO lw_costcenters
*                                    WITH KEY bukrs = gw_contract-bukrs
*                                             prctr = gw_contract-prctr
*                                             cnsubjecttype = gw_contract-objtype.
*      IF sy-subrc EQ 0.
*****      IF lw_costcenters-kostl IS NOT INITIAL.
*****        CONCATENATE 'VI01/' lw_costcenters-kostl INTO lv_kostl.
*****      ENDIF.
*      ENDIF.
    gw_object_rel-contract_object_type      = 'IE'.
    gw_object_rel-contract_object_id        = gw_contract-objtype."im_objtype.              "'CSIND'.
*    gw_object_rel-object_group_number       = '0010'.
*    gw_object_rel-informational_assignment  = 'X'.
*    gw_object_rel-object_type_acct          = 'IE'. "c_bus_obj_typ.            "'KS'.
    gw_object_rel-contract_subject_text     = gw_contract-zzrecn_ext. "im_contract_subtxt.       "'IDGJ100020
*****    gw_object_rel-contract_subject_type     = im_objtype.               "'CSIND'.
    gw_object_rel-valid_from                = gw_contract-start_date. "im_start_date.
    gw_object_rel-valid_to                  = gw_contract-end_date."im_end_date.
*      gw_object_rel-object_id_acct = lv_kostl.
      APPEND gw_object_rel TO gt_object_rel.
      CLEAR gw_object_rel.



*****      LOOP AT gt_interest INTO DATA(gw_interest).
*****        IF gw_interest-fiscal_year EQ gw_contract-start_date+0(4) AND
*****           ( gw_contract-start_date BETWEEN gw_interest-from_date AND gw_interest-to_date ).
*****          DATA(lv_interest_rate)                 = gw_interest-interest_rate .
*****        ENDIF.
*****        IF lv_interest_rate IS NOT INITIAL.
*****          EXIT.
*****        ENDIF.
*****      ENDLOOP.

*   Interest Rate
      IF gw_contract-interestrate IS NOT INITIAL.
*****        lv_interest_rate = gw_contract-interestrate.
        DATA(lv_interest_chk) = abap_true.
      ENDIF.
*****      zcl_refx=>get_term_evaluation( EXPORTING im_consbeg      = gw_contract-consbeg
*****                                              im_usefullifeend = gw_contract-usefullifeend
*****                                              im_kostl         = lv_kostl
*****                                              im_interest_rate = lv_interest_rate
*****                                              im_cerrule       = gw_contract-cerule
*****                                   IMPORTING et_term_eval      = gt_term_evaluation ).
*****
****** Custom fields Location ID , Vendor ID and Vendor Text
*****      zcl_refx=>get_extensionin( EXPORTING im_zzstort          = gw_contract-zzrecn_ext
*****                                            im_zzktext         = gw_contract-zzframe_recn
*****                                            im_zzusrtext       = gw_contract-zzusrtext
*****                                            im_zzinterest_chk  = lv_interest_chk
*****                                 IMPORTING et_extensionin      = gt_extensionin ).



      CALL FUNCTION 'BAPI_RE_CN_CREATE'
        EXPORTING
          comp_code_ext             = gv_comp_code_ext
          contract_type             = gv_contract_type
          contract                  = gw_contract_bapi
          trans                     = 'MCAK'
          test_run                  = lv_test_run
        IMPORTING
          contractnumber            = gv_contractnumber
        TABLES
          term_org_assignment       = gt_term_org_assignment
          term_payment              = gt_term_payment
          term_rhythm               = gt_term_frequency
          partner                   = gt_partner
          object_rel                = gt_object_rel
          condition                 = gt_condition
          extension_in              = gt_extensionin
          return                    = gt_return
          term_evaluation           = gt_term_evaluation
          term_evaluation_condition = gt_evaluation_condition.
      IF gt_return IS NOT INITIAL.
        READ TABLE gt_return WITH KEY type = gc_e TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.
          IF gv_contractnumber IS NOT INITIAL.
            PERFORM f_perform_valuation_parameters USING gv_contractnumber.
          ENDIF.
        ENDIF.
        LOOP AT gt_return INTO DATA(ls_ret).
          PERFORM f_message_handling USING ls_ret-type gv_contractnumber ls_ret-message
                                           CHANGING gw_contract-remarks gw_contract-icon.

          MOVE-CORRESPONDING ls_ret TO gw_final.
          gw_final-reccn = gv_contractnumber.
          gw_final-seqno = gw_contract-recnnr.
          APPEND gw_final TO gt_final.
          CLEAR :gw_final, ls_ret.
        ENDLOOP.
      ENDIF.
    ELSE.
      gw_final-type = gc_e.
      gw_final-reccn = gw_contract-recnnr.
      PERFORM f_message_handling USING gc_e gw_final-reccn TEXT-015
                              CHANGING gw_final-message gw_final-tlights.
      APPEND gw_final TO gt_final.
      CLEAR gw_final.
*      CONTINUE.
    ENDIF.
    CLEAR   : gw_contract_bapi,   gw_term_frequency,  gw_term_payment,  gw_object_rel, gw_condition,
              gw_term_evaluation, gw_term_adjustment, gw_resubmit_rule, gw_contract.
*              gw_adrc,
*              gw_t499s.
    REFRESH : gt_contract_bapi,   gt_term_frequency,  gt_term_payment,  gt_object_rel, gt_evaluation_condition, gt_condition,
              gt_term_evaluation, gt_term_evaluation, gt_resubmit_rule, gt_partner, gt_term_org_assignment, gt_extensionin.
*    CLEAR   : lv_kostl, lv_interest_rate, lv_condtype, lv_index, lv_interest_chk, gv_contractnumber.
      CLEAR   : lv_kostl, lv_condtype, lv_index, lv_interest_chk, gv_contractnumber.
  ENDLOOP.
ENDFORM.
FORM f_message_handling  USING    p_type
                                  p_gv_buildingnumber
                                  p_message
                                 CHANGING p_remarks
                                  p_icon.

  IF p_type EQ gc_e.
    CONCATENATE p_remarks p_message INTO p_remarks.
    p_icon = gc_red.
  ELSEIF  p_type EQ gc_s.
    CONCATENATE p_gv_buildingnumber p_message INTO p_remarks.
    p_icon = gc_green.
  ENDIF.
ENDFORM.
**&---------------------------------------------------------------------*
**& Form display
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
FORM display .
*- Display ALV
  DATA :lc_smess  TYPE char12.
  lc_smess = 'ContractREFX'.
  LOOP AT gt_final ASSIGNING FIELD-SYMBOL(<abc>).
*    IF <abc>-type = 'S' and lc_smess co <abc>-message..
    IF <abc>-type = 'S' AND  <abc>-message+0(12) = lc_smess.
      <abc>-tlights = '3'.
    ELSEIF <abc>-type = 'E'.
      <abc>-tlights = '1'.
    ELSE.
      <abc>-tlights = '2'.
    ENDIF.
  ENDLOOP.
  TRY.
      cl_salv_table=>factory(
      IMPORTING
        r_salv_table = go_alv
      CHANGING
        t_table      = gt_final ).
    CATCH cx_salv_msg.
  ENDTRY.

  gr_columns = go_alv->get_columns( ).
  gr_columns->set_exception_column( value = 'TLIGHTS' ).

  IF go_alv IS BOUND.
    CALL METHOD go_alv->display( ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
**& Form f_perform_valuation_parameters
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**&      --> GV_CONTRACTNUMBER
**&      --> LW_BUILD_CI
**&      <-- LW_EXCEL
**&---------------------------------------------------------------------*
FORM f_perform_valuation_parameters  USING    p_gv_contractnumber.

  CLEAR: lv_bukrs_c,lv_recnnr,lt_term_val,lt_term_val_cal,
     lt_term_val_cal_u,lt_term_val_u,lt_status,lt_status_u,lt_term_org.

  DATA : lt_return TYPE  TABLE OF bapiret2.

*  lv_bukrs_c = lw_excel-comp_code.
  lv_bukrs_c = gw_contract-bukrs.
  lv_recnnr = p_gv_contractnumber.

  CALL FUNCTION 'API_RE_CN_GET_DETAIL'
    EXPORTING
      id_bukrs                     = lv_bukrs_c
      id_recnnr                    = lv_recnnr
    IMPORTING
      et_term_org_assignment       = lt_term_org
      et_term_evaluation           = lt_term_val
      et_term_evaluation_condition = lt_term_val_cal
      et_status                    = lt_status.


  IF lt_term_val[] IS NOT INITIAL AND lt_term_val_cal[] IS NOT INITIAL.
    MOVE-CORRESPONDING lt_term_val TO lt_term_val_u.
    MOVE-CORRESPONDING lt_term_val_cal TO lt_term_val_cal_u.

    LOOP AT lt_term_val_u ASSIGNING FIELD-SYMBOL(<ls_val>).
      <ls_val>-changeind = 'U'.
      <ls_val>-statusrule = 'C'.
      <ls_val>-statuseval = 'C'.
    ENDLOOP.
    LOOP AT  lt_term_val_cal_u ASSIGNING FIELD-SYMBOL(<ls_valc>).
      <ls_valc>-changeind = 'U'.
      <ls_valc>-statuscondrule = 'C'.
    ENDLOOP.

    CALL FUNCTION 'API_RE_CN_CHANGE'
      EXPORTING
        id_bukrs                     = lv_bukrs_c
        id_recnnr                    = lv_recnnr
        it_term_evaluation           = lt_term_val_u
        it_term_evaluation_condition = lt_term_val_cal_u
*       IT_STATUS                    = lt_status_u
      EXCEPTIONS
        error                        = 1
        OTHERS                       = 2.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

*      PERFORM f_bdc_update_status1 USING lv_recnnr.
*      CLEAR lv_stat_flag.
*
*      DATA(gv_trans) = 'MCAK'.
*      CALL FUNCTION 'BAPI_RE_CN_CHANGE'
*        EXPORTING
*          compcode       = '1000'
*          contractnumber = lv_recnnr
*          trans          = gv_trans
**         test_run       = p_test
*        TABLES
*          return         = lt_return.
*      READ TABLE lt_return INTO DATA(ls_return) WITH KEY type = 'E'.  "Error
*      IF sy-subrc EQ 0.
*        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'  .
*      ELSE.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'  "Commit Transaction
*          EXPORTING
*            wait = abap_true.
*      ENDIF.

*      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO
**----------------------------------------------------------------------*
**        Insert field                                                  *
**----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> nodata.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.
**&---------------------------------------------------------------------*
**& Form f_bdc_update_status1
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**&      --> LV_RECNNR
**&---------------------------------------------------------------------*
FORM f_bdc_update_status1  USING    p_lv_recnnr.
  DATA : lt_message       TYPE TABLE OF bdcmsgcoll,
         lwa_message      TYPE bdcmsgcoll,
         lt_message_grad  TYPE TABLE OF bdcmsgcoll,
         lwa_message_grad TYPE bdcmsgcoll,
         lv_lock          TYPE char1,
         lv_message       TYPE char30.
  REFRESH : lt_message[],bdcdata[], lt_message ,lt_message_grad.
  REFRESH bdcdata[].
*********************************************************
  PERFORM bdc_dynpro      USING 'SAPLRECA_BDT_APPL_INITIAL' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=RECA_ENTER'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RECN_CONTRACT_X-BUKRS'.
  PERFORM bdc_field       USING 'RECN_CONTRACT_X-BUKRS'
                                 '1000'.  "record-BUKRS_001.
  PERFORM bdc_field       USING 'RECN_CONTRACT_X-RECNNR'
                                p_lv_recnnr.  "record-RECNNR_002.
  PERFORM bdc_dynpro      USING 'SAPLRECA_BDT_APPL_TOOL' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=REWB_DISPCHANGE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'GS_OBJECT_INFO-OBJIDENT'.
  PERFORM bdc_dynpro      USING 'SAPLRECA_BDT_APPL_TOOL' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=RECA_STATUS'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'REGCFLDS_FE-OBJIDENT'.
  PERFORM bdc_dynpro      USING 'SAPLBSVA' '0300'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'JOSTD-STSMA'.
  PERFORM bdc_field       USING 'JOSTD-STSMA'
                                'ZRE_CN'.  "record-STSMA_010.
  PERFORM bdc_dynpro      USING 'SAPLSPO1' '0500'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=OPT1'.
  PERFORM bdc_dynpro      USING 'SAPLBSVA' '0300'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'J_STMAINT-ANWS(02)'.
*perform bdc_field       using 'JOSTD-STSMA'
*                              record-STSMA_011.
*perform bdc_field       using 'J_STMAINT-ANWS(01)'
*                              'record-ANWS_01_012.
  PERFORM bdc_field       USING 'J_STMAINT-ANWS(02)'
                                'X'.  "record-ANWS_02_013.
  PERFORM bdc_dynpro      USING 'SAPLRECA_BDT_APPL_TOOL' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=RECA_STATUS'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'REGCFLDS_FE-OBJIDENT'.
  PERFORM bdc_dynpro      USING 'SAPLBSVA' '0300'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'J_STMAINT-ANWS(03)'.
*perform bdc_field       using 'JOSTD-STSMA'
*                              record-STSMA_021.
*perform bdc_field       using 'J_STMAINT-ANWS(02)'
*                              record-ANWS_02_022.
  PERFORM bdc_field       USING 'J_STMAINT-ANWS(03)'
                                'X'.  "record-ANWS_03_023.
  PERFORM bdc_dynpro      USING 'SAPLRECA_BDT_APPL_TOOL' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=RECA_BDT_STORE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'REGCFLDS_FE-OBJIDENT'.
  CALL TRANSACTION 'RECN' USING bdcdata MODE 'N' UPDATE 'L' MESSAGES INTO lt_message.
ENDFORM.
**&---------------------------------------------------------------------*
**& Form validations
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM file_validations .
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form clear_date
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**&      --> GW_CONDITIONS_ADJ_NEXTDATE
**&      <-- GW_CONDITION_NEXT_ADJUSTMENT_D
**&---------------------------------------------------------------------*
*FORM clear_date  USING    p_gs_file_data_rel_startdate
*                 CHANGING p_ls_partner_valid_from  TYPE dats.
*
*
*  IF p_gs_file_data_rel_startdate IS NOT INITIAL.
*    p_ls_partner_valid_from = p_gs_file_data_rel_startdate.
*  ELSE.
*    CLEAR p_ls_partner_valid_from.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form add_grading_conditions
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**&      --> GW_CONDITION
**&---------------------------------------------------------------------*
*FORM add_grading_conditions  USING p_ls_condition TYPE bapi_re_condition_dat..
**FIELD-SYMBOLS: <lfs_condition>    TYPE bapi_re_condition_dat.
*
*  DATA: lv_tabix         TYPE sy-tabix,
*        lv_condvalidfrom TYPE sy-datum,
*        lv_condvalidto   TYPE sy-datum,
*        lv_time          TYPE mara-mhdhb.
*
*  CONSTANTS: lc_month TYPE mara-iprkz VALUE '2'.
*
*  DESCRIBE TABLE gt_condition LINES lv_tabix.
*  READ TABLE gt_condition ASSIGNING FIELD-SYMBOL(<lfs_condition>) INDEX lv_tabix.
*  IF sy-subrc = 0.
*    IF <lfs_condition>-valid_to IS INITIAL.
*      lv_condvalidfrom = <lfs_condition>-valid_from.
*      lv_time = gw_conditions-gradmonth.
*      CALL FUNCTION 'ADD_TIME_TO_DATE'
*        EXPORTING
*          i_idate               = lv_condvalidfrom
*          i_time                = lv_time
*          i_iprkz               = lc_month
*        IMPORTING
*          o_idate               = lv_condvalidto
*        EXCEPTIONS
*          invalid_period        = 1
*          invalid_round_up_rule = 2
*          internal_error        = 3
*          OTHERS                = 4.
*      IF sy-subrc IS INITIAL.    "++ASINGH0318102017
*        <lfs_condition>-valid_to = lv_condvalidto - 1.
*      ENDIF.
*
*    ENDIF.
*  ENDIF.
*
*  p_ls_condition-valid_from = lv_condvalidto.  "Valid from Changed
*
*  "" Unit Price changed
*  IF gw_conditions-gradpercent IS NOT INITIAL.
*    p_ls_condition-unit_price = p_ls_condition-unit_price + ( ( p_ls_condition-unit_price * gw_conditions-gradpercent ) / 100 ).
*  ELSE.
*    p_ls_condition-unit_price = p_ls_condition-unit_price + gw_conditions-gradabsolute.
*  ENDIF.
*
*  APPEND p_ls_condition TO gt_condition.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form get_hcf
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
FORM get_hcf .
*  CONSTANTS : lc_id     TYPE zxdynamic_func-id        VALUE 'ZNI_MRN',
*              lc_crt1   TYPE zxdynamic_func-criteria1 VALUE 'CHECK',
*              lc_value1 TYPE zxdynamic_func-value1    VALUE 'MRN'.

*****  lwa_hcf-id        = 'ZNI_MRN'. " lc_id.
*****  lwa_hcf-criteria1 = 'CHECK'. "lc_crt1.
*****  lwa_hcf-value1    = 'MRN'. "lc_value1.

*****  CALL METHOD zcl_dynamic_param=>get_multiple_func
*****    EXPORTING
*****      im_zxdynamic_func = lwa_hcf
*****    RECEIVING
*****      re_zxdynamic_func = lt_hcf.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_file_valid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_file_valid .
**  SELECT bukrs FROM t001
**             INTO TABLE @DATA(gt_t001)
**            FOR ALL ENTRIES IN @gt_contract
**             WHERE bukrs = @gt_contract-bukrs.
**
**  SELECT smvart,
**          xmbez
**     FROM tiv2f
**     INTO TABLE @DATA(gt_contract_type)
**      FOR ALL ENTRIES IN @gt_contract
**     WHERE spras = 'EN'
**     AND smvart = @gt_contract-recntype.
**
****    Object type :
**  SELECT cnsubjecttype,
**        cuexcludeassign
**        FROM tivbdcnsubtype
**                 INTO TABLE @DATA(gt_object_type)
**                 FOR ALL ENTRIES IN @gt_contract
**                 WHERE cnsubjecttype = @gt_contract-objtype.
**** Business partner number
**  SELECT partner FROM but000
**             INTO TABLE @DATA(gt_but000)
**                    FOR ALL ENTRIES IN @gt_contract
**                        WHERE partner = @gt_contract-partner.
**** Location & Vendor ID
**  SELECT * FROM t499s
**           INTO TABLE @DATA(gt_t499s)
**                  FOR ALL ENTRIES IN @gt_contract
**                      WHERE stand = @gt_contract-zzrecn_ext.
*
*
***    Valuation Rule
**  SELECT * FROM tivcerule
**           INTO TABLE @DATA(gt_valrule)
**                  FOR ALL ENTRIES IN @gt_contract
**                      WHERE cerule = @gt_contract-cerule.
**
**
************************  Conditions  ************************
****  Conditon type
**
**  SELECT * FROM tivcdcondtypet
**          INTO TABLE @DATA(gt_condtype)
**                 FOR ALL ENTRIES IN @gt_conditions
**                     WHERE xcondtypel = @gt_conditions-condtype
**                      AND spras  = 'E'.
**
**  SELECT * FROM znss_wh_locat INTO TABLE @DATA(gt_wh_locat)
**              FOR ALL ENTRIES IN @gt_contract
**                WHERE prctr = @gt_contract-prctr
**                   AND wh_location = @gt_contract-zzrecn_ext.
*  LOOP AT gt_contract INTO gw_contract.
*    DATA(lv_index) = sy-tabix.
**    IF  gw_contract-recnnr IS INITIAL.
**      DATA(lv_reccn_msg) = 'Please maintain sequence number for Contract Details'.
**    ELSE.
**      IF gw_contract-recnnr CO '0123456789'.
**        lv_reccn_msg = 'Please maintain Proper sequence number for Contract Details'.
**      ENDIF.
**    ENDIF.
**
**    IF  gw_contract-bukrs IS INITIAL.
**      DATA(lv_bukrs_msg) = 'Please enter company code'.
**    ELSE.
**      READ TABLE gt_t001 TRANSPORTING NO FIELDS WITH KEY bukrs = gw_contract-bukrs.
**      IF sy-subrc NE 0.
**        lv_reccn_msg = 'Please enter valid company code'.
**      ENDIF.
**    ENDIF.
**
**    IF  gw_contract-recntype IS INITIAL.
**      DATA(lv_recntype_msg) = 'Please enter Contract type'.
**    ELSE.
**      READ TABLE gt_contract_type TRANSPORTING NO FIELDS WITH KEY smvart = gw_contract-recntype.
**      IF sy-subrc NE 0.
**        lv_recntype_msg = 'Please enter valid Contract type'.
**      ENDIF.
**    ENDIF.
**
***    object type
**    IF gw_contract-objtype IS INITIAL.
**      DATA(lv_objtyp_msg) = 'Please enter Object type'.
**    ELSE.
**      TRANSLATE gw_contract-objtype TO UPPER CASE.
**      READ TABLE gt_object_type TRANSPORTING NO FIELDS WITH KEY cnsubjecttype = gw_contract-objtype.
**      IF sy-subrc NE 0.
**        lv_objtyp_msg = 'Please enter valid Object type'.
**      ENDIF.
**    ENDIF.
**
***    start date
*    IF gw_contract-start_date IS INITIAL.
*      DATA(lv_sdate_msg) = 'Please enter start date'.
*    ELSE.
*      gw_contract-start_date = gw_contract-start_date+4(4) && gw_contract-start_date+2(2) && gw_contract-start_date+0(2).
*
**      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
**        EXPORTING
**          date_external            = gw_contract-start_date
***         ACCEPT_INITIAL_DATE      =
**        IMPORTING
**          date_internal            = gw_contract-start_date
**        EXCEPTIONS
**          date_external_is_invalid = 1
**          OTHERS                   = 2.
**      IF sy-subrc <> 0.
**        lv_sdate_msg = 'Invalid start date'.
**      ENDIF.
*    ENDIF.
**
***    End date
*    IF gw_contract-end_date IS INITIAL.
*      DATA(lv_edate_msg) = 'Please enter end date'.
*    ELSE.
*      gw_contract-end_date = gw_contract-end_date+4(4) && gw_contract-end_date+2(2) && gw_contract-end_date+0(2).
**      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
**        EXPORTING
**          date_external            = gw_contract-end_date
***         ACCEPT_INITIAL_DATE      =
**        IMPORTING
**          date_internal            = gw_contract-end_date
**        EXCEPTIONS
**          date_external_is_invalid = 1
**          OTHERS                   = 2.
**      IF sy-subrc <> 0.
**        lv_edate_msg = 'Invalid end date'.
**      ENDIF.
*    ENDIF.
**
****    Business partner number
**    IF gw_contract-partner IS NOT INITIAL.
**      DATA(lv_partner_msg) = 'Please enter Business partner number'.
**    ELSE.
**      READ TABLE gt_but000 TRANSPORTING NO FIELDS WITH KEY partner = gw_contract-partner.
**      IF sy-subrc NE 0.
**        lv_partner_msg = 'Invalid Business partner' && gw_contract-partner.
**      ENDIF.
**    ENDIF.
**
****      Profit Centre
**    IF gw_contract-prctr IS NOT INITIAL.
**      DATA(lv_prctr_msg) = 'Please enter Profit Center'.
**    ELSE.
**     READ TABLE gt_wh_locat INTO data(lw_prctr) with key prctr = gw_contract-prctr.
**     if sy-subrc ne 0.
**     lv_prctr_msg = 'Profit center not exists'.
**     endif.
**    ENDIF.
***
*****     Location ID
**    IF gw_contract-zzrecn_ext IS INITIAL.
**      DATA(lv_loc_msg) = 'Please enter Location'.
**    ELSE.
**      READ TABLE gt_t499s TRANSPORTING NO FIELDS WITH KEY stand = gw_contract-zzframe_recn.
**      IF sy-subrc NE 0.
**        lv_loc_msg = 'Invalid Location ID'.
**      ENDIF.
**    ENDIF.
*
**    READ TABLE gt_wh_locat INTO data(lw_prctr) with key prctr = gw_contract-prctr
**                                                        wh_location = gw_contract-zzrecn_ext.
**    if sy-subrc ne 0.
**      data(lv_prof_valid) = 'Invalid profit centre with Location'.
**    endif.
**
****    Vendor ID
**    IF gw_contract-zzrecn_ext IS INITIAL.
**      DATA(lv_venid_msg) = 'Please enter Vendor ID'.
**    ELSE.
**      READ TABLE gt_t499s TRANSPORTING NO FIELDS WITH KEY ktext = gw_contract-zzrecn_ext.
**      IF sy-subrc NE 0.
**        lv_venid_msg = 'Invalid Vendor ID'.
**      ENDIF.
**    ENDIF.
**
****    Valuation Rule
**    IF gw_contract-cerule IS INITIAL.
**      DATA(lv_cerule_msg) = 'Please enter Vendor ID'.
**    ELSE.
**    ENDIF.
**
****    End of Usage RoU
**    IF gw_contract-usefullifeend IS INITIAL.
**    ELSE.
**    ENDIF.
**
****   Start of consideration
*    IF gw_contract-consbeg IS INITIAL.
*      DATA(lv_stofcon_msg) = 'Please enter Start of consideration Date'.
*    ELSE.
*      gw_contract-consbeg = gw_contract-consbeg+4(4) && gw_contract-consbeg+2(2) && gw_contract-consbeg+0(2).
**      gw_contract-consbeg = | { gw_contract-consbeg+4(4) } | &  |{ gw_contract-consbeg+0(2) } |
**
**                            & | { gw_contract-consbeg+0(2) } |.
*
**      CONCATENATE gw_contract-consbeg+4(4) gw_contract-consbeg+2(2)
**      gw_contract-consbeg+0(2) INTO gw_contract-consbeg.
**      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
**        EXPORTING
**          date_external            = gw_contract-consbeg
***         ACCEPT_INITIAL_DATE      =
**        IMPORTING
**          date_internal            = gw_contract-consbeg
**        EXCEPTIONS
**          date_external_is_invalid = 1
**          OTHERS                   = 2.
**      IF sy-subrc <> 0.
**        lv_stofcon_msg = 'Invalid Start of consideration Date'.
**      ENDIF.
*    ENDIF.
****      Interest rate
*
*    MODIFY gt_contract FROM gw_contract INDEX lv_index TRANSPORTING start_date end_date consbeg.
*  ENDLOOP.
*
************************    Conditions  *************************
*  LOOP AT gt_conditions INTO gw_conditions.
*    DATA(lv_index1) = sy-tabix.
**    IF gw_conditions-recnnr IS INITIAL.
**      DATA(lv_sernum_msg) = 'Please enter serial Number'.
**    ELSE.
***       Valdiate with numeric numbers
**    ENDIF.
**
****   Condition type
**    IF gw_conditions-condtype IS INITIAL.
**      DATA(lv_condtyp_msg) = 'Please enter Condition type in Conditions tab'.
**    ELSE.
**      READ TABLE gt_condtype TRANSPORTING NO FIELDS WITH KEY condtype = gw_conditions-condtype.
**      IF sy-subrc NE 0.
**        lv_condtyp_msg = 'Invalid Condition type in Conditions tab'.
**      ENDIF.
**    ENDIF.
**
**
*****  Valid from
*    IF gw_conditions-cond_valid_from IS  INITIAL.
*      DATA(lv_validfr_msg) = 'Please enter Valid from date in Conditions tab'.
*    ELSE.
*      gw_conditions-cond_valid_from = gw_conditions-cond_valid_from+4(4) &&
*      gw_conditions-cond_valid_from+2(2) && gw_conditions-cond_valid_from+0(2).
**          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
**        EXPORTING
**          date_external            = gw_conditions-cond_valid_from
***         ACCEPT_INITIAL_DATE      =
**        IMPORTING
**          date_internal            = gw_conditions-cond_valid_from
**        EXCEPTIONS
**          date_external_is_invalid = 1
**          OTHERS                   = 2.
**      IF sy-subrc <> 0.
**        lv_validfr_msg = 'Invalid Valid from date in Conditions tab'.
**      ENDIF.
*    ENDIF.
**
****    Valid to
**      if gw_conditions-cond_valid_to is  INITIAL.
**         DATA(lv_validto_msg) = 'Please enter Valid to date in Conditions tab'.
**      else.
**          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
**        EXPORTING
**          date_external            = gw_conditions-cond_valid_to
***         ACCEPT_INITIAL_DATE      =
**        IMPORTING
**          date_internal            = gw_conditions-cond_valid_to
**        EXCEPTIONS
**          date_external_is_invalid = 1
**          OTHERS                   = 2.
**      IF sy-subrc <> 0.
**        lv_validto_msg = 'Invalid Valid to date in Conditions tab'.
**      ENDIF.
**      endif.
**
****    Frequency
**       if gw_conditions-frequency is  INITIAL.
**          DATA(lv_frequency_msg) = 'Please enter Frequency in Conditions tab'.
**       else.
****      Implement logic not exceeding lenght to 4 chars
**       endif.
**
****       Payment Form
**       if gw_conditions-paymentform is  INITIAL.
**          DATA(lv_paymentform_msg) = 'Please enter paymentform in Conditions tab'.
**       else.
**
**       endif.
**
****     Unit Price
**       if gw_conditions-unitprice is  INITIAL.
**          DATA(lv_unitprice_msg) = 'Please enter Unit Price in Conditions tab'.
**       else.
**
**       endif.
**
****     Escalation Frequncy
**       if gw_conditions-calcrule is  INITIAL.
**          DATA(lv_calcrule_msg) = 'Please enter Escalation Frequncy in Conditions tab'.
**       else.
**
**       endif.
*    MODIFY gt_conditions FROM gw_conditions INDEX lv_index1 TRANSPORTING cond_valid_from.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_grading_conditions
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GW_CONDITIONS
*&---------------------------------------------------------------------*
FORM add_grading_conditions  USING p_ls_condition TYPE bapi_re_condition_dat.

  FIELD-SYMBOLS: <lfs_condition>    TYPE bapi_re_condition_dat.

  DATA: lv_tabix         TYPE sy-tabix,
        lv_condvalidfrom TYPE sy-datum,
        lv_condvalidto   TYPE sy-datum,
        lv_time          TYPE mara-mhdhb.

  CONSTANTS: lc_month TYPE mara-iprkz VALUE '2'.

  lv_index1 = lv_index1 + 1.

  DESCRIBE TABLE gt_condition LINES lv_tabix.
  READ TABLE gt_condition ASSIGNING <lfs_condition> INDEX lv_tabix.
  IF sy-subrc = 0.
    CLEAR <lfs_condition>-valid_to.
    IF <lfs_condition>-valid_to IS INITIAL.
      lv_condvalidfrom = <lfs_condition>-valid_from.
*      lv_time = gw_conditions-gradmonth.
      lv_time = gw_conditions-calcrule.
      CALL FUNCTION 'ADD_TIME_TO_DATE'
        EXPORTING
          i_idate               = lv_condvalidfrom
          i_time                = lv_time
          i_iprkz               = lc_month
        IMPORTING
          o_idate               = lv_condvalidto
        EXCEPTIONS
          invalid_period        = 1
          invalid_round_up_rule = 2
          internal_error        = 3
          OTHERS                = 4.
      IF sy-subrc IS INITIAL.   "++ASINGH0318102017
        <lfs_condition>-valid_to = lv_condvalidto - 1.
      ENDIF.

    ENDIF.
  ENDIF.

  p_ls_condition-valid_from = lv_condvalidto.  "Valid from Changed
  IF lv_index1 EQ lv_index.
    CLEAR  : p_ls_condition-valid_to.
  ENDIF.
  "" Unit Price changed
*  IF gw_conditions-gradpercent IS NOT INITIAL.
  IF gw_conditions-distrule IS NOT INITIAL.
    p_ls_condition-unit_price = p_ls_condition-unit_price + ( ( p_ls_condition-unit_price * gw_conditions-distrule ) / 100 ).
*  ELSE.
*    p_ls_condition-unit_price = p_ls_condition-unit_price + gw_conditions-gradabsolute.
  ENDIF.

  APPEND p_ls_condition TO gt_condition.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_value_scr_field
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_value_scr_field .
*IF sscrfields-ucomm = gc_fc01.

*endif
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_f4 .
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = 'Select a file'
    CHANGING
      file_table   = lt_file_table
      rc           = lv_rc.
  IF sy-subrc = 0.
    READ TABLE lt_file_table INTO ls_file_table INDEX 1.
    p_file = ls_file_table-filename.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_grading
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_grading .
  DATA : lv_fromdt TYPE sy-datum.
  DATA : lv_todt TYPE sy-datum.

  CONCATENATE gw_conditions-cond_valid_from+6(2) gw_conditions-cond_valid_from+4(2) gw_conditions-cond_valid_from+0(4)
                            INTO DATA(im_fromdt) SEPARATED BY '.'.
  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      date_external            = im_fromdt  "gw_conditions-cond_valid_from
    IMPORTING
      date_internal            = lv_fromdt
    EXCEPTIONS
      date_external_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
*        CONCATENATE gw_contract-end_date+6(2) gw_contract-end_date+4(2) gw_contract-end_date+0(4)
  CONCATENATE gw_contract-end_date+6(2) gw_contract-end_date+4(2) gw_contract-end_date+0(4)
                     INTO DATA(im_enddt) SEPARATED BY '.'.
  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      date_external            = im_enddt   "gw_contract-end_date
    IMPORTING
      date_internal            = lv_todt
    EXCEPTIONS
      date_external_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  CALL METHOD cl_reca_date=>get_date_diff
    EXPORTING
      id_date_from     = lv_fromdt                      "gw_conditions-cond_valid_from   "
      id_date_to       = lv_todt                       "gw_contract_bapi-first_end_date
    IMPORTING
      ed_years         = ld_years
      ed_months        = ld_months
      ed_calendar_days = ld_calendar_days.
  "" Add Conditions based on Grading
  DATA(lv_gradeperiod) =  ( ld_years * 12 ) + ld_months.
  CLEAR : lv_loop, lv_index, lv_index1.
*        lv_loop = gw_conditions-gradperiod DIV gw_conditions-gradmonth.
  IF gw_conditions-calcrule GT 0.
    lv_loop = lv_gradeperiod DIV gw_conditions-calcrule.
    lv_loop = lv_loop - 1.
    lv_index = lv_loop.
    DO lv_loop TIMES.
      PERFORM add_grading_conditions USING gw_condition.
    ENDDO.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form validate_date_format
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form validate_date_format
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GW_CONTRACT_START_DATE
*&---------------------------------------------------------------------*
FORM validate_date_format  CHANGING p_date.
  p_date = p_date+4(4) && p_date+2(2) && p_date+0(2).
ENDFORM.
*****
*****Class :
*****Method :GET_CONDITIONS
*****IM_CONDTYPE TYPE RECDCONDTYPE OPTIONAL  Name of Condition Type
*****IM_VALID_FROM TYPE CHAR10 OPTIONAL  Character Field with Length 10
*****IM_VALID_TO TYPE CHAR10 OPTIONAL  Character Field with Length 10
*****IM_UNITPRICE  TYPE RECDUNITPRICE OPTIONAL Unit Price
*****EX_CONDTYPE TYPE BAPI_RE_CONDITION_DAT  Condition Type
*****
*****
*****  METHOD get_conditions.
****** Condition type    Valid from          Valid to
****** CONDTYPE          CONDVALIDFROM       CONDVALIDTO
*****
*****    ex_condtype-condition_type = im_condtype.
*****    ex_condtype-unit_price = im_unitprice.
*****    ex_condtype-calculation_object_id           = c_cal_obj_id.           "'0010'.
*****    ex_condtype-calculation_object_type         = c_cal_obj_typ.          "'J4'.
*****    ex_condtype-valid_from                      = im_valid_from. "20220401
*****    ex_condtype-valid_to                        = im_valid_to. "20230331
*****    ex_condtype-calc_rule                       = 'A'.
******    IF gw_conditions-frequency ='onetime'.
******      EX_CONDTYPE-external_purpose             = 'B'.
******    ELSE.
*****    ex_condtype-external_purpose                = 'A'.
******    ENDIF.
*****
*****
*****  ENDMETHOD.
*****
*****Method : GET_COSTCENTRE
*****  method GET_COSTCENTRE.
****** * Z dynamics table for cost centre
*****DATA: lt_hcf  TYPE ztt_dynamic_func,
*****      lwa_hcf TYPE zxdynamic_func.
*****   CONSTANTS : lc_id     TYPE zxdynamic_func-id        VALUE 'ZNI_MRN',
*****              lc_crt1   TYPE zxdynamic_func-criteria1 VALUE 'CHECK',
*****              lc_value1 TYPE zxdynamic_func-value1    VALUE 'MRN'.
*****
*****  lwa_hcf-id        = lc_id.
*****  lwa_hcf-criteria1 = lc_crt1.
*****  lwa_hcf-value1    = lc_value1.
*****  lwa_hcf-criteria2    = 'BUKRS'.
*****  lwa_hcf-criteria3    = 'ANLKL'.
*****  lwa_hcf-criteria3    = 'KOSTL'.
*****  lwa_hcf-criteria3    = 'PRCTR'.
*****
*****  CALL METHOD zcl_dynamic_param=>get_multiple_func
*****    EXPORTING
*****      im_zxdynamic_func = lwa_hcf
*****    RECEIVING
*****      re_zxdynamic_func = lt_hcf.
*****
******   SELECT * FROM tivceassetdif INTO TABLE @DATA(gt_costcentre)
******                 FOR ALL ENTRIES IN @gt_contract
******                        WHERE bukrs EQ @gt_contract-bukrs
******                         AND  recntype EQ @gt_contract-recntype.
*****  endmethod.
*****
*****Method: GET_EXTENSIONIN
*****
*****IM_ZZSTORT  TYPE STORT_T499S  Location
*****IM_ZZKTEXT  TYPE ZZTEXT40 Vendor ID
*****IM_ZZUSRTEXT  TYPE ZZUSRTXT OPTIONAL  User Text for Location ID
*****IM_ZZINTEREST_CHK  TYPE CHAR1 OPTIONAL Single-Character Flag
*****ET_EXTENSIONIN  TYPE TY_EXTENSION Ref. structure for BAPI parameter ExtensionIn/ExtensionOut
*****
*****  METHOD get_extensionin.
*****    DATA:
*****      lt_extension_in TYPE TABLE OF bapiparex,
*****      ls_extension_in TYPE bapiparex,
*****      ls_ci_data      TYPE recn_contract_ci.
*****
*****   clear : ls_ci_data, ls_extension_in, lt_extension_in[].
****** fill values for user fields
*****    ls_ci_data-zzstort        =  im_zzstort.
*****    ls_ci_data-zzktext        = im_zzktext.
*****
*****    CALL METHOD cl_abap_container_utilities=>fill_container_c
*****      EXPORTING
*****        im_value     = ls_ci_data
*****      IMPORTING
*****        ex_container = ls_extension_in-valuepart1
*****      EXCEPTIONS
*****        OTHERS       = 0.
*****
*****    IF im_zzusrtext IS NOT INITIAL.
*****      ls_extension_in-valuepart2+29(40) = im_zzusrtext.
*****    ENDIF.
*****
****** prepare BAPI-parameter
*****    ls_extension_in-structure = 'CI_DATA'  .  "'RECN_CONTRACT_CI'.
****** doesn't work with unicode:
******    ls_extension_in-valuepart1 = ls_ci_data.
****** use instead:
*****
*****
*****    APPEND ls_extension_in TO et_extensionin.
*****
*****  ENDMETHOD.
*****Method : GET_FREQUENCY
*****IM_TERNMNORH  TYPE STRING
*****IM_PAYMENTFORM  TYPE STRING
*****EX_FREQUENCY  TYPE BAPI_RE_TERM_RH_DAT  Frequency Term of an RE Object - Data
*****  METHOD get_frequency.
******    Frequency  Payment Form  Unit Price    Escalation Frequncy     Escalation Percentage
******    TERMNORH     TERMNORH     UNITPRICE     CALCRULE                DISTRULE
*****
*****
*****    IF   im_ternmnorh    ='Monthly' .
*****      ex_frequency-frequency        = '0001'.
*****      ex_frequency-frequency_unit        = 0.
*****    ELSEIF  im_ternmnorh = 'Quaterly'.
*****      ex_frequency-frequency        = '0003'.
*****      ex_frequency-frequency_unit        = 0.
*****    ELSEIF im_ternmnorh  = 'Semi Annually'.
*****      ex_frequency-frequency        = '0006'.
*****      ex_frequency-frequency_unit        = 0.
*****    ELSEIF im_ternmnorh  = 'Annually' .
*****      ex_frequency-frequency        = '0001'.
*****      ex_frequency-frequency_unit        = 1.
*****    ELSEIF im_ternmnorh  = 'onetime' .
*****      ex_frequency-frequency        = '0001'.
*****      ex_frequency-frequency_unit        = 0.
*****    ENDIF.
*****    ex_frequency-due_date_move_begin = abap_true.
*****    ex_frequency-due_date_move_end   = abap_true.
*****    ex_frequency-starting_month              = 14.
*****    ex_frequency-condition_amount_ref        = 3.
*****
******    ex_frequency-term_no    = c_termno_0001.
******    ex_frequency-term_text   gw_conditions-xterm.
*****    IF im_paymentform    = 'Start'.
*****      ex_frequency-payment_form    = '0000'.
*****    ELSEIF im_paymentform = 'Inmiddle'.
*****      ex_frequency-payment_form    = '0001'.
*****    ELSEIF im_paymentform = 'End'.
*****      ex_frequency-payment_form    = '0002'.
*****    ENDIF.
*****
*****  ENDMETHOD.
*****Method : GET_OBJECTS_REL
*****IM_OBJTYPE  TYPE CHAR6  Character field of length 6
*****IM_CONTRACT_SUBTXT  TYPE STORT_T499S  Name for Contract Item
*****IM_START_DATE  TYPE CHAR10 Character Field with Length 10
*****IM_END_DATE  TYPE CHAR10 Character Field with Length 10
*****EX_OBJECTS_REL  TYPE BAPI_RE_OBJECT_REL_DAT Objects of Real Estate Contract - Data
*****  METHOD get_objects_rel.
*****    ex_objects_rel-contract_object_type      = 'J4'.
*****    ex_objects_rel-contract_object_id        = im_objtype.              "'CSIND'.
*****    ex_objects_rel-object_group_number       = '0010'.
*****    ex_objects_rel-informational_assignment  = 'X'.
*****    ex_objects_rel-object_type_acct          = c_bus_obj_typ.            "'KS'.
*****    ex_objects_rel-contract_subject_text     = im_contract_subtxt.       "'IDGJ100020
*****    ex_objects_rel-contract_subject_type     = im_objtype.               "'CSIND'.
*****    ex_objects_rel-valid_from                = im_start_date.
*****    ex_objects_rel-valid_to                  = im_end_date.
*****  ENDMETHOD.
*****Method : GET_POSTING  t
*****IM_CONTRACT_TYPE  TYPE RECNCONTRACTTYPE Contract Type
*****IM_PARTNER  TYPE BU_PARTNER Business Partner Number
*****EX_TERM_PAYMENT TYPE BAPI_RE_TERM_PY_DAT  Posting Term of an RE Object - Data
*****METHOD get_posting.
******    gw_term_payment-term_no                      = zcl_refx=>c_termno_0001.
******    IF im_contract_type EQ 'ZI01' .
******      ex_term_payment-acc_det_key                 = 'VAL_INDUS'.
******    ELSEIF im_contract_type EQ 'ZI02' .
******      ex_term_payment-acc_det_key                 = 'CSNIND'.
******    ELSEIF im_contract_type EQ 'ZI03' .
******      ex_term_payment-acc_det_key                 = 'CSLL'.
******    ELSEIF im_contract_type EQ 'ZI04' .
******      ex_term_payment-acc_det_key                 = 'LHLN'.
******    ELSEIF im_contract_type EQ 'ZI05' .
******      ex_term_payment-acc_det_key                 = 'LCH'.
******    ELSEIF im_contract_type EQ 'ZI06' .
******      ex_term_payment-acc_det_key                 = 'IRU'.
******    ELSEIF im_contract_type EQ 'ZI07' .
******      ex_term_payment-acc_det_key                 = 'Imm'.
******    ENDIF.
*****    ex_term_payment-partner                     = im_partner.
*****  ENDMETHOD.
*****Method : GET_TERM_EVALUATION
*****IM_CONSBEG  TYPE RECECONSBEG  Start of Consideration
*****IM_USEFULLIFEEND  TYPE RECEUSEFULLIFEEND  End of Usage RoU
*****IM_KOSTL  TYPE REBDBUSOBJIDACCT ID Part of Account Assignment Object
*****IM_INTEREST_RATE  TYPE ZDE_INTRATE  Interest Rate
*****IM_CERRULE  TYPE CHAR30 30 Characters
*****ET_TERM_EVAL  TYPE TY_TERM_EVALUATION Valuation Rule for an RE Object - Internal
*****  METHOD get_term_evaluation.
*****    DATA : wa_term_eval TYPE bapi_re_term_ce_dat.
*****    IF im_cerrule EQ 'IFRSA16' OR im_cerrule EQ 'IFRSA16&IND AS116'.
*****      wa_term_eval-term_no                       = c_termno_0001.        "'0001'.
*****      wa_term_eval-rule_object_type              = c_cal_obj_typ.        "'J4'.
*****      wa_term_eval-valuation_rule                = c_val_rule_ifrs.      "'IFRS_16'.
*****      wa_term_eval-rule_object_id                = c_val_rule_id.        "'0010'.
*****      wa_term_eval-start_date_of_consideration   = im_consbeg.
*****      wa_term_eval-end_date_of_usage             = im_usefullifeend.
*****      wa_term_eval-acct_object_type              = c_bus_obj_typ.        "'KS'.
*****      wa_term_eval-status_valuation_rule         = c_stat_rule.          "'C'.
*****      wa_term_eval-status_valuation              = c_stat_val.           "'C'.
*****      wa_term_eval-acct_object_id                = im_kostl.
*****      wa_term_eval-interest_rate                 = im_interest_rate.
*****      APPEND wa_term_eval TO et_term_eval.
*****      CLEAR wa_term_eval.
*****       data(lv_flag) = abap_True.
*****    ENDIF.
*****    IF im_cerrule EQ 'IND AS116' OR im_cerrule EQ 'IFRSA16&IND AS116'.
*****      if  lv_flag is INITIAL.
*****      wa_term_eval-term_no                       = zcl_refx=>c_termno_0001.
*****      ELSEIF lv_flag eq abap_True.
*****      wa_term_eval-term_no                       = zcl_refx=>c_termno_0002.
*****      endif.
*****      wa_term_eval-rule_object_type              = c_cal_obj_typ.        "'J4'.
*****      wa_term_eval-valuation_rule                = 'IND AS116'.
*****      wa_term_eval-rule_object_id                = c_val_rule_id.        "'0010'.
*****      wa_term_eval-start_date_of_consideration   = im_consbeg.
*****      wa_term_eval-end_date_of_usage             = im_usefullifeend.
*****      wa_term_eval-acct_object_type              = c_bus_obj_typ.        "'KS'.
*****      wa_term_eval-status_valuation_rule         = c_stat_rule.          "'C'.
*****      wa_term_eval-status_valuation              = c_stat_val.           "'C'.
*****      wa_term_eval-acct_object_id                = im_kostl.
*****      wa_term_eval-interest_rate                 = im_interest_rate.
*****      APPEND wa_term_eval TO et_term_eval.
*****      CLEAR wa_term_eval.
*****    ENDIF.
*****    clear lv_Flag.
*****  ENDMETHOD.
*****Method : GET_TERM_EVALUATION_CONDITION
*****IM_CONDTYPE TYPE RECDCONDTYPE OPTIONAL  Condition Type
*****IM_CERRULE  TYPE CHAR30 OPTIONAL  Valuation Rule
*****IM_COND_VALI_FROM TYPE CHAR10 OPTIONAL  Single-Character Flag
*****IM_COND_VALI_TO TYPE CHAR10 OPTIONAL  Character Field with Length 10
*****ET_EVALUATION_CONDITION TYPE TY_TERM_CONDTIONS  Condition-Spec. Valuation Rule for an RE Object - Internal
*****  METHOD get_term_evaluation_condition.
*****    DATA ex_evaluation_condition TYPE bapi_re_term_cecond_dat.
*****    IF im_cerrule EQ 'IFRSA16' OR im_cerrule EQ 'IFRSA16&IND AS116'.
*****      ex_evaluation_condition-condition_type                 = im_condtype.   "zcl_refx=>c_cond_type.
*****      ex_evaluation_condition-term_no                        = c_termno_0001.
*****      ex_evaluation_condition-term_text                      = 'Indian Accounting Standards (IFRSA16)'.
*****      ex_evaluation_condition-condition_valid_from           = im_cond_vali_from.
*****      ex_evaluation_condition-condition_valid_to             = im_cond_vali_to.
*****      ex_evaluation_condition-condition_external_purpose     = 'A'.
*****      ex_evaluation_condition-condition_object_type          = 'J4'.
*****      ex_evaluation_condition-condition_object_id            = '0010'.
*****      ex_evaluation_condition-condition_valuation_property   = 'A'.
*****      ex_evaluation_condition-indicator_consider_condition   = 'X'.
*****      ex_evaluation_condition-condition_consideration        = 'O'.
*****      ex_evaluation_condition-percentage_share_of_condition  = '80.0000'.
*****      ex_evaluation_condition-valid_from                     = '00000000'.
*****      ex_evaluation_condition-valid_to                       = '00000000'.
*****      ex_evaluation_condition-status_valuation_rule          = 'C'.
*****      APPEND ex_evaluation_condition TO et_evaluation_condition.
*****      CLEAR ex_evaluation_condition.
*****      data(lv_flag) = abap_True.
*****
******      ex_evaluation_condition-condition_type                 = im_condtype.   "zcl_refx=>c_cond_type.
******      ex_evaluation_condition-term_no                        = c_termno_0001.
******      ex_evaluation_condition-term_text                      = 'Indian Accounting Standards (IFRS_16)'.
******      ex_evaluation_condition-condition_valid_from           = im_cond_vali_from.
******      ex_evaluation_condition-condition_external_purpose     = 'A'.
******      ex_evaluation_condition-condition_object_type          = 'J4'.
******      ex_evaluation_condition-condition_object_id            = '0010'.
******      ex_evaluation_condition-condition_valuation_property   = 'A'.
******      ex_evaluation_condition-indicator_consider_condition   = 'X'.
******      ex_evaluation_condition-condition_consideration        = 'O'.
******      ex_evaluation_condition-percentage_share_of_condition  = '80.0000'.
******      ex_evaluation_condition-valid_from                     = '00000000'.
******      ex_evaluation_condition-valid_to                       = '00000000'.
******      ex_evaluation_condition-status_valuation_rule          = 'C'.
******      APPEND ex_evaluation_condition TO et_evaluation_condition.
******      CLEAR ex_evaluation_condition.
*****    ENDIF.
*****    IF im_cerrule EQ 'IND AS116' OR im_cerrule EQ 'IFRSA16&IND AS116'.
*****      ex_evaluation_condition-condition_type                 = im_condtype.  "zcl_refx=>c_cond_type.                       "'Z100'.
*****      if lv_flag is INITIAL.
*****      ex_evaluation_condition-term_no                        = c_termno_0001.
*****      ELSEIF lv_flag eq abap_true.
*****      ex_evaluation_condition-term_no                        = c_termno_0002.
*****      endif.
*****      ex_evaluation_condition-term_text                      = 'Indian Accounting Standards (IND AS116)'.
*****      ex_evaluation_condition-condition_valid_from           = im_cond_vali_from.
*****      ex_evaluation_condition-condition_external_purpose     = 'A'.
*****      ex_evaluation_condition-condition_object_type          = 'J4'.
*****      ex_evaluation_condition-condition_object_id            = '0010'.
*****      ex_evaluation_condition-condition_valuation_property   = 'A'.
*****      ex_evaluation_condition-indicator_consider_condition   = 'X'.
*****      ex_evaluation_condition-condition_consideration        = 'F'.
*****      ex_evaluation_condition-percentage_share_of_condition  = '100.0000'.
*****      ex_evaluation_condition-valid_from                     = '00000000'.
*****      ex_evaluation_condition-valid_to                       = '00000000'.
*****      ex_evaluation_condition-status_valuation_rule          = 'C'.
*****      APPEND ex_evaluation_condition TO et_evaluation_condition.
*****      CLEAR  ex_evaluation_condition.
*****    ENDIF.
*****    clear : lv_flag.
*****  ENDMETHOD.
******** INCLUDE ZCLM_CONTRACT_UPLD_SUB
******** INCLUDE ZCLM_CONTRACT_UPLD_SUB

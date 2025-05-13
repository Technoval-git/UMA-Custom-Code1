*class YCL_FI_COMMON_UTIL definition
*  public
*  final
*  create public .
*
*public section.
*protected section.
*private section.
*ENDCLASS.
*
*
*
*CLASS YCL_FI_COMMON_UTIL IMPLEMENTATION.
*ENDCLASS.
CLASS ycl_fi_common_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_soa_data,
        kunnr         TYPE kna1-kunnr,
        name          TYPE kna1-name1,
        zterm         TYPE knb1-zterm,
        belnr         TYPE bsid-belnr,
        duedate       TYPE sy-datum,
        docdate       TYPE sy-datum,
        reference     TYPE string,
        po            TYPE bstnk, "CR 8100002617
        division      TYPE string,
        branch        TYPE string,
        debit         TYPE dmbtr,
        credit        TYPE dmbtr,
        acc_balance   TYPE dmbtr,
        postdate      TYPE sy-datum,
        open_bal      TYPE string,
        baseline_date TYPE sy-datum,
        name_ar       TYPE adrc-name1,
      END OF ty_soa_data,
      tt_soa_data TYPE TABLE OF ty_soa_data.
    TYPES:
      BEGIN OF ty_plant_veh,
        po_box     TYPE adrc-po_box,
        city1      TYPE adrc-city1,
        post_code1 TYPE adrc-post_code1,
        fax_number TYPE adrc-fax_number,
        smtp_addr  TYPE adr6-smtp_addr,
        tel_number TYPE adr2-tel_number,
      END OF ty_plant_veh .
    TYPES:
      BEGIN OF ty_plant_address,
        po_box TYPE adrc-po_box,
        orto   TYPE adrc-city1,
        adrnr  TYPE adrc-post_code1,
        name   TYPE t005t-landx,
        name2  TYPE adrc-name2,
        butxt  TYPE butxt,
        fax    TYPE adrc-fax_number,
        mail   TYPE adr6-smtp_addr,
        phone  TYPE adr2-tel_number,
      END OF ty_plant_address .
    TYPES:
      BEGIN OF ty_customer,
        name       TYPE string,
        tel_no     TYPE string,
        email      TYPE string,
        address    TYPE string,
        fax_number TYPE string,
      END OF ty_customer .
    TYPES:
      "Table type to store customer details from the table kna1
      BEGIN OF ty_kna1,
        name1 TYPE name1_gp,
        name2 TYPE name2_gp,
        adrnr TYPE adrnr,
        telf1 TYPE telf1,
        telfx TYPE telfx,
      END OF ty_kna1 .
    TYPES:
      "Table type to store address details from the table adrc
      BEGIN OF ty_adrc,
        street     TYPE ad_street,
        house_num1 TYPE ad_hsnm1,
        post_code1 TYPE ad_pstcd1,
        city1      TYPE ad_city1,
        country    TYPE  land1,
        region     TYPE regio,
        fax_number TYPE adrc-fax_number,
      END OF ty_adrc .
    CLASS-METHODS get_plant_address
      IMPORTING
        !iv_bukrs        TYPE bukrs OPTIONAL
        !iv_lang         TYPE sy-langu OPTIONAL
        !iv_werks        TYPE werks_d OPTIONAL
      EXPORTING
        !es_comp_details TYPE ty_plant_address .
    CLASS-METHODS get_customer_details
      IMPORTING
        !iv_kunnr    TYPE kunnr
      EXPORTING
        !es_customer TYPE ty_customer .
    CLASS-METHODS get_plant_for_veh
      IMPORTING
        !iv_lang         TYPE sy-langu
        !iv_werks        TYPE werks_d OPTIONAL
      EXPORTING
        !es_comp_details TYPE ty_plant_veh .
protected section.
private section.

  data GC_VALUE_E type SPRAS .
ENDCLASS.



CLASS YCL_FI_COMMON_UTIL IMPLEMENTATION.


  METHOD get_customer_details.

    DATA: ts_kna1       TYPE ty_kna1,
          ts_adrc       TYPE ty_adrc,
          lv_country    TYPE landx,
          lv_region     TYPE bezei20,
          lv_tel_number TYPE ad_tlnmbr,
          lv_smtp_addr  TYPE ad_smtpadr.
    "Gettinig the data from kna1 table
    SELECT SINGLE  name1 name2 adrnr telf1 telfx
           FROM kna1
            INTO ts_kna1 WHERE kunnr = iv_kunnr.
    IF sy-subrc = 0.
      es_customer-fax_number =  ts_kna1-telfx.
      CONDENSE es_customer-fax_number.
      es_customer-tel_no =  ts_kna1-telf1.
      CONDENSE es_customer-tel_no.
      "Inserting the customer name into the header structure
      CONCATENATE ts_kna1-name1 ts_kna1-name2
                  INTO es_customer-name
                  SEPARATED BY space.
      CONDENSE es_customer-name.
    ENDIF.
    "Gettinig the data from ADRC table
    SELECT SINGLE
      street
      house_num1
      post_code1
      city1
      country
      region
      fax_number
      FROM adrc
      INTO ts_adrc
      WHERE addrnumber = ts_kna1-adrnr.
    IF ts_adrc-street IS NOT INITIAL OR ts_adrc-house_num1
            IS NOT INITIAL OR ts_adrc-city1 IS NOT INITIAL.
      "Inserting the customer address into the header structure
      CONCATENATE ts_adrc-street ts_adrc-house_num1 ts_adrc-city1
                  INTO es_customer-address SEPARATED BY space.
      CONDENSE es_customer-address.
    ENDIF.

    "Getting country
    SELECT SINGLE landx
      AS lv_country
      FROM t005t
      INTO lv_country
    WHERE spras = 'E' "yif_dbm_jet_constants=>gc_value_e
      AND land1 = ts_adrc-country.
    "Getting region
    SELECT SINGLE bezei AS lv_region
      FROM t005u
      INTO lv_region
    WHERE spras = 'E' "yif_dbm_jet_constants=>gc_value_e
      AND land1 = ts_adrc-country
      AND bland = ts_adrc-region.
    IF  lv_region IS NOT INITIAL OR lv_country IS NOT INITIAL
      OR ts_adrc-post_code1 IS NOT INITIAL.
      "inserting it to the string table
      CONCATENATE es_customer-address
      lv_region lv_country ts_adrc-post_code1
      INTO es_customer-address SEPARATED BY space.
      CONDENSE es_customer-address.
    ENDIF.
    "Selecting the customer telephone number
*        SELECT SINGLE tel_number AS lv_tel_number FROM adr2
*          INTO lv_tel_number
*          WHERE addrnumber = ts_kna1-adrnr.
    "Selecting the customer Email address
    SELECT SINGLE smtp_addr AS lv_smtp_addr FROM adr6
      INTO lv_smtp_addr
      WHERE addrnumber = ts_kna1-adrnr.
    IF lv_tel_number IS NOT INITIAL AND lv_smtp_addr IS NOT INITIAL.
*                es_customer-tel_no = lv_tel_number.
      es_customer-email = lv_smtp_addr.
    ELSEIF lv_tel_number IS NOT INITIAL.
*         es_customer-tel_no = lv_tel_number.
    ELSEIF lv_smtp_addr IS NOT INITIAL.
      es_customer-email = lv_smtp_addr.
    ENDIF.
  ENDMETHOD.


  METHOD get_plant_address.

*    SELECT SINGLE butxt ort01 adrnr landx po_box INTO ES_COMP_DETAILS "#EC CI_BUFFJOIN
*    FROM t001
*    INNER JOIN t005t
*    ON t001~land1 = t005t~land1
*    inner join adrc
*    on adrc~addrnumber = t001~adrnr
*    WHERE t001~bukrs = iv_bukrs
*    AND t005t~spras = yif_dbm_jet_constants=>gc_value_e.
    DATA : lv_werks TYPE werks_d.
    IF iv_werks IS INITIAL.
      lv_werks = iv_bukrs.
    ELSE.
      lv_werks = iv_werks.
    ENDIF.

    SELECT SINGLE
      po_box
      city1
      post_code1
      landx
     INTO es_comp_details
     FROM t001w
     INNER JOIN adrc
     ON adrc~addrnumber = t001w~adrnr
      INNER JOIN t005t
     ON t001w~land1 = t005t~land1
     WHERE t001w~werks = lv_werks
     AND t005t~spras = iv_lang.

    SELECT SINGLE butxt adrc~name2
    INTO CORRESPONDING FIELDS OF es_comp_details
    FROM t001
    INNER JOIN adrc
    ON adrc~addrnumber = t001~adrnr
    WHERE t001~bukrs = iv_bukrs
    AND spras = iv_lang.
  ENDMETHOD.


  method GET_PLANT_FOR_VEH.

    SELECT SINGLE
      po_box
      city1
      post_code1
      fax_number
      adr2~tel_number
      adr6~smtp_addr
     INTO CORRESPONDING FIELDS OF es_comp_details
     FROM t001w
     INNER JOIN adrc
     ON adrc~addrnumber = t001w~adrnr
     INNER JOIN adr2
      ON t001w~adrnr = adr2~addrnumber
     INNER JOIN adr6
      ON t001w~adrnr = adr6~addrnumber
     WHERE t001w~werks = iv_werks
     AND t001w~spras = iv_lang.
  endmethod.
ENDCLASS.

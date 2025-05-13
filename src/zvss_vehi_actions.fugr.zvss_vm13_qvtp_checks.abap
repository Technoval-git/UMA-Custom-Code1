FUNCTION zvss_vm13_qvtp_checks .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_VLCACTDATA) TYPE  VLCACTDATA
*"     REFERENCE(IS_VLCDIAVEHI) TYPE  VLCDIAVEHI
*"  EXCEPTIONS
*"      ORDER_CHECK
*"      ORDER_OPEN
*"      COMPANY_DATA_ERROR
*"      WERKS_BUKRS_ERROR
*"      ORDER_NOT_FOUND
*"--------------------------------------------------------------------

  CONSTANTS:
    lc_vbtyp_c   TYPE vbtyp VALUE 'C',        "#EC CI_USAGE_OK[2198647]
    lc_engine_sd TYPE /dbe/c_order_engine VALUE 'SD',
    lc_engine_cs TYPE /dbe/c_order_engine VALUE 'CS',       "N:2801315
    lc_engine_fo TYPE /dbe/c_order_engine VALUE 'FO'.

  DATA:
    lt_guids     TYPE TABLE OF vlcguid,
    ls_guids     LIKE LINE OF lt_guids,
    lt_orders    TYPE TABLE OF /dbe/vlcorder,
    lt_comp_data TYPE TABLE OF /dbe/c_company,
    ls_comp_data LIKE LINE OF lt_comp_data,
    lv_vbeln     LIKE /dbe/vbak_db-vbeln,
    ls_ordertp   LIKE /dbe/c_ordertp,
    ls_vbak_com  LIKE /dbe/vbak_com,
    lt_splhdr    TYPE STANDARD TABLE OF /dbe/splhdr_db.

  FIELD-SYMBOLS:
    <ls_order>  TYPE /dbe/vlcorder,
    <ls_splhdr> TYPE /dbe/splhdr_db.

****** Check for opend DBM Orders
  ls_guids-vguid = is_vlcdiavehi-vguid.
  APPEND ls_guids TO lt_guids.

  CALL FUNCTION '/DBE/VM13_READ_VLCORDER'
    TABLES
      it_vlcguid       = lt_guids
      et_vlcorder      = lt_orders
    EXCEPTIONS
      no_data_received = 1
      nothing_found    = 2
      OTHERS           = 3.
  IF sy-subrc <> 0 AND sy-subrc <> 2.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING order_check.
  ENDIF.

* remove contract records N:2481749
  DELETE lt_orders WHERE actdoctype = 'QCVA'.

  LOOP AT lt_orders ASSIGNING <ls_order> .

    CALL FUNCTION '/DBE/ORD_DB_READ_HEADER'
      EXPORTING
        iv_vbeln     = <ls_order>-vbeln
      IMPORTING
        es_vbak_com  = ls_vbak_com
      EXCEPTIONS
        not_found    = 1
        inconsistent = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING order_not_found.
    ENDIF.

    IF   ls_vbak_com-closed IS NOT INITIAL
      OR ls_vbak_com-loevm IS NOT INITIAL.              "all order types with assigned vehicle are relevant N:2801315
      DELETE lt_orders.
      CONTINUE.
    ENDIF.

*   Check if plants are different               "1713006
    IF NOT is_vlcactdata-werks IS INITIAL AND NOT is_vlcactdata-umwerks IS INITIAL AND
           is_vlcactdata-werks <> is_vlcactdata-umwerks.
*      IF ls_vbak_com-engine = lc_engine_sd OR ls_vbak_com-engine = lc_engine_fo. "N:2801315
*        MESSAGE e254(/dbe/vehicle_master) WITH <ls_order>-vbeln RAISING order_not_found.
*      ENDIF.
    ELSE.
      "For vehicle orders no problem. Storage locations will be updated
    ENDIF.

    CALL FUNCTION '/DBE/C_GET_ORDER_PARAMETER'
      EXPORTING
        i_aufart  = ls_vbak_com-aufart
      IMPORTING
        e_ordertp = ls_ordertp
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF ls_ordertp-doc_type = '02' OR ls_ordertp-doc_type = '05'. "N:2829711
*     At this point, it is known that this is an Internal Service Order. Subsequent checks
*     should determine if the internal order of the Vehicle is used in this service order.
      IF is_vlcactdata-/dbe/coaufnr = ls_vbak_com-int_ord.
        IF is_vlcactdata-umwerks NE ls_vbak_com-werks.
          MESSAGE e273(/dbe/vehicle_master) WITH is_vlcactdata-/dbe/coaufnr ls_vbak_com-vbeln RAISING order_open.
        ENDIF.
      ENDIF.
    ENDIF.                                                  "N:2829711

*   check as well all splits > 1                                                                >>>N:2829711
    SELECT splnr aufart int_ord FROM /dbe/splhdr_db
      INTO CORRESPONDING FIELDS OF TABLE lt_splhdr
      WHERE vbeln = <ls_order>-vbeln AND
            splnr > '0001'.

    LOOP AT lt_splhdr ASSIGNING <ls_splhdr>.
      CALL FUNCTION '/DBE/C_GET_ORDER_PARAMETER'
        EXPORTING
          i_aufart  = <ls_splhdr>-aufart
        IMPORTING
          e_ordertp = ls_ordertp
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

      IF ls_ordertp-doc_type = '02' OR ls_ordertp-doc_type = '05'.
*       At this point, it is known that this is an Internal Service Order. Subsequent checks
*       should determine if the internal order of the Vehicle is used in this service order.
        IF is_vlcactdata-/dbe/coaufnr = <ls_splhdr>-int_ord.
          MESSAGE e273(/dbe/vehicle_master) WITH is_vlcactdata-/dbe/coaufnr ls_vbak_com-vbeln RAISING order_open.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

******* Check Plants in same Companycode
*  IF NOT is_vlcactdata-werks IS INITIAL AND NOT is_vlcactdata-umwerks IS INITIAL.
*    CALL FUNCTION '/DBE/C_GET_COMPANY_DATA'
*      EXPORTING
*        i_check_access = 'X'
*      TABLES
*        e_company      = lt_comp_data
*      EXCEPTIONS
*        no_data_found  = 1
*        OTHERS         = 2.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING company_data_error.
*    ENDIF.
*
*    READ TABLE lt_comp_data INTO ls_comp_data WITH KEY werks = is_vlcactdata-werks.
*    IF sy-subrc <> 0.
*      MESSAGE e534(/dbe/common) RAISING  company_data_error.
*    ENDIF.
*
*    READ TABLE lt_comp_data WITH KEY werks = is_vlcactdata-umwerks
*                                     bukrs = ls_comp_data-bukrs
*    TRANSPORTING NO FIELDS.
*    IF sy-subrc <> 0.
*      MESSAGE e255(/dbe/vehicle_master) RAISING werks_bukrs_error.
*    ENDIF.
*  ENDIF.

******* Check alredy Accouting Rules for interlan order

ENDFUNCTION.

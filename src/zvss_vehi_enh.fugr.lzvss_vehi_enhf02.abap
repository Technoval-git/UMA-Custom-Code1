*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ENHF02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form f_get_last_service_date
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_VLCDIAVEHI_VGUID
*&      <-- /DBE/SCR_DATA_OVERVIEW_LAST_SE
*&---------------------------------------------------------------------*
FORM f_get_last_service_date  USING    p_vguid TYPE vlcguid-vguid
                              CHANGING p_last_service_date TYPE datum.

  DATA: lt_vlcguid  TYPE TABLE OF vlcguid,
        ls_vlcguid  TYPE vlcguid,
        ls_vlcorder TYPE /DBE/vlcorder,
        ls_last_service_order TYPE /DBE/vlcorder,
        lt_vlcorder TYPE TABLE OF /DBE/vlcorder,
        lt_ordtyp   TYPE /DBE/c_tt_ordertp,
        ls_ordtyp   TYPE /DBE/c_ordertp,
        ls_search_data TYPE /DBE/s_co_ord_search_single,
        lt_vbak_com TYPE /DBE/vbak_com_tt,
        ls_vbak_com TYPE /DBE/vbak_com,
        lv_last_service TYPE tzntstmps.
  DATA:
       lv_status   TYPE /DBE/status_vb.
  DATA: lv_veh_mode TYPE c.

  CLEAR p_last_service_date.

*Get vehicle mode - change or display
  CALL FUNCTION '/DBE/VM08_VEHICLE_MODE_GET'
    IMPORTING
      ev_veh_mode = lv_veh_mode.
  IF lv_veh_mode = gc_2.
    RETURN.
  ENDIF.

* Get order type customizing to determine service orders
  CALL FUNCTION '/DBE/CU06_READ_ORDTYP_ENG'
*   EXPORTING
*     IV_ENGINE          =
*     IV_VBTYP           =
  IMPORTING
*     ES_C_ORDERTP       =
     et_c_ordertp       = lt_ordtyp
  EXCEPTIONS
*    not_found          = 1
    OTHERS             = 0. "No error

* Select all service orders / quotations for the vehicle
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbak_com
        FROM /DBE/vbak_db AS vbak
        INNER JOIN /DBE/splhdr_db AS splhdr
        ON splhdr~vbeln = vbak~vbeln
        AND splhdr~splnr = 1
        WHERE       engine  = 'CS'
                    AND   vguid = p_vguid
          ORDER BY audat DESCENDING.

  IF lt_vbak_com IS INITIAL.
*   No service orders exist for the vehicle
    RETURN.
  ENDIF.
  CLEAR lv_last_service.
  LOOP AT lt_vbak_com INTO ls_vbak_com.
*   Check if the document is an order
    READ TABLE lt_ordtyp WITH KEY aufart = ls_vbak_com-aufart vbtyp = 'C' TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
*     Not order, maybe quotation or returns
      CONTINUE.
    ELSE.
*     Order document
*     Check if order is  technically confirmed                     "N:1590926
      CLEAR lv_status.
      SELECT SINGLE status INTO lv_status FROM /DBE/oe_vbakst WHERE vbeln = ls_vbak_com-vbeln AND action = 'TECH_CONF'.
      IF lv_status = /DBE/cl_oe_status_handling=>c_complete.
          p_last_service_date = ls_vbak_com-audat.
          EXIT.
        ELSE.
* The order isn't technically completed or the customer doesn't use this status, therefore
* the status ord_close is  checked
          CLEAR lv_status.
          SELECT SINGLE status INTO lv_status FROM /DBE/oe_vbakst WHERE vbeln = ls_vbak_com-vbeln AND action = 'ORD_CLOSE'.
          IF lv_status = /DBE/cl_oe_status_handling=>c_complete.
            p_last_service_date = ls_vbak_com-audat.
            EXIT.
          ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

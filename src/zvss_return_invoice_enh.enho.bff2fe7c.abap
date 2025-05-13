"Name: \PR:/DBE/SAPLORDER_INT\FO:MODIFY_INVOICE_DATA_USER_EXIT\SE:BEGIN\EI
ENHANCEMENT 0 ZVSS_RETURN_INVOICE_ENH.
DATA: lr_order       TYPE REF TO /dbe/cl_order,
      ls_order       TYPE /dbe/order_object,
      lv_vbeln       TYPE /dbe/vbeln_va,
      lt_so_invoices TYPE STANDARD TABLE OF vbrk,
      ls_so_invoices TYPE vbrk,
      lt_invoices    TYPE STANDARD TABLE OF vbeln,
      ls_invoices    TYPE  vbeln.
DATA: it_doc_flow  TYPE  /dbe/docflow_documents_tt, "to get proforma no using FM
      it_doc_flow1 TYPE  /dbe/docflow_documents_tt, "to get proforma no using FM
      ts_doc_flow  TYPE /dbe/docflow_documents. "to get proforma no using FM
CLEAR:  ls_order, it_doc_flow,lv_vbeln,lt_so_invoices , ls_so_invoices,it_doc_flow1.

READ TABLE lt_order INTO ls_order INDEX 1.
lr_order = ls_order-order.

SELECT SINGLE * FROM /dbe/c_ordertp INTO @DATA(ls_types) WHERE aufart = @lr_order->ms_header_detail-aufart AND vbtyp EQ 'H'.

IF sy-subrc EQ 0.
  lv_vbeln = lr_order->ms_header_detail-vbeln.

*   *   get proforma number for the given quotation numer.
  CALL FUNCTION '/DBE/OE_MAIN_DOCFLOW_READ_ALL'
    EXPORTING
      iv_vbeln       = lv_vbeln
*     iv_borobj      = 'VBRK'
    IMPORTING
      et_documents   = it_doc_flow1
    EXCEPTIONS
      internal_error = 1
      OTHERS         = 2.

  LOOP AT it_doc_flow1 INTO ts_doc_flow WHERE objtype = 'BUS2400'.

    lv_vbeln = ts_doc_flow-docnum.

*   *   get proforma number for the given quotation numer.
    CALL FUNCTION '/DBE/OE_MAIN_DOCFLOW_READ_ALL'
      EXPORTING
        iv_vbeln       = lv_vbeln
        iv_borobj      = 'VBRK'
        iv_posnr       = ts_doc_flow-posnr
      IMPORTING
        et_documents   = it_doc_flow
      EXCEPTIONS
        internal_error = 1
        OTHERS         = 2.
    IF sy-subrc = 0.
      SORT it_doc_flow DESCENDING BY  docnum seqno.

      CLEAR: ts_doc_flow.
      LOOP AT it_doc_flow INTO ts_doc_flow WHERE objtype = 'VBRK'.
        ls_invoices = ts_doc_flow-docnum.
        APPEND ls_invoices TO lt_invoices.
      ENDLOOP.
      SORT lt_invoices.
      DELETE ADJACENT DUPLICATES FROM lt_invoices COMPARING ALL FIELDS.
      IF lt_invoices IS NOT INITIAL.
        CLEAR:lt_so_invoices.
        SELECT * FROM vbrk INTO TABLE  lt_so_invoices FOR ALL ENTRIES IN lt_invoices WHERE vbeln = lt_invoices-table_line AND fksto = '' AND sfakn = ''.
        IF sy-subrc EQ 0.
          SORT lt_so_invoices BY vbeln.
        ENDIF.

        LOOP AT ct_komfkgn ASSIGNING FIELD-SYMBOL(<fs_kom1>) .
          READ TABLE lt_so_invoices INTO ls_so_invoices WITH KEY kunag = <fs_kom1>-kunag.
          IF sy-subrc EQ 0.
            <fs_kom1>-bstnk_vf = ls_so_invoices-vbeln.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDIF.


ENDENHANCEMENT.

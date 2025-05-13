*&---------------------------------------------------------------------*
*& Include          ZXCATU06
*&---------------------------------------------------------------------*

DATA: lo_dbmdata TYPE REF TO /dbe/cl_tm_dbmdata_example,
      lv_ok_code TYPE syucomm,
      lv_vbeln   TYPE /dbe/vbeln_va,
      lv_status  TYPE status_vb,
      ls_job_com TYPE /dbe/job_com.

FIELD-SYMBOLS: <ls_enrich_table> TYPE cats_comm.

CREATE OBJECT lo_dbmdata.

*IF NOT <ls_enrich_table>-/dbe/vbeln IS INITIAL.

lv_ok_code = sy-ucomm.

IF lv_ok_code = 'SAVE'.

  IF NOT go_order IS INITIAL.

* Check, if order is approved
    CALL METHOD go_order->mo_status->get_header
      EXPORTING
        iv_action = 'CUST_APPROVAL'
      RECEIVING
        ev_status = lv_status.

    IF lv_status = 'A'.
      LOOP AT go_order->mt_job_com INTO ls_job_com WHERE jobnr <> '000000'.
        IF ls_job_com-rejected IS NOT INITIAL OR ls_job_com-deferred_work IS NOT INITIAL OR ls_job_com-approved IS INITIAL.
          MESSAGE e350(/dbe/tm) WITH go_order->ms_vbak_com-vbeln.
        ENDIF.
      ENDLOOP.
    ELSEIF lv_status = 'B'.
      MESSAGE e350(/dbe/tm) WITH go_order->ms_vbak_com-vbeln.
    ENDIF.
    CREATE OBJECT lo_dbmdata.
    CALL METHOD lo_dbmdata->save_order
      CHANGING
        co_order        = go_order
      EXCEPTIONS
        parameter_error = 1
        OTHERS          = 2.
  ENDIF.
ENDIF.
IF lv_ok_code = 'YES'.
  CALL METHOD lo_dbmdata->set_sub_seq_costs
    EXPORTING
      is_tcats           = sap_tcats
      is_enrich_table    = <ls_enrich_table> "gs_enrich_table "<ls_enrich_table>
    IMPORTING
      ev_vbeln           = lv_vbeln
    CHANGING
      co_order           = go_order
    EXCEPTIONS
      order_error        = 1
      order_closed       = 2
      order_not_relevant = 3.
  IF sy-subrc = 1.
    MESSAGE e057(/dbe/rfc_common) WITH sy-uname lv_vbeln.
    RETURN.
  ENDIF.
  IF sy-subrc = 2.
    MESSAGE e350(/dbe/tm) WITH lv_vbeln.
    RETURN.
  ENDIF.
ENDIF.
*ENDIF.

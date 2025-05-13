*&---------------------------------------------------------------------*
*& Include          ZXCATU02
*&---------------------------------------------------------------------*


DATA: lo_dbmdata TYPE REF TO /dbe/cl_tm_dbmdata_example,
      lv_vbeln   TYPE /dbe/vbeln_va.

FIELD-SYMBOLS: <ls_enrich_table> TYPE cats_comm.
READ TABLE enrich_table ASSIGNING <ls_enrich_table> INDEX 1.
CREATE OBJECT lo_dbmdata.
CALL METHOD lo_dbmdata->fill_cats_dbm_data
  EXPORTING
    is_tcats        = sap_tcats
  CHANGING
    cs_enrich_table = <ls_enrich_table>.

IF NOT <ls_enrich_table>-/dbe/vbeln IS INITIAL.
  DATA: lv_ok_code TYPE sy-ucomm.
  lv_ok_code = sy-ucomm.
  IF lv_ok_code = 'TIME' OR lv_ok_code = 'COPY'.
    CALL METHOD lo_dbmdata->set_sub_seq_costs
      EXPORTING
        is_tcats           = sap_tcats
        is_enrich_table    = <ls_enrich_table>
      CHANGING
        co_order           = go_order
      EXCEPTIONS
        order_error        = 1
        order_closed       = 2
        order_not_relevant = 3.
    IF sy-subrc = 1.
      MESSAGE e057(/dbe/rfc_common) WITH sy-uname go_order->ms_vbak_com-vbeln.
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e350(/dbe/tm) WITH go_order->ms_vbak_com-vbeln.
    ENDIF.
  ENDIF.

  IF lv_ok_code = 'SAVE'.
    CALL METHOD lo_dbmdata->set_sub_seq_costs
      EXPORTING
        is_tcats           = sap_tcats
        is_enrich_table    = <ls_enrich_table>
      CHANGING
        co_order           = go_order
      EXCEPTIONS
        order_error        = 1
        order_closed       = 2
        order_not_relevant = 3.
    IF sy-subrc = 1.
      MESSAGE e057(/dbe/rfc_common) WITH sy-uname go_order->ms_vbak_com-vbeln.
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e350(/dbe/tm) WITH go_order->ms_vbak_com-vbeln.
    ENDIF.
    IF sy-subrc = 3.
      MESSAGE e002(/dbe/subseq_costs) WITH go_order->ms_vbak_com-vbeln.
    ENDIF.
    CALL METHOD lo_dbmdata->save_order
      CHANGING
        co_order        = go_order
      EXCEPTIONS
        parameter_error = 1
        OTHERS          = 2.
  ENDIF.
ENDIF.

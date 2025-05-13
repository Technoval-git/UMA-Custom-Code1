*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF98 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_JOBS_WITHOUT_ITEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LO_PDI_ORDER  text
*----------------------------------------------------------------------*
FORM f_create_jobs_without_items
              USING
                    ps_pdi_job LIKE LINE OF gt_pdi_ord
                    pv_vhvin TYPE vlc_vhvin
              CHANGING po_order TYPE REF TO /DBE/cl_order.

  DATA lt_return          TYPE bapiret2_t.
  DATA ls_return          LIKE LINE OF lt_return.
  DATA ls_job_detail      TYPE /DBE/job_com.

  REFRESH po_order->mt_job_detail.
  CLEAR ls_job_detail.
  ls_job_detail-descr1 = ps_pdi_job-job_descr.
  APPEND ls_job_detail TO po_order->mt_job_detail.

  "Create Job
  CALL FUNCTION '/DBE/OE_MAIN_CONTROL'
    EXPORTING
      iv_event         = /DBE/cl_order_engine=>c_ord_job_new
      io_order         = po_order
    EXCEPTIONS
      internal_error   = 1
      nothing_selected = 2
      action_error     = 3
      OTHERS           = 4.

  IF sy-subrc NE 0.
    "Collect logs to global table
    PERFORM update_logs_to_globaltable USING lo_pdi_order ls_order_creation-vhvin.
    "In case of error, delete all success message/s
    DELETE gt_bapireturn WHERE type NE 'E'.
    "Update logs into the log tab
*    lo_veh->add_bapiret2_bal( EXPORTING it_bapiret2 = gt_bapireturn
*                                        is_context = ls_context
*                                        is_params = ls_params  ).

  ENDIF.

ENDFORM.                    " F_CREATE_JOBS_WITHOUT_ITEMS

FUNCTION ZDBE_VMASS_ADC_FINAL_CHECK.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_ACTION_NAME) TYPE  VLC_ACTION
*"  TABLES
*"      IT_VLC_AC_PO TYPE  /DBE/VLC_AC_PO_T
*"  EXCEPTIONS
*"      DATA_INCOS
*"--------------------------------------------------------------------
  DATA: ls_vlc_ac_po TYPE /DBE/vlc_ac_po.

  LOOP AT it_vlc_ac_po INTO ls_vlc_ac_po.

    IF ls_vlc_ac_po-guid IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-tstmp IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-vguid IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-int_ord IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-plant IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-purch_org IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-pur_group IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-vendor IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-service_type IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-service_mat IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-cost IS INITIAL . RAISE data_incos. ENDIF.
    IF ls_vlc_ac_po-currency IS INITIAL . RAISE data_incos. ENDIF.

*    IF ls_vlc_ac_po-netamout IS INITIAL . RAISE data_incos. ENDIF.
*    IF ls_vlc_ac_po-tax_amount IS INITIAL . RAISE data_incos. ENDIF.
*    IF ls_vlc_ac_po-ref_doc_no IS INITIAL . RAISE data_incos. ENDIF.
*    IF ls_vlc_ac_po-gross_amount IS INITIAL . RAISE data_incos. ENDIF.
*    IF ls_vlc_ac_po-bldat IS INITIAL . RAISE data_incos. ENDIF.
*    IF ls_vlc_ac_po-budat IS INITIAL . RAISE data_incos. ENDIF.
*    IF ls_vlc_ac_po-comp_code IS INITIAL . RAISE data_incos. ENDIF.

    CASE iv_action_name.
      WHEN /DBE/if_vms_constants=>c_qapo.
        IF ls_vlc_ac_po-po_number IS INITIAL . RAISE data_incos. ENDIF.
        IF ls_vlc_ac_po-po_item IS INITIAL . RAISE data_incos. ENDIF.
        IF ls_vlc_ac_po-po_status IS INITIAL . RAISE data_incos. ENDIF.
      WHEN /DBE/if_vms_constants=>c_qagr.
        IF ls_vlc_ac_po-gr_number IS INITIAL . RAISE data_incos. ENDIF.
        IF ls_vlc_ac_po-gr_year IS INITIAL . RAISE data_incos. ENDIF.
        IF ls_vlc_ac_po-gr_status IS INITIAL . RAISE data_incos. ENDIF.
      WHEN /DBE/if_vms_constants=>c_qain.
        IF ls_vlc_ac_po-tax_code IS INITIAL . RAISE data_incos. ENDIF.
        IF ls_vlc_ac_po-inv_number IS INITIAL . RAISE data_incos. ENDIF.
        IF ls_vlc_ac_po-inv_year IS INITIAL . RAISE data_incos. ENDIF.
        IF ls_vlc_ac_po-inv_status IS INITIAL . RAISE data_incos. ENDIF.
      WHEN OTHERS.
        RAISE data_incos.
    ENDCASE.

  ENDLOOP.
ENDFUNCTION.

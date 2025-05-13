FUNCTION ZDBE_VMASS_VARIANT_DELETE_DB.
*"--------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  TABLES
*"      IT_SVARIANT_DEL STRUCTURE  /DBE/V_SVARIANT
*"--------------------------------------------------------------------
  DATA: ls_svariant TYPE /DBE/vm_svariant.

  DATA:    lc_rep_name TYPE string VALUE '/DBE/VEHI_STOCK_AGEING',
           lv_report TYPE rsvar-report,
           lv_variant TYPE rsvar-variant.

  LOOP AT it_svariant_del INTO ls_svariant.                 "#EC ENHOK

    DELETE FROM /DBE/vm_svariant WHERE uname = ls_svariant-uname AND svar = ls_svariant-svar.
    DELETE FROM /DBE/vm_svartxt WHERE uname = ls_svariant-uname AND svar = ls_svariant-svar.
    DELETE FROM /DBE/vm_svcrit WHERE uname = ls_svariant-uname AND svar = ls_svariant-svar.
    DELETE FROM /DBE/vm_svval WHERE uname = ls_svariant-uname AND svar = ls_svariant-svar.


    "Delete the varinat for stock age also

    lv_report = lc_rep_name.
    lv_variant = ls_svariant-svar.

    CALL FUNCTION 'RS_VARIANT_DELETE'
      EXPORTING
        report               = lv_report
        variant              = lv_variant
        flag_confirmscreen   = 'X'
        flag_delallclient    = 'X'
      EXCEPTIONS
        not_authorized       = 1
        not_executed         = 2
        no_report            = 3
        report_not_existent  = 4
        report_not_supplied  = 5
        variant_locked       = 6
        variant_not_existent = 7
        no_corr_insert       = 8
        variant_protected    = 9
        OTHERS               = 10.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.



  ENDLOOP.

ENDFUNCTION.

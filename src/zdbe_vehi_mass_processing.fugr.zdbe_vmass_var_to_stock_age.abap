FUNCTION ZDBE_VMASS_VAR_TO_STOCK_AGE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_SVARIANT STRUCTURE  /DBE/VM_SVARIANT
*"      IT_SVARTXT STRUCTURE  /DBE/VM_SVARTXT
*"      IT_SVCRIT STRUCTURE  /DBE/VM_SVCRIT
*"      IT_SVVAL STRUCTURE  /DBE/VM_SVVAL
*"--------------------------------------------------------------------
  DATA:    lt_create_var TYPE TABLE OF varid-variant,
           ls_varid   TYPE varid,
           lt_vsa_var_db TYPE TABLE OF varid,
           lt_vari_contents	TYPE TABLE OF rsparams,
           ls_vari_contents	TYPE  rsparams,
           lt_vari_text TYPE TABLE OF   varit,
           ls_vari_text TYPE  varit,
           lv_curr_report TYPE rsvar-report VALUE '/DBE/VEHI_STOCK_AGEING' ,
           lv_curr_variant TYPE rsvar-variant.

  DATA:   lt_svariant TYPE TABLE OF /DBE/vm_svariant,
          lv_svar       TYPE /DBE/vm_svariant-svar,
          ls_svartxt  TYPE  /DBE/vm_svartxt,
          ls_svcrit TYPE  /DBE/vm_svcrit,
          ls_svval  TYPE  /DBE/vm_svval.

  FIELD-SYMBOLS: <ls_var> TYPE /DBE/vm_svariant,
                 <ls_var_txt> TYPE /DBE/vm_svartxt,
                 <var> TYPE varid-variant.

  SELECT * FROM varid INTO TABLE lt_vsa_var_db WHERE report = lv_curr_report .
IF sy-subrc <> 0.
  " This means that this is DBM 8.0. we need to push the variant now on.
  " This code will execute only once when ebm 8.0 is installed.
  " We need to fillter the data which is already exist in the Mass Acton DB
ENDIF.

  " we need stop the incosistent data to be pushed to stock ageing.
  " In standard varinat only variant key is unique so we need check with all variant ID
  " Only unique variant will be pushed to standard variant
  LOOP AT it_svariant ASSIGNING <ls_var>.
    lv_svar = <ls_var>-svar.
    TRANSLATE lv_svar TO UPPER CASE.
    IF lv_svar EQ <ls_var>-svar.
    READ TABLE lt_vsa_var_db TRANSPORTING NO FIELDS WITH KEY variant = <ls_var>-svar.
    IF sy-subrc <> 0.
      APPEND <ls_var>-svar TO lt_create_var.
    ENDIF.
    ENDIF.
  ENDLOOP.


    LOOP AT lt_create_var ASSIGNING <var>.
      READ TABLE it_svariant ASSIGNING <ls_var> WITH KEY svar = <var>.
      ls_varid-report = lv_curr_report.
      ls_varid-variant = lv_curr_variant = <ls_var>-svar.
      ls_varid-version = 1.
      MOVE sy-mandt             TO ls_varid-mandt.
      MOVE sy-uname             TO ls_varid-ename.
      MOVE sy-datum             TO ls_varid-edat .
      MOVE sy-uzeit             TO ls_varid-etime.
      MOVE 'A'                  TO ls_varid-environmnt.
      MOVE 'F'                  TO ls_varid-transport.

      LOOP AT it_svartxt INTO ls_svartxt WHERE svar = <var>.
        ls_vari_text-report = lv_curr_report.
        ls_vari_text-variant = ls_svartxt-svar.
        ls_vari_text-vtext = ls_svartxt-svart.

        MOVE sy-mandt             TO ls_vari_text-mandt.
        MOVE sy-langu             TO ls_vari_text-langu.

        APPEND ls_vari_text TO lt_vari_text.

      ENDLOOP.

      CALL FUNCTION 'RS_CREATE_VARIANT'
        EXPORTING
          curr_report               = lv_curr_report
          curr_variant              = lv_curr_variant
          vari_desc                 = ls_varid
        TABLES
          vari_contents             = lt_vari_contents
          vari_text                 = lt_vari_text
        EXCEPTIONS
          illegal_report_or_variant = 1
          illegal_variantname       = 2
          not_authorized            = 3
          not_executed              = 4
          report_not_existent       = 5
          report_not_supplied       = 6
          variant_exists            = 7
          variant_locked            = 8
          OTHERS                    = 9.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    ENDLOOP.


ENDFUNCTION.

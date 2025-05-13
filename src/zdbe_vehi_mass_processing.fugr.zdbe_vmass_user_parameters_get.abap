FUNCTION ZDBE_VMASS_USER_PARAMETERS_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_PARID) TYPE  MEMORYID
*"  EXPORTING
*"     REFERENCE(EV_PARVA) TYPE  XUVALUE
*"  EXCEPTIONS
*"      NOT_FOUND
*"--------------------------------------------------------------------
DATA:    ls_usparam         TYPE          usparam.
DATA:    lt_usparam         TYPE TABLE OF USPARAM.
DATA:    ls_mass_usparam         TYPE          usparam.
DATA:    lt_mass_usparam         TYPE TABLE OF USPARAM.
STATICS: sv_usparam_read    TYPE          flag.
*----------------------------------------------------------------------

*Check: User parameters already read?
IF sv_usparam_read IS INITIAL.
* Read user parameters from SU01
  CALL FUNCTION 'SUSR_USER_PARAMETERS_GET'
        EXPORTING
          user_name       = sy-uname
        TABLES
          user_parameters = lt_usparam
        EXCEPTIONS
          USER_NAME_NOT_EXIST = 1
          OTHERS = 2.

  IF sy-subrc NE 0.
    RAISE not_found.
  ENDIF.

  READ TABLE lt_usparam WITH KEY parid = iv_parid TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    ls_usparam-parid = gc_mass_svariant_def.
    APPEND ls_usparam TO lt_usparam.
    CALL FUNCTION 'SUSR_USER_PARAMETERS_PUT'
      EXPORTING
        user_name                 = sy-uname
      TABLES
        user_parameters           = lt_usparam
      EXCEPTIONS
        user_name_not_exist = 1
        OTHERS = 2.

  IF sy-subrc NE 0.
  ENDIF.

  ENDIF.
  gt_mass_usparam[] = lt_usparam[].

*   Set static flag to indicate that user parameters have already been
*   read
    sv_usparam_read = gc_x.

ENDIF.

*Any user parameters found?
IF NOT gt_mass_usparam IS INITIAL.

* Try to find the entry for the requested Parameter ID
  READ TABLE gt_mass_usparam INTO ls_usparam
        WITH KEY parid = iv_parid.

  CLEAR ev_parva.
* Return the value found for the Parameter ID
  ev_parva = ls_usparam-parva.
ENDIF.

ENDFUNCTION.

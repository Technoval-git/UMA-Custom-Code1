FUNCTION ZDBE_CHECK_MODELCATALOG_AUTH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MODEL_CAT) TYPE  /DBE/MCATALOG OPTIONAL
*"     VALUE(IV_COMP_CODE) TYPE  BUKRS OPTIONAL
*"     VALUE(IV_ACTIVITY) TYPE  ACTIV_AUTH OPTIONAL
*"  EXCEPTIONS
*"      NO_AUTHORITY
*"      OTHERS
*"--------------------------------------------------------------------


*Model Catalog(Brand) Level Authority Check
  IF NOT iv_model_cat IS INITIAL .

    AUTHORITY-CHECK OBJECT vlc_mcat_authority_object
         ID '/DBE/MCAT'  FIELD iv_model_cat
         ID 'BUKRS'      DUMMY
         ID 'ACTVT'      DUMMY.

  ENDIF.

  IF sy-subrc = 4.
    RAISE no_authority.
  ELSEIF sy-subrc <> 0.
    RAISE others.
  ENDIF.



ENDFUNCTION.

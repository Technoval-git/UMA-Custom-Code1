FUNCTION ZDBE_VMASS_PARAMETERID_SAVE.
*"--------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_UNAME) TYPE  SYUNAME
*"  TABLES
*"      IT_USPARAM STRUCTURE  USPARAM
*"--------------------------------------------------------------------

CALL FUNCTION 'SUSR_USER_PARAMETERS_PUT'
  EXPORTING
    user_name                 = iv_uname
  TABLES
    user_parameters           = it_usparam.

CALL FUNCTION 'SUSR_USER_BUFFERS_TO_DB'.
*  EXPORTING
*    BACK_DISTRIBUTION               = ' '
*    MESSAGE_OUT                     = ' '
*    DISTRIBUTION                    = 'X'
*  TABLES
*    OFFICE_USERS                    =
*  EXCEPTIONS
*    NO_LOGONDATA_FOR_NEW_USER       = 1
*    NO_INIT_PASSWORD                = 2
*    DB_INSERT_USR02_FAILED          = 3
*    DB_UPDATE_USR02_FAILED          = 4
*    DB_INSERT_USR01_FAILED          = 5
*    DB_UPDATE_USR01_FAILED          = 6
*    DB_INSERT_USR05_FAILED          = 7
*    DB_UPDATE_USR05_FAILED          = 8
*    DB_INSERT_USR21_FAILED          = 9
*    DB_UPDATE_USR21_FAILED          = 10
*    INTERNAL_ERROR                  = 11
*    OTHERS                          = 12.

*IF sy-subrc <> 0.
*  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.

ENDFUNCTION.

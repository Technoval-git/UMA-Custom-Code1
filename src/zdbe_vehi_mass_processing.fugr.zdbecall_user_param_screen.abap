FUNCTION ZDBECALL_USER_PARAM_SCREEN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_OK_CODE) TYPE  SYUCOMM
*"--------------------------------------------------------------------

  CLEAR: ok_code.

  CALL SCREEN 1001 STARTING AT 5 4 ENDING AT 60 4.

ENDFUNCTION.

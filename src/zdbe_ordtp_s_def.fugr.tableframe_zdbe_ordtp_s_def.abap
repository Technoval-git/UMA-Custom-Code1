*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZDBE_ORDTP_S_DEF
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZDBE_ORDTP_S_DEF   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

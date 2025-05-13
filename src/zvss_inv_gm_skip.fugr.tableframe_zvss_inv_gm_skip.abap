*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZVSS_INV_GM_SKIP
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZVSS_INV_GM_SKIP   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

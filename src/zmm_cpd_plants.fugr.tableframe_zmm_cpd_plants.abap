*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZMM_CPD_PLANTS
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZMM_CPD_PLANTS     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

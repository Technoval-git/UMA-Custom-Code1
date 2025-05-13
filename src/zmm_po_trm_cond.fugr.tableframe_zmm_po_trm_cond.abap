*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZMM_PO_TRM_COND
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZMM_PO_TRM_COND    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

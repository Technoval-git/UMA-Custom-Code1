*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_PO_TRM_COND.................................*
DATA:  BEGIN OF STATUS_ZMM_PO_TRM_COND               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_PO_TRM_COND               .
CONTROLS: TCTRL_ZMM_PO_TRM_COND
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMM_PO_TRM_COND               .
TABLES: ZMM_PO_TRM_COND                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

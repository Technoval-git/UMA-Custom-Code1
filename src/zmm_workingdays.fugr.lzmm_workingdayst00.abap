*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_WORKINGDAYS.................................*
DATA:  BEGIN OF STATUS_ZMM_WORKINGDAYS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_WORKINGDAYS               .
CONTROLS: TCTRL_ZMM_WORKINGDAYS
            TYPE TABLEVIEW USING SCREEN '0900'.
*.........table declarations:.................................*
TABLES: *ZMM_WORKINGDAYS               .
TABLES: ZMM_WORKINGDAYS                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

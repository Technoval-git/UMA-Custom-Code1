*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_WORK_DAYS...................................*
DATA:  BEGIN OF STATUS_ZMM_WORK_DAYS                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_WORK_DAYS                 .
CONTROLS: TCTRL_ZMM_WORK_DAYS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMM_WORK_DAYS                 .
TABLES: ZMM_WORK_DAYS                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

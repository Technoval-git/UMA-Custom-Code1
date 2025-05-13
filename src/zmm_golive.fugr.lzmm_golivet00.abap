*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_GOLIVE......................................*
DATA:  BEGIN OF STATUS_ZMM_GOLIVE                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_GOLIVE                    .
CONTROLS: TCTRL_ZMM_GOLIVE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMM_GOLIVE                    .
TABLES: ZMM_GOLIVE                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPRCTR_001......................................*
DATA:  BEGIN OF STATUS_ZPRCTR_001                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPRCTR_001                    .
CONTROLS: TCTRL_ZPRCTR_001
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPRCTR_001                    .
TABLES: ZPRCTR_001                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

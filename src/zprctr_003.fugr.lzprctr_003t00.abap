*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPRCTR_003......................................*
DATA:  BEGIN OF STATUS_ZPRCTR_003                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPRCTR_003                    .
CONTROLS: TCTRL_ZPRCTR_003
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPRCTR_003                    .
TABLES: ZPRCTR_003                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

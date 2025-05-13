*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPRCTR_002......................................*
DATA:  BEGIN OF STATUS_ZPRCTR_002                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPRCTR_002                    .
CONTROLS: TCTRL_ZPRCTR_002
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPRCTR_002                    .
TABLES: ZPRCTR_002                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDBE_WTYDATA_AS1................................*
DATA:  BEGIN OF STATUS_ZDBE_WTYDATA_AS1              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDBE_WTYDATA_AS1              .
CONTROLS: TCTRL_ZDBE_WTYDATA_AS1
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDBE_WTYDATA_AS1              .
TABLES: ZDBE_WTYDATA_AS1               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

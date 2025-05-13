*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YABC............................................*
DATA:  BEGIN OF STATUS_YABC                          .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YABC                          .
CONTROLS: TCTRL_YABC
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *YABC                          .
TABLES: YABC                           .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

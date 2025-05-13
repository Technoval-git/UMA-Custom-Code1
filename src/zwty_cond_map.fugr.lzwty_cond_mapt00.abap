*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZWTY_COND_MAP...................................*
DATA:  BEGIN OF STATUS_ZWTY_COND_MAP                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZWTY_COND_MAP                 .
CONTROLS: TCTRL_ZWTY_COND_MAP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZWTY_COND_MAP                 .
TABLES: ZWTY_COND_MAP                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

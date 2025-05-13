*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVSS_PRICE_COND1................................*
DATA:  BEGIN OF STATUS_ZVSS_PRICE_COND1              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVSS_PRICE_COND1              .
CONTROLS: TCTRL_ZVSS_PRICE_COND1
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVSS_PRICE_COND1              .
TABLES: ZVSS_PRICE_COND1               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

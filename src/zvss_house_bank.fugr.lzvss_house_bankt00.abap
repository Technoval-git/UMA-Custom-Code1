*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVSS_HOUSE_BANK.................................*
DATA:  BEGIN OF STATUS_ZVSS_HOUSE_BANK               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVSS_HOUSE_BANK               .
CONTROLS: TCTRL_ZVSS_HOUSE_BANK
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVSS_HOUSE_BANK               .
TABLES: ZVSS_HOUSE_BANK                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

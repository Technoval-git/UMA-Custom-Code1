*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVSS_BANK_CODE..................................*
DATA:  BEGIN OF STATUS_ZVSS_BANK_CODE                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVSS_BANK_CODE                .
CONTROLS: TCTRL_ZVSS_BANK_CODE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVSS_BANK_CODE                .
TABLES: ZVSS_BANK_CODE                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

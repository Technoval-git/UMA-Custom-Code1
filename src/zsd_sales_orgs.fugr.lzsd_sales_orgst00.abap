*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSD_SALES_ORGS..................................*
DATA:  BEGIN OF STATUS_ZSD_SALES_ORGS                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSD_SALES_ORGS                .
CONTROLS: TCTRL_ZSD_SALES_ORGS
            TYPE TABLEVIEW USING SCREEN '0900'.
*.........table declarations:.................................*
TABLES: *ZSD_SALES_ORGS                .
TABLES: ZSD_SALES_ORGS                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVSS_INV_GM_SKIP................................*
DATA:  BEGIN OF STATUS_ZVSS_INV_GM_SKIP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVSS_INV_GM_SKIP              .
CONTROLS: TCTRL_ZVSS_INV_GM_SKIP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVSS_INV_GM_SKIP              .
TABLES: ZVSS_INV_GM_SKIP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

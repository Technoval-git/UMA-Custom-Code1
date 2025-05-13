*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YMM_MRP_PL......................................*
DATA:  BEGIN OF STATUS_YMM_MRP_PL                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YMM_MRP_PL                    .
CONTROLS: TCTRL_YMM_MRP_PL
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *YMM_MRP_PL                    .
TABLES: YMM_MRP_PL                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

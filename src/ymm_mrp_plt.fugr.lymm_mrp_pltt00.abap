*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YMM_MRP_PLT.....................................*
DATA:  BEGIN OF STATUS_YMM_MRP_PLT                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YMM_MRP_PLT                   .
CONTROLS: TCTRL_YMM_MRP_PLT
            TYPE TABLEVIEW USING SCREEN '9002'.
*.........table declarations:.................................*
TABLES: *YMM_MRP_PLT                   .
TABLES: YMM_MRP_PLT                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

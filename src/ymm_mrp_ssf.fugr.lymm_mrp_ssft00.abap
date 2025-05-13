*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YMM_MRP_SSF.....................................*
DATA:  BEGIN OF STATUS_YMM_MRP_SSF                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YMM_MRP_SSF                   .
CONTROLS: TCTRL_YMM_MRP_SSF
            TYPE TABLEVIEW USING SCREEN '9002'.
*.........table declarations:.................................*
TABLES: *YMM_MRP_SSF                   .
TABLES: YMM_MRP_SSF                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

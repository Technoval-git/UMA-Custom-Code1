*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMSA_ORD_AREA...................................*
DATA:  BEGIN OF STATUS_ZMSA_ORD_AREA                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMSA_ORD_AREA                 .
CONTROLS: TCTRL_ZMSA_ORD_AREA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMSA_ORD_AREA                 .
TABLES: ZMSA_ORD_AREA                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSAC_VAR........................................*
DATA:  BEGIN OF STATUS_ZSAC_VAR                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSAC_VAR                      .
CONTROLS: TCTRL_ZSAC_VAR
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSAC_VAR                      .
TABLES: ZSAC_VAR                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVSSC_ITCAT_PART................................*
DATA:  BEGIN OF STATUS_ZVSSC_ITCAT_PART              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVSSC_ITCAT_PART              .
CONTROLS: TCTRL_ZVSSC_ITCAT_PART
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVSSC_ITCAT_PART              .
TABLES: ZVSSC_ITCAT_PART               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

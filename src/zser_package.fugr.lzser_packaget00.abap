*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSER_PACKAGE....................................*
DATA:  BEGIN OF STATUS_ZSER_PACKAGE                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSER_PACKAGE                  .
CONTROLS: TCTRL_ZSER_PACKAGE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSER_PACKAGE                  .
TABLES: ZSER_PACKAGE                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

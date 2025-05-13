*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSER_PARTS_PRCT.................................*
DATA:  BEGIN OF STATUS_ZSER_PARTS_PRCT               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSER_PARTS_PRCT               .
CONTROLS: TCTRL_ZSER_PARTS_PRCT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSER_PARTS_PRCT               .
TABLES: ZSER_PARTS_PRCT                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_CPD_PLANTS..................................*
DATA:  BEGIN OF STATUS_ZMM_CPD_PLANTS                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_CPD_PLANTS                .
CONTROLS: TCTRL_ZMM_CPD_PLANTS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMM_CPD_PLANTS                .
TABLES: ZMM_CPD_PLANTS                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

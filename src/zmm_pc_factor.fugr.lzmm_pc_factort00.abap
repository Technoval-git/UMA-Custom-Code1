*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_PC_FACTOR...................................*
DATA:  BEGIN OF STATUS_ZMM_PC_FACTOR                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_PC_FACTOR                 .
CONTROLS: TCTRL_ZMM_PC_FACTOR
            TYPE TABLEVIEW USING SCREEN '0999'.
*.........table declarations:.................................*
TABLES: *ZMM_PC_FACTOR                 .
TABLES: ZMM_PC_FACTOR                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_PC_AUTHO....................................*
DATA:  BEGIN OF STATUS_ZMM_PC_AUTHO                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_PC_AUTHO                  .
CONTROLS: TCTRL_ZMM_PC_AUTHO
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZMM_PC_AUTHO                  .
TABLES: ZMM_PC_AUTHO                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

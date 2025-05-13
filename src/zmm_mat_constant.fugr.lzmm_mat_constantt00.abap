*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_MAT_CONSTANT................................*
DATA:  BEGIN OF STATUS_ZMM_MAT_CONSTANT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_MAT_CONSTANT              .
CONTROLS: TCTRL_ZMM_MAT_CONSTANT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMM_MAT_CONSTANT              .
TABLES: ZMM_MAT_CONSTANT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

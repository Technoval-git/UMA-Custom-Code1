*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCASH_DESK_USER.................................*
DATA:  BEGIN OF STATUS_ZCASH_DESK_USER               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCASH_DESK_USER               .
CONTROLS: TCTRL_ZCASH_DESK_USER
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCASH_DESK_USER               .
TABLES: ZCASH_DESK_USER                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

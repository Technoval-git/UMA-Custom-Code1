*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDBE_ORDTP_S_DEF................................*
DATA:  BEGIN OF STATUS_ZDBE_ORDTP_S_DEF              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDBE_ORDTP_S_DEF              .
CONTROLS: TCTRL_ZDBE_ORDTP_S_DEF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDBE_ORDTP_S_DEF              .
TABLES: ZDBE_ORDTP_S_DEF               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

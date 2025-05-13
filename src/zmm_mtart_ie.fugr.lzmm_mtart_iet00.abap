*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_MTART_IE....................................*
DATA:  BEGIN OF STATUS_ZMM_MTART_IE                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_MTART_IE                  .
CONTROLS: TCTRL_ZMM_MTART_IE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMM_MTART_IE                  .
TABLES: ZMM_MTART_IE                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

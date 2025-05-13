*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_UPDATE_CCA..................................*
DATA:  BEGIN OF STATUS_ZFI_UPDATE_CCA                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_UPDATE_CCA                .
CONTROLS: TCTRL_ZFI_UPDATE_CCA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_UPDATE_CCA                .
TABLES: ZFI_UPDATE_CCA                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

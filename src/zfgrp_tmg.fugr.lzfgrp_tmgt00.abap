*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_VEND_USER...................................*
DATA:  BEGIN OF STATUS_ZFI_VEND_USER                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_VEND_USER                 .
CONTROLS: TCTRL_ZFI_VEND_USER
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_VEND_USER                 .
TABLES: ZFI_VEND_USER                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

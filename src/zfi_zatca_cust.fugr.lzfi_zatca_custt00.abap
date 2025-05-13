*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_ZATCA_CUST..................................*
DATA:  BEGIN OF STATUS_ZFI_ZATCA_CUST                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_ZATCA_CUST                .
CONTROLS: TCTRL_ZFI_ZATCA_CUST
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_ZATCA_CUST                .
TABLES: ZFI_ZATCA_CUST                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YFI_DER_MM......................................*
DATA:  BEGIN OF STATUS_YFI_DER_MM                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YFI_DER_MM                    .
CONTROLS: TCTRL_YFI_DER_MM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *YFI_DER_MM                    .
TABLES: YFI_DER_MM                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

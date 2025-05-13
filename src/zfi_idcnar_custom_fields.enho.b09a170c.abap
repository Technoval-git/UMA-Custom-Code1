"Name: \PR:RFIDCN_AR_AGING\FO:FICN_APP_OTH_FIELDS\SE:END\EI
ENHANCEMENT 0 ZFI_IDCNAR_CUSTOM_FIELDS.
*
  READ TABLE  ct_fieldcat TRANSPORTING NO FIELDS WITH KEY fieldname = 'XBLOCKED'.
 IF sy-subrc <> 0.
   CLEAR ls_fieldcat.
   ls_fieldcat-fieldname = 'XBLOCKED'.
   ls_fieldcat-scrtext_l = 'Block'.
   ls_fieldcat-scrtext_m = 'Block in Cr. Mgt'.
   ls_fieldcat-scrtext_s = 'Blocked in Credit Management'.
*   ls_fieldcat-col_pos = 232.
   APPEND ls_fieldcat TO ct_fieldcat.
 ENDIF.

 READ TABLE  ct_fieldcat TRANSPORTING NO FIELDS WITH KEY fieldname = 'BU_GROUP'.
 IF sy-subrc <> 0.
   CLEAR ls_fieldcat.
   ls_fieldcat-fieldname = 'BU_GROUP'.
   ls_fieldcat-scrtext_l = 'Business Partner Grouping'.
   ls_fieldcat-scrtext_m = 'BU Grouping'.
   ls_fieldcat-scrtext_s = 'BU Grouping'.
*   ls_fieldcat-col_pos = 232.
   APPEND ls_fieldcat TO ct_fieldcat.
 ENDIF.
  READ TABLE  ct_fieldcat TRANSPORTING NO FIELDS WITH KEY fieldname = 'TXT40'.
 IF sy-subrc <> 0.
   CLEAR ls_fieldcat.
   ls_fieldcat-fieldname = 'TXT40'.
   ls_fieldcat-scrtext_l = 'Description'.
   ls_fieldcat-scrtext_m = 'Description'.
   ls_fieldcat-scrtext_s = 'Description'.
*   ls_fieldcat-col_pos = 232.
   APPEND ls_fieldcat TO ct_fieldcat.
 ENDIF.


ENDENHANCEMENT.

FUNCTION ZDBE_VMASS_ADC_DELETE_DB.
*"--------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  TABLES
*"      IT_VLC_AC_PO TYPE  /DBE/VLC_AC_PO_T
*"--------------------------------------------------------------------

  delete /DBE/vlc_ac_po from TABLE it_vlc_ac_po.
  IF sy-subrc <> 0.
  ENDIF.

ENDFUNCTION.

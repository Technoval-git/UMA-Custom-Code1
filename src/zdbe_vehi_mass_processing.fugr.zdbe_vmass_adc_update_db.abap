FUNCTION ZDBE_VMASS_ADC_UPDATE_DB.
*"--------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  TABLES
*"      IT_VLC_AC_PO TYPE  /DBE/VLC_AC_PO_T
*"--------------------------------------------------------------------
  FIELD-SYMBOLS: <fs_vlc_ac_po> TYPE /DBE/vlc_ac_po.

  MODIFY /DBE/vlc_ac_po FROM TABLE it_vlc_ac_po.
  IF sy-subrc <> 0.
  ENDIF.

ENDFUNCTION.

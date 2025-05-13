"Name: \PR:RAGITT_ALV01\FO:FILL_OUTTAB_LINE\SE:END\EI
ENHANCEMENT 0 Z_ASSET_HISTORY.
DATA : lt_ht   TYPE STANDARD TABLE OF fiaa_salvtab_ragitt,
       lw_ht   TYPE fiaa_salvtab_ragitt,
       sytabix TYPE sy-tabix,
       lv_guid TYPE /DBE/EXTS_OUID,
       lv_modguid type /dbe/model_guid.
MOVE-CORRESPONDING <itab_data> TO lt_ht.
CLEAR: <itab_data>, lv_guid.

LOOP AT lt_ht INTO lw_ht.
  sytabix = sy-tabix.
*  IF lw_ht-typbz IS NOT INITIAL  and ( lw_ht-ANLKL = '20800' or lw_ht-ANLKL = '20900' or lw_ht-ANLKL = '30100' or lw_ht-ANLKL = '30200' ).
*    SELECT SINGLE  model_guid modline modyear vmake FROM /dbe/v_model INTO ( lv_guid, lw_ht-modline , lw_ht-modyear, lw_ht-vmake )
*             WHERE mcodesd = lw_ht-typbz.
*    IF sy-subrc = 0.
*      SELECT SINGLE motext1 FROM /dbe/v_modelt INTO lw_ht-motext1 WHERE model_guid =  lv_guid.
*        select single vhvin from VLCVEHICLE into lw_ht-vhvin where matnr = lw_ht-typbz and bwtar = lw_ht-anlue.
*
*      MODIFY lt_ht  FROM lw_ht INDEX sytabix TRANSPORTING modline modyear vmake motext1 vhvin.
*    ENDIF.
*  ENDIF.
    IF lw_ht-typbz IS NOT INITIAL and ( lw_ht-ANLKL = '00020800' or lw_ht-ANLKL = '00020900' or lw_ht-ANLKL = '00030100' or lw_ht-ANLKL = '00030200' ).
*    Hardcoded assest class as per the instructin, will be decided to include in table later

     select single /DBE/IOBJGUID vhvin from VLCVEHICLE into ( lv_guid , lw_ht-vhvin ) where  bwtar = lw_ht-anlue.
     SELECT SINGLE  MODGUID modline modyear vmake mcodesd FROM /dbe/v_imodel INTO ( lv_modguid, lw_ht-modline , lw_ht-modyear, lw_ht-vmake , lw_ht-mcodesd )
             WHERE product_guid = lv_guid.
    IF sy-subrc = 0.
      SELECT SINGLE motext1 FROM /dbe/v_modelt INTO lw_ht-motext1 WHERE model_guid =  lv_modguid and spras = 'EN'.
      SELECT SINGLE descr FROM /dbe/c_veh_maket INTO lw_ht-motext2 WHERE V_MAKE =  lw_ht-VMAKE and spras = 'EN'.
        MODIFY lt_ht  FROM lw_ht INDEX sytabix TRANSPORTING modline modyear vmake motext1 vhvin mcodesd motext2.
    ENDIF.

  ENDIF.
  MOVE-CORRESPONDING lw_ht TO <itab_line>.
  APPEND <itab_line> TO <itab_data>.
ENDLOOP.

ENDENHANCEMENT.

FUNCTION zvss_vehi_valu_update.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  TABLES
*"      LT_VEHICLE TYPE  VLCDIAVEHI_T
*"  EXCEPTIONS
*"      NO_DATA_RECEIVED
*"      NO_UPDATE_PERFORMED
*"----------------------------------------------------------------------

  DATA : ls_vehicle TYPE vlcdiavehi.

  LOOP AT lt_vehicle INTO ls_vehicle.
    UPDATE mbew SET bklas = '8100' vmbkl = '8100' vjbkl = '8100' eklas = '8100'  WHERE matnr EQ  ls_vehicle-matnr AND
                                                                                       bwkey EQ ls_vehicle-werks AND
                                                                                       bwtar EQ ls_vehicle-vhcle.
  ENDLOOP.



ENDFUNCTION.

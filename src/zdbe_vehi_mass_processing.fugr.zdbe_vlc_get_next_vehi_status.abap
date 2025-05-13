FUNCTION ZDBE_VLC_GET_NEXT_VEHI_STATUS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_ACTION_PERFORMED) TYPE  VLC_ACTION
*"     REFERENCE(IV_VGUID) TYPE  VLC_GUID
*"     REFERENCE(IT_POSSIBLE_STATUS) TYPE  /DBE/VLC_MMSTATU_T
*"  EXPORTING
*"     REFERENCE(EV_NEXT_STATUS) TYPE  VLC_MMSTATU
*"  EXCEPTIONS
*"      NO_HISTORY_FOUND
*"      FAILED_TO_DETERMINED
*"--------------------------------------------------------------------

  DATA:
          lt_vlchistory TYPE TABLE OF vlchistory,
          ls_vlchistory TYPE vlchistory,
          lv_status TYPE vlc_mmstatu,
          lv_count  TYPE i.

  CHECK iv_action_performed EQ  /DBE/if_vms_constants=>c_qain OR iv_action_performed EQ  /DBE/if_vms_constants=>c_qapc.
  CHECK iv_vguid IS NOT INITIAL.

*Get the hostory for the vehicle action
  SELECT * FROM vlchistory INTO TABLE lt_vlchistory WHERE vguid = iv_vguid.
  IF sy-subrc <> 0.
    RAISE no_history_found.
  ENDIF.

*Sort the table to get latest history first
  SORT lt_vlchistory BY tstmp DESCENDING.

*we need to move two step back to get old status

*  IF iv_action_performed EQ lc_action_qain OR iv_action_performed EQ lc_action_qapc.
*    lv_count = 2.
*  ENDIF.
*
*  LOOP AT lt_vlchistory INTO ls_vlchistory.
*    IF iv_action_performed EQ lc_action_qain.
**Action performed to post the cost
*      IF ls_vlchistory-action EQ lc_action_qagr.
*        lv_count = lv_count - 1.
*      ELSEIF ls_vlchistory-action EQ lc_action_qapo.
*        lv_count = lv_count - 1.
*      ENDIF.
*    ELSEIF iv_action_performed EQ lc_action_qapc.
**Action performed to cancel the cost
*      IF ls_vlchistory-action EQ lc_action_qagc.
*        lv_count = lv_count - 1.
*      ELSEIF ls_vlchistory-action EQ lc_action_qaic.
*        lv_count = lv_count - 1.
*      ENDIF.
*    ENDIF.
*    IF lv_count EQ 0.
*      ev_next_status = ls_vlchistory-mmsta_old.
*      EXIT.
*    ENDIF.
*  ENDLOOP.
*
*  IF ev_next_status IS INITIAL.
*    RAISE failed_to_determined.
*  ENDIF.

  LOOP AT lt_vlchistory INTO ls_vlchistory.
    LOOP AT it_possible_status INTO lv_status.
      IF ls_vlchistory-mmsta_old EQ lv_status.
        ev_next_status = ls_vlchistory-mmsta_old.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFUNCTION.

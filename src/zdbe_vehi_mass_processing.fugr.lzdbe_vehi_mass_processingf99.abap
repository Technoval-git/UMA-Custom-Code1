*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF99 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UPDATE_VEHICLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_vehicles USING  lt_vlcdiavehi TYPE vlcdiavehi_t
                            lt_vlcstatus TYPE vlcstatus_t
                            ls_incoming_action TYPE vlcc_cvlc03_ps
                            ls_elementary_action TYPE vlcc_cvlc03_ps
                            vlcactdata_cs TYPE vlcactdata.
  DATA : ls_vladiavehi   TYPE vlcdiavehi .
  DATA : newtsp_lv       TYPE vlc_ltstamp.
  DATA : ct_vlch_mssg    TYPE vlch_mssg_pt.
  FIELD-SYMBOLS <ls_vlcdiavehi>  TYPE vlcdiavehi.

  LOOP AT lt_vlcdiavehi ASSIGNING <ls_vlcdiavehi>.
* Same time stamp for all vehciles
    CALL FUNCTION 'VELO03_GET_LONG_TIMESTAMP'
      IMPORTING
        long_timestamp_ev = newtsp_lv.

    <ls_vlcdiavehi>-newtsp = newtsp_lv.
  ENDLOOP.


  CALL FUNCTION 'VELO09_SET_LOC_AVAIL_STIME'
    TABLES
      vlcdiavehi_ct      = lt_ok_vlcdiavehi
      vlcstatus_it       = lt_vlcstatus
      vlch_mssg_ct       = ct_vlch_mssg
    EXCEPTIONS
      internal_error     = 1
      update_error       = 2
      debitor_not_found  = 3
      kreditor_not_found = 4
      calendar_error     = 5
      OTHERS             = 6.

  IF sy-subrc <> 0.
*--> error occured!! set the rollback-flag
    RAISE action_not_performed.
*    The error message(s) are written into VLCH_MSSG_ct by the
*    function module
  ENDIF.

  CALL FUNCTION 'VELO09_UPDATE_VH_STATUS'
    EXPORTING
      action_is          = ls_elementary_action
    TABLES
      vlcdiavehi_ct      = lt_vlcdiavehi
*     vlcstatus_it       = vlcstatus_it
      vlcstatus_it       = lt_vlcstatus
      vlch_mssg_ct       = ct_vlch_mssg
    EXCEPTIONS
      status_not_updated = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
*--> error occured!! set the rollback-flag
    RAISE action_not_performed.
*    The error message(s) are written into VLCH_MSSG_ct by the
*    function module
  ENDIF.
*** sixth step: update history

  CALL FUNCTION 'VELO09_SET_HISTORY'
    EXPORTING
      incoming_action_is   = ls_incoming_action
      elementary_action_is = ls_elementary_action
      vlcactdata_is        = vlcactdata_cs
    TABLES
      vlcdiavehi_ct        = lt_vlcdiavehi
*     vlcstatus_it         = vlcstatus_it
      vlcstatus_it         = lt_vlcstatus
      vlch_mssg_ct         = ct_vlch_mssg
    EXCEPTIONS
      no_history           = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
*--> error occured!! set the rollback-flag
    RAISE action_not_performed.
*    The error message(s) are written into VLCH_MSSG_ct by the
*    function module
  ENDIF.

  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " UPDATE_VEHICLES

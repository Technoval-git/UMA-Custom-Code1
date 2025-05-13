FUNCTION zdbe_vm13_qcio_prepare.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_XINTERLINKED) LIKE  CVLC03-INTRLK OPTIONAL
*"     REFERENCE(IV_XCALLEDBYEXECUTE) TYPE  VLC_XCALLEDBYEXECUTE
*"       OPTIONAL
*"     REFERENCE(IS_INCOMING_ACTION) TYPE  CVLC03 OPTIONAL
*"     REFERENCE(IS_ELEMENTARY_ACTION) TYPE  CVLC03 OPTIONAL
*"  EXPORTING
*"     VALUE(EV_AUART) TYPE  /DBE/CTRL_VALUE
*"  TABLES
*"      IT_VLCDIAVEHI STRUCTURE  VLCDIAVEHI OPTIONAL
*"  CHANGING
*"     REFERENCE(CS_VLCACTDATA) TYPE  VLCACTDATA
*"  EXCEPTIONS
*"      MISSING_CUSTOMIZING
*"      ACTION_PREPARE_NOT_PERFORMED
*"----------------------------------------------------------------------

  DATA: lv_value_act_vhtra_plt TYPE /dbe/ctrl_value,
        lv_value_act_vhtra_cmp TYPE /dbe/ctrl_value,
        lv_act_action          TYPE  vlc_action,
        lt_action              TYPE TABLE OF cvlc03,
        ls_action              LIKE LINE OF lt_action,
        ls_vlcdiavehi          LIKE vlcdiavehi,
        ls_sel_action          TYPE  cvlc03,
        ls_cvlc03              LIKE  cvlc03.
  STATICS: is_qvtp_call TYPE flag.

** --> control data is derived
*  CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
*    EXPORTING
*      object               = gc_auart_co
*    IMPORTING
*      value                = ev_auart
*    EXCEPTIONS
*      object_not_defined   = 1
*      value_not_maintained = 2
*      OTHERS               = 3.
*
*  IF sy-subrc <> 0 OR ev_auart IS INITIAL.
*    MESSAGE e020(/DBE/vehicle_master) RAISING missing_customizing.
*  ENDIF.

* default sy-datum values into posting and document date
  IF iv_xcalledbyexecute IS INITIAL.
    cs_vlcactdata-bldat = sy-datlo.                         "N:1895307
    cs_vlcactdata-budat = sy-datlo.                         "N:1895307
  ENDIF.

* checks for interlinked action QVTP. These checks only
* should be done if QCIO is the first action in the interlinked action.
* So if not we will give an error message
*  CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
*    EXPORTING
*      object               = gc_ini_act_vhtra_plt
*    IMPORTING
*      value                = lv_value_act_vhtra_plt
*    EXCEPTIONS
*      object_not_defined   = 1
*      value_not_maintained = 2
*      OTHERS               = 3.
*  IF sy-subrc <> 0.                                         "#EC *
*  ENDIF.

*  IF is_qvtp_call = 'X'.                                  "1713006
  READ TABLE it_vlcdiavehi INTO ls_vlcdiavehi INDEX 1.
  CALL FUNCTION 'ZVSS_VM13_QVTP_CHECKS'
    EXPORTING
      is_vlcactdata = cs_vlcactdata
      is_vlcdiavehi = ls_vlcdiavehi
    EXCEPTIONS
      OTHERS        = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING action_prepare_not_performed.
  ENDIF.
*  ENDIF.

  IF lv_value_act_vhtra_plt = is_incoming_action-aktion.
    IF NOT is_incoming_action-intrlk IS INITIAL.
      CALL FUNCTION 'VELO14_READ_CVLC03I'
        EXPORTING
          action_iv                     = is_incoming_action-aktion
        TABLES
          cvlc03_et                     = lt_action
        EXCEPTIONS
          no_entry_found                = 1
          elementary_action_not_defined = 2
          OTHERS                        = 3.
      IF sy-subrc <> 0.
        RAISE action_prepare_not_performed.
      ENDIF.

      IF NOT lt_action[] IS INITIAL.
        READ TABLE lt_action INTO ls_action INDEX 1.
        IF ls_action-aktion = is_elementary_action-aktion.
          READ TABLE it_vlcdiavehi INTO ls_vlcdiavehi INDEX 1.

          IF lv_value_act_vhtra_plt = is_incoming_action-aktion.
            is_qvtp_call = 'X'.
            CALL FUNCTION '/DBE/VM13_QVTP_CHECKS'
              EXPORTING
                is_vlcactdata = cs_vlcactdata
                is_vlcdiavehi = ls_vlcdiavehi
              EXCEPTIONS
                OTHERS        = 1.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING action_prepare_not_performed.
            ENDIF.

          ENDIF.
        ELSE.
*       in this case the action QCIO is not the first action
          MESSAGE e262(/dbe/vehicle_master)
                      WITH     is_elementary_action-aktion
                               is_incoming_action-aktion
                      RAISING  action_prepare_not_performed.

        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR is_qvtp_call.
  ENDIF.

ENDFUNCTION.

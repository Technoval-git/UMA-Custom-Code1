FUNCTION ZDBE_VMASS_VARIANT_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"--------------------------------------------------------------------
  DATA: lt_usparam    TYPE TABLE OF usparam.
  DATA: lt_svariant   TYPE TABLE OF /DBE/vm_svariant.
  DATA: lt_svartxt    TYPE TABLE OF /DBE/vm_svartxt.
  DATA: lt_svcrit     TYPE TABLE OF /DBE/vm_svcrit.
  DATA: lt_svval      TYPE TABLE OF /DBE/vm_svval.

  lt_usparam[] = gt_mass_usparam[].

  CALL FUNCTION '/DBE/VMASS_PARAMETERID_SAVE' "IN UPDATE TASK
    EXPORTING
      iv_uname = sy-uname
    TABLES
      it_usparam = lt_usparam.


  lt_svariant[]   = gt_mass_svariant_buf[].
  lt_svartxt[]    = gt_mass_svartxt_buf[].
  lt_svcrit[]     = gt_mass_user_svcrit_buf[].
  lt_svval[]      = gt_mass_user_svval_buf[].

  CALL FUNCTION 'ENQUEUE_/DBE/EV_MSVARIAN'
    EXPORTING
      mode_/DBE/vm_svariant = 'E'
      mandt                 = sy-mandt
      uname                 = sy-uname
      x_uname               = ' '
      _scope                = '2'
      _wait                 = ' '
      _collect              = ' '
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CALL FUNCTION '/DBE/VMASS_VARIANT_UPDATE_DB'
    TABLES
      it_svariant = lt_svariant                             "#EC ENHOK
      it_svartxt  = lt_svartxt                              "#EC ENHOK
      it_svcrit   = lt_svcrit                               "#EC ENHOK
      it_svval    = lt_svval.                               "#EC ENHOK

  CALL FUNCTION 'DEQUEUE_/DBE/EV_MSVARIAN'
    EXPORTING
      mode_/DBE/vm_svariant = 'E'
      mandt                 = sy-mandt
      uname                 = ' '
      x_uname               = ' '
      _scope                = '3'
      _synchron             = ' '
      _collect              = ' '.


*message s461(/DBE/VEHICLE_MASTER).
*Wrokarond to suppress the message
message s770(/DBE/vehicle_master).

ENDFUNCTION.

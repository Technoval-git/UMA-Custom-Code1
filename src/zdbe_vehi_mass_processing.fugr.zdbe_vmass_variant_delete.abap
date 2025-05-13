FUNCTION ZDBE_VMASS_VARIANT_DELETE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_SVARIANT_DEL STRUCTURE  /DBE/V_SVARIANT
*"--------------------------------------------------------------------

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


  CALL FUNCTION '/DBE/VMASS_VARIANT_DELETE_DB'
    TABLES
      it_svariant_del = it_svariant_del.

  CALL FUNCTION 'DEQUEUE_/DBE/EV_MSVARIAN'
    EXPORTING
      mode_/DBE/vm_svariant = 'E'
      mandt                 = sy-mandt
      uname                 = ' '
      x_uname               = ' '
      _scope                = '3'
      _synchron             = ' '
      _collect              = ' '.


ENDFUNCTION.

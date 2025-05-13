FUNCTION ZDBE_VMASS_VARIANT_READ_DB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"--------------------------------------------------------------------
  DATA:    lv_alert   TYPE flag.
  DATA:    lv_subrc   TYPE flag.
  STATICS: sv_read    TYPE flag.


* DB is read only once!
  IF sv_read IS INITIAL.

    SELECT * FROM /DBE/vm_svariant APPENDING TABLE gt_mass_svariant_buf WHERE uname = sy-uname.

    lv_subrc = sy-subrc.

    SELECT * FROM /DBE/vm_svartxt APPENDING TABLE gt_mass_svartxt_buf WHERE uname = sy-uname.

* If the return code does not match the previous one,
* the DB tables are not consistent.
    IF sy-subrc NE lv_subrc.
      lv_alert = gc_x.
    ENDIF.
    lv_subrc = sy-subrc.

    SELECT * FROM /DBE/vm_svcrit APPENDING TABLE gt_mass_user_svcrit_buf WHERE uname = sy-uname.

* If the return code does not match the previous one,
* the DB tables are not consistent.
    IF sy-subrc NE lv_subrc.
      lv_alert = gc_x.
    ENDIF.
    lv_subrc = sy-subrc.

    SELECT * FROM /DBE/vm_svval APPENDING TABLE gt_mass_user_svval_buf WHERE uname = sy-uname.

* If the return code does not match the previous one,
* the DB tables are not consistent.
    IF sy-subrc NE lv_subrc.
      lv_alert = gc_x.
    ENDIF.

    IF NOT lv_alert IS INITIAL.
      MESSAGE a003(/DBE/vehicle_master) WITH '/DBE/VMASS_VARIANT_READ_DB'.
    ENDIF.
  ENDIF.

  sv_read = gc_x.

ENDFUNCTION.

FUNCTION ZDBE_VMASS_GET_VARIANT_BUFFER.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_FLAG) TYPE  BOOLEAN OPTIONAL
*"--------------------------------------------------------------------
  "----------------------------------------------------------------------
  "*"Local Interface:
  "  IMPORTING
  "     VALUE(IV_FLAG) TYPE  BOOLEAN OPTIONAL
  "----------------------------------------------------------------------
  DATA: ls_svartxt  TYPE /DBE/vm_svartxt.
  DATA: ls_alv_var  TYPE /DBE/alv_var.

  DATA: ls_svariant TYPE /DBE/vm_svariant.


  gt_mass_svariant[] = gt_mass_svariant_buf[].

  CLEAR gt_mass_svartxt.

  LOOP AT gt_mass_svariant INTO ls_svariant.
    READ TABLE gt_mass_svartxt_buf INTO ls_svartxt WITH KEY svar = ls_svariant-svar spras = sy-langu .
    IF sy-subrc NE 0.
      CLEAR ls_svartxt.
      MOVE-CORRESPONDING ls_svariant TO ls_svartxt.
      ls_svartxt-spras = sy-langu.
    ENDIF.
    INSERT ls_svartxt INTO TABLE gt_mass_svartxt.
  ENDLOOP.


  gt_mass_user_svcrit[] = gt_mass_user_svcrit_buf[].
  gt_mass_user_svval[] = gt_mass_user_svval_buf[].


  GET PARAMETER ID  '/DBE/VM_SVARDEF' FIELD gv_mass_svariant_def.

  CLEAR gt_mass_alv_var.
  LOOP AT gt_mass_svartxt INTO ls_svartxt.
    MOVE-CORRESPONDING ls_svartxt TO ls_alv_var.
    ls_alv_var-orig = ls_svartxt-svar.
    IF ls_svartxt-svar = gv_mass_svariant_def.
      ls_alv_var-def_flag = gv_mass_icon_okay.
    ELSE.
      ls_alv_var-def_flag = gv_mass_icon_cancel.
    ENDIF.
    APPEND ls_alv_var TO gt_mass_alv_var.
    CLEAR ls_alv_var.
  ENDLOOP.

ENDFUNCTION.

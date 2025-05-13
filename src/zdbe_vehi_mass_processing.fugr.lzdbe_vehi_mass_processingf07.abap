*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHECK_MANDATORY_ENTRIES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mandatory_entries INPUT."#EC CALLED

      DATA ls_msg            TYPE bapiret2.
      DATA lv_dummy          TYPE string.


IF gv_ok_code EQ gc_exec_fc.
  CLEAR gt_bapireturn.
  IF vlcactdata_head_s-/dbe/bustype IS INITIAL.
    MESSAGE e043(/DBE/vehicle_master) WITH space INTO lv_dummy.
      ls_msg-type = sy-msgty.
      ls_msg-id = sy-msgid.
      ls_msg-number = sy-msgno.
      APPEND ls_msg TO gt_bapireturn.
  ENDIF.

  IF vlcactdata_item_s-/DBE/spart IS INITIAL.
    MESSAGE e405(/DBE/vehicle_master) INTO lv_dummy.
      ls_msg-type = sy-msgty.
      ls_msg-id = sy-msgid.
      ls_msg-number = sy-msgno.
      APPEND ls_msg TO gt_bapireturn.
  ENDIF.

   IF vlcactdata_head_s-werks IS INITIAL.
    MESSAGE e404(/DBE/vehicle_master) INTO lv_dummy.
      ls_msg-type = sy-msgty.
      ls_msg-id = sy-msgid.
      ls_msg-number = sy-msgno.
      APPEND ls_msg TO gt_bapireturn.
   ENDIF.

   IF /DBE/V_IMODEL-mcodesd IS INITIAL.
     MESSAGE e066(/DBE/vehicle_master) INTO lv_dummy.
      ls_msg-type = sy-msgty.
      ls_msg-id = sy-msgid.
      ls_msg-number = sy-msgno.
      APPEND ls_msg TO gt_bapireturn.
   ENDIF.
ENDIF.
ENDMODULE.                 " CHECK_MANDATORY_ENTRIES  INPUT

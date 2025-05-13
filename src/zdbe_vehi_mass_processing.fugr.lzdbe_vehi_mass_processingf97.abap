*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF97 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ENTRY_EXT_SERVICE_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_entry_ext_service_type .

  DATA:   lt_servtypetxt TYPE /DBE/servtype_tt,
          ls_servtypetxt TYPE /DBE/servtype_t.

*  Read Customizing Entries
  CALL FUNCTION '/DBE/VMASS_READ_SERVTYPE_TEXT'
    EXPORTING
      iv_langu       = sy-langu
    IMPORTING
      et_servtypetxt = lt_servtypetxt.

  READ TABLE lt_servtypetxt INTO ls_servtypetxt WITH KEY
              service_type = vlcactdata_head_s-/DBE/ext_service_type.
  IF sy-subrc <> 0.
    MESSAGE e058(00) WITH vlcactdata_head_s-/DBE/ext_service_type '' '' '/DBE/SERVTYPE'.
  ELSE.
    vlcactdata_item_s-/dbe/ext_service_type_txt = ls_servtypetxt-text .
  ENDIF.

ENDFORM.                    " F_CHECK_ENTRY_EXT_SERVICE_TYPE

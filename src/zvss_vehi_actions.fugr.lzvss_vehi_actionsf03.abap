*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ACTIONSF03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form f_get_default
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_IOBJ_FAMILY
*&      --> LV_VALUE
*&---------------------------------------------------------------------*
FORM F_GET_DEFAULT  USING PV_OBJ_NAME
                          PV_OBJ_VALUE.

  DATA: lv_obj_name TYPE /DBE/CTRL_OBJECT.
  DATA: lv_obj_value TYPE /DBE/CTRL_VALUE.

  lv_obj_name = PV_OBJ_NAME.
  lv_obj_value = PV_OBJ_VALUE.

  CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
    EXPORTING
      OBJECT               = lv_obj_name
    IMPORTING
      VALUE                = lv_obj_value
    EXCEPTIONS
      OBJECT_NOT_DEFINED   = 1
      VALUE_NOT_MAINTAINED = 2
      OTHERS               = 3.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PV_OBJ_VALUE = lv_obj_value.

ENDFORM.                    " F_GET_ACTION

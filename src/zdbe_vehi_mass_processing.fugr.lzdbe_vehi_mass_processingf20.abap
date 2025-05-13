*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF20 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_BUSTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_bustype .                                   "#EC CALLED
  IF vlcactdata_head_s-/dbe/bustype IS INITIAL.
    MESSAGE e043(/dbe/vehicle_master) WITH space.
  ENDIF.

  PERFORM f_check_bustype.
ENDFORM.                    " F_VALIDATE_BUSTYPE

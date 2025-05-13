*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI09 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MOVE_SCREEN_GVAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_SCREEN_GVAR INPUT."#EC CALLED
* Move Category ID from screen to global variable
  gv_iobj_catid = /DBE/vm_fields_crea-category_id.
ENDMODULE.                 " MOVE_SCREEN_GVAR  INPUT

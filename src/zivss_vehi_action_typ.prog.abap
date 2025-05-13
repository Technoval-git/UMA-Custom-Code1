*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_ACTION_TYP
*&---------------------------------------------------------------------*
*Type for screen actions
TYPES: BEGIN OF action_type.
*         include structure CVLC03.
TYPES:  action TYPE cvlc03.
TYPES:  actiont TYPE vlc_actiont.
TYPES:  authority TYPE c.
TYPES:  naventry  TYPE /DBE/naventry,
       END OF action_type.

*Type for search help determination
TYPES: BEGIN OF checktable_type_s,
          checktable     TYPE dd03p-checktable,
          checktab_key   TYPE dfies-fieldname,
          fieldname      TYPE fieldname,
       END OF checktable_type_s.

TYPES: checktable_type_t TYPE STANDARD TABLE OF checktable_type_s.

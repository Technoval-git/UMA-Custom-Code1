FUNCTION-POOL zwty.                         "MESSAGE-ID ..

* INCLUDE LZWTYD...                          " Local class definition
TYPE-POOLS: pwty, wty07.

TABLES: wty_pnh_dynpro,
        wty_pnv_dynpro,
        wty_rcl_stru.

DATA:  gv_mode TYPE c.

********************* PDF-FILE-VIEW

DATA:
  gv_firstcall     TYPE c,
  custom_container TYPE REF TO cl_gui_custom_container,     "#EC NEEDED
  html_control     TYPE REF TO cl_gui_html_viewer,
  url(2000).

DATA: gt_pvwty_dynpro TYPE TABLE OF wty_pv_dynpro,
      gt_pvwty        TYPE wty_pv_dynpro OCCURS 0 WITH HEADER LINE,
      gs_pnwtyv       TYPE wty_pnv_dynpro.
DATA:    gs_pnwtyh       TYPE wty_pnh_dynpro.

DATA:    gv_relob_ext TYPE wty_relob_ext.

DATA     gv_post_fi TYPE flag.


*----------------------------------------------------------------------*
* Constants
*----------------------------------------------------------------------*
CONSTANTS:
* Initial Registration
  gc_init_reg TYPE /dbe/regtype_ui VALUE '01',
  gc_dbm      TYPE wty_relot VALUE 'DBM'.

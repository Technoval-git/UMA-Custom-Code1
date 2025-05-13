class ZCL_BADI_RECA_GUI_TABLE_EXT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_RECA_GUI_TABLE_EXT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BADI_RECA_GUI_TABLE_EXT IMPLEMENTATION.


METHOD if_ex_reca_gui_table_ext~get_extension.

  DATA: ls_extension LIKE LINE OF ct_extension.

  ls_extension-guinameext = 'ZBADI_RECA_GUI_TABLE_EXT'.
  ls_extension-objnameext = 'ZCL_BADI_RECA_GUI_TABLE_EXT'.
  ls_extension-structname = 'ZZSERGE'.

  APPEND ls_extension TO ct_extension.

ENDMETHOD.


METHOD if_ex_reca_gui_table_ext~get_extension_data.

  FIELD-SYMBOLS:  <ls_curr_item> TYPE rebd_obj_assign_bo_l.

  IF sy-tcode = 'RECN' OR sy-tcode = 'REOROF'.

    TRY.
        ASSIGN is_curr_item TO <ls_curr_item> CASTING.
        DATA(lv_newequi) = <ls_curr_item>-objnrtrg+2(18).
        SELECT SINGLE serge FROM equi INTO cs_ext_data WHERE equnr =  lv_newequi.
    CATCH cx_sy_assign_cast_illegal_cast.
    ENDTRY.

  ENDIF.

ENDMETHOD.


METHOD if_ex_reca_gui_table_ext~pai.

* nothing to do

ENDMETHOD.


METHOD if_ex_reca_gui_table_ext~pbo.

*  DATA:
**<<<  BEGIN MODIFY EXAMPLE CODE
*    ls_curr_item TYPE rebd_prop_tax_bu.
*
*  CHECK id_guinameext = 'REPTBU'.
**<<<  END MODIFY EXAMPLE CODE
*
*  ls_curr_item = is_curr_item.
**<<<  BEGIN MODIFY EXAMPLE CODE
*    CALL FUNCTION 'ZREBD_PROP_TAX_BU_EXT'
**<<<  END MODIFY EXAMPLE CODE
*    EXPORTING
*      io_storable_ext = io_storable_ext
*      io_parent       = io_object
*      is_curr_item    = ls_curr_item
*      id_ext_num      = id_guinameext+3
*    IMPORTING
*      ed_caption      = cd_caption
*      es_subscreen    = cs_subscreen.

ENDMETHOD.
ENDCLASS.

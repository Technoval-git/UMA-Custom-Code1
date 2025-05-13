class ZCL_IM_WTY_BAPI_CREATE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_WTY_BAPI_CREATE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_WTY_BAPI_CREATE IMPLEMENTATION.


  METHOD if_ex_wty_bapi_create~bapi_ex_create.
    DATA: ls_header_cust  TYPE wty_pnwtyh_cust,
          ls_version_cust TYPE wty_pnwtyv_cust,
          ls_item_cust    TYPE wty_pvwty_cust,
          ls_pnwtyv       TYPE pnwtyv,
          ls_pvwty        TYPE pvwty,
          ls_extensionin  TYPE bapiparex,
          lt_extensionin  TYPE TABLE OF bapiparex,
          ls_x031l        TYPE x031l,
          lt_x031l        TYPE TABLE OF x031l,
          lv_field(61)    TYPE c,
          ls_handle_guid  TYPE pwty_handle_guid,
          ls_messages     TYPE bapiret2.


    FIELD-SYMBOLS: <field_value> TYPE any.

    CONSTANTS: lc_error1(80) TYPE c VALUE
  'Error during customer field mapping,check BADI impl.WTY_BAPI_CREATE'.
    "#EC
***********************************************************************
* bapiparex usage                                                     *
* STRUCTURE = wty_pnwtyh_cust for customer header fields              *
*           = wty_pnwtyv_cust for customer version fields             *
*           = wty_pvwty_cust  for customer item fields                *
* VALUEPART1 = "fieldname" of wty_..._cust field                      *
* VALUEPART2 = value of field of wty_..._cust field                   *
* VALUEPART3 = handle of object (header, version, item) of            *
* corresponding field                                                 *
***********************************************************************

*** customer fields header ***
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = 'wty_pnwtyh_cust'
      TABLES
        x031l_tab = lt_x031l
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    READ TABLE  it_handle_guid INTO ls_handle_guid
                WITH KEY guid = cs_pnwtyh-pnguid.
    IF sy-subrc <> 0.
      ls_messages-id         = 'WTY'.
      ls_messages-type       = 'E'.
      ls_messages-number     = '001'.
      ls_messages-message    = lc_error1.
      APPEND  ls_messages TO ct_messages.
* error message
      EXIT.
    ENDIF.
    LOOP AT it_extensionin INTO ls_extensionin
                          WHERE valuepart3 = ls_handle_guid-handle.
      READ TABLE lt_x031l INTO ls_x031l
                      WITH KEY fieldname =  ls_extensionin-valuepart1.
      CHECK sy-subrc = 0.
      CONCATENATE 'cs_pnwtyh' '-' ls_x031l-fieldname
      INTO lv_field.
      ASSIGN (lv_field) TO <field_value>.
      CHECK sy-subrc = 0.
      MOVE   ls_extensionin-valuepart2 TO <field_value>.
    ENDLOOP.

*** customer fields version ***
    REFRESH lt_x031l.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = 'wty_pnwtyv_cust'
      TABLES
        x031l_tab = lt_x031l
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    LOOP AT ct_pnwtyv INTO ls_pnwtyv.
      READ TABLE  it_handle_guid INTO ls_handle_guid
                  WITH KEY guid = ls_pnwtyv-pnguid.
      IF sy-subrc <> 0.
        ls_messages-id         = 'WTY'.
        ls_messages-type       = 'E'.
        ls_messages-number     = '001'.
        ls_messages-message    = lc_error1.
        APPEND  ls_messages TO ct_messages.
        EXIT.
      ENDIF.
      LOOP AT it_extensionin INTO ls_extensionin
                            WHERE valuepart3 = ls_handle_guid-handle.
        READ TABLE lt_x031l INTO ls_x031l
                        WITH KEY fieldname =  ls_extensionin-valuepart1.
        CHECK sy-subrc = 0.
        CONCATENATE 'ls_pnwtyv' '-' ls_x031l-fieldname
        INTO lv_field.
        ASSIGN (lv_field) TO <field_value>.
        CHECK sy-subrc = 0.
        MOVE   ls_extensionin-valuepart2 TO <field_value>.
        MODIFY ct_pnwtyv  FROM ls_pnwtyv.
      ENDLOOP.
    ENDLOOP.
*** customer fields item ***
    REFRESH lt_x031l.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = 'wty_pvwty_cust'
      TABLES
        x031l_tab = lt_x031l
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    LOOP AT ct_pvwty INTO ls_pvwty.
      READ TABLE  it_handle_guid INTO ls_handle_guid
                  WITH KEY guid = ls_pvwty-pvguid.
      IF sy-subrc <> 0.
        ls_messages-id         = 'WTY'.
        ls_messages-type       = 'E'.
        ls_messages-number     = '001'.
        ls_messages-message    = lc_error1.
        APPEND  ls_messages TO ct_messages.
        EXIT.
      ENDIF.
      LOOP AT it_extensionin INTO ls_extensionin
                            WHERE valuepart3 = ls_handle_guid-handle.
        READ TABLE lt_x031l INTO ls_x031l
                        WITH KEY fieldname =  ls_extensionin-valuepart1.
        CHECK sy-subrc = 0.
        CONCATENATE 'ls_pvwty' '-' ls_x031l-fieldname
        INTO lv_field.
        ASSIGN (lv_field) TO <field_value>.
        CHECK sy-subrc = 0.
        MOVE   ls_extensionin-valuepart2 TO <field_value>.
        MODIFY ct_pvwty  FROM ls_pvwty.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  method IF_EX_WTY_BAPI_CREATE~BAPI_EX_CREATE_BEFORE_M.
  endmethod.


  method IF_EX_WTY_BAPI_CREATE~BAPI_EX_READ.
  endmethod.
ENDCLASS.

class ZCL_ZPO_DECISION_DPC_EXT definition
  public
  inheriting from ZCL_ZPO_DECISION_DPC
  create public .

public section.
protected section.
METHODS : ZTY_DWI_ENTITYTY_GET_ENTITYSET REDEFINITION,
          zvss_stock_types_get_entityset REDEFINITION,
          zvss_sales_types_get_entityset REDEFINITION.
private section.
ENDCLASS.



CLASS ZCL_ZPO_DECISION_DPC_EXT IMPLEMENTATION.

  METHOD zty_dwi_entityty_get_entityset.
    DATA: lt_list       TYPE STANDARD TABLE OF abaplist.
    "DATA: txtlines TYPE zty_dwi WITH HEADER LINE. "(3000)
    TYPES: BEGIN OF zstring_table,
             string1(300) TYPE c,
           END OF zstring_table.

    FIELD-SYMBOLS: <fs_field> TYPE any.

    DATA : llt_DWI       TYPE TABLE OF zstring_table,
           lt_fields     TYPE TABLE OF string,
           lt_final      TYPE TABLE OF zty_dwi, " Final structured table
           lt_header     TYPE TABLE OF string, " Table to store header fields
           ls_final      TYPE zty_dwi, " Work area for structured data
           lv_line       TYPE string,
           lv_index      TYPE i,
           lv_field_name TYPE string.
    FIELD-SYMBOLS: <lt_data> TYPE table.


    SELECT SINGLE * FROM zsac_var WHERE cprg = 'ZMM_PO_REJ_REASON' INTO  @DATA(ls_Variant).


    IF ls_Variant IS NOT INITIAL.

      " Execute the report and capture output in memory

      SUBMIT zmm_po_rej_reason USING SELECTION-SET ls_Variant-variant
      EXPORTING LIST TO MEMORY
      AND RETURN.

*     select * from ZTABLE_DWI
*    into table  et_entityset.


      CALL FUNCTION 'LIST_FROM_MEMORY'
        TABLES
          listobject = lt_list.

      CALL FUNCTION 'LIST_TO_ASCI'
        TABLES
          listobject         = lt_list
          listasci           = llt_DWI
        EXCEPTIONS
          empty_list         = 1
          list_index_invalid = 2
          OTHERS             = 3.

      CALL FUNCTION 'LIST_FREE_MEMORY'
        TABLES
          listobject = lt_list.


      DELETE llt_DWI INDEX 1. " Remove first separator
      READ TABLE llt_DWI INDEX 1 INTO lv_line. " Read the header row
      DELETE llt_DWI INDEX 1. " Remove header row
      DELETE llt_DWI INDEX 1. " Remove second separator



      CONDENSE lv_line.
      SPLIT lv_line AT '|' INTO TABLE lt_header.
      DELETE lt_header WHERE table_line = space. " Remove empty fields


      LOOP AT lt_header INTO lv_field_name.
        REPLACE ALL OCCURRENCES OF '.' IN lv_field_name WITH ''.
        MODIFY lt_header FROM lv_field_name.
      ENDLOOP.

      LOOP AT lt_header INTO lv_field_name.
        CONDENSE lv_field_name NO-GAPS.
        TRANSLATE lv_field_name TO UPPER CASE.
        "REPLACE ALL OCCURRENCES OF '.' IN lv_field_name WITH ''.
        MODIFY lt_header FROM lv_field_name.
      ENDLOOP.

      LOOP AT llt_DWI INTO lv_line.
        " Trim leading and trailing spaces
        CONDENSE lv_line.

        IF lv_line CO '-'.
          DELETE llt_DWI INDEX sy-tabix.
          CONTINUE.
        ELSE.

          " Split the line into fields
          SPLIT lv_line AT '|' INTO TABLE lt_fields.

          " Remove empty first and last elements caused by leading/trailing '|'
          DELETE lt_fields WHERE table_line = space.

          " Populate structure
          CLEAR ls_final.
          LOOP AT lt_header INTO lv_field_name.
            lv_index = sy-tabix. " Get the current field position

            ASSIGN COMPONENT lv_field_name OF STRUCTURE ls_final TO <fs_field>.
            IF sy-subrc = 0.
              READ TABLE lt_fields INDEX lv_index INTO <fs_field>.
            ENDIF.
          ENDLOOP.

          " Append to final table
          APPEND ls_final TO lt_final.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " Execute the report and capture output in memory


    APPEND LINES OF lt_final TO et_entityset.
    " move-corresponding llt_dwi to et_entityset.


  ENDMETHOD.


  METHOD ZVSS_STOCK_TYPES_GET_ENTITYSET.
       SELECT SINGLE * FROM zsac_var WHERE cprg = 'ZVSS_VEHICLE_STOCK' INTO  @DATA(ls_Variant).


    IF ls_Variant IS NOT INITIAL.

      " Execute the report and capture output in memory

      SUBMIT ZVSS_VEHICLE_STOCK USING SELECTION-SET ls_Variant-variant
      EXPORTING LIST TO MEMORY
      AND RETURN.
   ENDIF.
    select * from ZVSS_STOCK into table et_entityset.

  ENDMETHOD.

  METHOD ZVSS_SALES_TYPES_GET_ENTITYSET.
    SELECT SINGLE * FROM zsac_var WHERE cprg = 'ZVSS_VEHICLE_SALES' INTO  @DATA(ls_Variant).


    IF ls_Variant IS NOT INITIAL.

      " Execute the report and capture output in memory

      SUBMIT ZVSS_VEHICLE_SALES USING SELECTION-SET ls_Variant-variant
      EXPORTING LIST TO MEMORY
      AND RETURN.
   ENDIF.
    select * from ZVSS_SALES into table et_entityset.
  ENDMETHOD.

ENDCLASS.

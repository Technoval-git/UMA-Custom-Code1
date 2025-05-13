FUNCTION yvss_convert_struc_num_to_ar.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(CS_STRUC) TYPE  ANY
*"----------------------------------------------------------------------
  DATA: ls_components TYPE abap_compdescr.
  DATA: lo_strucdescr TYPE REF TO cl_abap_structdescr.
  DATA: lv_str        TYPE string.

  FIELD-SYMBOLS: <fs_value>            TYPE any.
  lo_strucdescr ?= cl_abap_typedescr=>describe_by_data( cs_struc ).

  LOOP AT lo_strucdescr->components INTO ls_components.
    TRY.
        ASSIGN COMPONENT ls_components-name OF STRUCTURE cs_struc TO <fs_value>.
        lv_str = <fs_value>.
        TRANSLATE lv_str USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
        <fs_value> = lv_str.
      CATCH cx_root.

    ENDTRY.
  ENDLOOP.

ENDFUNCTION.

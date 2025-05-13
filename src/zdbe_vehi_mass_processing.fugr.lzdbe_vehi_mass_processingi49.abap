*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI49 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  NUMBER_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE number_check INPUT.

  DATA :ls_screen TYPE dfies,
        lv_tab    TYPE ddobjname,
        lv_field  TYPE fieldname,
        lt_screen TYPE STANDARD TABLE OF dfies.

*  LOOP AT SCREEN  .
*    IF screen-input = '1' AND screen-group1 = gc_ftype_in1
*      AND screen-name = 'VLCACTDATA_HEAD_S-NUMOFVEHI'
*       AND vlcactdata_head_s-numofvehi IS INITIAL.
**       Get shorttext of dynprofield for appropriate error message
*      SPLIT screen-name AT '-' INTO lv_tab lv_field.
*      CALL FUNCTION 'DDIF_FIELDINFO_GET'                    "N:1449767
*        EXPORTING
*          tabname        = lv_tab                           "N:1486828
*          all_types      = 'X'
*        TABLES
*          dfies_tab       = lt_screen
*        EXCEPTIONS
*          not_found      = 1
*          internal_error = 2
*          OTHERS         = 3.
*      IF sy-subrc <> 0 AND lt_screen IS INITIAL.
*        ls_screen-fieldtext = screen-name.
*      ELSE.
*        READ TABLE lt_screen WITH KEY fieldname = lv_field
*                                      langu     = sy-langu
*                                      INTO ls_screen.
*      ENDIF.
*      MESSAGE e001(/DBE/vehicle_master) WITH ls_screen-fieldtext.
*    ENDIF.
*
*  ENDLOOP.
ENDMODULE.                 " NUMBER_CHECK  INPUT

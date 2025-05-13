*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF21 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ENTRY_FIELDS_FILLED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_entry_fields_filled .

  DATA: lv_tab    TYPE ddobjname,
        lv_field  TYPE fieldname,
        lt_screen TYPE STANDARD TABLE OF dfies,
        ls_screen TYPE dfies.

* Content of the input field on the screen
  FIELD-SYMBOLS <input_field> TYPE any.
  CLEAR gv_block_navigation .
*  IF sy-ucomm EQ gc_exec_fc .
  CLEAR  gv_block_navigation.
  LOOP AT SCREEN.
*     Check: Field is an entry field and belongs to group IN1 ?
    IF screen-input = 1 AND ( screen-group1 = gc_ftype_in1 OR screen-required = '2' ).      "as well in case of field requested:recommended N:2711659
      ASSIGN (screen-name) TO <input_field>.
*       Check: Is entry field filled ?
      IF <input_field> IS INITIAL.
*       Get shorttext of dynprofield for appropriate error message
        SPLIT screen-name AT '-' INTO lv_tab lv_field.
        CALL FUNCTION 'DDIF_FIELDINFO_GET'                  "N:1449767
          EXPORTING
            tabname        = lv_tab                         "N:1486828
            all_types      = 'X'
          TABLES
            dfies_tab      = lt_screen
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc <> 0 AND lt_screen IS INITIAL.
          ls_screen-fieldtext = screen-name.
        ELSE.
          READ TABLE lt_screen WITH KEY fieldname = lv_field
                                        langu     = sy-langu
                                        INTO ls_screen.
        ENDIF.

        SET CURSOR FIELD screen-name.
*         Ensure that user is able to fill out the obligatory field
        screen-input = 1.
        MODIFY SCREEN.
        gv_block_navigation = abap_true.
        CLEAR gv_ok_code. " message 0120031469 0000164353 2012 VMA_USA: create vehicles resizing triggers ucomm
        sy-ucomm = gc_error .
        MESSAGE e001(/dbe/vehicle_master) WITH ls_screen-fieldtext.
      ELSE.
        CONTINUE.
      ENDIF.

    ENDIF.
  ENDLOOP.
* ENDIF.
ENDFORM.                    " F_CHECK_ENTRY_FIELDS_FILLED

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO29 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GENERATE_ALVGRID_DEL_ININVOICE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE generate_alvgrid_del_ininvoice OUTPUT.
  DATA :
        custom_container3 TYPE REF TO cl_gui_custom_container,
        cont_on_main3          TYPE scrfname VALUE 'CC_CANCEL_INCOMING_INV',
        gs_layout3             TYPE lvc_s_layo,
        incinvoice_cancel_alvgrid      TYPE REF TO cl_gui_alv_grid.

  CLEAR gt_fieldcatalog.
  CLEAR gs_fieldcat.

  IF custom_container3 IS INITIAL .
* CREATE A CUSTOM CONTAINER CONTROL FOR OUR ALV CONTROL
    CREATE OBJECT custom_container3
      EXPORTING
        container_name              = cont_on_main3
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc NE 0.
* ADD YOUR HANDLING, FOR EXAMPLE
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = sy-repid
          txt2  = sy-subrc
          txt1  = 'THE CONTROL COULD NOT BE CREATED'(510).
    ENDIF.


* CREATE AN INSTANCE OF ALV CONTROL
    CREATE OBJECT incinvoice_cancel_alvgrid
      EXPORTING
        i_parent = custom_container3.

    gs_fieldcat-fieldname   = 'VHCLE'.
    gs_fieldcat-coltext   = 'Int. Veh. No.'(097).
    gs_fieldcat-outputlen = 35.
    gs_fieldcat-col_pos     = 1.
    gs_fieldcat-datatype = 'CHAR' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-fieldname   = 'BUDAT'.
    gs_fieldcat-coltext   = 'Posting Date'(098).
    gs_fieldcat-outputlen = 8.
    gs_fieldcat-col_pos     = 2.
    gs_fieldcat-datatype = 'DATS' .

    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.

    gs_fieldcat-fieldname   = 'STGRD'.
    gs_fieldcat-coltext   = 'Reversal Reason'(099).
    gs_fieldcat-outputlen = 2.
    gs_fieldcat-col_pos     = 3.
    gs_fieldcat-datatype = 'CHAR' .
    APPEND gs_fieldcat TO gt_fieldcatalog.
    CLEAR  gs_fieldcat.



* SET A TITLEBAR FOR THE GRID CONTROL
    gs_layout3-grid_title = 'Cancel Incoming Invoice'(100).

*Optionally register ENTER to raise event DATA_CHANGED.
* (Per default the user may check data by using the check icon).
    CALL METHOD incinvoice_cancel_alvgrid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.
*create the event handler for verifying the input data.
    CREATE OBJECT g_alv_handler.

* register double click handler
    SET HANDLER g_alv_handler->handle_data_changed
           FOR incinvoice_cancel_alvgrid.

    PERFORM prepare_invoice_cancel_info.

    CALL METHOD incinvoice_cancel_alvgrid->set_table_for_first_display
      EXPORTING
*       i_structure_name = 'vlcactdata_head_s'
        is_layout        = gs_layout3
      CHANGING
        it_outtab        = gt_ininvoice_cancel_info
        it_fieldcatalog  = gt_fieldcatalog.

  ENDIF.

ENDMODULE.                 " GENERATE_ALVGRID_DEL_ININVOICE  OUTPUT

*&---------------------------------------------------------------------*
*& Include          ZIVSSLVM07CL1
*&---------------------------------------------------------------------*

CLASS lcl_history_event_receiver DEFINITION.

  PUBLIC SECTION.
    METHODS: show_hist_on_doubleclick
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row.

    METHODS: show_hist_on_hotspotclick
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id.

    METHODS: add_buttons_to_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.

    METHODS: handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.


ENDCLASS.                    "LCL_HISTORY_EVENT_RECEIVER DEFINITION


*---------------------------------------------------------------------*
*       CLASS LCL_HISTORY_EVENT_RECEIVER IMPLEMENTATION
*---------------------------------------------------------------------*
*       show the standard document for the history entry              *
*---------------------------------------------------------------------*
CLASS lcl_history_event_receiver IMPLEMENTATION.

  METHOD show_hist_on_doubleclick.
    PERFORM f_show_standarddocument USING e_row.
  ENDMETHOD.                    "SHOW_HIST_ON_DOUBLECLICK

  METHOD show_hist_on_hotspotclick.
    PERFORM f_show_standarddocument USING e_row_id.
  ENDMETHOD.                    "SHOW_HIST_ON_HOTSPOTCLICK

  METHOD add_buttons_to_toolbar.
    DATA: ls_toolbar  TYPE stb_button.
*--> append a separator to the toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.
*--> append the refresh-button to the toolbar
    CLEAR ls_toolbar.
    MOVE 0 TO ls_toolbar-butn_type.
    MOVE 'REFRESH' TO ls_toolbar-function.
    MOVE icon_refresh TO ls_toolbar-icon.
    MOVE 'Refresh'(047) TO ls_toolbar-quickinfo.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "ADD_BUTTONS_TO_TOOLBAR

  METHOD handle_user_command.
    DATA rcode TYPE i.
    IF e_ucomm = 'REFRESH'.
      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = gc_xxxx_fc
        IMPORTING
          rc       = rcode.
    ENDIF.

  ENDMETHOD.                           "handle_user_command


ENDCLASS.                    "LCL_HISTORY_EVENT_RECEIVER IMPLEMENTATION


*---------------------------------------------------------------------*
*       CLASS LCL_KONFIG_EVENT_RECEIVER DEFINITION
*---------------------------------------------------------------------*
*                                                                     *
*---------------------------------------------------------------------*
CLASS lcl_konfig_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS: add_buttons_to_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.

    METHODS: handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

ENDCLASS.                    "LCL_KONFIG_EVENT_RECEIVER DEFINITION


*---------------------------------------------------------------------*
*       CLASS LCL_KONFIG_EVENT_RECEIVER IMPLEMENTATION
*---------------------------------------------------------------------*
*                                                                     *
*---------------------------------------------------------------------*
CLASS lcl_konfig_event_receiver IMPLEMENTATION.

  METHOD add_buttons_to_toolbar.
    DATA: ls_toolbar  TYPE stb_button.
*--> append a separator to the toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.
*--> append the refresh-button to the toolbar
    CLEAR ls_toolbar.
    MOVE 0 TO ls_toolbar-butn_type.
    MOVE 'REFRESH' TO ls_toolbar-function.
    MOVE icon_refresh TO ls_toolbar-icon.
    MOVE 'Refresh'(047) TO ls_toolbar-quickinfo.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "ADD_BUTTONS_TO_TOOLBAR

  METHOD handle_user_command.
    DATA rcode TYPE i.
    IF e_ucomm = 'REFRESH'.
      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = gc_xxxx_fc
        IMPORTING
          rc       = rcode.
    ENDIF.
  ENDMETHOD.                           "handle_user_command
ENDCLASS.                    "LCL_KONFIG_EVENT_RECEIVER IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_serv_hist_event_receiver DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_serv_hist_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS serv_hist_sel_on_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row.

    METHODS serv_hist_sel_on_hotspot_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id.
    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
    METHODS add_buttons_to_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.
ENDCLASS.                    "lcl_serv_hist_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_serv_hist_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_serv_hist_event_receiver IMPLEMENTATION.
  METHOD serv_hist_sel_on_double_click.
    DATA ls_serv_hist_list TYPE /dbe/s_vm_ui_serv_his.

    READ TABLE gt_serv_hist_list INTO ls_serv_hist_list INDEX e_row.
    IF sy-subrc = 0.
      SET PARAMETER ID '/DBE/ORDER_NUMBER' FIELD ls_serv_hist_list-vbeln.


      AUTHORITY-CHECK OBJECT 'S_TCODE'
               ID 'TCD' FIELD '/DBE/ORDER03'.
      IF sy-subrc <> 0.
        MESSAGE s321(/dbe/service) WITH '/DBE/ORDER03'. "#NOTEXT.
* No Authority for Transaction &1
        EXIT.
      ENDIF.



      AUTHORITY-CHECK OBJECT 'S_TCODE'
               ID 'TCD' FIELD '/DBE/ORDER03'.
      IF sy-subrc <> 0.
        MESSAGE s321(/dbe/service) WITH '/DBE/ORDER03'. "#NOTEXT.
* No Authority for Transaction &1
        EXIT.
      ENDIF.

      CALL TRANSACTION '/DBE/ORDER03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDMETHOD.                    "serv_hist_sel_on_double_click
  METHOD serv_hist_sel_on_hotspot_click.
    DATA ls_serv_hist_list TYPE /dbe/s_vm_ui_serv_his.

    READ TABLE gt_serv_hist_list INTO ls_serv_hist_list INDEX e_row_id.
    IF sy-subrc = 0.
      SET PARAMETER ID '/DBE/ORDER_NUMBER' FIELD ls_serv_hist_list-vbeln.
      TRY.
          CALL TRANSACTION '/DBE/ORDER03' AND SKIP FIRST SCREEN.
        CATCH cx_sy_authorization_error.
          MESSAGE s321(/dbe/service) WITH '/DBE/ORDER03'. "#NOTEXT.
      ENDTRY.
    ENDIF.
  ENDMETHOD.                    "contr_sel_on_hotspot_click
  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'REFRESH'.
*->     refresh service history ALV
        PERFORM refresh_alv.
        CLEAR gv_serv_hist_read.
        REFRESH gt_serv_hist_list.

      WHEN OTHERS.
    ENDCASE.

*-> status icon of tab needs to be refreshed
    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'REFRESH'.
  ENDMETHOD.                    "handle_user_command
  METHOD add_buttons_to_toolbar.
    DATA ls_toolbar TYPE stb_button.

    CLEAR ls_toolbar.
    WRITE icon_refresh AS ICON TO ls_toolbar-icon.
    ls_toolbar-quickinfo = TEXT-047.    "Refresh
    ls_toolbar-function = 'REFRESH'.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "add_buttons_to_toolbar
ENDCLASS.                    "lcl_serv_hist_event_receiver IMPLEMENTATION

*&---------------------------------------------------------------------*
*& Include          ZIVSSLVM07CL3
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class LCL_CHGDOC_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_chgdoc_event_receiver DEFINITION.

  PUBLIC SECTION.
    METHODS:
      show_user_on_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no.

ENDCLASS.               "LCL_CHGDOC_EVENT_RECEIVER

*----------------------------------------------------------------------*
*       CLASS lcl_optionalv_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_chgdoc_event_receiver IMPLEMENTATION.

  METHOD show_user_on_double_click.

    DATA: ls_veh_chgd TYPE /dbe/v_change_doc.

*   Check if double click on the username column
    IF e_column EQ 'USERNAME'.
*     Read the clicked row
      READ TABLE gt_veh_chgd INTO ls_veh_chgd INDEX e_row.
      IF sy-subrc EQ 0.
*       Show the SU01 transaction in disply mode, without first screen
        CALL FUNCTION 'SUSR_SHOW_USER_DETAILS'
          EXPORTING
            bname = ls_veh_chgd-username.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "SHOW_HIST_ON_DOUBLECLICK

ENDCLASS.               "LCL_CHGDOC_EVENT_RECEIVER

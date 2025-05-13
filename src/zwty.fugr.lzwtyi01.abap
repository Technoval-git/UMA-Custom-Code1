*----------------------------------------------------------------------*
***INCLUDE LZWTYI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  FIELD-SYMBOLS: <lo_wty_navtree_cntl> TYPE REF TO cl_wty_navtree_cntl.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'CANCEL' OR 'BACK'.
      IF NOT html_control IS INITIAL.
        CALL METHOD html_control->free.
        FREE html_control.
      ENDIF.
      IF NOT custom_container IS INITIAL.
        CALL METHOD custom_container->free
          EXCEPTIONS
            OTHERS = 1.
      ENDIF.
      CLEAR gv_firstcall.

*     if the warranty transaction is called from an other program,
*     (DBM order, Business Object Builder-SWO1), the navigation tree is
*     still displayed after leaving the warranty transaction
*     nav. tree should be hidden
      ASSIGN ('(SAPLPVSUIWTY)go_wty_navtree_cntl') TO
        <lo_wty_navtree_cntl>.
      IF <lo_wty_navtree_cntl> IS BOUND.
        CALL METHOD <lo_wty_navtree_cntl>->set_visible( '' ).
      ENDIF.
  ENDCASE.

ENDMODULE.

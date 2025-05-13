*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO37 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ACTION_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE action_status OUTPUT.

  gs_button_text-icon_text = gv_action_text.
  gs_button_text-icon_id = '@0V@'.
  gs_button_text-quickinfo = gv_action_text.

  SET PF-STATUS 'ACTIONS'.
  SET TITLEBAR 'ACTION_TITLEBAR' WITH gv_action_text.

ENDMODULE.                 " ACTION_STATUS  OUTPUT

*&---------------------------------------------------------------------*
*& Include          /DBE/LVEHI_MASS_PROCESSINGO56
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module M_PREPARE_RESERV_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE m_prepare_reserv_data OUTPUT.
  PERFORM f_prepare_reserv_action_data USING ok_code gv_action.
  PERFORM f_display_text_editor USING 'RESERV_NOTE'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module m_generate_alv_grid_crt_reserv OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE m_generate_alv_grid_crt_reserv OUTPUT.
  PERFORM f_create_alv_grid_reserv.
ENDMODULE.

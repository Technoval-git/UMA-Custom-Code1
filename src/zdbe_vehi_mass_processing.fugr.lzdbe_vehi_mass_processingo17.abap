*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO17 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_PREPARE_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_prepare_data OUTPUT.


    PERFORM f_default_data .

    PERFORM f_prepare_action_data USING ok_code gv_action .

ENDMODULE.                 " M_PREPARE_DATA  OUTPUT

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI14 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1300 INPUT."#EC CALLED

*  CASE ok_code.
*    WHEN gc_set_action.
*      CLEAR gs_bulk_actions.
*      READ TABLE gt_bulk_actions INTO gs_bulk_actions WITH KEY aktion = gv_action.
*      IF sy-subrc = 0  AND gs_bulk_actions-creaact <> 'X'.
*        IF gt_vsresult_selection IS INITIAL .
*          MESSAGE w402(/DBE/vehicle_master) .
*        ENDIF.
*      ENDIF.
*    WHEN OTHERS.
*  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1300  INPUT

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI10 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_TRANSFER_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_transfer_data INPUT.

*In case error in set method and changing the data on the grid controll
*    IF sy-msgty EQ  gc_a OR
*      sy-msgty EQ gc_e.
**    IF sy-msgty EQ 'A' OR
**    sy-msgty EQ 'E'.
*      PERFORM f_iobj_multi_set.
*    ENDIF.

    PERFORM f_transfer_data.
ENDMODULE.                 " M_TRANSFER_DATA  INPUT

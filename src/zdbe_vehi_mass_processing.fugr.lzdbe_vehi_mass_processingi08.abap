**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGI08 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Module  M_CHECK_ENTRY_FIELDS_FILLED  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE m_check_entry_fields_filled INPUT.
*
**  DATA : wa_gr_create TYPE ty_gr_create.
*
*  IF sy-ucomm EQ 'MASS_FC2' OR  sy-ucomm EQ 'ACT_EXE' .
*    PERFORM f_check_entry_fields_filled.
*  ENDIF.
*
*  IF sy-ucomm NE 'CG_ALL'.
*    LOOP AT gt_gr_create INTO wa_gr_create.
*      IF wa_gr_create-lgort IS INITIAL.
*        MESSAGE e001(/DBE/vehicle_master) WITH 'Storage Location'.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
*ENDMODULE.                 " M_CHECK_ENTRY_FIELDS_FILLED  INPUT

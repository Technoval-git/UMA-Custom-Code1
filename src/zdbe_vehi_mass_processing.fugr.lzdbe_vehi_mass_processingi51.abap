**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGI51 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Module  M_FILL_STORAGE_LOC  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE m_fill_storage_loc INPUT.
*
*  DATA : wa_gr_create TYPE ty_gr_create.
*
**  IF sy-ucomm EQ 'ACT_EXE'.
**    LOOP AT gt_gr_create INTO wa_gr_create.
**      IF wa_gr_create-lgort IS INITIAL.
**        MESSAGE e001(/DBE/vehicle_master) WITH 'Storage Location'.
**      ENDIF.
**    ENDLOOP.
**  ENDIF.
*
*  IF sy-ucomm EQ 'CG_ALL'.
*    IF vlcactdata_head_s-lgort IS INITIAL.
*      MESSAGE e001(/DBE/vehicle_master) WITH 'Storage Location'.
*    ELSE.
*      LOOP AT gt_gr_create INTO wa_gr_create.
*        wa_gr_create-lgort = vlcactdata_head_s-lgort.
*        wa_gr_create-lfsnr = vlcactdata_head_s-lfsnr.
*        wa_gr_create-frbnr = vlcactdata_head_s-frbnr.
*        MODIFY gt_gr_create INDEX sy-tabix FROM wa_gr_create TRANSPORTING lgort lfsnr frbnr.
*      ENDLOOP.
*    ENDIF.
*    CALL METHOD go_gr_create->refresh_table_display.
*  ENDIF.
*
*
*ENDMODULE.                 " M_FILL_STORAGE_LOC  INPUT
*
*
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

*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI52 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_FILL_STORAGE_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_fill_storage_loc INPUT.

  DATA : wa_gr_create TYPE ty_gr_create.

  IF sy-ucomm EQ 'CG_ALL'.
    LOOP AT gt_gr_create INTO wa_gr_create.
      wa_gr_create-lgort = vlcactdata_head_s-lgort.
      wa_gr_create-lfsnr = vlcactdata_head_s-lfsnr.
      wa_gr_create-frbnr = vlcactdata_head_s-frbnr.
      MODIFY gt_gr_create INDEX sy-tabix FROM wa_gr_create
      TRANSPORTING lgort lfsnr frbnr.
    ENDLOOP.
    CALL METHOD go_gr_create->refresh_table_display.
  ENDIF.

ENDMODULE.                 " M_FILL_STORAGE_LOC  INPUT

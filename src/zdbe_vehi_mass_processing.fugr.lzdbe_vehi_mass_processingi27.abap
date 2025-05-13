*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI27 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_TRANSFER_INVOICE_INFO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_transfer_invoice_info INPUT.

*  DATA  : lv_gross_amount  TYPE vlcactdata_head_s-gross_amount,
*          lv_tax_amount  TYPE vlcactdata_head_s-tax_amount.
*  DATA lv_valid TYPE c.
*  IF incinvoice_alvgrid IS BOUND.
*    CALL METHOD incinvoice_alvgrid->check_changed_data
*      IMPORTING
*        e_valid = lv_valid.
*  ENDIF.
*  CALL METHOD incinvoice_alvgrid->refresh_table_display.
*
*  IF sy-subrc <> 0.
**   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
**
**  CASE gv_ok_code.
**    WHEN 'ACT_EXE'.
*      CLEAR : ls_invoice_info.
*      LOOP AT gt_ininvoice_info INTO ls_invoice_info.
**        vlcactdata_head_s-tax_code = ls_invoice_info-tax_code.
*        vlcactdata_head_s-gross_amount = vlcactdata_head_s-gross_amount + ls_invoice_info-gross_amount.
*        vlcactdata_head_s-tax_amount = vlcactdata_head_s-tax_amount + ls_invoice_info-tax_amount.
*      ENDLOOP.
*  ENDCASE.

ENDMODULE.                 " M_TRANSFER_INVOICE_INFO  INPUT

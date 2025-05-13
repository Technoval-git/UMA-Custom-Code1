FUNCTION ZDBE_ORD_SRV_CNT_F4.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------

  DATA lv_kdauf_aufk    TYPE /DBE/cnt_serv_cntrct_number.
  DATA lv_kdpos_aufk    TYPE /DBE/cnt_serv_cntrct_item.
  DATA ls_selopt        LIKE LINE OF shlp-selopt.
  FIELD-SYMBOLS <ls_interface> TYPE ddshiface.
  FIELD-SYMBOLS <field>.

  IF callcontrol-step = 'PRESEL1'.
    READ TABLE shlp-interface ASSIGNING <ls_interface>
                           WITH KEY shlpfield = 'POSNR'.
    IF sy-subrc = 0.
      ls_selopt-shlpname = shlp-shlpname.
      ls_selopt-shlpfield = 'POSNR'.
      ls_selopt-sign = 'I'.
      ls_selopt-option = 'EQ'.
      ls_selopt-low = <ls_interface>-value.
      APPEND ls_selopt TO shlp-selopt.
    ENDIF.

    EXIT.
  ENDIF.

ENDFUNCTION.

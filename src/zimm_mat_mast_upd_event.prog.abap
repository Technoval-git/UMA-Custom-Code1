*&---------------------------------------------------------------------*
*& Include          ZIMM_MAT_MAST_UPD_EVENT
*&---------------------------------------------------------------------*


START-OF-SELECTION.
  DATA gv_uname TYPE sy-uname .
  gv_uname = sy-uname.
  PERFORM f_prepare_loaddata.
  PERFORM f_prepare_data.

AT SELECTION-SCREEN.
  IF sy-ucomm EQ 'TEMPLATE'.
    PERFORM zimm_mat_mast_upld_temp.
  ENDIF.


AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-name = 'rb_pi'.
      screen-input = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


  IF p_sall = abap_true AND p_rb_1 IS INITIAL.
    p_rb_1 = abap_true.
    p_basic = abap_true.
    p_sales = abap_true.
    p_mrp   = abap_true.
    p_purc  =  abap_true.
    p_plant =  abap_true.
    p_acc   =  abap_true.
    p_forcst = abap_true.
  ELSEIF p_usall = abap_true AND p_rb_1 IS NOT INITIAL .
    p_rb_1 = abap_false.
    p_basic = abap_false.
    p_sales = abap_false.
    p_mrp   = abap_false.
    p_purc  =  abap_false.
    p_plant =  abap_false.
    p_acc   =  abap_false.
    p_forcst = abap_false.
  ENDIF.

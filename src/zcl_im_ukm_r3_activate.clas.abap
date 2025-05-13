class ZCL_IM_UKM_R3_ACTIVATE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_UKM_R3_ACTIVATE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_UKM_R3_ACTIVATE IMPLEMENTATION.


  METHOD if_ex_ukm_r3_activate~dcd_active.
    e_dcd_active = 'X'.
  ENDMETHOD.


  METHOD if_ex_ukm_r3_activate~fi_ar_update_mode.
    e_direct_update = 'X'. "necessary to suppress PM from SD
    e_update_fm = ''.
    e_read_view = 'X'. "use FI/AR views and not UKM_ITEM for FI/AR commitments
  ENDMETHOD.


  METHOD if_ex_ukm_r3_activate~get_rfcdest_fscm.
    c_rfcdest = space.
*  this method will decide whether FSCM-CR is local or not

    DATA: l_fill_active            TYPE flag,
          l_check_active           TYPE flag,
          lo_badi_ukm_fill         TYPE REF TO if_ex_ukm_fill,
          lo_badi_ukm_credit_check TYPE REF TO if_ex_ukm_credit_check.

    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = 'UKM_FILL'
        null_instance_accepted = 'X'
      IMPORTING
        act_imp_existing       = l_fill_active
      CHANGING
        instance               = lo_badi_ukm_fill
      EXCEPTIONS
        OTHERS                 = 1.

    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = 'UKM_CREDIT_CHECK'
        null_instance_accepted = 'X'
      IMPORTING
        act_imp_existing       = l_check_active
      CHANGING
        instance               = lo_badi_ukm_credit_check
      EXCEPTIONS
        OTHERS                 = 1.

    IF NOT lo_badi_ukm_fill IS BOUND AND NOT lo_badi_ukm_credit_check IS BOUND
     AND l_fill_active = space AND l_check_active = space.
      c_is_local_interface_used = 'X'.
    ENDIF.
  ENDMETHOD.


  METHOD if_ex_ukm_r3_activate~no_sld.
*    e_no_sld = 'X'.
  ENDMETHOD.


  METHOD if_ex_ukm_r3_activate~set_active.

    e_active_flag = abap_true.
    e_erp2005     = abap_true.

  ENDMETHOD.
ENDCLASS.

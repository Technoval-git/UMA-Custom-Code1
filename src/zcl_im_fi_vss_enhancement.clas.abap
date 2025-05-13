class ZCL_IM_FI_VSS_ENHANCEMENT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_ACC_DOCUMENT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_FI_VSS_ENHANCEMENT IMPLEMENTATION.


  METHOD if_ex_acc_document~change.
  ENDMETHOD.


  METHOD if_ex_acc_document~fill_accit.
    DATA : lv_export(30) TYPE c,
           lv_wp_log     TYPE /dbe/t_wp_log,
           lv_pay_type   TYPE /dbe/t_payment_type.
    IMPORT zcash_desk TO lv_export FROM MEMORY ID 'ZCASH'.
    IF lv_export IS NOT INITIAL.

      SPLIT lv_export AT '-' INTO  lv_wp_log lv_pay_type.
      SELECT SINGLE * FROM /dbe/t_wp_paytyp INTO @DATA(lv_paytyp) WHERE wp_log EQ @lv_wp_log AND
                                                                        payment_type EQ @lv_pay_type AND
                                                                        saknr EQ @c_accit-hkont.
      IF sy-subrc EQ 0.
        SELECT SINGLE * FROM zvss_house_bank INTO @DATA(lv_house_bank) WHERE bukrs EQ @c_accit-bukrs AND
                                                                             wp_log EQ @lv_wp_log AND
                                                                             payment_type EQ @lv_pay_type.
        IF sy-subrc EQ 0.
          c_bapi_accit-bank_id = lv_house_bank-hbkid.
          c_bapi_accit-housebankacctid = lv_house_bank-hktid.
          c_accit-hbkid = lv_house_bank-hbkid.
          c_accit-hktid = lv_house_bank-hktid.
*          c_accit-xref3 = lv_house_bank-spanid.


        ENDIF.

      ENDIF.
*      FREE MEMORY ID 'ZCASH'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

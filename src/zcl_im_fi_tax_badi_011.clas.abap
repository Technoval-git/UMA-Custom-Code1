class ZCL_IM_FI_TAX_BADI_011 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_FI_TAX_BADI_011 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_FI_TAX_BADI_011 IMPLEMENTATION.


  METHOD if_ex_fi_tax_badi_011~append_tax_item.
    DATA lv_glvor TYPE bkpf-glvor.
    DATA lv_bukrs TYPE bkpf-bukrs.
    DATA lv_source_key TYPE edoc_source_key.

***CONCATENATE ch_tax_item-belnr  ch_tax_item-bukrs  ch_tax_item-gjahr  into ch_tax_item-USER_FIELD_1 .
    SELECT SINGLE awkey usnam glvor bukrs FROM bkpf INTO ( ch_tax_item-user_field_1, ch_tax_item-user_field_2 , lv_glvor , lv_bukrs ) WHERE bukrs = ch_tax_item-bukrs AND
                                      belnr = ch_tax_item-belnr AND
                                      gjahr = ch_tax_item-gjahr .

    IF lv_GLVOR  =  'SD00' AND lv_bukrs = '1000'.
      SELECT SINGLE proc_status FROM edocument INTO ch_tax_item-user_field_3 WHERE source_key =  ch_tax_item-user_field_1.


    ELSEIF lv_GLVOR  =  'RFBU' AND lv_bukrs = '1000'.

      CONCATENATE   ch_tax_item-bukrs ch_tax_item-belnr  ch_tax_item-gjahr  INTO lv_source_key .

      SELECT SINGLE  proc_status FROM edocument INTO ch_tax_item-user_field_3 WHERE source_key =  lv_source_key.

    ENDIF.

    CASE ch_tax_item-user_field_3.

      WHEN 'CREATED'.
        ch_tax_item-user_field_3 = 'eDocument Created '.
      WHEN 'CANCELLED'.
        ch_tax_item-user_field_3 = 'eDocument Cancelled '.
      WHEN 'ACCEPTED'.
        ch_tax_item-user_field_3 = 'Accepted by Tax Authority '.
      WHEN 'REJECTED'.
        ch_tax_item-user_field_3 = 'Rejected by Tax Authority'.
      WHEN 'SEND'.
        ch_tax_item-user_field_3 = 'Sent to Interface '.
      WHEN 'SEND_REQ'.
        ch_tax_item-user_field_3 = 'Sending Requested '.
      WHEN 'SENTTOCUST'.
        ch_tax_item-user_field_3 = 'Sent to Customer'.
      WHEN 'CONTINGENC'.
        ch_tax_item-user_field_3 = 'Contingency Enabled'.

    ENDCASE.


  ENDMETHOD.


  method IF_EX_FI_TAX_BADI_011~SET_FLAGS.

    CH_USE_BADI_11 = 'X'.
  endmethod.
ENDCLASS.

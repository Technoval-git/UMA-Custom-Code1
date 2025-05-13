FUNCTION-POOL ZVSS_CASH_RECEIPT.            "MESSAGE-ID ..
 DATA: xscreen(1) TYPE c.
* INCLUDE LZVSS_CASH_RECEIPTD...             " Local class definition
DATA c_msgtype_dp_rec type /DBE/T_TEXT_TYPE value 3.
*INCLUDE rle_delnote_forms.
DATA c_msgtype_receipt type /DBE/T_TEXT_TYPE value 1.
*INCLUDE rle_print_forms.

*&---------------------------------------------------------------------*
*& Report ZFI_VEND_NOTIFICATION_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_vend_notification.
DATA : it_no_open_tab TYPE ztt_ven_blns,
       it_adv_tab     TYPE ztt_ven_blns,
       it_on_acc_tab  TYPE ztt_ven_blns.
DATA : o_days TYPE verzn.
DATA : lv_days TYPE verzn.
DATA : it_duedays TYPE TABLE OF ztb_duedays.
DATA : wa_duedays TYPE ztb_duedays.

zcl_vendor_email_notificat=>norm_open_itms(
  IMPORTING
    et_table = it_no_open_tab
).

zcl_vendor_email_notificat=>advances(
  IMPORTING
    et_table = it_adv_tab
).

zcl_vendor_email_notificat=>on_account_pymnts(
  IMPORTING
    et_table = it_on_acc_tab
).

DATA : itab TYPE ZTT_FI_VEND_USER.
SELECT  *
      FROM ZFI_VEND_USER
      INTO TABLE itab
        WHERE zfi_normal_invoices <> ' ' OR zfi_onaccountpayments <> ' ' OR  zfi_advances <> ' '.
*
**BREAK-POINT.

zcl_vendor_email_notificat=>email1(
  EXPORTING
    it_norm_tab  = it_no_open_tab
    it_adv_tab   = it_adv_tab
    it_onacc_tab = it_on_acc_tab
  CHANGING
    im_usr_table = itab
).

*BREAK-POINT.

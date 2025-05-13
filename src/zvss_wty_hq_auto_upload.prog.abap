*&---------------------------------------------------------------------*
*& Report ZVSS_WTY_HQ_AUTO_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_wty_hq_auto_upload.

INCLUDE zivss_wty_hq_a_upl_top.
INCLUDE zivss_wty_hq_a_upl_sel.
INCLUDE zivss_wty_hq_a_upl_frm.

START-OF-SELECTION.

  PERFORM process_claim.

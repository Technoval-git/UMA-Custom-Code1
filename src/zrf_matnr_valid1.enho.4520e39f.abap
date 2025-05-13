"Name: \FU:/SCWM/RF_PICK_MATID_CHECK\SE:END\EI
ENHANCEMENT 0 ZRF_MATNR_VALID1.


CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
  EXPORTING
    input  = ordim_confirm-matid_verif
  IMPORTING
    output = ordim_confirm-matid_verif.
IF ordim_confirm-matid_verif+0(2) NE ls_mat_global-matnr+0(2).
  CONCATENATE ls_mat_global-matnr+0(2) ordim_confirm-matid_verif INTO ordim_confirm-matid_verif.
  IF ordim_confirm-matid_verif = ls_mat_global-matnr.
    MODIFY tt_ordim_confirm FROM ordim_confirm INDEX lv_line
         TRANSPORTING matid_verif.
    ev_flg_verified = /scmb/cl_c=>boole_true.
  ENDIF.
ENDIF.

ENDENHANCEMENT.

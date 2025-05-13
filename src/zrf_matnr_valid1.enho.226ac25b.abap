"Name: \FU:/SCWM/RF_PICK_MATID_CHECK\SE:BEGIN\EI
ENHANCEMENT 0 ZRF_MATNR_VALID1.
*

   IF iv_flg_verified = /scmb/cl_c=>boole_true.
     ev_flg_verified = /scmb/cl_c=>boole_true.
     EXIT.
   ENDIF.
**
**   IF is_valid_prf-valid_obj = 'MATNR'.
**     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
**       EXPORTING
**         input  = cs_ptwy-matnr_verif
**       IMPORTING
**         output = cs_ptwy-matnr_verif.
**
**   if cs_ptwy-matnr+0(2) NE cs_ptwy-matnr_verif+0(2).
**     CONCATENATE cs_ptwy-matnr+0(2) cs_ptwy-matnr_verif INTO  cs_ptwy-matnr_verif.
**     if cs_ptwy-matnr = cs_ptwy-matnr_verif.
**       ev_flg_verified = 'X'.
**     endif.
**   endif.
**   ENDIF.
ENDENHANCEMENT.

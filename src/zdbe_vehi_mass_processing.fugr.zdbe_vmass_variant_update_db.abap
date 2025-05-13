FUNCTION ZDBE_VMASS_VARIANT_UPDATE_DB.
*"--------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  TABLES
*"      IT_SVARIANT STRUCTURE  /DBE/V_SVARIANT
*"      IT_SVARTXT STRUCTURE  /DBE/V_SVARTXT
*"      IT_SVCRIT STRUCTURE  /DBE/V_SVCRIT
*"      IT_SVVAL STRUCTURE  /DBE/V_SVVAL
*"--------------------------------------------------------------------


  MODIFY /DBE/vm_svariant   FROM TABLE it_svariant.         "#EC ENHOK
  MODIFY /DBE/vm_svartxt    FROM TABLE it_svartxt.          "#EC ENHOK
  MODIFY /DBE/vm_svcrit     FROM TABLE it_svcrit.           "#EC ENHOK
  MODIFY /DBE/vm_svval      FROM TABLE it_svval.            "#EC ENHOK


  " Push the mass action varinats to stock ageing report variants
  CALL FUNCTION '/DBE/VMASS_VAR_TO_STOCK_AGE'
    TABLES
      it_svariant = it_svariant
      it_svartxt  = it_svartxt
      it_svcrit   = it_svcrit
      it_svval    = it_svval.


ENDFUNCTION.

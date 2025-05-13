"Name: \TY:CL_UKM_FACADE_LOCAL_CLIENT\ME:CR_IS_LOCAL\SE:END\EI
ENHANCEMENT 0 ZVSS_CREDIT_LOCAL.
        DATA : lv_credit TYPE c.
        IMPORT lv_credit = lv_credit FROM MEMORY ID 'ZCREDIT'.
        IF lv_credit EQ 'X'.
          CLEAR is_local.
          FREE MEMORY ID 'ZCREDIT'.
        ENDIF.

ENDENHANCEMENT.

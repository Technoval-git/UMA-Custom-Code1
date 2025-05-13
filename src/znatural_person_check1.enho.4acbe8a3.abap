"Name: \TY:/DBE/CL_CU_BUSINESS_PARTNER\ME:CREATE_SALES_DATA_FOR_BP\SE:END\EI
ENHANCEMENT 0 ZNATURAL_PERSON_CHECK1.
*
  if is_cu_bp_creation-BP_CAT_PER = 'X'.

   UPDATE but000 SET natpers = 'X'
      WHERE partner = is_cu_bp_creation-bp_partner.

   endif.
ENDENHANCEMENT.

"Name: \FU:BUTX_BUPA_PBC_BUTX01\SE:END\EI
ENHANCEMENT 0 ZNATURAL_PERSON_CHECK.
*
  CALL FUNCTION 'BUP_BUPA_BUT000_GET'
       IMPORTING
           e_but000 = l_but000.
*  IF  g_current_control-aktyp = gc_aktyp_create  AND l_but000-type = gc_type-person .
  IF   l_but000-type = gc_type-person .
    gv_natural_person     = gc_x.
    gv_natural_person_old = gc_x.
    gv_natural_person_check = gc_x.
  ENDIF.
ENDENHANCEMENT.

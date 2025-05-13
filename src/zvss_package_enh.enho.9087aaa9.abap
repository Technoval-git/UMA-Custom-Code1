"Name: \PR:/DBE/SAPLORDER_INT\FO:PACK_RESOLVE_CHECK_DEL_H_LVS\SE:END\EI
ENHANCEMENT 0 ZVSS_PACKAGE_ENH.
DATA : ls_tvarvc TYPE tvarvc.
SELECT SINGLE * FROM tvarvc INTO ls_tvarvc WHERE name EQ 'ADD_LV_TYPE' and low eq is_pack_h-awtyp.
IF sy-subrc eq 0.
  CLEAR cv_remove_header_lvs.
ENDIF.
ENDENHANCEMENT.

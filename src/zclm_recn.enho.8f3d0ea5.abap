"Name: \TY:CL_RECA_TABLE_EXT_HANDLER\IN:IF_RECA_TABLE_EXT_HANDLER\ME:ADAPT_FIELDCATALOG\SE:END\EI
ENHANCEMENT 0 ZCLM_RECN.
*

****  IF sy-tcode = 'RECN' or sy-tcode = 'REOROF'.
****    READ TABLE ct_fieldcatalog ASSIGNING FIELD-SYMBOL(<ls_fieldcatalog2>)
****           WITH KEY FIELDNAME = 'SERGE'."FIELDNAME
****    IF sy-subrc = 0.
****      READ TABLE lt_field_list_excl INTO DATA(s_LT_FIELD_LIST_EXCL)  WITH KEY fieldname = 'SERGE'.
****      IF sy-subrc = 0.
****          MOVE-CORRESPONDING s_LT_FIELD_LIST_EXCL TO <ls_fieldcatalog2>.
****           <ls_fieldcatalog2>-ROLLNAME = ' '.
****           <ls_fieldcatalog2>-tabname = '1'.
*****          ls_fieldcatalog1-col_pos = ls_fieldcatalog1-col_pos + 1.
****           <ls_fieldcatalog2>-tech = ' '.
****           <ls_fieldcatalog2>-no_out = ' '.
****
****      ENDIF.
****    ENDIF.
****  ENDIF.
ENDENHANCEMENT.

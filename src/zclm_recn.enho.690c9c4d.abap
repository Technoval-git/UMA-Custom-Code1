"Name: \TY:CL_RECA_TABLE_EXT_HANDLER\IN:IF_RECA_TABLE_EXT_HANDLER\ME:FILL_EXTENSION_DATA\SE:END\EI
ENHANCEMENT 0 ZCLM_RECN.
*
*  *REBD_OBJ_ASSIGN_BO_L

*  DATA:  lr_data1_ext      TYPE REF TO data.
*  FIELD-SYMBOLS:   <ls_data1_ext> TYPE ANY.
*
*        CREATE DATA lr_data1_ext type rebd_obj_assign_bo_l."(ls_extension-structname).
*        ASSIGN lr_data1_ext->* TO <ls_data1_ext>.
*
*
**ASSIGN COMPONENT 'rebd_obj_assign_bo_l' of STRUCTURE cs_Data to <ls_data1_ext>.
*   MOVE-CORRESPONDING cs_data TO <ls_data1_ext>.
**data(lv_newqui) = <LS_DATA1_EXT>+29(18) .
*data lv_serge type SERGE.
*IF sy-tcode = 'RECN' OR sy-tcode = 'REOROF'.
**  IF <ls_data1_ext>-identtrg = 'EQU'.
**    DATA(lv_string) = <ls_data1_ext>-objnrtrg+2(18).
*    SELECT SINGLE serge FROM equi INTO lv_SERGE WHERE equnr = <LS_DATA1_EXT>+29(18).
*    IF sy-subrc = 0.
*      MOVE-CORRESPONDING <ls_data1_ext> TO cs_data.
*    ENDIF.
**  ENDIF.
*ENDIF.




ENDENHANCEMENT.

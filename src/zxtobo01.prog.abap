*----------------------------------------------------------------------*
***INCLUDE ZXTOBO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
*  DATA(lv_aktyp) = /pacg/cl_rsm_rent_enh=>exit_saplito0_pbo( ).
*  IF lv_aktyp = /pacg/cl_rsm_rent_enh=>mc_act_type-display.
*    LOOP AT SCREEN.
*      screen-input = '0'.
*      MODIFY SCREEN.
*    ENDLOOP.
*  ENDIF.
*
*  IF lv_aktyp = /pacg/cl_rsm_rent_enh=>mc_act_type-change AND
*     /pacg/cl_rsm_rent_enh=>is_veh_created_for_equi( equi-equnr ) EQ 'X'.
*    LOOP AT SCREEN.
*      IF screen-name EQ 'EQUI-/PACG/RSM_ISRENTAL'.
*        screen-input = '0'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo_1000 OUTPUT.

*  CONSTANTS:
*    BEGIN OF lc_activity_type_c,
*      add     TYPE akttyp VALUE 'H',
*      change  TYPE akttyp VALUE 'V',
*      display TYPE akttyp VALUE 'A',
*    END OF lc_activity_type_c.
*
*  DATA:
*    lt_tabstrip_tab TYPE ito0t_tabstrip_tab,
*    ls_attr         TYPE itobattr.
*
*
*  CALL FUNCTION 'ITOB_DATA_EXPORT'
*    IMPORTING
*      e_rec_itobattr = ls_attr
*    TABLES
*      t_tabstrip_tab = lt_tabstrip_tab[].
*
*  IF ls_attr-aktyp = lc_activity_type_c-display.
*    LOOP AT SCREEN.
*      screen-input = '0'.
*      MODIFY SCREEN.
*    ENDLOOP.
*  ENDIF.

  DATA(lv_aktyp) = /pacg/cl_rsm_rent_enh=>exit_saplito0_pbo( ).
  IF lv_aktyp = /pacg/cl_rsm_rent_enh=>mc_act_type-display.
    LOOP AT SCREEN.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF lv_aktyp = /pacg/cl_rsm_rent_enh=>mc_act_type-change." AND
*     /pacg/cl_rsm_rent_enh=>is_veh_created_for_equi( equi-equnr ) EQ 'X'.
    LOOP AT SCREEN.
      IF screen-name EQ 'EQUI-/PACG/RSM_ISRENTAL'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.

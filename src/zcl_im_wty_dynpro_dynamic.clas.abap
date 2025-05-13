class ZCL_IM_WTY_DYNPRO_DYNAMIC definition
  public
  final
  create public .

public section.

  interfaces IF_EX_WTY_DYNPRO_DYNAMIC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_WTY_DYNPRO_DYNAMIC IMPLEMENTATION.


  method IF_EX_WTY_DYNPRO_DYNAMIC~CHANGE_CLAIM_NAVTREE_STRUCTURE.
  endmethod.


  METHOD if_ex_wty_dynpro_dynamic~change_fieldcat_item.
    CALL FUNCTION '/DBE/S_WTY_UE_DYN_DYNA_CH_FCAT'
      EXPORTING
        is_pnh_dynpro = is_pnh_dynpro
        is_pnv_dynpro = is_pnv_dynpro
        it_pvwty_alv  = it_pvwty_alv
      CHANGING
        ct_fieldcat   = ct_fieldcat.
  ENDMETHOD.


  METHOD if_ex_wty_dynpro_dynamic~change_layout_item.
    CALL FUNCTION '/DBE/S_WTY_UE_DYN_DYNA_CH_LAYO'
      EXPORTING
        is_pnh_dynpro = is_pnh_dynpro
        is_pnv_dynpro = is_pnv_dynpro
        is_pvwty_alv  = is_pvwty_alv
      CHANGING
        ct_celltab    = ct_celltab
        ct_color      = ct_color
        cs_linecolor  = cs_linecolor.
  ENDMETHOD.


  METHOD if_ex_wty_dynpro_dynamic~get_related_claims.
    CALL FUNCTION '/DBE/S_WTY_UE_DYN_DYNA_REL_CLA'
      EXPORTING
        is_pnwtyh         = is_pnwtyh
      IMPORTING
        et_pnwtyh         = et_pnwtyh
      CHANGING
        cv_tree_header    = cv_tree_header
      EXCEPTIONS
        no_related_claims = 1
        OTHERS            = 2.
    IF sy-subrc = 0.
      RAISE no_related_claims.
    ENDIF.
  ENDMETHOD.


  METHOD if_ex_wty_dynpro_dynamic~set_screen.
    CALL FUNCTION '/DBE/S_WTY_UE_DYN_DYNA_SET_SCR'
      EXPORTING
        iv_gui_mode      = iv_gui_mode
        is_pnh_dynpro    = is_pnwtyh_dynpro
      CHANGING
        cv_header_screen = cv_header_screen.

    IF is_pnwtyh_dynpro-clmty NE 'ZRCW'.
      cv_header_screen = 1500.
    ENDIF.



  ENDMETHOD.
ENDCLASS.

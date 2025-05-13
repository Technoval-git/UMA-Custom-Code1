class ZCL_IM_FI_TAX_BADI_014 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_FI_TAX_BADI_014 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_FI_TAX_BADI_014 IMPLEMENTATION.


  METHOD if_ex_fi_tax_badi_014~modify_fieldcat.
    DATA: LS_tab_fieldcat TYPE slis_fieldcat_alv.

    READ TABLE ch_tab_fieldcat INTO ls_tab_fieldcat WITH KEY fieldname = 'USER_FIELD_1'.

    IF sy-subrc EQ 0.

      CLEAR ls_tab_fieldcat-no_out.

      ls_tab_fieldcat-seltext_m = 'Referance Key'.

      ls_tab_fieldcat-ref_fieldname = 'USER_FIELD_1'.

      ls_tab_fieldcat-ref_tabname = 'RFUMS_TAX_ITEM'.

      ls_tab_fieldcat-ddictxt  = 'M'.

      MODIFY ch_tab_fieldcat FROM ls_tab_fieldcat TRANSPORTING no_out seltext_m  ref_fieldname ref_tabname ddictxt WHERE fieldname = 'USER_FIELD_1'.

      CLEAR ls_tab_fieldcat.

    ENDIF.




    READ TABLE ch_tab_fieldcat INTO ls_tab_fieldcat WITH KEY fieldname = 'USER_FIELD_2'.

    IF sy-subrc EQ 0.

      CLEAR ls_tab_fieldcat-no_out.

      ls_tab_fieldcat-seltext_m = 'User Name'.

      ls_tab_fieldcat-ref_fieldname = 'USER_FIELD_2'.

      ls_tab_fieldcat-ref_tabname = 'RFUMS_TAX_ITEM'.

      ls_tab_fieldcat-ddictxt  = 'M'.

      MODIFY ch_tab_fieldcat FROM ls_tab_fieldcat TRANSPORTING no_out seltext_m  ref_fieldname ref_tabname ddictxt WHERE fieldname = 'USER_FIELD_2'.

      CLEAR ls_tab_fieldcat.

    ENDIF.


 READ TABLE ch_tab_fieldcat INTO ls_tab_fieldcat WITH KEY fieldname = 'USER_FIELD_3'.

    IF sy-subrc EQ 0.

      CLEAR ls_tab_fieldcat-no_out.

      ls_tab_fieldcat-seltext_m = 'Process Status'.

      ls_tab_fieldcat-ref_fieldname = 'USER_FIELD_3'.

      ls_tab_fieldcat-ref_tabname = 'RFUMS_TAX_ITEM'.

      ls_tab_fieldcat-ddictxt  = 'M'.

      MODIFY ch_tab_fieldcat FROM ls_tab_fieldcat TRANSPORTING no_out seltext_m  ref_fieldname ref_tabname ddictxt WHERE fieldname = 'USER_FIELD_3'.

      CLEAR ls_tab_fieldcat.

    ENDIF.

  ENDMETHOD.
ENDCLASS.

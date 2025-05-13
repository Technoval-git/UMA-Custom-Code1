*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF37 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_LOAD_DEFAULT_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_load_default_variant .

  TYPE-POOLS vrm.

  DATA: lv_svariant      TYPE /DBE/svariant.
  DATA: ls_svartxt       TYPE /DBE/vm_svartxt.
  DATA: ls_varlistitem   TYPE vrm_value.
  DATA: lt_varlist       TYPE vrm_values.
  DATA: ls_dynp          TYPE screen.
  DATA: lv_scrfield      TYPE string.
  DATA: lt_dynp_fields   TYPE TABLE OF rsparams.
  DATA: lt_filter        TYPE badi_filter_bindings.
  DATA: lv_flag          TYPE boolean VALUE 'X'.


  IF gv_prog_name IS INITIAL.
    TRY.
        CALL METHOD cl_enh_badi_runtime_functions=>get_prog_and_dynp_for_subscr
          EXPORTING
            badi_name       = '/DBE/BADI_VMASS_SEARCH_UI'
            calling_dynpro  = gc_first_subscreen_dynpro
            calling_program = gc_mass_main_program
            filter_values   = lt_filter
            subscreen_area  = 'SUBSCREEN1'
          IMPORTING
            called_dynpro   = gv_dynnr_name
            called_program  = gv_prog_name.
      CATCH cx_enh_badi_inconsistent
            cx_enh_badi_no_such_extension
            cx_enh_badi_not_found
            cx_enh_badi_mulitple_impls
            cx_enh_badi_filter_missing.
    ENDTRY.
    IF gv_prog_name EQ gc_badi_program
       OR gv_prog_name = gc_badi_program2.
      gv_prog_name = gc_mass_main_program.
    ELSE.
*   This fm loads the customer screen to the memory
      CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
        EXPORTING
          curr_report     = gv_prog_name
        TABLES
          selection_table = lt_dynp_fields
        EXCEPTIONS
          not_found       = 1
          no_report       = 2
          OTHERS          = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDIF.
*
*  IF gv_prog_name EQ gc_badi_program
*     OR gv_prog_name = gc_badi_program2 .
*    gv_prog_name = gc_mass_main_program.
*  ELSE.
*    gv_prog_name  = gv_badi_program .
*  ENDIF.
*
*  IF gv_prog_name IS NOT INITIAL.
**   This fm loads the customer screen to the memory
*    CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
*      EXPORTING
*        curr_report     = gv_prog_name
*      TABLES
*        selection_table = lt_dynp_fields
*      EXCEPTIONS
*        not_found       = 1
*        no_report       = 2
*        OTHERS          = 3.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*  ENDIF.

  IF gv_mass_icon_okay IS INITIAL.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = icon_okay
*       TEXT                  = ' '
        info                  = 'Default Variant'(dva)
*       ADD_STDINF            = 'X'
      IMPORTING
        result                = gv_mass_icon_okay
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.

    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  IF gv_mass_icon_cancel IS INITIAL.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = icon_cancel
*       TEXT                  = ' '
        info                  = 'Not Default Variant'(ndv)
*       ADD_STDINF            = 'X'
      IMPORTING
        result                = gv_mass_icon_cancel
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.

    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  IF gv_mass_usparam_exists IS INITIAL.
*
    CALL FUNCTION '/DBE/VMASS_USER_PARAMETERS_GET'
      EXPORTING
        iv_parid  = gc_mass_svariant_def
      IMPORTING
        ev_parva  = gv_mass_svariant_def
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    gv_mass_usparam_exists = gc_x.
    lv_svariant = gv_mass_svariant_def.
  ENDIF.

  CALL FUNCTION '/DBE/VMASS_VARIANT_READ_DB'.

  CALL FUNCTION '/DBE/VMASS_GET_VARIANT_BUFFER'.

* Try to get the listbox
  IF <gf_varlistitem_shown> IS NOT ASSIGNED.
    LOOP AT screen INTO ls_dynp.
      IF ls_dynp-name = '/DBE/VM_SVARTXT-SVART'.
        ASSIGN (ls_dynp-name) TO <gf_varlistitem_shown>.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        <gf_varlistitem_shown> = lv_svariant.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF <gf_exact> IS NOT ASSIGNED.
    CONCATENATE '(' gv_prog_name ')' 'EXACT' INTO lv_scrfield.
    ASSIGN (lv_scrfield) TO <gf_exact>.
    IF sy-subrc EQ 0.
* Set exact search mode as default
      <gf_exact> = gc_x.
    ENDIF.
  ENDIF.

*  IF <gf_stockage> IS NOT ASSIGNED.
*    CONCATENATE '(' gv_prog_name ')' 'STOCKAGE' INTO lv_scrfield.
*    ASSIGN (lv_scrfield) TO <gf_stockage>.
*  ENDIF.

  IF NOT <gf_varlistitem_shown> IS INITIAL.
* Check if the variant displayed in the listbox is still valid
    READ TABLE gt_mass_svariant WITH KEY svar = <gf_varlistitem_shown> TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
*     Variant is valid->put its search criteria to the screen
      PERFORM f_clear_fields.
      lv_svariant = <gf_varlistitem_shown>.
      PERFORM f_load_variant USING lv_svariant.
    ELSE.
* Variant name is invalid
      CLEAR <gf_varlistitem_shown>.
    ENDIF.
  ENDIF.

* Assemble listbox entries
  LOOP AT gt_mass_svartxt INTO ls_svartxt.
    ls_varlistitem-key = ls_svartxt-svar.
    ls_varlistitem-text = ls_svartxt-svart.
    APPEND ls_varlistitem TO lt_varlist.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = '/DBE/VM_SVARTXT-SVART'
      values          = lt_varlist
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " F_LOAD_DEFAULT_VARIANT

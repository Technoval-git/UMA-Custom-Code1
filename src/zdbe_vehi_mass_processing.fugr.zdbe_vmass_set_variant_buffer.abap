FUNCTION ZDBE_VMASS_SET_VARIANT_BUFFER.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_VAR_ROW_ID) TYPE  I
*"     VALUE(IV_FLAG) TYPE  BOOLEAN OPTIONAL
*"--------------------------------------------------------------------

*  CONSTANTS: lc_tab_ind_1 TYPE c VALUE '1'.


  DATA: ls_alv_var        TYPE /DBE/alv_var.
  DATA: ls_mass_alv_var        TYPE /DBE/alv_var.
  DATA: ls_svartxt        TYPE /DBE/vm_svartxt.
  DATA: ls_mass_svartxt        TYPE /DBE/vm_svartxt.
  DATA: lt_svartxt        TYPE TABLE OF /DBE/vm_svartxt.
  DATA: lt_mass_svartxt        TYPE TABLE OF /DBE/vm_svartxt.
  DATA: ls_svariant       TYPE /DBE/vm_svariant.
  DATA: ls_mass_svariant       TYPE /DBE/vm_svariant.
  DATA: lt_svariant_del   TYPE TABLE OF /DBE/vm_svariant.
  DATA: lt_mass_svariant_del   TYPE TABLE OF /DBE/vm_svariant.
  DATA: ls_search_crit    TYPE /DBE/veh_searchcrit.
  DATA: ls_mass_search_crit    TYPE /DBE/veh_searchcrit.
  DATA: ls_svcrit         TYPE /DBE/vm_svcrit.
  DATA: ls_mass_svcrit         TYPE /DBE/vm_svcrit.
  DATA: ls_svcrit_prev    TYPE /DBE/vm_svcrit.
  DATA: ls_mass_svcrit_prev    TYPE /DBE/vm_svcrit.
  DATA: ls_svval          TYPE /DBE/vm_svval.
  DATA: ls_mass_svval          TYPE /DBE/vm_svval.
  DATA: lv_index          TYPE i.
  DATA: ls_usparam        TYPE usparam.
  DATA: ls_mass_usparam        TYPE usparam.
  DATA: lt_alv_modrows    TYPE TABLE OF /DBE/alv_var.
  DATA: lt_mass_alv_modrows    TYPE TABLE OF /DBE/alv_var.
  DATA: ls_modrow         TYPE /DBE/alv_var.
  DATA: ls_mass_modrow         TYPE /DBE/alv_var.
  DATA: lv_tabix          TYPE sy-tabix.
  DATA: lt_svariant_cp    TYPE TABLE OF /DBE/vm_svariant.
  DATA: lt_svartxt_cp     TYPE TABLE OF /DBE/vm_svartxt.
  DATA: lt_svcrit_cp      TYPE TABLE OF /DBE/vm_svcrit.
  DATA: lt_svval_cp       TYPE TABLE OF /DBE/vm_svval.

  DATA: lt_mass_svariant_cp    TYPE TABLE OF /DBE/vm_svariant.
  DATA: lt_mass_svartxt_cp     TYPE TABLE OF /DBE/vm_svartxt.
  DATA: lt_mass_svcrit_cp      TYPE TABLE OF /DBE/vm_svcrit.
  DATA: lt_mass_svval_cp       TYPE TABLE OF /DBE/vm_svval.
  DATA: lv_var_row_id     TYPE i.
  DATA: lv_flag TYPE boolean.


* Set new default selection variant if user parameter exists
  IF gv_mass_usparam_exists IS NOT INITIAL.  "AND gv_external_function NE gc_mass_search_fc'.
    SET PARAMETER ID  '/DBE/VM_SVARDEF' FIELD gv_mass_svariant_def.
    ls_mass_usparam-parid = gc_mass_svariant_def.
    ls_mass_usparam-parva = gv_mass_svariant_def.
    ls_mass_usparam-partext = gc_mass_parid_desc.

    MODIFY TABLE gt_mass_usparam FROM ls_mass_usparam.

  ELSEIF gv_external_function = gc_mass_search_fc.
    MESSAGE e048(/DBE/vehicle_master).
  ENDIF.

*  IF iv_flag EQ abap_true.

  lt_alv_modrows[] = gt_mass_alv_var[].
  IF NOT iv_var_row_id IS INITIAL.
    lv_var_row_id = iv_var_row_id.
* The newest entry is not needed as its orig field is empty
    DELETE lt_alv_modrows INDEX lv_var_row_id.
  ENDIF.


* Select variants to delete and to keep
  LOOP AT gt_mass_svariant_buf INTO ls_svariant.
    READ TABLE gt_mass_alv_var WITH KEY svar = ls_svariant-svar INTO ls_alv_var.
    IF sy-subrc NE 0 OR sy-subrc EQ 0 AND lv_var_row_id EQ sy-tabix.
*     Entry was deleted by user and/or a new entry was created with
*     a previously existing key->entry from buffer must be deleted!
      APPEND ls_svariant TO lt_svariant_del.
    ELSEIF sy-subrc EQ 0 AND ls_alv_var-svar EQ ls_alv_var-orig.
*     The key of entry was not changed,though a description update
*     may prove necessary
      MOVE-CORRESPONDING ls_alv_var TO ls_svartxt.
      ls_svartxt-mandt = sy-mandt.
      ls_svartxt-uname = sy-uname.
      ls_svartxt-spras = sy-langu.
      APPEND ls_svartxt TO lt_svartxt.
    ELSE.
*     The key of entry was changed,it must be updated
*     ->original must be deleted
      APPEND ls_svariant TO lt_svariant_del.
    ENDIF.
  ENDLOOP.



* Copy buffer tables to have the original data
* when updating modified entries
  lt_svariant_cp[] = gt_mass_svariant_buf.
  lt_svartxt_cp[] = gt_mass_svartxt_buf.
  lt_svcrit_cp[] = gt_mass_user_svcrit_buf.
  lt_svval_cp[] = gt_mass_user_svval_buf.

* Delete lines from buffer that were selected to delete
  LOOP AT lt_svariant_del INTO ls_svariant.
    DELETE gt_mass_svariant_buf WHERE svar = ls_svariant-svar.
    DELETE gt_mass_svartxt_buf WHERE svar = ls_svariant-svar.
    DELETE gt_mass_user_svcrit_buf WHERE svar = ls_svariant-svar.
    DELETE gt_mass_user_svval_buf WHERE svar = ls_svariant-svar.
  ENDLOOP.

  CALL FUNCTION '/DBE/VMASS_VARIANT_DELETE'
    TABLES
      it_svariant_del = lt_svariant_del. "#EC ENHOK


* Update buffer for rows selected to keep with modified description
  LOOP AT lt_svartxt INTO ls_svartxt.
    MODIFY TABLE gt_mass_svartxt_buf FROM ls_svartxt TRANSPORTING svart.
    IF sy-subrc NE 0.
      INSERT ls_svartxt INTO TABLE gt_mass_svartxt_buf.
    ENDIF.
  ENDLOOP.

* Update buffer for rows selected to keep with modified key
  LOOP AT lt_alv_modrows INTO ls_modrow.
    IF  ls_modrow-svar NE ls_modrow-orig.
*     Only variants with modified key field are handled
      lv_tabix = sy-tabix.
      ls_svariant-mandt = sy-mandt. "In these cases we don't need
      ls_svariant-uname = sy-uname. "to read the buffer table as
      ls_svariant-svar = ls_modrow-svar. "only this field is needed.
*     Insert entry with data from buffer but with modified key
      INSERT ls_svariant INTO TABLE gt_mass_svariant_buf.
      LOOP AT lt_svartxt_cp INTO ls_svartxt WHERE svar = ls_modrow-orig.
*       Read original data from buffer and change the key
        ls_svartxt-svar = ls_modrow-svar.
        IF ls_svartxt-spras EQ sy-langu.
*         If language is the same as the logon language,
*         just change it as user may have done so
          ls_svartxt-svart = ls_modrow-svart.
        ENDIF.
*       Insert entry with data from buffer but with modified key
        INSERT ls_svartxt INTO TABLE gt_mass_svartxt_buf.
      ENDLOOP.
      LOOP AT lt_svcrit_cp INTO ls_svcrit WHERE svar = ls_modrow-orig.
*       Read original data from buffer and change the key
        ls_svcrit-svar = ls_modrow-svar.
*       Insert entry with data from buffer but with modified key
        INSERT ls_svcrit INTO TABLE gt_mass_user_svcrit_buf.
      ENDLOOP.
      LOOP AT lt_svval_cp INTO ls_svval WHERE svar = ls_modrow-orig.
*       Read original data from buffer and change the key
        ls_svval-svar = ls_modrow-svar.
*       Insert entry with data from buffer but with modified key
        INSERT ls_svval INTO TABLE gt_mass_user_svval_buf.
      ENDLOOP.
*     Set the new key as original for the ALV entry
*     as the data has been put to the buffer
      ls_modrow-orig = ls_modrow-svar.
      MODIFY gt_mass_alv_var FROM ls_modrow INDEX lv_tabix.
    ENDIF.
  ENDLOOP.

* If new variant was added, update the criteria tables as well
  IF NOT lv_var_row_id IS INITIAL.
*    IF iv_flag EQ 'TRUE'.
    READ TABLE gt_mass_alv_var INTO ls_alv_var INDEX lv_var_row_id.
*    ELSE.
*      READ TABLE gt_alv_var INTO ls_alv_var INDEX lv_var_row_id.

    IF sy-subrc EQ 0 AND NOT gt_mass_search_crit IS INITIAL.
      <gf_varlistitem_shown> = ls_alv_var-svar.
      MOVE-CORRESPONDING ls_alv_var TO ls_svartxt.
      ls_svartxt-mandt = sy-mandt.
      ls_svartxt-uname = sy-uname.
      ls_svartxt-spras = sy-langu.
      INSERT ls_svartxt INTO TABLE gt_mass_svartxt_buf.
      MOVE-CORRESPONDING ls_svartxt TO ls_svariant.
      INSERT ls_svariant INTO TABLE gt_mass_svariant_buf.
      MOVE-CORRESPONDING ls_svariant TO ls_svcrit.
      LOOP AT gt_mass_search_crit INTO ls_search_crit.
        ls_svcrit-scinterfacefield = ls_search_crit-qual.
        INSERT ls_svcrit INTO TABLE gt_mass_user_svcrit_buf.
        MOVE-CORRESPONDING ls_svcrit TO ls_svval.
        IF ls_svcrit EQ ls_svcrit_prev.
          lv_index = lv_index + 1.
        ELSE.
          lv_index = 1.
        ENDIF.
        ls_svval-svind = lv_index.
        ls_svval-sign = ls_search_crit-sign.
        ls_svval-operator = ls_search_crit-option.
        ls_svval-low = ls_search_crit-low.
        ls_svval-high = ls_search_crit-high.
*        ls_svval-tab_ind = ls_search_crit-tab_ind.
*        IF ls_svval-tab_ind IS INITIAL.
*          ls_svval-tab_ind = lc_tab_ind_1.
*        ENDIF.
        INSERT ls_svval INTO TABLE gt_mass_user_svval_buf.
        ls_svcrit_prev = ls_svcrit.
      ENDLOOP.
*     Add the fields of screen Extended Vehicle Search
      CLEAR: ls_svcrit_prev.
*      LOOP AT gt_ext_search_var_fields INTO ls_search_crit.
*        ls_svcrit-scinterfacefield = ls_search_crit-qual.
*        INSERT ls_svcrit INTO TABLE gt_user_svcrit_buf.
*        MOVE-CORRESPONDING ls_svcrit TO ls_svval.
*        IF ls_svcrit EQ ls_svcrit_prev.
*          lv_index = lv_index + 1.
*        ELSE.
*          lv_index = 1.
*        ENDIF.
*        ls_svval-svind = lv_index.
*        ls_svval-sign = ls_search_crit-sign.
*        ls_svval-operator = ls_search_crit-option.
*        ls_svval-low = ls_search_crit-low.
*        ls_svval-high = ls_search_crit-high.
**        ls_svval-tab_ind = ls_search_crit-tab_ind.
*        INSERT ls_svval INTO TABLE gt_user_svval_buf.
*        ls_svcrit_prev = ls_svcrit.
*      ENDLOOP.
      ls_alv_var-orig = ls_alv_var-svar.
      MODIFY gt_mass_alv_var FROM ls_alv_var INDEX lv_var_row_id.
    ENDIF.
  ENDIF.
  CALL FUNCTION '/DBE/VMASS_VARIANT_SAVE'.


 ENDFUNCTION.

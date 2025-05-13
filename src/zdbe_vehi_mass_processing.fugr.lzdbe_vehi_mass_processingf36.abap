*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF36 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_LOAD_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_SVARIANT  text
*----------------------------------------------------------------------*
FORM f_load_variant  USING lv_svariant TYPE /DBE/svariant.

  DATA: lv_critname   TYPE string.
  DATA: ls_svval      TYPE /DBE/vm_svval.
  DATA: ls_searchcrit TYPE rsdsselopt.
  DATA: lt_searchcrit TYPE TABLE OF rsdsselopt.
  DATA: ls_svcrit     TYPE /DBE/vm_svcrit.
  DATA: descr_ref     TYPE REF TO cl_abap_typedescr.
  DATA: lv_tabix      TYPE sy-tabix.
  DATA: lv_text       TYPE string.
  DATA: ls_optionsearchalv TYPE /DBE/s_veh_alv_option_search.


  FIELD-SYMBOLS: <lv_dynpcrit>       TYPE any,
                 <lv_searchcrit_cp>  TYPE any,
                 <lv_dynpcrit_tab>   TYPE INDEX TABLE.

  CONCATENATE '(' gv_prog_name ')' 'TEXT' INTO lv_text.
  READ TABLE gt_mass_svartxt WITH KEY svar = lv_svariant TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  CLEAR: gv_mass_search_filled, gv_extsearch_filled.

  LOOP AT gt_mass_user_svcrit INTO ls_svcrit WHERE svar = lv_svariant.
    CLEAR ls_searchcrit.
    CLEAR lt_searchcrit.
    LOOP AT gt_mass_user_svval INTO ls_svval WHERE svar = lv_svariant
                          AND     scinterfacefield = ls_svcrit-scinterfacefield.
      CONCATENATE '(' gv_prog_name ')' ls_svval-scinterfacefield '[]' INTO lv_critname.
      ASSIGN (lv_critname) TO <lv_dynpcrit_tab>.
      IF sy-subrc NE 0.
        CONCATENATE '(' gv_prog_name ')' ls_svval-scinterfacefield INTO lv_critname.
        ASSIGN (lv_critname) TO <lv_dynpcrit>.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
      ENDIF.
      IF <lv_dynpcrit_tab> IS ASSIGNED.
        ls_searchcrit-sign = ls_svval-sign.
        ls_searchcrit-option = ls_svval-operator.
        ls_searchcrit-low = ls_svval-low.
        ls_searchcrit-high = ls_svval-high.
        APPEND ls_searchcrit TO lt_searchcrit.
        CONCATENATE '(' gv_prog_name ')' ls_svval-scinterfacefield INTO lv_critname.
        ASSIGN (lv_critname) TO <lv_dynpcrit>.
        descr_ref = cl_abap_typedescr=>describe_by_data( <lv_dynpcrit> ).
        LOOP AT lt_searchcrit INTO ls_searchcrit.
          lv_tabix = sy-tabix.
          ASSIGN ls_searchcrit TO <lv_searchcrit_cp> CASTING TYPE (descr_ref->absolute_name).
          MOVE-CORRESPONDING ls_searchcrit TO <lv_searchcrit_cp>.
          INSERT <lv_searchcrit_cp> INTO TABLE <lv_dynpcrit_tab>.
        ENDLOOP.
        DELETE lt_searchcrit INDEX lv_tabix.
      ELSEIF <lv_dynpcrit> IS ASSIGNED.
        IF lv_critname EQ lv_text
           AND <gf_exact> IS ASSIGNED
           AND <gf_fuzzy> IS ASSIGNED.
          <lv_dynpcrit> = ls_svval-low.
          IF ls_svval-sign EQ 'F'.
            CLEAR <gf_exact>.
            <gf_fuzzy> = gc_x.
          ELSE.
            CLEAR <gf_fuzzy>.
            <gf_exact> = gc_x.
          ENDIF.
          gv_mass_search_filled = gc_x.
        ELSE.
          <lv_dynpcrit> = ls_svval-low.
        ENDIF.
      ENDIF.

      MOVE gc_x TO gv_mass_search_filled.
      UNASSIGN <lv_dynpcrit>.
      UNASSIGN <lv_dynpcrit_tab>.
    ENDLOOP.
  ENDLOOP.

*  PERFORM f_put_data_to_searchcrit. " For screen 1300

* Set tab icons according to search criteria screen is filled or not
  PERFORM f_find_tab_text_set .

ENDFORM.                    " F_LOAD_VARIANT
*&---------------------------------------------------------------------*
*&      Module  M_FIELDS_DETERMINE_BY_BT_TYPE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_fields_determine_by_bt_type OUTPUT.

    PERFORM f_determine_fields_by_bt_type.

ENDMODULE.                 " M_FIELDS_DETERMINE_BY_BT_TYPE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_INITIALIZE_PO_CREA_SCREEN  OUTPUT           N:2773495
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_initialize_po_crea_screen OUTPUT.

  PERFORM f_initialize_po_crea_screen.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      FORM f_initialize_po_crea_screen                      N:2773495
*&---------------------------------------------------------------------*
FORM f_initialize_po_crea_screen.

  DATA lo_factory TYPE REF TO /dbe/cl_veh_md_reader_factory.
  DATA lo_reader  TYPE REF TO /dbe/if_veh_md_reader.
  DATA lo_buskey TYPE REF TO /dbe/cl_veh_md_key_bustype.
  DATA lo_result TYPE REF TO /dbe/if_veh_md_result.
  DATA lo_doctype TYPE REF TO /dbe/cl_veh_md_key_doctype.
  DATA lo_purchorg TYPE REF TO /dbe/cl_veh_md_key_purchorg.
  DATA lo_purchgrp TYPE REF TO /dbe/cl_veh_md_key_purchgrp.
  DATA lo_costcenter TYPE REF TO /dbe/cl_veh_md_key_costcenter.
  DATA lo_vendor TYPE REF TO /dbe/cl_veh_md_key_vendor.
  DATA lo_plant TYPE REF TO /dbe/cl_veh_md_key_plant.
  DATA lv_error_message TYPE string.

* fill out the short texts
  DATA lr_exroot TYPE REF TO cx_root.

* default values if not filled from another source
  IF vlcactdata_head_s-bsart IS INITIAL.
    GET PARAMETER ID 'BSA' FIELD vlcactdata_head_s-bsart.
  ENDIF.

  IF vlcactdata_head_s-ekorg IS INITIAL.
    GET PARAMETER ID 'EKO' FIELD vlcactdata_head_s-ekorg.
  ENDIF.

  IF vlcactdata_head_s-ekgrp IS INITIAL.
    GET PARAMETER ID 'EKG' FIELD vlcactdata_head_s-ekgrp.
  ENDIF.


  TRY.
      lo_factory = /dbe/cl_veh_md_reader_factory=>get_instance( ).
      TRY.
* document type master data reader
          lo_reader = lo_factory->create_reader( 'DOCTYPE' ).
          lo_doctype ?= lo_reader->createkey( ).
          lo_doctype->set_doctype( vlcactdata_head_s-bsart ).
* we are looking for purchase document types only.
          lo_doctype->set_doccategory('F').
          lo_result = lo_reader->read( lo_doctype ).
          t161t-batxt = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t161t-batxt = ''.
      ENDTRY.
      TRY.
* read purchase organization
          lo_reader = lo_factory->create_reader( 'PURCHORG' ).
          lo_purchorg ?= lo_reader->createkey( ).
          lo_purchorg->set_purchorg( vlcactdata_head_s-ekorg ).
          lo_result = lo_reader->read( lo_purchorg ).
          t024e-ekotx = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t024e-ekotx = ''.
      ENDTRY.
      TRY.
* read purchase group
          lo_reader = lo_factory->create_reader( 'PURCHGRP' ).
          lo_purchgrp ?= lo_reader->createkey( ).
          lo_purchgrp->set_purchgrp( vlcactdata_head_s-ekgrp ).
          lo_result = lo_reader->read( lo_purchgrp ).
          t024-eknam = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t024-eknam = ''.
      ENDTRY.
      TRY.
*read cost center
          lo_reader = lo_factory->create_reader( 'COSTCENTER' ).
          lo_costcenter ?= lo_reader->createkey( ).
          lo_costcenter->set_costcenter( vlcactdata_head_s-/dbe/kostl ).
          lo_result = lo_reader->read( lo_costcenter ).
          m_kostn-mctxt = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          m_kostn-mctxt = ''.
      ENDTRY.
      TRY.
* read vendor
          lo_reader = lo_factory->create_reader( 'VENDOR' ).
          lo_vendor ?= lo_reader->createkey( ).
          lo_vendor->set_vendorkey( vlcactdata_head_s-lifnr ).
          lo_result = lo_reader->read( lo_vendor ).
          lfa1-name1 = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          lfa1-name1 = ''.
      ENDTRY.
      TRY.
* read plant
          lo_reader = lo_factory->create_reader( 'PLANT' ).
          lo_plant ?= lo_reader->createkey( ).
          lo_plant->set_plant( vlcactdata_head_s-werks ).
          lo_result = lo_reader->read( lo_plant ).
          t001w-name1 = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          t001w-name1 = ''.
      ENDTRY.
    CATCH cx_root INTO lr_exroot .
      lv_error_message = lr_exroot->if_message~get_longtext( ).
*     if something went wrong during reading short text, the shost text will be empty and error silently
*     dropped becasue it not effecting.
  ENDTRY.

ENDFORM.

class ZCL_IM_MM_INB_PO_DOC_MAP definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_DELIVERY_PROC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_MM_INB_PO_DOC_MAP IMPLEMENTATION.


  method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_HEADER.
  endmethod.


  METHOD if_ex_le_shp_delivery_proc~change_delivery_item.
    "***********************************************************
    "*            BEGIN OF DECLARING LOCAL DATA
    "***********************************************************
    "CONSTANTS:.
    "***********************************************************
    TYPES: BEGIN OF lty_keyval,
             key   TYPE string,
             value TYPE string,
           END OF lty_keyval.
    "***********************************************************
    DATA:
      "-------------------------------------
      "extra request data
      lobj_reg_root   TYPE REF TO lcl_registry_entry,
      lobj_reg_entry  TYPE REF TO lcl_registry_entry,
      lint_extra_data TYPE TABLE OF lty_keyval,
      fs_extra_data   LIKE LINE OF lint_extra_data,
      "-------------------------------------
      wf_mode_create  TYPE abap_bool,
      wf_po_doctype   TYPE bsart.
    "**********************************************************
    FIELD-SYMBOLS:
      <fs_xlikp>     LIKE LINE OF it_xlikp.
    "************ END OF DECLARING LOCAL DATA ******************


    "-----------------------------------------------
    "check if the document type is inbound document
    "-----------------------------------------------
    IF cs_likp-lfart = 'EL'.
      "get document type of PO from PO Header
      SELECT SINGLE bsart INTO wf_po_doctype FROM ekko WHERE ebeln = cs_lips-vgbel.
      IF sy-subrc EQ 0 AND cs_lips-vgbel IS NOT INITIAL.

        TRY .
            lobj_reg_root = lcl_registry_entry=>get_root( ).
            IF lobj_reg_root IS BOUND.
              lobj_reg_entry = lobj_reg_root->get_subentry( 'MM' )->get_subentry( 'Enhancement' )->get_subentry( 'Inbound_Process' )->get_subentry( 'SHP_DELIVERY_PO_DOC_MAP' ).
              IF lobj_reg_entry IS NOT INITIAL.
                lint_extra_data = lobj_reg_entry->get_values( ).

                "check if there is maping for giving document
                READ TABLE lint_extra_data INTO fs_extra_data WITH KEY key = wf_po_doctype.
                IF sy-subrc = 0.
                  cs_lips-pstyv = fs_extra_data-value.
                ENDIF.

              ENDIF.
            ENDIF.

          CATCH cx_root.

        ENDTRY.
      ENDIF.
    ENDIF.
    IF cs_likp-lfart = 'EL'.
      TRY .
          lobj_reg_root = lcl_registry_entry=>get_root( ).
          IF lobj_reg_root IS BOUND.
            lobj_reg_entry = lobj_reg_root->get_subentry( 'MM' )->get_subentry( 'Enhancement' )->get_subentry( 'Inbound_Process' )->get_subentry( 'SHP_DELIVERY_ITCAT_DEL_MAP ' ).
            IF lobj_reg_entry IS NOT INITIAL.
              lint_extra_data = lobj_reg_entry->get_values( ).

              "check if there is maping for giving document
              READ TABLE lint_extra_data INTO fs_extra_data WITH KEY key = cs_lips-lgort.
              IF sy-subrc = 0.
                cs_lips-pstyv = fs_extra_data-value.
              ENDIF.
            ENDIF.

            lobj_reg_entry = lobj_reg_root->get_subentry( 'MM' )->get_subentry( 'Enhancement' )->get_subentry( 'Inbound_Process' )->get_subentry( 'SHP_DELIVERY_PO_DOC_MAP ' ).
            IF lobj_reg_entry IS NOT INITIAL.
              lint_extra_data = lobj_reg_entry->get_values( ).

              "check if there is maping for giving document
              READ TABLE lint_extra_data INTO fs_extra_data WITH KEY key = cs_lips-lgort.
              IF sy-subrc = 0.
                cs_likp-lfart = fs_extra_data-value.
              ENDIF.
            ENDIF.
          ENDIF.
        CATCH cx_root.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FCODE_ATTRIBUTES.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FIELD_ATTRIBUTES.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~CHECK_ITEM_DELETION.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_DELETION.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~DOCUMENT_NUMBER_PUBLISH.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_HEADER.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_ITEM.

  "***********************************************************
  "*            BEGIN OF DECLARING LOCAL DATA
  "***********************************************************
  "CONSTANTS:.
  "***********************************************************
  TYPES: BEGIN OF lty_keyval,
           key   TYPE string,
           value TYPE string,
         END OF lty_keyval.
  "***********************************************************
  DATA:
    "-------------------------------------
    "extra request data
    lobj_reg_root   TYPE REF TO lcl_registry_entry,
    lobj_reg_entry  TYPE REF TO lcl_registry_entry,
    lint_extra_data TYPE TABLE OF lty_keyval,
    fs_extra_data   LIKE LINE OF lint_extra_data,
    "-------------------------------------
    wf_mode_create  TYPE abap_bool,
    wf_po_doctype   TYPE bsart.
  "**********************************************************
*  FIELD-SYMBOLS:
*                 .
  "************ END OF DECLARING LOCAL DATA ******************

  "-----------------------------------------------
  "check if the document type is inbound document
  "-----------------------------------------------
  IF is_likp-lfart = 'EL' .

    "get document type of PO from PO Header
    SELECT SINGLE bsart INTO wf_po_doctype FROM ekko WHERE ebeln = cs_lips-vgbel.
    IF sy-subrc EQ 0 AND cs_lips-vgbel IS NOT INITIAL.

      TRY .
          lobj_reg_root = lcl_registry_entry=>get_root( ).
          IF lobj_reg_root IS BOUND.
            lobj_reg_entry = lobj_reg_root->get_subentry( 'MM' )->get_subentry( 'Enhancement' )->get_subentry( 'Inbound_Process' )->get_subentry( 'SHP_DELIVERY_PO_DOC_MAP' ).
            IF lobj_reg_entry IS NOT INITIAL.
              lint_extra_data = lobj_reg_entry->get_values( ).

              "check if there is maping for giving document
              READ TABLE lint_extra_data INTO fs_extra_data WITH KEY key = wf_po_doctype.
              IF sy-subrc = 0.
                cs_lips-pstyv = fs_extra_data-value.
              ENDIF.

            ENDIF.
          ENDIF.

        CATCH cx_root.

      ENDTRY.
    ENDIF.
  ENDIF.
  IF is_likp-lfart = 'EL'.
    TRY .
        lobj_reg_root = lcl_registry_entry=>get_root( ).
        IF lobj_reg_root IS BOUND.
          lobj_reg_entry = lobj_reg_root->get_subentry( 'MM' )->get_subentry( 'Enhancement' )->get_subentry( 'Inbound_Process' )->get_subentry( 'SHP_DELIVERY_ITCAT_DEL_MAP ' ).
          IF lobj_reg_entry IS NOT INITIAL.
            lint_extra_data = lobj_reg_entry->get_values( ).

            "check if there is maping for giving document
            READ TABLE lint_extra_data INTO fs_extra_data WITH KEY key = cs_lips-lgort.
            IF sy-subrc = 0.
              cs_lips-pstyv = fs_extra_data-value.
            ENDIF.
          ENDIF.
        ENDIF.
      CATCH cx_root.
    ENDTRY.
  ENDIF.

  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~INITIALIZE_DELIVERY.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~ITEM_DELETION.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~PUBLISH_DELIVERY_ITEM.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~READ_DELIVERY.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_BEFORE_OUTPUT.
  endmethod.


  METHOD if_ex_le_shp_delivery_proc~save_and_publish_document.

    IF sy-ucomm = 'WABU_T'.
      DATA: wa_xlips TYPE lips,
            rg_vbeln TYPE likp-vbeln,
            rg_kschl TYPE nase-kschl,
            wa_xlikp TYPE likp.

      READ TABLE it_xlips INTO wa_xlips INDEX 1.
      IF sy-subrc = 0 AND ( wa_xlips-vtweg = '10' OR wa_xlips-vtweg = '20' ).

        READ TABLE it_xlikp INTO wa_xlikp INDEX 1.
        IF sy-subrc = 0 AND wa_xlikp-vkorg = '1020' OR wa_xlikp-vkorg = '1035'.

          " Assign the delivery information to the parameter fields
          MOVE wa_xlikp-vbeln TO rg_vbeln.
          rg_kschl = 'Y002'.  " Delivery output type
          SET PARAMETER ID 'NAC' FIELD rg_kschl.
          SET PARAMETER ID 'VL' FIELD rg_vbeln.

          " Commit work and wait before calling the transaction
          COMMIT WORK AND WAIT.

          " Call transaction VL71 to handle delivery output
          CALL TRANSACTION 'VL71'.

          " Error handling after calling the transaction
          IF sy-subrc NE 0.
            " Handle errors, maybe display a message or leave the screen
            MESSAGE 'Error occurred during transaction VL71' TYPE 'E'.
            LEAVE SCREEN.
          ENDIF.

        ENDIF.

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD if_ex_le_shp_delivery_proc~save_document_prepare.

    DATA : ls_likp1 TYPE likpvb.
    FIELD-SYMBOLS: <ct_xlips> TYPE LINE OF shp_lips_t.
    DATA : lo_order TYPE REF TO /dbe/cl_order.
    DATA: ls_dialog_control     TYPE /dbe/oe_dialog_control.

    DATA: lv_paid  TYPE crmt_boolean,
          lv_dummy TYPE string.

    DATA : ls_log TYPE shp_badi_error_log.

    READ TABLE ct_xlikp INTO ls_likp1 INDEX 1.

    IF sy-ucomm EQ 'WABU_T' AND if_tcode EQ 'VL02N' AND if_trtyp EQ 'V'.
      CHECK ls_likp1-vbtyp  EQ 'J'.

      LOOP AT ct_xlips ASSIGNING <ct_xlips> WHERE vbeln = ls_likp1-vbeln AND
      /dbe/vbeln IS NOT INITIAL.
        EXIT.
      ENDLOOP.
      IF <ct_xlips> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      IF lo_order IS NOT BOUND.
        ls_dialog_control-actvt = /dbe/cl_order_engine=>c_actvt_change.
        CALL FUNCTION '/DBE/OE_MAIN_GET'
          EXPORTING
            iv_vbeln          = <ct_xlips>-/dbe/vbeln
            is_dialog_control = ls_dialog_control
          IMPORTING
            eo_order          = lo_order
          EXCEPTIONS
            internal_error    = 1
            nothing_selected  = 2
            action_error      = 3
            OTHERS            = 4.
        IF sy-subrc <> 0.

          CLEAR lo_order.
        ENDIF.

        IF lo_order IS BOUND.
          IF  lo_order->ms_vbak_com-vtweg EQ '10'.

            SELECT SINGLE * FROM zvss_inv_gm_skip INTO @DATA(ls_valdn_skip)
              WHERE action = 'GDMVT_CREATE'
                AND company = @lo_order->ms_vbak_com-bukrs_vf
                AND plant = @lo_order->ms_vbak_com-werks
                AND dist_chnl = @lo_order->ms_vbak_com-vtweg
                AND ( division = @lo_order->ms_vbak_com-spart
                 OR division = '' ).
            IF sy-subrc = 0.
              IF ls_valdn_skip-user_id = sy-uname.
                RETURN.  "======>> Skip further validations
              ENDIF.
            ENDIF.

            CALL FUNCTION 'ZVSS_PARTS_ORDER_PAYMENT_CHECK'
              EXPORTING
                iv_ord_no = lo_order->ms_vbak_com-vbeln
              IMPORTING
                ev_paid   = lv_paid.

            IF lv_paid <> abap_true.
              MESSAGE e316(ymsg_jet_dbm) INTO lv_dummy.
              ls_log-vbeln =  ls_likp1-vbeln.
              ls_log-msgty = 'E'.
              ls_log-msgid = 'ZMSG_VSS01'.
              ls_log-msgno = '007'.
              APPEND ls_log TO ct_log.
              CLEAR ls_log.
              RETURN.
            ENDIF.

          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

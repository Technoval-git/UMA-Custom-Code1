*&---------------------------------------------------------------------*
*& Include          ZMM_PPC_POOL_LIST_MODULES
*&---------------------------------------------------------------------*
TYPES: tt_eban TYPE TABLE OF ty_eban.
TYPES BEGIN OF ty_purchase_req.
INCLUDE TYPE ty_eban.
TYPES      regio TYPE regio.
TYPES      labst TYPE labst.
TYPES END OF ty_purchase_req.
TYPES tt_purchase_req TYPE TABLE OF ty_purchase_req.

CLASS lcl_event_handler_main DEFINITION.
  PUBLIC SECTION.
    METHODS: hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id   e_column_id  es_row_no.
ENDCLASS.

CLASS lcl_event_handler_sup DEFINITION.
  PUBLIC SECTION.
    METHODS: hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id   e_column_id  es_row_no.
ENDCLASS.

DATA:go_container_main     TYPE REF TO cl_gui_custom_container,
     go_container_sup      TYPE REF TO cl_gui_custom_container,
     go_alv_main           TYPE REF TO cl_gui_alv_grid,
     go_alv_sup            TYPE REF TO cl_gui_alv_grid,
     go_event_handler_main TYPE REF TO lcl_event_handler_main,
     go_event_handler_sup  TYPE REF TO lcl_event_handler_sup.

DATA: gt_eban          TYPE TABLE OF ty_purchase_req WITH HEADER LINE,
      it_fieldcat_main TYPE lvc_t_fcat,
      it_fieldcat_sup  TYPE lvc_t_fcat,
      gt_picpsrl       TYPE TABLE OF v_picpsrl.

DATA: gs_eban TYPE ty_purchase_req
*      gs_po type "Type needed
      .

DATA: gv_description TYPE string.

CLASS lcl_event_handler_main IMPLEMENTATION.
  METHOD hotspot_click.
    DATA: lt_row_no TYPE lvc_t_roid,
          ls_row_no TYPE lvc_s_roid.
    READ TABLE gt_eban INTO gs_eban INDEX e_row_id.
    CASE e_column_id-fieldname.
      WHEN 'BNFPO'.
        CLEAR gt_picpsrl.

        SELECT SINGLE maktx INTO gv_description FROM makt
          WHERE matnr = gs_eban-matnr
          AND spras = sy-langu.

        IF sy-subrc = 0.
          CALL FUNCTION 'PIC01_GET_MEMBER_SINGLE'
            EXPORTING
              i_matnr           = gs_eban-matnr
            TABLES
              et_picpsrl        = gt_picpsrl
            EXCEPTIONS
              notfound_matnr    = 1
              notfound_pic      = 2
              missing_parameter = 3
              OTHERS            = 4.
          PERFORM f_prepare_fcat USING 'V_PICPSRL' CHANGING it_fieldcat_sup.
          go_alv_sup->refresh_table_display( ).
        ENDIF.
      WHEN 'BANFN'.
        SET PARAMETER ID 'BAN' FIELD gs_eban-banfn.
        CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
CLASS lcl_event_handler_sup IMPLEMENTATION.
  METHOD hotspot_click.
    DATA ts_picpsrl TYPE v_picpsrl.

    READ TABLE gt_picpsrl INTO ts_picpsrl INDEX e_row_id-index.
    CASE e_column_id-fieldname.
      WHEN 'MATNR'.
        SET PARAMETER ID 'MAT' FIELD ts_picpsrl-matnr.
        SET PARAMETER ID 'MXX' FIELD 'K' .
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN .
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

MODULE status_1002 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_TABLE1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_tables OUTPUT.
  DATA: ts_fcat TYPE lvc_s_fcat.
  DATA: ts_sort LIKE LINE OF it_sort.
* Create main alv table and container
  IF go_container_main IS INITIAL.
    CREATE OBJECT go_container_main
      EXPORTING
        container_name = 'GC_PR_LIST_CONT'.
  ENDIF.
  IF go_alv_main IS INITIAL.
    CREATE OBJECT go_alv_main
      EXPORTING
        i_parent = go_container_main.
    CREATE OBJECT go_event_handler_main.
    SET HANDLER go_event_handler_main->hotspot_click FOR go_alv_main.
  ENDIF.
* Get PRL table data
  CLEAR gt_eban[].
  PERFORM get_eban_table_data CHANGING gt_eban[].
  DELETE gt_eban WHERE ebeln IS NOT INITIAL.
* Set main table for display
  PERFORM f_prepare_prl_layout.

  CLEAR: ts_fcat,it_fieldcat_main.
  ts_fcat-outputlen = 6.
  ts_fcat-fieldname = 'REGIO'.
  ts_fcat-scrtext_m = 'Region'.
  ts_fcat-col_pos = '0'.
  ts_fcat-emphasize = 'C110'.
  ts_fcat-ref_field = 'REGIO'.
  ts_fcat-ref_table = 'T001W'.
  ts_fcat-f4availabl = abap_true.
  ts_fcat-tabname = 'GT_EBAN'.
  APPEND ts_fcat TO it_fieldcat_main.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 18.
  ts_fcat-fieldname = 'MATNR'.
  ts_fcat-scrtext_m = 'Material'.
  ts_fcat-col_pos = '1'.
  ts_fcat-emphasize = 'C110'.
  ts_fcat-tabname = 'GT_EBAN'.
  ts_fcat-ref_field = 'MATNR'.
  ts_fcat-datatype = 'MATNR'.
  ts_fcat-convexit = 'MATN1'.
  APPEND ts_fcat TO it_fieldcat_main.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 14.
  ts_fcat-fieldname = 'BANFN'.
  ts_fcat-scrtext_m = 'Purchase Req.'.
  ts_fcat-col_pos = '2'.
  ts_fcat-hotspot = abap_true.
  ts_fcat-tabname = 'GT_EBAN'.
  APPEND ts_fcat TO it_fieldcat_main.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 8.
  ts_fcat-fieldname = 'BNFPO'.
  ts_fcat-scrtext_m = 'Item No.'.
  ts_fcat-col_pos = '3'.
  ts_fcat-hotspot = abap_true.
  ts_fcat-tabname = 'GT_EBAN'.
  APPEND ts_fcat TO it_fieldcat_main.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 4.
  ts_fcat-fieldname = 'PO_DOC'.
  ts_fcat-scrtext_m = 'PO doc. type'.
  ts_fcat-ref_field = 'BSART'.
  ts_fcat-ref_table = 'EKKO'.
  ts_fcat-f4availabl = abap_true.
  ts_fcat-col_pos = '4'.
  ts_fcat-tabname = 'GT_EBAN'.
  APPEND ts_fcat TO it_fieldcat_main.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 5.
  ts_fcat-fieldname = 'WERKS'.
  ts_fcat-scrtext_m = 'Plant'.
  ts_fcat-col_pos = '5'.
  ts_fcat-tabname = 'GT_EBAN'.
  ts_fcat-ref_field = 'WERKS'.
  ts_fcat-ref_table = 'T001W'.
  ts_fcat-f4availabl = abap_true.
  APPEND ts_fcat TO it_fieldcat_main.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 13.
  ts_fcat-fieldname = 'MENGE'.
  ts_fcat-scrtext_m = 'Quantity Req.'.
  ts_fcat-col_pos = '6'.
  ts_fcat-tabname = 'GT_EBAN'.
  APPEND ts_fcat TO it_fieldcat_main.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 10.
  ts_fcat-fieldname = 'RSNUM'.
  ts_fcat-scrtext_m = 'Reservation'.
  ts_fcat-col_pos = '7'.
  ts_fcat-tabname = 'GT_EBAN'.
  APPEND ts_fcat TO it_fieldcat_main.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 13.
  ts_fcat-fieldname = 'LABST'.
  ts_fcat-scrtext_m = 'On Hand'.
  ts_fcat-col_pos = '8'.
  ts_fcat-tabname = 'GT_EBAN'.
  APPEND ts_fcat TO it_fieldcat_main.

  CLEAR it_sort.
  ts_sort-fieldname = 'REGIO'.
  ts_sort-up = abap_true.
  APPEND ts_sort TO it_sort.
  ts_sort-fieldname = 'MATNR'.
  APPEND ts_sort TO it_sort.

  go_alv_main->set_table_for_first_display(
  EXPORTING
    is_layout                     = ts_prl_layo
  CHANGING
    it_outtab = gt_eban[]
    it_fieldcatalog = it_fieldcat_main
    it_sort = it_sort
    ).
* Create supersession alv table and container
  IF go_container_sup IS INITIAL.
    CREATE OBJECT go_container_sup
      EXPORTING
        container_name = 'GC_SUPERSESSION_CONT'.
  ENDIF.
  IF go_alv_sup IS INITIAL.
    CREATE OBJECT go_alv_sup
      EXPORTING
        i_parent = go_container_sup.
    CREATE OBJECT go_event_handler_sup.
    SET HANDLER go_event_handler_sup->hotspot_click FOR go_alv_sup.
  ENDIF.

  CLEAR: ts_fcat,it_fieldcat_sup.
  ts_fcat-outputlen = 10.
  ts_fcat-fieldname = 'PICPOS'.
  ts_fcat-scrtext_m = 'PIC No.'.
  ts_fcat-col_pos = '0'.
  ts_fcat-tabname = 'GT_PICPSRL'.
  APPEND ts_fcat TO it_fieldcat_sup.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 20.
  ts_fcat-fieldname = 'MATNR'.
  ts_fcat-scrtext_m = 'Material'.
  ts_fcat-col_pos = '1'.
  ts_fcat-tabname = 'GT_PICPSRL'.
  ts_fcat-convexit = 'MATN1'.
  ts_fcat-hotspot = abap_true.
  APPEND ts_fcat TO it_fieldcat_sup.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 10.
  ts_fcat-fieldname = 'PICNUM'.
  ts_fcat-scrtext_m = 'PIC Grp. No.'.
  ts_fcat-col_pos = '2'.
  ts_fcat-tabname = 'GT_PICPSRL'.
  ts_fcat-ref_field = 'PICNUM'.
  ts_fcat-ref_table = 'V_PICPSRL'.
  ts_fcat-f4availabl = abap_true.
  APPEND ts_fcat TO it_fieldcat_sup.
  CLEAR ts_fcat.
  ts_fcat-outputlen = 10.
  ts_fcat-fieldname = 'PICCAT'.
  ts_fcat-scrtext_m = 'PIC category'.
  ts_fcat-col_pos = '3'.
  ts_fcat-tabname = 'GT_PICPSRL'.
  ts_fcat-ref_field = 'PICCAT'.
  ts_fcat-ref_table = 'V_PICPSRL'.
  ts_fcat-f4availabl = abap_true.
  APPEND ts_fcat TO it_fieldcat_sup.

  go_alv_sup->set_table_for_first_display(
  CHANGING
    it_outtab = gt_picpsrl
    it_fieldcatalog = it_fieldcat_sup
    ).
ENDMODULE.
FORM get_eban_table_data CHANGING it_eban TYPE tt_purchase_req.
  DATA it_eban_c  TYPE TABLE OF eban.
  DATA ts_eban_c  TYPE eban.
  DATA ts_eban    LIKE LINE OF it_eban.
  DATA ts_ekko    LIKE LINE OF it_ekko.
  DATA it_mard TYPE TABLE OF mard.
  DATA ts_mard LIKE LINE OF it_mard.
  DATA it_t001w TYPE TABLE OF t001w.
  DATA ts_t001w LIKE LINE OF it_t001w.

  FIELD-SYMBOLS:<fs_table>  TYPE ANY TABLE.
  CALL FUNCTION 'YDBM_JET_GET_PR_LIST'
    EXPORTING
      it_banfn  = s_banfn[]
      it_ekgrp  = s_ekgrp[]
      it_matnr  = s_matnr[]
      it_maktl  = s_matkl[]
      it_bednr  = s_bednr[]
      it_werks  = s_werks[]
      it_bsart  = s_bsart[]
      it_lfdat  = s_lfdat[]
      it_frgdt  = s_frgdt[]
      it_dispo  = s_dispo[]
      it_statu  = s_statu[]
      it_flief  = s_flief[]
      it_banpr  = s_banpr[]
      it_blckd  = s_blckd[]
      iv_afnam  = p_afnam
      iv_txz01  = p_txz01
      iv_zugba  = p_zugba
      iv_memory = p_memory
      iv_erlba  = p_erlba
      iv_bstba  = p_bstba
      iv_freig  = p_freig
      iv_selgs  = p_selgs
      iv_selpo  = p_selpo
      it_region = s_region[]
    IMPORTING
      et_eban   = it_eban_c.
  IF it_eban_c IS NOT INITIAL.
    SELECT ebeln bsart FROM ekko INTO TABLE it_ekko FOR ALL ENTRIES IN it_eban_c
      WHERE ebeln = it_eban_c-ebeln ORDER BY PRIMARY KEY.

    SELECT * FROM mard INTO TABLE it_mard FOR ALL ENTRIES IN it_eban_c
      WHERE matnr = it_eban_c-matnr AND
            werks = it_eban_c-werks.
    SELECT * FROM t001w INTO TABLE it_t001w FOR ALL ENTRIES IN it_eban_c
      WHERE werks = it_eban_c-werks.
  ENDIF.
  LOOP AT it_eban_c INTO ts_eban_c.
    CLEAR ts_eban.
    MOVE-CORRESPONDING ts_eban_c TO ts_eban.
    ts_eban-pr_type = ts_eban_c-bsart.
    CLEAR ts_ekko.
    READ TABLE it_ekko INTO ts_ekko WITH KEY ebeln = ts_eban-ebeln BINARY SEARCH.
    IF sy-subrc = 0.
      ts_eban-po_doc = ts_ekko-bsart.
    ENDIF.
    READ TABLE it_mard INTO ts_mard WITH KEY matnr = ts_eban_c-matnr werks = ts_eban_c-werks.
    IF sy-subrc = 0.
      ts_eban-labst = ts_mard-labst.
    ENDIF.
    READ TABLE it_t001w INTO ts_t001w WITH KEY werks = ts_eban_c-werks.
    IF sy-subrc = 0.
      ts_eban-regio = ts_t001w-regio.
    ENDIF.
    APPEND ts_eban TO it_eban.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1002 INPUT.
  DATA: ok_code TYPE sy-ucomm.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN 'ACCEPT'.
      PERFORM f_create_po.
    WHEN 'CANCEL'.
      CLEAR: gs_eban,gt_picpsrl,gv_description.
  ENDCASE.
ENDMODULE.
FORM crete_po.
  DATA:it_pr       TYPE Zvss_pr_update_tt,
       ts_pr       LIKE LINE OF it_pr,
       lv_doc_type TYPE bsart,
       lv_tracking TYPE bednr,
       lv_po_no    TYPE ebeln,
       lt_bapiret2 TYPE bapiret2_t.

  MOVE-CORRESPONDING gt_eban TO ts_pr.
  APPEND ts_pr TO it_pr.
  lv_doc_type = gs_eban-po_doc.

  IF it_pr IS NOT INITIAL.
    CALL FUNCTION 'YDBM_CREATE_PO_FROM_PR_FM'
      EXPORTING
        it_pr_items  = it_pr
        iv_doc_type  = lv_doc_type
*       iv_trackingno = lv_tracking
      IMPORTING
        ev_po_number = lv_po_no
        et_return    = lt_bapiret2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  STATUS_1003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1003 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
  SET TITLEBAR '008'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1003 INPUT.
  CASE sy-ucomm.
    WHEN 'FC_CONFIRM'.
      IF gv_cn_po_type IS NOT INITIAL.
        IF gv_cn_reswk IS NOT INITIAL
          OR gv_cn_lifnr IS NOT INITIAL.

          gs_po-po_order_type = gv_cn_po_type.
          gs_po-reswk = gv_cn_reswk.
          gs_po-lifnr = gv_cn_lifnr.
          PERFORM f_create_po.
          CLEAR: gv_cn_po_type, gv_cn_reswk, gv_cn_lifnr.
          LEAVE TO SCREEN 0.
        ELSE.
          MESSAGE s298(ymsg_jet_dbm) DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        MESSAGE s297(ymsg_jet_dbm) DISPLAY LIKE 'E'.
      ENDIF.

    WHEN 'FC_CANCEL' OR 'CANCEL'.
      CLEAR: gs_po.
      CLEAR: gv_cn_po_type, gv_cn_reswk, gv_cn_lifnr.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

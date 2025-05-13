*&---------------------------------------------------------------------*
*& Report ZMM_INBOUND_DLV_UPL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_inbound_dlv_upl.

TABLES: lips.

TYPES: BEGIN OF ts_ekpo,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
         meins TYPE ekpo-meins,
         txz01 TYPE ekpo-txz01,
         matnr TYPE ekpo-matnr,
       END OF ts_ekpo.
TYPES : BEGIN OF ty_details,
          delivery   TYPE vbeln,
          deliv_item TYPE posnr,
          material   TYPE matnr,
          vend_mat   TYPE idnlf,
          matl_desc	 TYPE	maktx,
          deliv_qty	 TYPE	lfimg,
          unit       TYPE bstme,
          po_number	 TYPE	ebeln,
          po_item	   TYPE	ebelp,
          lifnr      TYPE lifnr,
          lgort   type lgort_d,
        END OF ty_details.

DATA : lt_details TYPE TABLE OF ty_details,
       wa_details TYPE ty_details.


DATA : lt_bapireturn TYPE TABLE OF bapireturn WITH HEADER LINE.
DATA : BEGIN OF ty_line,
         lines1 TYPE char200,
       END OF ty_line.

TYPES: BEGIN OF ty_exis_r,
         lines  LIKE ty_line,
         nested LIKE lt_bapireturn,
       END OF ty_exis_r.
*data : lt_exist_1 TYPE table  ty_exis_r-nested.
DATA : lt_exist_2 TYPE TABLE OF ty_exis_r-lines.
DATA : lt_exist_li TYPE TABLE OF ty_exis_r-lines.
DATA : lt_exist_re TYPE TABLE OF ty_exis_r-nested WITH HEADER LINE.

DATA : lt_exist_fi TYPE  zstr_del_up..
DATA : wa_exist_li LIKE LINE OF lt_exist_fi.

DATA : lt_ekpo TYPE TABLE OF ts_ekpo.
DATA : wa_con_1 TYPE ts_ekpo.

TYPES: BEGIN OF ty_data,
         po_number(10) TYPE c,
         po_item       TYPE ebelp,
         deliv_qty     TYPE lfimg,
       END OF ty_data.
DATA: lt_con TYPE STANDARD TABLE OF ty_data,
      wa_con TYPE ty_data.

DATA wa_existingdelivery LIKE lips.
DATA lt_existingdelivery LIKE STANDARD TABLE OF lips.

DATA: it_inb_delivery_detail TYPE TABLE OF bbp_inbd_d,
      is_inb_delivery_header LIKE bbp_inbd_l.

DATA: wa_it_inb_delivery_detail TYPE bbp_inbd_d,
      wa_is_inb_delivery_header TYPE bbp_inbd_l.

DATA lt_return TYPE TABLE OF bapireturn WITH HEADER LINE.
DATA lt_return1 TYPE TABLE OF bapireturn WITH HEADER LINE.
DATA deliv_dat(8) TYPE c.
DATA po_document_item TYPE purchasingdocumentitemuniqueid.


DATA delivery_no LIKE likp-vbeln.

FIELD-SYMBOLS : <gt_data_h> TYPE STANDARD TABLE,
                <gt_data_l> TYPE ANY TABLE,
                <gt_table>  TYPE STANDARD TABLE,
                <gs_table>  TYPE any.
DATA : lv_filename      TYPE string,
       lt_records       TYPE solix_tab,
       lv_headerxstring TYPE xstring,
       lv_filelength    TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-015.

  PARAMETERS: pv_file TYPE localfile.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 4(60) TEXT-014.
  SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK b2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pv_file.


  DATA: l_window_title      TYPE string,
        l_rc                TYPE sysubrc,
        l_default_file_name TYPE string.

  DATA lt_file_table TYPE filetable.
  CONSTANTS : lc_err TYPE i VALUE -1,
              lc_suc TYPE i VALUE 1.

  l_window_title = 'Excel File'.


* Method to provide value help for input file name
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = l_window_title
      default_filename        = l_default_file_name
      default_extension       = 'XLS'
    CHANGING
      file_table              = lt_file_table
      rc                      = l_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc = 0.
    IF l_rc EQ lc_err.
      MESSAGE ID sy-msgid
            TYPE sy-msgty
          NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSEIF l_rc EQ lc_suc.
      READ TABLE lt_file_table INDEX 1 INTO pv_file.
      IF sy-subrc IS NOT INITIAL.
        CLEAR pv_file.
      ENDIF.
    ENDIF.
  ENDIF.
  FREE lt_file_table.

  lv_filename = pv_file.

START-OF-SELECTION.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_filelength
      header                  = lv_headerxstring
    TABLES
      data_tab                = lt_records
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  "convert binary data to xstring
  "if you are using cl_fdt_xl_spreadsheet in odata then skips this step
  "as excel file will already be in xstring
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_filelength
    IMPORTING
      buffer       = lv_headerxstring
    TABLES
      binary_tab   = lt_records
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    "Implement suitable error handling here
  ENDIF.

  DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet .

  TRY .
      lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
        document_name = lv_filename
        xdocument     = lv_headerxstring ).
    CATCH cx_fdt_excel_core.
  ENDTRY .

  "Get List of Worksheets
  lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
    IMPORTING
      worksheet_names = DATA(lt_worksheets) ).

  IF NOT lt_worksheets IS INITIAL.
    LOOP AT lt_worksheets INTO DATA(lv_woksheetname).

      DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
        lv_woksheetname ).
      "now you have excel work sheet data in dyanmic internal table
      ASSIGN lo_data_ref->* TO <gt_data_h>.
*    *-- Excel work sheet data in dyanmic internal table
      ASSIGN lo_data_ref->* TO <gt_data_h>.

*-Checking table strcuture componet count value
      IF lv_woksheetname EQ 'Sheet1'.
        DATA(lr_descr) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( wa_con ) ).
      ENDIF.

      DATA(l_count) = lines( lr_descr->components ).
      DATA :dref TYPE REF TO data.
      CREATE DATA dref LIKE LINE OF <gt_data_h>.
      ASSIGN dref->* TO  <gs_table>.
*-Checking excel file from PWC strcuture componet count value
      DATA(lr_descr1) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( <gs_table> ) ).
      DATA(l_count1) = lines( lr_descr->components ).

*-Deleting Excel  header
      DATA:lv_int TYPE i.
      LOOP AT <gt_data_h> ASSIGNING FIELD-SYMBOL(<ls_datah>) FROM 2.
        LOOP AT lr_descr1->components[] ASSIGNING FIELD-SYMBOL(<ls_compnt>) FROM 1 TO l_count.
          lv_int = sy-tabix.

          DATA(ls_compont) = lr_descr->components[ lv_int ].
          ASSIGN COMPONENT <ls_compnt>-name OF STRUCTURE <ls_datah> TO FIELD-SYMBOL(<ls_fld>).
          IF sy-subrc IS INITIAL.
            IF lv_woksheetname EQ 'Sheet1'.
              ASSIGN COMPONENT ls_compont-name OF STRUCTURE wa_con TO FIELD-SYMBOL(<ls_file>).
            ENDIF.
            IF sy-subrc IS INITIAL.
              <ls_file> = <ls_fld>.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF wa_con IS NOT INITIAL AND lv_woksheetname EQ 'Sheet1'.

          APPEND wa_con TO lt_con.
        ENDIF.
        CLEAR :wa_con.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  IF lt_con IS NOT INITIAL.
    SELECT ebeln, lifnr FROM ekko FOR ALL ENTRIES IN @lt_con WHERE ebeln = @lt_con-po_number
      INTO TABLE @DATA(lt_ekko).
    SELECT
       ebeln AS po_number,
       ebelp AS po_item,
       meins,
       txz01,
       matnr FROM ekpo FOR ALL ENTRIES IN @lt_con WHERE ebeln = @lt_con-po_number
    AND ebelp = @lt_con-po_item INTO TABLE @lt_ekpo.
  ENDIF.


  SORT lt_con BY po_number po_item.
  SORT lt_ekpo BY ebeln ebelp.
  SORT lt_ekko BY ebeln lifnr.

  DATA(lt_tab) = lt_con.

  SORT lt_tab BY po_number po_item.
  DELETE ADJACENT DUPLICATES FROM lt_tab COMPARING po_number.
  DATA(lt_count1) =  lines( lt_tab ) .

  DATA(ls_tab1) = VALUE #( lt_tab[ 1 ] OPTIONAL ).
  DATA(ls_tab2) = VALUE #( lt_tab[ lt_count1 ] OPTIONAL ).

  DATA : lv_ebeln TYPE ekko-ebeln.
  SELECT-OPTIONS : s_ebeln FOR lv_ebeln NO-DISPLAY.
  s_ebeln-sign = 'I'.
  s_ebeln-option = 'BT'.
  s_ebeln-low = ls_tab1-po_number.
  s_ebeln-high = ls_tab2-po_number.
  APPEND s_ebeln.

  TYPES : BEGIN OF ty_ekpo,
            ebeln    TYPE ebeln,
            ebelp(6) TYPE n,
          END OF ty_ekpo.
  DATA : it_ekpo1 TYPE TABLE OF ty_ekpo.
  DATA : it_ekpo2 TYPE TABLE OF ekpo.
  DATA : lv_cnt TYPE i.
  SELECT a~* FROM ekpo AS a LEFT OUTER JOIN @lt_con AS b ON a~ebeln = b~po_number
  WHERE a~ebeln IN @s_ebeln INTO CORRESPONDING FIELDS OF TABLE @it_ekpo1."taking all po delivery is created.

  DATA : it_ekpo3 TYPE TABLE OF ekpo.
  SELECT * FROM lips FOR ALL ENTRIES IN @it_ekpo1 WHERE vgbel = @it_ekpo1-ebeln AND vgpos = @it_ekpo1-ebelp
    INTO TABLE @DATA(lips1). "taking only those delivery is created.

  SELECT a~* FROM ekpo AS a LEFT OUTER JOIN @lt_con AS b ON a~ebeln = b~po_number
WHERE a~ebeln IN @s_ebeln INTO  TABLE @it_ekpo2.

  SORT it_ekpo1 BY ebeln ebelp.
  SORT it_ekpo2 BY ebeln ebelp.
  SORT lips1 BY vgbel vgpos.
  DELETE ADJACENT DUPLICATES FROM it_ekpo2 COMPARING ebeln ebelp.

  LOOP AT it_ekpo2 ASSIGNING FIELD-SYMBOL(<fs_ekpo2>).
    " Step 2: Fetch existing deliveries for this PO item
    IF <fs_ekpo2> IS ASSIGNED.
      SELECT SUM( lfimg ) FROM lips INTO @DATA(lv_total_delivered) WHERE
         vgbel = @<fs_ekpo2>-ebeln
         AND vgpos = @<fs_ekpo2>-ebelp.
    ENDIF.

    "Step 3: Fetch the PO quantity for comparison
    DATA(lv_po_qty) = <fs_ekpo2>-menge.
    READ TABLE lt_con ASSIGNING FIELD-SYMBOL(<fs_con1>) WITH KEY po_number = <fs_ekpo2>-ebeln po_item =  <fs_ekpo2>-ebelp.
    IF <fs_con1> IS ASSIGNED.
      " Check quantity is exceeds
      IF ( lv_total_delivered + <fs_con1>-deliv_qty ) > lv_po_qty.
        wa_exist_li-lines = | Delivery for  { <fs_ekpo2>-ebeln } { <fs_ekpo2>-ebelp }  can not create please check the quantity exceeded   |.
        APPEND  wa_exist_li-lines TO lt_exist_fi.
      ELSE.
        IF strlen( <fs_con1>-po_number ) < 10 .
          <fs_con1>-po_number = |0{ <fs_con1>-po_number }|.
        ENDIF.

        wa_con_1 = VALUE #( lt_ekpo[  ebeln = <fs_con1>-po_number ebelp = <fs_con1>-po_item ] OPTIONAL ).
        wa_it_inb_delivery_detail-po_number = <fs_con1>-po_number.
        wa_it_inb_delivery_detail-po_item = <fs_con1>-po_item.
        wa_it_inb_delivery_detail-deliv_qty = <fs_con1>-deliv_qty.
        wa_it_inb_delivery_detail-material = wa_con_1-matnr.
        wa_it_inb_delivery_detail-matl_desc   = wa_con_1-txz01.
        wa_it_inb_delivery_detail-unit = wa_con_1-meins.
          IF <fs_ekpo2>-lgort IS INITIAL.
          wa_it_inb_delivery_detail-lgort = 'P001'.
        ENDIF.
        APPEND  wa_it_inb_delivery_detail TO it_inb_delivery_detail.

        deliv_dat = sy-datum.
        DATA(date_for_lips) = |{ sy-datum+6(2) }{ sy-datum+4(2) }{ sy-datum+0(4) }|.
        is_inb_delivery_header-deliv_date = deliv_dat.
        CLEAR wa_existingdelivery.
        CLEAR : wa_con, lt_return, wa_it_inb_delivery_detail,
         is_inb_delivery_header, wa_exist_li-lines .
      ENDIF.
    ENDIF.
  ENDLOOP.

*  LOOP AT lt_con INTO DATA(ls_con1).
*
*    IF strlen( ls_con1-po_number ) < 10 .
*      ls_con1-po_number = |0{ ls_con1-po_number }|.
*    ENDIF.
*
*    wa_con_1 = VALUE #( lt_ekpo[  ebeln = ls_con1-po_number ebelp = ls_con1-po_item ] OPTIONAL ).
*
**    IF sy-subrc = 0.
*    wa_it_inb_delivery_detail-po_number = ls_con1-po_number.
*    wa_it_inb_delivery_detail-po_item = ls_con1-po_item.
*    wa_it_inb_delivery_detail-deliv_qty = ls_con1-deliv_qty.
*    wa_it_inb_delivery_detail-material = wa_con_1-matnr.
*    wa_it_inb_delivery_detail-matl_desc   = wa_con_1-txz01.
*    wa_it_inb_delivery_detail-unit = wa_con_1-meins.
*    APPEND  wa_it_inb_delivery_detail TO it_inb_delivery_detail.
*
*    deliv_dat = sy-datum.
*    DATA(date_for_lips) = |{ sy-datum+6(2) }{ sy-datum+4(2) }{ sy-datum+0(4) }|.
*    is_inb_delivery_header-deliv_date = deliv_dat.
*    CLEAR wa_existingdelivery.
*    CLEAR : wa_con, lt_return, wa_it_inb_delivery_detail,
*     is_inb_delivery_header, wa_exist_li-lines  .
*  ENDLOOP.
*



  SORT  it_inb_delivery_detail BY po_number po_item.
  lt_details = CORRESPONDING #( it_inb_delivery_detail ).
  LOOP AT lt_details  ASSIGNING FIELD-SYMBOL(<fs_details>).
    READ TABLE lt_ekko ASSIGNING FIELD-SYMBOL(<fs_ekko1>)
     WITH KEY ebeln = <fs_details>-po_number.
    IF <fs_details> IS ASSIGNED.
      IF  <fs_ekko1> IS ASSIGNED.
        <fs_details>-lifnr = <fs_ekko1>-lifnr.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DATA(itab) = it_inb_delivery_detail.
  CLEAR itab.

  LOOP AT lt_ekko  ASSIGNING FIELD-SYMBOL(<fs_ekko>).
    ON CHANGE OF <fs_ekko>-lifnr.
      LOOP AT lt_details ASSIGNING FIELD-SYMBOL(<fs_items>) WHERE lifnr = <fs_ekko>-lifnr .
        APPEND <fs_items> TO itab.
      ENDLOOP.
      IF itab IS NOT INITIAL.
        deliv_dat = sy-datum.
        DATA(date_for_lips1) = |{ sy-datum+6(2) }{ sy-datum+4(2) }{ sy-datum+0(4) }|.
        is_inb_delivery_header-deliv_date = deliv_dat.
        delete ADJACENT DUPLICATES FROM itab COMPARING deliv_qty po_number po_item.

        CALL FUNCTION 'BBP_INB_DELIVERY_CREATE'
          EXPORTING
            is_inb_delivery_header = is_inb_delivery_header
          IMPORTING
            ef_delivery            = delivery_no
          TABLES
            it_inb_delivery_detail = itab[]
*           return                 = lt_return[].
            return                 = lt_bapireturn.
        LOOP AT lt_bapireturn  INTO DATA(ls_bapi) WHERE type = 'A'
               OR type = 'E'
             OR type = 'X'
          OR type = 'S'.
          IF ls_bapi-type = 'S'.
            wa_exist_li-lines =  ls_bapi-message.
            APPEND wa_exist_li TO lt_exist_fi.
            CLEAR : ls_bapi.
          ENDIF.
        ENDLOOP.
        IF lt_bapireturn[] IS INITIAL.
          wa_exist_li-lines = CONV #( | Please Check if PO numbers applicable for inbound delivery or Delivery already exist // Conferm using Tcode:- VL31N'. | ).
          APPEND  wa_exist_li-lines TO lt_exist_fi.
        ELSE.
        ENDIF.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.
      REFRESH itab.
    ENDON.
  ENDLOOP.

  CALL FUNCTION 'ZMM_ALV_POPUP'
    EXPORTING
      i_start_column = 10
      i_start_line   = 10
      i_end_column   = 150
      i_end_line     = 15
      i_title        = 'ALV'
      i_popup        = 'X'
    TABLES
      it_alv         = lt_exist_fi[].

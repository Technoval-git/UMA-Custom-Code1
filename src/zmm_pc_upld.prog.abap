*----------------------------------------------------------------------*
***INCLUDE ZMM_PC_UPLD.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zmm_pc_upld
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zmm_pc_upld .

  DATA: lw_gm TYPE zmm_gm,
        lw_ac TYPE zmm_ac,
        lw_hq TYPE zmm_hq,
        lw_df TYPE zmm_df,
        lw_ma TYPE zmm_ma.
  DATA : lt_gm TYPE STANDARD TABLE OF zmm_gm,
         lt_ac TYPE  STANDARD TABLE OF zmm_ac,
         lt_hq TYPE STANDARD TABLE OF zmm_hq,
         lt_df TYPE STANDARD TABLE OF zmm_df,
         lt_ma TYPE STANDARD TABLE OF zmm_ma.

  DATA:
    gt_icdtxt   TYPE STANDARD TABLE OF cdtxt,
    gv_objectid TYPE  cdhdr-objectid.

  TYPES: BEGIN OF ty_data_gm,
           gm_matnr(40)        TYPE c,
           gm_maktx(40)        TYPE c,
           gm_price(11)        TYPE c,
           gm_waers(5)         TYPE c,
           gm_cour_surc(11)    TYPE c,
           gm_comment(200)     TYPE c,
           gm_supersession(40) TYPE c,
           gm_min_ord_qty(13)  TYPE c,
           gm_merch_qty(13)    TYPE c,
           gm_extwg(18)        TYPE c,

         END OF ty_data_gm.
  DATA: lt_con_gm TYPE STANDARD TABLE OF ty_data_gm,
        wa_con_gm TYPE ty_data_gm.

  TYPES: BEGIN OF ty_data_hq,

           hq_matnr(40)      TYPE c,
           hq_maktx(40)      TYPE c,
           hq_pack_qty(13)   TYPE c,
           hq_price(11)      TYPE c,
           hq_amount(11)     TYPE c,
           hq_waers(5)       TYPE c,
           hq_car_series(40) TYPE c,
           hq_meins(3)       TYPE c,
         END OF ty_data_hq.
  DATA: lt_con_hq TYPE STANDARD TABLE OF ty_data_hq,
        wa_con_hq TYPE ty_data_hq.


  TYPES: BEGIN OF ty_data_ac,
           ac_matnr(40)        TYPE c,
           ac_delco(40)        TYPE c,
           ac_maktx(40)        TYPE c,
           ac_price(11)        TYPE c,
           ac_oeprice(11)      TYPE c,
           ac_waers(5)         TYPE c,
           ac_cour_surc(11)    TYPE c,
           ac_comment(200)     TYPE c,
           ac_supersession(40) TYPE c,
           ac_min_ord_qty(13)  TYPE c,
           ac_merch_qty(13)    TYPE c,
           ac_extwg(18)        TYPE c,
           ac_remark(200)      TYPE c,
           ac_remark1(200)     TYPE c,
         END OF ty_data_ac.
  DATA: lt_con_ac TYPE STANDARD TABLE OF ty_data_ac,
        wa_con_ac TYPE ty_data_ac.


  TYPES: BEGIN OF ty_data_df,
           df_matnr(40)     TYPE c,
           df_maktx(40)     TYPE c,
           df_qty(13)       TYPE c,
           df_price(11)     TYPE c,
           df_amount(11)    TYPE c,
           df_waers(5)      TYPE c,
           df_carseries(50) TYPE c,
           df_meins(3)      TYPE c,
         END OF ty_data_df.
  DATA: lt_con_df TYPE STANDARD TABLE OF ty_data_df,
        wa_con_df TYPE ty_data_df.

  TYPES: BEGIN OF ty_data_ma,
           ma_matnr(40)     TYPE c,
           ma_maktx(40)     TYPE c,
           ma_qty(13)       TYPE c,
           ma_price(11)     TYPE c,
           ma_amount(11)    TYPE c,
           ma_waers(5)      TYPE c,
           ma_carseries(50) TYPE c,
           ma_meins(3)      TYPE c,
         END OF ty_data_ma.
  DATA: lt_con_ma TYPE STANDARD TABLE OF ty_data_ma,
        wa_con_ma TYPE ty_data_ma.

  FIELD-SYMBOLS : <gt_data_h> TYPE STANDARD TABLE,
                  <gt_data_l> TYPE ANY TABLE,
                  <gt_table>  TYPE STANDARD TABLE,
                  <gs_table>  TYPE any.
  DATA : lv_filename      TYPE string,
         lt_records       TYPE solix_tab,
         lv_headerxstring TYPE xstring,
         lv_filelength    TYPE i.
  DATA lv_cat TYPE char4.
  DATA lv_WS TYPE char2.

  IF p_gm = 'X'.

    SELECT SINGLE category INTO lv_cat FROM zmm_pc_autho WHERE uname = sy-uname AND category = 'GM'.
    IF lv_cat NE 'GM'.
      MESSAGE e002(zmm_pc).
    ENDIF.
  ELSEIF p_ac = 'X'.
    SELECT SINGLE category INTO lv_cat FROM zmm_pc_autho WHERE uname = sy-uname AND category = 'AC'.
    IF lv_cat NE 'AC'.
      MESSAGE e002(zmm_pc).
    ENDIF.

  ELSEIF p_hq = 'X'.
    SELECT SINGLE category INTO lv_cat FROM zmm_pc_autho WHERE uname = sy-uname AND category = 'HQ'.
    IF lv_cat NE 'HQ'.
      MESSAGE e002(zmm_pc).
    ENDIF.

  ELSEIF p_df = 'X'.
    SELECT SINGLE category INTO lv_cat FROM zmm_pc_autho WHERE uname = sy-uname AND category = 'DF'.
    IF lv_cat NE 'DF'.
      MESSAGE e002(zmm_pc).
    ENDIF.

  ELSEIF p_ma = 'X'.
    SELECT SINGLE category INTO lv_cat FROM zmm_pc_autho WHERE uname = sy-uname AND category = 'MS'.
    IF lv_cat NE 'MS'.
      MESSAGE e002(zmm_pc).
    ENDIF.


  ENDIF.




  IF pv_file IS INITIAL.
    MESSAGE e001(zmm_pc).
  ENDIF.
  lv_filename = pv_file.

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
  ENDIF.

  DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet .

  TRY .
      lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                              document_name = lv_filename
                              xdocument     = lv_headerxstring ) .
    CATCH cx_fdt_excel_core.
  ENDTRY .
  IF lo_excel_ref IS BOUND.
    "Get List of Worksheets
    lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING
        worksheet_names = DATA(lt_worksheets) ).

    IF NOT lt_worksheets IS INITIAL.
      LOOP AT lt_worksheets INTO DATA(lv_woksheetname).
        IF sy-tabix = 1.
          lv_ws = lv_woksheetname+0(2).
        ELSE.
          CONTINUE.
        ENDIF.
        DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                                 lv_woksheetname ).
        "now you have excel work sheet data in dyanmic internal table
        ASSIGN lo_data_ref->* TO <gt_data_h>.
*    *-- Excel work sheet data in dyanmic internal table
*        ASSIGN lo_data_ref->* TO <gt_data_h>.

*-Checking table strcuture componet count value
*      IF lv_woksheetname EQ 'Sheet1'.
        IF p_gm = 'X'.
          DATA(lr_descr) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( wa_con_gm ) ).
        ELSEIF p_hq = 'X'.
          lr_descr = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( wa_con_hq ) ).
        ELSEIF p_ac = 'X'.
          lr_descr = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( wa_con_ac ) ).
        ELSEIF p_df = 'X'.
          lr_descr = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( wa_con_df ) ).
        ELSEIF p_ma = 'X'.
          lr_descr = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( wa_con_ma ) ).
        ENDIF.
*      ENDIF.

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
          IF <ls_datah> IS INITIAL.
            CONTINUE.
          ENDIF.
          LOOP AT lr_descr1->components[] ASSIGNING FIELD-SYMBOL(<ls_compnt>) FROM 1 TO l_count.
            lv_int = sy-tabix.

            DATA(ls_compont) = lr_descr->components[ lv_int ].
            ASSIGN COMPONENT <ls_compnt>-name OF STRUCTURE <ls_datah> TO FIELD-SYMBOL(<ls_fld>).
            IF sy-subrc IS INITIAL.
*            IF lv_woksheetname EQ 'Sheet1'.
              IF p_gm = 'X'.
                ASSIGN COMPONENT ls_compont-name OF STRUCTURE wa_con_gm TO FIELD-SYMBOL(<ls_file>).
              ELSEIF p_hq = 'X'.
                ASSIGN COMPONENT ls_compont-name OF STRUCTURE wa_con_hq TO <ls_file>.
              ELSEIF p_ac = 'X'.
                ASSIGN COMPONENT ls_compont-name OF STRUCTURE wa_con_ac TO <ls_file>.
              ELSEIF p_df = 'X'.
                ASSIGN COMPONENT ls_compont-name OF STRUCTURE wa_con_df TO <ls_file>.
              ELSEIF p_ma = 'X'.
                ASSIGN COMPONENT ls_compont-name OF STRUCTURE wa_con_ma TO <ls_file>.
              ENDIF.

*            ENDIF.
              IF sy-subrc IS INITIAL.
                <ls_file> = <ls_fld>.
              ENDIF.
            ENDIF.
          ENDLOOP.
*        IF wa_con IS NOT INITIAL AND lv_woksheetname EQ 'Sheet1'.
          IF p_gm = 'X'.
            APPEND wa_con_gm TO lt_con_gm.
          ELSEIF p_hq = 'X'.
            APPEND wa_con_hq TO lt_con_hq.
          ELSEIF p_ac = 'X'.
            APPEND wa_con_ac TO lt_con_ac.
          ELSEIF p_df = 'X'.
            APPEND wa_con_df TO lt_con_df.
          ELSEIF p_ma = 'X'.
            APPEND wa_con_ma TO lt_con_ma.
          ENDIF.


*        ENDIF.
          CLEAR :wa_con_gm,wa_con_ac,wa_con_hq,wa_con_df,wa_con_ma.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.
*Upload activey happend onece in week or twice in a week . we need to upload in forground only from fiori tile
*select single in loop beacause, if we download entire table and save it in internal table and memory allocation will be very huge for GM
*  so purpusfully kept select single in loop we need to decide for best performance


  IF p_gm = 'X'.
    IF lv_ws NE 'GM'.
      MESSAGE 'Brand Radio Button and Worksheet Name Mismatch or excel should be xlsx' TYPE 'E'.
    ENDIF.
    CLEAR gv_objectid.
    LOOP AT lt_con_gm INTO wa_con_gm.
      MOVE-CORRESPONDING wa_con_gm TO lw_gm.
      lw_gm-mandt = sy-mandt.
      lw_gm-gm_ersda = sy-datum.
      lw_gm-gm_createdon = sy-uzeit.
      lw_gm-gm_ERNAM = sy-uname.
*select * is mandatory here to make structure identical for change log FM
      SELECT SINGLE * FROM zmm_gm INTO @DATA(lw_old_gm)
                                 WHERE gm_matnr = @wa_con_gm-gm_matnr
                                   AND gm_price NE @lw_gm-gm_price .   " added
      IF sy-subrc = 0 .
*        AND ( lw_old_gm-gm_price <> lw_gm-gm_price )." OR lw_old_gm-gm_cour_surc <> lw_gm-gm_cour_surc ) .
        gv_objectid = wa_con_gm-gm_matnr.
        CONDENSE gv_objectid.


        CALL FUNCTION 'ZMM_HQ_WRITE_DOCUMENT'
          EXPORTING
            objectid                = gv_objectid
            tcode                   = sy-tcode
            utime                   = sy-uzeit
            udate                   = sy-datum
            username                = sy-uname
            object_change_indicator = 'U'
            n_zmm_gm                = lw_gm
            o_zmm_gm                = lw_old_gm
            upd_zmm_gm              = 'U'
          TABLES
            icdtxt_zmm_hq           = gt_icdtxt.
      ENDIF.
      MODIFY  zmm_gm FROM lw_gm.

    ENDLOOP.

  ELSEIF p_ac = 'X'.
    IF lv_ws NE 'AC'.
      MESSAGE 'Brand Radio Button and Worksheet Name Mismatch or excel should be xlsx' TYPE 'E'.
    ENDIF.
    LOOP AT lt_con_ac INTO wa_con_ac.
      CLEAR gv_objectid.
      MOVE-CORRESPONDING wa_con_ac TO lw_ac.
      lw_ac-mandt = sy-mandt.
      lw_ac-ac_ersda = sy-datum.
      lw_ac-ac_createdon = sy-uzeit.
      lw_ac-ac_ernam = sy-uname.
      SELECT SINGLE * FROM zmm_ac INTO @DATA(lw_old_ac)
                                       WHERE ac_matnr = @wa_con_ac-ac_matnr AND ac_delco = @wa_con_ac-ac_delco.
      IF sy-subrc = 0 AND ( lw_old_ac-ac_price NE lw_ac-ac_price )." OR
*                            lw_old_ac-ac_oeprice NE lw_ac-ac_oeprice OR
*                            lw_old_ac-ac_cour_surc NE lw_Ac-ac_cour_surc ).
        gv_objectid = wa_con_ac-ac_matnr.
        CONDENSE gv_objectid.

        CALL FUNCTION 'ZMM_HQ_WRITE_DOCUMENT'
          EXPORTING
            objectid                = gv_objectid
            tcode                   = sy-tcode
            utime                   = sy-uzeit
            udate                   = sy-datum
            username                = sy-uname
            object_change_indicator = 'U'
            n_zmm_ac                = lw_ac
            o_zmm_ac                = lw_old_ac
            upd_zmm_ac              = 'U'
          TABLES
            icdtxt_zmm_hq           = gt_icdtxt.

      ENDIF.
      MODIFY  zmm_ac FROM lw_ac.

    ENDLOOP.

  ELSEIF p_hq = 'X'.
    IF lv_ws NE 'HQ'.
      MESSAGE 'Brand Radio Button and Worksheet Name Mismatch or excel should be xlsx' TYPE 'E'.
    ENDIF.
    CLEAR gv_objectid.
    LOOP AT lt_con_hq INTO wa_con_hq.
      MOVE-CORRESPONDING wa_con_hq TO lw_hq.
      lw_hq-mandt = sy-mandt.
      lw_hq-hq_ersda = sy-datum.
      lw_hq-hq_createdon = sy-uzeit.
      lw_hq-hq_ERNAM = sy-uname.
      SELECT SINGLE * FROM zmm_hq INTO @DATA(lw_old_hq)
                                     WHERE hq_matnr = @wa_con_hq-hq_matnr.

      IF sy-subrc = 0 AND ( lw_old_hq-hq_pack_qty NE lw_hq-hq_pack_qty )." OR
*                            lw_old_hq-hq_price  =  lw_hq-hq_price  OR
*                            lw_old_hq-hq_amount = lw_hq-hq_price ).

        gv_objectid = wa_con_hq-hq_matnr.
        CONDENSE gv_objectid.


        CALL FUNCTION 'ZMM_HQ_WRITE_DOCUMENT'
          EXPORTING
            objectid                = gv_objectid
            tcode                   = sy-tcode
            utime                   = sy-uzeit
            udate                   = sy-datum
            username                = sy-uname
            object_change_indicator = 'U'
            n_zmm_hq                = lw_hq
            o_zmm_hq                = lw_old_hq
            upd_zmm_hq              = 'U'
          TABLES
            icdtxt_zmm_hq           = gt_icdtxt.
      ENDIF.
      MODIFY  zmm_hq FROM lw_hq.
    ENDLOOP.

  ELSEIF p_df = 'X'.
    IF lv_ws NE 'DF'.
      MESSAGE 'Brand Radio Button and Worksheet Name Mismatch or excel should be xlsx' TYPE 'E'.
    ENDIF.
    CLEAR gv_objectid.
    LOOP AT lt_con_df INTO wa_con_df.
      MOVE-CORRESPONDING wa_con_df TO lw_df.
      lw_df-mandt = sy-mandt.
      lw_df-df_ersda = sy-datum.
      lw_df-df_createdon = sy-uzeit.
      lw_df-df_ERNAM = sy-uname.
      SELECT SINGLE * FROM zmm_df INTO @DATA(lw_old_df)
                                     WHERE df_matnr = @wa_con_df-df_matnr.

      IF sy-subrc = 0  AND lw_old_df-df_price  NE  lw_df-df_price .

        gv_objectid = wa_con_df-df_matnr.
        CONDENSE gv_objectid.


        CALL FUNCTION 'ZMM_HQ_WRITE_DOCUMENT'
          EXPORTING
            objectid                = gv_objectid
            tcode                   = sy-tcode
            utime                   = sy-uzeit
            udate                   = sy-datum
            username                = sy-uname
            object_change_indicator = 'U'
            n_zmm_df                = lw_df
            o_zmm_df                = lw_old_df
            upd_zmm_df              = 'U'
          TABLES
            icdtxt_zmm_hq           = gt_icdtxt.
      ENDIF.
      MODIFY  zmm_df FROM lw_df.
    ENDLOOP.



  ELSEIF p_ma = 'X'.
    IF lv_ws NE 'MS'.
      MESSAGE 'Brand Radio Button and Worksheet Name Mismatch or excel should be xlsx' TYPE 'E'.
    ENDIF.
    CLEAR gv_objectid.
    LOOP AT lt_con_ma INTO wa_con_ma.
      MOVE-CORRESPONDING wa_con_ma TO lw_ma.
      lw_ma-mandt = sy-mandt.
      lw_ma-ma_ersda = sy-datum.
      lw_ma-ma_createdon = sy-uzeit.
      lw_ma-ma_ERNAM = sy-uname.
      SELECT SINGLE * FROM zmm_ma INTO @DATA(lw_old_ma)
                                     WHERE ma_matnr = @wa_con_ma-ma_matnr.

      IF sy-subrc = 0 AND   lw_old_ma-ma_price  =  lw_ma-ma_price .

        gv_objectid = wa_con_ma-ma_matnr.
        CONDENSE gv_objectid.


        CALL FUNCTION 'ZMM_HQ_WRITE_DOCUMENT'
          EXPORTING
            objectid                = gv_objectid
            tcode                   = sy-tcode
            utime                   = sy-uzeit
            udate                   = sy-datum
            username                = sy-uname
            object_change_indicator = 'U'
            n_zmm_ma                = lw_ma
            o_zmm_ma                = lw_old_ma
            upd_zmm_ma              = 'U'
          TABLES
            icdtxt_zmm_hq           = gt_icdtxt.
      ENDIF.
      MODIFY  zmm_ma FROM lw_ma.
    ENDLOOP.


  ENDIF.


ENDFORM.

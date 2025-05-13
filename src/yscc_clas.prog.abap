*&---------------------------------------------------------------------*
*& Include          YSCC_CLAS
*&---------------------------------------------------------------------*
CLASS lcl_scc DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: validation, " validation radiobuttons
      f4help. " F4 help for upload
    METHODS: xsl_to_tabel RETURNING VALUE(rr_table) TYPE REF TO data,
      bapi_save_data EXPORTING le_table TYPE REF TO data,
      get_material,
      get_dates,
      Get_moths EXPORTING le_remonth TYPE i,
      get_finaldata,
      getdata,
      get_salesdata EXPORTING le_date TYPE lt_syrrage, " SALES DATA FOR MATERILA
      display_update,
      get_mevr, " SALES RMMAING DATA
      update RETURNING VALUE(rr_tabud) TYPE REF TO data,
      applyfilter.
ENDCLASS.
CLASS lcl_scc IMPLEMENTATION.
  METHOD f4help.
    cl_gui_frontend_services=>file_open_dialog(
  EXPORTING
    file_filter             = |xlsx (*.xlsx)\|*.xlsx\|{ cl_gui_frontend_services=>filetype_all }|    " File Extension Filter String
  CHANGING
    file_table              =    lv_file  " Table Holding Selected Files
    rc                      =  lv_rc    " Return Code, Number of Files or -1 If Error Occurred
    user_action             =  lv_action   " User Action (See Class Constants ACTION_OK, ACTION_CANCEL)
  EXCEPTIONS
    file_open_dialog_failed = 1
    cntl_error              = 2
    error_no_gui            = 3
    not_supported_by_gui    = 4
    OTHERS                  = 5 ).
    READ TABLE lv_file INDEX 1 INTO DATA(wa_file).
    IF sy-subrc = 0.
      p_file = wa_file-filename.
    ENDIF.
  ENDMETHOD.
  METHOD validation.
    LOOP AT SCREEN.
      CASE 'X'.
        WHEN rb_upl.
          IF screen-group1 = 'UPR' OR screen-group1 = 'UPD'.
            screen-active = 0.
          ENDIF.

        WHEN rb_upd.
          IF screen-group1 = 'UPL'.
            screen-active = 0.
          ENDIF.

        WHEN rb_rep.
          IF screen-group1 = 'UPD' OR screen-group1 = 'UPL'.
            screen-active = 0.
          ENDIF.

      ENDCASE.

      MODIFY SCREEN.
    ENDLOOP.
  ENDMETHOD.
  METHOD: xsl_to_tabel.
    DATA: filename    TYPE  string,
          it_bin_data TYPE w3mimetabtype,
          lv_filesize TYPE w3param-cont_len.
    filename = p_file.
    cl_gui_frontend_services=>gui_upload(
  EXPORTING
    filename                =  filename    " Name of file
    filetype                = 'BIN'    " File Type (ASCII, Binary)
  IMPORTING
    filelength              = lv_filesize    " File Length
  CHANGING
    data_tab                =  it_bin_data   " Transfer table for file contents
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
    not_supported_by_gui    = 17
    error_no_gui            = 18
    OTHERS                  = 19 ).
    DATA(lv_bin_data) = cl_bcs_convert=>solix_to_xstring(
                            it_solix   = it_bin_data ).
    DATA(o_excel) = NEW cl_fdt_xl_spreadsheet(
        document_name     = CONV #( filename  )
        xdocument         = lv_bin_data ).
    DATA: it_worksheet_name TYPE if_fdt_doc_spreadsheet=>t_worksheet_names.
    o_excel->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING
        worksheet_names = it_worksheet_name ).
    IF lines( it_worksheet_name ) > 0.
      DATA(o_worksheet_itab)  = o_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
           it_worksheet_name[ 1 ] ).
    ENDIF.
*    delete o_worksheet_itab where index = 1.
    rr_table = o_worksheet_itab.
  ENDMETHOD.
  METHOD:bapi_save_data.
    ASSIGN le_table->* TO <worksheet>.
    IF rb_upl = 'X'.
      DELETE <worksheet> INDEX 1.
    ENDIF.
    LOOP AT <worksheet> ASSIGNING FIELD-SYMBOL(<wa>).
*      IF sy-tabix > 1.
      ASSIGN COMPONENT 1 OF STRUCTURE <wa> TO FIELD-SYMBOL(<fs_matnr>).
      lv_material  = <fs_matnr>.
      ASSIGN COMPONENT 2 OF STRUCTURE <wa> TO FIELD-SYMBOL(<fs_plant>).
      lv_plant  = <fs_plant>.
      lv_material  = |{ lv_material ALPHA = IN }|.
      CALL FUNCTION 'BAPI_MATERIAL_GET_ALL'
        EXPORTING
          material   = lv_material   " Material Number
          plant      = lv_plant     " Plant
        IMPORTING
          clientdata = ls_get_marahed    " Material Data at Client Level
          plantdata  = ls_get_marcpla.  " Material Data at Plant Level " Units of Measure
      MOVE-CORRESPONDING ls_get_marahed  TO  ls_bapimatrhead.
      MOVE-CORRESPONDING ls_get_marcpla TO  ls_bapiplantdata.
      CLEAR: ls_get_marahed,ls_get_marcpla.
      ASSIGN COMPONENT 3 OF STRUCTURE <wa> TO FIELD-SYMBOL(<fs_eislo>).
      lv_eislo  = <fs_eislo>.
      ls_bapiplantdata-REORDER_PT = lv_eislo.
      ls_bapiplantdataX-REORDER_PT = 'X'.
      ls_bapiplantdata-plant =  lv_plant.
      ls_bapiplantdatax-plant =  lv_plant.
      ls_bapiplantdata-safety_stk = lv_eislo.
      ls_bapiplantdatax-safety_stk = 'X'.
      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          headdata       = ls_bapimatrhead  " Header segment with control information
          plantdata      = ls_bapiplantdata  " Plant-specific material data
          plantdatax     = ls_bapiplantdatax " Information on update for PLANTDATA
        TABLES
          returnmessages = lt_return.      " All messages
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      UNASSIGN: <fs_matnr>,<fs_plant>,<fs_eislo>.
      CLEAR: lt_return ,ls_bapimatrhead,ls_bapiplantdata,ls_bapiplantdatax.
    ENDLOOP.
    MESSAGE 'Safety Stock Calculation update for materilas' TYPE 'S'.

    UNASSIGN <worksheet>.
  ENDMETHOD.
  METHOD getdata.
    IF go_ida IS NOT BOUND.
      go_ida = cl_salv_gui_table_ida=>create_for_cds_view( iv_cds_view_name = `YI_ABC_CLASSIFICATION`).
    ENDIF.
    me->applyfilter( ).
    go_ida->fullscreen( )->display( ).
  ENDMETHOD.
  METHOD applyfilter.
    DATA(lo_selectoptions) = NEW cl_salv_range_tab_collector( ).
    lo_selectoptions->add_ranges_for_name( iv_name = 'MATNR' it_ranges = s_matnr[] ).
    data(ls_matkl1) = s_matkl1.
    ls_matkl1-sign = 'I'.
    ls_matkl1-option = 'EQ'.
    ls_matkl1-low = s_matkl.
    append ls_matkl1 to s_matkl1.


     data(ls_werks1) = s_werks1.
    ls_werks1-sign = 'I'.
    ls_werks1-option = 'EQ'.
    ls_werks1-low = s_werks.
    append ls_werks1 to s_werks1.


*    loop at s_matkl1 ASSIGNING FIELD-SYMBOL(<abc>).
*      <abc>-low = s_matkl.
*    endloop.
*     loop at s_werks1 ASSIGNING FIELD-SYMBOL(<pqr>).
*      <pqr>-low = s_werks.
*    endloop.
    lo_selectoptions->add_ranges_for_name( iv_name = 'MATKL' it_ranges = s_matkl1[] ).
    lo_selectoptions->add_ranges_for_name( iv_name = 'MAABC' it_ranges = s_maabc[] ).
*    lo_selectoptions->add_ranges_for_name( iv_name = 'WERKS' it_ranges = s_werks1[] ).
        lo_selectoptions->add_ranges_for_name( iv_name = 'WERKS' it_ranges = s_werks[] ).

    lo_selectoptions->get_collected_ranges( IMPORTING et_named_ranges = DATA(lt_name_ranges) ).
    go_ida->set_select_options( it_ranges = lt_name_ranges ).
  ENDMETHOD.
  METHOD get_material.
*    DATA : lt_golive TYPE STANDARD TABLE OF zmm_golive.
*       SELECT * FROM zmm_golive INTO TABLE lt_golive.
*    DATA lv_golive_date TYPE sy-datum.
*
*
*    READ TABLE lt_golive INTO DATA(ls_golive) WITH KEY werks = s_werks
*                                                       matkl = s_matkl.
*    IF sy-subrc = 0.
*      lv_golive_date = ls_golive-golive_date.
*    ENDIF.
    SELECT  name, low FROM tvarvc INTO TABLE  @DATA(lt_tvarvc) WHERE name IN ('ZABC_GOLIVE','ZNO_MONTHS','ZLV_RETURN').
    IF sy-subrc = 0.
      TRY.
**********         get_livedate = ls_golive-golive_date.
*          get_livedate = lt_tvarvc[ name = 'ZABC_GOLIVE' ]-low. " GET livedate
***          get_livedate = lv_golive_date.
**********           CONCATENATE get_livedate+4(4)  get_livedate+3(2)  get_livedate+0(2) INTO go_DATE.
***          go_DATE = lv_golive_date.
*********          stc_year = go_DATE+0(4).
          lv_coumon = lt_tvarvc[ name = 'ZNO_MONTHS' ]-low. " Number of moths
          lv_return = lt_tvarvc[ name = 'ZLV_RETURN' ]-low. " Get the return value
          CATCH cx_sy_itab_line_not_found.
      ENDTRY.
      SELECT werks pdt  FROM ymm_mrp_plt INTO TABLE lt_mrppl.
      SELECT werks,maabc,slev,serpv FROM ymm_mrp_ssf INTO TABLE @lt_mrpssf.
      SELECT * FROM yi_abc_classification INTO TABLE @lt_final WHERE matnr IN @s_matnr AND
                                                                     matkl = @s_matkl AND
*                                                                    werks = @S_werks.
*                                                                    matkl IN @s_matkl AND
                                                                     maabc in @s_maabc and
                                                                    werks IN @S_werks.
    ENDIF.
  ENDMETHOD.
  METHOD get_dates.
****    IF go_DATE IS NOT INITIAL.
****      IF sy-datum+0(6) > go_DATE+0(6).
*****        GET  PAST SALES ORDER
****        CALL FUNCTION 'MONTHS_BETWEEN_TWO_DATES' " count of number of moths b/w go live date and present date
****          EXPORTING
****            i_datum_bis = sy-datum
****            i_datum_von = go_DATE
****          IMPORTING
****            e_monate    = count_moths.
****        IF count_moths  >= 1.
****          CALL FUNCTION 'OIL_LAST_DAY_OF_PREVIOUS_MONTH' " get the last date of month
****            EXPORTING
****              i_date_old = sy-datum
****            IMPORTING
****              e_date_new = lv_date.
****          APPEND VALUE #( sign = 'I'  option = 'BT' low = go_DATE high = lv_date ) TO   lt_syrange.
****          IF  lt_syrange IS NOT INITIAL.
****            me->get_salesdata( IMPORTING le_date =  lt_syrange ). " sales DATA
****          ENDIF.
****          if lv_coumon > count_moths.
****          lv_coumon = lv_coumon - count_moths.
****          else.
****            lv_coumon = 1.
****
****          endif.
****          IF lv_coumon >= 1.    " get monts count is > 1 or not
****            me->get_moths( IMPORTING le_remonth = lv_coumon ). "get MVER  MOTHS DATA based on given months
****            me->get_mevr( )."GET MEVR GATA FOR AFTER SALES
****          ENDIF.
****        ENDIF.
****      ELSE.
****        IF lv_coumon > 1.
****          me->get_moths(
****      IMPORTING
****        le_remonth = lv_coumon
****    ).
****          me->get_mevr( ).
****        ENDIF.
****      ENDIF.
****    ENDIF.
  ENDMETHOD.
  METHOD get_salesdata.
*SELECT vbeln, fkart,a~ FROM vbrk INTO TABLE @DATA(lt_retrn)  WHERE fkart = @lv_return and fkdat IN @le_date.
    SORT lt_final ASCENDING BY matnr.
**    SELECT a~vbeln, a~fkart,a~sfakn, b~matnr, b~werks,a~fkdat,a~fksto, b~fkimg" get past sales data
**             FROM vbrk AS a INNER JOIN
**                  vbrp AS b ON a~vbeln = b~vbeln
**INTO TABLE @DATA(lt_pastmat)
**             FOR ALL ENTRIES IN @lt_final
**             WHERE  a~fkdat IN @le_date AND
***                    a~fksto NE 'X' AND
**                   b~matnr = @lt_final-matnr AND
**                   b~werks = @lt_final-werks.
***                   a~fkart NE @lv_return.
**    IF sy-subrc = 0.
**      SORT lt_pastmat ASCENDING BY vbeln.
**      LOOP AT lt_pastmat INTO DATA(wa_pst) WHERE fkart NE lv_return.
**        IF lt_pastsal IS NOT INITIAL.
**          READ TABLE lt_pastsal ASSIGNING FIELD-SYMBOL(<fs>) WITH KEY  matnr = wa_pst-matnr werks =  wa_pst-werks.
**          IF sy-subrc = 0.
**            READ TABLE lt_pastmat INTO DATA(wa_paren) WITH KEY sfakn = wa_pst-vbeln fkart = lv_return. " removing return data
**            IF sy-subrc = 0.
**              <fs>-fkimg = <fs>-fkimg + ( wa_pst-fkimg - wa_paren-fkimg ).
**            ELSE.
**              <fs>-fkimg  = <fs>-fkimg  + wa_pst-fkimg.
**            ENDIF.
**          ELSE.
**            READ TABLE lt_pastmat INTO wa_paren WITH KEY sfakn = wa_pst-vbeln fkart = lv_return.
**            IF sy-subrc = 0.
**              wa_pst-fkimg =  wa_pst-fkimg - wa_paren-fkimg .
**              APPEND VALUE #( matnr = wa_pst-matnr werks =  wa_pst-werks fkimg =  wa_pst-fkimg ) TO lt_pastsal.
**            ELSE.
**              APPEND VALUE #( matnr = wa_pst-matnr werks =  wa_pst-werks fkimg =  wa_pst-fkimg ) TO lt_pastsal.
**            ENDIF.
**          ENDIF.
**        ELSE.
**          READ TABLE lt_pastmat INTO wa_paren WITH KEY sfakn = wa_pst-vbeln fkart = lv_return.
**          IF sy-subrc = 0.
**            wa_pst-fkimg = wa_pst-fkimg  - wa_paren-fkimg.
**            APPEND VALUE #( matnr = wa_pst-matnr werks =  wa_pst-werks fkimg =  wa_pst-fkimg ) TO lt_pastsal.
**          ELSE.
**            APPEND VALUE #( matnr = wa_pst-matnr werks =  wa_pst-werks fkimg =  wa_pst-fkimg ) TO lt_pastsal.
**          ENDIF.
**        ENDIF.
**      ENDLOOP.
**    ENDIF.

    SELECT  matnr, werks ,  fklmg  INTO TABLE @DATA(lt_pastsal1) FROM vbrp
      FOR ALL ENTRIES IN @lt_final
      WHERE   prsdt IN @le_date   AND sfakn_ana = ' ' AND vf_status_ana NE 'C'  AND matnr = @lt_final-matnr
       AND werks = @lt_final-werks   ." GROUP BY matnr, werks, fklmg.

   loop at lt_pastsal1 into data(tmp_pastsa).
     COLLECT tmp_pastsa INTO lt_pastsal.
   endloop.
  ENDMETHOD.
  METHOD get_mevr.
    lt_years  = VALUE #( FOR ls_year IN lt_months
               ( sign = 'I' option = 'EQ' low = ls_year-year ) ).
    SELECT matnr,werks,gjahr,perkz,zahlr,mgv01,
               mgv02,mgv03,mgv04,mgv05,mgv06,mgv07,
               mgv08,mgv09,mgv10,mgv11,mgv12,mgv13
              FROM mver INTO TABLE @DATA(lt_mver)
              FOR ALL ENTRIES IN @lt_final  WHERE matnr = @lt_final-matnr AND
                              werks = @lt_final-werks AND
                              perkz = 'M' AND
                              gjahr IN @lt_years .
    IF sy-subrc = 0.
      SORT lt_mver ASCENDING BY matnr.
      LOOP AT lt_mver INTO DATA(wa_material).
        READ TABLE lt_months INTO DATA(wa_mo) WITH KEY year = wa_material-gjahr.
        IF sy-subrc = 0.
          IF wa_mo-month CS 'JAN'.
            total = total + wa_material-mgv01.
          ENDIF.
          IF wa_mo-month CS 'FEB'.
            total = total + wa_material-mgv02.
          ENDIF.
          IF wa_mo-month CS 'MAR'.
            total = total + wa_material-mgv03.
          ENDIF.
          IF wa_mo-month CS 'APR'.
            total = total + wa_material-mgv04.
          ENDIF.
          IF wa_mo-month CS 'MAY'.
            total = total + wa_material-mgv05.
          ENDIF.
          IF wa_mo-month CS 'JUN'.
            total = total + wa_material-mgv06.
          ENDIF.
          IF wa_mo-month CS 'Jul'.
            total = total + wa_material-mgv07.
          ENDIF.
          IF wa_mo-month CS 'AUG'.
            total = total + wa_material-mgv08.
          ENDIF.
          IF wa_mo-month CS 'SEP'.
            total = total + wa_material-mgv09.
          ENDIF.
          IF wa_mo-month CS 'OCT'.
            total = total + wa_material-mgv10.
          ENDIF.
          IF wa_mo-month CS 'NOV'.
            total = total + wa_material-mgv11.
          ENDIF.
          IF wa_mo-month CS 'DEC'.
            total = total + wa_material-mgv12.
          ENDIF.
        ENDIF.

        wa_tabtot-matnr = wa_material-matnr.
        wa_tabtot-werks = wa_material-werks.
        wa_tabtot-total = total.
        COLLECT wa_tabtot INTO lt_tabtot.

*        APPEND VALUE #(  matnr = wa_material-matnr
*         werks = wa_material-werks
*         total   = total ) TO  lt_tabtot.
        CLEAR: total,wa_material.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  METHOD get_finaldata.

       DATA : lt_golive TYPE STANDARD TABLE OF zmm_golive.
       SELECT * FROM zmm_golive INTO TABLE lt_golive.
  data lv_fklmg type fklmg.

    SORT lt_final ASCENDING BY matnr.
    LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<fs>).
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs> TO FIELD-SYMBOL(<fs_matnr>).
      ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs> TO FIELD-SYMBOL(<fs_WERKS>).
      ASSIGN COMPONENT 'MATKL' OF STRUCTURE <fs> TO FIELD-SYMBOL(<fs_MATKL>).
*
******      TRY.
******          DATA(bill_qty) = lt_pastsal[ matnr = <fs_matnr> werks = <fs_WERKS> ]-fkimg.
******        CATCH cx_sy_itab_line_not_found.
******          clear bill_qty.
******      ENDTRY.
******      TRY.
******          DATA(cusme_qty) = lt_tabtot[ matnr = <fs_matnr> werks = <fs_WERKS>   ]-total.
******        CATCH cx_sy_itab_line_not_found.
******          clear cusme_qty.
******      ENDTRY.


       READ TABLE lt_golive INTO DATA(lw_golive) WITH KEY werks = <fs_WERKS>
                                                       matkl = <fs_MATKL>.
       if sy-subrc = 0.
         CALL FUNCTION 'ZMM_SALES_HISTORY'
           EXPORTING
             matnr            = <fs_matnr>
             werks            = <fs_WERKS>
            MONTHS           = lv_coumon
            GOLIVEDATE       = lw_golive-GOLIVE_DATE
          IMPORTING
            FKLMG            = lv_fklmg.
       DIVIDE lv_fklmg by lv_coumon.

       endif.
      TRY.
          lt =  lt_mrppl[ werks = <fs_WERKS> ]-pdt.
          lt = lt / 30.
        CATCH cx_sy_itab_line_not_found.
          lt = 1.
      ENDTRY.
      ASSIGN COMPONENT 'MAABC' OF STRUCTURE <fs> TO FIELD-SYMBOL(<fs_MAABC>).
      TRY.
          DATA(slf) = lt_mrpssf[ werks = <fs_WERKS>  maabc = <fs_MAABC> ]-serpv.
        CATCH cx_root.
          slf = 1.
      ENDTRY.
      IF  lt = 0 OR lt = 1.
        lt = 1.
      ENDIF.
      IF slf = 0 OR slf = 1.
        slf = 1.
      ENDIF.
*      ssf = lt * ( ( bill_qty + cusme_qty ) / lv_coumon  ) * slf.
      ssf = lt *  lv_fklmg  * slf.
*      valu = ssf.
*      data(lv_ss) = round( val = valu dec = 2 ).

      lv_ss = round( val = ssf dec = 0 ).
*       ssf = ssf / 10.

      ASSIGN COMPONENT 'EISBE' OF STRUCTURE <fs> TO FIELD-SYMBOL(<fs_EISBE>).
      <fs_EISBE> = lv_ss.

      clear lv_fklmg.
    ENDLOOP.
  ENDMETHOD.
  METHOD get_moths.
    IF  sy-datum+0(6) > go_DATE+0(6). " get
      DATA(lv_premoth)  = go_date+4(2).
    ELSE.
      lv_premoth = sy-datum+4(2).
    ENDIF.
    DATA(lv_goyear) = go_date+0(4).
    DO le_remonth TIMES.
      IF le_remonth = 0 .
        EXIT.
      ENDIF.
      IF lv_goyear = sy-datum+0(4).
        IF lv_premoth > 1.
          DATA(lv_getmoth) = lv_premoth - 1.
          lv_premoth = lv_getmoth.
        ELSE.
          lv_goyear = lv_goyear - 1.
          lv_premoth = 12.
          lv_getmoth = lv_premoth.
        ENDIF.
      ELSE.
        IF lv_premoth >  1.
          lv_getmoth = lv_premoth - 1.
          lv_premoth = lv_getmoth.
        ELSE.
          lv_goyear = lv_goyear - 1.
          lv_premoth = 12.
          lv_getmoth = lv_premoth.
        ENDIF.
      ENDIF.
      CASE lv_getmoth.
        WHEN 1.
          DATA(lv_mon) = 'JAN'.
        WHEN 2.
          lv_mon = 'FEB'.
        WHEN 3.
          lv_mon = 'MAR'.
        WHEN 4.
          lv_mon = 'APR'.
        WHEN 5.
          lv_mon = 'MAY'.
        WHEN 6.
          lv_mon = 'JUN'.
        WHEN 7.
          lv_mon = 'Jul'.
        WHEN 8.
          lv_mon = 'AUG'.
        WHEN 9.
          lv_mon = 'SEP'.
        WHEN 10.
          lv_mon = 'OCT'.
        WHEN 11.
          lv_mon = 'NOV'.
        WHEN 12.
          lv_mon = 'DEC'.
      ENDCASE.
      IF lt_months IS NOT INITIAL.
        READ TABLE lt_months INTO DATA(wa_monts) WITH KEY year = lv_goyear.
        IF sy-subrc = 0.
          CONCATENATE wa_monts-month lv_mon INTO wa_monts-month.
          MODIFY  lt_months FROM wa_monts INDEX sy-tabix.
        ELSE.
          APPEND VALUE #( month = lv_mon year =    lv_goyear  ) TO lt_months.
        ENDIF.
      ELSE.
        APPEND VALUE #( month = lv_mon year =    lv_goyear  ) TO lt_months.
      ENDIF.
    ENDDO.
  ENDMETHOD.
  METHOD display_update.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = DATA(lo_table)
          CHANGING
            t_table      = lt_final ).
      CATCH cx_salv_msg.
    ENDTRY.
    lv_functions = lo_table->get_functions( ).
    lv_functions->set_all( abap_true ).
    lo_table->display( ).
  ENDMETHOD.
  METHOD update.
    MOVE-CORRESPONDING lt_final TO lt_final_t.
    DELETE FROM ymm_ssf.

*    IF sy-subrc = 0.
*    COMMIT WORK AND WAIT.
      MODIFY ymm_ssf FROM TABLE  lt_final_t.
      COMMIT WORK.
      IF sy-subrc = 0.
        SELECT matnr,werks,eisbe FROM ymm_ssf INTO TABLE @DATA(lt_fin).
        IF sy-subrc = 0.
          DATA(lo_tabledesc) = CAST cl_abap_tabledescr(
                            cl_abap_tabledescr=>describe_by_data( p_data = lt_fin ) )." Create table in heap memory and set return reference
          CREATE DATA rr_tabud TYPE HANDLE lo_tabledesc.
          FIELD-SYMBOLS <lt_datatable> LIKE lt_fin. " Create a field-symbol...
          ASSIGN  rr_tabud->* TO <lt_datatable>.    " because append doesn't work with references
          APPEND LINES OF lt_fin TO <lt_datatable>.
        ENDIF.
      ENDIF.
*    ENDIF.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*& Include          YABC_I_CLASSIFICATION_CLS_IMP
*&---------------------------------------------------------------------*
CLASS lcl_abc_main IMPLEMENTATION.
  METHOD constructor.
    gv_user = sy-uname.

    SELECT SINGLE
           low
      FROM tvarvc
      INTO @DATA(lv_golvidate)
     WHERE name = 'ZABC_GOLIVE'
      AND  type = 'P'.
    IF sy-subrc = 0.

      SELECT SINGLE
             low
        FROM tvarvc
        INTO @DATA(lv_factor)
       WHERE name = 'ZABC_FACTOR'
        AND  type = 'P'.
      IF sy-subrc NE 0.
        MESSAGE 'Configuration not found: ZABC_FACTOR' TYPE 'E'.
      ENDIF.


      SELECT SINGLE
            low
       FROM tvarvc
       INTO @DATA(lv_div)
      WHERE name = 'ZABC_DIV'
       AND  type = 'P'.
      IF sy-subrc NE 0.
        MESSAGE 'Configuration not found: ZABC_DIV' TYPE 'E'.
      ENDIF.

      TRY.
          CONCATENATE lv_golvidate+6(4)  lv_golvidate+3(2)  lv_golvidate+0(2) INTO me->gv_golive.
          MOVE: lv_factor TO me->gv_factor,
               lv_div    TO me->gv_div.

        CATCH:cx_root INTO DATA(oerror).

          MESSAGE 'Configuration not Correct Please check!!' TYPE 'E'.

      ENDTRY.



      SELECT *  FROM yabc INTO TABLE me->gt_custom_abc.
    ELSE.

      MESSAGE 'Configuration not found: ZABC_GOLIVE' TYPE 'E'.
    ENDIF.

    me->gv_fmonth = 3.
    me->gv_smonth = 3.



  ENDMETHOD.
  METHOD display_update.
    DATA: lv_functions TYPE REF TO cl_salv_functions.


    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = DATA(lo_table)
          CHANGING
            t_table      = it_table ).
      CATCH cx_salv_msg.
    ENDTRY.
    lv_functions = lo_table->get_functions( ).
    lv_functions->set_all( abap_true ).
    lo_table->display( ).

  ENDMETHOD.
  METHOD upload_file.
    " Your upload_file logic remains unchanged
    DATA: lv_filename TYPE  string,
          it_bin_data TYPE w3mimetabtype,
          lv_filesize TYPE w3param-cont_len.

    DATA: lv_material TYPE matnr,
          lv_plant    TYPE werks_d,
          lv_abc      TYPE maabc.

    DATA: lt_final_abc TYPE STANDARD TABLE OF ty_final_abc.

    lv_filename = p_file.

    cl_gui_frontend_services=>gui_upload(
  EXPORTING
    filename                =  lv_filename
    filetype                = 'BIN'
  IMPORTING
    filelength              = lv_filesize
  CHANGING
    data_tab                =  it_bin_data
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
    IF sy-subrc NE 0.

    ENDIF.

    DATA(lv_bin_data) = cl_bcs_convert=>solix_to_xstring(
                            it_solix   = it_bin_data ).

    DATA(o_excel) = NEW cl_fdt_xl_spreadsheet(
        document_name     =  lv_filename
        xdocument         = lv_bin_data ).

    DATA: it_worksheet_name TYPE if_fdt_doc_spreadsheet=>t_worksheet_names.

    o_excel->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING
        worksheet_names = it_worksheet_name ).


    IF lines( it_worksheet_name ) > 0.

      DATA(o_worksheet_itab)  = o_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
           it_worksheet_name[ 1 ] ).


      ASSIGN o_worksheet_itab->* TO FIELD-SYMBOL(<fs_worksheet>).

      LOOP AT <fs_worksheet> ASSIGNING FIELD-SYMBOL(<wa>) .

        IF sy-tabix > 1.
          ASSIGN COMPONENT 1 OF STRUCTURE <wa> TO FIELD-SYMBOL(<fs_matnr>).

          lv_material  = <fs_matnr>.

          ASSIGN COMPONENT 2 OF STRUCTURE <wa> TO FIELD-SYMBOL(<fs_plant>).
          lv_plant  = <fs_plant>.

          lv_material  = |{ lv_material ALPHA = IN }|.

          ASSIGN COMPONENT 3 OF STRUCTURE <wa> TO FIELD-SYMBOL(<fs_abc>).
          lv_abc  = <fs_abc>.


          me->update_material( EXPORTING iv_material = lv_material
                               iv_plant   = lv_plant
                               iv_abc_id  = lv_abc
                               IMPORTING
                                ev_maabc  = DATA(lv_abc_actual)
                                ev_error  = DATA(lv_error)
                             ).


          APPEND VALUE #( material   = lv_material
                          werks      = lv_plant
                          abc_actual = lv_abc_actual
                          abc_target = lv_abc
                          error      = lv_error )
                       TO lt_final_abc.

        ENDIF.
      ENDLOOP.

      go_abc_main->display_update( CHANGING it_table = lt_final_abc ).

    ENDIF.


  ENDMETHOD.

  METHOD update_data.

    DATA: lv_abc_target TYPE maabc,
          lt_final_abc  TYPE STANDARD TABLE OF ty_final_abc.
    DATA : lt_golive TYPE STANDARD TABLE OF zmm_golive.

    SELECT * FROM zmm_golive INTO TABLE lt_golive.

**   Get Materials
    SELECT *
      FROM yi_abc_classification
      INTO TABLE @DATA(lt_materials)
     WHERE matnr IN @s_matnr
       AND matkl IN @s_matkl
       AND werks IN @s_werks
       AND maabc IN @s_maabc.

***Calculate the ABC
    LOOP AT lt_materials ASSIGNING FIELD-SYMBOL(<fs_material>).

      READ TABLE lt_golive INTO DATA(ls_golive) WITH KEY werks = <fs_material>-werks matkl = <fs_material>-matkl.
      IF sy-subrc = 0.
        me->gv_golive = ls_golive-golive_date.

*Calculate dates
        me->calculate_dates( IMPORTING
                             ev_count_agl       = DATA(lv_count_agl)
                             ev_count_bgl       = DATA(lv_count_bgl)
                             et_dates_intervel  = DATA(lr_dates)
                             et_dates_legacy    = DATA(lr_dates_legacy)
                             er_dates_first_3m  = DATA(lt_first_3m)
                             er_dates_secod_3m  = DATA(lt_second_3m)
                             ).
      ENDIF.
*Get Salse data
      IF lv_count_agl > 0.
*   first 3 months
        IF lines( lt_first_3m ) > 0.
          me->get_salesdata(
               EXPORTING
               iv_material   = <fs_material>-matnr
               iv_plant      = <fs_material>-werks
               ir_period     = lt_first_3m
               IMPORTING
               es_salse_data = DATA(ls_salse_data_first)
             ).
        ENDIF.

*  next 3 months
        IF lines( lt_second_3m ) > 0.
          me->get_salesdata(
               EXPORTING
               iv_material   = <fs_material>-matnr
               iv_plant      = <fs_material>-werks
               ir_period     = lt_second_3m
               IMPORTING
               es_salse_data = DATA(ls_salse_data_second)

             ).
        ENDIF.


      ENDIF.

*Get legecy data MVER
      IF lv_count_bgl > 0. " Any Legecy Data

        me->get_mevr( EXPORTING
                       iv_material     = <fs_material>-matnr
                       iv_plant        = <fs_material>-werks
                       it_dates_legacy = lr_dates_legacy
                       v_count_agl     = lv_count_agl
                     IMPORTING
                       es_legacy_f3m = DATA(ls_legacy_f3m)
                       es_legacy_s3m = DATA(ls_legacy_s3m)
                      ).

      ENDIF.

** Calculate the Sales factor
* Last three months sale quantity needs to multiple with 2 (the factor 2 need to maintain in STVARVC
*((last 3 months sales) *2 + (last before 3 months sales)) and / divided by 9
*((Sale of April + Sale of March + Sale of Feb) * 2) + (Sale of Jan + Sale of Dec + Sale of NOV)) / 9
*
*Exp: ((10+24+23) *2 + (13+15+18))/9 = (57*2 + 46) =114+46 = (160)/9 = 6
      DATA lv_factor TYPE i.

*******      IF lv_count_bgl = 0.
********
*********        lv_factor = ls_salse_data_first-fklmg * 2 + ( ls_salse_data_second-fklmg / 9 ).
*********        lv_factor = ls_salse_data_first-fklmg * me->gv_factor + ( ls_salse_data_second-fklmg / me->gv_div ).
*******        lv_factor = ls_salse_data_first-fklmg * me->gv_div + ( ls_salse_data_second-fklmg /  me->gv_factor ).
*******
*******      ELSE.
*********        lv_factor = ( ls_salse_data_first-fklmg + ls_legacy_f3m-fklmg ) * 2 + ( ( ls_salse_data_second-fklmg + ls_legacy_s3m-fklmg ) / 9 ).
*********        lv_factor = ( ls_salse_data_first-fklmg + ls_legacy_f3m-fklmg ) * me->gv_factor + ( ( ls_salse_data_second-fklmg + ls_legacy_s3m-fklmg ) / me->gv_div ).
*******        lv_factor = ( ( ls_salse_data_first-fklmg  + ls_legacy_f3m-fklmg ) * me->gv_div +
*******                    ( ( ls_salse_data_second-fklmg + ls_legacy_s3m-fklmg ) /  me->gv_factor ) ).
*******
*******      ENDIF.
*lv_factor = ( ls_salse_data_first-fklmg * me->gv_div ) + ( ls_legacy_f3m-fklmg / me->gv_factor ).


      IF lv_count_bgl = 0.
        lv_factor = ( ( ls_salse_data_first-fklmg * me->gv_div ) +  ls_salse_data_second-fklmg ) /  me->gv_factor .
      ELSE.
*        lv_factor = ( ( ls_salse_data_first-fklmg + ls_legacy_f3m-fklmg  * me->gv_div ) +  ls_salse_data_second-fklmg + ls_legacy_s3m-fklmg ) /  me->gv_factor .
        lv_factor = ( ( ( ( ls_salse_data_first-fklmg + ls_legacy_f3m-fklmg )  * me->gv_div ) ) +  ls_salse_data_second-fklmg + ls_legacy_s3m-fklmg ) /  me->gv_factor .
      ENDIF.
*      ENDIF.
***Get target ABC

*       lv_abc_target = 'Z'.

      IF lv_factor > 99 . "Set to max Number
        lv_factor = 99.
      ENDIF.
      LOOP AT me->gt_custom_abc ASSIGNING FIELD-SYMBOL(<fs_custom_abc_deter>)
                                    WHERE werks        EQ <fs_material>-werks
                                      AND from_soldqty LE lv_factor
                                      AND to_soldqty   GE lv_factor.

        lv_abc_target = <fs_custom_abc_deter>-maabc.
        EXIT.

      ENDLOOP.


**** Update MAterial ABC

      IF cb_sim EQ abap_false AND <fs_material>-maabc NE lv_abc_target.

        me->update_material( EXPORTING iv_material = <fs_material>-matnr
                               iv_plant   = <fs_material>-werks
                               iv_abc_id  = lv_abc_target
                               IMPORTING
                                ev_error  = DATA(lv_error)
                             ).

      ENDIF.

      APPEND VALUE #( material   = <fs_material>-matnr
                      werks      = <fs_material>-werks
                      abc_actual = <fs_material>-maabc
                      abc_target = lv_abc_target
                      error      = lv_error ) TO lt_final_abc.


      CLEAR: ls_salse_data_first,
             ls_salse_data_second,
             lv_abc_target,
             lv_factor.
      CLEAR : lr_dates_legacy,lv_count_agl,lv_count_bgl,lr_dates,lt_first_3m,lt_second_3m.

    ENDLOOP.

    go_abc_main->display_update( CHANGING it_table = lt_final_abc ).


  ENDMETHOD.
  METHOD calculate_dates.
    DATA lv_golive TYPE sy-datum.
    DATA:ls_dates_intervel TYPE ty_dates_intervel,

         lv_date_curr      TYPE sy-datum,
*         lv_date_today     TYPE sy-datum,
         lv_first_day      TYPE sy-datum,
         lv_last_day       TYPE sy-datum,
         lv_totalmonths    TYPE i.



*Get first day of the current month

    CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
      EXPORTING
        i_date      = sy-datum "lv_new_date
      IMPORTING
        e_first_day = lv_first_day
      EXCEPTIONS
        wrong_date  = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
*     Implement suitable error handling here
    ENDIF.


**
*    IF me->gv_golive+0(6) >= sy-datum+0(6).
    IF me->gv_golive+0(6) = sy-datum+0(6).
      ev_count_bgl = 1.
    ENDIF.
    lv_golive = me->gv_golive - 1.

*Calculate the  6 months Date intervels

    lv_totalmonths = gv_fmonth + gv_smonth.

    DO lv_totalmonths TIMES.
*    DO 6 TIMES.

      CALL FUNCTION 'UJD_ADD_MONTH_TO_DATE'
        EXPORTING
          i_months   = -1
          i_old_date = lv_first_day
        IMPORTING
          e_new_date = lv_date_curr.

      IF lv_golive+4(2)  = lv_date_curr+4(2) AND lv_golive+0(4) = lv_date_curr+0(4).
*      IF me->gv_golive+4(2)  = lv_date_curr+4(2) AND me->gv_golive+0(4) = lv_date_curr+0(4).
        ADD 1 TO ev_count_bgl.
      ELSE.
        IF ev_count_bgl NE 0 .
          ADD 1 TO ev_count_bgl.
        ELSE.
          ADD 1 TO ev_count_agl  .
        ENDIF.
      ENDIF.

      ls_dates_intervel-date_year = lv_date_curr+0(4).
      ls_dates_intervel-date_mon = lv_date_curr+4(2).
      ls_dates_intervel-date_from = lv_date_curr .
      CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
        EXPORTING
          i_date     = lv_date_curr
        IMPORTING
*         e_first_day = e_first_day
          e_last_day = ls_dates_intervel-date_to
        EXCEPTIONS
          wrong_date = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


      APPEND ls_dates_intervel TO et_dates_intervel.

      CLEAR:ls_dates_intervel.

      lv_first_day = lv_date_curr.


    ENDDO.

*   IF me->gv_golive+0(6) >= sy-datum+0(6).
    IF me->gv_golive+0(6) = sy-datum+0(6).
      SUBTRACT 1 FROM ev_count_bgl.
    ENDIF.


    LOOP AT et_dates_intervel INTO ls_dates_intervel .

      IF sy-tabix = ev_count_agl + 1 AND ev_count_agl NE 0.
*      IF sy-tabix = ev_count_agl + 2 AND ev_count_agl NE 0.
        APPEND ls_dates_intervel TO et_dates_legacy .
      ELSEIF et_dates_legacy IS NOT INITIAL OR ev_count_agl EQ 0.
        APPEND ls_dates_intervel TO et_dates_legacy .
      ENDIF.


    ENDLOOP.

    IF ev_count_agl >= 3.

      APPEND VALUE #( sign   = 'I'
                      option = 'BT'
                      low    = et_dates_intervel[ gv_fmonth ]-date_from
                      high   = et_dates_intervel[ 1 ]-date_to )
                 TO er_dates_first_3m.


*      WRITE:/ 'Intervel 1:' , et_dates_intervel[ 3 ]-date_from, ':', et_dates_intervel[ 1 ]-date_to.

      IF ev_count_agl - ev_count_bgl > 0.



        APPEND VALUE #( sign = 'I' option = 'BT'
                        low  = et_dates_intervel[ ev_count_agl ]-date_from
                        high = et_dates_intervel[ gv_fmonth + 1 ]-date_to )
                    TO er_dates_secod_3m.

      ENDIF.

    ELSEIF ev_count_agl > 0.
      APPEND VALUE #( sign = 'I' option = 'BT' low = et_dates_intervel[ ev_count_agl ]-date_from high = et_dates_intervel[ 1 ]-date_to ) TO er_dates_first_3m.


    ENDIF.



  ENDMETHOD.

  METHOD get_salesdata.
    DATA it_mararc TYPE STANDARD TABLE OF yi_abc_classification.
*
    CLEAR es_salse_data.  "Clearing

*    SELECT SINGLE
*           b~matnr AS matnr,
*           b~werks AS werks,
*           SUM( b~fklmg ) AS fklmg  " get past sales data
*      INTO @es_salse_data
*      FROM vbrk AS a INNER JOIN
*           vbrp AS b ON a~vbeln = b~vbeln
*     WHERE a~fkdat IN @ir_period
**       AND a~fksto EQ ''
*       AND b~matnr = @iv_material
*       AND b~werks = @iv_plant
*  GROUP BY b~matnr,
*           b~werks.
*
*** Cancel data
*    SELECT SINGLE
*           b~matnr AS matnr,
*           b~werks AS werks,
*           SUM( b~fklmg ) AS fklmg  " get past sales data
*      INTO @DATA(ls_salse_data_c)
*      FROM vbrk AS a INNER JOIN
*           vbrp AS b ON a~vbeln = b~vbeln
*     WHERE a~fkdat IN @ir_period
*       AND a~fksto EQ 'X'
*       AND b~matnr = @iv_material
*       AND b~werks = @iv_plant
*  GROUP BY b~matnr,
*           b~werks.
*    es_salse_data-fklmg = es_salse_data-fklmg -  ls_salse_data_c-fklmg.
*********
    SELECT SINGLE matnr, werks , SUM( fklmg ) AS fklmg INTO @DATA(ls_salse_data_c) FROM vbrp
         WHERE   prsdt IN @ir_period  AND sfakn_ana = ' ' AND vf_status_ana NE 'C'  AND matnr = @iv_material
          AND werks = @iv_plant    GROUP BY matnr, werks. ", fklmg.
*    IF sy-subrc = 0.
*      fklmg = es_salse_data-fklmg.
*    ENDIF.
    IF sy-subrc = 0 .
      es_salse_data-fklmg =  ls_salse_data_c-fklmg.

    ENDIF.


  ENDMETHOD.
  METHOD get_mevr.



    CLEAR: es_legacy_f3m,
           es_legacy_s3m.


    DATA: lr_years  TYPE RANGE OF char4,
          lv_sum    TYPE  fklmg,
          it_mararc TYPE STANDARD TABLE OF yi_abc_classification.

    IF it_dates_legacy IS INITIAL.
      RETURN.
    ENDIF.




    DATA(lt_dates) = it_dates_legacy.


    SORT lt_dates BY date_year.

    DELETE ADJACENT DUPLICATES FROM lt_dates COMPARING date_year.

    lr_years  = VALUE #( FOR ls_year IN lt_dates
                ( sign = 'I' option = 'EQ' low = ls_year-date_year ) ).

    SELECT matnr,
           werks,
           gjahr,
           perkz,
           zahlr,
           mgv01,
           mgv02,
           mgv03,
           mgv04,
           mgv05,
           mgv06,
           mgv07,
           mgv08,
           mgv09,
           mgv10,
           mgv11,
           mgv12,
           mgv13
      FROM mver
      INTO TABLE @DATA(lt_mver)
     WHERE matnr = @iv_material
       AND werks = @iv_plant
       AND gjahr IN @lr_years
       AND perkz = 'M'.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    SORT lt_mver BY matnr
                    werks
                    gjahr DESCENDING.


    DESCRIBE TABLE it_dates_legacy  LINES DATA(lv_total_months).
*    lv_total_months = lv_total_months - V_COUNT_AGL.

*    es_legacy_f3m-material = iv_material.
*    es_legacy_f3m-werks    = iv_plant.
*
*    IF lv_total_months > 3.
*
*      es_legacy_s3m-material = iv_material.
*      es_legacy_s3m-werks    = iv_plant.
*    ENDIF.

    DATA: lv_count_months  TYPE i.

    lv_count_months =  v_count_agl.





    LOOP AT it_dates_legacy ASSIGNING FIELD-SYMBOL(<fs_dates_legacy>).
*                                  WHERE date_year = <fs_mver>-gjahr .
*LOOP AT lt_mver ASSIGNING FIELD-SYMBOL(<fs_mver>)
*                                   where gjahr = <fs_dates_legacy>-date_year.
      READ TABLE lt_mver ASSIGNING FIELD-SYMBOL(<fs_mver>) WITH KEY gjahr = <fs_dates_legacy>-date_year.
*    LOOP AT lt_mver ASSIGNING FIELD-SYMBOL(<fs_mver>).
*
*
*      LOOP AT it_dates_legacy ASSIGNING FIELD-SYMBOL(<fs_dates_legacy>)
*                                  WHERE date_year = <fs_mver>-gjahr .
      IF sy-subrc = 0.
        CASE <fs_dates_legacy>-date_mon.
          WHEN 12.
            lv_sum = <fs_mver>-mgv12.
          WHEN 11.
            lv_sum = <fs_mver>-mgv11.
          WHEN 10.
            lv_sum = <fs_mver>-mgv10.
          WHEN 09.
            lv_sum = <fs_mver>-mgv09.
          WHEN 08.
            lv_sum = <fs_mver>-mgv08.
          WHEN 07.
            lv_sum = <fs_mver>-mgv07.
          WHEN 06.
            lv_sum = <fs_mver>-mgv06.
          WHEN 05.
            lv_sum = <fs_mver>-mgv05.
          WHEN 04.
            lv_sum = <fs_mver>-mgv04.
          WHEN 03.
            lv_sum = <fs_mver>-mgv03.
          WHEN 02.
            lv_sum = <fs_mver>-mgv02.
          WHEN 01.
            lv_sum = <fs_mver>-mgv01.
        ENDCASE.
      ENDIF.
      ADD  1 TO lv_count_months.
      IF lv_count_months LE 3.
        es_legacy_f3m-fklmg = es_legacy_f3m-fklmg + lv_sum.
        es_legacy_f3m-material = iv_material.
        es_legacy_f3m-werks    = iv_plant.
      ELSE.
        es_legacy_s3m-fklmg = es_legacy_s3m-fklmg + lv_sum.
        es_legacy_s3m-material = iv_material.
        es_legacy_s3m-werks    = iv_plant.
      ENDIF.

*      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.
  METHOD update_material.


    DATA: ls_get_marahed    TYPE bapi_mara_ga,
          ls_get_marcpla    TYPE bapi_marc_ga,
          lv_material_bapi  TYPE bapi_mara_ga-material,

          lv_eislo          TYPE werks_d,
          lt_return         TYPE TABLE OF bapi_matreturn2,
          ls_bapimatrhead   TYPE bapimathead,
          ls_bapiplantdata  TYPE bapi_marc,
          ls_bapiplantdatax TYPE bapi_marcx.

    lv_material_bapi = iv_material.

    CALL FUNCTION 'BAPI_MATERIAL_GET_ALL'
      EXPORTING
        material   = lv_material_bapi
        plant      = iv_plant
      IMPORTING
        clientdata = ls_get_marahed
        plantdata  = ls_get_marcpla.

    MOVE-CORRESPONDING ls_get_marahed TO  ls_bapimatrhead.
    MOVE-CORRESPONDING ls_get_marcpla TO  ls_bapiplantdata.

    CLEAR: ls_get_marahed,ls_get_marcpla.


    ls_bapiplantdatax-plant =
    ls_bapiplantdata-plant  =  iv_plant.

    ev_maabc = ls_bapiplantdata-abc_id. "Old ABC Indicator
    ls_bapiplantdata-abc_id = iv_abc_id.

    MOVE abap_true TO:ls_bapiplantdatax-abc_id.

    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata       = ls_bapimatrhead
        plantdata      = ls_bapiplantdata
        plantdatax     = ls_bapiplantdatax
      TABLES
        returnmessages = lt_return.

    IF lt_return IS NOT INITIAL AND ( lt_return[ 1 ]-type EQ 'E' OR lt_return[ 1 ]-type  EQ 'A').

      ev_error = lt_return[ 1 ]-type.

    ELSE.

*      ev_error = lt_return[ 1 ]-type.
      ev_error = 'S'.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

    ENDIF.





  ENDMETHOD.

  METHOD display_report.

    IF me->go_ida IS NOT BOUND.

      me->go_ida = cl_salv_gui_table_ida=>create_for_cds_view( iv_cds_view_name = `YI_ABC_CLASSIFICATION` ).

    ENDIF.
    me->applyfilter( ).

    me->go_ida->fullscreen( )->display( ).

  ENDMETHOD.
  METHOD applyfilter.

    DATA(lo_selectoptions) = NEW cl_salv_range_tab_collector( ).
    lo_selectoptions->add_ranges_for_name( iv_name = 'MATNR' it_ranges = s_matnr[] ).
    lo_selectoptions->add_ranges_for_name( iv_name = 'MATKL' it_ranges = s_matkl[] ).
    lo_selectoptions->add_ranges_for_name( iv_name = 'MAABC' it_ranges = s_maabc[] ).
    lo_selectoptions->add_ranges_for_name( iv_name = 'WERKS' it_ranges = s_werks[] ).

    lo_selectoptions->get_collected_ranges( IMPORTING et_named_ranges = DATA(lt_name_ranges) ).

    me->go_ida->set_select_options( it_ranges = lt_name_ranges ).


  ENDMETHOD.
ENDCLASS.

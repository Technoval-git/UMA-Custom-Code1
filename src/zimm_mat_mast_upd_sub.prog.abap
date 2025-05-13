

FORM f_prepare_loaddata .


  FIELD-SYMBOLS : <gt_data_h> TYPE STANDARD TABLE,
                  <gt_data_l> TYPE ANY TABLE,
                  <gt_table>  TYPE STANDARD TABLE,
                  <gs_table>  TYPE any.
  DATA : lv_filename      TYPE string,
         lt_records       TYPE solix_tab,
         lv_headerxstring TYPE xstring,
         lv_filelength    TYPE i.

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
    "Implement suitable error handling here
  ENDIF.

  DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet .

  TRY .
      lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
        document_name = lv_filename
        xdocument     = lv_headerxstring ).
    CATCH cx_fdt_excel_core.
    CATCH  cx_sy_ref_is_initial INTO DATA(lv_catch_ref).
      DATA(lv_ref_tex) = lv_catch_ref->get_text( ).
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


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data .
  DATA: it_main_copy    TYPE TABLE OF ty_main,
        it_mat_wrkst    TYPE TABLE OF ty_mat_wrkst,
        lw_mat_wrkst    TYPE ty_mat_wrkst,
        lv_fhori(20)    TYPE c,
        lt_extensionin  TYPE STANDARD TABLE OF bapiparex,
        ts_extensionin  LIKE LINE OF lt_extensionin,
        lt_extensioninx TYPE STANDARD TABLE OF bapiparexx,
        ts_extensioninx LIKE LINE OF lt_extensioninx,
        lv_meins        TYPE meins.


  SELECT category  uname  werks FROM zmm_pc_autho INTO TABLE lt_autho WHERE uname = sy-uname.
  SORT lt_autho BY category werks.

  SELECT * FROM zmm_mat_constant INTO TABLE lt_zmm_mat_constant.
  LOOP AT lt_con INTO wa_con.
    lwa_main-matnr = wa_con-matnr.
    lwa_main-mtart = wa_con-mtart.
    lwa_main-werks = wa_con-werks.
    lwa_main-lgort = wa_con-lgort.
    lwa_main-lgnum = wa_con-lgnum.
    lwa_main-maktx = wa_con-maktx.
    lwa_main-maktx_a = wa_con-maktx_a.
    lwa_main-meins = wa_con-meins.
    lwa_main-matkl = wa_con-matkl.
    lwa_main-brgew = wa_con-brgew.
    lwa_main-ntgew = wa_con-ntgew.
    lwa_main-gewei = wa_con-gewei.
    lwa_main-groes = wa_con-groes.
    IF wa_con-spart = '0'.
      lwa_main-spart = '00'.
    ELSE.
      lwa_main-spart = wa_con-spart.
    ENDIF.

    lwa_main-aumng = wa_con-aumng.
    lwa_main-bismt = wa_con-bismt.
    lwa_main-xchpf = wa_con-xchpf.
    lwa_main-extwg = wa_con-extwg.
    lwa_main-mfrpn = wa_con-mfrpn.
    lwa_main-maabc = wa_con-maabc.
    lwa_main-eisbe = wa_con-eisbe.
    lwa_main-eislo = wa_con-eislo.
    lwa_main-plifz = wa_con-plifz.
    lwa_main-webaz = wa_con-webaz.
    lwa_main-bklas = wa_con-bklas.
    lwa_main-peinh = wa_con-peinh.
    lwa_main-verpr = wa_con-verpr.
    lwa_main-lgpbe = wa_con-lgpbe.
    lwa_main-vprsv = wa_con-vprsv.
    lwa_main-vkorg = wa_con-vkorg.
    lwa_main-vtweg = wa_con-vtweg.
    lwa_main-taxm1 = wa_con-taxm1.
    lwa_main-mbrsh = wa_con-mbrsh.
    lwa_main-kondm = wa_con-kondm.
    lwa_main-ktgrm = wa_con-ktgrm.
    lwa_main-mtpos = wa_con-mtpos.
    lwa_main-mtpos_d = wa_con-mtpos_d.
    lwa_main-mtvfp = wa_con-mtvfp.
    lwa_main-tragr = wa_con-tragr.
    lwa_main-ladgr = wa_con-ladgr.
    lwa_main-prctr = wa_con-prctr.
    lwa_main-mfrnr = wa_con-mfrnr.
    lwa_main-ekgrp = wa_con-ekgrp.
    lwa_main-disgr = wa_con-disgr.
    lwa_main-dismm = wa_con-dismm.
    lwa_main-minbe = wa_con-minbe.
    lwa_main-disls = wa_con-disls.
    lwa_main-dispo = wa_con-dispo.
    lwa_main-beskz = wa_con-beskz.
    lwa_main-wzeit = wa_con-wzeit.
    lwa_main-prmod = wa_con-prmod.
    lwa_main-perkz = wa_con-perkz.
    lwa_main-peran = wa_con-peran.
    lwa_main-anzpr = wa_con-anzpr.
    lwa_main-kzini = wa_con-kzini.
    lwa_main-bwtty = wa_con-bwtty.
    lwa_main-stprs = wa_con-stprs.



    IF lwa_main-mtart IS NOT INITIAL AND lwa_main-spart IS NOT INITIAL AND
       lwa_main-werks IS NOT INITIAL AND lwa_main-matkl IS NOT INITIAL.
      CLEAR: lwa_zmm_mat_constant.
      READ TABLE lt_zmm_mat_constant INTO lwa_zmm_mat_constant WITH KEY mtart = lwa_main-mtart
                                                                        matkl = lwa_main-matkl
                                                                        spart = lwa_main-spart.
      IF sy-subrc = 0.
        lwa_main-prctr = lwa_zmm_mat_constant-prctr.
        lwa_main-bklas = lwa_zmm_mat_constant-bklas.
      ENDIF.
    ENDIF.
    IF lwa_main-mtart IS NOT INITIAL AND lwa_main-spart IS NOT INITIAL AND lwa_main-matkl IS NOT INITIAL.
      CLEAR: lwa_zmm_mat_constant.
      READ TABLE lt_zmm_mat_constant INTO lwa_zmm_mat_constant WITH KEY mtart = lwa_main-mtart
                                                                        matkl = lwa_main-matkl
                                                                        spart = lwa_main-spart.
      IF sy-subrc = 0.
        lwa_main-ktgrm = lwa_zmm_mat_constant-ktgrm.
      ENDIF.
    ENDIF.

    lv_meins = lwa_main-meins.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = lwa_main-meins
      IMPORTING
        output         = lwa_main-meins
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF lwa_main-meins IS INITIAL.
      lwa_main-meins = lv_meins.
    ENDIF.


    CLEAR lwa_zmm_mat_constant.

    READ TABLE lt_zmm_mat_constant INTO lwa_zmm_mat_constant WITH KEY mtart = lwa_main-mtart
                                                                           matkl = lwa_main-matkl.

    IF sy-subrc = 0.
      IF lwa_main-mtvfp IS INITIAL.
        lwa_main-mtvfp = lwa_zmm_mat_constant-mtvfp.
      ENDIF.
      IF lwa_main-tragr IS INITIAL.
        lwa_main-tragr = lwa_zmm_mat_constant-tragr.
      ENDIF.
      IF lwa_main-ladgr IS INITIAL.
        lwa_main-ladgr = lwa_zmm_mat_constant-ladgr.
      ENDIF.
      IF lwa_main-bklas IS INITIAL.
        lwa_main-bklas = lwa_zmm_mat_constant-bklas.
      ENDIF.
      IF lwa_main-bwtty IS INITIAL.
        lwa_main-bwtty = lwa_zmm_mat_constant-bwtty.
      ENDIF.
      IF lwa_main-prctr IS INITIAL.
        lwa_main-prctr = lwa_zmm_mat_constant-prctr.
      ENDIF.
      IF lwa_main-ktgrm IS INITIAL.
        lwa_main-ktgrm = lwa_zmm_mat_constant-ktgrm.
      ENDIF.
      IF lwa_main-kondm IS INITIAL.
        lwa_main-kondm = lwa_zmm_mat_constant-kondm.
      ENDIF.
      IF lwa_main-dismm IS INITIAL.
        lwa_main-dismm = lwa_zmm_mat_constant-dismm.
      ENDIF.
      IF lwa_main-dispo IS INITIAL.
        lwa_main-dispo = lwa_zmm_mat_constant-dispo.
      ENDIF.
      IF lwa_main-disls IS INITIAL.
        lwa_main-disls = lwa_zmm_mat_constant-disls.
      ENDIF.
      IF lwa_main-prmod IS INITIAL.
        lwa_main-prmod = lwa_zmm_mat_constant-prmod.
      ENDIF.
      IF lwa_main-taxm1 IS INITIAL.
        lwa_main-taxm1 = lwa_zmm_mat_constant-taklv.
      ENDIF.
      IF lwa_main-gewgr IS INITIAL.
        lwa_main-gewgr = lwa_zmm_mat_constant-gewgr.
      ENDIF.

    ENDIF.


    PERFORM f_leading_zeros CHANGING lwa_main-tragr.
    PERFORM f_leading_zeros CHANGING lwa_main-mtvfp.
    PERFORM f_leading_zeros CHANGING lwa_main-ladgr.
    PERFORM f_leading_zeros CHANGING lwa_main-prctr.
    PERFORM f_leading_zeros CHANGING lwa_main-kondm.
    PERFORM f_leading_zeros CHANGING lwa_main-ktgrm.
    PERFORM f_leading_zeros CHANGING lwa_main-vtweg.
    PERFORM f_leading_zeros CHANGING lwa_main-fhori.

    IF lwa_main IS NOT INITIAL.
      APPEND lwa_main TO lt_main.
    ENDIF.
    CLEAR lwa_main.
  ENDLOOP.

  it_main_copy = lt_main.
  SORT it_main_copy BY matnr mfrpn mfrnr.
  DELETE ADJACENT DUPLICATES FROM it_main_copy COMPARING matnr mfrpn mfrnr.
  DELETE it_main_copy WHERE mfrpn IS INITIAL
    AND mfrnr IS INITIAL.

  IF it_main_copy IS NOT INITIAL.
    SELECT matnr mfrpn mfrnr mhdhb FROM mara
           INTO TABLE lt_mat_data
           FOR ALL ENTRIES IN it_main_copy
           WHERE mfrpn EQ it_main_copy-mfrpn AND
                mfrnr EQ it_main_copy-mfrnr
            %_HINTS ORACLE 'INDEX("MARA" "MARA~MPN")'.    "#EC CI_HINTS
  ENDIF.

  CLEAR: it_main_copy.
  it_main_copy = lt_main.
  SORT it_main_copy BY wrkst.
  DELETE ADJACENT DUPLICATES FROM it_main_copy COMPARING wrkst.
  DELETE it_main_copy WHERE wrkst IS INITIAL.

  IF it_main_copy IS NOT INITIAL.
    SELECT matnr wrkst FROM mara
         INTO TABLE it_mat_wrkst
         FOR ALL ENTRIES IN it_main_copy
         WHERE wrkst EQ it_main_copy-wrkst.
  ENDIF.

  va_total_records = lines( lt_main ).
  DATA lt_zmm_mtart_ie TYPE STANDARD TABLE OF zmm_mtart_ie.
  DATA lw_zmm_mtart_ie TYPE zmm_mtart_ie.

  SELECT mtart intorext FROM zmm_mtart_ie INTO TABLE lt_zmm_mtart_ie.

  SORT lt_mat_data BY mfrpn mfrnr.

  LOOP AT lt_main INTO lwa_main.
    CLEAR lwa_zmm_mat_constant.

    READ TABLE lt_zmm_mat_constant INTO lwa_zmm_mat_constant WITH KEY mtart = lwa_main-mtart
                                                                           matkl = lwa_main-matkl.
    CLEAR lw_zmm_mtart_ie.
    READ TABLE lt_zmm_mtart_ie INTO lw_zmm_mtart_ie WITH KEY mtart = lwa_main-mtart.

    IF lwa_main-mtart EQ lw_zmm_mtart_ie-mtart AND lw_zmm_mtart_ie = 'I'.
      IF lwa_main-matnr IS INITIAL.
        READ TABLE lt_mat_data INTO ls_mat_data WITH KEY
            mfrpn = lwa_main-mfrpn
            "mfrnr = lwa_main-mfrnr
            BINARY SEARCH.
        IF sy-subrc EQ 0.

          lwa_main-matnr = ls_mat_data-matnr.

        ELSE.
          READ TABLE it_mat_wrkst INTO lw_mat_wrkst
            WITH KEY wrkst = lwa_main-wrkst.
          IF sy-subrc = 0.
            lwa_main-matnr = lw_mat_wrkst-matnr.

            ls_mat_data-matnr = lwa_main-matnr.
            ls_mat_data-mfrpn = lwa_main-mfrpn.
            INSERT ls_mat_data INTO TABLE lt_mat_data.
          ELSE.
            CALL FUNCTION 'BAPI_MATERIAL_GETINTNUMBER'
              EXPORTING
                material_type    = lwa_main-mtart
*               INDUSTRY_SECTOR  = ' '
                required_numbers = 1
*       IMPORTING
*               RETURN           =
              TABLES
                material_number  = lt_material.

            READ TABLE lt_material INTO ls_material INDEX 1.
            IF sy-subrc EQ 0.
              lwa_main-matnr = ls_material-material.

              ls_mat_data-matnr = lwa_main-matnr.
              ls_mat_data-mfrpn = lwa_main-mfrpn.
              INSERT ls_mat_data INTO TABLE lt_mat_data.
              CLEAR: lt_material, ls_material.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        READ TABLE lt_mat_data INTO ls_mat_data
          WITH KEY mfrpn = lwa_main-matnr.
        IF sy-subrc = 0.
          lwa_main-matnr = ls_mat_data-matnr.
        ELSE.
          CLEAR: lwa_main-matnr.
          CALL FUNCTION 'BAPI_MATERIAL_GETINTNUMBER'
            EXPORTING
              material_type    = lwa_main-mtart
*             INDUSTRY_SECTOR  = ' '
              required_numbers = 1
*       IMPORTING
*             RETURN           =
            TABLES
              material_number  = lt_material.

          READ TABLE lt_material INTO ls_material INDEX 1.
          IF sy-subrc EQ 0.
            lwa_main-matnr = ls_material-material.
            CLEAR: lt_material, ls_material.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      IF lwa_main-matnr IS INITIAL.
        CALL FUNCTION 'BAPI_MATERIAL_GETINTNUMBER'
          EXPORTING
            material_type    = lwa_main-mtart
*           INDUSTRY_SECTOR  = ' '
            required_numbers = 1
*       IMPORTING
*           RETURN           =
          TABLES
            material_number  = lt_material.
        READ TABLE lt_material INTO ls_material INDEX 1.
        IF sy-subrc EQ 0.
          lwa_main-matnr = ls_material-material.
          CLEAR: lt_material, ls_material.
        ENDIF.
      ENDIF.
    ENDIF.

********************************* Fill Header Level Details *********************************
    DATA(lv_mat) = strlen( lwa_main-matnr ).
    IF lv_mat > 18.
      lwa_header-material_long      = lwa_main-matnr.
    ELSE.
      lwa_header-material      = lwa_main-matnr.
    ENDIF.
    lwa_header-ind_sector    = 'M'.
    lwa_header-matl_type     = lwa_main-mtart.
    lwa_header-basic_view    = p_basic.
    lwa_header-purchase_view = p_purc.
    lwa_header-sales_view    = p_sales.
    lwa_header-account_view  = p_acc.
    lwa_header-storage_view  = p_plant.
    lwa_header-mrp_view      = p_mrp.
    lwa_header-forecast_view = p_forcst.


********************************* Material Description - Short Text **********************************
    IF lwa_main-maktx IS NOT INITIAL.
      lwa_makt-langu = sy-langu.
      lwa_makt-matl_desc = lwa_main-maktx.
      APPEND lwa_makt TO it_makt.
    ENDIF.

*  Change to add Arabic text only if filled.

    IF lwa_main-maktx_a IS NOT INITIAL.
      lwa_makt-langu = 'AR'.
      lwa_makt-matl_desc = lwa_main-maktx_a.
      APPEND lwa_makt TO it_makt.
    ENDIF.

********************************** Basic Data **********************************
    lwa_client-matl_group     = lwa_main-matkl.
    lwa_client-base_uom       = lwa_main-meins.
    lwa_client-division       = lwa_main-spart.
    lwa_client-item_cat       = lwa_main-mtpos.
    lwa_client-trans_grp      = lwa_main-tragr.

    lwa_client-net_weight     = lwa_main-ntgew.
    lwa_client-size_dim       = lwa_main-groes.
    lwa_client-manu_mat       = lwa_main-mfrpn.
    lwa_client-mfr_no         = lwa_main-mfrnr.
    lwa_client-old_mat_no     = lwa_main-bismt.
    lwa_client-basic_matl     = lwa_main-wrkst.
    lwa_client-extmatlgrp     = lwa_main-matkl.

    IF lwa_client-matl_group  IS NOT INITIAL.
      lwa_clientx-matl_group = 'X'.
      lwa_clientx-extmatlgrp = 'X'.
    ENDIF.
    IF lwa_client-base_uom  IS NOT INITIAL.
      lwa_clientx-base_uom   = 'X'.
    ENDIF.
    IF lwa_client-division  IS NOT INITIAL.
      lwa_clientx-division   = 'X'.
    ENDIF.
    IF lwa_client-item_cat  IS NOT INITIAL.
      lwa_clientx-item_cat   = 'X'.
    ENDIF.
    IF lwa_client-pur_valkey  IS NOT INITIAL.
      lwa_clientx-pur_valkey = 'X'.
    ENDIF.
    IF lwa_client-trans_grp  IS NOT INITIAL.
      lwa_clientx-trans_grp  = 'X'.
    ENDIF.
    IF lwa_client-pur_status  IS NOT INITIAL.
      lwa_clientx-pur_status = 'X'.
    ENDIF.
    IF lwa_client-pvalidfrom  IS NOT INITIAL.
      lwa_clientx-pvalidfrom = 'X'.
    ENDIF.
    IF lwa_client-net_weight  IS NOT INITIAL.
      lwa_clientx-net_weight = 'X'.
    ENDIF.
    IF lwa_client-size_dim  IS NOT INITIAL.
      lwa_clientx-size_dim   = 'X'.
    ENDIF.
    IF lwa_client-manu_mat  IS NOT INITIAL.
      lwa_clientx-manu_mat   = 'X'.
    ENDIF.
    IF lwa_client-mfr_no  IS NOT INITIAL.
      lwa_clientx-mfr_no     = 'X'.
    ENDIF.
    IF lwa_client-old_mat_no  IS NOT INITIAL.
      lwa_clientx-old_mat_no = 'X'.
    ENDIF.
    IF lwa_client-basic_matl  IS NOT INITIAL.
      lwa_clientx-basic_matl = 'X'.
    ENDIF.

********************************** Purchasing **********************************

    lwa_plant-plant      = lwa_main-werks.
    lwa_plant-pur_group  = lwa_main-ekgrp.
    lwa_plant-profit_ctr = lwa_main-prctr.
    lwa_plant-availcheck  = lwa_main-mtvfp.
    lwa_plant-loadinggrp  = lwa_main-ladgr.
    lwa_plant-mrp_type    = lwa_main-dismm.
    lwa_plant-proc_type   = lwa_main-beskz.
    lwa_plant-lotsizekey  = lwa_main-disls.
    lwa_plant-reorder_pt  = lwa_main-minbe.
    lwa_plant-safety_stk  = lwa_main-eisbe.
    lwa_plant-mrp_ctrler  = lwa_main-dispo.
    lwa_plant-serno_prof  = lwa_zmm_mat_constant-sernp.
    IF lwa_main-disgr IS INITIAL.
      SELECT SINGLE mtart FROM t438m INTO lwa_main-disgr WHERE werks = lwa_main-werks.
    ENDIF.
    lwa_plant-mrp_group   = lwa_main-disgr.

    lwa_plant-abc_id      = lwa_main-maabc.
    lwa_plant-plnd_delry  =  lwa_main-plifz.
    lwa_plant-gr_pr_time  = lwa_main-webaz.
    lwa_plant-min_safety_stk = lwa_main-eislo.
    lwa_plant-replentime  = lwa_main-wzeit.
    lwa_plant-period_ind  = lwa_main-perkz.
    lwa_plant-sm_key = lwa_main-fhori.
    lwa_plant-auto_p_ord  = 'X'.
    lwa_plant-batch_mgmt = lwa_main-xchpf.
    lwa_plantx-plant       = lwa_main-werks.
    IF lwa_plant-pur_group IS NOT INITIAL.
      lwa_plantx-pur_group   = 'X'.
    ENDIF.
    IF lwa_plant-batch_mgmt IS NOT INITIAL.
      lwa_plantx-batch_mgmt  = 'X'.
    ENDIF.
    IF lwa_plant-profit_ctr IS NOT INITIAL.
      lwa_plantx-profit_ctr  = 'X'.
    ENDIF.
    IF lwa_plant-availcheck IS NOT INITIAL.
      lwa_plantx-availcheck  = 'X'.
    ENDIF.
    IF lwa_plant-loadinggrp IS NOT INITIAL.
      lwa_plantx-loadinggrp  = 'X'.
    ENDIF.
    IF lwa_plant-mrp_type IS NOT INITIAL.
      lwa_plantx-mrp_type    = 'X'.
    ENDIF.
    IF lwa_plant-proc_type IS NOT INITIAL.
      lwa_plantx-proc_type   = 'X'.
    ENDIF.
    IF lwa_plant-lotsizekey IS NOT INITIAL.
      lwa_plantx-lotsizekey  = 'X'.
    ENDIF.
    IF lwa_plant-reorder_pt IS NOT INITIAL.
      lwa_plantx-reorder_pt  = 'X'.
    ENDIF.
    IF lwa_plant-safety_stk IS NOT INITIAL.
      lwa_plantx-safety_stk  = 'X'.
    ENDIF.
    IF lwa_plant-mrp_ctrler IS NOT INITIAL.
      lwa_plantx-mrp_ctrler  = 'X'.
    ENDIF.
    IF lwa_plant-mrp_group IS NOT INITIAL.
      lwa_plantx-mrp_group   = 'X'.
    ENDIF.
    IF lwa_plant-abc_id IS NOT INITIAL.
      lwa_plantx-abc_id      = 'X'.
    ENDIF.
    IF lwa_plant-fixed_lot IS NOT INITIAL.
      lwa_plantx-fixed_lot   = 'X'.
    ENDIF.
    IF lwa_plant-auto_p_ord IS NOT INITIAL.
      lwa_plantx-auto_p_ord  = 'X'.
    ENDIF.
    IF lwa_plant-plnd_delry IS NOT INITIAL.
      lwa_plantx-plnd_delry  =  'X'.
    ENDIF.
    IF lwa_plant-gr_pr_time IS NOT INITIAL.
      lwa_plantx-gr_pr_time  = 'X'.
    ENDIF.
    IF lwa_plant-min_safety_stk IS NOT INITIAL.
      lwa_plantx-min_safety_stk = 'X'.
    ENDIF.
    IF lwa_plant-replentime IS NOT INITIAL.
      lwa_plantx-replentime  = 'X'.
    ENDIF.
    IF lwa_plant-period_ind IS NOT INITIAL.
      lwa_plantx-period_ind  = 'X'.
    ENDIF.
    IF lwa_plant-sm_key IS NOT INITIAL.
      lwa_plantx-sm_key = 'X'.
    ENDIF.

    lwa_forecast-plant = lwa_main-werks.
    lwa_forecast-fore_model = lwa_main-prmod.
    lwa_forecast-hist_vals  = lwa_main-peran.
    lwa_forecast-fore_pds = lwa_main-anzpr.
    lwa_forecast-fore_pds = lwa_main-anzpr.
    lwa_forecast-initialize = lwa_main-kzini.

    lwa_forecast-wtg_group = lwa_main-gewgr.

    lwa_forecastx-plant = lwa_main-werks.
    IF lwa_forecast-fore_model IS NOT INITIAL.
      lwa_forecastx-fore_model = 'X'.
    ENDIF.
    IF lwa_forecast-hist_vals IS NOT INITIAL.
      lwa_forecastx-hist_vals  = 'X'.
    ENDIF.
    IF lwa_forecast-fore_pds IS NOT INITIAL.
      lwa_forecastx-fore_pds = 'X'.
    ENDIF.
    IF lwa_forecast-initialize IS NOT INITIAL.
      lwa_forecastx-initialize = 'X'.
    ENDIF.
    "new entry
    IF lwa_forecast-wtg_group IS NOT INITIAL.
      lwa_forecastx-wtg_group = 'X'.
    ENDIF.


********************************** Sales **********************************

    lwa_sale-sales_org   = lwa_main-vkorg.
    lwa_sale-distr_chan  = lwa_main-vtweg.
    lwa_sale-item_cat    = lwa_main-mtpos_d.
    lwa_sale-mat_pr_grp  = lwa_main-kondm.
    lwa_sale-acct_assgt  = lwa_main-ktgrm.
    lwa_sale-matl_stats = lwa_zmm_mat_constant-versg.
    lwa_sale-min_order  = lwa_main-aumng.
    lwa_sale-matl_grp_4  = lwa_main-matl_grp_4.
    lwa_sale-matl_grp_3  = lwa_main-matl_grp_3.

    lwa_salex-sales_org   = lwa_main-vkorg.
    lwa_salex-distr_chan  = lwa_main-vtweg.
    IF lwa_sale-item_cat  IS NOT INITIAL.
      lwa_salex-item_cat    = 'X'.
    ENDIF.
    IF lwa_sale-mat_pr_grp  IS NOT INITIAL.
      lwa_salex-mat_pr_grp  = 'X'.
    ENDIF.
    IF lwa_sale-acct_assgt  IS NOT INITIAL.
      lwa_salex-acct_assgt  = 'X'.
    ENDIF.
    IF lwa_sale-min_order  IS NOT INITIAL.
      lwa_salex-min_order   = 'X'.
    ENDIF.
    IF lwa_sale-matl_grp_4  IS NOT INITIAL.
      lwa_salex-matl_grp_4 = 'X'.
    ENDIF.
    IF lwa_sale-matl_grp_3  IS NOT INITIAL.
      lwa_salex-matl_grp_3 = 'X'.
    ENDIF.

    CLEAR : lwa_tax-depcountry,lwa_tax-tax_type_1.
    SELECT SINGLE land1 INTO lwa_tax-depcountry FROM t001w WHERE werks = lwa_main-werks.
    IF sy-subrc = 0 AND lwa_main-werks CP '2***'.
      SELECT SINGLE tatyp INTO  lwa_tax-tax_type_1 FROM tstl WHERE talnd = lwa_tax-depcountry.

      lwa_tax-taxclass_1 = lwa_main-taxm1.
      lwa_tax-tax_ind    = lwa_zmm_mat_constant-taxim.

      APPEND lwa_tax TO it_tax.
    ENDIF.
*since SA is hardcoded so now onwards every material will have 'SA'.
*    Begin of change
    CLEAR lwa_tax.
    lwa_tax-depcountry = 'SA'.
    SELECT SINGLE tatyp INTO  lwa_tax-tax_type_1 FROM tstl WHERE talnd = lwa_tax-depcountry.
    IF sy-subrc = 0 AND lwa_main-werks CP '1***'.
      lwa_tax-taxclass_1 = lwa_main-taxm1.
      lwa_tax-tax_ind    = lwa_zmm_mat_constant-taxim.
      APPEND lwa_tax TO it_tax.
*    end of change
    ENDIF.
    lwa_store-plant     = lwa_main-werks.
    lwa_store-stge_loc  = lwa_main-lgort.
    lwa_store-stge_bin  = lwa_main-lgpbe.


    lwa_storex-plant    = lwa_main-werks.
    lwa_storex-stge_loc  = lwa_main-lgort.
    IF lwa_store-stge_bin IS NOT INITIAL.
      lwa_storex-stge_bin  = 'X'.
    ENDIF.

********************************** Accounting **********************************

    lwa_acc-val_area   = lwa_main-werks.
    lwa_acc-val_class  = lwa_main-bklas.
    lwa_acc-val_cat    = lwa_main-bwtty.
    lwa_acc-price_ctrl = lwa_main-vprsv.
    lwa_acc-moving_pr  = lwa_main-verpr.
    lwa_acc-price_unit = lwa_main-peinh.
    lwa_acc-std_price  = lwa_main-stprs.

    lwa_accx-val_area   = lwa_main-werks.
    IF lwa_acc-val_cat  IS NOT INITIAL.
      lwa_accx-val_cat    = 'X'.
    ENDIF.
    IF lwa_acc-val_class  IS NOT INITIAL.
      lwa_accx-val_class  = 'X'.
    ENDIF.
    IF lwa_acc-price_ctrl  IS NOT INITIAL.
      lwa_accx-price_ctrl = 'X'.
    ENDIF.
    IF lwa_acc-moving_pr  IS NOT INITIAL.
      lwa_accx-moving_pr  = 'X'.
    ENDIF.
    IF lwa_acc-price_unit  IS NOT INITIAL.
      lwa_accx-price_unit = 'X'.
    ENDIF.
    IF lwa_acc-std_price  IS NOT INITIAL.
      lwa_accx-std_price  = 'X'.
    ENDIF.

    lwa_ware-whse_no = lwa_main-lgnum.
    lwa_ware-stge_type = lwa_main-lgtyp.
    lwa_warex-whse_no = lwa_main-lgnum.
    IF lwa_ware-stge_type IS NOT INITIAL.
      lwa_warex-stge_type = 'X'.
    ENDIF.
    IF lwa_header-material IS NOT INITIAL.
      CLEAR lv_htype.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          string_in = lwa_header-material
        IMPORTING
*         STRING_OUT       =
          htype     = lv_htype.
      IF lv_htype = 'NUMC'.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input  = lwa_header-material  "lwa_main-matnr
          IMPORTING
            output = lwa_header-material.  "lwa_main-matnr.

      ENDIF.
    ENDIF.
*   loop at lt_werks into data(lw_werks).
*     lwa_plant-plant = lw_werks-werks.
    CLEAR: lwa_return.
    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata             = lwa_header
        clientdata           = lwa_client
        clientdatax          = lwa_clientx
        plantdata            = lwa_plant
        plantdatax           = lwa_plantx
        forecastparameters   = lwa_forecast
        forecastparametersx  = lwa_forecastx
        storagelocationdata  = lwa_store
        storagelocationdatax = lwa_storex
        valuationdata        = lwa_acc
        valuationdatax       = lwa_accx
        warehousenumberdata  = lwa_ware
        warehousenumberdatax = lwa_warex
        salesdata            = lwa_sale
        salesdatax           = lwa_salex
      IMPORTING
        return               = lwa_return
      TABLES
        materialdescription  = it_makt
        extensionin          = lt_extensionin
        extensioninx         = lt_extensioninx
        taxclassifications   = it_tax.

*   endloop.
    CLEAR: it_makt, it_tax, lt_extensionin, lt_extensioninx.

    CLEAR:
*           lwa_header   ,
           lwa_client   ,
           lwa_clientx  ,
*           lwa_plant    ,
*           lwa_plantx   ,
           lwa_forecast ,
           lwa_forecastx,
           lwa_store    ,
           lwa_storex   ,
           lwa_acc      ,
           lwa_accx     ,
           lwa_ware     ,
           lwa_warex    ,
           lwa_sale     ,
           lwa_salex    .

    ls_log-material = lwa_main-matnr.
    ls_log-plant = lwa_main-werks.
    ls_log-type = lwa_return-type.
    ls_log-message = lwa_return-message.

    APPEND ls_log TO lt_log.
    CLEAR ls_log.


    IF lwa_return-type EQ 'S'.
      MOVE-CORRESPONDING lwa_header TO lw_header.
      APPEND lw_header TO lt_header.

      MOVE-CORRESPONDING lwa_plant TO lw_plant.
      MOVE-CORRESPONDING lwa_plantx TO lw_plantx.
      IF lwa_main+0(2) = 'MS' OR lwa_main+0(3) = 'LMS'.
        LOOP AT lt_autho INTO lw_autho WHERE category = 'MS' AND werks NE lwa_main-werks.
          PERFORM plant .
        ENDLOOP.
      ENDIF.
      IF lwa_main+0(2) = 'DF' OR lwa_main+0(3) = 'LDF'.
        LOOP AT lt_autho INTO lw_autho WHERE category = 'DF' AND werks NE lwa_main-werks.
          PERFORM plant .
        ENDLOOP.
      ENDIF.
      IF lwa_main+0(2) = 'HQ' OR lwa_main+0(3) = 'LHQ'.
        LOOP AT lt_autho INTO lw_autho WHERE category = 'HQ' AND werks NE lwa_main-werks.
          PERFORM plant .
        ENDLOOP.
      ENDIF.
      IF lt_plant[] IS NOT INITIAL.
        CALL FUNCTION 'BAPI_MATERIAL_SAVEREPLICA'
          EXPORTING
            noappllog   = 'X'
            nochangedoc = 'X'
            testrun     = ' '
            inpfldcheck = ' '
*           FLAG_CAD_CALL              = ' '
*           NO_ROLLBACK_WORK           = ' '
*           FLAG_ONLINE = ' '
          IMPORTING
            return      = lw_bapiret2
          TABLES
            headdata    = lt_header
            plantdata   = lt_plant
            plantdatax  = lt_plantx.

      ENDIF.


      CLEAR:
                lwa_header   ,

                lwa_plant    ,
                lwa_plantx   ,
                lt_header   ,
                lw_plant,
                lt_plant,
                lt_plant    ,
                lt_plantx   .
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          wait = 'X'.

      IF lwa_main-xchpf = 'X'.
        DATA lt_valuenum TYPE STANDARD TABLE OF bapi1003_alloc_values_num.
        DATA lw_valuenum TYPE bapi1003_alloc_values_num.
        DATA lt_return TYPE STANDARD TABLE OF bapiret2.
        DATA lv_objnum TYPE objnum.
        lv_objnum =  lwa_main-matnr.
        lw_valuenum-charact = 'LOBM_HSDAT'.
        APPEND lw_valuenum TO lt_valuenum.
        CALL FUNCTION 'BAPI_OBJCL_CREATE'
          EXPORTING
            objectkeynew   = lv_objnum
            objecttablenew = 'MARA'
            classnumnew    = lwa_zmm_mat_constant-classnum
            classtypenew   = '023'
            status         = '1'
            keydate        = sy-datum
          TABLES
            allocvaluesnum = lt_valuenum
            return         = lt_return.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            wait = 'X'.


      ENDIF.



      va_succ_records = va_succ_records + 1.
    ELSE.
      va_fail_records = va_fail_records + 1.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  IF lt_log[] IS NOT INITIAL.

    PERFORM f_fill_field_catalog CHANGING it_fieldcat.

    wa_layout-zebra             = abap_true.
    wa_layout-colwidth_optimize = abap_true.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program     = sy-cprog
        i_callback_top_of_page = va_top
        i_grid_title           = TEXT-003
        is_layout              = wa_layout
        it_fieldcat            = it_fieldcat
        is_print               = ls_print
      TABLES
        t_outtab               = lt_log
      EXCEPTIONS
        program_error          = 1
        OTHERS                 = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       Fill field catalog for ALV
*----------------------------------------------------------------------*
*      <--P_IT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM f_fill_field_catalog  CHANGING ct_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: lw_fcat TYPE slis_fieldcat_alv.

  DEFINE m_cat ##NEEDED.
    lw_fcat-fieldname   = &1.
    lw_fcat-tabname     = &2.
    lw_fcat-seltext_l   = &3.
    lw_fcat-outputlen   = &4.
    APPEND lw_fcat TO ct_fieldcat.
  END-OF-DEFINITION.

  m_cat 'TYPE'           'LT_LOG' TEXT-004 TEXT-008.
  m_cat 'MATERIAL'         'LT_LOG' TEXT-005 TEXT-008.
  m_cat 'PLANT'         'LT_LOG' TEXT-006 TEXT-008.
  m_cat 'MESSAGE'        'LT_LOG' TEXT-007 TEXT-009.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LEADING_ZEROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LWA_MAIN_TRAGR  text
*----------------------------------------------------------------------*
FORM f_leading_zeros  CHANGING cv_data.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = cv_data
    IMPORTING
      output = cv_data.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ALV_HEADER
*&---------------------------------------------------------------------*
* To Display Success and error records (top_of_page)
*----------------------------------------------------------------------*
FORM f_alv_header ##called.

  DATA  lt_head      TYPE STANDARD TABLE OF slis_listheader.
  DATA  lw_head      TYPE slis_listheader.

  CONSTANTS: lc_head TYPE c VALUE  'H',
             lc_sel  TYPE c VALUE  'S'.

  lw_head-typ  = lc_head.
  lw_head-info = TEXT-010.
  APPEND lw_head TO  lt_head.
  CLEAR lw_head.

  " Record count for ALV header display
  lw_head-typ  = lc_sel.
  CONCATENATE TEXT-011
              va_total_records      INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR lw_head.

  lw_head-typ  = lc_sel.
  CONCATENATE TEXT-012
              va_succ_records    INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR lw_head.

  lw_head-typ  = lc_sel.
  CONCATENATE TEXT-013
              va_fail_records     INTO lw_head-info RESPECTING BLANKS.
  APPEND lw_head TO lt_head.
  CLEAR lw_head.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_head.
ENDFORM.

FORM plant ."using lw_autho1 type zmm_pc_autho .
  lw_plant-function = 'REF'.
  lw_plantx-function = 'REF'.

  lw_plant-plant        = lw_autho-werks.
  lw_plantx-plant       = lw_autho-werks.

  lw_plant-material_long = lwa_main-matnr.
  lw_plantx-material_long = 'X'.
  APPEND lw_plant TO lt_plant.
  APPEND lw_plantx TO lt_plantx.
ENDFORM.

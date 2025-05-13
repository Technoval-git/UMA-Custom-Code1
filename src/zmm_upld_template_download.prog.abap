*&---------------------------------------------------------------------*
*& Report  ZMM_TEMPLATE_DOWNLOAD_PORG
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zmm_template_download_porg.

SELECTION-SCREEN : BEGIN OF BLOCK b1.
  SELECTION-SCREEN : BEGIN OF LINE,
  PUSHBUTTON 1(18) TEXT-p01 USER-COMMAND template,
  END OF LINE.
SELECTION-SCREEN : END OF BLOCK b1.

AT SELECTION-SCREEN.
  IF sy-ucomm EQ 'TEMPLATE'.
    PERFORM download.
  ENDIF.

FORM download.
  TYPE-POOLS: soi,ole2.
  TYPES: var(1500) TYPE c,
         ty_excel  TYPE TABLE OF var.

  DATA: gt_excel TYPE ty_excel WITH HEADER LINE.
  DATA: gt_excel2 TYPE ty_excel WITH HEADER LINE.
  DATA: gv_delimiter,
           gv_rc TYPE i.
  DATA: lo_application TYPE  ole2_object,
        lo_workbook    TYPE  ole2_object,
        lo_workbooks   TYPE  ole2_object,
        lo_range       TYPE  ole2_object,
        lo_worksheet   TYPE  ole2_object,
        lo_worksheets  TYPE  ole2_object,
        lo_column      TYPE  ole2_object,
        lo_row         TYPE  ole2_object,
        lo_cell        TYPE  ole2_object,
        lo_font        TYPE ole2_object.
  DATA: lo_cellstart  TYPE ole2_object,
        lo_cellend    TYPE ole2_object,
        lo_cellstartW TYPE ole2_object,
        lo_cellendW   TYPE ole2_object,
        lo_selection  TYPE ole2_object,
        lo_validation TYPE ole2_object,
        shading       TYPE ole2_object,
        Border        TYPE ole2_object.

  DATA: lv_selected_folder TYPE string,
        lv_complete_path   TYPE char256,
        lv_titulo          TYPE string VALUE 'Select a Folder to save Template'.


  TYPES: BEGIN OF ty_format,
           matnr(200),
           mtart(140),
           werks(100),
           lgort(102),
           lgnum(102),
           maktx(102),
           maktxARB(102),
           meins(102),
           matkl(102),
           brgew(102),
           ntgew(102),
           gewei(102),
           groes(102),
           spart(102),
           aumng(102),
           bismt(102),
           xchpf(102),
           extwg(102),
           mfrpn(102),
           maabc(102),
           eisbe(102),
           eislo(102),
           plifz(102),
           webaz(102),
           bklas(102),
           peinh(102),
           verpr(102),
           lgpbe(102),
           vprsv(102),
           vkorg(102),
           vtweg(102),
           taxm1(102),
           mbrsh(102),
           kondm(102),
           ktgrm(102),
           mtposmara(102),
           mtposmvke(120),
           mtvfp(120),
           tragr(102),
           ladgr(120),
           prctr(102),
           mfrnr(120),
           ekgrp(120),
           disgr(120),
           dismm(120),
           minbe(120),
           disls(102),
           dispo(120),
           beskz(120),
           wzeit(120),
           prmod(120),
           perkz(120),
           peran(120),
           anzpr(120),
           kzini(120),
           bwtty(120),
           stprs(180),
         END OF ty_format.

  DATA: gt_format  TYPE TABLE OF ty_format,
        gwa_format TYPE ty_format.
  DATA: gt_des_format  TYPE TABLE OF ty_format,
        gwa_des_format TYPE ty_format.

  gv_delimiter = cl_abap_char_utilities=>horizontal_tab.

  REFRESH: gt_format, gt_des_format, gt_excel[].
  CLEAR: gwa_format, gwa_des_format, gt_excel.


*+++++++++++++++++++++++++++++++++++++++++++++++ASSIGNING THE FIELDS TO EXCEL============================================
  gwa_des_format-matnr = 'Parts Number'.
  gwa_des_format-mtart = 'Material Type'.                       """"""""
  gwa_des_format-werks = 'Plant'.                       """"""""""""
  gwa_des_format-lgort = 'Storage Location'.
  gwa_des_format-lgnum = 'Warehouse number'.
  gwa_des_format-maktx = 'Material Description (Short Text)'.
  gwa_des_format-maktxarb = 'Material Description (Short Text) - Arabic'.
  gwa_des_format-meins = 'Base Unit of Measure'.
  gwa_des_format-matkl = 'Material Group'.
  gwa_des_format-brgew = 'Gross Weight'.
  gwa_des_format-ntgew = 'Net Weight'.
  gwa_des_format-gewei = 'Weight of unit'.
  gwa_des_format-groes = 'Size/dimensions'.
  gwa_des_format-spart = 'Division'.
  gwa_des_format-aumng = 'Minimum order quantity in base unit of measure'.
  gwa_des_format-bismt = 'Old material number'.
  gwa_des_format-xchpf = 'Expiration "x"'.
  gwa_des_format-extwg = 'External Manterial Group'.
  gwa_des_format-mfrpn = 'Manufacturer Part Number (40digitnumber)'.
  gwa_des_format-maabc = 'ABC Indicator'.
  gwa_des_format-eisbe = 'Safety Stock'.
  gwa_des_format-eislo = 'Minimum Safety Stock'.
  gwa_des_format-plifz = 'Planned Delivery Time in Days'.
  gwa_des_format-webaz = 'Goods Receipt Processing Time in Days'.
  gwa_des_format-bklas = 'Valuation Class'.
  gwa_des_format-peinh = 'Price Unit'.
  gwa_des_format-verpr = 'Moving Average Price/Periodic Unit Price'.
  gwa_des_format-lgpbe = 'Storage Bin'.
  gwa_des_format-vprsv = 'Price control indicator '.
  gwa_des_format-vkorg = 'Sales Organization'.
  gwa_des_format-vtweg = 'Distribution Channel'.
  gwa_des_format-taxm1 = 'Tax classification material'.
  gwa_des_format-mbrsh = 'Industry sector'.
  gwa_des_format-kondm = 'Material Pricing Group'.
  gwa_des_format-ktgrm = 'Account assignment group for this material'.
  gwa_des_format-mtposmara = 'General item category group'.
  gwa_des_format-mtposmvke = 'Item category group from material master'.
  gwa_des_format-mtvfp = 'Availability Check'.
  gwa_des_format-tragr = 'Transportation Group'.
  gwa_des_format-ladgr = 'Loading Group'.
  gwa_des_format-prctr = 'Profit Center'.
  gwa_des_format-mfrnr = 'Manufacturer OEM Number'.
  gwa_des_format-ekgrp = 'Purchasing Group'.
  gwa_des_format-disgr = 'MRP Group'.
  gwa_des_format-dismm = 'MRP Type'.
  gwa_des_format-minbe = 'Reorder Point'.
  gwa_des_format-disls = 'Lot size (materials planning)'.
  gwa_des_format-dispo = 'MRP Controller (Materials Planner)'.
  gwa_des_format-beskz = 'Procurement Type'.
  gwa_des_format-wzeit = 'Total replenishment lead time (in workdays)'.
  gwa_des_format-prmod = 'Forecast Model'.
  gwa_des_format-perkz = 'Period Indicator'.
  gwa_des_format-peran = 'Historical periods'.
  gwa_des_format-anzpr = 'Forecast periods'.
  gwa_des_format-kzini = 'Initialization indicator'.
  gwa_des_format-bwtty = 'Valuation Category'.                 "'''''''''''''
  gwa_des_format-stprs = 'Standard price'.                 ""'''''''
*=========================================END OF FIELD ASSIGNE++++++++++++++++++++++++++++++++++

  INSERT gwa_des_format INTO gt_des_format INDEX 1.

  LOOP AT gt_des_format INTO gwa_des_format.
    CONCATENATE   gwa_des_format-matnr
                  gwa_des_format-mtart
                  gwa_des_format-werks
                  gwa_des_format-lgort
                  gwa_des_format-lgnum
                  gwa_des_format-maktx
                  gwa_des_format-maktxarb
                  gwa_des_format-meins
                  gwa_des_format-matkl
                  gwa_des_format-brgew
                  gwa_des_format-ntgew
                  gwa_des_format-gewei
                  gwa_des_format-groes
                  gwa_des_format-spart
                  gwa_des_format-aumng
                  gwa_des_format-bismt
                  gwa_des_format-xchpf
                  gwa_des_format-extwg
                  gwa_des_format-mfrpn
                  gwa_des_format-maabc
                  gwa_des_format-eisbe
                  gwa_des_format-eislo
                  gwa_des_format-plifz
                  gwa_des_format-webaz
                  gwa_des_format-bklas
                  gwa_des_format-peinh
                  gwa_des_format-verpr
                  gwa_des_format-lgpbe
                  gwa_des_format-vprsv
                  gwa_des_format-vkorg
                  gwa_des_format-vtweg
                  gwa_des_format-taxm1
                  gwa_des_format-mbrsh
                  gwa_des_format-kondm
                  gwa_des_format-ktgrm
                  gwa_des_format-mtposmara
                  gwa_des_format-mtposmvke
                  gwa_des_format-mtvfp
                  gwa_des_format-tragr
                  gwa_des_format-ladgr
                  gwa_des_format-prctr
                  gwa_des_format-mfrnr
                  gwa_des_format-ekgrp
                  gwa_des_format-disgr
                  gwa_des_format-dismm
                  gwa_des_format-minbe
                  gwa_des_format-disls
                  gwa_des_format-dispo
                  gwa_des_format-beskz
                  gwa_des_format-wzeit
                  gwa_des_format-prmod
                  gwa_des_format-perkz
                  gwa_des_format-peran
                  gwa_des_format-anzpr
                  gwa_des_format-kzini
                  gwa_des_format-bwtty
                  gwa_des_format-stprs
                INTO gt_excel2 SEPARATED BY gv_delimiter.
    APPEND gt_excel2.
    CLEAR gt_excel2.
  ENDLOOP.
*+++++++++++++++++++++++++++++++++++++++ASSIGNING THE FIELD DESCRIPTION============================
  gwa_format-matnr = 'Matnr'.
  gwa_format-mtart = 'Mtart'.
  gwa_format-werks = 'Werks'.
  gwa_format-lgort = 'lgort'.
  gwa_format-lgnum = 'lgnum'.
  gwa_format-maktx = 'Maktx'.
  gwa_format-maktxarb = 'Maktx-ARb'.
  gwa_format-meins = 'Meins'.
  gwa_format-matkl = 'Matkl'.
  gwa_format-brgew = 'Brgew'.
  gwa_format-ntgew = 'ntgew'.
  gwa_format-gewei = 'gewei'.
  gwa_format-groes = 'groes'.
  gwa_format-spart = 'Spart'.
  gwa_format-aumng = 'aumng'.
  gwa_format-bismt = 'bismt'.
  gwa_format-xchpf = 'xchpf'.
  gwa_format-extwg = 'extwg'.
  gwa_format-mfrpn = 'Mfrpn'.
  gwa_format-maabc = 'Maabc'.
  gwa_format-eisbe = 'eisbe'.
  gwa_format-eislo = 'eislo'.
  gwa_format-plifz = 'plifz'.
  gwa_format-webaz = 'Webaz'.
  gwa_format-bklas = 'Bklas'.
  gwa_format-peinh = 'peinh'.
  gwa_format-verpr = 'Verpr'.
  gwa_format-lgpbe = 'lgpbe'.
  gwa_format-vprsv = 'vprsv'.
  gwa_format-vkorg = 'vkorg'.
  gwa_format-vtweg = 'vtweg'.
  gwa_format-taxm1 = 'taxm1'.
  gwa_format-mbrsh = 'Mbrsh'.
  gwa_format-kondm = 'kondm'.
  gwa_format-ktgrm = 'ktgrm'.
  gwa_format-mtposmara = 'Mtpos-Mara'.
  gwa_format-mtposmvke = 'Mtpos-mvke'.
  gwa_format-mtvfp = 'Mtvfp'.
  gwa_format-tragr = 'tragr'.
  gwa_format-ladgr = 'ladgr'.
  gwa_format-prctr = 'prctr'.
  gwa_format-mfrnr = 'Mfrnr'.
  gwa_format-ekgrp = 'ekgrp'.
  gwa_format-disgr = 'disgr'.
  gwa_format-dismm = 'dismm'.
  gwa_format-minbe = 'minbe'.
  gwa_format-disls = 'disls'.
  gwa_format-dispo = 'dispo'.
  gwa_format-beskz = 'beskz'.
  gwa_format-wzeit = 'wzeit'.
  gwa_format-prmod = 'prmod'.
  gwa_format-perkz = 'perkz'.
  gwa_format-peran = 'peran'.
  gwa_format-anzpr = 'anzpr'.
  gwa_format-kzini = 'kzini'.
  gwa_format-bwtty = 'bwtty'.
  gwa_format-stprs = 'stprs'.
*=============================================END OF FIELD DESCRIPTION ASSIGN+++++++++++++++++++++++++++++++++++++++++++


  INSERT gwa_format INTO gt_format INDEX 1.

  LOOP AT gt_format INTO gwa_format.
    CONCATENATE   gwa_format-matnr
                  gwa_format-mtart
                  gwa_format-werks
                  gwa_format-lgort
                  gwa_format-lgnum
                  gwa_format-maktx
                  gwa_format-maktxarb
                  gwa_format-meins
                  gwa_format-matkl
                  gwa_format-brgew
                  gwa_format-ntgew
                  gwa_format-gewei
                  gwa_format-groes
                  gwa_format-spart
                  gwa_format-aumng
                  gwa_format-bismt
                  gwa_format-xchpf
                  gwa_format-extwg
                  gwa_format-mfrpn
                  gwa_format-maabc
                  gwa_format-eisbe
                  gwa_format-eislo
                  gwa_format-plifz
                  gwa_format-webaz
                  gwa_format-bklas
                  gwa_format-peinh
                  gwa_format-verpr
                  gwa_format-lgpbe
                  gwa_format-vprsv
                  gwa_format-vkorg
                  gwa_format-vtweg
                  gwa_format-taxm1
                  gwa_format-mbrsh
                  gwa_format-kondm
                  gwa_format-ktgrm
                  gwa_format-mtposmara
                  gwa_format-mtposmvke
                  gwa_format-mtvfp
                  gwa_format-tragr
                  gwa_format-ladgr
                  gwa_format-prctr
                  gwa_format-mfrnr
                  gwa_format-ekgrp
                  gwa_format-disgr
                  gwa_format-dismm
                  gwa_format-minbe
                  gwa_format-disls
                  gwa_format-dispo
                  gwa_format-beskz
                  gwa_format-wzeit
                  gwa_format-prmod
                  gwa_format-perkz
                  gwa_format-peran
                  gwa_format-anzpr
                  gwa_format-kzini
                  gwa_format-bwtty
                  gwa_format-stprs
                INTO gt_excel SEPARATED BY gv_delimiter.
    APPEND gt_excel.
    CLEAR gt_excel.
  ENDLOOP.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = lv_titulo
      initial_folder  = 'C:\'
    CHANGING
      selected_folder = lv_selected_folder
    EXCEPTIONS
      cntl_error      = 1
      error_no_gui    = 2
      OTHERS          = 3.
  CHECK NOT lv_selected_folder IS INITIAL.

  CREATE OBJECT lo_application 'Excel.Application'.
  CALL METHOD OF lo_application 'Workbooks' = lo_workbooks.
  CALL METHOD OF lo_workbooks 'Add' = lo_workbook.
  SET PROPERTY OF lo_application 'Visible' = 0.
  GET PROPERTY OF lo_application 'ACTIVESHEET' = lo_worksheet.



  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data                 = gt_excel2[]
    CHANGING
      rc                   = gv_rc
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

* 1. Select starting cell
  CALL METHOD OF lo_worksheet 'Cells' = lo_cellstart
  EXPORTING
  #1 = 1
  #2 = 1.
* 2. Select ending cell
  CALL METHOD OF lo_worksheet 'Cells' = lo_cellend
  EXPORTING
  #1 = 1
  #2 = 57.

* Select the Range:
  CALL METHOD OF lo_worksheet 'RANGE' = lo_range
  EXPORTING
  #1 = lo_cellstart
  #2 = lo_cellend.

  CALL METHOD OF lo_range 'select'.
  CALL METHOD OF lo_worksheet 'Paste' NO FLUSH.

  GET PROPERTY OF lo_range 'FONT' = lo_font.
  SET PROPERTY OF lo_font 'BOLD' = 1.
  SET PROPERTY OF lo_font 'Size' = 12.

  CALL METHOD OF
    lo_range
      'Interior' = shading.
  SET PROPERTY OF Shading 'colorindex' = 6.
  SET PROPERTY OF shading 'pattern' = 1.
  FREE OBJECT shading.

  CALL METHOD OF lo_application 'Cells' = lo_cellstart
  EXPORTING
  #1 = 2
  #2 = 1.
* 2. Select ending cell
  CALL METHOD OF lo_application 'Cells' = lo_cellend
  EXPORTING
  #1 = 2
  #2 = 57.

* Select the Range:
  CALL METHOD OF lo_application 'RANGE' = lo_range
  EXPORTING
  #1 = lo_cellstart
  #2 = lo_cellend.

  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data                 = gt_excel[]
    CHANGING
      rc                   = gv_rc
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  CALL METHOD OF lo_range 'select'.
  CALL METHOD OF lo_worksheet 'Paste' NO FLUSH.

  GET PROPERTY OF lo_range 'FONT' = lo_font.
  SET PROPERTY OF lo_font 'BOLD' = 1.
  SET PROPERTY OF lo_font 'Size' = 12.

  CALL METHOD OF
    lo_range
      'Interior' = shading.
  SET PROPERTY OF Shading 'colorindex' = 6.
  SET PROPERTY OF shading 'pattern' = 1.
  FREE OBJECT shading.

  CALL METHOD OF
        lo_range
        'BORDERS' = border
       EXPORTING
         #1       = '1'.
  SET PROPERTY OF border 'LINESTYLE' = '1'.
  SET PROPERTY OF border 'WEIGTH' = 2.
  FREE OBJECT border.

  CALL METHOD OF
        lo_range
        'BORDERS' = border
       EXPORTING
         #1       = '2'.
  SET PROPERTY OF border 'LINESTYLE' = '1'.
  SET PROPERTY OF border 'WEIGTH' = 2.
  FREE OBJECT border.

  CALL METHOD OF
        lo_range
        'BORDERS' = border
       EXPORTING
         #1       = '3'.
  SET PROPERTY OF border 'LINESTYLE' = '1'.
  SET PROPERTY OF border 'WEIGTH' = 2.
  FREE OBJECT border.

  CALL METHOD OF
        lo_range
        'BORDERS' = border
       EXPORTING
         #1       = '4'.
  SET PROPERTY OF border 'LINESTYLE' = '1'.
  SET PROPERTY OF border 'WEIGTH' = 2.
  FREE OBJECT border.

  CALL METHOD OF lo_worksheet 'Columns' = lo_column..
  CALL METHOD OF lo_column 'Autofit'.
  FREE OBJECT lo_column.


  CONCATENATE lv_selected_folder '\MatUpldTemplate' INTO lv_complete_path.

  CALL METHOD OF lo_workbook 'SaveAs'
    EXPORTING
      #1 = lv_complete_path.
  IF sy-subrc EQ 0.
    MESSAGE 'File downloaded successfully’' TYPE 'S'.
  ELSE.
    MESSAGE 'Error downloading the file' TYPE 'E'.
  ENDIF.

  CALL METHOD OF lo_application 'QUIT'.
  FREE OBJECT lo_worksheet.
  FREE OBJECT lo_workbook.
  FREE OBJECT lo_application.
ENDFORM.

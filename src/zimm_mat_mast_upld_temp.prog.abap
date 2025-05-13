*----------------------------------------------------------------------*
***INCLUDE ZIMM_MAT_MAST_UPLD_TEMP.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zIMM_MAT_MAST_UPLD_TEMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zimm_mat_mast_upld_temp .



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


DATA lwf_filename            TYPE string.
  DATA lwf_path                TYPE string.
  DATA lwf_fullpath            TYPE string.
  DATA lwf_user_action         TYPE i.
  DATA lint_data_tab           TYPE TABLE OF ty_format.
  DATA gwa_des_format            LIKE LINE OF lint_data_tab.


  gwa_des_format-matnr = 'Parts Number(MATNR)'.
  gwa_des_format-mtart = 'Material Type(MTART)'.
  gwa_des_format-werks = 'Plant(WERKS)'.
  gwa_des_format-lgort = 'Storage Location(LGORT)'.
  gwa_des_format-lgnum = 'Warehouse number(LGNUM)'.
  gwa_des_format-maktx = 'Material Description (Short Text)(MAKTX)'.
  gwa_des_format-maktxarb = 'Material Description (Short Text) - Arabic(MAKTXARB)'.
  gwa_des_format-meins = 'Base Unit of Measure(MEINS)'.
  gwa_des_format-matkl = 'Material Group(MATKL)'.
  gwa_des_format-brgew = 'Gross Weight(BRGEW)'.
  gwa_des_format-ntgew = 'Net Weight(NTGEW)'.
  gwa_des_format-gewei = 'Weight of unit(GEWEI)'.
  gwa_des_format-groes = 'Size/dimensions(GROES)'.
  gwa_des_format-spart = 'Division(SPART)'.
  gwa_des_format-aumng = 'Minimum order quantity in base unit of measure(AUMNG)'.
  gwa_des_format-bismt = 'Old material number(BISMT)'.
  gwa_des_format-xchpf = 'Expiration "x"(XCHPF)'.
  gwa_des_format-extwg = 'External Manterial Group(EXTWG)'.
  gwa_des_format-mfrpn = 'Manufacturer Part Number (40digitnumber)(MFRPN)'.
  gwa_des_format-maabc = 'ABC Indicator(MAABC)'.
  gwa_des_format-eisbe = 'Safety Stock(EISBE)'.
  gwa_des_format-eislo = 'Minimum Safety Stock(EISLO)'.
  gwa_des_format-plifz = 'Planned Delivery Time in Days(PLIFZ)'.
  gwa_des_format-webaz = 'Goods Receipt Processing Time in Days(WEBAZ)'.
  gwa_des_format-bklas = 'Valuation Class(BKLAS)'.
  gwa_des_format-peinh = 'Price Unit(PEINH)'.
  gwa_des_format-verpr = 'Moving Average Price/Periodic Unit Price(VERPR)'.
  gwa_des_format-lgpbe = 'Storage Bin(LGPBE)'.
  gwa_des_format-vprsv = 'Price control indicator(VPRSV) '.
  gwa_des_format-vkorg = 'Sales Organization(VKORG)'.
  gwa_des_format-vtweg = 'Distribution Channel(VTWEG)'.
  gwa_des_format-taxm1 = 'Tax classification material(TAXM1)'.
  gwa_des_format-mbrsh = 'Industry sector(MBRSH)'.
  gwa_des_format-kondm = 'Material Pricing Group(KONDM)'.
  gwa_des_format-ktgrm = 'Account assignment group for this material(KTGRM)'.
  gwa_des_format-mtposmara = 'General item category group(MARA-MTPOS)'.
  gwa_des_format-mtposmvke = 'Item category group from material master(MVKE-MTPOS)'.
  gwa_des_format-mtvfp = 'Availability Check(MTVFP)'.
  gwa_des_format-tragr = 'Transportation Group(TRAGR)'.
  gwa_des_format-ladgr = 'Loading Group(LADGR)'.
  gwa_des_format-prctr = 'Profit Center(PRCTR)'.
  gwa_des_format-mfrnr = 'Manufacturer OEM Number(MFRNR)'.
  gwa_des_format-ekgrp = 'Purchasing Group(EKGRP)'.
  gwa_des_format-disgr = 'MRP Group(DISGR)'.
  gwa_des_format-dismm = 'MRP Type(DISMM)'.
  gwa_des_format-minbe = 'Reorder Point(MINBE)'.
  gwa_des_format-disls = 'Lot size (materials planning)(DISLS)'.
  gwa_des_format-dispo = 'MRP Controller (Materials Planner)(DISPO)'.
  gwa_des_format-beskz = 'Procurement Type(BESKZ)'.
  gwa_des_format-wzeit = 'Total replenishment lead time (in workdays)(WZEIT)'.
  gwa_des_format-prmod = 'Forecast Model(PRMOD)'.
  gwa_des_format-perkz = 'Period Indicator(PERKZ)'.
  gwa_des_format-peran = 'Historical periods(PERAN)'.
  gwa_des_format-anzpr = 'Forecast periods(ANZPR)'.
  gwa_des_format-kzini = 'Initialization indicator(KZINI)'.
  gwa_des_format-bwtty = 'Valuation Category(BWTTY)'.
  gwa_des_format-stprs = 'Standard price(STPRS)'.

APPEND gwa_des_format TO lint_data_tab.
  CLEAR: gwa_des_format.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      file_filter               = cl_gui_frontend_services=>filetype_excel
    CHANGING
      filename                  = lwf_filename
      path                      = lwf_path
      fullpath                  = lwf_fullpath
      user_action               = lwf_user_action
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
         ).
  IF sy-subrc <> 0 AND lwf_user_action <> 0.
    RETURN.
  ENDIF.

  cl_gui_frontend_services=>gui_download(
    EXPORTING
      filename                  = lwf_filename
      filetype                  = 'DAT'
    CHANGING
      data_tab                  = lint_data_tab
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
         ).
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.

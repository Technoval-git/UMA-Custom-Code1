*----------------------------------------------------------------------*
***INCLUDE ZMM_PC_TEMP.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zmm_pc_temp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zmm_pc_temp .
  TYPES: BEGIN OF ty_format_hq,
           hq_matnr(160),
           hq_maktx(160),
           hq_pack_qty(160),
           hq_price(160),
           hq_amount(160),
           hq_waers(160),
           hq_car_series(160),
           hq_meins(160),
         END OF ty_format_hq,
         BEGIN OF ty_format_gm,
           gm_matnr(160),
           gm_maktx(160),
           gm_price(160),
           gm_waers(160),
           gm_cour_surc(160),
           gm_comment(160),
           gm_supersession(160),
           gm_min_ord_qty(160),
           gm_merch_qty(160),
           gm_extwg(160),
         END OF ty_format_gm,
         BEGIN OF ty_format_ac,
           ac_matnr(160),
           ac_delco(160),
           ac_maktx(160),
           ac_price(160),
           ac_oeprice(160),
           ac_waers(160),
           ac_cour_surc(160),
           ac_comment(160),
           ac_supersession(160),
           ac_min_ord_qty(160),
           ac_merch_qty(160),
           ac_extwg(160),
           ac_remark(160),
           ac_remark1(160),
         END OF ty_format_ac,
         BEGIN OF ty_format_df,
           df_matnr(160),
           df_maktx(160),
           df_qty(160),
           df_price(160),
           df_amount(160),
           df_waers(160),
           df_carseries(160),
           df_meins(160),
         END OF ty_format_df,
         BEGIN OF ty_format_ma,
           ma_matnr(160),
           ma_maktx(160),
           ma_qty(160),
           ma_price(160),
           ma_amount(160),
           ma_waers(160),
           ma_carseries(160),
           ma_meins(160),
         END OF ty_format_ma.



  DATA :lwf_filename      TYPE string,
        lwf_path          TYPE string,
        lwf_fullpath      TYPE string,
        lwf_user_action   TYPE i,
        lint_data_tab_hq  TYPE TABLE OF ty_format_hq,
        lint_data_tab_ma  TYPE TABLE OF ty_format_ma,
        lint_data_tab_df  TYPE TABLE OF ty_format_df,
        lint_data_tab_gm  TYPE TABLE OF ty_format_gm,
        lint_data_tab_ac  TYPE TABLE OF ty_format_ac,
        hq_gwa_des_format LIKE LINE OF lint_data_tab_hq,
        ac_gwa_des_format LIKE LINE OF lint_data_tab_ac,
        gm_gwa_des_format LIKE LINE OF lint_data_tab_gm,
        df_gwa_des_format LIKE LINE OF lint_data_tab_df,
        ma_gwa_des_format LIKE LINE OF lint_data_tab_ma,
        lv_lint_data      TYPE char16.

  IF p_hq = 'X'.
    hq_gwa_des_format-hq_matnr = 'Part Number'.
    hq_gwa_des_format-hq_maktx = 'Material Description'.
    hq_gwa_des_format-hq_pack_qty = 'Pack Quantity'.
    hq_gwa_des_format-hq_price = 'Price'.
    hq_gwa_des_format-hq_amount = 'Amount'.
    hq_gwa_des_format-hq_waers  = 'Currency'.
    hq_gwa_des_format-hq_car_series = 'Car Series'.
    hq_gwa_des_format-hq_meins = 'Unit'.
    APPEND hq_gwa_des_format TO lint_data_tab_hq.
    lv_lint_data = 'lint_data_tab_hq'.
    CLEAR: hq_gwa_des_format.
  ELSEIF p_gm = 'X'.
    gm_gwa_des_format-gm_matnr = 'Part Number'.
    gm_gwa_des_format-gm_maktx = 'Material Description'.
    gm_gwa_des_format-gm_price = 'Price'.
    gm_gwa_des_format-gm_waers = 'Currency'.
    gm_gwa_des_format-gm_cour_surc = 'Cour Surc Price'.
    gm_gwa_des_format-gm_comment = 'Comment'.
    gm_gwa_des_format-gm_supersession = 'Material for supersession'.
    gm_gwa_des_format-gm_min_ord_qty = 'Minimum Order Quantity'.
    gm_gwa_des_format-gm_merch_qty = 'Merchandise Quantity'.
    gm_gwa_des_format-gm_extwg = 'External Material Group'.
    APPEND gm_gwa_des_format TO lint_data_tab_gm.
    lv_lint_data = 'lint_data_tab_gm'.
    CLEAR: gm_gwa_des_format.
  ELSEIF p_ac = 'X'.

    ac_gwa_des_format-ac_matnr = 'Part Number'.
    ac_gwa_des_format-ac_delco = 'Material Number'.
    ac_gwa_des_format-ac_maktx = 'Material Description'.
    ac_gwa_des_format-ac_price = 'Net Price'.
    ac_gwa_des_format-ac_oeprice = 'Net Price'.
    ac_gwa_des_format-ac_waers = 'Currency Key'.
    ac_gwa_des_format-ac_cour_surc = 'Net Price'.
    ac_gwa_des_format-ac_comment = 'Comment'.
    ac_gwa_des_format-ac_supersession = 'Material Number'.
    ac_gwa_des_format-ac_min_ord_qty = 'Minimum Order Quantity'.
    ac_gwa_des_format-ac_merch_qty = 'Merchandise Quantity'.
    ac_gwa_des_format-ac_extwg = 'External Material Group'.
    ac_gwa_des_format-ac_remark = 'Comment'.
    ac_gwa_des_format-ac_remark1 = 'Comment'.
    APPEND ac_gwa_des_format TO lint_data_tab_ac.
    CLEAR: ac_gwa_des_format.
    lv_lint_data = 'lint_data_tab_ac'.
  ELSEIF p_df = 'X'.
    df_gwa_des_format-df_matnr = 'Spare Part Code'.
    df_gwa_des_format-df_maktx = 'Spare part name'.
    df_gwa_des_format-df_qty  = 'Package Quantity'.
    df_gwa_des_format-df_price  = 'Unit price expressed by currency'.
    df_gwa_des_format-df_amount = 'Amount'.
    df_gwa_des_format-df_waers = 'Currency symbol code '.
    df_gwa_des_format-df_carseries = 'Car Series'.
    df_gwa_des_format-df_meins = 'Unit of measurement'.
    APPEND df_gwa_des_format TO lint_data_tab_df.
    CLEAR: df_gwa_des_format.
    lv_lint_data = 'lint_data_tab_df'.
  ELSEIF p_ma = 'X'.
      ma_gwa_des_format-ma_matnr = 'Spare Part Code'.
    ma_gwa_des_format-ma_maktx = 'Spare part name'.
    ma_gwa_des_format-ma_qty  = 'Package Quantity'.
    ma_gwa_des_format-ma_price  = 'Unit price expressed by currency'.
    ma_gwa_des_format-ma_amount = 'Amount'.
    ma_gwa_des_format-ma_waers = 'Currency symbol code '.
    ma_gwa_des_format-ma_carseries = 'Car Series'.
    ma_gwa_des_format-ma_meins = 'Unit of measurement'.
    APPEND ma_gwa_des_format TO lint_data_tab_ma.
    CLEAR: ma_gwa_des_format.
    lv_lint_data = 'lint_data_tab_ma'.
  ENDIF.


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
  IF p_gm = 'X'.
    cl_gui_frontend_services=>gui_download(
      EXPORTING
        filename                  = lwf_filename
        filetype                  = 'DAT'
      CHANGING
        data_tab                  = lint_data_tab_gm
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
  ELSEIF p_ac = 'X'.
    cl_gui_frontend_services=>gui_download(
    EXPORTING
      filename                  = lwf_filename
      filetype                  = 'DAT'
    CHANGING
      data_tab                  = lint_data_tab_ac
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
  ELSEIF p_HQ = 'X'.
    cl_gui_frontend_services=>gui_download(
    EXPORTING
      filename                  = lwf_filename
      filetype                  = 'DAT'
    CHANGING
      data_tab                  = lint_data_tab_hq
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

   ELSEIF p_df = 'X'.
     cl_gui_frontend_services=>gui_download(
    EXPORTING
      filename                  = lwf_filename
      filetype                  = 'DAT'
    CHANGING
      data_tab                  = lint_data_tab_df
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
   ELSEIF p_ma = 'X'.
    cl_gui_frontend_services=>gui_download(
    EXPORTING
      filename                  = lwf_filename
      filetype                  = 'DAT'
    CHANGING
      data_tab                  = lint_data_tab_ma
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
  ENDIF.

ENDFORM.

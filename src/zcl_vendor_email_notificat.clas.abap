class ZCL_VENDOR_EMAIL_NOTIFICAT definition
  public
  final
  create public .

public section.

  class-methods NORM_OPEN_ITMS
    importing
      !IM_UMSKZ type UMSKZ default SPACE
      !IM_AUGBL type AUGBL default SPACE
      !IM_NETDT type NETDT optional
      !IM_BSCHL type BSCHL optional
      !IM_KOART type KOART default 'K'
    exporting
      !ET_TABLE type ZTT_VEN_BLNS .
  class-methods ADVANCES
    importing
      !IM_UMSKZ type UMSKZ default 'A'
      !IM_AUGBL type AUGBL default SPACE
      !IM_NETDT type NETDT optional
      !IM_BSCHL type BSCHL optional
      !IM_KOART type KOART default 'K'
    exporting
      !ET_TABLE type ZTT_VEN_BLNS .
  class-methods ON_ACCOUNT_PYMNTS
    importing
      !IM_UMSKZ type UMSKZ default SPACE
      !IM_AUGBL type AUGBL default SPACE
      !IM_NETDT type NETDT optional
      !IM_BSCHL type BSCHL optional
      !IM_KOART type KOART default 'K'
    exporting
      !ET_TABLE type ZTT_VEN_BLNS .
  class-methods GET_OVERDUE_DAYS
    importing
      !IM_KEY_DATE type SY-DATUM optional
      !IM_DUE_DATE type SY-DATUM
    exporting
      !ES_OVERDUE_DAYS type RFPOSX-VERZN .
  class-methods ITAB_TO_XSTRING
    importing
      !IR_DATA_REF type ref to DATA
    returning
      value(RV_XSTRING) type XSTRING .
  class-methods EMAIL
    importing
      !IM_STRING_NORM type XSTRING optional
      !IM_STRING_ADV type XSTRING optional
      !IM_STRING_ONACC type XSTRING optional
    changing
      !IM_USR_TABLE type ZTT_FI_VEND_USER .
  class-methods EMAIL1
    importing
      !IM_STRING_NORM type XSTRING optional
      !IM_STRING_ADV type XSTRING optional
      !IM_STRING_ONACC type XSTRING optional
      !IT_NORM_TAB type ZTT_VEN_BLNS optional
      !IT_ADV_TAB type ZTT_VEN_BLNS optional
      !IT_ONACC_TAB type ZTT_VEN_BLNS optional
    changing
      !IM_USR_TABLE type ZTT_FI_VEND_USER optional .
  PROTECTED SECTION.
private section.

  class-methods EMAIL_BODY
    changing
      !IM_DUEDAYS_TAB type ZTT_DUEDAYS optional
      !ET_CONTENT type SRM_T_SOLISTI1 optional
      !IS_VEND_NOTIFIC type ZTT_FI_VEND_USER optional .
  class-methods LO_EXCEL_INI
    exporting
      !LO_EXCEL type ref to ZCL_EXCEL
      !LO_WORKSHEET type ref to ZCL_EXCEL_WORKSHEET
    changing
      !CH_TITLE type ZEXCEL_SHEET_TITLE optional
      !IT_NORM_TAB type ZTT_VEN_BLNS optional
      !IT_ADV_TAB type ZTT_VEN_BLNS optional
      !IT_ONACC_TAB type ZTT_VEN_BLNS optional
      !SHEET_TITLE type ZEXCEL_SHEET_TITLE optional
      !IT_COMMON_TAB1 type ZTT_VEN_BLNS optional
      !IT_COMMON_TAB2 type ZTT_VEN_BLNS optional .
ENDCLASS.



CLASS ZCL_VENDOR_EMAIL_NOTIFICAT IMPLEMENTATION.


  METHOD advances.
    SELECT SINGLE name,
         low
        FROM tvarvc
        INTO @DATA(lwa_notif_day)
        WHERE name = 'ZFI_VEND_NOTIF_DAYS'.
    DATA lv_net_due_date TYPE netdt.

    lv_net_due_date = sy-datum - lwa_notif_day-low.

    SELECT a~bukrs,
      a~belnr,
      a~gjahr,
      a~umskz,
*      a~dmbtr,
  CASE WHEN a~shkzg = 'H' THEN  ( - a~dmbtr )
  WHEN a~shkzg = 'S' THEN  a~dmbtr
  END AS dmbtr,
      a~h_hwaer,
      a~wrbtr,
      a~h_waers,
      a~lifnr,
      a~awkey,
      a~netdt,
      a~h_budat,
      a~h_bldat,
*       b~xblnr,
*       B~waers,
      c~ktokk,
      c~name1,
      d~txt30
*      b~waers
      FROM bseg AS a
      INNER JOIN lfa1 AS c ON a~lifnr = c~lifnr
*      INNER JOIN bsik_view AS b ON a~lifnr = b~lifnr
      INNER JOIN t077y AS d ON c~ktokk = d~ktokk
      WHERE a~koart = @im_koart
      AND a~umskz = @im_umskz
      AND a~augbl = @im_augbl
*      AND a~netdt >= @lv_net_due_date
*      AND a~bschl <> 35 AND a~bschl <> 25
      AND ( a~bukrs = 1000 OR a~bukrs = 2100 OR a~bukrs = 2200 ) AND d~spras = 'E'
      INTO TABLE @et_table.

    SORT et_table.
*    DELETE et_table WHERE netdt < lv_net_due_date.
    DELETE ADJACENT DUPLICATES FROM et_table  COMPARING ALL FIELDS.

  ENDMETHOD.


  METHOD email.

    DATA: mail_subject(50) TYPE c,
          lo_sent_req      TYPE REF TO cl_bcs,
          lt_body          TYPE bcsy_text,
          lo_sender        TYPE REF TO if_sender_bcs,
          lv_type          TYPE so_obj_tp VALUE 'HTM',
          lv_att_sub       TYPE sood-objdes,
          lo_document      TYPE REF TO cl_document_bcs,
          lo_recipient     TYPE REF TO cl_cam_address_bcs,
          lt_email_body    TYPE bcsy_text,
          et_content       TYPE srm_t_solisti1,
          im_duedays_tab   TYPE ztt_duedays,
          wa_duedays_tab   TYPE ztb_duedays.

    LOOP AT im_usr_table ASSIGNING FIELD-SYMBOL(<fs_user_tab>).
      mail_subject = 'Subject to be change'.
      wa_duedays_tab-bukrs = <fs_user_tab>-zfi_bukrs.
      APPEND wa_duedays_tab TO im_duedays_tab.
      email_body(
        CHANGING
          im_duedays_tab = im_duedays_tab
          et_content     = et_content
      ).

      TRY.
          lo_sender = cl_sapuser_bcs=>create( sy-uname ).
        CATCH  cx_address_bcs  INTO DATA(lv_catch3).
          DATA(lv_text1) =  lv_catch3->get_text( ).
      ENDTRY.

      TRY.
          lo_sent_req  = cl_bcs=>create_persistent( ).
        CATCH cx_root INTO DATA(gr_err).
          DATA(lv_text7) = gr_err->get_text( ).
      ENDTRY.
      TRY.
          lo_document = cl_document_bcs=>create_document(
            i_type    = lv_type
            i_subject = mail_subject
            i_text    = et_content ).
*            i_text    = lt_email_body ).
        CATCH cx_document_bcs INTO DATA(lv_catch8).
          lv_catch8->get_text(
            RECEIVING
              result = DATA(lv_text8)             " ---
          ).
      ENDTRY.
      IF <fs_user_tab>-zfi_normal_invoices = 'X'.
        TRY.
            lo_document->add_attachment(
              i_attachment_type    = 'xls'
              i_attachment_size    = CONV #( xstrlen( im_string_norm ) )
              i_attachment_subject = 'Normal invoice'
              i_att_content_hex    = cl_bcs_convert=>xstring_to_solix( im_string_norm )
            ).
          CATCH cx_document_bcs INTO DATA(lv_catch1).
            lv_catch1->get_text(
              RECEIVING
                result = DATA(lv_text6)             " ---
            ).
        ENDTRY.
      ENDIF.
      IF <fs_user_tab>-zfi_advances = 'X'.
*        IF <fs_user_tab>-zfi_normal_invoices = 'X'.
*          TRY.
*              lo_document->add_document_as_attachment( im_document = lo_document ).
*            CATCH cx_document_bcs INTO DATA(lv_catch40).
*              lv_catch40->get_text(
*                RECEIVING
*                  result = DATA(lv_text40)             " ---
*              ).
*          ENDTRY.
*        ENDIF.
        TRY.
            lo_document->add_attachment(
              i_attachment_type    = 'xls'
              i_attachment_size    = CONV #( xstrlen( im_string_adv ) )
              i_attachment_subject = 'Advances'
              i_att_content_hex    = cl_bcs_convert=>xstring_to_solix( im_string_adv )
            ).
          CATCH cx_document_bcs INTO DATA(lv_catch2).
            lv_catch2->get_text(
              RECEIVING
                result = DATA(lv_text2)             " ---
            ).
        ENDTRY.
      ENDIF.
      IF <fs_user_tab>-zfi_onaccountpayments = 'X'.
        TRY.
            lo_document->add_attachment(
              i_attachment_type    = 'xls'
              i_attachment_size    = CONV #( xstrlen( im_string_onacc ) )
              i_attachment_subject = 'On account invoice'
              i_att_content_hex    = cl_bcs_convert=>xstring_to_solix( im_string_onacc )
            ).
          CATCH cx_document_bcs INTO DATA(lv_catch7).
            lv_catch7->get_text(
              RECEIVING
                result = DATA(lv_text3)             " ---
            ).
        ENDTRY.
      ENDIF.
      TRY.
          lo_recipient  = cl_cam_address_bcs=>create_internet_address(  CONV adr6-smtp_addr( <fs_user_tab>-zfi_emailaddress ) ).
          lo_sent_req->add_recipient(
            EXPORTING
              i_recipient = lo_recipient
          ).
        CATCH cx_address_bcs INTO DATA(lv_catch4).
        CATCH cx_send_req_bcs INTO DATA(lv_catch5).
          DATA(lv_text4) = lv_catch1->get_text( ).
          DATA(lv_text5) = lv_catch2->get_text( ).
      ENDTRY.
      TRY.
          lo_sent_req->set_document( i_document =  lo_document ).
          lo_sent_req->send( ).
        CATCH cx_send_req_bcs INTO DATA(lx_req_bsc).
          lx_req_bsc->get_text(
            RECEIVING
              result = DATA(lv_error)
          ).
      ENDTRY.
      COMMIT WORK.
      CLEAR : lo_sent_req,lo_document,lo_recipient,lo_sender,lt_email_body,mail_subject,lo_sender,im_duedays_tab,et_content,wa_duedays_tab.
    ENDLOOP.
    CLEAR : im_usr_table.
  ENDMETHOD.


  METHOD email1.
    DATA: mail_subject(50)    TYPE c,
          lo_sent_req         TYPE REF TO cl_bcs,
          lt_body             TYPE bcsy_text,
          lo_sender           TYPE REF TO if_sender_bcs,
          lv_type             TYPE so_obj_tp VALUE 'HTM',
          lv_att_sub          TYPE sood-objdes,
          lo_document         TYPE REF TO cl_document_bcs,
          lo_recipient        TYPE REF TO cl_cam_address_bcs,
          lt_email_body       TYPE bcsy_text,
          et_content          TYPE srm_t_solisti1,
          im_duedays_tab      TYPE ztt_duedays,
          wa_duedays_tab      TYPE ztb_duedays,
          sood_bytecount      TYPE sood-objlen,
          t_attachment_header TYPE soli_tab,
          lv_sheet_ti         TYPE zexcel_sheet_title,
          cl_excel            TYPE REF TO zcl_excel,
          iv_info_message     TYPE abap_bool VALUE abap_true,
          xdata               TYPE xstring,
          t_rawdata           TYPE solix_tab,
          bytecount           TYPE i,
          cl_writer           TYPE REF TO zif_excel_writer,
          cl_error            TYPE REF TO zcx_excel,

          lo_excel            TYPE REF TO zcl_excel,
          lo_worksheet        TYPE REF TO zcl_excel_worksheet,
          cl_worksheet        TYPE REF TO zcl_excel_worksheet,
          lo_column           TYPE REF TO zcl_excel_column,
          ls_table_settings   TYPE zexcel_s_table_settings,
          lv_title            TYPE zexcel_sheet_title,
          row                 TYPE zexcel_cell_row VALUE 2,
          ls_error            TYPE zcl_excel_worksheet=>mty_s_ignored_errors,
          lt_error            TYPE zcl_excel_worksheet=>mty_th_ignored_errors,
          lo_range            TYPE REF TO zcl_excel_range,
          lo_data_validation  TYPE REF TO zcl_excel_data_validation.

    DATA: lv_sum1 TYPE dmbtr.
    DATA: lv_sum2 TYPE dmbtr.
    DATA: lv_sum3 TYPE dmbtr.
    DATA(onaccpayment) = 'Onaccpayment'.
    DATA(normalinv) = 'Normal invoice'.
    DATA(advances) = 'Advances'.
*    DATA : o_days TYPE verzn.
*    DATA : lv_days TYPE verzn.
    CONSTANTS: c_airlines TYPE string VALUE 'Airlines'.
    CONSTANTS: gc_save_file_name TYPE string VALUE 'tableswithmtab.xlsx'.

    CREATE OBJECT : cl_excel.


    SELECT SINGLE name,
       low
      FROM tvarvc
      INTO @DATA(lwa_notif_day)
      WHERE name = 'ZFI_VEND_NOTIF_DAYS'.

*   1 = Normal Open Items  2 = Advances  3 = On Account payments.

    DATA lv_net_due_date TYPE netdt.

    lv_net_due_date = sy-datum + lwa_notif_day-low.


*    BREAK-POINT.
    LOOP AT im_usr_table ASSIGNING FIELD-SYMBOL(<fs_user_tab>).

      DATA(itab_norm) = it_norm_tab[].
      DATA(itab_adv) = it_adv_tab[].
      DATA(itab_onacc) = it_onacc_tab[].
      DELETE itab_norm WHERE bukrs <> <fs_user_tab>-zfi_bukrs.
      DELETE itab_adv WHERE bukrs <> <fs_user_tab>-zfi_bukrs.
      DELETE itab_onacc WHERE bukrs <> <fs_user_tab>-zfi_bukrs.

      mail_subject = 'Subject to be change'.
*      wa_duedays_tab-bukrs = <fs_user_tab>-zfi_bukrs.
*      APPEND wa_duedays_tab TO im_duedays_tab.
*      email_body(
*        CHANGING
*          im_duedays_tab = im_duedays_tab
*          et_content     = et_content
*      ).

      TRY.
          lo_sender = cl_sapuser_bcs=>create( sy-uname ).
        CATCH  cx_address_bcs  INTO DATA(lv_catch3).
          DATA(lv_text1) =  lv_catch3->get_text( ).
      ENDTRY.

      TRY.
          lo_sent_req  = cl_bcs=>create_persistent( ).
        CATCH cx_root INTO DATA(gr_err).
          DATA(lv_text7) = gr_err->get_text( ).
      ENDTRY.
      IF <fs_user_tab>-zfi_normal_invoices = 'X'.

        SORT itab_norm BY netdt.
        SELECT SUM( dmbtr ) FROM @itab_norm AS amount WHERE netdt < @sy-datum  INTO @lv_sum1 . "oday
        SELECT SUM( dmbtr ) FROM @itab_norm AS amount WHERE netdt = @sy-datum  INTO @lv_sum2.   "bday
        SELECT SUM( dmbtr ) FROM @itab_norm AS amount WHERE netdt > @lv_net_due_date  INTO @lv_sum3 .   "uday

        wa_duedays_tab-bukrs = <fs_user_tab>-zfi_bukrs.
        wa_duedays_tab-categ = normalinv.
        wa_duedays_tab-o_day = lv_sum1.
        wa_duedays_tab-b_day = lv_sum2.
        wa_duedays_tab-u_day = lv_sum3.
        APPEND wa_duedays_tab TO im_duedays_tab.
        CLEAR: lv_sum1,lv_sum2,lv_sum3,wa_duedays_tab.
        lv_title = 'Normal invoice'.
        lv_sheet_ti  = 'Normal invoice'.
        lo_excel_ini(
          IMPORTING
            lo_excel       = lo_excel
            lo_worksheet   = lo_worksheet
          CHANGING
            ch_title       = lv_sheet_ti
            sheet_title    = lv_sheet_ti
            it_common_tab1 = itab_norm
            it_common_tab2 = itab_norm
        ).
      ENDIF.
      IF <fs_user_tab>-zfi_advances = 'X'.

        SORT itab_adv BY netdt.
        SELECT SUM( dmbtr ) FROM @itab_adv AS amount WHERE netdt < @sy-datum  INTO @lv_sum1 . "oday
        SELECT SUM( dmbtr ) FROM @itab_adv AS amount WHERE netdt = @sy-datum  INTO @lv_sum2.   "bday
        SELECT SUM( dmbtr ) FROM @itab_adv AS amount WHERE netdt > @lv_net_due_date  INTO @lv_sum3 .   "uday

        wa_duedays_tab-bukrs = <fs_user_tab>-zfi_bukrs.
        wa_duedays_tab-categ = advances.
        wa_duedays_tab-o_day = lv_sum1.
        wa_duedays_tab-b_day = lv_sum2.
        wa_duedays_tab-u_day = lv_sum3.
        APPEND wa_duedays_tab TO im_duedays_tab.
        CLEAR: lv_sum1,lv_sum2,lv_sum3,wa_duedays_tab.

        lv_title = 'Advances'.
        lv_sheet_ti  = 'Advances'.
        lo_excel_ini(
          IMPORTING
            lo_excel       = lo_excel
            lo_worksheet   = lo_worksheet
          CHANGING
            ch_title       = lv_sheet_ti
            sheet_title    = lv_sheet_ti
            it_common_tab1 = itab_adv
            it_common_tab2 = itab_adv
        ).
      ENDIF.

      IF <fs_user_tab>-zfi_onaccountpayments = 'X'.

        SORT itab_onacc BY netdt.
        SELECT SUM( dmbtr ) FROM @itab_onacc AS amount WHERE netdt < @sy-datum  INTO @lv_sum1 . "oday
        SELECT SUM( dmbtr ) FROM @itab_onacc AS amount WHERE netdt = @sy-datum  INTO @lv_sum2.   "bday
        SELECT SUM( dmbtr ) FROM @itab_onacc AS amount WHERE netdt > @lv_net_due_date  INTO @lv_sum3 .   "uday

        wa_duedays_tab-bukrs = <fs_user_tab>-zfi_bukrs.
        wa_duedays_tab-categ = onaccpayment..
        wa_duedays_tab-o_day = lv_sum1.
        wa_duedays_tab-b_day = lv_sum2.
        wa_duedays_tab-u_day = lv_sum3.
        APPEND wa_duedays_tab TO im_duedays_tab.
        CLEAR: lv_sum1,lv_sum2,lv_sum3,wa_duedays_tab.

        lv_title = 'Onccdvances'.
        lv_sheet_ti  = 'Onccdvances'.
        lo_excel_ini(
          IMPORTING
            lo_excel       = lo_excel
            lo_worksheet   = lo_worksheet
          CHANGING
            ch_title       = lv_sheet_ti
            sheet_title    = lv_sheet_ti
            it_common_tab1 = itab_onacc
            it_common_tab2 = itab_onacc
        ).
      ENDIF.
      TRY.

          CREATE OBJECT cl_writer TYPE zcl_excel_writer_2007.
          xdata = cl_writer->write_file( lo_excel ).
          t_rawdata = cl_bcs_convert=>xstring_to_solix( iv_xstring  = xdata ).
          bytecount = xstrlen( xdata ).
        CATCH zcx_excel INTO cl_error.
          IF iv_info_message = abap_true.
            MESSAGE cl_error TYPE 'I' DISPLAY LIKE 'E'.
          ELSE.
            TRY.
              CATCH zcx_excel INTO cl_error.
                DATA(lv_text) = cl_error->get_text(
                 ).
            ENDTRY.
          ENDIF.

      ENDTRY.
      TRY.

          email_body(
            CHANGING
              im_duedays_tab = im_duedays_tab
              et_content     = et_content
          ).
          TRY.
              lo_document = cl_document_bcs=>create_document(
                i_type    = lv_type
                i_subject = mail_subject
                i_text    = et_content ).
*            i_text    = lt_email_body ).
            CATCH cx_document_bcs INTO DATA(lv_catch8).
              lv_catch8->get_text(
                RECEIVING
                  result = DATA(lv_text8)             " ---
              ).
          ENDTRY.
          sood_bytecount = bytecount.
          lo_document->add_attachment( i_attachment_type    = 'XLS' "#EC NOTEXT
                                       i_attachment_subject = 'Balances'
                                       i_attachment_size    = sood_bytecount
                                       i_att_content_hex    = t_rawdata ).
        CATCH cx_document_bcs INTO DATA(lv_catch1).
      ENDTRY.
      TRY.
          lo_recipient  = cl_cam_address_bcs=>create_internet_address(  CONV adr6-smtp_addr( <fs_user_tab>-zfi_emailaddress ) ).
          lo_sent_req->add_recipient(
            EXPORTING
              i_recipient = lo_recipient
          ).
        CATCH cx_address_bcs INTO DATA(lv_catch4).
        CATCH cx_send_req_bcs INTO DATA(lv_catch5).
          DATA(lv_text4) = lv_catch4->get_text( ).
          DATA(lv_text5) = lv_catch5->get_text( ).
      ENDTRY.
      TRY.
          lo_sent_req->set_document( i_document =  lo_document ).
          lo_sent_req->send( ).
        CATCH cx_send_req_bcs INTO DATA(lx_req_bsc).
          lx_req_bsc->get_text(
            RECEIVING
              result = DATA(lv_error)
          ).
      ENDTRY.
      COMMIT WORK.
      CLEAR : lo_sent_req,lo_document,lo_recipient,lo_sender,lt_email_body,mail_subject,
      lo_sender,im_duedays_tab,et_content,wa_duedays_tab,lo_excel,t_rawdata,
      lo_worksheet,xdata,bytecount,itab_norm,itab_adv,itab_onacc,lv_title,lv_sheet_ti.
    ENDLOOP.
    CLEAR : im_usr_table.
  ENDMETHOD.


  METHOD email_body.

    DATA : wa_contents TYPE solisti1,
           c_space(6)  TYPE c VALUE '&nbsp'.

    "email body
    wa_contents-line = '<HTML> <BODY>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    CONCATENATE '<p style="font-family:Calibri;font-size:15;">' 'Dear ,' INTO wa_contents-line.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.


    wa_contents-line = '<br>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<br>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.



    CONCATENATE 'We wish to inform you that your due details are as follows'
    ':-'
     INTO wa_contents-line SEPARATED BY space.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.


    "html body
    wa_contents-line = '<table style="font-family:calibri;font-size:15;MARGIN:10px;"'.   " bordercolor="blue"'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = 'cellspacing="0" cellpadding="1" width="75%" '.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = 'border="1"><tbody><tr>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<th bgcolor="#ADD8E6">Company Code</th>'.                    "66CCFF
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<th bgcolor="#ADD8E6">Category</th>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.


    wa_contents-line = '<th bgcolor="#ADD8E6">Over due</th>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<th bgcolor="#ADD8E6">Due today</th>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

*    wa_contents-line = '<th bgcolor="#ADD8E6">Due in 7 days</th>'.
*    APPEND wa_contents TO et_content.
*    CLEAR : wa_contents.

    "table content
    LOOP AT im_duedays_tab INTO DATA(gs_duetab).

      wa_contents-line = '<tr align = "center">'.
      APPEND wa_contents TO et_content.
      CLEAR : wa_contents.

*      lv_cnt = lv_cnt + 1.
      CONCATENATE '<td>' gs_duetab-bukrs '</td>' INTO wa_contents-line SEPARATED BY space.
      APPEND wa_contents TO et_content.
      CLEAR : wa_contents.

      CONCATENATE '<td>' gs_duetab-categ '</td>' INTO wa_contents-line SEPARATED BY space.
      APPEND wa_contents TO et_content.
      CLEAR : wa_contents.

      CONCATENATE '<td>' gs_duetab-o_day '</td>' INTO wa_contents-line SEPARATED BY space.
      APPEND wa_contents TO et_content.
      CLEAR : wa_contents.

      CONCATENATE '<td>' gs_duetab-b_day '</td>' INTO wa_contents-line SEPARATED BY space.
      APPEND wa_contents TO et_content.
      CLEAR : wa_contents.

*      CONCATENATE '<td>' gs_duetab-u_day '</td>' INTO wa_contents-line SEPARATED BY space.
*      APPEND wa_contents TO et_content.
*      CLEAR : wa_contents.
    ENDLOOP.

*----------------------------end on 17.07.2017--------------------------------------*
    wa_contents-line = '</tbody> </table>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<br>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<br>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = 'Kindly note:'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<br>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    CONCATENATE c_space c_space c_space c_space '-  this is system generated email.' INTO wa_contents-line SEPARATED BY space.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<br>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<br>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = 'Regards,'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<br>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = 'MR.XYZ'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

    wa_contents-line = '<br>'.
    APPEND wa_contents TO et_content.
    CLEAR : wa_contents.

  ENDMETHOD.


  METHOD get_overdue_days.

    CALL FUNCTION 'FAGL_ITEM_OVERDUE_DAYS'
      EXPORTING
        key_date     = im_key_date
*       PAY_DATE     =
        due_date     = im_due_date
*       CLEAR_DATE   =
      IMPORTING
*       OVER_SKONTO1_DAYS       =
        overdue_days = es_overdue_days.

  ENDMETHOD.


  METHOD itab_to_xstring.
    FIELD-SYMBOLS: <fs_data> TYPE ANY TABLE.

    CLEAR rv_xstring.
    ASSIGN ir_data_ref->* TO <fs_data>.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = DATA(lo_table)
          CHANGING
            t_table      = <fs_data> ).

        DATA(lt_fcat) =
          cl_salv_controller_metadata=>get_lvc_fieldcatalog(
          r_columns      = lo_table->get_columns( )
          r_aggregations = lo_table->get_aggregations( ) ).

        DATA(lo_result) =
          cl_salv_ex_util=>factory_result_data_table(
          r_data         = ir_data_ref
          t_fieldcatalog = lt_fcat ).

        cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform(
          EXPORTING
            xml_type      = if_salv_bs_xml=>c_type_xlsx
            xml_version   = cl_salv_bs_a_xml_base=>get_version( )
            r_result_data = lo_result
            xml_flavour   = if_salv_bs_c_tt=>c_tt_xml_flavour_export
            gui_type      = if_salv_bs_xml=>c_gui_type_gui
          IMPORTING
            xml           = rv_xstring ).
      CATCH cx_root.
        CLEAR rv_xstring.
    ENDTRY.
  ENDMETHOD.


  METHOD norm_open_itms.
    CONSTANTS : lv_val type REBZG VALUE 'V'.
    CONSTANTS : lv_val1 type REBZG VALUE abap_true.
    SELECT SINGLE name,
       low
      FROM tvarvc
      INTO @DATA(lwa_notif_day)
      WHERE name = 'ZFI_VEND_NOTIF_DAYS'.
    DATA lv_net_due_date TYPE netdt.

    lv_net_due_date = sy-datum - lwa_notif_day-low.

    SELECT a~bukrs,
      a~belnr,
      a~gjahr,
      a~umskz,
*      a~dmbtr,
  CASE WHEN a~shkzg = 'H' THEN  ( - a~dmbtr )
  WHEN a~shkzg = 'S' THEN  a~dmbtr
  END AS dmbtr,
      a~h_hwaer,
      a~wrbtr,
      a~h_waers,
      a~lifnr,
      a~awkey,
      a~netdt,
      a~h_budat,
      a~h_bldat,
*       b~xblnr, "ASK FOR BOTH KEYS
*       B~waers,
      c~ktokk,
      c~name1,
      d~txt30
*      b~waers
      FROM bseg AS a
      INNER JOIN lfa1 AS c ON a~lifnr = c~lifnr
      INNER JOIN t077y AS d ON c~ktokk = d~ktokk
      WHERE a~koart = @im_koart
      AND a~umskz = @im_umskz
      AND a~augbl = @im_augbl
*      AND a~netdt >= @lv_net_due_date
*      AND a~bschl <> 35 AND a~bschl <> 25

      AND ( a~bukrs = 1000 OR a~bukrs = 2100 OR a~bukrs = 2200 ) AND d~spras = 'E'
 AND ( a~rebzg <> @lv_val or a~rebzg <> @lv_val1 )

      INTO TABLE @et_table
      .

    SORT et_table.
*    DELETE et_table WHERE netdt < lv_net_due_date.
    DELETE ADJACENT DUPLICATES FROM et_table  COMPARING ALL FIELDS.
  ENDMETHOD.


  METHOD on_account_pymnts.
    SELECT SINGLE name,
         low
        FROM tvarvc
        INTO @DATA(lwa_notif_day)
        WHERE name = 'ZFI_VEND_NOTIF_DAYS'.
    DATA lv_net_due_date TYPE netdt.

    lv_net_due_date = sy-datum - lwa_notif_day-low.

    SELECT a~bukrs,
      a~belnr,
      a~gjahr,
      a~umskz,
*      a~dmbtr,
  CASE WHEN a~shkzg = 'H' THEN  ( - a~dmbtr )
  WHEN a~shkzg = 'S' THEN  a~dmbtr
  END AS dmbtr,
      a~h_hwaer,
      a~wrbtr,
      a~h_waers,
      a~lifnr,
      a~awkey,
      a~netdt,
      a~h_budat,
      a~h_bldat,
*       b~xblnr,
*       B~waers,
      c~ktokk,
      c~name1,
      d~txt30
*      b~waers
      FROM bseg AS a
      INNER JOIN lfa1 AS c ON a~lifnr = c~lifnr
*      INNER JOIN bsik_view AS b ON a~lifnr = b~lifnr
      INNER JOIN t077y AS d ON c~ktokk = d~ktokk
      WHERE a~koart = @im_koart
      AND a~umskz = @im_umskz
      AND a~augbl = @im_augbl
*      AND a~netdt >= @lv_net_due_date
      AND ( a~bschl = 35 or a~bschl = 25 )
      AND ( a~bukrs = 1000 OR a~bukrs = 2100 OR a~bukrs = 2200 ) AND d~spras = 'E'
      AND a~rebzg = ' '
      INTO TABLE @et_table.

    SORT et_table.
*    DELETE et_table WHERE netdt < lv_net_due_date.
    DELETE ADJACENT DUPLICATES FROM et_table  COMPARING ALL FIELDS.


  ENDMETHOD.


  METHOD lo_excel_ini.

    DATA: xdata     TYPE xstring,             " Will be used for sending as email
          t_rawdata TYPE solix_tab,           " Will be used for downloading or open directly
          bytecount TYPE i,
          ls_error  TYPE zcl_excel_worksheet=>mty_s_ignored_errors,
          lt_error  TYPE zcl_excel_worksheet=>mty_th_ignored_errors,
          lv_style_mixed_guid      TYPE zexcel_cell_style.
    DATA:
      cl_writer TYPE REF TO zif_excel_writer,
      cl_error  TYPE REF TO zcx_excel.
    DATA:
          lo_column    TYPE REF TO zcl_excel_column.
    DATA: ls_table_settings       TYPE zexcel_s_table_settings.


    IF lo_excel IS NOT BOUND.
      CREATE OBJECT lo_excel.
      TRY.
          lo_worksheet = lo_excel->get_active_worksheet( ).
          lo_worksheet->set_title( ip_title = ch_title ).

          ls_table_settings-table_style       = zcl_excel_table=>builtinstyle_medium2.
          ls_table_settings-show_row_stripes  = abap_true.
          ls_table_settings-nofilters         = abap_true.

          lo_worksheet->bind_table( ip_table          = it_common_tab1
                                    is_table_settings = ls_table_settings ).



          lo_worksheet->freeze_panes( ip_num_columns = 1 ip_num_rows = 1 ). "freeze column headers when scrolling
          IF lines( it_common_tab1 ) >= 1.
            ls_error-cell_coords = |B2:B{ lines( it_common_tab1 ) + 1 }|.
            ls_error-number_stored_as_text = abap_true.
            INSERT ls_error INTO TABLE lt_error.
            lo_worksheet->set_ignored_errors( lt_error ).
          ENDIF.

          lo_column = lo_worksheet->get_column( ip_column = 'A' ). "make date field a bit wider
          lo_column->set_width( ip_width = 9 ).
          lo_column = lo_worksheet->get_column( ip_column = 'B' ). "make date field a bit wider
          lo_column->set_width( ip_width = 17 ).
          lo_column = lo_worksheet->get_column( ip_column = 'C' ). "make date field a bit wider
          lo_column->set_width( ip_width = 10 ).
          lo_column = lo_worksheet->get_column( ip_column = 'D' ). "make date field a bit wider
          lo_column->set_width( ip_width = 14 ).
          lo_column = lo_worksheet->get_column( ip_column = 'E' ). "make date field a bit wider
          lo_column->set_width( ip_width = 14 ).
          lo_column = lo_worksheet->get_column( ip_column = 'F' ). "make date field a bit wider
          lo_column->set_width( ip_width = 13 ).
          lo_column = lo_worksheet->get_column( ip_column = 'G' ). "make date field a bit wider
          lo_column->set_width( ip_width = 11 ).
          lo_column = lo_worksheet->get_column( ip_column = 'H' ). "make date field a bit wider
          lo_column->set_width( ip_width = 9 ).
          lo_column = lo_worksheet->get_column( ip_column = 'I' ). "make date field a bit wider
          lo_column->set_width( ip_width = 16 ).
          lo_column = lo_worksheet->get_column( ip_column = 'J' ). "make date field a bit wider
          lo_column->set_width( ip_width = 20 ).
          lo_column = lo_worksheet->get_column( ip_column = 'K' ). "make date field a bit wider
          lo_column->set_width( ip_width = 14 ).
          lo_column = lo_worksheet->get_column( ip_column = 'L' ). "make date field a bit wider
          lo_column->set_width( ip_width = 13 ).
          lo_column = lo_worksheet->get_column( ip_column = 'M' ). "make date field a bit wider
          lo_column->set_width( ip_width = 15 ).
          lo_column = lo_worksheet->get_column( ip_column = 'N' ). "make date field a bit wider
          lo_column->set_width( ip_width = 13 ).
          lo_column = lo_worksheet->get_column( ip_column = 'O' ). "make date field a bit wider
          lo_column->set_width( ip_width = 30 ).
           lo_column = lo_worksheet->get_column( ip_column = 'P' ). "make date field a bit wider
          lo_column->set_width( ip_width = 24 ).
           lo_column = lo_worksheet->get_column( ip_column = 'Q' ). "make date field a bit wider
          lo_column->set_width( ip_width = 9 ).
          lo_excel->set_active_sheet_index( 1 ).
          lo_worksheet->set_show_gridlines(  i_show_gridlines  = abap_true ).
          lo_worksheet->set_print_gridlines( i_print_gridlines = abap_true ).
          lo_worksheet = lo_excel->get_active_worksheet( ).
        CATCH zcx_excel INTO cl_error.
          DATA(lv_text) = cl_error->get_text(
           ).
      ENDTRY.
    ELSE.
      TRY.
          lo_worksheet = lo_excel->add_new_worksheet( ).
          lo_worksheet->set_title( sheet_title ).
          ls_table_settings-table_style       = zcl_excel_table=>builtinstyle_medium2.
          ls_table_settings-show_row_stripes  = abap_true.
          ls_table_settings-nofilters         = abap_true.

          lo_worksheet->bind_table( ip_table          = it_common_tab2
                                    is_table_settings = ls_table_settings ).
*          lo_column = lo_worksheet->get_column( ip_column = 'A' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 9 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'B' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 17 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'C' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 10 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'D' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 14 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'E' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 12 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'F' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 8 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'G' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 11 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'H' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 20 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'I' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 9 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'J' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 12 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'K' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 14 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'L' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 13 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'M' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 21 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'N' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 21 ).
*          lo_column = lo_worksheet->get_column( ip_column = 'O' ). "make date field a bit wider
*          lo_column->set_width( ip_width = 9 ).
          lo_column = lo_worksheet->get_column( ip_column = 'A' ). "make date field a bit wider
          lo_column->set_width( ip_width = 9 ).
          lo_column = lo_worksheet->get_column( ip_column = 'B' ). "make date field a bit wider
          lo_column->set_width( ip_width = 17 ).
          lo_column = lo_worksheet->get_column( ip_column = 'C' ). "make date field a bit wider
          lo_column->set_width( ip_width = 10 ).
          lo_column = lo_worksheet->get_column( ip_column = 'D' ). "make date field a bit wider
          lo_column->set_width( ip_width = 14 ).
          lo_column = lo_worksheet->get_column( ip_column = 'E' ). "make date field a bit wider
          lo_column->set_width( ip_width = 14 ).
          lo_column = lo_worksheet->get_column( ip_column = 'F' ). "make date field a bit wider
          lo_column->set_width( ip_width = 13 ).
          lo_column = lo_worksheet->get_column( ip_column = 'G' ). "make date field a bit wider
          lo_column->set_width( ip_width = 11 ).
          lo_column = lo_worksheet->get_column( ip_column = 'H' ). "make date field a bit wider
          lo_column->set_width( ip_width = 9 ).
          lo_column = lo_worksheet->get_column( ip_column = 'I' ). "make date field a bit wider
          lo_column->set_width( ip_width = 16 ).
          lo_column = lo_worksheet->get_column( ip_column = 'J' ). "make date field a bit wider
          lo_column->set_width( ip_width = 20 ).
          lo_column = lo_worksheet->get_column( ip_column = 'K' ). "make date field a bit wider
          lo_column->set_width( ip_width = 14 ).
          lo_column = lo_worksheet->get_column( ip_column = 'L' ). "make date field a bit wider
          lo_column->set_width( ip_width = 13 ).
          lo_column = lo_worksheet->get_column( ip_column = 'M' ). "make date field a bit wider
          lo_column->set_width( ip_width = 15 ).
          lo_column = lo_worksheet->get_column( ip_column = 'N' ). "make date field a bit wider
          lo_column->set_width( ip_width = 13 ).
          lo_column = lo_worksheet->get_column( ip_column = 'O' ). "make date field a bit wider
          lo_column->set_width( ip_width = 30 ).
           lo_column = lo_worksheet->get_column( ip_column = 'P' ). "make date field a bit wider
          lo_column->set_width( ip_width = 24 ).
           lo_column = lo_worksheet->get_column( ip_column = 'Q' ). "make date field a bit wider
          lo_column->set_width( ip_width = 9 ).


        CATCH zcx_excel INTO DATA(lo_root).
          DATA(lv_text1) = lo_root->get_text(
           ).
      ENDTRY.
    ENDIF.
    CLEAR :  it_common_tab1,it_common_tab2.
  ENDMETHOD.
ENDCLASS.

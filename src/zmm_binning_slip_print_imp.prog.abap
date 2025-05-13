*&---------------------------------------------------------------------*
*& Include          ZMM_PICKING_SLIP_PRINT_IMP
*&---------------------------------------------------------------------*

CLASS lcl_print_form IMPLEMENTATION.

  METHOD call_form.

    DATA : lwa_formout       TYPE fpformoutput,
           lv_function       TYPE rs38l_fnam,
           lv_formname       TYPE fpname,
           lwa_interfacetype TYPE fpinterfacetype.

    fill_control_strcture(
      EXPORTING
        im_nast         = nast
        im_preview      = ch_preview
      IMPORTING
        ex_outputparams = DATA(lwa_outputparams)
        ex_docparams    = DATA(lwa_docparams) ).

    lwa_outputparams-preview = ch_preview.

    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = lwa_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.

      update_nast_protocol(
        EXPORTING
          im_msgid = sy-msgid
          im_msgno = sy-msgno
          im_msgty = sy-msgty ).

      ch_retcode = 1.
      RETURN.

    ENDIF.

    IF tnapr-sform IS NOT INITIAL.
      lv_formname = tnapr-sform.

      TRY.

          CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
            EXPORTING
              i_name           = lv_formname
            IMPORTING
              e_funcname       = lv_function
              e_interface_type = lwa_interfacetype.

        CATCH cx_root INTO DATA(lo_root).

          update_nast_protocol(
            EXPORTING
              im_msgid = sy-msgid
              im_msgno = sy-msgno
              im_msgty = sy-msgty ).

          ch_retcode = 1.
          RETURN.

      ENDTRY.
    ELSE.
      update_nast_protocol(
        EXPORTING
          im_msgid = sy-msgid
          im_msgno = sy-msgno
          im_msgty = sy-msgty ).

      ch_retcode = 1.
      RETURN.
    ENDIF.

    map_data(
      IMPORTING
        es_header = DATA(ls_header)
        et_items  = DATA(lt_item) ).

    CALL FUNCTION lv_function
      EXPORTING
        /1bcdwb/docparams  = lwa_docparams
        is_header          = ls_header
        it_items           = lt_item
      IMPORTING
        /1bcdwb/formoutput = lwa_formout
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.

    IF sy-subrc <> 0.
      update_nast_protocol(
        EXPORTING
          im_msgid = sy-msgid
          im_msgno = sy-msgno
          im_msgty = sy-msgty ).

      ch_retcode = 1.
      RETURN.
    ENDIF.

    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      update_nast_protocol(
        EXPORTING
          im_msgid = sy-msgid
          im_msgno = sy-msgno
          im_msgty = sy-msgty ).

      ch_retcode = 1.
      RETURN.
    ENDIF.
*      Return Success Code
    ch_retcode = 0.

  ENDMETHOD.

  METHOD fill_control_strcture.
    CLEAR: ex_outputparams,ex_docparams.
    CONSTANTS: lc_mail TYPE fpmedium VALUE 'MAIL'.
    IF im_preview EQ abap_true.
      ex_outputparams-preview   = abap_true.
    ENDIF.
    ex_outputparams-nodialog = abap_true.                 " No Dialog
    ex_outputparams-dest     = im_nast-ldest.             " Printer Name
    ex_outputparams-reqimm   = im_nast-dimme.
    ex_outputparams-reqdel   = im_nast-delet.
    ex_outputparams-copies   = im_nast-anzal.             " No of copies
    ex_outputparams-dataset  = im_nast-dsnam.             " Data Set
    ex_outputparams-suffix1  = im_nast-dsuf1.             " Spool request: Suffix 1
    ex_outputparams-suffix2  = im_nast-dsuf2.             " Spool request: Suffix 2
    ex_outputparams-covtitle = im_nast-tdcovtitle.        " Document Title for email
    ex_outputparams-cover    = im_nast-tdocover.          " Document Cover
    ex_outputparams-receiver = im_nast-tdreceiver.        " Receiver
    ex_outputparams-division = im_nast-tddivision.        " Division
    ex_outputparams-reqfinal = abap_true.                 " Final
    ex_outputparams-arcmode  = im_nast-tdarmod.           " Archiv?
    ex_outputparams-schedule = im_nast-tdschedule.        " Scheduling
    ex_outputparams-senddate = im_nast-vsdat.             " Send Date
    ex_outputparams-sendtime = im_nast-vsura.             " Send Time
*- If medium is mail
    IF nast-nacha EQ 5 AND im_preview IS INITIAL.
      ex_outputparams-getpdf   = abap_true.               " Get PDF
      ex_outputparams-device   = lc_mail.                 " Mail
    ENDIF.
*- lo_document Parameters
    ex_docparams-langu       = nast-spras.                " Language
    ex_docparams-country     = nast-tland.                " Countery Code

  ENDMETHOD.

  METHOD update_nast_protocol.
    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
      EXPORTING
        msg_arbgb = im_msgid                              " Message  ID
        msg_nr    = im_msgno                              " Message Number
        msg_ty    = im_msgty                              " Messasge  Type
        msg_v1    = sy-msgv1                              " Variable 1
        msg_v2    = sy-msgv2                              " Varibale 2
        msg_v3    = sy-msgv3                              " Varibale 3
        msg_v4    = sy-msgv4                              " Variable 4
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1.
    ENDIF.
  ENDMETHOD.

  METHOD map_data.

    DATA ls_item TYPE zmm_s_inf_binning_item.
    data lt_LINE type TABLE of TLINE.
    data lv_name type TDOBNAME.


    REFRESH et_items.

    SELECT SINGLE
           vbeln,
           erdat,
           erzet,
           lfart,
           lprio,
           vsbed,
           bolnr,
           xabln
      FROM likp
      INTO @DATA(ls_likp)
     WHERE vbeln = @nast-objky(10).
    IF sy-subrc NE 0.
**Manage Error
      CLEAR es_header.
      RETURN.
    ENDIF.


*    IF lt_likp IS NOT INITIAL.
    SELECT lips~vbeln AS vbeln,
           lips~posnr AS posnr,
           lips~werks AS werks,
           lips~lgort AS lgort,
           lips~charg AS charg,
           lips~lfimg AS lfimg,
           lips~meins AS meins,
           lips~lfbnr AS lfbnr,
           lips~kdauf AS kdauf,
           lips~lgpbe AS lgpbe,
           lips~matnr AS matnr,
           lips~arktx AS arktx,
           lips~vgbel AS vgbel,
           lips~vgpos AS vgpos,
           lips~lichn as lichn,
*           makt~MATNR,
           makt~maktx AS maktx,
           makt_a~maktx AS maktx_a,
           makt_a~spras as spras,
           mard~labst AS labst
*           ekpo~netpr as netpr, " Unit FOB
*           ekpo~netwr as netwr,  " Total FOB
*           ekpo~ebelp as ebelp "ebelp
*           ekpo~reslo AS reslo
*           mard~lgpbe AS lgpbe
       FROM lips AS lips
         INNER JOIN makt AS makt
                 ON lips~matnr = makt~matnr
                AND makt~spras = @nast-spras
    LEFT OUTER JOIN makt AS makt_a
                 ON lips~matnr = makt_a~matnr
*               AND makt_a~spras = 'A'
     LEFT OUTER JOIN mard AS mard
                 ON lips~matnr = mard~matnr
                AND lips~werks = mard~werks
                AND lips~lgort = mard~lgort
    INTO TABLE @DATA(lt_lips)

*      FOR ALL ENTRIES IN @LT_LIKP
      WHERE lips~vbeln EQ @ls_likp-vbeln
      ORDER BY vbeln,
               posnr.

SELECT   ekpo~ebeln as ebeln,
          ekpo~netpr as netpr, " Unit FOB
           ekpo~netwr as netwr,  " Total FOB
           ekpo~ebelp as ebelp "ebelp
  from ekpo as ekpo FOR ALL ENTRIES IN @lt_lips
  where ebeln = @lt_lips-vgbel
    and ebelp = @lt_lips-posnr+1(5)
  into table @data(lt_ekpo).
*          AND lips~lgpbe NE ' '.

loop at lt_lips into data(lww_lips).
  if lww_lips-spras = 'A'.
    delete  lt_lips where vbeln = lww_lips-vbeln AND posnr = lww_lips-posnr and matnr = lww_lips-matnr and spras = 'E'.
  endif.
endloop.

    "Start of code by M.sameer
*    SELECT vepo~venum FROM vepo left OUTER JOIN lips ON vepo~vbeln = lips~vbeln
*      WHERE vbeln = @lt_lips-vbeln AND posnr = @lt_lips-posnr INTO TABLE @DATA(lt_vepo).
    IF lt_lips IS NOT INITIAL.
      SELECT venum,vepos,vbeln,posnr FROM vepo FOR ALL ENTRIES IN @lt_lips
         WHERE vbeln = @lt_lips-vbeln AND posnr = @lt_lips-posnr
        INTO TABLE @DATA(lt_vepo).
    ENDIF.
    IF lt_vepo IS NOT INITIAL.
      "To get box id
      SELECT venum,exidv,vbeln_gen,posnr_gen FROM vekp FOR ALL ENTRIES IN @lt_vepo
         WHERE venum = @lt_vepo-venum INTO TABLE @DATA(lt_vekp).
    ENDIF.
    "End of code by M.sameer




    es_header-vbeln = ls_likp-vbeln.

    es_header-erdat = ls_likp-erdat.
    es_header-erzet = ls_likp-erzet.
    IF ls_likp-bolnr IS NOT INITIAL.
      es_header-invoiceno =   ls_likp-bolnr. " && '/' && ls_likp-xabln.

      IF ls_likp-xabln IS NOT INITIAL.
        es_header-invoiceno =   es_header-invoiceno && '/' && ls_likp-xabln.
      ENDIF.
      CONDENSE es_header-invoiceno.
    ENDIF.

*    es_header-vsbed = ls_likp-vsbed.
*    es_header-lprio = ls_likp-lprio.



    LOOP AT lt_lips ASSIGNING FIELD-SYMBOL(<fs_lips>).
      "START of code by M.sameer
      IF sy-subrc = 0.
        DATA(ls_vepo) = VALUE #( lt_vepo[ vbeln = <fs_lips>-vbeln posnr = <fs_lips>-posnr  ] OPTIONAL ).
      ENDIF.
      IF sy-subrc = 0.
        DATA(ls_vekp) = VALUE #(  lt_vekp[ venum = ls_vepo-venum ] OPTIONAL ).
      ENDIF.

       LOOP AT lt_ekpo into data(ls_ekpo) where ebeln = <fs_lips>-vgbel
                                            and ebelp = <fs_lips>-posnr+1(5).
      ls_item-unit_fob = ls_ekpo-netpr. " Unit FOB
      ls_item-total_fob = ls_ekpo-netwr. " Toatl FOB
      lv_name = |{ <fs_lips>-vgbel }{ ls_ekpo-ebelp }|.
       CALL FUNCTION 'READ_TEXT'
        EXPORTING
         CLIENT                        = SY-MANDT
          id                            = 'F01'
          language                      = 'E'
          NAME                          = lv_name
          OBJECT                        = 'EKPO'

        TABLES
          lines                         = lt_LINE
         EXCEPTIONS
           ID                            = 1
           LANGUAGE                      = 2
           NAME                          = 3
           NOT_FOUND                     = 4
           OBJECT                        = 5
           REFERENCE_CHECK               = 6
           WRONG_ACCESS_TO_ARCHIVE       = 7
           OTHERS                        = 8
                  .
        IF sy-subrc = 0.
* Implement suitable error handling here\
          READ TABLE lt_LINE into data(lv_line) INDEX 1.
          ls_item-remarks = lv_line-tdline+0(40).
        ENDIF.
      ENDLOOP.

*      ls_item-box_no = ls_vekp-exidv.
  ls_item-box_no = <fs_lips>-lichn.
      "End of code by M.sameer
      ls_item-posnr = <fs_lips>-posnr.
*      ls_item-werks = <fs_lips>-werks.
      ls_item-lgort = <fs_lips>-lgort.
      ls_item-lgpbe = <fs_lips>-lgpbe.
      ls_item-lfimg = <fs_lips>-lfimg.
      ls_item-meins = <fs_lips>-meins.
      ls_item-matnr = <fs_lips>-matnr.

*      gs_intf-header-kdauf = ls_lips-kdauf.

      APPEND <fs_lips>-maktx TO ls_item-tt_maktx.

      IF <fs_lips>-maktx_a IS NOT INITIAL and <FS_LIPS>-SPRAS = 'A'.
        APPEND <fs_lips>-maktx_a TO ls_item-tt_maktx.
      ENDIF.


      ls_item-labst = <fs_lips>-labst.
      ls_item-charg = <fs_lips>-charg.

*      Get superssion material
      SELECT SINGLE
             pickey
        FROM picps
        INTO @DATA(lv_pickey)
       WHERE matnr = @<fs_lips>-matnr.
      IF sy-subrc EQ 0.

*****        SELECT matnr
*****          FROM picps
*****          INTO TABLE @DATA(lt_submatnr)
*****         WHERE pickey = @lv_pickey
*****           AND matnr NE @<fs_lips>-matnr.
*****        IF sy-subrc EQ 0.
*****
*****          APPEND LINES OF lt_submatnr TO ls_item-supmaterials.
*****        ELSE.
*****          APPEND space TO ls_item-supmaterials.
*****        ENDIF.
        SELECT  matnr UP TO 1 ROWS
          FROM picps
          INTO TABLE  @DATA(lt_submatnr)
         WHERE pickey = @lv_pickey
           AND matnr NE @<fs_lips>-matnr.
        IF sy-subrc EQ 0.

          APPEND LINES OF lt_submatnr TO ls_item-supmaterials.
        ELSE.
          APPEND space TO ls_item-supmaterials.
        ENDIF.
        REFRESH: lt_submatnr.

      ELSE.
        APPEND space  TO ls_item-supmaterials.
      ENDIF.


      APPEND ls_item TO et_items.

      REFRESH: lt_submatnr.
      CLEAR: ls_item.

    ENDLOOP.
    IF lt_lips IS NOT INITIAL.

*Reference Order Number and Receiving Plant
      es_header-vgbel = lt_lips[ 1 ]-vgbel.
      DATA(lv_item) = lt_lips[ 1 ]-vgpos.
      SELECT SINGLE
             werks
        FROM ekpo
        INTO es_header-werks
       WHERE ebeln EQ es_header-vgbel
         AND ebelp EQ lv_item.

*Supplying Plant
      SELECT SINGLE
             reswk
        FROM ekko
        INTO es_header-reswk
       WHERE ebeln EQ es_header-vgbel
               AND ( bsart = 'YSTO' OR bsart = 'YSTB' ).


    ENDIF.

***Header Texts
****Header Custom Name
    DATA(lv_patner) = 'BP' && es_header-werks .
    IF es_header-werks IS NOT INITIAL.
      SELECT SINGLE
             name_org1
        FROM but000
        INTO es_header-cust_name
       WHERE partner EQ lv_patner.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*& Include          ZVSS_ORDER_DETAIL_NEW_TOP
*&---------------------------------------------------------------------*

TABLES : /dbe/vbak_db,
         /dbe/splhdr_db,
         /dbe/vbap,
         ekko,
         ekpo,
         eban.

TYPES : BEGIN OF ty_vbak_com.
          INCLUDE STRUCTURE /dbe/vbak_com.
TYPES:    matnr     TYPE matnr18,
          banfn     TYPE banfn,
          posnr     TYPE posnr,
          jobs      TYPE /dbe/vbap-jobs,
          bnfpo     TYPE bnfpo,
          pr_quan   TYPE string,
          ord_quan  TYPE string,
          po_quan   TYPE string,
          po_status TYPE string,
          exdate    TYPE string,
          ebelp     TYPE string,
          lifnr     TYPE lifnr,
          inb_no    TYPE vbeln,
          inb_item  TYPE posnr,
          inb_dat   TYPE erdat,
          outb_no   TYPE vbeln,
          outb_item TYPE posnr,
          outb_dat  TYPE erdat,
          po_date   TYPE aedat,
          dif_dt    TYPE string,
          po_text   TYPE string,
          ek_bsart  TYPE esart,   "by ismail
          eb_bsart  TYPE esart,   "by ismail
          del_stat  TYPE string,   "added by ismail
        END OF ty_vbak_com,

        tt_vbak_com TYPE TABLE OF ty_vbak_com,


        BEGIN OF ty_po,
          ebeln   TYPE ebeln,
          ebelp   TYPE numc06,
          matnr   TYPE matnr18,
*         po_quan TYPE bstmg,
          menge   TYPE bstmg,
          werks   TYPE werks_d,
          kunnr   TYPE kunnr,
          mfrnr   TYPE mfrnr,
          banfn   TYPE banfn,
          bnfpo   TYPE bnfpo,
          pr_quan TYPE bstmg,
          bsart   TYPE esart,   "by ismail
          ebelp1  TYPE ebelp,    "by ismail
        END OF ty_po,

        BEGIN OF ty_ekko,
          ebeln TYPE ebeln,
          lifnr TYPE lifnr,
          frgke TYPE ekko-frgke,
          aedat TYPE aedat,
          bsart TYPE esart,   "by ismail
        END OF ty_ekko,

        BEGIN OF ty_eket,
          ebeln TYPE ebeln,
          ebelp TYPE numc05,
          eindt TYPE eindt,
        END OF ty_eket,


        BEGIN OF ty_lips,
          ebeln TYPE ebeln,
          ebelp TYPE numc06,
          vbeln TYPE vbeln,
          posnr TYPE posnr,
          erdat TYPE erdat,
          vbtyv TYPE vbtyp,
        END OF ty_lips,
        BEGIN OF ty_likp_h,
          vbeln TYPE vbeln,
          vbtyp TYPE vbtyp,
        END OF ty_likp_h,

*    i~vbeln
*    i~posnr
*    i~matnr
*    i~erdat
*    i~vgbel
*    i~vgpos
*     i~/dbe/vbeln
*    i~/dbe/posnr
*    h~vbtyp
        BEGIN OF ty_lips1,
          vbeln      TYPE vbeln,
          posnr      TYPE posnr,
          matnr      TYPE matnr,
          erdat      TYPE erdat,
          ebeln      TYPE ebeln,
          ebelp      TYPE numc06,
          /dbe/vbeln TYPE /dbe/vbeln_va,
          /dbe/posnr TYPE /dbe/posnr,
          vbtyv      TYPE vbtyp,
        END OF ty_lips1,

        BEGIN OF ty_vbup,
          vbeln TYPE vbeln,
          posnr TYPE posnr,
          wbsta TYPE wbsta,
        END OF ty_vbup,

        BEGIN OF ty_ban,
          banfn TYPE banfn,
          bnfpo TYPE bnfpo,
          bsart TYPE esart,   "by ismail
          menge TYPE bstmg,
          ebeln TYPE ebeln,
          ebelp TYPE ebelp,

        END OF ty_ban,

        BEGIN OF ty_vbap,
          vbeln TYPE vbeln,
          matnr TYPE matnr,
          posnr TYPE posnr,
          zmeng TYPE /dbe/amount,
          jobs  TYPE /dbe/vbap-jobs,    "added by Shahid 8100004362
        END OF ty_vbap,
        ty_ebeln TYPE RANGE OF ebeln.

TYPES : BEGIN OF ty_vbeln_pr,
          vbeln TYPE vbeln,
          pr    TYPE banfn,
          posnr TYPE posnr,
        END OF ty_vbeln_pr.

DATA : it_order     TYPE tt_vbak_com,
       it_orderlist TYPE  /dbe/orderlist_icon_t,
       lt_contents  TYPE STANDARD TABLE OF solisti1,
       lw_contents  TYPE solisti1,
       it_po        TYPE TABLE OF ty_po,
       it_po_t      TYPE TABLE OF ty_po,
       it_po_t2     TYPE TABLE OF ty_po,
       it_ban       TYPE TABLE OF ty_ban,
       it_ban_t     TYPE TABLE OF ty_ban,
       it_vbap      TYPE TABLE OF ty_vbap,
       it_ekko      TYPE TABLE OF ty_ekko,
       it_ekko_t    TYPE TABLE OF ty_ekko,
       it_eket      TYPE TABLE OF ty_eket,
       it_ebeln     TYPE TABLE OF ty_ebeln,
       it_lips      TYPE TABLE OF ty_lips,
       it_vbup      TYPE TABLE OF ty_vbup,
       it_lips1     TYPE TABLE OF ty_lips1,  "Added by ismail
       it_lips2     TYPE TABLE OF ty_lips1,  "Added by ismail
       it_lips1_t   TYPE TABLE OF ty_lips1,  "Added by ismail
       it_likp_h    TYPE TABLE OF ty_likp_h,  "Added by ismail
       it_vbup1     TYPE TABLE OF ty_vbup,  "Added by ismail
       it_po_list   TYPE fip_t_ebeln_range,
       it_pr_list   TYPE wtysc_banfn_ranges_tab.

DATA :ra_kunnr TYPE fiappt_t_kunnr,
      ts_kunnr TYPE fiappt_s_kunnr,
      ts_ebeln TYPE fip_s_ebeln_range,
      ra_ebeln TYPE fip_t_ebeln_range,
      ra_pr    TYPE  wtysc_banfn_ranges_tab,
      ts_pr    TYPE wtysc_wwb_s_banfn,
      ra_vbeln TYPE wtysc_vbeln_ranges_tab,
      ts_vbeln TYPE wtysc_wwb_s_vbeln,
      ra_matnr TYPE range_t_matnr,
      ts_matnr TYPE range_s_matnr,
      ra_werks TYPE range_t_werks_d,
      ts_werks TYPE range_s_werks_d,
      ra_vkorg TYPE range_t_vkorg,
      ts_vkorg TYPE range_s_vkorg,
      ra_mfrnr TYPE zrange_t_mfrnr,
      ts_mfrnr TYPE zrange_s_mfrnr,
      ra_pernr TYPE zrange_t_pernr,
      ts_pernr TYPE zrange_s_pernr,
      ra_ddate TYPE date_t_range,  "by ismail
      ts_ddate TYPE date_range.    "by ismailZZZZZZ


TYPES: BEGIN OF ty_vbeln_order,
         dbe_ordr TYPE /dbe/ord_docflow-instid_a, "vbeln_src
         pr       TYPE /dbe/ord_docflow-instid_b, "vbeln_tgt
       END OF ty_vbeln_order.
TYPES: BEGIN OF ty_ebant,
         banfn TYPE banfn,
         bnfpo TYPE bnfpo,
         vbeln TYPE vbeln,
         posnr TYPE posnr,
       END OF ty_ebant,
       BEGIN OF ty_email,
         pernr     TYPE pernr,
         werks     TYPE werks,
         email_dl  TYPE soobjinfi1-obj_name,
         email_adr TYPE so_address,
       END OF ty_email,
       BEGIN OF ty_pono,
         vbeln      TYPE vbeln,
         jobs       TYPE /dbe/vbap-jobs,
         po_stat    TYPE string,
         del_status TYPE string,
       END OF ty_pono,
       BEGIN OF lty_keyval,
         key   TYPE string,
         value TYPE string,
       END OF lty_keyval.

DATA:
  lt_pono   TYPE STANDARD TABLE OF ty_pono,
  lt_pono2  TYPE STANDARD TABLE OF ty_pono,
  lt_pono3  TYPE STANDARD TABLE OF ty_pono,
  ts_pono   TYPE ty_pono,
  lt_email  TYPE STANDARD TABLE OF ty_email,
  lt_email2 TYPE STANDARD TABLE OF ty_email,
  ts_email  TYPE ty_email,
  lt_ebant  TYPE STANDARD TABLE OF ty_ebant,
  lt_ebantp TYPE STANDARD TABLE OF ty_ebant,
  lt_ebant2 TYPE STANDARD TABLE OF ty_ebant,
  lw_ebant  TYPE ty_ebant.
RANGES ra_banfn FOR eban-banfn.
DATA: it_ord1  TYPE  TABLE OF ty_vbeln_order.
DATA: it_ord_lips  TYPE  TABLE OF ty_vbeln_order.
DATA : ts_orderlist TYPE /dbe/orderlist_icon,
       ts_order     TYPE ty_vbak_com,
       ts_vbap      TYPE ty_vbap,
       ts_po        TYPE ty_po,
*         ts_ebeln     LIKE LINE OF it_ebeln,
       lv_ebeln     TYPE ebeln,
       lv_flag      TYPE n VALUE 0,
       lv_preq_num  TYPE bapieban-preq_no,
       it_doc_flow  TYPE /dbe/docflow_documents_tt,
       ts_doc_flow  TYPE /dbe/docflow_documents,
       it_pr        TYPE TABLE OF bapieban,
       it_pr_buffer TYPE TABLE OF bapieban,
*         ts_pr        TYPE bapieban,
       ts_ban       TYPE ty_ban,
       it_vbeln_pr  TYPE TABLE OF ty_vbeln_pr,
       ts_vbeln_pr  TYPE ty_vbeln_pr,
       ts_ekko      TYPE ty_ekko,
       ts_eket      TYPE ty_eket,
       ts_lips      TYPE ty_lips,
       ts_lips1     TYPE ty_lips1,
       ts_vbup      TYPE ty_vbup,
       lv_day       TYPE pea_scrdd,
       tdobject	    TYPE tdobject VALUE 'EKPO',
       tdid         TYPE tdid VALUE 'F01',
       tdnam        TYPE tdobname,
       tdspras      TYPE tdspras VALUE 'E',
       tdlines      TYPE TABLE OF tline,
       ts_lines     TYPE tline,
       lv_sv_adv_rm TYPE char2 VALUE '  '.  " SA for service advisor RM for regional manager  "Shahid added 8100004362

RANGES ra_ord FOR /dbe/ord_docflow-instid_a.
PERFORM f_prepare_range_tbl.
" Read the dbe Orders based on the Criteria
DATA: ls_vbak_com TYPE /dbe/vbak_com.
DATA: lv_rows TYPE i.
DATA: it_vbak_com      TYPE /dbe/vbak_com_tt,
      ts_order_no      TYPE  wtysc_wwb_s_vbeln,
      it_order_no_temp TYPE  wtysc_vbeln_ranges_tab.

DATA : lt_vbak_com TYPE /dbe/vbak_com_tt,
       lw_vbak_com LIKE LINE OF lt_vbak_com.
DATA lv_curs      TYPE cursor.
*  DATA ls_kunnr     LIKE LINE OF KUNNR.
DATA lv_trex_search TYPE abap_bool.

DATA: lt_prtab TYPE  wtysc_banfn_ranges_tab,
      lw_prtab LIKE LINE OF lt_prtab.
DATA:
*         ts_po  TYPE ty_po,
      ts_po1 TYPE ty_po.
*        ts_ban TYPE ty_ban.
*  DATA: it_po_t2      TYPE TABLE OF ty_po.
FIELD-SYMBOLS : <fs_po> LIKE LINE OF it_po_t.

DATA: lt_t16fb        TYPE STANDARD TABLE OF t16fb,
      lw_t16fb        TYPE t16fb,
      "extra request data
      lint_extra_data TYPE TABLE OF lty_keyval,
      fs_extra_data   LIKE LINE OF lint_extra_data,
      dli_entries     TYPE TABLE OF sodlienti1,
      dli_entries2    TYPE TABLE OF sodlienti1,
      dls_entries     TYPE sodlienti1,
      dls_entries2    TYPE sodlienti1,
      lv_id           LIKE  thead-tdid,
      lv_name         LIKE  thead-tdname,
      lv_object       LIKE  thead-tdobject,
      lv_lang         LIKE  thead-tdspras,
      tt_lines        TYPE TABLE OF tline,
      lt_lines        TYPE TABLE OF tline,
      lc_new_line     TYPE char255 VALUE '<br>',
      lv_mail_subj    TYPE string,
      ls_lines        TYPE tline.

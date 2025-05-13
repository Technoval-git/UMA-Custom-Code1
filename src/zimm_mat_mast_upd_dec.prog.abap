*&---------------------------------------------------------------------*
*& Include          ZIMM_MAT_MAST_UPD_DEC
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_main,
          matnr      TYPE     mfrpn,
          mbrsh      TYPE     mbrsh,
          mtart      TYPE     mtart,
          werks      TYPE     werks_d,
          lgort      TYPE     lgort_d,
          vkorg      TYPE     vkorg,
          vtweg      TYPE     vtweg,
          lgnum      TYPE     lgnum,
          lgtyp      TYPE     mlgn_plkpt,
          maktx      TYPE     maktx,
          maktx_a    TYPE     maktx,
          bismt      TYPE     bismt,
          xchpf      TYPE     xchpf,
          extwg      TYPE     extwg,   " added
          wrkst      TYPE     wrkst,
          brgew      TYPE     brgew,
          gewei      TYPE     gewei,
          groes      TYPE     groes,
          matkl      TYPE     matkl,
          meins      TYPE     meins,
          spart      TYPE     spart,
          mtpos      TYPE     mtpos,
          ntgew      TYPE     ntgew,
          taxm1      TYPE     taxkm,
          aumng      TYPE     aumng,
          kondm      TYPE     kondm,
          ktgrm      TYPE     ktgrm,
          mtpos_d    TYPE     mtpos,
          mtvfp      TYPE     mtvfp,
          tragr      TYPE     tragr,
          ladgr      TYPE     ladgr,
          prctr      TYPE     prctr,
          mfrpn      TYPE     mfrpn,
          mfrnr      TYPE     mfrnr,
          ekgrp      TYPE     ekgrp,
          disgr      TYPE     dispr,
          maabc      TYPE     maabc,
          dismm      TYPE     dismm,
          minbe      TYPE     minbe,
          disls      TYPE     disls,
          dispo      TYPE     dispo,
          beskz      TYPE     beskz,
          plifz      TYPE     plifz,
          webaz      TYPE     webaz,
          eisbe      TYPE     eisbe,
          eislo      TYPE     eislo,
          wzeit      TYPE     wzeit,
          prmod      TYPE     prmod,
          perkz      TYPE     perkz,
          peran      TYPE     peran,
          anzpr      TYPE     anzpr,
          kzini      TYPE     kzini,
          lgpbe      TYPE     lgpbe,
          bklas      TYPE     bklas,
          bwtty      TYPE     bwtty_d,
          peinh      TYPE     peinh,
          stprs      TYPE     stprs,
          verpr      TYPE     verpr,
          vprsv      TYPE     vprsv,
          fhori      TYPE    fhori,
          gewgr      TYPE    gewgr,
          matl_grp_4 TYPE mvke-mvgr4,
          matl_grp_3 TYPE mvke-mvgr3,
        END OF ty_main.

TYPES: BEGIN OF ty_mat_data,
         matnr TYPE  matnr,
         mfrpn TYPE mfrpn,
         mfrnr TYPE mfrnr,
         mhdhb TYPE mhdhb,
       END OF ty_mat_data.

TYPES: BEGIN OF ty_mat_wrkst,
         matnr TYPE  matnr,
         wrkst TYPE wrkst,
       END OF ty_mat_wrkst.

TYPES: tt_mat_data TYPE TABLE OF ty_mat_data.

DATA : lt_main              TYPE STANDARD TABLE OF ty_main,
       lwa_main             TYPE ty_main,
       lt_zmm_mat_constant  TYPE STANDARD TABLE OF zmm_mat_constant,
       lwa_zmm_mat_constant TYPE zmm_mat_constant.

TYPES : BEGIN OF ty_autho,
        category type ZMM_CAT,
        uname type uname,
        werks type werks,
       END OF ty_autho.

DATA : lt_autho type STANDARD TABLE OF ty_autho,
       lw_autho type ty_autho.
DATA: lwa_header    TYPE bapimathead,
      lwa_makt      TYPE bapi_makt, "Short Text
      lwa_longtxt   TYPE bapi_mltx, " Long Text
      lwa_client    TYPE bapi_mara,
      lwa_clientx   TYPE bapi_marax,
      lwa_unit      TYPE bapi_marm,
      lwa_unitx     TYPE bapi_marmx,
      lwa_plant     TYPE bapi_marc,
      lwa_plantx    TYPE bapi_marcx,
      lwa_sale      TYPE bapi_mvke,
      lwa_salex     TYPE bapi_mvkex,
      lwa_tax       TYPE bapi_mlan,
      lwa_acc       TYPE bapi_mbew,
      lwa_accx      TYPE bapi_mbewx,
      lwa_store     TYPE bapi_mard,
      lwa_storex    TYPE bapi_mardx,
      lwa_forecast  TYPE bapi_mpop,
      lwa_forecastx TYPE bapi_mpopx,
      lwa_ware      TYPE bapi_mlgn,
      lwa_warex     TYPE bapi_mlgnx,
      lwa_return    TYPE bapiret2,
      it_makt       TYPE TABLE OF bapi_makt,
      it_tax        TYPE TABLE OF bapi_mlan.
data :lw_plant   type BAPIE1MARC,
      lw_plantx  type BAPIE1MARCX,
      lt_plant   type STANDARD TABLE OF BAPIE1MARC,
       lt_plantx  type STANDARD TABLE OF BAPIE1MARCX,
      lt_header type STANDARD TABLE OF BAPIE1MATHEADER ,
      lw_header type  BAPIE1MATHEADER .


data lw_BAPIRET2 type BAPIRET2.

CONSTANTS : ca_check TYPE c       VALUE '0',
            ca_ftype TYPE char10  VALUE 'ASC',
            ca_mtart TYPE mtart   VALUE 'YPOM'.

TYPES: BEGIN OF ty_file_data,
         file_record(1000) TYPE c,
       END OF ty_file_data.

DATA : i_file_data  TYPE STANDARD TABLE OF  ty_file_data,
       wa_file_data TYPE ty_file_data.

data lv_htype like DD01V-DATATYPE.
*----------------------



TYPES: BEGIN OF ty_data,
         matnr(40) TYPE c,
         mtart(4)  TYPE c,
         werks(4)  TYPE c,
         lgort(4)  TYPE c,
         lgnum(3)  TYPE c,
         maktx(40) TYPE c,
         maktx_a(40) TYPE c,
         meins(3)  TYPE c,
         matkl(8)  TYPE c,
         brgew(13) TYPE c,
         ntgew(13) TYPE c,
         gewei(11) TYPE c,
         groes(32) TYPE c,
         spart(2)  TYPE c,
         aumng(13) TYPE c,
         bismt(18) TYPE c,
         xchpf(1)  TYPE c,
         extwg(18) TYPE c,
         mfrpn(40) TYPE c,
         maabc(1)  TYPE c,
         eisbe(13) TYPE c,
         eislo(13) TYPE c,
         plifz(3)  TYPE c,
         webaz(3)  TYPE c,
         bklas(4)  TYPE c,
         peinh(5)  TYPE c,
         verpr(11) TYPE c,
         lgpbe(10) TYPE c,
         vprsv(1)  TYPE c,
         vkorg(4)  TYPE c,
         vtweg(2)  TYPE c,
         taxm1(1)  TYPE c,
         mbrsh(1)  TYPE c,
         kondm(2)  TYPE c,
         ktgrm(2)  TYPE c,
         mtpos(4)  TYPE c,
         mtpos_d(4)  TYPE c,
         mtvfp(2)  TYPE c,
         tragr(4)  TYPE c,
         ladgr(4)  TYPE c,
         prctr(10) TYPE c,
         mfrnr(10) TYPE c,
         ekgrp(3)  TYPE c,
         disgr(4)  TYPE c,
         dismm(2)  TYPE c,
         minbe(13) TYPE c,
         disls(2)  TYPE c,
         dispo(3)  TYPE c,
         beskz(1)  TYPE c,
         wzeit(3)  TYPE c,
         prmod(1)  TYPE c,
         perkz(1)  TYPE c,
         peran(1)  TYPE c,
         anzpr(1)  TYPE c,
         kzini(1)  TYPE c,
         bwtty(1)  TYPE c,
         stprs(11) TYPE c,
       END OF ty_data.
DATA: lt_con TYPE STANDARD TABLE OF ty_data,
      wa_con TYPE ty_data.





DATA : wa_file_name  TYPE file_table.

DATA : lv_tab        TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.



TYPES: BEGIN OF ty_log,
         material TYPE matnr,
         plant    TYPE werks_d,
         type     TYPE bapi_mtype,
         message  TYPE bapi_msg,
       END OF ty_log.


DATA : lt_log TYPE STANDARD TABLE OF ty_log,
       ls_log TYPE ty_log.

DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
       wa_layout   TYPE slis_layout_alv,
       ls_print    TYPE slis_print_alv.

DATA va_top           TYPE slis_formname VALUE 'F_ALV_HEADER'.

DATA : lt_material TYPE STANDARD TABLE OF bapimatinr,
       ls_material TYPE bapimatinr.

DATA : lv_matnr TYPE matnr.



DATA: lt_mat_data TYPE tt_mat_data,
      ls_mat_data TYPE ty_mat_data.

DATA: va_total_records TYPE char7,
      va_succ_records  TYPE char7,
      va_fail_records  TYPE char7.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.


  SELECTION-SCREEN : BEGIN OF LINE,
  PUSHBUTTON 1(18) TEXT-p01 USER-COMMAND template,
  END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (15) TEXT-037.
    PARAMETER : p_sall RADIOBUTTON GROUP gr1  USER-COMMAND com_sel ,
                p_rb_1 LIKE abap_true NO-DISPLAY .
    SELECTION-SCREEN COMMENT (10) TEXT-038 .
    PARAMETER : p_usall RADIOBUTTON GROUP gr1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (13) TEXT-039 .
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN ULINE .

  "view selection
  PARAMETERS : p_basic  AS CHECKBOX,
               p_sales  AS CHECKBOX,
               p_mrp    AS CHECKBOX,
               p_purc   AS CHECKBOX,
               p_plant  AS CHECKBOX,
               p_acc    AS CHECKBOX,
               p_forcst AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK b1.


SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-015.

  PARAMETERS: pv_file TYPE localfile.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 4(60) TEXT-014.
  SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK b2.


SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME.
*PARAMETERS: p_na RADIOBUTTON GROUP e1 DEFAULT 'X',
*           p_sa RADIOBUTTON GROUP  e1 ,
*           p_ae RADIOBUTTON GROUP e1.

PARAMETERS : p_fg RADIOBUTTON GROUP g1 DEFAULT 'X',
             p_bg RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b3.







AT SELECTION-SCREEN ON VALUE-REQUEST FOR pv_file.


  DATA: l_window_title      TYPE string,
        l_rc                TYPE sysubrc,
        l_default_file_name TYPE string.

  DATA lt_file_table TYPE filetable.
  CONSTANTS : lc_err TYPE i VALUE -1,
              lc_suc TYPE i VALUE 1.

  l_window_title = 'Excel File'.


* Method to provide value help for input file name
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = l_window_title
      default_filename        = l_default_file_name
      default_extension       = 'XLS'
    CHANGING
      file_table              = lt_file_table
      rc                      = l_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc = 0.
    IF l_rc EQ lc_err.
      MESSAGE ID sy-msgid
            TYPE sy-msgty
          NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSEIF l_rc EQ lc_suc.
      READ TABLE lt_file_table INDEX 1 INTO pv_file.
      IF sy-subrc IS NOT INITIAL.
        CLEAR pv_file.
      ENDIF.
    ENDIF.
  ENDIF.
  FREE lt_file_table.

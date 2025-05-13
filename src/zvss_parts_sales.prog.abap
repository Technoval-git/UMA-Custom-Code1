*&---------------------------------------------------------------------*
*& Report ZVSS_PARST_SALES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_parts_sales.

TABLES: /dbe/vbak_db,/dbe/vbap, /dbe/oe_vbakst, /dbe/oe_vbapst, /dbe/c_ordertp, vbrk,
        /dbe/splhdr_db, mara.
* new table added.
*        vlcvehicle.

TYPES:
  BEGIN OF ty_vbak,
    vbeln           TYPE vbeln,
    audat           TYPE audat,
    vkorg           TYPE vkorg,
    vtweg           TYPE vtweg,
    spart           TYPE spart,
    bukrs_vf        TYPE bukrs_vf,
    werks           TYPE /dbe/vbak_db-werks,
    pl_comp_dat     TYPE /dbe/vbak_db-fert_date_tmstp,
    pernr           TYPE /dbe/servcons,
    engine          TYPE /dbe/c_order_engine,
    vguid           TYPE vlcvehicle-vguid,
    licpl           TYPE /dbe/vbak_db-licpl,
    hstat           TYPE /dbe/vbak_db-hstat,
    visit_start_tst TYPE /dbe/vbak_db-visit_start_tst,
    visit_end_tst   TYPE /dbe/vbak_db-visit_end_tst,
    ange_user       TYPE /dbe/vbak_db-ange_user,
  END OF ty_vbak,

  BEGIN OF ty_billing,
    vbeln      TYPE vbeln_vf,
    posnr      TYPE posnr_vf,
    dbm_vbeln  TYPE /dbe/vbeln_va,
    dbm_item   TYPE posnr,
*    fkdat     TYPE fkdat,
    werks      TYPE werks_d,
    wavwr      TYPE wavwr,
    augru_auft TYPE augru,
    ktgrm      TYPE ktgrm,
  END OF ty_billing,

  BEGIN OF ty_pernr,
    pernr TYPE /dbe/servcons,
    nachn TYPE nachn,
    name2 TYPE name2,
  END OF ty_pernr,

  BEGIN OF ty_cust_group ,
    kunnr TYPE kunnr,
    vkorg TYPE vkorg,
    vtweg TYPE vtweg,
    spart TYPE spart,
    kdgrp TYPE kdgrp,
  END OF ty_cust_group,

  BEGIN OF ty_vbap,
    vbeln        TYPE vbeln,
    posnr        TYPE /dbe/posnr,
    kunnr        TYPE kunnr,
    aufart       TYPE aufart,
    itcat        TYPE /dbe/vbap-itcat,
    matnr40      TYPE matnr40,
    matnr18      TYPE matnr18,
    descr1       TYPE /dbe/s_descr_1,
    itcanc       TYPE /dbe/vbap-itcanc,
    target_time  TYPE /dbe/vbap-target_time,
    zmeng        TYPE /dbe/vbap-zmeng,
    netwr        TYPE /dbe/vbap-netwr,
    itobjid      TYPE /dbe/vbap-itobjid,
    abgru        TYPE /dbe/vbap-abgru,
    mvgr1        TYPE mvgr1,
    mvgr2        TYPE mvgr2,
    mvgr3        TYPE mvgr3,
    mvgr4        TYPE mvgr4,
    mvgr5        TYPE mvgr5,
*    zallowed_disc TYPE /dbe/rebate,
    manual_price TYPE netpr,
    kzwi5        TYPE /dbe/vbap-kzwi5, "field for profit margin
    status       TYPE char40,
    deliv_qty    TYPE lfimg,
    open_qty     TYPE lfimg,


  END OF ty_vbap,

  BEGIN OF ty_ange_user,
    bname     TYPE xubname,
    name_text TYPE name_text,
  END OF ty_ange_user,

  BEGIN OF ty_otype,
    aufart   TYPE /dbe/c_ordertp-aufart,
    auart_sd TYPE /dbe/c_ordertp-auart_sd,
    auart_co TYPE /dbe/c_ordertp-auart_co,
    vbtyp    TYPE vbtyp,
  END OF ty_otype,

  BEGIN OF ty_aufart,
    aufart TYPE aufart,
    bezei  TYPE bezei,
  END OF ty_aufart,

  BEGIN OF ty_vbrkt,
    vbeln TYPE vbrk-vbeln,
    vbtyp TYPE vbrk-vbtyp,
    vtweg TYPE vbrk-vtweg,
    spart TYPE vbrk-spart,
    zuonr TYPE vbrk-zuonr,
    fkdat TYPE vbrk-fkdat,
    fksto TYPE vbrk-fksto,
  END OF ty_vbrkt,

  BEGIN OF ty_plant,
    werks TYPE werks_d,
    name1 TYPE name1,
  END OF ty_plant,

  BEGIN  OF ty_alv,
    flag             TYPE char1,
    vbeln            TYPE string,
    posnr            TYPE string,
    werks            TYPE string,
    vkorg            TYPE string,
    vtweg            TYPE string,
    spart            TYPE string,
    hstat            TYPE string,
    status           TYPE string,
*   pl_comp_dat      TYPE string,
*   licpl            TYPE string,
    accept_date      TYPE string,
    it_cat           TYPE string,
    matnr40          TYPE string,
    descr1           TYPE string,
    matnr18          TYPE string,
    quantity         TYPE /dbe/amount,
*   vhvin            TYPE string,
    fkdat            TYPE string,
    fkmon            TYPE string,
    ernam            TYPE string,
*   vhcle            TYPE string,
*   modyear          TYPE string,
*   model_code       TYPE string,
*   model_text       TYPE string,
    invoice_no       TYPE string,
    invoice_cleared  TYPE string,
*   job_no           TYPE int8,
*   delivered_time   TYPE catshours,
*   promised_time    TYPE /dbe/vbap-target_time,
*   received_date    TYPE string,
*   promised_date    TYPE string,
*   no_of_lines      TYPE string,
    spare_qty        TYPE string,
    spare_amount     TYPE netwr,
    prom_dt_change   TYPE string,
    no_of_days       TYPE int8,
    range            TYPE string,
    customer_name    TYPE string,
    customer_group   TYPE vtxtk,
    voucher_number   TYPE string,
    voucher_date     TYPE string,
    voucher_value    TYPE int8,
    repair_type      TYPE string,
    payment_received TYPE netwr,
    service_advisor  TYPE string,
    workshop         TYPE string,
    month            TYPE string,
    del_itm          TYPE string, " deleted item|07.10.2019
    rej_itm          TYPE string, " rejected item | 07.10.2019
    rej_itmt         TYPE string, " rejected item text 07.10.2019
*   dwell_time       TYPE int8,
*   splnr            TYPE /dbe/splnr,
    netwr            TYPE netwr_ak,
    unit_price       TYPE kwert,
    head_disc        TYPE kwert,
    head_disc_perc   TYPE kbetr,
    item_disc        TYPE kwert,
    item_disc_perc   TYPE kbetr,
    cg_discount      TYPE kwert,
    head_surch       TYPE kwert,
    item_surch       TYPE kwert,
    vat              TYPE kwert,
    gross_value      TYPE kwert,
    cost             TYPE kwert,
    profit_margin    TYPE kwert,
    status_icon      TYPE /dbe/oe_hstat_icon,
    zterm            TYPE dzterm,
    zterm_txt        TYPE dzterm_bez,
    deliv_qty        TYPE lfimg,
    open_qty         TYPE lfimg,
    ange_user        TYPE /dbe/vbak_db-ange_user,
    ange_name        TYPE name_text,
    bill_ord_reas    TYPE augru,
    bill_ord_reas_t  TYPE bezei40,
    ktgrm            TYPE ktgrm,
    ktgrm_t          TYPE bezei20,
    mvgr1            TYPE mvgr1,
    mvgr2            TYPE mvgr2,
    mvgr3            TYPE mvgr3,
    mvgr4            TYPE mvgr4,
    mvgr5            TYPE mvgr5,
    aufart           TYPE /dbe/splhdr_db-aufart,
    augru            TYPE bezei40,
    reject           TYPE bezei40,
    zallowed_disc    TYPE /dbe/rebate,
    manual_price     TYPE netpr,
    reject_user      TYPE cdusername,
    reject_date      TYPE cddatum,
    disc_user        TYPE cdusername,
    manual_user      TYPE cdusername,
*---vhvin--
    vhvin            TYPE vlc_vhvin,
*---vhvin--
    total_price      TYPE kwert, "manual price * order Quantity.
    sum              TYPE kwert, " Sum = manual price * order Quantity + VAT
  END OF ty_alv,

  BEGIN  OF ty_alv_str,
    flag             TYPE char1,
    vbeln            TYPE string,
    posnr            TYPE string,
    werks            TYPE string,
    vkorg            TYPE string,
    spart            TYPE string,
    hstat            TYPE string,
    status           TYPE char40,
    accept_date      TYPE string,
    it_cat           TYPE string,
    matnr40          TYPE string,
    descr1           TYPE string,
    matnr18          TYPE string,
    quantity         TYPE char15,
    fkdat            TYPE string,
    ernam            TYPE string,
    invoice_no       TYPE string,
    invoice_cleared  TYPE string,
    spare_qty        TYPE string,
    spare_amount     TYPE char16,
    prom_dt_change   TYPE string,
    no_of_days       TYPE char20,
    range            TYPE string,
    customer_name    TYPE string,
    customer_group   TYPE vtxtk,
    voucher_number   TYPE string,
    voucher_date     TYPE string,
    voucher_value    TYPE char20,
    repair_type      TYPE string,
    payment_received TYPE char16,
    service_advisor  TYPE string,
    workshop         TYPE string,
    month            TYPE string,
    del_itm          TYPE string, " deleted item|07.10.2019
    rej_itm          TYPE string, " rejected item | 07.10.2019
    rej_itmt         TYPE string, " rejected item text 07.10.2019
    netwr            TYPE char16,
    unit_price       TYPE char16,
    head_disc        TYPE char16,
    head_disc_perc   TYPE char16,
    item_disc        TYPE char16,
    item_disc_perc   TYPE char16,
    cg_discount      TYPE char16,
    head_surch       TYPE char16,
    item_surch       TYPE char16,
    vat              TYPE char16,
    gross_value      TYPE char16,
    cost             TYPE char16,
    profit_margin    TYPE char16,
    status_icon      TYPE /dbe/oe_hstat_icon,
    zterm            TYPE dzterm,
    zterm_txt        TYPE dzterm_bez,
    deliv_qty        TYPE char16,
    open_qty         TYPE char16,
    ange_user        TYPE string,
    ange_name        TYPE string,
    bill_ord_reas    TYPE string,
    bill_ord_reas_t  TYPE string,
    ktgrm            TYPE string,
    ktgrm_t          TYPE string,
    mvgr1            TYPE string,
    mvgr2            TYPE string,
    mvgr3            TYPE string,
    mvgr4            TYPE string,
    mvgr5            TYPE string,
    aufart           TYPE string,
    augru            TYPE string,
    reject           TYPE string,
    zallowed_disc    TYPE string,
    manual_price     TYPE string,
    reject_user      TYPE string,
    reject_date      TYPE string,
    disc_user        TYPE string,
    manual_user      TYPE string,
  END OF ty_alv_str,

  BEGIN OF ty_vbup,
    vbeln TYPE vbeln,
    posnr TYPE posnr,
    wbsta TYPE wbsta,
  END OF ty_vbup,

  BEGIN OF ty_lips,
    vbeln     TYPE vbeln,
    posnr     TYPE posnr,
    dbm_vbeln TYPE /dbe/vbeln_va,
    dbm_posnr TYPE /dbe/posnr,
    lfimg     TYPE lfimg,
    vbtyp     TYPE vbtyp,
    wbsta     TYPE wbsta,
  END OF ty_lips,

  BEGIN OF ty_likp,
    vbeln TYPE likp-vbeln,
    vbtyp TYPE likp-vbtyp,
  END OF ty_likp,

  BEGIN OF ty_splhdr,
    vbeln  TYPE /dbe/vbeln_va,
    zterm  TYPE dzterm,
    aufart TYPE /dbe/splhdr_db-aufart,
    augru  TYPE /dbe/splhdr_db-augru,
  END OF ty_splhdr.

DATA:
  it_alv          TYPE TABLE OF ty_alv,
  it_vbak         TYPE TABLE OF ty_vbak,
  it_vbap         TYPE TABLE OF ty_vbap,
  it_plant        TYPE TABLE OF ty_plant,
  it_vbup         TYPE TABLE OF ty_vbup,
  it_lips         TYPE TABLE OF ty_lips,
  it_lips_o       TYPE TABLE OF ty_lips,
  it_likp         TYPE TABLE OF ty_likp,
  ls_lips         TYPE ty_lips,
  ls_lips_o       TYPE ty_lips,
  it_billing      TYPE TABLE OF ty_billing,
  it_tvaut        TYPE TABLE OF tvaut,
  it_aag          TYPE TABLE OF tvkmt,
  it_pernr        TYPE TABLE OF ty_pernr,
  it_cg_desc      TYPE TABLE OF t151t,
  it_hstat_icon   TYPE TABLE OF /dbe/oe_hstat,
  it_aufart       TYPE TABLE OF /dbe/c_ordertpt,
  it_cust_group   TYPE TABLE OF ty_cust_group,
  it_so_stat      TYPE TABLE OF /dbe/oe_vbakst,
  it_order_status TYPE TABLE OF /dbe/oe_hstat_t,
  it_item_price   TYPE zcl_mm_sales_rpt_util=>tt_item_price,
  lt_vbap_st      TYPE STANDARD TABLE OF /dbe/oe_vbapst,
  it_vbrkt        TYPE TABLE OF ty_vbrkt,
  it_tvagt        TYPE TABLE OF tvagt,
  wa_rtxt         TYPE tvagt,
  lt_order_type   TYPE TABLE OF ty_otype,
  gv_vkorg        TYPE vbrk-vkorg,
  gv_bukrs        TYPE vbrk-bukrs,
  it_splhdr       TYPE TABLE OF ty_splhdr,
  it_augru        TYPE TABLE OF tvaut,
  it_reject       TYPE TABLE OF tvagt,
  it_zterm_txt    TYPE TABLE OF tvzbt,
  lv_6mon_date    TYPE dats,
  gv_recipient    TYPE ad_smtpadr,
  gt_recipient    TYPE TABLE OF ad_smtpadr,
  it_ange_user    TYPE TABLE OF ty_ange_user.

DATA: lv_vat       TYPE kwert, "vat calculation
      lv_man_price TYPE netpr. "manual price

      types:       BEGIN OF ty_part_name,
      vbeln        TYPE /dbe/vbeln_va,
      name1        TYPE text40,
      name2        TYPE text40,
      name3        TYPE text40,
      name4        TYPE text40,
      END OF ty_part_name.
DATA: it_part_name TYPE TABLE OF ty_part_name.
TYPES: BEGIN OF ty_cdpos,
         username TYPE cdusername,
         udate    TYPE cddatum,
         tabkey   TYPE tabkey,
         fname    TYPE fieldname,
       END OF ty_cdpos.
DATA: it_cdpos TYPE TABLE OF ty_cdpos.
**--vhvin--
TYPES: BEGIN OF ty_vlcvehicle,
         vhvin TYPE vlc_vhvin,
         vguid TYPE vlc_guid,
       END OF ty_vlcvehicle.
DATA: it_vlcvehicle TYPE TABLE OF ty_vlcvehicle.
TYPES: BEGIN OF ty_vbpa,
         adrnr TYPE adrnr,
         vbeln TYPE /dbe/vbeln_va,
       END OF ty_vbpa.
DATA: it_vbpa TYPE TABLE OF ty_vbpa.
TYPES: BEGIN OF ty_adrct,
         remark     TYPE ad_remark1,
         addrnumber TYPE ad_addrnum,
       END OF ty_adrct.
DATA: it_adrct TYPE TABLE OF ty_adrct.
**--vhvin--
*-----------------------------------------------------------------------
* SELECTION-SCREEN
*-----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b1  WITH FRAME TITLE  TEXT-001.
SELECT-OPTIONS:
  s_plant  FOR /dbe/vbak_db-werks NO INTERVALS,
  s_vkorg  FOR /dbe/vbak_db-vkorg,
  s_vtweg  FOR /dbe/vbak_db-vtweg, "DEFAULT '23',
  s_div    FOR /dbe/vbak_db-spart,
  s_docdat FOR /dbe/vbak_db-audat,
  s_fkdat  FOR  vbrk-fkdat,
  s_mtrl   FOR /dbe/vbap-matnr40,
  s_cust   FOR /dbe/vbap-kunnr,
  s_zterm  FOR /dbe/splhdr_db-zterm,
  s_mtart  FOR mara-mtart,
  s_aufart FOR /dbe/splhdr_db-aufart,
  s_reason FOR /dbe/splhdr_db-augru.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2  WITH FRAME TITLE  TEXT-002.
PARAMETERS:
  p_oso   RADIOBUTTON GROUP rb1 USER-COMMAND tbl_display,
  p_rvrp  RADIOBUTTON GROUP rb1,
  p_rv_bc RADIOBUTTON GROUP rb1,
  p_del   RADIOBUTTON GROUP rb1,
  p_lost  RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.

  s_mtart-sign = 'I'.
  s_mtart-option = 'EQ'.
  s_mtart-low = 'YPOM'.
  APPEND s_mtart.
*  s_mtart-low = 'YCON'.
*  APPEND s_mtart.

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN OUTPUT
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  DATA: lv_executable TYPE char01.
  LOOP AT SCREEN.
    CHECK 1 = 2.
    CHECK screen-name CP 'P_*'.
    CASE screen-name.
      WHEN 'P_OSO'.
        AUTHORITY-CHECK OBJECT 'ZPSALESN' ID 'EXEC_OPTN' FIELD 'OP_ORD_OTC'.
      WHEN 'P_RVRP'.
        AUTHORITY-CHECK OBJECT 'ZPSALESN' ID 'EXEC_OPTN' FIELD 'RV_RPT_OTC'.
      WHEN 'P_RV_BC'.
        AUTHORITY-CHECK OBJECT 'ZPSALESN' ID 'EXEC_OPTN' FIELD 'RV_RPT_BC'.
      WHEN 'P_DEL'.
        AUTHORITY-CHECK OBJECT 'ZPSALESN' ID 'EXEC_OPTN' FIELD 'DELIV_OTC'.
      WHEN 'P_LOST'.
        AUTHORITY-CHECK OBJECT 'ZPSALESN' ID 'EXEC_OPTN' FIELD 'LOST_SALES'.
    ENDCASE.
    IF sy-subrc = 0 .
      screen-invisible = 0.
      screen-active = 1.
      lv_executable = 'X'.
    ELSE.
      screen-invisible = 1.
      screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*  IF lv_executable <> 'X'.
*    MESSAGE TEXT-009 TYPE  'E'.
*  ENDIF.
  IF s_plant IS INITIAL.
    SET CURSOR FIELD 'S_PLANT-LOW'.
  ELSEIF s_vtweg IS INITIAL.
    SET CURSOR FIELD 'S_VTWEG-LOW'.
  ELSEIF s_div IS INITIAL.
    SET CURSOR FIELD 'S_DIV-LOW'.
  ELSEIF ( p_rvrp = abap_true OR p_rv_bc = abap_true ) AND s_fkdat IS INITIAL.
    SET CURSOR FIELD 'S_FKDAT-LOW'.
  ELSEIF ( p_rvrp <> abap_true AND p_rv_bc <> abap_true ) AND s_docdat IS INITIAL.
    SET CURSOR FIELD 'S_DOCDAT-LOW'.
  ENDIF.
  LOOP AT SCREEN.
    IF  screen-name CS 'S_FKDAT'.
      IF p_rvrp <> abap_true
        AND p_rv_bc <> abap_true.
        IF s_fkdat[] IS NOT INITIAL.
          s_docdat[] = s_fkdat[].
        ENDIF.
        CLEAR: s_fkdat, s_fkdat[].
        screen-invisible = 1.
        screen-active = 0.
      ELSE.
        screen-invisible = 0.
        screen-active = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF screen-name CS 'S_DOCDAT'.
      IF p_rvrp <> abap_true
        AND p_rv_bc <> abap_true.
        screen-invisible = 0.
        screen-active = 1.
      ELSE.
        IF s_docdat[] IS NOT INITIAL.
          s_fkdat[] = s_docdat[].
        ENDIF.
        CLEAR: s_docdat , s_docdat[].
        screen-invisible = 1.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.

*  IF s_plant-low IS NOT INITIAL.
*    SELECT SINGLE vkorg FROM tvkwz INTO gv_vkorg WHERE vtweg IN s_vtweg AND werks = s_plant-low.
*    IF sy-subrc <> 0.
*      MESSAGE 'Please enter a valid plant' TYPE 'E'.
*    ENDIF.
*
*    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
*             ID 'ACTVT' FIELD '03'
*             ID 'WERKS' FIELD s_plant-low.
*    IF sy-subrc <> 0.
*      MESSAGE 'You are not authorized for this plant' TYPE 'E'.
*    ENDIF.
*  ENDIF.

  IF ( p_rvrp = abap_true OR p_rv_bc = abap_true ).
    IF s_fkdat IS INITIAL.
      MESSAGE 'Please enter Billing date' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

  IF ( p_rvrp <> abap_true AND p_rv_bc <> abap_true ).
    IF s_docdat IS INITIAL.
      MESSAGE 'Please enter Order date' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
*  IF s_div IS INITIAL.
*    MESSAGE 'Please enter Division' TYPE 'S' DISPLAY LIKE 'E'.
*  ENDIF.
*  IF s_vtweg IS INITIAL.
*    MESSAGE 'Please enter distribution channel' TYPE 'S' DISPLAY LIKE 'E'.
*  ENDIF.
  IF s_plant IS INITIAL.
    MESSAGE 'Please enter plant' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

  IF sy-ucomm = 'TBL_DISPLAY'.
*    REFRESH: s_vtweg[], s_mtart.
*    s_vtweg-sign = 'I'.
*    s_vtweg-option = 'EQ'.
*    IF p_rv_bc = 'X'.
*      s_vtweg-low = '22'.
*    ELSE.
*      s_vtweg-low = '23'.
*    ENDIF.
*    APPEND s_vtweg.

    s_mtart-sign = 'I'.
    s_mtart-option = 'EQ'.
    s_mtart-low = 'YPOM'.
    APPEND s_mtart.
*    s_mtart-low = 'YCON'.
*    APPEND s_mtart.
  ENDIF.
*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

  IF s_plant IS INITIAL.
    MESSAGE 'Please enter plant' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  IF s_vkorg IS INITIAL.
    MESSAGE 'Please enter Sales Organization' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
*  IF s_vtweg IS INITIAL.
*    MESSAGE 'Please enter distribution channel' TYPE 'S' DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
*  ENDIF.
*  IF s_div IS INITIAL.
*    MESSAGE 'Please enter Division' TYPE 'S' DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

  LOOP AT s_plant.
*    SELECT SINGLE vkorg FROM tvkwz INTO gv_vkorg WHERE vtweg IN s_vtweg AND werks = s_plant-low.
*    IF sy-subrc <> 0.
*      MESSAGE e999(ymsg_jet_dbm) WITH 'Plant ' s_plant-low 'is not valid'.
*    ENDIF.

    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
    ID 'ACTVT' FIELD '03'
    ID 'WERKS' FIELD s_plant-low.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized for this plant' TYPE 'E'.
    ENDIF.
  ENDLOOP.

  IF ( p_rvrp = abap_true OR p_rv_bc = abap_true ).
    IF s_fkdat IS INITIAL.
      MESSAGE 'Please enter Billing date' TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ELSEIF sy-batch <> 'X'.
      CALL FUNCTION 'HR_JP_ADD_MONTH_TO_DATE'
        EXPORTING
          iv_monthcount = '6'    " Number of Months
          iv_date       = s_fkdat-low    " Input Date
        IMPORTING
          ev_date       = lv_6mon_date.    " Output Date
      IF s_fkdat-high IS NOT INITIAL AND lv_6mon_date LT s_fkdat-high.
        MESSAGE 'Billing date interval cannot be more than 3 months in foreground'
          TYPE 'S' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ( p_rvrp <> abap_true AND p_rv_bc <> abap_true ).
    IF s_docdat IS INITIAL.
      MESSAGE 'Please enter Order date' TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ELSEIF sy-batch <> 'X'.
      CALL FUNCTION 'HR_JP_ADD_MONTH_TO_DATE'
        EXPORTING
          iv_monthcount = '3'    " Number of Months
          iv_date       = s_docdat-low    " Input Date
        IMPORTING
          ev_date       = lv_6mon_date.    " Output Date
      IF s_docdat-high IS NOT INITIAL AND lv_6mon_date LT s_docdat-high.
        MESSAGE 'Order date interval cannot be more than 3 months in foreground'
          TYPE 'S' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
  ENDIF.

  IF sy-batch IS NOT INITIAL.
    SELECT SINGLE a~smtp_addr FROM usr21 AS u
      INNER JOIN adr6 AS a
      ON u~addrnumber = a~addrnumber
      AND u~persnumber = a~persnumber
      INTO gv_recipient
      WHERE bname = sy-uname.
      IF sy-subrc = 0.
        APPEND gv_recipient TO gt_recipient.
      ENDIF.
      SELECT low FROM tvarvc
        CLIENT SPECIFIED
        INTO TABLE @DATA(lt_low)
        WHERE mandt = '000'
          AND name = 'YDBM_JET_YPSALESN_EMAILS'.
        IF sy-subrc = 0.
          LOOP AT lt_low INTO DATA(ls_low).
            gv_recipient = ls_low-low.
            APPEND gv_recipient TO gt_recipient.
          ENDLOOP.
        ENDIF.
        IF gt_recipient IS INITIAL.
          MESSAGE 'No email found' TYPE 'E'.
          LEAVE LIST-PROCESSING.
        ENDIF.
      ENDIF.

      PERFORM f_getdata.
      PERFORM f_get_item_price.
      PERFORM f_prepare_data.
      IF sy-batch IS NOT INITIAL.
        PERFORM f_email.
      ELSE.
        PERFORM f_display.
      ENDIF.

*&---------------------------------------------------------------------*
*&      Form  F_GETDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_getdata.
  DATA: r_vbeln      TYPE RANGE OF /dbe/vbak_db-vbeln,
        r_vbeln_del  TYPE RANGE OF lips-vbeln,
        r_o_type     TYPE RANGE OF /dbe/c_ordertp-aufart,
        r_vbeln_inv  TYPE RANGE OF vbrk-vbeln,
        r_zuonr      TYPE RANGE OF vbrk-zuonr,
        r_orders     TYPE RANGE OF vbrk-vbeln,
        lt_engine    TYPE RANGE OF /dbe/vbak_db-engine,
        ls_engine    LIKE LINE OF lt_engine,
        lt_vbak_ange TYPE TABLE OF ty_vbak.

  FIELD-SYMBOLS: <fs_vbap> TYPE ty_vbap.
  CONSTANTS: gc_mm TYPE /dbe/vbak_db-engine VALUE 'MM',
             gc_cs TYPE /dbe/vbak_db-engine VALUE 'CS'.

  IF p_rv_bc = 'X'.
    ls_engine-sign = 'I'.
    ls_engine-option = 'EQ'.
    ls_engine-low = gc_cs.
    APPEND ls_engine TO lt_engine.
  ELSEIF p_lost = 'X'.
    ls_engine-sign = 'I'.
    ls_engine-option = 'EQ'.
    ls_engine-low = gc_cs.
    APPEND ls_engine TO lt_engine.
    ls_engine-sign = 'I'.
    ls_engine-option = 'EQ'.
    ls_engine-low = gc_mm.
    APPEND ls_engine TO lt_engine.
  ELSE.
    ls_engine-sign = 'I'.
    ls_engine-option = 'EQ'.
    ls_engine-low = gc_mm.
    APPEND ls_engine TO lt_engine.
  ENDIF.

*  IF gv_vkorg IS INITIAL.
*    SELECT SINGLE vkorg FROM tvkwz INTO gv_vkorg WHERE vtweg IN s_vtweg AND werks IN s_plant[].
*  ENDIF.
*  SELECT SINGLE bukrs FROM tvko INTO gv_bukrs WHERE vkorg = gv_vkorg.

  IF p_rvrp = 'X' OR p_rv_bc = 'X'.

    SELECT vbeln vbtyp vtweg spart zuonr fkdat fksto
      FROM vbrk
      INTO TABLE it_vbrkt
     WHERE vkorg IN s_vkorg"  gv_vkorg
       AND vtweg IN s_vtweg
       AND fkdat IN s_fkdat.
*      AND spart IN s_div.
      IF it_vbrkt IS NOT INITIAL.
        SORT it_vbrkt BY vbtyp fksto.
        DELETE it_vbrkt WHERE NOT ( ( vbtyp = 'M' OR vbtyp = 'O' ) AND fksto = '' ).
        SORT it_vbrkt BY spart.
        DELETE it_vbrkt WHERE spart NOT IN s_div.
      ENDIF.

* dont change the following lines as it_billing is used later for price fm. loop at it_vbrk for fkdat will take more time
*      SELECT h~vbeln i~posnr i~vgbel i~vgpos h~fkdat
*        FROM vbrk AS h
*       INNER JOIN vbrp AS i
*          ON h~vbeln = i~vbeln
*        INTO TABLE it_billing
*       WHERE i~vbeln IN r_orders.
      IF it_vbrkt IS NOT INITIAL.
        SELECT vbeln posnr vgbel vgpos werks wavwr
               augru_auft ktgrm
          FROM vbrp
          INTO TABLE it_billing
           FOR ALL ENTRIES IN it_vbrkt
         WHERE vbeln = it_vbrkt-vbeln.
          IF sy-subrc = 0 AND it_billing IS NOT INITIAL.
            SORT it_billing BY werks.
            DELETE it_billing WHERE werks NOT IN s_plant[].

            r_vbeln_inv = VALUE #( FOR <ls4> IN it_billing ( sign = 'I' option = 'EQ'  low = |{ <ls4>-vbeln ALPHA = IN }| ) ).
            SORT r_vbeln_inv BY low.
            DELETE ADJACENT DUPLICATES FROM r_vbeln_inv COMPARING low.
            DELETE it_vbrkt WHERE vbeln NOT IN r_vbeln_inv.

            SORT it_billing BY vbeln.
            r_orders = VALUE #( FOR <ls> IN it_billing ( sign = 'I' option = 'EQ'  low = |{ <ls>-dbm_vbeln ALPHA = IN }| ) ).
            SORT r_orders BY low.
            DELETE ADJACENT DUPLICATES FROM r_orders COMPARING low.

            SELECT * FROM tvaut INTO TABLE it_tvaut
              WHERE spras = 'EN'.

              SELECT * FROM tvkmt
                INTO TABLE it_aag
                WHERE spras = 'EN'.
              ENDIF.
            ENDIF.

            IF r_orders IS NOT INITIAL.
              SELECT vbeln audat  vkorg vtweg spart bukrs_vf werks fert_date_tmstp
                     pernr engine vguid licpl hstat visit_start_tst visit_end_tst ange_user
                INTO TABLE it_vbak
                FROM /dbe/vbak_db
                FOR ALL ENTRIES IN r_orders
               WHERE vbeln = r_orders-low
                 AND audat IN s_docdat.
                IF sy-subrc = 0 AND it_vbak IS NOT INITIAL.
                  SORT it_vbak BY engine.
                  DELETE it_vbak WHERE engine NOT IN lt_engine.
                ENDIF.
              ENDIF.

            ELSE.

              SELECT vbeln audat  vkorg vtweg spart bukrs_vf werks fert_date_tmstp
                     pernr engine vguid licpl hstat visit_start_tst visit_end_tst ange_user
                INTO TABLE it_vbak
                FROM /dbe/vbak_db
               WHERE werks IN s_plant
*    AND vkorg IN s_s_org
                 AND vtweg IN s_vtweg
                 AND spart IN s_div
                 AND engine IN lt_engine
*    AND vbeln IN s_odr_no
*    AND pernr IN s_sr_adv
                 AND audat IN s_docdat. "check if this is affecting performance and replace with delete later
*    AND hstat IN s_odr_st.
                IF sy-subrc = 0 AND it_vbak IS NOT INITIAL.
                  SORT it_vbak BY vkorg.
*      DELETE it_vbak WHERE vkorg <> gv_vkorg.
                ENDIF.
              ENDIF.

              IF it_vbak IS NOT INITIAL.
                SELECT vbeln zterm aufart augru
                  FROM /dbe/splhdr_db
                  INTO TABLE it_splhdr
                  FOR ALL ENTRIES IN it_vbak
                  WHERE vbeln = it_vbak-vbeln
                    AND aufart IN s_aufart
                    AND augru IN s_reason
                    AND splnr = '0001'
                    AND zterm IN s_zterm.
                  IF sy-subrc = 0.
                    SELECT * FROM tvaut
                      INTO TABLE it_augru
                      WHERE spras = 'EN'.
                    ENDIF.

                    SELECT * FROM tvzbt
                      INTO TABLE it_zterm_txt
                      WHERE spras = 'EN'.

                      lt_vbak_ange = it_vbak.
                      SORT lt_vbak_ange BY ange_user.
                      DELETE ADJACENT DUPLICATES FROM lt_vbak_ange COMPARING ange_user.
                      DELETE lt_vbak_ange WHERE ange_user IS INITIAL.
                      IF lt_vbak_ange IS NOT INITIAL.
                        SELECT bname name_text FROM user_addrp
                          INTO TABLE it_ange_user
                          FOR ALL ENTRIES IN lt_vbak_ange
                          WHERE bname = lt_vbak_ange-ange_user.
                        ENDIF.
                      ENDIF.

                      IF it_vbak IS NOT INITIAL.
                        SORT it_vbak BY vbeln.
* Pick orders from order status table based on status
                        r_vbeln = VALUE #( FOR <ls1> IN it_vbak ( sign = 'I' option = 'EQ' low = <ls1>-vbeln ) ).

                        IF p_rvrp = 'X'.
                          SELECT *
                            INTO TABLE it_so_stat
                            FROM /dbe/oe_vbakst
                            FOR ALL ENTRIES IN r_vbeln
                           WHERE vbeln = r_vbeln-low
                             AND ( ( action = 'BILLING_CREATE' AND status EQ 'C') ).
* Open Sales orders
                          ELSEIF p_oso = 'X'.
                            SELECT *
                              INTO TABLE it_so_stat
                              FROM /dbe/oe_vbakst
                              FOR ALL ENTRIES IN r_vbeln
                             WHERE vbeln = r_vbeln-low
                              AND ( ( action = 'BILLING_CREATE' AND status NE 'C') OR ( action = 'DELIVERY_CREATE' AND status NE 'C' ) ).
* Delivery created not billed
                            ELSEIF p_del = 'X'.
                              SELECT *
                                INTO TABLE it_so_stat
                                FROM /dbe/oe_vbakst
                                FOR ALL ENTRIES IN r_vbeln
                               WHERE vbeln = r_vbeln-low
                                AND ( ( action = 'BILLING_CREATE' AND status NE 'C') OR ( action = 'DELIVERY_CREATE' AND status EQ 'C' ) ).
                              ENDIF.

                              IF p_oso = 'X' OR p_rvrp = 'X'.
* Clear the range table and populate again with entries from the header status table
                                CLEAR r_vbeln[].
                                r_vbeln = VALUE #( FOR <ls2> IN it_so_stat ( sign = 'I' option = 'EQ' low = <ls2>-vbeln ) ).
                                DELETE it_vbak WHERE vbeln NOT IN r_vbeln.
                              ELSEIF p_del = 'X'.
                                LOOP AT it_vbak ASSIGNING FIELD-SYMBOL(<fs_vbak_del>).
                                  READ TABLE it_so_stat TRANSPORTING NO FIELDS
                                    WITH KEY vbeln = <fs_vbak_del>-vbeln
                                             action = 'BILLING_CREATE'.
                                  IF sy-subrc = 0.
                                    READ TABLE it_so_stat TRANSPORTING NO FIELDS
                                      WITH KEY vbeln = <fs_vbak_del>-vbeln
                                               action = 'DELIVERY_CREATE'.
                                    IF sy-subrc <> 0.
                                      CLEAR: <fs_vbak_del>.
                                    ENDIF.
                                  ELSE.
                                    CLEAR: <fs_vbak_del>.
                                  ENDIF.
                                ENDLOOP.
                                DELETE it_vbak WHERE vbeln IS INITIAL.
                              ENDIF.
*------------------------VIN NUMBER LOGIC-------------------------------------------------
                              IF it_vbak IS NOT INITIAL.
*      2
                                SELECT vhvin  vguid
                                    FROM vlcvehicle
                                    INTO TABLE it_vlcvehicle
                                      FOR ALL ENTRIES IN it_vbak
                                    WHERE vguid = it_vbak-vguid.
*        3.
                                  SELECT adrnr vbeln
                                    FROM /dbe/vbpa
                                    INTO TABLE it_vbpa
                                    FOR ALL ENTRIES IN it_vbak
                                    WHERE vbeln = it_vbak-vbeln AND
                                          parvw = 'AG'.
                                    IF it_vbpa IS NOT INITIAL.
                                      SELECT remark addrnumber
                                        FROM adrct
                                        INTO TABLE it_adrct
                                        FOR ALL ENTRIES IN it_vbpa
                                        WHERE addrnumber = it_vbpa-adrnr AND langu = 'E'.
                                      ENDIF.
                                    ENDIF.
*----------------------------------------END-----------------------------------------------
* Sales order types
                                    SELECT aufart auart_sd auart_co vbtyp
                                      FROM /dbe/c_ordertp
                                      INTO TABLE lt_order_type
                                     WHERE engine IN lt_engine
                                       AND ( vbtyp  EQ 'B' OR vbtyp  EQ 'C'
                                        OR vbtyp EQ 'H'
                                        OR vbtyp EQ 'O' ).

                                      IF lt_order_type IS NOT INITIAL.
                                        r_o_type = VALUE #( FOR <ls3> IN lt_order_type ( sign = 'I' option = 'EQ' low = <ls3>-aufart ) ).
                                      ENDIF.

                                      IF r_vbeln IS NOT INITIAL.
                                        IF p_lost = 'X'.
                                          SELECT vbeln posnr kunnr aufart itcat matnr40 matnr18
                                                 descr1 itcanc target_time zmeng netwr itobjid abgru
                                                 mvgr1 mvgr2 mvgr3 mvgr4 mvgr5 "zallowed_disc
                                                 netpr kzwi5           "KZWI5 for profit margin
                                            FROM /dbe/vbap
                                            INTO TABLE it_vbap
                                            FOR ALL ENTRIES IN r_vbeln
                                           WHERE vbeln   = r_vbeln-low
                                             AND aufart  IN r_o_type
                                             AND kunnr   IN s_cust
                                             AND matnr40 IN s_mtrl
                                             AND itcanc = 'X'.
                                          ELSE.
                                            SELECT vbeln posnr kunnr aufart itcat matnr40 matnr18
                                                   descr1 itcanc target_time zmeng netwr itobjid abgru
                                                   mvgr1 mvgr2 mvgr3 mvgr4 mvgr5 "zallowed_disc
                                              netpr kzwi5           "KZWI5 for profit margin
                                              FROM /dbe/vbap
                                              INTO TABLE it_vbap
                                              FOR ALL ENTRIES IN r_vbeln
                                             WHERE vbeln   =  r_vbeln-low
                                               AND aufart  IN r_o_type
                                               AND kunnr   IN s_cust
                                               AND matnr40 IN s_mtrl.
                                            ENDIF.
                                          ENDIF.

*   Clear the range table and populate again with entries from the header status table
                                          IF it_vbap[] IS NOT INITIAL.
                                            CLEAR r_vbeln[].
                                            r_vbeln = VALUE #( FOR <ls5> IN it_vbap ( sign = 'I' option = 'EQ' low = <ls5>-vbeln ) ) .
                                            DELETE ADJACENT DUPLICATES FROM r_vbeln.
                                            DELETE it_vbak WHERE vbeln NOT IN r_vbeln.

                                          ENDIF.
                                        ENDIF.

                                        IF it_vbak IS NOT INITIAL.
                                          SELECT *
                                            FROM /dbe/oe_hstat_t
                                            INTO TABLE it_order_status
                                             "FOR ALL ENTRIES IN it_vbak
                                           WHERE "hstat = it_vbak-hstat
                                            " AND
                                            spras = 'EN'.
                                            IF sy-subrc = 0.
                                              SORT it_order_status BY hstat.
                                            ENDIF.

                                            SELECT *
                                              FROM /dbe/oe_hstat
                                              INTO TABLE it_hstat_icon.

                                              SELECT pernr nachn name2
                                                FROM pa0002
                                                INTO TABLE it_pernr
                                                 FOR ALL ENTRIES IN it_vbak
                                               WHERE pernr = it_vbak-pernr.
                                                IF sy-subrc = 0.
                                                  SORT it_pernr BY pernr.
                                                ENDIF.

                                                IF it_vbap IS NOT INITIAL.
                                                  SELECT *
                                                    FROM tvagt
                                                    INTO TABLE it_tvagt
                                                     FOR ALL ENTRIES IN it_vbap
                                                   WHERE spras = sy-langu AND abgru = it_vbap-abgru.

                                                    SELECT kunnr vkorg vtweg spart kdgrp
                                                      FROM knvv
                                                      INTO TABLE it_cust_group
                                                       FOR ALL ENTRIES IN it_vbap
                                                     WHERE kunnr = it_vbap-kunnr.

                                                      SELECT spras kdgrp ktext
                                                        FROM t151t
                                                        INTO TABLE it_cg_desc
                                                       WHERE spras = sy-langu.

                                                        SELECT spras aufart bezei
                                                          FROM /dbe/c_ordertpt
                                                          INTO TABLE it_aufart
                                                           FOR ALL ENTRIES IN it_vbap
                                                         WHERE aufart = it_vbap-aufart
                                                           AND spras =  'EN'.
                                                          IF sy-subrc = 0.
                                                            SORT it_aufart BY aufart.
                                                          ENDIF.

*      DATA: lt_tabkey TYPE TABLE OF cdtabkey,
*            lv_tabkey TYPE cdtabkey.
*      LOOP AT it_vbap INTO DATA(ls_vbap).
*        CONCATENATE sy-mandt ls_vbap-vbeln ls_vbap-posnr INTO lv_tabkey.
*        APPEND lv_tabkey TO lt_tabkey.
*        CONCATENATE ls_vbap-vbeln ls_vbap-posnr INTO lv_tabkey.
*        APPEND lv_tabkey TO lt_tabkey.
*      ENDLOOP.
                                                          DATA: lt_objectid TYPE TABLE OF cdobjectv,
                                                                lv_objectid TYPE cdobjectv.

                                                          LOOP AT it_vbak INTO DATA(ls_vbak_key).
                                                            lv_objectid = ls_vbak_key-vbeln.
                                                            APPEND lv_objectid TO lt_objectid.
                                                          ENDLOOP.
                                                          IF lt_objectid IS NOT INITIAL.
                                                            SELECT h~username h~udate i~tabkey i~fname FROM cdhdr AS h
                                                              INNER JOIN cdpos AS i
                                                              ON ( h~objectclas = i~objectclas
                                                              AND  h~objectid = i~objectid
                                                              AND  h~changenr = i~changenr )
                                                              INTO TABLE it_cdpos
*        FOR ALL ENTRIES IN lt_tabkey
                                                              FOR ALL ENTRIES IN lt_objectid
                                                              WHERE i~objectclas = '/DBE/ORDER'
                                                                AND i~objectid = lt_objectid-table_line
                                                                AND i~tabname = '/DBE/VBAP'
*          AND i~tabkey = lt_tabkey-table_line
                                                                AND ( i~fname = 'ABGRU'
                                                                 OR i~fname = 'ZALLOWED_DISC'
                                                                 OR i~fname = 'NETPR' ).

                                                              SORT it_cdpos BY udate DESCENDING.
                                                            ENDIF.
                                                          ENDIF.

                                                          IF r_vbeln IS NOT INITIAL.
                                                            SELECT *
                                                              FROM /dbe/oe_vbapst
                                                              INTO TABLE lt_vbap_st
                                                              FOR ALL ENTRIES IN r_vbeln
                                                             WHERE vbeln = r_vbeln-low.
                                                            ENDIF.

                                                            SELECT t001w~werks "#EC CI_NO_TRANSFORM
                                                                   t001w~name1
                                                              INTO TABLE it_plant
                                                              FROM t001w
                                                               FOR ALL ENTRIES IN it_vbak
                                                             WHERE werks = it_vbak-werks.
                                                              IF sy-subrc = 0.
                                                                SORT it_plant BY werks.
                                                              ENDIF.

*   Fetch Lips and Likp vbuk part for item delivery status
                                                              IF r_vbeln IS NOT INITIAL.
                                                                SELECT vbeln posnr /dbe/vbeln /dbe/posnr lfimg wbsta  "h~vbtyp
                                                                  FROM lips
                                                                  INTO TABLE it_lips
                                                                  FOR ALL ENTRIES IN r_vbeln
                                                                 WHERE /dbe/vbeln = r_vbeln-low.
                                                                  IF sy-subrc = 0.
                                                                    r_vbeln_del = VALUE #( FOR <wa> IN it_lips ( sign = 'I' option = 'EQ' low = <wa>-vbeln ) ).

                                                                    IF r_vbeln_del IS NOT INITIAL.
                                                                      SELECT vbeln vbtyp FROM likp INTO TABLE it_likp
                                                                        FOR ALL ENTRIES IN r_vbeln_del
                                                                        WHERE vbeln = r_vbeln_del-low.
                                                                        IF sy-subrc = 0 AND it_likp IS NOT INITIAL.
                                                                          SORT it_likp BY vbtyp.
                                                                          DELETE it_likp WHERE vbtyp <> 'J'.
                                                                          SORT it_likp BY vbeln.
                                                                          CLEAR r_vbeln_del[].
                                                                          r_vbeln_del = VALUE #( FOR <wa2> IN it_likp ( sign = 'I' option = 'EQ' low = <wa2>-vbeln ) ).
                                                                          DELETE it_lips WHERE vbeln NOT IN r_vbeln_del.
                                                                          SORT it_lips BY vbeln posnr.
                                                                          it_lips_o[] = it_lips[].
                                                                          DELETE it_lips_o WHERE wbsta NE 'C'.
                                                                        ENDIF.
                                                                      ENDIF.
                                                                    ENDIF.
                                                                  ENDIF.

*    IF r_vbeln_del IS NOT INITIAL.
*      SELECT vbeln posnr wbsta
*        FROM vbup
*        INTO TABLE it_vbup
*        FOR ALL ENTRIES IN r_vbeln_del
*       WHERE vbeln = r_vbeln_del-low.
**        AND wbsta = 'C'.
*      IF it_vbup IS NOT INITIAL.
*        DELETE it_vbup WHERE wbsta NE 'C'.
*      ENDIF.
*    ENDIF.


*   Part 2

*    SORT it_vbup BY vbeln posnr.
                                                                  SORT it_lips BY dbm_vbeln dbm_posnr.
                                                                  SORT it_billing BY dbm_vbeln dbm_item.

                                                                  IF s_mtart[] IS NOT INITIAL.
                                                                    DATA: lt_vbap_mat LIKE it_vbap.
                                                                    lt_vbap_mat = it_vbap.
                                                                    SORT lt_vbap_mat BY matnr18.
                                                                    DELETE ADJACENT DUPLICATES FROM lt_vbap_mat COMPARING matnr18.
                                                                    DELETE lt_vbap_mat WHERE matnr18 IS INITIAL.
                                                                    IF lt_vbap_mat IS NOT INITIAL.
                                                                      SELECT matnr FROM mara
                                                                        INTO TABLE @DATA(lt_matnr18)
                                                                        FOR ALL ENTRIES IN @lt_vbap_mat
                                                                        WHERE matnr = @lt_vbap_mat-matnr40
                                                                          AND mtart IN @s_mtart.
                                                                      ENDIF.
                                                                    ENDIF.

                                                                    LOOP AT it_vbap ASSIGNING <fs_vbap>.
                                                                      IF s_mtart[] IS NOT INITIAL.
                                                                        READ TABLE lt_matnr18 TRANSPORTING NO FIELDS
                                                                          WITH KEY matnr = <fs_vbap>-matnr18.
                                                                        IF sy-subrc <> 0.
                                                                          CLEAR: <fs_vbap>-vbeln.
                                                                          CONTINUE. "==========>>>
                                                                        ENDIF.
                                                                      ENDIF.
                                                                      CLEAR: ls_lips.
                                                                      LOOP AT it_lips INTO ls_lips
                                                                        WHERE dbm_vbeln = <fs_vbap>-vbeln
                                                                          AND dbm_posnr = <fs_vbap>-posnr.
                                                                        READ TABLE it_lips_o INTO ls_lips_o WITH KEY  vbeln = ls_lips-vbeln
                                                                                   posnr = ls_lips-posnr  BINARY SEARCH.
                                                                        IF sy-subrc = 0.
                                                                          <fs_vbap>-deliv_qty = <fs_vbap>-deliv_qty + ls_lips-lfimg.
                                                                        ELSE.
                                                                          <fs_vbap>-open_qty = <fs_vbap>-open_qty + ls_lips-lfimg.
                                                                        ENDIF.
                                                                      ENDLOOP.
                                                                      IF sy-subrc <> 0 AND p_del = 'X'.
                                                                        CLEAR: <fs_vbap>-vbeln.
                                                                      ENDIF.
                                                                      IF <fs_vbap>-open_qty GT 0.
                                                                        <fs_vbap>-status = 'Delivery Created'.
                                                                      ELSE.
                                                                        <fs_vbap>-status = 'PGI Complete'.
                                                                      ENDIF.

                                                                      READ TABLE it_billing TRANSPORTING NO FIELDS
                                                                      WITH KEY dbm_vbeln = <fs_vbap>-vbeln
                                                                                 dbm_item = <fs_vbap>-posnr BINARY SEARCH.
                                                                      IF sy-subrc = 0.
                                                                        IF ls_lips-vbeln IS NOT INITIAL AND p_oso = 'X'.
                                                                          CLEAR: <fs_vbap>-vbeln.
                                                                        ENDIF.
                                                                        IF <fs_vbap>-status <> 'PGI Complete'.
                                                                          <fs_vbap>-status = 'Billing Created'.
                                                                        ENDIF.
                                                                      ELSEIF p_rvrp = 'X' OR p_rv_bc = 'X'.
                                                                        CLEAR: <fs_vbap>-vbeln.
                                                                      ENDIF.
                                                                    ENDLOOP.

                                                                    DELETE it_vbak WHERE vbeln IS INITIAL.
                                                                    DELETE it_vbap WHERE vbeln IS INITIAL.
*** end of lips/likp/vbuk part.

                                                                    SELECT v~vbeln a~name1 a~name2 a~name3 a~name4
                                                                      FROM /dbe/vbpa AS v INNER JOIN
                                                                      adrc AS a ON v~adrnr = a~addrnumber
                                                                      INTO TABLE it_part_name
                                                                      FOR ALL ENTRIES IN it_vbak
                                                                      WHERE v~vbeln = it_vbak-vbeln
                                                                        AND v~split = '0001'
                                                                        AND v~parvw = 'AG'.
                                                                    ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_ITEM_PRICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_item_price .
  DATA: lt_items   TYPE zcl_mm_sales_rpt_util=>tt_items,
        lv_invoice TYPE crmt_boolean.

  IF p_rvrp IS NOT INITIAL OR p_rv_bc IS NOT INITIAL.
    lt_items[] = it_billing[].
    lv_invoice = abap_true.
  ELSE.
    lt_items[] = it_vbap[].
  ENDIF.

  CALL METHOD zcl_mm_sales_rpt_util=>get_item_price
    EXPORTING
      it_items      = lt_items
      iv_invoice    = lv_invoice    " Logical Variable
    IMPORTING
      et_item_price = it_item_price.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
*       same code from previous report, no change
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data .
  DATA : ts_vbak              TYPE ty_vbak,
         ts_plant             TYPE ty_plant,
         ts_hstat             TYPE /dbe/oe_hstat_t,
         ts_vbap              TYPE ty_vbap,
         ts_aufart            TYPE ty_aufart,
         ts_pernr             TYPE ty_pernr,
         ts_alv               TYPE ty_alv,
         ts_centraldataperson TYPE bapibus1006_central_person,
         lv_zuonr             TYPE string,
         it_lines             TYPE TABLE OF tline,
         ts_lines             TYPE tline,
         lv_text_name         TYPE tdobname,
         lv_date              TYPE sy-datum,
         lv_time              TYPE sy-timlo,
         it_item_cat          TYPE TABLE OF zvssc_itcat_part,
         ts_item_cat          TYPE zvssc_itcat_part,
         ts_splhdr            TYPE /dbe/splhdr_db,
         ls_centraldata_org   TYPE bapibus1006_central_organ,
         ls_cust_group        TYPE ty_cust_group,
         ls_cg_desc           TYPE t151t,
         ls_billing           TYPE ty_billing,
         lv_paid              TYPE boolean,
         ts_hstat_icon        TYPE /dbe/oe_hstat.

  DATA: ls_item_price TYPE zcl_mm_sales_rpt_util=>ty_item_price.

  SORT it_item_price BY vbeln posnr.
  SORT it_vbrkt BY vbeln.

  LOOP AT it_vbak INTO ts_vbak.

    READ TABLE it_splhdr INTO DATA(ls_splhdr)
      WITH KEY vbeln = ts_vbak-vbeln.
    IF sy-subrc = 0.
      ts_alv-zterm = ls_splhdr-zterm.
      ts_alv-aufart = ls_splhdr-aufart.
      READ TABLE it_augru INTO DATA(ls_augru)
        WITH KEY augru = ls_splhdr-augru.
      IF sy-subrc = 0.
        ts_alv-augru = ls_augru-bezei.
      ENDIF.
      READ TABLE it_zterm_txt INTO DATA(ls_zterm_txt)
        WITH KEY zterm = ls_splhdr-zterm.
      IF sy-subrc = 0.
        ts_alv-zterm_txt = ls_zterm_txt-vtext.
      ENDIF.
    ELSE.
      CONTINUE. "==========>>>
    ENDIF.
    ts_alv-vbeln = ts_vbak-vbeln.
    ts_alv-werks = ts_vbak-werks.
    ts_alv-vkorg = ts_vbak-vkorg.
    ts_alv-vtweg = ts_vbak-vtweg.
    ts_alv-spart = ts_vbak-spart.
    ts_alv-ange_user = ts_vbak-ange_user.
    READ TABLE it_ange_user INTO DATA(ls_ange_user)
      WITH KEY bname = ts_vbak-ange_user.
    IF sy-subrc = 0.
      ts_alv-ange_name = ls_ange_user-name_text.
    ENDIF.

    ts_alv-hstat = ts_vbak-hstat.
    ts_alv-no_of_days = sy-datum - ts_vbak-audat.
    IF ts_alv-no_of_days < 15.
      ts_alv-range = '< 15 days'.
    ELSEIF ts_alv-no_of_days <= 30.
      ts_alv-range = '15-30 days'.
    ELSEIF ts_alv-no_of_days <= 60.
      ts_alv-range = '31-60 days'.
    ELSE.
      ts_alv-range = '>60 days'.
    ENDIF.

    CLEAR : lv_date, lv_time.
    CONVERT TIME STAMP ts_vbak-pl_comp_dat TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time.
*   CONCATENATE lv_date+6(2) '-' lv_date+4(2) '-' lv_date+0(4) INTO ts_alv-pl_comp_dat.
    CLEAR : lv_date, lv_time.
    CONVERT TIME STAMP ts_vbak-visit_start_tst TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time.
*    CONCATENATE lv_date+6(2) '-' lv_date+4(2) '-' lv_date+0(4) INTO ts_alv-received_date.
    CONCATENATE  lv_date+4(2) '-' lv_date+0(4) INTO  ts_alv-month.
    CLEAR : lv_date, lv_time.
    CONVERT TIME STAMP ts_vbak-visit_start_tst TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time.
*   CONCATENATE lv_date+6(2) '-' lv_date+4(2) '-' lv_date+0(4) INTO ts_alv-promised_date.
*   ts_alv-received_date = lv_date.
*   ts_alv-licpl = ts_vbak-licpl.
*   ts_alv-accept_date = ts_vbak-audat.
    CONCATENATE ts_vbak-audat+6(2) '-' ts_vbak-audat+4(2) '-' ts_vbak-audat+0(4) INTO ts_alv-accept_date.
*   CONCATENATE ts_alv-received_date+4(2) '-' ts_alv-received_date+0(4) INTO ts_alv-month.

    READ TABLE it_hstat_icon INTO ts_hstat_icon WITH KEY hstat = ts_vbak-hstat.
    IF sy-subrc = 0.
      WRITE ts_hstat_icon-icon_id AS ICON TO ts_alv-status_icon.
    ENDIF.

    READ TABLE it_order_status INTO ts_hstat WITH KEY hstat = ts_vbak-hstat.
    IF sy-subrc = 0.
      CONCATENATE ts_alv-hstat '-' ts_hstat-bezei INTO ts_alv-hstat.
    ENDIF.

    READ TABLE it_pernr INTO ts_pernr WITH KEY pernr = ts_vbak-pernr BINARY SEARCH.
    IF sy-subrc = 0.
      CONCATENATE ts_pernr-nachn ts_pernr-name2 INTO ts_alv-service_advisor SEPARATED BY space.
    ENDIF.

    READ TABLE it_part_name INTO DATA(ls_part_name) WITH KEY vbeln = ts_alv-vbeln.
    IF sy-subrc = 0.
      CONCATENATE ls_part_name-name1 ls_part_name-name2 ls_part_name-name3 ls_part_name-name4
           INTO ts_alv-customer_name SEPARATED BY space.
      CONDENSE ts_alv-customer_name.
    ENDIF.

    LOOP AT it_vbap INTO ts_vbap WHERE vbeln = ts_vbak-vbeln." AND splnr = ts_splhdr-splnr.
      READ TABLE it_cust_group INTO ls_cust_group
        WITH KEY kunnr = ts_vbap-kunnr
                 vkorg = ts_vbak-vkorg
                 vtweg = ts_vbak-vtweg
                 spart = ts_vbak-spart.
      IF sy-subrc = 0.
        READ TABLE it_cg_desc INTO ls_cg_desc
          WITH KEY kdgrp = ls_cust_group-kdgrp.
        IF sy-subrc = 0.
          ts_alv-customer_group = ls_cg_desc-ktext.
        ENDIF.
      ENDIF.
** rejection status
      ts_alv-del_itm = ts_vbap-itcanc.
      ts_alv-rej_itm = ts_vbap-abgru.
      READ TABLE it_tvagt INTO wa_rtxt WITH KEY abgru = ts_vbap-abgru.
      IF sy-subrc = 0.
        ts_alv-rej_itmt = wa_rtxt-bezei.
      ENDIF.
*      ts_alv-zallowed_disc = ts_vbap-zallowed_disc.
*      ts_alv-manual_price = ts_vbap-manual_price. "05/12/2024
      ts_alv-mvgr1 = ts_vbap-mvgr1.
      ts_alv-mvgr2 = ts_vbap-mvgr2.
      ts_alv-mvgr3 = ts_vbap-mvgr3.
      ts_alv-mvgr4 = ts_vbap-mvgr4.
      ts_alv-mvgr5 = ts_vbap-mvgr5.
      ts_alv-status = ts_vbap-status.
*        ts_alv-it_cat = ts_vbap-it_cat.
      ts_alv-posnr = ts_vbap-posnr.
      ts_alv-matnr18 = ts_vbap-matnr18.
*      ts_alv-matnr40 = ts_vbap-matnr40.
      ts_alv-matnr40 = ts_vbap-itobjid.
      ts_alv-quantity = ts_vbap-zmeng.
      ts_alv-deliv_qty = ts_vbap-deliv_qty.
      ts_alv-open_qty = ts_alv-quantity - ts_alv-deliv_qty.
*      CLEAR: ts_centraldataperson, ls_centraldata_org.
*      CALL FUNCTION 'BAPI_BUPA_CENTRAL_GETDETAIL'
*        EXPORTING
*          businesspartner         = ts_vbap-kunnr
*        IMPORTING
*          centraldataperson       = ts_centraldataperson
*          centraldataorganization = ls_centraldata_org.
*      IF ts_centraldataperson IS NOT INITIAL.
*        CONCATENATE ts_centraldataperson-firstname ts_centraldataperson-lastname INTO ts_alv-customer_name SEPARATED BY space.
*      ELSE.
*        CONCATENATE ls_centraldata_org-name1 ls_centraldata_org-name2 ls_centraldata_org-name3 ls_centraldata_org-name4
*          INTO ts_alv-customer_name SEPARATED BY space.
*      ENDIF.
*      CONDENSE ts_alv-customer_name.

      READ TABLE it_aufart INTO ts_aufart WITH KEY aufart = ts_vbap-aufart BINARY SEARCH.
      IF sy-subrc = 0.
        ts_alv-repair_type = ts_aufart-bezei.
      ENDIF.
      DATA: lv_table_key TYPE cdtabkey.
      DATA: lv_table_key1 TYPE cdtabkey.

      CONCATENATE sy-mandt ts_vbap-vbeln ts_vbap-posnr INTO lv_table_key.
      CONCATENATE '   ' ts_vbap-vbeln ts_vbap-posnr INTO lv_table_key1 RESPECTING BLANKS .
      READ TABLE it_cdpos INTO DATA(ls_cdpos)
        WITH KEY tabkey = lv_table_key
                 fname = 'ABGRU'.
      IF sy-subrc = 0.
        ts_alv-reject_user = ls_cdpos-username.
        ts_alv-reject_date = ls_cdpos-udate.
      ELSE.
        READ TABLE it_cdpos INTO ls_cdpos
          WITH KEY tabkey = lv_table_key1
                   fname = 'ABGRU'.
        IF sy-subrc = 0.
          ts_alv-reject_user = ls_cdpos-username.
          ts_alv-reject_date = ls_cdpos-udate.
        ENDIF.
      ENDIF.

      READ TABLE it_cdpos INTO ls_cdpos
        WITH KEY tabkey = lv_table_key
           fname = 'ZALLOWED_DISC'.
      IF sy-subrc = 0.
        ts_alv-disc_user = ls_cdpos-username.
      ELSE.
        READ TABLE it_cdpos INTO ls_cdpos
          WITH KEY tabkey = lv_table_key1
             fname = 'ZALLOWED_DISC'.
        IF sy-subrc = 0.
          ts_alv-disc_user = ls_cdpos-username.
        ENDIF.
      ENDIF.

      READ TABLE it_cdpos INTO ls_cdpos
        WITH KEY tabkey = lv_table_key
           fname = 'NETPR'.
      IF sy-subrc = 0.
        ts_alv-manual_user = ls_cdpos-username.
      ELSE.
        READ TABLE it_cdpos INTO ls_cdpos
         WITH KEY tabkey = lv_table_key1
            fname = 'NETPR'.
        IF sy-subrc = 0.
          ts_alv-manual_user = ls_cdpos-username.
        ENDIF.
      ENDIF.
*        READ TABLE it_qty_amount INTO ts_qty_amount WITH KEY vbeln = ts_vbak-vbeln BINARY SEARCH.
*        IF sy-subrc = 0.
      ts_alv-spare_qty = ts_vbap-zmeng.
      ts_alv-spare_amount = ts_vbap-netwr.
      ts_alv-descr1 = ts_vbap-descr1.
*        ENDIF.
*      ELSEIF  s_odr_tp IS NOT INITIAL OR s_it_cat IS NOT INITIAL
*        OR s_mtrl IS NOT INITIAL OR s_prm IS NOT INITIAL OR  s_c_a_id IS NOT INITIAL.
*        CONTINUE.
*      ENDIF.
      ts_alv-netwr = ts_vbap-netwr.

*..<< Fill Billing details >>
      IF p_rvrp = abap_true OR p_rv_bc = abap_true.
        READ TABLE it_billing INTO ls_billing
          WITH KEY dbm_vbeln = ts_vbap-vbeln
                   dbm_item = ts_vbap-posnr.
        IF sy-subrc = 0.
          ts_alv-invoice_no = ls_billing-vbeln.
          ts_alv-bill_ord_reas = ls_billing-augru_auft.
          READ TABLE it_tvaut INTO DATA(ls_tvaut)
            WITH KEY augru = ls_billing-augru_auft.
          IF sy-subrc = 0.
            ts_alv-bill_ord_reas_t = ls_tvaut-bezei.
          ENDIF.
          ts_alv-ktgrm = ls_billing-ktgrm.
          READ TABLE it_aag INTO DATA(ls_aag)
            WITH KEY ktgrm = ls_billing-ktgrm.
          IF sy-subrc = 0.
            ts_alv-ktgrm_t = ls_aag-vtext.
          ENDIF.
*          ts_alv-fkdat = ls_billing-fkdat.
          DATA: lw_vbrkt TYPE ty_vbrkt.
          DATA: lv_sign TYPE kwert.
          lv_sign = 1.
          READ TABLE it_vbrkt INTO lw_vbrkt WITH KEY vbeln = ls_billing-vbeln BINARY SEARCH.
          IF sy-subrc = 0.
            IF lw_vbrkt-vbtyp = 'O' OR lw_vbrkt-vbtyp = 'H'.
              lv_sign = -1.
            ENDIF.
            ts_alv-vtweg = lw_vbrkt-vtweg.
*            ts_alv-fkdat = lw_vbrkt-fkdat.
            CONCATENATE lw_vbrkt-fkdat+6(2) '-' lw_vbrkt-fkdat+4(2) '-' lw_vbrkt-fkdat+0(4) INTO ts_alv-fkdat.
            CONCATENATE lw_vbrkt-fkdat+0(4) lw_vbrkt-fkdat+4(2) INTO ts_alv-fkmon.
          ENDIF.


*..<< Filling Price Details >>
          READ TABLE it_item_price INTO ls_item_price
            WITH KEY vbeln = ls_billing-vbeln posnr = ls_billing-posnr
            BINARY SEARCH.
          IF sy-subrc = 0.
            ts_alv-unit_price = ls_item_price-unit_price * lv_sign.
            ts_alv-head_disc = ls_item_price-head_disc * lv_sign.
            ts_alv-head_disc_perc = ls_item_price-head_disc_perc * lv_sign.
            ts_alv-item_disc = ls_item_price-item_disc * lv_sign.
            ts_alv-item_disc_perc = ls_item_price-item_disc_perc * lv_sign.
            ts_alv-cg_discount = ls_item_price-cg_discount * lv_sign.
            ts_alv-head_surch = ls_item_price-head_surch * lv_sign.
            ts_alv-item_surch = ls_item_price-item_surch * lv_sign.
            ts_alv-vat = ls_item_price-vat * lv_sign.
            ts_alv-gross_value = ls_item_price-gross_value * lv_sign.
            ts_alv-cost = ls_item_price-cost * lv_sign.
*            ts_alv-profit_margin = ( ts_alv-gross_value - ts_alv-vat ) - ts_alv-cost .
            ts_alv-profit_margin = ts_vbap-kzwi5 * lv_sign.           "profit margin changes.
            ts_alv-vbeln = ts_vbak-vbeln.
            ts_alv-posnr = ts_vbap-posnr.
            ts_alv-manual_price = ts_vbap-manual_price * lv_sign. "05/12/2024
*            Sum = manual price * order Quantity + VAT
*            ts_alv-total_price = ts_alv-manual_price * ts_alv-quantity.
*            ts_alv-sum = ts_alv-manual_price * ts_alv-quantity + ts_alv-vat.
*            ---.
          ENDIF.
        ENDIF.

        CALL FUNCTION 'ZVSS_FI_DOC_STATUS_FM'
          EXPORTING
            iv_billing_no = ls_billing-vbeln    " Sales and Distribution Document Number
*           iv_logsys     = ls_billing-logsys    " Logical System
            iv_bukrs      = ts_vbak-bukrs_vf  "gv_bukrs    " Company Code
*           iv_gjahr      = ls_billing-gjahr    " Fiscal Year
            iv_fkdat      = lw_vbrkt-fkdat  "ls_billing-fkdat    " Billing Date for Billing Index and Printout
          IMPORTING
            ev_cleared    = lv_paid.

        IF lv_paid = abap_true.
          ts_alv-invoice_cleared = 'Yes'.
        ELSE.
          ts_alv-invoice_cleared = 'No'.
        ENDIF.

      ELSE.
*..<< Filling Price Details >>
        READ TABLE it_item_price INTO ls_item_price
          WITH KEY vbeln = ts_vbap-vbeln posnr = ts_vbap-posnr
          BINARY SEARCH.
        IF sy-subrc = 0.
          lv_sign = 1.
          READ TABLE lt_order_type INTO DATA(ls_order_type)
            WITH KEY aufart = ts_vbap-aufart.
          IF sy-subrc = 0
            AND ( ls_order_type-vbtyp = 'H' OR ls_order_type-vbtyp = 'O' ).
            lv_sign = -1.
          ENDIF.
          ls_item_price-unit_price     = ls_item_price-unit_price     * lv_sign.
          ls_item_price-head_disc      = ls_item_price-head_disc      * lv_sign.
          ls_item_price-head_disc_perc = ls_item_price-head_disc_perc * lv_sign.
          ls_item_price-item_disc      = ls_item_price-item_disc      * lv_sign.
          ls_item_price-item_disc_perc = ls_item_price-item_disc_perc * lv_sign.
          ls_item_price-cg_discount    = ls_item_price-cg_discount    * lv_sign.
          ls_item_price-head_surch     = ls_item_price-head_surch     * lv_sign.
          ls_item_price-item_surch     = ls_item_price-item_surch     * lv_sign.
          ls_item_price-vat            = ls_item_price-vat            * lv_sign.
          ls_item_price-gross_value    = ls_item_price-gross_value    * lv_sign.
          ls_item_price-cost           = ls_item_price-cost           * lv_sign.

          MOVE-CORRESPONDING ls_item_price TO ts_alv.
*          ts_alv-profit_margin = ( ts_alv-gross_value - ts_alv-vat ) - ts_alv-cost .
          ts_alv-profit_margin = ts_vbap-kzwi5 * lv_sign.           "profit margin changes.

**          changes 05/12/2024 start.

          ts_alv-manual_price = ts_vbap-manual_price * lv_sign. "05/12/2024
**          changes 05/12/2024 end.


        ENDIF.
      ENDIF.
**---
      READ TABLE it_vlcvehicle INTO DATA(ls_vlcvehicle)
      WITH KEY vguid = ts_vbak-vguid.
      IF sy-subrc EQ 0.
        ts_alv-vhvin = ls_vlcvehicle-vhvin.
      ELSE.
        READ TABLE it_vbpa INTO DATA(ls_vbpa) WITH KEY vbeln = ts_vbak-vbeln.
        IF sy-subrc EQ 0.
          READ TABLE it_adrct INTO DATA(ls_adrct) WITH KEY addrnumber = ls_vbpa-adrnr .
          IF sy-subrc EQ 0.
            ts_alv-vhvin = ls_adrct-remark.
          ENDIF.
        ENDIF.
      ENDIF.
**---
*           Sum = manual price * order Quantity + VAT
      CLEAR: lv_vat,lv_man_price.
      ts_alv-total_price = ts_alv-manual_price * ts_alv-quantity.
      lv_vat = ts_alv-vat * lv_sign.  "converting negative value to positive.
      lv_man_price = ts_alv-manual_price * lv_sign.                                       "converting negative value to positive.
      ts_alv-sum = ( lv_man_price * ts_alv-quantity + lv_vat ) * lv_sign. "calculation of Sum value.
*      ts_alv-sum = ( ( ts_alv-manual_price * ts_alv-quantity ) + ( ts_alv-vat * lv_sign ) * lv_sign ). "calculation of Sum value.
*            ---.
      APPEND ts_alv TO it_alv.
      CLEAR:ts_aufart,
            ts_pernr,
            ts_centraldataperson,
            lv_zuonr.
    ENDLOOP.
    CLEAR ts_alv.
  ENDLOOP.

  CLEAR : ts_vbak,
        ts_vbap.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_display .
  DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
         wa_layout   TYPE slis_layout_alv,
         it_menu     TYPE slis_t_extab,
         it_events   TYPE slis_t_event,
         ls_events   TYPE slis_alv_event,
         it_sort     TYPE slis_t_sortinfo_alv,
         lv_title    TYPE lvc_title,
         ls_variant  TYPE disvariant.

  wa_layout-colwidth_optimize = abap_true.
  wa_layout-box_fieldname = 'FLAG'.

  "fill field catalog and Sort tables
*  IF p_oso = abap_true.
  PERFORM f_fill_fcat_and_sort_oso CHANGING it_fieldcat it_sort.
*  ELSEIF p_del = abap_true OR p_cso = abap_true.
*    PERFORM f_fill_fcat_and_sort_oso CHANGING it_fieldcat it_sort.
*  ELSE.
*    PERFORM f_fill_fcat_and_sort_othr_rpts CHANGING it_fieldcat it_sort.
*  ENDIF.

  ls_variant-report = sy-repid.
  IF p_oso = abap_true.
    lv_title = 'Open Sales Orders'.
    ls_variant-handle = '0001'.
  ELSEIF p_del = abap_true.
    lv_title = 'Delivery Created not Billed'.
    ls_variant-handle = '0002'.
  ELSEIF p_rvrp = abap_true.
    lv_title = 'Revenue (OTC)'.
    ls_variant-handle = '0003'.
  ELSEIF p_rv_bc = abap_true.
    lv_title = 'Revenue ( Service Channel)'.
    ls_variant-handle = '0004'.
  ELSEIF p_lost = abap_true.
    lv_title = 'Lost Sales'.
    ls_variant-handle = '0005'.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_pf_status_set = 'SET_STATUS'
      i_grid_title             = lv_title
      it_fieldcat              = it_fieldcat
      is_layout                = wa_layout
*     it_excluding             = it_menu
      it_sort                  = it_sort
      it_events                = it_events
      i_save                   = 'X'
      is_variant               = ls_variant
    TABLES
      t_outtab                 = it_alv
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FCAT_AND_SORT_OSO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_IT_FIELDCAT  text
*      <--P_IT_SORT  text
*----------------------------------------------------------------------*
FORM f_fill_fcat_and_sort_oso  CHANGING ct_fieldcat TYPE slis_t_fieldcat_alv
                                             ct_sort     TYPE slis_t_sortinfo_alv.

  DATA: ts_fcat TYPE slis_fieldcat_alv,
        ts_sort TYPE slis_sortinfo_alv.

  DEFINE m_cat ##NEEDED.
    ts_fcat-fieldname   = &1.
    ts_fcat-tabname     = &2.
    ts_fcat-seltext_l   = &3.
*   ts_fcat-outputlen   = &4.
    ts_fcat-do_sum =   &4.
    ts_fcat-no_out = &5.
    ts_fcat-emphasize = &6.
    ts_fcat-col_pos = &7.
    IF ts_fcat-fieldname = 'VBELN' OR
      ts_fcat-fieldname = 'WERKS' OR
        ts_fcat-fieldname = 'VKORG' OR
        ts_fcat-fieldname = 'VTWEG' OR
        ts_fcat-fieldname = 'SPART' OR
        ts_fcat-fieldname = 'SPLNR' OR
        ts_fcat-fieldname = 'POSNR' OR
        ts_fcat-fieldname = 'STATUS_ICON'.

        ts_fcat-fix_column = abap_true.
        ts_fcat-key = abap_true.
        ts_fcat-emphasize = 'C400'.
      ELSEIF ts_fcat-fieldname = 'FLAG'.
          ts_fcat-edit = abap_true.
          ts_fcat-no_out = abap_true.
      ENDIF.

      IF ts_fcat-fieldname = 'VBELN'
        OR ts_fcat-fieldname = 'INVOICE_NO'.
        ts_fcat-hotspot = abap_true.
      ENDIF.

    APPEND ts_fcat TO ct_fieldcat.
    CLEAR ts_fcat.
  END-OF-DEFINITION.

  "       Field           Tabname    Desc               Do_sum       No_Out       Emphasis  Position
  m_cat   'STATUS_ICON'        'it_alv'   'Status'           abap_false   abap_false     ' '     '1'       .    "status icon
  m_cat   'VBELN'        'it_alv'   TEXT-h01           abap_false   abap_false     ' '     '1'       .    "vbeln
  m_cat   'POSNR'        'it_alv'   'Item No'          abap_false   abap_false     ' '     '1'       .    "posnr
  m_cat   'WERKS'        'it_alv'   TEXT-h13           abap_false   abap_false     ' '     '2'       .
  m_cat   'VKORG'       'it_alv'   TEXT-h14           abap_false   abap_false     ' '     '3'       .
*  m_cat   TEXT-d25        'it_alv'   TEXT-h25           abap_false   abap_false     ' '     '4'       .
  m_cat   'SPART'        'it_alv'   TEXT-h15           abap_false   abap_false     ' '     '5'       .
*  m_cat   'SPLNR'         'it_alv'   'Split No.'         abap_false   abap_false    ' '     '5'       .
  m_cat   'HSTAT'        'it_alv'   TEXT-h16           abap_false   abap_false     ' '     '6'       .
  m_cat   'STATUS'        'IT_ALV'   'Status'           abap_false   abap_false     ' '     '7'       .
  m_cat   'AUFART'        'it_alv'   'Document Type'    abap_false abap_false '' '7'.
  m_cat   'AUGRU'        'it_alv'   'Order Reason'    abap_false abap_false '' '7'.
*  m_cat   TEXT-d17        'it_alv'   TEXT-h17           abap_false   abap_false     ' '     '7'       .
*  m_cat   TEXT-d18        'it_alv'   TEXT-h18           abap_false    abap_false    ' '     '8'       .
*  m_cat   TEXT-d19        'it_alv'   TEXT-h19           abap_false   abap_false     ' '     '9'.
  m_cat   'ZTERM'          'it_alv'   'Payment Term'     abap_false    abap_false    ' '     '8'.
  m_cat   'ZTERM_TXT'      'it_alv'   'Desc. of Payterm'     abap_false    abap_false    ' '     '9'.
  m_cat   'MATNR40'        'it_alv'   TEXT-h20           abap_false    abap_false    ' '     '10'.
  m_cat   'DESCR1'        'it_alv'   'Mat. Description'           abap_false    abap_false    ' '     '10'.
  m_cat   'QUANTITY'        'it_alv'   'Quantity'           abap_false    abap_false    ' '     '10'.
*  m_cat   TEXT-d21        'it_alv'   TEXT-h21           abap_false   abap_false     ' '     '11'.
*  m_cat   TEXT-d22        'it_alv'   TEXT-h22           abap_false   abap_false     ' '     '12'      .
*  m_cat   TEXT-d23        'it_alv'   TEXT-h23           abap_false   abap_false     ' '     '13'.
*  m_cat   TEXT-d24        'it_alv'   TEXT-h24           abap_false   abap_false     ' '     '14'.
  m_cat   TEXT-d02        'it_alv'   TEXT-h02           abap_false   abap_false     ' '     '15'      .
  m_cat   TEXT-d03        'it_alv'   TEXT-h03           abap_false   abap_false     ' '     '16'      .
  m_cat   'CUSTOMER_GROUP'        'it_alv'    'Customer Group'           abap_false   abap_false     ' '     '17'      .
  m_cat   'ANGE_USER'        'it_alv'    'Accepted by'           abap_false   abap_false     ' '     '17'      .
  m_cat   'ANGE_NAME'        'it_alv'    'Accepted by(Name)'           abap_false   abap_false     ' '     '17'      .
*  m_cat   TEXT-d34        'it_alv'   TEXT-h34           abap_false   abap_false     ' '     '17'      .
*  m_cat   TEXT-d35        'it_alv'   TEXT-h35           abap_false   abap_false     ' '     '18'      .
*  m_cat   TEXT-d36        'it_alv'   TEXT-h36           abap_true    abap_false     ' '     '19'      .
*  m_cat   TEXT-d37        'it_alv'   TEXT-h37           abap_false   abap_false     ' '     '20'      .
*  m_cat   TEXT-d38        'it_alv'   TEXT-h38           abap_true    abap_false     ' '     '21'      .
*  m_cat   TEXT-d07        'it_alv'   TEXT-h07           abap_false   abap_false     ' '     '22'      .
*  m_cat   'NETWR'         'it_alv'   'Net value'        abap_true    abap_false     ' '     '23'      .
*  m_cat   TEXT-d08        'it_alv'   TEXT-h08           abap_true    abap_false     ' '     '24'      .
  m_cat   TEXT-d09        'it_alv'   TEXT-h09           abap_false   abap_false     ' '     '25'      .
*  m_cat   TEXT-d39        'it_alv'   TEXT-h39           abap_false   abap_false     ' '     '26'      .
*  m_cat   TEXT-d10        'it_alv'   TEXT-h10           abap_false   abap_false     ' '     '30'      .
  m_cat   TEXT-d11        'it_alv'   TEXT-h11           abap_false   abap_true      ' '     '33'      .
  m_cat   'VTWEG'        'it_alv'   TEXT-h43           abap_false   abap_false     ' '     '34'       .
*------------------------VHVIN- Start--------------*
  m_cat   'VHVIN'        'it_alv'   'VIN number'           abap_false   abap_false     ' '     '1'       .
*------------------------VHVIN- End--------------*

  IF p_rvrp = abap_true OR p_rv_bc = abap_true.
    m_cat   'INVOICE_NO'      'it_alv'   'Invoice No.'                 abap_false   abap_false     ' '     '30'      .
    m_cat   'INVOICE_CLEARED'      'it_alv'   'Invoice Cleared'                 abap_false   abap_false     ' '     '30'      .
    m_cat   'FKDAT'      'it_alv'   'Invoice date'                 abap_false   abap_false     ' '     '30'      .
    m_cat   'FKMON'      'it_alv'   'Invoice Month'                 abap_false   abap_false     ' '     '30'      .
    m_cat   'BILL_ORD_REAS'      'it_alv'   'Inv. Ord Reasn'                 abap_false   abap_false     ' '     '30'      .
    m_cat   'BILL_ORD_REAS_T'      'it_alv'   'Inv. Reasn Text'                 abap_false   abap_false     ' '     '30'      .
    m_cat   'KTGRM'      'it_alv'   'AAG'                 abap_false   abap_false     ' '     '30'      .
    m_cat   'KTGRM_T'      'it_alv'   'AAG Text'                 abap_false   abap_false     ' '     '30'      .

  ELSEIF p_lost <> abap_true.
    m_cat   'DELIV_QTY'        'it_alv'   'Delivered Qty'           abap_false   abap_false     ' '     '30'      .
    m_cat   'OPEN_QTY'        'it_alv'   'Open Qty'           abap_false   abap_false     ' '     '30'      .
  ENDIF.
  m_cat   'DEL_ITM'  'it_alv'  'Delete Order Item'      abap_false   abap_false     ' '     '30'      .
  m_cat   'REJ_ITM'  'it_alv'  'Rej. Item'      abap_false   abap_false     ' '     '30'      .
  m_cat   'REJ_ITMT' 'it_alv'  'Rej. Item text'      abap_false   abap_false     ' '     '30'      .
  m_cat   'MVGR1' 'it_alv'  'Mat Grp 1'      abap_false   abap_false     ' '     '30'      .
  m_cat   'MVGR2' 'it_alv'  'Mat Grp 2'      abap_false   abap_false     ' '     '30'      .
  m_cat   'MVGR3' 'it_alv'  'Mat Grp 3'      abap_false   abap_false     ' '     '30'      .
  m_cat   'MVGR4' 'it_alv'  'Mat Grp 4'      abap_false   abap_false     ' '     '30'      .
  m_cat   'MVGR5' 'it_alv'  'Mat Grp 5'      abap_false   abap_false     ' '     '30'      .
*    IF p_dwell = abap_true.
*      m_cat   TEXT-d12        'it_alv'   TEXT-h12           abap_false   abap_false     ' '     '26'.
*    ENDIF.
*    IF p_v_tp = abap_true.
*      m_cat   TEXT-d26        'it_alv'   TEXT-h26           abap_false   abap_false     ' '     '254'.
*  m_cat   TEXT-d27        'it_alv'   TEXT-h27           abap_false   abap_false     ' '     '27'      .
*  m_cat   TEXT-d28        'it_alv'   TEXT-h28           abap_false   abap_false     ' '     '28'      .
*  m_cat   TEXT-d29        'it_alv'   TEXT-h29           abap_false   abap_false     ' '     '29'      .
  m_cat   'UNIT_PRICE'      'it_alv'   'Unit Price'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'HEAD_DISC'      'it_alv'   'Header Discount'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'HEAD_DISC_PERC'      'it_alv'   'Header Discount %'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'ITEM_DISC'      'it_alv'   'Item Discount'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'ITEM_DISC_PERC'      'it_alv'   'Item Discount %'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'CG_DISCOUNT'      'it_alv'   'Customer Grp Disc.'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'HEAD_SURCH'      'it_alv'   'Header Surcharge'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'ITEM_SURCH'      'it_alv'   'Item Surchage'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'VAT'      'it_alv'   'VAT'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'GROSS_VALUE'      'it_alv'   'Gross Value'                 abap_false   abap_false     ' '     '30'      .
  m_cat   'COST'      'it_alv'   'Cost'                 abap_false   abap_false     ' '     '30'      .
*------Sum--
  m_cat   'TOTAL_PRICE'      'it_alv'   'Total Price'                 abap_false   abap_false     ' '     '30'   .
  m_cat   'SUM'      'it_alv'   'Sum(Total Price + VAT)'                 abap_false   abap_false     ' '     '30'   .
*------Sum--
  m_cat   'PROFIT_MARGIN'      'it_alv'   'Profit Margin'                 abap_false   abap_false     ' '     '30'      .
  m_cat   TEXT-d40        'it_alv'   TEXT-h40           abap_false   abap_false     ' '     '31'      .
  m_cat   TEXT-d41        'it_alv'   TEXT-h41           abap_false   abap_false     ' '     '32'      .
*  m_cat   'REJECT'      'it_alv'   'Reject'                 abap_false   abap_false     ' '     '33'      .
  m_cat   'ZALLOWED_DISC'      'it_alv'   'Allowed Discount'                 abap_false   abap_false     ' '     '33'      .
  m_cat   'MANUAL_PRICE'      'it_alv'   'Manual Price'                 abap_false   abap_false     ' '     '33'      .
  m_cat   'REJECT_USER'      'it_alv'   'Rejected User'                 abap_false   abap_false     ' '     '33'      .
  m_cat   'REJECT_DATE'      'it_alv'   'Rejected Date'                 abap_false   abap_false     ' '     '33'      .
  m_cat   'DISC_USER'      'it_alv'   'Discount User'                 abap_false   abap_false     ' '     '33'      .
  m_cat   'MANUAL_USER'      'it_alv'   'Manual Price User'                 abap_false   abap_false     ' '     '33'      .

*  m_cat   TEXT-d43        'it_alv'   ''                 abap_false   abap_false     ' '     '34'      .
*    ENDIF.
*    IF p_dc = abap_true.
*      m_cat   TEXT-d32        'it_alv'   TEXT-h32           abap_false   abap_false     ' '     '27'.
*      m_cat   TEXT-d33        'it_alv'   TEXT-h33           abap_false   abap_false     ' '     '28'.
*    ENDIF.

  ts_sort-fieldname = TEXT-d11.
  ts_sort-subtot = abap_true.
  ts_sort-up = abap_true.
  APPEND ts_sort TO ct_sort.

ENDFORM.

FORM user_command USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.
  DATA: ls_vbak TYPE /dbe/vbak_db,
        ls_mara TYPE mara,
        lv_vbrk TYPE vbeln.

  IF rs_selfield-fieldname = 'VBELN'.
    SELECT SINGLE * FROM /dbe/vbak_db INTO ls_vbak WHERE vbeln = rs_selfield-value.
      IF sy-subrc = 0.
        SET PARAMETER ID '/DBE/ORDER_NUMBER' FIELD rs_selfield-value.
        CALL TRANSACTION '/DBE/ORDER03' AND SKIP FIRST SCREEN.
      ENDIF.
    ELSEIF rs_selfield-fieldname = 'MATNR40'.
      SELECT SINGLE * FROM mara INTO ls_mara WHERE matnr = rs_selfield-value.
        IF sy-subrc = 0.
          SET PARAMETER ID 'MAT' FIELD rs_selfield-value.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
        ENDIF.
      ELSEIF rs_selfield-fieldname = 'INVOICE_NO'.
        SELECT SINGLE vbeln FROM vbrk INTO lv_vbrk WHERE vbeln = rs_selfield-value.
          IF sy-subrc = 0.
            SET PARAMETER ID 'VF' FIELD rs_selfield-value.
            CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
          ENDIF.
        ELSEIF r_ucomm = 'DETAIL'.
          PERFORM button_event.
        ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUTTON_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM button_event .
  DATA: lt_bdcdata TYPE TABLE OF bdcdata,
        lt_vbeln   TYPE RANGE OF vbeln,
        lt_vbap    TYPE TABLE OF /dbe/vbap,
        lt_fcat    TYPE TABLE OF slis_fieldcat_alv,
        ls_alv     LIKE LINE OF it_alv,
        ls_fcat    TYPE slis_fieldcat_alv,
        lv_vbeln   LIKE LINE OF lt_vbeln.
*   break tech5.
  IF it_alv IS NOT INITIAL.
    LOOP AT it_alv INTO ls_alv WHERE flag = abap_true.
      lv_vbeln-low = ls_alv-vbeln.
      APPEND lv_vbeln TO lt_vbeln.
    ENDLOOP.

    SELECT * FROM /dbe/vbap INTO TABLE lt_vbap FOR ALL ENTRIES IN lt_vbeln WHERE vbeln = lt_vbeln-low.
      IF sy-subrc = 0.

        DEFINE m_cat ##NEEDED.
          ls_fcat-fieldname   = &1.
          ls_fcat-tabname     = &2.
          ls_fcat-seltext_l   = &3.
          ls_fcat-do_sum      = &4.
          ls_fcat-no_out      = &5.
          ls_fcat-emphasize   = &6.
          ls_fcat-col_pos     = &7.
          ls_fcat-emphasize   = &8.
          ls_fcat-key         = &8.
          ls_fcat-fix_column  = &8.

          IF &1 = 'VBELN' OR &1 = 'MATNR40'.
            ls_fcat-hotspot = abap_true.
          ENDIF.

          APPEND ls_fcat TO lt_fcat.
          CLEAR ls_fcat.
        END-OF-DEFINITION.
        "            field     table     seltext          do sum      no out      emphasize   column     Key
        m_cat 'VBELN'    'LT_VBAP' 'Sales order number'   abap_false  abap_false  abap_false  '1'        abap_true  .
        m_cat 'POSNR'    'LT_VBAP' 'Item number'          abap_false  abap_false  abap_false  '2'        abap_true  .
        m_cat 'ITCAT'    'LT_VBAP' 'Item category'        abap_false  abap_false  abap_false  '3'        abap_false .
        m_cat 'MATNR40'  'LT_VBAP' 'Material number'      abap_false  abap_false  abap_false  '4'        abap_false .
        m_cat 'ARKTX'    'LT_VBAP' 'Description'          abap_false  abap_false  abap_false  '5'        abap_false .
        m_cat 'WERKS'    'LT_VBAP' 'Plant'                abap_false  abap_false  abap_false  '6'        abap_false .
        m_cat 'LGORT'    'LT_VBAP' 'Storage Loc.'         abap_false  abap_false  abap_false  '7'        abap_false .
        m_cat 'MATKL'    'LT_VBAP' 'Material Group'       abap_false  abap_false  abap_false  '8'        abap_false .
        m_cat 'MATNR18'  'LT_VBAP' 'Pricing Reference'    abap_false  abap_false  abap_false  '9'        abap_false .
        m_cat 'LABVAL'   'LT_VBAP' 'Labour value'         abap_false  abap_false  abap_false  '10'       abap_false .
        m_cat 'SPART'    'LT_VBAP' 'Division'             abap_false  abap_false  abap_false  '11'       abap_false .
        m_cat 'BRGEW'    'LT_VBAP' 'Gross weight'         abap_false  abap_false  abap_false  '12'       abap_false .
        m_cat 'NTGEW'    'LT_VBAP' 'Net weight'           abap_false  abap_false  abap_false  '13'       abap_false .
        m_cat 'GEWEI'    'LT_VBAP' 'Weight Unit'          abap_false  abap_false  abap_false  '14'       abap_false .
        m_cat 'ERDAT'    'LT_VBAP' 'Record Created'       abap_false  abap_false  abap_false  '15'       abap_false .
        m_cat 'ERNAM'    'LT_VBAP' 'Ceated By'            abap_false  abap_false  abap_false  '16'       abap_false .
        m_cat 'NETPR'    'LT_VBAP' 'Item Price'           abap_false  abap_false  abap_false  '17'       abap_false .
        m_cat 'ZMENG'    'LT_VBAP' 'Order Quantity'       abap_false  abap_false  abap_false  '18'       abap_false .
        m_cat 'DIFFTAX'  'LT_VBAP' 'Margin taxation'      abap_false  abap_false  abap_false  '19'       abap_false .
        m_cat 'NETWR'    'LT_VBAP' 'Net Cost'             abap_true   abap_false  abap_false  '20'       abap_false .
        m_cat 'VTWEG'    'LT_VBAP' 'Distribution Channel' abap_true   abap_false  abap_false  '21'       abap_false .

        DELETE ADJACENT DUPLICATES FROM lt_vbap COMPARING vbeln posnr.

        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
            i_callback_program      = sy-repid
            i_callback_user_command = 'USER_COMMAND'
            i_grid_title            = 'Item details '
            it_fieldcat             = lt_fcat
          TABLES
            t_outtab                = lt_vbap.
      ENDIF.
    ENDIF.
ENDFORM.
FORM set_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTATUS'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_email .
***cmn decl
  CONSTANTS:
    lc_htm      TYPE char3   VALUE 'HTM',
    lc_new_line TYPE char255 VALUE '<br>',
    lc_tab      TYPE c VALUE cl_bcs_convert=>gc_tab,
    lc_crlf     TYPE c VALUE cl_bcs_convert=>gc_crlf.

  DATA: lt_contents       TYPE STANDARD TABLE OF solisti1,
        lw_contents       TYPE solisti1,
        w_document        TYPE REF TO cl_document_bcs,
        l_send_request    TYPE REF TO cl_bcs,
        l_document        TYPE REF TO cl_document_bcs,
        l_sender          TYPE REF TO cl_sapuser_bcs,
        l_recipient       TYPE REF TO if_recipient_bcs,
        l_bcs_exception   TYPE REF TO cx_bcs,
        tl_contents       TYPE STANDARD TABLE OF soli,
        l_doc_len         TYPE so_obj_len,
        l_cnt             TYPE sy-tabix,
        l_rcv_email       TYPE adr6-smtp_addr VALUE 'YMULTIPROGRAM@EAJB.COM.SA',
        l_result          TYPE sy-binpt,
        lv_mail_subj      TYPE string,
        l_sub             TYPE so_obj_des,
        l_subj            TYPE string,
        lv_string         TYPE string,
        lt_binary_content TYPE solix_tab,
        lv_size           TYPE so_obj_len,
        l_attsub          TYPE so_obj_des,
        l_att_type        TYPE soodk-objtp,
        i_copy            TYPE c,
        lv_title_type     TYPE string.

  DATA: lv_netwr TYPE c LENGTH 15.
***  end

  CASE 'X'.
    WHEN p_oso.
      lv_title_type = 'Open Orders OTC'.
    WHEN p_rvrp.
      lv_title_type = 'Revenue Report OTC'.
    WHEN p_rv_bc.
      lv_title_type = 'Revenue Rpt Service Channel'.
    WHEN p_del.
      lv_title_type = 'Delviered but not billed'.
    WHEN p_lost.
      lv_title_type = 'Lost Sales'.
  ENDCASE.
  TRY.
      CONCATENATE 'Dear Sir/Madam,' lc_new_line lc_new_line INTO lw_contents-line.
      APPEND lw_contents TO lt_contents.
      CONCATENATE 'Please find the output of YPSALESN report attached with this email' lc_new_line lc_new_line INTO lw_contents-line.
      APPEND lw_contents TO lt_contents.
      CONCATENATE 'Best Regards,' lc_new_line INTO lw_contents-line.
      APPEND lw_contents TO lt_contents.
      CONCATENATE 'JISC' lc_new_line INTO lw_contents-line.
      APPEND lw_contents TO lt_contents.
*-- Subject of the Mail
      CONCATENATE lv_title_type ' : ' sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4)
        INTO lv_mail_subj RESPECTING BLANKS.

*-- Get the length of the Document
      DESCRIBE TABLE tl_contents LINES l_cnt.
      READ TABLE tl_contents INTO lw_contents INDEX l_cnt.
      l_doc_len = ( l_cnt - 1 ) * 255 + strlen( lw_contents ).
*-- Subject of the mail
      l_sub = lv_mail_subj.

*-- Create persistent send request
      l_send_request = cl_bcs=>create_persistent( ).
      tl_contents[] = lt_contents[].

*-- Get the length of the Document
      DESCRIBE TABLE tl_contents LINES l_cnt.
      READ TABLE tl_contents INTO lw_contents INDEX l_cnt.
      l_doc_len = ( l_cnt - 1 ) * 255 + strlen( lw_contents ).
*-- Subject of the mail
      l_sub = lv_mail_subj.

*-- Create Document
      l_document = cl_document_bcs=>create_document(
                   i_type       = lc_htm
                   i_text       = tl_contents
                   i_length     = l_doc_len
                   i_subject    = l_sub
                   i_language   = sy-langu
                   i_importance = '1' ).
      w_document = l_document.

      TRY.
*-- Set the Message Subject
          CALL METHOD l_send_request->set_message_subject
            EXPORTING
              ip_subject = lv_mail_subj. "l_subj.
        CATCH cx_sy_dyn_call_illegal_method.
      ENDTRY.

*-- Add document to send request
      CALL METHOD l_send_request->set_document( l_document ).

*-- Do send delivery info for successful mails
      CALL METHOD l_send_request->set_status_attributes
        EXPORTING
          i_requested_status = 'E'
          i_status_mail      = 'A'.

*-- Set sender
      l_sender = cl_sapuser_bcs=>create( sy-uname ).
      CALL METHOD l_send_request->set_sender
        EXPORTING
          i_sender = l_sender.
****  column names
      CONCATENATE
      ''
*        'Status'
        'Sales Order No.'
        'Item No'
        'Plant'
        'Sales Organisation'
        'Division'
        'Order Status'
        'Status'
        'Payment Term'
        'Desc. of Payterm'
        'Material'
        'Mat. Description'
        'Quantity'
        'Accepted Date'
        'Customer Name'
        'Customer Group'
        'Customer Advisor'
        INTO lv_string SEPARATED BY lc_tab.
      IF p_rv_bc = 'X' OR p_rvrp = 'X'.
        CONCATENATE lv_string
          'Invoice No.'
          'Invoice Cleared'
          'Invoice date'
          'Inv. Ord Reasn'
          'Inv. Reasn text'
          'AAG'
          'AAG text'
        INTO lv_string SEPARATED BY lc_tab.
      ELSE.
        CONCATENATE lv_string
          'Delivered Qty'
          'Open Qty'
          INTO lv_string SEPARATED BY lc_tab.
      ENDIF.
      CONCATENATE lv_string
        'Delete Order Item'
        'Rej. Item'
        'Rej. Item text'
        'Unit Price'
        'Header Discount'
        'Header Discount %'
        'Item Discount'
        'Item Discount %'
        'Customer Grp Disc.'
        'Header Surcharge'
        'Item Surchage'
        'VAT'
        'Gross Value'
        'Cost'
        'Profit Margin'
        'Number of Days'
        'Range'
        'Accepted by'
        'Accepted by(Name)'
        'Mat Grp 1'
        'Mat Grp 2'
        'Mat Grp 3'
        'Mat Grp 4'
        'Mat Grp 5'
      INTO lv_string SEPARATED BY lc_tab.
      CONCATENATE lv_string lc_crlf INTO lv_string.

      DATA: wa TYPE ty_alv_str.
*-- Converting file to binary
      LOOP AT it_alv INTO DATA(ls_alv).
        MOVE-CORRESPONDING ls_alv TO wa.
        CONCATENATE
         lv_string
*           wa-status_icon
           wa-vbeln
           wa-posnr
           wa-werks
           wa-vkorg
           wa-spart
           wa-hstat
           wa-status
           wa-zterm
           wa-zterm_txt
           wa-matnr40
           wa-descr1
           wa-quantity
           wa-accept_date
           wa-customer_name
           wa-customer_group
           wa-service_advisor
           INTO lv_string SEPARATED BY lc_tab.

        IF p_rv_bc = 'X' OR p_rvrp = 'X'.
          CONCATENATE
            lv_string
              wa-invoice_no
              wa-invoice_cleared
              wa-fkdat
              wa-bill_ord_reas
              wa-bill_ord_reas_t
              wa-ktgrm
              wa-ktgrm_t
                   INTO lv_string SEPARATED BY lc_tab.
        ELSE.
          CONCATENATE
            lv_string
              wa-deliv_qty
              wa-open_qty
            INTO lv_string SEPARATED BY lc_tab.
        ENDIF.

        CONCATENATE
          lv_string
            wa-del_itm
            wa-rej_itm
            wa-rej_itmt
            wa-unit_price
            wa-head_disc
            wa-head_disc_perc
            wa-item_disc
            wa-item_disc_perc
            wa-cg_discount
            wa-head_surch
            wa-item_surch
            wa-vat
            wa-gross_value
            wa-cost
            wa-profit_margin
            wa-no_of_days
            wa-range
            wa-ange_user
            wa-ange_name
            wa-mvgr1
            wa-mvgr2
            wa-mvgr3
            wa-mvgr4
            wa-mvgr5
          INTO lv_string SEPARATED BY lc_tab.
        CONCATENATE lv_string lc_crlf INTO lv_string.
      ENDLOOP.

      TRY.
          cl_bcs_convert=>string_to_solix(
            EXPORTING
              iv_string   = lv_string
              iv_codepage = '4103'  "suitable for MS Excel, leave empty
              iv_add_bom  = 'X'     "for other doc types
            IMPORTING
              et_solix  = lt_binary_content
              ev_size   = lv_size ).
        CATCH cx_bcs.
          MESSAGE e445(so).
      ENDTRY.


      IF lt_binary_content[] IS NOT INITIAL.
*-- Subject of the Attachment
        CONCATENATE lv_title_type ' : ' sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4)
          ' ' sy-uzeit(2) ':' sy-uzeit+2(2) ':' sy-uzeit+4(2)
          INTO l_attsub RESPECTING BLANKS.
*        l_attsub  = 'YPSALESN'.
*-- Format of the Attachment
        l_att_type = 'XLS'."w_extn.


        TRY.
*-- Add Attachment to the Document
            CALL METHOD w_document->add_attachment
              EXPORTING
                i_attachment_type    = l_att_type
                i_attachment_subject = l_attsub
                i_att_content_hex    = lt_binary_content.
          CATCH cx_document_bcs.
        ENDTRY.
      ENDIF.


*-- Add the recipients to the Send mail
*      LOOP AT lt_email INTO lw_email WHERE zrule = pv_rule.
*      l_rcv_email = 'YMULTIPROGRAM@EAJB.COM.SA'."'bhagat.dharm@eajb.com.sa' email address
*        i_copy = lw_email-ccopy." To/cc
      LOOP AT gt_recipient INTO gv_recipient.
        CHECK NOT gv_recipient IS INITIAL.
        l_recipient = cl_cam_address_bcs=>create_internet_address(
                                                      gv_recipient ).
        CALL METHOD l_send_request->add_recipient
          EXPORTING
            i_recipient = l_recipient
*           i_copy      = lw_email-ccopy "i_copy
            i_express   = 'X'.
      ENDLOOP.

*-- Send Email
      CALL METHOD l_send_request->send(
        EXPORTING
          i_with_error_screen = space
        RECEIVING
          result              = l_result ).

      IF l_result = 'X'.
        LOOP AT gt_recipient INTO gv_recipient.
          MESSAGE s999(ymsg_jet_dbm) WITH
            'Mail sent to : '(005) gv_recipient.
        ENDLOOP.
      ENDIF.

    CATCH cx_bcs INTO l_bcs_exception.
      IF l_result NE 'X'.
        MESSAGE s999(zz) WITH
        'Sending notification failed'(004).
      ENDIF.
  ENDTRY.
  COMMIT WORK.
ENDFORM.

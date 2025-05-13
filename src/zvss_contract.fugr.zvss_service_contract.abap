FUNCTION zvss_service_contract.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(LV_VHVIN) TYPE  VLC_VHVIN
*"     REFERENCE(LV_SALES_DATE) TYPE  DATS
*"----------------------------------------------------------------------

  DATA : lt_serv_cont_info TYPE STANDARD TABLE OF zser_cont_info,
         ls_serv_cont_info TYPE zser_cont_info,
         lt_ser_package    TYPE STANDARD TABLE OF zser_package,
         ls_ser_packge     TYPE zser_package.

  DATA: ls_header   TYPE bapisdhd1,
        lv_order    TYPE bapivbeln-vbeln,
        ls_return   TYPE bapiret2,
        lt_return   TYPE TABLE OF bapiret2,
        ls_items    TYPE bapisditm,
        lt_items    TYPE TABLE OF bapisditm,
        ls_partners TYPE bapiparnr,
        lt_partners TYPE TABLE OF bapiparnr,
        ls_ctrdata  TYPE bapictr,
        lt_ctrdata  TYPE TABLE OF bapictr,
        lt_cond     TYPE TABLE OF bapicond,
        lt_condx    TYPE TABLE OF bapicondx,
        ls_cond     TYPE bapicond,
        ls_condx    TYPE bapicondx.

  DATA : lt_extensionin TYPE TABLE OF bapiparex,
         ls_extensionin TYPE bapiparex.

  SELECT SINGLE * FROM vlcvehicle INTO @DATA(lv_vlcvehicle) WHERE vhvin EQ @lv_vhvin.
  IF sy-subrc EQ 0.

    SELECT * FROM zser_cont_info INTO TABLE lt_serv_cont_info WHERE model EQ lv_vlcvehicle-matnr.
    IF sy-subrc EQ 0.
      SELECT * FROM zser_package INTO TABLE lt_ser_package
               FOR ALL ENTRIES IN lt_serv_cont_info
               WHERE serv_mat EQ lt_serv_cont_info-con_mat.
    ENDIF.


  ENDIF.



ENDFUNCTION.

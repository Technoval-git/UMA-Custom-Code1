*&---------------------------------------------------------------------*
*& Report ZMM_PRICE_CATALOG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_price_catalog.


INCLUDE fzmm_hqcdt.

TABLES: zpc_matnr.
CONSTANTS : ca_check TYPE c       VALUE '0',
            ca_ftype TYPE char10  VALUE 'ASC',
            ca_mtart TYPE mtart   VALUE 'YPOM'.

TYPES: BEGIN OF ty_file_data,
         file_record(1000) TYPE c,
       END OF ty_file_data.

DATA : i_file_data  TYPE STANDARD TABLE OF  ty_file_data,
       wa_file_data TYPE ty_file_data.
DATA : wa_file_name  TYPE file_table.

DATA : lv_tab        TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.
DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
       wa_layout   TYPE slis_layout_alv,
       ls_print    TYPE slis_print_alv.


DATA gt_gm TYPE STANDARD TABLE OF zmm_gm.
DATA gt_ac TYPE STANDARD TABLE OF zmm_ac.
DATA gt_hq TYPE STANDARD TABLE OF zmm_hq.
DATA gt_df TYPE STANDARD TABLE OF zmm_df.
DATA gt_ma TYPE STANDARD TABLE OF zmm_ma.

DATA : lv_TBNAME TYPE dfies-tabname,
       lv_SH     TYPE shlpname.
DATA:  lt_return   TYPE STANDARD TABLE OF ddshretval.
DATA: tb_oper     TYPE msgfn,
      cond_usage  TYPE kvewe,
      table_no    TYPE  kotabnr,
      tb_kappl    TYPE kappl,
      tb_KSCHL    TYPE kscha,
      tb_VKORG    TYPE vkorg,
      tb_VTWEG    TYPE vtweg,
      tb_SPART    TYPE spart,
      tb_AUFART   TYPE /dbe/aufart,
      tb_matnr    TYPE zmm_matnr,
      tb_KNUMH    TYPE knumh,
      tb_KOPOS    TYPE kopos,
      tb_DATBI    TYPE kodatbi,   "Validity end date of the condition record
      tb_DATAB    TYPE kodatab,   "Validity start date of the condition record
      tb_meins    TYPE meins,
      tb_kpein    TYPE kpein,
      tb_stfkz    TYPE Stfkz,
      tb_krech    TYPE krech,
      tb_kstbm    TYPE kstbm,
      tb_kmein    TYPE kmein,
      tb_kumza    TYPE kumza,
      tb_kumne    TYPE kumne,
      tb_curr     TYPE konws,
      tb_curr_iso TYPE bapiisocd,
      tb_price    TYPE netpr,
      tb_condidx  TYPE dzaehk_ind_short,
      tb_var      TYPE char100.

 data: gv_matnr type matnr,
        gv_werks type werks_d,
        gv_ekorg type ekorg,
        gv_lifnr type lifnr,
        gv_price1 type char15,
        gv_price2 type char15,
        gv_vkorg type vkorg,
        gv_vtweg type vtweg,
         lwwwbapiret2     TYPE bapiret2 ,
          lt_BAPIRET3 TYPE STANDARD TABLE OF bapiret2,
           lw_ct       TYPE  bapicondct.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETER   p_gm RADIOBUTTON GROUP gr1  DEFAULT 'X' USER-COMMAND rb1sel .
    SELECTION-SCREEN COMMENT 2(10) FOR FIELD p_gm.
    PARAMETERS  p_ac RADIOBUTTON GROUP gr1 .
    SELECTION-SCREEN COMMENT 17(10) FOR FIELD p_ac.
    PARAMETERS  p_hq RADIOBUTTON GROUP gr1.
    SELECTION-SCREEN COMMENT 32(10) FOR FIELD p_hq.
    PARAMETERS p_DF RADIOBUTTON GROUP gr1.    "DFM
    SELECTION-SCREEN COMMENT 47(10) FOR FIELD p_df.
    PARAMETERS p_MA RADIOBUTTON GROUP gr1.    "MAS
    SELECTION-SCREEN COMMENT 62(10) FOR FIELD p_ma.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.


SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME .
  PARAMETERS: pv_file TYPE localfile.
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN PUSHBUTTON /2(25) template USER-COMMAND temp MODIF ID sc3.
  SELECTION-SCREEN PUSHBUTTON 30(25) upload USER-COMMAND upld MODIF ID sc3.
SELECTION-SCREEN END OF BLOCK b2.



SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME .
  SELECT-OPTIONS s_matnr FOR zpc_matnr-pc_matnr. "zmm_gm-gm_matnr.
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN PUSHBUTTON /2(25) creport USER-COMMAND crep .
  SELECTION-SCREEN PUSHBUTTON 30(25) hreport USER-COMMAND hrep  .
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN PUSHBUTTON /2(25) matmas USER-COMMAND matm  .
  SELECTION-SCREEN PUSHBUTTON 30(25) infore USER-COMMAND info .
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN PUSHBUTTON /2(25) supers USER-COMMAND supe .
  SELECTION-SCREEN PUSHBUTTON 30(25) salesp USER-COMMAND sale1 .
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN PUSHBUTTON /2(25) pricec USER-COMMAND pric .
SELECTION-SCREEN END OF BLOCK b3.



INITIALIZATION.
  template = 'Download Template'.
  upload   = 'Upload'.
  creport  = 'Current Report'.
  hreport  = 'Historical Report'.
  matmas   = 'Update Material Master'.
  infore   = 'Update Purchase Price'.
  supers   = 'Update SuperSession'.
  salesp   = 'Update Sales Price'.
  pricec   = 'Price Comparison'.

AT SELECTION-SCREEN OUTPUT.

  IF p_gm = 'X'.
    lv_TBNAME = 'ZMM_GM'.
    lv_SH     = 'ZMM_GM_PART'.
  ELSEIF p_ac = 'X'.
    lv_TBNAME = 'ZMM_AC'.
    lv_SH     = 'ZMM_AC_PART'.
  ELSEIF p_hq = 'X'.
    lv_TBNAME = 'ZMM_HQ'.
    lv_SH     = 'ZMM_HQ_PART'.
  ELSEIF p_DF = 'X'.
    lv_TBNAME = 'ZMM_DF'.
    lv_SH     = 'ZMM_DF_PART'.
   ELSEIF p_MA = 'X'.
    lv_TBNAME = 'ZMM_MA'.
    lv_SH     = 'ZMM_MA_PART'.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_matnr-low.

  CLEAR lt_return.
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = lv_TBNAME
      fieldname         = 'ZMM_MATNR'
      searchhelp        = lv_SH
    TABLES
      return_tab        = lt_return   " Return the selected value
    EXCEPTIONS
      field_not_found   = 1           " Field does not exist in the Dictionary
      no_help_for_field = 2           " No F4 help is defined for the field
      inconsistent_help = 3           " F4 help for the field is inconsistent
      no_values_found   = 4           " No values found
      OTHERS            = 5.

  IF sy-subrc NE 0.
    RETURN.
  ENDIF.
  READ TABLE lt_return INTO DATA(ls_ret) INDEX 1.
  s_matnr-low = ls_ret-fieldval.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_matnr-high.
  CLEAR lt_return.
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = lv_TBNAME
      fieldname         = 'ZMM_MATNR'
      searchhelp        = lv_SH
    TABLES
      return_tab        = lt_return   " Return the selected value
    EXCEPTIONS
      field_not_found   = 1           " Field does not exist in the Dictionary
      no_help_for_field = 2           " No F4 help is defined for the field
      inconsistent_help = 3           " F4 help for the field is inconsistent
      no_values_found   = 4           " No values found
      OTHERS            = 5.

  IF sy-subrc NE 0.
    RETURN.
  ENDIF.
  READ TABLE lt_return INTO DATA(ls_ret) INDEX 1.
  s_matnr-high = ls_ret-fieldval.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR pv_file.

  DATA: l_window_title      TYPE string,
        l_rc                TYPE sysubrc,
        l_default_file_name TYPE string.

  DATA lt_file_table TYPE filetable.
  CONSTANTS : lc_err TYPE i VALUE -1,
              lc_suc TYPE i VALUE 1.

  l_window_title = 'Upload Excel File'.

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




AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'TEMP'.
      PERFORM zmm_pc_temp.
    WHEN 'UPLD'.
      PERFORM zmm_pc_upld.
    WHEN 'CREP'.
      PERFORM zmm_pc_crep.
    WHEN 'HREP'.
      IF s_matnr[] IS INITIAL.
        MESSAGE 'Please enter part number for Historical Report' TYPE 'E'.
      ELSE.
        PERFORM zmm_pc_hrep.
      ENDIF.
    WHEN 'MATM'.
      PERFORM zmm_pc_matm.
    WHEN 'INFO'.
      PERFORM zmm_pc_info.
    WHEN 'SUPE'.
      IF s_matnr[] IS INITIAL.
        MESSAGE 'Please enter part number for creating SuperSession' TYPE 'E'.
      ELSE.
        PERFORM zmm_pc_supe.
      ENDIF.
    WHEN 'SALE1'.
      PERFORM zmm_pc_sale.
    WHEN 'PRIC'.
      PERFORM zmm_pc_pricecompare.
  ENDCASE.



START-OF-SELECTION.

*WRITE :/ 'Transaction Completed'.
  INCLUDE zmm_pc_crep.

  INCLUDE zmm_pc_hrep.

  INCLUDE zmm_pc_matm.

  INCLUDE zmm_pc_info.

  INCLUDE zmm_pc_supe.

  INCLUDE zmm_pc_sale.

  INCLUDE zmm_pc_temp.

  INCLUDE zmm_pc_upld.

  INCLUDE zmm_pc_pricecompare.

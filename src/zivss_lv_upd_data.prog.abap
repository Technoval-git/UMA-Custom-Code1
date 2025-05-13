*&---------------------------------------------------------------------*
*& Include          ZIVSS_LV_UPD_DATA
*&---------------------------------------------------------------------*

*...<< Types >>
TYPES: BEGIN OF ty_log,
         lbrcat  TYPE /dbe/lbrop_rfc-lbrcat,
         labval  TYPE /dbe/lbrop_rfc-labval,
         type    TYPE bapi_mtype,
         message TYPE bapi_msg,
       END OF ty_log.

TYPES: BEGIN OF ty_header_file,                    "Structure for header file
         identifier TYPE char1,
         lbrcat     TYPE /dbe/lbrop_rfc-lbrcat,
         labval     TYPE /dbe/lbrop_rfc-labval,
         multilog   TYPE /dbe/lbrop_rfc-multilog,
         matnr      TYPE /dbe/lbrop_rfc-matnr,
         lbrgroup   TYPE /dbe/lbrop_rfc-lbrgroup,
         matchcode  TYPE /dbe/lbropt_rfc-matchcode,
         srv_it_grp TYPE /dbe/lbrop_rfc-srv_it_grp,
         descr1     TYPE /dbe/lbropt_rfc-descr1,
         descr2     TYPE /dbe/lbropt_rfc-descr2,
         descr3     TYPE /dbe/lbropt_rfc-descr3,
         descr4     TYPE /dbe/lbropt_rfc-descr4,
       END OF ty_header_file,

       BEGIN OF ty_text_file,                      "Structure for text file
         identifier TYPE char1,
         lbrcat     TYPE /dbe/lbrop_rfc-lbrcat,
         labval     TYPE /dbe/lbrop_rfc-labval,
         tdid       TYPE /dbe/lt_ltext_rfc-tdid,
         tdline     TYPE /dbe/lt_ltext_rfc-tdline,
         flag(1)    TYPE c,
       END OF ty_text_file,

       BEGIN OF ty_time_file,                            "Structure for time file
         identifier  TYPE char1,
         lbrcat      TYPE /dbe/lbrop_time_rfc-lbrcat,
         labval      TYPE /dbe/lbrop_time_rfc-labval,
         labval_type TYPE /dbe/lbrop_time_rfc-labval_type,
         value(7)    TYPE c,
       END OF ty_time_file.

TYPES: tt_header_file TYPE TABLE OF ty_header_file,
       tt_text_file   TYPE TABLE OF ty_text_file,
       tt_time_file   TYPE TABLE OF ty_time_file.

*...<< Tables >>
DATA: it_log         TYPE TABLE OF ty_log,
      it_header_file TYPE TABLE OF ty_header_file,
      it_text_file   TYPE TABLE OF ty_text_file,
      it_time_file   TYPE TABLE OF ty_time_file,
      it_fieldcat    TYPE slis_t_fieldcat_alv.

*...<< Work Areas >>
DATA: wa_layout        TYPE slis_layout_alv.

*...<< Variables >>
DATA: va_logical_file  TYPE c,
      va_total_records TYPE i,
      va_succ_records  TYPE i,
      va_fail_records  TYPE i,
      va_top           TYPE slis_formname VALUE 'F_ALV_HEADER'.

*&---------------------------------------------------------------------*
*& Include          ZCLM_CONTRACT_UPLD_TOP
*&---------------------------------------------------------------------*

DATA : lv_filename      TYPE string,
       lt_records       TYPE solix_tab,
       lv_headerxstring TYPE xstring,
       lv_filelength    TYPE i.


TYPES : BEGIN OF ty_contract_tab,
          heading         TYPE char20,
          recnnr          TYPE recnnumber,                       "Contract Number                      "Required
          bukrs           TYPE bukrs,                            "Company code                         "Required
          recntype        TYPE recncontracttype,                 "Contract type                        "Required
          objtype         TYPE char8, "char6, "RECAOBJTYPE,              "ID Part of Contract Object           "Required
          contract_text   TYPE recntxt,                          "Contract name                        "Required
          old_contract_no TYPE vvosmive,                         "Number of old contract               "Optional     "data element not found
          start_date      TYPE char10,  "recncnbeg,              "Contract start date                  "Required
          end_date        TYPE char10,  "recncnend1st,           "Contract end date                    "Optional
          relevanteval    TYPE recerelevanteval,                 "Valuation relevance                  "Required/Optional
          partner         TYPE bu_partner,                       "Business Partner Number              "Required
          prctr           TYPE prctr,                            "Profit Centre
          FUNCTIONALAREA  TYPE FKBER,                            " Functional Area
*          KOSTL           type kostl,                            "Cost Centre
          zzrecn_ext      TYPE stort_t499s,                      "Location  (Custom 1)                 "Required
          zzframe_recn    TYPE char40, "zztext40,                         "Vendor ID (Custom 2)                 "Required
          zzusrtext       TYPE char40, "zzusrtxt,                         "User Additional text                 "Optional
          cerule          TYPE char30,  "rececerule,             "Valuation Rule                       "Required
          usefullifeend   TYPE receusefullifeend,                "End of Usage RoU                     "Optional
          consbeg         TYPE receconsbeg,                      "Start of consideration               "Required
          interestrate    TYPE receinterestrate,                 "Interest rate                        "Required
          contramend      TYPE char6,    "p DECIMALS 6,                     "Contract Amendment
          remarks         TYPE string,
          icon            TYPE icon_d,
        END OF ty_contract_tab,

        BEGIN OF ty_conditions_tab,
          heading         TYPE char20,
          recnnr          TYPE recnnumber,                      "Contract Number                      "Required
*          bukrs           TYPE bukrs,                          "Company code                         "Required
          condtype        TYPE RECDCONDTYPE, "recdxcondtypel, "string, "char30, "recdcondtype,  "Condition Type                       "Required
          cond_valid_from TYPE char10, "recdvalidfrom,                   "Valid from                           "Required
          cond_valid_to   TYPE char10, "recdvalidto,                     "Valid to                             "Optional
          frequency       TYPE string,  "char20, "recdtermnorh, "Frequency Number  text               "Required
          paymentform     TYPE string, "char20,  "recdtermnorh, "Payment Form                         "Required
          unitprice       TYPE recdunitprice,                   "Unit Price                           "Required
          calcrule        TYPE recdcalcrule,                    "Calculation Formula                  "Required
          distrule        TYPE recddistrule,                    "Distribution Formula                 "Required
          grading         TYPE char4,
          gradperiod      TYPE recdgradperiod,                  "Grade Period                         "Optional
          gradmonth       TYPE recdgradmonth,                   "Grade Month                         "Optional
          gradpercent     TYPE reajvaluepercent,                "Grade Percentage                     "Optional
          gradabsolute    TYPE char20,
        END OF ty_conditions_tab.


DATA : gt_contract TYPE TABLE OF ty_contract_tab,
       gw_contract TYPE ty_contract_tab.

DATA : gt_conditions TYPE TABLE OF ty_conditions_tab,
       gw_conditions TYPE ty_conditions_tab.

DATA : gt_condtypes TYPE TABLE OF tivcdcondtypet,
       g_condtypes  TYPE tivcdcondtypet.

* Z dynamics table for cost centre
*DATA: lt_hcf  TYPE ztt_dynamic_func,
*      lwa_hcf TYPE zxdynamic_func.
*Conditions
DATA : gt_condition LIKE TABLE OF bapi_re_condition_dat,
       gw_condition LIKE bapi_re_condition_dat.


DATA: lv_bukrs_c        TYPE bapi_re_contract_intk-bukrs,
      lv_recnnr         TYPE bapi_re_contract_intk-recnnr,
      lt_term_val       TYPE bapi_re_t_term_ce_int,
      lt_term_org       TYPE bapi_re_t_term_oa_int,
      lt_term_val_cal   TYPE bapi_re_t_term_cecond_int,
      lt_term_val_u     TYPE bapi_re_t_term_ce_intc,
      lt_term_val_cal_u TYPE bapi_re_t_term_cecond_intc,
      lt_status         TYPE bapi_re_t_status_int,
      lt_status_u       TYPE bapi_re_t_status_intc,
      lw_status_u       TYPE bapi_re_status_intc,
      lw_custom         TYPE recn_contract_ci,
      lv_prctr          TYPE anlz-prctr..
FIELD-SYMBOLS : <gt_data_h> TYPE STANDARD TABLE,
                <gt_data_l> TYPE ANY TABLE,
                <gt_table>  TYPE STANDARD TABLE,
                <gs_table>  TYPE any.
CONSTANTS : gc_x TYPE c VALUE 'X',
            gc_e TYPE msgtysd VALUE 'E',
            gc_s TYPE msgtysd VALUE 'S'.

DATA : go_alv    TYPE REF TO cl_salv_table,
       gt_return TYPE TABLE OF bapiret2.
TYPES : BEGIN OF ty_final,
          tlights    TYPE c,
          seqno      TYPE numc3, "zseqno,
          reccn      TYPE recnnumber,
          type       TYPE bapi_mtype,
          id         TYPE symsgid,
          number     TYPE symsgno,
          message	   TYPE	bapi_msg,
          log_no     TYPE balognr,
          log_msg_no TYPE balmnr,
          message_v1 TYPE symsgv,
          message_v2 TYPE symsgv,
          message_v3 TYPE symsgv,
          message_v4 TYPE symsgv,
          parameter	 TYPE	bapi_param,
          row	       TYPE	bapi_line,
          field	     TYPE	bapi_fld,
        END OF ty_final.
DATA : gt_final TYPE TABLE OF ty_final,
       gw_final TYPE ty_final.

DATA : gr_alv     TYPE REF TO cl_salv_table,
       gr_columns TYPE REF TO cl_salv_columns_table.

DATA: lv_rc TYPE i.
DATA: lt_file_table TYPE filetable,
      ls_file_table TYPE file_table.
DATA :gc_green  TYPE c LENGTH 4 VALUE '@08@', "  Green light; Go; OK
      gc_yellow TYPE c LENGTH 4 VALUE '@09@', "  Yellow light; Caution
      gc_red    TYPE c LENGTH 4 VALUE '@0A@'. "  Red light; Negative...

* *Grading
DATA : lv_temp   TYPE char10,
       lv_loop   TYPE i,
       lv_index  TYPE i,
       lv_index1 TYPE i,
       lv_temp1  TYPE char10.
* Job declarartion:
DATA:gv_index      TYPE i,
     gv_msg        TYPE string,
     gv_service_no TYPE bapisrv_asmd-service,
     gv_jobname    TYPE tbtcjob-jobname,
     lwa_priparams TYPE pri_params,
     gv_jobcount   TYPE tbtcjob-jobcount,
     gv_repname    TYPE sy-repid,
     gc_mode       TYPE sy-callr   VALUE 'BATCH',
     gc_x1         TYPE c  VALUE 'X',
     gc_success    TYPE char10 VALUE 'Success', ##NO_TEXT
     gc_error      TYPE char10 VALUE 'Error'. ##NO_TEXT.

DATA: bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE,
      nodata.
DATA : lv_stat_flag(1) TYPE c.
DATA :lv_system_status TYPE bsvx-sttxt,
      lv_user_status   TYPE bsvx-sttxt.

DATA : ld_years         TYPE i,
       ld_months        TYPE i,
       ld_calendar_days TYPE i.

CONSTANTS :gc_fc01 TYPE c LENGTH 4 VALUE 'FC01'.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME .
  PARAMETERS : p_file TYPE ibipparms-path MODIF ID abc.
*SELECTION-SCREEN END OF BLOCK b1.
  SELECTION-SCREEN SKIP 1.
  PARAMETERS : r1_simu RADIOBUTTON GROUP g1,
               r2_updt RADIOBUTTON GROUP g1.
  PARAMETERS: p_job   TYPE char1 DEFAULT ' ' NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b1.
*** INCLUDE ZCLM_CONTRACT_UPLD_TOP
*** INCLUDE ZCLM_CONTRACT_UPLD_TOP

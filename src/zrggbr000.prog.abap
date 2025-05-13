PROGRAM zrggbr000 .
*---------------------------------------------------------------------*
*                                                                     *
*   Regeln: EXIT-Formpool for Uxxx-Exits                              *
*                                                                     *
*   This formpool is used by SAP for demonstration purposes only.     *
*                                                                     *
*   Note: If you define a new user exit, you have to enter your       *
*         user exit in the form routine GET_EXIT_TITLES.              *
*                                                                     *
*---------------------------------------------------------------------*
INCLUDE fgbbgd00.               "Data types


*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
*    PLEASE INCLUDE THE FOLLOWING "TYPE-POOL"  AND "TABLES" COMMANDS  *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM         *
*TYPE-POOLS: GB002. " TO BE INCLUDED IN
*TABLES: BKPF,      " ANY SYSTEM THAT
*        BSEG,      " HAS 'FI' INSTALLED
*        COBL,
*        GLU1.

"{ Begin ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }
*{   INSERT         KA5K001798                                        1
TYPE-POOLS: gb002.
TABLES: cnmmdates.
*}   INSERT
"{ End ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }

*ENHANCEMENT-POINT RGGBR000_01 SPOTS ES_RGGBR000 STATIC.
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*


*----------------------------------------------------------------------*
*       FORM GET_EXIT_TITLES                                           *
*----------------------------------------------------------------------*
*       returns name and title of all available standard-exits         *
*       every exit in this formpool has to be added to this form.      *
*       You have to specify a parameter type in order to enable the    *
*       code generation program to determine correctly how to          *
*       generate the user exit call, i.e. how many and what kind of    *
*       parameter(s) are used in the user exit.                        *
*       The following parameter types exist:                           *
*                                                                      *
*       TYPE                Description              Usage             *
*    ------------------------------------------------------------      *
*       C_EXIT_PARAM_NONE   Use no parameter         Subst. and Valid. *
*                           except B_RESULT                            *
*       C_EXIT_PARAM_CLASS  Use a type as parameter  Subst. and Valid  *
*----------------------------------------------------------------------*
*  -->  EXIT_TAB  table with exit-name and exit-titles                 *
*                 structure: NAME(5), PARAM(1), TITEL(60)
*----------------------------------------------------------------------*
FORM get_exit_titles TABLES etab.

  DATA: BEGIN OF exits OCCURS 50,
          name(5)   TYPE c,
          param     LIKE c_exit_param_none,
          title(60) TYPE c,
        END OF exits.
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*  EXITS-NAME  = 'U101'.
*  EXITS-PARAM = C_EXIT_PARAM_CLASS.
*  EXITS-TITLE = TEXT-100.                 "Posting date check
*  APPEND EXITS.

  exits-name  = 'ZDHT'.  " Document Header Text
  exits-param = c_exit_param_none.        "Complete data used in exit.
  exits-title = TEXT-104.                 "Posting date check
  APPEND exits.
    exits-name  = 'ZPM1'.  " payment method
  exits-param = c_exit_param_none.        "Complete data used in exit.
  exits-title = TEXT-104.                 "Posting date check
  APPEND exits.
    exits-name  = 'ZIT1'.  " Item Text
  exits-param = c_exit_param_none.        "Complete data used in exit.
  exits-title = TEXT-104.                 "Posting date check
  APPEND exits.
    exits-name  = 'ZDNO'.  " Document number
  exits-param = c_exit_param_none.        "Complete data used in exit.
  exits-title = TEXT-104.                 "Posting date check
  APPEND exits.
  exits-name  = 'ZCCA'.
  exits-param = c_exit_param_none.        "Complete data used in exit.
  exits-title = TEXT-104.                 "Posting date check
  APPEND exits.

  exits-name  = 'U100'.
  exits-param = c_exit_param_none.        "Complete data used in exit.
  exits-title = TEXT-101.                 "Posting date check
  APPEND exits.

* forms for SAP_EIS
  exits-name  = 'US001'.                  "single validation: only one
  exits-param = c_exit_param_none.        "data record used
  exits-title = TEXT-102.                 "Example EIS
  APPEND exits.

  exits-name  = 'UM001'.                  "matrix validation:
  exits-param = c_exit_param_class.       "complete data used in exit.
  exits-title = TEXT-103.                 "Example EIS
  APPEND exits.


***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
  INCLUDE rggbr_ps_titles.

***********************************************************************
** EXIT EXAMPLES FROM Argentina Legal Change - Law Res 177
***********************************************************************
  INCLUDE rggbs_ar_titles.

  REFRESH etab.
  LOOP AT exits.
    etab = exits.
    APPEND etab.
  ENDLOOP.

ENDFORM.                    "GET_EXIT_TITLES

*eject

FORM zcca USING b_result.
  TABLES: bseg, bkpf.
*  BREAK-POINT.

  DATA lv_customer TYPE kunnr.
  TYPES : BEGIN OF ty_ucs,
            partner      TYPE  ukmbp_cms_sgm-partner,
            credit_sgmnt TYPE ukmbp_cms_sgm-credit_sgmnt,
          END OF ty_ucs.
  DATA lt_ucs TYPE STANDARD TABLE OF ty_ucs.
  DATA ls_ucs TYPE ty_ucs.

  IF bseg-kkber IS  INITIAL   AND bseg-vorgn = 'RFBU' AND bseg-koart = 'D'  and bkpf-XBLNR is not initial.

    b_result = b_false.


  ELSEIF bseg-vorgn = 'RFBU' AND bseg-koart = 'D' and bkpf-XBLNR is not initial.

    SELECT SINGLE businesspartner FROM ibupacustomer INTO lv_customer WHERE customer = bseg-kunnr.
    SELECT partner credit_sgmnt FROM ukmbp_cms_sgm INTO TABLE lt_UCS WHERE partner = lv_customer.

    READ TABLE lt_ucs INTO ls_ucs WITH KEY credit_sgmnt = bseg-kkber.

    IF sy-subrc <> 0 ."and ls_ucs-credit_sgmnt = '0000'.
      B_Result = b_false.
    ENDIF.

  ENDIF.





ENDFORM.


FORM ZDHT USING b_result.
  IF bseg-koart = 'D'.

  IF bkpf-bktxt IS INITIAL.
      b_result = b_false.
    ENDIF.
  ENDIF.



ENDFORM.
FORM ZIT1 USING b_result.
*  For Company Code 1000 (Document type DR,DG,DD,DZ,DX):
*  Accounting document Item Text in Customer Line(mentioning the Material/Service description) BSEG-SGTXT
  IF bseg-buzid <> 'T'.
    IF bseg-sgtxt IS INITIAL.
      b_result = b_false.
    ENDIF.
  ENDIF.


ENDFORM.

FORM ZDNO USING b_result.
  IF bseg-koart = 'D'.
    IF bseg-rebzg IS INITIAL.
      b_result = b_false.
    ENDIF.
  ENDIF.


ENDFORM.

FORM ZPM1 USING b_result.
*  For Company Code 1000 (Document type DR,DG,DD,DZ,DX):
*  Payment Method in Customer Line item  BSEG-ZLSCH
  IF bseg-koart = 'D'.
    IF bseg-zlsch IS INITIAL.
      b_result = b_false.
    ENDIF.
  ENDIF.


ENDFORM.


*----------------------------------------------------------------------*
*       FORM U100                                                      *
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule                          *
*       This exit can be used in FI for callup points 1,2 or 3.        *
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM u100  USING b_result.

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*
*   IF SY-DATUM = BKPF-BUDAT.
*     B_RESULT  = B_TRUE.
*  ELSE.
*    B_RESULT  = B_FALSE.
*  ENDIF.
*{   INSERT         DS4K900363                                        1


  BREAK-POINT.
* if bseg-kkber is  INITIAL.
*
*  B_RESULT = B_TRUE.
*
* endif.
****
****data lv_customer type kunnr.
****types : Begin of ty_ucs,
****        partner  type  ukmbp_cms_sgm-partner,
****        credit_sgmnt type ukmbp_cms_sgm-credit_sgmnt,
****        end of ty_ucs.
**** data lt_ucs type STANDARD TABLE OF ty_ucs.
**** data ls_ucs type ty_ucs.
****
**** select single BUSINESSPARTNER from IBUPACUSTOMER into lv_customer WHERE CUSTOMER = BSEG-KUNNR.
****   select partner credit_sgmnt from ukmbp_cms_sgm into table lt_UCS where partner = lv_customer.
****
****  read table lt_ucs into ls_ucs with key credit_sgmnt = BSEG-KKBER.
****
****  if sy-subrc <> 0 and ls_ucs-credit_sgmnt = '0000'.
****    B_Result = B_TRUE.
****  endif.

*
*}   INSERT

  DATA: tmp_datum LIKE sy-datum.    "{ ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }

*ENHANCEMENT-POINT RGGBR000_02 SPOTS ES_RGGBR000 STATIC.


  "{ Begin ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }
  tmp_datum = cnmmdates-badat + 10.
  IF cnmmdates-bdter > tmp_datum.
    B_result = B_true.
  ENDIF.
  "{ End ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }

*ENHANCEMENT-POINT RGGBR000_03 SPOTS ES_RGGBR000.


ENDFORM.                                                    "U100

*eject
*----------------------------------------------------------------------*
*       FORM U101                                                      *
*----------------------------------------------------------------------*
*       Example of an exit using the complete data from one            *
*       multi-line rule.                                               *
*       This exit is intended for use from callup point 3, in FI.      *
*                                                                      *
*       If account 400000 is used, then account 399999 must be posted  *
*       to in another posting line.                                    *
*----------------------------------------------------------------------*
*  -->  BOOL_DATA   The complete posting data.                         *
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*FORM u101 USING    bool_data TYPE gb002_015
*          CHANGING B_RESULT.
*  DATA: B_ACC_400000_USED LIKE D_BOOL VALUE 'F'.
*
*  B_RESULT = B_TRUE.
** Has account 400000 has been used?
*  LOOP AT BOOL_DATA-BSEG INTO BSEG
*                 WHERE HKONT  = '0000400000'.
*     B_ACC_400000_USED = B_TRUE.
*     EXIT.
*  ENDLOOP.
*
** Check that account 400000 has been used.
*  CHECK B_ACC_400000_USED = B_TRUE.
*
*  B_RESULT = B_FALSE.
*  LOOP AT BOOL_DATA-BSEG INTO BSEG
*                 WHERE HKONT  = '0000399999'.
*     B_RESULT = B_TRUE.
*     EXIT.
* ENDLOOP.
*
*ENDFORM.

*eject
*----------------------------------------------------------------------*
*       FORM US001
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule in SAP-EIS
*       for aspect 001 (single validation).
*       one data record is transfered in structure CF<asspect>
*----------------------------------------------------------------------
*       Attention: for any FORM one has to make an entry in the
*       form GET_EXIT_TITLES at the beginning of this include
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM us001 USING b_result.

*TABLES CF001.                                 "table name aspect 001
*
*  IF ( CF001-SPART = '00000001' OR
*       CF001-GEBIE = '00000001' ) AND
*       CF001-ERLOS >= '1000000'.
*
**   further checks ...
*
*    B_RESULT  = B_TRUE.
*  ELSE.
*
**   further checks ...
*
*    B_RESULT  = B_FALSE.
*  ENDIF.

ENDFORM.                                                    "US001

*eject
*----------------------------------------------------------------------*
*       FORM UM001
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule in SAP-EIS
*       for aspect 001 (matrix validation).
*       Data is transfered in BOOL_DATA:
*       BOOL_DATA-CF<aspect> is intern table of structure CF<asspect>
*----------------------------------------------------------------------
*       Attention: for any FORM one has to make an entry in the
*       form GET_EXIT_TITLES at the beginning of this include
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM um001 USING bool_data    "TYPE GB002_<boolean class of aspect 001>
           CHANGING b_result.

*DATA: LC_CF001 LIKE CF001.
*DATA: LC_COUNT TYPE I.

*  B_RESULT = B_TRUE.
*  CLEAR LC_COUNT.
*  process data records in BOOL_DATA
*  LOOP AT BOOL_DATA-CF001 INTO LC_CF001.
*    IF LC_CF001-SPART = '00000001'.
*      ADD 1 TO LC_COUNT.
*      IF LC_COUNT >= 2.
**       division '00000001' may only occur once !
*        B_RESULT = B_FALSE.
*        EXIT.
*      ENDIF.
*    ENDIF.
*
**   further checks ....
*
*  ENDLOOP.

ENDFORM.                                                    "UM001


***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
*INCLUDE rggbr_ps_forms.

***********************************************************************
** EXIT EXAMPLES FROM Argentina Legal Change - Law Res 177
***********************************************************************

*INCLUDE RGGBS_AR_FORMS.

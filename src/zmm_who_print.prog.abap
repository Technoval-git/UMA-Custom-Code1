*&---------------------------------------------------------------------*
*& Report ZMM_WHO_PRINT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report ZMM_WHO_PRINT.

tables: /SCWM/ORDIM_C, /SAPAPO/MATKEY, /SCDL/DB_REFDOC, /SCWM/T300T.

types:
  begin of XTAB,
    LGNUM        type /SCWM/ORDIM_C-LGNUM,
    WHO          type /SCWM/ORDIM_C-WHO,

    CREATED_AT   type /SCWM/WHO-CREATED_AT,
*    CREATED_TXT   type STRING,
*    CREATED_DT    type DATUM,
*    CREATED_TM    type DATUM,

    CREATED_BY   type /SCWM/WHO-CREATED_BY,

    STARTED_AT   type /SCWM/WHO-STARTED_AT,
*    STARTED_TXT   type STRING,
*    STARTED_DT    type DATUM,
*    STARTED_TM    type UZEIT,

    CONFIRMED_AT type /SCWM/WHO-CONFIRMED_AT,
*    CONFIRMED_TXT type STRING,
*    CONFIRMED_DT  type DATUM,
*    CONFIRMED_TM  type UZEIT,

    CONFIRMED_BY type /SCWM/WHO-CONFIRMED_BY,
    PROCESSOR    type /SCWM/WHO-PROCESSOR,

*********
    TANUM        type /SCWM/ORDIM_C-TANUM,

    MATID        type /SCWM/ORDIM_C-MATID,
    MATNR        type /SAPAPO/MATKEY-MATNR,
    MAKTX        type /SAPAPO/MATTXT-MAKTX,

    CHARG        type /SCWM/ORDIM_C-CHARG, "Batch
    VSOLA        type /SCWM/ORDIM_C-VSOLA, "Source/Target Qty
    NISTM        type /SCWM/ORDIM_C-NISTM, "Actual Qty
    VLTYP        type /SCWM/ORDIM_C-VLTYP, "Source Storage Type
    VLPLA        type /SCWM/ORDIM_C-VLPLA, "Source Storage Bin
    NLTYP        type /SCWM/ORDIM_C-NLTYP, "Destination Storage Type
    NLPLA        type /SCWM/ORDIM_C-NLPLA, "Destination Storage Bin

    VLENR        type /SCWM/ORDIM_C-VLENR, "Source HU
    NLENR        type /SCWM/ORDIM_C-NLENR, "Destination HU

  end of XTAB.

data:
  IT_TAB      type table of ZMM_WHO_STRUCT with header line,
  IT_TAB2     type table of ZMM_WHO_STRUCT with header line,
  IT_TAB3     type table of ZMM_WHO_STRUCT with header line,
  IT_WHO      type table of ZMM_WHO_STRUCT with header line,
  IT_WHO3     type table of ZMM_WHO_STRUCT with header line,
  IT_ERPDLV   type table of ZMM_WHO_STRUCT with header line,
  IT_ENTITLED type table of ZMM_WHO_STRUCT with header line,
  WA_TAB      type XTAB,
  WA_WHO      type ZMM_WHO_STRUCT,

  IT_HUITM    type /SCWM/TT_HUITM_INT with header line.

selection-screen begin of block B1 with frame.
select-options:
S_LGNUM for /SCWM/ORDIM_C-LGNUM default '1300' no intervals no-extension
                          obligatory," matchcode object /SCWM/SH_LGNUM,
S_WHO   for /SCWM/ORDIM_C-WHO , "obligatory,
S_TANUM for /SCWM/ORDIM_C-TANUM       no-display,
*S_MATNR for /SAPAPO/MATKEY-MATNR.

S_REFDOC for /SCDL/DB_REFDOC-REFDOCNO,
S_ENTTLD for /SCWM/ORDIM_C-ENTITLED,
S_DOCID  for /SCWM/ORDIM_C-QDOCID     no-display.

parameters: P_LANGU type /SAPAPO/MATTXT-LANGU default 'EN' obligatory.
selection-screen end of block B1.

selection-screen skip.

selection-screen begin of block B2 with frame title text-001.

parameters:
  LOC_SORT radiobutton group G1,    "Sort by Source Storage Bin
  MAT_SORT radiobutton group G1,    "Sort by Material Number
  ALL_SORT radiobutton group G1.    "Sort by Storage Bin & Material

selection-screen end of block B2.

selection-screen skip.

selection-screen begin of block B3 with frame title text-002.

parameters:
*  R_ALL  radiobutton group G2,
  R_OFFL radiobutton group G2 user-command X,          "Offloading Slip
  R_PICK radiobutton group G2 ,          "Picking Slip
  R_DELV radiobutton group G2 .          "Delivery Slip

selection-screen skip.

parameters C_COLDLV as checkbox default ''.
parameters C_QTY    as checkbox default 'X'.

selection-screen end of block B3.

data IV_GUID_X16 type SYSUUID-X.
data EV_GUID_C22 type SYSUUID-C22.
data V_NUMBERING type INT4.

data: V_DLV(130).
data: V_REFDOC         type /SCDL/DB_REFDOC-REFDOCNO,
      V_REFDOC_TXT(20),
      V_HU(20).

at selection-screen output.

  if R_DELV <>'X' and R_PICK <>'X'.
    loop at screen.
      if SCREEN-NAME     = 'C_COLDLV'.
        SCREEN-ACTIVE    = '0'.
        SCREEN-INVISIBLE = '1'.
        modify screen.
      endif.
    endloop.
    C_COLDLV = ''.
  endif.
*******************************************************************
*******************************************************************

start-of-selection.

  if S_WHO    is initial and
     S_REFDOC is initial .

    message 'You must enter Warehouse Order or Delivery Document!' type 'S'
    display like 'E'.
    exit.
  endif.
*******************************************************************

  if S_REFDOC is not initial.
    select distinct DOCID
      from /SCDL/DB_REFDOC
      into S_DOCID-LOW
      where REFDOCNO in S_REFDOC and
            REFDOCCAT = 'ERP'    and
            DOCCAT like 'PD%'.

      S_DOCID-SIGN   = 'I'.
      S_DOCID-OPTION = 'EQ'.
      append S_DOCID.
    endselect.
  endif.
*******************************************************************

  select *
    from /SCWM/ORDIM_O
    join /SCWM/WHO on /SCWM/WHO~LGNUM = /SCWM/ORDIM_O~LGNUM and
         /SCWM/WHO~WHO = /SCWM/ORDIM_O~WHO
    into corresponding fields of table IT_TAB2
    where
          /SCWM/WHO~LGNUM in S_LGNUM and
          /SCWM/WHO~WHO   in S_WHO   and
          TANUM    in S_TANUM        and
          ENTITLED in S_ENTTLD       and
          QDOCID   in S_DOCID.

  if S_DOCID is not initial.
    select *
      from /SCWM/ORDIM_O
      join /SCWM/WHO on /SCWM/WHO~LGNUM = /SCWM/ORDIM_O~LGNUM and
           /SCWM/WHO~WHO = /SCWM/ORDIM_O~WHO
      appending corresponding fields of table IT_TAB2
      where
            /SCWM/WHO~LGNUM in S_LGNUM and
            /SCWM/WHO~WHO   in S_WHO   and
            TANUM    in S_TANUM        and
            ENTITLED in S_ENTTLD       and
            RDOCID   in S_DOCID.
  endif.

  select *
    from /SCWM/ORDIM_C
    join /SCWM/WHO on /SCWM/WHO~LGNUM = /SCWM/ORDIM_C~LGNUM and
         /SCWM/WHO~WHO = /SCWM/ORDIM_C~WHO
    appending corresponding fields of table IT_TAB2
    where
          /SCWM/WHO~LGNUM in S_LGNUM and
          /SCWM/WHO~WHO   in S_WHO   and
          TANUM    in S_TANUM        and
          ENTITLED in S_ENTTLD       and
          QDOCID   in S_DOCID.

  if S_DOCID is not initial.
    select *
      from /SCWM/ORDIM_C
      join /SCWM/WHO on /SCWM/WHO~LGNUM = /SCWM/ORDIM_C~LGNUM and
           /SCWM/WHO~WHO = /SCWM/ORDIM_C~WHO
      appending corresponding fields of table IT_TAB2
      where
            /SCWM/WHO~LGNUM in S_LGNUM and
            /SCWM/WHO~WHO   in S_WHO   and
            TANUM    in S_TANUM        and
            ENTITLED in S_ENTTLD       and
            RDOCID   in S_DOCID.
  endif.


  sort IT_TAB2.
  delete adjacent duplicates from IT_TAB2 comparing all fields.

  if IT_TAB2[] is initial.
    message 'No data found!' type 'S' display like 'E'.
    exit.
  endif.
*****************
*****************

  loop at IT_TAB2 where ENTITLED is not initial.    "Marwan 25062021
    IT_ENTITLED-WHO      = IT_TAB2-WHO.
    IT_ENTITLED-ENTITLED = IT_TAB2-ENTITLED.

    append IT_ENTITLED.
  endloop.

  sort IT_ENTITLED.
  delete adjacent duplicates from IT_ENTITLED.
*************************************************

  loop at IT_TAB2.

    read table IT_ENTITLED with key WHO = IT_TAB2-WHO. "Marwan 25062021
    if SY-SUBRC = 0.
      IT_TAB2-ENTITLED = IT_ENTITLED-ENTITLED.

    else.                                              "Marwan 04072021
      if IT_TAB2-QDOCID is initial and IT_TAB2-RDOCID is initial and
         IT_TAB2-NLENR is not initial.

*        if IT_TAB2-NLENR cp '*/*'.
*          split IT_TAB2-NLENR at '/' into V_HU V_REFDOC_TXT.
*          if V_REFDOC_TXT(1) = '0'.
*            V_REFDOC = V_REFDOC_TXT(10).
*          else.
*            V_REFDOC(1) = '0'.
*            V_REFDOC+1  = V_REFDOC_TXT(9).
*          endif.

        select single ENTITLED QDOCID RDOCID
          from /SCWM/ORDIM_H
          into: (IT_TAB2-ENTITLED, IT_TAB2-QDOCID, IT_TAB2-RDOCID)
          where HUIDENT = IT_TAB2-NLENR.

*          select single DOCID
*            from /SCDL/DB_REFDOC
*            into IT_TAB-QDOCID
*            where REFDOCNO = V_REFDOC and
*                  REFDOCCAT = 'ERP'   and
*                  DOCCAT like 'PD%'.

*          if IT_TAB-QDOCID is not initial.
*
*          endif.
*        endif.

      endif.
    endif.

    move-corresponding IT_TAB2 to IT_TAB.

    if IT_TAB-MATID is initial and IT_TAB-VLENR is not initial.

      select MATID NISTM
        from /SCWM/ORDIM_H
        into corresponding fields of IT_TAB
        where TANUM   = IT_TAB-TANUM and
              HUIDENT = IT_TAB-VLENR.

        perform PROCESS_DATA.

        append IT_TAB.
        clear  IT_TAB-VSOLA.
      endselect.

******************************************
      if SY-SUBRC <> 0.

        clear: IT_HUITM, IT_HUITM[].
        call function '/SCWM/HU_READ'
          exporting
            IV_APPL    = 'WME'         "IV_APPL
            IV_LGNUM   = IT_TAB-LGNUM  "'Z023' "IV_LGNUM
            IV_HUIDENT = IT_TAB-VLENR  " HU    "IV_HUIDENT
          importing
            ET_HUITM   = IT_HUITM[]
          exceptions
            DELETED    = 1
            NOT_FOUND  = 2
            ERROR      = 3
            others     = 4.
        if SY-SUBRC <> 0.
* Implement suitable error handling here
        endif.

        loop at IT_HUITM.

          IT_TAB-MATID = IT_HUITM-MATID.
          IT_TAB-NISTM = IT_HUITM-QUAN .
          IT_TAB-ENTITLED = IT_HUITM-ENTITLED.
          perform PROCESS_DATA.
*        if IT_TAB-VSOLA is initial.
*          IT_TAB-VSOLA = IT_TAB-NISTM.
*        endif.
*
*        perform MATID_TO_PRODUCT.
*
*        if C_QTY <> 'X'.
*          clear: IT_TAB-VSOLA, IT_TAB-NISTM.
*        endif.
*
*        if R_OFFL = 'X'.
*          select single LGPLA as NLPLA LGTYP as NLTYP
*            from /SCWM/BINMAT
*            into corresponding fields of IT_TAB
*            where MATNR = IT_TAB-MATNR.
*        endif.

          append IT_TAB.
        endloop.
      endif.

******************************************
    elseif IT_TAB-MATID is not initial.

      perform PROCESS_DATA.
*    perform MATID_TO_PRODUCT.
*    if C_QTY <> 'X'.
*      clear: IT_TAB-VSOLA, IT_TAB-NISTM.
*    endif.
*
*    if R_OFFL = 'X'.
*      select single LGPLA as NLPLA LGTYP as NLTYP
*        from /SCWM/BINMAT
*        into corresponding fields of IT_TAB
*        where MATNR = IT_TAB-MATNR.
*    endif.

*    modify IT_TAB.
      append IT_TAB.
    endif.

  endloop.

  if IT_TAB[] is initial.
    IT_TAB[] = IT_TAB2[].
  endif.

*break-point.
*delete adjacent duplicates from IT_TAB comparing all fields.
  IT_WHO[]    = IT_TAB[].
  IT_ERPDLV[] = IT_TAB[].

  sort IT_WHO by WHO.
  delete adjacent duplicates from IT_WHO comparing WHO.

  sort IT_ERPDLV by ERP_DLV.

**************************************
  if C_COLDLV = 'X'.                "Marwan 10032021
    loop at IT_ERPDLV.
      IT_ERPDLV-ERP_DLV = V_DLV.
      modify IT_ERPDLV.
    endloop.
    loop at IT_TAB.
      IT_TAB-ERP_DLV    = V_DLV.
      modify IT_TAB.
    endloop.
    loop at IT_WHO.
      IT_WHO-ERP_DLV    = V_DLV.
      modify IT_WHO.
    endloop.

  else.
    if R_DELV = 'X' or R_PICK = 'X'.
      loop at IT_ERPDLV.
        read table IT_WHO with key ERP_DLV = IT_ERPDLV-ERP_DLV.
        if SY-SUBRC <> 0.
          delete IT_ERPDLV.
        endif.
      endloop.
    endif.
  endif.
  delete adjacent duplicates from IT_ERPDLV comparing ERP_DLV.

*******************************************************
*******************************************************

  perform ADOBEFORM.


form ADOBEFORM .
  data: FM_NAME         type RS38L_FNAM,      "Name of Function Module
        FP_DOCPARAMS    type SFPDOCPARAMS,    "Form Parameters
        FP_OUTPUTPARAMS type SFPOUTPUTPARAMS. "Output Parameter

  data: FORM_NAME type FPNAME.

  data(ABAP_TRUE)  = 'X'.
  data(ABAP_FALSE) = ''.

*    FP_OUTPUTPARAMS-NODIALOG   = ABAP_TRUE.
*    FP_OUTPUTPARAMS-GETPDF     = 'M'.
*    FP_OUTPUTPARAMS-ASSEMBLE   = ABAP_TRUE.
*    FP_OUTPUTPARAMS-PREVIEW    = ABAP_FALSE.


  call function 'FP_JOB_OPEN' "& Form Processing: Call Form
*    importing
*      ASSEMBLE        = ABAP_TRUE
*      NODIALOG        = ABAP_TRUE
*      GETPDF          = 'M'
*      PREVIEW         = ABAP_FALSE
    changing
      IE_OUTPUTPARAMS = FP_OUTPUTPARAMS
    exceptions
      CANCEL          = 1
      USAGE_ERROR     = 2
      SYSTEM_ERROR    = 3
      INTERNAL_ERROR  = 4
      others          = 5.
  if SY-SUBRC <> 0.
*            <error handling>
  endif.


  if     R_OFFL = 'X'.
    FORM_NAME = 'ZMM_WHO_OFFLOADING'.
  elseif R_PICK = 'X'.
    FORM_NAME = 'ZMM_WHO_PICKING'.
  elseif R_DELV = 'X'.
    FORM_NAME = 'ZMM_WHO_DELIVERY'.
  else.
    FORM_NAME = 'ZMM_WHO_PRINT_FORM'. "'ZMM_TEST'.
  endif.

  call function 'FP_FUNCTION_MODULE_NAME' "& Form Processing Generation
    exporting
      I_NAME     = FORM_NAME
    importing
      E_FUNCNAME = FM_NAME.

*  FP_DOCPARAMS-FILLABLE = 'X' .

*  append lines of IT_TAB to IT_TAB.
*  append lines of IT_TAB to IT_TAB.
*  append lines of IT_TAB to IT_TAB.
*  append lines of IT_TAB to IT_TAB.

  if ALL_SORT = 'X'.
    sort IT_TAB by WHO VLPLA MATNR. "Sort by Storage Bin & Material

    if R_OFFL = 'X'.
      sort IT_TAB by WHO NLPLA MATNR. "Sort by Storage Bin & Material
    endif.
  elseif LOC_SORT = 'X'.
    sort IT_TAB by WHO VLPLA.       "Sort by Source Storage Bin

    if R_OFFL = 'X'.
      sort IT_TAB by WHO NLPLA.       "Sort by Source Storage Bin
    endif.

  elseif MAT_SORT = 'X'.
    sort IT_TAB by WHO MATNR.       "Sort by Material Number
  endif.


***********************************************
***********************************************
  if R_OFFL <> 'X'.            "In case of Picking or Delivery layout
    loop at IT_TAB.
      move-corresponding IT_TAB to IT_TAB3.
      clear: IT_TAB3-TANUM, IT_TAB3-CHARG.
      collect IT_TAB3.
    endloop.
    IT_TAB[] = IT_TAB3[].
  endif.

***********************************************
  if R_DELV <> 'X'.            "In case of Offloading or Picking layout

    if R_PICK = 'X'.          "Marwan
      data: V_WHO like IT_TAB-WHO.
      clear V_NUMBERING.
      loop at IT_TAB.
        if V_WHO <> IT_TAB-WHO.
          clear V_NUMBERING.
          V_WHO = IT_TAB-WHO.
        endif.
        V_NUMBERING  = 1 + V_NUMBERING.
        IT_TAB-NUMBERING = V_NUMBERING.
        modify IT_TAB.
      endloop.
    endif.

    call function FM_NAME
      exporting
        /1BCDWB/DOCPARAMS = FP_DOCPARAMS
        WA_WHO            = WA_WHO
        IT_WHO            = IT_WHO[]
        IT_TAB            = IT_TAB[]
*       LOGO              = LOGO
*       title             = title
*    IMPORTING
*       /1BCDWB/FORMOUTPUT       =
      exceptions
        USAGE_ERROR       = 1
        SYSTEM_ERROR      = 2
        INTERNAL_ERROR    = 3
        others            = 5.
    if SY-SUBRC <> 0.
*  <error handling>
    endif.

***********************************************
***********************************************
  else.                       "In case of Delivery layout
    IT_WHO3[] = IT_WHO[].
    IT_TAB3[] = IT_TAB[].

***********************************************
*    loop at IT_WHO3.
    loop at IT_ERPDLV.

      IT_WHO[] = IT_WHO3[].
      IT_TAB[] = IT_TAB3[].

*      delete IT_WHO where WHO <> IT_WHO3-WHO.
*      delete IT_TAB where WHO <> IT_WHO3-WHO.
      delete IT_WHO where ERP_DLV <> IT_ERPDLV-ERP_DLV.
      delete IT_TAB where ERP_DLV <> IT_ERPDLV-ERP_DLV.
      read table IT_WHO into WA_WHO index 1.

*      clear V_NUMBERING.
*      loop at IT_TAB.
*        V_NUMBERING  = 1 + V_NUMBERING.
*        IT_TAB-NUMBERING = V_NUMBERING.
*        modify IT_TAB.
*      endloop.

      clear: V_WHO.
      clear V_NUMBERING.
      loop at IT_TAB.
        if V_WHO <> IT_TAB-WHO.
          clear V_NUMBERING.
          V_WHO = IT_TAB-WHO.
        endif.
        V_NUMBERING  = 1 + V_NUMBERING.
        IT_TAB-NUMBERING = V_NUMBERING.
        modify IT_TAB.
      endloop.

***********************************************

      call function FM_NAME
        exporting
          /1BCDWB/DOCPARAMS = FP_DOCPARAMS
          WA_WHO            = WA_WHO
          IT_WHO            = IT_WHO[]
          IT_TAB            = IT_TAB[]
*         LOGO              = LOGO
*         title             = title
*    IMPORTING
*         /1BCDWB/FORMOUTPUT       =
        exceptions
          USAGE_ERROR       = 1
          SYSTEM_ERROR      = 2
          INTERNAL_ERROR    = 3
          others            = 5.
      if SY-SUBRC <> 0.
*  <error handling>
      endif.

***********************************************
    endloop.

    data: PDF_TABLE     type TFPCONTENT,
          E_PDF_CONTENT type XSTRING,
          LA_PDF        like line of PDF_TABLE.

    call function 'FP_GET_PDF_TABLE'
      importing
        E_PDF_TABLE = PDF_TABLE.

    read table PDF_TABLE into LA_PDF index 1.
    if SY-SUBRC eq 0.
      E_PDF_CONTENT = LA_PDF.
    else.
* Raise Appropriate Error
    endif.
***********************************************
  endif.


***********************************************

*&---- Close the spool job
  call function 'FP_JOB_CLOSE'
*    IMPORTING
*     E_RESULT             =
    exceptions
      USAGE_ERROR    = 1
      SYSTEM_ERROR   = 2
      INTERNAL_ERROR = 3
      others         = 4.
  if SY-SUBRC <> 0.
*            <error handling>
  endif.


endform. " ADOBEFORM

*&---------------------------------------------------------------------*
*&      Form  MATID_TO_PRODUCT
*----------------------------------------------------------------------*
form MATID_TO_PRODUCT .

  clear EV_GUID_C22.

  call function 'GUID_CONVERT'
    exporting
      IV_GUID_X16            = IT_TAB-MATID "IV_GUID_X16
    importing
      EV_GUID_C22            = EV_GUID_C22
    exceptions
      NO_UNICODE_SUPPORT_YET = 1
      PARAMETERS_ERROR       = 2
      others                 = 3.


*  if IT_TAB-MATNR is not initial.
*    select single MATID
*      from /SAPAPO/MATKEY
*      into EV_GUID_C22
*      where /SAPAPO/MATKEY~MATNR = IT_TAB-MATNR.
*  endif.

  select single MATNR
    from /SAPAPO/MATKEY
    into corresponding fields of IT_TAB
    where /SAPAPO/MATKEY~MATID = EV_GUID_C22.

  select single MAKTX
    from /SAPAPO/MATTXT
    into corresponding fields of IT_TAB
    where MATID = EV_GUID_C22 and
          LANGU = P_LANGU.
*      ( ( LANGU = 'E' or LANGU = 'A' ) and MAKTX not like '#%' ).

endform.

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*----------------------------------------------------------------------*
form PROCESS_DATA .

  if IT_TAB-VSOLA is initial.
    IT_TAB-VSOLA = IT_TAB-NISTM.
  endif.

  if IT_TAB-NISTM is initial.
    IT_TAB-NISTM = IT_TAB-VSOLA.
  endif.

  perform MATID_TO_PRODUCT.

  if C_QTY <> 'X'.
    clear: IT_TAB-VSOLA, IT_TAB-NISTM.
  endif.

  clear IT_TAB-FIX_BIN.
  if R_OFFL = 'X'.

    data: V_FIX_BIN type /SCWM/BINMAT-LGPLA.
    clear V_FIX_BIN.

*    select single LGPLA as FIX_BIN "LGTYP as NLTYP
*      from /SCWM/BINMAT
*      into corresponding fields of IT_TAB
*      where MATNR = IT_TAB-MATNR.

    select LGPLA
      from /SCWM/BINMAT
      into V_FIX_BIN
      where MATNR    = IT_TAB-MATNR    and
            ENTITLED = IT_TAB-ENTITLED.

      concatenate IT_TAB-FIX_BIN V_FIX_BIN
             into IT_TAB-FIX_BIN separated by ', '.

*      do 10 times.
*        replace '  ' into IT_TAB-FIX_BIN with ' '.
*      enddo.
*      condense IT_TAB-FIX_BIN no-gaps.
*      replace ','   into IT_TAB-FIX_BIN with ', '.
*      replace ' , ' into IT_TAB-FIX_BIN with ', '.
    endselect.
    shift IT_TAB-FIX_BIN left deleting leading ', '.

    if IT_TAB-FIX_BIN is initial.
*DATA INPUT  TYPE CLIKE.
*DATA OUTPUT TYPE CLIKE.
      data V_MATNR type /SCWM/BINMAT-MATNR.
      clear V_MATNR.

      call function 'CONVERSION_EXIT_ALPHA_INPUT'
        exporting
          INPUT  = IT_TAB-MATNR
        importing
          OUTPUT = V_MATNR.

      select LGPLA
        from /SCWM/BINMAT
        into V_FIX_BIN
        where MATNR    = V_MATNR         and
              ENTITLED = IT_TAB-ENTITLED.

        concatenate IT_TAB-FIX_BIN V_FIX_BIN
               into IT_TAB-FIX_BIN separated by ', '.

      endselect.
      shift IT_TAB-FIX_BIN left deleting leading ', '.
    endif.
*    condense IT_TAB-FIX_BIN no-gaps.
*  do 4 times.
*    replace all occurrences of ',' in IT_TAB-FIX_BIN with ', '.
*  enddo.
*    shift IT_TAB-FIX_BIN left deleting leading SPACE.

  endif.

*********************************************************************
*********************************************************************
*  if IT_TAB-QDOCID is initial and IT_TAB-RDOCID is initial.
*  endif.

  if IT_TAB-QDOCID is not initial or IT_TAB-RDOCID is not initial.
    data :
      LT_DOCID        type /SCWM/DLV_DOCID_ITEM_TAB,
      LS_INCLUDE      type /SCWM/DLV_QUERY_INCL_STR_PRD,
      LT_HEADERS      type /SCWM/DLV_HEADER_OUT_PRD_TAB with header line,
      LT_ITEMS        type /SCWM/DLV_ITEM_OUT_PRD_TAB,
      LT_ITEMS_TO     type /SCWM/DLV_ITEM_OUT_TO_PRD_TAB,
      LO_STATUS_PPF   type ref to /SCWM/CL_DLV_MANAGEMENT_PRD,
      IS_READ_OPTIONS type /SCWM/DLV_QUERY_CONTR_STR,

      WA_REFDOC       type /SCDL/DL_REFDOC_STR,
      WA_PARTYLOC     type /SCDL/DL_PARTYLOC_STR,

      LS_DOCID        type line of /SCWM/DLV_DOCID_ITEM_TAB,
      LV_DOCID        type /SCWM/DLV_DOCID_ITEM_STR-DOCID,
      LV_DOCCAT       type /SCWM/DLV_DOCID_ITEM_STR-DOCCAT.

*Here please mark the ones you need. Comment the ones you do not need.
    LS_INCLUDE-HEAD_PARTYLOC = 'X'.     "_DATA
    LS_INCLUDE-HEAD_REFDOC   = 'X'.     "_DATA
*LS_INCLUDE-HEAD_DATE     = 'X'.     "_DATA
*LS_INCLUDE-HEAD_ADDMEAS  = 'X'.     "_DATA
*LS_INCLUDE-ITEM_REFDOC   = 'X'.     "_DATA

    create object LO_STATUS_PPF.

    if IT_TAB-RDOCID is not initial.
      LV_DOCID       = IT_TAB-RDOCID.
    endif.

    if IT_TAB-QDOCID is not initial.
      LV_DOCID       = IT_TAB-QDOCID.
    endif.

    LS_DOCID-DOCID = LV_DOCID.

    append LS_DOCID to LT_DOCID.

*IS_READ_OPTIONS-MDCTRL-ADDRESS = 'X'.
*IS_READ_OPTIONS-MDCTRL-TEXT    = 'X'.

    try.

        call method LO_STATUS_PPF->QUERY(
          exporting
            IT_DOCID        = LT_DOCID
            IV_DOCCAT       = LV_DOCCAT
            IS_INCLUDE_DATA = LS_INCLUDE "_DATA
            IS_READ_OPTIONS = IS_READ_OPTIONS
          importing
            ET_HEADERS      = LT_HEADERS[]
            ET_ITEMS        = LT_ITEMS
            ET_ITEMS_TO     = LT_ITEMS_TO ).

      catch /SCDL/CX_DELIVERY. " ( ).

    endtry.

    if LT_HEADERS[] is not initial.
      read table LT_HEADERS index 1.
      check SY-SUBRC = 0.

      read table LT_HEADERS-REFDOC[] into WA_REFDOC
        with key REFDOCCAT = 'ERP'.
      if SY-SUBRC = 0.

        if C_COLDLV = ''.
          IT_TAB-ERP_DLV = WA_REFDOC-REFDOCNO.

        else.
          if not V_DLV cs WA_REFDOC-REFDOCNO.
*        IT_TAB-ERP_DLV = WA_REFDOC-REFDOCNO.
            concatenate V_DLV WA_REFDOC-REFDOCNO
            into IT_TAB-ERP_DLV separated by ', ' .
            V_DLV = IT_TAB-ERP_DLV.
            shift V_DLV right deleting trailing ','.
            shift V_DLV left  deleting leading  ', '.
          endif.
        endif.
      endif.

      data: V_NAME2 type BUT000-MC_NAME2,
            V_NAME1 type BUT000-MC_NAME1.

      clear: V_NAME2, V_NAME1.

      read table LT_HEADERS-PARTYLOC[] into WA_PARTYLOC
        with key PARTY_ROLE = 'STPRT'. "Ship-To Party
      if SY-SUBRC = 0.

        select single MC_NAME1 MC_NAME2
          from BUT000
          into: (V_NAME1, V_NAME2)
          where PARTNER = WA_PARTYLOC-PARTYNO.

        concatenate V_NAME1 V_NAME2 into IT_TAB-PARTY_TEXT
        separated by SPACE.

*        IT_TAB-PARTY_TEXT = WA_PARTYLOC-PARTY_TEXT.

      endif.

      read table LT_HEADERS-PARTYLOC[] into WA_PARTYLOC
        with key PARTY_ROLE = 'SFPRT'. "Ship-From Party
      if SY-SUBRC = 0.

        select single MC_NAME1 MC_NAME2
          from BUT000
          into: (V_NAME1, V_NAME2)
          where PARTNER = WA_PARTYLOC-PARTYNO.

        concatenate V_NAME1 V_NAME2 into IT_TAB-PARTY_TEXT
        separated by SPACE.

*        IT_TAB-PARTY_TEXT = WA_PARTYLOC-PARTY_TEXT.

      endif.


    endif.
  endif.

endform.

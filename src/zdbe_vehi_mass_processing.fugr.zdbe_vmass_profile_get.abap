FUNCTION ZDBE_VMASS_PROFILE_GET .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PROTOKOLL_AB_DATUM_IV) LIKE  SY-DATUM
*"     REFERENCE(PROTOKOLL_AB_UZEIT_IV) LIKE  SY-UZEIT
*"  EXPORTING
*"     VALUE(DISPLAY_PROFILE_ES) TYPE  BAL_S_PROF
*"--------------------------------------------------------------------

  DATA: L_S_SORT  TYPE BAL_S_SORT,
        L_S_FCAT  TYPE BAL_S_FCAT.

  DATA: DATUM_LV(10) TYPE C,
        UZEIT_LV(8) TYPE C.

  DATA: TITLE_STRING_LV TYPE BAL_S_PROF-TITLE.

  WRITE PROTOKOLL_AB_DATUM_IV TO DATUM_LV.
  UZEIT_LV      = PROTOKOLL_AB_UZEIT_IV(2).
  UZEIT_LV+2(1) = ':'.
  UZEIT_LV+3(2) = PROTOKOLL_AB_UZEIT_IV+2(2).
  UZEIT_LV+5(1) = ':'.
  UZEIT_LV+6(2) = PROTOKOLL_AB_UZEIT_IV+4(2).

  CONCATENATE TEXT-001 UZEIT_LV TEXT-003 INTO TITLE_STRING_LV
              SEPARATED BY ' '.


**********************************************************************
* define some standard parameters
**********************************************************************
  DISPLAY_PROFILE_ES-LANGU        = SY-LANGU.
  DISPLAY_PROFILE_ES-TITLE        = TITLE_STRING_LV.
  DISPLAY_PROFILE_ES-HEAD_TEXT    = TEXT-002.   "Uhrzeit, Aktion
  DISPLAY_PROFILE_ES-HEAD_SIZE    = 45.
  DISPLAY_PROFILE_ES-EXP_LEVEL    = 0.
  DISPLAY_PROFILE_ES-TREE_ONTOP   = NOFLAG_GC.
  DISPLAY_PROFILE_ES-TREE_ADJST   = XFLAG_GC.
  DISPLAY_PROFILE_ES-TREE_SIZE    = 27.
  DISPLAY_PROFILE_ES-SHOW_ALL     = NOFLAG_GC.
  DISPLAY_PROFILE_ES-USE_GRID     = XFLAG_GC.
*  DISPLAY_PROFILE_ES-CWIDTH_OPT   = XFLAG_GC.


**********************************************************************
* macro to simplify creation of field catalog entry
**********************************************************************
  DEFINE MACRO_ADD_FIELDS.
    CLEAR L_S_FCAT.
    L_S_FCAT-REF_TABLE = &5.
    IF &2 = 0.
      L_S_FCAT-NO_OUT    = XFLAG_GC.
    ELSE.
      L_S_FCAT-COL_POS   = &2.
    ENDIF.
    L_S_FCAT-IS_TREECOL = &3.
    L_S_FCAT-REF_FIELD  = &4.
    L_S_FCAT-OUTPUTLEN  = &6.
    L_S_FCAT-CLTXT_ADD  = &7.
    L_S_FCAT-COLDDICTXT = &8.
    APPEND L_S_FCAT TO DISPLAY_PROFILE_ES-&1_FCAT.
  END-OF-DEFINITION.


**********************************************************************
* define fields in tree and list
**********************************************************************
  MACRO_ADD_FIELDS:

* Level/Column/InList/FieldName/Tablename/Length/AddColumnText/DDICText

*--> LEV1
  LEV1  0  NOFLAG_GC 'LOG_HANDLE' 'BAL_S_SHOW'   0   NOFLAG_GC   ' ',
  LEV1  3  XFLAG_GC  'ALDATE'     'BAL_S_SHOW'  20   NOFLAG_GC   ' ',
  LEV1  1  NOFLAG_GC 'ALTIME'     'BAL_S_SHOW'  10   NOFLAG_GC   ' ',
  LEV1  4  XFLAG_GC  'ALUSER'     'BAL_S_SHOW'  20   NOFLAG_GC   ' ',
  LEV1  2  NOFLAG_GC 'EXTNUMBER'  'BAL_S_SHOW'  60   NOFLAG_GC   'R',
  LEV1  5  XFLAG_GC  'T_OBJECT'   'BAL_S_SHOW'  20   NOFLAG_GC   'R',
  LEV1  6  XFLAG_GC  'T_SUBOBJ'   'BAL_S_SHOW'  20   NOFLAG_GC   'R',
  LEV1  7  XFLAG_GC  'ALTCODE'    'BAL_S_SHOW'  14   NOFLAG_GC   'R',
  LEV1  8  XFLAG_GC  'ALPROG'     'BAL_S_SHOW'  15   NOFLAG_GC   ' ',
  LEV1  9  XFLAG_GC  'T_ALMODE'   'BAL_S_SHOW'  15   NOFLAG_GC   ' ',
  LEV1 10  XFLAG_GC  'LOGNUMBER'  'BAL_S_SHOW'  25   NOFLAG_GC   ' ',


*--> LEV2
*  LEV2  0  NOFLAG_GC 'PROBCLASS'  'BAL_S_SHOW'   0   NOFLAG_GC   ' ',
*  LEV2  1  NOFLAG_GC 'T_PROBCLSS' 'BAL_S_SHOW'   0   NOFLAG_GC   'R',

*--> MESS
  MESS  0  NOFLAG_GC 'LOGNUMBER'  'BAL_S_SHOW'    0   NOFLAG_GC   ' ',
  MESS  0  NOFLAG_GC 'MSGNUMBER'  'BAL_S_SHOW'    0   NOFLAG_GC   ' ',
  MESS  1  NOFLAG_GC 'T_MSG'      'BAL_S_SHOW'   72   NOFLAG_GC   ' ',
  MESS  0  NOFLAG_GC 'MSGTY'      'BAL_S_SHOW'    0   NOFLAG_GC   ' ',
  MESS  0  NOFLAG_GC 'MSGID'      'BAL_S_SHOW'    0   NOFLAG_GC   ' ',
  MESS  0  XFLAG_GC  'MSGNO'      'BAL_S_SHOW'    0   NOFLAG_GC   ' ',
  MESS  0  NOFLAG_GC 'DETLEVEL'   'BAL_S_SHOW'    0   NOFLAG_GC   ' ',
  MESS  0  NOFLAG_GC 'T_PROBCLSS' 'BAL_S_SHOW'    0   NOFLAG_GC   ' ',
  MESS  0  NOFLAG_GC 'ALSORT'     'BAL_S_SHOW'    0   NOFLAG_GC   ' ',
  MESS  0  NOFLAG_GC 'MSG_COUNT'  'BAL_S_SHOW'    0   NOFLAG_GC   ' ',
  MESS  2  XFLAG_GC  'VHCLE'      'VLCMSGCONTXT' 12   NOFLAG_GC   'S',
  MESS  3  XFLAG_GC  'VHCEX'      'VLCMSGCONTXT' 20   NOFLAG_GC   'S',
  MESS  4  XFLAG_GC  'VHVIN'      'VLCMSGCONTXT' 20   NOFLAG_GC   'S'.


**********************************************************************
* macro to define sort sequences
**********************************************************************
  DEFINE MACRO_ADD_SORT_FIELD.
    CLEAR L_S_SORT.
    L_S_SORT-SPOS      = &2.
    L_S_SORT-REF_TABLE = 'BAL_S_SHOW'.
    L_S_SORT-REF_FIELD = &3.
    IF &4 = XFLAG_GC.
      L_S_SORT-UP        = &4.
    ELSE.
      L_S_SORT-DOWN      = &4.
    ENDIF.
    APPEND L_S_SORT TO DISPLAY_PROFILE_ES-&1_SORT.
  END-OF-DEFINITION.


**********************************************************************
* define sort sequences
**********************************************************************
  MACRO_ADD_SORT_FIELD:
*   level  sortpos  fieldname   up
    LEV1   1        'ALDATE'    XFLAG_GC,
    LEV1   2        'ALTIME'    XFLAG_GC,
    LEV1   3        'ALUSER'    XFLAG_GC,
    LEV2   1        'PROBCLASS' XFLAG_GC.


**********************************************************************
* define color for problem class 1
**********************************************************************
  DISPLAY_PROFILE_ES-COLORS-PROBCLASS1 = '3'. "COL_HEADING
  DISPLAY_PROFILE_ES-COLORS-PROBCLASS3 = '3'. "COL_HEADING

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Report Z_BUT020_BUT021_FS_INCONSIST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_BUT020_BUT021_FS_INCONSIST.


Tables : but000.

SELECTION-SCREEN
          BEGIN OF BLOCK b_partners
          WITH FRAME TITLE b_text1.

SELECT-OPTIONS: BP_Num FOR but000-partner.

SELECTION-SCREEN
          END OF BLOCK b_partners.

SELECTION-SCREEN

          BEGIN OF BLOCK b_testrun
          WITH FRAME TITLE b_text3.

 PARAMETERS: testrun TYPE c AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN
          END OF BLOCK b_testrun.


 DATA: lt_but021_fs TYPE TABLE OF but021_fs,
       ls_but020 TYPE but020,
       lt_but021_fs_del TYPE TABLE OF but021_fs,
       lt_but020 TYPE TABLE OF  but020,
       wa TYPE but021_fs.

 SELECT * FROM but021_fs INTO TABLE lt_but021_fs where partner in BP_Num.

 SELECT * FROM but020 INTO TABLE lt_but020 where partner in BP_Num.
   SORT lt_but020 by addrnumber.

 WRITE : / 'Inconsistent partners are listed below'.
 WRITE : /, /  'BP Number', 'Address Number'.
     loop at lt_but021_fs into wa.
       READ TABLE lt_but020 INTO ls_but020
          WITH KEY addrnumber = wa-addrnumber BINARY SEARCH.

   IF sy-subrc <> 0.
     APPEND wa to lt_but021_fs_del.
     WRITE: / wa-partner, wa-addrnumber.
   ENDIF.
   ENDLOOP.

   CLEAR: wa.

    IF  testrun <> 'X'.
       DELETE but021_fs from table lt_but021_fs_del.
      WRITE: /, / ' THE DATABASE IS UPDATED'.
    ELSE.
      WRITE: /, / ' THE DATABASE IS NOT UPDATED'.
    ENDIF.

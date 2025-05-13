*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF31 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIND_TAB_TEXT_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form F_FIND_TAB_TEXT_SET .

  DATA: lv_icontext(128) TYPE c.
*        lv_icontext2(128) TYPE c.
  IF gv_mass_search_filled IS NOT INITIAL.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                        = 'ICON_DISPLAY_MORE'
       text                        = 'Find'(fnd)
       INFO                        = 'Find'(fnd)
*       ADD_STDINF                  = 'X'
     IMPORTING
       RESULT                      = lv_icontext
     EXCEPTIONS
       ICON_NOT_FOUND              = 1
       OUTPUTFIELD_TOO_SHORT       = 2
       OTHERS                      = 3
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                        = 'ICON_ENTER_MORE'
       text                        = 'Find'(fnd)
       INFO                        = 'Find'(fnd)
*       ADD_STDINF                  = 'X'
     IMPORTING
       RESULT                      = lv_icontext
     EXCEPTIONS
       ICON_NOT_FOUND              = 1
       OUTPUTFIELD_TOO_SHORT       = 2
       OTHERS                      = 3
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
*  IF gv_extsearch_filled IS NOT INITIAL.
*    CALL FUNCTION 'ICON_CREATE'
*      EXPORTING
*        name                        = 'ICON_DISPLAY_MORE'
*       text                        = 'Extended Vehicle Search'(evs)
*       INFO                        = 'Extended Vehicle Search'(evs)
**       ADD_STDINF                  = 'X'
*     IMPORTING
*       RESULT                      = lv_icontext2
*     EXCEPTIONS
*       ICON_NOT_FOUND              = 1
*       OUTPUTFIELD_TOO_SHORT       = 2
*       OTHERS                      = 3
*             .
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*  ELSE.
*    CALL FUNCTION 'ICON_CREATE'
*      EXPORTING
*        name                        = 'ICON_ENTER_MORE'
*       text                        = 'Extended Vehicle Search'(evs)
*       INFO                        = 'Extended Vehicle Search'(evs)
**       ADD_STDINF                  = 'X'
*     IMPORTING
*       RESULT                      = lv_icontext2
*     EXCEPTIONS
*       ICON_NOT_FOUND              = 1
*       OUTPUTFIELD_TOO_SHORT       = 2
*       OTHERS                      = 3
*              .
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*  ENDIF.
  suche_tab = lv_icontext.
*  searchtab2 = lv_icontext2.

endform.                    " F_FIND_TAB_TEXT_SET

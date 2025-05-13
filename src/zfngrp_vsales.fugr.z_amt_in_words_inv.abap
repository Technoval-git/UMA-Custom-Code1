FUNCTION z_amt_in_words_inv.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(AMOUNT)
*"     REFERENCE(CURRENCY) TYPE  WAERS
*"     REFERENCE(LANGUAGE) TYPE  LANGU
*"  EXPORTING
*"     REFERENCE(AMT_IN_WORDS) TYPE  STRING
*"----------------------------------------------------------------------
* This function module will return the amount in words with units and subunits
* as maintained in the custom table ZJET_CURT
*"----------------------------------------------------------------------
  DATA:
    lv_words TYPE spell,
    wacurt   TYPE zjet_curtab.


  IF amount IS NOT INITIAL AND currency IS NOT INITIAL AND language IS NOT INITIAL.
    SELECT SINGLE * FROM zjet_curtab INTO wacurt WHERE zlang = language AND zcurr = currency.
    CALL FUNCTION 'SPELL_AMOUNT'
      EXPORTING
        amount    = amount
        currency  = currency
*       FILLER    = ' '
        language  = language "SY-LANGU
      IMPORTING
        in_words  = lv_words
      EXCEPTIONS
        not_found = 1
        too_large = 2
        OTHERS    = 3.
    IF sy-subrc <> 0.
*       Implement suitable error handling here
    ELSE.
      IF wacurt  IS NOT INITIAL.
        IF lv_words-decword NE 'ZERO'.
          amt_in_words = |{ wacurt-zprefix } { lv_words-word } { wacurt-zunit_text } { wacurt-zand } { lv_words-decword } { wacurt-zsubunit_text } { wacurt-zonly } |.
        ELSE.
          amt_in_words = |{ wacurt-zprefix } { lv_words-word } { wacurt-zunit_text } { wacurt-zonly }|.
        ENDIF.

      ELSE." if the table is not maintained for the currency
        amt_in_words = |{ wacurt-zprefix } { lv_words-word } Saudi Riyal and { lv_words-decword } Halala only  - Amount includes VAT|.
        IF language = 'A'.
*        amt_in_words = |{ wacurt-zprefix } { lv_words-word } ريال السعودي and { lv_words-decword } شامل ضريبة القيمة المضافة - هللة فقط |.
          amt_in_words = |{ wacurt-zprefix } { lv_words-word } ريال السعودي  و { lv_words-decword } هلله لا غير - المبلغ يشمل ضريبة القيمة المضافة |.
*          amt_in_words = |{ wacurt-zprefix } { lv_words-word }  ريال سعودي و  هلله لا غير - المبلغ يشمل ضريبة القيمة المضافة |.
        ENDIF.
      ENDIF.
    ENDIF.

  ELSE.

  ENDIF.
  CONDENSE amt_in_words.
*SHIFT amt_in_words LEFT DELETING LEADING ' '.

ENDFUNCTION.

FUNCTION zmm_amount_to_words.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(AMOUNT) TYPE  BWERT
*"     REFERENCE(WAERS) TYPE  WAERS
*"  EXPORTING
*"     REFERENCE(A_WORD) TYPE  STRING
*"----------------------------------------------------------------------

  DATA in_wordslv LIKE spell.
  DATA in_wordsdec LIKE spell.
  DATA: int_part TYPE i.
  DATA: deci_part TYPE bwert,
        len       TYPE i.

  int_part = trunc( amount ).
  deci_part = frac( amount ).

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = int_part
      currency  = ' '
      filler    = ' '
      language  = sy-langu
    IMPORTING
      in_words  = in_wordslv
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  IF deci_part IS NOT INITIAL OR deci_part <> 00.
    CALL FUNCTION 'SPELL_AMOUNT'
      EXPORTING
        amount    = deci_part
        currency  = ' '
        filler    = ' '
        language  = sy-langu
      IMPORTING
        in_words  = in_wordsdec
      EXCEPTIONS
        not_found = 1
        too_large = 2
        OTHERS    = 3.
    IF waers = 'SAR'.
      CONCATENATE 'Total net value of' in_wordslv-word 'Saudi Riyal and' in_wordsdec-word 'Halala only.' INTO a_word SEPARATED BY ' '.
    ELSEIF waers = 'AED'.
      CONCATENATE 'Total net value of' in_wordslv-word 'Dirham and' in_wordsdec-word 'Fills only.' INTO a_word SEPARATED BY ' '.
    ELSE.

      CONCATENATE 'Total net value of' in_wordslv-word  in_wordsdec-word  INTO a_word SEPARATED BY ' '.
    ENDIF.
  ELSE.
    IF waers = 'SAR'.
      CONCATENATE 'Total net value of' in_wordslv-word 'Saudi Riyal only.' INTO a_word SEPARATED BY ' '.
    ELSEIF waers = 'AED'.
      CONCATENATE 'Total net value of' in_wordslv-word 'Dirham only.' INTO a_word SEPARATED BY ' '.

    ELSE.
      CONCATENATE 'Total net value of' in_wordslv-word  INTO a_word SEPARATED BY ' '.
    ENDIF.
  ENDIF.




ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Include          ZMM_PC_INFO_SUB
*&---------------------------------------------------------------------*
IF ltt_eina[] IS NOT INITIAL.

*lv_timess = '0.2'.

*this logic is because eine_indx is 2 digit only that is max 99.

  DESCRIBE TABLE ltt_eine LINES d1.
  v3 = d1.
  DO d1 TIMES.
    IF v3 < 99.
      CONTINUE.
    ENDIF.

    v1 = v1 + '01'.
**  update ltt_eine

    LOOP AT ltt_eina INTO ls_eina.

      APPEND ls_eina TO l3t_eina.
      DELETE  ltt_eina INDEX 1.
      EXIT.
    ENDLOOP.


    LOOP AT ltt_einax INTO ls_einax.
      APPEND ls_einax TO l3t_einax.
      DELETE  ltt_einax INDEX  1.
      EXIT.
    ENDLOOP.

    LOOP AT ltt_eine INTO ls_eine.
      lv_new = v1.
      ls_eine-eine_indx =  lv_new .
      APPEND ls_eine TO l3t_eine.
      DELETE  ltt_eine  INDEX  1.
      EXIT.
    ENDLOOP.

    LOOP AT ltt_einex INTO ls_einex.
      lv_new = v1.
      ls_einex-eine_indx =  lv_new .
      APPEND ls_einex TO l3t_einex.
      DELETE  ltt_einex  INDEX  1.

      EXIT.
    ENDLOOP.

    LOOP AT ltt_cond_validity INTO ls_cond_validity.
      lv_new = v1.
      ls_cond_validity-eine_indx = lv_new .
      APPEND ls_cond_validity TO l3t_cond_validity.
      DELETE  ltt_cond_validity  INDEX  1.
      EXIT.
    ENDLOOP.

    LOOP AT ltt_condition INTO ls_condition.
      lv_new = v1.
      ls_condition-eine_indx =  lv_new .
      APPEND ls_condition TO l3t_condition.
      DELETE  ltt_condition  INDEX 1.
      EXIT.
    ENDLOOP.


    IF v1 = 99.
      v2 = v2 + 99.
      v3 = d1 - v2.



      CALL FUNCTION 'ME_INFORECORD_MAINTAIN_MULTI'
*        EXPORTING
*          testrun       = 'X'
        IMPORTING
          et_eina       = im_eina
          et_eine       = im_eine
        TABLES
          t_eina        = l3t_eina
          t_einax       = l3t_einax
          t_eine        = l3t_eine
          t_einex       = l3t_einex
          cond_validity = l3t_cond_validity
          condition     = l3t_condition
          return        = lt_return.
      CLEAR : l3t_eina,l3t_einax, l3t_eine, l3t_einex,l3t_cond_validity,l3t_condition,im_eina,im_eine.

      CLEAR v1.
    ENDIF.
  ENDDO.


  DO v3 TIMES..

*    update ltt_eine
    IF sy-index = v3.

      LOOP AT ltt_eina INTO ls_eina.
        APPEND ls_eina TO l3t_eina.
        DELETE  ltt_eina INDEX 1.
      ENDLOOP.
      LOOP AT ltt_einax INTO ls_einax.
        APPEND ls_einax TO l3t_einax.
        DELETE  ltt_einax INDEX 1.
      ENDLOOP.


      lv_indx =  01."1.
      CLEAR ls_eine.
      LOOP AT ltt_eine INTO ls_eine.
        lv_new = lv_indx.
        ls_eine-eine_indx = lv_new. "lv_indx.
        APPEND ls_eine TO l3t_eine.
        DELETE  ltt_eine  INDEX 1.
        lv_indx = lv_indx +  01.
      ENDLOOP.
      lv_indx =  01. "1.
      CLEAR ls_einex.
      LOOP AT ltt_einex INTO ls_einex.
        lv_new = lv_indx.
        ls_einex-eine_indx =  lv_new. "lv_indx.
        APPEND ls_einex TO l3t_einex.
        DELETE  ltt_einex  INDEX 1.
        lv_indx = lv_indx +  01.  "1.
      ENDLOOP.
      lv_indx =  01. "1.
      CLEAR ls_cond_validity.
      LOOP AT ltt_cond_validity INTO ls_cond_validity.
        lv_new = lv_indx.
        ls_cond_validity-eine_indx =   lv_new. "lv_indx.
        APPEND ls_cond_validity TO l3t_cond_validity.
        DELETE  ltt_cond_validity  INDEX 1.
        lv_indx = lv_indx +  01."1.
      ENDLOOP.

      lv_indx =  01."1.
      CLEAR ls_condition.
      LOOP AT ltt_condition INTO ls_condition.
        lv_new = lv_indx.
        ls_condition-eine_indx =  lv_new. "lv_indx.
        APPEND ls_condition TO l3t_condition.
        DELETE  ltt_condition  INDEX 1.
        lv_indx = lv_indx +  01."1.
      ENDLOOP.



*      call function
      CALL FUNCTION 'ME_INFORECORD_MAINTAIN_MULTI'
*        EXPORTING
*          testrun       = 'X'
        IMPORTING
          et_eina       = im_eina
          et_eine       = im_eine
        TABLES
          t_eina        = l3t_eina
          t_einax       = l3t_einax
          t_eine        = l3t_eine
          t_einex       = l3t_einex
          cond_validity = l3t_cond_validity
          condition     = l3t_condition
          return        = lt_return.
      CLEAR : l3t_eina,l3t_einax, l3t_eine, l3t_einex,l3t_cond_validity,l3t_condition,im_eina,im_eine.
    ENDIF.

  ENDDO.

ENDIF.

DELETE lt_return WHERE type = 'W'.

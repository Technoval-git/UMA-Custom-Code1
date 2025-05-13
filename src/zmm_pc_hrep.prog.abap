*----------------------------------------------------------------------*
***INCLUDE ZMM_PC_HREP.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zmm_pc_hrep
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zmm_pc_hrep .

  TYPES: BEGIN OF ty_chglog,
           matnr     TYPE zpc_matnr-pc_matnr,
           username  TYPE cdhdr-username,
           udate     TYPE cdhdr-udate,
           utime     TYPE cdhdr-utime,
           fname     TYPE cdpos-fname,
           value_new TYPE zmm_value_new,
           value_old TYPE zmm_value_old,
         END OF ty_chglog.
  DATA lw_chglog TYPE ty_chglog.
  DATA lt_chglog TYPE STANDARD TABLE OF ty_chglog.

  DATA lv_cat TYPE char2.

  DATA fdate TYPE sy-datum.
  DATA lv_objcls TYPE cdhdr-objectclas VALUE 'ZMM_HQ'.

  CALL FUNCTION 'OIUPR_DATE_SUBTRACT_MONTH'
    EXPORTING
      date   = sy-datum
      months = 2
    IMPORTING
      date_e = fdate.



*  LOOP AT s_matnr.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = s_matnr-low
*      IMPORTING
*        output = s_matnr-low.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = s_matnr-high
*      IMPORTING
*        output = s_matnr-high.
*    MODIFY s_matnr INDEX sy-tabix.
*  ENDLOOP.

  IF p_GM = 'X'.

    SELECT a~objectclas, a~objectid, a~username, a~udate, a~utime,
        b~fname, b~value_new, b~value_old  INTO TABLE @DATA(lt_gm)
      FROM cdhdr AS a INNER JOIN cdpos AS b
      ON a~objectclas = b~objectclas AND
         a~objectid = b~objectid AND
         a~changenr = b~changenr
        WHERE a~objectclas = @lv_objcls   "'ZMM_HQ'
          AND a~objectid IN @s_matnr
          AND b~chngind = 'U' AND b~tabname = 'ZMM_GM'
          AND a~udate >= @fdate
          AND a~Tcode = 'ZMM_PRICE_CATALOG'.
       lt_chglog = VALUE #( FOR wa1 IN lt_gm
                      ( CORRESPONDING #( wa1 MAPPING
                        matnr = objectid
                        username = username
                        udate = udate
                        utime = utime
                        fname = fname
                        value_new = value_new
                        value_old = value_old
                        ) ) ).
  ELSEIF p_AC = 'X'.

    SELECT a~objectclas, a~objectid, a~username, a~udate, a~utime,
        b~fname, b~value_new, b~value_old  INTO TABLE @DATA(lt_ac)
      FROM cdhdr AS a INNER JOIN cdpos AS b
      ON a~objectclas = b~objectclas AND
         a~objectid = b~objectid AND
         a~changenr = b~changenr
        WHERE a~objectclas = @lv_objcls   "'ZMM_HQ'
          AND a~objectid IN @s_matnr
          AND b~chngind = 'U' AND b~tabname = 'ZMM_AC'
          AND a~udate >= @fdate
          AND a~Tcode = 'ZMM_PRICE_CATALOG'.
       lt_chglog = VALUE #( FOR wa2 IN lt_ac
                      ( CORRESPONDING #( wa2 MAPPING
                        matnr = objectid
                        username = username
                        udate = udate
                        utime = utime
                        fname = fname
                        value_new = value_new
                        value_old = value_old
                        ) ) ).
  ELSEIF p_hq = 'X'.

    SELECT a~objectclas, a~objectid, a~username, a~udate, a~utime,
        b~fname, b~value_new, b~value_old  INTO TABLE @DATA(lt_hq)
      FROM cdhdr AS a INNER JOIN cdpos AS b
      ON a~objectclas = b~objectclas AND
         a~objectid = b~objectid AND
         a~changenr = b~changenr
        WHERE a~objectclas = @lv_objcls   "'ZMM_HQ'
          AND a~objectid IN @s_matnr
          AND b~chngind = 'U'  AND b~tabname = 'ZMM_HQ'
          AND a~udate >= @fdate
          AND a~Tcode = 'ZMM_PRICE_CATALOG'.
       lt_chglog = VALUE #( FOR wa3 IN lt_hq
                      ( CORRESPONDING #( wa3 MAPPING
                        matnr = objectid
                        username = username
                        udate = udate
                        utime = utime
                        fname = fname
                        value_new = value_new
                        value_old = value_old
                        ) ) ).

   ELSEIF p_df = 'X'.

    SELECT a~objectclas, a~objectid, a~username, a~udate, a~utime,
        b~fname, b~value_new, b~value_old  INTO TABLE @DATA(lt_df)
      FROM cdhdr AS a INNER JOIN cdpos AS b
      ON a~objectclas = b~objectclas AND
         a~objectid = b~objectid AND
         a~changenr = b~changenr
        WHERE a~objectclas = @lv_objcls   "'ZMM_HQ'
          AND a~objectid IN @s_matnr
          AND b~chngind = 'U' AND b~tabname = 'ZMM_DF'
          AND a~udate >= @fdate
          AND a~Tcode = 'ZMM_PRICE_CATALOG'.
       lt_chglog = VALUE #( FOR wa4 IN lt_df
                      ( CORRESPONDING #( wa4 MAPPING
                        matnr = objectid
                        username = username
                        udate = udate
                        utime = utime
                        fname = fname
                        value_new = value_new
                        value_old = value_old
                        ) ) ).
   ELSEIF p_ma = 'X'.

    SELECT a~objectclas, a~objectid, a~username, a~udate, a~utime,
        b~fname, b~value_new, b~value_old  INTO TABLE @DATA(lt_ma)
      FROM cdhdr AS a INNER JOIN cdpos AS b
      ON a~objectclas = b~objectclas AND
         a~objectid = b~objectid AND
         a~changenr = b~changenr
        WHERE a~objectclas = @lv_objcls   "'ZMM_HQ'
          AND a~objectid IN @s_matnr
          AND b~chngind = 'U' AND b~tabname = 'ZMM_MA'
          AND a~udate >= @fdate
          AND a~Tcode = 'ZMM_PRICE_CATALOG'.
       lt_chglog = VALUE #( FOR wa5 IN lt_df
                      ( CORRESPONDING #( wa5 MAPPING
                        matnr = objectid
                        username = username
                        udate = udate
                        utime = utime
                        fname = fname
                        value_new = value_new
                        value_old = value_old
                        ) ) ).
  ENDIF.



  CALL FUNCTION 'ZMM_ALV_POPUP'
    EXPORTING
      i_start_column = 5
      i_start_line   = 5
      i_end_column   = 200
      i_end_line     = 100
      i_title        = 'ALV'
      i_popup        = 'X'
    TABLES
      it_alv         = lt_chglog.



ENDFORM.

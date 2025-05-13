*&---------------------------------------------------------------------*
*& Report ZSD_SALSE_ORG_EXTEND
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsd_salse_org_extend.

DATA : lv_knvv    TYPE knvv,
       lv_knvp    TYPE knvp,
       ltt_knvv   TYPE STANDARD TABLE OF knvv,
       it_knvv_01 TYPE STANDARD TABLE OF knvv.



PARAMETERS : p_date TYPE sy-datum DEFAULT sy-datum.
PARAMETERS : p_usr TYPE sy-uname DEFAULT 'RFCUSER'.


START-OF-SELECTION.

  SELECT *
     FROM zsd_sales_orgs
  INTO TABLE @DATA(sales_orgs_range).                   "#EC CI_NOWHERE

  SELECT *
    FROM knvv
    INTO TABLE @DATA(it_knvv)
    WHERE erdat = @p_date
    AND ernam = @p_usr "'RFCUSER'
    AND vtweg = '00'
    AND spart = '00' AND ( vkorg = '1000' OR vkorg = '2100' ).   "#EC CI_ALL_FIELDS_NEEDED

  SELECT parvw FROM tpaer INTO TABLE @DATA(lt_pf) WHERE pargr = 'KAG' AND papfl = 'X'.


*  DATA(it_knvv_01) = it_knvv.                            "#EC CI_SORTED
  LOOP AT it_knvv INTO DATA(lw_knvv).
    lw_knvv-vkbur = ''.
    lw_knvv-vkgrp = ''.
    lw_knvv-vwerk = ''.
    APPEND lw_knvv TO it_knvv_01.
  ENDLOOP.

  SORT it_knvv_01 BY kunnr vkorg.                        "#EC CI_SORTED
  DELETE ADJACENT DUPLICATES FROM it_knvv_01 COMPARING kunnr vkorg. "#EC CI_SORTED


  LOOP AT it_knvv_01 INTO DATA(lwa_knvv) WHERE ( vkorg = '1000' OR vkorg = '2100' ).

    LOOP AT it_knvv INTO DATA(lwa_k_cust) WHERE kunnr = lwa_knvv-kunnr.
      lv_knvv =  lwa_k_cust.
      lv_knvv-vkbur = ''.
      lv_knvv-vkgrp = ''.
      lv_knvv-vwerk = ''.
      LOOP AT sales_orgs_range INTO DATA(lwa_sales_orgs_range) WHERE mainsales_org = lwa_knvv-vkorg.
        IF lwa_sales_orgs_range-sales_org NE lwa_k_cust-vkorg.
          lv_knvv-vkorg = lwa_sales_orgs_range-sales_org.
          INSERT knvv FROM lv_knvv.
          IF sy-subrc = 0.
            CLEAR lv_knvp.
            LOOP AT lt_pf INTO DATA(lw_pf).
              MOVE-CORRESPONDING lv_knvv TO lv_knvp.
              lv_knvp-parvw = lw_pf-parvw.
              lv_knvp-parza = '000'.
              lv_knvp-kunn2 = lv_knvv-kunnr.
              INSERT knvp FROM lv_knvp.
            ENDLOOP.
            APPEND lv_knvv TO ltt_knvv.
          ENDIF.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDLOOP.
      CLEAR lwa_sales_orgs_range.
    ENDLOOP.

    CLEAR lwa_k_cust.
  ENDLOOP.


  IF ltt_knvv[] IS NOT INITIAL.
    CALL FUNCTION 'ZMM_ALV_POPUP'
      EXPORTING
        i_start_column = 5
        i_start_line   = 5
        i_end_column   = 200
        i_end_line     = 100
        i_title        = 'ALV'
        i_popup        = 'X'
      TABLES
        it_alv         = ltt_knvv.
  ENDIF.

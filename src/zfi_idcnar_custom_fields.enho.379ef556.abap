"Name: \PR:RFIDCN_AR_AGING\FO:SPLIT_SCREEN_0101\SE:BEGIN\EI
ENHANCEMENT 0 ZFI_IDCNAR_CUSTOM_FIELDS.
*
  IF gt_mid_output[] IS NOT INITIAL.
    SELECT partner,
           credit_sgmnt,
           xblocked
      INTO TABLE @DATA(lt_ukmbp_cms_sgm)
      FROM ukmbp_cms_sgm
      FOR ALL ENTRIES IN @gt_mid_output
      WHERE partner = @gt_mid_output-kunnr.

    SELECT a~partner, a~bu_group ,b~txt40 FROM but000 AS a INNER JOIN tb002 AS b
     ON a~bu_group = b~bu_group
     FOR ALL ENTRIES IN @gt_mid_output
      WHERE a~partner = @gt_mid_output-kunnr AND b~spras = 'E' INTO TABLE @DATA(lt_bugroup1).
    IF sy-subrc = 0.
      LOOP AT gt_mid_output ASSIGNING FIELD-SYMBOL(<fs_output>).
        READ TABLE lt_bugroup1 INTO DATA(lw_bugroup1) WITH KEY partner = <fs_output>-kunnr.
        IF sy-subrc = 0.
          <fs_output>-bu_group = lw_bugroup1-bu_group.
          <fs_output>-txt40 = lw_bugroup1-txt40.
        ENDIF.

        READ TABLE lt_ukmbp_cms_sgm INTO DATA(ls_ukmbp_cms_sgm)
                       WITH KEY partner = <fs_output>-kunnr
                                credit_sgmnt = <fs_output>-kkber BINARY SEARCH.
        CHECK sy-subrc = 0.
        <fs_output>-xblocked = ls_ukmbp_cms_sgm-xblocked.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDENHANCEMENT.

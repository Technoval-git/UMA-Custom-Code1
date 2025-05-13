"Name: \PR:RFIDCN_AR_AGING\FO:FM_CREATE_ALV\SE:BEGIN\EI
ENHANCEMENT 0 ZFI_IDCNAR_CUSTOM_FIELDS.
IF ut_alv_output[] IS NOT INITIAL.
  DATA: output_t         TYPE STANDARD TABLE OF idcn_s_ar_aging_header,
        lt_ukmbp_cms_sgm TYPE STANDARD TABLE OF ukmbp_cms_sgm,
        lw_ukmbp_cms_sgm TYPE ukmbp_cms_sgm,
        lvcreditseg      TYPE ukm_credit_sgmnt. "ukmbp_cms_sgn-credit_seg.
  output_t[] = ut_alv_output[].
  SELECT * INTO TABLE lt_ukmbp_cms_sgm  FROM ukmbp_cms_sgm
    FOR ALL ENTRIES IN output_t
    WHERE partner = output_t-kunnr.

  SELECT a~partner, a~bu_group ,b~txt40 FROM but000 AS a INNER JOIN tb002 AS b
    ON a~bu_group = b~bu_group
    FOR ALL ENTRIES IN @output_t
     WHERE a~partner = @output_t-kunnr AND b~spras = 'E' INTO TABLE @DATA(lt_bugroup).
  IF sy-subrc = 0.
    SORT output_t BY kunnr kkber.
    LOOP AT output_t ASSIGNING FIELD-SYMBOL(<fs_output>).
      CLEAR lvcreditseg.
      lvcreditseg = <fs_output>-kkber.

      READ TABLE lt_bugroup INTO DATA(lw_bugroup) WITH KEY partner = <fs_output>-kunnr.
      IF sy-subrc = 0.
        <fs_output>-bu_group = lw_bugroup-bu_group.
        <fs_output>-txt40 = lw_bugroup-txt40.
      ENDIF.

      READ TABLE lt_ukmbp_cms_sgm INTO lw_ukmbp_cms_sgm
                     WITH KEY partner = <fs_output>-kunnr
                              credit_sgmnt = lvcreditseg.
      CHECK sy-subrc = 0.
      <fs_output>-xblocked = lw_ukmbp_cms_sgm-xblocked.
    ENDLOOP.
  ENDIF.
  CLEAR: ut_alv_output[],lt_ukmbp_cms_sgm[].
  MOVE-CORRESPONDING output_t[] TO ut_alv_output[].
ENDIF.
ENDENHANCEMENT.

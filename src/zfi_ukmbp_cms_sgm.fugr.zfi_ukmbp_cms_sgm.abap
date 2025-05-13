FUNCTION ZFI_UKMBP_CMS_SGM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      OUTPUT TYPE  ANY
*"----------------------------------------------------------------------

  data lt_ukmbp_cms_sgm type STANDARD TABLE OF ukmbp_cms_sgm.
  data lw_ukmbp_cms_sgm type ukmbp_cms_sgm.




  if output[] is NOT INITIAL.
   SELECT PARTNER,
          CREDIT_SGMNT,
          XBLOCKED
     INTO TABLE lt_ukmbp_cms_sgm
     FROM ukmbp_cms_sgm
     FOR ALL ENTRIES in OUTPUT
     WHERE
     PARTNER = OUTPUT-KUNNR
       AND
      CREDIT_SGMNT = output-kkber.
*   SORT lt_cepct BY prctr.
*     BREAK-POINT.
   IF sy-subrc = 0.
*     LOOP AT ut_alv_output ASSIGNING FIELD-SYMBOL(<fs_output>).
*       READ TABLE lt_ukmbp_cms_sgm INTO lw_ukmbp_cms_sgm
*                      WITH KEY PARTNER = <fs_output>-kunnr
*                               CREDIT_SGMNT = <fs_output>-kkber BINARY SEARCH.
*       CHECK sy-subrc = 0.
*       <fs_output>-XBLOCKED = lw_ukmbp_cms_sgm-XBLOCKED.
*     ENDLOOP.
   ENDIF.


endif.

ENDFUNCTION.

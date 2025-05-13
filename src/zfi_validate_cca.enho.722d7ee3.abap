"Name: \PR:RGGBR000\EX:RGGBR000_02\EI
ENHANCEMENT 0 ZFI_VALIDATE_CCA.
**
* BREAK-POINT.
** if bseg-kkber is  INITIAL.
*
*  B_RESULT = B_TRUE.
*
** endif.
*
*data lv_customer type kunnr.
*types : Begin of ty_ucs,
*        partner  type  ukmbp_cms_sgm-partner,
*        credit_sgmnt type ukmbp_cms_sgm-credit_sgmnt,
*        end of ty_ucs.
* data lt_ucs type STANDARD TABLE OF ty_ucs.
* data ls_ucs type ty_ucs.
*
* select single BUSINESSPARTNER from IBUPACUSTOMER into lv_customer WHERE CUSTOMER = BSEG-KUNNR.
*   select partner credit_sgmnt from ukmbp_cms_sgm into table lt_UCS where partner = lv_customer.
*
*  read table lt_ucs into ls_ucs with key credit_sgmnt = BSEG-KKBER.
*
*  if sy-subrc <> 0 and ls_ucs-credit_sgmnt = '0000'.
*    B_Result = B_TRUE.
*  endif.

ENDENHANCEMENT.

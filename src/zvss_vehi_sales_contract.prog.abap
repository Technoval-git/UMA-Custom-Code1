*&---------------------------------------------------------------------*
*& Report ZVSS_VEHI_SALES_CONTRACT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZVSS_VEHI_SALES_CONTRACT.

INCLUDE ZIVSS_VEHI_SAL_CON_DEC.
INCLUDE ZIVSS_VEHI_SAL_CON_SEL.
INCLUDE ZIVSS_VEHI_SAL_CON_FORM.

START-OF-SELECTION.

PERFORM get_data.

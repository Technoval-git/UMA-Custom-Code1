class ZCL_DBME_KMA_MATC_NAV_BUTTONS definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBME/KMA_IF_MATC_NAV_BUTTONS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DBME_KMA_MATC_NAV_BUTTONS IMPLEMENTATION.


  METHOD /dbme/kma_if_matc_nav_buttons~on_button_click.
*    BREAK-POINT.
SET PARAMETER ID 'MAT' FIELD is_material_data-matnr.
SET PARAMETER ID 'WRK' FIELD is_material_data-werks.
*call TRANSACTION MB5T.
    CASE sy-ucomm.
      WHEN 'BUT06'.  " MB5T

        call TRANSACTION 'MB5T'.
*        SUBMIT rm07mtrb WITH matnr-low = is_material_data-matnr AND RETURN.
      WHEN 'BUT07'.   " MB5B


*        SET PARAMETER ID 'MAT' FIELD is_material_data-matnr.
*        DATA: rspar_tab  TYPE TABLE OF rsparams,
*              rspar_line LIKE LINE OF rspar_tab.
*        rspar_line-selname = 'SELCRIT1'.
*        rspar_line-kind    = 'S'.
*        rspar_line-sign    = 'I'.
*        rspar_line-option  = 'EQ'.
*        rspar_line-low     = is_material_data-matnr.
*        APPEND rspar_line TO rspar_tab.
*
*        SUBMIT rm07mlbd USING SELECTION-SCREEN '1000'
*       WITH SELECTION-TABLE rspar_tab
*       AND RETURN.

*        SUBMIT rm07mlbd USING SELECTION-SCREEN '1000' WITH matnr-low = is_material_data-matnr AND RETURN.
        call TRANSACTION 'MB5B' .
      WHEN 'BUT08'.   " MB52
*        SET PARAMETER ID 'MAT' FIELD is_material_data-matnr.
        call TRANSACTION 'MB52'.
*        SUBMIT rm07mlbs WITH matnr-low = is_material_data-matnr AND RETURN.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.

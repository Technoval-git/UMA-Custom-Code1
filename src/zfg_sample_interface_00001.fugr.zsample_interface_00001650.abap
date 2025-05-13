FUNCTION zsample_interface_00001650.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_POSTAB) LIKE  RFPOS STRUCTURE  RFPOS
*"  EXPORTING
*"     VALUE(E_POSTAB) LIKE  RFPOS STRUCTURE  RFPOS
*"----------------------------------------------------------------------
************************************************************************
*                        ALL RIGHTS RESERVED                           *
************************************************************************
*----------------------------------------------------------------------*
* PROGRAM NAME       : ZSAMPLE_INTERFACE_00001650                      *
* PROGRAM DESCRIPTION: Schnittstellenbeschreibung zum Event 00001650   *
* DEVELOPER          : Asif Rashid Diyargaroo                          *
* CREATION DATE      : 03.01.2023                                      *                                     *
*----------------------------------------------------------------------*
* REVISION HISTORY-----------------------------------------------------*
* REVISION NO  :                                                       *
* REFERENCE NO :                                                       *
* DEVELOPER    :                                                       *
* DATE         :                                                       *
* DESCRIPTION  :                                                       *
*----------------------------------------------------------------------*
  CONSTANTS lc_tcode TYPE sy-tcode VALUE 'FBL5N'.
  e_postab = i_postab.
  IF sy-tcode = lc_tcode.
    SELECT SINGLE name1 name2 FROM kna1
    INTO (e_postab-name1, e_postab-name2)
    WHERE kunnr = i_postab-konto.
    SELECT SINGLE xblocked block_reason FROM ukmbp_cms_sgm
    INTO (e_postab-xblocked, e_postab-block_reason)
    WHERE partner = i_postab-konto.
    ENDIF.
ENDFUNCTION.

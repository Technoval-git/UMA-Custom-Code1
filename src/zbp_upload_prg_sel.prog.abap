
*&---------------------------------------------------------------------*
*&  Include           ZBP_UPLOAD_PRG_SEL
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                       SELECTION SCREEN                               *
*----------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-mod.

PARAMETERS:
p_file(1024) LOWER CASE DEFAULT 'D:\Extend_Material_Master.xlsx'.
SELECTION-SCREEN END OF BLOCK b1.

***********************************************************************
*                   AT SELECTION SCREEN                               *
***********************************************************************
AT SELECTION-SCREEN.
  PERFORM f_function_key_handler.

***********************************************************************
*                   AT SELECTION SCREEN ON                            *
***********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM f_f4_file_browser.

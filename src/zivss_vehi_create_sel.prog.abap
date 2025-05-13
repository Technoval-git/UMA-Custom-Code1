*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_CREATE_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: pr_pc    RADIOBUTTON GROUP rad2 DEFAULT 'X' MODIF ID b3 USER-COMMAND select,     " Presentation server
              pr_pi    RADIOBUTTON GROUP rad2 MODIF ID b3,                                     " Application server
              p_file   TYPE              localfile,
              p_logicl TYPE              filename-fileintern MODIF ID log.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: pr_file  RADIOBUTTON GROUP rad1 DEFAULT 'X' MODIF ID b4 USER-COMMAND file,
              pr_logic RADIOBUTTON GROUP rad1 MODIF ID b4,
              p_succ   TYPE              localfile MODIF ID fil , "DEFAULT '/tmp',
              p_error  TYPE              localfile MODIF ID fil , "DEFAULT '/tmp',
              p_slogic TYPE              filename-fileintern MODIF ID lgc,
              p_elogic TYPE              filename-fileintern MODIF ID lgc.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-023.
  PARAMETERS: rb_upd RADIOBUTTON GROUP rad3 DEFAULT 'X',
              rb_inb RADIOBUTTON GROUP rad3.
SELECTION-SCREEN END OF BLOCK b3.

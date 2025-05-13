
*&---------------------------------------------------------------------*
*&  Include           ZLANDCOST_UPDATE_SEL
*&---------------------------------------------------------------------*
TABLES: ekbe,ekko.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

*  PARAMETERS: p_invo type EKBE-belnr,
       PARAMETERS:       p_po type ekko-ebeln.
  PARAMETERS: r_upd  RADIOBUTTON GROUP rb DEFAULT 'X' USER-COMMAND uc MODIF ID sc1,
             r_ex   RADIOBUTTON GROUP rb MODIF ID sc1.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK c1 WITH FRAME TITLE TEXT-003.
*  PARAMETERS:  r_rep RADIOBUTTON GROUP rb1 MODIF ID sc1.
  PARAMETERS:  r_header RADIOBUTTON GROUP rb1 MODIF ID sc2 .
  PARAMETERS:  r_item RADIOBUTTON GROUP rb1 MODIF ID sc2.
SELECTION-SCREEN END OF BLOCK c1.

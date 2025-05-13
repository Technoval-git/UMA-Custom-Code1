*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF94 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISTRIBUTE_COST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM distribute_cost .

  data: lv_cnt TYPE numb VALUE 1.

  FIELD-SYMBOLS: <ls_ac_cost> LIKE LINE OF gt_ac_post_buf.

  LOOP AT gt_ac_post_buf ASSIGNING <ls_ac_cost>. " where index NE .
*    <ls_ac_cost>-cost = ( gv_netamt - gv_costent ) DIV ( gv_costcnt - lv_cnt ).
     <ls_ac_cost>-cost =  <ls_ac_cost>-cost * gv_calcost.
      <ls_ac_cost>-ref_cost =  <ls_ac_cost>-cost.
  ENDLOOP.
*  if
* lv_cnt = lv_cnt + 1.

  ENDFORM.                    " DISTRIBUTE_COST

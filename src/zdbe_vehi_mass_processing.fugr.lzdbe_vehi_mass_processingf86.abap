**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGF86 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Form  SET_DRDN_TABLE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*form SET_DRDN_TABLE .
*
**§1.Define a dropdown table and pass it to ALV.
**   One listbox is referenced by a handle, e.g., '1'.
**   For each entry that shall appear in this listbox
**   you have to append a line to the dropdown table
**   with handle '1'.
**   This handle can be assigned to several columns
**   of the output table using the field catalog.
**
*  data: lt_dropdown type lvc_t_drop,
*        ls_dropdown type lvc_s_drop.
*
*  data: lt_dral type lvc_t_dral,                            "#EC NEEDED
*        ls_dral type lvc_s_dral.                            "#EC NEEDED
*
** First listbox (handle '1').
*  ls_dropdown-handle = '1'.
*  ls_dropdown-value = VLCACTDATA_HEAD_S-lgort.
*  append ls_dropdown to lt_dropdown.
*
*    g_grid->set_drop_down_table(
*    it_drop_down = lt_dropdown ).
*
*  if 1 eq 2.
*    ls_dral-handle = '1'.
*    ls_dral-int_value = 'KG'.
*    ls_dral-value = 'Kilogramm'.
*    append ls_dral to lt_dral.
*
*    ls_dral-handle = '1'.
*    ls_dral-int_value = 'G'.
*    ls_dral-value = 'Gramm'.
*    append ls_dral to lt_dral.
*
*    g_grid->set_drop_down_table(
*      it_drop_down_alias = lt_dral ).
*  endif.
*
*
*endform.                    " SET_DRDN_TABLE

"Name: \PR:RM06K010\FO:ALV_FILL_OUTPUT_TABLE\SE:END\EI
ENHANCEMENT 0 ZMM_ME1E_MAKTX.
*

  loop at lt_outtab ASSIGNING FIELD-SYMBOL(<Fs_outtab>).
    select single maktx from makt into <FS_outtab>-maktx where matnr = <FS_OUTTAB>-matnr and spras = 'EN'.

  endloop.
  clear cht_outtab[].
  cht_outtab[] = lt_outtab.
ENDENHANCEMENT.

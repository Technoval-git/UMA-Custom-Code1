FUNCTION ZMM_GET_OPENSO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(MATNR) TYPE  MATNR
*"     REFERENCE(WERKS) TYPE  WERKS_D
*"  EXPORTING
*"     REFERENCE(ZMENG) TYPE  /DBE/AMOUNT
*"----------------------------------------------------------------------


*select /DBE/VBELN,/DBE/POSNR from LIPS into table @data(lt_lips) where  matnr = @matnr and werks = @werks.

  select sum( zmeng ) from /DBE/VBAP into @data(lv_zmeng) where  matnr40 = @matnr and werks = @werks .


*  select sum( zmeng )  from /DBE/VBAP FOR ALL ENTRIES IN @lt_lips  WHERE vbeln = @lt_lips-/dbe/vbeln
*                                                                   and posnr = @lt_lips-/dbe/posnr
*
*    into @data(lv_zmeng1) .

    select sum( b~zmeng ) from lips as a INNER JOIN /DBE/VBAP as b on b~vbeln = a~/dbe/vbeln and
                                                                       b~posnr = a~/dbe/posnr
       where a~matnr = @matnr and a~werks = @werks and a~/DBE/VBELN is not INITIAL and a~/DBE/POSNR is not INITIAL
      into @data(lv_zmeng1).

zmeng = lv_zmeng - lv_zmeng1.
ENDFUNCTION.

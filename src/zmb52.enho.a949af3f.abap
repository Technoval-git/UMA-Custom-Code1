"Name: \PR:RM07MLBS\EX:EHP604_RM07MLBS_30\EI
ENHANCEMENT 0 ZMB52.
*


TRY.
* Adding a field into the Field catalog
    INSERT VALUE #( fieldname = 'VERPR'
                    tabname   = 'BESTAND'
                    ref_fieldname = 'VERPR'
                    ref_tabname = 'MBEW'
                    col_pos = fieldcat[ fieldname = 'CHARG' ]-col_pos )

                    INTO TABLE fieldcat.

    INSERT VALUE #( fieldname = 'LGPBE'
                       tabname   = 'BESTAND'
                       ref_fieldname = 'LGPBE'
                       ref_tabname = 'MARD'
                       col_pos = fieldcat[ fieldname = 'VERPR' ]-col_pos )

                       INTO TABLE fieldcat.
    INSERT VALUE #( fieldname = 'WGBEZ'
                       tabname   = 'BESTAND'
                       ref_fieldname = 'WGBEZ'
                       ref_tabname = 'T023T'
                       col_pos = fieldcat[ fieldname = 'MATKL' ]-col_pos )

                       INTO TABLE fieldcat.
    INSERT VALUE #( fieldname = 'MTBEZ'
                       tabname   = 'BESTAND'
                       ref_fieldname = 'MTBEZ'
                       ref_tabname = 'T134T'
                       col_pos = fieldcat[ fieldname = 'MTART' ]-col_pos )

                       INTO TABLE fieldcat.
*    DATA(lt_query) = CORRESPONDING tt_mcha( bestand[] ).

    DATA(lt_query) =  bestand[] .

    SELECT matnr, werks, lgort ,lgpbe
      INTO TABLE @DATA(lt_master)
      FROM mard FOR ALL ENTRIES IN @lt_query
      WHERE  matnr = @lt_query-matnr AND
             werks = @lt_query-werks .
    SELECT matkl, wgbez INTO TABLE @DATA(lt_matkl) FROM t023t FOR ALL ENTRIES IN @lt_query
       WHERE matkl = @lt_query-matkl AND spras = 'E'.
    SELECT mtart, mtbez INTO TABLE @DATA(lt_mtart) FROM t134t FOR ALL ENTRIES IN @lt_query
       WHERE mtart = @lt_query-mtart AND spras = 'E'.
*    IF sy-subrc EQ 0.
    LOOP AT bestand[] ASSIGNING FIELD-SYMBOL(<lfs_output>).
      TRY.

          <lfs_output>-wgbez = lt_matkl[ matkl = <lfs_output>-matkl ]-wgbez.

          <lfs_output>-mtbez = lt_mtart[ mtart = <lfs_output>-mtart ]-mtbez.



          <lfs_output>-lgpbe = lt_master[ matnr = <lfs_output>-matnr
                                                werks = <lfs_output>-werks ]-lgpbe.
          <lfs_output>-verpr = <lfs_output>-wlabs / <lfs_output>-labst.
        CATCH cx_sy_itab_line_not_found.
          CONTINUE.
      ENDTRY.
    ENDLOOP.
*    ENDIf.
  CATCH cx_sy_itab_line_not_found.

ENDTRY.
ENDENHANCEMENT.

FUNCTION ZBBP_INB_DELIVERY_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_INB_DELIVERY_HEADER) LIKE  BBP_INBD_L
*"  STRUCTURE  BBP_INBD_L
*"  EXPORTING
*"     VALUE(EF_DELIVERY) LIKE  LIKP-VBELN
*"  TABLES
*"      IT_INB_DELIVERY_DETAIL STRUCTURE  BBP_INBD_D
*"      RETURN STRUCTURE  BAPIRETURN
*"--------------------------------------------------------------------

** Refresh
  REFRESH: RETURN.


  PERFORM INB_DELIVERY_CREATE
              TABLES
                 IT_INB_DELIVERY_DETAIL[]
                 RETURN[]
              USING
                 IS_INB_DELIVERY_HEADER
                 EF_DELIVERY.

  IF NOT RETURN[] IS INITIAL.
*      TODO Error Trapping
  ENDIF.




ENDFUNCTION.

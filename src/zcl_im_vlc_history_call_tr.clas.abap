class ZCL_IM_VLC_HISTORY_CALL_TR definition
  public
  final
  create public .

public section.

  interfaces IF_EX_VLC_HISTORY_CALL_TRA .

  methods CALL_TRA_ZSTO
    importing
      !VGUID_IV type VLC_GUID
      !TSTAMP_IV type VLC_LTSTAMP
      !ACTDOCTYPE_IV type VLC_ACTDOCTYPE
      !ACTION_IV type VLC_ACTION
    changing
      !TCODE_EV type C
      !BDC_ET type CK_T_BDCDATA
      !VLCHISTORY_BORLINK_CS type VLC_HISTORY_BOR_OBJID optional
    exceptions
      BADI_ERROR .
  methods CALL_TRA_ZSGI
    importing
      !VGUID_IV type VLC_GUID
      !TSTAMP_IV type VLC_LTSTAMP
      !ACTDOCTYPE_IV type VLC_ACTDOCTYPE
      !ACTION_IV type VLC_ACTION
    changing
      !TCODE_EV type C
      !BDC_ET type CK_T_BDCDATA
      !VLCHISTORY_BORLINK_CS type VLC_HISTORY_BOR_OBJID optional
    exceptions
      BADI_ERROR .
  methods CALL_TRA_ZSGR
    importing
      !VGUID_IV type VLC_GUID
      !TSTAMP_IV type VLC_LTSTAMP
      !ACTDOCTYPE_IV type VLC_ACTDOCTYPE
      !ACTION_IV type VLC_ACTION
    changing
      !TCODE_EV type C
      !BDC_ET type CK_T_BDCDATA
      !VLCHISTORY_BORLINK_CS type VLC_HISTORY_BOR_OBJID optional
    exceptions
      BADI_ERROR .
  methods CALL_TRA_ZSHP
    importing
      !VGUID_IV type VLC_GUID
      !TSTAMP_IV type VLC_LTSTAMP
      !ACTDOCTYPE_IV type VLC_ACTDOCTYPE
      !ACTION_IV type VLC_ACTION
    changing
      !TCODE_EV type C
      !BDC_ET type CK_T_BDCDATA
      !VLCHISTORY_BORLINK_CS type VLC_HISTORY_BOR_OBJID optional
    exceptions
      BADI_ERROR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_VLC_HISTORY_CALL_TR IMPLEMENTATION.


  METHOD call_tra_zsgi.

    DATA: ls_gois_vhbln TYPE vlcgissue,
          ls_bdc        TYPE bdcdata,
          lv_text       TYPE c,
          lv_mblnr      TYPE mblnr.
*        tstamp type timestampl.

    DEFINE fill_bdc.
      CLEAR ls_bdc.
      ls_bdc-program = &1.
      ls_bdc-dynpro = &2.
      ls_bdc-dynbegin = &3.
      ls_bdc-fnam = &4.
      ls_bdc-fval = &5.
      APPEND ls_bdc TO bdc_et.
    END-OF-DEFINITION.


    SELECT SINGLE *
    INTO ls_gois_vhbln
    FROM vlcgissue
    WHERE vguid = vguid_iv
      AND tstmp = tstamp_iv
      AND actdoctype = actdoctype_iv.

    IF sy-subrc = 0.
*****   If material document is archived, its visualization       "N.1539716
*****   is provided via MIGO_DIALOG
****      SELECT SINGLE mblnr FROM mkpf INTO lv_mblnr
****        WHERE mblnr = ls_gois_vhbln-mblnr
****        AND   mjahr = ls_gois_vhbln-mjahr.
****      IF sy-subrc <> 0.
****        CALL FUNCTION 'MIGO_DIALOG'
****          EXPORTING
****            i_mblnr = ls_gois_vhbln-mblnr
****            i_mjahr = ls_gois_vhbln-mjahr.
*****     throw a success message, so that VELO02_CALL_TRANSACTION
*****     does not try to also display the goodsreceipt.
****        MESSAGE lv_text TYPE 'S' RAISING badi_error.
****      ENDIF.
****
****      fill_bdc 'SAPMM07M' '0460' 'X' '' ''.
****
****      fill_bdc '' '' '' 'RM07M-MBLNR' ls_gois_vhbln-mblnr.
****      fill_bdc '' '' '' 'RM07M-MJAHR' ls_gois_vhbln-mjahr.
****
****      fill_bdc '' '' '' 'BDC_OKCODE' ''.
****
****      tcode_ev = 'MB03'.
*****------History Link----------------
****      vlchistory_borlink_cs-objtype = 'MKPF'.
****      CONCATENATE ls_gois_vhbln-mblnr  ls_gois_vhbln-mjahr INTO
****      vlchistory_borlink_cs-objkey .

*------History Link----------------
      vlchistory_borlink_cs-objtype = 'MKPF'.
      CONCATENATE ls_gois_vhbln-mblnr ls_gois_vhbln-mjahr INTO
      vlchistory_borlink_cs-objkey .

*     MIGO is not Batch enabled so we have to call it via function
*     module
      CALL FUNCTION 'MIGO_DIALOG'
        EXPORTING
          i_mblnr             = ls_gois_vhbln-mblnr
          i_mjahr             = ls_gois_vhbln-mjahr
        EXCEPTIONS
          illegal_combination = 1
          OTHERS              = 2.

*     throw a success message, so that VELO02_CALL_TRANSACTION
*     does not try to also display the goodsreceipt.
      MESSAGE lv_text TYPE 'S' RAISING badi_error.
    ENDIF.

  ENDMETHOD.


  METHOD call_tra_zsgr.
    DATA: lv_gore_vhbln TYPE mblnr,
          lv_gore_mjahr TYPE mjahr,
          lv_text       TYPE string.

    SELECT SINGLE mblnr mjahr
    INTO (lv_gore_vhbln, lv_gore_mjahr)
    FROM vlcgreceipt
    WHERE vguid      = vguid_iv
      AND tstmp      = tstamp_iv
      AND actdoctype = actdoctype_iv.

    IF sy-subrc = 0.
*------History Link----------------
      vlchistory_borlink_cs-objtype = 'MKPF'.
      CONCATENATE lv_gore_vhbln  lv_gore_mjahr INTO
      vlchistory_borlink_cs-objkey .

*     MIGO is not Batch enabled so we have to call it via function
*     module
      CALL FUNCTION 'MIGO_DIALOG'
        EXPORTING
          i_mblnr             = lv_gore_vhbln
          i_mjahr             = lv_gore_mjahr
        EXCEPTIONS
          illegal_combination = 1
          OTHERS              = 2.

*     throw a success message, so that VELO02_CALL_TRANSACTION
*     does not try to also display the goodsreceipt.
      MESSAGE lv_text TYPE 'S' RAISING badi_error.

    ENDIF.

  ENDMETHOD.


  METHOD call_tra_zshp.

    DATA: ls_vlcdelivery TYPE vlcdelivery,
          lv_text        TYPE c,
          lv_mblnr       TYPE mblnr.

************************************************************************
* Read the data
************************************************************************
    SELECT SINGLE
        *
      INTO ls_vlcdelivery
      FROM vlcdelivery
      WHERE
        vguid = vguid_iv AND
        tstmp = tstamp_iv AND
        actdoctype = actdoctype_iv.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

************************************************************************
* Call transaction
************************************************************************
    SET PARAMETER ID 'VL' FIELD ls_vlcdelivery-vbeln.
    TRY.
        CALL TRANSACTION 'VL33N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN. "#EC CI_CALLTA
      CATCH cx_sy_authorization_error.                  "#EC NO_HANDLER
    ENDTRY.

************************************************************************
* Throw a success message, in the same way, like the transaction QGIS does
************************************************************************
    MESSAGE space TYPE 'S' RAISING badi_error.
  ENDMETHOD.


  METHOD call_tra_zsto.
    DATA: lv_ord_vhbln TYPE vlcporder-ebeln.

    SELECT SINGLE ebeln
    INTO lv_ord_vhbln
    FROM vlcporder
    WHERE vguid = vguid_iv
      AND tstmp = tstamp_iv
      AND actdoctype = actdoctype_iv.

    IF sy-subrc = 0.

*   Forwarding data to ME23N via BDC table does not work. Instead the
*   document number is set by set/get parameter
      SET PARAMETER ID 'BES' FIELD lv_ord_vhbln.
      tcode_ev = 'ME23N'.

*------History Link----------------
      vlchistory_borlink_cs-objtype = 'BUS2012'. " bus_po_gc
      vlchistory_borlink_cs-objkey = lv_ord_vhbln.

    ENDIF.


  ENDMETHOD.


  METHOD if_ex_vlc_history_call_tra~prepare_call_transaction_data.
*prefix for METHODS name
     CONSTANTS: lc_meth_pref(9)   TYPE c VALUE 'CALL_TRA_'.
*method name
    DATA: lv_meth_name TYPE string.
* Variables for getting exception type
    DATA: lo_root TYPE REF TO cx_root.
    DATA: lv_exceptiontype TYPE string.

*construct the relevant methods name
    CONCATENATE lc_meth_pref action_iv INTO lv_meth_name.

*try to call the method
    TRY.
        CALL METHOD me->(lv_meth_name)
          EXPORTING
            vguid_iv              = vguid_iv
            tstamp_iv             = tstamp_iv
            actdoctype_iv         = actdoctype_iv
            action_iv             = action_iv
          CHANGING
            tcode_ev              = tcode_ev
            bdc_et                = bdc_et
            vlchistory_borlink_cs = vlchistory_borlink_cs
          EXCEPTIONS
            badi_error            = 1
            OTHERS                = 2.
        IF sy-subrc = 0.
          opt-racommit = 'X'.   " do not terminate transaction after COMMIT for DBM actions N:1472509
        ELSE.
          RAISE badi_error.
        ENDIF.
      CATCH cx_sy_dyn_call_illegal_method.              "#EC NO_HANDLER
*   This is not an error. Implementation might be in other BAdI or only "technical" action without implementation
      CATCH cx_root INTO lo_root.
*   Error occurred
        lv_exceptiontype = lo_root->get_text( ).
        MESSAGE e016(velo) WITH lv_exceptiontype space space space RAISING badi_error.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.

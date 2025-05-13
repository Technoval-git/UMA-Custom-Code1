class ZCL_IM_VSS_CUSTOM_ACTIONS definition
  public
  final
  create public .

public section.

  interfaces IF_EX_VLC_EXECUTE_ACTION .

  methods LIFECYCLE_UPDATE
    importing
      !IV_TIMING type /DBE/VEH_PRE_POST
      !IS_INCOMING_ACTION type VLCC_CVLC03_PS
      !IS_ELEMENTARY_ACTION type VLCC_CVLC03_PS
      !IT_VEH_BOB type /DBE/T_VEH_BOB
    changing
      !CT_VLCDIAVEHI type VLCDIAVEHI_T
      !CS_VLCACTDATA type VLCACTDATA
      !CT_VLCH_MSSG type VLCH_MSSG_PT
    raising
      CX_STATIC_CHECK .
  methods EXECUTE_ZSTO
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C optional
      !VLCBAPICU_IT type VLCBAPICU_T optional
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT
    exceptions
      ACTION_NOT_PERFORMED .
  methods CHECK_ZSTO
    importing
      !IS_INCOMING_ACTION type VLCC_CVLC03_PS
      !IS_ELEMENTARY_ACTION type VLCC_CVLC03_PS
      !IS_VLCDIAVEHI type VLCDIAVEHI
      !IS_VLCACTDATA type VLCACTDATA
      !IT_VLCSTATUS type VLCSTATUS_T
      !IT_VLCH_MSSG type VLCH_MSSG_PT
    changing
      !CT_VLCH_MSSG type VLCH_MSSG_PT optional
      !CT_ACTION type VLCC_CVLC03_PT optional
    exceptions
      CHECK_ERROR .
  methods EXECUTE_ZSGI
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C optional
      !VLCBAPICU_IT type VLCBAPICU_T optional
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT
    exceptions
      ACTION_NOT_PERFORMED .
  methods CHECK_ZSGI
    importing
      !IS_INCOMING_ACTION type VLCC_CVLC03_PS
      !IS_ELEMENTARY_ACTION type VLCC_CVLC03_PS
      !IS_VLCDIAVEHI type VLCDIAVEHI
      !IS_VLCACTDATA type VLCACTDATA
      !IT_VLCSTATUS type VLCSTATUS_T
      !IT_VLCH_MSSG type VLCH_MSSG_PT
    changing
      !CT_VLCH_MSSG type VLCH_MSSG_PT optional
      !CT_ACTION type VLCC_CVLC03_PT optional
    exceptions
      CHECK_ERROR .
  methods EXECUTE_ZSGR
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C optional
      !VLCBAPICU_IT type VLCBAPICU_T optional
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT
    exceptions
      ACTION_NOT_PERFORMED .
  methods CHECK_ZSGR
    importing
      !IS_INCOMING_ACTION type VLCC_CVLC03_PS
      !IS_ELEMENTARY_ACTION type VLCC_CVLC03_PS
      !IS_VLCDIAVEHI type VLCDIAVEHI
      !IS_VLCACTDATA type VLCACTDATA
      !IT_VLCSTATUS type VLCSTATUS_T
      !IT_VLCH_MSSG type VLCH_MSSG_PT
    changing
      !CT_VLCH_MSSG type VLCH_MSSG_PT optional
      !CT_ACTION type VLCC_CVLC03_PT optional
    exceptions
      CHECK_ERROR .
  methods EXECUTE_ZGRA
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C
      !VLCBAPICU_IT type VLCBAPICU_T
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT
    exceptions
      ACTION_NOT_PERFORMED
      CHECK_ERROR .
  methods EXECUTE_ZREP
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C optional
      !VLCBAPICU_IT type VLCBAPICU_T optional
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT
    exceptions
      ACTION_NOT_PERFORMED .
  methods EXECUTE_ZNJS
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C optional
      !VLCBAPICU_IT type VLCBAPICU_T optional
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT .
  methods EXECUTE_ZUPD
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C optional
      !VLCBAPICU_IT type VLCBAPICU_T optional
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT
    exceptions
      ACTION_NOT_PERFORMED .
  methods EXECUTE_ZVAL
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C optional
      !VLCBAPICU_IT type VLCBAPICU_T optional
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT
    exceptions
      ACTION_NOT_PERFORMED .
  methods EXECUTE_ZDMG
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C optional
      !VLCBAPICU_IT type VLCBAPICU_T optional
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT
    exceptions
      ACTION_NOT_PERFORMED .
  methods EXECUTE_ZRPV
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !VLCSTATUS_IT type VLCSTATUS_T
      !DIALOGUE_ALLOWED_IV type C optional
      !VLCBAPICU_IT type VLCBAPICU_T optional
    changing
      !RFCDEST_CT type VLC_RFCDEST_T
      !VLCDIAVEHI_CT type VLCDIAVEHI_T
      !VLCACTDATA_CS type VLCACTDATA
      !VLCH_MSSG_CT type VLCH_MSSG_PT
    exceptions
      ACTION_NOT_PERFORMED .
protected section.
private section.

  types:
    BEGIN OF dtel_type,
           name    TYPE ddobjname,
           s_dd04v TYPE dd04v,
         END OF dtel_type .
  types:
    tt_dtel_type TYPE SORTED TABLE OF dtel_type WITH UNIQUE KEY name .

  class-data ST_DTEL type TT_DTEL_TYPE .
*"* private components of class /DBE/CL_IM_EXECUTE_ACTION
*"* do not include other source files here!!!
  data MT_VLCDIAVEHI type VLCDIAVEHI_T .

  methods CHECK_COM_PRODUCT_AUTH
    importing
      !IV_AUTH_ACT type ACTIV_AUTH
    exceptions
      NO_AUTHORITY .
ENDCLASS.



CLASS ZCL_IM_VSS_CUSTOM_ACTIONS IMPLEMENTATION.


  METHOD check_com_product_auth.
    CALL FUNCTION 'COM_PRODUCT_AUTHORITY_CHECK'
      EXPORTING
        iv_auth_act    = iv_auth_act
      EXCEPTIONS
        no_authority   = 1
        wrong_call     = 2
        internal_error = 3.
    IF sy-subrc <> 0.
      RAISE no_authority.
    ENDIF.

  ENDMETHOD.


  METHOD check_zsgi.
*    DATA: wa_vlcdiavehi_ct TYPE vlcdiavehi,
*          ls_actdata_item  TYPE vlcactdata_item_s,
*          lt_mbew          TYPE TABLE OF mbew,
*          ls_mbew          TYPE mbew,
*          lv_errmsg        TYPE string,
*          ls_error         TYPE vlch_mssg_ps,
*          lv_vin           TYPE string,
*          lv_error         TYPE boolean,
*          lv_agr_name      TYPE agr_name,
*          lv_agr_name1     TYPE agr_name,
*          lv_stck_role     TYPE string.
*
*    CONSTANTS: lc_jaco_user TYPE string   VALUE 'J2100*',
*               lc_stck_role TYPE agr_name VALUE 'ZS_2100_DB00_VS08_STCK-CR_',
*               lc_lgmr_role TYPE agr_name VALUE 'ZS_2100_DB00_VS10_SLSM-LM_%'.
*
*    CHECK is_vlcactdata-werks CP '21*'.
*    IF sy-uname CP lc_jaco_user.
*      LOOP AT is_vlcactdata-actdata_item INTO ls_actdata_item.
*        CONCATENATE lc_stck_role ls_actdata_item-werks INTO lv_stck_role.
*        lv_agr_name1 = lv_stck_role.
*        SELECT SINGLE agr_name INTO lv_agr_name
*          FROM agr_users WHERE uname = sy-uname AND
*                              ( agr_name LIKE lv_agr_name1 OR
*                               agr_name LIKE lc_lgmr_role ).
*        IF sy-subrc <> 0.
*          CLEAR: ls_error,lv_errmsg.
*          MESSAGE e383(ymsg_jet_dbm) WITH ls_actdata_item-werks
*                                     INTO lv_errmsg.
*          ls_error-vguid = ls_actdata_item-vguid.
*          ls_error-vhcle = ls_actdata_item-vhcle.
*          ls_error-vhvin  = ls_actdata_item-vhvin.
*          ls_error-msgid = sy-msgid.
*          ls_error-msgty = sy-msgty.
*          ls_error-msgno = sy-msgno.
*          ls_error-msgv1 = sy-msgv1.
*          ls_error-msgv2 = sy-msgv2.
*          APPEND ls_error TO ct_vlch_mssg.
*          lv_error = abap_true.
*        ENDIF.
*
*      ENDLOOP.
*    ENDIF.
*    "Raise the error message
*    IF lv_error = abap_true.
*      RAISE check_error.
*    ENDIF.
  ENDMETHOD.


  method CHECK_ZSGR.
  endmethod.


  METHOD check_zsto.
*    DATA: wa_vlcdiavehi_ct TYPE vlcdiavehi,
*          ls_actdata_item  TYPE vlcactdata_item_s,
*          lt_mbew          TYPE TABLE OF mbew,
*          ls_mbew          TYPE mbew,
*          lv_errmsg        TYPE string,
*          ls_error         TYPE vlch_mssg_ps,
*          lv_vin           TYPE string,
*          lv_error         TYPE boolean,
*          lv_agr_name      TYPE agr_name.
*
*    CONSTANTS: lc_jaco_user TYPE string   VALUE 'J2100*',
*               lc_stck_role TYPE agr_name VALUE 'ZS_2100_DB00_VS08_STCK-CR_%',
*               lc_lgmr_role TYPE agr_name VALUE 'ZS_2100_DB00_VS10_SLSM-LM_%'.
*
*    CHECK is_vlcactdata-ekorg = '2100'.
*
*    DATA:
*      lt_vlcporder TYPE TABLE OF vlcporder,
*      ls_vlcporder TYPE vlcporder,
*      lt_ekpo      TYPE TABLE OF ekpo.
*
*    IF is_vlcactdata-bsart = 'UB'.
*      SELECT * FROM vlcporder INTO TABLE lt_vlcporder
*        WHERE vguid = is_vlcdiavehi-vguid.
*      IF sy-subrc = 0.
*        SELECT * FROM ekpo INTO TABLE lt_ekpo
*          FOR ALL ENTRIES IN lt_vlcporder
*          WHERE ebeln = lt_vlcporder-ebeln AND
*                ebelp = lt_vlcporder-ebelp AND
*                ( loekz = space AND elikz = space ).
*        IF sy-subrc = 0.
*          " Means, Vehicle is having Open Purchase Order
*          MESSAGE e422(ymsg_jet_dbm) WITH is_vlcdiavehi-vhcle INTO lv_errmsg.
*          ls_error-vguid = is_vlcdiavehi-vguid.
*          ls_error-vhcle = is_vlcdiavehi-vhcle.
*          ls_error-vhvin = is_vlcdiavehi-vhvin.
*          ls_error-msgid = yif_dbm_jet_constants=>gc_msg_class_id.
*          ls_error-msgty = /dbm/if_vsa_constants=>msg_severity_error.
*          ls_error-msgno = 422.
*          ls_error-msgv1 = is_vlcdiavehi-vhcle.
*          APPEND ls_error TO ct_vlch_mssg.
*          lv_error = abap_true.
*          RAISE check_error.
*          RETURN.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    "Read the stock information for the vehicles.
*    SELECT SINGLE * FROM mbew INTO ls_mbew
*      WHERE bwtar = is_vlcdiavehi-vhcle AND matnr = is_vlcdiavehi-matnr AND
*            bwkey = is_vlcdiavehi-werks AND lbkum >= 1.
*    IF sy-subrc <> 0.
*      "Check the vehicle stock before raising the Stock Purchase Order
*      MESSAGE e379(ymsg_jet_dbm) WITH is_vlcdiavehi-vhcle INTO lv_errmsg.
*      CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
*        EXPORTING
*          msgid_iv     = sy-msgid
*          msgty_iv     = sy-msgty
*          msgno_iv     = sy-msgno
*          msgv1_iv     = sy-msgv1
*          msgv2_iv     = sy-msgv2
*          msgv3_iv     = sy-msgv3
*          msgv4_iv     = sy-msgv4
*        TABLES
*          vlch_mssg_ct = ct_vlch_mssg.
*
*      lv_error = abap_true.
*    ENDIF.
*
*    "Validate the Vehicle BT Type for STO Process
*    IF is_vlcdiavehi-dbm_bustype <> 'NEC' AND is_vlcdiavehi-dbm_bustype <> 'USC'.
*      CLEAR: ls_error,lv_errmsg.
*      MESSAGE e378(ymsg_jet_dbm) WITH is_vlcdiavehi-vhcle is_vlcdiavehi-dbm_bustype
*                                 INTO lv_errmsg.
*      CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
*        EXPORTING
*          msgid_iv     = sy-msgid
*          msgty_iv     = sy-msgty
*          msgno_iv     = sy-msgno
*          msgv1_iv     = sy-msgv1
*          msgv2_iv     = sy-msgv2
*          msgv3_iv     = sy-msgv3
*          msgv4_iv     = sy-msgv4
*        TABLES
*          vlch_mssg_ct = ct_vlch_mssg.
*
*      lv_error = abap_true.
*    ENDIF.
*
*    IF sy-uname CP lc_jaco_user.
*      SELECT SINGLE agr_name INTO lv_agr_name
*        FROM agr_users WHERE uname = sy-uname AND
*                            ( agr_name LIKE lc_stck_role OR
*                             agr_name LIKE lc_lgmr_role ).
*      IF sy-subrc <> 0.
*        CLEAR: ls_error,lv_errmsg.
*        MESSAGE e380(ymsg_jet_dbm) WITH ls_actdata_item-vhcle ls_actdata_item-dbm_bustype
*                                   INTO lv_errmsg.
*        CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
*          EXPORTING
*            msgid_iv     = sy-msgid
*            msgty_iv     = sy-msgty
*            msgno_iv     = sy-msgno
*            msgv1_iv     = sy-msgv1
*            msgv2_iv     = sy-msgv2
*            msgv3_iv     = sy-msgv3
*            msgv4_iv     = sy-msgv4
*          TABLES
*            vlch_mssg_ct = ct_vlch_mssg.
*
*        lv_error = abap_true.
*      ENDIF.
*    ENDIF.
*
*    "Raise the Exception if any error message been raised
*    IF lv_error = abap_true.
*      RAISE check_error.
*    ENDIF.


    DATA: ls_incoming_action   TYPE cvlc03,
          ls_elemantary_action TYPE cvlc03.

    DATA : list_of_vehicles_it TYPE vlcdiavehi_t,
           ls_list             TYPE vlcdiavehi,
           vlcactdata_cs       TYPE vlcactdata.

    MOVE-CORRESPONDING is_incoming_action TO ls_incoming_action.
    MOVE-CORRESPONDING is_elementary_action TO ls_elemantary_action.
    LOOP AT it_vlcstatus INTO DATA(lv_vlcstatus).
      MOVE-CORRESPONDING lv_vlcstatus TO ls_list.
      MOVE-CORRESPONDING is_vlcdiavehi TO ls_list.
      APPEND ls_list TO list_of_vehicles_it.
    ENDLOOP.
    MOVE-CORRESPONDING is_vlcactdata TO vlcactdata_cs.

    CALL FUNCTION 'ZDBE_VM13_QCIO_PREPARE'
      EXPORTING
        iv_xinterlinked      = is_incoming_action-intrlk
        is_incoming_action   = ls_incoming_action
        is_elementary_action = ls_elemantary_action
      TABLES
        it_vlcdiavehi        = list_of_vehicles_it
      CHANGING
        cs_vlcactdata        = vlcactdata_cs
      EXCEPTIONS
        OTHERS               = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING check_error.
    ENDIF.

  ENDMETHOD.


  METHOD execute_zdmg.
    READ TABLE vlcdiavehi_ct INTO DATA(ls_vlcdaivehi) INDEX 1.
    IF sy-subrc EQ 0.
      ls_vlcdaivehi-zdamage =  vlcactdata_cs-zdamage.
      MODIFY vlcdiavehi_ct FROM ls_vlcdaivehi INDEX 1.
    ENDIF.
  ENDMETHOD.


  METHOD execute_zgra.
    DATA : lv_delivery      TYPE lips-vbeln,
           ls_vbkok         TYPE vbkok,
           lv_error_any     TYPE c,
           lt_vlcgreceipt   TYPE TABLE OF vlcgreceipt,
           ls_vlcgreceipt   TYPE vlcgreceipt,
           ls_tvarvc        TYPE tvarvc,
           ls_vlcdiavehi    TYPE vlcdiavehi,
           wa_vlcdiavehi_ct TYPE vlcdiavehi,
           l_mseg           TYPE mseg,
           l_mkpf           TYPE mkpf,
           it_return        TYPE TABLE OF bapiret2,
           wa_return        TYPE bapiret2,
           lt_vlcporder     TYPE STANDARD TABLE OF vlcporder,
           ls_vlcporder     TYPE vlcporder,
           ls_vlcvhehi      TYPE vlcstatus,
           ls_vbap          TYPE /dbe/vbap.

    FIELD-SYMBOLS : <fs_vlcdiavehi_ct> TYPE vlcdiavehi.

    IF vlcactdata_cs-lbeln IS INITIAL.
      READ TABLE vlcstatus_it INTO ls_vlcvhehi INDEX 1.
      IF sy-subrc EQ 0.
        SELECT * FROM vlcporder INTO TABLE lt_vlcporder WHERE vguid EQ ls_vlcvhehi-vguid AND actdoctype EQ 'ZSTO'.
        SORT lt_vlcporder DESCENDING BY ebeln.
        READ TABLE lt_vlcporder INTO ls_vlcporder  INDEX 1.
        IF sy-subrc EQ 0.
          SELECT SINGLE belnr FROM ekbe INTO vlcactdata_cs-lbeln WHERE ebeln  EQ ls_vlcporder-ebeln AND ebelp EQ ls_vlcporder-ebelp.
        ENDIF.
      ENDIF.
    ENDIF.

    SELECT SINGLE vbeln FROM lips INTO lv_delivery WHERE vbeln EQ vlcactdata_cs-lbeln.
    IF sy-subrc NE 0.
      MESSAGE e104(/dbe/vehicle_master) .
      RAISE action_not_performed.
    ENDIF.
    ls_vbkok-vbeln_vl = lv_delivery.

    ls_vbkok-wabuc = 'X'.
    ls_vbkok-spe_auto_gr = 'X'.

    CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
      EXPORTING
        vbkok_wa      = ls_vbkok
        synchron      = 'X'
*       commit        = 'X'
        delivery      = lv_delivery
      IMPORTING
        ef_error_any  = lv_error_any
      EXCEPTIONS
        error_message = 1
        OTHERS        = 2.
    IF lv_error_any IS INITIAL.
*      MESSAGE e106(/dbm/vehicle_master).
*      RAISE check_error.
*    ELSE.
      IMPORT l_mkpf_memory TO l_mkpf FROM MEMORY ID 'MSG'.
      IMPORT l_mseg_memory TO l_mseg FROM MEMORY ID 'MSG'.
      IF l_mseg-mblnr IS INITIAL. "OR l_mkpf-mblnr IS INITIAL.
*        CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
*          EXPORTING
*            msgid_iv     = yif_dbm_jet_constants=>gc_msg_class_id
*            msgty_iv     = yif_dbm_jet_constants=>gc_value_e
*            msgno_iv     = '381'
*          TABLES
*            vlch_mssg_ct = vlch_mssg_ct.
        RAISE action_not_performed.
        RETURN.
      ENDIF.

      REFRESH lt_vlcgreceipt.
      LOOP AT vlcdiavehi_ct INTO wa_vlcdiavehi_ct.
        wa_vlcdiavehi_ct-actdoctype = 'ZGRA'.
        wa_vlcdiavehi_ct-werks = l_mseg-werks.
        wa_vlcdiavehi_ct-lgort = l_mseg-lgort.
        ls_vlcgreceipt-mandt = wa_vlcdiavehi_ct-mandt.
        ls_vlcgreceipt-vguid = wa_vlcdiavehi_ct-vguid.
        ls_vlcgreceipt-tstmp = wa_vlcdiavehi_ct-newtsp.
        ls_vlcgreceipt-actdoctype = 'ZGRA'.
        ls_vlcgreceipt-mblnr = l_mseg-mblnr.
        ls_vlcgreceipt-mjahr = l_mseg-mjahr.
        ls_vlcgreceipt-mblpo = l_mseg-zeile.
        ls_vlcgreceipt-ernam = sy-uname.
        ls_vlcgreceipt-revflag = ' '.
        APPEND ls_vlcgreceipt TO lt_vlcgreceipt.
        MODIFY vlcdiavehi_ct FROM wa_vlcdiavehi_ct.
      ENDLOOP.
      vlcactdata_cs-werks = l_mseg-werks.
      vlcactdata_cs-lgort = l_mseg-lgort.
      CHECK NOT lt_vlcgreceipt[] IS INITIAL.
      CALL FUNCTION 'VELO04_UPDATE_VLCGRECEIPT'
        TABLES
          vlcgreceipt_it = lt_vlcgreceipt.

      SELECT SINGLE * FROM /dbe/vbap INTO ls_vbap WHERE vguid EQ ls_vlcvhehi-vguid.
      IF sy-subrc EQ 0.
        ls_vbap-lgort = vlcactdata_cs-lgort.
        MODIFY /dbe/vbap FROM ls_vbap.
      ENDIF.

    ENDIF.
    LOOP AT it_return INTO wa_return.
      CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
        EXPORTING
          msgid_iv     = wa_return-id
          msgty_iv     = wa_return-type
          msgno_iv     = wa_return-number
          msgv1_iv     = wa_return-message_v1
          msgv2_iv     = wa_return-message_v2
          msgv3_iv     = wa_return-message_v3
          msgv4_iv     = wa_return-message_v4
        TABLES
          vlch_mssg_ct = vlch_mssg_ct.
    ENDLOOP.
    READ TABLE it_return INTO wa_return WITH KEY type = 'E' .
    IF sy-subrc EQ 0.
      RAISE action_not_performed.
    ELSE.

*      SELECT SINGLE * FROM tvarvc INTO ls_tvarvc
*               WHERE name EQ 'VEHI_AUTO_UPD_RESV' AND
*                     low EQ 'X'.
*      IF sy-subrc = 0.
*        LOOP AT vlcdiavehi_ct INTO ls_vlcdiavehi.
*          CALL FUNCTION 'YDBM_UPDATE_IO_IN_RESV_DOC' IN UPDATE TASK
*            EXPORTING
*              iv_vhcle = ls_vlcdiavehi-vhcle.
*        ENDLOOP.
*
*
*      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD execute_znjs.

    DATA: headdata     TYPE bapimathead,
          bapi_mbew1   TYPE bapi_mbew,
          bapi_mbewx   TYPE bapi_mbewx,
          v_matnr(18)  TYPE c,
          v_werks(4)   TYPE c,
          v_price_ctrl TYPE c,
          v_vhcle(10)  TYPE c.
    CLEAR: v_matnr,v_werks,v_price_ctrl,v_vhcle.
    DATA: return TYPE bapiret2.

    FIELD-SYMBOLS <fs_vlcdiavehi_ct> TYPE  vlcdiavehi.

    LOOP AT vlcdiavehi_ct ASSIGNING <fs_vlcdiavehi_ct>.
      <fs_vlcdiavehi_ct>-werks = vlcactdata_cs-werks.

      v_werks = vlcactdata_cs-werks.
      v_matnr = <fs_vlcdiavehi_ct>-matnr.
      v_price_ctrl = 'S'.
      v_vhcle = <fs_vlcdiavehi_ct>-vhcle.
*      IF vlcactdata_cs-werks = yif_dbm_jet_constants=>gc_nai_plant .
      headdata-material = v_matnr.
      headdata-account_view = 'X'.
      bapi_mbew1-val_area = v_werks.
      bapi_mbew1-val_type = v_vhcle.
      bapi_mbewx-val_area = v_werks.
      bapi_mbewx-val_type = v_vhcle.

      IF vlcactdata_cs-werks = '2101'.
        bapi_mbew1-val_class = '8000'.
        bapi_mbewx-val_class = '8000'.
        bapi_mbew1-price_ctrl = v_price_ctrl.
        bapi_mbewx-price_ctrl = 'X'.
      ENDIF.

      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          headdata       = headdata
          valuationdata  = bapi_mbew1
          valuationdatax = bapi_mbewx
        IMPORTING
          return         = return.


**..<< Copy of configurations >>
*        DATA ts_obj_key TYPE   bapi1003_object_keys .
*        DATA it_obj_key TYPE TABLE OF   bapi1003_object_keys .
*        DATA :lv_objkey TYPE   bapi1003_key-object,
*              it_cha_in TYPE TABLE OF bapi1003_alloc_values_char,
*              numbtab   TYPE TABLE OF bapi1003_alloc_values_num,
*              curtab    TYPE TABLE OF bapi1003_alloc_values_curr,
*              it_return TYPE bapiret2_tab.
*        DATA lv_classnum TYPE  bapi1003_key-classnum .
*
*        ts_obj_key-key_field = 'MATNR'.
*        ts_obj_key-value_int = <fs_vlcdiavehi_ct>-matnr.
*        APPEND ts_obj_key TO it_obj_key.
*
*        ts_obj_key-key_field = 'WERKS'.
*        ts_obj_key-value_int = <fs_vlcdiavehi_ct>-werks.
*        APPEND ts_obj_key TO it_obj_key.
*
*        ts_obj_key-key_field = 'CHARG'.
*        ts_obj_key-value_int = <fs_vlcdiavehi_ct>-charg.
*        APPEND ts_obj_key TO it_obj_key.
*
*        CALL FUNCTION 'BAPI_OBJCL_CONCATENATEKEY'
*          EXPORTING
*            objecttable    = 'MCH1'
*          IMPORTING
*            objectkey_conc = lv_objkey
*          TABLES
*            objectkeytable = it_obj_key
*            return         = it_return.
*         move yif_dbm_jet_constants=>GC_NAI_CLASSNUM TO lv_classnum.
**         move 'ZVEHICLE' TO LV_CLASSNUM.
*        CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*          EXPORTING
*            objectkey          = lv_objkey
*            objecttable        = 'MCH1'
*            classnum           = lv_classnum
*            classtype          = '023'
*          TABLES
*            allocvaluesnumnew  = numbtab
*            allocvaluescharnew = it_cha_in
*            allocvaluescurrnew = curtab
*            return             = it_return.
*        IF sy-subrc = 0.
*          READ TABLE it_return TRANSPORTING NO FIELDS
*          WITH KEY type = yif_dbm_jet_constants=>gc_value_e.
*          IF sy-subrc <> 0.
**            COMMIT WORK AND WAIT.
*          ELSE.
*            RAISE action_not_performed.
*          ENDIF.
*        ELSE.
*          RAISE action_not_performed.
*        ENDIF.
**..<< End >>
*      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD execute_zrep.
    vlcactdata_cs-werks = '2101'.
*break sohail.
    CALL FUNCTION 'VELO09_SET_ACTION'
      EXPORTING
        incoming_action_iv         = 'REPL'
      TABLES
        vlcdiavehi_ct              = vlcdiavehi_ct
      CHANGING
        vlcactdata_cs              = vlcactdata_cs
      EXCEPTIONS
        action_not_defined         = 1
        no_authority               = 2
        interlinked_action_error   = 3
        crea_prepare_failed        = 4
        action_not_performed       = 5
        action_not_compl_performed = 6
        OTHERS                     = 7.
    IF sy-subrc = 0.
      vlcactdata_cs-werks = '2101'.
* Implement suitable error handling here
      CALL FUNCTION 'VELO09_SET_ACTION'
        EXPORTING
          incoming_action_iv         = 'ZNJS'
        TABLES
          vlcdiavehi_ct              = vlcdiavehi_ct
        CHANGING
          vlcactdata_cs              = vlcactdata_cs
        EXCEPTIONS
          action_not_defined         = 1
          no_authority               = 2
          interlinked_action_error   = 3
          crea_prepare_failed        = 4
          action_not_performed       = 5
          action_not_compl_performed = 6
          OTHERS                     = 7.
      IF sy-subrc = 0.
        vlcactdata_cs-werks = '2101'.
        vlcactdata_cs-lgort = 'V001'.
*        vlcactdata_cs-bwart = 101.
        vlcactdata_cs-bldat = sy-datum.
        vlcactdata_cs-budat = sy-datum.
      ELSE.
        RAISE action_not_performed.
      ENDIF.
    ELSE.
      RAISE   action_not_performed.
    ENDIF.
  ENDMETHOD.


  METHOD execute_zrpv.
    READ TABLE vlcdiavehi_ct INTO DATA(ls_vlcdaivehi) INDEX 1.
    IF sy-subrc EQ 0.
      ls_vlcdaivehi-zreported =  vlcactdata_cs-zreported.
      ls_vlcdaivehi-zreported_date =  vlcactdata_cs-zreported_date.
      MODIFY vlcdiavehi_ct FROM ls_vlcdaivehi INDEX 1.
    ENDIF.
  ENDMETHOD.


  METHOD execute_zsgi.
    DATA : it_lips          TYPE TABLE OF lips,
           wa_lips          TYPE lips,
           ls_vbkok         TYPE vbkok,
           lt_vbpok         TYPE TABLE OF vbpok,
           wa_vbpok         TYPE vbpok,
           lv_err_anyerr    TYPE c,
           lt_prot          TYPE TABLE OF prott,
           wa_prot          TYPE prott,
           lt_verko         TYPE TABLE OF verko,
           lt_verpo         TYPE TABLE OF verpo,
           lt_vbsupcon      TYPE TABLE OF vbsupcon,
           lt_vlcgissue     TYPE TABLE OF vlcgissue,
           ls_vlcgissue     TYPE vlcgissue,
           wa_vlcdiavehi_ct TYPE vlcdiavehi,
           l_mseg           TYPE mseg,
           it_return        TYPE TABLE OF bapiret2,
           it_return1       TYPE TABLE OF prott,
           wa_return        TYPE bapiret2.

    SELECT * FROM lips INTO TABLE it_lips WHERE vbeln = vlcactdata_cs-lbeln.
    IF sy-subrc EQ 0.
*populate required fields to perform pgi.
      ls_vbkok-vbeln_vl = vlcactdata_cs-lbeln.
      ls_vbkok-vbtyp_vl = 'J'.
      ls_vbkok-wabuc = 'X'.
      ls_vbkok-komue = 'X'.

      LOOP AT vlcdiavehi_ct INTO wa_vlcdiavehi_ct.
        READ TABLE it_lips INTO wa_lips WITH KEY charg = wa_vlcdiavehi_ct-vhcle.
        IF sy-subrc EQ 0.
*        LOOP AT it_lips INTO wa_lips WHERE charg <> space .
          CLEAR lt_vbpok.
          wa_vbpok-vbeln_vl = wa_lips-vbeln. " Delivery No
          wa_vbpok-posnr_vl = wa_lips-posnr. " Delivery Item
          wa_vbpok-vbeln    = wa_lips-vgbel. " Sales order - Ref Doc
          wa_vbpok-posnn    = wa_lips-vgpos. " SO Line item - Ref doc item
          wa_vbpok-matnr    = wa_lips-matnr. " Material No
          wa_vbpok-werks    = wa_lips-werks. " Plant
          wa_vbpok-pikmg    = wa_lips-lfimg.
          wa_vbpok-pikmg_wh = wa_lips-lfimg.
          wa_vbpok-pikmg_wh_bu = wa_lips-lfimg.
          APPEND wa_vbpok TO lt_vbpok.
          CLEAR wa_vbpok.
*        ENDLOOP.
        ENDIF.
      ENDLOOP.




      CALL FUNCTION 'WS_DELIVERY_UPDATE'
        EXPORTING
          vbkok_wa                 = ls_vbkok
          delivery                 = vlcactdata_cs-lbeln
          if_database_update       = '1'
          if_error_messages_send_0 = 'X'
        TABLES
          vbpok_tab                = lt_vbpok
          prot                     = lt_prot
          verko_tab                = lt_verko
          verpo_tab                = lt_verpo
          vbsupcon_tab             = lt_vbsupcon.


      IF lv_err_anyerr IS INITIAL.     " GI doc creation failed


        IMPORT l_mseg_memory TO l_mseg FROM MEMORY ID 'MSG'.
        IF l_mseg-mblnr IS INITIAL.
          LOOP AT lt_prot INTO wa_prot.
            CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
              EXPORTING
                msgid_iv     = wa_prot-msgid
                msgty_iv     = wa_prot-msgty
                msgno_iv     = wa_prot-msgno
                msgv1_iv     = wa_prot-msgv1
                msgv2_iv     = wa_prot-msgv2
                msgv3_iv     = wa_prot-msgv3
                msgv4_iv     = wa_prot-msgv4
              TABLES
                vlch_mssg_ct = vlch_mssg_ct.
          ENDLOOP.
          RAISE action_not_performed.
          RETURN.
        ENDIF.

        LOOP AT vlcdiavehi_ct INTO wa_vlcdiavehi_ct.
          wa_vlcdiavehi_ct-actdoctype = 'ZSGI'.
          ls_vlcgissue-mandt = wa_vlcdiavehi_ct-mandt.
          ls_vlcgissue-vguid = wa_vlcdiavehi_ct-vguid.
          ls_vlcgissue-tstmp = wa_vlcdiavehi_ct-newtsp.
          ls_vlcgissue-actdoctype = 'ZSGI'.
          ls_vlcgissue-mblnr = l_mseg-mblnr.
          ls_vlcgissue-mjahr = l_mseg-mjahr.
          ls_vlcgissue-mblpo = l_mseg-zeile.
          ls_vlcgissue-ernam = sy-uname.

          APPEND ls_vlcgissue TO lt_vlcgissue.
          MODIFY vlcdiavehi_ct FROM wa_vlcdiavehi_ct.
        ENDLOOP.

        CHECK NOT lt_vlcgissue[] IS INITIAL.

        CALL FUNCTION 'VELO04_UPDATE_VLCGISSUE' IN UPDATE TASK
          TABLES
            vlcgissue_it = lt_vlcgissue.

      ENDIF.

      LOOP AT lt_prot INTO wa_prot.
        CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
          EXPORTING
            msgid_iv     = wa_prot-msgid
            msgty_iv     = wa_prot-msgty
            msgno_iv     = wa_prot-msgno
            msgv1_iv     = wa_prot-msgv1
            msgv2_iv     = wa_prot-msgv2
            msgv3_iv     = wa_prot-msgv3
            msgv4_iv     = wa_prot-msgv4
*           DOCNUM_IV    =
*           VGUID_IV     =
*           VHCLE_IV     =
*           VHVIN_IV     =
*           VHCEX_IV     =
          TABLES
            vlch_mssg_ct = vlch_mssg_ct.
      ENDLOOP.
      READ TABLE lt_prot INTO wa_prot WITH KEY msgty = 'E'.
      IF sy-subrc EQ 0.
        RAISE action_not_performed.
      ENDIF.
    ELSE.
      RAISE action_not_performed.
    ENDIF.

  ENDMETHOD.


  METHOD execute_zsgr.
*    DATA : lv_delivery      TYPE lips-vbeln,
*           ls_vbkok         TYPE vbkok,
*           lv_error_any     TYPE c,
*           lt_vlcgreceipt   TYPE TABLE OF vlcgreceipt,
*           ls_vlcgreceipt   TYPE vlcgreceipt,
*           wa_vlcdiavehi_ct TYPE vlcdiavehi,
*           l_mseg           TYPE mseg,
*           l_mkpf           TYPE mkpf,
*           it_return        TYPE TABLE OF bapiret2,
*           wa_return        TYPE bapiret2.
*
*    FIELD-SYMBOLS : <fs_vlcdiavehi_ct> TYPE vlcdiavehi.
*
*    SELECT SINGLE vbeln FROM lips INTO lv_delivery WHERE vbeln EQ vlcactdata_cs-lbeln.
*    IF sy-subrc NE 0.
*      MESSAGE e104(/dbm/vehicle_master) .
*    ENDIF.
*    ls_vbkok-vbeln_vl = lv_delivery.
*
*    ls_vbkok-wabuc = 'X'.
*    ls_vbkok-spe_auto_gr = 'X'.
*
*    CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
*      EXPORTING
*        vbkok_wa      = ls_vbkok
*        synchron      = 'X'
**       commit        = 'X'
*        delivery      = lv_delivery
*      IMPORTING
*        ef_error_any  = lv_error_any
*      EXCEPTIONS
*        error_message = 1
*        OTHERS        = 2.
*    IF lv_error_any IS INITIAL.
*
*      IMPORT l_mkpf_memory TO l_mkpf FROM MEMORY ID 'MSG'.
*      IMPORT l_mseg_memory TO l_mseg FROM MEMORY ID 'MSG'.
*
*      REFRESH lt_vlcgreceipt.
*      LOOP AT vlcdiavehi_ct INTO wa_vlcdiavehi_ct.
*        wa_vlcdiavehi_ct-actdoctype = 'ZSGR'.
*        wa_vlcdiavehi_ct-werks = l_mseg-werks.
*        wa_vlcdiavehi_ct-lgort = l_mseg-lgort.
*        ls_vlcgreceipt-mandt = wa_vlcdiavehi_ct-mandt.
*        ls_vlcgreceipt-vguid = wa_vlcdiavehi_ct-vguid.
*        ls_vlcgreceipt-tstmp = wa_vlcdiavehi_ct-newtsp.
*        ls_vlcgreceipt-actdoctype = 'ZSGR'.
*        ls_vlcgreceipt-mblnr = l_mseg-mblnr.
*        ls_vlcgreceipt-mjahr = l_mseg-mjahr.
*        ls_vlcgreceipt-mblpo = l_mseg-zeile.
*        ls_vlcgreceipt-ernam = sy-uname.
*        ls_vlcgreceipt-revflag = ' '.
*        APPEND ls_vlcgreceipt TO lt_vlcgreceipt.
*        MODIFY vlcdiavehi_ct FROM wa_vlcdiavehi_ct.
*      ENDLOOP.
*      CHECK NOT lt_vlcgreceipt[] IS INITIAL.
*      CALL FUNCTION 'VELO04_UPDATE_VLCGRECEIPT'
*        TABLES
*          vlcgreceipt_it = lt_vlcgreceipt.
*
**      LOOP AT vlcdiavehi_ct ASSIGNING <fs_vlcdiavehi_ct>.
**        <fs_vlcdiavehi_ct>-zveh_bin = ''.
**      ENDLOOP.
*    ENDIF.
*    LOOP AT it_return INTO wa_return.
*      CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
*        EXPORTING
*          msgid_iv     = wa_return-id
*          msgty_iv     = wa_return-type
*          msgno_iv     = wa_return-number
*          msgv1_iv     = wa_return-message_v1
*          msgv2_iv     = wa_return-message_v2
*          msgv3_iv     = wa_return-message_v3
*          msgv4_iv     = wa_return-message_v4
*        TABLES
*          vlch_mssg_ct = vlch_mssg_ct.
*    ENDLOOP.
*    READ TABLE it_return INTO wa_RETURN WITH KEY type = 'E' .
*    IF sy-subrc EQ 0.
*      RAISE action_not_performed.
*    ENDIF.

  ENDMETHOD.


  METHOD execute_zsto.
    DATA : it_header        TYPE bapimepoheader,
           it_headerx       TYPE bapimepoheaderx,
           wa_vlcdiavehi_ct TYPE vlcdiavehi,
           i_item_no        TYPE i,
           it_item          TYPE TABLE OF bapimepoitem,
           wa_item          TYPE bapimepoitem,
           it_item_x        TYPE TABLE OF bapimepoitemx,
           wa_item_x        TYPE bapimepoitemx,
           it_return        TYPE TABLE OF bapiret2,
           wa_return        TYPE bapiret2,
           porder           TYPE bapimepoheader-po_number,
           pheader          TYPE bapimepoheader,
           pexpheader       TYPE bapieikp,
           lt_vlcporder     TYPE TABLE OF vlcporder,
           ls_vlcporder     TYPE vlcporder,
           v_vbeln          TYPE lips-vbeln,
           wa_lips          TYPE lips,
           it_posched       TYPE TABLE OF  bapimeposchedule,
           wa_posched       TYPE bapimeposchedule,
           it_poschedx      TYPE TABLE OF  bapimeposchedulx,
           wa_poschedx      TYPE bapimeposchedulx,
           lt_request       TYPE TABLE OF bapideliciousrequest,
           ls_request       TYPE bapideliciousrequest,
           lt_createditems  TYPE TABLE OF bapideliciouscreateditems,
           ls_createditems  TYPE bapideliciouscreateditems,
           lt_return        TYPE TABLE OF bapiret2,
           ls_return        TYPE bapiret2,
           wa_ekko          TYPE ekko,
           it_ekpo          TYPE TABLE OF ekpo,
           wa_ekpo          TYPE ekpo,
           it_sitem         TYPE TABLE OF bapidlvreftosto,
           wa_sitem         TYPE bapidlvreftosto,
           lv_delivery      TYPE bapishpdelivnumb-deliv_numb,
           lv_count         TYPE bapidlvcreateheader-num_deliveries,
           vstel            TYPE tvst-vstel,
           logsys           TYPE tbdls-logsys,
           ls_itm           TYPE bapidlvitemcreated,

           lt_itm           TYPE TABLE OF bapidlvitemcreated,

           ls_ext           TYPE bapiparex,

           lt_extin         TYPE TABLE OF bapiparex,

           lt_extout        TYPE TABLE OF bapiparex,
           ls_deli          TYPE bapishpdelivnumb,

           lt_deli          TYPE TABLE OF bapishpdelivnumb,
           ship_point       TYPE bapidlvcreateheader-ship_point,
           lt_pti_ekpv_key  TYPE TABLE OF ekpo_key,
           lt_msg           TYPE bapiret2_t,
           ls_msg           LIKE LINE OF lt_msg.


    it_header-doc_type = vlcactdata_cs-bsart.
    it_header-suppl_plnt = vlcactdata_cs-werks.
    it_header-purch_org = vlcactdata_cs-ekorg.
    it_header-pur_group = vlcactdata_cs-ekgrp.
    it_header-creat_date = sy-datum.
    it_header-langu = sy-langu.
    it_headerx-comp_code = 'X'.
    it_headerx-doc_type = 'X'.
    it_headerx-suppl_plnt = 'X'.
    it_headerx-purch_org = 'X'.
    it_headerx-pur_group = 'X'.
    it_headerx-creat_date = 'X'.
    it_headerx-langu = 'X'.

    wa_posched-po_item = '000010'.
    wa_posched-delivery_date = sy-datum.
    wa_posched-quantity = '1'.
    APPEND wa_posched TO it_posched.
    wa_poschedx-po_item = '000010'.
    wa_poschedx-po_itemx = 'X'.
    wa_poschedx-delivery_date  = 'X'.
    wa_poschedx-quantity = 'X'.
    APPEND wa_poschedx TO it_poschedx.

    LOOP AT vlcdiavehi_ct INTO wa_vlcdiavehi_ct.
      it_header-comp_code = vlcactdata_cs-ekorg.
      i_item_no = i_item_no + 10.
      wa_item-po_item = i_item_no.
      wa_item-material = vlcactdata_cs-matnr.
      wa_item-plant = vlcactdata_cs-umwerks.
      wa_item-stge_loc = vlcactdata_cs-umlgo.
      wa_item-suppl_stloc = vlcactdata_cs-lgort.
      wa_item-val_type = wa_vlcdiavehi_ct-charg.
      wa_item-batch = wa_vlcdiavehi_ct-charg.
      wa_item-quantity = '1'.
      wa_item-po_unit = 'EA'.
      APPEND wa_item TO it_item.
      CLEAR :wa_item.

      wa_item_x-po_item = i_item_no.
      wa_item_x-po_itemx = 'X'.
      wa_item_x-material = 'X'.
      wa_item_x-plant = 'X'.
      wa_item_x-stge_loc = 'X'.
      wa_item_x-quantity = 'X'.
      wa_item_x-po_unit = 'X'.
      wa_item_x-val_type = 'X'.
      wa_item_x-batch = 'X'.
      wa_item_x-suppl_stloc = 'X'.
      APPEND wa_item_x TO it_item_x.

      CLEAR : wa_item_x,wa_item,it_return,wa_return.

    ENDLOOP.
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader          = it_header
        poheaderx         = it_headerx
      IMPORTING
        exppurchaseorder  = porder
        expheader         = pheader
        exppoexpimpheader = pexpheader
      TABLES
        return            = it_return
        poitem            = it_item
        poitemx           = it_item_x
        poschedule        = it_posched
        poschedulex       = it_poschedx.

    READ TABLE it_return INTO wa_return WITH KEY type = 'S'.
    IF sy-subrc EQ 0.

      REFRESH lt_vlcporder.
      LOOP AT vlcdiavehi_ct INTO wa_vlcdiavehi_ct.
        LOOP AT it_item INTO wa_item WHERE val_type EQ wa_vlcdiavehi_ct-charg.
          wa_vlcdiavehi_ct-actdoctype = 'ZSTO'.
          ls_vlcporder-mandt = wa_vlcdiavehi_ct-mandt.
          ls_vlcporder-vguid = wa_vlcdiavehi_ct-vguid.
          ls_vlcporder-tstmp = wa_vlcdiavehi_ct-newtsp.
          ls_vlcporder-actdoctype = 'ZSTO'.
          ls_vlcporder-ebeln = porder.
          ls_vlcporder-ebelp = wa_item-po_item.
          ls_vlcporder-cuobj = wa_vlcdiavehi_ct-cuobj.
          ls_vlcporder-ernam = sy-uname.
          APPEND ls_vlcporder TO lt_vlcporder.
          MODIFY vlcdiavehi_ct FROM wa_vlcdiavehi_ct.
        ENDLOOP.
      ENDLOOP.

      LOOP AT lt_vlcporder INTO ls_vlcporder.
        MODIFY vlcporder FROM ls_vlcporder .
      ENDLOOP.
    ENDIF.

    LOOP AT it_return INTO wa_return.
      CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
        EXPORTING
          msgid_iv     = wa_return-id
          msgty_iv     = wa_return-type
          msgno_iv     = wa_return-number
          msgv1_iv     = wa_return-message_v1
          msgv2_iv     = wa_return-message_v2
          msgv3_iv     = wa_return-message_v3
          msgv4_iv     = wa_return-message_v4
        TABLES
          vlch_mssg_ct = vlch_mssg_ct.
    ENDLOOP.
    READ TABLE it_return INTO wa_return WITH KEY type = 'E' .
    IF sy-subrc EQ 0.
      RAISE action_not_performed.
    ENDIF.

  ENDMETHOD.


  METHOD execute_zupd.

    DATA lv_vguid           TYPE /dbe/veh_guid.
    DATA lv_dummy.
    DATA ls_ocf_action      TYPE /dbe/ocf_actions.
    DATA ls_vbak_com        TYPE /dbe/vbak_com.
    DATA ls_events          TYPE /dbe/ocf_events.
    DATA ls_object_events   TYPE /dbe/if_oe_cole=>ty_cole_link.
    DATA ls_dialog_control  TYPE /dbe/oe_dialog_control.
    DATA lt_return          TYPE bapiret2_t.
    DATA lt_vms_actions     TYPE /dbe/vms_actions.
    DATA lt_veh_cvlc03      TYPE /dbe/t_veh_cvlc03.
    DATA lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle.
    DATA lo_order           TYPE REF TO /dbe/cl_order.
    DATA lo_vehi_interface  TYPE REF TO /dbe/cl_veh_option_assistant.
    DATA lv_call_before     TYPE abap_bool.
    DATA lv_new_storage_loc TYPE lgort.



*    lo_vehicle ?= /dbe/if_oe_object.


    READ TABLE vlcdiavehi_ct INTO DATA(ls_vlcdaiveh) INDEX 1.
    IF sy-subrc EQ 0.
      SELECT SINGLE * FROM /dbe/vbap INTO @DATA(ls_vbap) WHERE vguid EQ @ls_vlcdaiveh-vguid AND
                                                               itcanc EQ ' ' AND
                                                               itcat EQ 'P003'.
      IF sy-subrc EQ 0.

* get order
        ls_dialog_control-actvt = /dbe/cl_order_engine=>c_actvt_change.
        ls_dialog_control-dialog = abap_false.
        ls_dialog_control-no_commit = abap_true.

        CALL FUNCTION '/DBE/OE_MAIN_GET'
          EXPORTING
            iv_vbeln          = ls_vbap-vbeln
            is_dialog_control = ls_dialog_control
          IMPORTING
            eo_order          = lo_order
          TABLES
            et_return         = lt_return
          EXCEPTIONS
            internal_error    = 1
            nothing_selected  = 2
            action_error      = 3
            OTHERS            = 4.
        IF sy-subrc <> 0.
          IF sy-subrc = 1.
*            io_vehicle->/dbe/if_oe_object~bal_add_bapiret2( it_bapiret2 = lt_return ).
*            RAISE EXCEPTION TYPE action_not_performed.
          ELSE.
*            io_vehicle->/dbe/if_oe_object~bal_add_bapiret2( it_bapiret2 = lt_return ).
*            RAISE EXCEPTION TYPE action_not_performed.
          ENDIF.
        ELSE.

* set simulated storage location
          lo_order->mo_parameter->set_param( iv_name = 'NEW_SIM_STORAGE_LOCATION' iv_value = vlcactdata_cs-umlgo ).

          LOOP AT lo_order->mt_vbap_com INTO DATA(ls_item_detail) WHERE vguid EQ ls_vlcdaiveh-vguid.
            ls_item_detail-lgort = vlcactdata_cs-umlgo.
            APPEND ls_item_detail TO lo_order->mt_item_detail.
            CLEAR ls_item_detail.
          ENDLOOP.

          CALL FUNCTION '/DBE/OE_MAIN_CONTROL'
            EXPORTING
              iv_event         = 'ITEM_CHANGE'
              io_order         = lo_order
            EXCEPTIONS
              internal_error   = 1
              nothing_selected = 2
              action_error     = 3
              user_abort       = 4
              OTHERS           = 5.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

          CALL FUNCTION '/DBE/OE_MAIN_CONTROL'
            EXPORTING
              iv_event         = 'ORD_SAVE'
              io_order         = lo_order
            EXCEPTIONS
              internal_error   = 1
              nothing_selected = 2
              action_error     = 3
              user_abort       = 4
              OTHERS           = 5.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

          CALL FUNCTION '/DBE/OE_MAIN_EXIT'
            EXPORTING
              io_order = lo_order
            EXCEPTIONS
              OTHERS   = 0.

*       some order events have to be carried out
*----- maybe new one UPDATE_SALESORDER_OPTIONS ----------
*       does the ord_get and item_change

*          ls_object_events-objref = lo_order.
*          ls_object_events-events = /dbe/cl_ocf_events=>read( iv_event = 'UPD_SO_FROM_VEH' ).
*          CLEAR ls_object_events-events-auto_save.
*          CLEAR ls_object_events-events-oe_leave.
*          ls_object_events-oe_control-actvt = /dbe/cl_object_engine=>c_actvt_change.
**          IF lo_vehicle->mo_wrapper IS BOUND.
**            ls_object_events-oe_control-dialog = lo_vehicle->mo_wrapper->ms_oe_control-dialog.
**          ENDIF.
*
**----- ord_save -----------------------------------------
*          CLEAR ls_object_events-events.
*          ls_object_events-events = /dbe/cl_ocf_events=>read( iv_event = /dbe/cl_order_engine=>c_ord_save ).
*          CLEAR ls_object_events-events-auto_save.
*          CLEAR ls_object_events-events-oe_leave.
*          ls_object_events-ignore_cx_oe_nothing_selected = abap_true. "N:2576160
*          ls_object_events-skip_if_not_modified = abap_true. "N:2671186
*
**----- ord_exit -----------------------------------------
*          CLEAR ls_object_events-events.
*          ls_object_events-events = /dbe/cl_ocf_events=>read( iv_event = /dbe/cl_order_engine=>c_ord_exit ).
*          CLEAR ls_object_events-events-auto_save.
*          CLEAR ls_object_events-events-oe_leave.
*          ls_object_events-oe_control-soft_exit = abap_true.


        ENDIF.


      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD execute_zval.
    DATA : wa_vlcdiavehi_ct TYPE vlcdiavehi.

*    LOOP AT vlcdiavehi_ct INTO wa_vlcdiavehi_ct.
*
*    ENDLOOP.

    CALL FUNCTION 'ZVSS_VEHI_VALU_UPDATE' IN UPDATE TASK
      TABLES
        lt_vehicle = vlcdiavehi_ct
* EXCEPTIONS
*       NO_DATA_RECEIVED          = 1
*       NO_UPDATE_PERFORMED       = 2
*       OTHERS     = 3
      .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.



  ENDMETHOD.


  method IF_EX_VLC_EXECUTE_ACTION~CHANGE_MESSAGES.
  endmethod.


  METHOD if_ex_vlc_execute_action~checks_before_action.
    INCLUDE /DBE/lvm03con.

*Prefix for methods name
    CONSTANTS: lc_meth_pref(8)   TYPE c VALUE 'CHECK_'.
*method name
    DATA: lv_meth_name TYPE string.
* Dummy character for hiding message
    DATA: lv_dummy TYPE c.
* Variables for getting exception type
    DATA: lo_root TYPE REF TO cx_root.
    DATA: lv_exceptiontype TYPE string.
    DATA: lv_progname         TYPE syrepid.
    DATA: lv_inclname         TYPE syrepid.
    DATA: lv_srcline          TYPE i.
* Vehicle and status relevant declarations
    DATA:
      lo_vbuffer         TYPE REF TO /DBE/cl_veh_buf,
      lo_vehicle         TYPE REF TO /DBE/cl_veh_dbmvehicle,
      lo_action          TYPE REF TO /DBE/cl_veh_action,
      ls_vlcstatus       TYPE vlcstatus,
      ls_vehicle         TYPE /DBE/s_veh_bob,
      lt_vehicles        TYPE /DBE/t_veh_bob,
      ls_vlcactdata_item TYPE vlcactdata_item_s,
      lo_iobject         TYPE REF TO /DBE/cl_veh_iobject.

*----------------------------------------------------------------------
******************CHANGE DOCUMENT RELATED PART*************************
*----------------------------------------------------------------------
*Store the original vehicle data in class attribute, this attribute is
*used as the original vehicle data for change document functionality
    APPEND vlcdiavehi_is TO mt_vlcdiavehi.
*----------------------------------------------------------------------

    READ TABLE vlcstatus_it INTO ls_vlcstatus WITH KEY vguid = vlcdiavehi_is-vguid.
    IF sy-subrc = 0.
      lo_vbuffer = /DBE/cl_veh_buf=>get_instance( ).
      ls_vehicle-guid = vlcdiavehi_is-vguid.
      ls_vehicle-bobtype = /DBE/cl_veh_dbmvehicle=>gc_bobtype.
      lo_vehicle ?= lo_vbuffer->is_in_buffer( ls_vehicle ).
      IF lo_vehicle IS NOT BOUND.
        READ TABLE vlcactdata_is-actdata_item INTO ls_vlcactdata_item WITH KEY vguid = vlcdiavehi_is-vguid.
        IF sy-subrc = 0.
          lt_vehicles = lo_vbuffer->get_all( ).
          LOOP AT lt_vehicles INTO ls_vehicle.
            lo_vehicle ?= ls_vehicle-bobref.
            lo_iobject ?= lo_vehicle->iobject_get( ).
            IF lo_iobject->get_guid( ) = ls_vlcactdata_item-/dbe/iobjguid AND
               ls_vlcactdata_item-/dbe/iobjguid IS NOT INITIAL.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
      IF lo_vehicle IS BOUND.
        lo_vehicle->get_action( IMPORTING eo_action = lo_action ).
*     in vehicle buffer can be vehicles without preapared action N:1701016
        IF lo_action IS BOUND.
          lo_action->set_status( ls_vlcstatus ).
        ENDIF.
      ENDIF.
    ENDIF.

*construct the relevant methods name
    CONCATENATE lc_meth_pref elementary_action_is-aktion INTO lv_meth_name.

*try to call the method
    TRY.
        CALL METHOD me->(lv_meth_name)
          EXPORTING
            is_incoming_action   = incoming_action_is
            is_elementary_action = elementary_action_is
            is_vlcdiavehi        = vlcdiavehi_is
            is_vlcactdata        = vlcactdata_is
            it_vlcstatus         = vlcstatus_it
            it_vlch_mssg         = vlch_mssg_it
          CHANGING
            ct_vlch_mssg         = vlch_mssg_ct
            ct_action            = action_ct
          EXCEPTIONS
            check_error          = 1
            OTHERS               = 2.
        IF sy-subrc <> 0.
          RAISE vehicle_error.
        ENDIF.
      CATCH cx_sy_dyn_call_illegal_method.
*   This is not an error. Implementation might be in other BAdI or only "technical" action without implementation
      CATCH cx_root INTO lo_root.
*   Error occurred
        lv_exceptiontype = lo_root->get_text( ).
        CALL METHOD lo_root->get_source_position
          IMPORTING
            program_name = lv_progname
            include_name = lv_inclname
            source_line  = lv_srcline.
        MESSAGE e016(velo) WITH lv_exceptiontype space space space INTO lv_dummy.
*     An error has occurred
        CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
          EXPORTING
            msgid_iv     = sy-msgid
            msgty_iv     = sy-msgty
            msgno_iv     = sy-msgno
            msgv1_iv     = sy-msgv1
            msgv2_iv     = sy-msgv2
            msgv3_iv     = sy-msgv3
            msgv4_iv     = sy-msgv4
          TABLES
            vlch_mssg_ct = vlch_mssg_ct.
        RAISE vehicle_error.
    ENDTRY.
  ENDMETHOD.


  method IF_EX_VLC_EXECUTE_ACTION~COMMIT_MODE.
  endmethod.


  method IF_EX_VLC_EXECUTE_ACTION~COMMUNICATE_WITH_EXT_SYSTEM.
  endmethod.


  METHOD if_ex_vlc_execute_action~data_changes_after_action.
* important note:
* At this point of time i.e. after the action execution, the VMS data
* of the vehicle stored in VLCDIAVEHI_CT and in the corresponding instances
* of the buffer (/DBE/CL_VEH_BUF) differ, unless the action itself took care
* about updating it. However, this should not be a problem unless someone tries
* to modify the VMS data of an instance within this BAdI, expecting that the
* changes made here will be taken into account which is not at all the case
* since only the data in VLCDIAVEHI_CT will be commited. Therefore, every change
* here must be done to the VLCDIAVEHI_CT. The reason for its not being a
* problem is that after saving, the saved instances are completely
* removed from the buffer and get newly reloaded from DB level.
* INCLUDE /dbe/lvm01con.
     include /dbe/lvm01ini.

    CONSTANTS:
      lc_timing       TYPE /dbe/veh_pre_post VALUE 'POST',
      lc_utc_timezone TYPE tznzone VALUE IS INITIAL.

    DATA:
      ls_vlcdiavehi              TYPE vlcdiavehi,
      ls_vlcdiavehi_trans        TYPE vlcdiavehi,
      ls_vlcactdata_item         TYPE vlcactdata_item_s,
      lt_bapireturn              TYPE TABLE OF bapiret2,
      ls_bapireturn              TYPE bapiret2,
      ls_vlcmsg                  TYPE vlch_mssg_ps,
      lv_cx_gettext              TYPE sy-msgv1,
      lo_iobject                 TYPE REF TO /dbe/cl_veh_iobject_vehicle,
      ls_iobject                 TYPE /dbe/s_veh_iobject_ref,
      lt_iobjects                TYPE /dbe/t_veh_iobject_ref,
      lo_cx_iobject              TYPE REF TO /dbe/cx_veh_iobject_error,
      ls_vlcvehicle_n            TYPE vlcvehicle,
      ls_vlcvehicle_o            TYPE vlcvehicle,
      ls_vlcadddata_n            TYPE vlc_vlcadddata,
      ls_vlcadddata_o            TYPE vlc_vlcadddata,
      ls_vlcadddata_item         TYPE vlcadddata_item_s,
      lt_vlcadddata_item         TYPE STANDARD TABLE OF vlcadddata,
      ls_vlcadddata              TYPE vlcadddata,
      lt_vlcadddata_n            TYPE STANDARD TABLE OF vlc_vlcadddata,
      lt_vlcadddata_o            TYPE STANDARD TABLE OF vlc_vlcadddata,
      lt_cdtxt                   TYPE TABLE OF cdtxt,
      lr_vehbuf                  TYPE REF TO /dbe/cl_veh_buf,
      lt_vehget                  TYPE /dbe/t_veh_bobget,
      ls_vehget                  TYPE /dbe/s_veh_bobget,
      lt_vehref                  TYPE /dbe/t_veh_bob,
      lt_vehref_relevant         TYPE /dbe/t_veh_bob,
      ls_vehref                  TYPE /dbe/s_veh_bob,
      lr_dbmvehicle              TYPE REF TO /dbe/cl_veh_dbmvehicle,
      lr_cx_root                 TYPE REF TO cx_root,
      lr_cx_cast                 TYPE REF TO cx_sy_move_cast_error,
      lv_progname                TYPE syrepid,
      lv_inclname                TYPE syrepid,
      lv_srcline                 TYPE i,
      lt_cx_root                 TYPE sibfexctab,
      lr_cx_veh_static_check     TYPE REF TO /dbe/cx_veh_static_check,
      ls_vlcactdata              TYPE vlcactdata,
      lv_iobjguid                TYPE /dbe/exts_ouid,
      lv_vguid                   TYPE /dbe/veh_guid,
      lv_tabix                   TYPE sy-tabix,
      lv_subrc                   TYPE sy-subrc,
      lt_vguid                   TYPE vlch_sel_vguid_pt,
      ls_vguid                   LIKE LINE OF  lt_vguid,
      lt_quali                   TYPE vlch_sel_quali_pt,
      ls_quali                   LIKE LINE OF lt_quali,
      ls_vlcstatus               TYPE vlcstatus,
      lv_tcode                   TYPE cdhdr-tcode,
      lv_utime                   TYPE cdhdr-utime,
      lv_udate                   TYPE cdhdr-udate,
      lv_username                TYPE cdhdr-username,
      lv_planned_change_number   TYPE cdhdr-planchngnr,
      lv_object_change_indicator TYPE cdhdr-change_ind,
      lv_planned_or_real_changes TYPE cdhdr-change_ind,
      lv_no_change_pointers      TYPE cdhdr-change_ind,
      lv_objectid                TYPE cdhdr-objectid,
      lt_ltext_instances         TYPE  /dbe/lt_ltext_instances_tt,
      lv_ltext_changed           TYPE char1,
*--> lean vehicle creation action
      lv_actn_clv                TYPE /dbe/ctrl_value,
      lv_vlcadddata_update       TYPE cdpos-chngind,
      lv_dd04v_wa                TYPE dd04v,
      lv_actn_chg                TYPE /dbe/ctrl_value,
      lv_kunnr                   TYPE vlc_kunnr,
      lt_bapiret                 TYPE bapiret2_t,
      lt_relevant_vguids         TYPE vlch_sel_vguid_pt,
      lt_vms_vehicles            TYPE /dbe/t_veh_bob,
      lt_vms_vehicles2           TYPE /dbe/t_veh_bob,
      ls_vms_vehicle             TYPE /dbe/s_veh_bob,
      lt_veh_get                 TYPE /dbe/t_veh_bobget,
      ls_veh_get                 TYPE /dbe/s_veh_bobget,
      lv_actiontype              TYPE vlc_action,
      lv_vd_kunnr                TYPE /dbe/vd_kunnr,
      lv_vd_kunnr2               TYPE /dbe/vd_kunnr,
      lv_adrnr                   TYPE /dbe/adrnr,
      lv_adrnr2                  TYPE /dbe/adrnr,
      lv_cpd                     TYPE xcpdk,
      lv_vbeln_sd                TYPE vbeln,
      lv_ebeln                   TYPE ebeln,
      lv_saveneeded              TYPE abap_bool,
      lv_saveneeded_overall      TYPE abap_bool,
      ls_iobj_data_multi         TYPE /dbe/iobj_data_multi_txt_s,
      lr_iobj_data_multi_com     TYPE REF TO /dbe/iobj_data_multi_com_s,
      ls_iobj_data_multi_com     TYPE /dbe/iobj_data_multi_com_s,
      ls_ipartner                TYPE /dbe/v_ipartner_dynp,
      lv_timestamp               TYPE timestamp,
      lv_system_timezone         TYPE timezone,
      lt_vlc_history             TYPE TABLE OF vlchistory,
      ls_vlc_history             TYPE vlchistory,
      lv_latest_status           TYPE vlchistory-mmsta_new,
      lo_business_partner        TYPE REF TO /dbe/cl_cu_business_partner, ">>>1721400
      lv_tstmp                   TYPE vlc_ltstamp,
      lv_result                  TYPE i.
*    ls_data_general            TYPE bapi_itob,
*    ls_data_specific           TYPE bapi_itob_eq_only,
*    ls_data_generalx           TYPE bapi_itobx,
*    ls_data_specificx          TYPE bapi_itob_eq_onlyx,
*    lt_extensionin             TYPE TABLE OF bapiparex,
*    ls_extensionin             TYPE bapiparex,
*    ls_eams_te_equi            TYPE eams_te_equi,
*    lv_container               TYPE me_max_container,
*    ls_return                  TYPE bapiret2,
*    lt_ihpa                    TYPE TABLE OF ihpavb,
*    ls_equi_sync               TYPE /dbe/itob_str_equi_sync,
*    lo_badi_equi_sync          TYPE REF TO /dbe/itob_equi_sync_badi,
*    lt_ihpa_new                TYPE TABLE OF ihpavb,
*    lt_cpar                    TYPE TABLE OF /dbe/itob_cpar.

    FIELD-SYMBOLS:
      <ls_vlcstatus>       TYPE vlcstatus,
      <ls_ltext_instances> LIKE LINE OF lt_ltext_instances,
      <ls_partner>         TYPE /dbe/v_ipartner_dynp,
      <ls_partner_com>     TYPE /dbe/v_ipartner_dynp.


* Collect DBM relevant vehicles
    lr_vehbuf = /dbe/cl_veh_buf=>get_instance( ).
    lt_vehref = lr_vehbuf->get_all( ).
    LOOP AT lt_vehref INTO ls_vehref.
      TRY.
          lr_dbmvehicle ?= ls_vehref-bobref.
          lv_vguid = lr_dbmvehicle->get_guid( ).
*       only ok vehicles should be checked, some vehicles can be excluded N:1706360
          READ TABLE vlcdiavehi_ct TRANSPORTING NO FIELDS WITH KEY vguid = lv_vguid.
          IF sy-subrc = 0.
            READ TABLE vlcactdata_cs-actdata_item TRANSPORTING NO FIELDS WITH KEY vguid = lv_vguid.
          ENDIF.
          IF sy-subrc = 0.
            ls_vguid-sign   = 'I'.
            ls_vguid-option = 'EQ'.
            ls_vguid-low    = ls_vehref-guid.
            APPEND ls_vguid TO lt_relevant_vguids.
            APPEND ls_vehref TO lt_vehref_relevant.
          ELSE.
            lo_iobject ?= lr_dbmvehicle->iobject_get( ).
            lv_iobjguid = lo_iobject->get_guid( ).
*         only ok vehicles should be checked, some vehicles can be excluded N:1706360
            READ TABLE vlcdiavehi_ct TRANSPORTING NO FIELDS WITH KEY /dbe/iobjguid = lv_iobjguid.
            IF sy-subrc = 0.
              READ TABLE vlcactdata_cs-actdata_item TRANSPORTING NO FIELDS WITH KEY /dbe/iobjguid = lv_iobjguid..
            ENDIF.
            IF sy-subrc = 0.
              ls_vguid-sign   = 'I'.
              ls_vguid-option = 'EQ'.
              ls_vguid-low    = ls_vehref-guid.
              APPEND ls_vguid TO lt_relevant_vguids.
              APPEND ls_vehref TO lt_vehref_relevant.
            ENDIF.
          ENDIF.
        CATCH cx_sy_move_cast_error INTO lr_cx_root.
          CLEAR lt_bapireturn.
          lr_vehbuf->get_messages( EXPORTING io_cx_root    = lr_cx_root
                                   IMPORTING et_bapireturn = lt_bapireturn ).
*     Make it clear as it cannot be filled since the cast failed but it
*     needs to be passed as being an obligatory parameter.
          CLEAR ls_vlcdiavehi.
          CALL FUNCTION '/DBE/VM03_CONVERT_BAPIRET2VMS'
            EXPORTING
              is_vlcdiavehi = ls_vlcdiavehi
              it_bapiret    = lt_bapireturn
            CHANGING
              ct_vlch_mssg  = vlch_mssg_ct.
      ENDTRY.
    ENDLOOP.

*   Collect VMS vehicles which are DBM enabled
    LOOP AT vlcdiavehi_ct INTO ls_vlcdiavehi WHERE /dbe/iobjguid IS NOT INITIAL.
      READ TABLE lt_relevant_vguids WITH KEY low = ls_vlcdiavehi-vguid TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
*       DBM enabled VMS vehicle
        TRY.
            CLEAR ls_veh_get.
            CLEAR lt_veh_get.
            ls_veh_get-guid = ls_vlcdiavehi-vguid.
            ls_veh_get-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
            INSERT ls_veh_get INTO TABLE lt_veh_get.
            /dbe/cl_veh_dbmvehicle=>get_dbmvehicle(
              EXPORTING
                it_bobget   = lt_veh_get
                iv_iobj_req = 'X'
              IMPORTING
                et_bob      = lt_vms_vehicles
            ).

            READ TABLE lt_vms_vehicles INTO ls_vms_vehicle WITH KEY guid = ls_vlcdiavehi-vguid.
            INSERT ls_vms_vehicle INTO TABLE lt_vms_vehicles2.
            lr_dbmvehicle ?= ls_vms_vehicle-bobref.

          CATCH /dbe/cx_veh_error_occured INTO lr_cx_root.
*               Maybe we are in DBM enablement still, no iobject exists on DB level
            TRY.
                /dbe/cl_veh_dbmvehicle=>get_dbmvehicle(
                  EXPORTING
                    it_bobget   = lt_veh_get
                    iv_iobj_req = space
                  IMPORTING
                    et_bob      = lt_vms_vehicles
                ).

                READ TABLE lt_vms_vehicles INTO ls_vms_vehicle WITH KEY guid = ls_vlcdiavehi-vguid.
                INSERT ls_vms_vehicle INTO TABLE lt_vms_vehicles2.
                lr_dbmvehicle ?= ls_vms_vehicle-bobref.
              CATCH /dbe/cx_veh_error_occured INTO lr_cx_root.
                CLEAR lt_bapireturn.
                lr_vehbuf->get_messages(
                  EXPORTING
                    io_cx_root    = lr_cx_root
                  IMPORTING
                    et_bapireturn = lt_bapireturn ).

                CALL FUNCTION '/DBE/VM03_CONVERT_BAPIRET2VMS'
                  EXPORTING
                    is_vlcdiavehi = ls_vlcdiavehi
                    it_bapiret    = lt_bapireturn
                  CHANGING
                    ct_vlch_mssg  = vlch_mssg_ct.
                RAISE processing_impossible.
            ENDTRY.
        ENDTRY.
      ENDIF.
    ENDLOOP.


** determine the customized lean vehicle creation action
*    CALL FUNCTION '/DBE/VM15_GET_INI_VALUE'
*      EXPORTING
*        object               = gc_actn_clv
*      IMPORTING
*        value                = lv_actn_clv
*      EXCEPTIONS
*        object_not_defined   = 1
*        value_not_maintained = 2
*        OTHERS               = 3.
*
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*              RAISING processing_impossible.
*    ENDIF.
*
**--> read first vehicle
*    LOOP AT vlcdiavehi_ct INTO ls_vlcdiavehi WHERE vguid IN lt_relevant_vguids.
**   Additional check needed as if the QCRE is not set as an
**   alias action for QCLV,vehicles still get created but without
**   internal vehicle number!!!
*      IF ls_vlcdiavehi-vhcle IS INITIAL AND incoming_action_is-aktion EQ lv_actn_clv.
*        ls_bapireturn-type   = 'E'.
*        ls_bapireturn-id     = 'VELO'.
*        ls_bapireturn-number = '020'.
*        APPEND ls_bapireturn TO lt_bapireturn.
*
*        CALL FUNCTION '/DBE/VM03_CONVERT_BAPIRET2VMS'
*          EXPORTING
*            is_vlcdiavehi = ls_vlcdiavehi
*            it_bapiret    = lt_bapireturn
*          CHANGING
*            ct_vlch_mssg  = vlch_mssg_ct.
*
*        MESSAGE e020(velo) RAISING processing_impossible.
*      ENDIF.
*    ENDLOOP.

*-----------------------------------------------------------------------
* Save longtext objects on vehicle and vehicle options level. In
* creation mode the business key tdname of vehicle longtext be filled
* with the created vehicle guid.
*-----------------------------------------------------------------------

*--> get the table of longtext object instancies
    CALL FUNCTION '/DBE/VM10_GET_LTEXT_OBJECTS'
      IMPORTING
        et_ltext_instances = lt_ltext_instances.

    LOOP AT lt_ltext_instances ASSIGNING <ls_ltext_instances>.

*--> check if data changed
      CLEAR lv_ltext_changed.
      CALL METHOD <ls_ltext_instances>-mo_ltext->change_status_get
        IMPORTING
          ev_ltext_changed = lv_ltext_changed.
      IF lv_ltext_changed IS INITIAL.
        CONTINUE.
      ENDIF.

*--> creation case: move vehicle guid to longtext key; remark in case of
*    option longtexts the tdname is filled with opclass and opkey (as
*    maximum with 19 characters)
      IF <ls_ltext_instances>-mo_ltext->mv_tdname+19 IS INITIAL.
        CONCATENATE ls_vlcdiavehi-vguid <ls_ltext_instances>-tdname
                    INTO <ls_ltext_instances>-tdname.
        CALL METHOD <ls_ltext_instances>-mo_ltext->key_change
          EXPORTING
            iv_tdname              = <ls_ltext_instances>-tdname
          EXCEPTIONS
            key_change_not_allowed = 1
            OTHERS                 = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                     RAISING processing_impossible.
        ENDIF.
      ENDIF.

*--> save longtext
      CALL METHOD <ls_ltext_instances>-mo_ltext->save
        EXCEPTIONS
          update_error = 1
          OTHERS       = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                   RAISING processing_impossible.
      ENDIF.

    ENDLOOP.

*--> write the table of longtext object instancies back
    CALL FUNCTION '/DBE/VM10_SET_LTEXT_OBJECTS'
      EXPORTING
        it_ltext_instances = lt_ltext_instances.


*-----------------------------------------------------------------------
* Ensure the consistency between the fields LICEXT and LICINT
*-----------------------------------------------------------------------
    LOOP AT vlcdiavehi_ct INTO ls_vlcdiavehi WHERE /dbe/licext IS NOT INITIAL
      AND vguid IN lt_relevant_vguids.
      lv_tabix = sy-tabix.
      ls_vlcdiavehi-/dbe/licint = ls_vlcdiavehi-/dbe/licext.
      CONDENSE ls_vlcdiavehi-/dbe/licint NO-GAPS.

*  --> Update the vehicle
      MODIFY vlcdiavehi_ct FROM ls_vlcdiavehi INDEX lv_tabix.
    ENDLOOP.

*-----------------------------------------------------------------------
* After executing the action, the iObject data has to be saved.
* By saving the iObject data in this place it is possible to still
* change the iObject data in the action's EXECUTE function module.
*-----------------------------------------------------------------------

    TRY.
        lifecycle_update(
          EXPORTING
            iv_timing            = lc_timing
            is_incoming_action   = incoming_action_is
            is_elementary_action = elementary_action_is
            it_veh_bob           = lt_vehref_relevant
          CHANGING
            ct_vlcdiavehi        = vlcdiavehi_ct
            cs_vlcactdata        = vlcactdata_cs
            ct_vlch_mssg         = vlch_mssg_ct ).
      CATCH cx_static_check
            cx_dynamic_check INTO lr_cx_root.
        CLEAR lt_bapireturn.
        lr_vehbuf->get_messages( EXPORTING io_cx_root    = lr_cx_root
                                 IMPORTING et_bapireturn = lt_bapireturn ).
*     Make it clear as it cannot be filled since the cast failed but it
*     needs to be passed as being an obligatory parameter.
        CLEAR ls_vlcdiavehi.
        CALL FUNCTION '/DBE/VM03_CONVERT_BAPIRET2VMS'
          EXPORTING
            is_vlcdiavehi = ls_vlcdiavehi
            it_bapiret    = lt_bapireturn
          CHANGING
            ct_vlch_mssg  = vlch_mssg_ct.
        RAISE processing_impossible.
    ENDTRY.

    TRY.
        /dbe/cl_itob_synch_vms=>data_changes_after_action( EXPORTING iv_action     = elementary_action_is-aktion
                                                           CHANGING  ct_vlcdiavehi = vlcdiavehi_ct
                                                                     ct_vlch_mssg  = vlch_mssg_ct
                                                                     ct_vlcstatus  = vlcstatus_ct ).
      CATCH /dbme/cx_cma_main INTO DATA(lo_error).
        IF lo_error->is_empty( ) = abap_false.
          lo_error->set_sy_message( ).
          CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
            EXPORTING
              msgid_iv     = sy-msgid
              msgty_iv     = sy-msgty
              msgno_iv     = sy-msgno
              msgv1_iv     = sy-msgv1
              msgv2_iv     = sy-msgv2
              msgv3_iv     = sy-msgv3
              msgv4_iv     = sy-msgv4
            TABLES
              vlch_mssg_ct = vlch_mssg_ct.
        ENDIF.
        RAISE processing_impossible.
    ENDTRY.

** Set the legal owner of the vehicle
*    CASE incoming_action_is-aktion.
*      WHEN 'QINV' OR 'INIV'.
*        lv_actiontype = /dbe/cl_veh_partner=>c_act_incoming_invoice.
*      WHEN 'QIIR' OR 'IIVR'.
*        lv_actiontype = /dbe/cl_veh_partner=>c_act_cancel_incinvoice.
*      WHEN 'QORD' OR 'ORD1' OR 'QORB'.
*        lv_actiontype = /dbe/cl_veh_partner=>c_act_po_create.
*        lv_ebeln = vlcactdata_cs-ebeln.
*      WHEN 'OUIV'.
*        lv_actiontype = /dbe/cl_veh_partner=>c_act_bill_vms.
*        lv_vbeln_sd = vlcactdata_cs-vbeln.
*      WHEN 'OIVR' OR 'RECM'.
*        lv_actiontype = /dbe/cl_veh_partner=>c_act_bill_canc_vms.
*    ENDCASE.
*    IF incoming_action_is-aktion <> 'QOIV' AND
*       incoming_action_is-aktion <> 'QOIR' AND
*       incoming_action_is-aktion <> 'QFOR' AND
*       incoming_action_is-aktion <> 'QFOC' AND
*       incoming_action_is-aktion <> 'QRBD' AND
*       incoming_action_is-aktion <> 'QADC'.
**     Handled in BAdI /DBE/BADI_VEHICLE_ACTIONS, no owner determination here
*      LOOP AT vlcdiavehi_ct INTO ls_vlcdiavehi WHERE /dbe/iobjguid IS NOT INITIAL.
*        CALL METHOD /dbe/cl_veh_partner=>determine_owner
*          EXPORTING
*            is_vlcdiavehi = ls_vlcdiavehi
*            iv_actiontype = lv_actiontype
**           io_order      =
*            iv_ebeln      = lv_ebeln
*            iv_vbeln_sd   = lv_vbeln_sd
*          IMPORTING
*            ev_kunnr      = lv_vd_kunnr
*            ev_adrnr      = lv_adrnr
*            ev_cpd        = lv_cpd
*            es_bapiret2   = ls_bapireturn
*          EXCEPTIONS
*            not_found     = 1
*            error_occured = 2
*            OTHERS        = 3.
*        IF sy-subrc <> 0.
*          IF sy-subrc <> 1.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING processing_impossible.
*          ENDIF.
*        ENDIF.
*        READ TABLE lt_vms_vehicles2 INTO ls_vms_vehicle WITH KEY guid = ls_vlcdiavehi-vguid.
*        IF sy-subrc <> 0.
*          READ TABLE lt_vehref_relevant INTO ls_vms_vehicle WITH KEY guid = ls_vlcdiavehi-vguid.
*        ENDIF.
*        IF ls_vms_vehicle IS NOT INITIAL.
*          lr_dbmvehicle ?= ls_vms_vehicle-bobref.
*        ELSE.
*          RAISE processing_impossible.
*        ENDIF.
*        TRY.
*            lo_iobject ?= lr_dbmvehicle->iobject_get( ).
*            lr_iobj_data_multi_com ?= lo_iobject->get_data_com( lr_dbmvehicle->gc_iobj_data_multi_com_s ).
*          CATCH cx_root.
*            RAISE processing_impossible.
*        ENDTRY.
*        ls_iobj_data_multi_com = lr_iobj_data_multi_com->*.
*        lv_saveneeded = abap_false.                         "1719797
*        READ TABLE ls_iobj_data_multi_com-/dbe/v_ipartner INTO ls_ipartner
*             WITH KEY parvw = /dbe/cl_veh_partner=>c_parvw_owner.
*        IF sy-subrc = 0.
*          IF ls_ipartner-kunnr <> lv_vd_kunnr.
*            DELETE ls_iobj_data_multi_com-/dbe/v_ipartner WHERE parvw = /dbe/cl_veh_partner=>c_parvw_owner.
*            lv_saveneeded = abap_true.                      "1719797
*          ENDIF.
*        ELSE.
*          IF lv_vd_kunnr IS NOT INITIAL.                     "check if save is necessary N:1776242
*            lv_saveneeded = abap_true.
*          ENDIF.
*        ENDIF.
*        IF lv_saveneeded = abap_true.
*          CLEAR ls_ipartner.
*          IF lv_vd_kunnr IS NOT INITIAL.
*            ls_ipartner-parvw = /dbe/cl_veh_partner=>c_parvw_owner.
*            ls_ipartner-kunnr = lv_vd_kunnr.
*            ls_ipartner-adrnr = lv_adrnr.
*
*            CALL METHOD /dbe/cl_cu_business_partner=>get_singleton
*              RECEIVING
*                ro_single = lo_business_partner.
*
*            ls_ipartner-partner = lo_business_partner->bp_for_customer_get( iv_kunnr = ls_ipartner-kunnr ).
*            TRY.
*                ls_ipartner-partner_desc = lo_business_partner->get_bp_description(
*                  iv_bpnum     = ls_ipartner-partner
*                  iv_with_name = 'X' ).
*              CATCH /dbe/cx_cu_no_data.
*                CLEAR: lt_bapireturn,
*                       ls_bapireturn,
*                       ls_vlcdiavehi.                       "1722356
*                ls_bapireturn-type   = 'W'.                 "1794444
*                ls_bapireturn-id     = '/DBE/CUSTOMER'.
*                ls_bapireturn-number = '036'.
*                ls_bapireturn-message_v1 = ls_ipartner-kunnr.
*                APPEND ls_bapireturn TO lt_bapireturn.
*
*                CALL FUNCTION '/DBE/VM03_CONVERT_BAPIRET2VMS'
*                  EXPORTING
*                    is_vlcdiavehi = ls_vlcdiavehi
*                    it_bapiret    = lt_bapireturn
*                  CHANGING
*                    ct_vlch_mssg  = vlch_mssg_ct.
*            ENDTRY.                                         "<<<1721400
*
*            APPEND ls_ipartner TO ls_iobj_data_multi_com-/dbe/v_ipartner.
*          ENDIF.
*
*          lr_iobj_data_multi_com->* = ls_iobj_data_multi_com.
*          TRY.
*              lo_iobject->validate_com( ).
*              lo_iobject->com2work( ).
*              lr_dbmvehicle->before_save( ).                "N:1702116
*            CATCH cx_root.
*              RAISE processing_impossible.
*          ENDTRY.
*        ELSE.
**       check if iObject was modified in VELO to force set and save N:1776242
*          IF lv_saveneeded IS INITIAL AND lr_dbmvehicle->is_registered_for_commit( ) IS INITIAL.
*            TRY.
*                lv_saveneeded = lo_iobject->is_modified( ).
*              CATCH cx_root.
*                RAISE processing_impossible.
*            ENDTRY.
*          ENDIF.
*        ENDIF.
**     set overall save needed flag                                               "1814926
*        IF lv_saveneeded IS NOT INITIAL.
*          lv_saveneeded_overall = abap_true.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.

    IF incoming_action_is-intrlk = abap_true OR lv_saveneeded_overall = abap_true. "1729840,1814926
      LOOP AT lt_vehref_relevant INTO ls_vehref.
        lr_dbmvehicle ?= ls_vehref-bobref.
        IF lr_dbmvehicle->is_registered_for_commit( ) <> 'X'.
          lo_iobject ?= lr_dbmvehicle->iobject_get( ).
          IF lo_iobject IS BOUND AND lo_iobject->is_explicit_save( ) <> 'X'.     "Exclude in case that explicit save will be executed N:1760783
            ls_iobject-iobject = lo_iobject.
            APPEND ls_iobject TO lt_iobjects.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lv_saveneeded_overall = abap_true.                 "1814926
        LOOP AT lt_vms_vehicles2 INTO ls_vehref.
          lr_dbmvehicle ?= ls_vehref-bobref.
          IF lr_dbmvehicle->is_registered_for_commit( ) <> 'X'.
            lo_iobject ?= lr_dbmvehicle->iobject_get( ).
            IF lo_iobject IS BOUND AND lo_iobject->is_explicit_save( ) <> 'X'.   "Exclude in case that explicit save will be executed N:1760783
              ls_iobject-iobject = lo_iobject.
              APPEND ls_iobject TO lt_iobjects.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF lt_iobjects IS NOT INITIAL.
        TRY.
            /dbe/cl_veh_iobject_vehicle=>/dbe/if_veh_iobject_mass~set( lt_iobjects ).
            /dbe/cl_veh_iobject_vehicle=>/dbe/if_veh_iobject_mass~save( ).

          CATCH /dbe/cx_veh_nothing_done.
*         Not an error, iobject save skipped.

          CATCH /dbe/cx_veh_iobject_error INTO lo_cx_iobject.
            LOOP AT lo_cx_iobject->mt_bapiret INTO ls_bapireturn WHERE type CA 'AE'.
              CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
                EXPORTING
                  msgid_iv     = ls_bapireturn-id
                  msgty_iv     = ls_bapireturn-type
                  msgno_iv     = ls_bapireturn-number
                  msgv1_iv     = ls_bapireturn-message_v1
                  msgv2_iv     = ls_bapireturn-message_v2
                  msgv3_iv     = ls_bapireturn-message_v3
                  msgv4_iv     = ls_bapireturn-message_v4
                TABLES
                  vlch_mssg_ct = vlch_mssg_ct.
            ENDLOOP.
            RAISE processing_impossible.
        ENDTRY.
      ENDIF.
    ENDIF.

* remove vehicle after commit/rollback to avoid dump in case of update from actions without commit N:1710097
    lr_vehbuf->rem_bob_after_tx( lt_vms_vehicles2 ).

* FIXME: Hardcoding on action names is not allowed. However,
* currently there's no customizing to figure which action is
* being executed as actions can be reimplemented in Z namespace
* or even aliases can be used.
*    IF incoming_action_is-aktion = 'QDBM' OR
*       elementary_action_is-aktion = 'QVED'.                "N:1713524
*      LOOP AT lt_iobjects INTO ls_iobject.
*        lo_iobject ?= ls_iobject-iobject.
*        lv_iobjguid = lo_iobject->get_guid( ).
*        /dbe/exts_cl_a_xobject=>dequeue( iv_object_id = lv_iobjguid ).
**       FIXME: This is necessary because in a VMS-DBM integrated
**       scenario distinguishing actions of VMS/DBM is based on
**       the vehicle buffer's being empty. When QDBM is executed
**       (VMS only) the buffer contains vehicles so determining
**       the list of possible actions is not working properly.
**       The best solution would be to reengineer the fm /DBE/VM14_ENABLE_VMS2DBM
**       to create the iobject part of the vehicle only by using
**       the iobject class and not the vehicle class itself.
**       Deleting the buffer would be useless then as it'd not be used
**       at all. The unlocking above needs to be reconsidered as well
**       to see if it can be moved to that fm or not.
*        lr_vehbuf->del_buf( ).
*      ENDLOOP.
*    ENDIF.

*-----------------------------------------------------------------------
*Change document functionality
*-----------------------------------------------------------------------
*  Note 3074241 {
*  Please notice, that the note 3074241 comments the generation of change documents at VSS side (because starting from S/4 VMS does it)
*  LOOP AT vlcdiavehi_ct INTO ls_vlcdiavehi WHERE vguid IN lt_relevant_vguids.
*    READ TABLE mt_vlcdiavehi INTO ls_vlcdiavehi_trans
*      WITH KEY vguid = ls_vlcdiavehi-vguid.
*    IF sy-subrc NE 0.
*      CONTINUE.
*    ENDIF.
**   move the original vehicle data to the vlcvehicle structure
*    MOVE-CORRESPONDING ls_vlcdiavehi_trans TO ls_vlcvehicle_o.
**   move the new vehicle data to the vlcvehicle structure
*    MOVE-CORRESPONDING vlcactdata_cs TO ls_vlcvehicle_n.
*    MOVE-CORRESPONDING ls_vlcdiavehi TO ls_vlcvehicle_n.
*    ls_vlcvehicle_n-mandt = sy-mandt.
*    ls_vlcvehicle_o-mandt = sy-mandt.
**   Check if VLCADDDATA is change document relevant (only QUASP is relevant)
*    CALL FUNCTION 'DDIF_DTEL_GET'
*      EXPORTING
*        name          = 'VLC_QTEXT'
*      IMPORTING
*        dd04v_wa      = lv_dd04v_wa
*      EXCEPTIONS
*        illegal_input = 1
*        OTHERS        = 2.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*      RAISING processing_impossible.
*    ENDIF.
*
*    IF lv_dd04v_wa-logflag IS NOT INITIAL.
**     VLCADDDATA is change document relevant, prepare structures
**     move the new vehicle additional data to the vlcadddata structure
*      LOOP AT vlcactdata_cs-adddata_item[] INTO ls_vlcadddata_item
*        WHERE vguid = ls_vlcdiavehi-vguid.
*        MOVE-CORRESPONDING ls_vlcadddata_item TO ls_vlcadddata_n.
*        ls_vlcadddata_n-mandt = sy-mandt.
*        APPEND ls_vlcadddata_n TO lt_vlcadddata_n[].
*        ls_quali-sign = 'I'.
*        ls_quali-option = 'EQ'.
*        ls_quali-low = ls_vlcadddata_n-aqual.
*        APPEND ls_quali TO lt_quali.
*      ENDLOOP.
*
**     prepare "list" of guids
*      ls_vguid-sign   = 'I'.
*      ls_vguid-option = 'EQ'.
*      ls_vguid-low    = ls_vlcdiavehi-vguid.
*      APPEND ls_vguid TO lt_vguid.
*
**     if there is no qualifier don't read the data from VLCADDDATA table
*      IF NOT lt_quali IS INITIAL.                           "n:1697761
**       read the vehicle's qualifier data
*        CALL FUNCTION 'VELO14_READ_ADDDATA'
*          TABLES
*            vlcguid_range_it  = lt_vguid
*            vlcquali_range_it = lt_quali
*            vlcadddata_et     = lt_vlcadddata_item
*          EXCEPTIONS
*            no_adddata_found  = 0
*            OTHERS            = 0.
**       Add original qualifiers to the old vlcadddata table
**       Only one vehicle adddata was requested so no need to specify a
**       where clause as condition for vguid.
*        LOOP AT lt_vlcadddata_item INTO ls_vlcadddata.
*          MOVE-CORRESPONDING ls_vlcadddata TO ls_vlcadddata_o.
*          APPEND ls_vlcadddata_o TO lt_vlcadddata_o.
*        ENDLOOP.
*        MOVE 'U' TO lv_vlcadddata_update.
*      ENDIF.
*    ELSE.
**     VLCADDDATA change is not recorded
*      MOVE space TO lv_vlcadddata_update.
*    ENDIF.
*
**  Set the change document header data
*    MOVE: sy-tcode              TO  lv_tcode,
*          sy-uname              TO  lv_username,
*          'U'                   TO  lv_object_change_indicator.
*
*    lv_objectid = ls_vlcdiavehi-vguid.
*
**   check change of availability code, if new value is in vlcstatus_ct then move new avail to ls_vlcvehicle_n to have it recorded in change documents
**   VMS will update VLCDIAVEHI_CT later from vlcstatus so we have to simulate it here N:1871309
*    READ TABLE vlcstatus_ct INTO ls_vlcstatus WITH KEY vguid = ls_vlcdiavehi-vguid.
*    IF sy-subrc = 0.
*      IF ls_vlcstatus-avail IS NOT INITIAL AND ls_vlcvehicle_n-avail <> ls_vlcstatus-avail.
*        ls_vlcvehicle_n-avail = ls_vlcstatus-avail.
*      ENDIF.
*    ENDIF.
*
*    CALL FUNCTION 'GET_SYSTEM_TIMEZONE'
*      IMPORTING
*        timezone            = lv_system_timezone
*      EXCEPTIONS
*        customizing_missing = 1
*        OTHERS              = 2.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING processing_impossible.
*    ENDIF.
*
*    CONVERT DATE sy-datum TIME sy-uzeit INTO TIME STAMP lv_timestamp TIME ZONE lv_system_timezone.
*    CONVERT TIME STAMP lv_timestamp TIME ZONE lc_utc_timezone INTO DATE lv_udate TIME lv_utime.
*
**   Perform change docuemnt functionality
*    CALL FUNCTION 'VEHICLE_WRITE_DOCUMENT'
*      EXPORTING
*        objectid                = lv_objectid
*        tcode                   = lv_tcode
*        utime                   = lv_utime
*        udate                   = lv_udate
*        username                = lv_username
*        planned_change_number   = lv_planned_change_number
*        object_change_indicator = lv_object_change_indicator
*        planned_or_real_changes = lv_planned_or_real_changes
*        no_change_pointers      = lv_no_change_pointers
*        upd_vlcadddata          = lv_vlcadddata_update
*        n_vlcvehicle            = ls_vlcvehicle_n
*        o_vlcvehicle            = ls_vlcvehicle_o
*        upd_vlcvehicle          = 'U'
*      TABLES
*        icdtxt_vehicle          = lt_cdtxt
*        xvlcadddata             = lt_vlcadddata_n
*        yvlcadddata             = lt_vlcadddata_o.
*
*    CLEAR: lt_vlcadddata_n,
*           lt_vlcadddata_o,
*           ls_vlcvehicle_n,
*           ls_vlcvehicle_o,
*           lt_vlcadddata_item,
*           lt_vguid,
*           lt_quali.                                        "1521509
*  ENDLOOP.
*  Note 3074241 }

*    CLEAR mt_vlcdiavehi.

*--------------------------------------------------------------------------------------*
*   Vehicle Costing
*--------------------------------------------------------------------------------------*
*  CASE elementary_action_is-aktion  .
*    WHEN 'QAIN' .
*      CLEAR lv_latest_status.
*      CLEAR lv_tstmp.
*      LOOP AT vlcdiavehi_ct INTO ls_vlcdiavehi.
*        SELECT * FROM vlchistory INTO TABLE lt_vlc_history WHERE vguid = ls_vlcdiavehi-vguid." AND mmsta_new = 'QP90'.
*        IF sy-subrc = 0.
*          SORT lt_vlc_history DESCENDING BY tstmp.
*          LOOP AT  lt_vlc_history INTO ls_vlc_history WHERE ( mmsta_old NE 'QP95' AND mmsta_new = 'QP90' ) OR  ( mmsta_old NE 'QP90' AND mmsta_new = 'QP95' ) .
*            READ TABLE vlcstatus_ct ASSIGNING <ls_vlcstatus> WITH KEY mmstatold = 'QP95'  vguid = ls_vlcdiavehi-vguid..
*            IF sy-subrc = 0 .
*              <ls_vlcstatus>-mmstatnew  = lv_latest_status = ls_vlc_history-mmsta_old.
**              lv_tstmp  = ls_vlc_history-tstmp  .
*            ENDIF.
*            EXIT.
*          ENDLOOP.
*        ENDIF.
*      ENDLOOP.
*
*    WHEN 'QAPC'.
*      LOOP AT vlcdiavehi_ct INTO ls_vlcdiavehi.
*        SELECT * FROM vlchistory INTO TABLE lt_vlc_history WHERE vguid = ls_vlcdiavehi-vguid ."AND  mmsta_new = 'QP90' AND mmsta_old NE 'QP95'."mmsta_new = 'QP95' AND mmsta_old NE 'QP90'.
*        IF sy-subrc = 0.
*          SORT lt_vlc_history DESCENDING BY tstmp .
*          DELETE lt_vlc_history WHERE ( ( mmsta_new = 'QP95' OR mmsta_new = 'QP90' OR mmsta_old = 'QP90' OR mmsta_old = 'QP95' ) ).
*          "get only transition to and from vehicle relevant status
*          LOOP AT lt_vlc_history INTO ls_vlc_history .."WHERE ( NOT ( mmsta_new = 'QP95' OR mmsta_new = 'QP90' OR mmsta_old = 'QP90' OR mmsta_old = 'QP95' ) ).
*            READ TABLE vlcstatus_ct ASSIGNING <ls_vlcstatus> WITH KEY  vguid = ls_vlcdiavehi-vguid..
*            IF sy-subrc = 0 .
*              <ls_vlcstatus>-mmstatnew = ls_vlc_history-mmsta_new.
*            ENDIF.
*            EXIT.
*          ENDLOOP.
*        ENDIF.
*      ENDLOOP.
*
*  ENDCASE.


  ENDMETHOD.


  METHOD if_ex_vlc_execute_action~data_changes_before_action.
* Since actions always get performed for exactly one vehicle when using
* /DBE/VM01 function modules we can assume that the VLCACTDATA_ITEM and
* VLCDIAVEHI tables only contain one record each.

  constants:
    lc_timing          type /dbe/veh_pre_post value 'PRE'.

    DATA:
      ls_vlcdiavehi          TYPE vlcdiavehi,
      ls_vlcactdata_item     TYPE vlcactdata_item_s,
      lt_cvlc03              TYPE TABLE OF cvlc03,
      lv_tabix               TYPE sy-tabix,
      lv_iobjguid            TYPE /dbe/exts_ouid,
      lv_vguid               TYPE /dbe/veh_guid,
      lv_cx_gettext          TYPE sy-msgv1,
      lv_progname            TYPE syrepid,
      lv_inclname            TYPE syrepid,
      lv_srcline             TYPE i,
      lr_vehbuf              TYPE REF TO /dbe/cl_veh_buf,
      lr_cx_cast             TYPE REF TO cx_sy_move_cast_error,
      lr_cx_root             TYPE REF TO cx_root,
      lr_cx_veh_static_check TYPE REF TO /dbe/cx_veh_static_check,
      lr_dbmvehicle          TYPE REF TO /dbe/cl_veh_dbmvehicle,
      ls_bapireturn          TYPE bapiret2,
      ls_vehget              TYPE /dbe/s_veh_bobget,
      ls_vehref              TYPE /dbe/s_veh_bob,
      lt_bapireturn          TYPE TABLE OF bapiret2,
      lt_vehget              TYPE /dbe/t_veh_bobget,
      lt_vehref              TYPE /dbe/t_veh_bob,
      lt_vehref_relevant     TYPE /dbe/t_veh_bob,
      lo_iobject             TYPE REF TO /dbe/cl_veh_iobject_vehicle,
      lt_relevant_vguids     TYPE vlch_sel_vguid_pt,
      ls_vguid               TYPE LINE OF vlch_sel_vguid_pt.

* Collect DBM implementation relevant vehicles
    lr_vehbuf = /dbe/cl_veh_buf=>get_instance( ).
    lt_vehref = lr_vehbuf->get_all( ).
    LOOP AT lt_vehref INTO ls_vehref.
      TRY.
          lr_dbmvehicle ?= ls_vehref-bobref.
          lv_vguid = lr_dbmvehicle->get_guid( ).
*     only ok vehicles should be checked, some vehicles can be excluded N:1706360
          READ TABLE vlcdiavehi_ct TRANSPORTING NO FIELDS WITH KEY vguid = lv_vguid.
          IF sy-subrc = 0.
            READ TABLE vlcactdata_cs-actdata_item TRANSPORTING NO FIELDS WITH KEY vguid = lv_vguid.
          ENDIF.
          IF sy-subrc = 0.
            ls_vguid-sign   = 'I'.
            ls_vguid-option = 'EQ'.
            ls_vguid-low    = ls_vehref-guid.
            APPEND ls_vguid TO lt_relevant_vguids.
            APPEND ls_vehref TO lt_vehref_relevant.
          ELSE.
            lo_iobject ?= lr_dbmvehicle->iobject_get( ).
            lv_iobjguid = lo_iobject->get_guid( ).
*       only ok vehicles should be checked, some vehicles can be excluded N:1706360
            READ TABLE vlcdiavehi_ct TRANSPORTING NO FIELDS WITH KEY /dbe/iobjguid = lv_iobjguid.
            IF sy-subrc = 0.
              READ TABLE vlcactdata_cs-actdata_item TRANSPORTING NO FIELDS WITH KEY /dbe/iobjguid = lv_iobjguid.
            ENDIF.
            IF sy-subrc = 0.
              lr_dbmvehicle->set_guid( ls_vlcactdata_item-vguid ).
              ls_vguid-sign   = 'I'.
              ls_vguid-option = 'EQ'.
              ls_vehref-guid = ls_vguid-low = lr_dbmvehicle->get_guid( ).
              APPEND ls_vguid TO lt_relevant_vguids.
              APPEND ls_vehref TO lt_vehref_relevant.
            ENDIF.
          ENDIF.
        CATCH cx_sy_move_cast_error INTO lr_cx_root.
          CLEAR lt_bapireturn.
          lr_vehbuf->get_messages( EXPORTING io_cx_root = lr_cx_root
                                   IMPORTING et_bapireturn = lt_bapireturn ).
*     Make it clear as it cannot be filled since the cast failed but it
*     needs to be passed as being an obligatory parameter.
          CLEAR ls_vlcdiavehi.
          CALL FUNCTION '/DBE/VM03_CONVERT_BAPIRET2VMS'
            EXPORTING
              is_vlcdiavehi = ls_vlcdiavehi
              it_bapiret    = lt_bapireturn
            CHANGING
              ct_vlch_mssg  = vlch_mssg_ct.
      ENDTRY.
    ENDLOOP.

* Check if there are any vehicles that need to be processed by DBM
    IF lt_relevant_vguids IS INITIAL.
      RETURN.
    ENDIF.
*-----------------------------------------------------------------------
* In order to make sure that create actions write the IObject Guid to
* the vehicle we have to write it to VLCDIAVEHI because VELO10_CREA_
* EXECUTE does not take care of the IOBJGUID.
*-----------------------------------------------------------------------
    LOOP AT vlcdiavehi_ct INTO ls_vlcdiavehi WHERE vguid IN lt_relevant_vguids.
      lv_tabix = sy-tabix.
      READ TABLE vlcactdata_cs-actdata_item INTO ls_vlcactdata_item
        WITH KEY vguid = ls_vlcdiavehi-vguid.
      IF ls_vlcdiavehi-/dbe/iobjguid IS INITIAL.
        ls_vlcdiavehi-/dbe/iobjguid = ls_vlcactdata_item-/dbe/iobjguid.
        MODIFY vlcdiavehi_ct FROM ls_vlcdiavehi INDEX lv_tabix.
      ENDIF.
      IF ls_vlcdiavehi-/dbe/spart IS INITIAL.
        ls_vlcdiavehi-/dbe/spart = ls_vlcactdata_item-/dbe/spart.
        MODIFY vlcdiavehi_ct FROM ls_vlcdiavehi INDEX lv_tabix.
      ENDIF.
    ENDLOOP.

*-----------------------------------------------------------------------
* Handling of iObject data for interlinked actions.
* In case an interlinked action is being executed and the current
* elementary action is not the first action, the iObject data has to
* be refreshed and read newly from the database.
*-----------------------------------------------------------------------

*  IF incoming_action_is-aktion <> elementary_action_is-aktion.
**   an interlinked action is being processed. Find out if it is not the
**   first elementary action.
*    CALL FUNCTION 'VELO14_READ_CVLC03I'
*      EXPORTING
*        action_iv = incoming_action_is-aktion
*      TABLES
*        cvlc03_et = lt_cvlc03.
*
*    READ TABLE lt_cvlc03
*      TRANSPORTING NO FIELDS
*      WITH KEY aktion = elementary_action_is-aktion.
*
*    IF sy-tabix > 1.
**     the current elementary action is not the first of the interlinked
**     action. Refresh the iObject data.
*      CALL FUNCTION '/DBE/VM02_IOBJ_REFRESH'.
*    ENDIF.
*  ENDIF.

    TRY.
        lifecycle_update(
          EXPORTING
            iv_timing            = lc_timing
            is_incoming_action   = incoming_action_is
            is_elementary_action = elementary_action_is
            it_veh_bob           = lt_vehref_relevant
          CHANGING
            ct_vlcdiavehi        = vlcdiavehi_ct
            cs_vlcactdata        = vlcactdata_cs
            ct_vlch_mssg         = vlch_mssg_ct ).
      CATCH cx_static_check
            cx_dynamic_check INTO lr_cx_root.
        CLEAR lt_bapireturn.
        lr_vehbuf->get_messages( EXPORTING io_cx_root = lr_cx_root
                                 IMPORTING et_bapireturn = lt_bapireturn ).
        CLEAR ls_vlcdiavehi.
        CALL FUNCTION '/DBE/VM03_CONVERT_BAPIRET2VMS'
          EXPORTING
            is_vlcdiavehi = ls_vlcdiavehi
            it_bapiret    = lt_bapireturn
          CHANGING
            ct_vlch_mssg  = vlch_mssg_ct.
        RAISE processing_impossible.
    ENDTRY.

    TRY.

        /dbe/cl_itob_synch_vms=>data_changes_before_action( EXPORTING iv_action = elementary_action_is-aktion
                                                                      it_vlcdiavehi = vlcdiavehi_ct
                                                            CHANGING ct_vlch_mssg = vlch_mssg_ct ).

      CATCH /dbme/cx_cma_main INTO DATA(lo_error).
        IF lo_error->is_empty( ) = abap_false.
          lo_error->set_sy_message( ).
          CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
            EXPORTING
              msgid_iv     = sy-msgid
              msgty_iv     = sy-msgty
              msgno_iv     = sy-msgno
              msgv1_iv     = sy-msgv1
              msgv2_iv     = sy-msgv2
              msgv3_iv     = sy-msgv3
              msgv4_iv     = sy-msgv4
            TABLES
              vlch_mssg_ct = vlch_mssg_ct.
        ENDIF.
        RAISE processing_impossible.
    ENDTRY.




  ENDMETHOD.


  method IF_EX_VLC_EXECUTE_ACTION~DETERM_PLANNED_SDATE.
  endmethod.


  method IF_EX_VLC_EXECUTE_ACTION~EXECUTE_ADDVDATA.
  endmethod.


  METHOD if_ex_vlc_execute_action~execute_further_actions.
    INCLUDE /DBE/lvm03con.

*Prefix for methods name
    CONSTANTS: lc_meth_pref(8)   TYPE c VALUE 'EXECUTE_'.
*method name
    DATA: lv_meth_name TYPE string.
* Dummy character for hiding message
    DATA: lv_dummy TYPE c.
* Variables for getting exception type
    DATA: lo_root TYPE REF TO cx_root.
    DATA: lv_exceptiontype TYPE string.
    DATA: lv_progname         TYPE syrepid.
    DATA: lv_inclname         TYPE syrepid.
    DATA: lv_srcline          TYPE i.

*construct the relevant methods name
    CONCATENATE lc_meth_pref action_to_be_performed_iv INTO lv_meth_name.

*try to call the method
    TRY.
        CALL METHOD me->(lv_meth_name)
          EXPORTING
            action_to_be_performed_iv = action_to_be_performed_iv
            incoming_action_is        = incoming_action_is
            elementary_action_is      = elementary_action_is
            vlcstatus_it              = vlcstatus_it
            dialogue_allowed_iv       = dialogue_allowed_iv
            vlcbapicu_it              = vlcbapicu_it
          CHANGING
            rfcdest_ct                = rfcdest_ct
            vlcdiavehi_ct             = vlcdiavehi_ct
            vlcactdata_cs             = vlcactdata_cs
            vlch_mssg_ct              = vlch_mssg_ct
          EXCEPTIONS
            action_not_performed      = 1
            OTHERS                    = 2.
        IF sy-subrc <> 0.
          RAISE action_not_performed.
        ENDIF.
      CATCH cx_sy_dyn_call_illegal_method.
*   This is not an error. Implementation might be in other BAdI or only "technical" action without implementation
      CATCH cx_root INTO lo_root.
*   Error occurred
        lv_exceptiontype = lo_root->get_text( ).
        CALL METHOD lo_root->get_source_position
          IMPORTING
            program_name = lv_progname
            include_name = lv_inclname
            source_line  = lv_srcline.
        MESSAGE e016(velo) WITH lv_exceptiontype space space space INTO lv_dummy.
*     An error has occurred
        CALL FUNCTION 'VELO03_FILL_ERROR_TABLE'
          EXPORTING
            msgid_iv     = sy-msgid
            msgty_iv     = sy-msgty
            msgno_iv     = sy-msgno
            msgv1_iv     = sy-msgv1
            msgv2_iv     = sy-msgv2
            msgv3_iv     = sy-msgv3
            msgv4_iv     = sy-msgv4
          TABLES
            vlch_mssg_ct = vlch_mssg_ct.
        RAISE action_not_performed.
    ENDTRY.

  ENDMETHOD.


  method IF_EX_VLC_EXECUTE_ACTION~GET_LOC_AVAIL_STIME.
  endmethod.


  method IF_EX_VLC_EXECUTE_ACTION~PREPARE_ADDVDATA.
  endmethod.


  method IF_EX_VLC_EXECUTE_ACTION~VEHICLE_ISOLATION.
  endmethod.


  METHOD lifecycle_update.

    CONSTANTS:
      lc_usage_name TYPE /dbe/lc_usage_d VALUE '/DBE/VEH_LCY',
      lc_action     TYPE char6 VALUE 'ACTION',
      lc_bustype    TYPE char7 VALUE 'BUSTYPE',
      lc_timing     TYPE char8 VALUE 'PRE_POST'.

    DATA:
      lv_comm_name                   TYPE /dbe/lc_comstruc_d,
      lv_data_name                   TYPE /dbe/lc_datastruc_d,
      lv_act                         TYPE /dbe/veh_actid,
      lv_datatype                    TYPE field_type,
      lv_structure                   TYPE strukname,
      lr_datadescr                   TYPE REF TO cl_abap_datadescr,
      lv_field                       TYPE name_komp,
      lv_iobjguid                    TYPE /dbe/exts_ouid,
      lv_vguid                       TYPE /dbe/veh_guid,
      ls_data                        TYPE /dbe/s_veh_lifecycle_dat,
      ls_vlcactdata_head_s           TYPE vlcactdata_head_s,
      ls_vlcactdata_item_s           TYPE vlcactdata_item_s,
      ls_vlcadddata_item_s           TYPE vlcadddata_item_s,
      ls_veh_bob                     TYPE /dbe/s_veh_bob,
      ls_bapireturn                  TYPE bapiret2,
      ls_vlcdiavehi                  TYPE vlcdiavehi,
      lt_vlcadddata_item             TYPE vlcadddata_item_t,
      lt_data                        TYPE TABLE OF /dbe/s_veh_lifecycle_dat,
      lt_bapireturn                  TYPE bapiret2_t,
      lo_badi_vehicle_lifecycle_ctrl TYPE REF TO /dbe/badi_veh_lifecyle_ctrl,
      lo_badi_vehicle_lifecycle_act  TYPE REF TO /dbe/badi_veh_lifecyle_acts,
      lo_veh_dbmvehicle              TYPE REF TO /dbe/cl_veh_dbmvehicle,
      lr_iobj_data_single_com        TYPE REF TO /dbe/iobj_data_single_com_s,
      lr_iobj_data_multi_com         TYPE REF TO /dbe/iobj_data_multi_com_s,
      ls_iobj_data_single_wk         TYPE /dbe/iobj_data_single_txt_s,
      ls_iobj_data_multi_wk          TYPE /dbe/iobj_data_multi_txt_s,
      lr_comm                        TYPE REF TO data,
      lr_data                        TYPE REF TO data,
      lx_root                        TYPE REF TO cx_root,
      lo_vehbuf                      TYPE REF TO /dbe/cl_veh_buf,
      lo_iobject                     TYPE REF TO /dbe/cl_veh_iobject_vehicle,
      lx_lifecycle_act               TYPE REF TO /dbe/cx_veh_lfcycl_exec_action.

    FIELD-SYMBOLS:
      <comm>          TYPE any,
      <data>          TYPE any,
      <act>           TYPE any,
      <action>        TYPE any,
      <btt>           TYPE any,
      <timing>        TYPE any,
      <passvalue>     TYPE any,
      <ls_vlcdiavehi> TYPE vlcdiavehi.

*.................. End of Declaration Part .......................... *

* Get a new BAdI object and set the BAdI reference
    TRY.
        GET BADI lo_badi_vehicle_lifecycle_ctrl.
      CATCH cx_badi_not_single_use.
    ENDTRY.

* Get communication and data structures for usage name
    CALL FUNCTION '/DBE/VM08_GET_LC_COMM_STR'
      EXPORTING
        iv_usage_name = lc_usage_name
      IMPORTING
        e_comm_str    = lv_comm_name
        e_data_str    = lv_data_name.

    CREATE DATA lr_comm TYPE (lv_comm_name).
    CREATE DATA lr_data TYPE (lv_data_name).
    ASSIGN lr_comm->* TO <comm>.
    ASSIGN lr_data->* TO <data>.
    ASSIGN COMPONENT: lc_action  OF STRUCTURE <comm> TO <action>,
                      lc_bustype OF STRUCTURE <comm> TO <btt>,
                      lc_timing  OF STRUCTURE <comm> TO <timing>.
    <action> = is_elementary_action-aktion.
    <timing> = iv_timing.

    LOOP AT it_veh_bob INTO ls_veh_bob.
      lo_veh_dbmvehicle ?= ls_veh_bob-bobref.
      READ TABLE cs_vlcactdata-actdata_item INTO ls_vlcactdata_item_s
        WITH KEY vguid = ls_veh_bob-guid.
      IF sy-subrc NE 0.
        lv_vguid = lo_veh_dbmvehicle->get_guid( ).
        READ TABLE cs_vlcactdata-actdata_item INTO ls_vlcactdata_item_s
          WITH KEY vguid = lv_vguid.
        IF sy-subrc NE 0.
          lo_iobject ?= lo_veh_dbmvehicle->iobject_get( ).
          lv_iobjguid = lo_iobject->get_guid( ).
          READ TABLE cs_vlcactdata-actdata_item INTO ls_vlcactdata_item_s
               WITH KEY /dbe/iobjguid = lv_iobjguid.
          IF sy-subrc NE 0.
            RAISE EXCEPTION TYPE /dbe/cx_veh_error_occured.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR lt_vlcadddata_item.
      <btt> = ls_vlcactdata_item_s-/dbe/bustype.

      LOOP AT cs_vlcactdata-adddata_item INTO ls_vlcadddata_item_s
        WHERE vguid EQ ls_vlcactdata_item_s-vguid.
        APPEND ls_vlcadddata_item_s TO lt_vlcadddata_item.
      ENDLOOP.

      MOVE-CORRESPONDING cs_vlcactdata TO ls_vlcactdata_head_s.

      READ TABLE ct_vlcdiavehi ASSIGNING <ls_vlcdiavehi>
           WITH KEY vguid = ls_vlcactdata_item_s-vguid.
      IF sy-subrc NE 0.
        RAISE EXCEPTION TYPE /dbe/cx_veh_error_occured.
      ENDIF.

      lo_iobject ?= lo_veh_dbmvehicle->iobject_get( ).
      lo_iobject->fill_data_com( ).
      lr_iobj_data_single_com ?= lo_iobject->get_data_com( lo_veh_dbmvehicle->gc_iobj_data_single_com_s ).
      lr_iobj_data_multi_com ?= lo_iobject->get_data_com( lo_veh_dbmvehicle->gc_iobj_data_multi_com_s ).

      lo_veh_dbmvehicle->get_valid_data( EXPORTING is_name = lo_veh_dbmvehicle->gc_iobj_data_single_txt_s
                                         IMPORTING ev_data = ls_iobj_data_single_wk ).
      lo_veh_dbmvehicle->get_valid_data( EXPORTING is_name = lo_veh_dbmvehicle->gc_iobj_data_multi_txt_s
                                         IMPORTING ev_data = ls_iobj_data_multi_wk ).

      IF lo_badi_vehicle_lifecycle_ctrl IS BOUND.
        CALL BADI lo_badi_vehicle_lifecycle_ctrl->comm_struc_change
          EXPORTING
            is_vlcactdata_head = ls_vlcactdata_head_s
            is_vlcactdata_item = ls_vlcactdata_item_s
            it_vlcadddata      = lt_vlcadddata_item
            is_iobj_single     = ls_iobj_data_single_wk
            is_iobj_multi      = ls_iobj_data_multi_wk
          CHANGING
            cs_comm            = <comm>.
      ENDIF.

      CALL METHOD /dbe/cl_lc_access=>read
        EXPORTING
          i_usage = lc_usage_name
          i_com   = <comm>
        IMPORTING
          et_data = lt_data.

      LOOP AT lt_data INTO ls_data.
        ASSIGN COMPONENT 'ACTID' OF STRUCTURE ls_data TO <act>.
        IF <act> IS NOT ASSIGNED.
          RAISE EXCEPTION TYPE /dbe/cx_veh_lfcycl_customizing
            EXPORTING
              mvact   = is_elementary_action-aktion
              mvactid = lv_act.
        ENDIF.
        TRY.
            GET BADI lo_badi_vehicle_lifecycle_act
              FILTERS
                lifecycle_act = <act>.
            IF lo_badi_vehicle_lifecycle_act IS NOT BOUND.
              RAISE EXCEPTION TYPE /dbe/cx_veh_lfcycl_customizing
                EXPORTING
                  mvact   = is_elementary_action-aktion
                  mvactid = lv_act.
            ENDIF.

            CALL BADI lo_badi_vehicle_lifecycle_act->get_passvalue_info
              CHANGING
                cv_data_type = lv_datatype.
            IF lv_datatype IS NOT INITIAL.
              lr_datadescr ?= cl_abap_typedescr=>describe_by_name( lv_datatype ).
              ASSIGN ls_data-passvalue TO <passvalue> CASTING TYPE (lr_datadescr->absolute_name).
              IF <passvalue> IS NOT ASSIGNED.
                RAISE EXCEPTION TYPE /dbe/cx_veh_error_occured.
              ENDIF.
            ELSE.
              CLEAR ls_data-passvalue.
              ASSIGN ls_data-passvalue TO <passvalue>.
            ENDIF.
            CALL BADI lo_badi_vehicle_lifecycle_act->perform
              EXPORTING
                iv_data             = <passvalue>
                iv_action           = is_elementary_action-aktion
                is_vlcactdata_head  = ls_vlcactdata_head_s
                is_vlcactdata_item  = ls_vlcactdata_item_s
              CHANGING
                cs_iobj_data_single = lr_iobj_data_single_com->*
                cs_iobj_data_multi  = lr_iobj_data_multi_com->*
                cs_vlcdiavehi       = <ls_vlcdiavehi>
                ct_vlch_mssg        = ct_vlch_mssg.
            UNASSIGN <passvalue>.
            lo_iobject->com2work( ).
          CATCH /dbe/cx_veh_lfcycl_exec_action INTO lx_lifecycle_act.
*         In case of lifecycle act exception error messages are expected
*         in ct_vlch_mssg, so they're NOT extracted from the exception.
            DELETE ct_vlcdiavehi WHERE vguid = ls_vlcactdata_item_s-vguid.
            IF ct_vlcdiavehi IS INITIAL.
              RAISE EXCEPTION lx_lifecycle_act.
            ELSE.
              EXIT."Stop executing lifecycle acts, continue with next vehicle
            ENDIF.
          CATCH cx_root INTO lx_root.
            CLEAR lt_bapireturn.
*         If NOT lifecycle act exception was raised, get error messages.
            lo_vehbuf = /dbe/cl_veh_buf=>get_instance( ).
            lo_vehbuf->get_messages( EXPORTING io_cx_root = lx_root
                                     IMPORTING et_bapireturn = lt_bapireturn ).
            CLEAR ls_vlcdiavehi.
            CALL FUNCTION '/DBE/VM03_CONVERT_BAPIRET2VMS'
              EXPORTING
                is_vlcdiavehi = ls_vlcdiavehi
                it_bapiret    = lt_bapireturn
              CHANGING
                ct_vlch_mssg  = ct_vlch_mssg.

            DELETE ct_vlcdiavehi WHERE vguid = ls_vlcactdata_item_s-vguid.
            IF ct_vlcdiavehi IS INITIAL.
              RAISE EXCEPTION lx_root.
            ELSE.
              EXIT."Stop executing lifecycle acts, continue with next vehicle
            ENDIF.
        ENDTRY.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

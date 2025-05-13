class ZCL_VSS_PRICE_F4 definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_PACKAGE_F4 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VSS_PRICE_F4 IMPLEMENTATION.


  method /DBE/IF_PACKAGE_F4~CHANGE_RESULT.
  endmethod.


  method /DBE/IF_PACKAGE_F4~CHANGE_RESULT_PACKAGE_ID_F4.
  endmethod.


  METHOD /dbe/if_package_f4~change_selection.
    DATA : ls_rsds_range  TYPE rsds_range,
           ls_rsds_frange TYPE rsds_frange,
           lt_rsds_frange TYPE STANDARD TABLE OF rsds_frange,
           ls_rsdsselopt  TYPE rsdsselopt,
           lt_rsdsselopt  TYPE STANDARD TABLE OF rsdsselopt.

    DATA : lv_index1,
           lv_index2.

    READ TABLE ct_sel_opt INTO ls_rsds_range INDEX 1.
    lv_index1 = sy-tabix.
    lt_rsds_frange[] = ls_rsds_range-frange_t[].

    READ TABLE lt_rsds_frange INTO ls_rsds_frange WITH KEY fieldname = 'AWTYP'.
    lv_index2 = sy-tabix.

    lt_rsdsselopt[] = ls_rsds_frange-selopt_t[].

    SELECT * FROM tvarvc INTO TABLE @DATA(lt_tvarvc) WHERE name EQ 'ADD_LV_TYPE'.

    IF lt_tvarvc IS NOT INITIAL.
      LOOP AT lt_tvarvc INTO DATA(ls_tvarvc).
        ls_rsds_frange-fieldname = 'AWTYP'.
        ls_rsdsselopt-sign = 'I'.
        ls_rsdsselopt-option = 'EQ'.
        ls_rsdsselopt-low = ls_tvarvc-low.
        APPEND ls_rsdsselopt TO lt_rsdsselopt.
        CLEAR ls_rsdsselopt.
      ENDLOOP.

      ls_rsds_frange-selopt_t[] = lt_rsdsselopt[].
      MODIFY lt_rsds_frange FROM ls_rsds_frange INDEX lv_index2.

** SPART

      READ TABLE lt_rsds_frange INTO ls_rsds_frange WITH KEY fieldname = 'SPART'.
      IF sy-subrc EQ 0.
        lv_index2 = sy-tabix.
        lt_rsdsselopt[] = ls_rsds_frange-selopt_t[].
        ls_rsds_frange-fieldname = 'SPART'.
        ls_rsdsselopt-sign = 'I'.
        ls_rsdsselopt-option = 'EQ'.
        ls_rsdsselopt-low = ' '.
        APPEND ls_rsdsselopt TO lt_rsdsselopt.
        CLEAR ls_rsdsselopt.
        ls_rsds_frange-selopt_t[] = lt_rsdsselopt[].
        MODIFY lt_rsds_frange FROM ls_rsds_frange INDEX lv_index2.
      ENDIF.

** MFRNR

      READ TABLE lt_rsds_frange INTO ls_rsds_frange WITH KEY fieldname = 'MFRNR'.
      IF sy-subrc EQ 0.
        lv_index2 = sy-tabix.
        lt_rsdsselopt[] = ls_rsds_frange-selopt_t[].
        ls_rsds_frange-fieldname = 'MFRNR'.
        ls_rsdsselopt-sign = 'I'.
        ls_rsdsselopt-option = 'EQ'.
        ls_rsdsselopt-low = ' '.
        APPEND ls_rsdsselopt TO lt_rsdsselopt.
        CLEAR ls_rsdsselopt.
        ls_rsds_frange-selopt_t[] = lt_rsdsselopt[].
        MODIFY lt_rsds_frange FROM ls_rsds_frange INDEX lv_index2.
      ENDIF.

** PACKAGE_TYPE

      READ TABLE lt_rsds_frange INTO ls_rsds_frange WITH KEY fieldname = 'PACKAGE_TYPE'.
      IF sy-subrc EQ 0.
        lv_index2 = sy-tabix.
        lt_rsdsselopt[] = ls_rsds_frange-selopt_t[].
        ls_rsds_frange-fieldname = 'PACKAGE_TYPE'.
        ls_rsdsselopt-sign = 'I'.
        ls_rsdsselopt-option = 'EQ'.
        ls_rsdsselopt-low = 'W1'.
        APPEND ls_rsdsselopt TO lt_rsdsselopt.
        CLEAR ls_rsdsselopt.
        ls_rsds_frange-selopt_t[] = lt_rsdsselopt[].
        MODIFY lt_rsds_frange FROM ls_rsds_frange INDEX lv_index2.
      ENDIF.

      ls_rsds_range-frange_t[] = lt_rsds_frange[].

      MODIFY ct_sel_opt FROM ls_rsds_range INDEX lv_index1.


    ENDIF.

  ENDMETHOD.


  METHOD /dbe/if_package_f4~move_vehicle_data_2_vbak.
    DATA ls_vlcdiavehi           TYPE vlcdiavehi.
    DATA ls_vlcactdata_head      TYPE vlcactdata_head_s.
    DATA ls_vlcactdata_item      TYPE vlcactdata_item_s.
    DATA lt_vlcadddata           TYPE vlcadddata_item_t.
    DATA lv_category_id          TYPE /dbe/exts_category_id.
    DATA ls_iobj_data_single_com TYPE /dbe/iobj_data_single_com_s.
    DATA ls_iobj_data_multi_com  TYPE /dbe/iobj_data_multi_com_s.

    IF NOT cs_vbak_com-vguid IS INITIAL.
      CALL FUNCTION '/DBE/VM01_VEHICLE_GET'
        EXPORTING
          iv_vguid                = cs_vbak_com-vguid
        IMPORTING
          es_vlcdiavehi           = ls_vlcdiavehi
          es_vlcactdata_head      = ls_vlcactdata_head
          es_vlcactdata_item      = ls_vlcactdata_item
          et_vlcadddata           = lt_vlcadddata
          ev_category_id          = lv_category_id
          es_iobj_data_single_com = ls_iobj_data_single_com
          es_iobj_data_multi_com  = ls_iobj_data_multi_com
        EXCEPTIONS
          error_vms_get           = 1
          error_iobj_get          = 2
          error_badi              = 3
          OTHERS                  = 4.
    ENDIF.

    cs_vbak_com-mcodecs  = ls_iobj_data_single_com-/dbe/v_imodel-mcodecs.
    cs_vbak_com-mcodesd  = ls_iobj_data_single_com-/dbe/v_imodel-mcodesd.
    cs_vbak_com-vmodel   = ls_vlcdiavehi-matnr.             "N:1671975
    cs_vbak_com-vhvin    = ls_vlcdiavehi-vhvin.
    cs_vbak_com-cstryear = ls_iobj_data_single_com-/dbe/v_imodel-conyear.
    cs_vbak_com-srvcard  = ls_iobj_data_single_com-/dbe/v_ivehicle-srvcard.

* fill LANDTX temporairly. Used in function /DBE/PACKAGE_SELOPT_ORGDATA
    SELECT SINGLE land1 FROM t001w
      INTO cs_vbak_com-landtx
      WHERE werks = cs_vbak_com-werks.

  ENDMETHOD.
ENDCLASS.

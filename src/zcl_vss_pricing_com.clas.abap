class ZCL_VSS_PRICING_COM definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_EX_PRICING_COM .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VSS_PRICING_COM IMPLEMENTATION.


  METHOD /dbe/if_ex_pricing_com~can_copy_vbap_price2split.
  ENDMETHOD.


  METHOD /dbe/if_ex_pricing_com~change_komk.
    cs_komk-zzbank = is_vbak_com-zzbank.
  ENDMETHOD.


  METHOD /dbe/if_ex_pricing_com~change_komp.
    cs_komp-zzbank = is_vbak_com-zzbank.
    cs_komp-modyear = is_vbap_com-modyear.
    cs_komp-mcodesd = is_vbap_com-mcodesd.
    cs_komp-vhvin = is_vbap_com-vhvin.
  ENDMETHOD.


  METHOD /dbe/if_ex_pricing_com~is_header_pricing_necessary.
    DATA: ls_vbak_old TYPE /dbe/vbak_com,
          ls_vbak_new TYPE /dbe/vbak_com.

    ls_vbak_old = is_vbak_old.
    ls_vbak_new = is_vbak_new.

* clear fields that are not relevant to pricing
    CLEAR: ls_vbak_new-bstnk, ls_vbak_old-bstnk,                            "PO number
           ls_vbak_new-w_leitzahl, ls_vbak_old-w_leitzahl,                  "Code for Vehicle Stock
           ls_vbak_new-pernr, ls_vbak_old-pernr,                            "Cust. advisor
           ls_vbak_new-mileage, ls_vbak_old-mileage,                        "Counter reading
           ls_vbak_new-mileage_uom, ls_vbak_old-mileage_uom,                "Counter reading unit
           ls_vbak_new-test_drive, ls_vbak_old-test_drive,                  "Test drive
           ls_vbak_new-header_status_icon, ls_vbak_old-header_status_icon,  "header statsu icon
           ls_vbak_new-hstat_txt, ls_vbak_old-hstat_txt,                    "header status description
* scheduling relevant header fields
           ls_vbak_new-base_start_date, ls_vbak_old-base_start_date,
           ls_vbak_new-base_start_time, ls_vbak_old-base_start_time,
           ls_vbak_new-base_end_date, ls_vbak_old-base_end_date,
           ls_vbak_new-base_end_time, ls_vbak_old-base_end_time,
           ls_vbak_new-visit_start_date, ls_vbak_old-visit_start_date,
           ls_vbak_new-visit_start_time, ls_vbak_old-visit_start_time,
           ls_vbak_new-visit_end_date,   ls_vbak_old-visit_end_date, "N:2184706
           ls_vbak_new-visit_end_time,   ls_vbak_old-visit_end_time, "N:2184706
           ls_vbak_new-visit_end_tst,    ls_vbak_old-visit_end_tst,
           ls_vbak_new-fertig_dat,       ls_vbak_old-fertig_dat,
           ls_vbak_new-fertig_time,      ls_vbak_old-fertig_time,
           ls_vbak_new-ready_date,       ls_vbak_old-ready_date,
           ls_vbak_new-ready_time,       ls_vbak_old-ready_time,
           ls_vbak_new-fert_date_tmstp,  ls_vbak_old-fert_date_tmstp,
           ls_vbak_new-base_start_tst,   ls_vbak_old-base_start_tst,
           ls_vbak_new-rep_car_req,      ls_vbak_old-rep_car_req,
           ls_vbak_new-ad_ret_plan_rel,  ls_vbak_old-ad_ret_plan_rel,
           ls_vbak_new-cust_waiting,     ls_vbak_old-cust_waiting,
           ls_vbak_new-ad_plan_rel,      ls_vbak_old-ad_plan_rel,
           ls_vbak_new-pname_rec,        ls_vbak_old-pname_rec,
           ls_vbak_new-pernr_rec,        ls_vbak_old-pernr_rec,
           ls_vbak_new-ad_etime,         ls_vbak_old-ad_etime,
           ls_vbak_new-ad_etime_meins,   ls_vbak_old-ad_etime_meins,
           ls_vbak_new-pernr_ret,        ls_vbak_old-pernr_ret,
           ls_vbak_new-ad_ret_etime,     ls_vbak_old-ad_ret_etime,
           ls_vbak_new-ad_ret_etime_m,   ls_vbak_old-ad_ret_etime_m,
           ls_vbak_new-pname_ret,        ls_vbak_old-pname_ret.

* VSS4.0: Measurement Point/Doc {
    /dbe/cl_itob_a_meas_doc_vehi=>get_instance_gen( )->clear_values(
      EXPORTING
        iv_obj_type = /dbe/cl_itob_x_const=>mc_vss_mpoint_obj-vss_order_hdr
      CHANGING
        cs_obj      = ls_vbak_new ).
    /dbe/cl_itob_a_meas_doc_vehi=>get_instance_gen( )->clear_values(
      EXPORTING
        iv_obj_type = /dbe/cl_itob_x_const=>mc_vss_mpoint_obj-vss_order_hdr
      CHANGING
        cs_obj      = ls_vbak_old ).
* VSS4.0: Measurement Point/Doc }

    IF ls_vbak_new = ls_vbak_old.
      cv_result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD /dbe/if_ex_pricing_com~is_item_pricing_necessary.
    DATA: ls_komk_new TYPE komk,
          ls_komk_old TYPE komk,
          ls_komp_new TYPE komp,
          ls_komp_old TYPE komp.

    ls_komk_new = is_komk_new.
    ls_komk_old = is_komk_old.
    ls_komp_new = is_komp_new.
    ls_komp_old = is_komp_old.

* clear komk fields that have to be ignored
    CLEAR: ls_komk_new-drukz_s, ls_komk_old-drukz_s.              "Print indicator

* clear komp fields that have to be ignored
    CLEAR: ls_komp_new-mblnr, ls_komp_old-mblnr,                  "Last material document number
           ls_komp_new-banfn, ls_komp_old-banfn.                  "Last PREQ document number

    IF ls_komk_new = ls_komk_old AND
       ls_komp_new = ls_komp_old.
      cv_result = abap_false.
    ENDIF.
  ENDMETHOD.


  method /DBE/IF_EX_PRICING_COM~IS_JOB_ITEMS_PRICING_NECESSARY.
  endmethod.
ENDCLASS.

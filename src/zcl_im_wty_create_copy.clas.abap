class ZCL_IM_WTY_CREATE_COPY definition
  public
  final
  create public .

public section.

  interfaces IF_EX_WTY_CREATE_COPY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_WTY_CREATE_COPY IMPLEMENTATION.


  method IF_EX_WTY_CREATE_COPY~DATA_CHANGE_CHANGE.
       CALL FUNCTION '/DBE/S_WTY_UE_CR_CPY_CHNG_CHNG'
     EXPORTING
       is_pnwtyv_old    = is_pnwtyv_old
       is_pnwtyh_old    = is_pnwtyh_old
       it_pvwty_old     = it_pvwty_old
       it_pvwty_dyn_old = it_pvwty_dyn_old
       it_pvwty_ver_new = it_pvwty_ver_new
     CHANGING
       cs_pnwtyh        = cs_pnwtyh
       cs_pnwtyv        = cs_pnwtyv
       ct_pvwty         = ct_pvwty
       cs_pnwtyh_dyn    = cs_pnwtyh_dyn
       cs_pnwtyv_dyn    = cs_pnwtyv_dyn
       ct_pvwty_dyn     = ct_pvwty_dyn
     EXCEPTIONS
       ev_error         = 1.
   IF sy-subrc = 1.
     RAISE ev_error .
   ENDIF.
  endmethod.


  method IF_EX_WTY_CREATE_COPY~DATA_CHANGE_COPY.
        DATA
      lo_default TYPE REF TO cl_def_im_wty_create_copy.

    CREATE OBJECT lo_default.
    CALL METHOD lo_default->if_ex_wty_create_copy~data_change_copy
      EXPORTING
        is_pnwtyv_from  = is_pnwtyv_from
        it_pvwty_from   = it_pvwty_from
        iv_kateg_from   = iv_kateg_from
        iv_kateg_to     = iv_kateg_to
      CHANGING
        cs_pnwtyh       =  cs_pnwtyh
        cs_pnwtyv_to    =  cs_pnwtyv_to
        ct_pvwty_to     =  ct_pvwty_to.
  endmethod.


  method IF_EX_WTY_CREATE_COPY~DATA_CHANGE_CREATE.
      DATA lo_default TYPE REF TO cl_def_im_wty_create_copy.

  CREATE OBJECT lo_default.
  CALL METHOD lo_default->if_ex_wty_create_copy~data_change_create
    EXPORTING
      iv_claim_exist = iv_claim_exist
    CHANGING
      cs_pnwtyh      = cs_pnwtyh
      cs_pnwtyv      = cs_pnwtyv
      ct_pvwty       = ct_pvwty
      ct_pvwty_dyn   = ct_pvwty_dyn
      cs_pnwtyh_dyn  = cs_pnwtyh_dyn
      cs_pnwtyv_dyn  = cs_pnwtyv_dyn.
  endmethod.


  method IF_EX_WTY_CREATE_COPY~DATA_CHANGE_LAST.
  endmethod.


  METHOD if_ex_wty_create_copy~include_version_in_sum_calc.
    DATA
      lo_default TYPE REF TO cl_def_im_wty_create_copy.

    CREATE OBJECT lo_default.
    CALL METHOD lo_default->if_ex_wty_create_copy~include_version_in_sum_calc
      EXPORTING
        is_pnwtyv_dia = is_pnwtyv_dia
        it_pnwtyv_dia = it_pnwtyv_dia
      CHANGING
        cv_include    = cv_include.
  ENDMETHOD.
ENDCLASS.

FUNCTION-POOL ZBP01.                        "MESSAGE-ID ..

**DATA macro_alpha_input.
** INCLUDE LZBP01D...                         " Local class definition
*
*DEFINE macro_alpha_input.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              input  = &1
*            IMPORTING
*              output = &2.
*
*END-OF-DEFINITION.

"***********************************************************
"*            BEGIN OF DECLARING LOCAL DATA
"***********************************************************
CONSTANTS:
  lc_fi_vendor_role   TYPE bapibus1006_bproles-partnerrole VALUE 'FLVN00', "  FI Vendor Role
  lc_vendor_role      TYPE bapibus1006_bproles-partnerrole VALUE 'FLVN01', "  Vendor Role
  lc_customer_role    TYPE bapibus1006_bproles-partnerrole VALUE 'FLCU01', "  Customer Role
  lc_fi_customer_role TYPE bapibus1006_bproles-partnerrole VALUE 'FLCU00'. "  FI Customer Role
*                     BEGIN OF GLOBAL MACRO
************************************************************************
DEFINE macro_alpha_input.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input         = &1
   IMPORTING
     output        = &2
            .

END-OF-DEFINITION.


*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DATAX_FLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FS_VENDOR_CENTRAL_DATA_ADDRE  text
*      <--P_P_FS_VENDOR_CENTRAL_DATA_ADDRE  text
*----------------------------------------------------------------------*
FORM f_update_datax_flag  USING    p_data
                          CHANGING p_datax.
  "***********************************************************
  "*            BEGIN OF DECLARING LOCAL DATA
  "***********************************************************
  "CONSTANTS:
  "***********************************************************
  DATA:
    lobj_typedescr TYPE REF TO cl_abap_structdescr,
    lint_fields    TYPE ddfields.

  "***********************************************************
  FIELD-SYMBOLS:
    <fs_field>  LIKE LINE OF lint_fields,
    <wf_field>  TYPE any,
    <wf_fieldx> TYPE any.
  "************ END OF DECLARING LOCAL DATA ******************
  lobj_typedescr  ?= cl_abap_structdescr=>describe_by_data( p_data ).
  lint_fields = lobj_typedescr->get_ddic_field_list( ).

  LOOP AT lint_fields ASSIGNING <fs_field>.

    ASSIGN COMPONENT <fs_field>-fieldname OF STRUCTURE p_data TO <wf_field>.
    IF sy-subrc = 0.
      IF <wf_field> IS NOT INITIAL.
        ASSIGN COMPONENT <fs_field>-fieldname OF STRUCTURE p_datax TO <wf_fieldx>.
        IF sy-subrc = 0.
          <wf_fieldx> = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BP_CUST_LINK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BPARTNER  text
*----------------------------------------------------------------------*
FORM bp_cust_link  USING    p_bpartner TYPE  bu_partner
                            cust_role  TYPE char1
                            fi_cust_role  TYPE char1   CHANGING lint_messages TYPE bapiret2_t.

  DATA: lfs_message   LIKE LINE OF lint_messages.
  DATA:
    lcl_bo_cvi      TYPE REF TO fsbp_bo_cvi,
    lcl_ka_customer TYPE REF TO cvi_ka_bp_customer,
    ls_bus_ei_main  TYPE bus_ei_main,
    ls_but000       TYPE but000,
    ls_but100       TYPE but100,
    ls_errors       TYPE mds_ctrls_error,
    lt_partners     TYPE bus_ei_extern_t,
    ls_partners     LIKE LINE OF lt_partners,
    ls_roles        TYPE bus_ei_bupa_roles,
    lt_return       TYPE TABLE OF bapiret2,
    lv_customer     TYPE kunnr,
    lv_relevant     TYPE flag,
    lv_role_deleted TYPE c,
    lv_status       TYPE c.
  CONSTANTS:
    object_type_bp     TYPE mds_ctrl_object VALUE 'BP',
    task_insert        TYPE bus_ei_object_task VALUE 'I',
    task_update        TYPE bus_ei_object_task VALUE 'U',
    task_current_state TYPE bus_ei_object_task VALUE 'C',
    true               TYPE boole-boole VALUE 'X',
    false              TYPE boole-boole VALUE ' ',
    isu_role           TYPE bu_partnerrole VALUE 'MKK   '.
  FIELD-SYMBOLS:
    <return>           TYPE bapiret2.

* 1.) check relevance
  mds_ctrl_controller=>am_i_relevant(
    EXPORTING
      iv_object_type = object_type_bp
    IMPORTING
      ev_relevant    = lv_relevant
      es_error       = ls_errors
  ).
  IF lv_relevant IS INITIAL.
* raise error message

    lfs_message-type = 'E'.
    lfs_message-id = 'CVIC_UI'.
    lfs_message-number = '022'.
    APPEND lfs_message TO lint_messages.
    EXIT.
  ENDIF.

* 2.a) find out if BP has ISU role MKK - if yes, do not establish link (see ISU note 1123452)
***  CALL FUNCTION 'BUP_BUT100_SELECT_SINGLE'
***    EXPORTING
***      i_partner = p_bpartner
***      i_rltyp   = isu_role
***    IMPORTING
***      e_but100  = ls_but100
***    EXCEPTIONS
***      OTHERS    = 1.
***  IF sy-subrc = 0.
****    MESSAGE e031(cvic_ui) WITH p_bpartner.
***    lfs_message-type = 'E'.
***    lfs_message-id = 'CVIC_UI'.
***    lfs_message-number = '031'.
****      lfs_message-message_v1 = 'Error While updating customer' .
****      lfs_message-message_v2 =  'please correct the record '.
****      lfs_message-message_v3 = bpartner.
***    APPEND lfs_message TO lint_messages.
***
***    EXIT.
***  ENDIF.

* 2.b) find out if the selected role exists
  IF cust_role IS NOT INITIAL.

    CALL FUNCTION 'BUP_BUT100_SELECT_SINGLE'
      EXPORTING
        i_partner = p_bpartner
        i_rltyp   = lc_customer_role
      IMPORTING
        e_but100  = ls_but100
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc = 0.
* 3.) delete role from data base to enable mapping as new assignment
      DELETE but100 FROM ls_but100.
      lv_role_deleted = true.
      COMMIT WORK.
    ENDIF.

  ENDIF.

  IF fi_cust_role IS NOT INITIAL.


    CALL FUNCTION 'BUP_BUT100_SELECT_SINGLE'
      EXPORTING
        i_partner = p_bpartner
        i_rltyp   = lc_fi_customer_role
      IMPORTING
        e_but100  = ls_but100
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc = 0.
* 3.) delete role from data base to enable mapping as new assignment
      DELETE but100 FROM ls_but100.
      lv_role_deleted = true.
      COMMIT WORK.
    ENDIF.
    CALL FUNCTION 'BAPI_BUPA_ROLE_ADD'
  EXPORTING
    businesspartner                = p_bpartner
    businesspartnerrole            = lc_fi_customer_role.

  ENDIF.

* 4.) send externally given custoemr No. to business object
  lcl_bo_cvi ?= fsbp_business_factory=>get_instance( p_bpartner ).
  lcl_bo_cvi->customer->set_customer( p_bpartner ).

* 5.) start BP inbound with new role
  CALL FUNCTION 'BUP_BUT000_SELECT_SINGLE'
    EXPORTING
      i_partner    = p_bpartner
      i_cp_exclude = true
    IMPORTING
      e_but000     = ls_but000.

  ls_partners-header-object_task                  = task_update.
  ls_partners-header-object_instance-bpartner     = p_bpartner.
  ls_partners-header-object_instance-bpartnerguid = ls_but000-partner_guid.
  ls_roles-task                                   = task_insert.

  IF fi_cust_role IS NOT INITIAL.
    ls_roles-data_key                               = lc_fi_customer_role.
  ENDIF.
  IF cust_role IS NOT INITIAL.
    ls_roles-data_key                               = lc_customer_role.
  ENDIF.
  APPEND ls_roles TO ls_partners-central_data-role-roles.

  CALL FUNCTION 'ABA_FSBP_INB_DEACTIVATE_VAL'.

  CALL FUNCTION 'BUPA_INBOUND_MAP_MAIN'
    EXPORTING
      iv_x_save   = true
    IMPORTING
      status      = lv_status
    TABLES
      et_return   = lt_return
    CHANGING
      c_bp_struct = ls_partners.

  LOOP AT lt_return ASSIGNING <return>.
    IF <return>-type = 'E' OR <return>-type = 'A'.
      lfs_message-type = 'E'.
      lfs_message-id = 'CVIC_UI'.
      lfs_message-number = '0223'.
      APPEND lfs_message TO lint_messages.
      EXIT.
    ENDIF.
  ENDLOOP.

* 6.) check if assignement has been persisted
  lcl_ka_customer = cvi_ka_bp_customer=>get_instance( ).
  lv_customer = lcl_ka_customer->get_assigned_customer_for_bp(
    i_partner        = ls_but000-partner_guid
    i_persisted_only = true
  ).
  IF lv_customer IS INITIAL.
    lfs_message-type = 'E'.
    lfs_message-id = 'CVIC_UI'.
    lfs_message-number = '023'.
    APPEND lfs_message TO lint_messages.
    IF lv_role_deleted = true.
      INSERT but100 FROM ls_but100.
    ENDIF.
  ELSE.

    lfs_message-type = 'S'.
    lfs_message-id = 'CVIC_UI'.
    lfs_message-number = '017'.
    APPEND lfs_message TO lint_messages.
  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BP_VEND_LINK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BPARTNER  text
*      -->P_VEND_DETAILS_VEND_ROLE  text
*      -->P_0310   text
*      <--P_LINT_MESSAGES  text
*----------------------------------------------------------------------*
FORM bp_vend_link  USING    p_bpartner TYPE  bu_partner
                           vend_role  TYPE char1
                            fi_vend_role  TYPE char1
                   CHANGING lint_messages TYPE bapiret2_t..

  DATA:
    lfs_message   LIKE LINE OF lint_messages.
  DATA:
    lcl_bo_cvi      TYPE REF TO   fsbp_bo_cvi,
    lcl_ka_vendor   TYPE REF TO   cvi_ka_bp_vendor,
    ls_bus_ei_main  TYPE          bus_ei_main,
    ls_but000       TYPE          but000,
    ls_but100       TYPE          but100,
    ls_errors       TYPE          mds_ctrls_error,
    lt_partners     TYPE          bus_ei_extern_t,
    ls_partners     LIKE LINE OF  lt_partners,
    ls_roles        TYPE          bus_ei_bupa_roles,
    lt_return       TYPE TABLE OF bapiret2,
    lv_vendor       TYPE          lifnr,
    lv_relevant     TYPE          flag,
    lv_role_deleted TYPE          c,
    lv_status       TYPE          c.
  CONSTANTS:
    object_type_bp     TYPE mds_ctrl_object VALUE 'BP',
    task_insert        TYPE bus_ei_object_task VALUE 'I',
    task_update        TYPE bus_ei_object_task VALUE 'U',
    task_current_state TYPE bus_ei_object_task VALUE 'C',
    true               TYPE boole-boole VALUE 'X',
    false              TYPE boole-boole VALUE ' '.
  FIELD-SYMBOLS:
    <return>           TYPE bapiret2.


* 1.) check relevance
  mds_ctrl_controller=>am_i_relevant(
    EXPORTING
      iv_object_type = object_type_bp
    IMPORTING
      ev_relevant    = lv_relevant
      es_error       = ls_errors
  ).
  IF lv_relevant IS INITIAL.
* raise error message

    lfs_message-type = 'E'.
    lfs_message-id = 'CVIC_UI'.
    lfs_message-number = '022'.
    APPEND lfs_message TO lint_messages.
    EXIT.
    EXIT.
  ENDIF.

* 2.) find out if the selected role exists
  IF vend_role IS NOT INITIAL.
    CALL FUNCTION 'BUP_BUT100_SELECT_SINGLE'
      EXPORTING
        i_partner = p_bpartner
        i_rltyp   = lc_vendor_role
      IMPORTING
        e_but100  = ls_but100
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc = 0.
* 3.) delete role from data base to enable mapping as new assignment
      DELETE but100 FROM ls_but100.
      lv_role_deleted = true.
      COMMIT WORK.
    ENDIF.
  ENDIF.

  IF fi_vend_role IS NOT INITIAL.

CALL FUNCTION 'BAPI_BUPA_ROLE_ADD'
  EXPORTING
    businesspartner                = p_bpartner
    businesspartnerrole            = lc_fi_vendor_role
          .

    CALL FUNCTION 'BUP_BUT100_SELECT_SINGLE'
      EXPORTING
        i_partner = p_bpartner
        i_rltyp   = lc_fi_vendor_role
      IMPORTING
        e_but100  = ls_but100
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc = 0.
* 3.) delete role from data base to enable mapping as new assignment
      DELETE but100 FROM ls_but100.
      lv_role_deleted = true.
      COMMIT WORK.
    ENDIF.
  ENDIF.

* 4.) send externally given custoemr No. to business object
  lcl_bo_cvi ?= fsbp_business_factory=>get_instance( p_bpartner ).
  lcl_bo_cvi->vendor->set_vendor( p_bpartner ).

* 5.) start BP inbound with new role
  CALL FUNCTION 'BUP_BUT000_SELECT_SINGLE'
    EXPORTING
      i_partner    = p_bpartner
      i_cp_exclude = true
    IMPORTING
      e_but000     = ls_but000.

  ls_partners-header-object_task                  = task_update.
  ls_partners-header-object_instance-bpartner     = p_bpartner.
  ls_partners-header-object_instance-bpartnerguid = ls_but000-partner_guid.
  ls_roles-task                                   = task_insert.
  ls_roles-data_key                               = lc_vendor_role.
  APPEND ls_roles TO ls_partners-central_data-role-roles.

  CALL FUNCTION 'ABA_FSBP_INB_DEACTIVATE_VAL'.

  CALL FUNCTION 'BUPA_INBOUND_MAP_MAIN'
    EXPORTING
      iv_x_save   = true
    IMPORTING
      status      = lv_status
    TABLES
      et_return   = lt_return
    CHANGING
      c_bp_struct = ls_partners.

  LOOP AT lt_return ASSIGNING <return>.
    IF <return>-type = 'E' OR <return>-type = 'A'.
      lfs_message-type = 'E'.
      lfs_message-id = 'CVIC_UI'.
      lfs_message-number = '0223'.
      APPEND lfs_message TO lint_messages.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

* 6.) check if assignement has been persisted
  lcl_ka_vendor = cvi_ka_bp_vendor=>get_instance( ).
  lv_vendor = lcl_ka_vendor->get_assigned_vendor_for_bp(
    i_partner        = ls_but000-partner_guid
    i_persisted_only = true
  ).
  IF lv_vendor IS INITIAL.
    lfs_message-type = 'E'.
    lfs_message-id = '00'.
    lfs_message-number = '001'.
    lfs_message-message_v1 = 'Error While linking BP Partner to Vendor' .
    lfs_message-message_v2 =  'please correct the record '.
    lfs_message-message_v3 = lv_vendor.
    APPEND lfs_message TO lint_messages.
    IF lv_role_deleted = true.
      INSERT but100 FROM ls_but100.
    ENDIF.
  ELSE.

    lfs_message-type = 'S'.
    lfs_message-id = '00'.
    lfs_message-number = '001'.
    lfs_message-message_v1 = 'BP Partner has been assigned to ' .
    IF vend_role IS NOT INITIAL.
      lfs_message-message_v2 =  'Vendor Role '.
    ENDIF.

    IF fi_vend_role IS NOT INITIAL.
      lfs_message-message_v2 =  'Vendor FI Role '.
    ENDIF.
    lfs_message-message_v3 = lv_vendor.
    APPEND lfs_message TO lint_messages.
  ENDIF.

ENDFORM.

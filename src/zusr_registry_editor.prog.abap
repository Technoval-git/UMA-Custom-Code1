*&---------------------------------------------------------------------*
*& Report ZUSR_REGISTRY_EDITOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZUSR_REGISTRY_EDITOR.

include zlib_registry.

* For tree control:
data: gr_tree type ref to cl_gui_alv_tree.
data: gr_tree_toolbar type ref to cl_gui_toolbar.
data: gs_node_layout type lvc_s_layn. "Layout for new nodes
* Table for registry entries on tree
types: begin of ts_tab,
         key type string,
         reg_entry type ref to lcl_registry_entry,
       end of ts_tab.
* Container for ALV tree data:
data: gt_tab type table of ts_tab.

* For maintaining registry values in an an entry (ALV control):
data: gr_table   type ref to cl_gui_alv_grid.
data: gt_value   type standard table of lcl_registry_entry=>ts_keyval.
data: gt_value_ori type standard table of lcl_registry_entry=>ts_keyval. "Original data

* For splitter container
data: gr_splitter type ref to cl_gui_easy_splitter_container.

* For registry access:
data: gr_reg_root type ref to lcl_registry_entry.

data: gr_sel_reg_entry type ref to lcl_registry_entry. "Selected reg. entry
data: gv_sel_node_key type lvc_nkey. "Tree node key of currently selected node

* Single statement to generate a selection screen
parameters: dummy.

*----------------------------------------------------------------------*
*       CLASS event_handler DEFINITION
*----------------------------------------------------------------------*
class event_handler definition.
  public section.
    class-methods:
      handle_node_expand for event expand_nc of cl_gui_alv_tree
        importing node_key sender,
      handle_table_toolbar for event toolbar of cl_gui_alv_grid
        importing e_object e_interactive sender,
      handle_table_command for event user_command of cl_gui_alv_grid
        importing e_ucomm,
      handle_node_selected for event selection_changed of cl_gui_alv_tree
        importing node_key,
      handle_tree_command for event function_selected of cl_gui_toolbar
        importing fcode.
*      handle_values_changed for event DATA_CHANGE of CL_GUI_ALV_GRID
*        importing er_data_changed e_onf4 e_onf4_before e_onf4_after e_ucomm.

endclass.                    "event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
class event_handler implementation.

* Handle commands to the tree toolbar
  method handle_tree_command.
    data: lv_new_key type string.
    data: lr_reg_entry type ref to lcl_registry_entry.
    data: lv_node_key type lvc_nkey.
    data: lv_rc type char1.
    data: lv_ntext type lvc_value.
    data: ls_tab type ts_tab.

    if gr_sel_reg_entry is not bound.
      message 'Select a node from the tree first' type 'I'.
      return.
    endif.

* Create a new node under selected node, or copy a registry node on the same level
    if fcode = 'INSE'.

* Dialog to capture name of new node
      perform value_input_dialog using 'New registry entry key'(007)
            changing lv_new_key lv_rc.

* Add the new key to the current registry entry if the user accepts
      if lv_rc = space.
        try.
* Update the tree by adding the new node
            gr_sel_reg_entry->add_subentry( lv_new_key ).
            perform refresh_subnodes using gv_sel_node_key.

          catch lcx_registry_entry_exists.
            message 'The registry entry already exists'(015) type 'I'.
            return.
        endtry.
      endif.

* Copy the selected node at the same level
    elseif fcode = 'COPY'.

* Dialog to capture name of new node
      perform value_input_dialog using 'Target registry entry key'(006)
            changing lv_new_key lv_rc.

* Perform deep copy of source to target node
      if lv_rc = space.
        data: lr_parent type ref to lcl_registry_entry.
        try.
            lr_parent = gr_sel_reg_entry->get_parent( ).
            lr_parent->copy_subentry( source_key = gr_sel_reg_entry->entry_id target_key = lv_new_key ).

* Get the parent node in the tree to refresh it
            call method gr_tree->get_parent
              exporting
                i_node_key        = gv_sel_node_key
              importing
                e_parent_node_key = lv_node_key.

* Refresh the parent node
            perform refresh_subnodes using lv_node_key.

          catch lcx_registry_entry_exists.
            message 'The registry entry already exists'(015) type 'I'.
            return.
          catch lcx_registry_err.
            message 'Error updating registry'(017) type 'I'.
            return.
        endtry.
      endif.

* Delete the selected node from the registry
    elseif fcode = 'DELE'.

* Prevent deleting of the root entity, which would fail anyway when we try get its parent
      if gr_sel_reg_entry->internal_key = lcl_registry_entry=>registry_root.
        message 'Root node cannot be deleted' type 'I'.
        return.
      endif.

      call function 'POPUP_TO_CONFIRM'
        exporting
          titlebar              = 'Confirm deletion'(009)
          text_question         = 'Are you sure you want to delete the selected entry?'(010)
          display_cancel_button = abap_false
        importing
          answer                = lv_rc
        exceptions
          text_not_found        = 1
          others                = 2.
      if sy-subrc <> 0.
* Won't happen
      endif.

* Check that the user selected OK on the confirmation
      check lv_rc = '1'.

      lr_reg_entry = gr_sel_reg_entry->get_parent( ).
      check lr_reg_entry is bound.
      lr_reg_entry->remove_subentry( gr_sel_reg_entry->entry_id ).

* Get the parent node in the tree to refresh it
      call method gr_tree->get_parent
        exporting
          i_node_key        = gv_sel_node_key
        importing
          e_parent_node_key = lv_node_key.

* Refresh the parent node
      perform refresh_subnodes using lv_node_key.

    endif.

  endmethod.                    "handle_tree_command

* Handle commands on the values table
  method handle_table_command.
    data: lv_node_key type lvc_nkey.
    data: ls_tab type ts_tab.
    data: lt_value type lcl_registry_entry=>tt_keyval.
    data: ls_value type lcl_registry_entry=>ts_keyval.

* Save current values
    if e_ucomm = 'SAVE'.
      perform save_values.
    endif.
  endmethod.                    "handle_table_command

* Handle selection of a node in the tree
  method handle_node_selected.
    data: ls_tab type ts_tab.
    data: lt_val type lcl_registry_entry=>tt_keyval.

* Check whether data has changed before
    data: lv_answer type char01.
    data: lv_refresh type char01.
* Check for changed data. The CHECK_CHANGED_DATA() method and
* neither the DATA_CHANGED or DATA_CHANGED_FINISHED
* events of CL_GUI_ALV_GRID seem to fit the bill, so we keep our own copy
* of the original data and compare it
    if gr_table is bound.
* Refresh data in local table (GT_VALUE)
      call method gr_table->check_changed_data.

      if gt_value ne gt_value_ori.
        call function 'POPUP_TO_CONFIRM'
          exporting
            titlebar              = 'Confirm data loss'(017)
            text_question         = 'Data has changed. Save first?'(018)
            display_cancel_button = abap_false
          importing
            answer                = lv_answer
          exceptions
            text_not_found        = 1
            others                = 2.
        if sy-subrc <> 0.
* Not going to happen; not using a text
        endif.

        if lv_answer = '1'. "Save data before moving on
          perform save_values.
        endif.

      endif.

    endif.

* Set up the table
    if gr_table is not bound.
      perform create_table.
    endif.

    call method gr_tree->get_outtab_line
      exporting
        i_node_key     = node_key
      importing
        e_outtab_line  = ls_tab    " Line of Outtab
      exceptions
        node_not_found = 1
        others         = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

* Read the values of the selected registry entry
    gt_value =  ls_tab-reg_entry->get_values( ).
    gt_value_ori = gt_value. "Store last values
* Ensure column widths are correct on every update
* Settings on table
*    data: ls_layout type lvc_s_layo.
*    ls_layout-cwidth_opt = abap_true.
*    gr_table->set_frontend_layout( ls_layout ).
    gr_table->refresh_table_display( ).
* Keep track of selected reg. entry for update
    gr_sel_reg_entry = ls_tab-reg_entry.
    gv_sel_node_key  = node_key.

  endmethod.                    "handle_node_selected

* Expand nodes of the registry tree to add sub-entries
  method handle_node_expand.
    data: lr_reg_entry type ref to lcl_registry_entry.
    data: ls_tab type ts_tab.

    call method sender->get_outtab_line
      exporting
        i_node_key     = node_key
      importing
        e_outtab_line  = ls_tab    " Line of Outtab
      exceptions
        node_not_found = 1
        others         = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

    data: lt_sub_entries type lcl_registry_entry=>tt_keyobj.
    data: ls_sub_entry type lcl_registry_entry=>ts_keyobj.
    data: lv_expander type abap_bool.
    data: lv_node_text type lvc_value.

* Add sub-entries to selected node in tree
    lt_sub_entries = ls_tab-reg_entry->get_subentries( ).
    loop at lt_sub_entries into ls_sub_entry.

      lr_reg_entry = ls_sub_entry-value.
      perform add_node using node_key lr_reg_entry.

    endloop.

  endmethod.                    "EXPAND_EMPTY_FOLDER

* Modify toolbar entries for table/grid
  method handle_table_toolbar.
    data: ls_tbe type stb_button.
* Keep only the local editing features
    loop at e_object->mt_toolbar into ls_tbe.
      if ls_tbe-function(7) ne '&LOCAL&'.
        delete e_object->mt_toolbar.
      endif.
    endloop.
* Add a function for saving the values
    ls_tbe-function = 'SAVE'.
    ls_tbe-icon = '@2L@'.
    ls_tbe-butn_type = '0'.
    ls_tbe-quickinfo = 'Save'.
    append ls_tbe to e_object->mt_toolbar.
  endmethod.                    "handle_table_toolbar

endclass.                    "event_handler IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      Form  refresh_subnodes
*&---------------------------------------------------------------------*
*       Delete and refresh subnodes of a node
*----------------------------------------------------------------------*
form refresh_subnodes using pv_nkey type lvc_nkey.
  data: ls_tab type ts_tab.
  data: ls_subentry type lcl_registry_entry=>ts_keyval.
  data: lr_reg_entry type ref to lcl_registry_entry.
  data: lt_children type lvc_t_nkey.
  data: lv_nkey type lvc_nkey.

* Delete subnodes of node. This means: getting all children and deleting
* them individually!
  call method gr_tree->get_children
    exporting
      i_node_key         = pv_nkey
    importing
      et_children        = lt_children
    exceptions
      historic_error     = 1
      node_key_not_found = 2
      others             = 3.
  if sy-subrc <> 0.
    message 'Error building tree'(014) type 'E'.
  endif.

  loop at lt_children into lv_nkey.

    call method gr_tree->delete_subtree
      exporting
        i_node_key                = lv_nkey
        i_update_parents_expander = abap_true
      exceptions
        node_key_not_in_model     = 1
        others                    = 2.
    if sy-subrc <> 0.
      message 'Error building tree'(014) type 'E'.
    endif.

  endloop.

* With the children deleted, proceed to re-add registry entries

* Get the registry entry on the node
  call method gr_tree->get_outtab_line
    exporting
      i_node_key     = pv_nkey
    importing
      e_outtab_line  = ls_tab
    exceptions
      node_not_found = 1
      others         = 2.
  if sy-subrc ne 0.
    message 'Error building tree'(014) type 'E'.
  endif.
* Add a subnode for each sub-entry
  loop at ls_tab-reg_entry->sub_entries into ls_subentry.
    lr_reg_entry = ls_tab-reg_entry->get_subentry( ls_subentry-key ).
    perform add_node using pv_nkey lr_reg_entry.
  endloop.
* Expand parent node
  call method gr_tree->expand_node
    exporting
      i_node_key          = pv_nkey
    exceptions
      failed              = 1
      illegal_level_count = 2
      cntl_system_error   = 3
      node_not_found      = 4
      cannot_expand_leaf  = 5
      others              = 6.
  if sy-subrc <> 0.
    message 'Error building tree'(014) type 'E'.
  endif.
* Update tree display
  gr_table->refresh_table_display( ).
endform.                    "refresh_subnodes


*&---------------------------------------------------------------------*
*&      Form  save_values
*&---------------------------------------------------------------------*
*       Save current values in table to currently selected reg. node
*----------------------------------------------------------------------*
form save_values.
  if gr_table is bound and gr_sel_reg_entry is bound.
    data: lt_value type lcl_registry_entry=>tt_keyval.
    data: ls_value type lcl_registry_entry=>ts_keyval.
* Normalize the values; duplicate keys are overwritten, with possible loss of data!
    loop at gt_value into ls_value.
      insert ls_value into table lt_value.
    endloop.
    gr_sel_reg_entry->set_values( lt_value ).
    try.
        gr_sel_reg_entry->save( ).
      catch lcx_registry_lock.
        message 'Values have been overwritten since last change and are refreshed'(004) type 'I'.
        gr_sel_reg_entry->reload( ).
        gt_value = gr_sel_reg_entry->get_values( ).
    endtry.
    gr_table->refresh_table_display( ).
  endif.

endform.                    "save_values

*&---------------------------------------------------------------------*
*&      Form  add_node
*&---------------------------------------------------------------------*
* Add single node to tree
*----------------------------------------------------------------------*
*      -->PV_NKEY    Node of tree to which to add node
*      -->PS_TAB     Table entry (with reg. entry) to add as child
*----------------------------------------------------------------------*
form add_node
  using pv_nkey type lvc_nkey pr_regentry type ref to lcl_registry_entry.

  data: lv_node_text type lvc_value.
  data: ls_node_layout type lvc_s_layn. "Layout for new nodes
  data: ls_tab type ts_tab.

  if pr_regentry is not bound.
    message 'Error building tree'(014) type 'E'.
  endif.

  ls_tab-reg_entry = pr_regentry.

* Add node as folder always
  ls_node_layout-isfolder = abap_true.
* Add expander only if there are more sub-entries
  if lines( pr_regentry->get_subentry_keys( ) ) > 0.
    ls_node_layout-expander = abap_true.
  else.
    ls_node_layout-expander = abap_false.
  endif.

  lv_node_text = pr_regentry->entry_id.

  call method gr_tree->add_node
    exporting
      i_relat_node_key     = pv_nkey
      i_relationship       = cl_gui_column_tree=>relat_last_child
      is_outtab_line       = ls_tab
      i_node_text          = lv_node_text
      is_node_layout       = ls_node_layout
    exceptions
      relat_node_not_found = 1
      node_not_found       = 2
      others               = 3.
  if sy-subrc <> 0.
    message 'Error building tree'(014) type 'E'.
  endif.

endform.                    "add_node

*&---------------------------------------------------------------------*
*&      Form  create_table
*&---------------------------------------------------------------------*
*       Initialize table for showing values in a registry entry
*----------------------------------------------------------------------*
form create_table raising cx_salv_msg.
  data: lr_func type ref to cl_salv_functions_list.
  data: lr_cols type ref to cl_salv_columns_table.

  data: lt_fcat type lvc_t_fcat.
  data: ls_fcat type lvc_s_fcat.

  create object gr_table
    exporting
      i_parent          = gr_splitter->bottom_right_container
      i_appl_events     = abap_true    " Register Events as Application Events
*     i_fcat_complete   = SPACE    " Boolean Variable (X=True, Space=False)
    exceptions
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      others            = 5.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Add fields to catalog
  ls_fcat-fieldname = 'KEY'.
  ls_fcat-edit      = abap_true.
  ls_fcat-key       = abap_true.
  ls_fcat-scrtext_s = 'Key'(001).
  ls_fcat-outputlen = 35. "Because colwidth opt is not always great
  append ls_fcat to lt_fcat.
  ls_fcat-fieldname = 'VALUE'.
  ls_fcat-edit      = abap_true.
  ls_fcat-key       = abap_false.
  ls_fcat-scrtext_s = 'Value'(002).
  ls_fcat-outputlen = 35. "Because colwidth opt is not always great
  append ls_fcat to lt_fcat.

  call method gr_table->set_table_for_first_display
    changing
      it_outtab                     = gt_value[]
      it_fieldcatalog               = lt_fcat
    exceptions
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      others                        = 4.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Toolbar to hold only functions for editing
  set handler event_handler=>handle_table_toolbar for gr_table.
  set handler event_handler=>handle_table_command for gr_table.
  gr_table->set_toolbar_interactive( ).

** Settings on table
*  data: ls_layout type lvc_s_layo.
*  ls_layout-cwidth_opt = abap_true.
*  gr_table->set_frontend_layout( ls_layout ).

endform.                    "create_table

*&---------------------------------------------------------------------*
*&      Form  create_tree
*&---------------------------------------------------------------------*
*       Initialize tree showing the registry hierarchy
*----------------------------------------------------------------------*
form create_tree.

  data: lt_fcat type lvc_t_fcat.
  data: ls_fcat type lvc_s_fcat.
  data: lt_event type cntl_simple_events,
        ls_event type cntl_simple_event.

  gr_reg_root = lcl_registry_entry=>get_root( ).

* Create tree
  create object gr_tree
    exporting
      parent                      = gr_splitter->top_left_container
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
      item_selection              = abap_false
      no_toolbar                  = abap_false
      no_html_header              = abap_true
    exceptions
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7
      others                      = 8.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Add key so that there is *something* in the field catalog
  ls_fcat-fieldname = 'KEY'.
  ls_fcat-no_out    = abap_true.
  append ls_fcat to lt_fcat.

  call method gr_tree->set_table_for_first_display
    changing
      it_outtab       = gt_tab
      it_fieldcatalog = lt_fcat.

* Get handle on tree toolbar
  data: lt_ttb type ttb_button.
  data: ls_ttb type stb_button.
  gr_tree->get_toolbar_object( importing er_toolbar = gr_tree_toolbar ).
  gr_tree_toolbar->delete_all_buttons( ).
* Add custom buttons for registry entry operations
  ls_ttb-function = 'INSE'. "Insert entry
  ls_ttb-icon     = '@17@'. "ICON_INSERT_ROW
  append ls_ttb to lt_ttb.
  ls_ttb-function = 'DELE'. "Delete entry
  ls_ttb-icon     = '@18@'. "ICON_DELETE_ROW
  append ls_ttb to lt_ttb.
  ls_ttb-function = 'COPY'. "Copy Entry
  ls_ttb-icon     = '@14@'. "ICON_COPY_OBJECT
  append ls_ttb to lt_ttb.
  call method gr_tree_toolbar->add_button_group
    exporting
      data_table       = lt_ttb
    exceptions
      dp_error         = 1
      cntb_error_fcode = 2
      others           = 3.
  if sy-subrc <> 0.
    message 'Error when setting up registry toolbar'(005) type 'E'.
  endif.

* Add root node
  perform add_node using '' gr_reg_root.

* Register events and set handlers
*  ls_event-eventid = cl_gui_simple_tree=>eventid_node_double_click.
  ls_event-eventid = cl_gui_simple_tree=>eventid_selection_changed.
  ls_event-appl_event = 'X'.
  append ls_event to lt_event.
  ls_event-eventid = cl_gui_simple_tree=>eventid_expand_no_children.
  ls_event-appl_event = 'X'.
  append ls_event to lt_event.
  call method gr_tree->set_registered_events
    exporting
      events                    = lt_event
    exceptions
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  set handler event_handler=>handle_node_expand for gr_tree.
  set handler event_handler=>handle_node_selected for gr_tree.
  set handler event_handler=>handle_tree_command for gr_tree_toolbar.

  call method gr_tree->frontend_update.

endform.                    "create_tree

*&---------------------------------------------------------------------*
*&      Form  value_input_dialog
*&---------------------------------------------------------------------*
*       Get single value from user
*----------------------------------------------------------------------*
form value_input_dialog using title changing value returncode.
  data: lt_fld type table of sval.
  data: ls_fld type sval.

  ls_fld-tabname = 'OJFIELDS'.
  ls_fld-fieldname = 'INPUT'.
  append ls_fld to lt_fld.

  call function 'POPUP_GET_VALUES'
    exporting
      no_value_check  = abap_true
      popup_title     = title
    importing
      returncode      = returncode
    tables
      fields          = lt_fld
    exceptions
      error_in_fields = 1
      others          = 2.
  if sy-subrc <> 0.
    message 'Error during request for value'(008) type 'E'.
  endif.

  read table lt_fld into ls_fld index 1.
  value = ls_fld-value.

endform.                    "value_input_dialog

start-of-selection.


at selection-screen output.
* Disable Execute and Save functions on report selection screen
  perform insert_into_excl(rsdbrunt) using 'ONLI'.
  perform insert_into_excl(rsdbrunt) using 'SPOS'.

* Initialize the display on the first dynpro roundtrip
  if gr_splitter is not bound.
    data: gv_dynnr type sydynnr.
    data: gv_repid type syrepid.
    gv_dynnr = sy-dynnr.
    gv_repid = sy-repid.
    create object gr_splitter
      exporting
        link_dynnr        = gv_dynnr
        link_repid        = gv_repid
        parent            = cl_gui_easy_splitter_container=>default_screen
        orientation       = 1    " Orientation: 0 = Vertical, 1 = Horizontal
        sash_position     = 30    " Position of Splitter Bar (in Percent)
        with_border       = 0    " With Border = 1; Without Border = 0
      exceptions
        cntl_error        = 1
        cntl_system_error = 2
        others            = 3.

    if sy-subrc <> 0.
      exit.
    endif.

    perform create_tree.

* Table creation is deferred until the first node is selected

  endif.

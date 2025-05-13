*&---------------------------------------------------------------------*
*& Include          ZLIB_REGISTRY
*&---------------------------------------------------------------------*

CLASS lcx_registry_err DEFINITION INHERITING FROM cx_dynamic_check.
ENDCLASS.                    "lcx_registry_err DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcx_registry_lock DEFINITION
*----------------------------------------------------------------------*
CLASS lcx_registry_lock DEFINITION INHERITING FROM lcx_registry_err.
ENDCLASS.                    "lcx_registry_lock DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcx_registry_noentry DEFINITION
*----------------------------------------------------------------------*
CLASS lcx_registry_noentry DEFINITION INHERITING FROM lcx_registry_err.
ENDCLASS.                    "lcx_registry_noentry DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcx_registry_entry_exists DEFINITION
*----------------------------------------------------------------------*
CLASS lcx_registry_entry_exists DEFINITION INHERITING FROM lcx_registry_err.
ENDCLASS.                    "lcx_registry_entry_exists DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcx_registry_entry_deleted DEFINITION
*----------------------------------------------------------------------*
CLASS lcx_registry_entry_deleted DEFINITION INHERITING FROM lcx_registry_err.
ENDCLASS.                    "lcx_registry_entry_deleted DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcx_registry_invalid_char DEFINITION
*----------------------------------------------------------------------*
CLASS lcx_registry_invalid_char DEFINITION INHERITING FROM lcx_registry_err.
ENDCLASS.                    "lcx_registry_invalid_char DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_registry_entry DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_registry_entry DEFINITION CREATE PROTECTED.

  PUBLIC SECTION.
* Predefined key for the registry root:
    CLASS-DATA: registry_root TYPE indx_srtfd READ-ONLY VALUE 'REGISTRY_ROOT'.

    TYPES: BEGIN OF ts_keyval,
             key   TYPE string,
             value TYPE string,
           END OF ts_keyval.
    TYPES: tt_keyval TYPE SORTED TABLE OF ts_keyval WITH UNIQUE KEY key.

* For keeping track of references to sub-entries, we maintain a shadow
* table with the same keys
    TYPES: BEGIN OF ts_keyobj,
             key   TYPE string,
             value TYPE REF TO lcl_registry_entry,
           END OF ts_keyobj.
    TYPES: tt_keyobj TYPE SORTED TABLE OF ts_keyobj WITH UNIQUE KEY key.

    DATA: sub_entries    TYPE tt_keyval READ-ONLY.
    DATA: values         TYPE tt_keyval READ-ONLY.
    DATA: internal_key   TYPE indx_srtfd READ-ONLY.
    DATA: parent_key     TYPE indx_srtfd READ-ONLY.
    DATA: entry_id       TYPE string READ-ONLY. "User-friendly ID of the subnode

    METHODS:
      constructor
        IMPORTING
          internal_key TYPE any,
      reload,
*      lock raising lcx_registry_err,
* Saves entry and all dirty sub-entries
      save RAISING lcx_registry_err,

      get_parent
        RETURNING VALUE(parent) TYPE REF TO lcl_registry_entry,

      create_by_path
        IMPORTING path         TYPE string
        RETURNING VALUE(entry) TYPE REF TO lcl_registry_entry
        RAISING   lcx_registry_err,

*--------------------------------------------------------------------*
* Methods dealing with sub-entries of the registry entry
      get_subentry
        IMPORTING key          TYPE clike
        RETURNING VALUE(entry) TYPE REF TO lcl_registry_entry,
      add_subentry
        IMPORTING key          TYPE clike
        RETURNING VALUE(entry) TYPE REF TO lcl_registry_entry
        RAISING   lcx_registry_entry_exists,
* Removes sub-entry and all entries underneath
      remove_subentry
        IMPORTING key TYPE clike
        RAISING   lcx_registry_err,
      remove_subentries
        RAISING lcx_registry_err,
      copy_subentry
        IMPORTING source_key          TYPE clike
                  target_key          TYPE clike
        RETURNING VALUE(target_entry) TYPE REF TO lcl_registry_entry
        RAISING   lcx_registry_err,

      get_subentry_keys
        RETURNING VALUE(keys) TYPE string_table,

      get_subentries
        RETURNING VALUE(sub_entries) TYPE tt_keyobj,

* Methods for dealing with values in the registry entry:

* Get keys of all values
      get_value_keys
        RETURNING VALUE(keys) TYPE string_table,
* Get all values
      get_values
        RETURNING VALUE(values) TYPE tt_keyval,
* Set all values in one go:
      set_values
        IMPORTING values TYPE tt_keyval,
* Get single value by key
      get_value
        IMPORTING key          TYPE clike
        RETURNING VALUE(value) TYPE string
        RAISING   lcx_registry_noentry,
* Set/overwrite single value
      set_value
        IMPORTING key   TYPE clike
                  value TYPE any,
* Delete single value by key
      delete_value
        IMPORTING key TYPE clike.


    CLASS-METHODS:
      get_entry_by_internal_key
        IMPORTING key          TYPE any
        RETURNING VALUE(entry) TYPE REF TO lcl_registry_entry,
      get_root
        RETURNING VALUE(root) TYPE REF TO lcl_registry_entry.

  PROTECTED SECTION.

    METHODS:
      set_optimistic_lock
        RAISING lcx_registry_lock,
      promote_lock
        RAISING lcx_registry_lock,
      release_lock,
      copy_subentry_deep
        IMPORTING source TYPE REF TO lcl_registry_entry
                  target TYPE REF TO lcl_registry_entry,
* Remove the registry entry from the database:
* The DELETE method is protected because you must always delete an entry
* as the sub-entry of its parent so that the link is removed from the
* parent
      delete
        RAISING lcx_registry_err.

    DATA: deleted TYPE abap_bool.

*    data: sub_entrobj type tt_keyobj.

* Class-wide buffer of instances of registry entries
    CLASS-DATA: registry_entries TYPE tt_keyobj.


ENDCLASS.                    "lcl_registry_entry DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_registry_entry IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_registry_entry IMPLEMENTATION.

*--------------------------------------------------------------------*
* CONSTRUCTOR - new instance of registry key
*--------------------------------------------------------------------*
  METHOD constructor.
    me->internal_key = internal_key.

* Load the entry from the database
    reload( ).

* Object inserts itself into registry of entries
    DATA: ko TYPE ts_keyobj.
    ko-key = me->internal_key.
    ko-value = me.
    INSERT ko INTO TABLE registry_entries.

  ENDMETHOD.                    "constructor

*--------------------------------------------------------------------*
* RELOAD - reload values and sub-entries from database, set new lock
*--------------------------------------------------------------------*
  METHOD reload.
* Reload the values and sub-entries from the database
    IMPORT values = me->values sub_entries = me->sub_entries parent = parent_key entry_id = entry_id
      FROM DATABASE zindx(zr) ID internal_key.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE lcx_registry_noentry.
    ENDIF.

    set_optimistic_lock( ).
  ENDMETHOD.                    "reload

*--------------------------------------------------------------------*
* GET_ROOT - retrieve root entry of registry
*--------------------------------------------------------------------*
  METHOD get_root.

* If the root doesn't exist yet, create it
    DATA: values TYPE tt_keyval.
    DATA: sub_entries TYPE tt_keyval.
    DATA: parent_key TYPE indx_srtfd VALUE space.
    DATA: entry_id TYPE string.
    IMPORT values = values sub_entries = sub_entries
      FROM DATABASE zindx(zr) ID registry_root.
    IF sy-subrc NE 0.
      entry_id = registry_root.
      EXPORT values = values sub_entries = sub_entries parent = parent_key entry_id = entry_id
        TO DATABASE zindx(zr) ID registry_root.
    ENDIF.

* Retrieve the root entry of the registry
    root = get_entry_by_internal_key( registry_root ).

  ENDMETHOD.                    "get_root

*--------------------------------------------------------------------*
* GET_ENTRY_BY_INTERNAL_KEY - retrieve reg. entry by internal ID
*--------------------------------------------------------------------*
  METHOD get_entry_by_internal_key.
    DATA: ko TYPE ts_keyobj.

* Search global index of registry entry instances
    READ TABLE registry_entries INTO ko WITH KEY key = key.

    IF sy-subrc = 0.
* Reference already exists; return that
      entry = ko-value.
    ELSE.
* Create new reference to sub-entry
      CREATE OBJECT entry
        EXPORTING
          internal_key = key.
* Will insert itself into registry entries
    ENDIF.
  ENDMETHOD.                    "get_entry_by_internal_key

*--------------------------------------------------------------------*
* CREATE_BY_PATH - convenience method, analogous to mkdir -p that
* allows you to create a path of registry entries if they do not yet
* exist; paths must be separated by forward slash ('/')
* Sub-entries are created from the current registry entry
*--------------------------------------------------------------------*
  METHOD create_by_path.
    DATA: keys TYPE string_table.
    DATA: key TYPE string.
    DATA: sub_entry TYPE REF TO lcl_registry_entry.

    SPLIT path AT '/' INTO TABLE keys.
    DELETE keys WHERE table_line IS INITIAL.

    entry = me.
    LOOP AT keys INTO key.
      sub_entry = entry->get_subentry( key ).
      IF sub_entry IS NOT BOUND.
        sub_entry = entry->add_subentry( key ).
      ENDIF.
      entry = sub_entry.
    ENDLOOP.
* After successful processing of chain, ENTRY will
* contain the last-created node

  ENDMETHOD.                    "create_by_path

*--------------------------------------------------------------------*
* GET_PARENT - retrieve parent entry of this entry
*--------------------------------------------------------------------*
  METHOD get_parent.
* Return the parent of the current key
    parent = get_entry_by_internal_key( parent_key ).
  ENDMETHOD.                    "get_parent

*--------------------------------------------------------------------*
* GET_SUBENTRY - return single child entry by key
*--------------------------------------------------------------------*
  METHOD get_subentry.
    DATA: kv TYPE ts_keyval.
    DATA: ko TYPE ts_keyobj.

* Read internal store of sub-entries
    READ TABLE sub_entries INTO kv WITH KEY key = key.
    IF sy-subrc NE 0.
* Entry does not exist; exit
      RETURN.
    ENDIF.

* Search global index of registry entry instances
    READ TABLE registry_entries INTO ko WITH KEY key =  kv-value.

*    read table sub_entrobj into ko with key key = kv-value.
    IF sy-subrc = 0.
* Reference already exists; return that
      entry = ko-value.
    ELSE.
* Create new reference to sub-entry
      CREATE OBJECT entry
        EXPORTING
          internal_key = kv-value.
* Will insert itself into registry entries
    ENDIF.

  ENDMETHOD.                    "get_subentry

*--------------------------------------------------------------------*
* GET_SUBENTRIES - return immediate children registry entries
*--------------------------------------------------------------------*
  METHOD get_subentries.
    DATA: ko TYPE ts_keyobj.
    DATA: subkeys TYPE string_table.
    DATA: subkey TYPE string.

    subkeys = get_subentry_keys( ).
    LOOP AT subkeys INTO subkey.
      ko-key = subkey.
      ko-value = get_subentry( subkey ).
      INSERT ko INTO TABLE sub_entries.
    ENDLOOP.

  ENDMETHOD.                    "get_subentries

*--------------------------------------------------------------------*
* ADD_SUBENTRY - add a child entry with new key and save
*--------------------------------------------------------------------*
  METHOD add_subentry.
    DATA: kv TYPE ts_keyval.
    DATA: ko TYPE ts_keyobj. "Shadow table with object references

* Prevent any changes if this entry is marked as deleted
    IF me->deleted = abap_true.
      RAISE EXCEPTION TYPE lcx_registry_entry_deleted.
    ENDIF.

* Check that only allowed characters are used. Will help for making
* sensible paths and string handling in other applications
* Most of all, we want to avoid spaces and slashes (although those
* square and curly brackets could cause problems for JSON...)
    IF NOT key CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890@#$%^_+-(){}[]'.
      RAISE EXCEPTION TYPE lcx_registry_invalid_char.
    ENDIF.

* Read internal store of sub-entries
    READ TABLE sub_entries INTO kv WITH KEY key = key.
    IF sy-subrc = 0.
      RAISE EXCEPTION TYPE lcx_registry_entry_exists.
    ENDIF.

* Create unique ID for key in INDX for the new entry
    kv-key = key.
    TRY.
        kv-value = cl_system_uuid=>create_uuid_c22_static( ).
      CATCH cx_uuid_error.
        RAISE EXCEPTION TYPE lcx_registry_err.
    ENDTRY.
    INSERT kv INTO TABLE sub_entries.

* Create an entry on the database for the new entry
    DATA: lt_empty_vals TYPE tt_keyval.
    DATA: lv_srtfd TYPE indx_srtfd.
    lv_srtfd = kv-value.
    EXPORT values = lt_empty_vals sub_entries = lt_empty_vals
      parent = internal_key entry_id = key
      TO DATABASE zindx(zr) ID lv_srtfd.

    CREATE OBJECT entry
      EXPORTING
        internal_key = kv-value.
* Will insert itself into registry entries

** Set current entry as the parent of the new entry
*    entry->parent_key = internal_key.
** Set short ID on the new entry
*    entry->entry_id = key.
** Save the new entry
*    entry->save( ).

* Save the current entry to update the list of sub-keys
    save( ).

  ENDMETHOD.                    "add_subentry

*--------------------------------------------------------------------*
* COPY_SUBENTRY - copy a child registry entry at the same level,
*  including all values, by passing a source and target key
*--------------------------------------------------------------------*
  METHOD copy_subentry.

    DATA: source_entry TYPE REF TO lcl_registry_entry.

* Prevent any changes if this entry is marked as deleted
    IF me->deleted = abap_true.
      RAISE EXCEPTION TYPE lcx_registry_entry_deleted.
    ENDIF.

    source_entry = get_subentry( source_key ).
    IF source_entry IS NOT BOUND.
      RAISE EXCEPTION TYPE lcx_registry_noentry.
    ENDIF.
    target_entry = add_subentry( target_key ).

* Using the source and the new target, do a deep copy that includes
* copies of sub-entries and values
    copy_subentry_deep( source = source_entry target = target_entry ).

  ENDMETHOD.                    "copy_subentry

*--------------------------------------------------------------------*
* COPY_SUBENTRY_DEEP - (protected) - copy a branch of the registry
*         at the same level, including all values
*--------------------------------------------------------------------*
  METHOD copy_subentry_deep.
    DATA: ls_subentry TYPE ts_keyval.
    DATA: lr_source TYPE REF TO lcl_registry_entry.
    DATA: lr_target TYPE REF TO lcl_registry_entry.

* Copy values from source to target
    target->values = source->values.

* Copy sub-entries from source to target
    LOOP AT source->sub_entries INTO ls_subentry.
      lr_source = source->get_subentry( ls_subentry-key ).
      lr_target = target->add_subentry( ls_subentry-key ).
      copy_subentry_deep( source = lr_source target = lr_target ).
    ENDLOOP.

* Ensure that values are also saved
    save( ).

  ENDMETHOD.                    "copy_subentry_deep

*--------------------------------------------------------------------*
* REMOVE_SUBENTRIES - remove all child entries of this entry
*--------------------------------------------------------------------*
  METHOD remove_subentries.
    DATA: kv TYPE ts_keyval.
    DATA: ko TYPE ts_keyobj. "Shadow table with object references

* Prevent any changes if this entry is marked as deleted
    IF me->deleted = abap_true.
      RAISE EXCEPTION TYPE lcx_registry_entry_deleted.
    ENDIF.

    LOOP AT sub_entries INTO kv.
      remove_subentry( kv-key ).
    ENDLOOP.
  ENDMETHOD.                    "remove_subentries

*--------------------------------------------------------------------*
* DELETE - delete the current entry from the database and mark it,
*          preventing any further operations on this entry
*--------------------------------------------------------------------*
  METHOD delete.

    DATA: sub_entry TYPE ts_keyval.
    DATA: entry TYPE REF TO lcl_registry_entry.

* Prevent any changes if this entry is marked as deleted
    IF me->deleted = abap_true.
      RAISE EXCEPTION TYPE lcx_registry_entry_deleted.
    ENDIF.

* Delete all sub-entries before deleting this entry
    LOOP AT sub_entries INTO sub_entry.
      entry = get_subentry( sub_entry-key ).
      entry->delete( ).
      DELETE sub_entries.
    ENDLOOP.

* Remove DB entry for the current entry
    promote_lock( ).
    DELETE FROM DATABASE zindx(zr) ID internal_key.
* Object removes itself from the global table too so that that reference no longer exists
    DELETE registry_entries WHERE key = internal_key.
* Set the object to deleted to prevent any operations on any remaining
* references to the object
    deleted = abap_true.

* Release lock held on this key
    release_lock( ).

  ENDMETHOD.                    "delete

*--------------------------------------------------------------------*
* REMOVE_SUBENTRY - remove a single child registry entry by key
*--------------------------------------------------------------------*
  METHOD remove_subentry.
    DATA: kv TYPE ts_keyval.
    FIELD-SYMBOLS: <ko> TYPE ts_keyobj. "Shadow table with object references
    DATA: sub_entry TYPE REF TO lcl_registry_entry.

* Prevent any changes if this entry is marked as deleted
    IF me->deleted = abap_true.
      RAISE EXCEPTION TYPE lcx_registry_entry_deleted.
    ENDIF.

* Read internal store of sub-entries
    READ TABLE sub_entries INTO kv WITH KEY key = key.
    IF sy-subrc NE 0.
* Entry does not exist; exit with error
      RAISE EXCEPTION TYPE lcx_registry_noentry.
    ENDIF.

* Remove all sub-entries of the sub-entry before removing the sub-entry
    sub_entry = get_subentry( key ).
    IF sub_entry IS BOUND.

* Delete the sub_entry (which deletes its sub-entries)
      sub_entry->delete( ).
* Remove entry from sub-entry table and shadow table
      DELETE sub_entries WHERE key = key.               "#EC CI_SORTSEQ

      save( ). "Save current entry to remove subentry that has been removed
    ENDIF.

  ENDMETHOD.                    "remove_subentry

*--------------------------------------------------------------------*
* SAVE - save the current entry, with concurrency control
*--------------------------------------------------------------------*
  METHOD save.

* Prevent any changes if this entry is marked as deleted
    IF me->deleted = abap_true.
      RAISE EXCEPTION TYPE lcx_registry_entry_deleted.
    ENDIF.

    promote_lock( ).
    EXPORT values = me->values sub_entries = me->sub_entries parent = parent_key entry_id = entry_id
      TO DATABASE zindx(zr) ID internal_key.
    set_optimistic_lock( ).
  ENDMETHOD.                    "save

*--------------------------------------------------------------------*
* GET_SUBENTRY_KEYS - retrieve keys of all child registry entries
*--------------------------------------------------------------------*
  METHOD get_subentry_keys.
    DATA: kv TYPE ts_keyval.
    LOOP AT sub_entries INTO kv.
      APPEND kv-key TO keys.
    ENDLOOP.
  ENDMETHOD.                    "get_subentry_keys

*--------------------------------------------------------------------*
* GET_VALUE_KEYS - retrieve keys of all values
*--------------------------------------------------------------------*
  METHOD get_value_keys.
    DATA: kv TYPE ts_keyval.
    LOOP AT values INTO kv.
      APPEND kv-key TO keys.
    ENDLOOP.
  ENDMETHOD.                    "get_value_keys

*--------------------------------------------------------------------*
* GET_VALUES - retrieve all values at once in key+value table
*--------------------------------------------------------------------*
  METHOD get_values.
    values = me->values.
  ENDMETHOD.                    "get_values

*--------------------------------------------------------------------*
* SET_VALUES - set all values at once with key+value table
*--------------------------------------------------------------------*
  METHOD set_values.
* Prevent any changes if this entry is marked as deleted
    IF me->deleted = abap_true.
      RAISE EXCEPTION TYPE lcx_registry_entry_deleted.
    ENDIF.

    me->values = values.
  ENDMETHOD.                    "set_values

*--------------------------------------------------------------------*
* GET_VALUE - return a single value by key
*--------------------------------------------------------------------*
  METHOD get_value.
    DATA: kv TYPE ts_keyval.
    READ TABLE values INTO kv WITH KEY key = key.
    IF sy-subrc = 0.
      value = kv-value.
    ENDIF.
  ENDMETHOD.                    "get_value

  METHOD set_value.
    DATA: kv TYPE ts_keyval.

* Prevent any changes if this entry is marked as deleted
    IF me->deleted = abap_true.
      RAISE EXCEPTION TYPE lcx_registry_entry_deleted.
    ENDIF.

* Add the value to set of values if not existing or change if it does exist
    READ TABLE values INTO kv WITH KEY key = key.
    IF sy-subrc NE 0.
      kv-key = key.
      kv-value = value.
      INSERT kv INTO TABLE values.
    ELSE.
      kv-value = value.
      MODIFY TABLE values FROM kv.
    ENDIF.
  ENDMETHOD.                    "set_value

  METHOD delete_value.

* Prevent any changes if this entry is marked as deleted
    IF me->deleted = abap_true.
      RAISE EXCEPTION TYPE lcx_registry_entry_deleted.
    ENDIF.

    DELETE values WHERE key = key.                      "#EC CI_SORTSEQ
  ENDMETHOD.                    "delete_value

**********************************************************************
* CONCURRENCY HELPER METHODS
**********************************************************************

*--------------------------------------------------------------------*
* SET_OPTIMISTIC_LOCK - always set when (re-)reading an entry
*--------------------------------------------------------------------*
  METHOD set_optimistic_lock.
* Existing lock must be released before acquiring a new one
    release_lock( ).
    CALL FUNCTION 'ENQUEUE_ESINDX'
      EXPORTING
        mode_indx      = 'O'
        relid          = 'ZR'
        srtfd          = internal_key
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_registry_lock.
    ENDIF.
  ENDMETHOD.                    "set_optimistic_lock

*--------------------------------------------------------------------*
* PROMOTE_LOCK - Get exclusive lock just before saving
*--------------------------------------------------------------------*
  METHOD promote_lock.
    CALL FUNCTION 'ENQUEUE_ESINDX'
      EXPORTING
        mode_indx      = 'R'
        relid          = 'ZR'
        srtfd          = internal_key
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_registry_lock.
    ENDIF.
  ENDMETHOD.                    "promote_lock

*--------------------------------------------------------------------*
* RELEASE_LOCK - called after deleting or before re-acquiring
*--------------------------------------------------------------------*
  METHOD release_lock.
    CALL FUNCTION 'DEQUEUE_ESINDX'
      EXPORTING
        relid = 'ZR'
        srtfd = internal_key.
  ENDMETHOD.                    "release_lock


ENDCLASS.                    "lcl_registry_entry IMPLEMENTATION

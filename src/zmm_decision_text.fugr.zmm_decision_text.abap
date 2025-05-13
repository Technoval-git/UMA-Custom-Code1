FUNCTION ZMM_DECISION_TEXT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_WIID) TYPE  SWW_WIID
*"  TABLES
*"      RETURN STRUCTURE  TLINE
*"----------------------------------------------------------------------
*----------------------------------------------------------------------

  type-pools: swlc.

  data: tl_object_content type table of solisti1,
        tl_tdline         type table of tdline,
        vl_string_text    type string,
        wa_return         type tline,
        wa_workitem       type swlc_workitem,
        wa_document_data  type sofolenti1,
        vl_document_id    type sofolenti1-doc_id.

  field-symbols: <lf_attachobj>       type swotobjid,
                 <lf_tdline>          type tdline,
                 <lf_object_content>  type solisti1.

  "Get the attachments...(Here is the "Father" Workitem, you don't have it use FM SWI_GET_RELATED_WORKITEMS to find out...)
  call function 'SWL_WI_ATTACHMENTS_READ'
    exporting
      wi_id                = im_wiid
    changing
      workitem             = wa_workitem
    exceptions
      no_attachments_found = 1
      workitem_not_found   = 2
      others               = 3.

  if sy-subrc <> 0.
    return.
  endif.

  loop at wa_workitem-attachobj assigning <lf_attachobj>.
    clear: tl_object_content[], vl_document_id, wa_document_data, tl_tdline[].
    "Leitura de cada objetos..
    vl_document_id = <lf_attachobj>-objkey.

    call function 'SO_DOCUMENT_READ_API1'
      exporting
        document_id                = vl_document_id
      importing
        document_data              = wa_document_data
      tables
        object_content             = tl_object_content
      exceptions
        document_id_not_exist      = 1
        operation_no_authorization = 2
        x_error                    = 3
        others                     = 4.

    if sy-subrc <> 0.
      continue.
    endif.
    "Here you could check for comments only as well(FIORI Appr. Texts...)
*    if wa_document_data-obj_type = 'TXT'
*      and wa_document_data-obj_name = 'COMMENT'
    if not tl_object_content[] is initial.
      loop at tl_object_content assigning <lf_object_content>.
        if vl_string_text is initial.
          vl_string_text = <lf_object_content>-line.
        else.
          concatenate vl_string_text <lf_object_content>-line into vl_string_text separated by space.
        endif.
      endloop.
      condense vl_string_text.
      call function 'SOTR_SERV_STRING_TO_TABLE'
        exporting
          text        = vl_string_text
          line_length = 72
        tables
          text_tab    = tl_tdline.
      loop at tl_tdline assigning <lf_tdline>.
        wa_return-tdline = <lf_tdline>.
        append wa_return to return.
      endloop.
    endif.
  endloop.




ENDFUNCTION.

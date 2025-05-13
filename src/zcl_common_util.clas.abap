class ZCL_COMMON_UTIL definition
  public
  final
  create public .

public section.

  constants GC_INV_DOC_TYPE type VLC_ACTDOCTYPE value 'QOIV' ##NO_TEXT.
  constants GC_INV_RETN_DOC_TYPE type VLC_ACTDOCTYPE value 'QRBD' ##NO_TEXT.
  constants GC_SERV_CONTRL_CODE type /DBE/C_ORDER_ENGINE value 'CS' ##NO_TEXT.
  constants GC_MM_CONTROL_CODE type /DBE/C_ORDER_ENGINE value 'MM' ##NO_TEXT.
  class-data GV_PO_DOC_TYPE type BSART .
  constants GC_SL_CONTROL_CODE type /DBE/C_ORDER_ENGINE value 'FO' ##NO_TEXT.
  class-data GT_TVARVC type TVARVC_T .
  class-data GT_KNVV type /DBE/KNVV_T .

  class-methods GET_DIRECTORY
    importing
      !IV_PATH type LOCALFILE optional
    exporting
      !EV_DIRECTORY type STRING .
  class-methods GET_PATH_PARAMS
    importing
      !IV_PATH type LOCALFILE
      !IV_PREFIX type STRING optional
    exporting
      !EV_DIRECTORY type STRING
      !EV_FILE_NAME type STRING
      !EV_EXTENSION type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_COMMON_UTIL IMPLEMENTATION.


  METHOD GET_DIRECTORY.
    CONSTANTS : lc_get_path TYPE string VALUE '(.*/)'.

    DATA : lv_user_path TYPE string,
           lv_path      TYPE string.
    lv_user_path = iv_path.
    FIND REGEX lc_get_path IN lv_user_path IGNORING CASE
                   SUBMATCHES lv_path .
    IF sy-subrc = 0 .
      ev_directory = lv_path.
    ENDIF.
  ENDMETHOD.


  METHOD GET_PATH_PARAMS.
    CONSTANTS: lc_dot           TYPE char01 VALUE '.',
               lc_pattern       TYPE string VALUE '(.*)(\.{1}(?:csv|txt){1})$', " end with extension
               lc_path          TYPE string VALUE '(.*)(\.{1}(?:csv|txt){1})$', " end with extension
               lc_last_f_sls    TYPE string VALUE '.*/$', "end with /
               lc_not_full_path TYPE string VALUE '(\.\w+)?$',
               lc_get_path      TYPE string VALUE '(.*/)', " get path including file name till the last /.
               lc_dir_f_name    TYPE string VALUE '(.*/)?(.*)?$'. " get directory and path (caution : it is used only with the format [directory]/[file])
*             lc_three_kings type string value '(.*/)?(.*)?(\.{1}(?:csv|txt){1})$'.
    DATA : lw_data                TYPE  string,
           l_path                 TYPE  string,
           lv_extension           TYPE  char5,
           ls_result              TYPE  match_result,
           lv_offset              TYPE  i,
           lv_off                 TYPE i,
           lv_len                 TYPE i,
           lt_result_tab          TYPE match_result_tab,
           ts_submatch_result_tab TYPE match_result,
           lv_sub_path_file       TYPE string,
           lv_sub_path_extension  TYPE string,
           lv_user_path           TYPE string,
           lv_ext_tmp             TYPE string.
*** Success Log
*  IF i_successful_records[] IS NOT INITIAL.
    CLEAR: l_path, ls_result, lv_offset, lv_extension,lv_user_path.
    "copy path to local variable type string to omit succedding string space.
    lv_user_path = iv_path.

    "fetch the file path and extension from the string using REGEX
    FIND REGEX lc_pattern IN lv_user_path IGNORING CASE
                     SUBMATCHES lv_sub_path_file lv_sub_path_extension .
    IF sy-subrc = 0 AND lv_sub_path_extension IS NOT INITIAL . " found extension
      lv_extension = lv_sub_path_extension.
      l_path = lv_sub_path_file.



    ELSE. " extension not found (.CSV or .TXT)
      lv_extension = '.txt'.
      "check its not full path
      CLEAR lv_ext_tmp.
      FIND REGEX lc_not_full_path IN lv_user_path IGNORING CASE RESULTS lt_result_tab  SUBMATCHES lv_ext_tmp  .

      IF sy-subrc = 0 AND lv_ext_tmp IS INITIAL. " it is not an extension or wrong extension
        READ TABLE lt_result_tab INTO ts_submatch_result_tab INDEX 1.
        l_path = lv_user_path(ts_submatch_result_tab-offset).
        "check if path has the last /
        "if not it will be added here
        FIND REGEX lc_last_f_sls IN l_path IGNORING CASE.
        IF sy-subrc <> 0 . " there is no "/
          "add /
          CONCATENATE l_path '/' INTO l_path.
        ENDIF.

      ELSEIF lv_ext_tmp IS NOT INITIAL .
        READ TABLE lt_result_tab INTO ts_submatch_result_tab INDEX 1.
        l_path = lv_user_path(ts_submatch_result_tab-offset).
      ENDIF.

    ENDIF.

**********************************************************************
    "get file name and file directory (The l_path contains only the text till the extension : Please refer the above steps of processing )
    FIND REGEX lc_dir_f_name IN l_path IGNORING CASE
                     SUBMATCHES ev_directory ev_file_name .

    ev_extension = lv_extension.
  ENDMETHOD.
ENDCLASS.

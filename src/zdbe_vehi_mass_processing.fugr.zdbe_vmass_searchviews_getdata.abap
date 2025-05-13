FUNCTION ZDBE_VMASS_SEARCHVIEWS_GETDATA.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(EV_TEXT) TYPE  CHAR50
*"     REFERENCE(EV_FUZZY) TYPE  CHAR1
*"     REFERENCE(EV_EXACT) TYPE  CHAR1
*"  TABLES
*"      ET_VLCEXTCRIT TYPE  VLCH_SEARCHCRIT_PT OPTIONAL
*"      ET_CONTRERROR STRUCTURE  VLCSEARCHCONTROL OPTIONAL
*"  EXCEPTIONS
*"      CONTROLERROR
*"--------------------------------------------------------------------
* This is a copy of VELO02 FM and determines which
* fields are filled out for searching (based on VMS customizing)
* and fills out search critiria structure

* variables to get data from the customer's screens
  DATA: report_lv    LIKE rsvar-report,
        seltab_lt    TYPE TABLE OF rsparams,
        allsel_lt    TYPE TABLE OF rsparams,
        rangeline_ls LIKE rsparams,
        time_ls      LIKE rsparams.

* VLCSEARCHCONTROL variables
  DATA: control_ls  TYPE vlcsearchcontrol,
        control2_ls LIKE control_ls,
        control_lt     TYPE vlcsearchcontrol_t,
        ctrl_search_lt TYPE vlcsearchcontrol_t.

* data describing a single search criteria
  DATA: typelen_lv TYPE i,
        pos_lv     TYPE i,
        len_lv     TYPE i,
        crit_ls    TYPE vlch_searchcrit_ps,
        lt_dfies   TYPE STANDARD TABLE OF dfies,
        ls_dfies   TYPE dfies.


* Handling of timestamps and dates
  DATA: timlnam_lv    TYPE string,
        timhnam_lv    TYPE string,
        datl_lv       LIKE sy-datlo,
        dath_lv       LIKE sy-datlo,
        timl_lv       LIKE sy-timlo,
        timh_lv       LIKE sy-timlo,
        tstpl_lv      LIKE tzonref-tstamps,
        tstph_lv      LIKE tzonref-tstamps,
        critoption_lv LIKE crit_ls-option.

* variables for error messages
  DATA: id1 TYPE string,
        id2 LIKE id1, id3 LIKE id1, id4 LIKE id1.

* actdoctypes for document searches
  TYPES: BEGIN OF tabdoc_ps,
          tab TYPE vlc_tabname,
          doctype TYPE vlc_actdoctype,
         END OF  tabdoc_ps.
  DATA: tabdocnote_ls TYPE tabdoc_ps,
        tabdocnote_lt TYPE TABLE OF tabdoc_ps.

  TYPES: BEGIN OF ts_selfield,
           selname TYPE rsscr_name,
           table   TYPE vlc_tabname,
           field   TYPE vlc_fieldname,
         END OF ts_selfield.

  DATA: ls_selfield TYPE ts_selfield,
        lt_selfield TYPE TABLE OF ts_selfield.

  DATA: lt_scr_info TYPE TABLE OF scr_info,
        ls_scr_info TYPE scr_info,
        lv_auxstr   TYPE string.
  FIELD-SYMBOLS <scr_info> TYPE scr_info.

  report_lv = gv_subscreen_program.
  REFRESH seltab_lt[].

*Get the selection criteria from customer screen
  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = report_lv
    TABLES
      selection_table = seltab_lt
    EXCEPTIONS
      not_found       = 1
      no_report       = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  APPEND LINES OF seltab_lt TO allsel_lt.

  SORT allsel_lt ASCENDING BY selname.

* get detail info regarding selection screen fields >>>N:1402199
  CALL FUNCTION 'RS_SELSCREEN_INFO'
      EXPORTING
        report              = report_lv
      TABLES
        field_info          = lt_scr_info
      EXCEPTIONS
        no_selections       = 1
        report_not_existent = 2
        subroutine_pool     = 3
        OTHERS              = 4.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* extract only importing info from selecion fields to lt_selfield
  LOOP AT lt_scr_info ASSIGNING <scr_info>.
    CLEAR ls_selfield.
    SPLIT <scr_info>-name AT '-' INTO ls_selfield-selname lv_auxstr. " remove ending -low -highs
    FIND FIRST OCCURRENCE OF '-' IN <scr_info>-dbfield. "check if dbfield contains table name
    IF sy-subrc = 0.
      SPLIT <scr_info>-dbfield AT '-' INTO ls_selfield-table ls_selfield-field.
    ELSE.
      ls_selfield-field = <scr_info>-dbfield.
    ENDIF.
    APPEND ls_selfield TO lt_selfield.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM lt_selfield COMPARING ALL FIELDS.
  SORT lt_selfield BY selname.                                     "<<<N:1402199

*Get the TREX search criteria
*FUZZY
  READ TABLE seltab_lt INTO rangeline_ls WITH KEY
    selname = 'FUZZY'.
  IF sy-subrc EQ 0.
    ev_fuzzy = rangeline_ls-low.
  ENDIF.
*Exact search
  READ TABLE seltab_lt INTO rangeline_ls WITH KEY
    selname = 'EXACT'.
  IF sy-subrc EQ 0.
    ev_exact = rangeline_ls-low.
  ENDIF.
*TEXT
  READ TABLE seltab_lt INTO rangeline_ls WITH KEY
    selname = 'TEXT'.
  IF sy-subrc EQ 0.
    ev_text = rangeline_ls-low.
  ENDIF.

* From the content of allsel_lt we have to build vlcextcrit
* entries
  REFRESH et_contrerror.
  REFRESH et_vlcextcrit.

* READ TABLE "SEARCH CONTROL" AND LOOP OVER TABLE
* OF ENTRIES IN "SEARCH CONTROL"
  CALL FUNCTION 'VELO14_READ_SEARCHCONTROL'
    TABLES
      control_et       = control_lt
    EXCEPTIONS
      no_entries_found = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID 'VELO' TYPE 'E' NUMBER '196' RAISING controlerror.
  ENDIF.

* SORT and REFRESH TABDOCNOTE_LT to consider B-criterions only
* if A-criterions are considered before.
  SORT control_lt BY sctable scactdoctype scprio ASCENDING.
  REFRESH tabdocnote_lt.

* copy for binary search by selection parameter name, table and tablefield N:1402199
  ctrl_search_lt[] = control_lt.
  SORT ctrl_search_lt BY scinterfacefield sctable sctablefield ASCENDING.

  LOOP AT control_lt INTO control_ls.

    READ TABLE allsel_lt
      WITH KEY selname = control_ls-scinterfacefield
      INTO rangeline_ls.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

*   read detail info for selection field >>>N:1402199
    READ TABLE lt_selfield
      WITH KEY selname = control_ls-scinterfacefield
      INTO ls_selfield
      BINARY SEARCH.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

*   in case that selection field has assigned table and control_ls-sctable is different from it
*   check if in control_lt(ctrl_search_lt) is better record
    IF ls_selfield-table IS NOT INITIAL AND control_ls-sctable <> ls_selfield-table.
      READ TABLE ctrl_search_lt WITH KEY scinterfacefield = control_ls-scinterfacefield
                                         sctable          = ls_selfield-table
                                         sctablefield     = ls_selfield-field
        BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CONTINUE.       " if there is better record skip current
      ENDIF.
    ENDIF.                                                "<<<N:1402199

*   if it is an empty searchcriterion it also can be ignored.
    IF rangeline_ls-low IS INITIAL AND rangeline_ls-high IS INITIAL
     AND rangeline_ls-sign IS INITIAL
    AND rangeline_ls-option IS INITIAL.                     "PA9K014510
      CONTINUE.
    ENDIF.
*    _______________________________________________________________
*     CHECK IF A B-PRIORITY-CRITERION SHOULD BE PROCESSED
*     CANCEL THE PROCESSING OF C-PRIORITY-CRITERION
*    _______________________________________________________________
    IF control_ls-scprio = 'B'.
      READ TABLE tabdocnote_lt WITH KEY
        tab = control_ls-sctable
        doctype = control_ls-scactdoctype
      INTO tabdocnote_ls .
      IF sy-subrc <> 0. "no a-prio criterion passed
        CONTINUE.
      ENDIF.
    ELSEIF control_ls-scprio = 'C'.
      CONTINUE.
    ENDIF. "control_ls = 'B'

    CASE control_ls-sctype.
      WHEN 'S' OR 'D' OR 'N'.
*     READ SELECTION-CRITERIONS FOR ENTRY (ONLY S,D or N)
*     >> RANGE-TABLES
        IF control_ls-scprio = 'A'.
          READ TABLE tabdocnote_lt WITH KEY
            tab = control_ls-sctable
            doctype = control_ls-scactdoctype
          INTO tabdocnote_ls .
          IF sy-subrc <> 0. "new a-prio has to be entered
            tabdocnote_ls-tab = control_ls-sctable.
            tabdocnote_ls-doctype = control_ls-scactdoctype.
            APPEND tabdocnote_ls TO tabdocnote_lt.
          ENDIF. "sy-subrc
        ENDIF. "control_ls-scprio = 'A'.
*       LOOP OVER CRITERION TABLE & PROCESS CRITERION-DATA
        LOOP AT allsel_lt INTO rangeline_ls
          WHERE selname = control_ls-scinterfacefield.

          CALL FUNCTION 'DDIF_FIELDINFO_GET'    "N:1449767
            EXPORTING
              tabname        = control_ls-sctable
              all_types      = 'X'
            TABLES
              dfies_tab       = lt_dfies
            EXCEPTIONS
              not_found      = 1
              internal_error = 2
              OTHERS         = 3.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          READ TABLE lt_dfies
                    WITH KEY fieldname = control_ls-sctablefield
                    INTO ls_dfies.

          typelen_lv = ls_dfies-leng.
*ENDIF.

          CLEAR crit_ls.
          crit_ls-tab = control_ls-sctable.
          crit_ls-qual = control_ls-sctablefield.
          crit_ls-sign = rangeline_ls-sign.
          crit_ls-option = rangeline_ls-option.
          crit_ls-doctype = control_ls-scactdoctype.
*         _______________________
*         S- OR N-CRITERION
*         >> SIMPLE RANGE-TABLE
          IF control_ls-sctype = 'S' OR control_ls-sctype = 'N'.
            CASE crit_ls-option.
              WHEN 'EQ' OR 'NE' OR 'GE' OR 'GT'
                    OR 'LE' OR 'LT' OR 'CP' OR 'NP'.
                crit_ls-low = rangeline_ls-low.
                IF control_ls-sctype = 'N'.
                  len_lv = strlen( crit_ls-low ).
                  len_lv = typelen_lv - len_lv.
                  IF crit_ls-low NA '*'.
                    DO len_lv  TIMES.
                      CONCATENATE '0' crit_ls-low INTO crit_ls-low.
                    ENDDO.
                  ENDIF. "NA *
                ENDIF.                 "control_ls-option = 'N'
              WHEN 'BT' OR 'NB'.
                pos_lv = 3 + typelen_lv.
                crit_ls-low = rangeline_ls-low.
                crit_ls-high = rangeline_ls-high.
                IF control_ls-sctype = 'N'.
                  len_lv = strlen( crit_ls-low ).
                  len_lv = typelen_lv - len_lv.
                  IF crit_ls-low NA '*'.
                    DO len_lv  TIMES.
                      CONCATENATE '0' crit_ls-low INTO crit_ls-low.
                    ENDDO.
                  ENDIF. "NA *
                  len_lv = strlen( crit_ls-high ).
                  len_lv = typelen_lv - len_lv.
                  IF crit_ls-low NA '*'.
                    DO len_lv  TIMES.
                      CONCATENATE '0' crit_ls-high INTO crit_ls-high.
                    ENDDO.
                  ENDIF. "NA *
                ENDIF.                 "control_ls-option = 'N'

              WHEN OTHERS.
                "error on subscreen, no select-options definition
                APPEND control_ls TO et_contrerror.
                EXIT.
            ENDCASE.
*         _______________________
*          D- CRITERION (consider time/timezone, build timestamp)
*          >> RANGE-TABLE AND CORRESPONDING TIME-FIELDS
          ELSEIF control_ls-sctype = 'D'.
*         _____ DETERMINE STARTTIME
            READ TABLE control_lt WITH KEY
               sctable = crit_ls-tab
               sctablefield = crit_ls-qual
               sctype = 'L'
               INTO control2_ls.
            IF sy-subrc <> 0.
              IF crit_ls-option = 'LE'.
                timl_lv = '235959'.
              ELSE.
                timl_lv = '000000'.
              ENDIF.
            ELSE.
              timlnam_lv = control2_ls-scinterfacefield.
              READ TABLE allsel_lt
                WITH KEY selname = timlnam_lv
                INTO time_ls.
              IF sy-subrc <> 0.
                timl_lv = '000000'.
                APPEND control2_ls TO et_contrerror.
              ELSE.
                timl_lv = time_ls-low.
              ENDIF.
            ENDIF.
            IF timl_lv = ''.
              timl_lv = '00000'.
            ENDIF.                     "timhnam_lv is inital
*          _____ DETERMINE ENDTIME
            READ TABLE control_lt WITH KEY
              sctable = crit_ls-tab sctablefield = crit_ls-qual
              sctype = 'H'
              INTO control2_ls.
            IF sy-subrc <> 0.
              timh_lv = '235959'.
            ELSE.
              timhnam_lv = control2_ls-scinterfacefield.
              READ TABLE allsel_lt
                WITH KEY selname = timhnam_lv
                INTO time_ls.
              IF sy-subrc <> 0.
                timh_lv = '235959'.
                APPEND control2_ls TO et_contrerror.
              ELSE.
                timh_lv = time_ls-low.
              ENDIF.                   "sy-subrc
            ENDIF.                     "sy-subrc
            IF timh_lv = ''.
              timh_lv = '235959'.
            ENDIF.                     "timhnam_lv is inital
*          _____ BUILD CRITERION
            CASE crit_ls-option.
              WHEN 'EQ'.
                datl_lv = rangeline_ls-low.
                dath_lv = datl_lv.
                critoption_lv = 'BT'.
              WHEN  'NE'.
                datl_lv = rangeline_ls-low.
                dath_lv = datl_lv.
                critoption_lv = 'NB'.
              WHEN 'BT' OR 'NB'.
                pos_lv = 3 + typelen_lv.
                datl_lv = rangeline_ls-low.
                dath_lv = rangeline_ls-high.
                critoption_lv = crit_ls-option.
              WHEN 'GT' OR 'LE' OR 'LT' OR 'GE'.
                datl_lv = rangeline_ls-low.
                dath_lv = datl_lv.
                critoption_lv = crit_ls-option.
              WHEN 'CP'.
                MESSAGE ID 'VELO' TYPE 'E' NUMBER '314'
                WITH crit_ls-option RAISING controlerror.
              WHEN 'NP'.
                MESSAGE ID 'VELO' TYPE 'E' NUMBER '314'
                WITH crit_ls-option RAISING controlerror.
              WHEN OTHERS.
*               error on subscreen, no select-options definition
                APPEND control_ls TO et_contrerror.
            ENDCASE.

            crit_ls-option = critoption_lv.

            CALL FUNCTION 'VELO03_CONVERT_INTO_TIMESTAMP'
              EXPORTING
                datlo_iv           = datl_lv
                timlo_iv           = timl_lv
*               TZONE_IV           = SY-ZONLO
             IMPORTING
               timestamp_ev       = tstpl_lv.

            crit_ls-low = tstpl_lv.

            CALL FUNCTION 'VELO03_CONVERT_INTO_TIMESTAMP'
              EXPORTING
                datlo_iv           = dath_lv
                timlo_iv           = timh_lv
*               TZONE_IV           = SY-ZONLO
             IMPORTING
               timestamp_ev       = tstph_lv.

            crit_ls-high = tstph_lv.
          ENDIF. "control_ls-sctype = 'S' OR control_ls-sctype = 'N'
*         _______________________
*         APPEND TO EXPORT TABLE
          SHIFT crit_ls-low LEFT DELETING LEADING space.
          IF NOT ( crit_ls-high IS INITIAL ).
            SHIFT crit_ls-high LEFT DELETING LEADING space.
          ENDIF.
          APPEND crit_ls TO et_vlcextcrit.
        ENDLOOP. "AT ALLSEL_LT INTO rangeline_ls.
*       END OF LOOP OVER CRITERION TABLE & PROCESS CRITERION-DATA
      WHEN 'P'.
*       READ SELECTION-CRITERIONS FOR ENTRY (ONLY P)
*       >> SIMPLE PARAMETER-FIELD
*       _______________________________________________________
*        ASSIGN FIELD
        READ TABLE allsel_lt
          WITH KEY selname = control_ls-scinterfacefield
          INTO rangeline_ls.
*       _______________________________________________________
*         PROCESS FILLED FIELD
        CLEAR crit_ls.
        crit_ls-tab = control_ls-sctable.
        crit_ls-qual = control_ls-sctablefield.
        crit_ls-sign = 'I'.
        IF  rangeline_ls-low CA '*+'.
          crit_ls-option = 'CP'.
        ELSE.
          crit_ls-option = 'EQ'.
        ENDIF.
        crit_ls-low = rangeline_ls-low.
        crit_ls-doctype = control_ls-scactdoctype.

        SHIFT crit_ls-low LEFT DELETING LEADING space.
        APPEND crit_ls TO et_vlcextcrit.
*       NOTE A PROCESSED A-PRIORITY-CRITERION
        IF control_ls-scprio = 'A'.

          READ TABLE tabdocnote_lt WITH KEY
            tab = control_ls-sctable
            doctype = control_ls-scactdoctype
          INTO tabdocnote_ls .

          IF sy-subrc <> 0. "new a-prio has to be entered
            tabdocnote_ls-tab = control_ls-sctable.
            tabdocnote_ls-doctype = control_ls-scactdoctype.
            APPEND tabdocnote_ls TO tabdocnote_lt.
          ENDIF. "sy-subrc
        ENDIF. "control_ls-scprio = 'A'.
      WHEN 'C'.
*       READ SELECTION-CRITERIONS FOR ENTRY (ONLY C)
*       >> NUMERIC PARAMETER-FIELD

        READ TABLE allsel_lt
          WITH KEY selname = control_ls-scinterfacefield
          INTO rangeline_ls.

        CLEAR crit_ls.
        crit_ls-tab = control_ls-sctable.
        crit_ls-qual = control_ls-sctablefield.
        crit_ls-sign = 'I'.
        IF  rangeline_ls-low CA '*+'.
          crit_ls-option = 'CP'.
        ELSE.
          crit_ls-option = 'EQ'.
        ENDIF.
        crit_ls-low = rangeline_ls-low.
        crit_ls-doctype = control_ls-scactdoctype.
*       determine the length of the field
        CALL FUNCTION 'DDIF_FIELDINFO_GET'    "N:1449767
          EXPORTING
            tabname        = control_ls-sctable   "N:1486828
            all_types      = 'X'
          TABLES
            dfies_tab       = lt_dfies
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        CLEAR ls_dfies.
        READ TABLE lt_dfies
          WITH KEY fieldname = control_ls-sctablefield
          INTO ls_dfies.

        typelen_lv = ls_dfies-leng.

        IF typelen_lv > 0.
          len_lv = strlen( crit_ls-low ).
          len_lv = typelen_lv - len_lv.
          IF crit_ls-low NA '*'.
            DO len_lv  TIMES.
              CONCATENATE '0' crit_ls-low INTO crit_ls-low.
            ENDDO.
          ENDIF. "NA *

          APPEND crit_ls TO et_vlcextcrit.
*         NOTE A PROCESSED A-PRIORITY-CRITERION
          IF control_ls-scprio = 'A'.
            READ TABLE tabdocnote_lt WITH KEY
              tab = control_ls-sctable
              doctype = control_ls-scactdoctype
            INTO tabdocnote_ls .

            IF sy-subrc <> 0. "new a-prio has to be entered
              tabdocnote_ls-tab = control_ls-sctable.
              tabdocnote_ls-doctype = control_ls-scactdoctype.
              APPEND tabdocnote_ls TO tabdocnote_lt.
            ENDIF. "sy-subrc
          ENDIF. "control_ls-scprio = 'A'.
        ENDIF.                                     "typelen_lv


      WHEN 'X'.
*       READ CONSTANT-CRITERIONS FOR ENTRY (ONLY X)
*       >> CONSTANT FIELD
        READ TABLE allsel_lt
          WITH KEY selname = control_ls-scinterfacefield
          INTO rangeline_ls.

        CLEAR crit_ls.
        crit_ls-tab = control_ls-sctable.
        crit_ls-qual = control_ls-sctablefield.
        crit_ls-sign = 'I'.
        crit_ls-option = 'EQ'.
        crit_ls-low = rangeline_ls-low.
        crit_ls-doctype = control_ls-scactdoctype.

        APPEND crit_ls TO et_vlcextcrit.
*       _______________________________________________________
*         NOTE A PROCESSED A-PRIORITY-CRITERION
        IF control_ls-scprio = 'A'.
          READ TABLE tabdocnote_lt WITH KEY
            tab = control_ls-sctable
            doctype = control_ls-scactdoctype
          INTO tabdocnote_ls .

          IF sy-subrc <> 0. "new a-prio has to be entered
            tabdocnote_ls-tab = control_ls-sctable.
            tabdocnote_ls-doctype = control_ls-scactdoctype.
            APPEND tabdocnote_ls TO tabdocnote_lt.
          ENDIF. "sy-subrc
        ENDIF. "control_ls-scprio = 'A'.
      WHEN 'H' OR 'L'.
*       H and L CRITERION ARE NOT INDEPENDENT CRITERIONS:
*       THEY ARE PROCESSED TOGETHER WITH THE CORRESPONDING D-CRITERION
      WHEN OTHERS.
        APPEND control_ls TO et_contrerror.
    ENDCASE.
  ENDLOOP.                             " at control_lt
* END OF LOOP OVER ENTRIES IN SEARCH CONTROL

* --------------------------------------------------------------
* ERROR-HANDLING
* --------------------------------------------------------------
  IF NOT ( et_contrerror[] IS INITIAL ).
    READ TABLE et_contrerror INDEX 1 INTO id1.
    CONDENSE id1.
    READ TABLE et_contrerror INDEX 2 INTO id2.
    CONDENSE id2.
    READ TABLE et_contrerror INDEX 3 INTO id3.
    CONDENSE id3.
    READ TABLE et_contrerror INDEX 4 INTO id4.
    CONDENSE id4.
    MESSAGE ID 'VELO' TYPE 'E' NUMBER '160' RAISING controlerror.
  ENDIF.           "( et_contrerror[] IS INITIAL )

ENDFUNCTION.

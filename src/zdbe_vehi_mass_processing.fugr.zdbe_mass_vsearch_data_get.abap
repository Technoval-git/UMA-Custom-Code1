FUNCTION ZDBE_MASS_VSEARCH_DATA_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      VLCVEHICRIT_ET TYPE  VLCH_SEARCHCRIT_PT OPTIONAL
*"      CONTRERROR_ET STRUCTURE  VLCSEARCHCONTROL OPTIONAL
*"  EXCEPTIONS
*"      CONTROLERROR
*"      BADI_IMPLEMENTATION_ERROR
*"--------------------------------------------------------------------
*
* This is a copy of VELO02 FM and determines which
* fields are filled out for searching (based on VMS customizing)
* and fills out search critiria structure
*
* --------------------------------------------------------------
* DATA DECLARATION
* --------------------------------------------------------------

  DATA: control_ls  TYPE vlcsearchcontrol,
        control2_ls LIKE control_ls,
        control_lt  TYPE vlcsearchcontrol_t.

  DATA: critname_lv   TYPE string,
        critlength_lv TYPE i,
        typelen_lv    TYPE i,
        pos_lv        TYPE i,
        len_lv        TYPE i,
        lines_lv      TYPE i,
        crit_ls       TYPE vlch_searchcrit_ps.

  DATA: timlnam_lv    TYPE string,
        timhnam_lv    TYPE string,
        datl_lv       LIKE sy-datlo,
        dath_lv       LIKE sy-datlo,
        timl_lv       LIKE sy-timlo,
        timh_lv       LIKE sy-timlo,
        tstpl_lv      LIKE tzonref-tstamps,
        tstph_lv      LIKE tzonref-tstamps,
        critoption_lv LIKE crit_ls-option.

  DATA: id1 TYPE string,
        id2 LIKE id1, id3 LIKE id1, id4 LIKE id1.

  TYPES: BEGIN OF tabdoc_ps,
           tab     TYPE vlc_tabname,
           doctype TYPE vlc_actdoctype,
         END OF  tabdoc_ps.
  DATA: tabdocnote_ls     TYPE tabdoc_ps,
        tabdocnote_lt     TYPE TABLE OF tabdoc_ps,
        lo_abap_typedescr TYPE REF TO cl_abap_typedescr.    "N:3412049

  FIELD-SYMBOLS: <crittable_lv> TYPE ANY TABLE,
                 <rangeline_lv> TYPE any.

  FIELD-SYMBOLS: <tim1_lv> LIKE timl_lv,
                 <tim2_lv> LIKE timh_lv.

  FIELD-SYMBOLS: <low_lv>  TYPE any,
                 <high_lv> TYPE any.



* --------------------------------------------------------------
* INIT, BADI INSTANCE
* --------------------------------------------------------------

  REFRESH contrerror_et.
  REFRESH vlcvehicrit_et.
  CLASS cl_exithandler DEFINITION LOAD.

* --------------------------------------------------------------
* READ TABLE "SEARCH CONTROL" AND LOOP OVER TABLE
* OF ENTRIES IN "SEARCH CONTROL"
* --------------------------------------------------------------
  CALL FUNCTION 'VELO14_READ_SEARCHCONTROL'
    TABLES
      control_et       = control_lt
    EXCEPTIONS
      no_entries_found = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID 'VELO' TYPE 'E' NUMBER '196' RAISING controlerror.
  ENDIF.

  SORT control_lt BY sctable scactdoctype scprio ASCENDING.
  REFRESH tabdocnote_lt.

  LOOP AT control_lt INTO control_ls.

* --------------------------------------------------------------
* PROCESS SINGLE ENTRY
* --------------------------------------------------------------

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
*    ===============================================================
*     READ SELECTION-CRITERIONS FOR ENTRY (ONLY S,D or N)
*     >> RANGE-TABLES
*    ===============================================================
*       _______________________________________________________
*       ASSIGN RANGE-TABLE (ONLY S,D or N)

        CONCATENATE control_ls-scinterfacefield '[]' INTO critname_lv.
        ASSIGN (critname_lv) TO <crittable_lv>.
        IF sy-subrc <> 0.
          CONTINUE. "no such select-option on VMS-interface
        ENDIF.                         "sy-subrc <> 0.
*       _______________________________________________________
*       CHECK FILLING OF TABLE
        DESCRIBE TABLE <crittable_lv> LINES lines_lv.
        IF lines_lv = 0.
          CONTINUE.
        ELSE.
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
        ENDIF. "length_lv=0
*       _______________________________________________________
*       LOOP OVER CRITERION TABLE & PROCESS CRITERION-DATA
        LOOP AT <crittable_lv> ASSIGNING <rangeline_lv>.

          ASSIGN COMPONENT 'LOW' OF STRUCTURE <rangeline_lv>
                  TO <low_lv>.
          ASSIGN COMPONENT 'HIGH' OF STRUCTURE <rangeline_lv>
                  TO <high_lv>.
          DESCRIBE FIELD <low_lv> OUTPUT-LENGTH typelen_lv.

          CLEAR crit_ls.
          crit_ls-tab = control_ls-sctable.
          crit_ls-qual = control_ls-sctablefield.
          crit_ls-sign = <rangeline_lv>+0(1).
          crit_ls-option = <rangeline_lv>+1(2).
          crit_ls-doctype = control_ls-scactdoctype.
*         _______________________
*         S- OR N-CRITERION
*         >> SIMPLE RANGE-TABLE
          IF control_ls-sctype = 'S' OR control_ls-sctype = 'N'.

            CASE crit_ls-option.
              WHEN 'EQ' OR 'NE' OR 'GE' OR 'GT'
                    OR 'LE' OR 'LT' OR 'CP' OR 'NP'.
                crit_ls-low = <low_lv>.
*                CONDENSE crit_ls-low NO-GAPS.
                IF control_ls-sctype = 'N'.
                  len_lv = typelen_lv - strlen( crit_ls-low ).
                  IF crit_ls-low NA '*'.
                    DO len_lv  TIMES.
                      CONCATENATE '0' crit_ls-low INTO crit_ls-low.
                    ENDDO.
                  ENDIF. "NA *
                ENDIF.                 "control_ls-option = 'N'

              WHEN 'BT' OR 'NB'.
                pos_lv = 3 + typelen_lv.
                crit_ls-low = <low_lv>.
                crit_ls-high = <high_lv>.
*                CONDENSE crit_ls-low NO-GAPS.
*                CONDENSE crit_ls-high NO-GAPS.
                IF control_ls-sctype = 'N'.
                  len_lv = typelen_lv - strlen( crit_ls-low ).
                  IF crit_ls-low NA '*'.
                    DO len_lv  TIMES.
                      CONCATENATE '0' crit_ls-low INTO crit_ls-low.
                    ENDDO.
                  ENDIF. "NA *
                  len_lv = typelen_lv - strlen( crit_ls-high ).
                  IF crit_ls-low NA '*'.
                    DO len_lv  TIMES.
                      CONCATENATE '0' crit_ls-high INTO crit_ls-high.
                    ENDDO.
                  ENDIF. "NA *
                ENDIF.                 "control_ls-option = 'N'

              WHEN OTHERS.
                "error on subscreen, no select-options definition
                APPEND control_ls TO contrerror_et.
                EXIT.
            ENDCASE.
*         _______________________
*          D- CRITERION (consider time/timezone, build timestamp)
*          >> RANGE-TABLE AND CORRESPONDING TIME-FIELDS
          ELSEIF control_ls-sctype = 'D'.
*         _____ DETERMINE STARTTIME
            READ TABLE control_lt WITH KEY
               sctable = crit_ls-tab sctablefield = crit_ls-qual
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
              ASSIGN (timlnam_lv) TO <tim1_lv>.
              IF sy-subrc <> 0.
                timl_lv = '000000'.
                APPEND control2_ls TO contrerror_et.
              ELSE.
                timl_lv = <tim1_lv>.
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
              ASSIGN (timhnam_lv) TO <tim2_lv>.
              IF sy-subrc <> 0.
                timh_lv = '235959'.
                APPEND control2_ls TO contrerror_et.
              ELSE.
                timh_lv = <tim2_lv>.
              ENDIF.                   "sy-subrc
            ENDIF.                     "sy-subrc
            IF timh_lv = ''.
              timh_lv = '235959'.
            ENDIF.                     "timhnam_lv is inital

*          _____ BUILD CRITERION

            CASE crit_ls-option.
              WHEN 'EQ'.
                datl_lv = <low_lv>.
                dath_lv = datl_lv.
                critoption_lv = 'BT'.
              WHEN  'NE'.
                datl_lv = <low_lv>.
                dath_lv = datl_lv.
                critoption_lv = 'NB'.
              WHEN 'BT' OR 'NB'.
                pos_lv = 3 + typelen_lv.
                datl_lv = <low_lv>.
                dath_lv = <high_lv>.
                critoption_lv = crit_ls-option.
              WHEN 'GT' OR 'LE' OR 'LT' OR 'GE'.
                datl_lv = <low_lv>.
                dath_lv = datl_lv.
                critoption_lv = crit_ls-option.
              WHEN 'CP'.
                MESSAGE ID 'VELO' TYPE 'E' NUMBER '314'
                  WITH crit_ls-option RAISING controlerror.
              WHEN 'NP'.
                MESSAGE ID 'VELO' TYPE 'E' NUMBER '314'
                  WITH crit_ls-option RAISING controlerror.
              WHEN OTHERS.
                APPEND control_ls TO contrerror_et.
            ENDCASE.

            crit_ls-option = critoption_lv.

* N:3412049 {
            lo_abap_typedescr = cl_abap_typedescr=>describe_by_data( p_data = <low_lv> ).
            IF lo_abap_typedescr->type_kind = cl_abap_typedescr=>typekind_date.
              "If the field is the the date, then we do not want to convert it into timestamp, we pass it to the search engine as it is
              crit_ls-low  = datl_lv.
              crit_ls-high = dath_lv.
            ELSE.
              "In other cases we convert it to the timestamps as before
* N:3412049 }

              CALL FUNCTION 'VELO03_CONVERT_INTO_TIMESTAMP'
                EXPORTING
                  datlo_iv     = datl_lv
                  timlo_iv     = timl_lv
*                 TZONE_IV     = SY-ZONLO
                IMPORTING
                  timestamp_ev = tstpl_lv.

              crit_ls-low = tstpl_lv.

              CALL FUNCTION 'VELO03_CONVERT_INTO_TIMESTAMP'
                EXPORTING
                  datlo_iv     = dath_lv
                  timlo_iv     = timh_lv
*                 TZONE_IV     = SY-ZONLO
                IMPORTING
                  timestamp_ev = tstph_lv.

              crit_ls-high = tstph_lv.
            ENDIF.                                          "N:3412049
          ENDIF. "control_ls-sctype = 'S' OR control_ls-sctype = 'N'
*         _______________________
*         APPEND TO EXPORT TABLE
          SHIFT crit_ls-low LEFT DELETING LEADING space.
          IF NOT ( crit_ls-high IS INITIAL ).
            SHIFT crit_ls-high LEFT DELETING LEADING space.
          ENDIF.
          APPEND crit_ls TO vlcvehicrit_et.
          IF sy-subrc <> 0.
            APPEND control_ls TO contrerror_et.
            CONTINUE.
          ENDIF. "sy-subrc <> 0
        ENDLOOP. "AT <crittable_lv> ASSIGNING <rangeline_lv>.
*       _______________________________________________________
*       END OF LOOP OVER CRITERION TABLE & PROCESS CRITERION-DATA
      WHEN 'P'.
*    ===============================================================
*     READ SELECTION-CRITERIONS FOR ENTRY (ONLY P)
*     >> SIMPLE PARAMETER-FIELD
*    ===============================================================
*       _______________________________________________________
*        ASSIGN FIELD
        ASSIGN (control_ls-scinterfacefield) TO <rangeline_lv>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF. "sy-subrc <> 0
*       _______________________________________________________
*         PROCESS FILLED FIELD
        IF NOT <rangeline_lv> IS INITIAL.
          CLEAR crit_ls.
          crit_ls-tab = control_ls-sctable.
          crit_ls-qual = control_ls-sctablefield.
          crit_ls-sign = 'I'.
          IF  <rangeline_lv> CA '*+'.
            crit_ls-option = 'CP'.
          ELSE.
            crit_ls-option = 'EQ'.
          ENDIF.
          crit_ls-low = <rangeline_lv>.
          crit_ls-doctype = control_ls-scactdoctype.
          SHIFT crit_ls-low LEFT DELETING LEADING space.
          APPEND crit_ls TO vlcvehicrit_et.
          IF sy-subrc <> 0.
            APPEND control_ls TO contrerror_et.
            CONTINUE.
          ENDIF. "sy-subrc <> 0
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
        ENDIF.
      WHEN 'C'.
*    ===============================================================
*     READ SELECTION-CRITERIONS FOR ENTRY (ONLY C)
*     >> NUMERIC PARAMETER-FIELD
*    ===============================================================
*       _______________________________________________________
*        ASSIGN FIELD
        ASSIGN (control_ls-scinterfacefield) TO <rangeline_lv>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF. "sy-subrc <> 0
        CLEAR crit_ls.
        crit_ls-tab = control_ls-sctable.
        crit_ls-qual = control_ls-sctablefield.
        crit_ls-sign = 'I'.
        IF  <rangeline_lv> CA '*+'.
          crit_ls-option = 'CP'.
        ELSE.
          crit_ls-option = 'EQ'.
        ENDIF.
        crit_ls-low = <rangeline_lv>.
        crit_ls-doctype = control_ls-scactdoctype.
*       _______________________________________________________
*        PROCESS FILLED FIELD
        DESCRIBE FIELD <rangeline_lv> LENGTH typelen_lv
          IN CHARACTER MODE.
        IF typelen_lv > 0.
          len_lv = strlen( crit_ls-low ).
          len_lv = typelen_lv - len_lv.
          IF crit_ls-low NA '*'.
            DO len_lv  TIMES.
              CONCATENATE '0' crit_ls-low INTO crit_ls-low.
            ENDDO.
          ENDIF. "NA *
          APPEND crit_ls TO vlcvehicrit_et.
          IF sy-subrc <> 0.
            APPEND control_ls TO contrerror_et.
            CONTINUE.
          ENDIF. "sy-subrc <> 0
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
        ENDIF.                                              "typelen_lv
      WHEN 'X'.
*    ===============================================================
*     READ CONSTANT-CRITERIONS FOR ENTRY (ONLY X)
*     >> CONSTANT FIELD
*    ===============================================================
*       _______________________________________________________
*        ASSIGN FIELD
        ASSIGN (control_ls-scinterfacefield) TO <rangeline_lv>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF. "sy-subrc <> 0

        CLEAR crit_ls.
        crit_ls-tab = control_ls-sctable.
        crit_ls-qual = control_ls-sctablefield.
        crit_ls-sign = 'I'.
        crit_ls-option = 'EQ'.
        crit_ls-low = <rangeline_lv>.
        crit_ls-doctype = control_ls-scactdoctype.
*       _______________________________________________________
*        PROCESS FILLED FIELD
        APPEND crit_ls TO vlcvehicrit_et.
        IF sy-subrc <> 0.
          APPEND control_ls TO contrerror_et.
          CONTINUE.
        ENDIF. "sy-subrc <> 0
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
*    ===============================================================
*     H and L CRITERION ARE NOT INDEPENDENT CRITERIONS:
*     THEY ARE PROCESSED TOGETHER WITH THE CORRESPONDING D-CRITERION
*    ===============================================================
      WHEN OTHERS.
*    ===============================================================
*     NOT SUPPORTED TYPEs
*    ===============================================================
        APPEND control_ls TO contrerror_et.
    ENDCASE.
  ENDLOOP.                             " at control_lt
* END OF LOOP OVER ENTRIES IN SEARCH CONTROL

* --------------------------------------------------------------
* ERROR-HANDLING
* --------------------------------------------------------------
  IF NOT ( contrerror_et[] IS INITIAL ).
    READ TABLE contrerror_et INDEX 1 INTO id1.
    CONDENSE id1.
    READ TABLE contrerror_et INDEX 2 INTO id2.
    CONDENSE id2.
    READ TABLE contrerror_et INDEX 3 INTO id3.
    CONDENSE id3.
    READ TABLE contrerror_et INDEX 4 INTO id4.
    CONDENSE id4.
    MESSAGE ID 'VELO' TYPE 'E' NUMBER '160' RAISING controlerror.
  ENDIF.                               "( contrerror_et[] IS INITIAL )

ENDFUNCTION.

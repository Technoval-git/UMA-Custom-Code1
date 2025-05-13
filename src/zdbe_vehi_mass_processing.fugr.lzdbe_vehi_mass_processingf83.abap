*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF83 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_TASK_END
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_task_end .

  DATA lv_mssg(80).                                         "#EC NEEDED

* Receiving task results
  RECEIVE RESULTS FROM FUNCTION 'RFC_PING_AND_WAIT'
    EXCEPTIONS
      resource_failure      = 1
      communication_failure = 2  MESSAGE lv_mssg
      system_failure        = 3  MESSAGE lv_mssg
      OTHERS                = 4.

  CHECK sy-subrc EQ 0.
  SET USER-COMMAND '&NTE'.             " Refresh

ENDFORM.                    " F_TASK_END

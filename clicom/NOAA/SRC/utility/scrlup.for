$STORAGE:2

      SUBROUTINE SCRLUP(ISIZE,NUMSCROLL)
C
C   DETERMINE IF ISIZE LINES WILL FIT ONTO THE SCREEN - WITH THE
C     THREE MESSAGE LINES AT THE BOTTOM
C          - SCROLL UP IF THERE IS NOT ENOUGH ROOM
C
      INTEGER*2 ISIZE,NUMSCROLL

      CALL POSLIN(IROW,ICOL)
      ILAST = IROW + ISIZE  
      NUMSCROLL = 0
      IF (ILAST.GE.22) THEN
         NUMSCROLL = ILAST - 22 + 1
         CALL SCROLL(1,NUMSCROLL,0,0,23,79)
      END IF
      RETURN
      END


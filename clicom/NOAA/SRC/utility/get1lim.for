$STORAGE:2

      SUBROUTINE GET1LIM(STNWANTED,STRTYRMO,ENDYRMO,FILNAME,RTNCODE)
C
C   SUBROUTINE TO SOLICIT A STATION AND RANGE OF YR/MONS TO BE PROCESSED
C       THE ROUTINE ASKS THE USER TO SUPPLY THE INFORMATION AND READS IT
C       FROM THE KEYBOARD BY CALLING ROUTINE GETFRM. 
C
      CHARACTER*64 FILNAME
      CHARACTER*8 STNWANTED
      INTEGER*4 STRTYRMO, ENDYRMO
      CHARACTER*1 RTNCODE
      CHARACTER*2 RTNFLAG
C
C   VARIABLES TO CONTROL THE INPUT FORM
C     
      CHARACTER*10 FIELD(5)
      FIELD(1) = '       '
      FIELD(2) = '    '
      FIELD(3) = '  '
      FIELD(4) = '    '
      FIELD(5) = '  '
      RTNCODE = '0'
      CALL POSLIN(IROW,ICOL)
C
C   BUILD AND READ THE DATA ENTRY FORM 
C
   40 CONTINUE
      CALL LOCATE(IROW,ICOL,IERR)
      RTNFLAG = 'SS'
      CALL GETFRM('GET1LIM ',FILNAME,FIELD,10,RTNFLAG)
      CALL POSLIN(IROW,IERR)
      IF (RTNFLAG.EQ.'4F') THEN
         RTNCODE = '1'
         RETURN
      END IF
C
C   CHECK THE INPUT DATA 
C
      STNWANTED = FIELD(1)
      READ(FIELD(2),'(I4)') IYEAR
      READ(FIELD(3),'(I2)') IMON
      RYEAR = IYEAR
      RMON = IMON
      RYRMON = RYEAR*100. + RMON
      STRTYRMO = INT4(RYRMON)
      READ(FIELD(4),'(I4)') IYEAR
      READ(FIELD(5),'(I2)') IMON
      RYEAR = IYEAR
      RMON = IMON
      RYRMON = RYEAR*100. + RMON
      ENDYRMO = INT4(RYRMON)
      IF (ENDYRMO.LT.STRTYRMO) THEN
         CALL WRTMSG(3,71,12,1,0,' ',0)
         GO TO 40
      END IF
      IROW = IROW + 7 
      CALL LOCATE(IROW,1,IERR) 
C
      RETURN
      END

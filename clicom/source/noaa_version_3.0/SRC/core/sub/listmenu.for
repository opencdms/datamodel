$storage:2

      SUBROUTINE LISTMENU
C
C   ROUTINE TO LIST THE MENU FILE MENUS IN ALPHABETICAL ORDER  
C
C   LOCAL VARIABLES 
C
      PARAMETER(MAXCHOICE=16,MAXLIN=65) 
      INTEGER*2 WIDTH,NUMCHOICE,FGCOLOR,BGCOLOR,HDRFGC,HDRBGC
     +         ,TLENGTH,CLENGTH,RECNUM(200)
      CHARACTER*60 TITLE
      CHARACTER*32 CHOICE(MAXCHOICE)
      CHARACTER*12 INNAME,HLDNAM(200)
      CHARACTER*1 BORDER,DELMARK,REPLY,RTNCODE
      DATA HLDNAM,RECNUM /200*'        ',200*0/
C
C   ASK FOR VERIFICATION BEFORE CONTINUING
C
      CALL WRTMSG(3,302,12,1,0,' ',0)
      CALL CLRMSG(2)
      CALL LOCATE(23,1,IERR)
      CALL OKREPLY(REPLY,RTNCODE)
      CALL CLRMSG(3)
      CALL CLRMSG(2)        
      IF (REPLY.EQ.'N'.OR.RTNCODE.EQ.'1') THEN
         RETURN
      END IF
C
C   OPEN THE MENU FILE FOR SHARED ACCESS
C
   20 CONTINUE
      OPEN (14,FILE='P:\FORM\USERMENU.DEF',STATUS='OLD',ACCESS='DIRECT'
     +    ,RECL=602,IOSTAT=IOCHK)
      IF(IOCHK.NE.0) THEN
         CALL OPENMSG('P:\FORM\USERMENU.DEF  ','LISTMENU    ',IOCHK)
         GO TO 20
      END IF   
C
C    FIND AND SORT THE CURRENT MENU NAMES
C 
      NUMMENU = 0
      DO 175 IREC = 1,999
         READ(14,REC=IREC,ERR=180) DELMARK,INNAME,TITLE,BORDER
     +       ,(CHOICE(J),J=1,MAXCHOICE),WIDTH,NUMCHOICE
     +       ,HDRFGC,HDRBGC,FGCOLOR,BGCOLOR,TLENGTH,CLENGTH
         IF (DELMARK.EQ.' ') THEN
            NUMMENU = NUMMENU + 1
            IF (NUMMENU.EQ.1) THEN
               HLDNAM(NUMMENU) = INNAME
               RECNUM(NUMMENU) = IREC
            ELSE
               DO 80 I = 1,NUMMENU-1
                  IF (INNAME.LT.HLDNAM(I)) THEN
                     DO 60 I2 = NUMMENU,I+1,-1
                        HLDNAM(I2) = HLDNAM(I2-1)
                        RECNUM(I2) = RECNUM(I2-1)
   60                CONTINUE
                     HLDNAM(I) = INNAME
                     RECNUM(I) = IREC
                     GO TO 90
                  END IF
   80          CONTINUE
               HLDNAM(NUMMENU) = INNAME
               RECNUM(NUMMENU) = IREC
   90          CONTINUE
           END IF
         END IF 
  175 CONTINUE
  180 CONTINUE
C
C   OPEN THE OUTPUT FILE - PRINTER
C
      OPEN(50,FILE='PRN',STATUS='UNKNOWN',FORM='FORMATTED')
C
C   LIST THE MENUS IN ALPHABETICAL ORDER
C
      IPAGE = 1
      ILINE = 3
      WRITE(50,190) 
  190 FORMAT(33X,'CLICOM FORTRAN Program Menus')
      WRITE(50,195) 
  195 FORMAT(11X,72('�')) 
      DO 500 I = 1,NUMMENU
         IREC = RECNUM(I)
         READ(14,REC=IREC) DELMARK,INNAME,TITLE,BORDER
     +          ,(CHOICE(J),J=1,MAXCHOICE),WIDTH,NUMCHOICE
     +          ,HDRFGC,HDRBGC,FGCOLOR,BGCOLOR,TLENGTH,CLENGTH
         ILEN = NUMCHOICE + 6
         IF (ILEN+ILINE.GT.MAXLIN-4) THEN
            DO 200 I2 = ILINE,MAXLIN-3
               WRITE(50,*) ' '
  200       CONTINUE
            WRITE(50,220) IPAGE
  220       FORMAT(40X,'C-',I1)
            WRITE(50,'(1H1)')
            WRITE(50,190) 
            WRITE(50,195) 
            IPAGE = IPAGE + 1
            ILINE = 3
         END IF
         ILINE = ILINE + ILEN
         WRITE (50,300) INNAME,WIDTH,TITLE
  300    FORMAT(/,15X,'Menu Name: ',A12,10X,'Width: ',I2,//
     +         ,20X,A60,/)
         WRITE(50,320) (J,CHOICE(J),J=1,NUMCHOICE)
  320    FORMAT(25X,I2,'.',2X,A32)
         WRITE(50,350)
  350    FORMAT(11X,72('�'))
  500 CONTINUE
      DO 600 I2 = ILINE,MAXLIN-3
         WRITE(50,*) ' '
  600 CONTINUE
      WRITE(50,220) IPAGE
      CLOSE(14)
      CLOSE(50)
      RETURN
      END

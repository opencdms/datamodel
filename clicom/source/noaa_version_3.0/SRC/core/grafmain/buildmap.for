$STORAGE:2
      PROGRAM BUILDMAP
C
C   PROGRAM TO ALLOW THE USER TO SPECIFY AN AREA AND LEVEL OF DETAIL
C   WANTED FOR A MAP.
C
C       ** FILE DESCRIPTIONS:
C             MAPNAMES.IDX   MAPNAMES INDEX FILE -- LIST OF DEFINED MAPS
C               QCMAPS.MPC   MAP LINK FILE -- LIST OF LINKS BETWEEN MAP NAMES
C                            AND THE AREAQC DATATYPE AND DATASET 
C             ________.MPC   MAP DEFINITION FILE -- LATITUDE/LONGITUDE
C                            BOUNDARIES AND DETAIL FOR THE SPECIFIED MAP
C             ________.QSC   MAP SCREEN FILE -- SAVED SCREEN FOR SPECIFIED MAP
C
      INTEGER*4    ICODE
      INTEGER*2    EGAREG(9),IFUNC,MSGLEN(2)
      INTEGER*2    IDUM1,IDUM2(16)
      CHARACTER*1  RTNCODE
      CHARACTER*2  INCHAR,RTNFLAG,YESUP,YESLO
      CHARACTER*8  MAPNAME,SAVNAME
      CHARACTER*12 NAMEXT
      CHARACTER*20 MAPFILE
      CHARACTER*32 MAPDESC
      CHARACTER*41 DESCREC
      CHARACTER*64 FILNAME,MESSAG(2)
      CHARACTER*78 MSGLIN 
      LOGICAL      OLDMAP,WRSPEC
C      LOGICAL      PASS1
C      PASS1 = .TRUE.
C
C   READ THE MESSAGES TO BE DISPLAYED
C 
      CALL GETYN(1,2,YESUP,YESLO)
      CALL GETMSG(217,MSGLIN)
      CALL PARSE1(MSGLIN,78,2,64,MESSAG,RTNCODE)
      CALL GETMSG(218,MSGLIN)
      CALL GETMSG(999,MSGLIN)
      DO 20 IMSG = 1,2
         DO 15 I = 64,1,-1
            IF (MESSAG(IMSG)(I:I).NE.' ') THEN
               MSGLEN(IMSG) = I
               GO TO 20
            END IF
15       CONTINUE
20    CONTINUE
C
      FILNAME = 'P:\HELP\BUILDMAP.HLP'
C
C   OPEN THE QCMAPS -> MAP LINK FILE (P:\DATA\QCMAPS.MPC)
C
30    CONTINUE
      OPEN (41,FILE='P:\DATA\QCMAPS.MPC',STATUS='OLD',ACCESS='DIRECT'
     +    ,RECL=30,IOSTAT=IOCHK)
      IF (IOCHK.NE.0) THEN
         CALL OPENMSG('P:\DATA\QCMAPS.MPC    ','BUILDMAP    ',IOCHK)
         GO TO 30
      END IF
C
C   READ THE EGA COLORS TO BE USED FROM THE DATAQC PARAMETER FILE
C
35    CONTINUE
      OPEN (9,FILE='P:\DATA\DATAQC.PRM',STATUS='OLD',
     +      FORM='FORMATTED',IOSTAT=IOCHK)
      IF (IOCHK.NE.0) THEN
         CALL OPENMSG('P:\DATA\DATAQC.PRM    ','AREAQC      ',IOCHK)
         GO TO 35
      END IF
C
C     SKIP THE LINES WHICH CONTROL COMPUTATION OF MOISTURE VARIABLES 
C     THEN READ IN THE EGA PALETTE COLORS
C
      DO 39 I1 = 1,23
         READ(9,*)
39    CONTINUE
      READ(9,*) (EGAREG(I1),I1=1,9)
      CLOSE(9)
C
C   ASK USER WHAT ACTION THEY WANT TO PERFORM
C
40    CONTINUE
      CALL CLS
      ICOL = 40 - MSGLEN(1)/2
      CALL LOCATE(0,ICOL,IERR)
      CALL WRTSTR(MESSAG(1),MSGLEN(1),11,0)
      CALL LOCATE(2,1,IERR)
      CALL GETMNU('BUILDMAP-FNC',FILNAME,IFUNC)
      IF (IFUNC.EQ.0) THEN
         CALL LOCATE(23,0,IERR)
         CLOSE(41)
         STOP ' '
C
C   IF USER WANTS TO MODIFY THE LINKS BETWEEN DATATYPE-DATASET AND
C   MAPS FOR AREA QC CALL THE QCMAP SUBROUTINE
C
      ELSE IF (IFUNC.EQ.2) THEN
         CALL QCMAP
         GO TO 40
      END IF
C
C   ASK FOR THE MAP NAME OR SELECT FROM LIST OF EXISTING MAPS
C
      CALL WRTFNC(9)
      MAPNAME = '        '
      MAPDESC = ' '
      CALL LOCATE(10,0,IERR)
      CALL WRTSTR(MSGLIN,78,14,0)
70    CONTINUE
      IFUNC = 1
      CALL LOCATE(11,0,IERR)
      CALL WRTSTR(MESSAG(2),MSGLEN(2),14,0)
      CALL WRTSTR(': ',2,14,0)
      CALL GETSTR(0,MAPNAME,8,15,1,RTNFLAG)
C
C    F1 - HELP
C
      IF (RTNFLAG.EQ.'1F') THEN
         CALL DSPWIN(FILNAME)
         GO TO 70
C
C    SHIFT-F1  - BRING UP WINDOW OF POSSIBLE VALUES.  IF THE USER PRESSES
C    F7 IN THAT ROUTINE HE WANTS THAT RECORD DELETED.  THE MAP DEFINITION
C    FILE (.MPC), MAP SCREEN FILE (.QSC), THE INDEX RECORD ARE IMMEDIATELY
C    REMOVED.  SEND A MSG TO USER IF THE .MPC FILE WAS MISSING DURING THE
C    DELETE OPERATION.
C
      ELSE IF (RTNFLAG.EQ.'1S') THEN
75       OPEN (51,FILE='O:\DATA\MAPNAMES.IDX',STATUS='OLD'
     +       ,FORM='BINARY',ACCESS='DIRECT',RECL=43,IOSTAT=IOCHK)
         IF (IOCHK.NE.0) THEN
            CALL OPENMSG('O:\DATA\MAPNAMES.IDX   ','BUILDMAP   ',IOCHK)
            STOP 2
         END IF
C
         DESCREC = ' '
         CALL POSLIN(KROW,KCOL)
         CALL VALWIN(51,DESCREC,41,3,IFLAG)
         CALL LOCATE(KROW,KCOL,KER)
         CLOSE(51)
         MAPNAME = DESCREC(1:8)
         MAPDESC = DESCREC(10:41)
         IF (MAPNAME.EQ.' ') THEN
C             .. NO MAP NAME SELECTED FROM DISPLAYED LIST
            GO TO 70
         ELSE 
            IF (IFLAG.EQ.1) THEN
C                .. REQUEST TO DELETE MAP NAME FROM INDEX FILE; DELETE ENTRY
C                   AND RETURN TO GET ANOTHER MAP NAME   
               RTNCODE='0'
               CALL RDMAP(MAPNAME,MAPFILE,RTNCODE)
               CALL DELMAP(MAPNAME,MAPFILE)
               GO TO 75
             ELSE
C             .. MAP NAME SELECTED FROM DISPLAYED LIST -- IFUNC=2 INDICATES 
C                MAP WAS CHOSEN FROM LIST
               IFUNC = 2
               CALL LOCATE(11,0,IERR)
               CALL WRTSTR(MESSAG(2),MSGLEN(2),14,0)
               CALL WRTSTR(': ',2,14,0)
               CALL WRTSTR(MAPNAME,8,15,1)
            ENDIF
         ENDIF
      ELSE IF (RTNFLAG.EQ.'4F'.OR.MAPNAME.EQ.' ') THEN
         GO TO 40
      ENDIF
C
C   SEE IF THE MAP EXISTS.  IF IT DOES, READ THE MAP DEFINITION FILE.
C   IF THE MAP DOES NOT EXIST BUT WAS IN THE INDEX FILES, REMOVE THE ENTRY 
C   IN THE INDEX FILE AND WRITE AN ERROR MESSAGE TO THE USER.  
C   RTNCODE=1 IMPLIES THE MAP DOES NOT EXIST
C
      CALL RDMAP(MAPNAME,MAPFILE,RTNCODE)
      IF (RTNCODE.EQ.'0') THEN
         OLDMAP = .TRUE.
         READ(40) YLATMN,YLATMX,XLONMN,XLONMX,ICOAST,IBORDER,ISTATE
     +           ,IRIVER,ILAKE
      ELSE
         OLDMAP = .FALSE.
         IF (IFUNC.EQ.2) THEN
C             .. MAP WAS ON THE LIST BUT DOES NOT EXIST -- DELETE LIST ENTRY   
            CALL WRTMSG(4,182,12,0,0,' ',0)
            CALL WRTMSG(3,183,12,1,1,' ',0)
            CALL DELMAP(MAPNAME,MAPFILE)
            GO TO 40
         END IF
      END IF
C
C   INITIALIZE MAP VALUES FOR NEW MAPS
C
      IF (IFUNC.EQ.1) THEN
         IF (.NOT.OLDMAP) THEN
            ICOAST = 1
            IBORDER = 1
            IRIVER = 0
            ILAKE = 0
            ISTATE = 0
            YLATMN = 0.0
            YLATMX = 0.0
            XLONMN = 0.0
            XLONMX = 0.0
         ENDIF
      ENDIF
100   CONTINUE
C
C   RETRIEVE MAP COORDINATES FROM THE USER
C
      RTNFLAG = '  '
      CALL MAPCOORD(12,YLATMN,YLATMX,XLONMN,XLONMX,RTNFLAG)
      IF (RTNFLAG.EQ.'4F') THEN
         IF (OLDMAP) CLOSE(40)
         GO TO 40
      END IF
      IF (.NOT.OLDMAP .AND. (XLONMN.LE.-65.AND.YLATMN.GE.25.)) THEN
          ISTATE = 1
      END IF
C      
C   SET HALO GRAPHICS ENVIRONMENT 
C
      CALL BGNHALO(10,IDUM1,IDUM2)      
      CALL BGNQCMAP(XLONMN,YLATMN,XLONMX,YLATMX,XKWMX,YKWMX)
C
      CALL INQCRA(MAXCLR)
      CALL SETCOL(MAXCLR)
      CALL SETXPA(8,EGAREG(8))
      CALL SETXPA(9,EGAREG(9))
      CALL KWBORD
C
C   DRAW THE MAP OUTLINES REQUESTED
C
      IF (ICOAST.GT.0) THEN
         ICODE = 1
         CALL SETCOL(11)
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
      END IF
      IF (IBORDER.GT.0) THEN
         ICODE = 3
         CALL SETCOL(15)
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
      END IF
      IF (ISTATE.GT.0) THEN
         ICODE = 5
         CALL SETCOL(12)
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
      END IF
      IF (IRIVER.GT.0) THEN
         ICODE = 2
         CALL SETCOL(14)
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
      END IF
      IF (ILAKE.GT.0) THEN
         ICODE = 4
         CALL SETCOL(10)
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
      END IF
C
C   ALLOW THE USERS TO INCLUDE/EXCLUDE MAP DETAIL LEVELS
C      
      XWIN = .05
      YWIN = .95
150   CONTINUE
      CALL GETCHAR(1,INCHAR)
155   CALL GRAFMNU(1,1,XWIN,YWIN,99,INCHAR)
      IF (INCHAR.EQ.'ES') THEN
         CALL CLOSEG
         GO TO 100
      ELSE IF (INCHAR.EQ.'1 ') THEN
         IF (ICOAST.EQ.0) THEN
            ICOAST = 1
            CALL SETCOL(11)
         ELSE
            ICOAST = 0
            CALL SETCOL(0)
         END IF
         ICODE = 1
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
      ELSE IF (INCHAR.EQ.'2 ') THEN
         IF (IRIVER.EQ.0) THEN
            IRIVER = 1
            CALL SETCOL(14)
         ELSE
            IRIVER = 0
            CALL SETCOL(0)
         END IF
         ICODE = 2
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
      ELSE IF (INCHAR.EQ.'3 ') THEN
         IF (IBORDER.EQ.0) THEN
            IBORDER = 1
            CALL SETCOL(15)
         ELSE
            IBORDER = 0            
            CALL SETCOL(0)
         END IF
         ICODE = 3
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
      ELSE IF (INCHAR.EQ.'4 ') THEN
         IF (ILAKE.EQ.0) THEN
            ILAKE = 1
            CALL SETCOL(10)
         ELSE
            ILAKE = 0
            CALL SETCOL(0)
         END IF
         ICODE = 4
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
      ELSE IF (INCHAR.EQ.'5 ') THEN
         IF (ISTATE.EQ.0) THEN
            ISTATE = 1
            CALL SETCOL(12)
         ELSE
            ISTATE = 0
            CALL SETCOL(0)
         END IF
         ICODE = 5
         CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
C
C   SAVE THE CURRENT MAP DEFINITION TO DISK.  FOR AN EXISTING MAP, ASK THE
C   USER IF HE WANTS TO SAVE IT UNDER A NEW NAME AND CHECK NAME ENTERED.
C
      ELSE IF (INCHAR.EQ.'6 ') THEN
 180     CONTINUE
         IF (OLDMAP) THEN
            RTNFLAG = '  '
            CALL GRAFNOTE(0.3,0.9,450,503,' ',0,RTNFLAG)
            IF (RTNFLAG .EQ. 'ES') THEN
               GO TO 155
            ELSE
               IF (RTNFLAG.EQ.YESUP .OR. RTNFLAG.EQ.YESLO) THEN
                  SAVNAME=MAPNAME
                  NCHR = 0
                  CALL GRAFMSG(0.3,0.9,451,527,' ',0,0,8,MAPNAME,NCHR)
                  IF (MAPNAME .EQ. 'ES'. OR. NCHR .LT. 1) THEN
                     MAPNAME=SAVNAME
                     GO TO 180
                  ENDIF
                  CLOSE(40)
                  RTNCODE=' '
                  CALL RDMAP(MAPNAME,MAPFILE,RTNCODE)
C
C-----     THE NEW MAP NAME EXISTS. DOES THE USER WANT TO REPLACE IT ?
C
                  IF (RTNCODE .EQ. '0') THEN
                     CALL GRAFNOTE(0.3,0.9,452,505,' ',0,RTNFLAG)
                     IF (RTNFLAG.NE.YESUP.AND.RTNFLAG.NE.YESLO) THEN
                        GO TO 180
                     ELSE
                        IFUNC = 2
                     ENDIF
                  ELSE
C-----               ASK FOR DESCRIPTION
                     CALL GRAFMSG(0.3,0.9,453,508,' ',0,1,32,MAPDESC,
     +               NCHR)
                     IFUNC = 1
                  ENDIF
               ENDIF
            ENDIF
         ELSE
            CALL GRAFMSG(0.3,0.9,453,508,' ',0,1,32,MAPDESC,NCHR)
         ENDIF
C        
         WRSPEC=.FALSE.
         NCHR=LNG(MAPNAME)
         NAMEXT = MAPNAME(1:NCHR)//'.QSC'
C---     REDRAW MAP IN TWO COLORS, WHITE AND YELLOW (INTERIOR ONLY)
         CALL SETCOL(0)
         CALL CLR
         CALL SETCOL(8)
         IF (ICOAST.GT.0) THEN
            ICODE = 1
            CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
         END IF
         IF (IBORDER.GT.0) THEN
            ICODE = 3
            CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
         END IF
         IF (ISTATE.GT.0) THEN
            ICODE = 5
            CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
         END IF
         IF (ILAKE.GT.0) THEN
            ICODE = 4
            CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
         END IF
         CALL SETCOL(9)
         IF (IRIVER.GT.0) THEN
            ICODE = 2
            CALL KWLAND(XLONMN,YLATMN,XLONMX,YLATMX,ICODE,IFLAG)
         END IF
         CALL WRBKGND(WRSPEC,NAMEXT)
         CALL CLOSEG
         IF (IFUNC.EQ.2) THEN
            REWIND 40
         ELSE
            OPEN(40,FILE=MAPFILE,STATUS='UNKNOWN',FORM='UNFORMATTED',
     +           IOSTAT=IOCHK)
            IF (IOCHK.NE.0) THEN
               CALL OPENMSG(MAPFILE,'BUILDMAP    ',IOCHK)
               STOP 2
            END IF
         END IF
         CALL SAVMAP(MAPNAME,MAPDESC,YLATMN,YLATMX,XLONMN,XLONMX
     +              ,ICOAST,IBORDER,ISTATE,IRIVER,ILAKE)
         CLOSE (40)
         CALL WRTMSG(4,600,14,0,1,'O:\DATA\'//NAMEXT,20)
         GO TO 40
      END IF
      GO TO 150
C
      END
************************************************************************

      SUBROUTINE QCMAP
C
C   PROGRAM TO ALLOW THE USER TO LINK A MAP WITH THE AREA QC ROUTINES
C
      CHARACTER*1 REPLY,DELMARK,RTNCODE
      CHARACTER*2 RTNFLAG
      CHARACTER*3 MAPTYPE,MAPDDS
      CHARACTER*8 FIELD(3)
      CHARACTER*20 MAPFILE, INFILE, DUMMY
      CHARACTER*64 HELPFILE
      LOGICAL RECFND
C
C   ASK FOR THE FUNCTION TO BE PERFORMED (ADD, MODIFY, DELETE, OR LIST)
C
   20 CONTINUE
      CALL LOCATE(4,32,IERR)
      CALL GETMNU('QCMAPS-FUNC ','  ',IFUNC)
      IF (IFUNC.EQ.0) THEN
         RETURN
      ELSE IF (IFUNC.EQ.4) THEN
         CALL LSTQCMAP
         GO TO 20
      END IF
C
C   INITIALIZE AND ASK FOR THE NAME OF THE MAP,DATATYPE, AND DATASET-ID       
C
      DO 125 I = 1,3
         FIELD(I) = '   '
  125 CONTINUE
  130 CONTINUE
      CALL LOCATE(13,0,IERR)
      HELPFILE = 'P:\HELP\QCMAPS.HLP'
      RTNFLAG = 'MM'
      CALL GETFRM('QCMAPS  ',HELPFILE,FIELD,8,RTNFLAG)
      IF (RTNFLAG.EQ.'4F') THEN
         CALL SCROLL(1,11,13,0,23,79)
         GO TO 20
      END IF
C
C   CHECK THAT THE DATATYPE ENTERED IS VALID
C
      IF (FIELD(1).NE.'MLY' .AND. FIELD(1).NE.'10D' .AND.
     +    FIELD(1).NE.'DLY' .AND. FIELD(1).NE.'SYN' .AND.
     +    FIELD(1).NE.'HLY' .AND. FIELD(1).NE.'15M') THEN
         CALL WRTMSG(3,250,12,1,0,' ',0)
         GO TO 130
      END IF
      IF (FIELD(2).LT.'000' .OR. FIELD(2).GT.'999') THEN
         CALL WRTMSG(3,101,12,1,0,' ',0)
         GO TO 130
      END IF
C
C   SEE IF THE DATATYPE AND DATASET SPECIFIED ARE ALREADY STORED IN THE 
C   QCMAP FILE   
C
      RECFND = .FALSE.
      DO 150 I = 1,9999
         READ(41,REC=I,ERR=155) DELMARK,MAPTYPE,MAPDDS,INFILE
         IF (DELMARK.NE.'*') THEN
            DO 151 J = 1,20
               IF (INFILE(J:J).EQ.' ') THEN
                  GO TO 152
               END IF
               NCHAR = J
  151       CONTINUE
  152       CONTINUE
            IF (MAPTYPE.EQ.FIELD(1).AND.MAPDDS.EQ.FIELD(2)
     +         .AND.FIELD(3).EQ.INFILE(9:NCHAR-4)) THEN
                RECFND = .TRUE.
                GO TO 155
            END IF
         END IF
  150 CONTINUE
  155 CONTINUE
C
C   CHECK THAT THE FUNCTION WANTED AGREES WITH THOSE POSSIBLE.
C   MARK THE RECORD AS DELETED IF THAT IS WHAT IS WANTED
C
      IF (RECFND) THEN
         IF (IFUNC.EQ.1) THEN
            CALL WRTMSG(3,162,12,1,1,' ',0)
         ELSE IF (IFUNC.EQ.3) THEN
            CALL WRTMSG(5,252,12,1,0,' ',0)
            CALL LOCATE(20,60,IERR)
            CALL OKREPLY(REPLY,RTNCODE)
            IF (REPLY.EQ.'Y'.AND.RTNCODE.EQ.'0') THEN
               DELMARK = '*'
               WRITE(41,REC=I) DELMARK,MAPTYPE,MAPDDS,INFILE
               CALL WRTMSG(3,315,12,0,1,' ',0)
               CALL SCROLL(1,11,13,0,23,79)
               GO TO 20
            END IF
         END IF
      ELSE IF (IFUNC.EQ.3) THEN
         CALL WRTMSG(3,61,12,1,1,' ',0)
         CALL SCROLL(1,11,13,0,23,79)
         GO TO 20
      END IF
      IF (RECFND.AND.IFUNC.NE.2) THEN
         CALL SCROLL(1,11,13,0,23,79)
         GO TO 20
      END IF
C
C   SEE IF THE MAP SPECIFIED EXISTS
C
      RTNCODE = ' '
      CALL RDMAP(FIELD(3),MAPFILE,RTNCODE)
      IF (RTNCODE.EQ.'0') THEN
         CLOSE(40)
      ELSE
         CALL WRTMSG(3,251,12,1,1,' ',0)
         CALL SCROLL(1,11,13,0,23,79)
         GO TO 130
      END IF
C
C   WRITE THE MAP NAME, DATASET, AND TYPE TO THE QCMAPS FILE      
C
      MAPTYPE = FIELD(1)
      MAPDDS = FIELD(2)
      IF (IFUNC.EQ.2) THEN
         DO 135 I = 1,9999
            READ(41,REC=I,ERR=136) DELMARK,MAPTYPE,MAPDDS,INFILE
            IF (DELMARK.NE.'*') THEN
               IF (MAPTYPE.EQ.FIELD(1).AND.MAPDDS.EQ.FIELD(2)) THEN
                  DELMARK = ' '
                  WRITE(41,REC=I) DELMARK,MAPTYPE,MAPDDS,MAPFILE
                  GO TO 230 
               END IF
            END IF 
  135 CONTINUE
  136 CONTINUE
      CALL WRTMSG(3,61,12,1,1,' ',0)
      CALL SCROLL(1,11,13,0,23,79)
      GO TO 20
      END IF
      IF (IFUNC.EQ.1) THEN
         DO 200 I = 1,9999
            IREC = I
            READ(41,REC=I,ERR=220) DELMARK,DUMMY
            IF (DELMARK.EQ.'*') THEN
               GO TO 220
            END IF
  200    CONTINUE          
  220    CONTINUE  
         DELMARK = ' '
         WRITE(41,REC=IREC) DELMARK,MAPTYPE,MAPDDS,MAPFILE
      END IF
  230 CONTINUE  
      CALL WRTMSG(3,314,12,0,1,' ',0)
      CALL SCROLL(1,11,13,0,23,79)
      GO TO 20
      END
************************************************************************

      SUBROUTINE LSTQCMAP
C
C       ** ROUTINE TO LIST THE CURRENT QC-MAP LINK FILE
C
      CHARACTER*1 DELMARK
      CHARACTER*2 INCHAR
      CHARACTER*3 MAPTYPE,MAPDDS,DEVERS
      CHARACTER*20 INFILE
      CHARACTER*78 MSGLIN
C
C       ** GET THE FUNCTION KEY LINE FOR THE BOTTOM OF THE WINDOW
C          USE ESC/F4 DEPENDING ON DATAEASE VERSION
      CALL GETDEASE(DEVERS)         
      IF (DEVERS.EQ.'4.0') THEN
         NMSG=220
      ELSE
         NMSG=219
      ENDIF
C
C       ** OPEN A WINDOW ON THE SCREEN 10 LINES LONG 
C          WINDOW HAS A DOUBLE LINE BORDER -- 1 CHARACTER WIDE ON ALL SIDES
C
      IBGROW = 10
      IENROW = IBGROW+11
      IBGCOL = 0
      IENCOL = 30
      CALL DRWBOX(IBGCOL,IBGROW,IENCOL,IENROW,2,0,3) 
   10 CONTINUE
C
C       ** CLEAR WINDOW
C   
      CALL CLTEXT(3,0,IERR)
      NROW = (IENROW-1) - (IBGROW+1) + 1
      CALL SCROLL(1,NROW,IBGROW+1,IBGCOL+1,IENROW-1,IENCOL-1)
      CALL CLTEXT(0,0,IERR)
C
C       ** READ MAP LINK FILE (QCMAPS.MPC) -- LIST ALL UNDELETED RECORDS
C
      IROW = IBGROW
      DO 150 I = 1,9999
         READ(41,REC=I,ERR=155) DELMARK,MAPTYPE,MAPDDS,INFILE
         IF (DELMARK.NE.'*') THEN
           IROW = IROW + 1
           IF (IROW.GT.IENROW-1) THEN
C
C               .. END OF PAGE -- WRITE FUNCTION KEY LINE; GET INPUT FROM USER
              CALL GETMSG(NMSG,MSGLIN)
              NCOL = (IENCOL-1) - (IBGCOL+1) + 1
              LGTH = MIN0(LNG(MSGLIN),NCOL)
              CALL LOCATE(IENROW,IBGCOL+4,IERR)
              CALL WRTSTR(MSGLIN,LGTH,0,3)
              CALL GETCHAR(0,INCHAR)
C
C               .. REMOVE FUNCTION KEY LINE BY DRAWING DOUBLE LINE BORDER
              LINCHR = 205
              DO 140 KNT=IBGCOL+1,IENCOL-1
                 CALL LOCATE(IENROW,KNT,IERR)
                 CALL CHRWRT(LINCHR,3,0,1)
  140         CONTINUE
C
C               .. PROCESS USER INPUT:  F4/ESC TO QUIT;  
C                                       ANY OTHER CHARACTER GIVES NEXT PAGE
              IF (INCHAR.EQ.'4F') THEN
                 GO TO 200
              END IF
C              
C               .. CLEAR WINDOW; SCROLL TO THE TOP OF THE PAGE
              CALL CLTEXT(3,0,IERR)
              NROW = (IENROW-1) - (IBGROW+1) + 1
              CALL SCROLL(1,NROW,IBGROW+1,IBGCOL+1,IENROW-1,IENCOL-1)
              CALL CLTEXT(0,0,IERR)
              IROW = IBGROW+1
           END IF
C
C            .. WRITE CURRENT MAP RECORD INFO TO SCREEN           
           CALL LOCATE(IROW,IBGCOL+1,IERR)
           CALL WRTSTR(MAPTYPE,3,0,3)
           CALL WRTSTR(' ',1,0,3)
           CALL WRTSTR(MAPDDS,3,0,3)
           CALL WRTSTR(' ',1,0,3)
           CALL WRTSTR(INFILE,20,0,3)
         END IF
  150 CONTINUE
  155 CONTINUE
      IF (IROW.EQ.IBGROW) THEN
C
C       ** NO RECORDS FOUND; WRITE MESSAGE IN WINDOW  
C
         CALL GETMSG(100,MSGLIN)
         LGTH = LNG(MSGLIN)
         CALL LOCATE(IROW+1,IBGCOL+1,IERR)
         CALL WRTSTR(MSGLIN,LGTH,0,3)
      ENDIF
C
C       ** GET AND PROCESS USER INPUT:  ESC/F4 TO QUIT
C                                       ANY OTHER KEY REDISPLAYS MENU
      CALL GETCHAR(0,INCHAR)
      IF (INCHAR.NE.'4F') GO TO 10
C      
  200 CONTINUE      
C
C       ** CLOSE MESSAGE FILE; REMOVE WINDOW FROM SCREEN BEFORE EXITING  
      CALL GETMSG(999,MSGLIN)
      CALL CLTEXT(0,0,IERR)
      NROW = IENROW - IBGROW + 1
      CALL SCROLL(1,NROW,IBGROW,IBGCOL,IENROW,IENCOL)
      RETURN
      END
************************************************************************

      SUBROUTINE RDMAP(MAPNAM,MAPFILE,RTNCODE)
C
C   ROUTINE TO OPEN THE MAP FILE FOR THE MAP NAME SPECIFIED
C
      CHARACTER*1 RTNCODE
      CHARACTER*8 MAPNAM
      CHARACTER*20 MAPFILE
C
C   CONVERT THE MAP NAME TO THE MAP FILE NAME
C      
      DO 100 I1 = 1,8
         IF (MAPNAM(I1:I1).EQ.' ') THEN
            GO TO 120 
         END IF
         NCHAR = I1
  100 CONTINUE
  120 CONTINUE
      MAPFILE = 'O:\DATA\            '
      MAPFILE(9:16) = MAPNAM
      MAPFILE(NCHAR+9:NCHAR+12) = '.MPC'
C
C   SEE IF THE MAP SPECIFIED EXISTS
C 
  180 CONTINUE
      OPEN (40,FILE=MAPFILE,STATUS='OLD',FORM='UNFORMATTED'
     +    ,IOSTAT=IOCHK)
      IF (IOCHK.NE.0) THEN
         IF (IOCHK.EQ.6416) THEN
            RTNCODE = '1'
         ELSE
            CALL OPENMSG(MAPFILE,'RDMAP       ',IOCHK)
            GO TO 180
         END IF
      ELSE
         RTNCODE = '0'
      END IF
      RETURN
      END
************************************************************************

      SUBROUTINE DELQCM(MAPFILE)
C
C   ROUTINE TO FIND THE QCMAP FILES THAT RELATE TO A GIVEN MAP AND 
C   DELETE THEM
C
      CHARACTER*20 MAPFILE,INFILE
      CHARACTER*3 MAPTYPE,MAPDDS
      CHARACTER*1 DELMARK
C
      DO 100 I = 1,9999
         READ(41,REC=I,ERR=110) DELMARK,MAPTYPE,MAPDDS,INFILE
         IF (DELMARK.NE.'*') THEN
            IF (INFILE.EQ.MAPFILE) THEN
               DELMARK = '*'
               WRITE(41,REC=I) DELMARK,MAPTYPE,MAPDDS,INFILE
            END IF
         END IF
  100 CONTINUE
  110 CONTINUE
      RETURN
      END             

************************************************************************
      SUBROUTINE DELMAP(MAPNAME,MAPFILE)
C
C   ROUTINE TO DELETE A MAP DEFINITION FILE, DELETE THE SAVED MAP SCREEN,
C   REMOVE ITS ENTRY FROM THE MAPNAMES INDEX FILE AND DELETE ALL LINKS FOR
C   THIS MAP TO THE AREAQC DATATYPE AND DATASET.
C
      CHARACTER*43 INREC
      CHARACTER*20 MAPFILE
      CHARACTER*8 MAPNAME
      CHARACTER*20 SCRNFILE
C
C       ** DELETE THE MAP FILE (________.MPC)
C          DELETE THE SAVED MAP SCREEN (________.QSC)
C
      CLOSE(40,STATUS='DELETE')
      NCHR=LNG(MAPNAME)
      SCRNFILE = 'O:\DATA\'//MAPNAME(1:NCHR)//'.QSC'
      OPEN (51,FILE=SCRNFILE,STATUS='OLD',FORM='FORMATTED'
     +     ,MODE='WRITE',IOSTAT=ICHK)
      IF (ICHK.NE.6416.AND.ICHK.NE.0) THEN
         CALL OPENMSG(SCRNFILE,'DELMAP     ',ICHK)
      END IF
      CLOSE(51,STATUS='DELETE')
C         
C   REMOVE ALL OF THE LINKS FOR THIS MAP TO THE AREAQC DATATYPE AND
C   DATASET (IF THEY EXIST) FROM FILE = QCMAPS.MPC
C     
         CALL DELQCM(MAPFILE)
C
C   FIND AND REMOVE THE ENTRY FROM THE MAPNAMES INDEX FILE (MAPNAMES.IDX)
C      
      OPEN (51,FILE='O:\DATA\MAPNAMES.IDX',STATUS='OLD',FORM='BINARY'
     +     ,ACCESS='DIRECT',RECL=43,IOSTAT=IOCHK)
      IF (IOCHK.NE.0) THEN
         CALL OPENMSG('O:\DATA\MAPNAMES.IDX    ','DELMAP    ',IOCHK)
         STOP 2
      END IF
      DO 100 I = 1,9999
         READ(51,REC=I,ERR=110) INREC
         IF (INREC(1:8).EQ.MAPNAME) THEN
            INREC(1:8) = '********'              
            INREC(10:41) = 'THIS RECORD DELETED'
            WRITE(51,REC=I) INREC
            GO TO 110
         END IF
100   CONTINUE
110   CONTINUE
      CLOSE(51)
      MAPNAME = ' '
      RETURN
      END

*************************************************************************
      SUBROUTINE SAVMAP(MAPNAME,MAPDESC,YLATMN,YLATMX,XLONMN,XLONMX
     +                 ,ICOAST,IBORDER,ISTATE,IRIVER,ILAKE)
C
C   ROUTINE TO SAVE THE MAP DEFINITION TO DISK
C
      CHARACTER*43 INREC
      CHARACTER*32 MAPDESC
      CHARACTER*8 MAPNAME
      CHARACTER*1 CHRRTN,LNFEED
      CHRRTN = CHAR(13)
      LNFEED = CHAR(10)
C
C     THE DESCRIPTION OF THIS MAP IS PASSED AS AN PARAMETER. ENTER IT INTO
C     THE FORTRAN MAP DEFINITION INDEX FILE.
C

      WRITE(40) YLATMN,YLATMX,XLONMN,XLONMX,ICOAST,IBORDER,ISTATE
     +         ,IRIVER,ILAKE
C
C   SAVE OR UPDATE THIS ENTRY IN THE MAPNAMES INDEX FILE
C
      OPEN (51,FILE='O:\DATA\MAPNAMES.IDX',STATUS='UNKNOWN'
     +     ,FORM='BINARY',ACCESS='DIRECT',RECL=43,IOSTAT=IOCHK)
      IF (IOCHK.NE.0) THEN
         CALL OPENMSG('O:\DATA\MAPNAMES.IDX    ','SAVMAP    ',IOCHK)
         STOP 2
      END IF
      IDEL = 0
      DO 150 I = 1,9999
         READ(51,REC=I,ERR=160) INREC
         IF (INREC(1:8).EQ.MAPNAME) THEN
            INREC(10:41) = MAPDESC
            IDEL = 0
            GO TO 200
         ELSE IF (INREC(1:8).EQ.'********') THEN
            IDEL = I
         END IF
150   CONTINUE
160   CONTINUE
      WRITE(INREC,'(A8,1X,A32,2A1)') MAPNAME,MAPDESC,CHRRTN,LNFEED
C
200   CONTINUE
      IF (IDEL.GT.0) THEN
         WRITE(51,REC=IDEL) INREC
      ELSE
         WRITE(51,REC=I) INREC
      END IF
      CLOSE (51)
C
      RETURN
      END

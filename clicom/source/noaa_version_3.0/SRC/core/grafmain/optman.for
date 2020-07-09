$STORAGE:2
      PROGRAM OPTMAN
C
$INCLUDE: 'GRFPARM.INC'
$INCLUDE: 'GRAFVAR.INC'
$INCLUDE: 'DATAVAL.INC'
$INCLUDE: 'FRMPOS.INC'
$INCLUDE: 'MODTMP.INC'
$INCLUDE: 'CURRPLT.INC'
C
      INTEGER*2 HELPLVL,WINSTAT,MENUNUM,NOKD,LENMSG
      PARAMETER (NOKD=3)
      CHARACTER*2 OPTCHR,EXITOPT,OKOPT(NOKD)
      CHARACTER INCHAR*2, RTNCODE*1, MSGTXT*14
      REAL*4 XWIN,YWIN
      LOGICAL APIOPN
C
      DATA XWIN /.05/,YWIN /.40/
C       .. VALID OPTION FLAG IN FILE DATACOM.CON -- VALUE EQUALS THE MENU
C          CHOICE IN GRAFMAN THAT PRODUCE CALL TO OPTMAN      
C          7=LINES  8=SIZE/BKGRND  9=DATA
      DATA OKOPT/'7 ','8 ','9 '/
C       .. VALUE OF OPTION FLAG IN FILE DATACOM.CON WHEN EXITING OPTMAN
C          AND RETURNING TO GRFMN2/134
      DATA EXITOPT/'GO'/      
C
C       **  Open and read GRAPHICS.GDF file and store the values in the
C           GRAFVAR common block.
C
      CALL RDGRAF('GRAPHICS',ITYPE,NELEM,RTNCODE)
C
C       ** INITIAL GRAPHICS
C
      IF (RTNCODE.EQ.'0') THEN
C          .. NORMAL RETURN FROM RDGRAF      
         CALL BGNHALO(1,PALETTE,PALDEF)
      ELSE
C          .. ERROR RETURN FROM RDGRAF      
         CALL BGNHALO(0,PALETTE,PALDEF)
         GO TO 900
      ENDIF      
C
C       ** OPEN AND READ DATACOM.CON FILE AND STORE CONSTANTS IN COMMON
C          BLOCKS -- FRMPOS,DATAVAL,CURRPLT,PLTSPEC; CLOSE FILE
      CALL RDDCON(1,OKOPT,NOKD,OPTCHR,RTNCODE)
      IF (RTNCODE.EQ.'2') THEN
C          .. ERROR IN READING O:\DATA\DATACOM.CON      
         GO TO 905        
      ELSE IF (RTNCODE.EQ.'3') THEN
C          .. INVALID OPTION CHARACTER      
         GO TO 920
      ENDIF   
C      MXDATROW = NROWDIM
C
C       .. MAIN MENU CHOICE #9 FOR MAP
      IF (IGRAPH.EQ.2 .AND. OPTCHR.EQ.'9 ') THEN
         OPTCHR = '10'
      ENDIF   
C      
      APIOPN = .FALSE.
C      IF (OPTCHR.NE.'8 ') THEN
C
C          ** Open the GRAPHICS.API file as unit 17 and read the first frame
C             into memory.
C
         IDATAOPT=0
         MSGTYP =2            
         NTTL=MXFRMD
         CALL GETDSET(ITYPSET,IDATAOPT,MSGTYP,NTTL,TTLSAV,INCSET,
     +                RTNCODE)
         IF (RTNCODE.NE.'0') GO TO 915
         APIOPN = .TRUE.
C      ENDIF
C         
      IF (OPTCHR.EQ.'7 ') THEN
         CALL PLTMAN            
      ELSE IF (OPTCHR.EQ.'8 ') THEN
         CALL VIEWMAN(VPNDLF,VPNDRT,VPNDBT,VPNDTP,GANWLF,GANWRT,
     +                GANWBT,GANWTP,PALETTE,PALDEF,BKGNCLR)
      ELSE IF (OPTCHR.EQ.'9 ') THEN
C
C          .. SWITCH FROM GRAPHICS TO TEXT MODE
         CALL CLOSEG
         CALL SETMOD(3,IERR)
C
         CALL DATMAN(INCSET)         
C
C          .. RETURN TO GRAPHICS MODE         
         CALL BGNHALO(1,PALETTE,PALDEF)
      ELSE IF (OPTCHR.EQ.'10') THEN
   20    CONTINUE   
         MENUNUM=42
         HELPLVL=42
         WINSTAT=2
         CALL GRAFMNU(WINSTAT,MENUNUM,XWIN,YWIN,HELPLVL,INCHAR)
         OPTCHR=INCHAR
         WINSTAT=0
         CALL GRAFMNU(WINSTAT,MENUNUM,XWIN,YWIN,HELPLVL,INCHAR)
         IF (OPTCHR.EQ.'ES') GO TO 100
C
C          .. SWITCH FROM GRAPHICS TO TEXT MODE
         CALL CLOSEG
         CALL SETMOD(3,IERR)
C
         IF (OPTCHR.EQ.'1 ') THEN
            CALL GTCONLEV(NDECRT(2),CONLEV,NCONLEV)         
         ELSE
            CALL DATMAN(INCSET)         
         ENDIF      
C
C          .. RETURN TO GRAPHICS MODE         
         CALL BGNHALO(1,PALETTE,PALDEF)
         GO TO 20
      ELSE
C          .. ILLEGAL OPTIONS CHARACTER
        GO TO 920
      ENDIF  
C      
  100 CONTINUE
      ITYPE = IOBSTYP
      ITEMP = 1
      CALL WRTGRAF(GDFNAME,ITYPE,ITEMP,INCHAR)
      IF (APIOPN) CALL WRFILPOS(-1,IGRAPH,NUMCOL,IDUM)
      OPTCHR=EXITOPT
      CALL WRTDCON(0,1,OPTCHR,RTNCODE)
      IF (RTNCODE.NE.'0') GO TO 910        
      CALL FINHALO
      CALL LOCATE(23,0,IERR) 
      STOP ' '
C
C       ** FATAL ERROR      
C
  900 CONTINUE
C          .. ERROR READING FILE: GRAPHICS.GDF  
         MSGN1=191
         MSGTXT='  GRAPHICS.GDF'
         LENMSG=14
         GO TO 990
  905 CONTINUE
C          .. ERROR READING FILE: DATACOM.CON  
         MSGN1=191
         MSGTXT='  DATACOM.CON'
         LENMSG=13
         GO TO 990
  910 CONTINUE
C          .. ERROR WRITING FILE: DATACOM.CON  
         MSGN1=192
         MSGTXT='  DATACOM.CON'
         LENMSG=13
         GO TO 990
  915 CONTINUE
C          .. ERROR READING FILE: GRAPHICS.API  
         MSGN1=191
         MSGTXT='  GRAPHICS.API'
         LENMSG=14
         GO TO 990
  920 CONTINUE
C          .. ILLEGAL OPTIONS CHARACTER  
         MSGN1=551
         MSGTXT=' '
         LENMSG=0
         GO TO 990
  990 CONTINUE         
         MSGN2=202
         XWIN=.1
         YWIN=.95
         CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,MSGTXT,LENMSG,INCHAR)
         IF (APIOPN) CALL WRFILPOS(-1,IGRAPH,NUMCOL,IDUM)
         OPTCHR=EXITOPT
         CALL WRTDCON(0,0,OPTCHR,RTNCODE)
         IF (RTNCODE.NE.'0') THEN
            MSGN1=192
            MSGTXT='  DATACOM.CON'
            LENMSG=13
            CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,MSGTXT,LENMSG,INCHAR)
         ENDIF            
         CALL FINHALO
         CALL LOCATE(23,0,IERR) 
         STOP ' '
      END            

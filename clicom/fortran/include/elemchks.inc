C
      PARAMETER (MAXCHK=11)
      CHARACTER*2 CHKRL1(MAXELEM,MAXCHK), CHKRL2(MAXELEM,MAXCHK)
      INTEGER*2 CHKTYP(MAXELEM,MAXCHK),CHKELM(MAXELEM,MAXCHK)
      REAL*4    CHKVL1(MAXELEM,MAXCHK),CHKVL2(MAXELEM,MAXCHK)
      COMMON /ELMCHK/ CHKTYP,CHKVL1,CHKELM,CHKVL2,CHKRL1,CHKRL2
      
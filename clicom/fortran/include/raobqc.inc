

      REAL*4 PRESSURE(MAXLINE),HEIGHT(MAXLINE)
      REAL*4 TEMP(MAXLINE),DEWPTDEP(MAXLINE)
      REAL*4 WINDSPEED(MAXLINE),WINDDIR(MAXLINE) 
      REAL*4 MISSING

      REAL*4 VIRTEMP(MAXLINE),COMPHT(MAXLINE)
      REAL*4 PRESS1,PRESS2,RH,MIXRATIO
      INTEGER*4 INTVAL

      CHARACTER*1 FLAGHOLD(MAXELEM,11,2)
      CHARACTER*1 DATAFLAG(6,MAXLINE),EXIT
      CHARACTER*6 BLANK
      LOGICAL WIND(MAXLINE)

      COMMON /QCCOMMON/ PRESSURE,HEIGHT,TEMP,DEWPTDEP,WINDSPEED,
     +                  WINDDIR,VIRTEMP,COMPHT,DATAFLAG,WIND

      DATA BLANK/'      '/
      DATA MISSING/-99999./


	SUBROUTINE DIVERT3
	INCLUDE 'SOLDIV.FI'
	real fac5,dqatold,xkdsol,fina,fracion
C		DISTRIBUTED SOL/DIVERTOR MODEL
C	SOLVES COUPLED PLASMA/NEUTRAL EQUATIONS IN SOL/DIVERTOR
C	FOR GIVEN PARTICLE AND HEAT FLUXES FROM PLASMA

C	ITERATIVE SOLUTION.  
	
C		WIDTHS--BOHM RADIAL TRANSPORT IN SOL
C		MKS UNITS, EXCEPT T IN eV
		
	JITX = 0 
	JX = 0 
	TPEL = 2. 
	IOPTCOOL = 0
	ITSTOP = 0
	MFLUX = 1
	ITERN = 0 
20	ITERN = ITERN + 1
c		TERMINATES AFTER 200 ITERATIONS
c       write(*,*) 'T0 =', T0
c	   write(*,*) 'TPED =', TPED
c	   write(*,*) 'TSOL =', TSOL
c	   write(*,*) 'TSEP =', TSEP
c	   write(*,*) 'XN0 =', XN0
c	   write(*,*) 'XNPED =', XNPED
c	   write(*,*) 'XNSOL =', XNSOL
c	   write(*,*) 'XNSEP =', XNSEP
	IF(ITERN.GT.100) GOTO 450 
	 xzc = fracsol
	CALL WIDTH 
C		RADIAL GEOMETRIC FACTORS
 	DERAT = (DELNV/DELEA) 
	DELN2 = DELNV
 	FAC1 = 0.0
	FAC2 = 0.0
	FAC4 = 1.0
	X = 1./DELRATNT
	Y = (X*EXP(-1./(2.*X)) + EXP(-1./X - 1./2.))/(1.+X)
	FAC5 = X*(1.0 - Y)
      X = 2./DELRATNT
	Y = (X*EXP(-1./(2.*X)) + EXP(-1./X - 1./2.))/(1.+X)
	FAC6 = X*(1. - Y)
C		FLAT RADIAL DENSITY PROFILE IN DIVERTOR CHANNEL
	IF(IOPTPROF.NE.0) GOTO 744	
	DERAT2 = 1.5*DELRATNT/(1.-EXP(-1.5*DELRATNT))
	DERAT1 = 1.0
	DERAT0 = DELRATNT/(1. - EXP(-1.*DELRATNT))
	DERAT3 = (1.+DELRATNT)/(1. - EXP(-1.*(1.+ DELRATNT)))
	FAC6 = 1.0/DERAT1
	DERAT4 = (1.-EXP(-1.*DELRATNT)) + 
	2		(1.-EXP(-1.5*DELRATNT))/(3.*DELRATNT) 
	GOTO 745
C		EXPONENTIAL RADIAL DENSITY PROFILE IN DIVERTOR CHANNEL & SOL
744	DERAT2 = (1.+1.5*DELRATNT)/(1. - EXP(-1.*(1.+1.5*DELRATNT)))
	DERAT1 = (1.+0.5*DELRATNT)/(1. - EXP(-1.*(1.+0.5*DELRATNT)))
	DERAT0 = (1.+DELRATNT)/(1. - EXP(-1.*(1.+ DELRATNT)))
	DERAT3 = (1.+DELRATNT)/(1. - EXP(-1.*(1.+ DELRATNT)))
	FAC6 = 1.0/DERAT1
	DERAT4 = (1.-EXP(-1.*DELRATNT))*(1.-EXP(-1.)) + 0.5/DERAT2  
745	CONTINUE  
C	redkappa = 0.1
	
C			COULOMB LOGARITHM & PARALLEL CONDUCTIVITY	
 	Y = 25.3 - 1.15*LOG10(1.E-6*XNSEP) + 2.3*LOG10(TSEP)
 	IF(TSEP.LT.50.) Y = 23.4-1.15*LOG10(1.E-6*XNSEP)+3.45*LOG10(TSEP)
	ZEFF=(1.+(IZINJECT**2)*FZINJECT + 4.*FHE +(IZINTRIN**2)*FZINTRIN)/
	2      (1.+ IZINJECT*FZINJECT + 2.*FHE + IZINTRIN*FZINTRIN) 
	XKAPPA = (3.07E4/(ZEFF*Y))*redkappa
C		INWARD ION DIFFUSION FRACTION
	X = 2.*XKAPPA*(TSEP**3.5)/(ASYMPART*FLUXHEAT*XLPERP)
	FINA = 1./(1.+X) 
C	BRAGINSKI (CHIPERP/CHIPAR)*(LPERP/DELN)
	X1 = 2.25E20*(TSEP**3)*((10.*B)**2)/
	2     (((Y/10)**2)*((1.E-6*XNSEP)**2))
	FIN1 = 1./(1. + X1*DELN/XLPERP)
	FIN2 = 1./(1. + X1*DELN/(XLPAR-XLPERP)) 
	FINA = 0.0
C	INWARD ION FRACTION
C	FIN = 0.5*FIN1
C	'OUTWARD' ION FRACTION
c	CALL FUEL

C	*****BEGIN NEUTRALS CALCULATION *********** 

C		IMOL=0 ATOM RECYCLING; =1 ATOM + MOLECULE RECYCLING

21 	CALL MOLECULE
C		NEUTRAL COOLING, MOMENTUM DISSIPATION & PARTICLE SOURCE/SINK
	XNODOLD = XNOD 
	GAMZEROLD = GAMZERO
	YIONSOLOLD = YIONSOL
	HNPED = 1.
	HTPED = 1.
	if(joptedped.eq.1)	goto 425
400	IF(IOPTSOLN.NE.1) GOTO 425
c	replace calculated values with exp values for neutral calc
	HNSOL = XNSEPEX/XNSEP
	HTSOL = 0.5*(TSEPEXI+TSEPEXE)/TSEP
	HNPED = XNPEDEX/XNPED
	HTPED = 0.5*(TPEDEXI+TPEDEXE)/TPED
	   IF (ITERN.EQ.100) THEN
	        write(9017,'(8A10)') 'HNSEP','HTSEP','HNPED','HTPED',
     1		'NSEP','TSEP','NPED','TPED'
	        write(9017,'(8E10.3)') HNSOL,HTSOL,HNPED,HTPED,
     1        XNSEP,TSEP,XNPED,TPED
	   ENDIF
425	XNSOL = HNSOL*XNSEP 
	TSOL = HTSOL*TSEP 
	XNDIV =  HNDIV*XNSOL/EPDIV + (1-HNDIV)*XND
	TDIV = HTDIV*TSOL + (1.- HTDIV)*TD
c	XNPED = HNPED*XNPED
c	TPED = HTPED*TPED
	xnbarold = xnbar
	tbarold = tbar
c	XNBAR = 0.5*(XNSOL+XNPED)
c	TBAR = 0.5*(TSOL+TPED)
c	IF(IPFLUX.EQ.1) GOTO 500
c	MFLUX = 0
	CALL NEUTRAL3
	IF(ITERN.GT.10) YIONSOL =YIONSOLOLD + 0.1*(YIONSOL-YIONSOLOLD)
C		PARALLEL HEAT REMOVAL BY ATOMIC COOLING OF PLASMA
	DQATOLD = DQAT
	DNATOLD = DNAT
	DMATOLD = DMAT
c	restore calculated values
	xx=tbar
	xx= xnbar
c	xnped = xnped/hnped
c	tped = tped/htped
	CALL ATOMIC
C	CONVERT TO PARALLEL FLUX TUBE & NORMALIZE TO DENSITY AT PLATE
c?????	DQAT = DQAT/(BETAG*FSHEATH)
	IF(ITERN.GT.10) DQAT = 0.5*(DQAT+DQATOLD)
	DMAT = DMAT/(BETAG*FSHEATH)
	DMATB = DMAT/XND
	DNAT = DNAT/(BETAG*FSHEATH) 
	DNATB = DNAT/XND
	DNATC = DNATB/XND
	DQAT = DQAT*FAC4
	tbar = tbarold
	xnbar = xnbarold 
C	*****END NEUTRALS CALCULATION**********

C	*****BEGIN CORE CALCULATION**********
22	CVV = T0
	XNAVOLD = XNAV
	TAVOLD = TAV
 	ITC = 0
	FLUXPARTOLD = FLUXPART
	FLUXHEATOLD = FLUXHEAT 
	AR = TPED
30	ITC = ITC + 1 
C		ION & HEAT FLUXES INTO DIVERTOR, NAV & TAV
	IF(IPFLUX.EQ.1) GOTO 105
	CALL QDIV
C		PEDESTAL VALUES	
      CALL PEDESTAL
C		CORE DISTRIBUTION
	x = alphan 
33 	CALL DISTR
C		CORE RADIATION & OHMIC AND FUSION  HEATING 
	CALL CORAD
	 
C	*****END CORE CALCULATION*********

C	*****BEGIN DIVERTOR PLASMA CALCULATION*********

C		DIVERTOR PLASMA CALCULATION

105	XNDOLD = XND
 	TDOLD = TD
	VSEPOLD = VSEP
	TSEPOLD = TSEP
	XNSEPOLD = XNSEP 
C		PARALLEL HEAT REMOVAL BY RADIATION COOLING OF PLASMA
	DQRADOLD = DQRAD
110	CALL DIVRAD

	DQRADB = DQRAD/XND
C		PARALLEL HEAT REMOVAL BY IONIZATION LESS RECOMBINATION(ATOMIC) 
C		PLUS WALL RECYCLING
	IF(ITERN.NE.1) GOTO 112
	FHEAT = ASYMHEAT*FLUXHEAT
	FPART = ASYMPART*FLUXPART
112	CONTINUE 
C		RADIAL LOSSES FROM SOLDIV PLASMA
	CALL RADIAL 
C	**********DELE OR DELN FORMULATION FOR ENERGY BALANCE?*******	
      RAT1 = 1.0	
C	*************************************************************
C	GOTO 115
	DQATB = DQAT/XND		 
	XXC = (DQRAD + DQAT+DQNIN+DQPERP)*RAT1/(ASYMHEAT*FLUXHEAT*XLPERP)
	IF(XXC.LE.0.99) GOTO 115
C		UPPER LIMIT ON RAD + ATOM COOLING OF 99%
	DQRAD = (DQRAD/XXC)*.99
	DQAT = (DQAT/XXC)*.99
	DQNIN = (DQNIN/XXC)*.99
	DQPERP = (DQPERP/XXC)*.99
	XXC = .99 
115	CONTINUE
C		UPPER LIMIT ON NET RECOMBINATION OF 95%
	XXR = -1.*(DNAT-DNRAD-DNIN)/(ASYMPART*FLUXPART*XLPERP)
	IF(XXR.GT.1.0) DNAT = (0.95/XXR)*DNAT	
	IF(XXR.GT.1.0) DNRAD = (0.95/XXR)*DNRAD	 
	IF(XXR.GT.1.0) DNIN = (0.95/XXR)*DNIN
	DQIN = ASYMHEAT*FLUXHEAT*XLPERP
    	DELNIN = ASYMPART*FLUXPART*XLPERP
C	******OLD DIVERTOR SOLUTION FORMULATION***************
          		 
C		SEPARATRIX TEMPERATURE AT DIVERTOR PLATE
122 	ZZ = (DNAT-DNRAD)/DELNIN
	TDOLD = TD 
	
	IF(ZZ.GT.-0.95) GOTO 124	
C	LIMIT NET RECOMBINATION TO 95% OF GAMPERP*LPERP
	DNAT = -0.95*(1.+ZZ)*DNAT/(0.05*ZZ)
	DNRAD = -0.95*(1.+ZZ)*DNRAD/(0.05*ZZ)
	DNATB = -0.95*(1.+ZZ)*DNATB/(0.05*ZZ)
	ZZ = -0.95
124	TD = FUDGE*(ASYMHEAT*FLUXHEAT/(ASYMPART*FLUXPART))*(DERAT2/DERAT1)
     2		*(1.-XXC)/((1.+ZZ)*GAMSHEATH*XK)

125	CONTINUE 

	if(itern.lt.55) goto 129
 	iyt = 5 
	aflx=fluxneutin
129	ITKD = 0 
C		SEPARATRIX TEMPERATURE AT STAGNATION POINT
130	Z = (7./(2.*XKAPPA*DELEA*EPDIV))*(DQIN*(XLPAR-0.5*XLPERP)-
  	2      (DQAT+DQRAD+DQNIN+DQPERP)*RAT1*0.5*XLPAR)*SOLTMULT
	TDP = TD
	TSEP = (((TDP**3.5)) + Z)**0.2857143 
c	write(*,*) 'DQRAD =', DQRAD

C		SEPARATRIX DENSITY AT DIVERTOR PLATE 
	CSD = SQRT(2.*XK*TD/XMASS) 
	GAMN = ((5./32.)*ALB*XK*(TSEP**2)/(B*ASYMHEAT*FLUXHEAT))*DELRATNT
	XKDSOLOLD = XKDSOL
	
	XND =  (1.+FAC1*DELRATNT)*(DNAT-DNRAD+ASYMPART*FLUXPART*XLPERP)*
	2		DERAT1/(CSD*EPDIV*DELNV)
	
	OMEGAPOL = (1.6E-19*BFIELD/XMASS)*BETAG
  	CSd = SQRT(2.*XK*Td/XMASS)
	RHOd = CSd/OMEGAPOL
 	GYRO = (RHOD/DELN)*DERAT4*DERAT3

      XKDSOL=SOLNMULT*((2.*EPDIV*TD*(DERAT3/DERAT0)) - GYRO +	
     2       (0.5*DMAT*DERAT3/(XK*XND*DELN)))/(EPDIV*TSEP)
		
	XND = SQRT((1.+FAC1*DELRATNT)*(DNAT-DNRAD+ASYMPART*FLUXPART*
     2	XLPERP)*DERAT1/(EPDIV*XKDSOL*GAMN*CSD))

      XKDSOL=SOLNMULT*((2.0)*EPDIV*TD+0.5*DMAT/(XK*XND*DELNT*FAC5))/
	2		(EPDIV*TSEP)
	XKDSOL=SOLNMULT*((2.*EPDIV*TD*(DERAT3/DERAT0)) - GYRO +	
     2       (0.5*DMAT*DERAT3/(XK*XND*DELN)))/(EPDIV*TSEP)
	 
C		SEPARATRIX DENSITY AT STAGNATION POINT 
132	XNSEP = XND*XKDSOL
C		UPDATE WIDTHS
 	CALL WIDTH
C		ITERATE DENSITY & WIDTHS TO CONSISTENCY
	ITKD = ITKD + 1
	IF(ITKD.GT.10) GOTO 180 
	XXX = ABS(XKDSOLOLD/XKDSOL-1.)
	IF(XXX.GT.1.E-4) GOTO 130

180	CONTINUE
C	ENERGY FRACTIONS
 	 vvv = fractot
185	COOLFRACRAD = DQRAD*RAT1/DQIN
	COOLFRACAT =  DQAT*RAT1/DQIN
	COOLFRACION = (DQION)*RAT1/DQIN 
	COOLFRAC   =  (DQAT+DQRAD+DQNIN+DQPERP)*RAT1/DQIN
	COOLFRACPERP = DQPERP*RAT1/DQIN
	 IF(IPFLUX.EQ.1) FRACSOL = 1.0 
	FRACRADIV = FRACSOL*COOLFRACRAD
	FRACATDIV = FRACSOL*COOLFRACAT
	FRACPERP = FRACSOL*COOLFRACPERP
	FRACIONDIV = FRACSOL*COOLFRACION
	fracwall = fracsol*(coolfrac-coolfracrad-coolfracion)
C			IONIZATION + LOSS TO WALL BY RECYCLING PARTICLES
	FRACATOM = FRACATDIV  
C		LOSS TO WALL BY IMPINGING NEUTRALS AND IONS
c	FRACWALL = FRACSOL*(DQAT*WALLFRAC-DQION+DQPERP)*RAT1/DQIN
c	FRACION  = FRACSOL*DQION*RAT1/DQIN	
	CSDB = CSD
C	CALCULATE NDB THAT SATISFIES PARTICLE BALANCE 
190	XNDBOLD = XNDB
	TDBOLD = TDB 
	XNSEPBOLD = XNSEPB 
	XNDB = (1.+FAC1*DELRATNT)*(ASYMPART*FLUXPART*XLPERP+DNAT-DNRAD)*
     2		DERAT1/(CSDB*EPDIV*DELNV)

 
C	CALCULATE TDB THAT SATISFIES ENERGY BALANCE
C	TDB = (1.+FAC2*DELRATNT)*DQIN*(1.-COOLFRAC)/
C    2    	(XK*XNDB*CSDB*GAMSHEATH*DELEA*EPDIV)
	TDB = FUDGE*(1.+FAC2*DELRATNT)*DQIN*(1.-COOLFRAC)*DERAT2/
     2    	(XK*XNDB*CSDB*GAMSHEATH*DELN*EPDIV)
 

	CSDB = SQRT(2.*XK*TDB/XMASS) 
	EP = 1.E-5
	IF(ABS(TDBOLD/TDB-1.).GT.EP) GOTO 190
	IF(ABS(XNDBOLD/XNDB-1.).GT.EP) GOTO 190 
c		RECALCULATE TSEPB FOR CONSISTENCY WITH NDB & TDB
	Z = (7./(2.*XKAPPA*DELEA*EPDIV))*(DQIN*(XLPAR-0.5*XLPERP)-
 	2      (DQAT+DQRAD+DQNIN+DQPERP)*RAT1*0.5*XLPAR)*SOLTMULT
	TSEPB = (((TDB**3.5)) + Z)**0.2857143 
C	CALCULATE NSEP THAT SATISFIES MOMENTUM BALANCE
	XKDSOL=SOLNMULT*((2.0)*EPDIV*TD+0.5*DMAT/(XK*XNDB*DELNT*FAC5))/
	2		(EPDIV*TSEP)
	OMEGAPOL = (1.6E-19*BFIELD/XMASS)*BETAG
	RHOdB = CSdB/OMEGAPOL
	GYROB = (RHODB/DELN)*DERAT4*DERAT3

      XKDSOL=SOLNMULT*((2.*EPDIV*TDB*(DERAT3/DERAT0)) - GYROB +	
     2       (0.5*DMAT*DERAT3/(XK*XNDB*DELN)))/(EPDIV*TSEPB)

 
	XNSEPB = XNDB*XKDSOL
	IF(ABS(XNSEPBOLD/XNSEPB-1.).GT.EP) GOTO 190 
195	EP = 1.E-3 
	
C		SOURCE & SINK OF TOTAL PARTICLES WITHIN CORE
c	AP = 39.44*RMAJOR*AMINOR*SQRT((1.+ELONG**2)/2.)
	APXPT = 6.2832*RMAJOR*DELXPT
	FUSION = PFUSION/(17.6*1.6E-13)
 
	SOURCEC = CURSEP*(1.-ALPHASEP)*(AP-APXPT) +
	2       CURSEPXPT*(1.-ALPHASEPXPT)*APXPT  +
     3	    (YIONSOL + YIONSOLXPT)*FINA*2.*6.2832*RMAJOR +
     5           SPELLET -dn_dt
	SINKC = (FLUXPART)*AP + 2.*FUSION

	RPARTC = SOURCEC/SINKC

C	SOURCE & SINK OF TOTAL PARTICLES IN SOL/DIV 
	FUELPL = FUELPLOUT 
	DELNS = DELNV*EPDIV/SIN(THETA) 
 	SOURCET = 2.*(FLUXPART)*XLPERP*BETAG*(6.2832*RMAJOR) + 
	2          (FUELMP+FUELPF+FUELPL) + 
     3  (2.*GAMZERO*DELNV*EPDIV/((1.-FMOL)*SIN(THETA)))*(6.2832*RMAJOR) 
	SINKT = (GAMOUTPF*(1.- RWPF)*2.*XLPF+GAMOUTPF*(1.-RPUMP)*DELPUMP +
     1 2.*GAMPUMP*YPUMP*(1.-RPUMP) + (6.2832*RMAJOR)*2.*DNRAD*(1.-RWPL)+
     2   GAMOUTPL*(1.- RWPL)*2.*XLPL + GAMOUTSPL*(1.- RWSOL)*2.*XLWSOL +
     3      (2.*GAMZEROM*DELNV*EPDIV/SIN(THETA)) +
	4        2.*CURSEP*(1.-ALPHASEP)*(XLPERP*BETAG-0.5*DELXPT) +
     5   CURSEPXPT*(1.-ALPHASEPXPT)*DELXPT)*(6.2832*RMAJOR)  +
     5        (2.*XND*CSD*DELNV*EPDIV*FAC6)*BETAG*(6.2832*RMAJOR) 
     6	+	(2.*FINA*YIONSOL)*(6.2832*RMAJOR)
	7	+	(2.*FINA*YIONSOLXPT)*(6.2832*RMAJOR)

	RPARTT = SOURCET/SINKT
C   	SOURCE & SINK OF NEUTRAL PARTICLES IN SOL/DIV
 	SOURCEN = (2.*GAMZERO*DELNV*EPDIV/((1.-FMOL)*SIN(THETA)))*
	2		  (6.2832*RMAJOR) +	(FUELMP+FUELPF+FUELPL) +
	3		  (6.2832*RMAJOR)*2.*DNRAD*RWPL*betag

	SINKN=(GAMOUTPF*(1.- RWPF)*2.*XLPF+GAMOUTPF*(1.-RPUMP)*DELPUMP +
     1      2.*GAMPUMP*YPUMP*(1.-RPUMP) +
     2 GAMOUTPL*(1.- RWPL)*2.*XLPL + GAMOUTSPL*(1.- RWSOL)*2.*XLWSOL +
	3       	2.*CURSEP*(1.-ALPHASEP)*(BETAG*XLPERP-0.5*DELXPT)  +
	4		2.*CURSEPXPT*(1.-ALPHASEPXPT)*0.5*DELXPT +
	4		2.*GAMZEROM*DELNV*EPDIV/SIN(THETA))*(6.2832*RMAJOR) +
	5		2.*(DNAT*BETAG+(YIONSOL+YIONSOLXPT)*FINA)*(6.2832*RMAJOR)
	RPARTN = SOURCEN/SINKN 
C	SOURCES & SINKS OF PLASMA PARTICLES IN SOL/DIV 
	SOURCEP=(1.+FAC1*DELRATNT)*2.*(DNAT+FLUXPART*XLPERP)*BETAG*
	2											(6.2832*RMAJOR) 	 
	SINKP = (2.*XND*CSD*DELNV*EPDIV*FAC6)*BETAG*(6.2832*RMAJOR) 
	2		 + (6.2832*RMAJOR)*2.*DNRAD*betag
	RPARTP = SOURCEP/SINKP
C		SOURCE & SINK OF TOTAL PARTICLES WITHIN CHAMBER
	SOURCETC =FUELMP+FUELPF+FUELPL+SPELLET +
	2 (2.*GAMZERO*DELNV*EPDIV/((1.-FMOL)*SIN(THETA)))*(6.2832*RMAJOR) 
	SINKTC = (GAMOUTPF*(1.-RWPF)*2.*XLPF+GAMOUTPF*(1.-RPUMP)*DELPUMP+
	1		2.*GAMPUMP*YPUMP*(1.-RPUMP) +
     2  GAMOUTPL*(1.- RWPL)*2.*XLPL + GAMOUTSPL*(1.- RWSOL)*2.*XLWSOL +
     3      (2.*GAMZEROM*DELNV*EPDIV/SIN(THETA)) +
     4      2.*XND*CSD*DELNV*EPDIV*FAC6*BETAG)*(6.2832*RMAJOR) +
	5	   (6.2832*RMAJOR)*2.*DNRAD*(1.-RWPL)
	RPARTTC = SOURCETC/SINKTC 
	FUELPL = FUELPLOUT
	EXTSOURCE =  FUELMP+FUELPF+FUELPL+SPELLET 
	RECSOURCE =  (2.*GAMZERO*DELNV*EPDIV/SIN(THETA))*(6.2832*RMAJOR)
C		PUMP FLUXES
C 	GAMPUMP1 = (GEOM11*Z*GAMR2PL1 + GEOM21*ZQ*GAMDIV2PL1 +
C     2			(APL1*GAMOUTPL1 + APF1*GAMOUTPF1)*YPUMP1)/YPUMP1
C    	GAMPUMP2 = (GEOM12*Z*GAMR2PF2 + GEOM22*ZQ*GAMDIV2PF2 +
C     2			(APL1*GAMOUTPL2)*YPUMP2)/YPUMP2

C	PUMPRATE=(2.*GAMPUMP*YPUMP*(1.-RPUMP)+GAMOUTPF*(1.-RPUMP)*DELPUMP)
C	2          *6.2832*RMAJOR
C	PUMPFRAC = PUMPRATE/EXTSOURCE
	RECSINK  = ((2.*GAMZEROM*DELNV*EPDIV/SIN(THETA)) +
     4      2.*XND*CSD*DELNV*EPDIV*FAC6*BETAG)*(6.2832*RMAJOR)

C	ENERGY BALANCE EDITS
C		CORE
	RHEATC = ((PFUSION/5.+PBEAM)*1.E6+POHMH-PRAD +
     2     3.*XK*(SPELLET*TPEL + FLUXSEPIN*AP*TSOL))/(FLUXHEAT*AP)
	

C	SUM ENERGY LOSS FRACTIONS = 1
	IF(IPFLUX.EQ.1) FRACRAD = 0.0 
	FRACTOT = FRACRAD + FRACRADIV + FRACWALL + FRACION
C	CONFINEMENT DEGRADATION
	IF(JJOPTPED.NE.10) GOTO 175
	CALL DENLIM
C	CHECK CONVERGENCE DIVERTOR PLASMA PARTICLE, MOMENTUM & ENERGY BALANCES 
175	EP = 1.E-4
200   IF (ABS(XNDB/XND - 1.).GT.EP) GOTO 20
	EP = 1.E-4
	IF (ABS(TDB/TD - 1.).GT.EP) GOTO 20
	EP = 1.E-4
	IF (ABS(XNSEPB/XNSEP - 1.).GT.EP) GOTO 20
	x = xn0
	x = xnped
	x = deltb
	x = xnel
C	CONVERGE SOL/DIV PLASMA & NEUTRAL CALCULATIONS
c	***this is for 98893 @ 4000*****
c	if(itern.eq.30) goto 500
c	***********************************	 
	EPN = 1.E-4 
	x = taun
C	IF(ABS(RPARTN-1.).GT.EPN) GOTO 20
C	IF(ABS(RPARTP-1.).GT.EPN) GOTO 20
C	IF(ABS(RPARTT-1.).GT.EPN) GOTO 20
C	CONVERGE CORE CALCULATION
	IF(ABS(RPARTC-1.).GT.EPN) GOTO 20
C	CONVERGE TOTAL NUMBER PARTICLES IN CHAMBER
C	IF(ABS(RPARTTC-1.).GT.EPN) GOTO 20	
	IF(ITERN.LE.15) GOTO 20	
C		INTERPOLATE ON VALUES IN DIVERTOR CHANNEL
c	***temporary to 'converge' 98893***********
c	if(itern.ge.30) goto 500
c	*******************************************
c		CONVERGE ON PARTICLE & HEAT FLUXES
	EP = 1.E-4
	IF(ABS(FLUXPARTOLD/FLUXPART-1.).GT.EP) GOTO 20
	IF(IPFLUX.EQ.2) GOTO 500
	IF(ABS(FLUXHEATOLD/FLUXHEAT-1.).GT.EP) GOTO 20
	x = omreweakI(14)
	x=ap
	x=vp
	       write(*,*) 'T0 =', T0
       write(*,*) 'TPED =', TPED
	   write(*,*) 'tpedexi =', tpedexi
	   write(*,*) 'tpedexe =', tpedexe
       write(*,*) 'TSOL =', TSOL
       write(*,*) 'TSEP =', TSEP
	   write(*,*) 'tsepexi =', tsepexi
	   write(*,*) 'tsepexe =', tsepexe
       write(*,*) 'XN0 =', XN0
       write(*,*) 'XNPED =', XNPED
	   write(*,*) 'xnpedex =', xnpedex
       write(*,*) 'XNSOL =', XNSOL
       write(*,*) 'XNSEP =', XNSEP
       write(*,*) 'xnsepex =', xnsepex
	GOTO 500
450	ITSTOP = 1
	       write(*,*) 'T0 =', T0
       write(*,*) 'TPED =', TPED
	   write(*,*) 'tpedexi =', tpedexi
	   write(*,*) 'tpedexe =', tpedexe
       write(*,*) 'TSOL =', TSOL
       write(*,*) 'TSEP =', TSEP
	   write(*,*) 'tsepexi =', tsepexi
	   write(*,*) 'tsepexe =', tsepexe
       write(*,*) 'XN0 =', XN0
       write(*,*) 'XNPED =', XNPED
	   write(*,*) 'xnpedex =', xnpedex
       write(*,*) 'XNSOL =', XNSOL
       write(*,*) 'XNSEP =', XNSEP
       write(*,*) 'xnsepex =', xnsepex
	GOTO 500	 
475	ITSTOP = 2 
	XXX=Q95
	XXX=TAUE
	XXX=HCONF	
500	RETURN
	END
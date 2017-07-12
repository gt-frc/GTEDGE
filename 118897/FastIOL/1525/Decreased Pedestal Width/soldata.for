      
	  SUBROUTINE SOLDATA(nbdep1,nbdep2,nbdep3,erextot,fpsi0,fb)

c*****************************************************************
c     Reads data in from text files and defines edge profiles from 
c     the DIII-D database
c*****************************************************************

	INCLUDE 'SOLDIV.FI'

	real ibal,imod,ioptsep,vplas,ioptgeom,dchirat,changeouter,tw,
	1     gammid,xlmid,czd(25),cmid,delsol,rwall,ioptdel,ioptpump,
	2     hxpt,riol,bpiol,btiol,psireal,vpold,vtord
	real nbdep1(51),nbdep2(51),nbdep3(51), erextot(51), fpsi0(51),
	1    fb(3)

	
	NAMELIST/GEOM/IOPTSN,ZX,RX,RSEP1,ZSEP1,RSEP2,ZSEP2,RDOME,PHIDOME,
	2		XRING,ZRING,DELLT1,DELLT2,YPUMP1,YPUMP2,
     3		RPUMP1,RPUMP2,R1,R2,PHITRAN,RINROUT,XLWPL1,XLWPL2,XLUP1,
     4		XLWPF1,XLWPF2,XLWSPL,elong,AMINOR,RMAJOR,TRIANG,DELXreal
     5		,DELXPT,zdome,xdome

	
	NAMELIST/CORE/IPFLUX,IBAL,IMOD,ISHEATH,FLUXPART,FLUXHEAT,FRACRAD,
     2    	TSEP,TD,TSOL,TBAR,TPED,TPLAS,TAV,XND,XNOD,XNPLAS,XNPED,
     3        XNBAR,XNSEP,XNSOL,XNDIV,XNOSOL,XNODIV,IOPTSEP,DELRATNT,
     4		DELRATNV,IOPTDEL,PFUSION,FLUXNEUTIN,FLUXIONIN,IOPTPROF,
	5		IOPTOHM,POHMIN
	

	NAMELIST/PARAM/B,IOPTQ95,Q95,GAMSHEATH,IOPTRAD,TAURES,IZINJECT,
	1        FZINJECT,AZINJECT,AZTRACE,IZTRACE,REDKAPPA,SOLNMULT,
     2 SOLTMULT,IZINTRIN,FZINTRIN,FHE,FBE,VPLAS,DELSOL,IOPTSOL,XNATOM,
     3    XLZRAD,FS,ALB,IOPTGEOM,CHANGE,CHANGEOUTER,DELNMAX,DELNMIN,
     4        DCHIRAT,ENHANCE,QZMULTDIV,CHIRSOL,FUDGE,REDKAPPA2,
	5  XDSEP,ASYMPART,ASYMHEAT,ioptdiv,deld,divdepth,xenhance,ZHGHT
	NAMELIST/GASNEUT/REFLECT,TW,GAMDIV,GAMMID,XLMID,CZD,CMID,EIOND,
     2                 EIONSOL,RWALL,EEX
	NAMELIST/XSECT1/IOPTLYMAN,ELAST,ELASTN
	NAMELIST/XSECT2/CX,EION
	NAMELIST/XSECT3/REC,TINT,ZNINT,FREC
	NAMELIST/GASNEUT2/BETAG,FPF,FPD,THETA,FMOL,FUELPF,FUELPLOUT,
     2	FUELPLIN,FUELMP,SPELLET,RWPF,RWPL,HXPT,
     3	RWSOL,XMSOL,HNDIV,HVSOL,HVDIV,HTSOL,HTDIV,DELTB,DELPED,
     4	RWDP,IOPTPUMP,DELPUMP,RPUMP,PUMPSPEED,HNSOL,wtxpt,
	5	EPDIV,FRACXPT,IMAT,IMOL,FEX,TSOR,AMU,wallmult,iopttheta,
	6	REABSORBD,REABSORBDIV,REABSORBSOL,REABSORBCOR,IOPTELN,IOPTSOLN
 	NAMELIST/PEDBAR/NBAR,NPED,GRADTPEDIS,XNU,ZEFF,Z0,CFZINJ,
     2	CFZINT,cfzinjtb,cfzinttb,ALPHAT1,ALPHAT2,IOPTPEDWIDTH,CPED,
     3	A1,A2,CHIREDGE,PLASMACUR,PBEAM,ENBI,PHIIN,RADMULT,TAVMULT,
	2    IOPTPART,HRAT,RHOGAUSS,SIGMA,ZEFFC,DPERP,TAUE,TAURATIO,HCONF,
	3	c89,CHEI,ALPHAN,RCOEF,XNCTRPED,TCTRPED,NNEUT,IOPTPED,FION,
	4	RXLTIXLTE,ERAD,VPHI,VTHET,VRAD,XNUBAR,XLQ,XLE,XLVTHET,ISHAPE,
	5	C89N,CC,XLVPHI,XNAV,AMASS,XNRHOPED,RSYN,IPROF,JJOPTPED,
	6 IOPTGRAD,FCOND,CBALLOON,HN,QZMULTCORE,PEDFAC,CHIRTBI,CHIRTBE,
	7	cPINCH,VPINCH,DTBI,IOPTLN,CIE,CNE,HEATFRACE,IOPTPINCH,CPED2,
     8  CPED1,JOPTPED2,fluxheatianom,fluxheateanom,IGRADPED,FI,IOPTCONF,
	9	IDRAKE,SHEARQ,CBALL,FISEP,CHITBLI,CHITBLE,SHEAR0,CSHEAR,ASS,
	1	IOPTTAUE,IOPTTRAN,MODPED,FSHAPE,CMHD,ccrit,cmfp

	NAMELIST/EXPDATA/XNPEDEX,XNSEPEX,TPEDEXI,TSEPEXI,GRADNBAR,GRADTBAR
     2,GRADNPED,GRADTPED,GRADTEBAR,CHIRC,CHIBAR,CHIRMARF,APED,TPEDAV, 
	3DREDGE,TPEDEXE,TSEPEXE,WIDTHNX,WIDTHTEX,WIDTHTIX, 
	4  dln_dt,dlnw_dt,wmhd,pradcorex,ssi95,chii0,chie0,xkrtherm,
	5  dlnnped_dt,dlnpped_dt
	NAMELIST/EDGE/IOPTEDGE,PHITE,IGRAD,XLT11,XLV1,FRACZ,ZION,ZIMP,
     1		AION,AIMP,BPHI,YLTIbarx,YLNBARX,YLVBARX,eb,abeam,rtan,
     2		alphain,VPHIAPEDX,DELNA,ephia,enh,sindeno,yltebarx,
     3		joptedped,SHEARM,dedr,sheare,ioptvphi,ioptpinchi,
     4	ioptvdif,ioptxlvm,sheareconst,fheate,ioptran,
	5	chixpi,chixpe,chitop,chetop,teintop,tiintop,xnintop,xltitop,
     5		xltetop,pedrhoti,pedrhote, rhotein,rhotiin,ioptdrag,ylti,
	6		ylte,ioptzerodrag,ioptapproach,iopterad,ioptvthet,
	7		ioptranscoef,erex,  ioptexpdata,xnesepreal,
	8		pedrhon,rhonin,OMEGTSEP1,OMEGTSEP2,OMEGTSEP1C,OMEGTSEP2C,
	9		OMEGTSEP1S,OMEGTSEP2S,anomdrag
	1		,delbsep,ylntop,VTHEXP,TORV,ioptpol


	NAMELIST/EXPROFILE1/EXNE
	NAMELIST/EXPROFILE2/XLNE,exlv
	NAMELIST/EXPROFILE3/XTE
	NAMELIST/EXPROFILE4/EXLTE
	NAMELIST/EXPROFILE5/XTI
	NAMELIST/EXPROFILE6/EXLTI

	NAMELIST/TIMEDEP/dlnn_dt,dlnwe_dt,dlnwi_dt
	namelist/balance/hconf,hrat,alphan,alphat2,cballoon
		
	OPEN(UNIT=10,FILE='DATA10',STATUS='OLD')
      READ (10,GEOM)
      CLOSE (UNIT=10,STATUS='KEEP') 
	OPEN(UNIT=11,FILE='DATA11',STATUS='OLD')
      READ (11,CORE)
 	CLOSE (UNIT=11,STATUS='KEEP')

     
	OPEN(UNIT=12,FILE='DATA12',STATUS='OLD')
      READ (12,PARAM)
      CLOSE (UNIT=12,STATUS='KEEP')
	OPEN(UNIT=13,FILE='DATA13',STATUS='OLD')
      READ (13,GASNEUT)
      CLOSE (UNIT=13,STATUS='KEEP')
C	OPEN(UNIT=14,FILE='DATA14',STATUS='OLD')
C      READ(14,XSECT1)
C      READ(14,XSECT2)
C	READ(14,XSECT3)
C	CLOSE(UNIT=14,STATUS='KEEP')
      open(unit=21,file='balance.txt',status='old')
	read(21,balance)
	close(21,status='keep')
	
	open(unit=14,file='radius_psi.txt',status='old')
 	do 25 j = 1,25
	    do 26 k = 1,9
             read(14,*) riol(j,k)
26        continue
25    continue
	close(14,status='keep')

		IOPTLYMAN = 0
	ELAST(1,1) = 2.7E-14
	ELAST(1,2) = 2.7E-14
	ELAST(1,3) = 4.6E-14
	ELAST(1,4) = 9.2E-14
	ELAST(1,5) = 9.2E-14
	ELAST(1,6) = 9.2E-14 
	ELAST(2,1) = 2.7E-14
	ELAST(2,2) = 2.7E-14
	ELAST(2,3) = 4.6E-14
	ELAST(2,4) = 9.2E-14
	ELAST(2,5) = 9.2E-14
	ELAST(2,6) = 9.2E-14 
	ELAST(3,1) = 4.6E-14
	ELAST(3,2) = 4.6E-14
	ELAST(3,3) = 6.8E-14
	ELAST(3,4) = 9.0E-14
	ELAST(3,5) = 9.0E-14
	ELAST(3,6) = 9.0E-14
	ELAST(4,1) = 9.2E-14
	ELAST(4,2) = 9.2E-14
	ELAST(4,3) = 9.0E-14
	ELAST(4,4) = 16.0E-14
	ELAST(4,5) = 16.0E-14
	ELAST(4,6) = 16.0E-14
	ELAST(5,1) = 9.2E-14
	ELAST(5,2) = 9.2E-14
	ELAST(5,3) = 9.0E-14
	ELAST(5,4) = 16.0E-14
	ELAST(5,5) = 16.0E-14
	ELAST(5,6) = 16.0E-14
	ELAST(6,1) = 9.2E-14
	ELAST(6,2) = 9.2E-14
	ELAST(6,3) = 9.0E-14
	ELAST(6,4) = 16.0E-14
	ELAST(6,5) = 16.0E-14
	ELAST(6,6) = 16.0E-14 
	ELASTN(1) = 2.7E-15
	ELASTN(2) = 6.8E-15
	ELASTN(3) = 16.0E-15
	ELASTN(4) = 16.0E-15
	ELASTN(5) = 16.0E-15
	ELASTN(6) = 16.0E-15 

	CX(1,1)    = 8.0E-15
	CX(1,2)    = 8.0E-15
	CX(1,3)    = 1.2E-14
	CX(1,4)    = 2.8E-14
	CX(1,5)    = 5.6E-14
	CX(1,6)    = 1.2E-13
	CX(2,1)    = 8.0E-15
	CX(2,2)    = 8.0E-15
	CX(2,3)    = 1.2E-14
	CX(2,4)    = 2.8E-14
	CX(2,5)    = 5.6E-14
	CX(2,6)    = 1.2E-13 
	CX(3,1)    = 1.2E-14
	CX(3,2)    = 1.2E-14
	CX(3,3)    = 1.5E-14
	CX(3,4)    = 2.9E-14
	CX(3,5)    = 5.8E-14
	CX(3,6)    = 1.2E-13
	CX(4,1)    = 2.8E-14
	CX(4,2)    = 2.8E-14
	CX(4,3)    = 2.9E-14
	CX(4,4)    = 3.7E-14
	CX(4,5)    = 7.4E-14
	CX(4,6)    = 1.5E-13
	CX(5,1)    = 2.8E-14
	CX(5,2)    = 2.8E-14
	CX(5,3)    = 2.9E-14
	CX(5,4)    = 3.7E-14
	CX(5,5)    = 7.4E-14
	CX(5,6)    = 1.5E-13
	CX(6,1)    = 2.8E-14
	CX(6,2)    = 2.8E-14
	CX(6,3)    = 2.9E-14
	CX(6,4)    = 3.7E-14
	CX(6,5)    = 7.4E-14
	CX(6,6)    = 1.5E-13 
	eion(1,1)  = 3.0E-21
	eion(1,2)  = 7.6E-21
	eion(1,3)  = 5.3E-15
	eion(1,4)  = 3.1E-14
	eion(1,5)  = 1.5E-14
	EION(1,6) =	 7.5E-15
	eion(2,1)  = 3.0E-21
	eion(2,2)  = 7.6E-21
	eion(2,3)  = 8.0E-15
	eion(2,4)  = 3.7E-14
	eion(2,5)  = 1.9E-14
	EION(2,6) =	 9 5E-15
	eion(3,1)  = 3.0E-21
	eion(3,2)  = 7.6E-21
	eion(3,3)  = 1.2E-14
	eion(3,4)  = 4.0E-14
	eion(3,5)  = 2.0E-14
	EION(3,6) =	 1.0E-14
	eion(4,1)  = 3.0E-21
	eion(4,2)  = 7.6E-21
	eion(4,3)  = 2.2E-14
	eion(4,4)  = 6.0E-14
	eion(4,5)  = 3.0E-14
	EION(4,6) =	 1.5E-14
	eion(5,1)  = 3.0E-21
	eion(5,2)  = 7.6E-21
	eion(5,3)  = 2.4E-14
	eion(5,4)  = 8.0E-14
	eion(5,5)  = 4.0E-14
	EION(5,6) =	 2.0E-14
	
	REC(1,1)   = 3.0E-16
	REC(1,2)   = 7.0E-17
	REC(1,3)   = 8.0E-20
	REC(1,4)   = 7.0E-21
	REC(1,5)   = 4.0E-22
	REC(2,1)   = 2.5E-15
	REC(2,2)   = 1.1E-18
	REC(2,3)   = 8.0E-20
	REC(2,4)   = 7.0E-21
	REC(2,5)   = 4.0E-22
	REC(3,1)   = 2.5E-14
	REC(3,2)   = 2.5E-18
	REC(3,3)   = 8.0E-20
	REC(3,4)   = 7.0E-21
	REC(3,5)   = 4.0E-22
	REC(4,1)   = 2.0E-13
	REC(4,2)   = 7.0E-18
	REC(4,3)   = 8.0E-20
	REC(4,4)   = 7.0E-21
	REC(4,5)   = 4.0E-22
	REC(5,1)   = 1.0E-12
	REC(5,2)   = 2.0E-17
	REC(5,3)   = 8.0E-20
	REC(5,4)   = 7.0E-21
	REC(5,5)   = 4.0E-22
	TINT(1) = 0.1
	TINT(2) = 1.0
	TINT(3) = 10.0
	TINT(4) = 100.0
	TINT(5) = 1000.0
	TINT(6) = 10000.0
	ZNINT(1) = 1.0E16
	ZNINT(2) = 1.0E18
	ZNINT(3) = 1.0E20
	ZNINT(4) = 1.0E21
	ZNINT(5) = 1.0E22
	FREC = 1.
	
C	ALL DATA ARE SIGMA-V FROM E.W. THOMAS EVALUATION 9/94.
C	SCHULTZ ELASTIC, JANEV C-X,IONIZATION ****not****LYMAN SUPPRESSED
C	RECOMBINATION FROM POST ALB=JANEV W/COLLISION-RADIATIVE, POST ET AL 10/9/98
C	FIRST INDEX Tn= 1, 10, 100 eV; 2ND INDEX Ti=.1,1,10,100,1000 eV: EL & CX
C    	1ST INDEX LOG10Ne=16,18,20,21,22 MKS; 2ND INDEX Te=.1,1,10,100,1000 eV: ION & RECOM

     
      OPEN(UNIT=15,FILE='DATA15',STATUS='OLD')
      READ(15,GASNEUT2)
	CLOSE(UNIT=15,STATUS='KEEP')
	OPEN(UNIT=16,FILE='DATA16',STATUS='OLD')
      READ(16,PEDBAR)
	CLOSE(UNIT=16,STATUS='KEEP')
	OPEN(UNIT=17,FILE='DATA17',STATUS='OLD')
      READ (17,EXPDATA)
      CLOSE (UNIT=17,STATUS='KEEP')
	OPEN(UNIT=18,FILE='DATA18',STATUS='OLD')
      READ (18,EDGE) 	
      CLOSE (UNIT=18,STATUS='KEEP')	

	ixx = ioptq95
	thetain = theta
	q95in = q95
	CHIRCORE(1) = CHIRC
	SPELLETREAL = SPELLET
	FUELMPREAL = FUELMP  
10	PFUSIONIN = PFUSION 
	BFIELD = B
  	XMASS = XNATOM*1.67E-27
	XK = 1.6E-19 
	FESEP = 1. - FISEP

C		SHEATH BOUNDARY CONDITION
	FSHEATH = 1.0
	IF(ISHEATH.EQ.1) FSHEATH = 1.0/BETAG
C		ATOMS ONLY RECYCLING
	IF(IMOL.NE.0) GOTO 100 
C	RWDP = 1.0	 
	FMOL = 0.0
C		ATOMS + GROUND STATE MOLECULES RECYCLING
100	IF(IMOL.EQ.1) FEX = 0.0
C		CALCULATE RATIO EXP TI & TE GRAD SCALE LENGTHS IN TB
	IF(JJOPTPED.EQ.9) FION = GRADTBAR(4)/GRADTEBAR(4)
	
C		INVERT EXPERIMENTAL GRAD SCALE LENGTHS
	DO 125 I=1,5
	IF(GRADNBAR(I).GT.0.0) GRADNBAR(I) = 1./GRADNBAR(I) 
	IF(GRADTBAR(I).GT.0.0) GRADTBAR(I) = 1./GRADTBAR(I)
	IF(GRADTEBAR(I).GT.0.0) GRADTEBAR(I) = 1./GRADTEBAR(I)
125	CONTINUE
	
C	CONSTRUCT EXPERIMENTAL TRANS BARRIER PARAMETERS
	XNTBEX = 0.5*(XNPEDEX + XNSEPEX)
	TTBEX  = 0.25*(TPEDEXE+TPEDEXI + TSEPEXE+TSEPEXI)
	TTBEXE = 0.5*(TPEDEXE + TSEPEXE)
	TTBEXI = 0.5*(TPEDEXI + TSEPEXI)  

C	SET CHIR IN TB IN CGS FOR GROWTH RATE CALCULATION
	
C	SET CHIR IN TB FOR PREDICTIVE MODE
							 
	CHITBI = 1.E4*CHIREDGE/(1.+CHEI)
	CHITBE = 1.E4*CHIREDGE/(1.+(1./CHEI))
	CHIRTBI = 1.E4*CHIRTBI
	CHIRTBE = 1.E4*CHIRTBE
 
C	CONFINEMENT ADJUSTMENT FACTOR
C		TRIANGULARITY DEPENDENCE OF H89, OSBORNE ET AL, PPCF 42,A175,2000
C	IF(JJOPTPED.EQ.10) HCONF = HCONF + 0.4*TRIANG	
	IF(IOPTTAUE.EQ.89) H89 = HCONF	
	IF(IOPTTAUE.EQ.98) H98 = HCONF	
	
c*****************************************************************
c                             OPTIONS
c     ioptFIOL - NBI ion orbit loss. requires more profiles
c     solovev - more realistic flux surface model for IOL
c     ioptxtran - xtransport (non-operational 9/1/15)
c     ioptionorb - IOL
c     ioptsol - IOL extended into scrape off layer (non-operational 9/1/15)
c     ioptedge - do edgecalc analysis
c     RLOSSIOL - fraction of IOL particles that remain lost
c     NBIspin - fraction of NBI momentum deposited 
c               co-current=1, ctr-current=1.2 are good estimates
c     NBIeloss - fraction of energy lost from NBI IOL
c               co-current=0, ctr-current=0.5 are good estimates
c*****************************************************************     
	if(jjoptped.eq.11) then
	ioptsoln = 1
	ioptpedn = 1
	endif 
	IF(JJOPTPED.EQ.9) IOPTSOLN = 1	
      ioptDdata = 0
	ioptFIOL = 1    	
	solovev = 0
 	ioptxtran = 0
 	ioptionorb = 1
	ioptsol = 0 
	ioptedge =1
	
	RLOSSIOL = 0.5
	NBIspin = 1.0
	NBIeloss = 0.0
c******************************************************
c    Begin shot specific input data
c******************************************************
c	 shot:118897 @ 1525, type: L-mode,  Date: 06/16/2004

c     Electron density [#/m^3]- drvr_pedxax.pro (after profile fitting) 
	  EXNE(1) = 2.1873697E19
	  EXNE(2) = 2.1618605E19
	  EXNE(3) = 2.1304664E19
	  EXNE(4) = 2.0979007E19
	  EXNE(5) = 2.0642321E19
	  EXNE(6) = 2.0294635E19
	  EXNE(7) = 1.9995314E19
	  EXNE(8) = 1.9624985E19
	  EXNE(9) = 1.9242479E19
	  EXNE(10) = 1.8846678E19
	  EXNE(11) = 1.8437257E19
	  EXNE(12) = 1.8085287E19
	  EXNE(13) = 1.7649702E19
	  EXNE(14) = 1.7199142E19
	  EXNE(15) = 1.6732923E19
	  EXNE(16) = 1.6250110E19
	  EXNE(17) = 1.5749690E19
	  EXNE(18) = 1.5318249E19 
	  EXNE(19) = 1.4781566E19
	  EXNE(20) = 1.4222800E19
	  EXNE(21) = 1.3637872E19
	  EXNE(22) = 1.3023108E19
	  EXNE(23) = 1.2483866E19
	  EXNE(24) = 1.1797687E19
	  EXNE(25) = 1.1060181E19
c     Electron density gradient scale length [m]-
c     drvr_pedxax.pro (after profile fitting)
c     xlne = [(1/n)dn/dr]^-1  
	  XLNE(1) = 0.19252524
	  XLNE(2) = 0.18245463
	  XLNE(3) = 0.17220364
	  XLNE(4) = 0.16193371
	  XLNE(5) = 0.15213397
	  XLNE(6) = 0.14291821
	  XLNE(7) = 0.13535642
	  XLNE(8) = 0.12690082
	  XLNE(9) = 0.11870170
	  XLNE(10) = 0.11069239
	  XLNE(11) = 0.10366178
	  XLNE(12) = 0.097398295
	  XLNE(13) = 0.090121754
	  XLNE(14) = 0.082966519 
	  XLNE(15) = 0.076488746
	  XLNE(16) = 0.070842946
	  XLNE(17) = 0.065610495
	  XLNE(18) = 0.061492768
	  XLNE(19) = 0.055322117
	  XLNE(20) = 0.048700338
	  XLNE(21) = 0.041855747
	  XLNE(22) = 0.035529490
	  XLNE(23) = 0.030574293
	  XLNE(24) = 0.024944900
	  XLNE(25) = 0.020421146
c     Toroidal Velocity gradient scale length [m]- 
c     drvr_pedxax.pro (after profile fitting)
c     exlv = [(1/v)dv/dr]^-1	
	  exlv(1) = 0.099907264
	  exlv(2) = 0.098302759
	  exlv(3) = 0.097178333
	  exlv(4) = 0.095968984
	  exlv(5) = 0.094908759
	  exlv(6) = 0.094115645
	  exlv(7) = 0.093452193
	  exlv(8) = 0.092997193
	  exlv(9) = 0.092649236
	  exlv(10) = 0.092600733
	  exlv(11) = 0.094098866
	  exlv(12) = 0.095695309
	  exlv(13) = 0.099696405
	  exlv(14) = 0.10894611
	  exlv(15) = 0.12865447
	  exlv(16) = 0.17365313
	  exlv(17) = 0.31563696
	  exlv(18) = 1.6665398
	  exlv(19) = -0.33385757
	  exlv(20) = -0.13678378
	  exlv(21) = -0.079995945
	  exlv(22) = -0.059999399
	  exlv(23) = -0.056005597
	  exlv(24) = -0.061144128
	  exlv(25) = -0.092714190
c     Electron temperature gradient scale length [m] - 
c     drvr_pedxax.pro (after profile fitting)
c     exlte = [(1/Te)dTe/dr]^-1
	  EXLTE(1) = 0.073618523
	  EXLTE(2) = 0.070358111
	  EXLTE(3) = 0.067036224
	  EXLTE(4) = 0.063593510
	  EXLTE(5) = 0.060230913
	  EXLTE(6) = 0.057008853
	  EXLTE(7) = 0.054306676
	  EXLTE(8) = 0.051261353
	  EXLTE(9) = 0.048255572
	  EXLTE(10) = 0.045288970
	  EXLTE(11) = 0.042691304
	  EXLTE(12) = 0.040353724
	  EXLTE(13) = 0.037631154
	  EXLTE(14) = 0.034962816
	  EXLTE(15) = 0.032592063
	  EXLTE(16) = 0.030604617
	  EXLTE(17) = 0.028835862
	  EXLTE(18) = 0.027512584
	  EXLTE(19) = 0.025426047
	  EXLTE(20) = 0.023168246
	  EXLTE(21) = 0.020815979 
	  EXLTE(22) = 0.018702195
	  EXLTE(23) = 0.017074058
	  EXLTE(24) = 0.015209088
	  EXLTE(25) = 0.013882695
c     Ion temperature [eV]- drvr_pedxax.pro (after profile fitting)	 
	  XTI(1) = 337.24295
	  XTI(2) = 331.49658
	  XTI(3) = 324.65193
	  XTI(4) = 317.88463
	  XTI(5) = 311.21340
	  XTI(6) = 304.66238
	  XTI(7) = 299.31441
	  XTI(8) = 293.05057
	  XTI(9) = 286.97178
	  XTI(10) = 281.09554
	  XTI(11) = 275.45240
	  XTI(12) = 270.95259
	  XTI(13) = 265.79416
	  XTI(14) = 260.92627
	  XTI(15) = 256.39358
	  XTI(16) = 252.18759
	  XTI(17) = 248.35926
	  XTI(18) = 245.46604
	  XTI(19) = 242.36931
	  XTI(20) = 239.67164
	  XTI(21) = 237.46185
	  XTI(22) = 235.67994
	  XTI(23) = 234.65179
	  XTI(24) = 233.94485
	  XTI(25) = 233.55717
c     Ion temperature gradient scale length [m]- 
c     drvr_pedxax.pro (after profile fitting)
c     exlti = [(1/Ti)dTi/dr]^-1
	  EXLTI(1) = 0.12918277
	  EXLTI(2) = 0.12589729
	  EXLTI(3) = 0.12328619
	  EXLTI(4) = 0.12077678
	  EXLTI(5) = 0.11866803
	  EXLTI(6) = 0.11717904
	  EXLTI(7) = 0.11611368
	  EXLTI(8) = 0.11547489
	  EXLTI(9) = 0.11524922
	  EXLTI(10) = 0.11539454
	  EXLTI(11) = 0.11689056
	  EXLTI(12) = 0.11801328
	  EXLTI(13) = 0.11997510
	  EXLTI(14) = 0.12268984
	  EXLTI(15) = 0.12718636
	  EXLTI(16) = 0.13446927
	  EXLTI(17) = 0.14475688
	  EXLTI(18) = 0.15650359
	  EXLTI(19) = 0.17154512
	  EXLTI(20) = 0.19124974
	  EXLTI(21) = 0.21947017
	  EXLTI(22) = 0.27043435
	  EXLTI(23) = 0.35354951
	  EXLTI(24) = 0.63725042
	  EXLTI(25) = -239.16255
c     Electron temperature [eV]- drvr_pedxax.pro (after profile fitting)					
	  XTE(1) = 250.31533
	  XTE(2) = 242.80847
	  XTE(3) = 233.79289
	  XTE(4) = 224.76914
	  XTE(5) = 215.73860
	  XTE(6) = 206.70342
	  XTE(7) = 199.17333
	  XTE(8) = 190.14100
	  XTE(9) = 181.12015
	  XTE(10) = 172.12024
	  XTE(11) = 163.15352
	  XTE(12) = 155.71753
	  XTE(13) = 146.85356
	  XTE(14) = 138.07280
	  XTE(15) = 129.40016
	  XTE(16) = 120.86163
	  XTE(17) = 112.48671
	  XTE(18) = 105.65652
	  XTE(19) = 97.665721
	  XTE(20) = 89.932197
	  XTE(21) = 82.490311
	  XTE(22) = 75.373180
	  XTE(23) = 69.711723
	  XTE(24) = 63.268138
	  XTE(25) = 57.228175 
c     safety factor [1]- EFITtools --> profiles_1_mse
c     need to manually input for GTEDGE rho vector
	  qedge(1) = 2.75
	  qedge(2) = 2.81
	  qedge(3) = 2.86
	  qedge(4) = 2.91
	  qedge(5) = 2.96
	  qedge(6) = 3.01
	  qedge(7) = 3.07
	  qedge(8) = 3.13
	  qedge(9) = 3.19
	  qedge(10) = 3.26
	  qedge(11) = 3.33
	  qedge(12) = 3.39
	  qedge(13) = 3.46
	  qedge(14) = 3.54
	  qedge(15) = 3.62
	  qedge(16) = 3.71
	  qedge(17) = 3.80
	  qedge(18) = 3.89
	  qedge(19) = 4.00
	  qedge(20) = 4.11
	  qedge(21) = 4.29
	  qedge(22) = 4.50
	  qedge(23) = 4.74
	  qedge(24) = 4.94
	  qedge(25) = 5.11
c     Radial Electric Field [V/m]- drvr_pedxax.pro (after profile fitting)
	  erex(1) = 3.7415425e3
	  erex(2) = 3.6929359e3
	  erex(3) = 3.6415041e3
	  erex(4) = 3.5977357e3
	  erex(5) = 3.5618904e3
	  erex(6) = 3.5331924e3
	  erex(7) = 3.5081408e3
	  erex(8) = 3.4927416e3
	  erex(9) = 3.4758651e3
	  erex(10) = 3.4894741e3
	  erex(11) = 3.5237794e3
	  erex(12) = 3.5783314e3
	  erex(13) = 3.6904000e3
	  erex(14) = 3.8686733e3
	  erex(15) = 3.7089182e3
	  erex(16) = 3.3996067e3
	  erex(17) = 3.1213456e3
	  erex(18) = 2.9032118e3
	  erex(19) = 2.6415452e3
	  erex(20) = 2.3555923e3
	  erex(21) = 2.8785988e3
	  erex(22) = 3.7848926e3
	  erex(23) = 4.7137862e3
	  erex(24) = 5.7800150e3
	  erex(25) = 6.5181038e3
c     Carbon Poloidal Velocity [m/s]- drvr_pedxax.pro (after profile fitting)
c	rh sign convention + is down at outer midplane
	  vthexp(1) = -1.319614e3
	  vthexp(2) = -1.248379e3
	  vthexp(3) = -1.160765e3
	  vthexp(4) = -1.070819e3
	  vthexp(5) = -0.978523e3
	  vthexp(6) = -0.883860e3
	  vthexp(7) = -0.803152e3
	  vthexp(8) = -0.703830e3
	  vthexp(9) = -0.597886e3
	  vthexp(10) = -0.47881e3
	  vthexp(11) = -0.34002e3
	  vthexp(12) = -0.20460e3
	  vthexp(13) = -0.01267e3
	  vthexp(14) = 0.217552e3
	  vthexp(15) = 0.466815e3
	  vthexp(16) = 0.608837e3
	  vthexp(17) = 0.485917e3
	  vthexp(18) = 0.139662e3
	  vthexp(19) = -0.33155e3
	  vthexp(20) = -0.54061e3
	  vthexp(21) = -0.27845e3
	  vthexp(22) = 0.326296e3
	  vthexp(23) = 0.964715e3
	  vthexp(24) = 1.738881e3
	  vthexp(25) = 2.354544e3
c     Carbon Toroidal Velocity [m/s]- drvr_pedxax.pro (after profile fitting)
	  torv(1) = 16.820131e3
	  torv(2) = 16.452213e3
	  torv(3) = 16.020493e3
	  torv(4) = 15.599724e3
	  torv(5) = 15.190295e3
	  torv(6) = 14.792582e3
	  torv(7) = 14.470380e3
	  torv(8) = 14.095130e3 
	  torv(9) = 13.732619e3
	  torv(10) = 13.383551e3
	  torv(11) = 13.049957e3
	  torv(12) = 12.786238e3
	  torv(13) = 12.490224e3
	  torv(14) = 12.220532e3
	  torv(15) = 11.992431e3 
	  torv(16) = 11.810463e3 
	  torv(17) = 11.694120e3 
	  torv(18) = 11.657399e3
	  torv(19) = 11.697734e3
	  torv(20) = 11.813664e3
	  torv(21) = 12.038557e3
	  torv(22) = 12.359969e3
	  torv(23) = 12.665104e3
	  torv(24) = 13.014996e3
	  torv(25) = 13.281311e3
c     Density time derivative correction [#/m^3-s]- drvr_pedtimed.pro (after profile fitting)	  
	  dlnn_dt(1) = 21.451479
	  dlnn_dt(2) = 22.012192
	  dlnn_dt(3) = 22.707678
	  dlnn_dt(4) = 23.445950
	  dlnn_dt(5) = 24.221222
	  dlnn_dt(6) = 25.049591
	  dlnn_dt(7) = 25.790287
	  dlnn_dt(8) = 26.715702
	  dlnn_dt(9) = 27.706221
	  dlnn_dt(10) = 28.751131
	  dlnn_dt(11) = 29.864323
	  dlnn_dt(12) = 30.833614
	  dlnn_dt(13) = 32.022797
	  dlnn_dt(14) = 33.234135
	  dlnn_dt(15) = 34.374599
	  dlnn_dt(16) = 35.419487
	  dlnn_dt(17) = 36.114861
	  dlnn_dt(18) = 36.124050
	  dlnn_dt(19) = 34.244949
	  dlnn_dt(20) = 25.865040
	  dlnn_dt(21) = 9.9370651
	  dlnn_dt(22) = -0.84176904
	  dlnn_dt(23) = -4.1709013
	  dlnn_dt(24) = -6.2106180
	  dlnn_dt(25) = -8.8766699
c     Electron temperature time derivative correction [eV/s]- drvr_pedtimed.pro (after profile fitting)
	  dlnwe_dt(1) = 36.558975
	  dlnwe_dt(2) = 37.362263
	  dlnwe_dt(3) = 38.389202
	  dlnwe_dt(4) = 39.485363
	  dlnwe_dt(5) = 40.647419
	  dlnwe_dt(6) = 41.870056
	  dlnwe_dt(7) = 42.919682
	  dlnwe_dt(8) = 44.195778
	  dlnwe_dt(9) = 45.447800
	  dlnwe_dt(10) = 46.602833
	  dlnwe_dt(11) = 47.551537
	  dlnwe_dt(12) = 48.085224
	  dlnwe_dt(13) = 48.263508
	  dlnwe_dt(14) = 47.726707
	  dlnwe_dt(15) = 46.256271
	  dlnwe_dt(16) = 43.681190
	  dlnwe_dt(17) = 39.893795
	  dlnwe_dt(18) = 35.792614
	  dlnwe_dt(19) = 29.779970
	  dlnwe_dt(20) = 22.646852
	  dlnwe_dt(21) = 14.556981
	  dlnwe_dt(22) = 5.8740163
	  dlnwe_dt(23) = -1.3822538
	  dlnwe_dt(24) = -9.4887562
	  dlnwe_dt(25) = -16.367039
c     Ion temperature time derivative correction [eV/s]- drvr_pedtimed.pro (after profile fitting)
	  dlnwi_dt(1) = 26.352587
	  dlnwi_dt(2) = 26.596733
	  dlnwi_dt(3) = 26.862871
	  dlnwi_dt(4) = 27.089596
	  dlnwi_dt(5) = 27.268682
	  dlnwi_dt(6) = 27.388420
	  dlnwi_dt(7) = 27.434895
	  dlnwi_dt(8) = 27.415813
	  dlnwi_dt(9) = 27.303696
	  dlnwi_dt(10) = 27.084433
	  dlnwi_dt(11) = 26.744419
	  dlnwi_dt(12) = 26.358809
	  dlnwi_dt(13) = 25.755333
	  dlnwi_dt(14) = 24.987238
	  dlnwi_dt(15) = 24.033998
	  dlnwi_dt(16) = 22.879198
	  dlnwi_dt(17) = 21.505114
	  dlnwi_dt(18) = 20.180796
	  dlnwi_dt(19) = 18.354767
	  dlnwi_dt(20) = 16.253643
	  dlnwi_dt(21) = 13.861624
	  dlnwi_dt(22) = 11.160252
	  dlnwi_dt(23) = 8.6505585
	  dlnwi_dt(24) = 5.3311157
	  dlnwi_dt(25) = 1.6457300
	  
	if(ioptDdata.eq.1) then
c     Deuterium Toroidal Velocity [m/s]- drvr_pedxax.pro OR from personal contact (after profile fitting)
      vtord(1) = 7.41e+04
      vtord(2) = 7.43e+04
      vtord(3) = 7.45e+04
      vtord(4) = 7.47e+04
      vtord(5) = 7.52e+04
      vtord(6) = 7.57e+04
      vtord(7) = 7.62e+04
      vtord(8) = 7.69e+04
      vtord(9) = 7.77e+04
      vtord(10) = 7.84e+04
      vtord(11) = 7.92e+04
      vtord(12) = 8.03e+04
      vtord(13) = 8.11e+04
      vtord(14) = 8.22e+04
      vtord(15) = 8.34e+04
      vtord(16) = 8.44e+04
      vtord(17) = 8.56e+04
      vtord(18) = 8.67e+04
      vtord(19) = 8.80e+04
      vtord(20) = 8.94e+04
      vtord(21) = 9.05e+04
      vtord(22) = 9.19e+04
      vtord(23) = 9.34e+04
      vtord(24) = 9.46e+04
      vtord(25) = 9.60e+04
c     Deuterium Poloidal Velocity [m/s]- drvr_pedxax.pro OR from personal contact (after profile fitting)
      vpold(1) = -5.23e+02
      vpold(2) = -6.08e+02
      vpold(3) = -6.93e+02
      vpold(4) = -7.73e+02
      vpold(5) = -9.07e+02
      vpold(6) = -1.04e+03
      vpold(7) = -1.15e+03
      vpold(8) = -1.32e+03
      vpold(9) = -1.50e+03
      vpold(10) = -1.65e+03
      vpold(11) = -1.84e+03
      vpold(12) = -2.09e+03
      vpold(13) = -2.29e+03
      vpold(14) = -2.53e+03
      vpold(15) = -2.83e+03
      vpold(16) = -3.10e+03
      vpold(17) = -3.43e+03
      vpold(18) = -3.70e+03
      vpold(19) = -4.10e+03
      vpold(20) = -4.50e+03
      vpold(21) = -4.84e+03
      vpold(22) = -5.30e+03
      vpold(23) = -5.84e+03
      vpold(24) = -6.28e+03
      vpold(25) = -6.81e+03
	endif
	
	if (ioptFIOL.eq.0) goto	500
c*************************************************
c     Input for neutral beam fast IOL calculation
c     Requires full profiles for rho [0,1]
c     Requires output data from NBeams 
c**************************************************
c	 shot:118897 @ 1525,  type:L-mode,  date:06/16/2004

c     Radial electric field [V/m] for rho [0,1], deltarho = 0.02
c     drvr_pedxax.pro (after profile fitting)
      erextot(1) = 3.3121499E3
      erextot(2) = 2.6368629E3
      erextot(3) = 3.6683018E3
      erextot(4) = 4.7778509E3
      erextot(5) = 5.8776332E3
      erextot(6) = 7.1588222E3
      erextot(7) = 8.6056368E3
      erextot(8) = 9.7499268E3
      erextot(9) = 10.837887E3
      erextot(10) = 11.827904E3
      erextot(11) = 12.712500E3
      erextot(12) = 13.491453E3
      erextot(13) = 14.158440E3
      erextot(14) = 14.730339E3
      erextot(15) = 15.197243E3
      erextot(16) = 15.557585E3
      erextot(17) = 15.805949E3
      erextot(18) = 15.970826E3
      erextot(19) = 16.031530E3
      erextot(20) = 15.986905E3
      erextot(21) = 15.861578E3
      erextot(22) = 15.650425E3
      erextot(23) = 15.352949E3
      erextot(24) = 14.988447E3
      erextot(25) = 14.553234E3
      erextot(26) = 14.046701E3
      erextot(27) = 13.497952E3
      erextot(28) = 12.889992E3
      erextot(29) = 12.257851E3
      erextot(30) = 11.579974E3
      erextot(31) = 10.866789E3
      erextot(32) = 10.173106E3
      erextot(33) = 9.4582213E3
      erextot(34) = 8.7712153E3
      erextot(35) = 8.0989320E3
      erextot(36) = 7.4425090E3
      erextot(37) = 6.8154198E3
      erextot(38) = 6.2320664E3
      erextot(39) = 5.6986234E3
      erextot(40) = 5.2088631E3
      erextot(41) = 4.7466070E3
      erextot(42) = 4.3452740E3
      erextot(43) = 4.0062439E3
      erextot(44) = 3.7518419E3
      erextot(45) = 3.5851048E3
      erextot(46) = 3.4941071E3
      erextot(47) = 3.5353637E3
      erextot(48) = 3.8692847E3
      erextot(49) = 2.8599295E3
      erextot(50) = 3.2307575E3
      erextot(51) = 6.5181038E3

c     Neutral beam deposition profile (hofr1) from NBeams (Dr. John Mandrekas)
c     units [#/s] - need to convert to GTEDGE rho coordinates using MATLAB script
c     nbeams2gtedge.m	from T.M.Wilks
      NBdep1(1) = .55043E+01
      NBdep1(2) = .11069E+02
      NBdep1(3) = .72842E+01
      NBdep1(4) = .64230E+01
      NBdep1(5) = .59440E+01
      NBdep1(6) = .55694E+01
      NBdep1(7) = .52320E+01
      NBdep1(8) = .49066E+01
      NBdep1(9) = .45870E+01
      NBdep1(10) = .42714E+01
      NBdep1(11) = .39624E+01
      NBdep1(12) = .36628E+01
      NBdep1(13) = .33760E+01
      NBdep1(14) = .31045E+01
      NBdep1(15) = .28502E+01
      NBdep1(16) = .25501E+01
      NBdep1(17) = .22085E+01
      NBdep1(18) = .19862E+01
      NBdep1(19) = .18104E+01
      NBdep1(20) = .16643E+01
      NBdep1(21) = .15398E+01
      NBdep1(22) = .14321E+01
      NBdep1(23) = .13378E+01
      NBdep1(24) = .12543E+01
      NBdep1(25) = .11801E+01
      NBdep1(26) = .11138E+01
      NBdep1(27) = .10541E+01
      NBdep1(28) = .10000E+01
      NBdep1(29) = .95082E+00
      NBdep1(30) = .90573E+00
      NBdep1(31) = .86413E+00
      NBdep1(32) = .82561E+00
      NBdep1(33) = .78980E+00
      NBdep1(34) = .75612E+00
      NBdep1(35) = .72417E+00
      NBdep1(36) = .69377E+00
      NBdep1(37) = .66444E+00
      NBdep1(38) = .63588E+00
      NBdep1(39) = .60774E+00
      NBdep1(40) = .57984E+00
      NBdep1(41) = .55191E+00
      NBdep1(42) = .52368E+00
      NBdep1(43) = .49496E+00
      NBdep1(44) = .46551E+00
      NBdep1(45) = .43520E+00
      NBdep1(46) = .40369E+00
      NBdep1(47) = .37087E+00
      NBdep1(48) = .33637E+00
      NBdep1(49) = .29990E+00
      NBdep1(50) = .26082E+00
      NBdep1(51) = .00000E+00

      NBdep2(1) = .42840E+01
      NBdep2(2) = .86254E+01
      NBdep2(3) = .56889E+01
      NBdep2(4) = .50322E+01
      NBdep2(5) = .46753E+01
      NBdep2(6) = .44018E+01
      NBdep2(7) = .41597E+01
      NBdep2(8) = .39286E+01
      NBdep2(9) = .37027E+01
      NBdep2(10) = .34795E+01
      NBdep2(11) = .32604E+01
      NBdep2(12) = .30464E+01
      NBdep2(13) = .28400E+01
      NBdep2(14) = .26429E+01
      NBdep2(15) = .24569E+01
      NBdep2(16) = .22294E+01
      NBdep2(17) = .19621E+01
      NBdep2(18) = .17917E+01
      NBdep2(19) = .16578E+01
      NBdep2(20) = .15466E+01
      NBdep2(21) = .14519E+01
      NBdep2(22) = .13700E+01
      NBdep2(23) = .12982E+01
      NBdep2(24) = .12344E+01
      NBdep2(25) = .11777E+01
      NBdep2(26) = .11269E+01
      NBdep2(27) = .10811E+01
      NBdep2(28) = .10394E+01
      NBdep2(29) = .10014E+01
      NBdep2(30) = .96630E+00
      NBdep2(31) = .93371E+00
      NBdep2(32) = .90334E+00
      NBdep2(33) = .87489E+00
      NBdep2(34) = .84777E+00
      NBdep2(35) = .82153E+00
      NBdep2(36) = .79618E+00
      NBdep2(37) = .77112E+00
      NBdep2(38) = .74602E+00
      NBdep2(39) = .72053E+00
      NBdep2(40) = .69441E+00
      NBdep2(41) = .66731E+00
      NBdep2(42) = .63888E+00
      NBdep2(43) = .60888E+00
      NBdep2(44) = .57694E+00
      NBdep2(45) = .54294E+00
      NBdep2(46) = .50630E+00
      NBdep2(47) = .46701E+00
      NBdep2(48) = .42459E+00
      NBdep2(49) = .37864E+00
      NBdep2(50) = .32794E+00
      NBdep2(51) = .00000E+00

      NBdep3(1) = .32670E+01
      NBdep3(2) = .65839E+01
      NBdep3(3) = .43514E+01
      NBdep3(4) = .38613E+01
      NBdep3(5) = .36022E+01
      NBdep3(6) = .34089E+01
      NBdep3(7) = .32416E+01
      NBdep3(8) = .30840E+01
      NBdep3(9) = .29312E+01
      NBdep3(10) = .27805E+01
      NBdep3(11) = .26324E+01
      NBdep3(12) = .24870E+01
      NBdep3(13) = .23460E+01
      NBdep3(14) = .22104E+01
      NBdep3(15) = .20817E+01
      NBdep3(16) = .19174E+01
      NBdep3(17) = .17173E+01
      NBdep3(18) = .15931E+01
      NBdep3(19) = .14968E+01
      NBdep3(20) = .14172E+01
      NBdep3(21) = .13497E+01
      NBdep3(22) = .12916E+01
      NBdep3(23) = .12408E+01
      NBdep3(24) = .11958E+01
      NBdep3(25) = .11559E+01
      NBdep3(26) = .11203E+01
      NBdep3(27) = .10884E+01
      NBdep3(28) = .10591E+01
      NBdep3(29) = .10326E+01
      NBdep3(30) = .10082E+01
      NBdep3(31) = .98526E+00
      NBdep3(32) = .96386E+00
      NBdep3(33) = .94371E+00
      NBdep3(34) = .92422E+00
      NBdep3(35) = .90484E+00
      NBdep3(36) = .88581E+00
      NBdep3(37) = .86636E+00
      NBdep3(38) = .84613E+00
      NBdep3(39) = .82477E+00
      NBdep3(40) = .80195E+00
      NBdep3(41) = .77726E+00
      NBdep3(42) = .75023E+00
      NBdep3(43) = .72054E+00
      NBdep3(44) = .68771E+00
      NBdep3(45) = .65158E+00
      NBdep3(46) = .61131E+00
      NBdep3(47) = .56696E+00
      NBdep3(48) = .51794E+00
      NBdep3(49) = .46373E+00
      NBdep3(50) = .40260E+00
      NBdep3(51) = .00000E+00

c      cosine of angle between injected NB particle and Bphi
      fpsi0(1) =  -6.05E-01
      fpsi0(2) =  -6.05E-01
      fpsi0(3) =  -6.04E-01
      fpsi0(4) =  -6.04E-01
      fpsi0(5) =  -6.04E-01
      fpsi0(6) =  -6.03E-01
      fpsi0(7) =  -6.02E-01
      fpsi0(8) =  -6.02E-01
      fpsi0(9) =  -6.01E-01
      fpsi0(10) = -6.00E-01
      fpsi0(11) = -5.98E-01
      fpsi0(12) = -5.97E-01
      fpsi0(13) = -5.95E-01
      fpsi0(14) = -5.93E-01
      fpsi0(15) = -5.92E-01
      fpsi0(16) = -5.89E-01
      fpsi0(17) = -5.86E-01
      fpsi0(18) = -5.83E-01
      fpsi0(19) = -5.80E-01
      fpsi0(20) = -5.77E-01
      fpsi0(21) = -5.75E-01
      fpsi0(22) = -5.72E-01
      fpsi0(23) = -5.69E-01
      fpsi0(24) = -5.67E-01
      fpsi0(25) = -5.64E-01
      fpsi0(26) = -5.61E-01
      fpsi0(27) = -5.59E-01
      fpsi0(28) = -5.56E-01
      fpsi0(29) = -5.53E-01
      fpsi0(30) = -5.51E-01
      fpsi0(31) = -5.48E-01
      fpsi0(32) = -5.46E-01
      fpsi0(33) = -5.43E-01
      fpsi0(34) = -5.41E-01
      fpsi0(35) = -5.38E-01
      fpsi0(36) = -5.36E-01
      fpsi0(37) = -5.34E-01
      fpsi0(38) = -5.31E-01
      fpsi0(39) = -5.29E-01
      fpsi0(40) = -5.27E-01
      fpsi0(41) = -5.25E-01
      fpsi0(42) = -5.24E-01
      fpsi0(43) = -5.22E-01
      fpsi0(44) = -5.21E-01
      fpsi0(45) = -5.20E-01
      fpsi0(46) = -5.19E-01
      fpsi0(47) = -5.19E-01
      fpsi0(48) = -5.19E-01
      fpsi0(49) = -5.20E-01
      fpsi0(50) = -5.23E-01
      fpsi0(51) = -0.00E+00
	  fb(1) = 0.76
	  fb(2) = 0.13
	  fb(3) = 0.11
c*************************************************
c     End neutral beam data
c*************************************************
500   continue

c***************************************************************************
c                 EFITtools Data
c    rmajor - major radius [m] - Plasma Equilibrium
c    aminor - minor radius [m] - Plasma Equilibrium
c    elong - elongation [1] - Plasma Equilibrium
c    triang - lower triangularity [1]	- Plasma Equilibrium
c    plasmacur - plasma current [MA] - Plasma Equilibrium
c    B - magnitude of toroidal magnetic field [T] - Plasma Equilibrium
c    bphi - vector toroidal magnetic field [T] - Plasma Equilibrium
c    q95 - safety factor at 95% flux surface [1] - Plasma Equilibrium
c    pbeam - total beam power [MW] - ReviewPlus 'pinj'
c    Rx - radius of x-point [m] - Plasma Equilibrium
c    zx - height of x-point [m] - Plasma Equilibrium
c    Rsep1 - radius of inside strike point [m] - Plasma Equilibrium
c    Rsep2 - radius of outside strike point [m] - Plasma Equilibrium
c    zsep1 - height of inside strike point [m] - Plasma Equilibrium
c    zsep2 - height of outside strike point [m] - Plasma Equilibrium
c    ssi95 - magnetic shear at 95% flux surface [1] - pointnames_vs_time
c    pohmin - ohmic heating power [MW] - pointnames_vs_time
c    fzintrin - impurity fraction [1] - estimate
c    cfzint - impurity fraction in core [1] - estimate
c    cfzinttb - impurity fraction at transport barrier [1] - estimate
c    fuelpf - fueling rate in private flux region [/s] - estimate
c    fuelplout - fueling rate out of divertor plenum [/s]	- estimate
c    fuelplin - fueling rate into divertor plenum [/s] - estimate
c    tauratio - ratio of particle to energy confinement time [1] - estimate
c    delxp - width of x-region [rad] - estimate
c    delxreal - width from inner to outer plenum in SOL [rad] - estimate
c    fheate - ratio of heat flux to particle flux in SOL [1] - estimate
c***************************************************************************
c		118897 @ 1525ms	 L-mode
		rmajor = 1.7086
		aminor = 0.5965
		elong = 1.8209
		triang = 0.363
		plasmacur = 1.39
   		B = 1.99
		bphi = -1.99
		q95 = 3.541
		pbeam = 4.3
		Rx = 1.48
		zx = -1.238
		Rsep1 = 1.21
		rsep2 = 1.57
		zsep1 = -1.366
		zsep2 = -1.366
		ssi95 = 4.09
		pohmin = 1.36
		fzintrin = 0.03
		cfzint =   0.03
		cfzinttb = 0.03
 		fuelpf = 0.0e21
 		fuelplout = 0.0e19
		fuelplin = 0.0
		fuelmp = 0.0
		tauratio =0.5
		delxpt = 0.1
		delxreal = 0.05
   		fheate = 0.4

c*******************************************************
c                CALCULATED PARAMTERS
c    use GTEDGE input calcs by T.M.Wilks
c*******************************************************
		xnpedex = 1.94e19
		xnsepex = 1.11e19
		tpedexi = 290.
		tsepexi = 235.
		tpedexe = 185.
		tsepexe = 58.
		widthnx = 0.1
		widthtex = 0.1
		widthtix = 0.1
		gradnbar(3) = 1.82e-1
		gradnbar(4) = 1.82e-1
		gradTbar(3) = 0.4773
 		gradTbar(4) = 0.4773
		gradTebar(3) = 0.09567
		gradTebar(4) = 0.09567
		aped = 5.19e-1
		xnctrped = 2.42
		tctrped = 7.0
c*************************************************
c              END INPUT DATA
c*************************************************
		
c	---------------temporary ---------------------
	do 1044 n = 1,25
	dlnwi_dt(n)=0.
	dlnwe_dt(n)=0.
	dlnn_dt(n) = 0.
1044	continue		     
 
c	normalize Rich's gsl to FSA geometry
225	se = sqrt(0.5*(1.+(elong**2)))
	do 250 n=1,26
	xlne(n) = se*xlne(n)
	exlte(n) = se*exlte(n)
	exlti(n) = se*exlti(n)	    	
c	qedge(n) = q95
250	continue
c	save experimental impurity poloidal velocity
	rhor(25) = 1.0
      	 do 255, NN=1,24
		  n= 25-NN
		 rhor(n) = rhor(n+1) - delna/(aminor*SQRT(0.5*(1.+ELONG**2)))
255		 continue 
 
	do 275 n = 1, 25
	vpol_imp(n) = vthexp(n)
275	continue
	do 1150 n = 1,24
	shearho(n) =  (qedge(n+1)-qedge(n))/(rhor(n+1)-rhor(n))
	dEdredge(n) = (erex(n+1)-erex(n))/(rhor(n+1)-rhor(n))
1150	CONTINUE
	shearho(25) = shearho(24) 
	dEdredge(25) = dEdredge(24)
c	smooth derivatives
	do 1155 n =2,24
	shearhonew(n) = (shearho(n-1)+shearho(n)+shearho(n+1))/3.
	dEdrnew(n)= (dEdredge(n-1)+dEdredge(n)+dEdredge(n+1))/3.
1155	continue
 	shearhonew(1)=shearho(1)
	shearhonew(25) = shearho(25)
	dEdrnew(1) = dEdredge(1)
	dEdrnew(25) = dEdredge(25)
	do 1160 n=1,25
	shearho(n) = shearhonew(n)
	dEdredge(n) = Dedrnew(n)
1160	continue 


300   return
	end   
	
	
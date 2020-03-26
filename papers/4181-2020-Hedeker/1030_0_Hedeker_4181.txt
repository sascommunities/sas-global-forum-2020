
/* SAS PROC NLMIXED syntax example  */;
PROC NLMIXED GCONV=1e-12 QPOINTS=11;
PARMS beta0=11.4756 beta_wave6=-0.2306 beta_smk7rate=-1.3321   
alpha0=1.43 alpha_wave6=0 alpha_Smk7rate=0
tau0=2.8726  tau_wave6=0.03296 tau_smk7rate=-0.1792     
corr=0 SD_scale=.005;

varBS = EXP(alpha0 + alpha_wave6*wave6 + alpha_Smk7rate*Smk7rate);
mean  = beta0  + beta_wave6*wave6 + beta_Smk7rate*Smk7rate + SQRT(varBS)*theta1;
varWS = EXP(tau0 + tau_wave6*wave6 + tau_Smk7rate*Smk7rate + SD_scale*theta2);

MODEL TimeHour ~ NORMAL(mean,varWS);
RANDOM theta1 theta2 ~ NORMAL([0,0], [1,corr,1]) SUBJECT=id;
RUN;


/* SAS PROC MCMC syntax example */;
PROC MCMC SEED=9879 NMC=100000 MAXTUNE=50 NBI=500  THIN=25 DIC;
PARMS beta0=11.4756 beta_wave6 -0.2306 beta_smk7rate -1.3321;   
PARMS alpha0=1.43 alpha_wave6=0 alpha_Smk7rate=0;
PARMS tau0=2.8726 tau_wave6 0.03296 tau_smk7rate -0.1792;
PARMS cov=0 ln_varScale=0;  

PRIOR be: ~ NORMAL(0,VAR=10000);
PRIOR al: ~ NORMAL(0,VAR=10000);
PRIOR ta: ~ NORMAL(0,VAR=10000);
PRIOR cov ~ NORMAL(0,VAR=10000);
PRIOR ln_varScale ~ NORMAL(0,VAR=10000);

varBS = EXP(alpha0 + alpha_wave6*wave6 + alpha_Smk7rate*Smk7rate);
varScale = EXP(ln_varScale);

/*cholesky decomposition*/
c11=SQRT(varBS);
c21=cov/c11;
c22=SQRT(varScale-c21**2);

mean  = beta0 + beta_wave6*wave6 + beta_Smk7rate*Smk7rate + c11*sub1l;
varWS = EXP(tau0 + tau_wave6*wave6 + tau_Smk7rate*Smk7rate + c21*sub1l + c22*sub1s);
	  
ARRAY location_scale[2] sub1l sub1s ;
ARRAY var_location_scale[2,2] (1,0,0,1);
ARRAY mu[2](0,0);
 
MODEL TimeHour ~ NORMAL(mean,var=varWS); 
RANDOM location_scale~MVN(mu,var_location_scale) SUBJECT=id;     
RUN; 

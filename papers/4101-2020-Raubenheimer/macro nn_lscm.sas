

%macro nn_LSCM;
ods graphics off;           
ods exclude all; 
	data err;
		hidden = .;
		_VAVERR_ = .;;
		_ITER_ = .;
	run;

	proc dmdb batch data=dev
	          out = dmh_dev
	          dmdbcat=cat_dev;
	   var col1 col2-col35;
	   target col1;
	run;

	data score;
		set score;

		drop col1;
	run;

	%do i = 1 % to 10;

		proc neural data=dev 
					dmdbcat=cat_dev
		            VALIDATA=val 
		            random=12345 ; 

			input col2-col35 / level=interval id=int;
			target col1  / level=interval id=ter;

			hidden &i / id=hu ACT=LOGistic COMBINE=LINEAR;

			netoptions objective = dev;

			train OUTEST= est ESTITER = 1 MAXITER = 50;
			score data=score outfit=netfit out=netout  ;
		 
		run;

		data est;
			set est;

			where _TYPE_ = "PARMS";
		run;
				
		PROC SQL;
		   CREATE TABLE min_err AS 
		   SELECT t1._VAVERR_, 
		          t1._ITER_
		      FROM WORK.EST t1
		      ORDER BY t1._VAVERR_,
		               t1._ITER_;
		QUIT;

		data min_err;
			set min_err;

			if _n_ = 1 then do;
					hidden = &i;
					output;
					call symputx("itt",_ITER_);
			end;

		run;

		data err;
			update err min_err;
			by hidden;
		run;

	%end;

	data err;
		set err;
		where hidden ~= .;
	run; 

	PROC SQL;
	   CREATE TABLE min_hid_err AS 
	   SELECT t1._VAVERR_, 
	          t1._ITER_,
			  t1.hidden
	      FROM WORK.err t1
	      ORDER BY t1._VAVERR_,
	               t1._ITER_,
				   t1.hidden;
	QUIT;

	data min_hid_err;
		set min_hid_err;

		if _n_ = 1 then do;
			call symputx("itt",_ITER_);
			call symputx("hidden",hidden);
		end;

	run;

	proc neural data=dev 
				dmdbcat=cat_dev
	            VALIDATA=val 
	            random=12345  ; 


		input col2-col35 / level=interval id=int;
		target col1  / level=interval id=ter;

		hidden &hidden / id=hu ACT=LOGistic COMBINE=LINEAR;

		netoptions objective = dev;

		train MAXITER = &itt;
		score data=score out=netout  ;
	 
	run;

	data netout;
		set netout;
		keep p_col1;
	run; 

	ods exclude none;

%mend;


proc iml;

	start m(t) global(c1,c2,age);
		m = c1**(-c2)*c2*(age+t)**(c2-1);
		return m;
	finish;

	r0 = 0.05;
	zeta_r  = 0.6;
	delta_r = 0.05;
	sigma_r = 0.03;

	K0 = 0.04;
	zeta_K  = 1.5;
	delta_K = 0.04;
	sigma_K = 0.4;

	S0 = 100;
	rho_SK = -0.7;
	rho_Sr = 0.00;
 	lambda_Y = 0.5;
	mu_Y = 0;
	sigma_Y = 0.07;

	zeta_mu = 0.5;
	sigma_mu = 0.03;
	lambda_mu = 0.1;
	gamma_mu = 0.01;
	c1 = 83.70;
	c2 = 8.3;
	age = 40;

	mu0 = m(0);

	kappa   = 0.02;
	kappa_w = 0.02;

	T = 15;
	M = 19000;

	BDS = 1;
	FDS = 0.01;

	n = T/FDS;
	dt = FDS;

	seed = 1234;
	call randseed(seed);

/*	BM*/
	dZr = J(M,n,0);
	dZS = J(M,n,0);
	dZK = J(M,n,0);
	dZmu = J(M,n,0);

	call randgen(dZr,"Normal");
	call randgen(dZS,"Normal");
	call randgen(dZK,"Normal");
	call randgen(dZmu,"Normal");

/*	jump  Y*/
	jump = J(M,1,0);
	call randgen(jump, 'EXPO', 1/lambda_Y);
	max = 0;
	i   = 2;
	itt = 100;
	do while (max = 0 & i < itt);	
		call randgen(inc, 'EXPO', 1/lambda_Y); 
		jump = jump || jump[,i-1] + inc;
		if (jump[,i])[><] > T then max = 1;
		i = i + 1;
	end;

	jump = jump[,1:i-2];

	JY = jump;
	call randgen(JY, 'normal',mu_Y,sigma_Y);
	do i = 2 to ncol(JY);
		JY[,i] = JY[,i] + JY[,i-1];
	end;

	jump  = J(M,1,0) || jump;
	JY = J(M,1,0) || JY;

	dJY = J(M,n,0);
	loc = do(1,ncol(jump),1) + J(M,ncol(jump),0);

	min0 = J(M,1,1);
	do i = 1 to n;
		tmp = jump;
		tmp[loc(jump <= i*dt)] = 1e6;
		min = tmp[,>:<]-1; 
		if (min=0)[+] >= 1 then min[loc(min=0)] = ncol(jump);
		dJY[,i] = JY[loc(loc = min)] - JY[loc(loc = min0)];
		min0 = min;
	end;


/*	jump  mu*/
	jump = J(M,1,0);
	call randgen(jump, 'EXPO', 1/lambda_mu);
	max = 0;
	i   = 2;
	itt = 100;
	do while (max = 0 & i < itt);	
		call randgen(inc, 'EXPO', 1/lambda_mu); 
		jump = jump || jump[,i-1] + inc;
		if (jump[,i])[><] > T then max = 1;
		i = i + 1;
	end;

	jump = jump[,1:i-2];

	Jmu = jump;
	call randgen(Jmu, 'expo', gamma_mu);
	do i = 2 to ncol(Jmu);
		Jmu[,i] = Jmu[,i] + Jmu[,i-1];
	end;

	jump  = J(M,1,0) || jump;
	Jmu = J(M,1,0) || Jmu;

	dJmu = J(M,n,0);
	loc = do(1,ncol(jump),1) + J(M,ncol(jump),0);

	min0 = J(M,1,1);
	do i = 1 to n;
		tmp = jump;
		tmp[loc(jump <= i*dt)] = 1e6;
		min = tmp[,>:<]-1;
		if (min=0)[+] >= 1 then min[loc(min=0)] = ncol(jump);
		dJmu[,i] = Jmu[loc(loc = min)] - Jmu[loc(loc = min0)];
		min0 = min;
	end;

/*	term structure*/

	rt = J(M,n+1,r0);
	do i = 1 to n;
		rt[,i+1] = rt[,i] + (zeta_r#(delta_r - rt[,i]))#dt + sigma_r#(rt[,i])##0.5#dt##0.5#dZr[,i] + (1/4)#sigma_r##2#dt#(dZr[,i]##2-1) ;
	end;	

/*	volatility*/


	Kt = J(M,n+1,K0);
	do i = 1 to n;
		Kt[,i+1] = Kt[,i] + (zeta_K#(delta_K - Kt[,i]))#dt + sigma_K#(Kt[,i])##0.5#dt##0.5#dZK[,i] + (1/4)#sigma_K##2#dt#(dZK[,i]##2-1) ;
	end;

/*	market value*/

	Yt = J(M,n+1,log(S0));
	
	do i = 1 to n;
		Yt[,i+1] = Yt[,i] + (rt[,i] - 0.5#Kt[,i] - lambda_Y*mu_Y)#dt 
				 + (Kt[,i]##0.5)#(rho_SK#(dt##0.5#dZK[,i]) + rho_Sr#(dt##0.5#dZr[,i]) + (1 - rho_SK**2 - rho_Sr**2)##0.5#(dt##0.5#dZS[,i])) 
				 + dJY[,i];
	end;

	St = exp(Yt);

/*	mortality*/

	mut = J(M,n+1,mu0);
	do i = 1 to n;
		mut[,i+1] = mut[,i] + (zeta_mu#(m(i*dt) - mut[,i]))#dt + sigma_mu#(mut[,i])##0.5#dt##0.5#dZmu[,i]+ (1/4)#sigma_mu##2#dt#(dZmu[,i]##2-1) + dJmu[,i];
	end;

	xi = J(M,1,0);
	call randgen(xi,"EXPO");
	
	gamma_t = mut#dt;
	do i = 2 to n+1;
		gamma_t[,i] = gamma_t[,i] + gamma_t[,i-1];
	end;

	tau = (((gamma_t <= xi)[,+]-1)#dt);
	
	Bt = rt#dt;
	do i = 2 to n+1;
		Bt[,i] = Bt[,i] + Bt[,i-1];
	end;

	Bt = exp(Bt);

	dt = BDS;
	n = T/BDS;

	dtt = do(0,T,dt)/FDS + 1;
	Bt  = Bt[,dtt];
	St  = St[,dtt];
	Yt  = Yt[,dtt];
	rt  = rt[,dtt]; 
	Kt  = Kt[,dtt]; 
	mut = mut[,dtt];

	ekappa   = exp(kappa  #(do(0,T,dt)+J(M,n+1,0)));
	ekappe_w = exp(kappa_W#(do(0,T,dt)+J(M,n+1,0)));
	eSt = St/St[,1];

	Ft_s = S0#(ekappa <> eSt);
	Ft_d = S0#(ekappa <> eSt);
	Ft_w = S0#(ekappe_w <> eSt);

	tau = ceil(tau/dt)#dt;
	theta = tau;

	Pt = Ft_s[,n+1]#(tau = T);

	if ( ( (do(0,T,dt)+J(M,n+1,0) = tau)[,1:n] )[+] >= 1 ) then 
	Pt[loc(Pt=0)] = Ft_d[loc((do(0,T,dt)+J(M,n+1,0) = tau)[,1:n] || J(M,1,0))];

	PE = Pt;

	do i = n-1 to 1 by -1;
		tj = i*dt;

		set = loc(tau > tj);
		Ctj = Pt[set] # ( Bt[set,i+1] / ((Bt[set,])[loc((do(0,T,dt)+J(M,n+1,0))[set,] = theta[set])]) );

		Xtj = rt[set,i+1] || Yt[set,i+1] || Kt[set,i+1] || mut[set,i+1] ;

		Xreg = J(nrow(Xtj),1,1);

		do l = 1 to 4;
			Xreg = xreg || Xtj[,l][,#];
			do j = l to 4;
				Xreg = xreg || Xtj[, (l || j )][,#];
				do k = j to 4;
					Xreg = xreg || Xtj[, (l || j || k)][,#];
				end;	
			end;	
		end;
	
		samp = J(ncol(set),1,0);
		call randgen(samp,"uniform");
		call sortndx(ndx,samp,{1});

		dev = Ctj[ndx[1:int(ncol(set)/2)],] || Xreg[ndx[1:int(ncol(set)/2)],2:35];
		val = Ctj[ndx[int(ncol(set)/2)+1:ncol(set)],] || Xreg[ndx[int(ncol(set)/2)+1:ncol(set)],2:35];

		score = Ctj|| Xreg[,2:35];

		create dev from dev;
		append from dev;
		close dev;
		
		create val from val;
		append from val;
		close val;

		create score from score;
		append from score;
		close score;

		submit;
			%nn_LSCM;
		endsubmit;

		use netout;
		read all var _num_ into Ctj_h;
		close netout;

		tmp = set[loc((Ft_w[set,i+1] > Ctj_h))];

		Pt[tmp] = Ft_w[tmp,i+1];
		theta[tmp] = tj;
		
	end;

	C  = ( Pt # (Bt[,1] / Bt[loc((do(0,T,dt)+J(M,n+1,0)) = theta)])) [:];
	CE = ( PE # (Bt[,1] / Bt[loc((do(0,T,dt)+J(M,n+1,0)) = tau)])) [:];

	out = C || CE;

	create out from out [colname = {'C','CE'}];
	append from out;
	close out;

quit;



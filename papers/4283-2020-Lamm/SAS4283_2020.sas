/*********************************************************/
/* Output in the paper was generated on a 3 worker grid  */
/*********************************************************/


/*********************************************************/
/* Simulation of the example data                        */
/*********************************************************/
proc cas;
   dataStep.runCode result=r/
      single='yes' code=
      'data one;
          call streaminit(1);
          array v{200} v1-v200;
          do i=1 to 10000;
             do j=1 to 200;
                v{j}=rand("normal");
             end;
             f1=-2*sin(2*v1);
             f2=v2*v2-1./3;
             f3=v3-0.5;
             f4=exp(-v4)+exp(-1)-1;
             linp=f1+f2+f3+f4;
             y=rand("normal",linp);
             output;
          end;
       run;'
   ;
   run;
quit;


/*********************************************************/
/* Code for creating Figure 1 True Function Curves       */
/*********************************************************/
proc sql noprint;
  select min(v1),max(v1),min(v2),max(v2),min(v3),max(v3),min(v4),max(v4)
   into :min_v1,:max_v1,:min_v2,:max_v2,:min_v3,:max_v3,:min_v4,:max_v4
  from mycas.one;
quit;

data score(drop=i d1 d2 d3 d4);
   d1=(&max_v1-&min_v1) / 100;
   d2=(&max_v2-&min_v2) / 100;
   d3=(&max_v3-&min_v3) / 100;
   d4=(&max_v4-&min_v4) / 100;
   do i=0 to 100;
   v1=&min_v1+i*d1; f1=-2*sin(2*v1);
   v2=&min_v2+i*d2; f2=v2*v2-1./3;
   v3=&min_v3+i*d3; f3=v3-0.5;
   v4=&min_v4+i*d4; f4=exp(-v4)+exp(-1)-1;
   output;
   end;
run;

proc template;
 define statgraph curves;
    begingraph ;
       entrytitle "True Function Curves";
       layout lattice / columns=2 rows=2;
         layout overlay ;
              seriesplot x=v1 y=f1 ;
         endlayout;
         layout overlay ;
              seriesplot x=v2 y=f2 ;
         endlayout;
         layout overlay ;
              seriesplot x=v3 y=f3 ;
         endlayout;
         layout overlay ;
              seriesplot x=v4 y=f4 ;
         endlayout;
      endlayout;
   endgraph;
end;

ods graphics on;
proc sgrender data=score template=curves;
run;


/*********************************************************/
/* Example 1 Initial PROC GENSELECT Analysis             */
/*********************************************************/
proc genselect data=mycas.one;
   model y = v1-v200;
   selection method = stepwise;
run;

proc genselect data=mycas.one;
   effect spl=spline(v1-v200/separate);
   model y = spl;
   selection method = stepwise;
run;

/*********************************************************/
/* Code for creating partial residual plot Figure 4      */
/*********************************************************/
data score2(drop=i);
   array v{5:200} v5-v200 (196*0);
   do i=1 to 101;
   output;
   end;
run;

data mycas.score;merge score score2;run;

data mycas.scorev1;merge score score2; v2=0;v3=0;v4=0;run;
data mycas.scorev2;merge score score2; v1=0;v3=0;v4=0;run;
data mycas.scorev3;merge score score2; v1=0;v2=0;v4=0;run;
data mycas.scorev4;merge score score2; v1=0;v2=0;v3=0;run;

%macro plotfit(fit,out);
   proc astore;score rstore=&fit data=mycas.scorev1 out=mycas.regscorev1 copyvars=(v1);run;
   proc astore;score rstore=&fit data=mycas.scorev2 out=mycas.regscorev2 copyvars=(v2);run;
   proc astore;score rstore=&fit data=mycas.scorev3 out=mycas.regscorev3 copyvars=(v3);run;
   proc astore;score rstore=&fit data=mycas.scorev4 out=mycas.regscorev4 copyvars=(v4);run;

   data regscorev1(rename=(p_y=f1)); set mycas.regscorev1;run;
   data regscorev2(rename=(p_y=f2)); set mycas.regscorev2;run;
   data regscorev3(rename=(p_y=f3)); set mycas.regscorev3;run;
   data regscorev4(rename=(p_y=f4)); set mycas.regscorev4;run;
   proc sort data=regscorev1;by v1;run;
   proc sort data=regscorev2;by v2;run;
   proc sort data=regscorev3;by v3;run;
   proc sort data=regscorev4;by v4;run;

   data regscore; merge regscorev1 regscorev2 regscorev3 regscorev4;run;

   data mycas.regout1f1; set &out; v2=0;v3=0;v4=0;run;
   data mycas.regout1f2; set &out; v1=0;v3=0;v4=0;run;
   data mycas.regout1f3; set &out; v1=0;v2=0;v4=0;run;
   data mycas.regout1f4; set &out; v1=0;v2=0;v3=0;run;

   proc astore;score rstore=&fit data=mycas.regout1f1 out=mycas.regfitv1 copyvars=(residual v1);run;
   proc astore;score rstore=&fit data=mycas.regout1f2 out=mycas.regfitv2 copyvars=(residual v2);run;
   proc astore;score rstore=&fit data=mycas.regout1f3 out=mycas.regfitv3 copyvars=(residual v3);run;
   proc astore;score rstore=&fit data=mycas.regout1f4 out=mycas.regfitv4 copyvars=(residual v4);run;

   data regfitv1(rename=(v1=var1)); set mycas.regfitv1;pf1=residual+p_y;run;
   data regfitv2(rename=(v2=var2)); set mycas.regfitv2;pf2=residual+p_y;run;
   data regfitv3(rename=(v3=var3)); set mycas.regfitv3;pf3=residual+p_y;run;
   data regfitv4(rename=(v4=var4)); set mycas.regfitv4;pf4=residual+p_y;run;

   data regfit(drop=p_y residual); merge regfitv1 regfitv2 regfitv3 regfitv4;run;

   data fitscore;set regfit regscore;run;
%mend;

proc template;
   define statgraph partialpred2;
   dynamic _title;
   begingraph ;
      entrytitle _title;
      layout lattice / columns=2 rows=2;
         layout overlay / xaxisopts=(label='v1') yaxisopts=(label='f1');
	        scatterplot x=var1 y=pf1 / name='pr' legendlabel='Partial Residual' markerattrs=(symbol=circlefilled size=1 );
             seriesplot x=v1 y=f1 / name='fit' legendlabel='Fit';
         endlayout;
         layout overlay / xaxisopts=(label='v2') yaxisopts=(label='f2');
		scatterplot x=var2 y=pf2 / name='pr' legendlabel='Partial Residual' markerattrs=(symbol=circlefilled size=1 );
             seriesplot x=v2 y=f2 / name='fit' legendlabel='Fit';
         endlayout;
         layout overlay / xaxisopts=(label='v3') yaxisopts=(label='f3');
		 scatterplot x=var3 y=pf3 / name='pr' legendlabel='Partial Residual' markerattrs=(symbol=circlefilled size=1 );
              seriesplot x=v3 y=f3 / name='fit' legendlabel='Fit';
         endlayout;
         layout overlay / xaxisopts=(label='v4') yaxisopts=(label='f4');
		 scatterplot x=var4 y=pf4 / name='pr' legendlabel='Partial Residual' markerattrs=(symbol=circlefilled size=1 );
              seriesplot x=v4 y=f4 / name='fit' legendlabel='Fit';
         endlayout;
      endlayout;
	 layout globallegend / type=row ;
	     discretelegend 'pr' 'fit';
      endlayout;
   endgraph;
end;

proc sql noprint;
   select quote(strip(name),"'") into :splineVars separated by ','
   from dictionary.columns
   where libname = "MYCAS" and memname = "ONE" and
   upcase(name) like 'V%';
quit;

proc cas;
   regression.genmod
   table='one',
   spline={{name='spl',vars={&splineVars},separate=true}},
   model={depVars='y',effects='spl'},
   selection={method='stepwise'},
   output={casout={name='regout1',replace=true},
           pred='p_y',resid='residual',copyvars='all'},
   store={name='glmfit1',replace=true};
run;

%plotfit(mycas.glmfit1,mycas.regout1);
proc sgrender data=fitscore template=partialpred2;
   dynamic _title='Regression Spline Fit by PROC GENSELECT';
run;

/*********************************************************/
/* Example 1 GAMSELECT METHOD=BOOSTING Analysis          */
/*********************************************************/
%macro SplinePrefixList(prefix,n);
   %do i = 1 %to &n;
      spline(&prefix.&i)
      %end;
%mend;

proc gamselect data=mycas.one plots=all;
   model y = %SplinePrefixList(v,200);
   selection method=boosting;
run;

data mycas.one / single=yes;
  set mycas.one;
  call streaminit(1848);
  cvFold = rand("table",0.2,0.2,0.2,0.2,0.2);
run;

proc gamselect data=mycas.one plots=all;
   model y = %SplinePrefixList(v,200);
   selection method=boosting(choose=CV index=cvFold
             stopHorizon=10 stopTol = 0.0005);
run;

proc gamselect data=mycas.one plots=all;
   model y = spline(v1 / df = 10) spline(v2) spline(v3) spline(v4);
   selection method=boosting(choose=CV index=cvFold
             stopHorizon=10 stopTol = 0.0005);
run;

/*********************************************************/
/* Example 1 GRADBOOST Analysis                          */
/*********************************************************/
proc gradboost data=mycas.one seed=1234;
   target y;
   input v1-v200;
   savestate rstore=mycas.gbTreeMod;
   crossvalidation;
run;

proc gradboost data=mycas.one seed=1234 numBin=500;
   target y;
   input v1-v200;
   savestate rstore=mycas.gbTreeMod2;
   crossvalidation;
run;

/*********************************************************/
/* Code for partial dependence plots Figures 17 and 19   */
/*********************************************************/

proc sql noprint;
   select quote(strip(name),"'") into :splineVars separated by ','
   from dictionary.columns
   where libname = "MYCAS" and memname = "ONE" and
   upcase(name) like 'V%';
quit;

%macro pdPlotData( astore, aVar,  meanPred,  odsName);
   ods exclude all;
   ods output PartialDependence = &odsName;
   proc cas;
       action explainModel.partialDependence /
       table            = "one",
       modelTable       = "&astore",
       inputs           = { &splineVars},
       predictedTarget  = "P_y",
       analysisVariable = {name = "&aVar", nBins=100},
       seed             = 1234
       ;
   run;
   quit;

   data &odsName(rename=MeanPrediction=&meanPred); set &odsName; drop StdErr; run;
   ods exclude none;
%mend;

proc template;
   define statgraph pdLattice;
   dynamic _title;
   begingraph ;
      entrytitle _title;
      layout lattice / columns=2 rows=2;
         layout overlay / xaxisopts=(label='v1') yaxisopts=(label='f1');
             seriesplot x=v1 y=f1 / name='fit' legendlabel='Fit' group=model;
         endlayout;
         layout overlay / xaxisopts=(label='v2') yaxisopts=(label='f2');
             seriesplot x=v2 y=f2 / name='fit' legendlabel='Fit' group=model;
         endlayout;
         layout overlay / xaxisopts=(label='v3') yaxisopts=(label='f3');
              seriesplot x=v3 y=f3 / name='fit' legendlabel='Fit' group=model;
         endlayout;
         layout overlay / xaxisopts=(label='v4') yaxisopts=(label='f4');
              seriesplot x=v4 y=f4 / name='fit' legendlabel='Fit' group=model;
         endlayout;
      endlayout;
	  layout globallegend / type=row ;
	     discretelegend 'fit' / title='Procedure';
	  endlayout;
   endgraph;
end;

proc cas;
 gam.gamselect
  table='one',
  seed=123,
  model={depVar='y',
  splines={ {vars='v1', df=10}, 'v2', 'v3','v4'}
  },
  selection={method='boosting',
            choose='CV',
            cvMethod={index='cvFold'},
            stopHorizon=10,
 		   stopTol = 0.0005
            },
  store={name='gamSelMod',replace='true'};
 run;
quit;

%pdPlotData( gbTreeMod, v1, f1,  gbTreePDv1);
%pdPlotData( gbTreeMod, v2, f2,  gbTreePDv2);
%pdPlotData( gbTreeMod, v3, f3,  gbTreePDv3);
%pdPlotData( gbTreeMod, v4, f4,  gbTreePDv4);

%pdPlotData( gamselMod, v1, f1,  gamselPDv1);
%pdPlotData( gamselMod, v2, f2,  gamselPDv2);
%pdPlotData( gamselMod, v3, f3,  gamselPDv3);
%pdPlotData( gamselMod, v4, f4,  gamselPDv4);

data gbTreePDData;
  merge gbTreePDv1 gbTreePDv2 gbTreePDv3 gbTreePDv4;
  model = "GRADBOOST";
run;

data gamselPDData;
   merge gamselPDv1 gamselPDv2 gamselPDv3 gamselPDv4;
   model = "GAMSELECT";
run;

data pdPlotData1;
   merge gamselPDData gbTreePDData;
   by model;
run;

proc sgrender data=pdPlotData1 template=pdLattice;
   dynamic _title='Partial Dependence Plot Comparison';
run;

%pdPlotData( gbTreeMod2, v1, f1,  gbTreePDv1m2);
%pdPlotData( gbTreeMod2, v2, f2,  gbTreePDv2m2);
%pdPlotData( gbTreeMod2, v3, f3,  gbTreePDv3m2);
%pdPlotData( gbTreeMod2, v4, f4,  gbTreePDv4m2);

data gbTreePDDatam2;
  merge gbTreePDv1m2 gbTreePDv2m2 gbTreePDv3m2 gbTreePDv4m2;
  model = "GRADBOOST";
run;

data pdPlotData2;
   merge gamselPDData gbTreePDDatam2;
   by model;
run;

proc sgrender data=pdPlotData2 template=pdLattice;
   dynamic _title='Partial Dependence Plot Comparison';
run;

/*********************************************************/
/* Example 1 GAMSELECT METHOD=SHRINKAGE Analysis         */
/*********************************************************/

proc gamselect data=mycas.one seed=123 plots=all;
   model y = %SplinePrefixList(v, 200);
   selection method=shrinkage;
run;

proc gamselect data=mycas.one seed=123 plots=all;
   model y=spline(v1 / weight1=0.716  weight2=0.075)
           spline(v2 / weight1=0.693  weight2=0.206)
           spline(v3 / weight1=1.046  weight2=17.62)
           spline(v4 / weight1=0.488  weight2=0.090)
           spline(v15/ weight1=343.5  weight2=34.68);
   selection method=shrinkage;
run;

/*********************************************************/
/* Example 2                                             */
/*********************************************************/
data mycas.hmeq;
   set sampsio.hmeq;
   if cmiss(of _all_) then delete;
   if CLAge > 1000 then delete;
   part = ranbin(1,1,0.2);
run;

proc gamselect data=mycas.hmeq plots=all;
   class Job Reason ;
   model Bad(event='1') = Param(Job Reason nInq Derog Delinq)
                          spline(CLAge) spline(CLNo) spline(DebtInc)
                          spline(Loan) spline(Mortdue)  spline(Value)
                          spline(YoJ) spline(MortDue Value) spline(MortDue Loan)
                          spline(Loan Value)
                      / dist=binary allobs;
   selection method=boosting(stopHorizon=10 stopTol=0.0005 stepSize=0.2);
   output out=mycas.hmeqPred copyvars=(_all_) pred = p role=rInd;
   partition role=part(test='1');
run;

data mycas.hmeqPred;
   set mycas.hmeqPred;
   if p >= 0.5 then I_Bad = 1;
   else if p < 0.5 and p ne . then I_Bad = 0;
   else I_Bad = .;
run;

proc freqtab data=mycas.hmeqPred;
   table rInd * I_Bad * Bad / nopercent;
run;


proc svmachine data=mycas.hmeq;
   input reason job derog delinq ninq / level=nominal;
   input loan mortdue value yoj clage clno debtinc / level=interval;
   kernel polynomial/degree=2;
   target bad / desc;
   partition role=part(test='1');
run;

proc gradboost data=mycas.hmeq seed=1234;
   input reason job derog delinq ninq / level=nominal;
   input loan mortdue value yoj clage clno debtinc / level=interval;
   target bad /level=nominal;
   partition role=part(test='1');
   output out=mycas.gbTreePred copyVars=(_all_)  role=rInd;
run;

proc logselect data=mycas.hmeq;
   class Job Reason;
   model Bad(event="1") = Job Reason nInq Derog Delinq
                          loan mortdue value yoj clage clno debtinc
  	             loan*value mortdue*value  mortDue*loan;
   selection method=forward;
   partition role=part(test='1');
   output out=mycas.logPred copyVars=(_all_) pred=p role=rInd;
run;

data mycas.logPred;
   set mycas.logPred;
   if p >= 0.5 then I_Bad = 1;
   else if p < 0.5 and p ne . then I_Bad = 0;
   else I_Bad = .;
run;

proc freqtab data=mycas.logPred;
   table rInd * I_Bad * Bad;
run;

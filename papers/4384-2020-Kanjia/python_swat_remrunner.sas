* Create an additional variable lists;
%dmcas_varmacro(name=dm_class_var, metadata=&dm_metadata, where=%nrbquote(level in ('NOMINAL','ORDINAL','BINARY') and role in ('INPUT','TARGET')), key=NAME, quote=Y, singlequote=Y, comma=Y, append=Y);
%dmcas_varmacro(name=dm_input, metadata=&dm_metadata, where=%nrbquote(role = 'INPUT'), key=NAME, quote=Y, singlequote=Y, comma=Y, append=Y);
/* Create a python file to execute on remote host */
proc cas;
      file _codef "&dm_nodedir&dm_dsep.gb01.py";
      print "#!/usr/bin/python";
      print "import os";
      print "import paramiko";
      print "import pandas as pd";
      print "import swat, sys";
      print "from sklearn import ensemble";
      print "from xgboost import XGBClassifier";
      print "from xgboost import plot_tree";
      print "import matplotlib";
      print "matplotlib.use('Agg')";
      print "from matplotlib import pyplot as plt";
      print "os.environ['CAS_CLIENT_SSL_CA_LIST'] = '/tmp/jk/ms_19w47_trustedcerts.pem'";
      print "conn = swat.CAS(hostname = '&dm_cashost', port = '&dm_casport', session = '&dm_cassessionid', authinfo='~/.authinfo')";
      print "table = '&dm_memname'";
      print "nodeid = '&dm_nodeid'";
      print "caslib = '&dm_caslib'";
      print "dm_partitionvar = '&dm_partitionvar'";
      print "dm_inputdf = conn.CASTable(caslib = caslib, name = table).to_frame()";
      print "dm_traindf = dm_inputdf[dm_inputdf[dm_partitionvar] == 1]";
      print "dm_validdf = dm_inputdf[dm_inputdf[dm_partitionvar] == 0]";
      print "outF = open('_output.txt', 'w')";
      print "print(dm_traindf.head(), sep=' ', end='\n\n', file=outF, flush=False)";
      print "X_train = dm_traindf.loc[:,[%dm_input]]";
      print "y_train = dm_traindf['%qktrim(&dm_dec_vvntarget)']";
      print "X_valid = dm_validdf.loc[:,[%dm_input]]";
      print "y_valid = dm_validdf['%qktrim(&dm_dec_vvntarget)']";
      print "eval_set = [(X_train, y_train),(X_valid, y_valid)]"; 
      print "X = dm_inputdf.loc[:,[%dm_input]]";
      print "xgb = XGBClassifier()";
      print "xgb.fit(X_train, y_train, eval_metric=['error', 'logloss'], eval_set=eval_set, verbose=True)";
      print "print(xgb, sep=' ', end='\n\n', file=outF, flush=False)";
      print "pred = xgb.predict_proba(X)";   
      print "dm_inputdf['%qktrim(&dm_predicted_vvnvar)'] = pred[:,1]";
      print "dm_inputdf['P_BAD0'] = pred[:,0]";
      print "dm_inputdf['%qktrim(&dm_into_vvnvar)'] = pd.DataFrame(xgb.predict(X))";
      print "print(dm_inputdf.head(), sep=' ', end='\n', file=outF, flush=False)";
      print "outF.close()";
      print "results = xgb.evals_result()";
      print "stat = pd.DataFrame()";
      print "stat['train_logloss'] = results['validation_0']['logloss']";
      print "stat['valid_logloss'] = results['validation_1']['logloss']";
      print "stat['train_error'] = results['validation_0']['error']";
      print "stat['valid_error'] = results['validation_1']['error']";
      print "conn.upload_frame(stat, casout = dict(name = 'gb_stat', caslib = caslib, replace = True))";
      print "plot_tree(xgb,num_trees=3)";
      print "fig = plt.gcf()";
      print "fig.set_size_inches(15,10)";
      print "fig.savefig('rpt_tree.png',dpi=700)";
      print "conn.upload_frame(dm_inputdf, casout = dict(name = nodeid + '_score', caslib = caslib, replace = True))";
      print "varimp = pd.DataFrame(list(zip(X_train, xgb.feature_importances_)), columns=['Variable Name', 'Importance'])";
      print "conn.upload_frame(varimp, casout = dict(name = 'gb_varimp', caslib = caslib, replace = True))";
      print "ssh_client=paramiko.SSHClient()";
      print "ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())";
      print "ssh_client.connect(hostname='&dm_cashost', username='&sysuserid')";
      print "ftp_client=ssh_client.open_sftp()";
      print "ftp_client.put('rpt_tree.png','&dm_nodedir&dm_dsep.rpt_tree.png')";
      print "ftp_client.put('_output.txt','&dm_nodedir&dm_dsep._output.txt')";
 run;

/* Create a python file which will execute on compute server system, uses remrunner to submit file to remote system. Currently, remrunner assumes that SSH keys to allow password-less logins are already in place. There is no option to prompt for password or ssh passphrase. */

  proc cas;
      file _codef "&dm_nodedir&dm_dsep.dm_srcfile.py";
      print "from remrunner import runner";
      print "r = runner.Runner('dmcas-thursday.aatesting.sashq-d.openstack.sas.com', '&sysuserid')";
      print "rval, stdout, stderr = r.run('&dm_nodedir&dm_dsep.gb01.py')";
      print "if rval:";
      print "    print(stderr)";
      print "else:";
      print "    print(stdout)";
      print "r.close()";
run;

/* Execute Python script */

/* Set classpath */
%let tmp=;
%dmcas_setClasspath();

data _null_;
      length rtn_val 8;
      declare javaobj j("com.sas.analytics.datamining.servertier.SASPythonExec", "&dm_nodedir&dm_dsep.dm_srcfile.py");
      j.callVoidMethod("setOutputFile", "&dm_nodedir&dm_dsep&lang._output.txt");
      j.callIntMethod("executeProcess", rtn_val);
      j.delete();
      call symput('javaobj_rtnval', rtn_val);
run;

/* Register _score table created in Python on remote host and uploaded to CAS */
%dmcas_register(dataset=&dm_output_memname, type=cas);

/* Display image file created in Python on remote host and transferred to Viya system */
%dmcas_report(file=&dm_nodedir&dm_dsep.rpt_tree.png, reportType=Image, description=%nrbquote('Tree Plot'), localize=N);

%dmcas_report(file=&dm_nodedir&dm_dsep._output.txt, reportType=CodeEditor, type=TEXT, description=%nrbquote('Python Output'), localize=N);

/* Generate report to display feature importance table created by Gradient Boosting Classifier model */

data &dm_lib..varimp;
	set &dm_datalib..gb_varimp;
run;

%dmcas_report(dataset=varimp, reportType=table, description=%nrbquote(Gradient Boosting Classifier Feature Importance));

/* Create a the gbstat table to plot different metrics by iteration */
data &dm_lib..gbstat( keep=Iteration dataRole logLoss error);
   length Iteration 8 datarole $8 logLoss error 8;
   label dataRole='Data Role'; logLoss='Log Loss'; error = 'Error';
   set &dm_datalib..gb_stat;
   Iteration = _N_;
   dataRole='TRAIN';    logLoss = train_logloss;  error = train_error; output;
   dataRole='VALIDATE'; logLoss = valid_logloss;  error = valid_error; output;
run;

/* Request a series plot for each metric */
%dmcas_report(view=1, dataset=gbstat, comboDescription= XGB Iteration Plot, reportType=SeriesPlot, description=%nrbquote(Log-Loss), X=Iteration, y=logLoss, group=dataRole, localize=N);
%dmcas_report(view=2, dataset=gbstat, comboDescription= XGB Iteration Plot, reportType=SeriesPlot, description=%nrbquote(Error), X=Iteration, y=error,   group=dataRole, localize=N);
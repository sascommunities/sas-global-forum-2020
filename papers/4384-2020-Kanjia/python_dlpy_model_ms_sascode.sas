/* SAS code */

/* Create additional variable lists */
%dmcas_varmacro(name=dm_class_var, metadata=&dm_metadata, where=%nrbquote(level in ('NOMINAL','ORDINAL','BINARY') and role in ('INPUT','TARGET')), key=NAME, quote=Y, singlequote=Y, comma=Y, append=Y);
%dmcas_varmacro(name=dm_input, metadata=&dm_metadata, where=%nrbquote(role = 'INPUT'), key=NAME, quote=Y, singlequote=Y, comma=Y, append=Y);
/* Create Python file to execute */
proc cas; 
    file _codef "&dm_nodedir&dm_dsep.dm_srcfile.py";
    print "import swat";
    print "from dlpy import Model, Sequential";
    print "from dlpy.model import Optimizer, AdamSolver";
    print "from dlpy.layers import *";
    print "import pandas as pd";
    print "import os";
    print "import matplotlib";
    print "from matplotlib import pyplot as plt";
    print "plt.switch_backend('agg')";
    print "s = swat.CAS(hostname='&dm_cashost', port='&dm_casport', session='&dm_cassessionid')";
    print "s.loadactionset('deeplearn')";
    print "s.setsessopt(caslib='&dm_caslib')";
    print "model = Sequential(s, model_table=s.CASTable('simple_dnn_classifier', replace=True))";
    print "model.add(InputLayer(std='STD'))";
    print "model.add(Dense(20, act='relu'))";
    print "model.add(OutputLayer(act='softmax', n=2, error='entropy'))";
    print "model.fit(s.CASTable('&dm_memname', where='&dm_partitionvar=&dm_partition_train_val'), target='&dm_dec_vvntarget', inputs=[%dm_input], nominals=[%dm_class_var], optimizer=Optimizer(algorithm=AdamSolver(learning_rate=0.005,learning_rate_policy='step',gamma=0.9,step_size=5), mini_batch_size=4, seed=1234, max_epochs=50))";
    print "outF = open('&dm_nodedir/_output.txt', 'w')";
    print "summary = model.print_summary()";
    print "print(summary, sep=' ', end='\n\n', file=outF, flush=False)";
    print "history = model.training_history";
    print "print(history, sep=' ', end='\n\n', file=outF, flush=False)";
    print "n=model.plot_network()";
    print "from graphviz import Graph";
    print "g = Graph(format='png')";
    print "n.format = 'png'";
    print "n.render('&dm_nodedir&dm_dsep.rpt_network1.gv')";
    print "outF.close()";
    print "th=model.plot_training_history(fig_size=(15,6))";
    print "th.get_figure().savefig('&dm_nodedir&dm_dsep.rpt_train_hist.png')";
    print "s.dlExportModel(modeltable='simple_dnn_classifier', initWeights='simple_dnn_classifier_weights', randomflip='NONE', randomCrop='NONE', randomMutation='NONE', casout='&dm_rstoretable')";
run;



/* Set class path */
%dmcas_setClasspath();
/* Execute Python script */

data _null_;
    length rtn_val 8;
    declare javaobj j("com.sas.analytics.datamining.servertier.SASPythonExec", "&dm_nodedir&dm_dsep.dm_srcfile.py");
    j.callVoidMethod("setOutputFile", "&dm_nodedir&dm_dsep&lang._output.txt");
    j.callIntMethod("executeProcess", rtn_val);
    j.delete();
    call symput('javaobj_rtnval', rtn_val);
run;

%let source=&dm_nodedir&dm_dsep.;

/* Rename png file that was created using graphviz function. */ 
data _null_;
   rc=rename("&dm_nodedir&dm_dsep.rpt_network1.gv.png", "&dm_nodedir&dm_dsep.rpt_network1_gv.png", "file");
run;

/* Create a report to display network plot */
%dmcas_report(file=&dm_nodedir&dm_dsep.rpt_network1_gv.png, reportType=Image, description=%nrbquote('Network Plot'), localize=N);

/* Create a report to display training history plot */
%dmcas_report(file=&dm_nodedir&dm_dsep.rpt_train_hist.png, reportType=Image, description=%nrbquote('Tree Plot'), localize=N);

/* Create a report to display Python output file */
%dmcas_report(file=&dm_nodedir&dm_dsep._output.txt, reportType=CodeEditor, type=TEXT, description=%nrbquote('Python Output'), localize=N);

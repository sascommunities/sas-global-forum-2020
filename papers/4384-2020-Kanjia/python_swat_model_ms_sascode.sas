/* SAS Code */

/* Create additional variable lists */
%dmcas_varmacro(name=dm_class_var, metadata=&dm_metadata, where=%nrbquote(level in ('NOMINAL','ORDINAL','BINARY') and role in ('INPUT','TARGET')), key=NAME, quote=Y, singlequote=Y, comma=Y, append=Y);
%dmcas_varmacro(name=dm_input, metadata=&dm_metadata, where=%nrbquote(role='INPUT'), key=NAME, quote=Y, singlequote=Y, comma=Y, append=Y);

* Create Python script with SAS macro variables inserted;
proc cas;
    file _codef "&dm_nodedir&dm_dsep.dm_srcfile.py";
    print "import swat";
    print "s=swat.CAS(hostname='&dm_cashost', port='&dm_casport', session='&dm_cassessionid')";
    print "s.loadactionset('decisiontree')";
    print "s.gbtreetrain(table=dict(caslib='&dm_caslib', name='&dm_memname', where='&dm_partitionvar=&dm_partition_train_val'), target='&dm_dec_vvntarget', inputs=[%dm_input], nominals=[%dm_class_var], savestate=dict(caslib='&dm_caslib', name='&dm_rstoretable', replace=True))";
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

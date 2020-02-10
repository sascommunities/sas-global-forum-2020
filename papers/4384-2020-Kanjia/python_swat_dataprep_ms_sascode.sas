/* Create additional variable lists */
%dmcas_varmacro(name=dm_class_input, metadata=&dm_metadata, where=%nrbquote(level in ('NOMINAL','ORDINAL','BINARY') and role = 'INPUT'), key=NAME, quote=Y, singlequote=Y, comma=Y, append=Y);

* Create Python script with SAS macro variables inserted;
proc cas;
    file _codef "&dm_nodedir&dm_dsep.dm_srcfile.py";
    print "import swat";
    print "s=swat.CAS(hostname='&dm_cashost', port='&dm_casport', session='&dm_cassessionid')";
    print "s.transform(table=dict(caslib='&dm_caslib', name='&dm_memname', where='&dm_partitionvar=&dm_partition_train_val'), requestPackages=dict(function=dict(name='TE', inputs=[%dm_class_input], targets='&dm_dec_vvntarget', event='&dm_dec_event', targetsinheritformats=True, inputsinheritformats=True, mapInterval=dict(method='moments', args=dict(includeMissingLevel=True, nMoments=1)))), savestate=dict(caslib='&dm_caslib', name='&dm_rstoretable', replace=True))";
run;

/* Set classpath */
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

/* Reject original inputs (optional) */
filename deltac "&dm_file_deltacode";

data _null_;
     file deltac;
     set &dm_metadata;

     length codeline $ 500;
     if level in ('NOMINAL','ORDINAL','BINARY') and role = 'INPUT' then do;
           codeline = "if upcase(NAME) = '"!!upcase(tranwrd(ktrim(NAME), "'", "''"))!!"' then do;";
           put codeline;

           codeline = "ROLE='REJECTED';";
           put +3 codeline;
           put 'end;';
           output;
     end;
run;

filename deltac;
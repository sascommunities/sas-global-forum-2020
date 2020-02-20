/*****************************************/
/* 1. WORK WITH REDSHIFT DATA FROM SAS 9 */
/*****************************************/


/* 1.1 LOADING DATA IN REDSHIFT */

/* 1.1.1 Standard load */

/* Standard Redshift library */
libname myrs redshift server="myredshift.amazonaws.com"
                      database="mydb" schema="public"
                      user="myuser" password=XXXXXXXXXX ;

/* SAS Library */
libname local "~/data" ;

proc append base=myrs.lineorder
            data=local.lineorder(obs=50000) ;
run ;


/* 1.1.2 Using buffer options */

proc append base=myrs.lineorder(insertbuff=4096)
            data=local.lineorder(obs=50000) ;
run ;


/* 1.1.3 Bulk Loading */

proc append base=myrs.lineorder(bulkload=yes
                                bl_bucket="sas-bucket/redshift/temp_bulk_loading")
            data=local.lineorder(obs=5000000) ;
run ;


/* 1.2 PROCESS REDSHIFT DATA */

/* 1.2.1 Implicit Pass-Through */

/* Standard Redshift library */
libname myrs redshift server="myredshift.amazonaws.com"
                      database="mydb" schema="public"
                      user="myuser" password="XXXXXX" ;

/* SAS Library */
libname local "~/data" ;

proc sql ;
   create table local.orders as select *
   from myrs.part p, myrs.supplier s, myrs.customer c, myrs.dwdate d, myrs.lineorder lo
   where p.p_partkey=lo.lo_partkey and
         s.s_suppkey=lo.lo_suppkey and
         c.c_custkey=lo.lo_custkey and
         d.d_datekey=lo.lo_orderdate ;
quit ;

options sastrace=',,,d' sastraceloc=saslog nostsuffix msglevel=i ;

proc sql ;
   create table myrs.orders as select *
   from myrs.part p, myrs.supplier s, myrs.customer c, myrs.dwdate d, myrs.lineorder lo
   where p.p_partkey=lo.lo_partkey and
         s.s_suppkey=lo.lo_suppkey and
         c.c_custkey=lo.lo_custkey and
         d.d_datekey=lo.lo_orderdate ;
quit ;


/* 1.2.2 Explicit Pass-Through */

/* Explicit pass-through - explicit credentials - select data */
proc sql ;
   connect to redshift as myrs_pt(server="myredshift.amazonaws.com"
                                  database="mydb" user="myuser"
                                  password="XXXXXX") ;
   select * from connection to myrs_pt(
      select c_nation as customer_country, s_nation as supplier_country,
             sum(lo_quantity) as qty, sum(lo_revenue) as revenue
      from public.orders
      group by c_nation, s_nation ;
   ) ;
   disconnect from myrs_pt ;
quit ;

/* Explicit pass-through - implicit credentials - run specific Redshift commands */
proc sql ;
   connect using myrs as myrs_pt ;
   execute (vacuum ;) by myrs_pt ;
   execute (analyze ;) by myrs_pt ;
   disconnect from myrs_pt ;
quit ;


/* 1.2.3 Use FedSQL */

proc fedsql iptrace ;
   create table myrs.test_fedsql
      (
         key TINYINT NOT NULL,
         field1 BIGINT NOT NULL
      ) ;
   insert into myrs.test_fedsql values (0,123456789012345) ;
   insert into myrs.test_fedsql values (1,123456789012345) ;
   insert into myrs.test_fedsql values (2,123456789012345) ;
quit ;


/* 1.2.4 Run SAS Procedures In-Database */

proc rank data=myrs.orders out=myrs.ranks ;
   var lo_revenue lo_supplycost ;
   ranks rev_rank cost_rank ;
run ;


/* 1.3 EXTRACTING REDSHIFT DATA */

/* 1.3.1 Standard extract */

data lineorder ;
   set myrs.lineorder ;
run ;


/* 1.3.2 READBUFF */

data lineorder ;
   set myrs.lineorder(readbuff=4096) ;
run ;


/* 1.3.3 Bulk Unloading */

data lineorder ;
   set myrs.lineorder(bulkunload=yes
                      bl_bucket="mybucket/redshift_bulk_loading") ;
run ;


/********************************************/
/* 2. WORK WITH REDSHIFT DATA FROM SAS VIYA */
/********************************************/


/* 2.1 LOAD REDSHIFT DATA IN CAS */

/* 2.1.1 Standard loading */

/* Standard Redshift CASLIB */
caslib rs datasource=(srctype="redshift" server="myredshift.amazonaws.com"
                      database="mydb" schema="public"
                      user="myuser" password="XXXXXX") ;

proc casutil incaslib="rs" outcaslib="rs" ;
   load casdata="lineorder" casout="lineorder" ;
quit ;


/* 2.1.2 Multi-Node Loading */

caslib rs datasource=(srctype="redshift" server="myredshift.amazonaws.com"
                      database="mydb" schema="public" user="myuser"
                      password="XXXXXX" numreadnodes=10) ;

libname casrs cas caslib="rs" ;

proc casutil incaslib="rs" outcaslib="rs" ;
   load casdata="lineorder" casout="lineorder" ;
quit ;


/* 2.1.3 Bulk Unloading (Redshift) and Multi-Node Loading (CAS) */

caslib rs datasource=(srctype="redshift" server="myredshift.amazonaws.com"
                      database="mydb" schema="public" user="myuser"
                      password="XXXXXX" numreadnodes=0) ;

proc casutil incaslib="rs" outcaslib="rs" ;
   load casdata="lineorder" casout="lineorder"
      datasourceoptions=(
         bulkunload=true
         awsconfig="/opt/sas/viya/config/data/AWSData/config"
         credentialsfile="/opt/sas/viya/config/data/AWSData/credentials"
         bucket="mybucket/redshift_bulk_loading"
      ) ;
quit ;


/* 2.2 PROCESS REDSHIFT DATA FROM CAS */

/* 2.2.1 FedSQL Implicit Pass-Through Facility */

proc fedsql sessref=mysession _method ;
   create table rs.orders as select
      p.p_name, p.p_color, p.p_type, p.p_size,
      s.s_nation, s.s_region,
      c.c_nation, c.c_region,
      d.d_month, d.d_year,
      lo.lo_quantity, lo.lo_revenue
   from rs.lineorder lo inner join rs.part p on lo.lo_partkey=p.p_partkey
      inner join rs.supplier s on lo.lo_suppkey=s.s_suppkey
      inner join rs.customer c on lo.lo_custkey=c.c_custkey
      inner join rs.dwdate d on lo.lo_orderdate=d.d_datekey
   ;
quit ;


/* 2.2.2 FedSQL Explicit Pass-Through Facility */

proc fedsql sessref=mysession _method ;
   create table rs.extract as
   select * from connection to rs
      (
         select c_nation as customer_country, s_nation as supplier_country,
         sum(lo_quantity) as qty, sum(lo_revenue) as revenue
         from public.orders
         group by c_nation, s_nation
      ) ;
   ;
quit ;


/* 2.3 SAVE CAS DATA TO REDSHIFT */

/* 2.3.1 Standard Saving */

caslib rs datasource=(srctype="redshift" server="myredshift.amazonaws.com"
                      database="mydb" schema="public" user="myuser"
                      password="XXXXXX") ;

proc casutil incaslib="casuser" outcaslib="rs" ;
   save casdata="orders" casout="orders" replace ;
quit ;


/* 2.3.2 Multi-Node Saving */

caslib rs datasource=(srctype="redshift" server="myredshift.amazonaws.com"
                      database="mydb" schema="public" user="myuser"
                      password="XXXXXX" numwritenodes=10) ;

proc casutil incaslib="casuser" outcaslib="rs" ;
   save casdata="orders" casout="orders" replace ;
quit ;


/* 2.3.3 "Bulk Loading" Saving */

caslib rs datasource=(srctype="redshift" server="myredshift.amazonaws.com"
                      database="mydb" schema="public" user="myuser"
                      password="XXXXXX" numwritenodes=1) ;

proc casutil incaslib="rs" outcaslib="rs" ;
   save casdata="orders" casout="orders" replace
      options=(
         bulkload=true
         awsconfig="/opt/sas/viya/config/data/AWSData/config"
         credentialsfile="/opt/sas/viya/config/data/AWSData/credentials"
         bucket="mybucket/redshift_bulk_loading"
      ) ;
quit ;


/* 2.3.4 Multi-Node Saving (CAS) and Bulk Loading (Redshift) */

caslib rs datasource=(srctype="redshift" server="myredshift.amazonaws.com"
                      database="mydb" schema="public" user="myuser"
                      password="XXXXXX" numwritenodes=0) ;

proc casutil incaslib="rs" outcaslib="rs" ;
   save casdata="orders" casout="orders" replace
      options=(
         bulkload=true
         awsconfig="/opt/sas/viya/config/data/AWSData/config"
         credentialsfile="/opt/sas/viya/config/data/AWSData/credentials"
         bucket="mybucket/redshift_bulk_loading"
      ) ;
quit ;

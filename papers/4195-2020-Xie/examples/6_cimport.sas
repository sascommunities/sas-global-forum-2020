/* Import the transport file in the target environment */
/* Extend all the character variables and their format */
/* 1.5 times to avoid truncation.                      */
filename infile 'class.xpt';
libname target 'output';
proc cimport infile=infile library=target extendvar=1.5; run;
proc contents data=target.class; run;

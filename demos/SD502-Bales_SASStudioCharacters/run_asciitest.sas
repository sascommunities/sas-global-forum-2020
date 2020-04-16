/*-------------------------------------------------------------------------*/
/* NAME:       run_ASCIItest.sas                                           */
/* PURPOSE:    This simple SAS program demonstrates the %ASCIItest() macro */
/*             found in this repository. See the comments below for        */
/*             for information about each call to the macro.               */
/*                                                                         */
/*-------------------------------------------------------------------------*/

%include 'ASCIItest.sas';

/* Test 1: This test demonstrates how the macro behaves when all charaters */
/* in the SAS data set are ASCII.                                          */
%asciitest(sashelp, class);

/* Test 2: This test demonstrates how the macro behaves when the data set  */
/* contains some WLATIN1 characters that are not ASCII.                    */
/* Note: If you run this test in SAS with a UTF-8 session encoding, some   */
/* characters will not display correctly in the report. However, the       */
/* report will list the observations and character columns that contain    */
/* non-ASCII characters.                                                   */
libname fr19 'fr' inencoding=asciiany;
%asciitest(fr19, class);

/* Test 3: This test demonstrates how the macro behaves when the dat sets  */
/* are encoded as UTF-8 and contains some non-ASCII characters. The report */
/* is suppressed fo1r the second data set in this section.                 */
/* Note: If you run this test in SAS with a non-UTF-8 session encoding,    */
/* some characters will not display correctly in the report.               */
libname u819 'u8' inencoding=asciiany;
%asciitest(u819, students);
%asciitest(u819, bptrial, printrep=no);

/* Test 4: This test demostrates how the macro behaves when ther data set  */
/* does not exist.                                                         */
%asciitest(fr19, staff);
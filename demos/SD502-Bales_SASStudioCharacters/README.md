# See All of Your Characters in SAS&#174; Studio
## Exploring the Great Unknown (&#xfffd;)

This repository is a companion to the SAS&#174; Global Forum 2020 presentation with the same name. A recorded presentation of [See All of Your Characters in SAS® Studio](https://www.youtube.com/watch?v=Di3ylTaHiMs) is available in the SAS Users Channel on YouTube. 

# Repository contents

This repository contains a PDF version of the slides presented during the presentation. It also includes SAS programs, text file, and SAS data set that was used as part of the presentation. 

Most of the screen shots included in the presentation were created using the SAS Studio Code Editor, Log or Results windows. Screen shots that show the contents of a file with the character encoding were made when the file was open in the Notepad++ editor. 

Files containing SAS programs and character data for the presentation were created using the windows-1252 character encoding. Note that *windows-1252* is another name for the SAS encoding *WLATIN1*.

All programs displayed in the screen shots were run in a SAS with a UTF-8 session encoding.

## File list

* **qlist.sas** - SAS program that demonstrates issues that occur when reading a WLATIN1 text file in a SAS UTF-8 session.
* **Quarantine.txt** - WLATIN1 text file.
* **qlist_withencoding.sas** - SAS program using FILENAME ENCODING= option to identify the encoding of the text file.
* **qlist2.sas** - SAS program created as WLATIN1 that uses a non-ASCII character in a TITLE statement.
* **toASCII.sas** - Simple SAS program demonstrating how to convert characters in your data to ASCII using the KPROPDATA and BASECHAR data step functions.

## Bonus material

* **asciitest.sas** - Contains code for the %asciitest macro, which checks all text in a SAS data set to determine if all of the characters are ASCII. If non-ASCII characters are found, the macro will display those strings in a simple report showing the observation number, variable name, and string.
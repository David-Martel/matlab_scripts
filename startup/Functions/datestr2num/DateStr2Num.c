// DateStr2Num.c
// DATESTR2NUM - Fast conversion of DATESTR to DATENUM
// The builtin DATENUM command is very powerful, but if you know the input
// format exactly, a specific MEX can be much faster: e.g. for single strings
// DateStr2Num is 50 to 100 times faster than DATENUM, for a {1 x 10000} cell
// string the speed up factor is 300 to 700 (Matlab 2009a/2011b/64, MSVC 2008).
//
// D = DateStr2Num(S, F)
// INPUT:
//   S: String or cell string in the format specified by F.
//      In opposite to DATENUM the validity of the input string is not checked
//      in any way (e.g. 1 <= month <= 12).
//   F: Integer number defining the input format. Accepted:
//           0: 'dd-mmm-yyyy HH:MM:SS'      01-Mar-2000 15:45:17
//           1: 'dd-mmm-yyyy'               01-Mar-2000
//          29: 'yyyy-mm-dd'                2000-03-01
//          30: 'yyyymmddTHHMMSS'           20000301T154517
//          31: 'yyyy-mm-dd HH:MM:SS'       2000-03-01 15:45:17
//      Not DATEFROM numbers of DATESTR:
//         230: 'mm/dd/yyyyHH:MM:SS'        12/24/201515:45:17
//         231: 'mm/dd/yyyy HH:MM:SS'       12/24/2015 15:45:17
//         240: 'dd/mm/yyyyHH:MM:SS'        24/12/201515:45:17
//         241: 'dd/mm/yyyy HH:MM:SS'       24/12/2015 15:45:17
//      Including the milliseconds:
//        1000: 'dd-mmm-yyyy HH:MM:SS.FFF'  01-Mar-2000 15:45:17.123
//        1030: 'yyyymmddTHHMMSS.FFF'       20000301T154517.123
//      The '-', ':', '/' and space characters are ignored and can be chosen
//      freely. Additional trailing characters are allowed.
//      Optional, default: 0.
//
// OUTPUT:
//   D: Serial date number. If S is a cell string, D has is same size.
//
// EXAMPLES:
//   C = {'2010-06-29 21:59:13', '2010-06-29 21:59:13'};
//   D = DateStr2Num(C, 31)
//   >> [734318.916122685, 734318.916122685]
// Equivalent Matlab command (but a column vector is replied):
//   D = datenum(C, 'yyyy-mm-dd HH:MM:SS')
//
// NOTES: The parsing of the strings works for clean ASCII characters only:
//   '0' MUST have the key code 48!
//   Month names must be English with the 2nd and 3rd charatcer in lower case.
//   Sorry for ugly numerical codes to define the format! This helps to squeeze
//   out some speed. If you need a 'nice' function, use DATENUM.
//   Trailing characters are ignore, such that you can ignore the time of
//   'dd-mmm-yyyy HH:MM:SS' by choosing F=1.
//
// COMPILATION:
//   Windows: mex -O DateStr2Num.c
//   Linux:   mex -O CFLAGS="\$CFLAGS -std=c99" DateStr2Num.c
//   Download precompiled Mex: http://www.n-simon.de/mex
//
// Tested: Matlab 6.5, 7.7, 7.8, 7.13, 9.1, WinXP/32, Win7/64, Win10/64
//         Compiler: LCC2.4/3.8, BCC5.5, OWC1.8, MSVC2008/2010
// Assumed Compatibility: higher Matlab versions, Mac, Linux
// Author: Jan Simon, Heidelberg, (C) 2010-2018 matlab.2010(a)n(MINUS)simon.de
//
// See also DATESTR, DATENUM, DATEVEC.
// FEX: DateConvert 25594 (Jan Simon)

/*
% $JRev: R-p V:016 Sum:1UM3d1l3M5xC Date:27-May-2018 22:51:23 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\Mex\Source\DateStr2Num.c $
% $UnitTest: uTest_DateStr2Num $
% History:
% 001: 29-Jun-2010 22:12, First version, for format 31 only.
% 002: 30-Jun-2010 16:08, Accept formats 0, 1, 29, 30, 31.
% 005: 23-Mar-2011 22:39, yyyymmddTHHMMSS.FFF format, called "300".
%      Using int32_T instead of uint16_T is about 50% faster: The conversion of
%      signed integers to a double is implemented in hardware.
% 007: 28-Jul-2013 12:59, 300 -> 1030, new format 1000.
% 011: 28-Nov-2014 08:47, New formats, trailing characters are ignored.
%      dd/mm/yyyyHH:MM:SS, mm/dd/yyyyHH:MM:SS, dd/mm/yyyy HH:MM:SS,
%      mm/dd/yyyy HH:MM:SS
% 016: 26-May-2018 04:31, Accept month names in upper-case also.
*/

#include "mex.h"
#include <math.h>
#include "tmwtypes.h"

// 32 bit addressing for Matlab 6.5:
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#define mwSize  int32_T           // Defined in tmwtypes.h
#define mwIndex int32_T
#endif

// Headers for error messages:
#define ERR_ID   "JSimon:DateStr2Num:"
#define ERR_HEAD "DateStr2Num[mex]: "
#define ERROR(id,msg) mexErrMsgIdAndTxt(ERR_ID id, ERR_HEAD msg);

// Prototypes:
double Str0Num(const mxArray *S);
double Str1Num(const mxArray *S);
double Str29Num(const mxArray *S);
double Str30Num(const mxArray *S);
double Str31Num(const mxArray *S);
double Str230Num(const mxArray *S);
double Str231Num(const mxArray *S);
double Str240Num(const mxArray *S);
double Str241Num(const mxArray *S);
double Str1000Num(const mxArray *S);
double Str1030Num(const mxArray *S);

// Type: Pointer to core function:
typedef double (*CoreFcn_T) (const mxArray *S);

// Cummulated number of days before the first of each month, non leap year:
// Leading 0 for 1 base indexing!
static int32_T cumdays[] = {0, 0,31,59,90,120,151,181,212,243,273,304,334};

// Algorithm to obtain the serial datenumber:
#define DATE_TO_NUMBER  (double) (365 * year  + cumdays[mon] + day + \
                        year / 4 - year / 100 + year / 400 + \
                        (year % 4 != 0) - (year % 100 != 0) + (year % 400 != 0))
#define TIME_TO_NUMBER  (hour * 3600 + min * 60 + sec) / 86400.0
        
// Add leap day for leap years:
#define ADD_LEAP_DAY \
  if (mon > 2) { \
     if ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)) \
       { dNum += 1.0; } \
  }

// Main function: --------------------------------------------------------------
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
   mwSize    iC, nC, ndim;
   double    *Out;
   int       Format;
   CoreFcn_T CoreFcn;
   const mwSize *dim;
   const mxArray *aC, *C;
           
   // Get 2nd input or use the default, check number of inputs:
   if (nrhs == 1) {
      Format = 0;
   } else if (nrhs == 2) {
      if (mxGetNumberOfElements(prhs[1]) != 1 || !mxIsNumeric(prhs[1])) {
         ERROR("BadFormatType", "2nd input [Format] must be a scalar number.");
      }
      Format = (int) mxGetScalar(prhs[1]);
   } else {
      ERROR("BadNInput", "1 or 2 inputs required.");
   }

   // Set conversion function according to format:
   switch (Format) {
      case    0:  CoreFcn = Str0Num;     break;
      case    1:  CoreFcn = Str1Num;     break;
      case   29:  CoreFcn = Str29Num;    break;
      case   30:  CoreFcn = Str30Num;    break;
      case   31:  CoreFcn = Str31Num;    break;
      case  230:  CoreFcn = Str230Num;   break;
      case  231:  CoreFcn = Str231Num;   break;
      case  240:  CoreFcn = Str240Num;   break;
      case  241:  CoreFcn = Str241Num;   break;
      case 1000:  CoreFcn = Str1000Num;  break;
      case 1030:  CoreFcn = Str1030Num;  break;
      default:    ERROR("BadFormat", "Format not supported.");
   }

   // Get 1st input:
   C  = prhs[0];
   if (mxIsChar(C)) {         // Input is a string:
      plhs[0] = mxCreateDoubleScalar(CoreFcn(C));

   } else if (mxIsCell(C)) {  // Input is a cell:
      ndim    = mxGetNumberOfDimensions(C);
      dim     = mxGetDimensions(C);
      plhs[0] = mxCreateNumericArray(ndim, dim, mxDOUBLE_CLASS, mxREAL);
      Out     = mxGetPr(plhs[0]);
      nC      = mxGetNumberOfElements(C);
   
      for (iC = 0; iC < nC; iC++) {
         // Get cell element and check, if it is a string:
         if ((aC = mxGetCell(C, iC)) == NULL) {  // Not initialized:
            ERROR("BadInputType", "Cell element is not a string.");
         }
         if (!mxIsChar(aC)) {                    // Not a string:
            ERROR("BadInputType", "Cell element is not a string.");
         }
         
         *Out++ = CoreFcn(aC);
      }
      
   } else {
      ERROR("BadInputType", "Input must be a string or a cell.");
   }

   return;
}

// -----------------------------------------------------------------------------
double Str0Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // "dd-mmm-yyyy HH:MM:SS"   "01-Mar-2000 15:45:17"
  
  uint16_T *d16, mIndex;
  int32_T  year, mon, day, hour, min, sec;
  double   dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) < 20) {
     ERROR("BadDateString",
           "Bad string length for [dd-mmm-yyyy HH:MM:SS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[7] - 48) * 1000 + (d16[8] - 48) * 100 +
          d16[9] * 10 + d16[10] - 528;
  day  =  d16[0] * 10 + d16[1]  - 528;
  
  // Identify the month by the sum of the 2nd and 3rd character. Setting the 6th
  // bit of the characters makes them lower-case.
  // This is ugly and near to be dirty, but fast!
  mIndex = (d16[4] * 256 + d16[5]) | 0x2020;
  if (mIndex <= 25955) {  // Split the test in 2 halfs for speed
     switch (mIndex) {
        case 24942:  mon = 1;   break;  // 'jan'
        case 24946:  mon = 3;   break;  // 'mar'
        case 24953:  mon = 5;   break;  // 'may'
        case 25460:  mon = 10;  break;  // 'oct'
        case 25954:  mon = 2;   break;  // 'feb'
        case 25955:  mon = 12;  break;  // 'dec'
        default:
          ERROR("BadDateString",
                "Bad month for [dd-mmm-yyyy HH:MM:SS] format.");
     }
  } else {
     switch (mIndex) {
        case 25968:  mon = 9;   break;  // 'sep'
        case 28534:  mon = 11;  break;  // 'nov'
        case 28786:  mon = 4;   break;  // 'apr'
        case 30055:  mon = 8;   break;  // 'aug'
        case 30060:  mon = 7;   break;  // 'jul'
        case 30062:  mon = 6;   break;  // 'jun'
        default:
           ERROR("BadDateString",
                 "Bad month for [dd-mmm-yyyy HH:MM:SS] format.");
     }
  }
  
  hour = d16[12] * 10 + d16[13] - 528;
  min  = d16[15] * 10 + d16[16] - 528;
  sec  = d16[18] * 10 + d16[19] - 528;
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER + TIME_TO_NUMBER;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str1Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // "dd-mmm-yyyy"   "01-Mar-2000"
  
  uint16_T *d16;
  int32_T  year, mon, mIndex, day;
  double   dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) < 11) {
     ERROR("BadDateString", "Bad string length for [dd-mmm-yyyy] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[7] - 48) * 1000 + (d16[8] - 48) * 100 +
          d16[9] * 10 + d16[10] - 528;
  day  =  d16[0] * 10 + d16[1]  - 528;
  
  // Identify the month by the sum of the 2nd and 3rd character. Setting the 6th
  // bit make the charaters lower case.
  // Alternative without a multiplication: d16[4]+d16[5] is unique also.
  mIndex = (d16[4] * 256 + d16[5]) | 0x2020;
  if (mIndex <= 25955) {  // Split the test in 2 halfs for speed
     switch (mIndex) {
        case 24942:  mon = 1;   break;  // 'jan'
        case 24946:  mon = 3;   break;  // 'mar'
        case 24953:  mon = 5;   break;  // 'may'
        case 25460:  mon = 10;  break;  // 'oct'
        case 25954:  mon = 2;   break;  // 'feb'
        case 25955:  mon = 12;  break;  // 'dec'
        default:
          ERROR("BadDateString", "Bad month for [dd-mmm-yyyy] format.");
     }
  } else {
     switch (mIndex) {
        case 25968:  mon = 9;   break;  // 'sep'
        case 28534:  mon = 11;  break;  // 'nov'
        case 28786:  mon = 4;   break;  // 'apr'
        case 30055:  mon = 8;   break;  // 'aug'
        case 30060:  mon = 7;   break;  // 'jul'
        case 30062:  mon = 6;   break;  // 'jun'
        default:
           ERROR("BadDateString", "Bad month for [dd-mmm-yyyy] format.");
     }
  }
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str29Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // "yyyy-mm-dd"  "2000-03-01"
  
  uint16_T *d16;
  int32_T  year, mon, day;
  double   dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) < 10) {
      ERROR("BadDateString", "Bad string length for [yyyy-mm-dd] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[0] - 48) * 1000 + (d16[1] - 48) * 100 +
          d16[2] * 10 + d16[3] - 528;
  mon  = d16[5]  * 10 + d16[6] - 528;  // (d16[5]-48) * 10 + d16[6]-48
  day  = d16[8]  * 10 + d16[9] - 528;
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str30Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // "yyyymmddTHHMMSS"   "20000301T154517"

  int16_T *d16;
  int32_T year, mon, day, hour, min, sec;
  double  dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) < 15) {
      ERROR("BadDateString", "Bad string length for [yyyymmddTHHMMSS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[0] - 48) * 1000 + (d16[1] - 48) * 100 +
          d16[2] * 10 + d16[3]  - 528;
  mon  = d16[4]  * 10 + d16[5]  - 528;  // (d16[5]-48) * 10 + d16[6]-48
  day  = d16[6]  * 10 + d16[7]  - 528;
  hour = d16[9]  * 10 + d16[10] - 528;
  min  = d16[11] * 10 + d16[12] - 528;
  sec  = d16[13] * 10 + d16[14] - 528;
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER + TIME_TO_NUMBER;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str31Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // "yyyy-mm-dd HH:MM:SS"  "2000-03-01 15:45:17"
  
  uint16_T *d16;
  int32_T  year, mon, day, hour, min, sec;
  double   dNum;
  
  // Check number of characters:
  if (mxGetNumberOfElements(S) < 19) {
      ERROR("BadDateString",
            "Bad string length for [yyyy-mm-dd HH:MM:SS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (int32_T) ((d16[0] - 48) * 1000 + (d16[1] - 48) * 100 +
                     d16[2] * 10 + d16[3]  - 528);
  mon  = d16[5]  * 10 + d16[6]  - 528;  // (d16[5]-48) * 10 + d16[6]-48
  day  = d16[8]  * 10 + d16[9]  - 528;
  hour = d16[11] * 10 + d16[12] - 528;
  min  = d16[14] * 10 + d16[15] - 528;
  sec  = d16[17] * 10 + d16[18] - 528;
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER + TIME_TO_NUMBER;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str230Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // 'mm/dd/yyyyHH:MM:SS'   '12/24/200015:45:17'
  
  uint16_T *d16;
  int32_T  year, mon, day, hour, min, sec;
  double   dNum;
  
  // Check number of characters:
  if (mxGetNumberOfElements(S) < 18) {
     ERROR("BadDateString",
           "Bad string length for [mm/dd/yyyyHH:MM:SS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  mon  = d16[0]  * 10 + d16[1]  - 528;  // (d16[3]-48) * 10 + (d16[4]-48)
  day  = d16[3]  * 10 + d16[4]  - 528;
  year = (int32_T) ((d16[6] - 48) * 1000 + (d16[7] - 48) * 100 +
                     d16[8] * 10 + d16[9]  - 528);
  hour = d16[10] * 10 + d16[11] - 528;
  min  = d16[13] * 10 + d16[14] - 528;
  sec  = d16[16] * 10 + d16[17] - 528;
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER + TIME_TO_NUMBER;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str231Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // 'mm/dd/yyyy HH:MM:SS'  '12/24/2000 15:45:17'
  
  uint16_T *d16;
  int32_T  year, mon, day, hour, min, sec;
  double   dNum;
  
  // Check number of characters:
  if (mxGetNumberOfElements(S) < 19) {
     ERROR("BadDateString",
           "Bad string length for [mm/dd/yyyy HH:MM:SS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  mon  = d16[0]  * 10 + d16[1]  - 528;  // (d16[3]-48) * 10 + (d16[4]-48)
  day  = d16[3]  * 10 + d16[4]  - 528;
  year = (int32_T) ((d16[6] - 48) * 1000 + (d16[7] - 48) * 100 +
                     d16[8] * 10 + d16[9]  - 528);
  hour = d16[11] * 10 + d16[12] - 528;
  min  = d16[14] * 10 + d16[15] - 528;
  sec  = d16[17] * 10 + d16[18] - 528;
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER + TIME_TO_NUMBER;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str240Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // 'dd/mm/yyyyHH:MM:SS'   '24/12/200015:45:17'
  
  uint16_T *d16;
  int32_T  year, mon, day, hour, min, sec;
  double   dNum;
  
  // Check number of characters:
  if (mxGetNumberOfElements(S) < 18) {
     ERROR("BadDateString",
           "Bad string length for [dd/mm/yyyyHH:MM:SS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  day  = d16[0]  * 10 + d16[1]  - 528;
  mon  = d16[3]  * 10 + d16[4]  - 528;  // (d16[3]-48) * 10 + (d16[4]-48)
  year = (int32_T) ((d16[6] - 48) * 1000 + (d16[7] - 48) * 100 +
                     d16[8] * 10 + d16[9]  - 528);
  hour = d16[10] * 10 + d16[11] - 528;
  min  = d16[13] * 10 + d16[14] - 528;
  sec  = d16[16] * 10 + d16[17] - 528;
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER + TIME_TO_NUMBER;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str241Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // 'dd/mm/yyyy HH:MM:SS'  '24/12/2000 15:45:17'
  
  uint16_T *d16;
  int32_T  year, mon, day, hour, min, sec;
  double   dNum;
  
  // Check number of characters:
  if (mxGetNumberOfElements(S) < 19) {
     ERROR("BadDateString",
           "Bad string length for [dd/mm/yyyy HH:MM:SS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  day  = d16[0]  * 10 + d16[1]  - 528;
  mon  = d16[3]  * 10 + d16[4]  - 528;  // (d16[3]-48) * 10 + (d16[4]-48)
  year = (int32_T) ((d16[6] - 48) * 1000 + (d16[7] - 48) * 100 +
                     d16[8] * 10 + d16[9]  - 528);
  hour = d16[11] * 10 + d16[12] - 528;
  min  = d16[14] * 10 + d16[15] - 528;
  sec  = d16[17] * 10 + d16[18] - 528;
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER + TIME_TO_NUMBER;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str1000Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // "dd-mmm-yyyy HH:MM:SS.FFF"   "01-Mar-2000 15:45:17.123"
  
  uint16_T *d16, mIndex;
  int32_T  year, mon, day, hour, min, sec, mil;
  double   dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) < 24) {
     ERROR("BadDateString",
           "Bad string length for [dd-mmm-yyyy HH:MM:SS.FFF] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[7] - 48) * 1000 + (d16[8] - 48) * 100 +
          d16[9] * 10 + d16[10] - 528;
  day  =  d16[0] * 10 + d16[1]  - 528;
  
  // Identify the month by the sum of the 2nd and 3rd character. Setting the 6th
  // bit makes the characters lower-case.
  // This is ugly and near to be dirty, but fast!
  mIndex = (d16[4] * 256 + d16[5]) | 0x2020;
  if (mIndex <= 25955) {  // Split the test in 2 halfs for speed
     switch (mIndex) {
        case 24942:  mon = 1;   break;  // 'jan'
        case 24946:  mon = 3;   break;  // 'mar'
        case 24953:  mon = 5;   break;  // 'may'
        case 25460:  mon = 10;  break;  // 'oct'
        case 25954:  mon = 2;   break;  // 'feb'
        case 25955:  mon = 12;  break;  // 'dec'
        default:
          ERROR("BadDateString",
                "Bad month in [dd-mmm-yyyy HH:MM:SS] format.");
     }
  } else {
     switch (mIndex) {
        case 25968:  mon = 9;   break;  // 'sep'
        case 28534:  mon = 11;  break;  // 'nov'
        case 28786:  mon = 4;   break;  // 'apr'
        case 30055:  mon = 8;   break;  // 'aug'
        case 30060:  mon = 7;   break;  // 'jul'
        case 30062:  mon = 6;   break;  // 'jun'
        default:
           ERROR("BadDateString",
                 "Bad month in [dd-mmm-yyyy HH:MM:SS] format.");
     }
  }
  
  hour = d16[12] * 10 + d16[13] - 528;
  min  = d16[15] * 10 + d16[16] - 528;
  sec  = d16[18] * 10 + d16[19] - 528;
  mil  = (d16[21] - 48) * 100 + (d16[22] - 48) * 10 + (d16[23] - 48);
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER +
         (hour * 3600000 + min * 60000 + sec * 1000 + mil) / 86400000.0;
  ADD_LEAP_DAY
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str1030Num(const mxArray *S)
{
  // Convert a single string to a serial date number.
  // "yyyymmddTHHMMSS.FFF"   "20000301T154517.123"
  
  uint16_T *d16;
  int32_T  year, mon, day, hour, min, sec, mil;
  double   dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) < 19) {
      ERROR("BadDateString",
            "Bad string length for [yyyymmddTHHMMSS.FFF] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[0] - 48) * 1000 + (d16[1] - 48) * 100 +
          d16[2] * 10 + d16[3]  - 528;
  mon  = d16[4]  * 10 + d16[5]  - 528;  // (d16[5]-48) * 10 + d16[6]-48
  day  = d16[6]  * 10 + d16[7]  - 528;
  hour = d16[9]  * 10 + d16[10] - 528;
  min  = d16[11] * 10 + d16[12] - 528;
  sec  = d16[13] * 10 + d16[14] - 528;
  mil  = (d16[16] - 48) * 100 + (d16[17] - 48) * 10 + (d16[18] - 48);
  
  // Calculate the serial date number:
  dNum = DATE_TO_NUMBER +
         (hour * 3600000 + min * 60000 + sec * 1000 + mil) / 86400000.0;
  ADD_LEAP_DAY
  
  return (dNum);
}

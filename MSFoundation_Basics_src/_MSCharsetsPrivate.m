/*
 
 _MSCharsetsPrivate.m
 
 This file is is a part of the MicroStep Framework.
 
 Copyright Herve MALAINGRE & Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use, 
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info". 
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability. 
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or 
 data to be ensured and,  more generally, to use and operate it in the 
 same conditions as regards security. 
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 */
#import "MSFoundation_Private.h"

char *__MSUnicodeToASCIIOne[768] = {
    /* 0080 000 */ NULL, NULL, "\001'", "\001f", "\001\"", "\003...", NULL, NULL, "\001^", NULL, "\001S", "\001<", "\002OE", NULL, NULL, NULL,
    /* 0090 016 */ NULL, "\001'", "\001'" , "\001\"", "\001\"", NULL, "\001-", "\001-", "\001~", "\002TM", "\001S", "\001>", "\002oe", NULL, NULL, "\001Y",
    /* 00A0 032 */ "\001 ", "\001!", NULL, "\003GBP", NULL, "\003JPY", "\001|", NULL, NULL, "\003(c)", "\001a", "\001\"", NULL, "\001-", "\003(R)", NULL,
    /* 00B0 048 */ "\001o", "\003+/-", "\0012", "\0013", NULL, NULL, NULL, "\001.", NULL, "\0011", "\001o", "\001\"", "\0031/4", "\0031/2", "\0033/4", NULL,
    /* 00C0 064 */ "\001A", "\001A", "\001A", "\001A", "\001A", "\001A", "\002AE", "\001C", "\001E", "\001E", "\001E", "\001E", "\001I", "\001I", "\001I", "\001I",
    /* 00D0 080 */ NULL, "\001N", "\001O", "\001O", "\001O", "\001O", "\001O", NULL, "\001O", "\001U", "\001U", "\001U", "\001U", "\001Y", NULL, "\002ss",
    /* 00E0 096 */ "\001a", "\001a", "\001a", "\001a", "\001a", "\001a", "\002ae", "\001c", "\001e", "\001e", "\001e", "\001e", "\001i", "\001i", "\001i", "\001i",
    /* 00F0 112 */ NULL, "\001n", "\001o", "\001o", "\001o", "\001o", "\001o", NULL, "\001o", "\001u", "\001u", "\001u", "\001u", "\001y", NULL, "\001y",
    /* 0100 128 */ "\001A", "\001a", "\001A", "\001a", "\001A", "\001a", "\001C", "\001c", "\001C", "\001c", "\001C", "\001c", "\001C", "\001c", "\001D", "\001d",
    /* 0110 144 */ "\001D", "\001d", "\001E", "\001e", "\001E", "\001e", "\001E", "\001e", "\001E", "\001e", "\001E", "\001e", "\001G", "\001g", "\001G", "\001g",
    /* 0120 160 */ "\001G", "\001g", "\001G", "\001g", "\001H", "\001h", "\001I", "\001i", "\001I", "\001i", "\001I", "\001i", "\001I", "\001i", "\001I", "\001i",
    /* 0130 176 */ "\001I", "\001i", "\002IJ", "\002ij", "\001J", "\001j", "\001K", "\001k", "\001k", "\001L", "\001l", "\001L", "\001l", "\001L", "\001l", "\001L",
    /* 0140 192 */ "\001l", "\001L", "\001l", "\001N", "\001n", "\001N", "\001n", "\001N", "\001n", "\001n", "\001N", "\001n", "\001O", "\001o", "\001O", "\001o",
    /* 0150 208 */ "\001O", "\001o", "\002OE", "\002oe", "\001R", "\001r", "\001R", "\001r", "\001R", "\001r", "\001S", "\001s", "\001S", "\001s", "\001S", "\001s",
    /* 0160 224 */ "\001S", "\001s", "\001T", "\001t", "\001T", "\001t", "\001T", "\001t", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u",
    /* 0170 240 */ "\001U", "\001u", "\001U", "\001u", "\001W", "\001w", "\001Y", "\001y", "\001Y", "\001Z", "\001z", "\001Z", "\001z", "\001Z", "\001z", "\001s",
    /* 0180 256 */ "\001b", "\001B", "\001B", "\001b", "\001B", "\001b", "\001O", "\001C", "\001c",  "\001D", "\001d", "\001D", "\001d", NULL, "\001E", NULL,
    /* 0190 272 */ "\001e", "\001F", "\001f", "\001G", NULL, "\002hv", "\001I", "\001I", "\001K", "\001k", "\001l", NULL, "\001m", "\001N", "\001n", "\001O",
    /* 01A0 288 */ "\001O", "\001o", "\002OI", "\002oi", "\001P", "\001p", "\002YR", NULL, NULL, NULL, NULL, "\001t", "\001T", "\001t", "\001T", "\001U",
    /* 01B0 304 */ "\001u", NULL, "\001V", "\001Y", "\001y", "\001Z", "\001z", NULL, NULL, NULL, NULL, "\0012", NULL, NULL, NULL, NULL,
    /* 01C0 320 */ "\001|", NULL, NULL, "\001!", "\002DZ", "\002Dz", "\002dz", "\002LJ", "\002Lj", "\002lj", "\002NJ", "\002Nj", "\002nj", "\001A", "\001a", "\001I",
    /* 01D0 336 */ "\001i", "\001O", "\001o", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", NULL, "\001A", "\001a",
    /* 01E0 352 */ "\001A", "\001a", "\002AE", "\002ae", "\001G", "\001g", "\001G", "\001g", "\001K", "\001k", "\001O", "\001o", "\001O", "\001o", NULL, NULL,
    /* 01F0 368 */ "\001j", "\002DZ", "\002Dz", "\002dz", "\001G", "\001g", NULL, NULL, "\001N", "\001n", "\001A", "\001a", "\002AE", "\002ae", "\001O", "\001o",
    /* 0200 384 */ "\001A", "\001a", "\001A", "\001a", "\001E", "\001e", "\001E", "\001e", "\001I", "\001i", "\001I", "\001i", "\001O", "\001o", "\001O", "\001o",
    /* 0210 400 */ "\001R", "\001r", "\001R", "\001r", "\001U", "\001u", "\001U", "\001u", "\001S", "\001s", "\001T", "\001t", NULL, NULL, "\001H", "\001h",
    /* 0220 416 */ "\001N", "\001d", NULL, NULL, "\001Z", "\001z", "\001A", "\001a", "\001E", "\001e", "\001O", "\001o", "\001O", "\001o", "\001O", "\001o",
    /* 0230 432 */ "\001O", "\001o", "\001Y", "\001y", "\001l", "\001n", "\001t", "\001j", "\002db", "\002qp", "\001A", "\001C", "\001c", "\001L", "\001T", "\001s",
    /* 0240 448 */ "\001z", NULL, NULL, "\001B", "\001U", "\001V", "\001E", "\001e", "\001J", "\001j", "\001Q", "\001q", "\001R", "\001r", "\001Y", "\001y",
    /* 0250 464 */ "\001a", NULL, NULL, "\001b", "\001o", "\001c", "\001d", "\001d", "\001e", NULL, NULL, "\001e", "\001e", "\001e", "\001e", "\001j",
    /* 0260 480 */ "\001g", "\001g", "\001G", NULL, NULL, "\001h", "\001h", "\001h", "\001i", "\001i", "\001I", "\001l", "\001l", "\001l", NULL, "\001m",
    /* 0270 496 */ "\001m", "\001m", "\001n", "\001n", "\001N", "\001o", "\002OE", NULL, NULL, "\001r", "\001r", "\001r", "\001r", "\001r", "\001r", "\001r",
    /* 0280 512 */ "\001R", "\001R", "\001s", NULL, NULL, NULL, NULL, "\001t", "\001t", "\001u", NULL, "\001v", "\001v", "\001w", "\001y", "\001Y",
    /* 0290 528 */ "\001z", "\001z", NULL, NULL, NULL, NULL, NULL, "\001C", NULL, "\001B", "\001e", "\001G", "\001H", "\001j", "\001k", "\001L",
    /* 02A0 544 */ "\001q", NULL, NULL, "\002dz", "\002dz", "\002dz", "\002ts", NULL, "\002tc", NULL, "\002ls", "\002lz", NULL, NULL, "\001h", "\001h",
    /* 02B0 560 */ "\001h", "\001h", "\001j", "\001r", "\001r", "\001r", "\001R", "\001w", "\001y", "\001'", "\001\"", "\001'", "\001'", "\001'", NULL, NULL,
    /* 02C0 576 */ NULL, NULL, "\001<", "\001>", NULL, NULL, "\001^", "\001^", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 02D0 592 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, "\001~", NULL, NULL, NULL,
    /* 02E0 608 */ NULL, "\001l", "\001s", "\001x", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, "\001=", NULL, NULL,
    /* 02F0 624 */ NULL, "\001<", "\001>", NULL, NULL, NULL, NULL, "\001~", "\001:", NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 0300 640 */ NULL, NULL, "\001^", "\001~", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 0310 656 */ NULL, NULL, "\001'", "\001'", "\001'", "\001'", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 0320 672 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 0330 688 */ "\001~", NULL, "\001_", NULL, "\001~", "\001-", "\001-", "\001/", "\001/", NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 0340 704 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 0350 720 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 0360 739 */ NULL, NULL, NULL, "\001a", "\001e", "\001i", "\001o", "\001u", "\001c", "\001d", "\001h", "\001m", "\001r", "\001t", "\001v", "\001x",
    /* 0370 752 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, "\001;", NULL
    /* 0380 768 */
} ;

char *__MSUnicodeToASCIITwo[1168] = {
    /* 1D00 000 */ "\001A", "\002AE", "\002ae", "\001B", "\001C", "\001D", NULL, "\001E", "\001e", "\001i", "\001J", "\001K", "\001L", "\001M", "\001N", "\001O",
    /* 1D10 016 */ "\001O", "\001o", "\001o" , "\001o", "\002oe", NULL, "\001o", "\001o", "\001P", "\001R", "\001R", "\001T", "\001U", "\001u", "\001u", "\001m",
    /* 1D20 032 */ "\001V", "\001W", "\001Z", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, "\001A", "\002AE", "\001B", "\001B",
    /* 1D30 048 */ "\001D", "\001E", "\001E", "\001G", "\001H", "\001I", "\001J", "\001K", "\001L", "\001M", "\001N", "\001N", "\001O", NULL, "\001P", "\001R",
    /* 1D40 064 */ "\001T", "\001U", "\001W", "\001a", "\001a", NULL, "\002ae", "\001b", "\001d", "\001e", NULL, "\001e", "\001e", "\001g", "\001i", "\001k",
    /* 1D50 080 */ "\001m", "\001n", "\001o", "\001o", "\001o", "\001o", "\001p", "\001t", "\001u", "\001u", "\001m", "\001v", NULL, NULL, NULL, NULL,
    /* 1D60 096 */ NULL, NULL, "\001i", "\001r", "\001u", "\001v", NULL, NULL, NULL, NULL, NULL, "\002ue", "\001b", "\001d", "\001f", "\001m",
    /* 1D70 112 */ "\001n", "\001p", "\001r", "\001r", "\001s", "\001t", "\001z", "\001g", NULL, NULL, "\002th", "\001I", NULL, "\001p", "\001u", NULL,
    /* 1D80 128 */ "\001b", "\001d", "\001f", "\001g", "\001k", "\001l", "\001m", "\001n", "\001p", "\001r", "\001s", NULL, "\001v", "\001x", "\001z", "\001a",
    /* 1D90 144 */ "\001a", "\001d", "\001e", "\001e", "\001e", NULL, "\001i", "\001o", NULL, "\001u", NULL, NULL, "\001c", "\001c", NULL, "\001e",
    /* 1DA0 160 */ "\001f", "\001j", "\001g", "\001h", "\001i", NULL, "\001I", "\001I", "\001j", "\001l", "\001l", "\001L", "\001m", "\001m", "\001n", "\001n",
    /* 1DB0 176 */ "\001N", "\001o", NULL, "\001s", NULL, "\001t", "\001u", NULL, "\001U", "\001v", "\001v", "\001z", "\001z", "\001z", NULL, NULL,
    /* 1DC0 192 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, "\001r", NULL, NULL, NULL, NULL, NULL,
    /* 1DD0 208 */ NULL, NULL, NULL, NULL, "\002ae", "\002ao", "\002av", "\001c", "\001d", NULL, NULL, "\001G", "\001k", "\001l", "\001L", "\001M",
    /* 1DE0 224 */ "\001n", "\001N", "\001R", "\001r", "\001s", "\001s", "\001z", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1DF0 240 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1E00 256 */ "\001A", "\001a", "\001B", "\001b", "\001B", "\001b", "\001B", "\001b", "\001C",  "\001c", "\001D", "\001d", "\001D", "\001d", "\001D", "\001d",
    /* 1E10 272 */ "\001D", "\001d", "\001D", "\001d", "\001E", "\001e", "\001E", "\001e", "\001E", "\001e", "\001E", "\001e", "\001E", "\001e", "\001F", "\001f",
    /* 1E20 288 */ "\001G", "\001g", "\001H", "\001h", "\001H", "\001h", "\001H", "\001h", "\001H", "\001h", "\001H", "\001h", "\001I", "\001i", "\001I", "\001i",
    /* 1E30 304 */ "\001K", "\001k", "\001K", "\001k", "\001K", "\001k", "\001L", "\001l", "\001L", "\001l", "\001L", "\001l", "\001L", "\001l", "\001M", "\001m",
    /* 1E40 320 */ "\001M", "\001m", "\001M", "\001m", "\001N", "\001n", "\001N", "\001n", "\001N", "\001n", "\001N", "\001n", "\001O", "\001o", "\001O", "\001o",
    /* 1E50 336 */ "\001O", "\001o", "\001O", "\001o", "\001P", "\001p", "\001P", "\001p", "\001R", "\001r", "\001R", "\001r", "\001R", "\001r", "\001R", "\001r",
    /* 1E60 352 */ "\001S", "\001s", "\001S", "\001s", "\001S", "\001s", "\001S", "\001s", "\001S", "\001s", "\001T", "\001t", "\001T", "\001t", "\001T", "\001t",
    /* 1E70 368 */ "\001T", "\001t", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", "\001V", "\001v", "\001V", "\001v",
    /* 1E80 384 */ "\001W", "\001w", "\001W", "\001w", "\001W", "\001w", "\001W", "\001w", "\001W", "\001w", "\001X", "\001x", "\001X", "\001x", "\001Y", "\001y",
    /* 1E90 400 */ "\001Z", "\001z", "\001Z", "\001z", "\001Z", "\001z", "\001h", "\001t", "\001w", "\001y", "\001a", "\001s", "\001s", "\001s", "\002SS", NULL,
    /* 1EA0 416 */ "\001A", "\001a", "\001A", "\001a", "\001A", "\001a", "\001A", "\001a", "\001A", "\001a", "\001A", "\001a", "\001A", "\001a", "\001A", "\001a",
    /* 1EB0 432 */ "\001A", "\001a", "\001A", "\001a", "\001A", "\001a", "\001A", "\001a", "\001E", "\001e", "\001E", "\001e", "\001E", "\001e", "\001E", "\001e",
    /* 1EC0 448 */ "\001E", "\001e", "\001E", "\001e", "\001E", "\001e", "\001E", "\001e", "\001I", "\001i", "\001I", "\001i", "\001O", "\001o", "\001O", "\001o",
    /* 1ED0 464 */ "\001O", "\001o", "\001O", "\001o", "\001O", "\001o", "\001O", "\001o", "\001O", "\001o", "\001O", "\001o", "\001O", "\001o", "\001O", "\001o",
    /* 1EE0 480 */ "\001O", "\001o", "\001O", "\001o", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u", "\001U", "\001u",
    /* 1EF0 496 */ "\001U", "\001u", "\001Y", "\001y", "\001Y", "\001y", "\001Y", "\001y", "\001Y", "\001y", "\002LL", "\002ll", "\001V", "\001v", "\001Y", "\001y",
    /* 1F00 512 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1F10 528 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1F20 544 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1F30 560 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1F40 576 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1F50 592 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1F60 608 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1F70 624 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1F80 640 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1F90 656 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1FA0 672 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1FB0 688 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1FC0 704 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1FD0 720 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1FE0 736 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 1FF0 752 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 2000 768 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 2010 784 */ "\001-", "\001-", "\001-", "\001-", "\001-", "\001-", NULL, NULL, "\001'", "\001'", "\001'", "\001'", "\001\"", "\001\"", "\001\"", "\001\"",
    /* 2020 800 */ NULL, NULL, NULL , NULL, "\001.", "\002..", "\003...", "\001.", "\001\015", "\002\015\012", NULL, NULL, NULL, NULL, NULL, "\001 ",
    /* 2030 816 */ NULL, NULL, "\001'", "\002''", "\003'''", "\001'", "\002''", "\003'''", "\001^", "\001<", "\001>", NULL, "\002!!", "\002!?", NULL, NULL,
    /* 2040 832 */ NULL, NULL, "\003***", "\001-", "\001/", "\001[", "\001]", "\002??", "\002?!", "\002!?", NULL, NULL, NULL, NULL, "\001*", "\001;",
    /* 2050 848 */ NULL, "\002**", "\001%", "\001~", NULL, "\001*", NULL, "\004''''", NULL, NULL, "\001:", NULL, NULL, NULL, NULL, "\001 ",
    /* 2060 864 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 2070 880 */ "\0010", "\001i", NULL, NULL, "\0014", "\0015", "\0016", "\0017", "\0018", "\0019", "\001+", "\001-", "\001=", "\001(", "\001)", "\001n",
    /* 2080 896 */ "\0010", "\0011", "\0012", "\0013", "\0014", "\0015", "\0016", "\0017", "\0018", "\0019", "\001+", "\001-", "\001=", "\001(", "\001)", NULL,
    /* 2090 912 */ "\001a", "\001e", "\001o", "\001x", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 20A0 828 */ "\003EUR", NULL, "\003BRL", "\003FRF", "\003ITL", NULL, NULL, "\003ESP", "\003INR", "\003KRW", "\003ILS", "\003VND", "\003EUR", "\003LAK", "\003MNT", "\003GRD",
    /* 20B0 944 */ NULL, NULL, "\003PYG", NULL, "\003UAH", "\003GHS", NULL, NULL, NULL, NULL, "\001\"", NULL, NULL, NULL, NULL, NULL,
    /* 20C0 960 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 20D0 976 */ NULL, NULL, "\001|", "\001|", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 20E0 992 */ NULL, NULL, NULL, NULL, NULL, "\001\\", NULL, NULL, "\003...", NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 20F0 1008 */ "\001*", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* 2100 1024 */ "\003a/c", "\003a/s", "\001C", NULL, NULL, "\003c/o", "\003c/u", NULL, NULL, NULL, "\001g", "\001H", "\001h", "\001H", "\001h", "\001h",
    /* 2110 1040 */ "\001I", "\001I", "\001L", "\001l", "\002lb", "\001N", "\002No", "\003(P)", "\001P",  "\001P", "\001Q", "\001R", "\001R", "\001R", "\001R", "\001R",    
    /* 2120 1056 */ "\002SM", "\003TEL", "\002TM", NULL, "\001Z", NULL, NULL, NULL, "\001Z", NULL, "\001K", "\001A", "\001B", "\001C", "\001e", "\001e",
    /* 2130 1088 */ "\001E", "\001F", "\001F", "\001M", "\001o", NULL, NULL, NULL, NULL, "\001i", "\001Q", "\003FAX", NULL, NULL, NULL, NULL,
    /* 2140 1104 */ NULL, "\001G", "\001L", "\001L", "\001Y", "\001D", "\001d", "\001e", "\001i", "\001j", NULL, "\001&", NULL, "\003A/S", "\001f", NULL,
    /* 2150 1120 */ NULL, NULL, NULL, "\0031/3", "\0032/3", "\0031/5", "\0032/5", "\0033/5", "\0034/5", "\0031/6", "\0035/6", "\0031/8", "\0033/8", "\0035/8", "\0037/8", "\0021/",
    /* 2160 1136 */ "\001I", "\002II", "\003III", "\002IV", "\001V", "\002VI", "\003VII", "\004VIII", "\002IX", "\001X", "\002XI", "\003XII", "\001L", "\001C", "\001D", "\001M",
    /* 2170 1152 */ "\001i", "\002ii", "\003iii", "\002iv", "\001v", "\002vi", "\003vii", "\004viii", "\002ix", "\001x", "\002xi", "\003xii", "\001l", "\001c", "\001d", "\001m"
    /* 2180 1168 */ 
} ;

char *__MSUnicodeToASCIIThree[160] = {
    /* 2460 000 */ "\003(1)", "\003(2)", "\003(3)", "\003(4)", "\003(5)", "\003(6)", "\003(7)", "\003(8)", "\003(9)", "\004(10)", "\004(11)", "\004(12)", "\004(13)", "\004(14)", "\004(15)", "\004(16)",
    /* 2470 016 */ "\004(17)", "\004(18)", "\004(19)" , "\004(20)", "\003(1)", "\003(2)", "\003(3)", "\003(4)", "\003(5)", "\003(6)", "\003(7)", "\003(8)", "\003(9)", "\004(10)", "\004(11)", "\004(12)",
    /* 2480 032 */ "\004(13)", "\004(14)", "\004(15)", "\004(16)", "\004(17)", "\004(18)", "\004(19)" , "\004(20)", "\0021.", "\0022.", "\0023.", "\0024.", "\0025.", "\0026.", "\0027.", "\0028.",
    /* 2490 048 */ "\0029.", "\00310.", "\00311.", "\00312.", "\00313.", "\00314.", "\00315.", "\00316.", "\00317.", "\00318.", "\00319.", "\00320.", "\003(a)", "\003(b)", "\003(c)", "\003(d)",
    /* 24A0 064 */ "\003(e)", "\003(f)", "\003(g)", "\003(h)", "\003(i)", "\003(j)", "\003(k)", "\003(l)", "\003(m)", "\003(n)", "\003(o)", "\003(p)", "\003(q)", "\003(r)", "\003(s)", "\003(t)",
    /* 24B0 080 */ "\003(u)", "\003(v)", "\003(w)", "\003(x)", "\003(y)", "\003(z)", "\003(A)", "\003(B)", "\003(C)", "\003(D)", "\003(E)", "\003(F)", "\003(G)", "\003(H)", "\003(I)", "\003(J)",
    /* 24C0 096 */ "\003(K)", "\003(L)", "\003(M)", "\003(N)", "\003(O)", "\003(P)", "\003(Q)", "\003(R)", "\003(S)", "\003(T)", "\003(U)", "\003(V)", "\003(W)", "\003(X)", "\003(Y)", "\003(Z)",
    /* 24D0 112 */ "\003(a)", "\003(b)", "\003(c)", "\003(d)", "\003(e)", "\003(f)", "\003(g)", "\003(h)", "\003(i)", "\003(j)", "\003(k)", "\003(l)", "\003(m)", "\003(n)", "\003(p)", "\003(p)",
    /* 24E0 128 */ "\003(q)", "\003(r)", "\003(s)", "\003(t)", "\003(u)", "\003(v)", "\003(w)", "\003(x)", "\003(y)", "\003(z)", "\003(0)", "\004(11)", "\004(12)", "\004(13)", "\004(14)", "\004(15)",
    /* 24F0 144 */ "\004(16)", "\004(17)", "\004(18)", "\004(19)", "\004(20)", "\003(1)", "\003(2)", "\003(3)", "\003(4)", "\003(5)", "\003(6)", "\003(7)", "\003(8)", "\003(9)", "\004(10)", "\003(0)"
    /* 2500 160 */
} ;

char *__MSUnicodeToASCIIFour[48] = {
    /* 2770 000 */ "\001<", "\001>", "\001[", "\001]", "\001{", "\001}", "\003(1)", "\003(2)", "\003(3)", "\003(4)", "\003(5)", "\003(6)", "\003(7)", "\003(8)", "\003(9)", "\004(10)",
    /* 2780 016 */ "\003(1)", "\003(2)", "\003(3)", "\003(4)", "\003(5)", "\003(6)", "\003(7)", "\003(8)", "\003(9)", "\004(10)", "\003(1)", "\003(2)", "\003(3)", "\003(4)", "\003(5)", "\003(6)",
    /* 2790 032 */ "\003(7)", "\003(8)", "\003(9)", "\004(10)", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    /* 27A0 048 */ 
} ;

char *__MSUnicodeToASCIIFive[32] = {
    /* 2C60 000 */ "\001L", "\001l", "\001L", "\001P", "\001R", "\001a", "\001t", "\001H", "\001h", "\001K", "\001k", "\001Z", "\001z", NULL, "\001M", "\001A",
    /* 2C70 016 */ NULL, "\001v", "\001W" , "\001w", "\001v", "\001H", "\001h", NULL, "\001e", "\001r", "\001o", "\001E", "\001j", "\001V", NULL, NULL
    /* 2C80 032 */
} ;    

char *__MSUnicodeToASCIISix[208] = {
    /* A730 000 */ "\001F", "\001S", "\002AA", "\002aa", NULL, NULL, NULL, NULL, "\002AV", "\002av", "\002AV", "\002av", NULL, NULL, "\001C", "\001c",
    /* A740 016 */ "\001K", "\001k", "\001K" , "\001k", "\001K", "\001k", NULL, NULL, "\001L", "\001l", "\001O", "\001o", NULL, NULL, "\002OO", "\002oo", 
    /* A750 032 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, "\001R", "\001r", NULL, NULL, NULL, NULL,
    /* A760 048 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* A770 064 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* A780 080 */ "\001L", "\001l", NULL, NULL, NULL, NULL, NULL, NULL, "\001^", "\001:", "\001=", NULL, NULL, NULL, NULL, NULL,
    /* A790 096 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* A7A0 112 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* A7B0 128 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* A7C0 144 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* A7D0 160 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* A7E0 176 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* A7F0 192 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, "\001F", "\001P", "\001M", "\001I", "\001M"
    /* A800 208 */
} ;    


// these chars seem to be unknown
//char *__MSUnicodeToASCIISeven[16] = {
//    /* F000 000 */ NULL, "\002fi", "\002fl", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
//    /* F010 016 */ 
//} ;    

// these chars seem to be unknown too
//char *__MSUnicodeToASCIIHeight[64] = {
//    /* F310 000 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, "\001A", "\001A", "\001A", "\001A", "\001E", "\001E", "\001E",
//    /* F320 016 */ "\001E", "\001O", "\001O", "\001O", "\001O", "\001E", "\001E", "\001E", "\001E", "\001E", "\001a", "\001a", "\001a", "\001a", "\001a", "\001e",
//    /* F330 032 */ "\001e", "\001e", "\001e", "\001i", "\001i", "\001i", "\001i", "\001o", "\001o", "\001o", "\001o", "\001u", "\001u", "\001u", "\001u", "\001u",
//    /* F340 048 */ "\001u", "\001u", "\001u", "\001u", "\001e", "\001e", "\001e", "\001e", "\001e", "\001g", NULL, NULL, NULL, NULL, NULL, NULL
//    /* F350 064 */ 
//} ;    


char *__MSUnicodeToASCIINine[16] = {
    /* FB00 000 */ "\002ff", "\002fi", "\002fl", "\003ffi", "\003ffl", "\002ft", "\002st", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FB10 016 */ 
} ;    

char *__MSUnicodeToASCIITen[336] = {
    /* FE10 000 */ NULL, NULL, NULL, "\001:", "\001;", "\001!", "\001?", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FE20 016 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FE30 032 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FE40 048 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FE50 064 */ "\001,", NULL, "\001.", NULL, "\001;", "\001:", "\001?", "\001!", "\001-", "\001(", "\001)", "\001{", "\001}", "\001[", "\001]", "\001#",
    /* FE60 080 */ "\001&", "\001*", "\001+", "\001-", "\001<", "\001>", "\001=", NULL, "\001\\", "\001$", "\001%", "\001@", NULL, NULL, NULL, NULL,
    /* FE70 096 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FE80 112 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FE90 128 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FEA0 144 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FEB0 160 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FEC0 176 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FED0 192 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FEE0 208 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FEF0 224 */ NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    /* FF00 240 */ NULL, "\001!", "\001\"", "\001#", "\001$", "\001%", "\001&", "\001'", "\001(", "\001)", "\001*", "\001+", "\001,", "\001-", "\001.", "\001/",
    /* FF10 256 */ "\0010", "\0011", "\0012", "\0013", "\0014", "\0015", "\0016", "\0017", "\0018", "\0019", "\001:", "\001;", "\001<", "\001=", "\001>", "\001?",
    /* FF20 272 */ "\001@", "\001A", "\001B", "\001C", "\001D", "\001E", "\001F", "\001G", "\001H", "\001I", "\001J", "\001K", "\001L", "\001M", "\001N", "\001O",
    /* FF30 288 */ "\001P", "\001Q", "\001R", "\001S", "\001T", "\001U", "\001V", "\001W", "\001X", "\001Y", "\001Z", "\001[", "\001\\", "\001]", "\001^", "\001_",
    /* FF40 304 */ "\001'", "\001a", "\001b", "\001c", "\001d", "\001e", "\001f", "\001g", "\001h", "\001i", "\001j", "\001k", "\001l", "\001m", "\001n", "\001o",
    /* FF50 320 */ "\001p", "\001q", "\001r", "\001s", "\001t", "\001u", "\001v", "\001w", "\001x", "\001y", "\001z", "\001{", "\001|", "\001}", "\001~", NULL
    /* FF60 336 */ 
} ;    


void _MSFillCBufferFromString(CBuffer *buf, SES ses)
{
    NSUInteger i, len, end ;

    for (i= SESStart(ses), end= SESEnd(ses); i < end;) {
        unichar c = SESIndexN(ses, &i) ;
        if (c < 0x0080) { 
            CBufferAppendByte(buf, (MSByte)c);
        }
        else {
            char *tmp = NULL;
            
            if (c < 0x0380) { tmp = __MSUnicodeToASCIIOne[c - 0x0080] ; }
            else if (c >= 0x1D00 && c < 0x2180) { tmp = __MSUnicodeToASCIITwo[c - 0x1D00] ; }
            else if (c >= 0x2460 && c < 0x2500) { tmp = __MSUnicodeToASCIIThree[c - 0x2460] ; }
            else if (c >= 0x2770 && c < 0x27A0) { tmp = __MSUnicodeToASCIIFour[c - 0x2770] ; }
            else if (c >= 0x2C60 && c < 0x2C80) { tmp = __MSUnicodeToASCIIFive[c - 0x2C60] ; }
            else if (c >= 0xA730 && c < 0xA800) { tmp = __MSUnicodeToASCIISix[c - 0xA730] ; }
            //else if (c >= 0xF000 && c < 0xF010) { tmp = __MSUnicodeToASCIISeven[c - 0xF000] ; }
            //else if (c >= 0xF310 && c < 0xF350) { tmp = __MSUnicodeToASCIIHeight[c - 0xF310] ; }
            else if (c >= 0xFB00 && c < 0xFB10) { tmp = __MSUnicodeToASCIINine[c - 0xFB00] ; }
            else if (c >= 0xFE10 && c < 0xFF60) { tmp = __MSUnicodeToASCIITen[c - 0xFE10] ; }
            
            if (tmp && (len = (NSUInteger)*tmp++) > 0) {
                if (len == 1) {
                    CBufferAppendByte(buf, (MSByte)*tmp);
                }
                else CBufferAppendBytes(buf, (void *)tmp, len);
            }
        }
    }

    
}


static inline MSASCIIString *_MSCreatedUnicodeToASCIIString(SES ses)
{
    NSUInteger length = SESLength(ses) ;
    MSASCIIString *buf = MSCreateASCIIString(length) ; // warning, this length may not be sufficient (that's a start)

    if (!buf) {
        MSRaise(NSMallocException, @"_MSCreatedUnicodeToASCIIString() : impossible to allocate a buffer of %lu bytes", (unsigned long)length) ;
        return nil ;
    }
    _MSFillCBufferFromString((CBuffer *)buf, ses) ;
    if (CBufferLength((CBuffer *)buf)) { return buf ; }
    RELEASE((id)buf) ;
    return nil ;
    
}

NSString *_MSUnicodeToASCIIString(NSString *self)
{
    if (self) {
        SES ses = [self stringEnumeratorStructure] ;
        if (SESOK(ses)) {
            MSASCIIString *ret = _MSCreatedUnicodeToASCIIString(ses) ;
            if (ret) { return AUTORELEASE(ret) ; }
        }
        return @"" ;
    }
    return nil ;
}

const char *_MSUnicodeToASCIICString(NSString *self)
{
    if (self) {
        char *ret = "" ;
        SES ses = [self stringEnumeratorStructure] ;
        if (SESOK(ses)) {
            MSASCIIString *buf = _MSCreatedUnicodeToASCIIString(ses) ; 
            if (buf) {
                CBufferAppendByte((CBuffer *)buf, '\0');
                ret = (char *)(buf->_buf) ;
                AUTORELEASE(buf) ; // the constitutional buffer holding our string will be released later
            }
        }
        
        return (const char *)ret ;
    }
    return NULL ;
}


unichar __MSAnsiToUnicode[256] = {
    0x00, 0x01, 0x02 , 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    0x10, 0x11, 0x12 , 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
    0x20, 0x21, 0x22 , 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x30, 0x31, 0x32 , 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
    0x40, 0x41, 0x42 , 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f,
    0x50, 0x51, 0x52 , 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f,
    0x60, 0x61, 0x62 , 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,
    0x70, 0x71, 0x72 , 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f,
    0x20ac, 0x81, 0x201a , 0x192, 0x201e, 0x2026, 0x2020, 0x2021, 0x2c6, 0x2030, 0x160, 0x2039, 0x152, 0x8d, 0x17d, 0x8f,
    0x90, 0x2018, 0x2019 , 0x201c, 0x201d, 0x2022, 0x2013, 0x2014, 0x2dc, 0x2122, 0x161, 0x203a, 0x153, 0x9d, 0x17e, 0x178,
    0xa0, 0xa1, 0xa2 , 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
    0xb0, 0xb1, 0xb2 , 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
    0xc0, 0xc1, 0xc2 , 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf,
    0xd0, 0xd1, 0xd2 , 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
    0xe0, 0xe1, 0xe2 , 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
    0xf0, 0xf1, 0xf2 , 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff
} ;

unichar __MSMacRomanToUnicode[256] = {
    0x00, 0x01, 0x02 , 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    0x10, 0x11, 0x12 , 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
    0x20, 0x21, 0x22 , 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x30, 0x31, 0x32 , 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
    0x40, 0x41, 0x42 , 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f,
    0x50, 0x51, 0x52 , 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f,
    0x60, 0x61, 0x62 , 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,
    0x70, 0x71, 0x72 , 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f,
    0xc4, 0xc5, 0xc7 , 0xc9, 0xd1, 0xd6, 0xdc, 0xe1, 0xe0, 0xe2, 0xe4, 0xe3, 0xe5, 0xe7, 0xe9, 0xe8,
    0xea, 0xeb, 0xed , 0xec, 0xee, 0xef, 0xf1, 0xf3, 0xf2, 0xf4, 0xf6, 0xf5, 0xfa, 0xf9, 0xfb, 0xfc,
    0x2020, 0xb0, 0xa2 , 0xa3, 0xa7, 0x2022, 0xb6, 0xdf, 0xae, 0xa9, 0x2122, 0xb4, 0xa8, 0x2260, 0xc6, 0xd8,
    0x221e, 0xb1, 0x2264 , 0x2265, 0xa5, 0xb5, 0x2202, 0x2211, 0x220f, 0x3c0, 0x222b, 0xaa, 0xba, 0x3a9, 0xe6, 0xf8,
    0xbf, 0xa1, 0xac , 0x221a, 0x192, 0x2248, 0x2206, 0xab, 0xbb, 0x2026, 0xa0, 0xc0, 0xc3, 0xd5, 0x152, 0x153,
    0x2013, 0x2014, 0x201c , 0x201d, 0x2018, 0x2019, 0xf7, 0x25ca, 0xff, 0x178, 0x2044, 0x20ac, 0x2039, 0x203a, 0xfb01, 0xfb02,
    0x2021, 0xb7, 0x201a , 0x201e, 0x2030, 0xc2, 0xca, 0xc1, 0xcb, 0xc8, 0xcd, 0xce, 0xcf, 0xcc, 0xd3, 0xd4,
    0xf8ff, 0xd2, 0xda , 0xdb, 0xd9, 0x131, 0x2c6, 0x2dc, 0xaf, 0x2d8, 0x2d9, 0x2da, 0xb8, 0x2dd, 0x2db, 0x2c7
} ;

unichar __MSNextstepToUnicode[256] = {
    0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xa,0xb,0xc,0xd,0xe,0xf,
    0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,
    0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f,
    0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,0x3e,0x3f,
    0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,
    0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0x5b,0x5c,0x5d,0x5e,0x5f,
    0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f,
    0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,0x7b,0x7c,0x7d,0x7e,0x7f,
    0xa0,0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc7,0xc8,0xc9,0xca,0xcb,0xcc,0xcd,0xce,0xcf,
    0xd0,0xd1,0xd2,0xd3,0xd4,0xd5,0xd6,0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xb5,0xd7,0xf7,
    0xa9,0xa1,0xa2,0xa3,0x2044,0xa5,0x192,0xa7,0xa4,0x2019,0x201c,0xab,0x2039,0x203a,0xfb01,0xfb02,
    0xae,0x2013,0x2020,0x2021,0xb7,0xa6,0xb6,0x2022,0x201a,0x201e,0x201d,0xbb,0x2026,0x2030,0xac,0xbf,
    0xb9,0x2cb,0xb4,0x2c6,0x2dc,0xaf,0x2d8,0x2d9,0xa8,0xb2,0x2da,0xb8,0xb3,0x2dd,0x2db,0x2c7,
    0x2014,0xb1,0xbc,0xbd,0xbe,0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe7,0xe8,0xe9,0xea,0xeb,
    0xec,0xc6,0xed,0xaa,0xee,0xef,0xf0,0xf1,0x141,0xd8,0x152,0xba,0xf2,0xf3,0xf4,0xf5,
    0xf6,0xe6,0xf9,0xfa,0xfb,0x131,0xfc,0xfd,0x142,0xf8,0x153,0xdf,0xfe,0xff,0xfffd,0xfffd
} ;

unichar __MSDOSToUnicode[256] = {
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
	16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
	32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
	48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
	64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
	80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 
	96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 
	112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 
	199, 252, 233, 226, 228, 224, 229, 231, 234, 235, 232, 239, 238, 236, 196, 197, 
	201, 230, 198, 244, 246, 242, 251, 249, 255, 214, 220, 162, 163, 165, 8359, 402, 
	225, 237, 243, 250, 241, 209, 170, 186, 191, 8976, 172, 189, 188, 161, 171, 187, 
	9617, 9618, 9619, 9474, 9508, 9569, 9570, 9558, 9557, 9571, 9553, 9559, 9565, 9564, 9563, 9488, 
	9492, 9524, 9516, 9500, 9472, 9532, 9566, 9567, 9562, 9556, 9577, 9574, 9568, 9552, 9580, 9575, 
	9576, 9572, 9573, 9561, 9560, 9554, 9555, 9579, 9578, 9496, 9484, 9608, 9604, 9612, 9616, 9600, 
	945, 223, 915, 960, 931, 963, 181, 964, 934, 920, 937, 948, 8734, 966, 949, 8745, 
	8801, 177, 8805, 8804, 8992, 8993, 247, 8776, 176, 8729, 183, 8730, 8319, 178, 9632, 160
} ;


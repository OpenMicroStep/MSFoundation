/*

 _OCIWin32Private.m

 This file is is a part of the MicroStep Framework.

 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011

 Jean-Michel BERTHEAS : jean-michel.bertheas@club-internet.fr

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

#import "_OCIWin32Private.h"

#ifdef WIN32
#import <windows.h>
#import <MSFoundation/MSFoundation.h>

static HINSTANCE __oci32_DLL = (HINSTANCE)NULL;

//***************************************************************
typedef	sword (__stdcall *DLL_OCI32_OCISessionEnd) (OCISvcCtx *svchp, OCIError *errhp, OCISession *usrhp, ub4 mode);
typedef sword (__stdcall *DLL_OCI32_OCIErrorGet) (void *hndlp, ub4 recordno, OraText *sqlstate, sb4 *errcodep, OraText *bufp, ub4 bufsiz, ub4 type);
typedef sword (__stdcall *DLL_OCI32_OCIServerDetach) (OCIServer *srvhp, OCIError *errhp, ub4 mode);
typedef sword (__stdcall *DLL_OCI32_OCIHandleFree) (void  *hndlp, const ub4 type);
typedef sword (__stdcall *DLL_OCI32_OCIEnvCreate) (OCIEnv **envp, ub4 mode, void  *ctxp, void *(*malocfp)(void  *ctxp, size_t size), void *(*ralocfp)(void *ctxp, void *memptr, size_t newsize), void (*mfreefp)(void  *ctxp, void  *memptr), size_t xtramem_sz, void  **usrmempp);
typedef sword (__stdcall *DLL_OCI32_OCIHandleAlloc) (const void *parenth, void **hndlpp, const ub4 type, const size_t xtramem_sz, void  **usrmempp);
typedef sword (__stdcall *DLL_OCI32_OCIServerAttach) (OCIServer *srvhp, OCIError *errhp, const OraText *dblink, sb4 dblink_len, ub4 mode);
typedef sword (__stdcall *DLL_OCI32_OCIAttrSet) (void  *trgthndlp, ub4 trghndltyp, void *attributep, ub4 size, ub4 attrtype, OCIError *errhp);
typedef sword (__stdcall *DLL_OCI32_OCISessionBegin) (OCISvcCtx *svchp, OCIError *errhp, OCISession *usrhp, ub4 credt, ub4 mode);
typedef sword (__stdcall *DLL_OCI32_OCIStmtPrepare) (OCIStmt *stmtp, OCIError *errhp, const OraText *stmt, ub4 stmt_len, ub4 language, ub4 mode);
typedef sword (__stdcall *DLL_OCI32_OCIStmtExecute) (OCISvcCtx *svchp, OCIStmt *stmtp, OCIError *errhp, ub4 iters, ub4 rowoff, const OCISnapshot *snap_in, OCISnapshot *snap_out, ub4 mode);
typedef sword (__stdcall *DLL_OCI32_OCIDescriptorAlloc) (const void *parenth, void **descpp, const ub4 type, const size_t xtramem_sz, void **usrmempp);
typedef sword (__stdcall *DLL_OCI32_OCIDefineByPos) (OCIStmt *stmtp, OCIDefine **defnp, OCIError *errhp, ub4 position, void  *valuep, sb4 value_sz, ub2 dty, void  *indp, ub2 *rlenp, ub2 *rcodep, ub4 mode);
typedef sword (__stdcall *DLL_OCI32_OCILobGetLength2) (OCISvcCtx *svchp, OCIError *errhp, OCILobLocator *locp, oraub8 *lenp);
typedef sword (__stdcall *DLL_OCI32_OCILobRead2) (OCISvcCtx *svchp, OCIError *errhp, OCILobLocator *locp, oraub8 *byte_amtp, oraub8 *char_amtp, oraub8 offset, void  *bufp, oraub8 bufl, ub1 piece, void  *ctxp, OCICallbackLobRead2 cbfp, ub2 csid, ub1 csfrm);
typedef sword (__stdcall *DLL_OCI32_OCIDescriptorFree) (void  *descp, const ub4 type);
typedef sword (__stdcall *DLL_OCI32_OCIStmtGetPieceInfo) (OCIStmt *stmtp, OCIError *errhp, void  **hndlpp, ub4 *typep, ub1 *in_outp, ub4 *iterp, ub4 *idxp, ub1 *piecep);
typedef sword (__stdcall *DLL_OCI32_OCIStmtSetPieceInfo) (void  *hndlp, ub4 type, OCIError *errhp, const void  *bufp, ub4 *alenp, ub1 piece, const void  *indp, ub2 *rcodep);
typedef sword (__stdcall *DLL_OCI32_OCIStmtFetch2) (OCIStmt *stmtp, OCIError *errhp, ub4 nrows, ub2 orientation, sb4 scrollOffset, ub4 mode);
typedef sword (__stdcall *DLL_OCI32_OCINumberToReal) (OCIError *err, const OCINumber *number, uword rsl_length, void  *rsl);
typedef sword (__stdcall *DLL_OCI32_OCINumberToInt) (OCIError *err, const OCINumber *number, uword rsl_length, uword rsl_flag, void  *rsl);
typedef sword (__stdcall *DLL_OCI32_OCIAttrGet) (const void  *trgthndlp, ub4 trghndltyp, void  *attributep, ub4 *sizep, ub4 attrtype, OCIError *errhp);
typedef sword (__stdcall *DLL_OCI32_OCIParamGet) (const void  *hndlp, ub4 htype, OCIError *errhp, void  **parmdpp, ub4 pos);
typedef sword (__stdcall *DLL_OCI32_OCITransRollback) (OCISvcCtx *svchp, OCIError *errhp, ub4 flags);
typedef sword (__stdcall *DLL_OCI32_OCITransCommit) (OCISvcCtx *svchp, OCIError *errhp, ub4 flags);

//***************************************************************
static DLL_OCI32_OCISessionEnd		__oci32_OCISessionEnd;
static DLL_OCI32_OCIErrorGet		__oci32_OCIErrorGet;
static DLL_OCI32_OCIServerDetach		__oci32_OCIServerDetach;
static DLL_OCI32_OCIHandleFree		__oci32_OCIHandleFree;
static DLL_OCI32_OCIEnvCreate		__oci32_OCIEnvCreate;
static DLL_OCI32_OCIHandleAlloc		__oci32_OCIHandleAlloc;
static DLL_OCI32_OCIServerAttach		__oci32_OCIServerAttach;
static DLL_OCI32_OCIAttrSet		__oci32_OCIAttrSet;
static DLL_OCI32_OCISessionBegin		__oci32_OCISessionBegin;
static DLL_OCI32_OCIStmtPrepare		__oci32_OCIStmtPrepare;
static DLL_OCI32_OCIStmtExecute		__oci32_OCIStmtExecute;
static DLL_OCI32_OCIDescriptorAlloc	__oci32_OCIDescriptorAlloc;
static DLL_OCI32_OCIDefineByPos		__oci32_OCIDefineByPos;
static DLL_OCI32_OCILobGetLength2	__oci32_OCILobGetLength2;
static DLL_OCI32_OCILobRead2		__oci32_OCILobRead2;
static DLL_OCI32_OCIDescriptorFree	__oci32_OCIDescriptorFree;
static DLL_OCI32_OCIStmtGetPieceInfo	__oci32_OCIStmtGetPieceInfo;
static DLL_OCI32_OCIStmtSetPieceInfo	__oci32_OCIStmtSetPieceInfo;
static DLL_OCI32_OCIStmtFetch2		__oci32_OCIStmtFetch2;
static DLL_OCI32_OCINumberToReal		__oci32_OCINumberToReal;
static DLL_OCI32_OCINumberToInt		__oci32_OCINumberToInt;
static DLL_OCI32_OCIAttrGet		__oci32_OCIAttrGet;
static DLL_OCI32_OCIParamGet		__oci32_OCIParamGet;
static DLL_OCI32_OCITransRollback	__oci32_OCITransRollback;
static DLL_OCI32_OCITransCommit		__oci32_OCITransCommit;

//***************************************************************
sword OCISessionEnd(OCISvcCtx *svchp, OCIError *errhp, OCISession *usrhp, ub4 mode) {
    return __oci32_OCISessionEnd(svchp, errhp, usrhp, mode) ;
}

sword OCIErrorGet(void *hndlp, ub4 recordno, OraText *sqlstate, sb4 *errcodep, OraText *bufp, ub4 bufsiz, ub4 type) {
    return __oci32_OCIErrorGet(hndlp, recordno, sqlstate, errcodep, bufp, bufsiz, type) ;
}

sword OCIServerDetach(OCIServer *srvhp, OCIError *errhp, ub4 mode) {
    return __oci32_OCIServerDetach(srvhp, errhp, mode) ;
}

sword OCIHandleFree(void  *hndlp, const ub4 type) {
    return  __oci32_OCIHandleFree(hndlp, type) ;
}

sword OCIEnvCreate(OCIEnv **envp, ub4 mode, void  *ctxp, void *(*malocfp)(void  *ctxp, size_t size), void *(*ralocfp)(void *ctxp, void *memptr, size_t newsize), void (*mfreefp)(void  *ctxp, void  *memptr), size_t xtramem_sz, void  **usrmempp) {
    return __oci32_OCIEnvCreate(envp, mode, ctxp, malocfp, ralocfp, mfreefp, xtramem_sz, usrmempp) ;
}

sword OCIHandleAlloc(const void *parenth, void **hndlpp, const ub4 type, const size_t xtramem_sz, void  **usrmempp) {
    return __oci32_OCIHandleAlloc(parenth, hndlpp, type, xtramem_sz, usrmempp) ;
}

sword OCIServerAttach(OCIServer *srvhp, OCIError *errhp, const OraText *dblink, sb4 dblink_len, ub4 mode) {
    return __oci32_OCIServerAttach(srvhp, errhp, dblink, dblink_len, mode) ;
}

sword OCIAttrSet(void  *trgthndlp, ub4 trghndltyp, void *attributep, ub4 size, ub4 attrtype, OCIError *errhp) {
    return __oci32_OCIAttrSet(trgthndlp, trghndltyp, attributep, size, attrtype, errhp) ;
}

sword OCISessionBegin(OCISvcCtx *svchp, OCIError *errhp, OCISession *usrhp, ub4 credt, ub4 mode) {
    return __oci32_OCISessionBegin(svchp, errhp, usrhp, credt, mode) ;
}

sword OCIStmtPrepare(OCIStmt *stmtp, OCIError *errhp, const OraText *stmt, ub4 stmt_len, ub4 language, ub4 mode) {
    return __oci32_OCIStmtPrepare(stmtp, errhp, stmt, stmt_len, language, mode) ;
}

sword OCIStmtExecute(OCISvcCtx *svchp, OCIStmt *stmtp, OCIError *errhp, ub4 iters, ub4 rowoff, const OCISnapshot *snap_in, OCISnapshot *snap_out, ub4 mode) {
    return __oci32_OCIStmtExecute(svchp, stmtp, errhp, iters, rowoff, snap_in, snap_out, mode) ;
}

sword OCIDescriptorAlloc(const void *parenth, void **descpp, const ub4 type, const size_t xtramem_sz, void **usrmempp) {
    return __oci32_OCIDescriptorAlloc(parenth, descpp, type, xtramem_sz, usrmempp) ;
}

sword OCIDefineByPos(OCIStmt *stmtp, OCIDefine **defnp, OCIError *errhp, ub4 position, void  *valuep, sb4 value_sz, ub2 dty, void  *indp, ub2 *rlenp, ub2 *rcodep, ub4 mode) {
    return __oci32_OCIDefineByPos(stmtp, defnp, errhp, position, valuep, value_sz, dty, indp, rlenp, rcodep, mode) ;
}

sword OCILobGetLength2(OCISvcCtx *svchp, OCIError *errhp, OCILobLocator *locp, oraub8 *lenp) {
    return __oci32_OCILobGetLength2(svchp, errhp, locp, lenp) ;
}

sword OCILobRead2(OCISvcCtx *svchp, OCIError *errhp, OCILobLocator *locp, oraub8 *byte_amtp, oraub8 *char_amtp, oraub8 offset, void  *bufp, oraub8 bufl, ub1 piece, void  *ctxp, OCICallbackLobRead2 cbfp, ub2 csid, ub1 csfrm) {
    return __oci32_OCILobRead2(svchp, errhp, locp, byte_amtp, char_amtp, offset, bufp, bufl, piece, ctxp, cbfp, csid, csfrm) ;
}

sword OCIDescriptorFree(void  *descp, const ub4 type) {
    return __oci32_OCIDescriptorFree(descp, type) ;
}

sword OCIStmtGetPieceInfo(OCIStmt *stmtp, OCIError *errhp, void  **hndlpp, ub4 *typep, ub1 *in_outp, ub4 *iterp, ub4 *idxp, ub1 *piecep) {
    return __oci32_OCIStmtGetPieceInfo(stmtp, errhp, hndlpp, typep, in_outp, iterp, idxp, piecep) ;
}

sword OCIStmtSetPieceInfo(void  *hndlp, ub4 type, OCIError *errhp, const void  *bufp, ub4 *alenp, ub1 piece, const void  *indp, ub2 *rcodep) {
    return __oci32_OCIStmtSetPieceInfo(hndlp, type, errhp, bufp, alenp, piece, indp, rcodep) ;
}

sword OCIStmtFetch2(OCIStmt *stmtp, OCIError *errhp, ub4 nrows, ub2 orientation, sb4 scrollOffset, ub4 mode) {
    return __oci32_OCIStmtFetch2(stmtp, errhp, nrows, orientation, scrollOffset, mode) ;
}

sword OCINumberToReal(OCIError *err, const OCINumber *number, uword rsl_length, void  *rsl) {
    return __oci32_OCINumberToReal(err, number, rsl_length, rsl) ;
}

sword OCINumberToInt(OCIError *err, const OCINumber *number, uword rsl_length, uword rsl_flag, void  *rsl) {
    return __oci32_OCINumberToInt(err, number, rsl_length, rsl_flag, rsl) ;
}

sword OCIAttrGet(const void  *trgthndlp, ub4 trghndltyp, void  *attributep, ub4 *sizep, ub4 attrtype, OCIError *errhp) {
    return __oci32_OCIAttrGet(trgthndlp, trghndltyp, attributep, sizep, attrtype, errhp) ;
}

sword OCIParamGet(const void  *hndlp, ub4 htype, OCIError *errhp, void  **parmdpp, ub4 pos) {
    return __oci32_OCIParamGet(hndlp, htype, errhp, parmdpp, pos) ;
}

sword OCITransRollback(OCISvcCtx *svchp, OCIError *errhp, ub4 flags) {
    return __oci32_OCITransRollback(svchp, errhp, flags) ;
}

sword OCITransCommit(OCISvcCtx *svchp, OCIError *errhp, ub4 flags) {
    return __oci32_OCITransCommit(svchp, errhp, flags) ;
}

//***************************************************************
void initializeOCILibraryForWin32()
{
    if(!__oci32_DLL)
    {
        __oci32_DLL = MSLoadDLL(@"oci.dll") ;

        if (__oci32_DLL != NULL) {
            __oci32_OCISessionEnd		= (DLL_OCI32_OCISessionEnd)		GetProcAddress(__oci32_DLL, "OCISessionEnd") ;
            __oci32_OCIErrorGet			= (DLL_OCI32_OCIErrorGet)		GetProcAddress(__oci32_DLL, "OCIErrorGet") ;
            __oci32_OCIServerDetach		= (DLL_OCI32_OCIServerDetach)		GetProcAddress(__oci32_DLL, "OCIServerDetach") ;
            __oci32_OCIHandleFree		= (DLL_OCI32_OCIHandleFree)		GetProcAddress(__oci32_DLL, "OCIHandleFree") ;
            __oci32_OCIEnvCreate			= (DLL_OCI32_OCIEnvCreate)		GetProcAddress(__oci32_DLL, "OCIEnvCreate") ;
            __oci32_OCIHandleAlloc     		= (DLL_OCI32_OCIHandleAlloc)		GetProcAddress(__oci32_DLL, "OCIHandleAlloc") ;
            __oci32_OCIServerAttach     		= (DLL_OCI32_OCIServerAttach)		GetProcAddress(__oci32_DLL, "OCIServerAttach") ;
            __oci32_OCIAttrSet     		= (DLL_OCI32_OCIAttrSet)		GetProcAddress(__oci32_DLL, "OCIAttrSet") ;
            __oci32_OCISessionBegin     		= (DLL_OCI32_OCISessionBegin)		GetProcAddress(__oci32_DLL, "OCISessionBegin") ;
            __oci32_OCIStmtPrepare     		= (DLL_OCI32_OCIStmtPrepare)		GetProcAddress(__oci32_DLL, "OCIStmtPrepare") ;
            __oci32_OCIStmtExecute     		= (DLL_OCI32_OCIStmtExecute)		GetProcAddress(__oci32_DLL, "OCIStmtExecute") ;
            __oci32_OCIDescriptorAlloc 		= (DLL_OCI32_OCIDescriptorAlloc)	GetProcAddress(__oci32_DLL, "OCIDescriptorAlloc") ;
            __oci32_OCIDefineByPos 		= (DLL_OCI32_OCIDefineByPos)		GetProcAddress(__oci32_DLL, "OCIDefineByPos") ;
            __oci32_OCILobGetLength2 		= (DLL_OCI32_OCILobGetLength2)		GetProcAddress(__oci32_DLL, "OCILobGetLength2") ;
            __oci32_OCILobRead2 			= (DLL_OCI32_OCILobRead2)		GetProcAddress(__oci32_DLL, "OCILobRead2") ;
            __oci32_OCIDescriptorFree 		= (DLL_OCI32_OCIDescriptorFree)		GetProcAddress(__oci32_DLL, "OCIDescriptorFree") ;
            __oci32_OCIStmtGetPieceInfo 		= (DLL_OCI32_OCIStmtGetPieceInfo)	GetProcAddress(__oci32_DLL, "OCIStmtGetPieceInfo") ;
            __oci32_OCIStmtSetPieceInfo 		= (DLL_OCI32_OCIStmtSetPieceInfo)	GetProcAddress(__oci32_DLL, "OCIStmtSetPieceInfo") ;
            __oci32_OCIStmtFetch2	     	= (DLL_OCI32_OCIStmtFetch2)		GetProcAddress(__oci32_DLL, "OCIStmtFetch2") ;
            __oci32_OCINumberToReal	     	= (DLL_OCI32_OCINumberToReal)		GetProcAddress(__oci32_DLL, "OCINumberToReal") ;
            __oci32_OCINumberToInt	     	= (DLL_OCI32_OCINumberToInt)		GetProcAddress(__oci32_DLL, "OCINumberToInt") ;
            __oci32_OCIAttrGet		     	= (DLL_OCI32_OCIAttrGet)		GetProcAddress(__oci32_DLL, "OCIAttrGet") ;
            __oci32_OCIParamGet		     	= (DLL_OCI32_OCIParamGet)		GetProcAddress(__oci32_DLL, "OCIParamGet") ;
            __oci32_OCITransRollback   	     	= (DLL_OCI32_OCITransRollback)		GetProcAddress(__oci32_DLL, "OCITransRollback") ;
            __oci32_OCITransCommit   	     	= (DLL_OCI32_OCITransCommit)		GetProcAddress(__oci32_DLL, "OCITransCommit") ;

            if (!(__oci32_OCISessionEnd
                  &&__oci32_OCIErrorGet
                  &&__oci32_OCIServerDetach
                  &&__oci32_OCIHandleFree
                  &&__oci32_OCIEnvCreate
                  &&__oci32_OCIHandleAlloc
                  &&__oci32_OCIServerAttach
                  &&__oci32_OCIAttrSet
                  &&__oci32_OCISessionBegin
                  &&__oci32_OCIStmtPrepare
                  &&__oci32_OCIStmtExecute
                  &&__oci32_OCIDescriptorAlloc
                  &&__oci32_OCIDefineByPos
                  &&__oci32_OCILobGetLength2
                  &&__oci32_OCILobRead2
                  &&__oci32_OCIDescriptorFree
                  &&__oci32_OCIStmtGetPieceInfo
                  &&__oci32_OCIStmtSetPieceInfo
                  &&__oci32_OCIStmtFetch2
                  &&__oci32_OCINumberToReal
                  &&__oci32_OCINumberToInt
                  &&__oci32_OCIAttrGet
                  &&__oci32_OCIParamGet
                  &&__oci32_OCITransRollback
                  &&__oci32_OCITransCommit
                  ))
            {
                if(!__oci32_OCISessionEnd)             	NSLog(@"__oci32_OCISessionEnd NULL");
                if(!__oci32_OCIErrorGet)			NSLog(@"__oci32_OCIErrorGet NULL");
                if(!__oci32_OCIServerDetach)		NSLog(@"__oci32_OCIServerDetach NULL");
                if(!__oci32_OCIHandleFree)		NSLog(@"__oci32_OCIHandleFree NULL");
                if(!__oci32_OCIEnvCreate)		NSLog(@"__oci32_OCIEnvCreate NULL");
                if(!__oci32_OCIHandleAlloc)		NSLog(@"__oci32_OCIHandleAlloc NULL");
                if(!__oci32_OCIServerAttach)		NSLog(@"__oci32_OCIServerAttach NULL");
                if(!__oci32_OCIAttrSet)			NSLog(@"__oci32_OCIAttrSet NULL");
                if(!__oci32_OCIAttrSet)			NSLog(@"__oci32_OCIAttrSet NULL");
                if(!__oci32_OCISessionBegin)		NSLog(@"__oci32_OCISessionBegin NULL");
                if(!__oci32_OCIStmtPrepare)		NSLog(@"__oci32_OCIStmtPrepare NULL");
                if(!__oci32_OCIStmtExecute)		NSLog(@"__oci32_OCIStmtExecute NULL");
                if(!__oci32_OCIDescriptorAlloc)		NSLog(@"__oci32_OCIDescriptorAlloc NULL");
                if(!__oci32_OCIDefineByPos)		NSLog(@"__oci32_OCIDefineByPos NULL");
                if(!__oci32_OCILobGetLength2)		NSLog(@"__oci32_OCILobGetLength2 NULL");
                if(!__oci32_OCILobRead2)			NSLog(@"__oci32_OCILobRead2 NULL");
                if(!__oci32_OCIDescriptorFree)		NSLog(@"__oci32_OCIDescriptorFree NULL");
                if(!__oci32_OCIStmtGetPieceInfo)		NSLog(@"__oci32_OCIStmtGetPieceInfo NULL");
                if(!__oci32_OCIStmtSetPieceInfo)		NSLog(@"__oci32_OCIStmtSetPieceInfo NULL");
                if(!__oci32_OCIStmtFetch2)		NSLog(@"__oci32_OCIStmtFetch2 NULL");
                if(!__oci32_OCINumberToReal)		NSLog(@"__oci32_OCINumberToReal NULL");
                if(!__oci32_OCINumberToInt)		NSLog(@"__oci32_OCINumberToInt NULL");
                if(!__oci32_OCIAttrGet)			NSLog(@"__oci32_OCIAttrGet NULL");
                if(!__oci32_OCIParamGet)			NSLog(@"__oci32_OCIParamGet NULL");
                if(!__oci32_OCITransRollback)		NSLog(@"__oci32_OCITransRollback NULL");
                if(!__oci32_OCITransCommit)		NSLog(@"__oci32_OCITransCommit NULL");

                MSRaise(NSGenericException, @"Error while loading oci.dll") ;
            }
        }
        else {
            MSRaise(NSGenericException, @"Error while loading oci.dll") ;
        }
    }
}

#endif

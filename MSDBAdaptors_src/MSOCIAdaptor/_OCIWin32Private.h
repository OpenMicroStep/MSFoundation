/*

 _OCIWin32Private.h

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

#ifdef WIN32
#import <oci.h>

void initializeOCILibraryForWin32() ;

/*
sword OCISessionEnd(OCISvcCtx *svchp, OCIError *errhp, OCISession *usrhp, ub4 mode);
sword OCIErrorGet(void *hndlp, ub4 recordno, OraText *sqlstate, sb4 *errcodep, OraText *bufp, ub4 bufsiz, ub4 type);
sword OCIServerDetach(OCIServer *srvhp, OCIError *errhp, ub4 mode);
sword OCIHandleFree(void  *hndlp, const ub4 type);
sword OCIEnvCreate (OCIEnv **envp, ub4 mode, void  *ctxp, void *(*malocfp)(void  *ctxp, size_t size), void *(*ralocfp)(void *ctxp, void *memptr, size_t newsize), void (*mfreefp)(void  *ctxp, void  *memptr), size_t xtramem_sz, void  **usrmempp);
sword OCIHandleAlloc(const void *parenth, void **hndlpp, const ub4 type, const size_t xtramem_sz, void  **usrmempp);
sword OCIServerAttach(OCIServer *srvhp, OCIError *errhp, const OraText *dblink, sb4 dblink_len, ub4 mode);
sword OCIAttrSet(void  *trgthndlp, ub4 trghndltyp, void *attributep, ub4 size, ub4 attrtype, OCIError *errhp);
sword OCISessionBegin(OCISvcCtx *svchp, OCIError *errhp, OCISession *usrhp, ub4 credt, ub4 mode);
sword OCIStmtPrepare(OCIStmt *stmtp, OCIError *errhp, const OraText *stmt, ub4 stmt_len, ub4 language, ub4 mode);
sword OCIStmtExecute(OCISvcCtx *svchp, OCIStmt *stmtp, OCIError *errhp, ub4 iters, ub4 rowoff, const OCISnapshot *snap_in, OCISnapshot *snap_out, ub4 mode);
sword OCIDescriptorAlloc(const void *parenth, void **descpp, const ub4 type, const size_t xtramem_sz, void **usrmempp);
sword OCIDefineByPos(OCIStmt *stmtp, OCIDefine **defnp, OCIError *errhp, ub4 position, void  *valuep, sb4 value_sz, ub2 dty, void  *indp, ub2 *rlenp, ub2 *rcodep, ub4 mode);
sword OCILobGetLength2(OCISvcCtx *svchp, OCIError *errhp, OCILobLocator *locp, oraub8 *lenp);
sword OCILobRead2(OCISvcCtx *svchp, OCIError *errhp, OCILobLocator *locp, oraub8 *byte_amtp, oraub8 *char_amtp, oraub8 offset, void  *bufp, oraub8 bufl, ub1 piece, void  *ctxp, OCICallbackLobRead2 cbfp, ub2 csid, ub1 csfrm);
sword OCIDescriptorFree(void  *descp, const ub4 type);
sword OCIStmtGetPieceInfo(OCIStmt *stmtp, OCIError *errhp, void  **hndlpp, ub4 *typep, ub1 *in_outp, ub4 *iterp, ub4 *idxp, ub1 *piecep);
sword OCIStmtSetPieceInfo(void  *hndlp, ub4 type, OCIError *errhp, const void  *bufp, ub4 *alenp, ub1 piece, const void  *indp, ub2 *rcodep);
sword OCIStmtFetch2(OCIStmt *stmtp, OCIError *errhp, ub4 nrows, ub2 orientation, sb4 scrollOffset, ub4 mode);
sword OCINumberToReal(OCIError *err, const OCINumber *number, uword rsl_length, void  *rsl);
sword OCINumberToInt(OCIError *err, const OCINumber *number, uword rsl_length, uword rsl_flag, void  *rsl);
sword OCIAttrGet(const void  *trgthndlp, ub4 trghndltyp, void  *attributep, ub4 *sizep, ub4 attrtype, OCIError *errhp);
sword OCIParamGet (const void  *hndlp, ub4 htype, OCIError *errhp, void  **parmdpp, ub4 pos);
sword OCITransRollback(OCISvcCtx *svchp, OCIError *errhp, ub4 flags);
sword OCITransCommit(OCISvcCtx *svchp, OCIError *errhp, ub4 flags);
*/

#endif //WIN32

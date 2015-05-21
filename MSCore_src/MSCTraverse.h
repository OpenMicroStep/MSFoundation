// MSCTraverse.h, 150505

#pragma mark ***** Traverse

MSCoreExtern CString* KJob;
MSCoreExtern CString* KCopy;
MSCoreExtern CString* KDescription;

MSCoreExtern CString* KDeep;
MSCoreExtern CString* KMutable;

MSCoreExtern CString* KRoot;
MSCoreExtern CString* KAll;
MSCoreExtern CString* KDone;
MSCoreExtern CString* KIndice;

// Add root in the context under the key 'KRoot'.
// Return in the context under the key 'KAll', a dictionary (Pointer, NaturalNotZero) of all
// (unretained) objects as keys associed with the number of occurrence of each object.
// subs returns a created array (witch will be released) of all direct sub-objects needed for the job.
MSCoreExtern void CTraversePrepare(id root, CArray* (*createSubs)(id, mutable CDictionary *), mutable CDictionary *context);

// Si l'action pour o a déjà été faite, retourne le précédent résultat.
// Sinon demande à l'action de faire ce qu'elle doit faire en fonction
// de o, de la précédente valeur retournée, du result et du ctx
// et doit retourner la même valeur (identical) ouun object créé (qui sera released)
// si elle veut ce retour pour la prochaine demande sur o.
//MSCoreExtern void CTraversePerform(id o, id result, int level, id (*action)(id, id, id, int, mutable CDictionary *), mutable CDictionary *ctx);

MSCoreExtern void CDescribe(id o, id result, int level, mutable CDictionary *ctx);
MSCoreExtern CString *CCreateDescription(id o);

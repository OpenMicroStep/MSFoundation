// MSCMessage.h

/*
UTILISATION:

Le déclanchement d'un message se réalise par la fonction:
  CMessageAdvise(CString* messageType, mutable CDictionary* context, const char *messageFormat, ...);

Ex: CMessageAdvise(CMessageInformation, CTX, "Cool !, il fait %s aujourd'hui","beau");
Ex: CMessageAdvise(CMessageWarning    , CTX, "Attention, le temps est %@ aujourd'hui",@"orageux");

1/ Un type de message
La fonction permet de signaler (à l'utilisateur, dans une console ou autres) un type de message identifié par le 'messageType'.
Ce type est prédéfini et associé à un ensemble de comportements que l'on peut définir.

2/ Le contexte
Pour le contexte, on peut utiliser la macro par défaut CTX qui contient le nom du fichier source, la méthode et la ligne et auxquels sera ajoutée la date. On peut ajouter ce qu'on veut à ce contexte et par exemple un ensemble de tags.

Ex1 : #define MYCTX CCreateCtx(CTX_MTD, tag 1, tag2, nil);
Ex2 : CArray *tags= CCreateArrayWithObjects(tag 1, tag2, nil); // To create the array only once
      #define MYCTX CCreateCtx(CTX_MTD, tags);

3/ Le message
Enfin, le message à transmettre, sous forme printf mais avec %@.

Attention, le 'context' est released par la fonction.


CONCEPTS:

On appelle 'message' aussi bien une erreur, qu'un warning ou une simple information.

Un message est toujours associé à un ou plusieurs comportements.
Les comportements standards sont:
(1) CBehaviorFatal           : arrêt du thread courant
(2) CBehaviorReportToFile    : ecriture dans un fichier
(3) CBehaviorReportToConsole : écriture dans la console
(4) CBehaviorReportToUser    : alerte l'utilisateur via un message d'alerte

Pour le comportement 2 le fichier par défaut est ...
Il peut être obtenu et modifié via les fonctions:
    CBehaviorReportFilePath();
    CBehaviorSetReportFilePath();

Pour le comportement 4, il faut définir la fonction de callback via la fonction:
    CBehaviorSetReportToUserCallback(callback);
Si aucune fonction de callback n'est définie, le comportement 3 s'applique
(ie le callback par défaut de 4 est celui de la console).

On peut créer autant de comportement qu'on veut en définisant une fonction de type:
    void CBehaviorFunction(CDictionary* context, CString* message);

On définit maintenant différents types de messages en fonction de leurs comportements

CMessageDebug:       registered with behavior  (3)
CMessageAnalyse:     registered with behavior  (2)
CMessageFatalError:  registered with behaviors (2), (4), (1)
CMessageWarning:     registered with behaviors (2), (4)
CMessageInformation: registered with behavior       (4)

CMessageDebug n'est activé que si CMessageDebugOn==YES et ne coute rien en terme de performance
à condition d'utiliser a macro CMESSAGEDEBUG plutôt que la fonction CMessageAdvise

Si un message n'est associé à aucun comportement, les comportements 2 et 4 s'appliquent ?

On peut définir autant de type de message que l'on veut avec les fonctions:
    void CMessageAddBehaviorForType(   CBehaviorCallback behavior, CString* messageType);
    void CMessageRemoveBehaviorForType(CBehaviorCallback behavior, CString* messageType);

La fonction suivante permet d'obtenir tous les comportements définis pour un type de message.
Les comportements sont ordonnés selon les add successifs.
    CArray* CMessageBehaviorsForType(CString* messageType);
*/

#pragma mark CONTEXT

MSCoreExtern CString* KDate;
MSCoreExtern CString* KType;
MSCoreExtern CString* KFile;
MSCoreExtern CString* KLine;
MSCoreExtern CString* KFunction;
MSCoreExtern CString* KMethod;
MSCoreExtern CString* KTags;
MSCoreExtern CString* KMessage;

MSCoreExtern mutable CDictionary* CCreateCtx(const char *file, int line, const char *function, const char *method, ...);
MSCoreExtern mutable CDictionary* CCreateCtxv(const char *file, int line, const char *function, const char *method, va_list vp);
#define CTX_FCT __FILE__, __LINE__, __FUNCTION__, NULL
#define CTX_MTD __FILE__, __LINE__, __FUNCTION__, NULL // sel_getName(_cmd)
#define CTXF  CCreateCtx(CTX_FCT,nil)
#define CTX   CCreateCtx(CTX_MTD,nil)

#pragma mark CBehavior

typedef void (*CBehaviorCallback)(CDictionary*,CString*);

MSCoreExtern void CBehaviorFatal(          CDictionary* context, CString* message);
MSCoreExtern void CBehaviorReportToFile(   CDictionary* context, CString* message);
MSCoreExtern void CBehaviorReportToConsole(CDictionary* context, CString* message);
MSCoreExtern void CBehaviorReportToUser(   CDictionary* context, CString* message);

MSCoreExtern BOOL     CMessageDebugOn;
MSCoreExtern CString* CBehaviorReportFilePath(void);
MSCoreExtern void     CBehaviorSetReportFilePath(CString* path);
MSCoreExtern void     CBehaviorSetReportToUserCallback(CBehaviorCallback callback);

#pragma mark CMessage type

MSCoreExtern CString* CMessageDebug;
MSCoreExtern CString* CMessageAnalyse;
MSCoreExtern CString* CMessageFatalError;
MSCoreExtern CString* CMessageWarning;
MSCoreExtern CString* CMessageInformation;

MSCoreExtern void CMessageAddBehaviorForType(CBehaviorCallback behavior, CString* messageType);
MSCoreExtern void CMessageRemoveBehaviorForType(CBehaviorCallback behavior, CString* messageType);
MSCoreExtern CArray* CMessageBehaviorsForType(CString* messageType);

// Warning: The context is RELEASED at the end of the function.
MSCoreExtern void CMessageAdvise(CString* messageType, mutable CDictionary* context, const char *messageFormat, ...);
MSCoreExtern void CMessageAdvisev(CString* messageType, mutable CDictionary* ctx, const char *msgFmt, va_list vp);

#define CMESSAGEDEBUG(DCTX, MSG...) ({if(CMessageDebugOn) CMessageAdvise(CMessageDebug, DCTX, MSG);})

// Append à str file:line[:function][:method]
MSCoreExtern void CStringAppendContextWhere(CString* str, CDictionary* ctx);

#pragma mark ASSERT ??? TODO: for what ? analyse ?

MSCoreExtern CString* KAssert;
MSCoreExtern CString* CMessageAssert;

#define ASSERT(TEST, MSG...) ({ __typeof__(TEST) __t= (TEST); __ASSERT(__t, MTD, #TEST, MSG, __t); })
#define ASSERTF(TEST, MSG...) ({ __typeof__(TEST) __t= (TEST); __ASSERT(__t, FCT, #TEST, MSG, __t); })

#define __ACTX(fct,assert) ACreateCtx(CTX_ ## fct, (assert), nil)
#define __ASSERT(test, fct, assert, msg...) (!!(test) ? 1 : (CMessageAdvise(CMessageAssert, __ACTX(fct, assert), msg), 0))

MSCoreExtern mutable CDictionary* ACreateCtx(const char *file, int line, const char *function, const char *method, const char *assert, ...);

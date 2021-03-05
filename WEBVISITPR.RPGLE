      *****************************************************************
      *               Web IP Records Prototype Definitions
      *
      *  Copy file WEBVISITPR
      *****************************************************************

      *****************************************************************
      * Prototyped call: addVisitor
      *****************************************************************
     d addVisitor      pr                  extpgm('WEBVISITRA')
     d  prmErrorCode                       like(returnCode)
     d  prmExit                            like(flag)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(SITE)
     d  prmVisitor                         like(RECID)

      *****************************************************************
      * Prototyped call: dspVisitor
      *****************************************************************
     d dspVisitor      pr                  extpgm('WEBVISITRB')
     d  prmErrorCode                       like(returnCode)
     d  prmExit                            like(flag)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(SITE)
     d  prmVisitor                         like(RECID)

      *****************************************************************
      * Prototyped call: updVisitor
      *****************************************************************
     d updVisitor      pr                  extpgm('WEBVISITRC')
     d  prmErrorCode                       like(returnCode)
     d  prmExit                            like(flag)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(SITE)
     d  prmVisitor                         like(RECID)

      *****************************************************************
      * Prototyped call: delVisitor
      *****************************************************************
     d delVisitor      pr                  extpgm('WEBVISITRD')
     d  prmErrorCode                       like(returnCode)
     d  prmExit                            like(flag)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(SITE)
     d  prmVisitor                         like(RECID)

      *****************************************************************
      * Prototyped call: chkVisitor
      *****************************************************************
     d chkVisitor      pr                  extpgm('WEBVISITRE')
     d  prmWarnid                          like(msgid)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(SITE)
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)

      *****************************************************************
      * Prototyped call: clrmsgc
      *****************************************************************
     d clrmsgc         pr                  extpgm('CLRMSGC')

      *****************************************************************
      * Prototyped call: sndmsgidc
      *****************************************************************
     d sndmsgidc       pr                  extpgm('SNDMSGIDC')
     d  prmMsgfile                         like(pgmnam)
     d  prmMsgid                           like(msgid)

      *****************************************************************
      * Prototyped call: sndmsgdtac
      *****************************************************************
     d sndmsgdtac      pr                  extpgm('SNDMSGDTAC')
     d  prmMsgdta                          like(msgdta)

      *****************************************************************
      * Subprocedure: setPOSDSC
      *****************************************************************
     d setPOSDSC       pr                  like(POSDSC)
     d  prmView                            like(viewmode)

      *****************************************************************
      * Subprocedure: setIPSEG
      *****************************************************************
     d setIPSEG        pr
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)
     d  prmIPCHR1                          like(IPCHR)
     d  prmIPCHR2                          like(IPCHR)
     d  prmIPCHR3                          like(IPCHR)
     d  prmIPCHR4                          like(IPCHR)

      *****************************************************************
      * Subprocedure: cvtIPSEG
      *****************************************************************
     d cvtIPSEG        pr
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)
     d  prmIPCHR1                          like(IPCHR)
     d  prmIPCHR2                          like(IPCHR)
     d  prmIPCHR3                          like(IPCHR)
     d  prmIPCHR4                          like(IPCHR)

      *****************************************************************
      * Subprocedure: chkIPBlocked
      *****************************************************************
     d chkIPBlocked    pr              n
     d  prmSite                            like(SITE)
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)

      *****************************************************************
      * Subprocedure: chkIPVisited
      *****************************************************************
     d chkIPVisited    pr              n
     d  prmSite                            like(SITE)
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)

      *****************************************************************
      * Data Structure Declaration
      *****************************************************************
      * system program feedback area
     d systemds       sds
     d  pgmnam                       10
     d  pgmlib                81     90
     d  jobnam               244    253
     d  usrnam                       10
     d  jobnbr                        6  0

      *****************************************************************
      * Stand Alone Fields Declaration
      *****************************************************************
     d* Base types
     d boolean         s               n
     d char            s              1a
     d flag            s                   like(char)
     d returnCode      s              1s 0
     d viewmode        s              1  0
     d IPCHR           s              3a
     d POSDSC          s              7a
     d SITE            s             10a
     d IPSEG           s              3  0
     d IPZERO          s                   like(IPSEG) inz(0)
     d RECID           s              7  0

     d* Message file variables
     d pgmsgq          s                   like(pgmnam)
     d prmMsgfile      s                   like(pgmnam)
     d msgid           s              7a
     d msgdta          s             78a
     d prmMsgid        s                   like(msgid)
     d prmMsgdta       s                   like(msgdta)

     d* Return code values
     d   wrkSuccess    c                   const(0)
     d   wrkFailure    c                   const(1)
     d   wrkError      c                   const(-1)

     d* Subfile load values
     d   Position      c                   const(0)
     d   ReadForward   c                   const(1)
     d   ReadBack      c                   const(-1)

     d* Subfile view values
     d   VisitorRRN    c                   const(0)
     d   IPaddress     c                   const(1)
     d   HostIP        c                   const(2)
     d   StateHost     c                   const(3)
     d   CityState     c                   const(4)
     d   TopicHost     c                   const(5)

     d* Constants
     d IPlen           c                   const(%len(IPSEG))
     d IPdec           c                   const(%decpos(IPSEG))
     d green_ul        c                   const(X'24')
     d green_ul_ri     c                   const(X'25')
     d non_pr          c                   const(X'A7')
     d msgFile         c                   'RDWMSGF'


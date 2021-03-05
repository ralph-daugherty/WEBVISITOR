      *****************************************************************
      *               Web IP Records File Maintenance Delete
      *
      *  Program WEBVISITRD
      *****************************************************************
     h  dftactgrp(*no) actgrp('RDWRITES') bnddir('RDWRITES')
     h  debug option(*srcstmt:*nodebugio)

      *****************************************************************
      * File Specifications
      *****************************************************************
      * WEBIPRECRD override file
     fwebiprecrduf   e           k disk    rename(WEBVISITR: IPRECRD)
      * Display File
     fwebvisitddcf   e             workstn

      *****************************************************************
      *Entry Declaration
      *****************************************************************
     d WEBVISITRD      pr
     d  prmErrorCode                       like(returnCode)
     d  prmExit                            like(flag)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(WEBSITE)
     d  prmVisitor                         like(VISITOR)

     d WEBVISITRD      pi
     d  prmErrorCode                       like(returnCode)
     d  prmExit                            like(flag)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(WEBSITE)
     d  prmVisitor                         like(VISITOR)

      *****************************************************************
      * Prototype Definitions
      *****************************************************************
      /copy RDWSRC,WEBVISITPR

      *****************************************************************
      * Data Structure Declaration
      *****************************************************************
      * function keys and indicators
     d @Indicator      s               *   inz(%addr(*IN))
     d Indicators      ds                  based(@Indicator)
     d  Exit                  03     03
     d  Cancel                12     12
     d  DeleteRec             22     22
     d  SflMsgEnd             98     98

      *****************************************************************
      * Stand Alone Fields Declaration
      *****************************************************************
     d wrkCfmflg       s                   like(flag)

      *****************************************************************
      * Mainline
      *****************************************************************
      /free
         chain (prmSite: prmVISITOR) WEBIPRECRD;
         if not %found(WEBIPRECRD);
           prmErrorCode = wrkError;
           exsr exitProgram;
         endif;

         write SCN04;
         exsr clrMsg;
         exsr setSCN04;

         dou Exit = *on or Cancel = *on;
           write MSGCTL;
           exfmt SCN04;
           exsr clrMsg;

           select;

            // F3 Exit pressed
             when Exit = *on;
               prmExit = Exit;
               leave;

            // F12 Return pressed
             when Cancel = *on;
               leave;

              // F22 Delete pressed
               when DeleteRec = *on;
                 exsr cfmDel;
                 if wrkCfmflg = 'N';
                   iter;
                 endif;
                 delete(e) IPRECRD;
                 if %error;
                   exsr IOSysErr;
                   leave;
                 endif;
                 prmErrorCode = wrkSuccess;
                 leave;

            // Enter pressed
             other;
               prmMsgfile = msgFile;
               prmMsgid = 'RDW0007';
              // 'Press F22 to delete.'
               exsr sndmsgid;
           endsl;
         enddo;

        // Exit program
         exsr exitProgram;

       //**************************************************************
       //  Subroutine: setSCN04
       //**************************************************************
         begsr setSCN04;

           S4FILE   = prmFile;
           S4SITE   = WEBSITE;

           S4VISITOR = VISITOR;

           callp setIPSEG(IPSEG1
                         :IPSEG2
                         :IPSEG3
                         :IPSEG4
                         :S4IPSEG1
                         :S4IPSEG2
                         :S4IPSEG3
                         :S4IPSEG4);

           S4HOST   = HOST;
           S4CITY   = CITY;
           S4STATE  = STATE;
           S4TOPIC  = TOPIC;
           S4USER   = USER;
           S4SEARCH = SEARCH;

         endsr;

       //**************************************************************
       //  Subroutine: cfmDel
       //**************************************************************
         begsr cfmDel;

           wrkCfmflg = 'N';
           write MSGCTL;
           exfmt DELCFMWR;
           select;

            // F3 Exit pressed
             when Exit = *on;
               Exit = *off;
               leavesr;

            // F12 Return pressed
             when Cancel = *on;
               Cancel = *off;
               leavesr;

            // Enter pressed
             other;
               wrkCfmflg = 'Y';
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: clrMsg
       //**************************************************************
         begsr clrMsg;

           SflMsgEnd = *on;
           write MSGCTL;
           SflMsgEnd = *off;
           clrmsgc();

         endsr;

       //**************************************************************
       //  Subroutine: sndMsgid
       //    parms:    prmMsgfile  message file
       //              prmMsgid    message id to send
       //**************************************************************
         begsr sndMsgid;

           sndmsgidc(prmMsgfile: prmMsgid);

         endsr;

       //**************************************************************
         begsr IOSysErr;

           prmErrorCode = wrkError;
           prmMsgfile = msgFile;
           prmMsgid = 'RDW0010';
          // 'Record I/O failure.'
           exsr sndmsgid;

         endsr;

       //**************************************************************
       //  Subroutine: exitProgram
       //**************************************************************
         begsr exitProgram;

           *inlr = *on;
           return;

         endsr;

       //**************************************************************
       //  Subroutine: *inzsr
       //**************************************************************
         begsr *inzsr;

          // default return code
           prmErrorCode = wrkFailure;
           prmExit = *blanks;

           pgmsgq = pgmnam;

         endsr;

      /end-free


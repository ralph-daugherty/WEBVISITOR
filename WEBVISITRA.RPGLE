      *****************************************************************
      *               Web IP Records File Maintenance Add
      *
      *  Program WEBVISITRA
      *****************************************************************
     h  dftactgrp(*no) actgrp('RDWRITES') bnddir('RDWRITES')
     h  debug option(*srcstmt:*nodebugio)

      *****************************************************************
      * File Specifications
      *****************************************************************
      * WEBIPRECRD override file
     fwebiprecrdif a e           k disk    rename(WEBVISITR: IPRECRD)
      * Display File
     fwebvisitdacf   e             workstn

      *****************************************************************
      *Entry Declaration
      *****************************************************************
     d WEBVISITRA      pr
     d  prmErrorCode                       like(returnCode)
     d  prmExit                            like(flag)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(WEBSITE)
     d  prmVisitor                         like(VISITOR)

     d WEBVISITRA      pi
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
     d  Save                  10     10
     d  Cancel                12     12
     d  SflMsgEnd             98     98

      *****************************************************************
      * Stand Alone Fields Declaration
      *****************************************************************
     d* Work variables
     d wrkVISITOR      s                   like(VISITOR)
     d wrkCfmflg       s                   like(flag)

      *****************************************************************
      * Mainline
      *****************************************************************
      /free
         write SCN06;
         exsr clrMsg;
         exsr setSCN06;

         dou Exit = *on or Cancel = *on;
           write MSGCTL;
           exfmt SCN06;
           exsr clrMsg;

           select;

            // F3 Exit pressed
             when Exit = *on;
               prmExit = Exit;
               leave;

            // F12 Return pressed
             when Cancel = *on;
               leave;

            // F10 Save pressed
             when Save = *on;
               exsr valSCN06;
               if wrkCfmflg = 'N';
                 iter;
               endif;
               exsr wrtSCN06;
               leave;

            // Enter pressed
             other;
               exsr valSCN06;
               if wrkCfmflg = 'Y';
                 prmMsgfile = msgFile;
                 prmMsgid = 'RDW0008';
                // 'Press F10 to save.'
                 exsr sndmsgid;
               endif;
           endsl;
         enddo;

        // Exit program
         exsr exitProgram;

       //**************************************************************
       //  Subroutine: setSCN06
       //**************************************************************
         begsr setSCN06;

           S6FILE   = prmFile;
           S6SITE   = prmSite;

           ATBIPSEG1 = green_ul;
           S6IPSEG1 = *zeros;
           S6IPSEG2 = *zeros;
           S6IPSEG3 = *zeros;
           S6IPSEG4 = *zeros;
           S6HOST   = *blanks;
           S6CITY   = *blanks;
           S6STATE  = *blanks;
           S6TOPIC  = *blanks;
           S6USER   = *blanks;
           S6SEARCH = *blanks;

         endsr;

       //**************************************************************
       //  Subroutine: valSCN06
       //**************************************************************
         begsr valSCN06;

           wrkCfmflg = 'N';
           ATBIPSEG1 = green_ul;

           if S6IPSEG1 = *zeros;
             ATBIPSEG1 = green_ul_ri;
             prmMsgfile = msgFile;
             prmMsgid = 'RDW0003';
            // 'Required field.'
             exsr sndmsgid;
             leavesr;
           endif;

           prmMsgid = *blanks;
           callp chkVisitor(prmMsgid
                           :prmFile
                           :prmSite
                           :S6IPSEG1
                           :S6IPSEG2
                           :S6IPSEG3
                           :S6IPSEG4);

           if prmMsgid <> *blanks;
             prmMsgfile = msgFile;
            // rules warning message
             exsr sndmsgid;
             leavesr;
           endif;

           wrkCfmflg = 'Y';

         endsr;

       //**************************************************************
       //  Subroutine: wrtSCN06
       //**************************************************************
         begsr wrtSCN06;

           setgt (prmSite: *hival) WEBIPRECRD;
           readpe (prmSite) WEBIPRECRD;
           if not %eof(WEBIPRECRD);
             wrkVISITOR = VISITOR;
           else;
             wrkVISITOR = *zeros;
           endif;
           monitor;
             wrkVISITOR += 1;
             on-error;
               exsr OverflowErr;
               leavesr;
             endmon;

           WEBSITE = prmSite;
           VISITOR = wrkVISITOR;
           IPSEG1  = S6IPSEG1;
           IPSEG2  = S6IPSEG2;
           IPSEG3  = S6IPSEG3;
           IPSEG4  = S6IPSEG4;
           HOST    = S6HOST;
           CITY    = S6CITY;
           STATE   = S6STATE;
           TOPIC   = S6TOPIC;
           USER    = S6USER;
           SEARCH  = S6SEARCH;

           write(e) IPRECRD;
           if %error;
             exsr IOSysErr;
             leavesr;
           endif;
           prmVISITOR = wrkVISITOR;
           prmErrorCode = wrkSuccess;

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
       //  Subroutine: OverflowErr
       //**************************************************************
         begsr OverflowErr;

           prmErrorCode = wrkError;
           prmMsgfile = msgFile;
           prmMsgid = 'RDW0011';
          // 'Numeric overflow. Operation failed.'
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


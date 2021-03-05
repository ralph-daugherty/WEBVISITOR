      *****************************************************************
      *               Web IP Records File Maintenance Update
      *
      *  Program WEBVISITRC
      *****************************************************************
     h  dftactgrp(*no) actgrp('RDWRITES')
     h  debug option(*srcstmt:*nodebugio)

      *****************************************************************
      * File Specifications
      *****************************************************************
      * WEBIPRECRD override file
     fwebiprecrduf   e           k disk    rename(WEBVISITR: IPRECRD)
      * Display File
     fwebvisitdccf   e             workstn

      *****************************************************************
      *Entry Declaration
      *****************************************************************
     d WEBVISITRC      pr
     d  prmErrorCode                       like(returnCode)
     d  prmExit                            like(flag)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(WEBSITE)
     d  prmVisitor                         like(VISITOR)

     d WEBVISITRC      pi
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

         write SCN02;
         exsr clrMsg;
         exsr setSCN02;

         dou Exit = *on or Cancel = *on;
           write MSGCTL;
           exfmt SCN02;
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
               exsr valSCN02;
               if wrkCfmflg = 'N';
                 iter;
               endif;
               exsr updSCN02;
               leave;

            // Enter pressed
             other;
               exsr valSCN02;
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
       //  Subroutine: setSCN02
       //**************************************************************
         begsr setSCN02;

           S2FILE   = prmFile;
           S2SITE   = WEBSITE;

           S2VISITOR = VISITOR;
           ATBIPSEG1 = green_ul;
           S2IPSEG1 = IPSEG1;
           S2IPSEG2 = IPSEG2;
           S2IPSEG3 = IPSEG3;
           S2IPSEG4 = IPSEG4;
           S2HOST   = HOST;
           S2CITY   = CITY;
           S2STATE  = STATE;
           S2TOPIC  = TOPIC;
           S2USER   = USER;
           S2SEARCH = SEARCH;

         endsr;

       //**************************************************************
       //  Subroutine: valSCN02
       //**************************************************************
         begsr valSCN02;

           wrkCfmflg = 'N';
           ATBIPSEG1 = green_ul;

           if S2IPSEG1 = *zeros;
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
                           :S2IPSEG1
                           :S2IPSEG2
                           :S2IPSEG3
                           :S2IPSEG4);

           if prmMsgid <> *blanks;
             prmMsgfile = msgFile;
            // rules warning message
             exsr sndmsgid;
             leavesr;
           endif;

           wrkCfmflg = 'Y';

         endsr;

       //**************************************************************
       //  Subroutine: updSCN02
       //**************************************************************
         begsr updSCN02;

           IPSEG1  = S2IPSEG1;
           IPSEG2  = S2IPSEG2;
           IPSEG3  = S2IPSEG3;
           IPSEG4  = S2IPSEG4;
           HOST    = S2HOST;
           CITY    = S2CITY;
           STATE   = S2STATE;
           TOPIC   = S2TOPIC;
           USER    = S2USER;
           SEARCH  = S2SEARCH;

           update(e) IPRECRD;
           if %error;
             exsr IOSysErr;
             leavesr;
           endif;
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


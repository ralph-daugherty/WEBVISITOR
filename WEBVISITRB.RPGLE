      *****************************************************************
      *               Web IP Records File Maintenance Display
      *
      *  Program WEBVISITRB
      *****************************************************************
     h  dftactgrp(*no) actgrp('RDWRITES') bnddir('RDWRITES')
     h  debug option(*srcstmt:*nodebugio)

      *****************************************************************
      * File Specifications
      *****************************************************************
      * WEBIPRECRD override file
     fwebiprecrdif   e           k disk    rename(WEBVISITR: IPRECRD)
      * Display File
     fwebvisitdbcf   e             workstn

      *****************************************************************
      *Entry Declaration
      *****************************************************************
     d WEBVISITRB      pr
     d  prmErrorCode                       like(returnCode)
     d  prmExit                            like(flag)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(WEBSITE)
     d  prmVisitor                         like(VISITOR)

     d WEBVISITRB      pi
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
     d  SflMsgEnd             98     98

      *****************************************************************
      * Mainline
      *****************************************************************
      /free
         chain (prmSite: prmVISITOR) WEBIPRECRD;
         if not %found(WEBIPRECRD);
           prmErrorCode = wrkError;
           exsr exitProgram;
         endif;

         prmErrorCode = wrkSuccess;
         write SCN05;
         exsr clrMsg;
         exsr setSCN05;

         dou Exit = *on or Cancel = *on;
           write MSGCTL;
           exfmt SCN05;
           exsr clrMsg;

           select;

            // F3 Exit pressed
             when Exit = *on;
               prmExit = Exit;
               leave;

            // F12 Return pressed
             when Cancel = *on;
               leave;

            // Enter pressed
             other;
               leave;
           endsl;
         enddo;

        // Exit program
         exsr exitProgram;

       //**************************************************************
       //  Subroutine: setSCN05
       //**************************************************************
         begsr setSCN05;

           S5FILE   = prmFile;
           S5SITE   = WEBSITE;

           S5VISITOR = VISITOR;

           callp setIPSEG(IPSEG1
                         :IPSEG2
                         :IPSEG3
                         :IPSEG4
                         :S5IPSEG1
                         :S5IPSEG2
                         :S5IPSEG3
                         :S5IPSEG4);

           S5HOST   = HOST;
           S5CITY   = CITY;
           S5STATE  = STATE;
           S5TOPIC  = TOPIC;
           S5USER   = USER;
           S5SEARCH = SEARCH;

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

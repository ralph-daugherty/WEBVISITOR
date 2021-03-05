      *****************************************************************
      *               Web IP Records File Maintenance
      *
      *  Program WEBVISITRP
      *****************************************************************
     h  dftactgrp(*no) actgrp('RDWRITES') bnddir('RDWRITES')
     h  debug option(*srcstmt:*nodebugio)

      *****************************************************************
      * File Specifications
      *****************************************************************
      * WEBIPRECRD override file
     fwebiprecrdif   e           k disk    rename(WEBVISITR: IPRECRD)
     fwebiprcdl1if   e           k disk    rename(WEBVISITR: IPRCDL1)
     fwebiprcdl2if   e           k disk    rename(WEBVISITR: IPRCDL2)
     fwebiprcdl3if   e           k disk    rename(WEBVISITR: IPRCDL3)
     fwebiprcdl4if   e           k disk    rename(WEBVISITR: IPRCDL4)
     fwebiprcdl5if   e           k disk    rename(WEBVISITR: IPRCDL5)
      * Display File
     fwebvisitd cf   e             workstn sfile(SFLS1:SF1RRN)
     f                                     infds(SFLC1DS)
     f                                     sfile(SFLS2:SF2RRN)

      *****************************************************************
      * *Entry Declaration
      *****************************************************************
     d WEBVISITRP      pr
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(WEBSITE)

     d WEBVISITRP      pi
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(WEBSITE)

      *****************************************************************
      * Prototype Definitions
      *****************************************************************
      /copy RDWSRC,WEBVISITPR

      *****************************************************************
      * Data Structure Declaration
      *****************************************************************
      * SFLC1 file information DS
     d SFLC1DS         ds           512     qualified
     d  rowcol               370    371b 0

      * function keys and indicators
     d @Indicator      s               *   inz(%addr(*IN))
     d Indicators      ds                  based(@Indicator)
     d  Exit                  03     03
     d  Refresh               05     05
     d  AddNew                06     06
     d  View                  11     11
     d  Cancel                12     12
     d  PageUp                26     26
     d  PageDown              27     27
     d  SflDsp                91     91
     d  SflDspCtl             92     92
     d  SflClr                93     93
     d  SflEnd                94     94
     d  SflNxtChg             95     95
     d  CsrLoc                96     96
     d  SflMsgEnd             98     98

      *****************************************************************
      * Stand Alone Fields Declaration
      *****************************************************************
     d* Mode variables
     d pageCtr         s                   like(SF1RRN) inz(0)
     d loopCtr         s                   like(SF1RRN)
     d loadmode        s                   like(viewmode)
     d reload          s                   like(boolean)
     d csrpos          s              5s 0

     d* Parm variables
     d prmErrorCode    s                   like(returnCode)
     d prmExit         s                   like(flag)
     d prmVisitor      s                   like(VISITOR)
     d prmView         s                   like(viewmode)

     d* Work variables
     d wrkErrflg       s                   like(flag)
     d wrkChgflg       s                   like(flag)
     d wrkTopflg       s                   like(flag)

     d* Save variables
     d savSf1RRN       s                   like(SF1RRN)
     d savVISITOR      s                   like(VISITOR)
     d savIPSEG1       s                   like(IPSEG1)
     d savIPSEG2       s                   like(IPSEG2)
     d savIPSEG3       s                   like(IPSEG3)
     d savIPSEG4       s                   like(IPSEG4)
     d savHOST         s                   like(HOST)
     d savCITY         s                   like(CITY)
     d savSTATE        s                   like(STATE)
     d savTOPIC        s                   like(TOPIC)

     d* Constants
     d sf1Size         c                   const(12)
     d sf2Size         c                   const(6)

      *****************************************************************
      * Mainline
      *****************************************************************
      /free
        // initial subfile load
         viewmode = IPaddress;
         exsr initLoadPos;
         reload = *on;

         dow Exit = *off;
           if reload = *on;
             CsrLoc = *off;
             exsr loadSfl;
             reload = *off;
           endif;
           write MSGCTL;
           write SFL1KEY;
           exfmt SFLC1;
           exsr clrMsg;
           exsr setSFLC1csr;
           CsrLoc = *off;

           select;
            // F3 Exit pressed
             when Exit = *on;
               leave;

            // F12 Cancel pressed
             when Cancel = *on;
               leave;
           endsl;

          // check if an option entered
           wrkChgflg = *off;
           wrkTopflg = *off;
           if SflDsp = *on;
             dou %eof;
               wrkErrflg = *off;
               readc SFLS1;
               if %eof;
                 leave;
               endif;

               CsrLoc = *on;
               select;
                // update IP address record
                 when S1SELECT = '2';
                   exsr optUpdIP;

                // delete IP address record
                 when S1SELECT = '4';
                   exsr optDelIP;

                // display IP address record
                 when S1SELECT = '5';
                   exsr optDspIP;

                // ignore blanks
                 when S1SELECT = *blanks;

                 other;
                   wrkErrflg = *on;
                   prmMsgfile = msgFile;
                   prmMsgid = 'RDW0012';
                  // 'Invalid option.'
                   exsr sndmsgid;
               endsl;

               select;
                 when wrkErrflg = *off;
                   S1SELECT = *blanks;
                   atbS1SEL = green_ul;
                   SflNxtChg = *off;

                 other;
                  // subfile selection criteria not met
                  // return with highlighted subfile change option
                   atbS1SEL = green_ul_ri;
                   SflNxtChg = *on;
                   wrkChgflg = *on;
               endsl;
               update SFLS1;
             enddo;
           endif;

           if wrkChgflg = *on;
             iter;
           endif;

           select;
            // check if PageDown key is pressed
             when PageDown = *on
               and SflEnd = *off;
               loadmode = ReadForward;
               reload = *on;

            // check if PageUp key is pressed
             when PageUp = *on
               and SflDsp = *on;
               loadmode = ReadBack;
               exsr setTopPos;
               reload = *on;

            // F5 Refresh pressed
             when Refresh = *on;
               loadmode = Position;
               exsr setTopPos;
               reload = *on;

            // F6 Add pressed
             when AddNew = *on;
               exsr optAddIP;

            // F11 Change View pressed
             when View = *on;
               exsr optView;

            // check if reposition is entered
             other;
               exsr chkReposition;
               if reload = *off
                 and wrkTopflg = *on;
                 loadmode = Position;
                 exsr setTopPos;
                 reload = *on;
               endif;
           endsl;
         enddo;

        // Exit program
         exsr exitProgram;

       //**************************************************************
       //  Subroutine: optAddIP
       //**************************************************************
         begsr optAddIp;

           callp addVisitor(prmErrorCode
                           :prmExit
                           :prmFile
                           :prmSite
                           :prmVisitor);
           select;
             when prmExit = *on;
               exsr exitProgram;

             when prmErrorCode = wrkSuccess;
               exsr setAddPos;
               reload = *on;
               prmMsgfile = msgFile;
               prmMsgid = 'RDW0004';
              // 'Record added.'
               exsr sndmsgid;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: setAddPos
       //    in:       viewmode set to selected view
       //**************************************************************
         begsr setAddPos;

           loadmode = Position;

           chain (prmSite: prmVISITOR) WEBIPRECRD;
           if not %found(WEBIPRECRD);
             leavesr;
           endif;

           select;
             when viewmode = VisitorRRN;
               C1VISITOR = VISITOR;

             when viewmode = IPaddress;
               C1IPSEG1 = IPSEG1;
               C1IPSEG2 = IPSEG2;
               C1IPSEG3 = IPSEG3;
               C1IPSEG4 = IPSEG4;

             when viewmode = HostIP;
               C1HOST = HOST;
               C1IPSEG1 = IPSEG1;
               C1IPSEG2 = IPSEG2;
               C1IPSEG3 = IPSEG3;
               C1IPSEG4 = IPSEG4;

             when viewmode = StateHost;
               C1STATE = STATE;
               C1HOST3 = HOST;
               C1IPSEG1 = IPSEG1;
               C1IPSEG2 = IPSEG2;
               C1IPSEG3 = IPSEG3;
               C1IPSEG4 = IPSEG4;

             when viewmode = CityState;
               C1CITY = CITY;
               C1STATE4 = STATE;
               C1HOST4 = HOST;
               C1IPSEG1 = IPSEG1;
               C1IPSEG2 = IPSEG2;
               C1IPSEG3 = IPSEG3;
               C1IPSEG4 = IPSEG4;

             when viewmode = TopicHost;
               C1TOPIC = TOPIC;
               C1HOST5 = HOST;
               C1IPSEG1 = IPSEG1;
               C1IPSEG2 = IPSEG2;
               C1IPSEG3 = IPSEG3;
               C1IPSEG4 = IPSEG4;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: optUpdIP
       //**************************************************************
         begsr optUpdIp;

           prmVisitor = S1VISITOR;
           callp updVisitor(prmErrorCode
                           :prmExit
                           :prmFile
                           :prmSite
                           :prmVisitor);
           select;
             when Exit = *on;
               exsr exitProgram;

             when prmErrorCode = wrkSuccess;
               wrkTopflg = *on;
               prmMsgfile = msgFile;
               prmMsgid = 'RDW0005';
              // 'Record updated.'
               exsr sndmsgid;

             when prmErrorCode = wrkError;
               wrkErrflg = *on;
               prmMsgfile = msgFile;
               prmMsgid = 'RDW0009';
              // 'Selection not completed.'
               exsr sndmsgid;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: optDelIP
       //**************************************************************
         begsr optDelIp;

           prmVisitor = S1VISITOR;
           callp delVisitor(prmErrorCode
                           :prmExit
                           :prmFile
                           :prmSite
                           :prmVisitor);
           select;
             when Exit = *on;
               exsr exitProgram;

             when prmErrorCode = wrkSuccess;
               wrkTopflg = *on;
               prmMsgfile = msgFile;
               prmMsgid = 'RDW0006';
              // 'Record deleted.'
               exsr sndmsgid;

             when prmErrorCode = wrkError;
               wrkErrflg = *on;
               prmMsgfile = msgFile;
               prmMsgid = 'RDW0009';
              // 'Selection not completed.'
               exsr sndmsgid;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: optDspIP
       //**************************************************************
         begsr optDspIp;

           prmVisitor = S1VISITOR;
           callp dspVisitor(prmErrorCode
                           :prmExit
                           :prmFile
                           :prmSite
                           :prmVisitor);
           select;
             when Exit = *on;
               exsr exitProgram;

             when prmErrorCode = wrkSuccess;
              // record displayed

             when prmErrorCode = wrkError;
               wrkErrflg = *on;
               prmMsgfile = msgFile;
               prmMsgid = 'RDW0009';
              // 'Selection not completed.'
               exsr sndmsgid;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: optView
       //**************************************************************
         begsr optView;

           exsr loadSfl2;
           exfmt SFLC2;

           dou %eof;
             readc SFLS2;
             if %eof;
               leave;
             endif;

             if S2SELECT <> *blanks;
               viewmode = SF2RRN-1;
               loadmode = Position;
               exsr setTopPos;
               exsr initViewMode;
               C1POSDSC = setPOSDSC(viewmode);
               reload = *on;
               leave;
             endif;
           enddo;

         endsr;

       //**************************************************************
       //  Subroutine: initLoadPos
       //    in:       viewmode set to selected view
       //**************************************************************
         begsr initLoadPos;

           loadmode = Position;
           C1POSDSC = setPOSDSC(viewmode);

           select;
             when viewmode = VisitorRRN;
               C1VISITOR = *loval;
               savVISITOR  = *zeros;

             when viewmode = IPaddress;
               C1IPSEG1 = *loval;
               C1IPSEG2 = *loval;
               C1IPSEG3 = *loval;
               C1IPSEG4 = *loval;
               savIPSEG1 = *zeros;
               savIPSEG2 = *zeros;
               savIPSEG3 = *zeros;
               savIPSEG4 = *zeros;

             when viewmode = HostIP;
               C1HOST   = *loval;
               C1IPSEG1 = *loval;
               C1IPSEG2 = *loval;
               C1IPSEG3 = *loval;
               C1IPSEG4 = *loval;
               savHOST  = *blanks;
               savIPSEG1 = *zeros;
               savIPSEG2 = *zeros;
               savIPSEG3 = *zeros;
               savIPSEG4 = *zeros;

             when viewmode = StateHost;
               C1STATE  = *loval;
               C1HOST3  = *loval;
               C1IPSEG1 = *loval;
               C1IPSEG2 = *loval;
               C1IPSEG3 = *loval;
               C1IPSEG4 = *loval;
               savSTATE = *blanks;
               savHOST  = *blanks;
               savIPSEG1 = *zeros;
               savIPSEG2 = *zeros;
               savIPSEG3 = *zeros;
               savIPSEG4 = *zeros;

             when viewmode = CityState;
               C1CITY   = *loval;
               C1STATE4 = *loval;
               C1HOST4  = *loval;
               C1IPSEG1 = *loval;
               C1IPSEG2 = *loval;
               C1IPSEG3 = *loval;
               C1IPSEG4 = *loval;
               savCITY  = *blanks;
               savSTATE = *blanks;
               savHOST  = *blanks;
               savIPSEG1 = *zeros;
               savIPSEG2 = *zeros;
               savIPSEG3 = *zeros;
               savIPSEG4 = *zeros;

             when viewmode = TopicHost;
               C1TOPIC  = *loval;
               C1HOST5  = *loval;
               C1IPSEG1 = *loval;
               C1IPSEG2 = *loval;
               C1IPSEG3 = *loval;
               C1IPSEG4 = *loval;
               savTOPIC = *zeros;
               savHOST  = *blanks;
               savIPSEG1 = *zeros;
               savIPSEG2 = *zeros;
               savIPSEG3 = *zeros;
               savIPSEG4 = *zeros;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: loadSfl
       //**************************************************************
         begsr loadSfl;

           exsr initSfl;
           SF1RRN = savSF1RRN;
           pageCtr = *zeros;

           exsr loadViewMode;

           SflClr = *off;
           SflDspCtl = *on;

          // Display message if no record found
           if SF1RRN = *zeros;
             SF1RRN = 1;
             atbS1SEL = non_pr;
             write SFLS1;
             prmMsgfile = msgFile;
             prmMsgid = 'RDW0002';
            // 'No records to display.'
             exsr sndmsgid;
           endif;

         endsr;

       //**************************************************************
       //  Subroutine: initSfl
       //**************************************************************
         begsr initSfl;

           exsr clrSfl;
           select;
             when loadmode = Position;
               exsr initViewMode;

             when loadmode = ReadForward;
               exsr rollSfl;

             when loadmode = ReadBack;
               exsr backSfl;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: clrSfl
       //**************************************************************
         begsr clrSfl;

           SflClr = *on;
           SflDsp = *off;
           SflDspCtl = *off;
           SflEnd = *off;
           SflNxtChg = *off;

           SF1RRN = *zeros;
           savSF1RRN = SF1RRN;

           write SFLC1;

           SflDsp = *on;
           SflDspCtl = *on;
           SflClr = *off;

           C1FILE   = prmFile;
           C1SITE   = prmSite;

           S1SELECT = *blanks;
           atbS1SEL = green_ul;
           S1VISITOR = *zeros;
           S1IPSEG1 = *zeros;
           S1IPSEG2 = *zeros;
           S1IPSEG3 = *zeros;
           S1IPSEG4 = *zeros;
           S1HOST   = *blanks;
           S1CITY   = *blanks;
           S1STATE  = *blanks;
           S1TOPIC  = *blanks;

         endsr;

       //**************************************************************
       //  Subroutine: initViewMode
       //    in:       viewmode set to selected view
       //              position to variables set
       //**************************************************************
         begsr initViewMode;

           *in50 = *off;
           *in51 = *off;
           *in52 = *off;
           *in53 = *off;
           *in54 = *off;
           *in55 = *off;

           select;
             when viewmode = VisitorRRN;
               setll (prmSite: C1VISITOR) WEBIPRECRD;
               *in50 = *on;

             when viewmode = IPaddress;
               setll (prmSite
                     :C1IPSEG1
                     :C1IPSEG2
                     :C1IPSEG3
                     :C1IPSEG4)
                     WEBIPRCDL1;
               *in51 = *on;

             when viewmode = HostIP;
               setll (prmSite
                     :C1HOST
                     :C1IPSEG1
                     :C1IPSEG2
                     :C1IPSEG3
                     :C1IPSEG4)
                     WEBIPRCDL2;
               *in52 = *on;

             when viewmode = StateHost;
               setll (prmSite
                     :C1STATE
                     :C1HOST3
                     :C1IPSEG1
                     :C1IPSEG2
                     :C1IPSEG3
                     :C1IPSEG4)
                     WEBIPRCDL3;
               *in53 = *on;

             when viewmode = CityState;
               setll (prmSite
                     :C1CITY
                     :C1STATE4
                     :C1HOST4
                     :C1IPSEG1
                     :C1IPSEG2
                     :C1IPSEG3
                     :C1IPSEG4)
                     WEBIPRCDL4;
               *in54 = *on;

             when viewmode = TopicHost;
               setll (prmSite
                     :C1TOPIC
                     :C1HOST5
                     :C1IPSEG1
                     :C1IPSEG2
                     :C1IPSEG3
                     :C1IPSEG4)
                     WEBIPRCDL5;
               *in55 = *on;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: rollSfl
       //**************************************************************
         begsr rollSfl;

           select;
             when viewmode = VisitorRRN;
               setgt (prmSite: savVISITOR) WEBIPRECRD;

             when viewmode = IPaddress;
               setgt (prmSite
                     :savIPSEG1
                     :savIPSEG2
                     :savIPSEG3
                     :savIPSEG4)
                     WEBIPRCDL1;

             when viewmode = HostIP;
               setgt (prmSite
                     :savHOST
                     :savIPSEG1
                     :savIPSEG2
                     :savIPSEG3
                     :savIPSEG4)
                     WEBIPRCDL2;

             when viewmode = StateHost;
               setgt (prmSite
                     :savSTATE
                     :savHOST
                     :savIPSEG1
                     :savIPSEG2
                     :savIPSEG3
                     :savIPSEG4)
                     WEBIPRCDL3;

             when viewmode = CityState;
               setgt (prmSite
                     :savCITY
                     :savSTATE
                     :savHOST
                     :savIPSEG1
                     :savIPSEG2
                     :savIPSEG3
                     :savIPSEG4)
                     WEBIPRCDL4;

             when viewmode = TopicHost;
               setgt (prmSite
                     :savTOPIC
                     :savHOST
                     :savIPSEG1
                     :savIPSEG2
                     :savIPSEG3
                     :savIPSEG4)
                     WEBIPRCDL5;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: backSfl
       //**************************************************************
         begsr backSfl;

           exsr initViewMode;

           select;
             when viewmode = VisitorRRN;
               exsr backVisitorRRN;

             when viewmode = IPaddress;
               exsr backIPaddress;

             when viewmode = HostIP;
               exsr backHostIP;

             when viewmode = StateHost;
               exsr backStateHost;

             when viewmode = CityState;
               exsr backCityState;

             when viewmode = TopicHost;
               exsr backTopicHost;
           endsl;

           exsr initViewMode;

         endsr;

       //**************************************************************
       //  Subroutine: loadViewMode
       //**************************************************************
         begsr loadViewMode;

           select;
             when viewmode = VisitorRRN;
               exsr loadVisitorRRN;

             when viewmode = IPaddress;
               exsr loadIPaddress;

             when viewmode = HostIP;
               exsr loadHostIP;

             when viewmode = StateHost;
               exsr loadStateHost;

             when viewmode = CityState;
               exsr loadCityState;

             when viewmode = TopicHost;
               exsr loadTopicHost;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: loadVisitorRRN
       //**************************************************************
         begsr loadVisitorRRN;

           if pageCtr >= sf1Size;
             leavesr;
           endif;

           dou %eof(WEBIPRECRD)
             or pageCtr = sf1Size;

             reade (prmSite) WEBIPRECRD;
             if %eof(WEBIPRECRD);
               leave;
             endif;

             exsr setSFL1;

           enddo;

           if pageCtr > *zeros;
             savVISITOR = VISITOR;

            // Check if EOF, end SFL
             select;
               when pageCtr < sf1Size;
                 SflEnd = *on;

               other;
                 reade (prmSite) WEBIPRECRD;
                 if %eof(WEBIPRECRD);
                   SflEnd = *on;
                 endif;
             endsl;
           else;
             SflEnd = *on;
           endif;

           C1VISITOR = *zeros;

         endsr;

       //**************************************************************
       //  Subroutine: loadIPaddress
       //**************************************************************
         begsr loadIPaddress;

           if pageCtr >= sf1Size;
             leavesr;
           endif;

           dou %eof(WEBIPRCDL1)
             or pageCtr = sf1Size;

             reade (prmSite) WEBIPRCDL1;
             if %eof(WEBIPRCDL1);
               leave;
             endif;

             exsr setSFL1;

           enddo;

           if pageCtr > *zeros;
             savIPSEG1 = IPSEG1;
             savIPSEG2 = IPSEG2;
             savIPSEG3 = IPSEG3;
             savIPSEG4 = IPSEG4;

            // Check if EOF, end SFL
             select;
               when pageCtr < sf1Size;
                 SflEnd = *on;

               other;
                 reade (prmSite) WEBIPRCDL1;
                 if %eof(WEBIPRCDL1);
                   SflEnd = *on;
                 endif;
             endsl;
           else;
             SflEnd = *on;
           endif;

           C1IPSEG1 = *zeros;
           C1IPSEG2 = *zeros;
           C1IPSEG3 = *zeros;
           C1IPSEG4 = *zeros;

         endsr;

       //**************************************************************
       //  Subroutine: loadHostIP
       //**************************************************************
         begsr loadHostIP;

           if pageCtr >= sf1Size;
             leavesr;
           endif;

           dou %eof(WEBIPRCDL2)
             or pageCtr = sf1Size;

             reade (prmSite) WEBIPRCDL2;
             if %eof(WEBIPRCDL2);
               leave;
             endif;

             exsr setSFL1;

           enddo;

           if pageCtr > *zeros;
             savHOST   = HOST;
             savIPSEG1 = IPSEG1;
             savIPSEG2 = IPSEG2;
             savIPSEG3 = IPSEG3;
             savIPSEG4 = IPSEG4;

            // Check if EOF, end SFL
             select;
               when pageCtr < sf1Size;
                 SflEnd = *on;

               other;
                 reade (prmSite) WEBIPRCDL2;
                 if %eof(WEBIPRCDL2);
                   SflEnd = *on;
                 endif;
             endsl;
           else;
             SflEnd = *on;
           endif;

           C1HOST   = *blanks;
           C1IPSEG1 = *zeros;
           C1IPSEG2 = *zeros;
           C1IPSEG3 = *zeros;
           C1IPSEG4 = *zeros;

         endsr;

       //**************************************************************
       //  Subroutine: loadStateHost
       //**************************************************************
         begsr loadStateHost;

           if pageCtr >= sf1Size;
             leavesr;
           endif;

           dou %eof(WEBIPRCDL3)
             or pageCtr = sf1Size;

             reade (prmSite) WEBIPRCDL3;
             if %eof(WEBIPRCDL3);
               leave;
             endif;

             exsr setSFL1;

           enddo;

           if pageCtr > *zeros;
             savSTATE  = STATE;
             savHOST   = HOST;
             savIPSEG1 = IPSEG1;
             savIPSEG2 = IPSEG2;
             savIPSEG3 = IPSEG3;
             savIPSEG4 = IPSEG4;

            // Check if EOF, end SFL
             select;
               when pageCtr < sf1Size;
                 SflEnd = *on;

               other;
                 reade (prmSite) WEBIPRCDL3;
                 if %eof(WEBIPRCDL3);
                   SflEnd = *on;
                 endif;
             endsl;
           else;
             SflEnd = *on;
           endif;

           C1STATE  = *blanks;
           C1HOST3  = *blanks;
           C1IPSEG1 = *zeros;
           C1IPSEG2 = *zeros;
           C1IPSEG3 = *zeros;
           C1IPSEG4 = *zeros;

         endsr;

       //**************************************************************
       //  Subroutine: loadCityState
       //**************************************************************
         begsr loadCityState;

           if pageCtr >= sf1Size;
             leavesr;
           endif;

           dou %eof(WEBIPRCDL4)
             or pageCtr = sf1Size;

             reade (prmSite) WEBIPRCDL4;
             if %eof(WEBIPRCDL4);
               leave;
             endif;

             exsr setSFL1;

           enddo;

           if pageCtr > *zeros;
             savCITY   = CITY;
             savSTATE  = STATE;
             savHOST   = HOST;
             savIPSEG1 = IPSEG1;
             savIPSEG2 = IPSEG2;
             savIPSEG3 = IPSEG3;
             savIPSEG4 = IPSEG4;

            // Check if EOF, end SFL
             select;
               when pageCtr < sf1Size;
                 SflEnd = *on;

               other;
                 reade (prmSite) WEBIPRCDL4;
                 if %eof(WEBIPRCDL4);
                   SflEnd = *on;
                 endif;
             endsl;
           else;
             SflEnd = *on;
           endif;

           C1CITY   = *blanks;
           C1STATE4 = *blanks;
           C1HOST4  = *blanks;
           C1IPSEG1 = *zeros;
           C1IPSEG2 = *zeros;
           C1IPSEG3 = *zeros;
           C1IPSEG4 = *zeros;

         endsr;

       //**************************************************************
       //  Subroutine: loadTopicHost
       //**************************************************************
         begsr loadTopicHost;

           if pageCtr >= sf1Size;
             leavesr;
           endif;

           dou %eof(WEBIPRCDL5)
             or pageCtr = sf1Size;

             reade (prmSite) WEBIPRCDL5;
             if %eof(WEBIPRCDL5);
               leave;
             endif;

             exsr setSFL1;

           enddo;

           if pageCtr > *zeros;
             savTOPIC  = TOPIC;
             savHOST   = HOST;
             savIPSEG1 = IPSEG1;
             savIPSEG2 = IPSEG2;
             savIPSEG3 = IPSEG3;
             savIPSEG4 = IPSEG4;

            // Check if EOF, end SFL
             select;
               when pageCtr < sf1Size;
                 SflEnd = *on;

               other;
                 reade (prmSite) WEBIPRCDL5;
                 if %eof(WEBIPRCDL5);
                   SflEnd = *on;
                 endif;
             endsl;
           else;
             SflEnd = *on;
           endif;

           C1TOPIC  = *blanks;
           C1HOST5  = *blanks;
           C1IPSEG1 = *zeros;
           C1IPSEG2 = *zeros;
           C1IPSEG3 = *zeros;
           C1IPSEG4 = *zeros;

         endsr;

       //**************************************************************
       //  Subroutine: setSFL1
       //**************************************************************
         begsr setSFL1;

           SF1RRN += 1;

           S1VISITOR = VISITOR;

           callp setIPSEG(IPSEG1
                         :IPSEG2
                         :IPSEG3
                         :IPSEG4
                         :S1IPSEG1
                         :S1IPSEG2
                         :S1IPSEG3
                         :S1IPSEG4);

           S1HOST   = HOST;
           S1CITY   = CITY;
           S1STATE  = STATE;
           S1TOPIC  = TOPIC;

           SflDspCtl = *on;
           SflNxtChg = *off;
           write SFLS1;
           pageCtr += 1;

         endsr;

       //**************************************************************
       //  Subroutine: chkReposition
       //    in:       viewmode set to selected view
       //              position to variables optionally set
       //**************************************************************
         begsr chkReposition;

           select;
             when viewmode = VisitorRRN;
               if C1VISITOR > *zeros;
                 loadmode = Position;
                 reload = *on;
               endif;

             when viewmode = IPaddress;
               if C1IPSEG1 > *zeros;
                 loadmode = Position;
                 reload = *on;
               endif;

             when viewmode = HostIP;
               if C1HOST > *blanks;
                 loadmode = Position;
                 reload = *on;
               endif;

             when viewmode = StateHost;
               if C1STATE > *blanks;
                 loadmode = Position;
                 reload = *on;
               endif;

             when viewmode = CityState;
               if C1CITY > *blanks;
                 loadmode = Position;
                 reload = *on;
               endif;

             when viewmode = TopicHost;
               if C1TOPIC > *blanks;
                 loadmode = Position;
                 reload = *on;
               endif;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: setTopPos
       //    in:       viewmode set to selected view
       //**************************************************************
         begsr setTopPos;

           SF1RRN = 1;
           chain SF1RRN SFLS1;

           select;
             when viewmode = VisitorRRN;
               C1VISITOR = S1VISITOR;

             when viewmode = IPaddress;
               exsr setC1IPSEG;

             when viewmode = HostIP;
               C1HOST = S1HOST;
               exsr setC1IPSEG;

             when viewmode = StateHost;
               C1STATE = S1STATE;
               C1HOST3 = S1HOST;
               exsr setC1IPSEG;

             when viewmode = CityState;
               C1CITY = S1CITY;
               C1STATE4 = S1STATE;
               C1HOST4 = S1HOST;
               exsr setC1IPSEG;

             when viewmode = TopicHost;
               C1TOPIC = S1TOPIC;
               C1HOST5 = S1HOST;
               exsr setC1IPSEG;
           endsl;

         endsr;

       //**************************************************************
       //  Subroutine: setC1IPSEG
       //    Convert character display of IP address to numeric IP
       //**************************************************************
         begsr setC1IPSEG;

           callp cvtIPSEG(C1IPSEG1
                         :C1IPSEG2
                         :C1IPSEG3
                         :C1IPSEG4
                         :S1IPSEG1
                         :S1IPSEG2
                         :S1IPSEG3
                         :S1IPSEG4);

         endsr;

       //**************************************************************
       //  Subroutine: backVisitorRRN
       //**************************************************************
         begsr backVisitorRRN;

           loopCtr = *zeros;

           dou %eof(WEBIPRECRD)
             or loopCtr = sf1Size;

             readpe(e) (prmSite) WEBIPRECRD;
             if %eof(WEBIPRECRD)
               or %error;
               leave;
             endif;

             C1VISITOR = VISITOR;
             loopCtr += 1;

           enddo;

         endsr;

       //**************************************************************
       //  Subroutine: backIPaddress
       //**************************************************************
         begsr backIPaddress;

           loopCtr = *zeros;

           dou %eof(WEBIPRCDL1)
             or loopCtr = sf1Size;

             readpe(e) (prmSite) WEBIPRCDL1;
             if %eof(WEBIPRCDL1)
               or %error;
               leave;
             endif;

             C1IPSEG1 = IPSEG1;
             C1IPSEG2 = IPSEG2;
             C1IPSEG3 = IPSEG3;
             C1IPSEG4 = IPSEG4;
             loopCtr += 1;

           enddo;

         endsr;

       //**************************************************************
       //  Subroutine: backHostIP
       //**************************************************************
         begsr backHostIP;

           loopCtr = *zeros;

           dou %eof(WEBIPRCDL2)
             or loopCtr = sf1Size;

             readpe(e) (prmSite) WEBIPRCDL2;
             if %eof(WEBIPRCDL2)
               or %error;
               leave;
             endif;

             C1HOST = HOST;
             C1IPSEG1 = IPSEG1;
             C1IPSEG2 = IPSEG2;
             C1IPSEG3 = IPSEG3;
             C1IPSEG4 = IPSEG4;
             loopCtr += 1;

           enddo;

         endsr;

       //**************************************************************
       //  Subroutine: backStateHost
       //**************************************************************
         begsr backStateHost;

           loopCtr = *zeros;

           dou %eof(WEBIPRCDL3)
             or loopCtr = sf1Size;

             readpe(e) (prmSite) WEBIPRCDL3;
             if %eof(WEBIPRCDL3)
               or %error;
               leave;
             endif;

             C1STATE = STATE;
             C1HOST3 = HOST;
             C1IPSEG1 = IPSEG1;
             C1IPSEG2 = IPSEG2;
             C1IPSEG3 = IPSEG3;
             C1IPSEG4 = IPSEG4;
             loopCtr += 1;

           enddo;

         endsr;

       //**************************************************************
       //  Subroutine: backCityState
       //**************************************************************
         begsr backCityState;

           loopCtr = *zeros;

           dou %eof(WEBIPRCDL4)
             or loopCtr = sf1Size;

             readpe(e) (prmSite) WEBIPRCDL4;
             if %eof(WEBIPRCDL4)
               or %error;
               leave;
             endif;

             C1CITY = CITY;
             C1STATE4 = STATE;
             C1HOST4 = HOST;
             C1IPSEG1 = IPSEG1;
             C1IPSEG2 = IPSEG2;
             C1IPSEG3 = IPSEG3;
             C1IPSEG4 = IPSEG4;
             loopCtr += 1;

           enddo;

         endsr;

       //**************************************************************
       //  Subroutine: backTopicHost
       //**************************************************************
         begsr backTopicHost;

           loopCtr = *zeros;

           dou %eof(WEBIPRCDL5)
             or loopCtr = sf1Size;

             readpe(e) (prmSite) WEBIPRCDL5;
             if %eof(WEBIPRCDL5)
               or %error;
               leave;
             endif;

             C1TOPIC = TOPIC;
             C1HOST5 = HOST;
             C1IPSEG1 = IPSEG1;
             C1IPSEG2 = IPSEG2;
             C1IPSEG3 = IPSEG3;
             C1IPSEG4 = IPSEG4;
             loopCtr += 1;

           enddo;

         endsr;

       //**************************************************************
       //  Subroutine: setSFLC1csr
       //**************************************************************
         begsr setSFLC1csr;

           csrpos = SFLC1DS.rowcol;
           ROWPOS = %div(csrpos: 256);
           COLPOS = %rem(csrpos: 256);

         endsr;

       //**************************************************************
       //  Subroutine: loadSfl2
       //**************************************************************
         begsr loadSfl2;

           exsr clrSfl2;

           dou SF2RRN = sf2Size;
             prmView = SF2RRN;
             S2DESC = setPOSDSC(prmView);
             SflDspCtl = *on;
             SF2RRN += 1;
             write SFLS2;
           enddo;

         endsr;

       //**************************************************************
       //  Subroutine: clrSfl2
       //**************************************************************
         begsr clrSfl2;

           SflClr = *on;
           SflDsp = *off;
           SflDspCtl = *off;

           SF2RRN = *zeros;

           write SFLC2;

           SflDsp = *on;
           SflDspCtl = *on;
           SflClr = *off;

           S2SELECT = *blanks;
           S2DESC   = *blanks;

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
       //  Subroutine: sndMsg
       //    parms:    prmMsgdta   message to send
       //**************************************************************
         begsr sndMsg;

           sndmsgdtac(prmMsgdta);

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

           pgmsgq = pgmnam;

         endsr;

      /end-free

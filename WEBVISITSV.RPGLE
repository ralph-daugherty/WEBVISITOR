      *****************************************************************
      *               Web IP Records Service Program
      *
      *  Program WEBVISITSV
      *****************************************************************
     h  nomain

      *****************************************************************
      * File Specifications
      *****************************************************************
     fwebblockl1if   e           k disk    prefix(blkl1_)
     f                                     rename(WEBVISITR: IPBLKL1)
     fwebvisitl1if   e           k disk    prefix(vstl1_)
     f                                     rename(WEBVISITR: IPVSTL1)

      *****************************************************************
      * Prototype Definitions
      *****************************************************************
      /copy RDWSRC,WEBVISITPR

       //**************************************************************
       //  Subprocedure: setPOSDSC
       //  Purpose:      set description for viewmode for WEBIPRECRD
       //  Parms:        prmView      = viewmode
       //                  VisitorRRN    0
       //                  IPaddress     1
       //                  HostIP        2
       //                  StateHost     3
       //                  CityState     4
       //                  TopicHost     5
       //  Returns:      prmPOSDSC    = viewmode description
       //**************************************************************
       //
     p setPOSDSC       b                   export
     d setPOSDSC       pi                  like(POSDSC)
     d  prmView                            like(viewmode)

       // local fields
     d prmPOSDSC       s                   like(POSDSC)

      /free
         select;
           when prmView = VisitorRRN;
             prmPOSDSC = 'Visitor';

           when prmView = IPaddress;
             prmPOSDSC = 'IPaddr ';

           when prmView = HostIP;
             prmPOSDSC = 'Host   ';

           when prmView = StateHost;
             prmPOSDSC = 'State  ';

           when prmView = CityState;
             prmPOSDSC = 'City   ';

           when prmView = TopicHost;
             prmPOSDSC = 'Topic  ';
         endsl;

         return prmPOSDSC;
      /end-free
     p setPOSDSC       e

       //**************************************************************
       //  Subprocedure: setIPSEG
       //  Purpose:      set IP character display for IP address
       //  Parms:        prmIPSEG1    = numeric IP first segment
       //                prmIPSEG2    = numeric IP second segment
       //                prmIPSEG3    = numeric IP third segment
       //                prmIPSEG4    = numeric IP fourth segment
       //                prmIPCHR1    = char IP first segment
       //                prmIPCHR2    = char IP second segment
       //                prmIPCHR3    = char IP third segment
       //                prmIPCHR4    = char IP fourth segment
       //  Returns:      none
       //**************************************************************
       //
     p setIPSEG        b                   export
     d setIPSEG        pi
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)
     d  prmIPCHR1                          like(IPCHR)
     d  prmIPCHR2                          like(IPCHR)
     d  prmIPCHR3                          like(IPCHR)
     d  prmIPCHR4                          like(IPCHR)

       // local fields

      /free
         prmIPCHR1 = %char(prmIPSEG1);
         if prmIPSEG2 > *zeros;
           prmIPCHR2 = %char(prmIPSEG2);
         else;
           prmIPCHR2 = ' * ';
         endif;
         if prmIPSEG3 > *zeros;
           prmIPCHR3 = %char(prmIPSEG3);
         else;
           prmIPCHR3 = ' * ';
         endif;
         if prmIPSEG4 > *zeros;
           prmIPCHR4 = %char(prmIPSEG4);
         else;
           prmIPCHR4 = ' * ';
         endif;
      /end-free
     p setIPSEG        e

       //**************************************************************
       //  Subprocedure: cvtIPSEG
       //  Purpose:      convert IP character display to numeric IP address
       //  Parms:        prmIPSEG1    = numeric IP first segment
       //                prmIPSEG2    = numeric IP second segment
       //                prmIPSEG3    = numeric IP third segment
       //                prmIPSEG4    = numeric IP fourth segment
       //                prmIPCHR1    = char IP first segment
       //                prmIPCHR2    = char IP second segment
       //                prmIPCHR3    = char IP third segment
       //                prmIPCHR4    = char IP fourth segment
       //  Returns:      none
       //**************************************************************
       //
     p cvtIPSEG        b                   export
     d cvtIPSEG        pi
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)
     d  prmIPCHR1                          like(IPCHR)
     d  prmIPCHR2                          like(IPCHR)
     d  prmIPCHR3                          like(IPCHR)
     d  prmIPCHR4                          like(IPCHR)

       // local fields

      /free
         prmIPSEG1 = %dec(prmIPCHR1: IPlen: IPdec);
         if prmIPCHR2 = ' * ';
           prmIPSEG2 = *zeros;
         else;
           prmIPSEG2 = %dec(prmIPCHR2: IPlen: IPdec);
         endif;
         if prmIPCHR3 = ' * ';
           prmIPSEG3 = *zeros;
         else;
           prmIPSEG3 = %dec(prmIPCHR3: IPlen: IPdec);
         endif;
         if prmIPCHR4 = ' * ';
           prmIPSEG4 = *zeros;
         else;
           prmIPSEG4 = %dec(prmIPCHR4: IPlen: IPdec);
         endif;
      /end-free
     p cvtIPSEG        e

       //**************************************************************
       //  Subprocedure: chkIPBlocked
       //  Purpose:      check if IP address blocked
       //                IPSEG of 0 = all
       //  Parms:        prmSite      = website
       //                prmIPSEG1    = numeric IP first segment
       //                prmIPSEG2    = numeric IP second segment
       //                prmIPSEG3    = numeric IP third segment
       //                prmIPSEG4    = numeric IP fourth segment
       //  Returns:      isblocked    = *on if blocked
       //**************************************************************
       //
     p chkIPBlocked    b                   export
     d chkIPBlocked    pi              n
     d  prmSite                            like(SITE)
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)

       // local fields
     d isblocked       s                   like(boolean)

      /free
         isblocked = *off;

         setll (prmSite
               :prmIPSEG1
               :IPZERO
               :IPZERO
               :IPZERO)
               WEBBLOCKL1;

         reade (prmSite) WEBBLOCKL1;
         if %eof(WEBBLOCKL1);
           return isblocked;
         endif;

         if blkl1_IPSEG1 <> prmIPSEG1;
           return isblocked;
         endif;

         if blkl1_IPSEG2 = *zeros
           or prmIPSEG2 = *zeros;
           isblocked = *on;
           return isblocked;
         endif;

         setll (prmSite
               :prmIPSEG1
               :prmIPSEG2
               :IPZERO
               :IPZERO)
               WEBBLOCKL1;

         reade (prmSite) WEBBLOCKL1;
         if %eof(WEBBLOCKL1);
           return isblocked;
         endif;

         if blkl1_IPSEG2 <> prmIPSEG2;
           return isblocked;
         endif;

         if blkl1_IPSEG3 = *zeros
           or prmIPSEG3 = *zeros;
           isblocked = *on;
           return isblocked;
         endif;

         setll (prmSite
               :prmIPSEG1
               :prmIPSEG2
               :prmIPSEG3
               :IPZERO)
               WEBBLOCKL1;

         reade (prmSite) WEBBLOCKL1;
         if %eof(WEBBLOCKL1);
           return isblocked;
         endif;

         if blkl1_IPSEG3 <> prmIPSEG3;
           return isblocked;
         endif;

         if blkl1_IPSEG4 = *zeros
           or prmIPSEG4 = *zeros;
           isblocked = *on;
           return isblocked;
         endif;

         setll (prmSite
               :prmIPSEG1
               :prmIPSEG2
               :prmIPSEG3
               :prmIPSEG4)
               WEBBLOCKL1;

         reade (prmSite) WEBBLOCKL1;
         if %eof(WEBBLOCKL1);
           return isblocked;
         endif;

         if blkl1_IPSEG4 <> prmIPSEG4;
           return isblocked;
         endif;

         isblocked = *on;
         return isblocked;

      /end-free
     p chkIPBlocked    e

       //**************************************************************
       //  Subprocedure: chkIPVisited
       //  Purpose:      check if visitor is in IP address range
       //                IPSEG of 0 = all
       //  Parms:        prmSite      = website
       //                prmIPSEG1    = numeric IP first segment
       //                prmIPSEG2    = numeric IP second segment
       //                prmIPSEG3    = numeric IP third segment
       //                prmIPSEG4    = numeric IP fourth segment
       //  Returns:      isvisitor    = *on if in range
       //**************************************************************
       //
     p chkIPVisited    b                   export
     d chkIPVisited    pi              n
     d  prmSite                            like(SITE)
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)

       // local fields
     d isvisitor       s                   like(boolean)

      /free
         isvisitor = *off;

         setll (prmSite
               :prmIPSEG1
               :IPZERO
               :IPZERO
               :IPZERO)
               WEBVISITL1;

         reade (prmSite) WEBVISITL1;
         if %eof(WEBVISITL1);
           return isvisitor;
         endif;

         if vstl1_IPSEG1 <> prmIPSEG1;
           return isvisitor;
         endif;

         if prmIPSEG2 = *zeros
           or vstl1_IPSEG2 = *zeros;
           isvisitor = *on;
           return isvisitor;
         endif;

         setll (prmSite
               :prmIPSEG1
               :prmIPSEG2
               :IPZERO
               :IPZERO)
               WEBVISITL1;

         reade (prmSite) WEBVISITL1;
         if %eof(WEBVISITL1);
           return isvisitor;
         endif;

         if vstl1_IPSEG2 <> prmIPSEG2;
           return isvisitor;
         endif;

         if prmIPSEG3 = *zeros
           or vstl1_IPSEG3 = *zeros;
           isvisitor = *on;
           return isvisitor;
         endif;

         setll (prmSite
               :prmIPSEG1
               :prmIPSEG2
               :prmIPSEG3
               :IPZERO)
               WEBVISITL1;

         reade (prmSite) WEBVISITL1;
         if %eof(WEBVISITL1);
           return isvisitor;
         endif;

         if vstl1_IPSEG3 <> prmIPSEG3;
           return isvisitor;
         endif;

         if prmIPSEG4 = *zeros
           or vstl1_IPSEG4 = *zeros;
           isvisitor = *on;
           return isvisitor;
         endif;

         setll (prmSite
               :prmIPSEG1
               :prmIPSEG2
               :prmIPSEG3
               :prmIPSEG4)
               WEBVISITL1;

         reade (prmSite) WEBVISITL1;
         if %eof(WEBVISITL1);
           return isvisitor;
         endif;

         if vstl1_IPSEG4 <> prmIPSEG4;
           return isvisitor;
         endif;

         isvisitor = *on;
         return isvisitor;

      /end-free
     p chkIPVisited    e

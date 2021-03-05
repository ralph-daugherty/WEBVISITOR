      *****************************************************************
      *               Web IP Records File Maintenance Check
      *
      *  Program WEBVISITRE
      *****************************************************************
     h  dftactgrp(*no) actgrp('RDWRITES') bnddir('RDWRITES')
     h  debug option(*srcstmt:*nodebugio)

      *****************************************************************
      *Entry Declaration
      *****************************************************************
     d WEBVISITRE      pr
     d  prmWarnid                          like(msgid)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(SITE)
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)

     d WEBVISITRE      pi
     d  prmWarnid                          like(msgid)
     d  prmFile                            like(pgmnam)
     d  prmSite                            like(SITE)
     d  prmIPSEG1                          like(IPSEG)
     d  prmIPSEG2                          like(IPSEG)
     d  prmIPSEG3                          like(IPSEG)
     d  prmIPSEG4                          like(IPSEG)

      *****************************************************************
      * Prototype Definitions
      *****************************************************************
      /copy RDWSRC,WEBVISITPR

      *****************************************************************
      * Mainline
      *****************************************************************
      /free
         select;
           when prmFile = 'WEBVISITOR';
             if chkIPBlocked(prmSite
                            :prmIPSEG1
                            :prmIPSEG2
                            :prmIPSEG3
                            :prmIPSEG4);
              // 'Warning: Visitor is blocked'
               prmWarnid = 'RDW0013';
             endif;

           when prmFile = 'WEBBLOCKER';
             if chkIPVisited(prmSite
                            :prmIPSEG1
                            :prmIPSEG2
                            :prmIPSEG3
                            :prmIPSEG4);
              // 'Warning: Visitor will be blocked'
               prmWarnid = 'RDW0014';
             endif;
         endsl;

        // Exit program
         exsr exitProgram;

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

           prmWarnid = *blanks;

         endsr;

      /end-free


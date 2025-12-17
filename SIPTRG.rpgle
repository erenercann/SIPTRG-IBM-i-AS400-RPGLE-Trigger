     H DFTACTGRP(*NO) ACTGRP(*CALLER) OPTION(*SRCSTMT : *NODEBUGIO)                   
     FSIPARISLOGUF A E           K DISK                                      
     D  SIPTRG         PR                  ExtPgm('SIPTRG')                  
     D  pBuffer                   32767A   OPTIONS(*VARSIZE)                 
     D  pBufferLen                   10I 0                                   
     D  SIPTRG         PI                                                    
     D  pBuffer                   32767A   OPTIONS(*VARSIZE)                 
     D  pBufferLen                   10I 0                                   
                                                                             
      * Trigger Buffer Yapisi (IBM Standart Yapi)                            
      
     D TrgBuffer       DS         32767                                      
     D  TrgFileName            1     10                                      
     D  TrgLibName            11     20                                      
     D  TrgMbrName            21     30                                      
     D  TrgEvent              31     31                                      
     D  TrgTime               32     32                                      
     D  TrgCmtLck             33     33                                      
     D  TrgFill1              34     36                                      
     D  TrgCCSID              37     40I 0                   
     D  TrgRrn                41     44I 0                   
     D  TrgFill2              45     48I 0                   
     D  TrgOldOff             49     52I 0                   
     D  TrgOldLen             53     56I 0                   
     D  TrgNewOff             65     68I 0                   
     D  TrgNewLen             69     72I 0                   
     D BeforeRec     E DS                  EXTNAME(SIPARIS)  
     D                                     BASED(PtrBefore)  
     D                                     QUALIFIED         
     D AfterRec      E DS                  EXTNAME(SIPARIS)  
     D                                     BASED(PtrAfter)   
     D                                     QUALIFIED         
                                                            
     D PtrBefore       S               *                     
     D PtrAfter        S               *                     
     D PgmStatus      SDS                                    
     D  CurrentUser          254    263                      
     D MaxLogID        S                   LIKE(LOGID)       
     D IslemTipi       S             10A                     
  
     /FREE                                                   
                                                            
     TrgBuffer = %Subst(pBuffer:1:pBufferLen);              
     PtrBefore = %Addr(pBuffer) + TrgOldOff;                
     PtrAfter  = %Addr(pBuffer) + TrgNewOff;                
                                                            
     Select;                                                
            When TrgEvent = '1';                             
            IslemTipi = 'INSERT';                          
            When TrgEvent = '2';                             
            IslemTipi = 'DELETE';                          
            When TrgEvent = '3';                             
            IslemTipi = 'UPDATE';                          
            Other;                                           
            IslemTipi = 'UNKNOWN';                         
     EndSl;                                                 
                                                            
     Setgt *Hival SIPARISLOG;                               
     Readp SIPARISLOG;                                      
      If %Eof(SIPARISLOG);                          
        MaxLogID = 1;                           
      Else;                                     
        MaxLogID = LOGID + 1;                         
      EndIf;                                    
                                                
      Clear LOGR;                                   
                                                
            LOGID     = MaxLogID;                     
            ISLEMTIP  = IslemTipi;                    
            ISLEMTAR  = %Date();                      
            ISLEMSAAT = %Time();                      
            KULLANICI = CurrentUser;                  
      If TrgEvent = '2';                           
            SIPNO  = BeforeRec.SIPNO;              
            MUSTNO = BeforeRec.MUSTNO;             
            TARIH  = BeforeRec.TARIH;              
            TUTAR  = BeforeRec.TUTAR;              
                                                
      Else;                                        
            SIPNO  = AfterRec.SIPNO;                
            MUSTNO = AfterRec.MUSTNO;               
            TARIH  = AfterRec.TARIH;                
            TUTAR  = AfterRec.TUTAR;                
      EndIf;                                  
                                                    
      Write LOGR;                               
                                                    
        *InLr = *On;                           
        Return;                                
                                                    
     /END-FREE                                       
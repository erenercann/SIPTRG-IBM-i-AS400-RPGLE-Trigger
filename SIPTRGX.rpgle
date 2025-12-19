     H DFTACTGRP(*NO) ACTGRP(*CALLER) OPTION(*SRCSTMT : *NODEBUGIO) 
      * Dosya Tanimlari                                             
     FSIPARISLOGUF A E           K DISK                             
                                                                
      * Veri Tanimlari (Data Specifications)                        
     D pBuffer         S          32767A                            
     D pBufferLen      S             10I 0                          
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
      * Before ve After Kayit Görüntüleri (Pointer ile)        
     D BeforeRec     E DS                  EXTNAME(SIPARIS)    
     D                                     BASED(PtrBefore)    
     D                                     QUALIFIED           
     D AfterRec      E DS                  EXTNAME(SIPARIS)    
     D                                     BASED(PtrAfter)     
     D                                     QUALIFIED           
                                                            
     D PtrBefore       S               *                       
     D PtrAfter        S               *                       
      * Program Durum Veri Yapisi (Kullaniciyi almak için)     
     D PgmStatus      SDS                                      
     D  CurrentUser          254    263                        
                                                            
     D MaxLogID        S                   LIKE(LOGID)         
     D IslemTipi       S             10A                       
      * ----------------------------------------------------------------   
      * Ana Islem Baslangici                                               
      * ----------------------------------------------------------------   
     C     *ENTRY        PLIST                                             
     C                   PARM                    pBuffer                   
     C                   PARM                    pBufferLen                
      * Gelen parametreyi Data Structure'a tasi                            
     C                   EVAL      TrgBuffer = %SUBST(pBuffer:1:pBufferLen)
                                                                        
      * Pointer Adreslerini Hesapla (Offsetleri kullanarak)                
     C                   EVAL      PtrBefore = %ADDR(pBuffer) + TrgOldOff  
     C                   EVAL      PtrAfter  = %ADDR(pBuffer) + TrgNewOff  
      * Islem Tipini Belirle (Select - When Yapisi)                        
     C                   SELECT                                            
     C                   WHEN      TrgEvent = '1'                          
     C                   EVAL      IslemTipi = 'INSERT'                    
     C                   WHEN      TrgEvent = '2'                          
     C                   EVAL      IslemTipi = 'DELETE'                    
     C                   WHEN      TrgEvent = '3'                          
     C                   EVAL      IslemTipi = 'UPDATE'                    
     C                   OTHER                                               
     C                   EVAL      IslemTipi = 'UNKNOWN'                     
     C                   ENDSL                                               
      * Son Log ID'yi bul ve 1 artir                                         
     C     *HIVAL        SETGT     SIPARISLOG                                
     C                   READP     SIPARISLOG                             99 
                                                                            
      * Eger dosya bossa (EOF) ID 1 olsun, degilse son ID + 1                
     C                   IF        *IN99 = *ON                               
     C                   EVAL      MaxLogID = 1                              
     C                   ELSE                                                
     C                   EVAL      MaxLogID = LOGID + 1                      
     C                   ENDIF                                               
      * Log Alanlarini Doldur                                                
     C                   CLEAR                   LOGR                        
     C                   EVAL      LOGID     = MaxLogID                      
     C                   EVAL      ISLEMTIP  = IslemTipi                     
     C                   EVAL      ISLEMTAR  = %DATE()                       
     C                   EVAL      ISLEMSAAT = %TIME()                       
     C                   EVAL      KULLANICI = CurrentUser                   
      * Silme ise Eski kaydi, Ekleme/Güncelleme ise Yeni kaydi al           
     C                   IF        TrgEvent = '2'                           
     C                   EVAL      SIPNO  = BeforeRec.SIPNO                 
     C                   EVAL      MUSTNO = BeforeRec.MUSTNO                
     C                   EVAL      TARIH  = BeforeRec.TARIH                 
     C                   EVAL      TUTAR  = BeforeRec.TUTAR                 
     C                   ELSE                                               
     C                   EVAL      SIPNO  = AfterRec.SIPNO                  
     C                   EVAL      MUSTNO = AfterRec.MUSTNO                 
     C                   EVAL      TARIH  = AfterRec.TARIH                  
     C                   EVAL      TUTAR  = AfterRec.TUTAR                  
     C                   ENDIF                                              
                                                                        
      * Kaydi Yaz ve Çik                                                    
     C                   WRITE     LOGR                                     
     C                   SETON                                        LR        
     C                   RETURN                                                                                                                         
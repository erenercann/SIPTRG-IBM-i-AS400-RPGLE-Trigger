# SIPTRG-IBM-i-AS400-RPGLE-Trigger
Bu proje, IBM i DB2 veritabanı üzerinde çalışan, RPGLE (Free-Format) ile yazılmış bir tetikleyici (trigger) programıdır.


IBM i (AS400) DB2 Sipariş Loglama Trigger Uygulaması
Merhaba, bu projede IBM i (AS400) sistemlerinde veri bütünlüğünü sağlamak ve yapılan işlemleri kayıt altına almak (audit trail) amacıyla geliştirdiğim bir Trigger (Tetikleyici) uygulamasını paylaşıyorum.
Bu uygulama, ana sipariş dosyasında (SIPARIS) bir kayıt eklendiğinde, güncellendiğinde veya silindiğinde otomatik olarak devreye girer ve işlemin detaylarını, işlemi yapan kullanıcıyı ve zaman bilgilerini log dosyasına (SIPARISLOG) kaydeder.

🛠 Teknik Detaylar
Proje tamamen RPGLE Free Format kullanılarak yazılmıştır ve IBM'in standart Trigger Buffer yapısını kullanır.
Dosya Yapısı
SIPARIS (PF): Ana veri tablosudur. Sipariş no, müşteri no, tarih ve tutar bilgilerini tutar.
SIPARISLOG (PF): Log tablosudur. Yapılan işlemin türünü (Insert/Update/Delete), zamanını, işlemi yapan kullanıcıyı ve verinin o anki halini saklar.
SIPTRG (RPGLE): Veritabanı tetikleyici programıdır.

Programın İşleyişi (SIPTRG)
Program, veritabanı seviyesinde bir işlem gerçekleştiğinde işletim sistemi tarafından otomatik olarak çağrılır. İşleyiş mantığı şu şekildedir:

1-Buffer Okuma: Program giriş parametresi olarak işletim sisteminden gelen pBuffer (tetikleyici tampon belleği) verisini alır.
2-Pointer Yönetimi: TrgOldOff ve TrgNewOff ofsetlerini kullanarak, kaydın işlemden önceki (BeforeRec) ve işlemden sonraki (AfterRec) hallerine pointer'lar aracılığıyla erişim sağlar. Bu sayede bellek yönetimi optimize edilir.
3-İşlem Tipi Belirleme: TrgEvent alanı kontrol edilerek işlemin türü belirlenir:
    1: Ekleme (INSERT)
    2: Silme (DELETE)
    3: Güncelleme (UPDATE)
4-Log ID Oluşturma: SIPARISLOG dosyasındaki son kayıt okunur (Setgt *Hival) ve sıralı bir LOGID üretilir.
5- Veri Eşleme:
    * Eğer işlem Silme (Delete) ise, kaydın silinmeden önceki hali (BeforeRec) loglanır.
    * Eğer işlem Ekleme veya Güncelleme ise, kaydın yeni hali (AfterRec) loglanır.
6-Kayıt: İşlemi yapan CurrentUser (Kullanıcı), tarih, saat ve veri detayları log dosyasına yazılır.

🚀 Kurulum ve Derleme
Bu projeyi kendi sisteminizde çalıştırmak için aşağıdaki adımları izleyebilirsiniz.
1. Dosyaların Oluşturulması (Physical Files)
Önce DDS kaynak kodlarını kullanarak fiziksel dosyaları derleyin:

CRTPF FILE(KUTUPHANENIZ/SIPARIS) SRCFILE(KUTUPHANENIZ/QDDSSRC)
CRTPF FILE(KUTUPHANENIZ/SIPARISLOG) SRCFILE(KUTUPHANENIZ/QDDSSRC)

2. Programın Derlenmesi (RPGLE)
Trigger programını derleyin:

CRTBNDRPG PGM(KUTUPHANENIZ/SIPTRG) SRCFILE(KUTUPHANENIZ/QRPGLESRC) DFTACTGRP(*NO) ACTGRP(*CALLER)

3. Trigger'ın Eklenmesi (Önemli Adım)
Program derlendikten sonra, bu programı SIPARIS dosyasına bir tetikleyici olarak tanımlamamız gerekir. Bunu ADDPFTRG komutu ile yapıyoruz. Bu komut, dosyaya yapılan Ekleme, Silme ve Güncelleme işlemlerinden *SONRA (AFTER) programımızın çalışmasını sağlar.

ADDPFTRG FILE(KUTUPHANENIZ/SIPARIS) +
         TRGTIME(*AFTER) +
         TRGEVENT(*INSERT *DELETE *UPDATE) +
         PGM(KUTUPHANENIZ/SIPTRG) +
         TRG(SIP_LOG_TRG) +
         RPLTRG(*YES)


Bu işlemden sonra SIPARIS dosyasına DFU, SQL veya başka bir program aracılığıyla veri girdiğinizde, SIPARISLOG dosyasına otomatik olarak kayıt atıldığını göreceksiniz.

----------------------------------------------------------------------------------------------

IBM i (AS400) DB2 Order Logging Trigger Application
Hi there, in this repository I am sharing a Trigger application I developed for IBM i (AS400) systems to ensure data integrity and create an audit trail for database transactions.
This application automatically activates whenever a record is inserted, updated, or deleted in the main order file (SIPARIS). It logs the transaction details, the user who performed the action, and timestamps into a log file (SIPARISLOG).

🛠 Technical Details
The project is written entirely in RPGLE Free Format and utilizes the standard IBM Trigger Buffer structure.

File Structure
    * SIPARIS (PF): The main data table. Contains Order No, Customer No, Date, and Amount.
    * SIPARISLOG (PF): The log table. Stores the operation type (Insert/Update/Delete), timestamp, user information, and snapshot of the data.
    * SIPTRG (RPGLE): The database trigger program.

How It Works (SIPTRG)
The program is automatically invoked by the OS when a database event occurs. The logic flow is as follows:

1-Buffer Parsing: The program accepts the pBuffer (trigger buffer) from the OS as an entry parameter.
2-Pointer Management: Using TrgOldOff and TrgNewOff offsets, it maps pointers to the "Before Image" (BeforeRec) and "After Image" (AfterRec) of the record. This ensures efficient memory handling.
3-Event Detection: It checks the TrgEvent field to determine the operation type:
    1: INSERT
    2: DELETE
    3: UPDATE
4-Log ID Generation: It reads the last record in SIPARISLOG (Setgt *Hival) to generate a sequential LOGID.
5-Data Mapping:
    * If the event is DELETE, it logs the data as it was before deletion (BeforeRec).
    * If the event is INSERT or UPDATE, it logs the new state of the data (AfterRec).
6-Writing Log: The CurrentUser, date, time, and record details are written to the log file.

🚀 Installation and Compilation
Follow these steps to deploy this project on your system.
1. Creating Physical Files
Compile the physical files using the DDS source codes:

CRTPF FILE(YOURLIB/SIPARIS) SRCFILE(YOURLIB/QDDSSRC)
CRTPF FILE(YOURLIB/SIPARISLOG) SRCFILE(YOURLIB/QDDSSRC)

2. Compiling the Program (RPGLE)
Compile the trigger program:

CRTBNDRPG PGM(YOURLIB/SIPTRG) SRCFILE(YOURLIB/QRPGLESRC) DFTACTGRP(*NO) ACTGRP(*CALLER)

3. Adding the Trigger (Crucial Step)
After compiling the program, you must attach it to the SIPARIS file as a trigger. We use the ADDPFTRG command for this. This command configures the program to run AFTER any Insert, Delete, or Update operation.

ADDPFTRG FILE(YOURLIB/SIPARIS) +
         TRGTIME(*AFTER) +
         TRGEVENT(*INSERT *DELETE *UPDATE) +
         PGM(YOURLIB/SIPTRG) +
         TRG(SIP_LOG_TRG) +
         RPLTRG(*YES)


Once this is done, any data manipulation on the SIPARIS file (via DFU, SQL, or another program) will automatically generate a corresponding audit record in SIPARISLOG.


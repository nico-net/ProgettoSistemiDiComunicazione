# Prova Finale SDC a.a. 2024-25
Progetto di Sistemi di Comunicazione dell'Anno Accademico 2024-2025, relativo a:
- simulazione e test OTA con SDR 'Adalm-Pluto' di un sistema OFDM con diverse codifiche di canale
- sviluppo di un sistema AMC (adaptive modulation and coding) con l'ausilio di un algoritmo di ML (machine learning) atto a classificare lo stato della     
  comunicazione.
  
Gli autori del progetto sono:
- Nicola Gallucci - nicola.gallucci@mail.polimi.it
- Matteo Malagrinò - matteo.malagrino@mail.polimi.it

## Indice
- [Introduzione](#introduzione)
- [Sistema OFDM](#sistema-ofdm)
  - [Introduzione agli esperimenti](introduzione-agli-esperimenti)
  - [Parametri di trasmissione](#parametri-di-trasmissione)
  - [Scenari considerati](#scenari-considerati)
  - [Risultati delle simulazioni](#risultati-delle-simulazioni)
  - [Risultati dei test OTA](risultati-dei-test-ota)
  - [Codice Matlab](codice-matlab-ofdm)
- [Sistema AMC](#amc)
  - [Introduzione al sistema](#introduzione-al-sistema)
  - [Descrizione del classificatore](#descrizione-del-classificatore)
    - [Generazione dei dati di training](#generazione-dei-dati-di-training)
    - [Training e accuracy del modello](#training-e-accuracy-del-modello)
  - [Test OTA](#test-ota)
  - [Codice Matlab](#codice-matlab-amc)   
- [Conclusioni](#conclusioni)

# Introduzione

La crescente diffusione delle reti di comunicazione wireless avanzate richiede sistemi sempre più efficienti e adattabili alle condizioni variabili del canale. Questa tesi si concentra sulla simulazione e la validazione **Over-The-Air (OTA)** di un sistema di comunicazione basato su **OFDM (Orthogonal Frequency Division Multiplexing)** utilizzando **SDR (Software-Defined Radio) Adalm-Pluto**. L’obiettivo principale è implementare e testare un sistema di **Adaptive Modulation and Coding (AMC)** che ottimizza la trasmissione in base alle condizioni del canale.

In una prima fase, vengono effettuati test su un sistema **OFDM base**, sia in assenza che in presenza di **codifica di canale**, valutando le prestazioni attraverso simulazioni e test **OTA**. Successivamente, per classificare lo stato della comunicazione e adattare dinamicamente i parametri di modulazione e codifica, viene sviluppato un modello di **Machine Learning (ML)**. Tale modello analizza parametri chiave come **SNR stimato, BER e risposta all’impulso del canale**, permettendo di selezionare la configurazione ottimale per massimizzare l'affidabilità e l’efficienza spettrale del sistema.

La validazione sperimentale avviene tramite test **OTA (Over The Air)** in ambienti controllati, valutando le prestazioni del sistema in presenza di **interferenze, fading e effetto Doppler**, tipici di scenari dinamici. I risultati ottenuti dimostrano l'efficacia dell'approccio proposto, evidenziando il ruolo cruciale dell'**intelligenza artificiale** nell’ottimizzazione adattiva delle comunicazioni wireless.


# AMC

## Introduzione al sistema

La crescente esigenza di sistemi di comunicazione wireless ad alte prestazioni ha portato allo sviluppo di tecniche avanzate come l'**Adaptive Modulation and Coding (AMC)**. L'AMC è una strategia che consente di ottimizzare la trasmissione dei dati in funzione delle condizioni variabili del canale di comunicazione, migliorando così l'efficienza spettrale e la robustezza del sistema. In questa sezione, esploreremo i fondamenti teorici dell'AMC, il ruolo cruciale di un **classifier** basato su algoritmi di **Machine Learning (ML)**, e i risultati ottenuti attraverso l'implementazione pratica con le schede SDR **Adalm-Pluto**.

L'AMC si basa sulla selezione dinamica di diverse configurazioni di modulazione e codifica per adattarsi in tempo reale alle condizioni del canale, come la **SNR (Signal-to-Noise Ratio)** e il **BER (Bit Error Rate)**. A seconda della qualità del canale, vengono utilizzati schemi di modulazione ad alta efficienza, come **QAM (Quadrature Amplitude Modulation)** e **PSK (Phase Shift Keying)**, insieme a diversi tassi di codifica per ottimizzare l'affidabilità e la velocità di trasmissione.

Un aspetto fondamentale nell'implementazione dell'AMC è la capacità di monitorare e classificare lo stato del canale in tempo reale. Per questo motivo, in questo lavoro, è stato scelto di utilizzare un **Support Vector Machine (SVM)**, un algoritmo di **Machine Learning** che permette di classificare efficacemente il canale in base ai parametri osservati, come la **SNR** e il **BER**. L'SVM è un metodo di apprendimento supervisionato particolarmente adatto a scenari con elevata dimensionalità, come quelli che caratterizzano i sistemi di comunicazione.

Successivamente, verrà illustrato l'algoritmo scelto per la trasmissione dei dati, che combina la modulazione adattativa con la codifica di canale, e come l'SVM viene integrato per ottimizzare dinamicamente la configurazione di modulazione e codifica. Infine, presenteremo i risultati degli esperimenti condotti utilizzando le schede **Adalm-Pluto**, che hanno permesso di testare l'implementazione dell'AMC in scenari reali di comunicazione, valutando le prestazioni del sistema in presenza di interferenze, fading e altre condizioni dinamiche del canale.

I risultati ottenuti dimostrano l'efficacia dell'approccio proposto, evidenziando come l'uso combinato dell'AMC e dell'apprendimento automatico possa migliorare significativamente le prestazioni dei sistemi di comunicazione wireless in ambienti complessi e variabili.

## Descrizione del classificatore
Il classificatore SVM utilizza un insieme di caratteristiche estratte dal segnale ricevuto per determinare lo stato della comunicazione. In particolare, gli ingressi del modello includono:

- **SNR stimato**: Indice del rapporto segnale-rumore.
- **BER (Bit Error Rate)**: Indicatore della qualità della decodifica.

L'uscita del classificatore è un punteggio discreto compreso tra 0 e 2, che rappresenta lo stato della comunicazione e determina la configurazione ottimale di modulazione e codifica.

Di seguito sono riportati i parametri associati ai vari casi di classificazione della comunicazione (modulazione - code rate):

- **0 - Comunicazione Pessima**: QPSK, 1/2
- **1 - Comunicazione Discreta**: 16-QAM, 2/3
- **2 - Comunicazione Ottima**: 64-QAM, 3/4

  
### Generazione dei dati di training
Per addestrare il modello SVM, è stata utilizzata una simulazione del sistema OFDM in cui sono stati variati in modo casuale diversi parametri:

- **SNR ricevuto**: da 0 a 25 dB.
- **Modulazione**: BPSK, QPSK, 16-QAM, 64-QAM.
- **Code rate**: 1/2, 2/3, 3/4.
- **Velocità del ricevitore**: da 0 a 3 km/h.
- **CFO (Carrier Frequency Offset)**: da 0 a 3 ppm.

I risultati ottenuti dalla simulazione sono stati salvati in un file CSV e etichettati per la classificazione in tre classi:

- **Classe 2**: se SNR ≥ 18 dB e BER < 10⁻².
- **Classe 1**: se 8 < SNR < 18 dB e 10⁻² ≤ BER < 8 × 10⁻², oppure se SNR ≥ 18 dB e BER > 10⁻².
- **Classe 0**: in tutti gli altri casi.

Il dataset finale contiene circa 13.000 campioni, suddivisi in training e test set per ottimizzare le prestazioni del modello SVM.

### Training e accuracy del modello
Il modello SVM è stato addestrato utilizzando un kernel **RBF** con parametri ottimizzati tramite *Grid Search*. Le metriche di valutazione del modello includono:

<p align="center">
  <img src="img/classreport.png" width="300">
</p>

Di seguito viene riportata la matrice di confusione del modello:

<p align="center">
  <img src="img/confmat.png" width="400">
</p>

## Test OTA

Il classificatore è stato integrato nel ricevitore OFDM, il quale, dopo aver stimato i parametri del canale, utilizza il modello SVM per determinare lo stato della comunicazione. In base alla decisione del classificatore, il trasmettitore adatta la modulazione e il code rate, garantendo un equilibrio tra efficienza spettrale e robustezza della trasmissione. Nel seguito saranno analizzati i risultati ottenuti dall’esperimento del sistema AMC attuato con l’ausilio di due SDR "Adalm-Pluto" che fungono da trasmettitore e ricevitore.
Si consideri il trasmettitore come Dispositivo 1 e il ricevitore, con il classificatore SVM, come Dispositivo 2.
I risultati sperimentali mostrano che l’implementazione dell’AMC basato su SVM migliora significativamente le prestazioni del sistema in scenari con variazioni rapide delle condizioni del canale. La comunicazione comincia sempre utilizzando una 64-QAM con un tasso di codifica di 3/4 per aumentare l’efficienza di trasmissione. Tuttavia, come si può osservare dai grafici, nel caso dell’esperimento la trasmissione appariva molto disturbata e le performance di trasmissione erano pessime (BER molto elevato).

<p align="center">
  <img src="img/results1step.png" width="300">
  <img src="img/results2step.png" width="300">
</p>
<p align = "center">
Fig.1-2 - Risultati rispettivamente della prima e seconda ricezione
</p>


Il classificatore ha restituito 0 (comunicazione pessima), quindi il messaggio di feedback inviato sarà 0000. PEr l’invio del feedback si scelgono code rate e modulazioni robuste quali BPSK e 1/2. Il trasmettitore, una volta ricevuto il feedback, cambia i propri parametri di trasmissione. Nelle figure sottostanti è possibile osservare le modulazioni ricevute nei due casi.

<p align="center">
  <img src="img/costellazione64qam.png" width="300">
  <img src="img/costellazioneqpsk.png" width="300">
</p>
<p align = "center">
Fig.3-4 - Costellazioni ricevute rispettivamente alla prima e seconda trasmissione
</p>

Il risultato della trasmissione è indicato nella figura 2. Il trasmettitore quindi sceglie la coppia 16-QAM 2/3 come nuovi parametri di trasmissione. In figura 5 è possibile osservare l’andamento dei parametri di trasmissione di Dispositivo 1 ai vari step di trasmissione.

<p align="center">
  <img src="img/paramAMC.png" width="400">
</p>
<p align = "center">
Fig.5 - Code Rate e Modulation order nel tempo
</p>

# Conclusioni

Il lavoro svolto in questa tesi ha dimostrato l'efficacia di un sistema di comunicazione basato su **OFDM** con **Adaptive Modulation and Coding (AMC)**, ottimizzato tramite tecniche di **Machine Learning** e validato in condizioni reali tramite test **Over-The-Air (OTA)** con **SDR Adalm-Pluto**. L'integrazione di un modello ML per la classificazione dello stato del canale ha permesso di adattare dinamicamente i parametri di trasmissione, migliorando l'affidabilità e l'efficienza spettrale del sistema.

Prima di implementare il sistema AMC, sono stati condotti test approfonditi sul sistema **OFDM base**, sia in simulazione che in ambiente reale tramite prove OTA, valutando le prestazioni in assenza e in presenza di codifica di canale. I risultati hanno evidenziato come la **codifica di canale** migliori significativamente la resilienza alle interferenze e alle degradazioni del canale, riducendo il **BER (Bit Error Rate)** rispetto alla configurazione senza codifica. Tuttavia, senza un meccanismo adattivo, il sistema non è in grado di rispondere dinamicamente alle variazioni delle condizioni di propagazione, portando a inefficienze o degrado delle prestazioni in scenari complessi.

I risultati sperimentali hanno confermato che l'uso di **tecniche adattive** consente di mitigare gli effetti delle variazioni del canale, come interferenze, fading e effetto Doppler, rendendo il sistema più robusto rispetto a una configurazione statica. In particolare, la capacità del modello di apprendere le condizioni del canale e selezionare la modulazione e il code rate più appropriati rappresenta un passo avanti verso l'ottimizzazione autonoma delle reti wireless.

Questa ricerca apre la strada a future applicazioni in scenari reali, come **le reti 5G**, dove l'adattabilità del sistema alle condizioni variabili del canale è fondamentale. Ulteriori sviluppi potrebbero includere l'integrazione con tecniche avanzate di **Deep Learning** e l'estensione del sistema a scenari multi-utente e multi-antenna (**MIMO**), migliorando ulteriormente la capacità di adattamento alle dinamiche del canale.

  


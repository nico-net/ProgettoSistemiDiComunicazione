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
  - [Introduzione al sistema](Introduzione-al-sistema)
  - [Descrizione del classificatore](descrizione-del-classificatore)
    - [Generazione dei dati di training](dati-di-training)
    - [Training e accuracy del modello](training-e-accuracy-del-modello)
  - [Test OTA](test-ota)
  - [Codice Matlab](codice-matlab-amc)   
- [Conclusioni](#conclusioni)


# AMC

## Introduzione al sistema
La crescente esigenza di sistemi di comunicazione wireless ad alte prestazioni ha portato allo sviluppo di tecniche avanzate come l'**Adaptive Modulation and Coding (AMC)**. L'AMC è una strategia che consente di ottimizzare la trasmissione dei dati in funzione delle condizioni variabili del canale di comunicazione, migliorando così l'efficienza spettrale e la robustezza del sistema. In questa sezione, esploreremo i fondamenti teorici dell'AMC, il ruolo cruciale di un **classifier** basato su algoritmi di **Machine Learning (ML)**, e i risultati ottenuti attraverso l'implementazione pratica con le schede SDR **Adalm-Pluto**.

L'AMC si basa sulla selezione dinamica di diverse configurazioni di modulazione e codifica per adattarsi in tempo reale alle condizioni del canale, come la **SNR (Signal-to-Noise Ratio)** e il **BER (Bit Error Rate)**. A seconda della qualità del canale, vengono utilizzati schemi di modulazione ad alta efficienza, come **QAM (Quadrature Amplitude Modulation)** e **PSK (Phase Shift Keying)**, insieme a diversi tassi di codifica per ottimizzare l'affidabilità e la velocità di trasmissione.

Un aspetto fondamentale nell'implementazione dell'AMC è la capacità di monitorare e classificare lo stato del canale in tempo reale. Per questo motivo, in questo lavoro, è stato scelto di utilizzare un **Support Vector Machine (SVM)**, un algoritmo di **Machine Learning** che permette di classificare efficacemente il canale in base ai parametri osservati, come la **SNR** e il **BER**. L'SVM è un metodo di apprendimento supervisionato particolarmente adatto a scenari con elevata dimensionalità, come quelli che caratterizzano i sistemi di comunicazione.

Successivamente, verrà illustrato l'algoritmo scelto per la trasmissione dei dati, che combina la modulazione adattativa con la codifica di canale, e come l'SVM viene integrato per ottimizzare dinamicamente la configurazione di modulazione e codifica. Infine, presenteremo i risultati degli esperimenti condotti utilizzando le schede **Adalm-Pluto**, che hanno permesso di testare l'implementazione dell'AMC in scenari reali di comunicazione, valutando le prestazioni del sistema in presenza di interferenze, fading e altre condizioni dinamiche del canale.

I risultati ottenuti dimostrano l'efficacia dell'approccio proposto, evidenziando come l'uso combinato dell'AMC e dell'apprendimento automatico possa migliorare significativamente le prestazioni dei sistemi di comunicazione wireless in ambienti complessi e variabili.


# Conclusioni

Il lavoro svolto in questa tesi ha dimostrato l'efficacia di un sistema di comunicazione basato su **OFDM** con **Adaptive Modulation and Coding (AMC)**, ottimizzato tramite tecniche di **Machine Learning** e validato in condizioni reali tramite test **Over-The-Air (OTA)** con **SDR Adalm-Pluto**. L'integrazione di un modello ML per la classificazione dello stato del canale ha permesso di adattare dinamicamente i parametri di trasmissione, migliorando l'affidabilità e l'efficienza spettrale del sistema.

Prima di implementare il sistema AMC, sono stati condotti test approfonditi sul sistema **OFDM base**, sia in simulazione che in ambiente reale tramite prove OTA, valutando le prestazioni in assenza e in presenza di codifica di canale. I risultati hanno evidenziato come la **codifica di canale** migliori significativamente la resilienza alle interferenze e alle degradazioni del canale, riducendo il **BER (Bit Error Rate)** rispetto alla configurazione senza codifica. Tuttavia, senza un meccanismo adattivo, il sistema non è in grado di rispondere dinamicamente alle variazioni delle condizioni di propagazione, portando a inefficienze o degrado delle prestazioni in scenari complessi.

I risultati sperimentali hanno confermato che l'uso di **tecniche adattive** consente di mitigare gli effetti delle variazioni del canale, come interferenze, fading e effetto Doppler, rendendo il sistema più robusto rispetto a una configurazione statica. In particolare, la capacità del modello di apprendere le condizioni del canale e selezionare la modulazione e il code rate più appropriati rappresenta un passo avanti verso l'ottimizzazione autonoma delle reti wireless.

Questa ricerca apre la strada a future applicazioni in scenari reali, come **le reti 5G**, dove l'adattabilità del sistema alle condizioni variabili del canale è fondamentale. Ulteriori sviluppi potrebbero includere l'integrazione con tecniche avanzate di **Deep Learning** e l'estensione del sistema a scenari multi-utente e multi-antenna (**MIMO**), migliorando ulteriormente la capacità di adattamento alle dinamiche del canale.

  


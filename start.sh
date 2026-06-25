#!/bin/sh

echo "Avvio di Helios in corso..."

# Avvia Helios in background
# Sintassi aggiornata per l'ultima versione di Helios dal branch master
helios --execution-rpc https://eth.llamarpc.com \
       --consensus-rpc https://www.lightclientdata.org 2>&1 &

# Attendi 15 secondi per dare tempo a Helios di scaricare lo stato iniziale
echo "Attesa di 15 secondi per la sincronizzazione di Helios..."
sleep 15

echo "Avvio dello script di monitoraggio Node.js..."
# Avvia lo script Node.js di monitoraggio
node /app/monitor.js

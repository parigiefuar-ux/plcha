#!/bin/sh

echo "Avvio di Helios in corso..."

# Avvia Helios in background e reindirizza i log allo standard output
# Aggiornato con i nuovi flag della CLI di Helios
helios --execution-rpc-url https://eth.llamarpc.com \
       --consensus-rpc-url https://www.lightclientdata.org \
       --rpc-port 8545 \
       --rpc-bind-ip 127.0.0.1 2>&1 &

# Attendi 15 secondi per dare tempo a Helios di scaricare lo stato iniziale
echo "Attesa di 15 secondi per la sincronizzazione di Helios..."
sleep 15

echo "Avvio dello script di monitoraggio Node.js..."
# Avvia lo script Node.js di monitoraggio
node /app/monitor.js

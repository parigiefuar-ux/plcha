# Usa l'immagine base più recente di Rust per supportare Cargo.lock v4
FROM rust:slim-bookworm AS builder

# Installa dipendenze per la compilazione
RUN apt-get update && apt-get install -y git clang libssl-dev pkg-config

# Clona e compila Helios (Light Client Ethereum)
RUN git clone https://github.com/a16z/helios.git /helios
WORKDIR /helios
RUN cargo build --release

# ==========================================
# Immagine finale
# ==========================================
FROM node:20-slim

# Copia il binario di Helios dal builder
COPY --from=builder /helios/target/release/helios /usr/local/bin/helios

WORKDIR /app

# Copia i file Node.js
COPY package.json ./
RUN npm install

COPY monitor.js ./
COPY start.sh ./

# Rendi eseguibile lo script di avvio
RUN chmod +x start.sh

# Avvia lo script che lancia sia Helios che Node.js
CMD ["./start.sh"]

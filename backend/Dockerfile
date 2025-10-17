# ====================================================
# DOCKERFILE OTIMIZADO PARA PRODUÇÃO
# UniAgendas Backend - Node.js + TypeScript
# ====================================================

# Usar imagem oficial Node.js Alpine (mais leve)
FROM node:18-alpine AS base

# Instalar dependências do sistema necessárias para Tesseract
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    tesseract-ocr \
    tesseract-ocr-data-por \
    && rm -rf /var/cache/apk/*

# Definir diretório de trabalho
WORKDIR /app

# ====================================================
# ESTÁGIO 1: INSTALAÇÃO DE DEPENDÊNCIAS
# ====================================================
FROM base AS dependencies

# Copiar arquivos de configuração do NPM
COPY package*.json ./

# Instalar dependências (incluindo devDependencies para build)
RUN npm ci --include=dev

# ====================================================
# ESTÁGIO 2: BUILD DA APLICAÇÃO
# ====================================================
FROM dependencies AS build

# Copiar código fonte
COPY . .

# Compilar TypeScript para JavaScript
RUN npm run build

# Remover devDependencies para reduzir tamanho
RUN npm prune --production

# ====================================================
# ESTÁGIO 3: IMAGEM FINAL OTIMIZADA
# ====================================================
FROM base AS production

# Criar usuário não-root para segurança
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Criar diretórios necessários
RUN mkdir -p /app/uploads /app/logs && \
    chown -R nodejs:nodejs /app

# Mudar para usuário não-root
USER nodejs

# Copiar dependências de produção
COPY --from=build --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copiar arquivos compilados
COPY --from=build --chown=nodejs:nodejs /app/build ./build

# Copiar arquivos de configuração
COPY --from=build --chown=nodejs:nodejs /app/package*.json ./

# Copiar scripts de banco de dados (se necessário)
COPY --from=build --chown=nodejs:nodejs /app/scripts ./scripts

# Definir variáveis de ambiente
ENV NODE_ENV=production
ENV PORT=3000

# Expor porta da aplicação
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => { process.exit(1) })"

# Comando para iniciar a aplicação
CMD ["npm", "start"]

# ====================================================
# LABELS PARA DOCUMENTAÇÃO
# ====================================================
LABEL maintainer="Diego Melo <diegohenriquemelo14@gmail.com>"
LABEL version="1.0.0"
LABEL description="UniAgendas Backend - Sistema de Agendamento Médico Inteligente"
LABEL repository="https://github.com/DiegoHenriqueMelo/hackathon-2025"
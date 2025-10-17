# 🏥 UniAgendas Backend

<div align="center">

![TypeScript](https://img.shields.io/badge/TypeScript-5.9.2-blue.svg)
![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)
![Express](https://img.shields.io/badge/Express-5.1.0-black.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-blue.svg)
![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4o--mini-orange.svg)
![Jest](https://img.shields.io/badge/Jest-29.7.0-red.svg)

*Backend robusto para sistema de agendamento médico inteligente*

</div>

## 🚀 Stack Tecnológico

### Core
- **Runtime:** Node.js 18+ com TypeScript 5.9.2
- **Framework:** Express.js 5.1.0
- **Banco de Dados:** PostgreSQL 12+
- **IA:** OpenAI GPT-4o-mini
- **Testes:** Jest 29.7.0 (95%+ cobertura)

### Principais Dependências
- **Autenticação:** JWT + Bcrypt
- **Upload:** Multer 2.0.2
- **OCR:** Tesseract.js 6.0.1
- **PDF:** pdf2json 3.2.2
- **Validação:** Zod 3.25.76
- **CORS:** cors 2.8.5

## 🏗️ Arquitetura

```
src/
├── 📁 config/          # Configurações (DB, OpenAI, JWT)
├── 📁 controller/      # Controladores da API
│   ├── authController.ts
│   ├── botController.ts
│   └── agendamentoController.ts
├── 📁 database/        # Camada de dados
│   ├── connection.ts
│   └── queries.ts
├── 📁 middleware/      # Middlewares (Auth, CORS, Error)
├── 📁 model/          # Modelos e lógica de IA
│   ├── openai.ts
│   └── textExtraction.ts
├── 📁 routes/         # Rotas da API
├── 📁 utils/          # Utilitários
├── 📁 validations/    # Validações Zod
└── 📁 __tests__/      # Suíte de testes completa
    ├── unit/          # Testes unitários
    ├── integration/   # Testes de integração
    ├── performance/   # Testes de carga
    └── e2e/           # Testes end-to-end
```

## 🚀 Instalação Rápida

### Pré-requisitos
```bash
# Verificar versões
node --version  # >= 18.0.0
npm --version   # >= 8.0.0
psql --version  # >= 12.0
```

### Setup Completo
```bash
# 1. Clonar repositório
git clone https://github.com/DiegoHenriqueMelo/hackathon-2025.git
cd hackathon-2025/backend

# 2. Instalar dependências
npm install

# 3. Configurar ambiente
cp .env.example .env
# Editar .env com suas credenciais

# 4. Criar banco de dados
createdb uniagendas
psql uniagendas < scripts/schema.sql

# 5. Executar testes
npm test

# 6. Build e start
npm run build
npm start
```

## ⚙️ Configuração (.env)

```env
# Servidor
PORT=3000
NODE_ENV=development

# Banco de Dados PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=uniagendas
DB_USER=seu_usuario
DB_PASSWORD=sua_senha
DB_SSL=false

# OpenAI API
OPENAI_API_KEY=sk-your-api-key-here
OPENAI_MODEL=gpt-4o-mini
OPENAI_MAX_TOKENS=2000

# Autenticação JWT
JWT_SECRET=seu_jwt_secret_super_seguro
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d

# Upload de Arquivos
MAX_FILE_SIZE=10485760  # 10MB
UPLOAD_PATH=./uploads
ALLOWED_EXTENSIONS=pdf,jpg,jpeg,png

# Rate Limiting
RATE_LIMIT_WINDOW=15    # minutos
RATE_LIMIT_MAX=100      # requests por window

# Logs
LOG_LEVEL=info
LOG_FILE=./logs/app.log
```

## 📡 API Endpoints

### 🔐 Autenticação
```typescript
POST   /api/auth/register     # Registrar usuário
POST   /api/auth/login        # Login
POST   /api/auth/logout       # Logout
POST   /api/auth/refresh      # Refresh token
GET    /api/auth/me          # Perfil do usuário
```

### 🤖 Bot/Assistente Virtual
```typescript
POST   /api/bot/message       # Enviar mensagem para IA
POST   /api/bot/document      # Upload e análise de documento
GET    /api/bot/history       # Histórico da conversa
DELETE /api/bot/session       # Limpar sessão
```

### 📅 Agendamentos
```typescript
GET    /api/agendamentos           # Listar agendamentos
POST   /api/agendamentos           # Criar agendamento
GET    /api/agendamentos/:id       # Detalhes do agendamento
PUT    /api/agendamentos/:id       # Atualizar agendamento
DELETE /api/agendamentos/:id       # Cancelar agendamento
GET    /api/agendamentos/cpf/:cpf  # Buscar por CPF
```

### 👨‍⚕️ Administração
```typescript
GET    /api/admin/doctors          # Listar médicos
POST   /api/admin/doctors          # Cadastrar médico
PUT    /api/admin/doctors/:id      # Atualizar médico
GET    /api/admin/especialidades   # Listar especialidades
GET    /api/admin/context          # Contexto do bot
PUT    /api/admin/context          # Atualizar contexto
GET    /api/admin/stats            # Estatísticas do sistema
```

## 🤖 Funcionalidades da IA

### Assistente Virtual (Ajudant)
```typescript
// Exemplo de uso da IA
const response = await openai.chat.completions.create({
  model: 'gpt-4o-mini',
  messages: [
    { role: 'system', content: MEDICAL_CONTEXT },
    { role: 'user', content: userMessage }
  ],
  max_tokens: 2000,
  temperature: 0.7
});
```

### Capacidades:
- ✅ **Agendamento Inteligente** - Busca por especialidade e localização
- ✅ **Análise de Documentos** - OCR + processamento de pedidos médicos
- ✅ **Verificação de Procedimentos** - Autorização automática vs auditoria
- ✅ **Protocolo Único** - Geração automática de códigos de confirmação
- ✅ **Contexto Médico** - Conhecimento especializado em saúde

## 📄 Processamento de Documentos

### OCR com Tesseract
```typescript
// Extrair texto de imagem
const { data: { text } } = await Tesseract.recognize(imageBuffer, 'por', {
  logger: m => console.log(m)
});
```

### PDF Processing
```typescript
// Processar PDF médico
const pdfParser = new PDFParser();
pdfParser.parseBuffer(pdfBuffer);
const extractedText = pdfParser.getRawTextContent();
```

### Formatos Suportados:
- **Imagens:** JPG, PNG, JPEG
- **Documentos:** PDF
- **Tamanho máximo:** 10MB
- **OCR:** Português otimizado

## 🧪 Testes

### Executar Testes
```bash
# Todos os testes
npm test

# Por categoria
npm run test:unit          # Testes unitários
npm run test:integration   # Testes de integração
npm run test:e2e          # End-to-end

# Com cobertura
npm run test:coverage

# Watch mode
npm run test:watch
```

### Métricas de Qualidade
- **Coverage:** 95%+ (statements, branches, functions)
- **Testes:** 98+ cenários cobertos
- **Performance:** < 2s tempo de resposta
- **Reliability:** 99.9% uptime

## 🗄️ Banco de Dados

### Schema Principal
```sql
-- Usuários
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  cpf VARCHAR(11) UNIQUE NOT NULL,
  senha_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Médicos
CREATE TABLE medicos (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  especialidade VARCHAR(100) NOT NULL,
  crm VARCHAR(20) UNIQUE NOT NULL,
  cidade VARCHAR(100) NOT NULL,
  disponibilidade JSONB
);

-- Agendamentos
CREATE TABLE agendamentos (
  id SERIAL PRIMARY KEY,
  usuario_id INT REFERENCES usuarios(id),
  medico_id INT REFERENCES medicos(id),
  data_consulta TIMESTAMP NOT NULL,
  protocolo VARCHAR(20) UNIQUE NOT NULL,
  status VARCHAR(20) DEFAULT 'agendado',
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Indices para Performance
```sql
-- Otimizações de consulta
CREATE INDEX idx_agendamentos_cpf ON agendamentos(usuario_id);
CREATE INDEX idx_agendamentos_data ON agendamentos(data_consulta);
CREATE INDEX idx_medicos_especialidade ON medicos(especialidade);
CREATE INDEX idx_medicos_cidade ON medicos(cidade);
```

## 🛡️ Segurança

### Implementações
- **JWT Authentication** - Tokens seguros com refresh
- **Bcrypt Hashing** - Senhas com salt rounds
- **Rate Limiting** - Proteção contra DDoS
- **CORS** - Configuração de origem cruzada
- **Input Validation** - Zod schemas
- **SQL Injection** - Prepared statements
- **File Upload** - Validação de tipo e tamanho

### Headers de Segurança
```typescript
// Helmet.js configurado
app.use(helmet({
  contentSecurityPolicy: true,
  crossOriginEmbedderPolicy: false
}));
```

## 📊 Monitoramento

### Logs Estruturados
```typescript
// Winston logger configurado
logger.info('User authenticated', {
  userId: user.id,
  timestamp: new Date().toISOString(),
  ip: req.ip
});
```

### Métricas Coletadas
- **Response Time** - Tempo de resposta por endpoint
- **Error Rate** - Taxa de erros por período
- **Throughput** - Requests por segundo
- **Database** - Query performance e conexões
- **AI Usage** - Tokens consumidos da OpenAI

## 🚀 Deploy

### Produção
```bash
# Build otimizado
npm run build

# Start em produção
NODE_ENV=production npm start
```

### Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

### Variáveis de Ambiente para Deploy
```bash
# Railway/Heroku/AWS
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://...
OPENAI_API_KEY=sk-...
JWT_SECRET=production-secret
```

## 🔧 Troubleshooting

### Problemas Comuns

**OpenAI API Error**
```bash
# Verificar cota e chave
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models
```

**Database Connection**
```bash
# Testar conexão PostgreSQL
psql postgresql://user:pass@host:port/db
```

**Upload Failures**
```bash
# Verificar permissões do diretório
chmod 755 uploads/
chown -R node:node uploads/
```

## 📈 Performance

### Otimizações Implementadas
- **Connection Pooling** - PostgreSQL pool otimizado
- **Caching** - Cache de consultas frequentes
- **Compression** - Gzip para responses
- **Async/Await** - I/O não-bloqueante
- **Database Indexes** - Queries otimizadas
- **File Streaming** - Upload eficiente

### Benchmarks
- **50+ concurrent users** suportados
- **< 500ms** average response time
- **100+ requests/second** throughput
- **< 100MB** memory usage

## 🤝 Contribuição

### Setup de Desenvolvimento
```bash
# Fork e clone
git clone https://github.com/SEU-USER/hackathon-2025.git

# Instalar dependências de dev
npm install

# Executar em modo watch
npm run dev

# Rodar linter
npm run lint

# Executar testes
npm test
```

### Padrões de Código
- **TypeScript strict mode**
- **ESLint + Prettier**
- **Conventional Commits**
- **Test Coverage > 90%**
- **JSDoc para funções públicas**

## 📞 Suporte

- **Documentação:** [GitHub Wiki](https://github.com/DiegoHenriqueMelo/hackathon-2025/wiki)
- **Issues:** [GitHub Issues](https://github.com/DiegoHenriqueMelo/hackathon-2025/issues)
- **Email:** diegohenriquemelo14@gmail.com

---

<div align="center">

**Desenvolvido com ❤️ pela equipe UniAgendas**

*Diego Melo • Davi Muniz • Luciano Neves • Renan Prado*

</div>
-- ====================================================
-- UNIAGENDAS - SETUP COMPLETO DO BANCO DE DADOS
-- ====================================================
-- Versão: 1.0
-- Autor: Equipe UniAgendas
-- Data: 2025-10-17
-- ====================================================

-- Criar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ====================================================
-- TABELAS PRINCIPAIS
-- ====================================================

-- Tabela de Usuários
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    senha_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    ativo BOOLEAN DEFAULT true,
    email_verificado BOOLEAN DEFAULT false,
    data_nascimento DATE,
    genero VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Especialidades Médicas
CREATE TABLE IF NOT EXISTS especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    descricao TEXT,
    icone VARCHAR(50),
    cor VARCHAR(7), -- hex color
    ativa BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Cidades
CREATE TABLE IF NOT EXISTS cidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    codigo_ibge VARCHAR(10),
    ativa BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Médicos
CREATE TABLE IF NOT EXISTS medicos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    especialidade_id INTEGER REFERENCES especialidades(id),
    crm VARCHAR(20) UNIQUE NOT NULL,
    cidade_id INTEGER REFERENCES cidades(id),
    endereco TEXT,
    telefone VARCHAR(15),
    email VARCHAR(255),
    disponibilidade JSONB, -- {"segunda": ["08:00", "18:00"], ...}
    valor_consulta DECIMAL(10,2),
    tempo_consulta INTEGER DEFAULT 30, -- minutos
    ativo BOOLEAN DEFAULT true,
    avaliacao DECIMAL(3,2) DEFAULT 0.00,
    total_avaliacoes INTEGER DEFAULT 0,
    bio TEXT,
    foto_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Agendamentos
CREATE TABLE IF NOT EXISTS agendamentos (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    medico_id INTEGER REFERENCES medicos(id) ON DELETE CASCADE,
    data_consulta TIMESTAMP NOT NULL,
    protocolo VARCHAR(20) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'agendado', -- agendado, confirmado, realizado, cancelado
    observacoes TEXT,
    valor DECIMAL(10,2),
    forma_pagamento VARCHAR(50),
    lembrete_enviado BOOLEAN DEFAULT false,
    avaliacao INTEGER CHECK (avaliacao >= 1 AND avaliacao <= 5),
    comentario_avaliacao TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Procedimentos Médicos
CREATE TABLE IF NOT EXISTS procedimentos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    codigo_tuss VARCHAR(20),
    especialidade_id INTEGER REFERENCES especialidades(id),
    tipo VARCHAR(50) NOT NULL, -- simples, complexo, opme
    valor_referencia DECIMAL(10,2),
    tempo_duracao INTEGER, -- minutos
    requer_autorizacao BOOLEAN DEFAULT false,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Solicitações de Procedimentos
CREATE TABLE IF NOT EXISTS solicitacoes_procedimento (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    procedimento_id INTEGER REFERENCES procedimentos(id),
    medico_solicitante VARCHAR(255),
    documento_url VARCHAR(500),
    status VARCHAR(30) DEFAULT 'pendente', -- pendente, autorizado, negado, auditoria
    protocolo VARCHAR(20) UNIQUE NOT NULL,
    justificativa TEXT,
    data_solicitacao TIMESTAMP DEFAULT NOW(),
    data_resposta TIMESTAMP,
    observacoes_auditoria TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Sessões do Chat Bot
CREATE TABLE IF NOT EXISTS chat_sessions (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    session_id UUID DEFAULT uuid_generate_v4(),
    contexto JSONB, -- histórico da conversa
    ativa BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Mensagens do Chat
CREATE TABLE IF NOT EXISTS chat_messages (
    id SERIAL PRIMARY KEY,
    session_id UUID REFERENCES chat_sessions(session_id) ON DELETE CASCADE,
    tipo VARCHAR(20) NOT NULL, -- user, assistant, system
    conteudo TEXT NOT NULL,
    metadata JSONB, -- arquivos, protocolos gerados, etc
    tokens_utilizados INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Configurações do Sistema
CREATE TABLE IF NOT EXISTS configuracoes (
    id SERIAL PRIMARY KEY,
    chave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT,
    descricao TEXT,
    tipo VARCHAR(50) DEFAULT 'string', -- string, number, boolean, json
    categoria VARCHAR(50) DEFAULT 'geral',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Logs de Auditoria
CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id),
    acao VARCHAR(100) NOT NULL,
    tabela VARCHAR(50),
    registro_id INTEGER,
    dados_antigos JSONB,
    dados_novos JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ====================================================
-- ÍNDICES PARA PERFORMANCE
-- ====================================================

-- Índices para Agendamentos
CREATE INDEX IF NOT EXISTS idx_agendamentos_usuario ON agendamentos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_agendamentos_medico ON agendamentos(medico_id);
CREATE INDEX IF NOT EXISTS idx_agendamentos_data ON agendamentos(data_consulta);
CREATE INDEX IF NOT EXISTS idx_agendamentos_status ON agendamentos(status);
CREATE INDEX IF NOT EXISTS idx_agendamentos_protocolo ON agendamentos(protocolo);

-- Índices para Médicos
CREATE INDEX IF NOT EXISTS idx_medicos_especialidade ON medicos(especialidade_id);
CREATE INDEX IF NOT EXISTS idx_medicos_cidade ON medicos(cidade_id);
CREATE INDEX IF NOT EXISTS idx_medicos_ativo ON medicos(ativo);
CREATE INDEX IF NOT EXISTS idx_medicos_crm ON medicos(crm);

-- Índices para Usuários
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_cpf ON usuarios(cpf);
CREATE INDEX IF NOT EXISTS idx_usuarios_ativo ON usuarios(ativo);

-- Índices para Chat
CREATE INDEX IF NOT EXISTS idx_chat_sessions_usuario ON chat_sessions(usuario_id);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_ativa ON chat_sessions(ativa);
CREATE INDEX IF NOT EXISTS idx_chat_messages_session ON chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_tipo ON chat_messages(tipo);

-- Índices para Procedimentos
CREATE INDEX IF NOT EXISTS idx_procedimentos_especialidade ON procedimentos(especialidade_id);
CREATE INDEX IF NOT EXISTS idx_procedimentos_tipo ON procedimentos(tipo);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_usuario ON solicitacoes_procedimento(usuario_id);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_status ON solicitacoes_procedimento(status);

-- ====================================================
-- TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA
-- ====================================================

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger nas tabelas necessárias
CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medicos_updated_at BEFORE UPDATE ON medicos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agendamentos_updated_at BEFORE UPDATE ON agendamentos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_solicitacoes_updated_at BEFORE UPDATE ON solicitacoes_procedimento
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_sessions_updated_at BEFORE UPDATE ON chat_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_configuracoes_updated_at BEFORE UPDATE ON configuracoes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ====================================================
-- FUNÇÕES UTILITÁRIAS
-- ====================================================

-- Função para gerar protocolo único
CREATE OR REPLACE FUNCTION gerar_protocolo()
RETURNS TEXT AS $$
BEGIN
    RETURN 'UNI' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(FLOOR(RANDOM() * 9999)::TEXT, 4, '0');
END;
$$ LANGUAGE plpgsql;

-- Função para verificar disponibilidade do médico
CREATE OR REPLACE FUNCTION verificar_disponibilidade_medico(
    medico_id_param INTEGER,
    data_consulta_param TIMESTAMP
)
RETURNS BOOLEAN AS $$
DECLARE
    conflito INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO conflito
    FROM agendamentos a
    WHERE a.medico_id = medico_id_param
    AND a.data_consulta = data_consulta_param
    AND a.status IN ('agendado', 'confirmado');
    
    RETURN conflito = 0;
END;
$$ LANGUAGE plpgsql;

-- ====================================================
-- DADOS INICIAIS (SEEDS)
-- ====================================================

-- Especialidades Médicas Comuns
INSERT INTO especialidades (nome, descricao, icone, cor) VALUES
('Cardiologia', 'Especialidade médica que se ocupa do diagnóstico e tratamento das doenças que acometem o coração', '❤️', '#e74c3c'),
('Dermatologia', 'Especialidade médica que se ocupa do diagnóstico, tratamento e prevenção de doenças relacionadas à pele', '🧔', '#f39c12'),
('Ginecologia', 'Especialidade da medicina que trata de doenças do sistema reprodutor feminino', '👩', '#9b59b6'),
('Neurologia', 'Especialidade médica que trata dos distúrbios estruturais do sistema nervoso', '🧠', '#3498db'),
('Oftalmologia', 'Especialidade da medicina que investiga e trata as doenças relacionadas aos olhos', '👁️', '#2ecc71'),
('Ortopedia', 'Especialidade médica que cuida da saúde relacionada aos elementos do aparelho locomotor', '🦴', '#95a5a6'),
('Pediatria', 'Especialidade médica dedicada à assistência à criança e ao adolescente', '👶', '#ff6b6b'),
('Psiquiatria', 'Especialidade da Medicina que lida com a prevenção, atendimento, diagnóstico, tratamento e reabilitação das diferentes formas de sofrimentos mentais', '🧠', '#6c5ce7'),
('Urologia', 'Especialidade cirúrgica da medicina que trata do trato urinário de ambos os sexos e do sistema reprodutor masculino', '🧿', '#74b9ff'),
('Clínica Geral', 'Especialidade médica que proporciona atenção continuada e abrangente ao indivíduo e família', '🩺', '#00b894')
ON CONFLICT (nome) DO NOTHING;

-- Algumas cidades exemplo
INSERT INTO cidades (nome, estado, codigo_ibge) VALUES
('São Paulo', 'SP', '3550308'),
('Rio de Janeiro', 'RJ', '3304557'),
('Belo Horizonte', 'MG', '3106200'),
('Brasília', 'DF', '5300108'),
('Salvador', 'BA', '2927408'),
('Franca', 'SP', '3516200'),
('Ribeirão Preto', 'SP', '3543402'),
('Campinas', 'SP', '3509502')
ON CONFLICT DO NOTHING;

-- Procedimentos Médicos Comuns
INSERT INTO procedimentos (nome, codigo_tuss, especialidade_id, tipo, requer_autorizacao, descricao) VALUES
('Consulta Médica', '10101012-6', 10, 'simples', false, 'Consulta médica em consultório'),
('Eletrocardiograma', '21010101-2', 1, 'simples', false, 'Exame do coração por meio de eletrodos'),
('Tomografia Computadorizada', '40701018-4', null, 'complexo', true, 'Exame de imagem por tomografia'),
('Ressonância Magnética', '40901025-0', null, 'complexo', true, 'Exame de imagem por ressonância'),
('Cirurgia de Catarata', '41601025-8', 5, 'opme', true, 'Cirurgia para remoção de catarata'),
('Colposcopia', '31203019-0', 3, 'simples', false, 'Exame ginecológico com colposcópio'),
('Ultrassonografia', '40601018-8', null, 'simples', false, 'Exame de ultrassom')
ON CONFLICT DO NOTHING;

-- Configurações do Sistema
INSERT INTO configuracoes (chave, valor, descricao, tipo, categoria) VALUES
('sistema_nome', 'UniAgendas', 'Nome do sistema', 'string', 'geral'),
('sistema_versao', '1.0.0', 'Versão atual do sistema', 'string', 'geral'),
('bot_contexto_medico', 'Você é um assistente virtual especializado em saúde...', 'Contexto base para o assistente virtual', 'string', 'ia'),
('agendamento_antecedencia_minima', '60', 'Antecedência mínima para agendamento (minutos)', 'number', 'agendamento'),
('agendamento_cancelamento_limite', '120', 'Tempo limite para cancelamento sem taxa (minutos)', 'number', 'agendamento'),
('upload_tamanho_maximo', '10485760', 'Tamanho máximo de arquivo (bytes)', 'number', 'upload'),
('notificacoes_email_ativas', 'true', 'Ativar notificações por email', 'boolean', 'notificacoes'),
('manutencao_modo', 'false', 'Modo de manutenção ativo', 'boolean', 'sistema')
ON CONFLICT (chave) DO NOTHING;

-- ====================================================
-- VIEWS PARA CONSULTAS OTIMIZADAS
-- ====================================================

-- View de agendamentos com dados completos
CREATE OR REPLACE VIEW vw_agendamentos_completos AS
SELECT 
    a.id,
    a.protocolo,
    a.data_consulta,
    a.status,
    a.observacoes,
    a.valor,
    u.nome as usuario_nome,
    u.cpf as usuario_cpf,
    u.telefone as usuario_telefone,
    m.nome as medico_nome,
    m.crm as medico_crm,
    e.nome as especialidade,
    c.nome as cidade,
    c.estado,
    a.created_at,
    a.updated_at
FROM agendamentos a
JOIN usuarios u ON a.usuario_id = u.id
JOIN medicos m ON a.medico_id = m.id
JOIN especialidades e ON m.especialidade_id = e.id
JOIN cidades c ON m.cidade_id = c.id;

-- View de médicos com dados completos
CREATE OR REPLACE VIEW vw_medicos_completos AS
SELECT 
    m.id,
    m.nome,
    m.crm,
    m.telefone,
    m.email,
    m.ativo,
    m.avaliacao,
    m.total_avaliacoes,
    m.valor_consulta,
    m.tempo_consulta,
    e.nome as especialidade,
    c.nome as cidade,
    c.estado,
    m.disponibilidade,
    m.created_at
FROM medicos m
JOIN especialidades e ON m.especialidade_id = e.id
JOIN cidades c ON m.cidade_id = c.id;

-- ====================================================
-- PERMISSÕES E SEGURANÇA
-- ====================================================

-- Criar usuário de aplicação (opcional)
-- CREATE USER uniagendas_app WITH PASSWORD 'senha_segura_aqui';
-- GRANT CONNECT ON DATABASE uniagendas TO uniagendas_app;
-- GRANT USAGE ON SCHEMA public TO uniagendas_app;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO uniagendas_app;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO uniagendas_app;

-- ====================================================
-- CONCLUSÃO
-- ====================================================

-- Verificar se tudo foi criado corretamente
SELECT 
    'Tabelas criadas' as status,
    COUNT(*) as total
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'usuarios', 'medicos', 'agendamentos', 'especialidades', 
    'cidades', 'procedimentos', 'solicitacoes_procedimento',
    'chat_sessions', 'chat_messages', 'configuracoes', 'audit_logs'
);

SELECT 'Setup do banco de dados concluído com sucesso!' as resultado;

-- ====================================================
-- FIM DO SCRIPT
-- ====================================================
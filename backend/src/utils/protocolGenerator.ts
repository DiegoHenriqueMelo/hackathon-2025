/**
 * @fileoverview Gerador de protocolos aleatórios
 */

/**
 * Gera um protocolo aleatório baseado no tipo
 */
export const generateProtocol = (type: 'AGD' | 'AUT' | 'ATD' = 'ATD'): string => {
  const randomNumber = Math.floor(Math.random() * 900000) + 100000; // 6 dígitos
  return `${type}${randomNumber}`;
};

/**
 * Gera protocolo de agendamento
 */
export const generateAgendamentoProtocol = (): string => {
  return generateProtocol('AGD');
};

/**
 * Gera protocolo de autorização
 */
export const generateAutorizacaoProtocol = (): string => {
  return generateProtocol('AUT');
};

/**
 * Gera protocolo de atendimento geral
 */
export const generateAtendimentoProtocol = (): string => {
  return generateProtocol('ATD');
};
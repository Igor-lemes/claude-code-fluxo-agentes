# Guia de economia de tokens no Claude Code

Notas práticas de um ambiente real, ao migrar o uso do Claude Code de uma assinatura para a API paga por token. Em PT-BR; resumo em inglês no fim.

## 1. Meça antes de mexer

- Instale o [`ccusage`](https://github.com/ryoppippi/ccusage) e veja o gasto por dia e por sessão: `ccusage daily --since AAAAMMDD`.
- O custo mostrado numa assinatura é o *equivalente em preço de API*, não o que foi cobrado. Em dias medidos aqui, o equivalente caiu de centenas de dólares por dia (com um agente autônomo em *heartbeat*) para poucos dólares por dia depois das mudanças abaixo. **São dias isolados e várias mudanças ao mesmo tempo; não é uma série longa, então não dá para atribuir o resultado a uma causa só.**
- O maior vilão foi leitura de cache repetida por um agente que acordava a cada ~55 min: contexto grande × muitas execuções.

## 2. O que entra em toda sessão (e custa token)

Liste e dimensione: servidores MCP, plugins, skills, e o tamanho dos `CLAUDE.md`/`AGENTS.md` carregados. Cada ferramenta MCP adiciona o schema ao contexto, mesmo sem uso.

- Mantenha `CLAUDE.md` curto: stack, comandos, convenções. Documentos longos de plano vão em arquivos que só se lê sob demanda.
- Instrução de outro sistema (que não o Claude Code) não deve ficar num arquivo carregado em toda sessão.
- MCP só no escopo do projeto que o usa (`.mcp.json`), não global.

## 3. Modelo certo para cada tarefa

| Papel | Modelo | Por quê |
|---|---|---|
| explorador (leitura/busca) | haiku | barato, só lê |
| planejador | opus | erro de plano custa mais que o plano |
| implementador | sonnet | bom custo/benefício para código |
| testador | haiku | roda comandos e resume saída |
| revisor | opus | olhos novos, cenário que quebra |

Modelo padrão da sessão: `sonnet`; Opus só quando pedido. Os agentes de `.claude/agents/` aplicam isso.

## 4. Hábitos que reduzem consumo

- Subagentes para leitura ampla: o contexto principal recebe só o resumo.
- Saída longa de comando vai para arquivo; devolva só as primeiras linhas do erro.
- `Grep` antes de `Read`; leia só o intervalo necessário.
- Hook `Stop` para typecheck (ver `.claude/hooks/typecheck-fim.sh`): roda uma vez no fim do turno, não a cada edição, e devolve o erro ao modelo com exit 2.
- Rotinas agendadas (crons) com modelo menor e contexto podado; evite *heartbeat* que reabre um contexto grande.
- Peça confirmação antes de rodar workflows com muitos subagentes.

## 5. O que não adotei

Uma ferramenta de compressão de saída (rtk) foi descartada porque um benchmark independente não encontrou economia. Um MCP de navegação por símbolo (Serena) ficou como piloto, sem conclusão medida.

## English summary

Measure first (`ccusage`); keep always-loaded context small (short `CLAUDE.md`, project-scoped MCP); pick the model per role (haiku to read/test, sonnet to implement, opus to plan/review); push big outputs to files; run typecheck once at the end of a turn with a `Stop` hook; avoid autonomous heartbeats that re-read a large context. The savings cited are single-day measurements with several simultaneous changes, so treat them as indicative, not as a controlled result.

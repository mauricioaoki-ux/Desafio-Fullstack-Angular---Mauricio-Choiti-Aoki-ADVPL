# Desafio Técnico: Gerenciador de Tarefas (Protheus + PO-UI)
Autor: Mauricio Choiti Aoki
Data: 26/03/2026

Este repositório contém a solução para o desafio de gerenciamento de tarefas e subtarefas, integrando o back-end **AdvPL (MVC)** com um front-end moderno em **PO-UI (Angular)** via **API REST**.

---

## Estrutura do Projeto

- **/backend**: Contém o fonte `GenTarSubTar.PRW` (MVC, MenuDef e a classe WSRESTFUL).
- **/database**: Arquivo `tabelas.csv` com a modelagem do dicionário de dados (SX2/SX3).
- **/frontend**: Aplicação Angular utilizando os componentes e templates do PO-UI.

---

## Configuração do Ambiente

### 1. Banco de Dados (Protheus)
1. Importe as definições do arquivo `/database/tabelas.csv` no **Configurador (SIGACFG)**.
2. Certifique-se de que os campos `ZZG_CODIGO` e `ZZH_CODIGO` estão configurados para numeração automática via `GetSxENum`.
3. Compile o arquivo `/backend/GenTarSubTar.PRW`.
4. Adicione a função `U_GenTarSubTar` ao seu Menu do Protheus.

### 2. API REST (AppServer.ini)
Configure o serviço REST no Protheus para permitir a comunicação com o Frontend:
```ini
[HTTPREST]
Port=8080
IPConn=ALL
Security=0

[ONSTART]
jobs=HTTPREST

## Regras de Negócio e Funcionalidades

### No Protheus (MVC)
Auditoria Automática: Preenchimento automático de Usuário de Inclusão (__cUserId) e Data de Inclusão (dDataBase).
Validação de Data: Bloqueio de gravação caso a Data de Conclusão seja menor que a Data de Inclusão.
Integridade Pai x Filho: Uma tarefa pai só pode ser concluída (Status 3) se todas as suas subtarefas estiverem concluídas.
Automação: Ao concluir a última subtarefa pendente, o sistema sugere/altera automaticamente o status da tarefa principal para "Concluída".

### Na Web (PO-UI)
CRUD Dinâmico: Interface completa para incluir, editar e excluir tarefas.
Filtros Avançados: Busca rápida por Título ou Descrição da tarefa.
Comunicação REST: Utilização da classe FWRestModel para garantir que todas as validações do Protheus sejam respeitadas na Web.

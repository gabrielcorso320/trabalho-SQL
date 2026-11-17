# Estudo de SQL Server: segurança e backup

Exercício prático com um banco de dados de loja para estudar controle de acesso, testes de permissões e recuperação de dados com T-SQL.

## Conteúdo

- Criação das tabelas Clientes, Produtos, Funcionarios e Vendas.
- Inserção de dados fictícios e criação da view `vw_VendasMes`.
- Logins, usuários e roles para vendedor, gerente e estagiário.
- Permissões com `GRANT` e `DENY` e herança entre roles.
- Testes com `EXECUTE AS USER` e retorno com `REVERT`.
- Backup full e restauração em um novo banco, `Loja_Copia`.
- Comparação das quantidades de registros com `SELECT COUNT(*)`.

## Perfis de acesso

| Perfil | Acessos permitidos | Restrições |
|---|---|---|
| Vendedor | Consultar produtos e inserir vendas | Não consultar CPF de clientes |
| Gerente | Herdar os acessos do vendedor e consultar o relatório mensal | Herda a restrição ao CPF |
| Estagiário | Consultar tabelas e views | Não consultar salários nem inserir, atualizar ou excluir dados |

As roles agrupam permissões. O login representa o acesso à instância; o usuário é vinculado ao login dentro do banco.

## Como executar

1. Use uma instância local de SQL Server com uma conta que possa criar bancos e logins, administrar permissões e executar backup e restore.
2. Abra `atividade_loja_completa.sql` no VS Code com a extensão MSSQL ou no SSMS.
3. Substitua os três marcadores `<DEFINA_SENHA_...>` por senhas fortes para seu ambiente local. Não publique a cópia com senhas preenchidas.
4. Confira os caminhos do backup e dos arquivos de dados. O exemplo usa as pastas padrão de uma instância SQL Server 2025 Express chamada `SQLEXPRESS`. As pastas devem existir e permitir gravação pela conta do serviço SQL Server.
5. Execute em um ambiente de estudo onde o banco Loja, os logins e o banco Loja_Copia ainda não existam.

O script cria os objetos diretamente e não é idempotente: executá-lo inteiro novamente causa erros de objetos já existentes. Para estudar um teste isolado, selecione seu bloco completo, incluindo `REVERT`. Não há comandos para excluir bancos existentes.

Os testes de acesso negado usam `TRY/CATCH` e mostram a mensagem de permissão negada como resultado esperado. Os testes de INSERT usam uma seleção sem linhas para conferir a permissão sem adicionar vendas.

## Resultado verificado

Na execução local com SQL Server 2025 Express, os acessos permitidos funcionaram, as consultas proibidas foram negadas e o backup foi restaurado em Loja_Copia.

| Tabela | Loja | Loja_Copia |
|---|---:|---:|
| Clientes | 8 | 8 |
| Produtos | 8 | 8 |
| Funcionarios | 5 | 5 |
| Vendas | 20 | 20 |

A versão publicada substitui as senhas locais por marcadores. Os arquivos de backup e os arquivos físicos dos bancos não são versionados.

## Contexto

Estudo desenvolvido a partir de uma atividade acadêmica de Segurança e Backup no SQL Server. A estrutura inicial e os dados fictícios da loja foram fornecidos no material da disciplina; o exercício aplica os perfis de acesso e verifica a restauração.

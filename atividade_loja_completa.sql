CREATE DATABASE Loja;
GO

USE Loja;
GO

CREATE TABLE dbo.Clientes (
    id_cliente   INT IDENTITY(1,1) PRIMARY KEY,
    nome         VARCHAR(100) NOT NULL,
    email        VARCHAR(100) NOT NULL,
    cpf          CHAR(14)     NOT NULL UNIQUE,
    cidade       VARCHAR(60)  NOT NULL
);

CREATE TABLE dbo.Produtos (
    id_produto   INT IDENTITY(1,1) PRIMARY KEY,
    nome         VARCHAR(100)  NOT NULL,
    categoria    VARCHAR(50)   NOT NULL,
    preco        DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    estoque      INT           NOT NULL DEFAULT 0
);

CREATE TABLE dbo.Funcionarios (
    id_funcionario INT IDENTITY(1,1) PRIMARY KEY,
    nome           VARCHAR(100)  NOT NULL,
    cargo          VARCHAR(50)   NOT NULL,
    salario        DECIMAL(10,2) NOT NULL,
    data_admissao  DATE          NOT NULL
);

CREATE TABLE dbo.Vendas (
    id_venda       INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente     INT NOT NULL REFERENCES dbo.Clientes(id_cliente),
    id_produto     INT NOT NULL REFERENCES dbo.Produtos(id_produto),
    id_funcionario INT NOT NULL REFERENCES dbo.Funcionarios(id_funcionario),
    quantidade     INT NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL,
    data_venda     DATETIME NOT NULL DEFAULT GETDATE()
);

INSERT INTO dbo.Clientes (nome, email, cpf, cidade) VALUES
('Cliente Teste 1', 'cliente1@example.com', 'TESTE000000001', 'Cidade Teste'),
('Cliente Teste 2', 'cliente2@example.com', 'TESTE000000002', 'Cidade Teste'),
('Cliente Teste 3', 'cliente3@example.com', 'TESTE000000003', 'Cidade Teste'),
('Cliente Teste 4', 'cliente4@example.com', 'TESTE000000004', 'Cidade Teste'),
('Cliente Teste 5', 'cliente5@example.com', 'TESTE000000005', 'Cidade Teste'),
('Cliente Teste 6', 'cliente6@example.com', 'TESTE000000006', 'Cidade Teste'),
('Cliente Teste 7', 'cliente7@example.com', 'TESTE000000007', 'Cidade Teste'),
('Cliente Teste 8', 'cliente8@example.com', 'TESTE000000008', 'Cidade Teste');

INSERT INTO dbo.Produtos (nome, categoria, preco, estoque) VALUES
('Notebook 15"',         'Informática', 3899.90, 12),
('Mouse sem fio',        'Informática',   89.90, 80),
('Teclado mecânico',     'Informática',  349.90, 35),
('Monitor 24"',          'Informática',  999.00, 20),
('Fone Bluetooth',       'Áudio',        199.90, 50),
('Caixa de som',         'Áudio',        279.00, 25),
('Cadeira gamer',        'Móveis',      1299.00,  8),
('Mesa para escritório', 'Móveis',       649.90, 10);

INSERT INTO dbo.Funcionarios (nome, cargo, salario, data_admissao) VALUES
('Funcionario Teste 1', 'Gerente', 1000.00, '2026-01-01'),
('Funcionario Teste 2', 'Vendedor', 2000.00, '2026-01-01'),
('Funcionario Teste 3', 'Vendedor', 3000.00, '2026-01-01'),
('Funcionario Teste 4', 'Vendedor', 4000.00, '2026-01-01'),
('Funcionario Teste 5', 'Estagiario', 5000.00, '2026-01-01');

INSERT INTO dbo.Vendas (id_cliente, id_produto, id_funcionario, quantidade, preco_unitario, data_venda) VALUES
(1, 1, 2, 1, 3899.90, '20260822'),
(2, 2, 3, 2,   89.90, '20260827'),
(3, 5, 4, 1,  199.90, '20260831'),
(4, 3, 2, 1,  349.90, '20260906'),
(5, 4, 3, 2,  999.00, '20260912'),
(6, 7, 4, 1, 1299.00, '20260918'),
(7, 2, 2, 3,   89.90, '20260924'),
(8, 6, 3, 1,  279.00, '20261001'),
(1, 8, 4, 1,  649.90, '20261006'),
(2, 5, 2, 2,  199.90, '20261013'),
(3, 1, 3, 1, 3899.90, '20261019'),
(4, 2, 4, 1,   89.90, '20261025'),
(5, 3, 2, 1,  349.90, '20261031'),
(6, 4, 3, 1,  999.00, '20261103'),
(7, 5, 4, 2,  199.90, '20261106'),
(8, 7, 2, 1, 1299.00, '20261109'),
(1, 2, 3, 2,   89.90, '20261111'),
(2, 6, 4, 1,  279.00, '20261112'),
(3, 3, 2, 1,  349.90, '20261113'),
(4, 1, 3, 1, 3899.90, '20261114');
GO

CREATE VIEW dbo.vw_VendasMes AS
SELECT
    YEAR(data_venda)                 AS ano,
    MONTH(data_venda)                AS mes,
    COUNT(*)                         AS qtd_vendas,
    SUM(quantidade * preco_unitario) AS faturamento
FROM dbo.Vendas
GROUP BY YEAR(data_venda), MONTH(data_venda);
GO
USE master;
GO

CREATE LOGIN login_vendedor WITH PASSWORD = '<DEFINA_SENHA_VENDEDOR>';
CREATE LOGIN login_gerente WITH PASSWORD = '<DEFINA_SENHA_GERENTE>';
CREATE LOGIN login_estagiario WITH PASSWORD = '<DEFINA_SENHA_ESTAGIARIO>';
GO
USE Loja;
GO

CREATE USER usuario_vendedor FOR LOGIN login_vendedor;
CREATE USER usuario_gerente FOR LOGIN login_gerente;
CREATE USER usuario_estagiario FOR LOGIN login_estagiario;
GO
CREATE ROLE vendedor;
CREATE ROLE gerente;
CREATE ROLE estagiario;
GO

ALTER ROLE vendedor ADD MEMBER usuario_vendedor;
ALTER ROLE gerente ADD MEMBER usuario_gerente;
ALTER ROLE estagiario ADD MEMBER usuario_estagiario;
GO
USE Loja;
GO
GRANT SELECT ON dbo.Produtos TO vendedor;
GRANT INSERT ON dbo.Vendas TO vendedor;
DENY SELECT ON dbo.Clientes (cpf) TO vendedor;
GO
ALTER ROLE vendedor ADD MEMBER gerente;
GRANT SELECT ON dbo.vw_VendasMes TO gerente;
GO
ALTER ROLE db_datareader ADD MEMBER estagiario;
ALTER ROLE db_denydatawriter ADD MEMBER estagiario;
DENY SELECT ON dbo.Funcionarios (salario) TO estagiario;
GO
USE Loja;
GO
EXECUTE AS USER = 'usuario_vendedor';
SELECT USER_NAME() AS usuario_atual;
SELECT * FROM dbo.Produtos;
REVERT;
GO
EXECUTE AS USER = 'usuario_vendedor';
SELECT USER_NAME() AS usuario_atual;
BEGIN TRY
    EXEC(N'SELECT cpf FROM dbo.Clientes;');
    SELECT N'FALHA: o acesso deveria ter sido negado' AS resultado;
END TRY
BEGIN CATCH
    SELECT
        CASE WHEN ERROR_NUMBER() IN (229, 230)
             THEN N'OK: acesso negado conforme esperado'
             ELSE N'FALHA: erro diferente do esperado' END AS resultado,
        ERROR_NUMBER() AS numero_erro,
        ERROR_MESSAGE() AS mensagem;
END CATCH;
REVERT;
GO
EXECUTE AS USER = 'usuario_gerente';
SELECT USER_NAME() AS usuario_atual;
SELECT * FROM dbo.Produtos;
REVERT;
GO
EXECUTE AS USER = 'usuario_gerente';
SELECT USER_NAME() AS usuario_atual;
SELECT * FROM dbo.vw_VendasMes;
REVERT;
GO
EXECUTE AS USER = 'usuario_gerente';
SELECT USER_NAME() AS usuario_atual;
BEGIN TRY
    EXEC(N'SELECT cpf FROM dbo.Clientes;');
    SELECT N'FALHA: o acesso deveria ter sido negado' AS resultado;
END TRY
BEGIN CATCH
    SELECT
        CASE WHEN ERROR_NUMBER() IN (229, 230)
             THEN N'OK: acesso negado conforme esperado'
             ELSE N'FALHA: erro diferente do esperado' END AS resultado,
        ERROR_NUMBER() AS numero_erro,
        ERROR_MESSAGE() AS mensagem;
END CATCH;
REVERT;
GO
EXECUTE AS USER = 'usuario_estagiario';
SELECT USER_NAME() AS usuario_atual;
SELECT * FROM dbo.Produtos;
REVERT;
GO
EXECUTE AS USER = 'usuario_estagiario';
SELECT USER_NAME() AS usuario_atual;
SELECT id_funcionario, nome, cargo, data_admissao FROM dbo.Funcionarios;
REVERT;
GO
EXECUTE AS USER = 'usuario_estagiario';
SELECT USER_NAME() AS usuario_atual;
BEGIN TRY
    EXEC(N'SELECT salario FROM dbo.Funcionarios;');
    SELECT N'FALHA: o acesso deveria ter sido negado' AS resultado;
END TRY
BEGIN CATCH
    SELECT
        CASE WHEN ERROR_NUMBER() IN (229, 230)
             THEN N'OK: acesso negado conforme esperado'
             ELSE N'FALHA: erro diferente do esperado' END AS resultado,
        ERROR_NUMBER() AS numero_erro,
        ERROR_MESSAGE() AS mensagem;
END CATCH;
REVERT;
GO
EXECUTE AS USER = 'usuario_estagiario';
SELECT USER_NAME() AS usuario_atual;
BEGIN TRY
    EXEC(N'UPDATE dbo.Produtos SET estoque = estoque WHERE 1 = 0;');
    SELECT N'FALHA: o acesso deveria ter sido negado' AS resultado;
END TRY
BEGIN CATCH
    SELECT
        CASE WHEN ERROR_NUMBER() IN (229, 230)
             THEN N'OK: acesso negado conforme esperado'
             ELSE N'FALHA: erro diferente do esperado' END AS resultado,
        ERROR_NUMBER() AS numero_erro,
        ERROR_MESSAGE() AS mensagem;
END CATCH;
REVERT;
GO
EXECUTE AS USER = 'usuario_vendedor';
INSERT INTO dbo.Vendas (id_cliente, id_produto, id_funcionario, quantidade, preco_unitario)
SELECT 1, 1, 2, 1, 3899.90 WHERE 1 = 0;
SELECT N'OK: INSERT autorizado para vendedor (teste sem adicionar linhas)' AS resultado;
REVERT;
GO

EXECUTE AS USER = 'usuario_gerente';
INSERT INTO dbo.Vendas (id_cliente, id_produto, id_funcionario, quantidade, preco_unitario)
SELECT 1, 1, 2, 1, 3899.90 WHERE 1 = 0;
SELECT N'OK: INSERT herdado pelo gerente (teste sem adicionar linhas)' AS resultado;
REVERT;
GO
USE master;
GO

BACKUP DATABASE Loja
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\Loja_atividade_20261116.bak';
GO

RESTORE VERIFYONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\Loja_atividade_20261116.bak';
GO
RESTORE FILELISTONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\Loja_atividade_20261116.bak';
GO

RESTORE DATABASE Loja_Copia
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\Loja_atividade_20261116.bak'
WITH MOVE 'Loja' TO 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\Loja_Copia.mdf',
     MOVE 'Loja_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\Loja_Copia_log.ldf',
     RECOVERY;
GO
SELECT 'Clientes' AS tabela,
       (SELECT COUNT(*) FROM Loja.dbo.Clientes) AS original,
       (SELECT COUNT(*) FROM Loja_Copia.dbo.Clientes) AS restaurado
UNION ALL
SELECT 'Produtos',
       (SELECT COUNT(*) FROM Loja.dbo.Produtos),
       (SELECT COUNT(*) FROM Loja_Copia.dbo.Produtos)
UNION ALL
SELECT 'Funcionarios',
       (SELECT COUNT(*) FROM Loja.dbo.Funcionarios),
       (SELECT COUNT(*) FROM Loja_Copia.dbo.Funcionarios)
UNION ALL
SELECT 'Vendas',
       (SELECT COUNT(*) FROM Loja.dbo.Vendas),
       (SELECT COUNT(*) FROM Loja_Copia.dbo.Vendas);
GO
USE Loja;
GO



CREATE DATABASE Datapedia

EXEC sp_rename 'Datapedia', 'Sales';

select * from sales

UPDATE Sales
SET Pre�o = Pre�o / 100;


/* PERGUNTA 1 - Me d� informa��es de commpras por ano */

SELECT YEAR(DATA) as ano,
	   COUNT(ORDER_ID) AS [Livros Vendidos],
	   COUNT(DISTINCT(ORDER_ID)) as [Pedidos Vendidos],
	   ROUND(SUM(pre�o), 2) as [Faturamento],
	   ROUND(SUM(pre�o)/COUNT(distinct(Order_id)),2) as [Ticket M�dio]
FROM SALES
group by year(data)



/* PERGUNTA 2 - Qual a quantidade e a porcentagem de clientes s�o homens e mulheres */

SELECT  Sexo,
		COUNT(DISTINCT(CLIENTE_ID)) as Quantidade,
		round(cast(COUNT(DISTINCT(CLIENTE_ID)) as float)/(select COUNT(distinct(cliente_id)) from Sales),2) as Percentual
from Sales
group by sexo


/*PERGUNTA 3 - Qual a quantidade de clientes s�o Crian�as (Menores de 18 anos), Adultos (entre 18 e 55) , e Idosos?
E como est�o distribuidas essas idades?*/


-- Adicionando Coluna Classificacao Idade  

ALTER TABLE Sales
ADD Classificacao VARCHAR(20);

UPDATE Sales
SET Classificacao = CASE 
					WHEN Idade < 18 THEN 'Crian�a'
					WHEN Idade <= 55 THEN 'Adulto'
					ELSE 'Idoso'
             END;




SELECT  Classificacao,
		COUNT(DISTINCT(CLIENTE_ID)) as Quantidade,
		ROUND(CAST(COUNT(DISTINCT(CLIENTE_ID))AS float)/(SELECT COUNT(DISTINCT CLIENTE_ID) FROM SALES),2) AS PERCENTUAL,
		MIN(IDADE) AS [IDADE MIN],
		MAX(IDADE) AS [IDADE MAX],
		AVG(IDADE) AS [IDADE MED],
		round(STDEVP(IDADE),2) AS [DEVPAD]
from Sales
group by Classificacao

/* PERGUNTA 4 - Desejo saber como � o perfil de compra de cada segmenta��o de usu�rio, 
bem como o faturamento gerado por cada segmento */


select  Sexo,
		Classificacao,
		COUNT(distinct(cliente_id)) as qtd_clientes,
		COUNT(distinct(order_id)) as qtd_pedidos,
		count(T�tulo) as qtd_livros_comprados,
		round(CAST(COUNT(distinct(order_id))as float) / CAST(COUNT(distinct(cliente_id))as float),2) as m�dia_pedidos_cliente,
		round(cast( count(order_id) as float) / cast(COUNT(distinct(order_id)) as float),2) as m�dia_items_pedido,
		round(sum(pre�o)/COUNT(distinct(order_id)),2) as ticket_m�dio,
		round(sum(pre�o),2) as faturamento_tt,
		Avg(P�ginas) as m�dia_pg_livro
from Sales
group by Sexo, Classificacao
order by qtd_clientes desc


/* PERGUNTA 5 - Entre os 3 segmentos que mais compram, qual � o perfil de livro que eles gostam? */

-- Criando um tier para os 3 melhores segmentos de clientes --
ALTER TABLE Sales
ADD Tier VARCHAR(10);

UPDATE Sales
SET Tier = CASE 
					WHEN Sexo = 'Feminino' AND CLASSIFICACAO ='Adulto' THEN'Sim'
					WHEN Sexo = 'Feminino' AND CLASSIFICACAO = 'Idoso' THEN 'Sim'
					WHEN Sexo = 'Masculino' AND CLASSIFICACAO = 'Adulto' then 'Sim'
					ELSE 'N�o'
             END;


WITH TB1 AS (SELECT CLASSIFICACAO,
	   SEXO,
	   GENERO,
	   COUNT(T�TULO) AS QTD,
	   ROUND(SUM(PRE�O)/COUNT(ORDER_ID),2) AS TICKET_M�DIO,
	   AVG(P�GINAS) AS M�DIA_PGS
FROM SALES
where tier = 'Sim'
GROUP BY GENERO, SEXO, CLASSIFICACAO
),
tb2 as (SELECT SEXO, 
	   CLASSIFICACAO,
	   GENERO,
	   QTD,
	   TICKET_M�DIO,
	   M�DIA_PGS,
	   RANK() OVER (partition by sexo, classificacao ORDER BY QTD DESC) AS RANKING_QTD
FROM TB1)

select SEXO, CLASSIFICACAO, GENERO,QTD, TICKET_M�DIO, M�DIA_PGS, RANKING_QTD
FROM tb2
WHERE RANKING_QTD <6

/* PERGUTA 6 - QUAL A QUANTIDADE DE PEDIDOS, CLIENTES, ITEMS POR PEDIDO, TICKET-M�DIO POR DIA?*/

SELECT DATA AS DIA,
	   COUNT(DISTINCT(ORDER_ID)) AS QTD_PEDIDOS,
	   COUNT(DISTINCT(CLIENTE_ID)) AS QTD_CLIENTES,
	   COUNT(T�TULO) AS QTD_LIVROS_VENDIDOS,
	   SUM(PRE�O) AS FATURAMENTO,
	   SUM(PRE�O)/COUNT(DISTINCT(ORDER_ID)) AS TICKET_M�DIO
FROM SALES
GROUP BY DATA





/* PERGUNTA 7 - QUAL A M�DIA DE AVALIA��ES POR GENERO LITERARIO E POR LIVRO, BEM COMO A QUANTIDADE DE VENDAS POR LIVRO */


SELECT distinct(GENERO),
	   T�TULO,
	   AVG(Review_Score) OVER (PARTITION BY T�TULO)	 as [Bookscore],
	   AVG(Review_Score) over (partition by GENERO) as [GenderScore],
	   COUNT(T�tulo) over (partition by T�tulo) as [Qtd Vendas]
FROM Sales
order by [Qtd Vendas] DESC


/* PERGUNTA 8 - O livro ter pr�mio, afeta a quantidade de vendas? */

--Adicionando uma coluna com valores binarios para "Premiado?"

ALTER TABLE Sales
ADD Premiado VARCHAR(10);

UPDATE Sales
SET Premiado = CASE 
					WHEN Award = 'Sem Pr�mio' THEN 0
					ELSE 1
                END;



SELECT T�tulo,
	   Premiado,
	   COUNT(T�tulo) as Vendas
from Sales
group by T�tulo, Premiado
order by Vendas desc






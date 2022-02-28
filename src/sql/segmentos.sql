/*DROP TABLE IF EXISTS tb_seller_sgmt;
CREATE TABLE tb_seller_sgmt */

SELECT T1.*,
        CASE WHEN PCT_RECEITA <= 0.5 AND PCT_FREQ <= 0.5 THEN 'BAIXO V. BAIXA F.'
             WHEN PCT_RECEITA > 0.5 AND PCT_FREQ <= 0.5 THEN 'ALTO VALOR'
             WHEN PCT_RECEITA > 0.5 AND PCT_FREQ > 0.5 THEN 'ALTA FREQ' 
             WHEN PCT_RECEITA < 0.9 OR PCT_FREQ < 0.9 THEN 'PRODUTIVO'
             ELSE 'SUPER_PRODUTIVO'
             END AS 'SEGMENTO_VALOR_FREQ',
        
        CASE WHEN QTDE_DIAS_BASE <= 60 THEN 'INICIO'
             WHEN QTDE_DIAS_ULT_VENDA >= 300 THEN 'RETENCAO'
             ELSE 'ATIVO'
        END AS SEGMENTO_VIDA,

        '{date_end}' AS DT_SGMT

FROM(
                SELECT T1.*,
                        PERCENT_RANK() OVER( ORDER BY RECEITA_TOTAL ASC ) AS PCT_RECEITA,
                        PERCENT_RANK() OVER( ORDER BY QTDE_PEDIDOS ASC ) AS PCT_FREQ
                FROM(
                                SELECT T2.seller_id,
                                        SUM(T2.price) AS RECEITA_TOTAL,
                                        COUNT(DISTINCT T1.order_id) AS QTDE_PEDIDOS,
                                        COUNT(T2.product_id) AS QTDE_PRODUTOS,
                                        COUNT(DISTINCT T2.product_id) AS QTDE_PRODUTOS_DIST,
                                        MIN( CAST( julianday('{date_end}') - julianday(T1.order_approved_at) AS INT ) ) AS QTDE_DIAS_ULT_VENDA,
                                        MAX( CAST( julianday('{date_end}') - julianday(dt_inicio) AS INT ) ) AS qtde_dias_base
                                FROM tb_orders AS T1
                                        LEFT JOIN tb_order_items AS T2 ON T1.order_id = T2.order_id
                                        LEFT JOIN ( SELECT T2.seller_id,
                                                        MIN(DATE (T1.order_approved_at)) AS dt_inicio
                                                FROM tb_orders as T1
                                                        LEFT JOIN tb_order_items AS T2 ON T1.order_id = T2.order_id
                                                GROUP BY T2.seller_id
                                        ) AS T3 ON T2.seller_id = T3.seller_id
                                WHERE T1.order_approved_at BETWEEN '{date_init}' AND '{date_end}'
                                GROUP BY T2.seller_id
                        ) AS T1
        ) AS T1

WHERE seller_id IS NOT NULL
;

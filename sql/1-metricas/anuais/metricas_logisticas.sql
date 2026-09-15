CREATE OR REPLACE TABLE metricas_logisticas AS 

----------------------------------------------------------------------------------
-- Resumo das métricas:

-- dist_base_principal_km   : Distância (km) do município até a base principal, em betim
-- dist_base_oliveira_km    : Distância (km) do município até a base em Oliveira
-- dist_base_atendimento_km : Distância (km) do município até a base responsável pelo atendimento do município
-- dist_refinaria_regap_km  : Distância do município até a REGAP
-- dist_refinaria_replan_km : Distância do município até a REPLAN
-- dist_referencia_km       : Limite empírico de operação aceitável (distância base-município)
-- base_atendimento         : Nome da base responsável (Betim ou Oliveira) pelo atendimento do município
-- refinaria_mais_proxima   : Nome da refinaria geograficamente mais próxima
----------------------------------------------------------------------------------

WITH 
    base AS (
        SELECT 
            m.id_municipio,

            -- IDs e nomes das bases
            b_principal.nome_base  AS nome_base_principal,
            b_principal.id_base    AS id_base_principal,

            b_oliveira.nome_base   AS nome_base_oliveira,
            b_oliveira.id_base     AS id_base_oliveira,

            -- Distância Haversine do município selecionado até Betim:
            (6371 * 2 * ASIN(
                SQRT(
                    POWER(SIN(RADIANS(m.latitude - b_principal.latitude) / 2), 2)
                    +
                    COS(RADIANS(b_principal.latitude))
                    * COS(RADIANS(m.latitude))
                    * POWER(SIN(RADIANS(m.longitude - b_principal.longitude) / 2), 2)
                )
            )) AS dist_base_principal_km,

            -- Distância Haversine do município selecionado até Oliveira:
            (6371 * 2 * ASIN(
                SQRT(
                    POWER(SIN(RADIANS(m.latitude - b_oliveira.latitude) / 2), 2)
                    +
                    COS(RADIANS(b_oliveira.latitude))
                    * COS(RADIANS(m.latitude))
                    * POWER(SIN(RADIANS(m.longitude - b_oliveira.longitude) / 2), 2)
                )
            )) AS dist_base_oliveira_km

        FROM coordenadas_municipios m

        LEFT JOIN bases_logisticas b_principal
            ON b_principal.id_base = '01'

        LEFT JOIN bases_logisticas b_oliveira
            ON b_oliveira.id_base = '02'
    ),
    ---------------------------------------------------------------------
    dist_refinarias AS (
        SELECT
            m.id_municipio,

            -- IDs e nomes das refinarias
            regap.id_refinaria     AS id_refinaria_regap,
            regap.nome_refinaria   AS nome_refinaria_regap,

            replan.id_refinaria    AS id_refinaria_replan,
            replan.nome_refinaria  AS nome_refinaria_replan,

            (6371 * 2 * ASIN(
                SQRT(
                    POWER(SIN(RADIANS(m.latitude - regap.latitude) / 2), 2)
                    +
                    COS(RADIANS(regap.latitude))
                    * COS(RADIANS(m.latitude))
                    * POWER(SIN(RADIANS(m.longitude - regap.longitude) / 2), 2)
                )
            )) AS dist_refinaria_regap_km,

            (6371 * 2 * ASIN(
                SQRT(
                    POWER(SIN(RADIANS(m.latitude - replan.latitude) / 2), 2)
                    +
                    COS(RADIANS(replan.latitude))
                    * COS(RADIANS(m.latitude))
                    * POWER(SIN(RADIANS(m.longitude - replan.longitude) / 2), 2)
                )
            )) AS dist_refinaria_replan_km

        FROM coordenadas_municipios m

        LEFT JOIN refinarias regap
            ON regap.id_refinaria = '01'
        
        LEFT JOIN refinarias replan
            ON replan.id_refinaria = '02'
    ),
    ---------------------------------------------------------------------
    dist_municipio_base AS (
        SELECT 
            *,

            LEAST(
                dist_base_principal_km,
                dist_base_oliveira_km
            ) AS dist_base_atendimento_km

        FROM base
    ),
    ---------------------------------------------------------------------
    municipios AS (
        SELECT
            d.id_municipio,
            d.dist_base_atendimento_km

        FROM dist_municipio_base d

        INNER JOIN municipios_atendidos a
            ON d.id_municipio = a.id_municipio
        
        WHERE a.atendido = TRUE
    ),
    ---------------------------------------------------------------------
    dist_referencia AS (
        SELECT
            -- Calcula a distância de referência município-base
            -- com base nos municípios atendidos (percentil 90%)
            quantile_cont(
                dist_base_atendimento_km,
                0.90
            ) AS dist_referencia_km

        FROM municipios
    )

SELECT 
    d.*,
    dr.dist_referencia_km,

    ---------------------------------------------------------------------
    -- Informações sobre as bases logísticas

    CASE
        WHEN d.dist_base_principal_km <= d.dist_base_oliveira_km
            THEN d.nome_base_principal
        ELSE d.nome_base_oliveira
    END AS base_atendimento,

    ---------------------------------------------------------------------
    -- Informações sobre as refinarias

    r.dist_refinaria_regap_km,
    r.dist_refinaria_replan_km,

    CASE
        WHEN r.dist_refinaria_regap_km <= r.dist_refinaria_replan_km
            THEN r.nome_refinaria_regap
        ELSE r.nome_refinaria_replan
    END AS refinaria_mais_proxima

FROM dist_municipio_base d

CROSS JOIN dist_referencia dr

LEFT JOIN dist_refinarias r
    ON d.id_municipio = r.id_municipio;

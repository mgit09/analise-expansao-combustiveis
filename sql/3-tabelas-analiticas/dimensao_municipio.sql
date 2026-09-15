-- Essa tabela unifica os dados estruturais e geográficos de dimensão da entidade município

CREATE OR REPLACE TABLE dimensao_municipio AS

SELECT DISTINCT
    m.*,

    c.latitude,
    c.longitude,

    ---------------------------------------------------------------------
    -- Informações sobre as bases logísticas

    ml.dist_base_oliveira_km,
    ml.dist_base_principal_km,
    ml.base_atendimento,

    CASE 
        WHEN bl.id_municipio IS NOT NULL
            THEN 'sim'
        
        ELSE 'nao'

    END AS tem_base_logistica_no_municipio,

    ---------------------------------------------------------------------
    -- Informações sobre as refinarias

    ml.dist_refinaria_regap_km,
    ml.dist_refinaria_replan_km,
    ml.refinaria_mais_proxima,

    CASE
        WHEN r.id_municipio IS NOT NULL
            THEN 'sim'
        
        ELSE 'nao'
    
    END AS tem_refinaria_no_municipio,

    ---------------------------------------------------------------------
    -- Status de atendimento (atendidos, não atendidos e fora do escopo)

    CASE 
        WHEN a.id_municipio IS NOT NULL
            THEN 'atendido'

        WHEN m.id_uf IN ('31', '32', '33', '35')
            THEN 'nao_atendido'

        ELSE 'fora_do_escopo'
    
    END AS status_atendimento

FROM municipios m

LEFT JOIN coordenadas_municipios c
    ON m.id_municipio = c.id_municipio

LEFT JOIN municipios_atendidos a
    ON m.id_municipio = a.id_municipio

LEFT JOIN metricas_logisticas ml
    ON m.id_municipio = ml.id_municipio

LEFT JOIN bases_logisticas bl
    ON m.id_municipio = bl.id_municipio

LEFT JOIN refinarias r
    ON m.id_municipio = r.id_municipio;

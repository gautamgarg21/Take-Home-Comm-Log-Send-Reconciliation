WITH RECURSIVE campaign_tree AS (
    SELECT id AS campaign_id, id AS root_campaign_id
    FROM campaign
    WHERE parent_id IS NULL

    UNION ALL

    SELECT c.id AS campaign_id, ct.root_campaign_id
    FROM campaign c
    JOIN campaign_tree ct ON c.parent_id = ct.campaign_id
),
chain_counts AS (
    SELECT root_campaign_id, COUNT(*) AS chain_size
    FROM campaign_tree
    GROUP BY root_campaign_id
),
valid_logs AS (
    SELECT 
        cl.id AS log_id,
        ct.root_campaign_id,
        cl.customer_id,
        cc.chain_size
    FROM communication_log cl
    JOIN campaign c ON cl.communication_id = c.id
    JOIN campaign_tree ct ON cl.communication_id = ct.campaign_id
    JOIN chain_counts cc ON ct.root_campaign_id = cc.root_campaign_id
    WHERE c.creation_status != 'approval_awaiting'
      AND c.processing_status = 'processed'
)
SELECT 
    COUNT(DISTINCT CASE WHEN chain_size > 1 THEN root_campaign_id || '-' || customer_id END) +
    COUNT(CASE WHEN chain_size = 1 THEN log_id END) AS target_base
FROM valid_logs;

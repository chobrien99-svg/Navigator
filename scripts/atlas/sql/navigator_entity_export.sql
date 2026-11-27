-- Export what Navigator holds about one organisation, for the Atlas `navigator` source.
-- Replace :slug with the organisation slug (e.g. 'nvidia'), run, and save the single JSON value
-- to data/atlas_runs/entity-<key>/navigator_export.json.
WITH o AS (SELECT * FROM organizations WHERE slug = :slug)
SELECT json_build_object(
  'exported_at', now(),
  'organization', (SELECT json_build_object('id', id, 'name', name, 'slug', slug) FROM o),
  'legal_entities', (SELECT coalesce(json_agg(json_build_object('siren', siren, 'legal_name', legal_name, 'incorporation_date', incorporation_date)), '[]')
                     FROM legal_entities WHERE organization_id = (SELECT id FROM o)),
  'investments', (SELECT coalesce(json_agg(json_build_object('round_id', r.id, 'company', c.name, 'stage', r.stage,
                     'date', r.announced_date, 'amount_eur_m', r.amount_eur, 'is_lead', i.is_lead) ORDER BY r.announced_date), '[]')
                  FROM funding_round_investors i JOIN funding_rounds r ON r.id = i.funding_round_id
                  JOIN organizations c ON c.id = r.organization_id
                  WHERE i.investor_id IN (SELECT id FROM o UNION
                        SELECT source_org_id FROM organization_relationships WHERE target_org_id = (SELECT id FROM o) AND relationship_type = 'subsidiary_of')),
  'relationships', (SELECT coalesce(json_agg(json_build_object('id', x.id, 'type', x.relationship_type,
                       'direction', CASE WHEN x.source_org_id = (SELECT id FROM o) THEN 'to' ELSE 'from' END,
                       'other', oo.name, 'description', x.description, 'start_date', x.start_date)), '[]')
                    FROM organization_relationships x
                    JOIN organizations oo ON oo.id = CASE WHEN x.source_org_id = (SELECT id FROM o) THEN x.target_org_id ELSE x.source_org_id END
                    WHERE (SELECT id FROM o) IN (x.source_org_id, x.target_org_id)),
  'rounds', (SELECT coalesce(json_agg(json_build_object('id', id, 'stage', stage, 'date', announced_date, 'closed_date', closed_date,
                'amount_eur_m', amount_eur, 'source_url', source_url) ORDER BY announced_date), '[]')
             FROM funding_rounds WHERE organization_id = (SELECT id FROM o)),
  'patents', (SELECT coalesce(json_agg(json_build_object('number', patent_number, 'title', title, 'url', url)), '[]')
              FROM patents WHERE organization_id = (SELECT id FROM o)),
  'events', (SELECT coalesce(json_agg(json_build_object('id', id, 'type', event_type, 'title', title, 'date', event_date, 'description', description, 'source_url', source_url)), '[]')
             FROM organization_events WHERE organization_id = (SELECT id FROM o)),
  'grants', (SELECT coalesce(json_agg(json_build_object('id', id, 'grant_name', grant_name, 'granting_body', granting_body,
                'amount_eur', amount_eur, 'awarded_date', awarded_date, 'source_url', source_url)), '[]')
             FROM grants WHERE organization_id = (SELECT id FROM o)),
  'projects', (SELECT coalesce(json_agg(json_build_object('slug', p.slug, 'name', p.name, 'role', l.role, 'start_date', l.start_date, 'website_url', p.website_url)), '[]')
               FROM project_links l JOIN projects p ON p.id = l.project_id WHERE l.organization_id = (SELECT id FROM o)),
  'programs', (SELECT coalesce(json_agg(json_build_object('edition_id', e.id, 'program', pg.name, 'role', po.membership_role)), '[]')
               FROM program_organizations po JOIN program_editions e ON e.id = po.program_edition_id
               JOIN programs pg ON pg.id = e.program_id WHERE po.organization_id = (SELECT id FROM o)),
  'articles_count', (SELECT count(*) FROM article_organizations WHERE organization_id = (SELECT id FROM o)),
  'known_urls', (SELECT coalesce(json_agg(DISTINCT u), '[]') FROM (
       SELECT p.website_url u FROM project_links l JOIN projects p ON p.id = l.project_id WHERE l.organization_id = (SELECT id FROM o)
       UNION SELECT a.url FROM article_organizations ao JOIN articles a ON a.id = ao.article_id WHERE ao.organization_id = (SELECT id FROM o)
       UNION SELECT source_url FROM grants WHERE organization_id = (SELECT id FROM o)
       UNION SELECT source_url FROM organization_events WHERE organization_id = (SELECT id FROM o)) k WHERE u IS NOT NULL)
) AS export;

CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 4: Create legal_entities for orgs with SIREN (37)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"name": "Verkor", "siren": "888047792"}, {"name": "Cosmobilis", "siren": "904723715"}, {"name": "Lydia", "siren": "884748898"}, {"name": "NEoT", "siren": "821239670"}, {"name": "Oui Care", "siren": "833520075"}, {"name": "Constellation", "siren": "820764454"}, {"name": "Lhyfe", "siren": "850415290"}, {"name": "Agronutris", "siren": "850855644"}, {"name": "Artur'In", "siren": "821012382"}, {"name": "Quantum Surgical", "siren": "824393003"}, {"name": "Skaleet", "siren": "484939038"}, {"name": "VOLTA Entreprises", "siren": "843587031"}, {"name": "Groupe INTM", "siren": "453207243"}, {"name": "Solstyce", "siren": "519589402"}, {"name": "Easiware", "siren": "508636537"}, {"name": "Ynsect", "siren": "534948617"}, {"name": "Tolv", "siren": "853875276"}, {"name": "Cocolis", "siren": "813144797"}, {"name": "OneWave", "siren": "821237815"}, {"name": "Polkally", "siren": "898587241"}, {"name": "UniFox", "siren": "902214808"}, {"name": "Vneuron", "siren": "845349935"}, {"name": "VISEO", "siren": "420798100"}, {"name": "Qonto", "siren": "819489626"}, {"name": "Prophesee", "siren": "800681892"}, {"name": "PLAYERS", "siren": "523860658"}, {"name": "Onestock", "siren": "529042376"}, {"name": "Mediawan", "siren": "815286398"}, {"name": "La Fourche", "siren": "839765062"}, {"name": "Infra", "siren": "314583543"}, {"name": "iDealwine", "siren": "431661628"}, {"name": "Elum Energy", "siren": "817860083"}, {"name": "BienManger", "siren": "533172094"}, {"name": "AssessFirst", "siren": "443179684"}, {"name": "Asobo Studio", "siren": "443752795"}, {"name": "AMI Paris", "siren": "527636609"}, {"name": "Advens", "siren": "433428018"}]$json$
  ) AS (name TEXT, siren TEXT)
)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  o.id,
  s.name,
  s.siren,
  'France',
  TRUE,
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = s.siren
);

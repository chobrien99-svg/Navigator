-- Atlas entity load: Iktos (iktos)
-- Run: 2026-11-18; accepted findings by type: {"establishment": 5, "legal_notice": 20}
-- Idempotent: legacy_source 'atlas:entity:iktos' / NOT EXISTS guards.
BEGIN;

-- registry:establishment:82318927900016
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'expansion'::event_type, '2016-10-17'::date, 'Opens a site in Paris', 'IKTOS (IKTOS): Opened 2016-10-17, closed 2019-06-19. Address: 61 RUE BLOMET 75015 PARIS', 'https://annuaire-entreprises.data.gouv.fr/entreprise/823189279', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:iktos', 'registry:establishment:82318927900016', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:82318927900016');
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2019-06-19'::date, 'Closes its site in Paris', 'IKTOS (IKTOS): site opened 2016-10-17, closed 2019-06-19.', 'https://annuaire-entreprises.data.gouv.fr/entreprise/823189279', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:iktos', 'registry:establishment:82318927900016:closed', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:82318927900016:closed');

-- registry:establishment:82318927900024
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'expansion'::event_type, '2019-06-19'::date, 'Opens a site in Paris', 'IKTOS (IKTOS): Opened 2019-06-19, open. Address: 65 RUE DE PRONY 75017 PARIS', 'https://annuaire-entreprises.data.gouv.fr/entreprise/823189279', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:iktos', 'registry:establishment:82318927900024', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:82318927900024');

-- registry:establishment:82318927900032
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'expansion'::event_type, '2022-07-01'::date, 'Opens a site in Villebon-Sur-Yvette', 'IKTOS (IKTOS): Opened 2022-07-01, closed 2026-08-03. Address: 25-27-BATIMENT B 25 AVENUE DU QUEBEC 91140 VILLEBON-SUR-YVETTE', 'https://annuaire-entreprises.data.gouv.fr/entreprise/823189279', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:iktos', 'registry:establishment:82318927900032', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:82318927900032');
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2026-08-03'::date, 'Closes its site in Villebon-Sur-Yvette', 'IKTOS (IKTOS): site opened 2022-07-01, closed 2026-08-03.', 'https://annuaire-entreprises.data.gouv.fr/entreprise/823189279', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:iktos', 'registry:establishment:82318927900032:closed', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:82318927900032:closed');

-- registry:establishment:82318927900040
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'expansion'::event_type, '2024-06-28'::date, 'Opens a site in Evry-Courcouronnes', 'IKTOS (IKTOS): Opened 2024-06-28, open. Address: BATIMENT MAUPERTUIS RUE DU PERE ANDRE JARLAN 91000 EVRY-COURCOURONNES', 'https://annuaire-entreprises.data.gouv.fr/entreprise/823189279', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:iktos', 'registry:establishment:82318927900040', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:82318927900040');

-- registry:establishment:82318927900057
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'expansion'::event_type, '2026-08-03'::date, 'Opens a site in Longjumeau', 'IKTOS (IKTOS): Opened 2026-08-03, open. Address: BATIMENT B9 1 E RUE PDT FRANCOIS MITTERRAND 91160 LONGJUMEAU', 'https://annuaire-entreprises.data.gouv.fr/entreprise/823189279', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:iktos', 'registry:establishment:82318927900057', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:82318927900057');

-- bodacc:legal_notice:A20160212976
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2016-10-28'::date, 'Créations: Iktos', 'Immatriculation d''une personne morale (B, C, D) suite à création d''un établissement principal', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:A20160212976', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:A20160212976', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:A20160212976');

-- bodacc:legal_notice:B20170146695
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2017-08-02'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B20170146695', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B20170146695', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B20170146695');

-- bodacc:legal_notice:B201800211135
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2018-01-31'::date, 'Modifications diverses: Iktos', 'modification survenue sur la forme juridique et l''administration', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B201800211135', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B201800211135', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B201800211135');

-- bodacc:legal_notice:B201800211136
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2018-01-31'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B201800211136', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B201800211136', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B201800211136');

-- bodacc:legal_notice:B201901551273
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2019-08-13'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation), l''adresse du siège, l''adresse de l''établissement et l''administration', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B201901551273', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B201901551273', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B201901551273');

-- bodacc:legal_notice:B202100522257
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2021-03-16'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202100522257', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202100522257', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202100522257');

-- bodacc:legal_notice:B202101142040
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2021-06-13'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202101142040', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202101142040', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202101142040');

-- bodacc:legal_notice:B202101942597
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2021-10-05'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202101942597', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202101942597', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202101942597');

-- bodacc:legal_notice:B202200582010
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2022-03-23'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202200582010', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202200582010', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202200582010');

-- bodacc:legal_notice:B202201082011
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2022-06-03'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202201082011', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202201082011', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202201082011');

-- bodacc:legal_notice:B202201823570
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2022-09-20'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202201823570', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202201823570', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202201823570');

-- bodacc:legal_notice:B202202151885
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2022-11-04'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202202151885', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202202151885', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202202151885');

-- bodacc:legal_notice:B202300862395
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2023-05-02'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation), la forme juridique, l''administration et le représentant permanent', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202300862395', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202300862395', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202300862395');

-- bodacc:legal_notice:B202301343348
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2023-07-13'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202301343348', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202301343348', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202301343348');

-- bodacc:legal_notice:B202401092101
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2024-06-07'::date, 'Modifications diverses: Iktos', 'modification survenue sur l''administration', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202401092101', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202401092101', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202401092101');

-- bodacc:legal_notice:B202401141159
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2024-06-14'::date, 'Modifications diverses: Iktos', 'modification survenue sur l''administration', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202401141159', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202401141159', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202401141159');

-- bodacc:legal_notice:B202401141160
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2024-06-14'::date, 'Modifications diverses: Iktos', 'modification survenue sur le capital (augmentation)', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202401141160', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202401141160', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202401141160');

-- bodacc:legal_notice:B202401192173
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2024-06-21'::date, 'Modifications diverses: Iktos', 'modification survenue sur le représentant permanent', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202401192173', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202401192173', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202401192173');

-- bodacc:legal_notice:B202600726264
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2026-04-15'::date, 'Modifications diverses: Iktos', 'modification survenue sur l''administration', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202600726264', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202600726264', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202600726264');

-- bodacc:legal_notice:B202601791944
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'other'::event_type, '2026-09-18'::date, 'Modifications diverses: Iktos', 'modification survenue sur l''administration', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202601791944', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:iktos', 'bodacc:legal_notice:B202601791944', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202601791944');

COMMIT;

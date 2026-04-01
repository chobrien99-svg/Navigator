# Unified Intelligence Database Handoff

## Executive recommendation

Yes. The recommended path is to create a **third Supabase database / project** as the new canonical core, build the optimized schema there from scratch, and then migrate data from the two existing databases into it.

Why this is the right move now:

- neither product is live yet
- the AI Radar database only has 6 test startups
- the Funding Tracker is still early and can be migrated before production usage
- rebuilding now is much cheaper than retrofitting later
- it lets you avoid years of schema drift, duplicate entities, and painful identity resolution

This new database should be designed as a **unified intelligence core** that can power:

- French AI Radar
- Funding Tracker
- future grants / patents / public data modules
- a broader French intelligence hub
- future European expansion

---

## Core architectural decision

### Canonical top-level entity
Use `organizations` as the core table, not `startups` or `companies`.

Reason:
- startups are organizations
- corporates are organizations
- investors are organizations
- accelerators are organizations
- universities / labs are organizations
- public bodies are organizations

This gives the system room to evolve into a real ecosystem intelligence graph.

### Product language vs database language

User-facing product language can still say:
- startup
- founder
- startup profile
- startup signals

But the underlying schema should use:
- organizations
- people
- legal_entities
- organization_events
- organization_relationships

This keeps the core flexible while allowing the Radar product to remain simple and intuitive.

---

## Final canonical schema target

### 1. Core entity layer

#### organizations
Main tracked object across the ecosystem.

Key fields:
- id
- name
- slug
- organization_type
- description
- short_description
- website
- email
- phone
- linkedin_url
- twitter_url
- logo_url
- status
- country
- city_id
- founded_date
- first_seen_at
- is_stealth
- created_at
- updated_at

Recommended organization_type values:
- startup
- corporate
- investor
- accelerator
- incubator
- university
- research_lab
- public_agency
- nonprofit
- media
- other

#### legal_entities
Formal legal identity layer.

Key fields:
- id
- organization_id
- legal_name
- legal_form
- siren
- siret
- capital_eur
- incorporation_date
- registered_city
- country
- is_primary
- created_at
- updated_at

#### cities
Normalized city table.

#### people
Canonical people table.

Key fields:
- id
- full_name
- slug
- linkedin_url
- twitter_url
- email
- bio
- photo_url
- has_phd
- is_repeat_founder
- has_big_tech_background
- big_tech_employer
- academic_lab
- previous_exits
- created_at
- updated_at

#### organization_people
Join table between people and organizations.

#### person_experience
Historical person/company history.

### 2. Classification layer

#### sectors
Structured taxonomy.

#### organization_sectors
Join table linking organizations to sectors.

#### organization_tags
Flexible labels for non-taxonomy categorization.

### 3. Intelligence layer

#### signals
Early indicators / evidence.

Key fields:
- id
- organization_id
- signal_type
- signal_date
- strength
- title
- description
- source_type
- source_name
- source_url
- confidence_score
- verification_status
- created_at
- updated_at

#### organization_events
Structured dated events.

Key fields:
- id
- organization_id
- event_type
- event_date
- strength
- title
- description
- created_at
- updated_at

#### organization_relationships
Graph relationships between organizations.

#### products
Products or product lines.

#### organization_profiles
Analyst / editorial layer.

Key fields:
- organization_id
- what_they_are_building
- why_it_matters
- investor_brief
- analyst_note
- updated_at

### 4. Capital and ecosystem layer

#### funding_rounds
#### funding_round_investors
#### articles
#### article_organizations
#### patents
#### patent_inventors
#### grants (future-ready)

### 5. User / product layer

#### profiles
#### watchlist
#### alerts
#### lists
#### list_items
#### saved_searches

---

## What should come from each existing database

### From Funding Tracker (base foundation)
Use as source for:
- companies -> organizations
- people -> people
- company_people -> organization_people
- cities -> cities
- sectors -> sectors
- company_sectors -> organization_sectors
- funding_rounds -> funding_rounds
- funding_round_investors -> funding_round_investors
- investors -> either organizations or keep temporary investor model
- articles -> articles
- article_companies -> article_organizations
- patents -> patents
- patent_inventors -> patent_inventors

### From AI Radar (missing intelligence/product layer)
Use as source for:
- startups -> organizations
- founders -> enrich / merge into people
- startup_founders -> organization_people
- founder_startups -> person_experience
- legal_entities -> legal_entities
- signals -> signals
- startup_events -> organization_events
- startup_relationships -> organization_relationships
- products -> products
- profiles -> profiles
- watchlist -> watchlist
- alerts -> alerts
- lists -> lists
- list_items -> list_items
- saved_searches -> saved_searches
- startup_tags -> organization_tags

---

## Migration recommendation

### Strong recommendation
Create a **new third Supabase project/database** with the final canonical schema.

Do not try to mutate one of the current databases in place.

Reason:
- safer
- easier rollback
- cleaner SQL
- easier to test
- no fear of breaking old structures while migrating

### Recommended approach

1. create the new unified database
2. create the canonical schema there
3. add temporary migration helper fields where useful, such as:
   - legacy_source
   - legacy_id
4. migrate Funding Tracker data first
5. migrate AI Radar data second
6. manually reconcile the 6 Radar startups if needed
7. create product views for Radar and Funding Tracker
8. repoint both frontends to the new database
9. archive the old databases

---

## Why a third database is preferable

### Pros
- you start clean with the right schema
- no destructive schema surgery on current projects
- easier to test and compare old vs new
- easier to rerun migration scripts
- lets you preserve old projects as backups until cutover
- better for team confidence and rollback

### Cons
- short-term setup overhead
- one-time migration work
- temporary duplication during transition

### Bottom line
Because you are still pre-launch, the pros heavily outweigh the cons.

---

## Migration order

### Phase 1: schema build
Create the canonical schema in the new database.

### Phase 2: foundational data
Import:
- cities
- sectors
- organizations from Funding Tracker
- people from Funding Tracker

### Phase 3: legal and relationship data
Import:
- legal_entities
- organization_people
- organization_sectors

### Phase 4: intelligence data
Import:
- signals
- organization_events
- organization_relationships
- products
- articles
- patents
- funding_rounds

### Phase 5: user/product data
Import:
- profiles
- watchlist
- alerts
- lists
- list_items
- saved_searches

### Phase 6: Radar startup reconciliation
Map the 6 Radar startups into canonical organizations.
This can be done manually if needed.

### Phase 7: views
Create frontend-ready views such as:
- v_radar_startups
- v_startup_profile
- v_signal_feed
- v_radar_stats
- v_funding_complete
- v_funding_stats

### Phase 8: cutover
Point the Radar frontend to the new DB first.
Later point the Funding Tracker frontend to the same DB.

---

## Key implementation principles

### 1. Do not overwrite current tables
Keep old databases untouched during migration.

### 2. Build in parallel
The new database is the target. The old ones are source systems.

### 3. Use mapping tables if helpful
Examples:
- organization_merge_map
- person_merge_map

### 4. Preserve provenance
Where possible, keep source metadata for migrated records.

### 5. Validate before cutover
Check:
- row counts
- spot checks
- legal entity matching
- founder/person matching
- funding totals
- startup profile outputs

---

## Recommended next steps

1. approve the canonical schema design
2. decide whether investor organizations should be represented directly in `organizations` from day one or temporarily remain separate
3. generate SQL DDL for the new database
4. prepare migration mapping tables
5. migrate sample data and validate
6. migrate full data
7. connect Radar frontend to unified DB

---

## Final recommendation

Yes: create a **third, new, unified Supabase database** from the ground up.

That should become the only long-term source of truth.

Then:
- migrate Funding Tracker data into it
- migrate AI Radar data into it
- point the AI Radar frontend at it for launch
- continue evolving the broader intelligence hub on the same foundation

This is the cleanest and most flexible path.


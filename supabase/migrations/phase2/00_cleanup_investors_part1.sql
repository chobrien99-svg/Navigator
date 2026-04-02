-- =============================================================================
-- INVESTOR CLEANUP PART 1: Delete description-as-name records
-- Run in the FUNDING TRACKER SQL Editor
-- =============================================================================
-- These are not real investors — they are descriptions/notes stored as names.
-- First reassign any funding_round_investors references, then delete.
-- =============================================================================

-- Step 1: Check which of these have funding_round_investors references
SELECT fri.id, fri.funding_round_id, i.name
FROM funding_round_investors fri
JOIN investors i ON i.id = fri.investor_id
WHERE i.id IN (
  'bb6b7f3e-ba54-470c-9ed8-bbdf1251cbe2',  -- "backed by Hexa startup-studio support"
  'b31d2bdd-0bee-43c3-9bc0-fa1248fdccc8',  -- "managed on behalf of the French State by Bpifrance..."
  'd9244e8e-91c6-4d0a-8441-bb2ea2d2e0e8',  -- "Multiple business angel groups..."
  'd3633da1-a8c3-46d2-912a-6651c73e242b',  -- "Regional France 2030 (Bpifrance)"
  '9a430454-9da7-4f2a-a2a0-6fdc52d92950',  -- "the French Tech Seed fund by Bpifrance..."
  '52619ad5-2f0c-48ee-9b41-fe8a7cc982a6',  -- "with additional public support from Bpifrance..."
  '8c614fc3-7d91-4b47-a4f5-a1c3245bd501',  -- "with banking support from Bpifrance"
  '5c04dbc9-0b14-471e-aa3c-d951d29e5b7f',  -- "with public support from France 2030..."
  'eb0f5381-8fcd-4847-b38d-5b2519762ae2',  -- "managed by Demeter Investment Managers"
  '6884c628-9f89-4aba-ace1-6749f10fac5c',  -- "managed by UI Investissement)"
  '3e51b124-8850-4bfc-baa1-e52d7889d292',  -- "Eurazeo and the Ecotechnologies 2 fund"
  '31596dd9-4032-4939-8f14-65215c4f25b1',  -- "Entrepreneurs from the Loire region"
  '4b0896fc-e901-47d3-9a65-01c0c8511b74',  -- "Crowdfunding via WiSeed"
  '969f951c-298f-44e9-9440-c2445e5921be',  -- "Armand Bensussan; bank partners..."
  'f764183a-949b-4829-8076-8bbcc6502498',  -- "Emblem; existing investors..."
  '6f7fbaf8-7b42-49ab-900c-c96af2316993',  -- "France Active Pays de la Loire et du programme..."
  '7757259a-e31d-48c6-b993-69490a6b6e42',  -- "Caisse d'Epargne Bourgogne Franche-Comté (debt partners)"
  '1aadebfc-0867-479e-830f-2d22760c9d93',  -- "Finovam Gestion et ILP"
  'aa4178c5-48eb-4f56-8973-048aeefaaa24',  -- "OVNI Capital WEPA Ventures"
  '7c69879a-60e3-412f-bd32-949f58e7f8ac',  -- "UI Investissement; IRD INVEST"
  '823a329f-e84c-401f-8746-f470d8672150',  -- "Fonds Régional Avenir Industrie..."
  '5e1369e4-0c3d-4403-bfae-e1012da3c941',  -- "Sud Mer Invest (Banque Populaire du Sud"
  'e1764e09-bc69-438b-9f93-bf629ac58cd5',  -- "Racine2 (operated by Serena and makesense)"
  '1ff09033-6db8-4837-9faa-d43b6f2533ab',  -- "Elevation Capital Partners (equity)"
  '9e6dcba2-3905-4262-9b07-d997dd1ff628',  -- "Crédit Mutuel Impact – Fonds Révolution..."
  '4688d45d-caba-4b93-a59b-aa9dafefe58f',  -- "Demeter (via the Fonds d'Amorçage...)"
  '71b163d4-91e0-48bc-85cb-486daafc5583',  -- "MH Innov'–Elaia partnership fund"
  'ab776b33-d3a1-4ac3-b542-e4b862bb1a87',  -- "Lazard Elaia Capital"
  '18238560-b3b5-4ebd-9801-b626a04f1eb2',  -- "Ledger Cathay Capital"
  '2c3c0b70-6c17-4530-95f2-4719ab22026f',  -- "Morgan Stanley Expansion Capital"
  'e2c5c81c-f5dd-4661-83d9-4f59116260d8',  -- "Odyssée Venture Business Angels Europe"
  '5e0ef0f7-b80a-456b-95ba-831e39201537'   -- "Sorbonne Venture by Audacia"
);

-- Step 2: Delete funding_round_investors references for these
DELETE FROM funding_round_investors
WHERE investor_id IN (
  'bb6b7f3e-ba54-470c-9ed8-bbdf1251cbe2',
  'b31d2bdd-0bee-43c3-9bc0-fa1248fdccc8',
  'd9244e8e-91c6-4d0a-8441-bb2ea2d2e0e8',
  'd3633da1-a8c3-46d2-912a-6651c73e242b',
  '9a430454-9da7-4f2a-a2a0-6fdc52d92950',
  '52619ad5-2f0c-48ee-9b41-fe8a7cc982a6',
  '8c614fc3-7d91-4b47-a4f5-a1c3245bd501',
  '5c04dbc9-0b14-471e-aa3c-d951d29e5b7f',
  'eb0f5381-8fcd-4847-b38d-5b2519762ae2',
  '6884c628-9f89-4aba-ace1-6749f10fac5c',
  '3e51b124-8850-4bfc-baa1-e52d7889d292',
  '31596dd9-4032-4939-8f14-65215c4f25b1',
  '4b0896fc-e901-47d3-9a65-01c0c8511b74',
  '969f951c-298f-44e9-9440-c2445e5921be',
  'f764183a-949b-4829-8076-8bbcc6502498',
  '6f7fbaf8-7b42-49ab-900c-c96af2316993',
  '7757259a-e31d-48c6-b993-69490a6b6e42',
  '1aadebfc-0867-479e-830f-2d22760c9d93',
  'aa4178c5-48eb-4f56-8973-048aeefaaa24',
  '7c69879a-60e3-412f-bd32-949f58e7f8ac',
  '823a329f-e84c-401f-8746-f470d8672150',
  '5e1369e4-0c3d-4403-bfae-e1012da3c941',
  'e1764e09-bc69-438b-9f93-bf629ac58cd5',
  '1ff09033-6db8-4837-9faa-d43b6f2533ab',
  '9e6dcba2-3905-4262-9b07-d997dd1ff628',
  '4688d45d-caba-4b93-a59b-aa9dafefe58f',
  '71b163d4-91e0-48bc-85cb-486daafc5583',
  'ab776b33-d3a1-4ac3-b542-e4b862bb1a87',
  '18238560-b3b5-4ebd-9801-b626a04f1eb2',
  '2c3c0b70-6c17-4530-95f2-4719ab22026f',
  'e2c5c81c-f5dd-4661-83d9-4f59116260d8',
  '5e0ef0f7-b80a-456b-95ba-831e39201537'
);

-- Step 3: Delete the junk investor records
DELETE FROM investors
WHERE id IN (
  'bb6b7f3e-ba54-470c-9ed8-bbdf1251cbe2',
  'b31d2bdd-0bee-43c3-9bc0-fa1248fdccc8',
  'd9244e8e-91c6-4d0a-8441-bb2ea2d2e0e8',
  'd3633da1-a8c3-46d2-912a-6651c73e242b',
  '9a430454-9da7-4f2a-a2a0-6fdc52d92950',
  '52619ad5-2f0c-48ee-9b41-fe8a7cc982a6',
  '8c614fc3-7d91-4b47-a4f5-a1c3245bd501',
  '5c04dbc9-0b14-471e-aa3c-d951d29e5b7f',
  'eb0f5381-8fcd-4847-b38d-5b2519762ae2',
  '6884c628-9f89-4aba-ace1-6749f10fac5c',
  '3e51b124-8850-4bfc-baa1-e52d7889d292',
  '31596dd9-4032-4939-8f14-65215c4f25b1',
  '4b0896fc-e901-47d3-9a65-01c0c8511b74',
  '969f951c-298f-44e9-9440-c2445e5921be',
  'f764183a-949b-4829-8076-8bbcc6502498',
  '6f7fbaf8-7b42-49ab-900c-c96af2316993',
  '7757259a-e31d-48c6-b993-69490a6b6e42',
  '1aadebfc-0867-479e-830f-2d22760c9d93',
  'aa4178c5-48eb-4f56-8973-048aeefaaa24',
  '7c69879a-60e3-412f-bd32-949f58e7f8ac',
  '823a329f-e84c-401f-8746-f470d8672150',
  '5e1369e4-0c3d-4403-bfae-e1012da3c941',
  'e1764e09-bc69-438b-9f93-bf629ac58cd5',
  '1ff09033-6db8-4837-9faa-d43b6f2533ab',
  '9e6dcba2-3905-4262-9b07-d997dd1ff628',
  '4688d45d-caba-4b93-a59b-aa9dafefe58f',
  '71b163d4-91e0-48bc-85cb-486daafc5583',
  'ab776b33-d3a1-4ac3-b542-e4b862bb1a87',
  '18238560-b3b5-4ebd-9801-b626a04f1eb2',
  '2c3c0b70-6c17-4530-95f2-4719ab22026f',
  'e2c5c81c-f5dd-4661-83d9-4f59116260d8',
  '5e0ef0f7-b80a-456b-95ba-831e39201537'
);

SELECT COUNT(*) AS remaining_investors FROM investors;

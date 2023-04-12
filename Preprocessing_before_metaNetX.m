%% This is the preprocessing files for all models before MetaNetX analysis 
% run these before executing removeBadrxns function
initCobraToolbox(false);
solverOK=changeCobraSolver('gurobi','LP');

%% RAVEN 
RA1A_proper=importModel('Raven_edited_main.xml', false);

drxns= removeBadRxns(RA1A_proper, 3);

% The purpose of "removeBadRxns" function is to remove reactions which enable production/consumption of metabolites even when exchange reactions aren't used.
% Deleted orphan gene VEJY3_oo520 from gene list to avoid rxnGene Mat
% mismatch 

writeCbModel(drxns, 'RA1A.xml', 'format', 'sbml');

%% DEMETER 
DE1A_proper=importModel('Demeter_1A01_x.xml', false);
drxns= removeBadRxns(DE1A_proper, 3);
writeCbModel(drxns, 'DE1A.xml', 'format', 'sbml');

%% ModelSeed/Kbase 
% Models created using SEED database (ModelSeed and Kbase) files do not contain the following fields:
% MetFormulas. For this purpose, the compound .tsv file were
% downloaded from
% (https://github.com/ModelSEED/ModelSEEDDatabase/tree/master/Biochemistry)
% and use for extracting metabolite formulas

ME1A_proper=importModel('1A01_Kbase.sbml', false);

%% add compound csv file 
compounds = readtable('output.csv');

%% loop to check for compounds from ModelSeed and Kbase files and extract formulas
% mets have the suffix "_c0, _e0, _b" at the end of every metabolite ID. The
% following code is to remove this 

% Convert the structure to a cell array
dataCell = struct2cell(ME1A_proper);

% Get the index of the "mets" field
metsIndex = find(strcmp(fieldnames(ME1A_proper), 'mets'));
dataStruct= [];

% Remove the suffix "_c0, _e0, _b" from all entries in the "mets" field
dataCell{metsIndex} = cellfun(@(x) strrep(x, '_c0', ''), dataCell{metsIndex}, 'UniformOutput', false);
dataCell{metsIndex} = cellfun(@(x) strrep(x, '_e0', ''), dataCell{metsIndex}, 'UniformOutput', false);
dataCell{metsIndex} = cellfun(@(x) strrep(x, '_b', ''), dataCell{metsIndex}, 'UniformOutput', false);

% Convert the cell array back to a structure
dataStruct = cell2struct(dataCell, fieldnames(ME1A_proper), 1);


%% Define the metabolite IDs to search from compound database
%extract query metabolite IDs
met_ME= dataStruct.mets;

%extract metabolite IDs from the database 
compound_id= compounds.id;

%extract fromulas from the database 
formula_com= compounds.formula;

%extract indexs of memebers
[~, idx] = ismember(met_ME, compound_id);

% Extract the formulas for the IDs that were found
formulas = cell(size(idx));
for i = 1:numel(idx)
    if idx(i) > 0 && idx(i) <= numel(formula_com)
        formulas{i} = formula_com{idx(i)};
    end
end

% add the extracted formulas in Model Seed
ME1A_proper.metFormulas=formulas;
drxns= removeBadRxns(ME1A_proper, 3);
writeCbModel(drxns, 'ME1A.xml', 'format', 'sbml');

% The resulting model needs to be validated by SBML validator. It will show
% a bunch of errors regarding "null" value in chemical species for "RNA
% transcription", "DNA replication", "protein biosynthesis" and "biomass".
% Enter the appropriate value for this and remove the
% <geneProduct></geneProducts> tags if GrRules do not exist in the model. 
% for Kbase--> the following was changed name="DNA_replication_c0"
% fbc:chemicalFormula="null"; RNA_transcription_c0;Protein_biosynthesis_c0;
% MPT_Synthases_c0;Acceptor_c0; Biomass_c0_b
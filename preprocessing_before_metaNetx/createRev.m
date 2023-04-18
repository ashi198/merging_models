function rev= createRev(old_model)
%%
n_rxns = length(old_model.rxns); % number of reactions in the model
rev = zeros(n_rxns, 1); % initialize the 'rev' vector
for i = 1:n_rxns
    if old_model.lb(i) == 0 && old_model.ub(i) > 0 
        rev(i) = 1; % reaction is reversible
    elseif old_model.lb(i) < 0 && old_model.ub(i) == 0
        rev(i) = 1; % reaction is reversible
    elseif old_model.lb(i) < 0 && old_model.ub(i) > 0
        rev(i) = 0; % reaction is irreversible
    end
end

%Reversible reactions:
%Lower bound (lb): A negative value (e.g., -1000 or -inf)
%Upper bound (ub): A positive value (e.g., 1000 or inf)
%both positive and negative flux values are allowed.

%%irreversible reaction--> forward direction 
%Lower bound (lb): 0 or a non-negative value
%Upper bound (ub): A positive value (e.g., 1000 or inf)
% only positive flux values are allowed.

%irreverible reaction--> reverse direction
%Lower bound (lb): A negative value (e.g., -1000 or -inf)
%Upper bound (ub): 0 or a non-positive value
%the reaction can only proceed in the reverse direction, so only negative flux values are allowed.

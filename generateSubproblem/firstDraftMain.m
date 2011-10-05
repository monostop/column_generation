tic
epsilon = -1e-12;
iter_MAX = 10000;
K = 5;
% Creating feasible schedule and coefficient matrices

% Find a set of feasible starting vectors
x1 = feasibleSched(T,K,Pj,Ak,Rj);
startingVectors = zeros(T*no_of_jobs,K);
for col = 1:K
    startingVectors(:,col) = x1(1+(col-1)*T*no_of_jobs:col*T*no_of_jobs);
end

% Create objective function
c = generateObj(T,Pj,Dj,1,1);
obj = [];
for k = 1:K
    obj = [obj; c*startingVectors(:,k)];
end

D = generateConstraint4bBlock(T,no_of_jobs);
% Generate initial constraint matrix
A = [];
for k = 1:K
    convexCol = zeros(K,1);
    convexCol(k) = 1;
    A = [A [D*startingVectors(:,k); convexCol] ];
end

% !! DO SOMETHING ABOUT THIS PART  !! %
startingVectors = sparse(startingVectors);
A = sparse(A);
D = sparse(D);
c = sparse(c);
obj = sparse(obj);
% !! ----------------------------- !! %

% Creating and populate the Master problem
master = Cplex('MasterProgram');
master.Model.sense = 'minimize';
master.Model.obj = obj; 
master.Model.lb = zeros(K,1);
master.Model.ub = ones(K,1); % Try setting this to 1 maybe
master.Model.A = A;
master.Model.lhs = ones(no_of_jobs+K,1);
master.Model.rhs = ones(no_of_jobs+K,1);

% Solve first time to get dual variables to the subproblem
master.solve()
% Generate c but without tardiness for the subproblems 
cSub = generateObj(T, Pj, Dj, 1, 1);
% Set up subproblems
subProblems = cell(5,1,1);
%A4d = generateConstraint4dBlock(T,Pj);
% Objective function not including the dual of the convexity constraint
obj = (cSub'-D'*sparse(master.Solution.dual(1:no_of_jobs)));
ctype = repmat('B', 1,no_of_jobs*T);

for k = 1:K
    A4c = generateConstraint4c(lambda(:,k), T);
    [rowsA4f A4f] = generateConstraint4f(Rj,Ak(k), T);
    
    subProblems{k} = Cplex();
    subProblems{k}.Model.sense = 'minimize';
    subProblems{k}.Model.obj = obj;
    subProblems{k}.Model.lb = zeros(no_of_jobs*T,1);   %Maybe not needed
    subProblems{k}.Model.ub = ones(no_of_jobs*T,1);
    subProblems{k}.Model.ctype = ctype;
    subProblems{k}.Model.A = [A4c; A4d; A4f];
    subProblems{k}.Model.rhs = [lambda(:,k); ones(T,1); zeros(rowsA4f,1)];
    subProblems{k}.Model.lhs = [ones(T+no_of_jobs,1)*-inf; zeros(rowsA4f,1)];
    
    % -- Cplex Parameters -- %
    % Set the maximum solution pool to 1
    subProblems{k}.Param.mip.pool.capacity.Cur = 1;
    subProblems{k}.Param.advance.Cur = 0;
    % Turn off display of info
    subProblems{k}.Param.mip.display.Cur = 0;
end

% Start main loop
extremePointsCol = sparse(no_of_jobs*T,K*iter_MAX);
extremePointsCol(:,1:5) = startingVectors;
for iter = 196:iter_MAX
    % Create temporary matrix to store new extremepoints and objvalues
    extremePoints = sparse(no_of_jobs*T,K);
    objValues = sparse(1,K);
    % Solve all subproblems to optimality and store columns
    
    for k = 1:K
        % Update subproblem objective function
        obj = (c'-D'*sparse(master.Solution.dual(1:no_of_jobs)));
        % Solve and store extremepoints
        subProblems{k}.Model.obj = obj;
        subProblems{k}.solve();
        extremePoints(:,k) = round(subProblems{k}.Solution.x);
        extremePointsCol(:,iter*K+k) = extremePoints(:,k);
        objValues(k) = subProblems{k}.Solution.objval;
    end
    
    % Check termination criterion 
    dualConvexity = master.Solution.dual(no_of_jobs+1:end);
    if min(objValues-dualConvexity') > epsilon
        break
    end
    
    % Add columns to master problem
    for k = 1:K
        convexityVector = sparse(k,1,1,K,1);
        master.addCols(c*extremePoints(:,k),[D*extremePoints(:,k);...
                                            convexityVector], 0, inf);
    end
    % Solve again
    
    master.solve() % This is fast
   
    if mod(iter,10) == 0;
        iter
    end
end
relaxedSol = master.Solution.x;
ctype = repmat('I', 1,length(relaxedSol));
master.Model.ctype = ctype;
master.solve();
schedules  = createSchedule(master.Solution.x, extremePointsCol, T);
plotSchedules(schedules);
%master = rmfield(master.Model, 'ctype');
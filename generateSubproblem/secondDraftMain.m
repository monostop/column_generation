% Data
%data
epsilon = -1e-6;
iter_MAX = 100;
K = 5;
% Creating feasible schedule and coefficient matrices

% Find a set of feasible starting vectors
x1 = feasibleSched(T,K,Pj);
startingVectors = zeros(T*no_of_jobs,K);
for col = 1:K
    startingVectors(:,col) = x1(1+(col-1)*T*no_of_jobs:col*T*no_of_jobs);
end

% Create objective function
c = generateObj(T,Pj,Dj);
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

startingVectors = sparse(startingVectors);
A = sparse(A);
D = sparse(D);
c = sparse(c);
obj = sparse(obj);
% Creating and populate the Master problem
master = Cplex('MasterProgram');
master.Model.sense = 'minimize';
master.Model.obj = obj; 
master.Model.lb = zeros(K,1);
master.Model.ub = ones(K,1)*inf; % Try setting this to 1 maybe
master.Model.A = A;
master.Model.lhs = ones(no_of_jobs+K,1);
master.Model.rhs = ones(no_of_jobs+K,1);

% Solve first time to get dual variables to the subproblem
master.solve()

% Set up subproblems

A4c = generateConstraint4c(lambda(:,k), T);
A4d = generateConstraint4dBlock(T,Pj);
k

obj = (c'-D'*sparse(master.Solution.dual(1:no_of_jobs))); % should be correct
% Objective function not including the dual of the convexity constraint
ctype = [];
for i = 1:no_of_jobs*T
    ctype = [ctype 'I'];
end

sub1 = Cplex('sub1')
sub1.Model.sense = 'minimize';
sub1.Model.obj = obj;
sub1.Model.lb = zeros(no_of_jobs*T,1);
sub1.Model.ub = ones(no_of_jobs*T,1);
sub1.Model.ctype = ctype;
sub1.Model.A = [A4c; A4d];
sub1.Model.rhs = [lambda(:,1); ones(T,1)];
sub1.Model.lhs = ones(T+no_of_jobs,1)*-inf;

sub2 = Cplex('sub2')
sub2.Model.sense = 'minimize';
sub2.Model.obj = obj;
sub2.Model.lb = zeros(no_of_jobs*T,1);
sub2.Model.ub = ones(no_of_jobs*T,1);
sub2.Model.ctype = ctype;
sub2.Model.A = [A4c; A4d];
sub2.Model.rhs = [lambda(:,2); ones(T,1)];
sub2.Model.lhs = ones(T+no_of_jobs,1)*-inf;

sub3 = Cplex('sub3')
sub3.Model.sense = 'minimize';
sub3.Model.obj = obj;
sub3.Model.lb = zeros(no_of_jobs*T,1);
sub3.Model.ub = ones(no_of_jobs*T,1);
sub3.Model.ctype = ctype;
sub3.Model.A = [A4c; A4d];
sub3.Model.rhs = [lambda(:,3); ones(T,1)];
sub3.Model.lhs = ones(T+no_of_jobs,1)*-inf;

sub4 = Cplex('sub4')
sub4.Model.sense = 'minimize';
sub4.Model.obj = obj;
sub4.Model.lb = zeros(no_of_jobs*T,1);
sub4.Model.ub = ones(no_of_jobs*T,1);
sub4.Model.ctype = ctype;
sub4.Model.A = [A4c; A4d];
sub4.Model.rhs = [lambda(:,4); ones(T,1)];
sub4.Model.lhs = ones(T+no_of_jobs,1)*-inf;

sub5 = Cplex('sub5')
sub5.Model.sense = 'minimize';
sub5.Model.obj = obj;
sub5.Model.lb = zeros(no_of_jobs*T,1);
sub5.Model.ub = ones(no_of_jobs*T,1);
sub5.Model.ctype = ctype;
sub5.Model.A = [A4c; A4d];
sub5.Model.rhs = [lambda(:,5); ones(T,1)];
sub5.Model.lhs = ones(T+no_of_jobs,1)*-inf;


% Start main loop
for iter = 1:iter_MAX
    % Create temporary matrix to store new extremepoints and objvalues
    extremePoints = sparse(no_of_jobs*T,K);
    objValues = sparse(1,K);
    % Solve all subproblems to optimality and store columns
    
    % Update subproblem objective function
    obj = (c'-D'*sparse(master.Solution.dual(1:no_of_jobs)));
    
    
    % Solve and store
    sub1.Model.obj = obj;
    sub1.solve();
    extremePoints(:,1) = sub1.Solution.x;
    objValues(1) = sub1.Solution.objval;
    
    sub2.Model.obj = obj;
    sub2.solve();
    extremePoints(:,2) = sub2.Solution.x;
    objValues(2) = sub2.Solution.objval;
    
    sub3.Model.obj = obj;
    sub3.solve();
    extremePoints(:,3) = sub3.Solution.x;
    objValues(3) = sub3.Solution.objval;
    
    sub4.Model.obj = obj;
    sub4.solve();
    extremePoints(:,4) = sub4.Solution.x;
    objValues(4) = sub4.Solution.objval;
    
    sub5.Model.obj = obj;
    sub5.solve();
    extremePoints(:,5) = sub5.Solution.x;
    objValues(5) = sub5.Solution.objval;
    
    % Check termination criterion (Maybe this for all?)
    dualConvexity = master.Solution.dual(no_of_jobs+1:end);
    if min(objValues-dualConvexity') > epsilon
        break
    end
    
    % Add columns to master problem
    for k = 1:K
        %convexityVector = zeros(K,1);
        %convexityVector(k) = 1;
        convexityVector = sparse(k,1,1,K,1);
        master.addCols(c*extremePoints(:,k),[D*extremePoints(:,k);...
            convexityVector], 0, inf);
    end
    % Solve again
    master.solve()
end


        
% sub2 = Cplex('sub2');
% sub2 = Cplex('sub1');
% sub2.Model.sense = 'minimize';
% obj = (c'-D'*master.Solution.dual(1:4));
% sub2.Model.obj = obj;
% sub2.Model.lb = zeros(no_of_jobs*T,1);
% sub2.Model.ub = ones(no_of_jobs*T,1);
% sub2.Model.ctype = 'IIIIIIIIIIIIIIII';
% A4c = generateConstraint4c(lambda_2,T);
% A4d = generateConstraint4dBlock(T,Pj);
% sub2.Model.A = [A4c; A4d];
% sub2.Model.rhs = [lambda_2; ones(T,1)];
% sub2.Model.lhs = ones(T+no_of_jobs,1)*-inf;
% 
% sub2.solve();
% 
% master.addCols(c*sub1.Solution.x, [D*sub1.Solution.x; 1 ; 0], 0, inf);
% master.addCols(c*sub2.Solution.x, [D*sub2.Solution.x; 0 ; 1], 0, inf);
% 
% master.solve();
% 
% % iteration 2
% obj = (c'-D'*master.Solution.dual(1:4));
% sub1.Model.obj = obj;
% sub2.Model.obj = obj;
% sub1.solve();
% sub2.solve();
% 
% master.addCols(c*sub1.Solution.x, [D*sub1.Solution.x; 1 ; 0], 0, inf);
% master.addCols(c*sub2.Solution.x, [D*sub2.Solution.x; 0 ; 1], 0, inf);
% master.solve();



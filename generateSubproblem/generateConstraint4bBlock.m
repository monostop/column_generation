function A = generateConstraint4bBlock (T, N)
% One block of doefficient matrix of constraint 4b, need one for each
% machine

A = sparse(N,T*N);
for i = 1:N
    A(i,1+(i-1)*T:i*T) = 1;
end

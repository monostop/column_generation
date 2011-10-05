function A = generateConstraint4c(lambda_k,T)

no_of_jobs = length(lambda_k);
A = sparse(no_of_jobs,T*no_of_jobs);
for i = 1:no_of_jobs
    A(i,1+(i-1)*T:i*T) = 1;
end

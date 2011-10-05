function A = generateConstraint4dBlock (T,Pj)

no_of_jobs = length(Pj);
A = sparse(T, no_of_jobs*T);

for t = 1:T
    for i = 1:no_of_jobs
        start = max(0,t-Pj(i));
        A(t, start+1+(i-1)*T:t+(i-1)*T)=1;
    end
    
end


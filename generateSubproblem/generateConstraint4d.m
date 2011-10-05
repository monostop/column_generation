function A = generateConstraint4d (T, Pj, K) 
% Coefficient matrix of 4d

no_of_jobs = length(Pj);
block = zeros(T, no_of_jobs*T);

for t = 1:T
    for i = 1:no_of_jobs
        start = max(0,t-Pj(i));
        block(t, start+1+(i-1)*T:t+(i-1)*T)=1;
    end
end

s = 'block';
for i = 0:K-1
    s = [s ',block'];
end  
st = ['blkdiag(' s ')'];
A = eval(st);
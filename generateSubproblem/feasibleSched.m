function x = feasibleSched(T,K, Pj,Ak,Rj)
% Assuming sums of Pj < planning horizons.

no_of_jobs = length(Pj);
jobs_per_machine = floor(no_of_jobs/K); % Assume K divides no of jobs


x = zeros(no_of_jobs * T * K,1 );
job = 1;
for k = 1:K
    time = max(Ak(k), Rj(jobs_per_machine*(k-1)+1))+1;
    for i = 1:jobs_per_machine
        x(time+(job-1)*T+no_of_jobs*T*(k-1)) = 1;
        if (i ~= jobs_per_machine)
            time = max(time + Pj(job),Rj(job+1));
        end
        job = job+1;
    end
end



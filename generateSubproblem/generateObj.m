function obj = generateObj(T,Pj,Dj,A,B)
% Objective coefficents for the subproblem

N = length(Pj);
obj = zeros(N*T,1);
j = 1;
for i = 1:N
    for t = 1:T
        obj(j) =A*(t+Pj(i))+B*(max(0,t+Pj(i)-Dj(i)));
        j = j + 1;
    end
end
obj = obj';
            
            
        
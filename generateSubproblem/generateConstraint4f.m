function [no_of_Rows A] = generateConstraint4f(rj,ak,T)
no_of_Rows = CalcRows(rj,ak);

if no_of_Rows == 0;
    A = sparse(0,0);
    return
else
    no_of_jobs = length(rj);
    A = sparse(CalcRows(rj,ak),no_of_jobs*T);
    row = 1;
    for i=1:no_of_jobs
        for t=1:max(ak,rj(i))
            A(row,(i-1)*T+t) = 1;
            row = row + 1; 
        end
    end
end
end
function no_of_rows = CalcRows(rj,ak)

sum = 0;
for i = 1:length(rj)
    sum = sum + max(rj(i),ak);
end
no_of_rows = sum;
end
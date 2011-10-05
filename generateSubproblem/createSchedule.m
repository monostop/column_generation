function schedule = createSchedule(x, extremePointsCol,T)

index = find(round(x));
points = sparse(size(extremePointsCol,1), 5);
for k=1:5
    if mod(index(k),5) == 0
        points(:,5) = extremePointsCol(:,index(k));
    else
        points(:,mod(index(k),5)) = extremePointsCol(:,index(k));
    end
end

for k=1:5
    schedule{k} = [ceil(find(points(:,k))./T) mod(find(points(:,k)),T)];
end
       
function plotSchedules(schedules)

maxLen = 0;
line = cell(5,1);
for k=1:5
    line{k} = diff([0; sort(schedules{k}(:,2))]);
    if length(line{k}) > maxLen;
        maxLen = length(line{k});
    end
end
barplot = zeros(5,maxLen);
for k = 1:5
    barplot(k,:) = [line{k}; zeros(maxLen-length(line{k}),1)];
end

barh(barplot,'stacked');
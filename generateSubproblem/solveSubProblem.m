function [extremePoint objValue] = solveSubProblem(objFunc, prob)

prob.Model.obj = objFunc;
prob.Model.solve();
extremePoint = prob.Solution.x;
objValue = prob.Solution.ojbval;
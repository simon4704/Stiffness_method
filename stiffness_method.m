







%% Example
 % Use script "testScript2_github" in "tester_work_dir" to replicate results.
 % Run the last two lines to get nodal displacements,
    % dun kno why they dont appear when script is run...

% Construction

% A-----B----------C
%      / \        /
%     /   \      /
%    /     \    /
%   /       \  /
%  /         \/
% D----------E


% Given parameters (all in mm and corresponding)

E = 210e9;
L = 5;
h = 0.150;
b = 0.080;
PCy = -500000;


% Calculated parameters

A = h*b;
I = 1/12*b*h^3;
theta = pi/3;


% Solution

AB = ConstructGlobalkMatrix(A, E, L/2, I, 0);       % k matrix for beam AC
BC = ConstructGlobalkMatrix(A, E, L, I, 0);         % -||- BC
DE = ConstructGlobalkMatrix(A, E, L, I, 0);         % -||- DE
DB = ConstructGlobalkMatrix(A, E, L, I, theta);     % -||- DB
BE = ConstructGlobalkMatrix(A, E, L, I, -theta);    % -||- BE
EC = ConstructGlobalkMatrix(A, E, L, I, theta);     % -||- EC

ABC = AssembleLocalMatrices([AB;BC;DE;DB;BE;EC], ...
    [1,2;2,3;4,5;4,2;2,5;5,3]);                     % Full k matrix

constraints = [0,0,0, 1,1,1, 1,1,1, 0,0,0, 1,1,1];  % Vector defining constraints
% 0 means constrained, 1 means can move,
% order is [u1, v1, theta1, u2, v2 theta2... ],
% where u is x-dir, v is y-dir and theta is cc rotation around z

ABC_simp = SimplifyMatrix(ABC, constraints);        % Simplified k matrix for AC and BC
% For every 'constraints(i) == 0' ABC(i,:) = ABC(:,i) = 0, except ABC(i,i) = 1

pVec = ([0,0,0, 0,0,0, 0,PCy,0, 0,0,0, 0,0,0])'; % Vector with external forces

uVec = ABC_simp\pVec;                               % Resulting displacement vector
% disp(uVec);


uVec__List = array2table(uVec'*1000, 'VariableNames', ["u1","v1","t1", "u2","v2","t2", "u3","v3","t3", "u4","v4","t4", "u5","v5","t5"]);
disp(uVec__List);



%%

% Plotting has yet to be automated, here it is done manually.

Lh = L*sqrt(3)/2;

xs1 = [0, L/2, 3/2*L, 0, L];
ys1 = [Lh, Lh, Lh, 0, 0];

xindexes = [1,4,7,10,13];
yindexes = xindexes + 1;
scalar = 50;
xs2 = xs1 + uVec(xindexes)' * scalar;
ys2 = ys1 + uVec(yindexes)' * scalar;


figure
hold on

plot(xs1(1:3), ys1(1:3), '--black');
plot(xs2(1:3), ys2(1:3), '-blue');

plot(xs1(4:5), ys1(4:5), '--black');
plot([xs1(4), xs1(2), xs1(5), xs1(3)], [ys1(4), ys1(2), ys1(5), ys1(3)], '--black');
plot(xs1, ys1, '.black', MarkerSize=15);


plot(xs2(4:5), ys2(4:5), '-blue');
plot([xs2(4), xs2(2), xs2(5), xs2(3)], [ys2(4), ys2(2), ys2(5), ys2(3)], '-blue');
plot(xs2, ys2, '.blue', MarkerSize=15);

legend("Undeformed", "Solution", Location="southeast")

% f = gcf;
% exportgraphics(f, "solution.jpg", 'Resolution', 600)






%%


function outputMatrix = ConstructGlobalkMatrix(A, E, L, I, theta)
    outputMatrix = zeros(6, 6);
    c = cos(theta); s = sin(theta);
    k11_1 = [A*c^2 + 12*I*s^2/L^2, A*s*c - 12*I*s*c/L^2, -6*I*s/L];
    k11_2 = [A*s*c - 12*I*s*c/L^2, A*s^2 + 12*I*c^2/L^2,  6*I*c/L];
    k11_3 = [-6*I*s/L,             6*I*c/L,               4*I];

    outputMatrix(1,1:3) = k11_1;
    outputMatrix(1,4:6) = k11_1.*[-1, -1, 1];
    outputMatrix(2,1:3) = k11_2;
    outputMatrix(2,4:6) = k11_2.*[-1, -1, 1];
    outputMatrix(3,1:3) = k11_3;
    outputMatrix(3,4:6) = k11_3.*[-1, -1, 1/2];

    outputMatrix(4,1:3) = k11_1*(-1);
    outputMatrix(4,4:6) = k11_1.*[1, 1, -1];
    outputMatrix(5,1:3) = k11_2*(-1);
    outputMatrix(5,4:6) = k11_2.*[1, 1, -1];
    outputMatrix(6,1:3) = k11_3.*[1, 1, 1/2];
    outputMatrix(6,4:6) = k11_3.*[-1, -1, 1];

    outputMatrix = outputMatrix*E/L;
end


function outputMatrix = AssembleLocalMatrices(inputMatrices, nodes)

    dof = 3*max(max(nodes));
    outputMatrix = zeros(dof, dof);

    concatinatedInputMatrices = inputMatrices(1:6, :);

    for i = 2:height(inputMatrices) / 6
        concatinatedInputMatrices(:,:,i) = inputMatrices(1 + 6*(i-1) : 6 + 6*(i-1), :);
    end

    for i = 1:size(concatinatedInputMatrices,3)
        
        interval1 = 1 + 3*(nodes(i,1) - 1) : 3 + 3*(nodes(i,1) - 1);
        interval2 = 1 + 3*(nodes(i,2) - 1) : 3 + 3*(nodes(i,2) - 1);


        outputMatrix(interval1, interval1) = ...
            outputMatrix(interval1, interval1) + concatinatedInputMatrices(1:3,1:3,i);
        
        outputMatrix(interval1, interval2) = ...
            outputMatrix(interval1, interval2) + concatinatedInputMatrices(1:3,4:6,i);
        
        outputMatrix(interval2, interval1) = ...
            outputMatrix(interval2, interval1) + concatinatedInputMatrices(4:6,1:3,i);

        outputMatrix(interval2, interval2) = ...
            outputMatrix(interval2, interval2) + concatinatedInputMatrices(4:6,4:6,i);

    end

end


function outputMatrix = SimplifyMatrix(inputMatrix, dVector)
    outputMatrix = inputMatrix;
    for i = 1:length(dVector)
        outputMatrix(:,i) = outputMatrix(:,i) * dVector(i);
    end

    for i = 1:length(dVector)
        if dVector(i) == 0
            outputMatrix(i,:) = 0;
            outputMatrix(i,i) = 1;
        end
    end
end




function radians = DegreesToRadians(degrees)
    radians = degrees*pi/180;
end



function outputString = ArrayToLatex(A, scalar, decimalPlaces)
    disp(A(1,1)/1e6);
    outputString = "\left[\begin{array}{";
    for i = 1:size(A,2)
        outputString = outputString + "c";
    end
    outputString = outputString + "}";

    for i = 1:size(A,1)
        for j = 1:size(A,2)
            if A(i,j) == 0
                outputString = outputString + "0";
            elseif A(i,j) == 1
                outputString = outputString + "1";
            else
                outputString = outputString + num2str(round(A(i,j)/(10^scalar), decimalPlaces));
                if scalar ~= 1
                    outputString = outputString + "\cdot 10^" + num2str(scalar);
                end
            end
            
            if j ~= size(A,2)
                outputString = outputString + "&";
            end
        end
        if i ~= size(A,1)
            outputString = outputString + "\\";
        end

    end
    outputString = outputString + "\end{array}\right]";
end






















































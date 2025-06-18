filePath = 'D:\MATLAB仿真程序\第四章改进\S盒检测消除\S_box_040.txt';
fileID = fopen(filePath, 'r');

S = fscanf(fileID, '%d', [16, 16]); % 按16x16矩阵读取
fclose(fileID);
S = reshape(S', 1, []);


P = [];
Q = [];
[P, Q] = fixed_point_detection(S);

H = [];
H = cycle_detection_fixed(S);
disp(H);

Cycles = cycle_detection_detailed(S);
disp(Cycles);
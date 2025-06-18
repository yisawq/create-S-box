function optimize_S_boxes()
    % 设置路径
    input_folder = 'D:\MATLAB仿真程序\第四章改进\生成S盒';
    output_folder = 'D:\MATLAB仿真程序\第四章改进\优化不含短周期';
    
    % 确保输出文件夹存在
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % 获取所有txt文件
    files = dir(fullfile(input_folder, '*.txt'));
    
    % 处理每个S盒
    for k = 1:length(files)
        filename = files(k).name;
        filepath = fullfile(input_folder, filename);
        
        % 读取S盒
        S = read_s_box(filepath);
        
        % 消除不动点和反不动点
        S = remove_fixed_anti_fixed(S);
        
        % 强制消除所有短周期环
        S = remove_all_short_cycles(S);
        
        % 保存优化后的S盒（16x16格式）
        save_s_box_matrix(S, output_folder, filename);
    end
    disp('所有S盒优化完成！');
end


function S = read_s_box(filepath)
    % 读取S盒文件，转换为1-based行向量
    data = importdata(filepath);
    S = data(:)'; % 确保为行向量
end

function save_s_box_matrix(S, output_folder, filename)
    % 转换为规范的16x16矩阵格式
    S_matrix = reshape(S, 16, 16)';  % 转置确保按行存储
    
    % 写入文件
    output_path = fullfile(output_folder, filename);
    dlmwrite(output_path, S_matrix, 'delimiter', ' ');
end

function S = remove_fixed_anti_fixed(S)
    % 检测不动点和反不动点
    [P, Q] = fixed_point_detection(S);
    
    % 处理不动点
    for p = P
        i = p + 1; % 转换为1-based索引
        found = false;
        % 向右查找可交换位置
        for j = i+1:256
            if S(j) ~= (j-1) && S(j) ~= (i-1)
                [S(i), S(j)] = deal(S(j), S(i));
                found = true;
                break;
            end
        end
        % 向左查找
        if ~found
            for j = i-1:-1:1
                if S(j) ~= (j-1) && S(j) ~= (i-1)
                    [S(i), S(j)] = deal(S(j), S(i));
                    found = true;
                    break;
                end
            end
        end
    end
    
    % 处理反不动点
    for q = Q
        i = 256 - q; % 转换为1-based索引
        found = false;
        for j = i+1:256
            if S(j) ~= (256 - j) && S(j) ~= (256 - i)
                [S(i), S(j)] = deal(S(j), S(i));
                found = true;
                break;
            end
        end
        if ~found
            for j = i-1:-1:1
                if S(j) ~= (256 - j) && S(j) ~= (256 - i)
                    [S(i), S(j)] = deal(S(j), S(i));
                    found = true;
                    break;
                end
            end
        end
    end
end

function S = remove_all_short_cycles(S)
    % 检测所有周期（不限制长度）
    Cycles = cycle_detection_detailed(S);
    
    % 仅当存在至少两个周期时执行链式交换
    if length(Cycles) >= 2
        cycle_elements = {Cycles.Elements};  % 获取所有周期元素
        
        % 执行链式交换操作
        for i = 1:length(cycle_elements)-1
            % 当前周期尾元素（0-based）
            tail = cycle_elements{i}(end);
            % 下一周期头元素（0-based）
            head = cycle_elements{i+1}(1);
            
            % 转换为1-based索引并交换值
            [S(tail+1), S(head+1)] = deal(S(head+1), S(tail+1));
        end
    end
end


function [P,Q] = fixed_point_detection(S)
    b = S + 1;
    P = [];
    Q = [];
    for i = 1:size(S,2)
        if b(i) == i
            p = i - 1;
            P = [P, p];
        elseif b(i) + i == size(S,2) + 1
            q = 256 - i;
            Q = [Q, q];
        end
    end
end

function Cycles = cycle_detection_detailed(S)
    A = S + 1;  % 转换为1-based索引
    n = numel(A);
    visited = false(1, n);
    Cycles = struct('Length', {}, 'Elements', {});

    for i = 1:n
        if ~visited(i)
            current = i;
            path = [];
            while true
                path = [path, current];
                visited(current) = true;
                next = A(current);
                if visited(next)
                    idx = find(path == next, 1);
                    if ~isempty(idx)
                        cycle = path(idx:end);
                        if length(cycle) > 1
                            cycle_length = length(cycle);
                            Cycles(end+1) = struct('Length', cycle_length, ...
                                'Elements', cycle-1); % 转换为0-based
                        end
                    end
                    break;
                end
                current = next;
            end
        end
    end
end
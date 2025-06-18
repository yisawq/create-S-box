function H = cycle_detection_fixed(S)
    A = S + 1;  % MATLAB数组索引从1开始，调整索引
    n = numel(A);
    visited = false(1, n);  % 标记是否已找到周期
    cycle_lengths = [];  % 用来存储所有的周期长度

    for i = 1:n
        if ~visited(i)
            b = i;
            sequence = i;
            visited(i) = true;
            % 模拟循环寻找周期
            while true
                b = A(b);
                if visited(b)
                    % 找到周期起始点
                    if b == i  % 确保是从同一个起点开始
                        cycle_length = numel(sequence);
                        cycle_lengths = [cycle_lengths, cycle_length];
                    end
                    break;
                end
                sequence = [sequence, b];  % 记录访问过的路径
                visited(b) = true;
            end
        end
    end

    % 返回唯一的周期长度值
    H = unique(cycle_lengths);
end

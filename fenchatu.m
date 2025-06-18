% 参数
v = 50;              % v 参数设为常数
y0 = 0.5;           % 初始条件 y
x0 = 0.5;           % 初始条件 x
u_min = 0;          % u 参数的最小值
u_max = 10;         % u 参数的最大值
u_steps = 600;     % u 参数的步数
num_iter = 600;    % 每个参数值的迭代次数
skip_iter = 100;    % 初始的迭代次数，用于跳过暂态行为

% 创建 u 的值的向量
u_values = linspace(u_min, u_max, u_steps);

% 初始化结果存储
x_results = zeros(num_iter - skip_iter, u_steps);
y_results = zeros(num_iter - skip_iter, u_steps);

% 对每一个 u 值进行迭代
for j = 1:u_steps
    u = u_values(j);
    x = x0;
    y = y0;
    
    % 迭代映射
    for i = 1:num_iter
        x_new = sin(u * cos(v / y));
        y_new = cos(u * sin(v * x^2));
        
        % 更新 x 和 y
        x = x_new;
        y = y_new;
        
        % 保存数据（跳过初始的迭代）
        if i > skip_iter
            x_results(i - skip_iter, j) = x;
            y_results(i - skip_iter, j) = y;
        end
    end
end

% 绘制 x 的分叉图
figure;
plot(u_values, x_results, 'b.', 'MarkerSize', 1);
title('x 的分叉图');
xlabel('u');
ylabel('x');

% 绘制 y 的分叉图
figure;
plot(u_values, y_results, 'b.', 'MarkerSize', 1);
title('y 的分叉图');
xlabel('u');
ylabel('y');
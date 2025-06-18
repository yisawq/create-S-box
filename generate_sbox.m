function S_box = generate_sbox()
    % 步骤1：参数初始化
    u = 100;
    v = 100;
    max_attempts = 1000;
    B = [];
    success = false;
    
    % 生成混沌序列并尝试构造可逆矩阵B
    for attempt = 1:max_attempts
        % 初始值随机化
        x0 = rand();
        y0 = rand();
        
        % 迭代混沌映射（200瞬态 + 64有效迭代）
        [x_seq, y_seq] = iterate_2desm(x0, y0, u, v, 200 + 64);
        x_seq = x_seq(201:end);
        y_seq = y_seq(201:end);
        
        % 生成矩阵B（8x8）
        B_data = mod(floor((mod(exp(x_seq) * 1e6, 1))), 2);
        B = reshape(B_data, 8, 8)'; % 按列填充
        
        % 检查B是否可逆（GF(2)）
        if gfrank(B, 2) == 8
            success = true;
            break;
        else
            % 更新初始值（公式4-5）
            x0 = mod(x_seq(end) + mod(sum(x_seq), 1), 1);
            y0 = mod(y_seq(end) + mod(sum(y_seq), 1), 1);
        end
    end
    
    if ~success
        error('无法生成可逆矩阵B（最大尝试次数%d次）', max_attempts);
    end
    
    % 步骤2(2)：生成初始S盒Speed（GF(2^8)逆）
    irr_poly = 283; % x^8 + x^4 + x^3 + x + 1
    S0 = zeros(256, 8); % 256个字节，每个字节8位
    for i = 0:255
        if i == 0
            inv_byte = 0;
        else
            % 计算GF(2^8)逆
            element = gf(i, 8, irr_poly);
            inv_element = inv(element);
            inv_byte = double(inv_element.x);
        end
        S0(i+1, :) = de2bi(inv_byte, 8, 'left-msb');
    end
    
    % 步骤2(3)：生成仿射常数C
    sum_y = sum(y_seq);
    c_decimal = mod(floor(mod(sum_y + sum_y, 1) * 1e16), 256) + 1;
    C = de2bi(c_decimal, 8, 'left-msb')'; % 8x1列向量
    
    % 步骤2(4)：应用仿射变换 S1 = B * S0^T + C
    S1 = mod(B * S0' + repmat(C, 1, 256), 2); % 扩展C为8x256矩阵
    
    % 转换为十进制并重塑为16x16 S盒
    S_box = bi2de(S1', 'left-msb');
    S_box = reshape(S_box, 16, 16);
    
    % 转换为十六进制输出
    S_box_hex = arrayfun(@(x) dec2hex(x, 2), S_box, 'UniformOutput', false);
    disp('生成的8x8 S盒（16x16十六进制格式）：');
    disp(S_box_hex);
end

% 辅助函数：迭代2D-ESM混沌映射
function [x_seq, y_seq] = iterate_2desm(x0, y0, u, v, iterations)
    x_seq = zeros(1, iterations);
    y_seq = zeros(1, iterations);
    x = x0;
    y = y0;
    for i = 1:iterations
        x_new = sin(u * cos(v / y));
        y_new = cos(u * sin(v * x^2));
        x_seq(i) = x_new;
        y_seq(i) = y_new;
        x = x_new;
        y = y_new;
    end
end

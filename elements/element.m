classdef element
    %ELEMENT Offers the basic stiffness matrix for the 3 node, 4 node and 8 node elements
    properties
        E;
        nu;
        thick;  % 厚度为10mm
        elem_node_num;
        Ke;
        N;      % 形状函数矩阵
        B;      % 应变矩阵
        D;      % 广义胡克定律刚度矩阵
        S;      % 应力矩阵,获取每一点的x,y方向上的应力
    end
    methods
        % 初始化，并计算单元刚度矩阵
        function obj = element(E, nu, thick, elem_node_num)
           obj.E = E;
           obj.nu = nu;
           obj.thick = thick;
           obj.elem_node_num = elem_node_num;
           switch elem_node_num
               case 3
                   obj = elem301(obj);
               case 4
                   obj = elem401(obj);
                   % 存储的是8x8的矩阵，一个节点是2x2的部分, 即k11-k44一共16个元素 
               case 8
                   obj = elem801(obj);
               otherwise
                   num = num2str(elem_node_num);
                   error(join(["only 3 4 and 8 nodes element are supported,", num, "nodes element is not supported"]));
           end
        end
        % 四节点单元刚度矩阵函数 E杨氏模量, nu 泊松比, h板厚度
        function obj = elem301(obj)
            
        end
        function obj = elem401(obj)
            syms x 
            syms y
            M = [
                [1, x, y, x*y,0,0,0,0]
                [0,0,0,0, 1, x, y, x*y]
                ];
            A = [
                [1 -1 -1 1 0 0 0 0]
                [0 0 0 0 1 -1 -1 1]
                [1 1 -1 -1 0 0 0 0]
                [0 0 0 0 1 1 -1 -1]
                [1 1 1 1 0 0 0 0]
                [0 0 0 0 1 1 1 1]
                [1 -1 1 -1 0 0 0 0]
                [0 0 0 0 1 -1 1 -1]
                ];
            obj.N = M/A;  % M * inv(A) , 为形状函数矩阵
            
            % 对x, y等参变量求导并得到对应的应变矩阵
            N_x = diff(obj.N,x);
            N_y = diff(obj.N,y);
            
            obj.B = [N_x(1,:)
                 N_y(2,:)
                 N_y(1,:) + N_x(2,:)];
            clear N_x N_y
            obj.D = obj.E/(1-obj.nu^2) * [
            [1 obj.nu 0]
            [obj.nu 1 0]
            [0 0 (1- obj.nu)/2]
            ];

            obj.S = obj.D * obj.B; % 计算对应的应力矩阵

            k_e = transpose(obj.B)* obj.D * obj.B;
            obj.Ke = obj.thick * int(int(k_e,x,[-1, 1]), y, [-1,1]); % 积分求解对应的四节点刚度矩阵
            % 注意: 使用vpa会损失精度
        end
        function obj = elem801(obj)
            syms x y
            % 对于平面八节点单元，共有
            M = [
                [1 x y x^2 x*y y^2 x^2*y x*y^2 0 0 0 0 0 0 0 0]
                [0 0 0 0 0 0 0 0 1 x y x^2 x*y y^2 x^2*y x*y^2]
                ];
            % 定义八节点单元的x_e和y_e
            x_e = [-1 0 1 1 1 0 -1 -1];
            y_e = [-1 -1 -1 0 1 1 1 0];
            
            % 创建初始矩阵A
            A = zeros(16,16);
            for i = 1:8
                A(2*i-1:1:2 *i,:) = subs(M,[x,y],[x_e(i),y_e(i)]);
            end
            % 计算形状函数矩阵 
            obj.N = M/A;
            % 使用求导方法求解对应的位移函数
            N_x = diff(obj.N,x);
            N_y = diff(obj.N,y);
            obj.B = [N_x(1,:)
                 N_y(2,:)
                 N_y(1,:) + N_x(2,:)
                 ];
            clear N_x N_y
            % 刚度矩阵D
            obj.D = obj.E/(1-obj.nu^2) * [
                [1 obj.nu 0]
                [obj.nu 1 0]
                [0 0 (1- obj.nu)/2]
                ];
            obj.S = obj.D* obj.B; % 计算对应的应力矩阵
            ke_pre = transpose(obj.B)*obj.S;  % B^T*D*B
            obj.Ke = obj.thick * int(int(ke_pre,x,[-1, 1]), y, [-1,1]); % 积分得到刚度矩阵
            % 注意不能使用vpa函数, vpa函数会产生截断误差
            clear ke_pre
        end
    end
end


function Mesh = simplemesh(h,l,elem_node_number,quality,xelem_input,yelem_input)
% 自动生成网格函数
% Test Part
% h = 28; % 28 mm 高度
% l = 300; % 300 mm 长度
% quality = "fine";
% xelem_input = int32(50);
% yelem_input = int32(4);
% elem_node_number = int8(4);   % 注意int8只能存储-128 - 127 的数据
%% ===== 自动生成网格 ====
% 提供质量信息, 自动创建矩形网格, 并返回每个节点在局部和整体坐标系中的位置
if (nargin ~= 4 && nargin ~= 6) || (elem_node_number ~= 4 && elem_node_number ~= 8)
    error("The Parameters input should be either 4 or 6, Only 4-node element and 8-node element are supported");
end

if nargin == 4
    xelem_input = 0;
    yelem_input = 0;
end

switch quality
    case "coarse"
        max_prop = 5;
        yelem_num = int32(2);
    case "normal"
        max_prop = 2.5;
        yelem_num = int32(4);
    case "fine"
        max_prop = 1.2;  % 对于较为精细的划分，尽可能使用较小的长宽比例
        yelem_num = int32(6);
    case "user-define"
        max_prop = inf;
end

prop = l/h;  % 长宽比例
while prop > max_prop || prop < 1/max_prop
    prop = sqrt(prop);
end
if quality == "user-define"
    xelem_num = int32(xelem_input);
    yelem_num = int32(yelem_input);
    dx = l/double(xelem_num);
    dy = h/double(yelem_num);
else
    % yelem_num 已经计算完
    dy = h/double(yelem_num);
    xelem_num = int32(l/(dy* prop) + 1);
    dx = l/double(xelem_num);
end

%% ======= 计算局部坐标矩阵 =================
% 使用mesh结构体存储对应的属性并且返回
Mesh.quality = quality;
Mesh.elem_node_number = int8(elem_node_number);   % 单元节点个数
Mesh.dx = dx;
Mesh.dy = dy;
Mesh.xelem_num = xelem_num;      % x 方向单元数量
Mesh.yelem_num = yelem_num;      % y 方向单元数量
Mesh.elem_number = xelem_num * yelem_num;  % 总单元数量
Mesh.height = h;
Mesh.length = l;
Mesh.conn = [];   % 初始化空的矩阵

% 从左上到右下进行编号, 因此对于每一个单元, 都记录对应的一个表
% 横坐标为elem_numbers,  纵坐标为1~4或者1~8的局部坐标
% 建立坐标系是右下的坐标系
Table = zeros(Mesh.elem_node_number, Mesh.elem_number);
if Mesh.elem_node_number == 4
    % 计算平面4节点单元的局部坐标矩阵
    xnode_num = xelem_num + 1;  % 仅有4节点单元可以计算出某一方向的nodeNum属性
    ynode_num = yelem_num + 1;  % y 方向节点数量
    Mesh.node_number = xnode_num * ynode_num;   % 计算总的节点个数
    for i = 1: double(Mesh.elem_number)
        % 在matlab中，对应的整形除法进行四舍五入
        elem_x = ceil(i/double(Mesh.yelem_num));  % 直接求解之后
        elem_y = i - (elem_x-1) * Mesh.yelem_num;  % 计算单元在全局坐标系中的x,y坐标
        % 分别计算每一个节点的局部坐标, 按照顺时针进行编号
        Table(4, i)= (elem_x -1) * ynode_num + elem_y;
        Table(1, i) = Table(4,i) + 1;
        Table(3, i) = elem_x * ynode_num + elem_y;
        Table(2, i) = Table(3,i) + 1;
    end
    Mesh.node_xloc = reshape(repmat(0: Mesh.dx : l,Mesh.yelem_num +1, 1),1, Mesh.node_number);
    Mesh.node_yloc = repmat(0: Mesh.dy : h,1, Mesh.xelem_num+1);
    % 记录每一个节点的x,y坐标
    
    % 每一个节点,向右连接和向下连接
    for i = 1: xnode_num
        for j = 1: ynode_num
            node_num = (i-1) * ynode_num + j;
            if i ~= Mesh.xelem_num + 1
                Mesh.conn = [Mesh.conn, [node_num; node_num + ynode_num]];
            end
            if j ~= Mesh.yelem_num +1
                Mesh.conn = [Mesh.conn, [node_num ; node_num + 1]];
            end
        end
    end
    
    % 计算连接的点的线
else % 平面8节点单元局部坐标矩阵
    Mesh.node_number =  (3 * Mesh.yelem_num + 2)* Mesh.xelem_num + 2 * Mesh.yelem_num + 1;
    temp = double(3 * Mesh.yelem_num + 2);  % 每一行前面的元素数量
    for i = 1: double(Mesh.elem_number)
        elem_x = ceil(i/double(Mesh.yelem_num));
        elem_y = i - (elem_x-1) * Mesh.yelem_num;
        Table(7,i) = temp*(elem_x-1) + 2 *(elem_y -1) + 1;
        Table(8,i) = Table(7,i) + 1;
        Table(1,i) = Table(7,i) + 2;
        Table(6,i) = temp*(elem_x-1) + 2*Mesh.yelem_num +1+ elem_y;
        Table(2,i) = Table(6,i) + 1;
        Table(5,i) = temp * elem_x + 2 *(elem_y -1) + 1;
        Table(4,i) = Table(5,i) + 1;
        Table(3,i) = Table(5,i) + 2;
    end % 计算八节点每个单元中的对应的全局坐标矩阵
    % 计算网格Node的横坐标和纵坐标
    Mesh.node_xloc = []; Mesh.node_yloc = [];
    for i = 1: 2 * double(Mesh.xelem_num) + 1
        if mod(i,2) == 0
            Mesh.node_xloc = [Mesh.node_xloc, (i-1) * Mesh.dx * ones(1, Mesh.yelem_num +1)];
            Mesh.node_yloc = [Mesh.node_yloc, 0: dy: h];
        else
            Mesh.node_xloc = [Mesh.node_xloc, (i-1) * Mesh.dx * ones(1, Mesh.yelem_num*2 +1)];
            Mesh.node_yloc = [Mesh.node_yloc, 0: dy/2: h];
        end
    end
    
    for i = 1: double(Mesh.xelem_num +1)
        % 八节点部分，如果i%2!=0, 则每一个节点,仅向下连接, 如果是中间点，连左右两个点
        if mod(i,2) == 0
            % 前面的列的节点个数
            pre_node_num = (i/2 -1) * (3 * Mesh.yelem_num + 2) + 2 * Mesh.yelem_num + 1;
            % 此时连接左右两个节点
            for j = 1: Mesh.yelem_num +1
                node_num = pre_node_num + j;
                Mesh.conn = [Mesh.conn, [node_num, pre_node_num - (2 * Mesh.yelem_num + 1) + 2 * j -1]];               
                Mesh.conn = [Mesh.conn, [node_num; pre_node_num + Mesh.yelem_num + 2 * j]];
            end
        else % 不向右连接，仅向下连接
            pre_node_num = ceil(i/2 -1) * (3 * Mesh.yelem_num + 2);
            for j = 1: 2 * Mesh.yelem_num 
                node_num = pre_node_num + j;
                Mesh.conn = [Mesh.conn, [node_num; node_num +1]];
            end
        end
    end
end
% 进行矩阵的转置, 用列向量求解
Mesh.node_xloc = Mesh.node_xloc';
Mesh.node_yloc = Mesh.node_yloc';

% 节点的连接情况


Mesh.cord_table = Table;  % 传回局部坐标矩阵
% Test Code: automesh(28, 300, 4, "normal")
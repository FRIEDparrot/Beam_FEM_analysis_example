function  load_vector = apply_pressure(Mesh,Load)
%APPLY_PRESSURE 分配节点力，在梁上施加竖直向下的均布载荷(仅适用于简单载荷编号)
%   Mesh: 传入网格
    load_vector = zeros(2 * Mesh.node_number,1);  % 生成总的载荷向量
    if Mesh.elem_node_number == 8
        node_num = zeros(Mesh.xelem_num * 2 + 1 ,1);
        node_num(1:2:end) = 2 : 2 * (3 * Mesh.yelem_num + 2) : 2 * Mesh.node_number - 2 * Mesh.yelem_num;
        node_num(2:2:end-1) = 4 * (Mesh.yelem_num + 1) : 2 * (3 * Mesh.yelem_num + 2): 2 * (Mesh.node_number - 3 * Mesh.yelem_num-1);
        first_point = double(node_num(1:end-1));
        second_point = double(node_num(2:end));
        load_vector(first_point) = Load/2;
        load_vector(second_point) = load_vector(second_point) + Load/2;
        % 其中需要注意的是，坐标是y向下方向为正的，因此使用100,200等载荷
    else % 4 节点单元或者3节点单元
        % 按照节点编号计算对应的
        node_num = 2: 2 *(Mesh.yelem_num + 1) : 2 * Mesh.node_number - 2 * Mesh.yelem_num;
        first_point = double(node_num(1:end-1));
        second_point = double(node_num(2:end));
        load_vector(first_point) = Load/2;
        load_vector(second_point) = load_vector(second_point) + Load/2;
    end
end


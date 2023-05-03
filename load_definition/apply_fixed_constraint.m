function displacement_vector = apply_fixed_constraint(Mesh,displacement_vector)
% 施加位移约束边界条件
% 只需要将右侧面的所有的点的位移(u,v)设置为0即可
    if Mesh.elem_node_number == 4
        displacement_vector((Mesh.node_number-Mesh.yelem_num)*2 -1:Mesh.node_number*2) = 0;
    else % 对于8节点单元
        displacement_vector(2*(Mesh.node_number-Mesh.yelem_num*2) -1:Mesh.node_number*2) = 0;
    end
end
function [MSRC_graph_train,MSRC_graph_test,MSRC_label_train,MSRC_label_test] = MSRC_segment(MSRC_graph,MSRC_label,idx_train,idx_test)
% ��MSRC���ֳɺü���ѵ�����Ͳ��Լ�
for i=1:length(idx_train)
    MSRC_graph_train{i}=MSRC_graph{idx_train(i)};
    MSRC_label_train(i,:)=MSRC_label(idx_train(i),:);
end
for j=1:length(idx_test)
    MSRC_graph_test{j}=MSRC_graph{idx_test(j)};
    MSRC_label_test(j,:)=MSRC_label(idx_test(j),:);
end

MSRC_label_train=MSRC_label_train';
MSRC_label_test=MSRC_label_test';
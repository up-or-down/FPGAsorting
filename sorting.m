% %% k-means聚类，（基于FSDE特征），输入为选择的特征；当以HAMMING编码方式聚类观察结果时，应以pca结果为参考标准（clusters）
num_clusters = 3;
Mclusters = struct;
distance = zeros(1,num_clusters);
% initialize
for j = 1:num_clusters
    Mclusters(j).spikes = [j+6]; %clusters.spikes记录该簇内spike的索引
    Mclusters(j).num = 1;
    Mclusters(j).center = double(HAMMC(j,:));
%     Mclusters(j).center = FSDE(j,:);
%     Mclusters(j).center = double(filtered(j,:))*100;
    Mclusters(j).next_center = Mclusters(j).center; %??spike???next
end
flag = 1; % indicate whether to iterate
iter_num = 1;
while flag 
    flag = 0;
    for i = 1:spike_num
        if sorted_spike(target_ch).label(i)~=0&&sorted_spike(target_ch).label(i)~=4 %剔除某些噪声类观察效果，RQ数据集本身不包含0,4
            tmp = double(HAMMC(i,:));
%             tmp = FSDE(i,:);
%             tmp = double(filtered(i,:))*100;
%             ii = mean((tmp-mean(tmp)).*(tmp-mean(tmp)));
            for j=1:num_clusters  %各簇中心分别计算距离，总的原则一种是确定中心后聚类,难点是如何确定中心?定点运算不方便确定平均值，改成随机选点；另一种是根据阈值自动成簇，可能导致簇数量过多
%                 distance(j) = sum(abs(tmp-Mclusters(j).next_center));
%                 ia = mean((tmp-mean(tmp)).*(Mclusters(j).next_center-mean(Mclusters(j).next_center)));
%                 aa = mean((Mclusters(j).next_center-mean(Mclusters(j).next_center)).*(Mclusters(j).next_center-mean(Mclusters(j).next_center)));
%                 distance(j) = ia^2/(ii*aa); % 相关性度量
                distance(j) = norm(Mclusters(j).next_center-tmp); % 欧式距离度量
            end
            if i<50  %仅打印部分用于比较数值是否具有区分能力
                disp([i,distance])
            end
            [~,result] = min(distance); % 欧氏距离度量时取最小距离
            not_in = 1;
%             [val,result] = max(distance); %相似度度量时相关性取最大
%             if val<0.01   %相似度不够则仅聚进去但不更新中心点
%                 not_in = 0;
%             else
%                 not_in = 1;
%             end
            if not_in
                Mclusters(result).center = Mclusters(result).center+tmp; %当使用随机取中心点的方式时不执行此处中心点更新运算
                Mclusters(result).num = Mclusters(result).num+1;      
                Mclusters(result).spikes = [Mclusters(result).spikes;i];
            end
        end
    end
    for j = 1:num_clusters  %将全数据集遍历一遍，判断此轮聚类结果是否收敛
        Mclusters(j).center = Mclusters(j).center/Mclusters(j).num; %当使用随机取中心点的方式时不执行此处中心点更新运算
%         Mclusters(j).center = HAMMC(Mclusters(j).spikes(randi(Mclusters(j).num)),:); 
        if norm(Mclusters(j).next_center-Mclusters(j).center)>0  % have not converged
            flag = flag||1;
        end
    end
    disp("running iter: "+num2str(iter_num));
    iter_num = iter_num + 1;
    if iter_num > 50
        break;
    end
    for j = 1:num_clusters  % ???????????????
        Mclusters(j).next_center = Mclusters(j).center;
        if flag  % 清空数据，准备下一次迭代
            Mclusters(j).num = 0;
            Mclusters(j).spikes = [];
            Mclusters(j).center = zeros(size(Mclusters(j).next_center));
        end
    end
end

%% 定量计算各种方法准确率，并绘制混淆矩阵图
target_label = uint8(sorted_spike(target_ch).label);
predict_label = uint8(zeros(size(target_label)));
for j=1:num_clusters
    for i=1:Mclusters(j).num
        predict_label(Mclusters(j).spikes(i)) = j;
    end
end
figure(7)
confusionchart(target_label,predict_label)


%% 输入clusters, sorted_spike, target_ch, color，绘制所用方法聚类结果在PCA空间中的显示
figure(4)
for j=1:num_clusters
    if Mclusters(j).num>0
        for i=1:Mclusters(j).num
%             subplot(2,2,j)
%             plot(target_spikes(clusters(j).spikes(i),:),color(2*j-1));
%             hold oni
% 在处理高维特征时，因不易表现，故以pca结果为基础展示新特征聚类结果，新特征的结果用颜色表示
              index = Mclusters(j).spikes(i); %指定簇j的第i个spike索引
              plot3(pca_result(index,1),pca_result(index,2),pca_result(index,3),color(2*j-1:2*j)); %特征空间点的分布发现，在单通道的数据处理情况下，仅需前两个维度就可将数据分开
              %plot(pca_result(index,1),pca_result(index,2),color(2*j-1:2*j)); 
              hold on
        end
    end
end
set(gca,'FontName','Times New Roman','FontSize',25);
xlabel( 'Feature PC1', 'Fontsize', 25);
ylabel( 'Feature PC2', 'Fontsize', 25)
zlabel( 'Feature PC3', 'Fontsize', 25);

%% 绘pca聚类结果图，某单一簇的spike集合
figure(5)
for j=1:num_clusters %j=3的索引下为真实spike
    subplot(3,3,j)    
    for i = 1:Mclusters(j).num
        plot(filtered(Mclusters(j).spikes(i),:));
        hold on
    end
end

%% 按照PCA分类结果将同一簇的特征绘制在一起
figure(6)
for i=1:length(Mclusters)
    subplot(3,3,i)
    for j=1:Mclusters(i).num
        tmp = HAMMC(Mclusters(i).spikes(j),:);
        for k=2:length(tmp)
           tmp(k) = tmp(k)+tmp(k-1);
        end
        plot(tmp) 
%         drawnow;
%         pause(0.01);
        hold on 
    end
end


%% 查看聚类结果在pca空间的效果
for i=1:spike_num
    j = predict_label(i);
    plot3(pca_result(i,1),pca_result(i,2),pca_result(i,3),color(2*j-1:2*j));
    hold on
    if i<4
    drawnow;
    pause(3)
    end
end




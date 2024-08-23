%%% 使用方法——首先load同目录下的chxx.mat数据
% 再运行process_EQ程序，最后运行feat_extrac程序
% RQ数据集下载链接：https://figshare.le.ac.uk/articles/dataset/Simulated_dataset/11897595

spike_num = length(spike_times{1});
color = ['r*','b+','go','kx','ys','m*','c+','wo','rx'];

sorted_spike=struct;
sorted_spike.name = strcat('ch',num2str(chan));
sorted_spike.spikes = [];% 直接获取的data变量是48个点为一个spike，通道如何定义？
sorted_spike.label = [];
sorted_spike.just = [];
sorted_spike.rela = [];
sorted_spike.timestamp = [];

for i=1:spike_num
    index = int32(spike_times{1}(i));
    sorted_spike.spikes = [sorted_spike.spikes;data(index:index+47)]; %涓?琛屾槸涓?涓猻pike
    sorted_spike.label = [sorted_spike.label;spike_class{1}(i)];
    sorted_spike.just = [sorted_spike.just;spike_class{2}(i)];
    sorted_spike.rela = [sorted_spike.rela;spike_class{3}(i)];
    sorted_spike.timestamp = [sorted_spike.timestamp;index];
%     figure(2)
%     plot(data(int32(spike_times{1}(i)):int32(spike_times{1}(i))+48),...
%                                 color(2*int8(spike_class{2}(i))+1));
% 
%         if spike_class{3}(i)<81&&spike_class{3}(i)>70
%             plot(data(int32(spike_times{1}(i)):int32(spike_times{1}(i))+48))
%         end
%         hold on
%     
end
target_spikes = sorted_spike.spikes;
target_label = uint8(sorted_spike.label); %因为要做索引故转换为int类型
target_ch = 1;  % 每份data只有一个通道
coeff = pca(target_spikes);
pca_result = target_spikes*coeff(:,1:3);
filtered = target_spikes;

% %% 绘图，某单一通道的spike集合
% figure(2);
% set(gca,'FontName','Times New Roman','FontSize',18);
% xlabel( 'Time(step)', 'Fontsize', 17);
% ylabel( '$ y $ position','Interpreter','latex', 'Fontsize', 19)
% for k = 1:length(sorted_spike(target_ch).spikes)
%     plot(sorted_spike(target_ch).spikes(k,:),color(1+sorted_spike(target_ch).label(k)));
%     hold on
% end
%% 
figure(1)
for k = 1:length(sorted_spike(1).spikes)
    label = sorted_spike(target_ch).label(k);
%     subplot(2,2,label)
    plot(sorted_spike(target_ch).spikes(k,:),color(2*label-1));
    hold on
end
set(gca,'FontName','Times New Roman','FontSize',25);
xlabel( 'Time Step ', 'Fontsize', 25);
ylabel( 'Normalized Amplitude', 'Fontsize', 25)

%% pca&pca_result,三维空间内的聚类分布,相当于ground truth
figure(3);
for i=1:spike_num
    label = sorted_spike(target_ch).label(i);
    plot3(pca_result(i,1),pca_result(i,2),pca_result(i,3),color(2*label-1:2*label));
    hold on
end
set(gca,'FontName','Times New Roman','FontSize',25);
xlabel( 'Feature PC1', 'Fontsize', 25);
ylabel( 'Feature PC2', 'Fontsize', 25)
zlabel( 'Feature PC3', 'Fontsize', 25);

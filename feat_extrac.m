%% 将某个或某些通道的spike集合在一起写入txt. 执行本程序发现matlab在涉及存储操作时运算速度较慢
chan = 2;%？
h = fopen(strcat('matlab_out',num2str(chan),'.txt'),'w'); %文件名
width = min(size(target_spikes));%size有两个元素，大数为spike样本数，小数为spike采样长度
count = 0;
FD = zeros(length(target_spikes),width-1); %FD与SD存储一个通道的所有spike线性特征
SD = zeros(length(target_spikes),width-2);
for i=1:length(target_spikes)
    tmp_spike = target_spikes(i,:)*1000;
    for j = 1:width
        tmp = dec2hex(typecast(int32(tmp_spike(j))+32768,'uint32'),4); %此处输出tmp应为4个16进制数字符串表示
%         fprintf(h,'%s',strcat(tmp(1:2)," ",tmp(3:4)," "));
        count = count + 2;
        if mod(count,144)==0
%             fprintf(h,'%s',strcat('AA'," ",'5A'," "));
            count = 0;
        end
%% 测试sorting算子
        % 计算FD与SD特征
        if j<width
            FD(i,j) = target_spikes(i,j+1)-target_spikes(i,j);
            if j>1    
                SD(i,j-1) = FD(i,j)-FD(i,j-1);
            end
        end
    end
end
fclose(h);

%% 特征提取——FSDE特征
close all;
% color = ['r*','b+','go','kx','ys','m*','c+','wo','rx']; %颜色和符号均标明时注意索引方式，此时color长度为2倍
% % % %color = ['r','b','g','k','y']; %只标注颜色不注明符号绘制不出图形
FSDE = zeros(spike_num,5);
figure(1);
for i = 1:spike_num
    FSDE(i,1) = max(FD(i,:));
    FSDE(i,2) = min(FD(i,:));
    FSDE(i,3) = max(SD(i,:));
    FSDE(i,4) = min(SD(i,:));
    FSDE(i,5) = max(target_spikes(i,:))-min(target_spikes(i,:));
    label = sorted_spike(target_ch).label(i);
    if label==0
        subplot(2,2,1)
        plot(target_spikes(i,:),color(2*label+1));
        hold on
    elseif label==1
        subplot(2,2,2)
        plot(target_spikes(i,:),color(2*label+1));
        hold on
    elseif label==2
        subplot(2,2,3)
        plot(target_spikes(i,:),color(2*label+1));
        hold on
    elseif label==3
        subplot(2,2,4)
        plot(target_spikes(i,:),color(2*label+1));
        hold on
    else
        a=1;
    end
end

%% 尝试对FSDE归一化
for i=1:spike_num
    FSDE(i,1) = (FSDE(i,1)-min(FSDE(:,1)))/(max(FSDE(:,1))-min(FSDE(:,1)));
    FSDE(i,2) = (FSDE(i,2)-min(FSDE(:,2)))/(max(FSDE(:,2))-min(FSDE(:,2)));
    FSDE(i,3) = (FSDE(i,3)-min(FSDE(:,3)))/(max(FSDE(:,3))-min(FSDE(:,3)));
    FSDE(i,4) = (FSDE(i,4)-min(FSDE(:,4)))/(max(FSDE(:,4))-min(FSDE(:,4)));
    FSDE(i,5) = (FSDE(i,5)-min(FSDE(:,5)))/(max(FSDE(:,5))-min(FSDE(:,5)));
end
%%
figure(2);
for i=1:spike_num
    label = sorted_spike(target_ch).label(i);
    plot3(FSDE(i,2),FSDE(i,3),FSDE(i,5),color(2*label+1:2*label+2)); %因数据集问题，暂不能判断出算法是否有效
    hold on
end

%% hamming distance && PCA,输入为待处理的数据集处理得到特征
[h,w] = size(target_spikes);
HAMMC = zeros(h,w-1); % 此时是多维特征，不易表示为空间点，仅可观察聚类结果，可参考PCA的标签
for i=1:spike_num
    for j=1:w-2
        if filtered(i,j+1)>filtered(i,j)
            HAMMC(i,j) = 1;
        else
            HAMMC(i,j) = 0;
        end
    end
end

%% 考虑到直接应用一阶特征区分度不高，推测由于在一阶微分时损失细节过多，故考虑二阶微分再做0-1压缩;
% 确实0-1之间展的更开，但聚类的很散
% [h,w] = size(filtered);
% DSD = zeros(h,w-2); % 离散二阶微分
% for i=1:spike_num % 每个spike一条压缩结果
%     for j=1:w-2
%         if (filtered(i,j+2)-filtered(i,j+1))-(filtered(i,j+1)-filtered(i,j))>0
%             DSD(i,j) = 1;
%         else
%             DSD(i,j) = 0;
%         end
%     end
% end

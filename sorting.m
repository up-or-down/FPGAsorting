% %% k-means���࣬������FSDE������������Ϊѡ�������������HAMMING���뷽ʽ����۲���ʱ��Ӧ��pca���Ϊ�ο���׼��clusters��
num_clusters = 3;
Mclusters = struct;
distance = zeros(1,num_clusters);
% initialize
for j = 1:num_clusters
    Mclusters(j).spikes = [j+6]; %clusters.spikes��¼�ô���spike������
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
        if sorted_spike(target_ch).label(i)~=0&&sorted_spike(target_ch).label(i)~=4 %�޳�ĳЩ������۲�Ч����RQ���ݼ���������0,4
            tmp = double(HAMMC(i,:));
%             tmp = FSDE(i,:);
%             tmp = double(filtered(i,:))*100;
%             ii = mean((tmp-mean(tmp)).*(tmp-mean(tmp)));
            for j=1:num_clusters  %�������ķֱ������룬�ܵ�ԭ��һ����ȷ�����ĺ����,�ѵ������ȷ������?�������㲻����ȷ��ƽ��ֵ���ĳ����ѡ�㣻��һ���Ǹ�����ֵ�Զ��ɴأ����ܵ��´���������
%                 distance(j) = sum(abs(tmp-Mclusters(j).next_center));
%                 ia = mean((tmp-mean(tmp)).*(Mclusters(j).next_center-mean(Mclusters(j).next_center)));
%                 aa = mean((Mclusters(j).next_center-mean(Mclusters(j).next_center)).*(Mclusters(j).next_center-mean(Mclusters(j).next_center)));
%                 distance(j) = ia^2/(ii*aa); % ����Զ���
                distance(j) = norm(Mclusters(j).next_center-tmp); % ŷʽ�������
            end
            if i<50  %����ӡ�������ڱȽ���ֵ�Ƿ������������
                disp([i,distance])
            end
            [~,result] = min(distance); % ŷ�Ͼ������ʱȡ��С����
            not_in = 1;
%             [val,result] = max(distance); %���ƶȶ���ʱ�����ȡ���
%             if val<0.01   %���ƶȲ�������۽�ȥ�����������ĵ�
%                 not_in = 0;
%             else
%                 not_in = 1;
%             end
            if not_in
                Mclusters(result).center = Mclusters(result).center+tmp; %��ʹ�����ȡ���ĵ�ķ�ʽʱ��ִ�д˴����ĵ��������
                Mclusters(result).num = Mclusters(result).num+1;      
                Mclusters(result).spikes = [Mclusters(result).spikes;i];
            end
        end
    end
    for j = 1:num_clusters  %��ȫ���ݼ�����һ�飬�жϴ��־������Ƿ�����
        Mclusters(j).center = Mclusters(j).center/Mclusters(j).num; %��ʹ�����ȡ���ĵ�ķ�ʽʱ��ִ�д˴����ĵ��������
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
        if flag  % ������ݣ�׼����һ�ε���
            Mclusters(j).num = 0;
            Mclusters(j).spikes = [];
            Mclusters(j).center = zeros(size(Mclusters(j).next_center));
        end
    end
end

%% ����������ַ���׼ȷ�ʣ������ƻ�������ͼ
target_label = uint8(sorted_spike(target_ch).label);
predict_label = uint8(zeros(size(target_label)));
for j=1:num_clusters
    for i=1:Mclusters(j).num
        predict_label(Mclusters(j).spikes(i)) = j;
    end
end
figure(7)
confusionchart(target_label,predict_label)


%% ����clusters, sorted_spike, target_ch, color���������÷�����������PCA�ռ��е���ʾ
figure(4)
for j=1:num_clusters
    if Mclusters(j).num>0
        for i=1:Mclusters(j).num
%             subplot(2,2,j)
%             plot(target_spikes(clusters(j).spikes(i),:),color(2*j-1));
%             hold oni
% �ڴ����ά����ʱ�����ױ��֣�����pca���Ϊ����չʾ���������������������Ľ������ɫ��ʾ
              index = Mclusters(j).spikes(i); %ָ����j�ĵ�i��spike����
              plot3(pca_result(index,1),pca_result(index,2),pca_result(index,3),color(2*j-1:2*j)); %�����ռ��ķֲ����֣��ڵ�ͨ�������ݴ�������£�����ǰ����ά�ȾͿɽ����ݷֿ�
              %plot(pca_result(index,1),pca_result(index,2),color(2*j-1:2*j)); 
              hold on
        end
    end
end
set(gca,'FontName','Times New Roman','FontSize',25);
xlabel( 'Feature PC1', 'Fontsize', 25);
ylabel( 'Feature PC2', 'Fontsize', 25)
zlabel( 'Feature PC3', 'Fontsize', 25);

%% ��pca������ͼ��ĳ��һ�ص�spike����
figure(5)
for j=1:num_clusters %j=3��������Ϊ��ʵspike
    subplot(3,3,j)    
    for i = 1:Mclusters(j).num
        plot(filtered(Mclusters(j).spikes(i),:));
        hold on
    end
end

%% ����PCA��������ͬһ�ص�����������һ��
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


%% �鿴��������pca�ռ��Ч��
for i=1:spike_num
    j = predict_label(i);
    plot3(pca_result(i,1),pca_result(i,2),pca_result(i,3),color(2*j-1:2*j));
    hold on
    if i<4
    drawnow;
    pause(3)
    end
end




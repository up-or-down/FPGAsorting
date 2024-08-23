%% ��ĳ����ĳЩͨ����spike������һ��д��txt. ִ�б�������matlab���漰�洢����ʱ�����ٶȽ���
chan = 2;%��
h = fopen(strcat('matlab_out',num2str(chan),'.txt'),'w'); %�ļ���
width = min(size(target_spikes));%size������Ԫ�أ�����Ϊspike��������С��Ϊspike��������
count = 0;
FD = zeros(length(target_spikes),width-1); %FD��SD�洢һ��ͨ��������spike��������
SD = zeros(length(target_spikes),width-2);
for i=1:length(target_spikes)
    tmp_spike = target_spikes(i,:)*1000;
    for j = 1:width
        tmp = dec2hex(typecast(int32(tmp_spike(j))+32768,'uint32'),4); %�˴����tmpӦΪ4��16�������ַ�����ʾ
%         fprintf(h,'%s',strcat(tmp(1:2)," ",tmp(3:4)," "));
        count = count + 2;
        if mod(count,144)==0
%             fprintf(h,'%s',strcat('AA'," ",'5A'," "));
            count = 0;
        end
%% ����sorting����
        % ����FD��SD����
        if j<width
            FD(i,j) = target_spikes(i,j+1)-target_spikes(i,j);
            if j>1    
                SD(i,j-1) = FD(i,j)-FD(i,j-1);
            end
        end
    end
end
fclose(h);

%% ������ȡ����FSDE����
close all;
% color = ['r*','b+','go','kx','ys','m*','c+','wo','rx']; %��ɫ�ͷ��ž�����ʱע��������ʽ����ʱcolor����Ϊ2��
% % % %color = ['r','b','g','k','y']; %ֻ��ע��ɫ��ע�����Ż��Ʋ���ͼ��
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

%% ���Զ�FSDE��һ��
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
    plot3(FSDE(i,2),FSDE(i,3),FSDE(i,5),color(2*label+1:2*label+2)); %�����ݼ����⣬�ݲ����жϳ��㷨�Ƿ���Ч
    hold on
end

%% hamming distance && PCA,����Ϊ����������ݼ�����õ�����
[h,w] = size(target_spikes);
HAMMC = zeros(h,w-1); % ��ʱ�Ƕ�ά���������ױ�ʾΪ�ռ�㣬���ɹ۲���������ɲο�PCA�ı�ǩ
for i=1:spike_num
    for j=1:w-2
        if filtered(i,j+1)>filtered(i,j)
            HAMMC(i,j) = 1;
        else
            HAMMC(i,j) = 0;
        end
    end
end

%% ���ǵ�ֱ��Ӧ��һ���������ֶȲ��ߣ��Ʋ�������һ��΢��ʱ��ʧϸ�ڹ��࣬�ʿ��Ƕ���΢������0-1ѹ��;
% ȷʵ0-1֮��չ�ĸ�����������ĺ�ɢ
% [h,w] = size(filtered);
% DSD = zeros(h,w-2); % ��ɢ����΢��
% for i=1:spike_num % ÿ��spikeһ��ѹ�����
%     for j=1:w-2
%         if (filtered(i,j+2)-filtered(i,j+1))-(filtered(i,j+1)-filtered(i,j))>0
%             DSD(i,j) = 1;
%         else
%             DSD(i,j) = 0;
%         end
%     end
% end

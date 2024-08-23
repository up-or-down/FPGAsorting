# FPGAsorting
spike-sorting implemented on FPGA

该组数据来源于https://figshare.le.ac.uk/articles/dataset/Simulated_dataset/11897595
，详细介绍如下：

从基底神经节和新皮层采集的皮质内在体记录，包含594个不同的spike波形，归一化噪声范围0.05-0.2
相当于SNR范围3-16
据文中表示数据集链接——http://www.vis.caltech.edu/~rodri. 
但打不开，page not found；不知道2022年和2023年两篇文章是怎么找到的数据

在bing国际版搜索人名+数据集，找到一个链接：显示由R.Q Quiroga在2020年2月26上传
https://figshare.le.ac.uk/articles/dataset/Simulated_dataset/11897595
不知道是不是对应，先凑活着用吧。虽然下载了数据但是没有数据集解释及处理方法，几乎没什么用

# 数据集mat内变量包括：
data：为一个通道一维时间序列，采样时间为1分钟，采样率24kHz
OVERLAP_DATA：暂未看懂其意思
samplingInterval：采样间隔，单位为毫秒ms，0.0417ms对应24kHz
spike_class：3个长度为3522的数组，第一个数组取值为1-3，代表三种spike；第二个取值为0,1，统计为0有2753个，1有769个，且对应标签为0的spike为干净的对齐spike，标签为1的既有三种groundtruth也有噪声波形；第三个取值不规则，大部分为0，其余在0-80之间随机分布，似乎表示一致性，因为数值越大的标签对应的spike绘制出来越整齐。
spike_times：一个长度为3522的数组，代表各spike出现的时间戳（应该是尖峰索引）

在数据及内部，用通道来表示不同文件夹下的数据：
channel=1     ======   C_Easy1_noise01，简单数据，噪声0.1

channel=2     ======   C_Easy1_noise02

channel=3     ======   C_Easy1_noise03

channel=4     ======   C_Easy1_noise04

channel=5     ======   C_Easy1_noise005

channel=6     ======   C_Easy1_noise015

channel=7     ======   C_Easy1_noise025

channel=8     ======   C_Easy1_noise035

channel=21     ======   C_Easy2_noise01

channel=22     ======   C_Easy2_noise02

channel=25     ======   C_Easy2_noise005

channel=26     ======   C_Easy2_noise015

channel=101     ======   C_Difficult1_noise01

channel=102     ======   C_Difficult1_noise02

channel=105     ======   C_Difficult1_noise005

channel=106     ======   C_Difficult1_noise015

channel=121     ======   C_Difficult2_noise01

channel=122     ======   C_Difficult2_noise02

channel=125     ======   C_Difficult2_noise005

channel=126     ======   C_Difficult2_noise015



# 程序介绍如下：
原始数据保存在所里台式机内，存储路径为D:\postgraduate\research\direction\Algorithm\JSSC-Osort\R.Q.Quirogadataset\Simulator
在matlab中首先打开上述easy或difficult数据，原始数据包含data、OVERLAP_DATA、sampling_interval、spike_class、spike_times
## 1、运行process_RQ.m程序
用于基于data出发获取sorted_spike，整理出固定长度的spike矩阵，做pca分析得到pca矩阵；figure(1)根据原始数据中的label直接绘制原波形；figure(3)基于pca矩阵获得pca空间spike特征点的分布情况；本文件还保留了为spike滤波的条件，滤波后的变量命名为filtered；
## 2、运行feat_extrac.m程序
进一步提取特征，一方面为了之后verilog读取，在本程序中对spike扩大1000倍后以16进制形式写到matlab_outxx.txt文本中，同时在遍历过程完成对FD、SD的计算，然后对每个spike计算FD和SD的最大值，从而计算出FSDE，在此次遍历过程完成对spike波形的绘制，这一步和上一步的figure(1)不同之处在于这里以子图的方式分别绘制每一类spike，可以观察spike的聚合程度；然后对所有spike的FSDE特征归一化，figure(2)绘制出在FSDE空间中的分布情况；接下来，再次遍历所有spike计算HAMMC，本程序主要功能为计算特征和转化txt文本，故画图不多；
## 3、进入最核心程序sorting.m
在这里执行sorting算法，由于功能多，可以用ctrl+enter分别运行每个小节。首先定义聚类的目标簇数，据此创建空结构体，随后对模拟按时间顺序到来的spike，在结构体中存在空簇时优先将当前spike分到空的簇，即使与之前某个簇中的spike很接近。然后遍历所有spike 的HAMMC特征，计算与各簇中心的距离，将当前spike分到最近距离的簇同时更新该簇中心，数据集内spike都聚类之后保存各簇中心点，清除本次的spike特征，继续进行下一轮迭代。两轮迭代后各簇中心点距离不变后认为收敛。在计算准确率时直接将结构体拿来运算即可。

# 绘图时：
据参考文献“An Online-Spike-Sorting IC Using Unsupervised Geometry-Aware OSort Clustering for Efficient Embedded Neural-Signal Processing, Chenyingping”，spike横坐标为Time Step, 纵坐标为Normalized Amplitude
PCA图中，分量坐标标签记为PC1、PC2（Feature extraction using first and second derivative extrema (FSDE) for real-time and hardware-efficient spike sorting），也有记为Feature1、Feature2(Accurate, Very low computational complexity spike sorting using unsupervised matched subspace learning)

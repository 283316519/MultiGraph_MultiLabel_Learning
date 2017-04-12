 %��ѵ������
 %{
data=importdata('corel5k_train_list.txt');
    length=length(data);
    path='./������Corel5k���ݼ�(����ע,ѵ������Լ�)/';
    gBagsTrain=cell(1,length);
    for i=1:length
        img_path=strcat(path,data{i},'.jpeg');
        im=imread(img_path);
        %����ͼƬ
        %������
    end
 %}
clc;
clear;
tic;
run('./vlfeat-0.9.20-bin\vlfeat-0.9.20\toolbox\vl_setup')
data=importdata('./������Corel5k���ݼ�(����ע,ѵ������Լ�)/corel5k_test_list.txt');%�����ļ�����

    length=length(data);
    
    path='./������Corel5k���ݼ�(����ע,ѵ������Լ�)/';
    gBagsTest=cell(1,length);%%����test��
    for i=1:length
        img_path=strcat(path,data{i},'.jpeg');
        im=imread(img_path);
       %����ͼƬ 
        ims = im2single(im) ;
        regionSize = 10 ;
        regularizer = 10 ;
        segments = vl_slic(ims, regionSize, regularizer);
        regionSize2 = 50;
        segments2 = vl_slic(ims, regionSize2, regularizer);
        minS=min(min(segments));%��segments�����е���Сֵ
        maxS=max(max(segments));%��segments�����е����ֵ
        [ms ns]=size(segments);

        %ȷ��ÿ������4096�еĵڼ�ά
        [a0 b0 c0]=size(im);
        im1=double(im);%�������͵Ĺ�ϵ��Ϊ�˺���ļ��㣬ת��im������Ϊdouble��
        imt=floor(im1./16);%����ת����һ���������ͣ��������4096ʱ�����;16bin;����ȡ��
        %(����������Ҳ������������ֱ������ȡ��)
        ref4096=zeros(a0,b0);%�˾����¼�����Ӧ4096ά�еĵڼ�ά
        %��Ϊ��RGB��ά��ֱ�Ӱ�RGB�ɸߵ��͵�˳��ӱ��������Ӧ��4096ֵ
        %����x=R*(16^2)+B*16+G;
        ref4096=imt(:,:,1).*(16^2)+imt(:,:,2).*16+imt(:,:,3);%ȡֵ��Χ0-4095

        %���ɸ������ص��Ӧ��4096ά����
        SuperPixel4096=zeros(1,max(max(segments))+1);%��ΪMATLAB�о����1��ʼ�����Ե�i�������ص��Ӧ�������Ǳ������еĵ�i+1��
        %��ͬ��ref4096����ref4096(i,j)=m,���Ӧ����SuperPixel4096�е�i+1�У�j+1�е�ֵ+1

        for r1=minS:maxS %��ʱ�벻����for����Ч�ʵķ���
            temp4096=zeros(1,4096);
            idx=find(segments==r1);%idx��һ��������
            temp=ref4096(idx);
            if size(idx)>0
                for r2=1:size(idx)
                 temp4096(temp(r2)+1)=temp4096(temp(r2)+1)+1;
                end
            end
            %ȡ4096��ֵ����һά
            [t idxm]=max(temp4096);
            SuperPixel4096(r1+1)=idxm;
        end
%��������������ĳ����ص�
    minR=min(min(segments2));%��segments�����е���Сֵ
    maxR=max(max(segments2));%��segments�����е����ֵ
    RegionV=zeros(maxR+1,maxS+1);%����ÿ�������SP����¼ÿ��������ͼ��������Щ�����ص�ľ���
    for r1=minR:maxR
        idxi=find(segments2==r1);
        tempi=double(segments(idxi));
        tablei=tabulate(tempi);%tabulate��һ�����������и������ֵ�Ƶ���ĺ�����������˳��
         %tablet=double(tablet);
        idxi1=find(tablei(:,2)~=0);%�ҳ�������Ƶ����Ϊ0��ֵ    
        [m1 n1]=size(idxi1);
      
        RegionV(r1+1,1:m1)=tablei(idxi1,1)';%RegionV�д����ʵ�ʳ����ص����
    
    end
graphSP=zeros(maxR+1,maxS+1,maxS+1);%
graphs=cell(1,maxR+1);
%����Ϊ�������ϵ����ͼ0��Ӧ��ͼ��graph����Ϊ��һάֵΪ1��Ӧ�ľ���

for r1=1:(maxR+1)%Ȧ��Χ�ҵ㷨���б�Ե���--�ѱ������ĵ�ử������
       %graphi=cell(2,1);
       edges=[];
      
        [mi ni]=find(segments2==(r1-1));%ȷ��segments�ж�Ӧ��segments2��i�����λ�ã�ע�����ֵ��ʵ����ֵ�Ķ�Ӧ
        Vertexi=find(RegionV(r1,:)~=0);%��¼����i������Щsuperpixel
        idxnl=Vertexi';
        if idxnl(1)~=1%�ų�һ��С�İ�0�����ص��Ʋ�˵Ĵ���
            idxnl=[1;idxnl];
        end
        [idxnlx,idxnly]=size(idxnl);%��֪����Ϊʲô�����ú���length()
        [Vertexix,Vertexiy]=size(Vertexi);
         nodelabels=zeros(idxnlx,1);
         nodelabels=SuperPixel4096(RegionV(r1,idxnl)'+1)'-1;
        for r2=1:Vertexiy
            [mj nj]=find(segments==RegionV(r1,r2));
            segt=segments(max(min(mj)-1,min(mi)):min(max(mj)+1,max(mi)),max((nj)-1,min(ni)):min(max(nj)+1,max(ni)));%��������superpixlj����С��1����
             %���������򻭵ıȽϴֲڣ����ڶԽ���������������һ���Խ������ӣ���
            idxj=find(segt~=RegionV(r1,r2));
            tablej=tabulate(double(segt(idxj)));%���ֳ����ص�i-1��Ӧ����С�������Σ���
            idxj1=find(tablej(:,2)~=0);    
            nsq=tablej(idxj1,1);
            for m=1:size(nsq)%��ĳɴ���ǳ����ص���ͼ�е���Ȼ˳�����
                idm=0;
                if nsq(m)==0%ʡ��һ��С������һ��0
                 idm=1;
                else
                idm=find(RegionV(r1,:)==nsq(m));
            end
            if isempty(idm)~=1 %%�㷨���,�ü���һ�����Ҳ��һ�ֱܴ��ʩ��
                if graphSP(r1,r2,idm)==0 &&(r2<=idm)
                     graphSP(r1,r2,idm)=1;%�õ�ʱ��ȡ�����ķ�1λ��ֵ����1����
                     edges=[edges;r2 idm 1];
                 %ֻ��С->��Ĺ�ϵ
                % graphSP(i,nsq(m)+1,RegionV(i,j)+1)=1;%����ͼ���������������ĶԳƹ�ϵ
                    end
                end
            end
        end
    
   %graphs{r1}={nodelabels;edges};
   graphs{r1}.nodelabels=uint32(nodelabels);
   graphs{r1}.edges=uint32(edges);
    end
   
        %����ʽ������
        
        gBagsTest{i}=graphs;%����test��
        fprintf('processing:%d\n',i);

    end
    toc;
   